-- CursorGlow
-- Made by Sharpedge_Gaming
-- v6.3 


local LibStub = LibStub or _G.LibStub
local AceDB            = LibStub:GetLibrary("AceDB-3.0")
local AceAddon         = LibStub:GetLibrary("AceAddon-3.0")
local AceConfig        = LibStub:GetLibrary("AceConfig-3.0")
local AceConfigDialog  = LibStub:GetLibrary("AceConfigDialog-3.0")
local AceDBOptions     = LibStub:GetLibrary("AceDBOptions-3.0")
local LDB              = LibStub:GetLibrary("LibDataBroker-1.1")
local LSM              = LibStub:GetLibrary("LibSharedMedia-3.0")
local AceGUI           = LibStub:GetLibrary("AceGUI-3.0")
local icon             = LibStub("LibDBIcon-1.0")
local L                = LibStub("AceLocale-3.0"):GetLocale("CursorGlow", true)

local CursorGlow = AceAddon:NewAddon("CursorGlow", "AceEvent-3.0", "AceConsole-3.0")

local NUM_PARTICLES   = 100
local EXPLOSION_SPEED = 30
CursorGlow.rotationAngle = 0

-- Texture options
local textureOptions = {
    ["ring1"]  = "Interface\\Addons\\CursorGlow\\Textures\\Test2.png",
    ["ring2"]  = "Interface\\Addons\\CursorGlow\\Textures\\Test3.png",
    ["ring3"]  = "Interface\\Addons\\CursorGlow\\Textures\\Test4.png",
    ["ring4"]  = "Interface\\Addons\\CursorGlow\\Textures\\Test6.png",
    ["ring5"]  = "Interface\\Addons\\CursorGlow\\Textures\\Test5.png",
    ["ring6"]  = "Interface\\Addons\\CursorGlow\\Textures\\Test8.png",
    ["ring7"]  = "Interface\\Addons\\CursorGlow\\Textures\\Test7.png",
    ["ring8"]  = "Interface\\Addons\\CursorGlow\\Textures\\Test9.png",
    ["ring9"]  = "Interface\\Addons\\CursorGlow\\Textures\\Test10.png",
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
    ["ring24"] = "Interface\\Addons\\CursorGlow\\Textures\\Fireball1.png",
    ["ring25"] = "Interface\\Addons\\CursorGlow\\Textures\\Spiderweb.png",
    ["ring26"] = "Interface\\Addons\\CursorGlow\\Textures\\ShatteredGlass.png",
    ["ring27"] = "Interface\\Addons\\CursorGlow\\Textures\\Bubbles.png",
    ["ring28"] = "Interface\\Addons\\CursorGlow\\Textures\\Eyeball.png",
    ["ring29"] = "Interface\\Addons\\CursorGlow\\Textures\\Skull.png",
    ["ring30"] = "Interface\\Addons\\CursorGlow\\Textures\\Snowflake.png",
    ["ring31"] = "Interface\\Addons\\CursorGlow\\Textures\\Paw.png",
    ["explosionParticle"] = "Interface\\Addons\\CursorGlow\\Textures\\Test17.png",
}
local orderedKeys = {
    "ring1","ring2","ring3","ring4","ring5","ring6","ring7","ring8","ring9","ring10",
    "ring11","ring12","ring13","ring14","ring15","ring16","ring17","ring18","ring19","ring20",
    "ring21","ring22","ring23","ring24","ring25","ring26","ring27","ring28","ring29","ring30","ring31",
}
local displayNames = {
    ring1='Ring 1', ring2='Ring 2', ring3='Ring 3', ring4='Ring 4', ring5='Ring 5',
    ring6='Ring 6', ring7='Ring 7', ring8='Ring 8', ring9='Ring 9', ring10='Star 1',
    ring11='Star 2', ring12='Star 3', ring13='Star 4', ring14='Star 5', ring15='Starburst',
    ring16='Butterfly', ring17='Butterfly2', ring18='Butterfly3', ring19='Swirl', ring20='Swirl2',
    ring21='Horde', ring22='Alliance', ring23='Burst', ring24='Fireball', ring25='Spiderweb',
    ring26='ShatteredGlass', ring27='Bubbles', ring28='Eyeball', ring29='Skull', ring30='Snowflake', ring31='Paw',
}
local values = {}; for _, key in ipairs(orderedKeys) do values[key] = displayNames[key] end

-- Predefined colors kept for migration and optional "Use Class Color"
local colorOptions = {
    red={1,0,0}, green={0,1,0}, blue={0,0,1}, purple={1,0,1}, white={1,1,1},
    pink={1,0.08,0.58}, orange={1,0.65,0}, cyan={0,1,1}, yellow={1,1,0}, gray={0.5,0.5,0.5},
    gold={1,0.84,0}, teal={0,0.5,0.5}, magenta={1,0,1}, lime={0.75,1,0}, olive={0.5,0.5,0}, navy={0,0,0.5},
    warrior={0.78,0.61,0.43}, paladin={0.96,0.55,0.73}, hunter={0.67,0.83,0.45}, rogue={1.00,0.96,0.41},
    priest={1,1,1}, deathknight={0.77,0.12,0.23}, shaman={0,0.44,0.87}, mage={0.41,0.80,0.94},
    warlock={0.58,0.51,0.79}, monk={0,1,0.59}, druid={1,0.49,0.04}, demonhunter={0.64,0.19,0.79}, evoker={0.20,0.58,0.50}
}

-- Frame & main texture
local frame = CreateFrame("Frame", nil, UIParent)
frame:SetFrameStrata("TOOLTIP")

local texture = frame:CreateTexture()
texture:SetTexture(textureOptions["ring14"]) -- safe initial texture
texture:SetBlendMode("ADD")
texture:SetSize(32, 32)
CursorGlow.texture = texture

local zzzFont = frame:CreateFontString(nil, "OVERLAY")
zzzFont:SetFont("Fonts\\FRIZQT__.TTF", 30, "OUTLINE")
zzzFont:SetText("ZZZ")
zzzFont:SetTextColor(1, 0, 0, 1)
zzzFont:Hide()

-- Tail data
local tailTextures = {}
local tailPositions = {}
CursorGlow.tailLength = 60

-- Particles (explosion)
local particles = {}

local function CreateExplosionParticles(textureKey, size)
    for i = 1, NUM_PARTICLES do
        if not particles[i] then
            local particle = CreateFrame("Frame", nil, UIParent)
            particle:SetFrameStrata("TOOLTIP")
            particle:SetSize(size, size)
            local tex = particle:CreateTexture(nil, "ARTWORK")
            tex:SetBlendMode("ADD")
            tex:SetAllPoints(particle)
            particle.texture = tex
            particle:Hide()
            particles[i] = particle
        end
        local path = textureOptions[textureKey]
        particles[i].texture:SetTexture(path)
        particles[i]:SetSize(size, size)
        particles[i].texture:SetVertexColor(1,1,1,1)
    end
end

