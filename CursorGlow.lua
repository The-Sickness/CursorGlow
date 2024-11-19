-- CursorGlow
-- Made by Sharpedge_Gaming
-- v3.9 - 11.0.5

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
local pulseElapsedTime = 0  

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
	["ring23"] = "Interface\\Addons\\CursorGlow\\Textures\\Burst.png",
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
	"ring23",
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
	ring23 = 'Burst',
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
local tailPositions = {}  -- Stores previous cursor positions for each tail

-- Initialize tail textures
for i = 1, tailLength do
    local tailTexture = frame:CreateTexture(nil, "BACKGROUND")
    tailTexture:SetTexture(textureOptions["star4"])  -- Use the same texture as the main glow
    tailTexture:SetBlendMode("ADD")
    tailTexture:SetSize(32, 32)
    tailTextures[i] = tailTexture
end

local function InitializeTailTextures()
    -- Ensure tailTextures and tailPositions are initialized as empty tables
    tailTextures = tailTextures or {}
    tailPositions = tailPositions or {}

    -- Hide and clear existing tail textures
    for _, tailGroup in pairs(tailTextures) do
        if tailGroup then
            for _, tailTexture in ipairs(tailGroup) do
                if tailTexture and tailTexture.Hide then
                    tailTexture:Hide()
                    tailTexture:SetTexture(nil)
                end
            end
        end
    end
    tailTextures = {}
    tailPositions = {}

    -- Proceed with initializing new tail textures
    local numTails = CursorGlow.db.profile.numTails or 1
    local colorValue = colorOptions[CursorGlow.db.profile.color] or {1, 1, 1}
    local texturePath = textureOptions[CursorGlow.db.profile.texture] or textureOptions["star4"]

    for tailIndex = 1, numTails do
        tailTextures[tailIndex] = {}
        tailPositions[tailIndex] = {}
        
        for i = 1, CursorGlow.tailLength do
            local tailTexture = frame:CreateTexture(nil, "BACKGROUND")
            tailTexture:SetTexture(texturePath)
            tailTexture:SetBlendMode("ADD")
            tailTexture:SetSize(32, 32)
            tailTexture:SetVertexColor(colorValue[1], colorValue[2], colorValue[3], CursorGlow.db.profile.opacity)
            tailTextures[tailIndex][i] = tailTexture  -- Store the created texture
        end
    end
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
    return {1, 1, 1}  -- Fallback color (white) if class color is unavailable
end

local function UpdateTextureColor()
    local colorValue = colorOptions[CursorGlow.db.profile.color] or {1, 1, 1}
    texture:SetVertexColor(colorValue[1], colorValue[2], colorValue[3], CursorGlow.db.profile.opacity)
    -- Update tail textures' color
    for _, tailGroup in pairs(tailTextures) do
        if tailGroup then
            for _, tailTexture in ipairs(tailGroup) do
                if tailTexture then
                    tailTexture:SetVertexColor(colorValue[1], colorValue[2], colorValue[3], CursorGlow.db.profile.opacity)
                end
            end
        end
    end
end

local function UpdateTexture(textureKey)
    local texturePath = textureOptions[textureKey] or textureOptions["star4"]
    texture:SetTexture(texturePath)
    -- Update tail textures' texture
    for _, tailGroup in pairs(tailTextures) do
        if tailGroup then
            for _, tailTexture in ipairs(tailGroup) do
                if tailTexture then
                    tailTexture:SetTexture(texturePath)
                end
            end
        end
    end
    UpdateTextureColor()
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

-- Define default values for profiles and global settings
local profileDefaults = {
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
        color = "white",
        enableTail = false,
        tailLength = 60,
		numTails = 1,          
        tailSpacing = 10,      
        minimap = { hide = false },
		pulseEnabled = false,
        pulseMinSize = 50,
        pulseMaxSize = 100,
        pulseSpeed = 1,  
    }
}

local globalDefaults = {
    global = {
        profileEnabled = false,
    }
}

