-- CursorGlow
-- Made by Sharpedge_Gaming
-- v2.9 - 11.0.2

local LibStub = LibStub or _G.LibStub
local AceDB = LibStub:GetLibrary("AceDB-3.0")
local AceAddon = LibStub:GetLibrary("AceAddon-3.0")
local AceConfig = LibStub:GetLibrary("AceConfig-3.0")
local AceConfigDialog = LibStub:GetLibrary("AceConfigDialog-3.0")
local AceDBOptions = LibStub:GetLibrary("AceDBOptions-3.0")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")
local AceGUI = LibStub:GetLibrary("AceGUI-3.0")
local icon = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CursorGlow", true)

local CursorGlow = AceAddon:NewAddon("CursorGlow", "AceEvent-3.0", "AceConsole-3.0")

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

local values = {}
for _, key in ipairs(orderedKeys) do
    values[key] = displayNames[key]
end

-- Create the main frame and texture
local frame = CreateFrame("Frame", nil, UIParent)
frame:SetFrameStrata("TOOLTIP")
local texture = frame:CreateTexture()
texture:SetTexture(textureOptions["star4"])  
texture:SetBlendMode("ADD")
texture:SetSize(32, 32) 

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
    demonhunter = {0.64, 0.19, 0.79},
    evoker = {0.20, 0.58, 0.50}
}

-- Function to get the default class color
local function GetDefaultClassColor()
    local _, class = UnitClass("player")
    if class then
        local classColor = RAID_CLASS_COLORS[class]
        if classColor then
            return {classColor.r, classColor.g, classColor.b}
        end
    end
    return colorOptions["red"]  -- Fallback color if class color is unavailable
end

-- Function to update texture color and opacity
local function UpdateTextureColor(color)
    local colorValue = colorOptions[color] or color
    texture:SetVertexColor(colorValue[1], colorValue[2], colorValue[3], CursorGlow.db.profile.opacity)
end

-- Function to update the texture
local function UpdateTexture(textureKey)
    local texturePath = textureOptions[textureKey] or textureOptions["star4"]
    texture:SetTexture(texturePath)
    UpdateTextureColor(CursorGlow.db.profile.color) 
end

local function ToggleAddon(enable)
    if not CursorGlow.db.profile.combatOnly or UnitAffectingCombat("player") then
        if enable then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

local function UpdateAddonVisibility()
    if CursorGlow.db.profile.operationMode == "disabled" then
        frame:Hide()
    elseif CursorGlow.db.profile.operationMode == "enabledAlways" or CursorGlow.db.profile.operationMode == "enabledAlwaysOnCursor" then
        frame:Show()
    elseif CursorGlow.db.profile.operationMode == "enabledInCombat" then
        if UnitAffectingCombat("player") then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

-- Initialize default settings with class color
local defaultClassColor = GetDefaultClassColor() 

-- Define default settings with class color
local defaults = {
    profile = {
        operationMode = "enabledAlways", -- Default mode
        color = defaultClassColor,       -- Default to class color
        opacity = 1,                     -- Default opacity
        minSize = 16,                    -- Default minimum size
        maxSize = 175,                   -- Default maximum size
        texture = "ring1",               -- Default texture
        minimap = {
            hide = false,                -- Minimap icon visibility
        },
    }
}


-- Create a DataBroker object for the minimap button
local minimapButton = LDB:NewDataObject("CursorGlow", {
    type = "data source",
    text = "CursorGlow",
    icon = "Interface\\Icons\\Spell_Frost_Frost",
    OnClick = function(self, button)
        if button == "LeftButton" then
            if Settings and Settings.OpenToCategory then
                Settings.OpenToCategory("CursorGlow")
            else
                InterfaceOptionsFrame_OpenToCategory("CursorGlow")
                InterfaceOptionsFrame_OpenToCategory("CursorGlow")
            end
        elseif button == "RightButton" then
            CursorGlow.db.profile.enabled = not CursorGlow.db.profile.enabled
            ToggleAddon(CursorGlow.db.profile.enabled)
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("|cFF00FF00CursorGlow|r")  
        tooltip:AddLine("|cFFFFFFFFLeft-click to open settings.|r")  
        tooltip:AddLine("|cFFFFFFFFRight-click to toggle addon.|r")  
    end,
})

