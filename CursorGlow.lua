-- CursorGlow
-- Made by Sharpedge_Gaming
-- v1.6 - 10.2.5

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Define texture options
local textureOptions = {   
	["ring1"] = "Interface\\Addons\\CursorGlow\\Textures\\Test2.png",
	["ring2"] = "Interface\\Addons\\CursorGlow\\Textures\\Test3.png",
	["ring3"] = "Interface\\Addons\\CursorGlow\\Textures\\Test4.png",
	["ring4"] = "Interface\\Addons\\CursorGlow\\Textures\\Test6.png",
	["ring5"] = "Interface\\Addons\\CursorGlow\\Textures\\Test5.png",
	["ring6"] = "Interface\\Addons\\CursorGlow\\Textures\\Test8.png",
	["ring7"] = "Interface\\Addons\\CursorGlow\\Textures\\Test7.png",
	["ring8"] = "Interface\\Addons\\CursorGlow\\Textures\\Test9.png",
	["ring9"] = "Interface\\Addons\\CursorGlow\\Textures\\Test10.png",
	["ring10"] = "Interface\\Addons\\CursorGlow\\Textures\\Test11.png",
	["ring11"] = "Interface\\Addons\\CursorGlow\\Textures\\Star1.png",
	["ring12"] = "Interface\\Addons\\CursorGlow\\Textures\\Star2.png",
	["ring13"] = "Interface\\Addons\\CursorGlow\\Textures\\Star3.png",
	["ring14"] = "Interface\\Cooldown\\star4",
    ["ring15"] = "Interface\\Cooldown\\starburst",
	["ring16"] = "Interface\\Addons\\CursorGlow\\Textures\\Test12.png",
	["ring17"] = "Interface\\Addons\\CursorGlow\\Textures\\Test13.png",
	["ring18"] = "Interface\\Addons\\CursorGlow\\Textures\\Test14.png",
	["ring19"] = "Interface\\Addons\\CursorGlow\\Textures\\Test15.png",
	["ring20"] = "Interface\\Addons\\CursorGlow\\Textures\\Test16.png",
	["ring21"] = "Interface\\Addons\\CursorGlow\\Textures\\Test17.png",
	["ring22"] = "Interface\\Addons\\CursorGlow\\Textures\\Test18.png",
	
		
}

local orderedKeys = {
    "ring1", 
	"ring2", 
	"ring3", 
	"ring4", 
	"ring5",
    "ring6", 
	"ring7", 
	"ring8", 
	"ring9", 
	"ring10",
    "ring11", 
	"ring12", 
	"ring13", 
	"ring14",
	"ring15",
	"ring16",
	"ring17",
	"ring18",
	"ring19",
	"ring20",
	"ring21",
	"ring22",
}

local displayNames = {
    ring1 = 'Ring 1',
    ring2 = 'Ring 2',
    ring3 = 'Ring 3',
    ring4 = 'Ring 4',
    ring5 = 'Ring 5',
    ring6 = 'Ring 6',
    ring7 = 'Ring 7',
    ring8 = 'Ring 8',
    ring9 = 'Ring 9',
    ring10 = 'Star 1',
	ring11 = 'Star 2',
    ring12 = 'Star 3',
    ring13 = 'Star 4',
    ring14 = 'Star 5',
    ring15 = 'Starburst',
	ring16 = 'Butterfly',
	ring17 = 'Butterfly2',
	ring18 = 'Butterfly3',
	ring19 = 'Swirl',
	ring20 = 'Swirl2',
	ring21 = 'Horde',
	ring22 = 'Alliance',
}
-- Build the values table dynamically
local values = {}
for _, key in ipairs(orderedKeys) do
    values[key] = displayNames[key]
end

-- Create the main frame and texture
local frame = CreateFrame("Frame", nil, UIParent)
frame:SetFrameStrata("TOOLTIP")
local texture = frame:CreateTexture()
texture:SetTexture(textureOptions["star4"])  -- Default texture
texture:SetBlendMode("ADD")
texture:SetSize(32, 32)  -- Set initial size for the main texture