-- Helpers
local function GetDefaultClassColor()
    local _, class = UnitClass("player")
    if class and RAID_CLASS_COLORS[class] then
        local c = RAID_CLASS_COLORS[class]
        return {c.r, c.g, c.b}
    end
    return {1,1,1}
end

-- New: read color as RGB (supports table {r,g,b} and migrates old string keys)
local function GetActiveColor()
    local c = CursorGlow.db and CursorGlow.db.profile and CursorGlow.db.profile.color
    if type(c) == "table" then
        return c[1] or 1, c[2] or 1, c[3] or 1
    elseif type(c) == "string" then
        local m = colorOptions[c] or {1,1,1}
        return m[1], m[2], m[3]
    else
        return 1,1,1
    end
end

local function UpdateTextureColor()
    local r,g,b = GetActiveColor()
    local a = CursorGlow.db.profile.opacity or 1
    texture:SetVertexColor(r, g, b, a)
    for _, tailGroup in pairs(tailTextures) do
        for _, t in ipairs(tailGroup or {}) do
            t:SetVertexColor(r, g, b, a)
        end
    end
end

local function UpdateTexture(texKey)
    local path = textureOptions[texKey] or textureOptions["ring14"]
    texture:SetTexture(path)
    for _, tailGroup in pairs(tailTextures) do
        for _, t in ipairs(tailGroup or {}) do
            t:SetTexture(path)
        end
    end
    UpdateTextureColor()
end

local function ToggleAddon(enable)
    if not CursorGlow.db.profile.combatOnly or UnitAffectingCombat("player") then
        if enable then frame:Show() else frame:Hide() end
    end
end

local function UpdateAddonVisibility()
    local mode = CursorGlow.db.profile.operationMode
    if mode == "disabled" then
        frame:Hide()
    elseif mode == "enabledAlways" or mode == "enabledAlwaysOnCursor" then
        frame:Show()
    elseif mode == "enabledInCombat" then
        if UnitAffectingCombat("player") then frame:Show() else frame:Hide() end
    end
end

local function InitializeTailTextures()
    for _, tailGroup in pairs(tailTextures) do
        for _, t in ipairs(tailGroup or {}) do
            t:Hide()
            t:SetTexture(nil)
        end
    end
    wipe(tailTextures)
    wipe(tailPositions)

    local numTails = CursorGlow.db.profile.numTails or 1
    local r,g,b = GetActiveColor()
    local a = CursorGlow.db.profile.opacity or 1
    local path = textureOptions[CursorGlow.db.profile.texture] or textureOptions["ring14"]

    for tailIndex = 1, numTails do
        tailTextures[tailIndex] = {}
        tailPositions[tailIndex] = {}
        for i = 1, CursorGlow.tailLength do
            local tt = frame:CreateTexture(nil, "BACKGROUND")
            tt:SetTexture(path)
            tt:SetBlendMode("ADD")
            tt:SetSize(32, 32)
            tt:SetVertexColor(r, g, b, a)
            tailTextures[tailIndex][i] = tt
        end
    end
end

local function UpdateExplosionTextureSize(size)
    for _, particle in ipairs(particles) do
        particle:SetSize(size, size)
    end
end

local function TriggerExplosion(cursorX, cursorY)
    local scale           = UIParent:GetEffectiveScale()
    local profile         = CursorGlow.db.profile
    local color           = profile.explosionColor or {1,1,1}
    local explosionSize   = profile.explosionSize or 15
    local texSize         = profile.explosionTextureSize or 10
    local explosionTexKey = profile.explosionTexture or "ring1"

    CreateExplosionParticles(explosionTexKey, texSize)

    for _, particle in ipairs(particles) do
        local angle   = math.random() * 2 * math.pi
        local dist    = math.random(1, explosionSize)
        local xOffset = math.cos(angle) * dist
        local yOffset = math.sin(angle) * dist

        particle:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, cursorY / scale)
        particle:SetAlpha(1)
        particle.texture:SetAlpha(1)
        particle.texture:SetVertexColor(color[1], color[2], color[3])
        particle:Show()

        particle:SetScript("OnUpdate", function(self, elapsed)
            local dx, dy = EXPLOSION_SPEED * xOffset * elapsed, EXPLOSION_SPEED * yOffset * elapsed
            local cx, cy = self:GetCenter()
            self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx + dx, cy + dy)
            local alpha = (self:GetAlpha() or 1) - (elapsed * 0.8)
            if alpha <= 0 then self:Hide() else self:SetAlpha(alpha) end
        end)
    end
end

local function TriggerExplosionOnClick()
    local x, y = GetCursorPosition()
    TriggerExplosion(x, y)
end

-- LDB / Minimap
local minimapButton = LDB:NewDataObject("CursorGlow", {
    type = "data source",
    text = "CursorGlow",
    icon = "Interface\\Icons\\Spell_Frost_Frost",
    OnClick = function(_, button)
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
    OnTooltipShow = function(tt)
        tt:AddLine("|cFF00FF00CursorGlow|r")
        tt:AddLine("|cFFFFFFFFLeft-click to open settings.|r")
        tt:AddLine("|cFFFFFFFFRight-click to toggle addon.|r")
    end,
})

-- Profiles
local defaultClassColor = GetDefaultClassColor()
local profileDefaults = {
    profile = {
        operationMode = "enabledAlways",
        enableExplosion = false,
        explosionColor = {1,1,1},
        explosionSize = 15,
        explosionTextureSize = 10,
        explosionTexture = "ring1",
        opacity = 1,
        minSize = 16,
        maxSize = 175,
        texture = "ring1",
        color = {1,1,1}, -- RGB table
        enableTail = false,
        tailLength = 60,
        numTails = 1,
        tailSpacing = 10,
        minimap = { hide = false },
        pulseEnabled = false,
        pulseMinSize = 50,
        pulseMaxSize = 100,
        pulseSpeed = 1,
        combatOnly = false,
        enabled = true,
        idleIndicatorEnabled = true,
        idleThreshold = 60,
        tailEffectStyle = "classic",
        tailParticleSpeed = 0.5,
        tailParticleScatter = 6,
        tailParticleWobble = 5,
        rotationEnabled = false,
        rotationSpeed = 30,
        bounceEnabled = false,
        bounceSpeed = 2,
        bounceAmplitude = 12,
    }
}
local globalDefaults = { global = { profileEnabled = false } }
local charDefaults   = { char = { lastSelectedProfile = nil } }

