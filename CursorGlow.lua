-- CursorGlow
-- Made by Sharpedge_Gaming
-- v3.3 - 11.0.2

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
local speed = 0
local stationaryTime = 0

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

-- Tail effect variables
local tailSegments = {}
local tailLength = 60  -- Adjust the length of the tail
local tailPositions = {}  -- Stores previous cursor positions
local tailTextures = {}   -- Stores the tail textures

-- Initialize tail textures
for i = 1, tailLength do
    local tailTexture = frame:CreateTexture(nil, "BACKGROUND")
    tailTexture:SetTexture(textureOptions["star4"])  -- Use the same texture as the main glow
    tailTexture:SetBlendMode("ADD")
    tailTexture:SetSize(32, 32)
    tailTextures[i] = tailTexture
end

local function InitializeTailTextures()
    for _, tailTexture in ipairs(tailTextures) do
        tailTexture:Hide()
        tailTexture:SetTexture(nil)
    end
    tailTextures = {}
    tailPositions = {}

    local colorValue = colorOptions[CursorGlow.db.profile.color] or {1, 1, 1}
    local texturePath = textureOptions[CursorGlow.db.profile.texture] or textureOptions["star4"]

    for i = 1, CursorGlow.tailLength do
        local tailTexture = frame:CreateTexture(nil, "BACKGROUND")
        tailTexture:SetTexture(texturePath)
        tailTexture:SetBlendMode("ADD")
        tailTexture:SetSize(32, 32)
        tailTexture:SetVertexColor(colorValue[1], colorValue[2], colorValue[3], CursorGlow.db.profile.opacity)
        tailTextures[i] = tailTexture
    end
end

function CursorGlow:OnInitialize()
    self.db = AceDB:New("CursorGlowDB", defaults, true)

    local characterProfileName = UnitName("player") .. " - " .. GetRealmName()
    if self.db:GetCurrentProfile() == "Default" then
        self.db:SetProfile(characterProfileName)
    end

    -- Register callbacks to handle profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileCopied", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileReset", "ApplySettings")

    -- Ensure the color is set correctly
    if not self.db.profile.color then
        -- If the color field does not exist, initialize it with a default value
        self.db.profile.color = {1, 1, 1}  -- Default to white
    elseif self.db.profile.color[1] == 1 and self.db.profile.color[2] == 1 and self.db.profile.color[3] == 1 then
        local classColor = GetDefaultClassColor()
        self.db.profile.color = classColor
    end

    -- Handle minimap button
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

    -- Apply the settings for the current profile
    self:ApplySettings()
end

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

local function UpdateTextureColor()
    local colorValue = colorOptions[CursorGlow.db.profile.color] or {1, 1, 1}
    texture:SetVertexColor(colorValue[1], colorValue[2], colorValue[3], CursorGlow.db.profile.opacity)
    -- Update tail textures' color
    for _, tailTexture in ipairs(tailTextures) do
        tailTexture:SetVertexColor(colorValue[1], colorValue[2], colorValue[3], CursorGlow.db.profile.opacity)
    end
end

-- Function to update the texture
local function UpdateTexture(textureKey)
    local texturePath = textureOptions[textureKey] or textureOptions["star4"]
    texture:SetTexture(texturePath)
    -- Update tail textures' texture
    for _, tailTexture in ipairs(tailTextures) do
        tailTexture:SetTexture(texturePath)
    end
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

local defaults = {
    profile = {
        operationMode = "enabledAlways",
        enableExplosion = false,
        explosionColor = {1, 1, 1},
        explosionSize = 15,  
        explosionTextureSize = 10,  
        explosionTexture = "ring1",  
        opacity = 1,
        minSize = 16,
        maxSize = 175,
        texture = "ring1",
        color = "white",  -- Default color key
        enableTail = false,  -- Default to tail effect enabled
        tailLength = 60,  -- Default tail length
        minimap = {
            hide = false,
        },
    }
}


local particles = {}

textureOptions["explosionParticle"] = "Interface\\Addons\\CursorGlow\\Textures\\Test17.png"

local particles = {}