function CursorGlow:OnInitialize()
    self.db = AceDB:New("CursorGlowDB", defaults, true)

    local characterProfileName = UnitName("player") .. " - " .. GetRealmName()
    if self.db:GetCurrentProfile() == "Default" then
        self.db:SetProfile(characterProfileName)
    end

    self.db.RegisterCallback(self, "OnProfileChanged", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileCopied", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileReset", "ApplySettings")

    -- Ensure the color is set correctly
    if self.db.profile.color[1] == 1 and self.db.profile.color[2] == 1 and self.db.profile.color[3] == 1 then
        local classColor = GetDefaultClassColor()
        self.db.profile.color = classColor
    end

    if minimapButton and icon then
        icon:Register("CursorGlow", minimapButton, self.db.profile.minimap)
    else
        print("Error: Minimap button or LibDBIcon not properly initialized.")
    end

    -- Show or hide the minimap button based on the saved setting
    if self.db.profile.minimap.hide then
        icon:Hide("CursorGlow")
    else
        icon:Show("CursorGlow")
    end

    local options = {
    name = "CursorGlow",
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = L["General"],
            order = 1,
            args = {
                operationMode = {
                    type = 'select',
                    name = L["Operation Mode"],
                    desc = L["Select when the addon should be active"],
                    order = 1,
                    values = {
                        enabledAlways = L["Enabled Always"],
                        enabledInCombat = L["Enabled in Combat Only"],
                        enabledAlwaysOnCursor = L["Always Show on Cursor"],
                    },
                    get = function() return CursorGlow.db.profile.operationMode end,
                    set = function(_, val)
                        CursorGlow.db.profile.operationMode = val
                        UpdateAddonVisibility()
                    end,
                },
                showMinimapIcon = {
                    type = 'toggle',
                    name = L["Show Minimap Icon"],
                    desc = L["Show or hide the minimap icon"],
                    order = 2,
                    get = function() return not CursorGlow.db.profile.minimap.hide end,
                    set = function(_, val)
                        CursorGlow.db.profile.minimap.hide = not val
                        if val then
                            icon:Show("CursorGlow")
                        else
                            icon:Hide("CursorGlow")
                        end
                    end,
                },
            },
        },
        appearance = {
            type = 'group',
            name = L["Appearance"],
            order = 2,
            args = {
                texture = {
                    type = 'select',
                    name = L["Texture"],
                    desc = L["Select the texture for the cursor glow"],
                    order = 1,
                    values = values, 
                    get = function() return CursorGlow.db.profile.texture end,
                    set = function(_, val)
                        CursorGlow.db.profile.texture = val
                        UpdateTexture(val)
                    end,
                },
                color = {
                    type = 'select',
                    name = L["Color"],
                    desc = L["Select the color for the texture"],
                    order = 2,
                    values = {
                        red = L["Red"],
                        green = L["Green"],
                        blue = L["Blue"],
                        purple = L["Purple"],
                        white = L["White"],
                        pink = L["Pink"],
                        orange = L["Orange"],
                        cyan = L["Cyan"],
                        yellow = L["Yellow"],
                        gray = L["Gray"],
                        gold = L["Gold"],
                        teal = L["Teal"],
                        magenta = L["Magenta"],
                        lime = L["Lime"],
                        olive = L["Olive"],
                        navy = L["Navy"],
                        warrior = L["Warrior"],
                        paladin = L["Paladin"],
                        hunter = L["Hunter"],
                        rogue = L["Rogue"],
                        priest = L["Priest"],
                        deathknight = L["Death Knight"],
                        shaman = L["Shaman"],
                        mage = L["Mage"],
                        warlock = L["Warlock"],
                        monk = L["Monk"],
                        druid = L["Druid"],
                        demonhunter = L["Demon Hunter"],
                        evoker = L["Evoker"],
                    },
                    get = function() return CursorGlow.db.profile.color end,
                    set = function(_, val)
                        CursorGlow.db.profile.color = val
                        UpdateTextureColor(val)
                    end,
                },
                opacity = {
                    type = 'range',
                    name = L["Opacity"],
                    desc = L["Adjust the opacity of the texture"],
                    order = 3,
                    min = 0,
                    max = 1,
                    step = 0.01,
                    get = function() return CursorGlow.db.profile.opacity end,
                    set = function(_, val)
                        CursorGlow.db.profile.opacity = val
                        UpdateTextureColor(CursorGlow.db.profile.color)
                    end,
                },
                minSize = {
                    type = 'range',
                    name = L["Minimum Size"],
                    desc = L["Set the minimum size of the texture"],
                    order = 4,
                    min = 16,
                    max = 64,
                    step = 1,
                    get = function() return CursorGlow.db.profile.minSize end,
                    set = function(_, val)
                        CursorGlow.db.profile.minSize = val
                    end,
                },
                maxSize = {
                    type = 'range',
                    name = L["Maximum Size"],
                    desc = L["Set the maximum size of the texture"],
                    order = 5,
                    min = 20,
                    max = 256,
                    step = 1,
                    get = function() return CursorGlow.db.profile.maxSize end,
                    set = function(_, val)
                        CursorGlow.db.profile.maxSize = val
                    end,
                },
            },
        },
        profiles = AceDBOptions:GetOptionsTable(self.db),
    },
}

    AceConfig:RegisterOptionsTable("CursorGlow", options)
    AceConfigDialog:AddToBlizOptions("CursorGlow", "CursorGlow")

    -- Apply the settings for the current profile
    self:ApplySettings()
