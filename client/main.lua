-- client/main.lua
local QBCore = exports['qb-core']:GetCoreObject()
local spawnedNPCs = {}

-- List of allowed hair colors (IDs for orange, brown, black, gray)
local allowedHairColors = {8, 3, 1, 4} -- Example IDs, these may need adjustment based on game data

-- Function to generate a random number within a range
local function randomInt(min, max)
    return math.random(min, max)
end

-- Function to select a random value from a table
local function randomFromList(list)
    return list[math.random(#list)]
end

-- Function to set a random appearance for an NPC
local function setRandomAppearance(npc)
    -- Set random hair style
    local hairDrawableId = randomInt(0, 36) -- Random hair style (adjust range as needed)
    local hairTextureId = randomFromList(allowedHairColors) -- Random hair color from allowed list
    SetPedComponentVariation(npc, 2, hairDrawableId, hairTextureId, 0)

    -- Set random beard style
    local beardDrawableId = randomInt(0, 28) -- Random beard style (adjust range as needed)
    local beardTextureId = randomFromList(allowedHairColors) -- Random beard color from allowed list
    SetPedHeadOverlay(npc, 1, beardDrawableId, 1.0) -- Beard
    SetPedHeadOverlayColor(npc, 1, 1, beardTextureId, beardTextureId) -- Beard color

    -- Set random facial hair and features
    SetPedEyeColor(npc, randomInt(0, 31)) -- Random eye color
    SetPedHeadOverlay(npc, 0, randomInt(0, 23), 1.0) -- Blemishes
    SetPedHeadOverlay(npc, 2, randomInt(0, 14), 1.0) -- Eyebrows
    SetPedHeadOverlay(npc, 10, randomInt(0, 17), 1.0) -- Chest hair
    SetPedHeadOverlayColor(npc, 10, 1, beardTextureId, beardTextureId) -- Chest hair color
end

-- Function to spawn an NPC
local function spawnNPC(locationConfig)
    local model = GetHashKey(locationConfig.npc.model)

    -- Load the model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end

    -- Create NPC ped
    local npc = CreatePed(4, model, locationConfig.npc.coords.x, locationConfig.npc.coords.y, locationConfig.npc.coords.z - 1.0, locationConfig.npc.coords.w, false, true)

    -- Set NPC clothing
    for _, cloth in ipairs(locationConfig.npc.clothes) do
        SetPedComponentVariation(npc, cloth.componentId, cloth.drawableId, cloth.textureId, 0)
    end

    -- Set NPC body armor
    if locationConfig.npc.bodyArmor then
        local armor = locationConfig.npc.bodyArmor
        SetPedComponentVariation(npc, armor.componentId, armor.drawableId, armor.textureId, 0)
    end

    -- Set random appearance
    setRandomAppearance(npc)

    -- Set a random hat if configured
    if locationConfig.npc.hats and #locationConfig.npc.hats > 0 then
        local hat = randomFromList(locationConfig.npc.hats)
        SetPedPropIndex(npc, hat.propId, hat.drawableId, hat.textureId, true) -- Set hat or head accessory
    end

    -- Set NPC properties
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    FreezeEntityPosition(npc, true)

    -- Store NPC reference
    table.insert(spawnedNPCs, npc)
end

-- Function to spawn NPCs at all armory locations
local function spawnAllNPCs()
    for _, location in ipairs(Config.ArmoryLocations) do
        if location.npc then
            spawnNPC(location)
        end
    end
end

-- Function to clean up NPCs
local function cleanupNPCs()
    for _, npc in ipairs(spawnedNPCs) do
        DeleteEntity(npc)
    end
    spawnedNPCs = {}
end

-- Main thread to detect player proximity to any armory location
Citizen.CreateThread(function()
    spawnAllNPCs() -- Spawn all NPCs at start

    while true do
        Citizen.Wait(0) -- Continuously check

        local playerPed = PlayerPedId() -- Get the player ped
        local playerCoords = GetEntityCoords(playerPed) -- Get the player's current coordinates
        local isNearArmory = false

        -- Check proximity to all armory locations
        for _, armory in ipairs(Config.ArmoryLocations) do
            local distance = #(playerCoords - armory.location) -- Calculate distance to each armory location

            -- If player is within the radius of any armory
            if distance < armory.radius then
                isNearArmory = true
                DrawText3D(armory.location.x, armory.location.y, armory.location.z, "~g~E~w~ to access the Armory")

                -- Check if the player presses the 'E' key
                if IsControlJustReleased(0, Config.ArmoryAccessKey) then
                    TriggerServerEvent('qb-armory:openArmory') -- Trigger the server event to open the armory
                end
                break
            end
        end

        if not isNearArmory then
            Citizen.Wait(500) -- If not near any armory, reduce the frequency of checks to save resources
        end
    end
end)

-- Event to show the armory menu to the player
RegisterNetEvent('qb-armory:client:showArmoryMenu', function(items)
    local menuOptions = {}

    -- Create menu options for each item in the armory
    for _, item in ipairs(items) do
        local menuText = item.category == 'item' and ("Buy " .. item.label .. " ($" .. item.cost .. " each)") or ("Take " .. item.label)
        local menuEvent = item.category == 'item' and "qb-armory:client:requestQuantity" or "qb-armory:client:giveItem"

        table.insert(menuOptions, {
            header = item.label,
            txt = menuText,
            params = {
                event = menuEvent,
                args = { itemName = item.name, itemLabel = item.label, itemCost = item.cost }
            }
        })
    end

    -- Open the menu using qb-menu
    exports['qb-menu']:openMenu(menuOptions)
end)

-- Event to request the quantity to purchase (only for items in the "item" category)
RegisterNetEvent('qb-armory:client:requestQuantity', function(data)
    local input = exports['ox_lib']:inputDialog('Purchase Quantity', {
        { label = 'Enter Quantity', type = 'number', default = 1 }
    })

    if input then
        local quantity = tonumber(input[1])
        if quantity and quantity > 0 then
            -- Trigger the server event to handle the purchase with the quantity
            TriggerServerEvent('qb-armory:server:giveItem', data.itemName, quantity)
        else
            TriggerEvent('ox_lib:notify', { type = 'error', description = "Invalid quantity entered!" })
        end
    end
end)

-- Event to request the server to give the selected item (for items in the "weapon" category)
RegisterNetEvent('qb-armory:client:giveItem', function(data)
    TriggerServerEvent('qb-armory:server:giveItem', data.itemName, 1) -- Always buy 1 if it's a weapon
end)

-- Function to draw 3D text at a specific location
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