local function CreateParticle(textureKey)
    local particle = CreateFrame("Frame", nil, UIParent)
    particle:SetFrameStrata("TOOLTIP")
    particle:SetSize(16, 16)

    local texture = particle:CreateTexture(nil, "ARTWORK")
    local texturePath = textureOptions[textureKey]
    if not texturePath then
       
        return
    end

    texture:SetTexture(texturePath)  
    texture:SetBlendMode("ADD")
    texture:SetAllPoints(particle)

    particle.texture = texture
    particle:SetAlpha(1)  
    texture:SetAlpha(1)   
    particle:Hide()

    return particle
end

local function UpdateExplosionTexture(textureKey)
    if not textureKey then
        return
    end

    -- Check if the texture key exists in the textureOptions table
    local texturePath = textureOptions[textureKey]
    if not texturePath then
        return
    end

    -- Recreate particles with the new texture
    particles = {}  -- Clear existing particles
    for i = 1, 100 do  -- Reinitialize 100 particles with the new texture
        particles[i] = CreateParticle(textureKey)
    end
end

local function TriggerExplosion(cursorX, cursorY)
    local scale = UIParent:GetEffectiveScale()
    local color = CursorGlow.db.profile.explosionColor  -- Get the explosion color from settings
    local explosionSize = CursorGlow.db.profile.explosionSize  -- Get the explosion size from settings
    local textureSize = CursorGlow.db.profile.explosionTextureSize or 10  -- Get the explosion texture size from settings
    local explosionTexture = CursorGlow.db.profile.explosionTexture or "ring1"  -- Fallback to "ring1"

    UpdateExplosionTexture(explosionTexture)  -- Update texture based on user selection

    for _, particle in ipairs(particles) do
        -- Randomize particle direction and distance, applying the explosion size
        local angle = math.random() * 2 * math.pi
        local distance = math.random(1, explosionSize)  -- Adjust particle spread based on explosion size
        local xOffset = math.cos(angle) * distance
        local yOffset = math.sin(angle) * distance

        particle:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, cursorY / scale)
        particle:SetAlpha(1)  -- Reset alpha when the particle is shown
        particle.texture:SetAlpha(1)  -- Reset the texture alpha
        particle.texture:SetVertexColor(unpack(color))  -- Apply the selected color

        -- Set the particle texture size based on the user's input
        particle:SetSize(textureSize, textureSize)  -- Dynamically adjust texture size
        particle:Show()

        -- Animate particle movement with a fade-out
        particle:SetScript("OnUpdate", function(self, elapsed)
            local speed = 30
            local dx, dy = speed * xOffset * elapsed, speed * yOffset * elapsed
            local currentX, currentY = self:GetCenter()
            particle:SetPoint("CENTER", UIParent, "BOTTOMLEFT", currentX + dx, currentY + dy)

            -- Get the current alpha, ensure it isn't nil, and fade it out
            local currentAlpha = particle:GetAlpha() or 1
            local newAlpha = currentAlpha - (elapsed * 0.8)
            if newAlpha <= 0 then
                particle:Hide()  -- Hide the particle when it's fully faded out
            else
                particle:SetAlpha(newAlpha)  -- Apply the new alpha value
            end
        end)
    end
end

local function UpdateExplosionTextureSize(size)
    -- Iterate over all particles and update their size based on the value
    for _, particle in ipairs(particles) do
        particle:SetSize(size, size)  -- Adjust the width and height
    end
end

local function TriggerExplosionOnClick(_, button)
    if button == "LeftButton" then
        -- Check if explosion is enabled in the settings
        if CursorGlow.db.profile.enableExplosion then
            local cursorX, cursorY = GetCursorPosition()
            TriggerExplosion(cursorX, cursorY)
        end
    end
end

-- Hook into the global mouse down event for the world frame
WorldFrame:HookScript("OnMouseDown", TriggerExplosionOnClick)

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

function CursorGlow:ApplySettings()
    -- Ensure the texture and color are applied based on the current profile
    UpdateTexture(self.db.profile.texture)
    UpdateTextureColor(self.db.profile.color)
    UpdateAddonVisibility()
    CursorGlow.tailLength = self.db.profile.tailLength or 10
    InitializeTailTextures()
end