-- Apply settings
function CursorGlow:ApplySettings()
    local profile = self.db.profile

    -- Migrate old string color -> RGB once
    if type(profile.color) == "string" then
        local m = colorOptions[profile.color] or {1,1,1}
        profile.color = {m[1], m[2], m[3]}
    end
    if type(profile.color) ~= "table" then profile.color = {1,1,1} end

    profile.minimap             = profile.minimap or { hide = false }
    profile.explosionColor      = profile.explosionColor or {1,1,1}
    profile.minSize             = profile.minSize or 16
    profile.maxSize             = profile.maxSize or 175
    profile.pulseEnabled        = profile.pulseEnabled or false
    profile.pulseMinSize        = profile.pulseMinSize or 50
    profile.pulseMaxSize        = profile.pulseMaxSize or 100
    profile.pulseSpeed          = profile.pulseSpeed or 1
    if profile.idleIndicatorEnabled == nil then profile.idleIndicatorEnabled = true end
    profile.idleThreshold       = profile.idleThreshold or 60
    profile.tailEffectStyle     = profile.tailEffectStyle or "classic"
    profile.tailParticleSpeed   = profile.tailParticleSpeed or 0.5
    profile.tailParticleScatter = profile.tailParticleScatter or 6
    profile.tailParticleWobble  = profile.tailParticleWobble or 5

    UpdateTexture(profile.texture)
    UpdateTextureColor()
    UpdateAddonVisibility()
    CursorGlow.tailLength = profile.tailLength or 60
    InitializeTailTextures()

    if profile.minimap.hide then icon:Hide("CursorGlow") else icon:Show("CursorGlow") end

    if not profile.rotationEnabled and CursorGlow.texture then
        CursorGlow.rotationAngle = 0
        CursorGlow.texture:SetRotation(0)
    end
end

function CursorGlow:SwitchProfile(forceGlobal, profileName)
    if profileName then
        self.db:SetProfile(profileName)
        self.dbChar.char.lastSelectedProfile = profileName
    elseif forceGlobal or self.dbGlobal.global.profileEnabled then
        self.db:SetProfile("Global")
        self.dbGlobal.global.profileEnabled = true
    else
        local characterProfileName = UnitName("player") .. " - " .. GetRealmName()
        self.db:SetProfile(characterProfileName)
        self.dbGlobal.global.profileEnabled = false
        self.dbChar.char.lastSelectedProfile = characterProfileName
    end
    self:ApplySettings()
end

function CursorGlow:OnProfileChanged()
    self.dbChar.char.lastSelectedProfile = self.db:GetCurrentProfile()
    self:ApplySettings()
end