local charDefaults = {
    char = {
       lastSelectedProfile = nil,
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
    local explosionSize = CursorGlow.db.profile.explosionSize or 15  -- Set default size if nil
    local textureSize = CursorGlow.db.profile.explosionTextureSize or 10  -- Set default texture size if nil
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
    local profile = self.db.profile

    -- Initialize any missing profile settings with defaults
    profile.minimap = profile.minimap or { hide = false }  -- Ensure minimap settings are initialized
    profile.explosionColor = profile.explosionColor or {1, 1, 1}  -- Ensure explosionColor is initialized
    profile.minSize = profile.minSize or 16  -- Fallback to default if nil
    profile.maxSize = profile.maxSize or 175  -- Fallback to default if nil

    -- Ensure pulse settings are initialized
    profile.pulseEnabled = profile.pulseEnabled or false
    profile.pulseMinSize = profile.pulseMinSize or 50
    profile.pulseMaxSize = profile.pulseMaxSize or 100
    profile.pulseSpeed = profile.pulseSpeed or 1

    -- Apply texture, color, and other settings based on the current profile
    UpdateTexture(profile.texture)
    UpdateTextureColor(profile.color)
    UpdateAddonVisibility()
    CursorGlow.tailLength = CursorGlow.db.profile.tailLength or 60
    InitializeTailTextures()

    -- Manage minimap button visibility based on profile settings
    if profile.minimap.hide then
        icon:Hide("CursorGlow")
    else
        icon:Show("CursorGlow")
    end
end

function CursorGlow:SwitchProfile(forceGlobal, profileName)
    if profileName then
        self.db:SetProfile(profileName)
        self.dbChar.char.lastSelectedProfile = profileName  
    elseif forceGlobal or self.dbGlobal.global.profileEnabled then
        -- Set to global profile
        self.db:SetProfile("Global")
        self.dbGlobal.global.profileEnabled = true
    else
        -- Set to character-specific profile
        local characterProfileName = UnitName("player") .. " - " .. GetRealmName()
        self.db:SetProfile(characterProfileName)
        self.dbGlobal.global.profileEnabled = false
        self.dbChar.char.lastSelectedProfile = characterProfileName  
    end

    -- Ensure all necessary defaults are applied in the selected profile
    local profile = self.db.profile
    profile.operationMode = profile.operationMode or "enabledAlways"
    profile.enableExplosion = profile.enableExplosion or false
    profile.explosionColor = profile.explosionColor or {1, 1, 1}
    profile.explosionSize = profile.explosionSize or 15
    profile.explosionTextureSize = profile.explosionTextureSize or 10
    profile.explosionTexture = profile.explosionTexture or "ring1"
    profile.opacity = profile.opacity or 1
    profile.minSize = profile.minSize or 16
    profile.maxSize = profile.maxSize or 175
    profile.texture = profile.texture or "ring1"
    profile.color = profile.color or (forceGlobal and {1, 1, 1} or GetDefaultClassColor())
    profile.enableTail = profile.enableTail or false
    profile.tailLength = profile.tailLength or 60
    profile.minimap = profile.minimap or { hide = false }
    -- Ensure pulse settings are initialized
    profile.pulseEnabled = profile.pulseEnabled or false
    profile.pulseMinSize = profile.pulseMinSize or 50
    profile.pulseMaxSize = profile.pulseMaxSize or 100
    profile.pulseSpeed = profile.pulseSpeed or 1

    self:ApplySettings()
end

function CursorGlow:OnProfileChanged(event, db, newProfile)
    self.dbChar.char.lastSelectedProfile = self.db:GetCurrentProfile()
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
                globalProfileEnabled = {
                    type = 'toggle',
                    name = L["Enable Global Profile"],
                    desc = L["Use the same settings for all characters"],
                    order = 1,
                    get = function() return CursorGlow.dbGlobal.global.profileEnabled end,
                    set = function(_, val)
                        CursorGlow.dbGlobal.global.profileEnabled = val
                        if val then
                            CursorGlow.db:SetProfile("Global")
                        else
                            local characterProfileName = UnitName("player") .. " - " .. GetRealmName()
                            CursorGlow.db:SetProfile(characterProfileName)
                        end
                        CursorGlow:ApplySettings()
                    end,
                },
                operationMode = {
                    type = 'select',
                    name = L["Operation Mode"],
                    desc = L["Select when the addon should be active"],
                    order = 2,
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
                    order = 3,
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
                spacerGeneral1 = {
                    type = 'description',
                    name = " ",  -- Blank spacer for separation
                    order = 4,
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
                explosionColor = {
                    type = 'color',
                    name = L["Explosion Color"],
                    desc = L["Pick a color for the explosion effect"],
                    order = 2,
                    get = function()
                        local color = CursorGlow.db.profile.explosionColor
                        return unpack(color or {1, 1, 1})
                    end,
                    set = function(_, r, g, b)
                        CursorGlow.db.profile.explosionColor = {r, g, b}
                    end,
                    disabled = function() return not CursorGlow.db.profile.enableExplosion end,
                },
                spacerExplosion1 = {
                    type = 'description',
                    name = " ",  -- Blank spacer for separation
                    order = 3,
                },
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
                    disabled = function() return not CursorGlow.db.profile.enableExplosion end,
                },
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
                        ring23 = "Burst",
                    },
                    get = function() return CursorGlow.db.profile.explosionTexture end,
                    set = function(_, val)
                        CursorGlow.db.profile.explosionTexture = val
                        UpdateExplosionTexture(val)
                    end,
                    disabled = function() return not CursorGlow.db.profile.enableExplosion end,
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
                        InitializeTailTextures()
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
                        -- WoW Class Colors
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
                        UpdateTextureColor()
                        InitializeTailTextures()
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
                spacerAppearance1 = {
                    type = 'description',
                    name = " ",  -- Blank spacer for separation
                    order = 4,
                },
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
                            for _, tailGroup in pairs(tailTextures or {}) do
                                if tailGroup then
                                    for _, tailTexture in ipairs(tailGroup) do
                                        if tailTexture and tailTexture.Hide then
                                            tailTexture:Hide()
                                        end
                                    end
                                end
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
                numTails = {
                    type = 'range',
                    name = L["Number of Tails"],
                    desc = L["Select the number of tails"],
                    order = 3,
                    min = 1,
                    max = 5,
                    step = 1,
                    get = function() return CursorGlow.db.profile.numTails or 1 end,
                    set = function(_, val)
                        CursorGlow.db.profile.numTails = val
                        InitializeTailTextures()
                    end,
                    disabled = function() return not CursorGlow.db.profile.enableTail end,
                },
                tailSpacing = {
                    type = 'range',
                    name = L["Tail Spacing"],
                    desc = L["Adjust the spacing between multiple tails"],
                    order = 4,
                    min = 0,
                    max = 50,
                    step = 1,
                    get = function() return CursorGlow.db.profile.tailSpacing or 10 end,
                    set = function(_, val)
                        CursorGlow.db.profile.tailSpacing = val
                    end,
                    disabled = function() return not CursorGlow.db.profile.enableTail end,
                },
            },
        },

        -- Pulse Effect Settings Header
        pulseHeader = {
            type = 'header',
            name = L["Pulse Effect Settings"],
            order = 40,
        },
        pulseSettings = {
            type = 'group',
            name = L["Pulse Effect"],
            order = 41,
            inline = true,
            args = {
                pulseEnabled = {
                    type = 'toggle',
                    name = L["Enable Pulse Effect"],
                    desc = L["Toggle the pulsing effect when cursor is stationary"],
                    order = 1,
                    get = function() return CursorGlow.db.profile.pulseEnabled end,
                    set = function(_, val)
                        CursorGlow.db.profile.pulseEnabled = val
                    end,
                },
                pulseMinSize = {
                    type = 'range',
                    name = L["Pulse Minimum Size"],
                    desc = L["Set the minimum size of the pulse effect"],
                    order = 2,
                    min = 10,
                    max = 150,
                    step = 1,
                    get = function() return CursorGlow.db.profile.pulseMinSize end,
                    set = function(_, val)
                        CursorGlow.db.profile.pulseMinSize = val
                    end,
                    disabled = function() return not CursorGlow.db.profile.pulseEnabled end,
                },
                pulseMaxSize = {
                    type = 'range',
                    name = L["Pulse Maximum Size"],
                    desc = L["Set the maximum size of the pulse effect"],
                    order = 3,
                    min = 20,
                    max = 200,
                    step = 1,
                    get = function() return CursorGlow.db.profile.pulseMaxSize end,
                    set = function(_, val)
                        CursorGlow.db.profile.pulseMaxSize = val
                    end,
                    disabled = function() return not CursorGlow.db.profile.pulseEnabled end,
                },
                pulseSpeed = {
                    type = 'range',
                    name = L["Pulse Speed"],
                    desc = L["Adjust the speed of the pulsing effect"],
                    order = 4,
                    min = 0.1,
                    max = 5,
                    step = 0.1,
                    get = function() return CursorGlow.db.profile.pulseSpeed end,
                    set = function(_, val)
                        CursorGlow.db.profile.pulseSpeed = val
                    end,
                    disabled = function() return not CursorGlow.db.profile.pulseEnabled end,
                },
            },
        },
    },
}

