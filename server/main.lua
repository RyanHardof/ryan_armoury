-- server/main.lua
local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-armory:openArmory', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player and Player.PlayerData and Player.PlayerData.job and Player.PlayerData.job.name == 'police' then
        local playerGrade = Player.PlayerData.job.grade.level

        -- Filter items based on player's grade
        local availableItems = {}

        for _, item in ipairs(Config.ArmoryItems) do
            if item.grades and tableContains(item.grades, playerGrade) then
                table.insert(availableItems, item)
            end
        end

        -- Send the filtered items to the client
        TriggerClientEvent('qb-armory:client:showArmoryMenu', src, availableItems)
    else
        -- Player does not have access to the armory
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = "You do not have access to the armory!" })
    end
end)

RegisterNetEvent('qb-armory:server:giveItem', function(itemName, quantity)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    quantity = tonumber(quantity) or 1 -- Default to 1 if quantity is not provided

    if Player and Player.PlayerData and Player.PlayerData.job and Player.PlayerData.job.name == 'police' then
        -- Find the item configuration from the armory items
        local itemConfig = nil
        for _, item in ipairs(Config.ArmoryItems) do
            if item.name == itemName then
                itemConfig = item
                break
            end
        end

        if itemConfig then
            -- Ensure weapons can only be purchased one at a time
            if itemConfig.category == 'weapon' then
                quantity = 1
            end

            local totalCost = itemConfig.cost * quantity

            -- Attempt to remove money from the police society fund
            local success = exports['qb-banking']:RemoveMoney('police', totalCost, 'Armory Purchase: ' .. itemConfig.label .. ' x' .. quantity)

            if success then
                -- Give the weapon/item to the player in bulk using ps-inventory
                exports['ps-inventory']:AddItem(src, itemConfig.name, quantity) -- Adds the specified quantity of items to the player's inventory
                TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = "You have received " .. quantity .. "x " .. itemConfig.label .. " for $" .. totalCost })

                -- Log the weapon in the database using oxmysql (without serial number)
                exports.oxmysql:insert('INSERT INTO police_weapons (officer_id, officer_name, weapon_name) VALUES (?, ?, ?)', {
                    Player.PlayerData.citizenid,
                    Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                    itemConfig.name
                }, function(insertedId)
                    if insertedId then
                        print("Weapon entry added to database with ID: " .. insertedId)
                    else
                        print("Failed to add weapon entry to database.")
                    end
                end)

                -- If the item has components, give those to the player in bulk as well
                if itemConfig.components and #itemConfig.components > 0 then
                    for _, component in ipairs(itemConfig.components) do
                        exports['ps-inventory']:AddItem(src, component, quantity) -- Adds each component as an item to the player's inventory
                    end
                    TriggerClientEvent('ox_lib:notify', src, { type = 'success', description = "Components have been added to your inventory." })
                end
            else
                -- Notify the player if there are not enough funds
                TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = "The police department does not have enough funds for this purchase." })
            end
        else
            -- Notify if the item is not found
            TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = "Item not found in the armory!" })
        end
    else
        -- Notify if the player is not allowed
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = "You do not have access to this item!" })
    end
end)

-- Helper function to check if a table contains a value
function tableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end