-- Options
local valuesTextures = values
local options = {
    name = "CursorGlow",
    type = 'group',
    args = {
        generalHeader = { type='header', name=L["General Settings"], order=1 },
        general = {
            type='group', name=L["General"], order=2, inline=true,
            args = {
                globalProfileEnabled = {
                    type='toggle', name=L["Enable Global Profile"], desc=L["Use the same settings for all characters"], order=1,
                    get=function() return CursorGlow.dbGlobal.global.profileEnabled end,
                    set=function(_, val)
                        CursorGlow.dbGlobal.global.profileEnabled = val
                        if val then
                            CursorGlow.db:SetProfile("Global")
                        else
                            local n = UnitName("player") .. " - " .. GetRealmName()
                            CursorGlow.db:SetProfile(n)
                        end
                        CursorGlow:ApplySettings()
                    end,
                },
                operationMode = {
                    type='select', name=L["Operation Mode"], desc=L["Select when the addon should be active"], order=2,
                    values = {
                        enabledAlways = L["Enabled Always"],
                        enabledInCombat = L["Enabled in Combat Only"],
                        enabledAlwaysOnCursor = L["Always Show on Cursor"],
                    },
                    get=function() return CursorGlow.db.profile.operationMode end,
                    set=function(_, val) CursorGlow.db.profile.operationMode = val; UpdateAddonVisibility() end,
                },
                showMinimapIcon = {
                    type='toggle', name=L["Show Minimap Icon"], desc=L["Show or hide the minimap icon"], order=3,
                    get=function() return not CursorGlow.db.profile.minimap.hide end,
                    set=function(_, val)
                        CursorGlow.db.profile.minimap.hide = not val
                        if val then icon:Show("CursorGlow") else icon:Hide("CursorGlow") end
                    end,
                },
                idleIndicatorEnabled = {
                    type='toggle', name="Show ZZZ Above Cursor When Idle", desc="Show a floating ZZZ indicator above the cursor after being idle.",
                    order=4,
                    get=function() return CursorGlow.db.profile.idleIndicatorEnabled end,
                    set=function(_, val)
                        CursorGlow.db.profile.idleIndicatorEnabled = val
                        if not val then zzzFont:Hide() end
                        CursorGlow:ApplySettings()
                    end,
                },
                idleThreshold = {
                    type='range', name="Idle Time (seconds)", desc="How long to wait before showing the ZZZ indicator.",
                    order=5, min=5, max=300, step=1,
                    get=function() return CursorGlow.db.profile.idleThreshold end,
                    set=function(_, val) CursorGlow.db.profile.idleThreshold = val end,
                },
                spacerGeneral1 = { type='description', name=" ", order=6 },
            },
        },

        explosionHeader = { type='header', name=L["Explosion Settings"], order=10 },
        explosion = {
            type='group', name=L["Explosion"], order=11, inline=true,
            args = {
                enableExplosion = {
                    type='toggle', name=L["Enable Explosion Effect"], desc=L["Enable or disable the explosion effect on left-click"], order=1,
                    get=function() return CursorGlow.db.profile.enableExplosion end,
                    set=function(_, val) CursorGlow.db.profile.enableExplosion = val end,
                },
                explosionColor = {
                    type='color', name=L["Explosion Color"], desc=L["Pick a color for the explosion effect"], order=2,
                    get=function() local c=CursorGlow.db.profile.explosionColor or {1,1,1}; return c[1],c[2],c[3] end,
                    set=function(_, r,g,b) CursorGlow.db.profile.explosionColor = {r,g,b} end,
                    disabled=function() return not CursorGlow.db.profile.enableExplosion end,
                },
                spacerExplosion1 = { type='description', name=" ", order=3 },
                explosionSize = {
                    type='range', name=L["Explosion Size"], desc=L["Adjust the size of the explosion effect"], order=4, min=5, max=50, step=1,
                    get=function() return CursorGlow.db.profile.explosionSize end,
                    set=function(_, v) CursorGlow.db.profile.explosionSize = v end,
                    disabled=function() return not CursorGlow.db.profile.enableExplosion end,
                },
                explosionTextureSize = {
                    type='range', name=L["Explosion Texture Size"], desc=L["Adjust the texture size for the explosion effect"], order=5, min=10, max=40, step=1,
                    get=function() return CursorGlow.db.profile.explosionTextureSize end,
                    set=function(_, v) CursorGlow.db.profile.explosionTextureSize = v; UpdateExplosionTextureSize(v) end,
                    disabled=function() return not CursorGlow.db.profile.enableExplosion end,
                },
                explosionTexture = {
                    type='select', name=L["Explosion Texture"], desc=L["Select the texture for the explosion effect"], order=6, values=valuesTextures,
                    get=function() return CursorGlow.db.profile.explosionTexture end,
                    set=function(_, val)
                        CursorGlow.db.profile.explosionTexture = val
                        CreateExplosionParticles(val, CursorGlow.db.profile.explosionTextureSize or 10)
                        local c = CursorGlow.db.profile.explosionColor or {1,1,1}
                        for _, p in ipairs(particles) do
                            p.texture:SetVertexColor(c[1], c[2], c[3])
                        end
                    end,
                    disabled=function() return not CursorGlow.db.profile.enableExplosion end,
                },
            },
        },

        appearanceHeader = { type='header', name=L["Appearance Settings"], order=20 },
        appearance = {
            type='group', name=L["Appearance"], order=21, inline=true,
            args = {
                texture = {
                    type='select', name=L["Texture"], desc=L["Select the texture for the cursor glow"], order=1, values=valuesTextures,
                    get=function() return CursorGlow.db.profile.texture end,
                    set=function(_, val) CursorGlow.db.profile.texture = val; UpdateTexture(val); InitializeTailTextures() end,
                },
                color = {
                    type='color', name=L["Color"], desc=L["Select the color for the texture"], order=2, hasAlpha=false,
                    get=function()
                        local c = CursorGlow.db.profile.color or {1,1,1}
                        return c[1], c[2], c[3]
                    end,
                    set=function(_, r,g,b)
                        CursorGlow.db.profile.color = {r,g,b}
                        UpdateTextureColor()
                        InitializeTailTextures()
                    end,
                },
                useClassColor = {
                    type='execute', name="Use Class Color", order=2.1,
                    func=function()
                        local c = GetDefaultClassColor()
                        CursorGlow.db.profile.color = {c[1], c[2], c[3]}
                        UpdateTextureColor()
                        InitializeTailTextures()
                    end,
                },
                opacity = {
                    type='range', name=L["Opacity"], desc=L["Adjust the opacity of the texture"], order=3, min=0, max=1, step=0.01,
                    get=function() return CursorGlow.db.profile.opacity end,
                    set=function(_, v) CursorGlow.db.profile.opacity = v; UpdateTextureColor() end,
                },
                rotationEnabled = {
                    type='toggle', name="Enable Rotation", desc="Slowly rotate the main cursor texture.", order=3.1,
                    get=function() return CursorGlow.db.profile.rotationEnabled end,
                    set=function(_, val)
                        CursorGlow.db.profile.rotationEnabled = val
                        if not val and CursorGlow.texture then
                            CursorGlow.rotationAngle = 0
                            CursorGlow.texture:SetRotation(0)
                        end
                    end,
                },
                rotationSpeed = {
                    type='range', name="Rotation Speed", desc="Degrees per second for rotation.", order=3.2, min=5, max=360, step=5,
                    get=function() return CursorGlow.db.profile.rotationSpeed end,
                    set=function(_, v) CursorGlow.db.profile.rotationSpeed = v end,
                    disabled=function() return not CursorGlow.db.profile.rotationEnabled end,
                },
                bounceEnabled = {
                    type='toggle', name="Enable Bounce", desc="Make the cursor move up and down.", order=3.3,
                    get=function() return CursorGlow.db.profile.bounceEnabled end,
                    set=function(_, v) CursorGlow.db.profile.bounceEnabled = v end,
                },
                bounceSpeed = {
                    type='range', name="Bounce Speed", desc="Number of up/down cycles per second.", order=3.4, min=0.2, max=5, step=0.1,
                    get=function() return CursorGlow.db.profile.bounceSpeed end,
                    set=function(_, v) CursorGlow.db.profile.bounceSpeed = v end,
                    disabled=function() return not CursorGlow.db.profile.bounceEnabled end,
                },
                bounceAmplitude = {
                    type='range', name="Bounce Amplitude", desc="Vertical distance (pixels) of the bounce.", order=3.5, min=2, max=64, step=1,
                    get=function() return CursorGlow.db.profile.bounceAmplitude end,
                    set=function(_, v) CursorGlow.db.profile.bounceAmplitude = v end,
                    disabled=function() return not CursorGlow.db.profile.bounceEnabled end,
                },
                spacerAppearance1 = { type='description', name=" ", order=4 },
                minSize = {
                    type='range', name=L["Minimum Size"], desc=L["Set the minimum size of the texture"], order=5, min=16, max=64, step=1,
                    get=function() return CursorGlow.db.profile.minSize end,
                    set=function(_, v) CursorGlow.db.profile.minSize = v end,
                },
                maxSize = {
                    type='range', name=L["Maximum Size"], desc=L["Set the maximum size of the texture"], order=6, min=20, max=256, step=1,
                    get=function() return CursorGlow.db.profile.maxSize end,
                    set=function(_, v) CursorGlow.db.profile.maxSize = v end,
                },
            },
        },

        tailHeader = { type='header', name=L["Tail Effect Settings"], order=30 },
        tailSettings = {
            type='group', name=L["Tail Effect"], order=31, inline=true,
            args = {
                enableTail = {
                    type='toggle', name=L["Enable Tail Effect"], desc=L["Toggle the tail effect behind the cursor"], order=1,
                    get=function() return CursorGlow.db.profile.enableTail end,
                    set=function(_, val)
                        CursorGlow.db.profile.enableTail = val
                        if not val then
                            for _, group in pairs(tailTextures or {}) do
                                for _, t in ipairs(group or {}) do if t then t:Hide() end end
                            end
                            wipe(tailPositions)
                        end
                    end,
                },
                tailLength = {
                    type='range', name=L["Tail Length"], desc=L["Adjust the length of the cursor tail"], order=2, min=10, max=80, step=1,
                    get=function() return CursorGlow.db.profile.tailLength end,
                    set=function(_, v) CursorGlow.db.profile.tailLength = v; CursorGlow.tailLength = v; InitializeTailTextures() end,
                    disabled=function() return not CursorGlow.db.profile.enableTail end,
                },
                numTails = {
                    type='range', name=L["Number of Tails"], desc=L["Select the number of tails"], order=3, min=1, max=5, step=1,
                    get=function() return CursorGlow.db.profile.numTails or 1 end,
                    set=function(_, v) CursorGlow.db.profile.numTails = v; InitializeTailTextures() end,
                    disabled=function() return not CursorGlow.db.profile.enableTail end,
                },
                tailSpacing = {
                    type='range', name=L["Tail Spacing"], desc=L["Adjust the spacing between multiple tails"], order=4, min=0, max=50, step=1,
                    get=function() return CursorGlow.db.profile.tailSpacing or 10 end,
                    set=function(_, v) CursorGlow.db.profile.tailSpacing = v end,
                    disabled=function() return not CursorGlow.db.profile.enableTail end,
                },
                tailEffectStyle = {
                    type='select', name="Tail Effect Style", desc="Choose the animation style for the cursor tail.", order=5,
                    values = { classic="Classic Trail", sparkle="Sparkle", wobble="Wobble", burst="Burst", rainbow="Rainbow", comet="Comet", pulse="Pulse", twist="Twist", wave="Wave", bounce="Bounce" },
                    get=function() return CursorGlow.db.profile.tailEffectStyle or "classic" end,
                    set=function(_, v) CursorGlow.db.profile.tailEffectStyle = v end,
                    disabled=function() return not CursorGlow.db.profile.enableTail end,
                },
                tailParticleSpeed = {
                    type='range', name="Particle Fade Speed", desc="How quickly particles fade out (in seconds)", order=6, min=0.2, max=2, step=0.1,
                    get=function() return CursorGlow.db.profile.tailParticleSpeed or 0.5 end,
                    set=function(_, v) CursorGlow.db.profile.tailParticleSpeed = v end,
                    disabled=function() return not CursorGlow.db.profile.enableTail end,
                },
                tailParticleScatter = {
                    type='range', name="Particle Scatter", desc="How much particles are randomly offset (in pixels)", order=7, min=0, max=16, step=1,
                    get=function() return CursorGlow.db.profile.tailParticleScatter or 6 end,
                    set=function(_, v) CursorGlow.db.profile.tailParticleScatter = v end,
                    disabled=function() return not CursorGlow.db.profile.enableTail end,
                },
                tailParticleWobble = {
                    type='range', name="Particle Wobble", desc="Wobble strength for the particle tail (in pixels)", order=8, min=0, max=20, step=1,
                    get=function() return CursorGlow.db.profile.tailParticleWobble or 5 end,
                    set=function(_, v) CursorGlow.db.profile.tailParticleWobble = v end,
                    disabled=function() return not CursorGlow.db.profile.enableTail end,
                },
            },
        },

        pulseHeader = { type='header', name=L["Pulse Effect Settings"], order=40 },
        pulseSettings = {
            type='group', name=L["Pulse Effect"], order=41, inline=true,
            args = {
                pulseEnabled = {
                    type='toggle', name=L["Enable Pulse Effect"], desc=L["Toggle the pulsing effect when cursor is stationary"], order=1,
                    get=function() return CursorGlow.db.profile.pulseEnabled end,
                    set=function(_, v) CursorGlow.db.profile.pulseEnabled = v end,
                },
                pulseMinSize = {
                    type='range', name=L["Pulse Minimum Size"], desc=L["Set the minimum size of the pulse effect"], order=2, min=10, max=150, step=1,
                    get=function() return CursorGlow.db.profile.pulseMinSize end,
                    set=function(_, v) CursorGlow.db.profile.pulseMinSize = v end,
                    disabled=function() return not CursorGlow.db.profile.pulseEnabled end,
                },
                pulseMaxSize = {
                    type='range', name=L["Pulse Maximum Size"], desc=L["Set the maximum size of the pulse effect"], order=3, min=20, max=200, step=1,
                    get=function() return CursorGlow.db.profile.pulseMaxSize end,
                    set=function(_, v) CursorGlow.db.profile.pulseMaxSize = v end,
                    disabled=function() return not CursorGlow.db.profile.pulseEnabled end,
                },
                pulseSpeed = {
                    type='range', name=L["Pulse Speed"], desc=L["Adjust the speed of the pulsing effect"], order=4, min=0.1, max=5, step=0.1,
                    get=function() return CursorGlow.db.profile.pulseSpeed end,
                    set=function(_, v) CursorGlow.db.profile.pulseSpeed = v end,
                    disabled=function() return not CursorGlow.db.profile.pulseEnabled end,
                },
            },
        },
    },
}