function CursorGlow:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("CursorGlowDB", profileDefaults)
    self.dbChar = LibStub("AceDB-3.0"):New("CursorGlowCharDB", charDefaults)
    self.dbGlobal = LibStub("AceDB-3.0"):New("CursorGlowGlobalDB", globalDefaults)

    -- Register callbacks for dynamic profile changes
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
   
    if self.dbGlobal.global.profileEnabled then
        self.db:SetProfile("Global")
    elseif self.dbChar.char.lastSelectedProfile then
        self.db:SetProfile(self.dbChar.char.lastSelectedProfile)
    else
        local characterProfileName = UnitName("player") .. " - " .. GetRealmName()
        self.db:SetProfile(characterProfileName)
    end

    self:ApplySettings()

    if minimapButton and icon then
        icon:Register("CursorGlow", minimapButton, self.db.profile.minimap)
    else
        print("Error: Minimap button or LibDBIcon not properly initialized.")
    end

    if self.db.profile.minimap and self.db.profile.minimap.hide then
        icon:Hide("CursorGlow")
    else
        icon:Show("CursorGlow")
end

    -- Register the main options
    AceConfig:RegisterOptionsTable("CursorGlow", options)
    AceConfigDialog:AddToBlizOptions("CursorGlow", "CursorGlow")

    -- Create the profiles options table after self.db is initialized
    local profilesOptions = AceDBOptions:GetOptionsTable(self.db)

    -- Register the profile options separately under "Profiles" tab
    AceConfig:RegisterOptionsTable("CursorGlow Profiles", profilesOptions)
    AceConfigDialog:AddToBlizOptions("CursorGlow Profiles", "Profiles", "CursorGlow")
