local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Define texture options
local textureOptions = {
    ["star4"] = "Interface\\Cooldown\\star4",
    ["starburst"] = "Interface\\Cooldown\\starburst",
    -- You can add more textures here as needed
}

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
    white = {1, 1, 1},    -- White color
    pink = {1, 0.08, 0.58}, -- Pink color
    orange = {1, 0.65, 0}, -- Orange color
    cyan = {0, 1, 1}     -- Cyan color
}

-- Initialize default settings with added size range
CursorGlowSettings = CursorGlowSettings or {
    enabled = true,     -- Addon enabled by default
    color = "red",
    opacity = 0.5,
    minSize = 16,
    maxSize = 128,
    texture = "star4"  -- Default texture
}

-- Function to update texture color and opacity
local function UpdateTextureColor(color)
    local colorValue = colorOptions[color] or colorOptions["red"]
    texture:SetVertexColor(colorValue[1], colorValue[2], colorValue[3], CursorGlowSettings.opacity)
end

-- Function to update the texture
local function UpdateTexture(textureKey)
    local texturePath = textureOptions[textureKey] or textureOptions["star4"]
    texture:SetTexture(texturePath)
    UpdateTextureColor(CursorGlowSettings.color) -- Update color to refresh the texture
end

-- Function to toggle the addon's functionality
local function ToggleAddon(enable)
    if enable then
        frame:Show()
    else
        frame:Hide()
    end
end

-- Addon options table for AceConfig
local options = {
    name = "CursorGlow",
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = 'General',
            order = 1,
            args = {
                enabled = {
                    type = 'toggle',
                    name = 'Enable Addon',
                    desc = 'Enable or disable the addon',
                    order = 1,
                    get = function() return CursorGlowSettings.enabled end,
                    set = function(_, val)
                        CursorGlowSettings.enabled = val
                        ToggleAddon(val)
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
                    values = {
                        star4 = 'Star4',
                        starburst = 'Starburst',
                        -- Add other textures here
                    },
                    get = function() return CursorGlowSettings.texture end,
                    set = function(_, val)
                        CursorGlowSettings.texture = val
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
                        cyan = 'Cyan'
                    },
                    get = function() return CursorGlowSettings.color end,
                    set = function(_, val)
                        CursorGlowSettings.color = val
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
                    get = function() return CursorGlowSettings.opacity end,
                    set = function(_, val)
                        CursorGlowSettings.opacity = val
                        UpdateTextureColor(CursorGlowSettings.color)
                    end,
                },
                minSize = {
                    type = 'range',
                    name = 'Minimum Size',
                    desc = 'Set the minimum size of the texture',
                    order = 4,
                    min = 0,
                    max = 64,
                    step = 1,
                    get = function() return CursorGlowSettings.minSize end,
                    set = function(_, val)
                        CursorGlowSettings.minSize = val
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
                    get = function() return CursorGlowSettings.maxSize end,
                    set = function(_, val)
                        CursorGlowSettings.maxSize = val
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

-- Event handling
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "CursorGlow" then
        -- Apply saved settings once they are loaded
        UpdateTexture(CursorGlowSettings.texture)
    end
end)
frame:RegisterEvent("ADDON_LOADED")

-- OnUpdate function for the frame
frame:SetScript("OnUpdate", function(self, elapsed)
    -- Ensure settings have valid values
    CursorGlowSettings.maxSize = CursorGlowSettings.maxSize or 128
    CursorGlowSettings.minSize = CursorGlowSettings.minSize or 16

    local prevX, prevY = x, y
    x, y = GetCursorPosition()
    local dX, dY = x - prevX, y - prevY

    local distance = math.sqrt(dX * dX + dY * dY)
    local decayFactor = 2048 ^ -elapsed
    speed = math.min(decayFactor * speed + (1 - decayFactor) * distance / elapsed, 1024)

    local size = math.max(math.min(speed / 6, CursorGlowSettings.maxSize), CursorGlowSettings.minSize)
    if size > CursorGlowSettings.minSize then
        local scale = UIParent:GetEffectiveScale()
        texture:SetHeight(size)
        texture:SetWidth(size)
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (x + 0.5 * dX) / scale, (y + 0.5 * dY) / scale)
        texture:Show()
    else
        texture:Hide()
    end
end)