function CursorGlow:OnInitialize()
    self.db = AceDB:New("CursorGlowDB", defaults, true)

    local characterProfileName = UnitName("player") .. " - " .. GetRealmName()
    if self.db:GetCurrentProfile() == "Default" then
        self.db:SetProfile(characterProfileName)
    end

    -- Register callbacks to handle profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileCopied", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileReset", "ApplySettings")

    -- Ensure the color is set correctly
    if not self.db.profile.color then
        -- If the color field does not exist, initialize it with a default value
        self.db.profile.color = {1, 1, 1}  -- Default to white
    elseif self.db.profile.color[1] == 1 and self.db.profile.color[2] == 1 and self.db.profile.color[3] == 1 then
        local classColor = GetDefaultClassColor()
        self.db.profile.color = classColor
    end

    -- Handle minimap button
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

  function CursorGlow:OnInitialize()
    self.db = AceDB:New("CursorGlowDB", defaults, true)

    local characterProfileName = UnitName("player") .. " - " .. GetRealmName()
    if self.db:GetCurrentProfile() == "Default" then
        self.db:SetProfile(characterProfileName)
    end

    -- Register callbacks to handle profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileCopied", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileReset", "ApplySettings")

    -- Ensure the color is set correctly
    if not self.db.profile.color then
        -- If the color field does not exist, initialize it with a default value
        self.db.profile.color = {1, 1, 1}  -- Default to white
    elseif self.db.profile.color[1] == 1 and self.db.profile.color[2] == 1 and self.db.profile.color[3] == 1 then
        local classColor = GetDefaultClassColor()
        self.db.profile.color = classColor
    end

    -- Handle minimap button
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

    -- Apply the settings for the current profile
    self:ApplySettings()
end

