-- Ensure Ace3 is loaded
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Create the main frame and texture
local frame = CreateFrame("Frame", nil, UIParent)
frame:SetFrameStrata("TOOLTIP")
local texture = frame:CreateTexture()
texture:SetTexture([[Interface\Cooldown\star4]])
texture:SetBlendMode("ADD")
texture:SetAlpha(0.5)

-- Define color options
local colorOptions = {
    red = {1, 0, 0, 1},
    green = {0, 1, 0, 1},
    blue = {0, 0, 1, 1},
    purple = {1, 0, 1, 1},
    white = {1, 1, 1, 1},    -- White color
    pink = {1, 0.08, 0.58, 1}, -- Pink color
    orange = {1, 0.65, 0, 1}, -- Orange color
    cyan = {0, 1, 1, 1}     -- Cyan color
}

-- Function to update texture color
local function UpdateTextureColor(color)
    texture:SetVertexColor(unpack(colorOptions[color] or colorOptions["red"]))
end

-- Initialize default settings (will be overwritten by SavedVariables)
CursorGlowSettings = CursorGlowSettings or {
    color = "red"
}

-- Addon options table for AceConfig
local options = {
    name = "CursorGlow",
    type = 'group',
    args = {
        color = {
            type = 'select',
            name = 'Color',
            desc = 'Select the color for the texture',
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
        UpdateTextureColor(CursorGlowSettings.color)
    end
end)
frame:RegisterEvent("ADDON_LOADED")

-- OnUpdate function for the frame
frame:SetScript("OnUpdate", function(self, elapsed)
    local prevX, prevY = x, y
    x, y = GetCursorPosition()
    local dX, dY = x - prevX, y - prevY

    local distance = math.sqrt(dX * dX + dY * dY)
    local decayFactor = 2048 ^ -elapsed
    speed = math.min(decayFactor * speed + (1 - decayFactor) * distance / elapsed, 1024)

    local size = speed / 6 - 16
    if size > 0 then
        local scale = UIParent:GetEffectiveScale()
        texture:SetHeight(size)
        texture:SetWidth(size)
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", (x + 0.5 * dX) / scale, (y + 0.5 * dY) / scale)
        texture:Show()
    else
        texture:Hide()
    end
end)