end

function CursorGlow:ApplySettings()
    -- Ensure the texture and color are applied based on the current profile
    UpdateTexture(self.db.profile.texture)
    UpdateTextureColor(self.db.profile.color)
    UpdateAddonVisibility()
end


frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

function HandleCombatState()
    if CursorGlow.db.profile.combatOnly then
        ToggleAddon(CursorGlow.db.profile.enabled)
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "CursorGlow" then
        UpdateTexture(CursorGlow.db.profile.texture)
        UpdateTextureColor(CursorGlow.db.profile.color)
        UpdateAddonVisibility()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        UpdateAddonVisibility()
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
        UpdateTexture(CursorGlow.db.profile.texture)
        UpdateTextureColor(CursorGlow.db.profile.color)
        UpdateAddonVisibility()
        speed = 0
    end
end)

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnUpdate", function(self, elapsed)
    local size = math.max(CursorGlow.db.profile.minSize, CursorGlow.db.profile.maxSize)

    if CursorGlow.db.profile.operationMode == "enabledAlwaysOnCursor" then
        local scale = UIParent:GetEffectiveScale()
        local cursorX, cursorY = GetCursorPosition()
        texture:SetHeight(size)
        texture:SetWidth(size)
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, cursorY / scale)
        texture:Show()
    else
        CursorGlow.db.profile.maxSize = CursorGlow.db.profile.maxSize or 128
        CursorGlow.db.profile.minSize = CursorGlow.db.profile.minSize or 16

        local cursorX, cursorY = GetCursorPosition()
        prevX = prevX or cursorX
        prevY = prevY or cursorY

        local dX, dY = cursorX - prevX, cursorY - prevY
        local distance = math.sqrt(dX * dX + dY * dY)
        
        if elapsed == 0 then
            elapsed = 0.0001
        end

        local decayFactor = 2048 ^ -elapsed
        speed = math.min(decayFactor * speed + (1 - decayFactor) * distance / elapsed, 1024)

        size = math.max(math.min(speed / 6, CursorGlow.db.profile.maxSize), CursorGlow.db.profile.minSize)
        local scale = UIParent:GetEffectiveScale()
        texture:SetHeight(size)
        texture:SetWidth(size)
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (cursorX + 0.5 * dX) / scale, (cursorY + 0.5 * dY) / scale)
        
        if size > CursorGlow.db.profile.minSize then
            texture:Show()
        else
            texture:Hide()
        end

        prevX = cursorX
        prevY = cursorY
    end
end)