-- Create and register the main options
local options = {
    name = "CursorGlow",
    type = 'group',
    args = {
        -- General Settings Header
        generalHeader = {
            type = 'header',
            name = L["General Settings"],
            order = 1,
        },
        general = {
            type = 'group',
            name = L["General"],
            order = 2,
            inline = true,
            args = {
                -- Operation Mode
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

                -- Show Minimap Icon
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

                -- Spacer
                spacerGeneral1 = {
                    type = 'description',
                    name = " ",  -- Blank spacer for separation
                    order = 3,
                },
            },
        },

        -- Explosion Settings Header
        explosionHeader = {
            type = 'header',
            name = L["Explosion Settings"],
            order = 10,
        },
        explosion = {
            type = 'group',
            name = L["Explosion"],
            order = 11,
            inline = true,
            args = {
                -- Enable/Disable Explosion Effect
                enableExplosion = {
                    type = 'toggle',
                    name = L["Enable Explosion Effect"],
                    desc = L["Enable or disable the explosion effect on left-click"],
                    order = 1,
                    get = function() return CursorGlow.db.profile.enableExplosion end,
                    set = function(_, val)
                        CursorGlow.db.profile.enableExplosion = val
                    end,
                },

                -- Explosion Color
                explosionColor = {
                    type = 'color',
                    name = L["Explosion Color"],
                    desc = L["Pick a color for the explosion effect"],
                    order = 2,
                    get = function() return unpack(CursorGlow.db.profile.explosionColor) end,
                    set = function(_, r, g, b)
                        CursorGlow.db.profile.explosionColor = {r, g, b}
                    end,
                    disabled = function() return not CursorGlow.db.profile.enableExplosion end,
                },

                -- Spacer
                spacerExplosion1 = {
                    type = 'description',
                    name = " ",  -- Blank spacer for separation
                    order = 3,
                },

                -- Explosion Size
                explosionSize = {
                    type = 'range',
                    name = L["Explosion Size"],
                    desc = L["Adjust the size of the explosion effect"],
                    order = 4,
                    min = 5,
                    max = 50,
                    step = 1,
                    get = function() return CursorGlow.db.profile.explosionSize end,
                    set = function(_, val)
                        CursorGlow.db.profile.explosionSize = val
                    end,
                },

                -- Explosion Texture Size
                explosionTextureSize = {
                    type = 'range',
                    name = L["Explosion Texture Size"],
                    desc = L["Adjust the texture size for the explosion effect"],
                    order = 5,
                    min = 10,
                    max = 40,
                    step = 1,
                    get = function() return CursorGlow.db.profile.explosionTextureSize end,
                    set = function(_, val)
                        CursorGlow.db.profile.explosionTextureSize = val
                        UpdateExplosionTextureSize(val)
                    end,
                    disabled = function() return not CursorGlow.db.profile.enableExplosion end,
                },

                -- Explosion Texture Selection
                explosionTexture = {
                    type = 'select',
                    name = L["Explosion Texture"],
                    desc = L["Select the texture for the explosion effect"],
                    order = 6,
                    values = {
                        ring1 = "Ring 1",
                        ring2 = "Ring 2",
                        ring3 = "Ring 3",
                        ring4 = "Ring 4",
                        ring5 = "Ring 5",
                        ring6 = "Ring 6",
                        ring7 = "Ring 7",
                        ring8 = "Ring 8",
                        ring9 = "Ring 9",
                        ring10 = "Star 1",
                        ring11 = "Star 2",
                        ring12 = "Star 3",
                        ring13 = "Star 4",
                        ring14 = "Star 5",
                        ring15 = "Starburst",
                        ring16 = "Butterfly",
                        ring17 = "Butterfly 2",
                        ring18 = "Butterfly 3",
                        ring19 = "Swirl",
                        ring20 = "Swirl 2",
                        ring21 = "Horde",
                        ring22 = "Alliance",
                    },
                    get = function() return CursorGlow.db.profile.explosionTexture end,
                    set = function(_, val)
                        CursorGlow.db.profile.explosionTexture = val
                        UpdateExplosionTexture(val)  -- Update the texture when the user selects one
                    end,
                },
            },
        },

        -- Appearance Settings Header
        appearanceHeader = {
            type = 'header',
            name = L["Appearance Settings"],
            order = 20,
        },
        appearance = {
            type = 'group',
            name = L["Appearance"],
            order = 21,
            inline = true,
            args = {
                -- Texture Selection
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
        InitializeTailTextures()  -- Re-initialize tail textures with new texture
    end,
                },

                -- Texture Color
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
                    },
                    get = function() return CursorGlow.db.profile.color end,
    set = function(_, val)
        CursorGlow.db.profile.color = val
        UpdateTextureColor()
        InitializeTailTextures()  -- Re-initialize tail textures with new color
    end,
                },

                -- Opacity Adjustment
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

                -- Spacer
                spacerAppearance1 = {
                    type = 'description',
                    name = " ",  -- Blank spacer for separation
                    order = 4,
                },

                -- Minimum Size
                minSize = {
                    type = 'range',
                    name = L["Minimum Size"],
                    desc = L["Set the minimum size of the texture"],
                    order = 5,
                    min = 16,
                    max = 64,
                    step = 1,
                    get = function() return CursorGlow.db.profile.minSize end,
                    set = function(_, val)
                        CursorGlow.db.profile.minSize = val
                    end,
                },

                -- Maximum Size
                maxSize = {
                    type = 'range',
                    name = L["Maximum Size"],
                    desc = L["Set the maximum size of the texture"],
                    order = 6,
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

        -- Tail Effect Settings Header
        tailHeader = {
            type = 'header',
            name = L["Tail Effect Settings"],
            order = 30,
        },
        tailSettings = {
            type = 'group',
            name = L["Tail Effect"],
            order = 31,
            inline = true,
            args = {
                enableTail = {
                    type = 'toggle',
                    name = L["Enable Tail Effect"],
                    desc = L["Toggle the tail effect behind the cursor"],
                    order = 1,
                    get = function() return CursorGlow.db.profile.enableTail end,
                    set = function(_, val)
                        CursorGlow.db.profile.enableTail = val
                        if not val then
                            -- Hide tail textures when disabled
                            for _, tailTexture in ipairs(tailTextures) do
                                tailTexture:Hide()
                            end
                            tailPositions = {}
                        end
                    end,
                },
                tailLength = {
    type = 'range',
    name = L["Tail Length"],
    desc = L["Adjust the length of the cursor tail"],
    order = 2,
    min = 10,
    max = 80,
    step = 1,
    get = function() return CursorGlow.db.profile.tailLength end,
    set = function(_, val)
        CursorGlow.db.profile.tailLength = val
        CursorGlow.tailLength = val
        InitializeTailTextures()
    end,
    disabled = function() return not CursorGlow.db.profile.enableTail end,
                },
            },
        },
    },
}


