Config = {}

-- List of armory locations with coordinates, radius, and NPC configurations
Config.ArmoryLocations = {
    {
        location = vector3(479.1974, -996.3953, 30.6920), -- Example location 1
        radius = 2.0,
        npc = {
            model = "mp_m_freemode_01", -- Male freemode character
            coords = vector4(480.3986, -996.7365, 30.6913, 91.5457), -- x, y, z, heading
            clothes = {
                { componentId = 11, drawableId = 190, textureId = 3 }, -- Top
                { componentId = 8, drawableId = 2, textureId = 0 }, -- Undershirt
                { componentId = 4, drawableId = 50, textureId = 0 }, -- Pants
                { componentId = 6, drawableId = 24, textureId = 0 },  -- Shoes
                { componentId = 9, drawableId = 7, textureId = 3 },  -- Vest
                { { propId = 0, drawableId = 10, textureId = 0 } }
            }
        }
    },
    {
        location = vector3(1853.6, 3686.0, 34.6), -- Example location 2
        radius = 2.0,
        npc = {
            model = "mp_m_freemode_01", -- Female freemode character
            coords = vector4(1853.6, 3686.0, 34.6, 90.0), -- x, y, z, heading
            clothes = {
                { componentId = 11, drawableId = 190, textureId = 3 }, -- Top
                { componentId = 8, drawableId = 2, textureId = 0 }, -- Undershirt
                { componentId = 4, drawableId = 50, textureId = 0 }, -- Pants
                { componentId = 6, drawableId = 24, textureId = 0 },  -- Shoes
                { componentId = 9, drawableId = 7, textureId = 3 },  -- Vest
                { { propId = 0, drawableId = 10, textureId = 0 } }
            }
        }
    },
    -- Add more locations as needed
}

Config.ArmoryAccessKey = 38 -- Key 'E'

-- List of items and weapons available in the armory, including components, grades, cost, and category
Config.ArmoryItems = {
    { 
        name = 'weapon_combatpistol', 
        label = 'Smith & Wesson M&P9',
        components = { 'flashlight_attachment' }, -- Flashlight
        grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27 }, -- Accessible to all grades
        cost = 17555, -- Cost in dollars
        category = 'weapon' -- Category: weapon
    },
    { 
        name = 'weapon_carbinerifle', 
        label = 'Carbine Rifle',
        components = { 'flashlight_attachment', 'holoscope_attachment', 'clip_attachment' }, -- Flashlight, holoscope, and extended clip
        grades = { 8, 9, 12, 13, 16, 17, 20, 21, 22, 23, 24, 25, 26, 27 }, -- Accessible to certain grades
        cost = 25495, -- Cost in dollars
        category = 'weapon' -- Category: weapon
    },
    { 
        name = 'weapon_stungun', 
        label = 'Stun Gun',
        components = {}, -- No components for stun gun
        grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27 }, -- Accessible to all grades
        cost = 1500, -- Cost in dollars
        category = 'weapon' -- Category: weapon
    },
    { 
        name = 'weapon_dd16_b', 
        label = 'Daniel Defence',
        components = { 'drum_attachment', 'flashlight_attachment', 'suppressor_attachment', 'holoscope_attachment', 'grip_attachment' }, -- Drum magazine, flashlight, suppressor, holoscope, and grip
        grades = { 7, 11, 16, 20, 21, 22, 23, 24, 25, 26, 27 }, -- Accessible to certain grades
        cost = 35000, -- Cost in dollars
        category = 'weapon' -- Category: weapon
    },
    { 
        name = 'armor', 
        label = 'Body Armor',
        components = {}, -- No components for armor
        grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27 }, -- Accessible to all grades
        cost = 2500, -- Cost in dollars
        category = 'item' -- Category: item (can be bought in bulk)
    },
    {
        name = 'pistol_ammo',
        label = '9mm Bullets',
        components = {},
        grades = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27 },
        cost = 150, -- Cost in dollars
        category = 'item' -- Category: item (can be bought in bulk)
    },
    {
        name = 'rifle_ammo',
        label = '5.56 Bullets',
        components = {},
        grades = { 7, 8, 9, 11, 12, 13, 16, 17, 19, 20, 21, 22, 23, 24, 25, 26, 27 },
        cost = 150, -- Cost in dollars
        category = 'item' -- Category: item (can be bought in bulk)
    },
    -- Additional items here...
}