-- Init
function CursorGlow:OnInitialize()
    self.db       = AceDB:New("CursorGlowDB", profileDefaults)
    self.dbChar   = AceDB:New("CursorGlowCharDB", charDefaults)
    self.dbGlobal = AceDB:New("CursorGlowGlobalDB", globalDefaults)

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
        DEFAULT_CHAT_FRAME:AddMessage("CursorGlow: Error initializing minimap button or LibDBIcon.")
    end
    if self.db.profile.minimap and self.db.profile.minimap.hide then icon:Hide("CursorGlow") else icon:Show("CursorGlow") end

    AceConfig:RegisterOptionsTable("CursorGlow", options)
    AceConfigDialog:AddToBlizOptions("CursorGlow", "CursorGlow")
    local profilesOptions = AceDBOptions:GetOptionsTable(self.db)
    AceConfig:RegisterOptionsTable("CursorGlow Profiles", profilesOptions)
    AceConfigDialog:AddToBlizOptions("CursorGlow Profiles", "Profiles", "CursorGlow")
end

-- Events
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

function CursorGlow:DisableTailEffect()
    if CursorGlow.db.profile.enableTail then
        for _, group in pairs(tailTextures or {}) do
            for _, t in ipairs(group or {}) do if t then t:Hide() end end
        end
        wipe(tailPositions)
    end
end

frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        UpdateAddonVisibility()
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
        UpdateTexture(CursorGlow.db.profile.texture)
        UpdateTextureColor()
        UpdateAddonVisibility()
        CursorGlow.speed = 0
    end
end)

-- Global mouse for explosion
local eventHandlerFrame = CreateFrame("Frame", nil, UIParent)
eventHandlerFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
eventHandlerFrame:SetScript("OnEvent", function(_, event, button)
    if event == "GLOBAL_MOUSE_DOWN" and button == "LeftButton" and CursorGlow.db.profile.enableExplosion then
        TriggerExplosionOnClick()
    end
end)