-- Define color options
local colorOptions = {
    red = {1, 0, 0},
    green = {0, 1, 0},
    blue = {0, 0, 1},
    purple = {1, 0, 1},
    white = {1, 1, 1},
    pink = {1, 0.08, 0.58},
    orange = {1, 0.65, 0},
    cyan = {0, 1, 1},
    yellow = {1, 1, 0},
    gray = {0.5, 0.5, 0.5},
    gold = {1, 0.84, 0},
    teal = {0, 0.5, 0.5},
    magenta = {1, 0, 1},
    lime = {0.75, 1, 0},
    olive = {0.5, 0.5, 0},
    navy = {0, 0, 0.5},
    -- WoW Class Colors
    warrior = {0.78, 0.61, 0.43},
    paladin = {0.96, 0.55, 0.73},
    hunter = {0.67, 0.83, 0.45},
    rogue = {1.00, 0.96, 0.41},
	priest = {1.00, 1.00, 1.00},
    deathknight = {0.77, 0.12, 0.23},
    shaman = {0.00, 0.44, 0.87},
    mage = {0.41, 0.80, 0.94},
    warlock = {0.58, 0.51, 0.79},
    monk = {0.00, 1.00, 0.59},
    druid = {1.00, 0.49, 0.04},
    demonhunter = {0.64, 0.19, 0.79}
}

-- Function to get the default class color
local function GetDefaultClassColor()
    local _, class = UnitClass("player")
    if class then
        local classColor = RAID_CLASS_COLORS[class]
        if classColor then
            -- Convert to format used in colorOptions
            return {classColor.r, classColor.g, classColor.b}
        end
    end
    return colorOptions["red"]  -- Fallback color if class color is unavailable
end

-- Initialize default settings with class color
local defaultClassColor = GetDefaultClassColor() 
CursorGlowCharacterSettings = CursorGlowCharacterSettings or {
    operationMode = "enabledAlways", -- Default mode
    color = defaultClassColor,
    opacity = 0.5,
    minSize = 16,
    maxSize = 128,
    texture = "star4"
}

local function ToggleAddon(enable)
    -- Only change visibility if not restricted to combat or if in combat
    if not CursorGlowCharacterSettings.combatOnly or UnitAffectingCombat("player") then
        if enable then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

-- Function to handle combat state changes
local function HandleCombatState()
    if CursorGlowCharacterSettings.combatOnly then
        ToggleAddon(CursorGlowCharacterSettings.enabled)
    end
end

-- Register combat events
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Entering combat
frame:RegisterEvent("PLAYER_REGEN_ENABLED") -- Leaving combat

-- Function to update texture color and opacity
local function UpdateTextureColor(color)
    local colorValue = colorOptions[color] or colorOptions["red"]
    texture:SetVertexColor(colorValue[1], colorValue[2], colorValue[3], CursorGlowCharacterSettings.opacity)
end

-- Function to update the texture
local function UpdateTexture(textureKey)
    local texturePath = textureOptions[textureKey] or textureOptions["star4"]
    texture:SetTexture(texturePath)
    UpdateTextureColor(CursorGlowCharacterSettings.color) -- Update color to refresh the texture
end

-- Function to toggle the addon's functionality
local function ToggleAddon(enable)
    if enable then
        frame:Show()
    else
        frame:Hide()
    end
end

local function UpdateAddonVisibility()
    if CursorGlowCharacterSettings.operationMode == "disabled" then
        frame:Hide()
    elseif CursorGlowCharacterSettings.operationMode == "enabledAlways" then
        frame:Show()
    elseif CursorGlowCharacterSettings.operationMode == "enabledInCombat" then
        if UnitAffectingCombat("player") then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