-- Profile options in a separate Blizzard options panel
local profileOptions = {
    name = "CursorGlow Profiles",
    type = 'group',
    args = AceDBOptions:GetOptionsTable(CursorGlow.db).args,
}

-- Register the main options (CursorGlow configuration)
AceConfig:RegisterOptionsTable("CursorGlow", options)
AceConfigDialog:AddToBlizOptions("CursorGlow", "CursorGlow")

-- Register the profile options separately under "Profiles" tab
AceConfig:RegisterOptionsTable("CursorGlow Profiles", AceDBOptions:GetOptionsTable(CursorGlow.db))
AceConfigDialog:AddToBlizOptions("CursorGlow Profiles", "Profiles", "CursorGlow")

    -- Apply the settings for the current profile
    self:ApplySettings()
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

-- OnUpdate function to handle the tail effect
frame:SetScript("OnUpdate", function(self, elapsed)
    local size = math.max(CursorGlow.db.profile.minSize, CursorGlow.db.profile.maxSize)

    if CursorGlow.db.profile.operationMode == "enabledAlwaysOnCursor" then
        -- Code for always-on-cursor mode
        local scale = UIParent:GetEffectiveScale()
        local cursorX, cursorY = GetCursorPosition()
        texture:SetHeight(size)
        texture:SetWidth(size)
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, cursorY / scale)
        texture:Show()
    else
        -- Initialization and calculation code
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

        if distance > 0 then
            -- Cursor is moving
            -- Reset stationary time
            stationaryTime = 0

            -- Existing movement code
            texture:SetHeight(size)
            texture:SetWidth(size)
            texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (cursorX + 0.5 * dX) / scale, (cursorY + 0.5 * dY) / scale)
            texture:Show()

            if CursorGlow.db.profile.enableTail then
                -- Tail effect logic
                local cursorPos = { x = cursorX / scale, y = cursorY / scale }
                table.insert(tailPositions, 1, cursorPos)
                if #tailPositions > CursorGlow.tailLength then
                    table.remove(tailPositions)
                end

                for i, tailTexture in ipairs(tailTextures) do
                    local pos = tailPositions[i]
                    if pos then
                        tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                        local alpha = (CursorGlow.tailLength - i + 1) / CursorGlow.tailLength
                        tailTexture:SetAlpha(alpha * CursorGlow.db.profile.opacity)
                        local tailSize = size * alpha
                        tailTexture:SetSize(tailSize, tailSize)
                        tailTexture:Show()
                    else
                        tailTexture:Hide()
                    end
                end
            else
                -- Tail effect disabled
                for _, tailTexture in ipairs(tailTextures) do
                    tailTexture:Hide()
                end
                tailPositions = {}
            end
        else
            -- Cursor is stationary
            texture:Hide()
            stationaryTime = stationaryTime + elapsed

            if CursorGlow.db.profile.enableTail then
                -- Tail effect logic when stationary
                for i, tailTexture in ipairs(tailTextures) do
                    local pos = tailPositions[i]
                    if pos then
                        tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                        -- Calculate alpha based on stationary time
                        local alpha = ((CursorGlow.tailLength - i + 1) / CursorGlow.tailLength) * math.max(1 - stationaryTime, 0)
                        tailTexture:SetAlpha(alpha * CursorGlow.db.profile.opacity)
                        local tailSize = size * alpha
                        tailTexture:SetSize(tailSize, tailSize)
                        if alpha > 0 then
                            tailTexture:Show()
                        else
                            tailTexture:Hide()
                        end
                    else
                        tailTexture:Hide()
                    end
                end

                -- Remove positions when alpha reaches zero
                if stationaryTime >= 1 then  -- Adjust duration as needed
                    tailPositions = {}
                end
            else
                -- Tail effect disabled
                for _, tailTexture in ipairs(tailTextures) do
                    tailTexture:Hide()
                end
                tailPositions = {}
            end
        end

        prevX = cursorX
        prevY = cursorY
    end
end)