-- HSV helper (for rainbow tail)
local function HSVtoRGB(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if     i == 0 then return v, t, p
    elseif i == 1 then return q, v, p
    elseif i == 2 then return p, v, t
    elseif i == 3 then return p, q, v
    elseif i == 4 then return t, p, v
    else               return v, p, q end
end

-- Runtime state
local speed = 0
local stationaryTime = 0
local pulseElapsedTime = 0
local prevX, prevY = nil, nil

-- OnUpdate
frame:SetScript("OnUpdate", function(_, elapsed)
    local profile = CursorGlow.db.profile
    if not profile then return end

    local scale = UIParent:GetEffectiveScale()
    local cursorX, cursorY = GetCursorPosition()
    if cursorX == 0 and cursorY == 0 then
        return
    end

    prevX = prevX or cursorX
    prevY = prevY or cursorY

    local dX, dY   = cursorX - prevX, cursorY - prevY
    local distance = (dX == 0 and dY == 0) and 0 or math.sqrt(dX*dX + dY*dY)

    if elapsed <= 0 then elapsed = 0.0001 end
    local decayFactor = 2048 ^ -elapsed
    speed = math.min(decayFactor * speed + (1 - decayFactor) * (distance / elapsed), 1024)

    local now = GetTime()
    local opacity = profile.opacity or 1
    local r,g,b = GetActiveColor()

    -- Base size
    local size = profile.minSize
    if distance > 0 then
        size = math.max(math.min(speed / 6, profile.maxSize), profile.minSize)
    end

    -- Bounce offset (pixels)
    local bounceOffsetY = 0
    if profile.bounceEnabled then
        local cycles = profile.bounceSpeed or 2
        local amp    = profile.bounceAmplitude or 12
        bounceOffsetY = math.sin(now * cycles * math.pi * 2) * amp
    end

    -- Always On Cursor mode (now with tail + idle handling)
    if profile.operationMode == "enabledAlwaysOnCursor" then
        if distance > 0 then
            stationaryTime = 0
            pulseElapsedTime = 0
        else
            stationaryTime = stationaryTime + elapsed
            if profile.pulseEnabled and stationaryTime >= 0.5 then
                local pSpeed = profile.pulseSpeed or 1
                local prog   = (math.sin(pulseElapsedTime * pSpeed * math.pi * 2) + 1) / 2
                size = profile.pulseMinSize + (profile.pulseMaxSize - profile.pulseMinSize) * prog
                pulseElapsedTime = pulseElapsedTime + elapsed
            end
        end

        -- Anchor/show main texture
        texture:ClearAllPoints()
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, (cursorY + bounceOffsetY) / scale)
        texture:SetSize(size, size)
        texture:SetAlpha(opacity)
        texture:Show()

        -- Rotation
        if profile.rotationEnabled then
            CursorGlow.rotationAngle = (CursorGlow.rotationAngle or 0) + ((profile.rotationSpeed or 30) * math.pi/180) * elapsed
            if CursorGlow.rotationAngle > math.pi*2 then CursorGlow.rotationAngle = CursorGlow.rotationAngle - math.pi*2 end
            texture:SetRotation(CursorGlow.rotationAngle)
        elseif CursorGlow.rotationAngle ~= 0 then
            CursorGlow.rotationAngle = 0
            texture:SetRotation(0)
        end

        if profile.enableTail then
            CursorGlow.tailLength = tonumber(CursorGlow.tailLength) or 60
            local numTails       = tonumber(profile.numTails) or 1
            local tailSpacing    = tonumber(profile.tailSpacing) or 10
            local effectStyle    = profile.tailEffectStyle or "classic"
            local fadeSpeed      = profile.tailParticleSpeed or 0.5
            local scatter        = profile.tailParticleScatter or 6
            local wobbleStrength = profile.tailParticleWobble or 5

            if distance > 0 then
                for tailIndex = 1, numTails do
                    local offset    = (tailIndex - (numTails + 1)/2) * tailSpacing * scale
                    local cursorPos = { x = (cursorX + offset) / scale, y = cursorY / scale }
                    tailPositions[tailIndex] = tailPositions[tailIndex] or {}
                    tailTextures[tailIndex]  = tailTextures[tailIndex] or {}

                    if effectStyle == "classic" then
                        table.insert(tailPositions[tailIndex], 1, cursorPos)
                    elseif effectStyle == "sparkle" then
                        table.insert(tailPositions[tailIndex], 1, {
                            x = cursorPos.x + math.random(-scatter, scatter),
                            y = cursorPos.y + math.random(-scatter, scatter),
                            t = now
                        })
                    elseif effectStyle == "wobble" then
                        table.insert(tailPositions[tailIndex], 1, {
                            x = cursorPos.x + math.random(-scatter, scatter),
                            y = cursorPos.y + math.random(-scatter, scatter),
                            t = now,
                            phase = math.random() * 2 * math.pi
                        })
                    elseif effectStyle == "burst" then
                        local burstScatter = scatter * 2
                        table.insert(tailPositions[tailIndex], 1, {
                            x = cursorPos.x + math.random(-burstScatter, burstScatter),
                            y = cursorPos.y + math.random(-burstScatter, burstScatter),
                            t = now
                        })
                    else
                        table.insert(tailPositions[tailIndex], 1, cursorPos) -- rainbow, comet, pulse, twist, wave, bounce
                    end

                    if #tailPositions[tailIndex] > CursorGlow.tailLength then
                        table.remove(tailPositions[tailIndex])
                    end

                    for i, tailTexture in ipairs(tailTextures[tailIndex]) do
                        local pos = tailPositions[tailIndex][i]
                        if pos and tailTexture then
                            local alphaBase = (CursorGlow.tailLength - i + 1) / CursorGlow.tailLength

                            if effectStyle == "classic" then
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                                tailTexture:SetAlpha(alphaBase * opacity)
                                tailTexture:SetSize(size, size)
                                tailTexture:SetVertexColor(r, g, b, alphaBase * opacity)
                                tailTexture:Show()

                            elseif effectStyle == "sparkle" then
                                local age  = now - (pos.t or now)
                                local fade = math.max(1 - (age / fadeSpeed), 0)
                                local s2   = size * fade
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                                tailTexture:SetAlpha(fade * opacity)
                                tailTexture:SetSize(s2, s2)
                                tailTexture:SetVertexColor(r, g, b, fade * opacity)
                                if fade > 0 then tailTexture:Show() else tailTexture:Hide() end

                            elseif effectStyle == "wobble" then
                                local age  = now - (pos.t or now)
                                local fade = math.max(1 - (age / fadeSpeed), 0)
                                local wobble = math.sin(now*8 + (pos.phase or 0)) * wobbleStrength * fade
                                local s2 = size * fade
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x + wobble, pos.y + wobble)
                                tailTexture:SetAlpha(fade * opacity)
                                tailTexture:SetSize(s2, s2)
                                tailTexture:SetVertexColor(r, g, b, fade * opacity)
                                if fade > 0 then tailTexture:Show() else tailTexture:Hide() end

                            elseif effectStyle == "burst" then
                                local age  = now - (pos.t or now)
                                local fade = math.max(1 - (age / (fadeSpeed*0.6)), 0)
                                local s2   = size * fade
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                                tailTexture:SetAlpha(fade * opacity)
                                tailTexture:SetSize(s2, s2)
                                tailTexture:SetVertexColor(r, g, b, fade * opacity)
                                if fade > 0 then tailTexture:Show() else tailTexture:Hide() end

                            elseif effectStyle == "rainbow" then
                                local h = ((i / CursorGlow.tailLength) + (now*0.5)) % 1
                                local rr,gg,bb = HSVtoRGB(h, 1, 1)
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                                tailTexture:SetAlpha(alphaBase * opacity)
                                tailTexture:SetVertexColor(rr, gg, bb, alphaBase * opacity)
                                tailTexture:SetSize(size, size)
                                tailTexture:Show()

                            elseif effectStyle == "comet" then
                                local fade = alphaBase
                                local cometAlpha = fade^3
                                local cometSize  = size * cometAlpha
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                                tailTexture:SetAlpha(cometAlpha * opacity)
                                tailTexture:SetSize(cometSize, cometSize)
                                tailTexture:SetVertexColor(r, g, b, cometAlpha * opacity)
                                tailTexture:Show()

                            elseif effectStyle == "pulse" then
                                local p = 0.8 + 0.2 * math.sin(now*7 + i)
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                                tailTexture:SetAlpha(alphaBase * opacity)
                                tailTexture:SetSize(size * p, size * p)
                                tailTexture:SetVertexColor(r, g, b, alphaBase * opacity)
                                tailTexture:Show()

                            elseif effectStyle == "twist" then
                                local angle = (i / CursorGlow.tailLength) * 2 * math.pi + now*2
                                local radius = 10 + 8 * ((CursorGlow.tailLength - i + 1)/CursorGlow.tailLength)
                                local alpha  = alphaBase * opacity
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
                                    pos.x + radius*math.cos(angle), pos.y + radius*math.sin(angle))
                                tailTexture:SetAlpha(alpha)
                                tailTexture:SetSize(size, size)
                                tailTexture:SetVertexColor(r, g, b, alpha)
                                tailTexture:Show()

                            elseif effectStyle == "wave" then
                                local wave  = math.sin(now*5 + i) * 12 * ((CursorGlow.tailLength - i + 1)/CursorGlow.tailLength)
                                local alpha = alphaBase * opacity
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y + wave)
                                tailTexture:SetAlpha(alpha)
                                tailTexture:SetSize(size, size)
                                tailTexture:SetVertexColor(r, g, b, alpha)
                                tailTexture:Show()

                            elseif effectStyle == "bounce" then
                                local bounce = math.abs(math.sin(now*6 + i)) * 28 * ((CursorGlow.tailLength - i + 1)/CursorGlow.tailLength)
                                local alpha  = alphaBase * opacity
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y + bounce)
                                tailTexture:SetAlpha(alpha)
                                tailTexture:SetSize(size, size)
                                tailTexture:SetVertexColor(r, g, b, alpha)
                                tailTexture:Show()

                            else
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                                tailTexture:SetAlpha(alphaBase * opacity)
                                tailTexture:SetSize(size, size)
                                tailTexture:SetVertexColor(r, g, b, alphaBase * opacity)
                                tailTexture:Show()
                            end
                        elseif tailTexture then
                            tailTexture:Hide()
                        end
                    end
                end
            else
                -- Stationary: fade existing tail
                local numTails = profile.numTails or 1
                if stationaryTime >= 1 then
                    wipe(tailPositions)
                else
                    for tailIndex = 1, numTails do
                        for i, tailTexture in ipairs(tailTextures[tailIndex] or {}) do
                            local pos = tailPositions[tailIndex] and tailPositions[tailIndex][i]
                            if pos and tailTexture then
                                local alpha = ((CursorGlow.tailLength - i + 1) / CursorGlow.tailLength) * math.max(1 - stationaryTime, 0)
                                tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                                tailTexture:SetAlpha(alpha * opacity)
                                tailTexture:SetSize(size * alpha, size * alpha)
                                tailTexture:SetVertexColor(r, g, b, alpha * opacity)
                                if alpha > 0 then tailTexture:Show() else tailTexture:Hide() end
                            elseif tailTexture then
                                tailTexture:Hide()
                            end
                        end
                    end
                end
            end
        else
            -- Tail disabled: hide any existing tail textures
            for _, group in pairs(tailTextures) do
                for _, t in ipairs(group or {}) do if t then t:Hide() end end
            end
            wipe(tailPositions)
        end

        -- Idle ZZZ in Always-On-Cursor
        if profile.idleIndicatorEnabled and stationaryTime > (profile.idleThreshold or 60) then
            zzzFont:Show()
            local wobble = math.sin(now * 2) * 5
            local flashAlpha = 0.5 + 0.5 * math.sin(now * 4)
            zzzFont:ClearAllPoints()
            zzzFont:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, (cursorY / scale) + 30 + wobble)
            zzzFont:SetAlpha(flashAlpha)
        else
            zzzFont:Hide()
        end

        prevX, prevY = cursorX, cursorY
        return
    end

    -- Other modes (Enabled Always / Enabled in Combat)
    if distance > 0 then
        stationaryTime = 0
        pulseElapsedTime = 0

        -- Anchor exactly at cursor
        texture:ClearAllPoints()
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, (cursorY + bounceOffsetY) / scale)
        texture:SetSize(size, size)
        texture:SetAlpha(opacity)
        texture:Show()
        zzzFont:Hide()

        if profile.enableTail then
            local effectStyle    = profile.tailEffectStyle or "classic"
            local fadeSpeed      = profile.tailParticleSpeed or 0.5
            local scatter        = profile.tailParticleScatter or 6
            local wobbleStrength = profile.tailParticleWobble or 5
            local numTails       = tonumber(profile.numTails) or 1
            local tailSpacing    = tonumber(profile.tailSpacing) or 10
            CursorGlow.tailLength = tonumber(CursorGlow.tailLength) or 60

            for tailIndex = 1, numTails do
                local offset    = (tailIndex - (numTails + 1)/2) * tailSpacing * scale
                local cursorPos = { x = (cursorX + offset) / scale, y = cursorY / scale }
                tailPositions[tailIndex] = tailPositions[tailIndex] or {}
                tailTextures[tailIndex]  = tailTextures[tailIndex] or {}

                if effectStyle == "classic" then
                    table.insert(tailPositions[tailIndex], 1, cursorPos)
                elseif effectStyle == "sparkle" then
                    table.insert(tailPositions[tailIndex], 1, { x=cursorPos.x + math.random(-scatter,scatter), y=cursorPos.y + math.random(-scatter,scatter), t=now })
                elseif effectStyle == "wobble" then
                    table.insert(tailPositions[tailIndex], 1, { x=cursorPos.x + math.random(-scatter,scatter), y=cursorPos.y + math.random(-scatter,scatter), t=now, phase=math.random()*2*math.pi })
                elseif effectStyle == "burst" then
                    local burstScatter = scatter * 2
                    table.insert(tailPositions[tailIndex], 1, { x=cursorPos.x + math.random(-burstScatter,burstScatter), y=cursorPos.y + math.random(-burstScatter,burstScatter), t=now })
                else
                    table.insert(tailPositions[tailIndex], 1, cursorPos) -- rainbow, comet, pulse, twist, wave, bounce
                end

                if #tailPositions[tailIndex] > CursorGlow.tailLength then table.remove(tailPositions[tailIndex]) end

                for i, tailTexture in ipairs(tailTextures[tailIndex]) do
                    local pos = tailPositions[tailIndex][i]
                    if pos and tailTexture then
                        local alphaBase = (CursorGlow.tailLength - i + 1) / CursorGlow.tailLength

                        if effectStyle == "classic" then
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                            tailTexture:SetAlpha(alphaBase * opacity)
                            tailTexture:SetSize(size, size)
                            tailTexture:SetVertexColor(r, g, b, alphaBase * opacity)
                            tailTexture:Show()

                        elseif effectStyle == "sparkle" then
                            local age  = now - (pos.t or now)
                            local fade = math.max(1 - (age / fadeSpeed), 0)
                            local s2   = size * fade
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                            tailTexture:SetAlpha(fade * opacity)
                            tailTexture:SetSize(s2, s2)
                            tailTexture:SetVertexColor(r, g, b, fade * opacity)
                            if fade > 0 then tailTexture:Show() else tailTexture:Hide() end

                        elseif effectStyle == "wobble" then
                            local age  = now - (pos.t or now)
                            local fade = math.max(1 - (age / fadeSpeed), 0)
                            local wobble = math.sin(now*8 + (pos.phase or 0)) * wobbleStrength * fade
                            local s2 = size * fade
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x + wobble, pos.y + wobble)
                            tailTexture:SetAlpha(fade * opacity)
                            tailTexture:SetSize(s2, s2)
                            tailTexture:SetVertexColor(r, g, b, fade * opacity)
                            if fade > 0 then tailTexture:Show() else tailTexture:Hide() end

                        elseif effectStyle == "burst" then
                            local age  = now - (pos.t or now)
                            local fade = math.max(1 - (age / (fadeSpeed*0.6)), 0)
                            local s2   = size * fade
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                            tailTexture:SetAlpha(fade * opacity)
                            tailTexture:SetSize(s2, s2)
                            tailTexture:SetVertexColor(r, g, b, fade * opacity)
                            if fade > 0 then tailTexture:Show() else tailTexture:Hide() end

                        elseif effectStyle == "rainbow" then
                            local h = ((i / CursorGlow.tailLength) + (now*0.5)) % 1
                            local rr,gg,bb = HSVtoRGB(h,1,1)
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                            tailTexture:SetAlpha(alphaBase * opacity)
                            tailTexture:SetVertexColor(rr,gg,bb, alphaBase * opacity)
                            tailTexture:SetSize(size,size)
                            tailTexture:Show()

                        elseif effectStyle == "comet" then
                            local fade = alphaBase
                            local cometAlpha = fade^3
                            local cometSize  = size * cometAlpha
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                            tailTexture:SetAlpha(cometAlpha * opacity)
                            tailTexture:SetSize(cometSize, cometSize)
                            tailTexture:SetVertexColor(r, g, b, cometAlpha * opacity)
                            tailTexture:Show()

                        elseif effectStyle == "pulse" then
                            local p = 0.8 + 0.2 * math.sin(now*7 + i)
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                            tailTexture:SetAlpha(alphaBase * opacity)
                            tailTexture:SetSize(size * p, size * p)
                            tailTexture:SetVertexColor(r, g, b, alphaBase * opacity)
                            tailTexture:Show()

                        elseif effectStyle == "twist" then
                            local angle = (i / CursorGlow.tailLength)*2*math.pi + now*2
                            local radius = 10 + 8 * ((CursorGlow.tailLength - i + 1)/CursorGlow.tailLength)
                            local alpha  = alphaBase * opacity
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
                                pos.x + radius*math.cos(angle),
                                pos.y + radius*math.sin(angle)
                            )
                            tailTexture:SetAlpha(alpha)
                            tailTexture:SetSize(size,size)
                            tailTexture:SetVertexColor(r, g, b, alpha)
                            tailTexture:Show()

                        elseif effectStyle == "wave" then
                            local wave = math.sin(now*5 + i) * 12 * ((CursorGlow.tailLength - i + 1)/CursorGlow.tailLength)
                            local alpha = alphaBase * opacity
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y + wave)
                            tailTexture:SetAlpha(alpha)
                            tailTexture:SetSize(size,size)
                            tailTexture:SetVertexColor(r, g, b, alpha)
                            tailTexture:Show()

                        elseif effectStyle == "bounce" then
                            local bounce = math.abs(math.sin(now*6 + i)) * 28 * ((CursorGlow.tailLength - i + 1)/CursorGlow.tailLength)
                            local alpha = alphaBase * opacity
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y + bounce)
                            tailTexture:SetAlpha(alpha)
                            tailTexture:SetSize(size,size)
                            tailTexture:SetVertexColor(r, g, b, alpha)
                            tailTexture:Show()

                        else
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                            tailTexture:SetAlpha(alphaBase * opacity)
                            tailTexture:SetSize(size,size)
                            tailTexture:SetVertexColor(r, g, b, alphaBase * opacity)
                            tailTexture:Show()
                        end
                    elseif tailTexture then
                        tailTexture:Hide()
                    end
                end
            end
        else
            for _, group in pairs(tailTextures) do
                for _, t in ipairs(group or {}) do if t then t:Hide() end end
            end
            wipe(tailPositions)
        end

    else
        -- Stationary
        stationaryTime = stationaryTime + elapsed
        if profile.pulseEnabled then
            if stationaryTime >= 0.5 then
                pulseElapsedTime = pulseElapsedTime + elapsed
                local pSpeed = profile.pulseSpeed or 1
                local prog   = (math.sin(pulseElapsedTime * pSpeed * math.pi * 2) + 1) / 2
                local pulseSize = profile.pulseMinSize + (profile.pulseMaxSize - profile.pulseMinSize) * prog
                texture:ClearAllPoints()
                texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, (cursorY + bounceOffsetY) / scale)
                texture:SetSize(pulseSize, pulseSize)
                texture:SetAlpha(opacity)
                texture:Show()
            else
                texture:Hide()
            end
        else
            -- Legacy behavior: hide while stationary if no pulse
            texture:Hide()
        end

        if profile.idleIndicatorEnabled and stationaryTime > (profile.idleThreshold or 60) then
            zzzFont:Show()
            local wobble = math.sin(now * 2) * 5
            local flashAlpha = 0.5 + 0.5 * math.sin(now * 4)
            zzzFont:ClearAllPoints()
            zzzFont:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cursorX / scale, (cursorY / scale) + 30 + wobble)
            zzzFont:SetAlpha(flashAlpha)
        else
            zzzFont:Hide()
        end

        if profile.enableTail then
            local numTails = profile.numTails or 1
            if stationaryTime >= 1 then
                wipe(tailPositions)
            else
                for tailIndex = 1, numTails do
                    for i, tailTexture in ipairs(tailTextures[tailIndex] or {}) do
                        local pos = tailPositions[tailIndex] and tailPositions[tailIndex][i]
                        if pos and tailTexture then
                            local alpha = ((CursorGlow.tailLength - i + 1)/CursorGlow.tailLength) * math.max(1 - stationaryTime, 0)
                            tailTexture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
                            tailTexture:SetAlpha(alpha * opacity)
                            tailTexture:SetSize(size * alpha, size * alpha)
                            tailTexture:SetVertexColor(r, g, b, alpha * opacity)
                            if alpha > 0 then tailTexture:Show() else tailTexture:Hide() end
                        elseif tailTexture then
                            tailTexture:Hide()
                        end
                    end
                end
            end
        else
            for _, group in pairs(tailTextures) do
                for _, t in ipairs(group or {}) do if t then t:Hide() end end
            end
            wipe(tailPositions)
        end
    end

    -- Unified rotation update (normal path)
    if profile.rotationEnabled and texture:IsShown() then
        CursorGlow.rotationAngle = (CursorGlow.rotationAngle or 0) + ((profile.rotationSpeed or 30) * math.pi/180) * elapsed
        if CursorGlow.rotationAngle > math.pi*2 then CursorGlow.rotationAngle = CursorGlow.rotationAngle - math.pi*2 end
        texture:SetRotation(CursorGlow.rotationAngle)
    elseif CursorGlow.rotationAngle ~= 0 then
        CursorGlow.rotationAngle = 0
        texture:SetRotation(0)
    end

    prevX, prevY = cursorX, cursorY
end)