local options = {
    name = "CursorGlow",
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = 'General',
            order = 1,
            args = {
                operationMode = {
                    type = 'select',
                    name = 'Operation Mode',
                    desc = 'Select when the addon should be active',
                    order = 1,
                    values = {
                        disabled = 'Disabled',
                        enabledAlways = 'Enabled Always',
                        enabledInCombat = 'Enabled in Combat Only',
                    },
                    get = function() return CursorGlowCharacterSettings.operationMode end,
                    set = function(_, val)
                        CursorGlowCharacterSettings.operationMode = val
                        UpdateAddonVisibility()
                    end,
                },
            },
        },
        appearance = {
            type = 'group',
            name = 'Appearance',
            order = 2,
            args = {
                texture = {
                    type = 'select',
                    name = 'Texture',
                    desc = 'Select the texture for the cursor glow',
                    order = 1,
                    values = values, 
                    get = function() return CursorGlowCharacterSettings.texture end,
                    set = function(_, val)
                        CursorGlowCharacterSettings.texture = val
                        UpdateTexture(val)
                    end,
                },
                color = {
                    type = 'select',
                    name = 'Color',
                    desc = 'Select the color for the texture',
                    order = 2,
                    values = {
                        red = 'Red',
                        green = 'Green',
                        blue = 'Blue',
                        purple = 'Purple',
                        white = 'White',
                        pink = 'Pink',
                        orange = 'Orange',
                        cyan = 'Cyan',
                        yellow = 'Yellow',
                        gray = 'Gray',
                        gold = 'Gold',
                        teal = 'Teal',
                        magenta = 'Magenta',
                        lime = 'Lime',
                        olive = 'Olive',
                        navy = 'Navy',
                        warrior = 'Warrior',
                        paladin = 'Paladin',
                        hunter = 'Hunter',
                        rogue = 'Rogue',
                        priest = 'Priest',
                        deathknight = 'Death Knight',
                        shaman = 'Shaman',
                        mage = 'Mage',
                        warlock = 'Warlock',
                        monk = 'Monk',
                        druid = 'Druid',
                        demonhunter = 'Demon Hunter',
                    },
                    get = function() return CursorGlowCharacterSettings.color end,
                    set = function(_, val)
                        CursorGlowCharacterSettings.color = val
                        UpdateTextureColor(val)
                    end,
                },
                opacity = {
                    type = 'range',
                    name = 'Opacity',
                    desc = 'Adjust the opacity of the texture',
                    order = 3,
                    min = 0,
                    max = 1,
                    step = 0.01,
                    get = function() return CursorGlowCharacterSettings.opacity end,
                    set = function(_, val)
                        CursorGlowCharacterSettings.opacity = val
                        UpdateTextureColor(CursorGlowCharacterSettings.color)
                    end,
                },
                minSize = {
                    type = 'range',
                    name = 'Minimum Size',
                    desc = 'Set the minimum size of the texture',
                    order = 4,
                    min = 16,
                    max = 64,
                    step = 1,
                    get = function() return CursorGlowCharacterSettings.minSize end,
                    set = function(_, val)
                        CursorGlowCharacterSettings.minSize = val
                    end,
                },
                maxSize = {
                    type = 'range',
                    name = 'Maximum Size',
                    desc = 'Set the maximum size of the texture',
                    order = 5,
                    min = 64,
                    max = 256,
                    step = 1,
                    get = function() return CursorGlowCharacterSettings.maxSize end,
                    set = function(_, val)
                        CursorGlowCharacterSettings.maxSize = val
                    end,
                },
            },
        },
    },
}

-- Register options table and add to interface options
AceConfig:RegisterOptionsTable("CursorGlow", options)
AceConfigDialog:AddToBlizOptions("CursorGlow", "CursorGlow")

-- Variables for cursor tracking
local x, y, speed = 0, 0, 0

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "CursorGlow" then
        UpdateTextureColor(CursorGlowCharacterSettings.color or GetDefaultClassColor())
        UpdateTexture(CursorGlowCharacterSettings.texture)
        UpdateAddonVisibility() -- Ensure correct initial visibility
        
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        UpdateAddonVisibility() -- Directly update visibility based on combat state
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
        -- Code to reapply the correct texture size or reset UI components
        UpdateTexture(CursorGlowCharacterSettings.texture)
        UpdateTextureColor(CursorGlowCharacterSettings.color)
        UpdateAddonVisibility()
        -- Optionally reset the speed calculation if necessary
        speed = 0
    end
end)

-- Register additional events for handling zone changes and player world entry
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- OnUpdate function for the frame
frame:SetScript("OnUpdate", function(self, elapsed)
    CursorGlowCharacterSettings.maxSize = CursorGlowCharacterSettings.maxSize or 128
    CursorGlowCharacterSettings.minSize = CursorGlowCharacterSettings.minSize or 16

    local prevX, prevY = x, y
    x, y = GetCursorPosition()
    local dX, dY = x - prevX, y - prevY

    local distance = math.sqrt(dX * dX + dY * dY)
    local decayFactor = 2048 ^ -elapsed
    speed = math.min(decayFactor * speed + (1 - decayFactor) * distance / elapsed, 1024)

    local size = math.max(math.min(speed / 6, CursorGlowCharacterSettings.maxSize), CursorGlowCharacterSettings.minSize)
    if size > CursorGlowCharacterSettings.minSize then
        local scale = UIParent:GetEffectiveScale()
        texture:SetHeight(size)
        texture:SetWidth(size)
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (x + 0.5 * dX) / scale, (y + 0.5 * dY) / scale)
        texture:Show()
    else
        texture:Hide()
    end
end)