end

frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

function HandleCombatState()
    if CursorGlow.db.profile.combatOnly then
        ToggleAddon(CursorGlow.db.profile.enabled)
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        UpdateAddonVisibility()
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
        UpdateTexture(CursorGlow.db.profile.texture)
        UpdateTextureColor(CursorGlow.db.profile.color)
        UpdateAddonVisibility()
        speed = 0
    end
end)

function CursorGlow:DisableTailEffect()
    if CursorGlow.db.profile.enableTail then
        -- Only attempt to hide textures if the tail effect is enabled
        for _, tailGroup in pairs(tailTextures or {}) do
            if tailGroup then
                for _, tailTexture in ipairs(tailGroup or {}) do
                    if tailTexture and tailTexture.Hide then
                        tailTexture:Hide()
                    end
                end
            end
        end
        tailPositions = {}
    end
end

frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Modified OnUpdate function to include pulse effect in all operation modes
frame:SetScript("OnUpdate", function(self, elapsed)
    local profile = CursorGlow.db.profile
    local opacity = profile.opacity or 1

    -- Variables to track cursor position and movement
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

    local scale = UIParent:GetEffectiveScale()

    -- Update stationary time
    if distance > 0 then
        stationaryTime = 0
        pulseElapsedTime = 0  -- Reset pulse timer when moving
    else
        stationaryTime = stationaryTime + elapsed
    end

    -- Determine size based on movement or pulse effect
    local size
    if distance > 0 then
        size = math.max(math.min(speed / 6, profile.maxSize), profile.minSize)
    elseif profile.pulseEnabled and stationaryTime >= 0.5 then
        pulseElapsedTime = pulseElapsedTime + elapsed
        local pulseSpeed = profile.pulseSpeed or 1
        local pulseProgress = (math.sin(pulseElapsedTime * pulseSpeed * math.pi * 2) + 1) / 2

        -- Calculate pulse size and alpha
        size = profile.pulseMinSize + (profile.pulseMaxSize - profile.pulseMinSize) * pulseProgress
        local pulseAlpha = opacity * pulseProgress
        texture:SetAlpha(pulseAlpha)
    else
        size = profile.minSize
        texture:SetAlpha(opacity)
    end

    -- Update texture size and position
    texture:SetHeight(size)
    texture:SetWidth(size)
    texture:SetAlpha(texture:GetAlpha() or opacity)

    -- Position the texture based on operation mode
    if profile.operationMode == "enabledAlwaysOnCursor" then
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, cursorY / scale)
        texture:Show()
    elseif profile.operationMode == "enabledInCombat" then
        if UnitAffectingCombat("player") then
            if distance > 0 or (profile.pulseEnabled and stationaryTime >= 0.5) then
                texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, cursorY / scale)
                texture:Show()
            else
                texture:Hide()
            end
        else
            texture:Hide()
        end
    else -- "enabledAlways"
        if distance > 0 or (profile.pulseEnabled and stationaryTime >= 0.5) then
            texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, cursorY / scale)
            texture:Show()
        else
            texture:Hide()
        end
    end

    -- Handle tail effect
    if profile.enableTail then
        local numTails = tonumber(profile.numTails) or 1
        local tailSpacing = tonumber(profile.tailSpacing) or 10
        CursorGlow.tailLength = tonumber(CursorGlow.tailLength) or 60

        if distance > 0 then
            for tailIndex = 1, numTails do
                local offset = (tailIndex - (numTails + 1) / 2) * tailSpacing * scale
                local cursorPos = { x = (cursorX + offset) / scale, y = cursorY / scale }

                tailPositions[tailIndex] = tailPositions[tailIndex] or {}
                table.insert(tailPositions[tailIndex], 1, cursorPos)
                if #tailPositions[tailIndex] > CursorGlow.tailLength then
                    table.remove(tailPositions[tailIndex])
                end

                tailTextures[tailIndex] = tailTextures[tailIndex] or {}
                for i, tailTexture in ipairs(tailTextures[tailIndex]) do
                    local pos = tailPositions[tailIndex][i]
                    if pos and tailTexture then
                        tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                        local alpha = (CursorGlow.tailLength - i + 1) / CursorGlow.tailLength
                        tailTexture:SetAlpha(alpha * opacity)
                        tailTexture:SetSize(size, size)
                        tailTexture:Show()
                    elseif tailTexture then
                        tailTexture:Hide()
                    end
                end
            end
        else
            if stationaryTime < 1 then
                for tailIndex = 1, numTails do
                    for i, tailTexture in ipairs(tailTextures[tailIndex] or {}) do
                        local pos = tailPositions[tailIndex] and tailPositions[tailIndex][i]
                        if pos and tailTexture then
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                            local alpha = ((CursorGlow.tailLength - i + 1) / CursorGlow.tailLength) * math.max(1 - stationaryTime, 0)
                            tailTexture:SetAlpha(alpha * opacity)
                            tailTexture:SetSize(size * alpha, size * alpha)
                            if alpha > 0 then
                                tailTexture:Show()
                            else
                                tailTexture:Hide()
                            end
                        elseif tailTexture then
                            tailTexture:Hide()
                        end
                    end
                end
            else
                tailPositions = {}
                for _, tailGroup in pairs(tailTextures) do
                    for _, tailTexture in ipairs(tailGroup or {}) do
                        if tailTexture then
                            tailTexture:Hide()
                        end
                    end
                end
            end
        end
    else
        -- Hide tail textures if tail effect is disabled
        for _, tailGroup in pairs(tailTextures) do
            for _, tailTexture in ipairs(tailGroup or {}) do
                if tailTexture then
                    tailTexture:Hide()
                end
            end
        end
        tailPositions = {}
    end

    prevX = cursorX
    prevY = cursorY
end)


