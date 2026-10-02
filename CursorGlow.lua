-- CursorGlow
-- Made by Sharpedge_Gaming
-- v8.0 Midnight/Forever

local LibStub = LibStub or _G.LibStub
local AceAddon        = LibStub:GetLibrary("AceAddon-3.0")
local AceDB           = LibStub:GetLibrary("AceDB-3.0")
local AceConfig       = LibStub:GetLibrary("AceConfig-3.0")
local AceConfigDialog = LibStub:GetLibrary("AceConfigDialog-3.0")
local AceDBOptions    = LibStub:GetLibrary("AceDBOptions-3.0")
local LDB             = LibStub:GetLibrary("LibDataBroker-1.1")
local icon            = LibStub:GetLibrary("LibDBIcon-1.0")

-- Fall back to raw keys if no locale is registered so L can never be nil
local L = LibStub("AceLocale-3.0"):GetLocale("CursorGlow", true)
    or setmetatable({}, { __index = function(_, key) return key end })

local ADDON_NAME = "CursorGlow"
local CursorGlow = AceAddon:NewAddon(ADDON_NAME, "AceEvent-3.0", "AceConsole-3.0")

-- Upvalues
local sin, cos, abs, sqrt = math.sin, math.cos, math.abs, math.sqrt
local min, max, floor = math.min, math.max, math.floor
local random = math.random
local TWO_PI = math.pi * 2
local DEG_TO_RAD = math.pi / 180
local GetCursorPosition, GetTime, GetFramerate = GetCursorPosition, GetTime, GetFramerate
local UIParent = UIParent

-- Constants
local NUM_PARTICLES      = 100
local EXPLOSION_SPEED    = 30
local MAX_TAIL_LENGTH    = 80
local MAX_TAILS          = 5
local DEFAULT_TEXTURE    = "ring14"
local FPS_CHECK_INTERVAL = 0.5   -- seconds between framerate checks
local FPS_LOW_CHECKS     = 3     -- consecutive low checks before acting
local FPS_RECOVER_CHECKS = 6     -- consecutive good checks before restoring
local FPS_RECOVER_MARGIN = 5     -- fps above threshold required to count as recovered
local MAX_RIPPLES        = 16
local SHAKE_WINDOW       = 1.0   -- seconds of history used for shake detection

-- Shake to Find tuning
-- reversals: direction changes needed inside the window
-- travel: minimum length (UI units) of each swing for it to count
local SHAKE_PROFILES = {
    low    = { reversals = 6, travel = 70 },
    medium = { reversals = 4, travel = 45 },
    high   = { reversals = 3, travel = 25 },
}

CursorGlow.rotationAngle = 0
CursorGlow.tailLength = 60
CursorGlow._settingsCategoryID = nil

local function Clamp(v, lo, hi)
    v = tonumber(v) or lo
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

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

local textureValues = {}
for _, key in ipairs(orderedKeys) do textureValues[key] = displayNames[key] end

-- Legacy named colors, used only to migrate old string color settings
local colorOptions = {
    red={1,0,0}, green={0,1,0}, blue={0,0,1}, purple={1,0,1}, white={1,1,1},
    pink={1,0.08,0.58}, orange={1,0.65,0}, cyan={0,1,1}, yellow={1,1,0}, gray={0.5,0.5,0.5},
    gold={1,0.84,0}, teal={0,0.5,0.5}, magenta={1,0,1}, lime={0.75,1,0}, olive={0.5,0.5,0}, navy={0,0,0.5},
    warrior={0.78,0.61,0.43}, paladin={0.96,0.55,0.73}, hunter={0.67,0.83,0.45}, rogue={1.00,0.96,0.41},
    priest={1,1,1}, deathknight={0.77,0.12,0.23}, shaman={0,0.44,0.87}, mage={0.41,0.80,0.94},
    warlock={0.58,0.51,0.79}, monk={0,1,0.59}, druid={1,0.49,0.04}, demonhunter={0.64,0.19,0.79}, evoker={0.20,0.58,0.50},
}

local tailStyleValues = {
    classic  = "Classic Trail",
    sparkle  = "Sparkle",
    wobble   = "Wobble",
    burst    = "Burst",
    rainbow  = "Rainbow",
    comet    = "Comet",
    pulse    = "Pulse",
    twist    = "Twist",
    wave     = "Wave",
    bounce   = "Bounce",
    fire     = "Fire",
    electric = "Electric",
    bubble   = "Bubble",
    ribbon   = "Ribbon",
}

-- Color math

local function HSVtoRGB(h, s, v)
    local i = floor(h * 6)
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

local function RGBtoHSV(r, g, b)
    local mx, mn = max(r, g, b), min(r, g, b)
    local d = mx - mn
    local h = 0
    if d > 0 then
        if mx == r then
            h = ((g - b) / d) % 6
        elseif mx == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    local s = (mx > 0) and (d / mx) or 0
    return h, s, mx
end

-- Colorblind support
-- Protan, deutan and tritan modes remap any saturated color to the nearest entry
-- in a bright palette that stays distinguishable for that type of color vision.
-- Additive blending means dark colors vanish, so every palette entry is bright.
local PALETTE_RED_GREEN = {
    { 0.00, 0.45, 1.00 },  -- strong blue
    { 1.00, 0.85, 0.00 },  -- yellow
    { 0.00, 0.90, 1.00 },  -- sky cyan
}
local PALETTE_BLUE_YELLOW = {
    { 1.00, 0.20, 0.20 },  -- red
    { 0.00, 0.85, 0.85 },  -- teal cyan
    { 1.00, 0.45, 0.75 },  -- pink
}
local CB_PALETTES = {
    protanopia   = PALETTE_RED_GREEN,
    deuteranopia = PALETTE_RED_GREEN,
    tritanopia   = PALETTE_BLUE_YELLOW,
}
for _, palette in pairs(CB_PALETTES) do
    for _, c in ipairs(palette) do
        c.h = RGBtoHSV(c[1], c[2], c[3])
    end
end

local cbEnabled, cbMode, cbThreshold = false, "none", 0.5
local cbDark, cbLight = { 1, 1, 1 }, { 1, 1, 0 }

local function MapToPalette(palette, r, g, b)
    local h, s = RGBtoHSV(r, g, b)
    if s < 0.25 then
        return r, g, b  -- whites and greys are already safe
    end
    local best, bestDist = palette[1], 2
    for i = 1, #palette do
        local c = palette[i]
        local d = abs(h - c.h)
        if d > 0.5 then d = 1 - d end
        if d < bestDist then best, bestDist = c, d end
    end
    return best[1], best[2], best[3]
end

local function ResolveColor(r, g, b)
    if not cbEnabled or cbMode == "none" then
        return r, g, b
    end
    if cbMode == "achromatopsia" then
        local l = 0.299 * r + 0.587 * g + 0.114 * b
        return l, l, l
    end
    if cbMode == "highcontrast" then
        local lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        local c = (lum < cbThreshold) and cbDark or cbLight
        return c[1] or 1, c[2] or 1, c[3] or 1
    end
    local palette = CB_PALETTES[cbMode]
    if palette then
        return MapToPalette(palette, r, g, b)
    end
    return r, g, b
end

local function CacheColorblind()
    local p = CursorGlow.db and CursorGlow.db.profile
    if not p then
        cbEnabled = false
        return
    end
    cbEnabled   = p.colorblindEnabled and true or false
    cbMode      = p.colorblindMode or "none"
    cbThreshold = tonumber(p.colorblindHighContrastThreshold) or 0.5
    if type(p.colorblindHighContrastDark) == "table" then cbDark = p.colorblindHighContrastDark end
    if type(p.colorblindHighContrastLight) == "table" then cbLight = p.colorblindHighContrastLight end
end

local function GetDefaultClassColor()
    local _, class = UnitClass("player")
    local c = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    if c then
        return { c.r, c.g, c.b }
    end
    return { 1, 1, 1 }
end

local function UnpackColor(c, fr, fg, fb)
    if type(c) == "table" then
        return c[1] or fr, c[2] or fg, c[3] or fb
    elseif type(c) == "string" then
        local m = colorOptions[c]
        if m then return m[1], m[2], m[3] end
    end
    return fr, fg, fb
end

local function GetBaseColor()
    local p = CursorGlow.db and CursorGlow.db.profile
    return UnpackColor(p and p.color, 1, 1, 1)
end

local function CharacterProfileName()
    return UnitName("player") .. " - " .. GetRealmName()
end

-- Main frame and texture

local frame = CreateFrame("Frame", nil, UIParent)
frame:SetFrameStrata("TOOLTIP")
frame:Hide()

local texture = frame:CreateTexture(nil, "ARTWORK")
texture:SetTexture(textureOptions[DEFAULT_TEXTURE])
texture:SetBlendMode("ADD")
texture:SetSize(32, 32)
CursorGlow.texture = texture

local zzzFont = frame:CreateFontString(nil, "OVERLAY")
zzzFont:SetFont("Fonts\\FRIZQT__.TTF", 30, "OUTLINE")
zzzFont:SetText("ZZZ")
zzzFont:SetTextColor(1, 0, 0, 1)
zzzFont:Hide()

-- Runtime state

local speed = 0
local stillTime = 0
local pulseTime = 0
local prevX, prevY
local inCombat = false
local fpsLowCPU = false
local currentTexturePath = textureOptions[DEFAULT_TEXTURE]
local mainR, mainG, mainB = 1, 1, 1
local baseR, baseG, baseB = 1, 1, 1
local glowPassive = false
local tailStillTime = 0

-- Elastic follow
local glowX, glowY, glowVX, glowVY

-- Mouselook
local mouselookAlpha = 1
local wasMouselooking = false

-- Shake to Find
local shakeStart = -100
local shakeCooldownEnd = 0
local shakeLastSign = 0
local shakeTravel = 0
local shakeTimes = {}

local function IsLowCPU()
    local p = CursorGlow.db and CursorGlow.db.profile
    return (p and p.lowCPUMode) or fpsLowCPU
end

local function ResetMotionState()
    speed, stillTime, pulseTime, tailStillTime = 0, 0, 0, 0
    prevX, prevY = nil, nil
    glowX, glowY, glowVX, glowVY = nil, nil, 0, 0
    shakeLastSign, shakeTravel = 0, 0
    for i = #shakeTimes, 1, -1 do shakeTimes[i] = nil end
end

-- Tail system
-- Textures come from a pool that only ever grows, so rebuilding never leaks.
-- Positions live in a fixed ring buffer per tail, so nothing is allocated per frame.

local tailPool = {}
local tails = {}
local tailLen = 60
local numTailsActive = 0
local tailsDrawn = false

-- Per frame render context, shared by the style functions
local ctxNow, ctxR, ctxG, ctxB, ctxOp = 0, 1, 1, 1, 1
local ctxStyle, ctxFade, ctxScatter, ctxWobble, ctxSpacing, ctxTaper = "classic", 0.5, 6, 5, 10, false

local function AcquireTailTexture(index)
    local t = tailPool[index]
    if not t then
        t = frame:CreateTexture(nil, "BACKGROUND")
        t:SetBlendMode("ADD")
        t:SetTexture(currentTexturePath)
        t:Hide()
        tailPool[index] = t
    end
    return t
end

local function EffectiveTailLength()
    local p = CursorGlow.db.profile
    if IsLowCPU() then
        return floor(Clamp(p.lowCPUTailLength or 20, 1, MAX_TAIL_LENGTH))
    end
    return floor(Clamp(p.tailLength or 60, 1, MAX_TAIL_LENGTH))
end

local function HideTail(tail)
    local tex = tail.tex
    for i = 1, tail.drawn do
        local t = tex[i]
        if t then t:Hide() end
    end
    tail.drawn = 0
end

local function ResetTails()
    for ti = 1, numTailsActive do
        local tail = tails[ti]
        if tail then
            HideTail(tail)
            tail.head, tail.count = 0, 0
        end
    end
    tailsDrawn = false
end

local function RebuildTails()
    if not CursorGlow.db then return end
    local p = CursorGlow.db.profile

    for _, t in pairs(tailPool) do t:Hide() end

    tailLen = EffectiveTailLength()
    CursorGlow.tailLength = tailLen
    numTailsActive = floor(Clamp(p.numTails or 1, 1, MAX_TAILS))

    for ti = 1, MAX_TAILS do
        if ti <= numTailsActive then
            local tail = tails[ti]
            if not tail then
                tail = { buf = {}, tex = {} }
                tails[ti] = tail
            end
            tail.head, tail.count, tail.drawn = 0, 0, 0
            local base = (ti - 1) * MAX_TAIL_LENGTH
            for i = 1, tailLen do
                tail.buf[i] = tail.buf[i] or { x = 0, y = 0, t = 0, phase = 0 }
                tail.tex[i] = AcquireTailTexture(base + i)
            end
            for i = tailLen + 1, #tail.tex do
                tail.tex[i] = nil
            end
        else
            tails[ti] = nil
        end
    end
    tailsDrawn = false
end

local function Place(tex, x, y, w, h, r, g, b, a)
    if a <= 0 or w <= 0 or h <= 0 then
        if tex:IsShown() then tex:Hide() end
        return
    end
    tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    tex:SetSize(w, h)
    tex:SetVertexColor(r, g, b, 1)
    tex:SetAlpha(a)
    if not tex:IsShown() then tex:Show() end
end

local function AgeFade(e, duration)
    return max(1 - ((ctxNow - e.t) / duration), 0)
end

-- Style functions: (texture, entry, index, alphaBase, segmentSize)
local tailStyles = {}

tailStyles.classic = function(tex, e, i, ab, seg)
    Place(tex, e.x, e.y, seg, seg, ctxR, ctxG, ctxB, ab * ctxOp)
end

tailStyles.sparkle = function(tex, e, i, ab, seg)
    local f = AgeFade(e, ctxFade)
    Place(tex, e.x, e.y, seg * f, seg * f, ctxR, ctxG, ctxB, f * ctxOp)
end

tailStyles.wobble = function(tex, e, i, ab, seg)
    local f = AgeFade(e, ctxFade)
    local w = sin(ctxNow * 8 + e.phase) * ctxWobble * f
    Place(tex, e.x + w, e.y + w, seg * f, seg * f, ctxR, ctxG, ctxB, f * ctxOp)
end

tailStyles.burst = function(tex, e, i, ab, seg)
    local f = AgeFade(e, ctxFade * 0.6)
    Place(tex, e.x, e.y, seg * f, seg * f, ctxR, ctxG, ctxB, f * ctxOp)
end

tailStyles.rainbow = function(tex, e, i, ab, seg)
    local r, g, b = ResolveColor(HSVtoRGB(((i / tailLen) + ctxNow * 0.5) % 1, 1, 1))
    Place(tex, e.x, e.y, seg, seg, r, g, b, ab * ctxOp)
end

tailStyles.comet = function(tex, e, i, ab, seg)
    local c = ab * ab * ab
    Place(tex, e.x, e.y, seg * c, seg * c, ctxR, ctxG, ctxB, c * ctxOp)
end

tailStyles.pulse = function(tex, e, i, ab, seg)
    local s = seg * (0.8 + 0.2 * sin(ctxNow * 7 + i))
    Place(tex, e.x, e.y, s, s, ctxR, ctxG, ctxB, ab * ctxOp)
end

tailStyles.twist = function(tex, e, i, ab, seg)
    local angle = (i / tailLen) * TWO_PI + ctxNow * 2
    local radius = 10 + 8 * ab
    Place(tex, e.x + radius * cos(angle), e.y + radius * sin(angle), seg, seg, ctxR, ctxG, ctxB, ab * ctxOp)
end

tailStyles.wave = function(tex, e, i, ab, seg)
    local wave = sin(ctxNow * 5 + i) * 12 * ab
    Place(tex, e.x, e.y + wave, seg, seg, ctxR, ctxG, ctxB, ab * ctxOp)
end

tailStyles.bounce = function(tex, e, i, ab, seg)
    local bounce = abs(sin(ctxNow * 6 + i)) * 28 * ab
    Place(tex, e.x, e.y + bounce, seg, seg, ctxR, ctxG, ctxB, ab * ctxOp)
end

tailStyles.fire = function(tex, e, i, ab, seg)
    local r, g, b = ResolveColor(1, 0.5 + 0.5 * (1 - i / tailLen), 0)
    Place(tex, e.x, e.y, seg, seg, r, g, b, ab * ctxOp)
end

tailStyles.electric = function(tex, e, i, ab, seg)
    local jitter = random(-3, 3)
    local r, g, b
    if i % 2 == 0 then
        r, g, b = ResolveColor(0.2, 0.6, 1)
    else
        r, g, b = ResolveColor(1, 1, 1)
    end
    Place(tex, e.x + jitter, e.y + jitter, seg, seg, r, g, b, ab * ctxOp)
end

tailStyles.ribbon = function(tex, e, i, ab, seg)
    Place(tex, e.x, e.y, seg * 1.8, seg * 0.6, ctxR, ctxG, ctxB, ab * ctxOp * 0.25)
end

tailStyles.bubble = function(tex, e, i, ab, seg)
    if i % 5 == 0 then
        Place(tex, e.x, e.y, seg * 1.4, seg * 1.4, ctxR, ctxG, ctxB, ab * ctxOp * 0.4)
    else
        Place(tex, e.x, e.y, seg, seg, ctxR, ctxG, ctxB, ab * ctxOp)
    end
end

local function PushTails(x, y)
    local center = (numTailsActive + 1) / 2
    local jitter = 0
    if ctxStyle == "sparkle" or ctxStyle == "wobble" then
        jitter = ctxScatter
    elseif ctxStyle == "burst" then
        jitter = ctxScatter * 2
    end

    for ti = 1, numTailsActive do
        local tail = tails[ti]
        if tail then
            local head = tail.head % tailLen + 1
            tail.head = head
            local e = tail.buf[head]
            local px = x + (ti - center) * ctxSpacing
            if jitter > 0 then
                e.x = px + (random() * 2 - 1) * jitter
                e.y = y + (random() * 2 - 1) * jitter
            else
                e.x, e.y = px, y
            end
            e.t = ctxNow
            e.phase = random() * TWO_PI
            if tail.count < tailLen then
                tail.count = tail.count + 1
            end
        end
    end
end

local function DrawTails(size)
    local style = tailStyles[ctxStyle] or tailStyles.classic
    for ti = 1, numTailsActive do
        local tail = tails[ti]
        if tail then
            local count, head, buf, tex = tail.count, tail.head, tail.buf, tail.tex
            for i = 1, count do
                local e = buf[((head - i) % tailLen) + 1]
                local ab = (tailLen - i + 1) / tailLen
                local seg = ctxTaper and (size * (0.3 + 0.7 * ab)) or size
                style(tex[i], e, i, ab, seg)
            end
            for i = count + 1, tail.drawn do
                local t = tex[i]
                if t then t:Hide() end
            end
            tail.drawn = count
        end
    end
    tailsDrawn = true
end

local function FadeTails(size, still)
    local k = max(1 - still, 0)
    for ti = 1, numTailsActive do
        local tail = tails[ti]
        if tail then
            local head, buf, tex = tail.head, tail.buf, tail.tex
            for i = 1, tail.count do
                local e = buf[((head - i) % tailLen) + 1]
                local a = ((tailLen - i + 1) / tailLen) * k
                Place(tex[i], e.x, e.y, size * a, size * a, ctxR, ctxG, ctxB, a * ctxOp)
            end
        end
    end
end

-- Stationary sparkles
-- One shared OnUpdate function stored on each pooled frame. Hidden frames do not tick.

local sparkles = {}
local sparklePoolCount = 24
local sparkleIndex = 1
local sparkleAcc = 0
local sparklesActive = false

local function SparkleOnUpdate(self, dt)
    local age = self.age + dt
    self.age = age
    local t = age / self.life
    if t >= 1 then
        self:Hide()
        return
    end
    local s = self.size * (1 + 0.2 * t)
    self:SetSize(s, s)
    self:SetAlpha((1 - t) * self.peak)
end

local function ClearIdleSparkles(force)
    sparkleAcc = 0
    if not sparklesActive and not force then return end
    for i = 1, #sparkles do
        sparkles[i]:Hide()
    end
    sparklesActive = false
    sparkleIndex = 1
end

local function RefreshSparkles()
    if not CursorGlow.db then return end
    local p = CursorGlow.db.profile

    if not p.stationarySparkleEnabled then
        ClearIdleSparkles(true)
        return
    end

    sparklePoolCount = floor(Clamp(p.stationarySparklePoolCount or 24, 1, 128))
    local path = textureOptions[p.stationarySparkleTexture] or textureOptions["ring11"]
    local br, bg, bb = GetBaseColor()
    local r, g, b = ResolveColor(UnpackColor(p.stationarySparkleColor, br, bg, bb))

    for i = 1, sparklePoolCount do
        local f = sparkles[i]
        if not f then
            f = CreateFrame("Frame", nil, UIParent)
            f:SetFrameStrata("TOOLTIP")
            f:SetFrameLevel((frame:GetFrameLevel() or 0) + 10)
            local tex = f:CreateTexture(nil, "ARTWORK")
            tex:SetAllPoints(f)
            tex:SetBlendMode("ADD")
            f.texture = tex
            f.age, f.life, f.size, f.peak = 0, 1, 1, 1
            f:SetScript("OnUpdate", SparkleOnUpdate)
            f:Hide()
            sparkles[i] = f
        end
        f.texture:SetTexture(path)
        f.texture:SetVertexColor(r, g, b, 1)
    end

    for i = sparklePoolCount + 1, #sparkles do
        sparkles[i]:Hide()
    end
    if sparkleIndex > sparklePoolCount then
        sparkleIndex = 1
    end
end

local function SpawnIdleSparkle(x, y, scale)
    local p = CursorGlow.db.profile
    local f = sparkles[sparkleIndex]
    if not f then return end
    sparkleIndex = sparkleIndex % sparklePoolCount + 1

    local offset = max(tonumber(p.stationarySparkleOffset) or 10, 0) / scale
    local minS = tonumber(p.stationarySparkleSizeMin) or 6
    local maxS = tonumber(p.stationarySparkleSizeMax) or 14
    if minS > maxS then minS, maxS = maxS, minS end
    local size = minS + random() * (maxS - minS)

    f.age  = 0
    f.life = max(tonumber(p.stationarySparkleLifetime) or 0.8, 0.05)
    f.size = size
    f.peak = tonumber(p.opacity) or 1

    f:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
        x + (random() * 2 - 1) * offset,
        y + (random() * 2 - 1) * offset)
    f:SetSize(size, size)
    f:SetAlpha(f.peak)
    f:Show()
    sparklesActive = true
end

-- Explosion particles
-- Configured when settings change, not on every click.

local particles = {}

local function ParticleOnUpdate(self, dt)
    local a = self.alpha - dt * 0.8
    if a <= 0 then
        self:Hide()
        return
    end
    self.alpha = a
    self.px = self.px + self.vx * dt
    self.py = self.py + self.vy * dt
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", self.px, self.py)
    self:SetAlpha(a)
end

local function RefreshParticles()
    if not CursorGlow.db then return end
    local p = CursorGlow.db.profile

    if not p.enableExplosion then
        for i = 1, #particles do particles[i]:Hide() end
        return
    end

    local size = Clamp(p.explosionTextureSize or 10, 1, 128)
    local path = textureOptions[p.explosionTexture] or textureOptions["ring1"]
    local r, g, b = ResolveColor(UnpackColor(p.explosionColor, 1, 1, 1))

    for i = 1, NUM_PARTICLES do
        local pt = particles[i]
        if not pt then
            pt = CreateFrame("Frame", nil, UIParent)
            pt:SetFrameStrata("TOOLTIP")
            local tex = pt:CreateTexture(nil, "ARTWORK")
            tex:SetBlendMode("ADD")
            tex:SetAllPoints(pt)
            pt.texture = tex
            pt.px, pt.py, pt.vx, pt.vy, pt.alpha = 0, 0, 0, 0, 0
            pt:SetScript("OnUpdate", ParticleOnUpdate)
            pt:Hide()
            particles[i] = pt
        end
        pt:SetSize(size, size)
        pt.texture:SetTexture(path)
        pt.texture:SetVertexColor(r, g, b, 1)
    end
end

local function TriggerExplosion()
    local p = CursorGlow.db.profile
    if not p.enableExplosion or not frame:IsShown() or glowPassive or wasMouselooking or #particles == 0 then
        return
    end

    local scale = UIParent:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    cx, cy = cx / scale, cy / scale
    local spread = max(1, floor(tonumber(p.explosionSize) or 15))

    for i = 1, #particles do
        local pt = particles[i]
        local angle = random() * TWO_PI
        local dist = random(1, spread)
        pt.px, pt.py = cx, cy
        pt.vx = cos(angle) * dist * EXPLOSION_SPEED
        pt.vy = sin(angle) * dist * EXPLOSION_SPEED
        pt.alpha = 1
        pt:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx, cy)
        pt:SetAlpha(1)
        pt:Show()
    end
end

-- Click ripples
-- Pooled ring frames sharing one OnUpdate function, reused round robin.

local ripples = {}
local rippleIndex = 1

local function RippleOnUpdate(self, dt)
    local age = self.age + dt
    self.age = age
    local t = age / self.life
    if t >= 1 then
        self:Hide()
        return
    end
    local e = 1 - (1 - t) * (1 - t)  -- ease out
    local s = self.s0 + (self.s1 - self.s0) * e
    self:SetSize(s, s)
    self:SetAlpha((1 - t) * self.peak)
end

local function RefreshRipples()
    if not CursorGlow.db then return end
    local p = CursorGlow.db.profile

    if not p.rippleEnabled then
        for i = 1, #ripples do ripples[i]:Hide() end
        return
    end

    local path = textureOptions[p.rippleTexture] or textureOptions["ring1"]
    for i = 1, MAX_RIPPLES do
        local f = ripples[i]
        if not f then
            f = CreateFrame("Frame", nil, UIParent)
            f:SetFrameStrata("TOOLTIP")
            f:SetFrameLevel((frame:GetFrameLevel() or 0) + 5)
            local tex = f:CreateTexture(nil, "ARTWORK")
            tex:SetAllPoints(f)
            tex:SetBlendMode("ADD")
            f.texture = tex
            f.age, f.life, f.s0, f.s1, f.peak = 0, 1, 1, 1, 1
            f:SetScript("OnUpdate", RippleOnUpdate)
            f:Hide()
            ripples[i] = f
        end
        f.texture:SetTexture(path)
    end
    if rippleIndex > #ripples then
        rippleIndex = 1
    end
end

local function TriggerRipple(button)
    local p = CursorGlow.db.profile
    if not p.rippleEnabled or not frame:IsShown() or glowPassive or wasMouselooking or #ripples == 0 then
        return
    end

    local which = p.rippleButtons or "both"
    local color
    if button == "LeftButton" and (which == "both" or which == "left") then
        color = p.rippleLeftColor
    elseif button == "RightButton" and (which == "both" or which == "right") then
        color = p.rippleRightColor
    else
        return
    end

    local r, g, b = ResolveColor(UnpackColor(color, 1, 1, 1))
    local scale = UIParent:GetEffectiveScale()
    local cx, cy = GetCursorPosition()

    local f = ripples[rippleIndex]
    rippleIndex = rippleIndex % #ripples + 1

    f.age  = 0
    f.life = max(tonumber(p.rippleDuration) or 0.45, 0.05)
    f.s0   = max(tonumber(p.rippleStartSize) or 16, 1)
    f.s1   = max(tonumber(p.rippleEndSize) or 96, 1)
    f.peak = tonumber(p.opacity) or 1

    f.texture:SetVertexColor(r, g, b, 1)
    f:SetPoint("CENTER", UIParent, "BOTTOMLEFT", cx / scale, cy / scale)
    f:SetSize(f.s0, f.s0)
    f:SetAlpha(f.peak)
    f:Show()
end

-- Appearance refresh

local function RefreshColors()
    CacheColorblind()
    baseR, baseG, baseB = GetBaseColor()
    mainR, mainG, mainB = ResolveColor(baseR, baseG, baseB)
    texture:SetVertexColor(mainR, mainG, mainB, 1)
    RefreshSparkles()
    RefreshParticles()
end

local function ApplyMainTexture()
    local p = CursorGlow.db.profile
    currentTexturePath = textureOptions[p.texture] or textureOptions[DEFAULT_TEXTURE]
    texture:SetTexture(currentTexturePath)
    for _, t in pairs(tailPool) do
        t:SetTexture(currentTexturePath)
    end
end

local function ResetRotation()
    CursorGlow.rotationAngle = 0
    texture:SetRotation(0)
end

-- Visibility

local function UpdateAddonVisibility()
    local db = CursorGlow.db
    if not db then return end
    local p = db.profile
    local mode = p.operationMode

    local active
    if CursorGlow._tempDisabled or mode == "disabled" then
        active = false
    elseif mode == "enabledInCombat" then
        active = inCombat
    else
        active = true
    end

    -- Passive mode keeps the update loop running only so Shake to Find still works
    local passive = (not active) and (not CursorGlow._tempDisabled) and (mode ~= "disabled")
        and p.shakeEnabled and p.shakeWhenHidden and true or false

    local enteringPassive = passive and not glowPassive
    glowPassive = passive

    if active or passive then
        if not frame:IsShown() then
            ResetMotionState()
            ResetTails()
            frame:Show()
        end
        if enteringPassive then
            ResetTails()
            ClearIdleSparkles(true)
            zzzFont:Hide()
            texture:Hide()
        end
    else
        if frame:IsShown() then
            frame:Hide()
        end
        zzzFont:Hide()
        ClearIdleSparkles(true)
        ResetTails()
    end
end

-- Low CPU and FPS watcher

local function SetFPSLowCPU(enable)
    enable = enable and true or false
    if fpsLowCPU == enable then return end
    fpsLowCPU = enable
    RebuildTails()
end

local fpsTicker
local fpsState  -- nil, "disable" or "lowcpu"
local fpsLowStreak, fpsOkStreak = 0, 0

local function ExitFPSFallback()
    if fpsState == "disable" then
        if CursorGlow._tempDisabled == "fps" then
            CursorGlow._tempDisabled = nil
        end
        UpdateAddonVisibility()
    elseif fpsState == "lowcpu" then
        SetFPSLowCPU(false)
    end
    fpsState = nil
    fpsLowStreak, fpsOkStreak = 0, 0
end

local function EnterFPSFallback(kind)
    if kind == "lowcpu" then
        SetFPSLowCPU(true)
    else
        CursorGlow._tempDisabled = "fps"
        UpdateAddonVisibility()
    end
    fpsState = kind
    fpsLowStreak, fpsOkStreak = 0, 0
end

local function CheckLowFPS()
    local db = CursorGlow.db
    if not db then return end
    local p = db.profile
    local fps = GetFramerate() or 60
    local threshold = tonumber(p.lowFPSThreshold) or 20

    if fpsState then
        if fps >= threshold + FPS_RECOVER_MARGIN then
            fpsOkStreak = fpsOkStreak + 1
            if fpsOkStreak >= FPS_RECOVER_CHECKS then
                ExitFPSFallback()
            end
        else
            fpsOkStreak = 0
        end
    else
        if fps < threshold then
            fpsLowStreak = fpsLowStreak + 1
            if fpsLowStreak >= FPS_LOW_CHECKS then
                EnterFPSFallback(p.lowFPSFallback == "lowcpu" and "lowcpu" or "disable")
            end
        else
            fpsLowStreak = 0
        end
    end
end

local function UpdateFPSWatcher()
    local p = CursorGlow.db.profile
    if p.autoDisableLowFPS then
        if not fpsTicker then
            fpsTicker = C_Timer.NewTicker(FPS_CHECK_INTERVAL, CheckLowFPS)
        end
    else
        if fpsTicker then
            fpsTicker:Cancel()
            fpsTicker = nil
        end
        if fpsState then
            ExitFPSFallback()
        end
    end
end

function CursorGlow:DisableAddonTemporarily(reason)
    self._tempDisabled = reason or true
    UpdateAddonVisibility()
end

function CursorGlow:EnableAddonAfterTemp()
    self._tempDisabled = nil
    UpdateAddonVisibility()
end

function CursorGlow:SetLowCPUModeActive(enable)
    SetFPSLowCPU(enable)
end

-- Settings panel

local function EnsureSettingsLoaded()
    if Settings then return end
    local loader = (C_AddOns and C_AddOns.LoadAddOn) or LoadAddOn
    if loader then
        pcall(loader, "Blizzard_Settings")
    end
end

local function ResolveCategoryID()
    if CursorGlow._settingsCategoryID ~= nil then
        return CursorGlow._settingsCategoryID
    end
    if SettingsPanel and SettingsPanel.GetAllCategories then
        local ok, cats = pcall(SettingsPanel.GetAllCategories, SettingsPanel)
        if ok and type(cats) == "table" then
            for _, cat in ipairs(cats) do
                local name = (cat.GetName and cat:GetName()) or cat.name
                if name == ADDON_NAME then
                    local id = (cat.GetID and cat:GetID()) or cat.ID
                    if id ~= nil then
                        CursorGlow._settingsCategoryID = id
                        return id
                    end
                end
            end
        end
    end
    return nil
end

local function OpenCursorGlowSettings()
    EnsureSettingsLoaded()

    local id = ResolveCategoryID()
    if id ~= nil and Settings and Settings.OpenToCategory then
        if pcall(Settings.OpenToCategory, id) then
            return
        end
    end

    if AceConfigDialog and AceConfigDialog.Open then
        AceConfigDialog:Open(ADDON_NAME)
        return
    end

    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(ADDON_NAME)
        InterfaceOptionsFrame_OpenToCategory(ADDON_NAME)
        return
    end

    print("|cffff0000CursorGlow: Settings not available.|r")
end

local function OpenMainOptions()
    EnsureSettingsLoaded()

    if SettingsPanel then
        if SettingsPanel.Open and pcall(SettingsPanel.Open, SettingsPanel) then
            return
        end
        if ShowUIPanel then
            ShowUIPanel(SettingsPanel)
            return
        end
    end

    if InterfaceOptionsFrame then
        InterfaceOptionsFrame:Show()
        return
    end

    OpenCursorGlowSettings()
end

function CursorGlow:OpenSettings()
    OpenCursorGlowSettings()
end

-- Minimap button

local minimapButton = LDB:NewDataObject(ADDON_NAME, {
    type = "data source",
    text = ADDON_NAME,
    icon = 1362657,
    OnClick = function(_, button)
        if button == "LeftButton" then
            OpenMainOptions()
        elseif button == "RightButton" then
            OpenCursorGlowSettings()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("|cff00ff00CursorGlow|r")
        tooltip:AddLine("|cffffff00Left Click:|r Open Options", 1, 1, 1)
        tooltip:AddLine("|cffffff00Right Click:|r Open CursorGlow Settings", 1, 1, 1)
    end,
})

-- Defaults

local profileDefaults = {
    profile = {
        operationMode = "enabledAlways",
        enableExplosion = false,
        explosionColor = { 1, 1, 1 },
        explosionSize = 15,
        explosionTextureSize = 10,
        explosionTexture = "ring1",
        opacity = 1,
        minSize = 16,
        maxSize = 175,
        texture = "ring1",
        color = { 1, 1, 1 },
        enableTail = false,
        tailLength = 60,
        numTails = 1,
        tailSpacing = 10,
        tailTaper = false,
        minimap = { hide = false },
        pulseEnabled = false,
        pulseMinSize = 50,
        pulseMaxSize = 100,
        pulseSpeed = 1,
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
        staticSizeEnabled = false,
        lowCPUMode = false,
        lowCPUUpdateInterval = 100,
        lowCPUTailLength = 20,
        autoDisableLowFPS = false,
        lowFPSThreshold = 20,
        lowFPSFallback = "disable",

        -- Hide while mouselooking
        hideWhileMouselooking = true,
        mouselookFadeTime = 0.15,

        -- Shake to Find
        shakeEnabled = false,
        shakeSensitivity = "medium",
        shakeBoostSize = 256,
        shakeDuration = 1.2,
        shakeCooldown = 1.5,
        shakeWhenHidden = true,

        -- Click ripples
        rippleEnabled = false,
        rippleButtons = "both",
        rippleLeftColor = { 0.3, 0.8, 1 },
        rippleRightColor = { 1, 0.6, 0.2 },
        rippleTexture = "ring1",
        rippleStartSize = 16,
        rippleEndSize = 96,
        rippleDuration = 0.45,

        -- Elastic follow
        elasticEnabled = false,
        elasticStiffness = 150,
        elasticBounciness = 0.35,
        elasticTailFollowsGlow = true,

        -- Color cycling
        colorCycleEnabled = false,
        colorCycleMode = "rainbow",
        colorCycleSecondColor = { 1, 0.2, 0.8 },
        colorCycleSpeed = 0.25,
        colorCycleTail = true,

        -- Stationary sparkles
        stationarySparkleEnabled = false,
        stationarySparkleInterval = 0.15,
        stationarySparklesPerTick = 1,
        stationarySparklePoolCount = 24,
        stationarySparkleSizeMin = 6,
        stationarySparkleSizeMax = 14,
        stationarySparkleOffset = 10,
        stationarySparkleLifetime = 0.8,
        stationarySparkleTexture = "ring11",
        stationarySparkleColor = { 1, 1, 1 },
        stationarySparkleDimMain = true,
        stationarySparkleMainAlpha = 0.6,

        -- Accessibility
        colorblindEnabled = false,
        colorblindMode = "none",
        colorblindHighContrastThreshold = 0.5,
        colorblindHighContrastDark = { 1, 1, 1 },
        colorblindHighContrastLight = { 1, 1, 0 },
    },
}
local globalDefaults = { global = { profileEnabled = false } }
local charDefaults   = { char = { lastSelectedProfile = nil } }

-- Settings application

function CursorGlow:ApplySettings()
    local p = self.db.profile

    -- One time migration of old named colors to RGB tables
    if type(p.color) == "string" then
        local m = colorOptions[p.color] or { 1, 1, 1 }
        p.color = { m[1], m[2], m[3] }
    end
    if type(p.color) ~= "table" then p.color = { 1, 1, 1 } end
    if type(p.minimap) ~= "table" then p.minimap = { hide = false } end

    ApplyMainTexture()
    RebuildTails()
    RefreshColors()
    RefreshRipples()

    if not p.rotationEnabled then
        ResetRotation()
    end
    if not p.idleIndicatorEnabled then
        zzzFont:Hide()
    end

    UpdateAddonVisibility()
    UpdateFPSWatcher()

    if icon:IsRegistered(ADDON_NAME) then
        icon:Refresh(ADDON_NAME, p.minimap)
        if p.minimap.hide then icon:Hide(ADDON_NAME) else icon:Show(ADDON_NAME) end
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
        local characterProfileName = CharacterProfileName()
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

local function P() return CursorGlow.db.profile end
local function TailOff() return not P().enableTail end
local function ExplosionOff() return not P().enableExplosion end
local function SparkleOff() return not P().stationarySparkleEnabled end
local function PulseOff() return not P().pulseEnabled end
local function LowCPUOff() return not P().lowCPUMode end
local function FPSOff() return not P().autoDisableLowFPS end
local function RippleOff() return not P().rippleEnabled end
local function ElasticOff() return not P().elasticEnabled end
local function CycleOff() return not P().colorCycleEnabled end
local function ShakeOff() return not P().shakeEnabled end

-- Setter that stores the value under the option key, then runs a refresh
local function Setter(after)
    return function(info, value)
        P()[info[#info]] = value
        if after then after() end
    end
end

local function ColorGetter(info)
    return UnpackColor(P()[info[#info]], 1, 1, 1)
end

local function ColorSetter(after)
    return function(info, r, g, b)
        P()[info[#info]] = { r, g, b }
        if after then after() end
    end
end

local options = {
    name = ADDON_NAME,
    type = "group",
    -- Inherited by every option whose key matches its profile key
    get = function(info) return P()[info[#info]] end,
    set = function(info, value) P()[info[#info]] = value end,
    args = {
        generalHeader = { type = "header", name = L["General Settings"], order = 1 },
        general = {
            type = "group", name = L["General"], order = 2, inline = true,
            args = {
                globalProfileEnabled = {
                    type = "toggle", name = L["Enable Global Profile"], desc = L["Use the same settings for all characters"], order = 1,
                    get = function() return CursorGlow.dbGlobal.global.profileEnabled end,
                    set = function(_, val)
                        CursorGlow.dbGlobal.global.profileEnabled = val
                        if val then
                            CursorGlow.db:SetProfile("Global")
                        else
                            CursorGlow.db:SetProfile(CharacterProfileName())
                        end
                        CursorGlow:ApplySettings()
                    end,
                },
                operationMode = {
                    type = "select", name = L["Operation Mode"], desc = L["Select when the addon should be active"], order = 2,
                    values = {
                        enabledAlways = L["Enabled Always"],
                        enabledInCombat = L["Enabled in Combat Only"],
                        enabledAlwaysOnCursor = L["Always Show on Cursor"],
                        disabled = "Disabled",
                    },
                    set = Setter(UpdateAddonVisibility),
                },
                showMinimapIcon = {
                    type = "toggle", name = L["Show Minimap Icon"], desc = L["Show or hide the minimap icon"], order = 3,
                    get = function() return not P().minimap.hide end,
                    set = function(_, val)
                        P().minimap.hide = not val
                        if val then icon:Show(ADDON_NAME) else icon:Hide(ADDON_NAME) end
                    end,
                },
                idleIndicatorEnabled = {
                    type = "toggle", name = "Show ZZZ Above Cursor When Idle",
                    desc = "Show a floating ZZZ indicator above the cursor after the mouse has been still for a while.",
                    order = 4,
                    set = Setter(function() if not P().idleIndicatorEnabled then zzzFont:Hide() end end),
                },
                idleThreshold = {
                    type = "range", name = "Idle Time (seconds)", desc = "How long to wait before showing the ZZZ indicator.",
                    order = 5, min = 5, max = 300, step = 1,
                },
                hideWhileMouselooking = {
                    type = "toggle", name = "Hide While Mouselooking", order = 5.1,
                    desc = "Hide the glow while you hold a mouse button to turn the camera, since the game hides your cursor then too.",
                },
                mouselookFadeTime = {
                    type = "range", name = "Mouselook Fade Time (s)", order = 5.2, min = 0, max = 1, step = 0.05,
                    desc = "How long the glow takes to fade out when mouselook starts. Set to 0 to hide instantly. It always comes back instantly.",
                    disabled = function() return not P().hideWhileMouselooking end,
                },
                spacerGeneral1 = { type = "description", name = " ", order = 6 },
            },
        },

        explosionHeader = { type = "header", name = L["Explosion Settings"], order = 10 },
        explosion = {
            type = "group", name = L["Explosion"], order = 11, inline = true,
            args = {
                enableExplosion = {
                    type = "toggle", name = L["Enable Explosion Effect"], desc = L["Enable or disable the explosion effect on left-click"], order = 1,
                    set = Setter(RefreshParticles),
                },
                explosionColor = {
                    type = "color", name = L["Explosion Color"], desc = L["Pick a color for the explosion effect"], order = 2,
                    get = ColorGetter, set = ColorSetter(RefreshParticles), disabled = ExplosionOff,
                },
                spacerExplosion1 = { type = "description", name = " ", order = 3 },
                explosionSize = {
                    type = "range", name = L["Explosion Size"], desc = L["Adjust the size of the explosion effect"], order = 4, min = 5, max = 50, step = 1,
                    disabled = ExplosionOff,
                },
                explosionTextureSize = {
                    type = "range", name = L["Explosion Texture Size"], desc = L["Adjust the texture size for the explosion effect"], order = 5, min = 10, max = 40, step = 1,
                    set = Setter(RefreshParticles), disabled = ExplosionOff,
                },
                explosionTexture = {
                    type = "select", name = L["Explosion Texture"], desc = L["Select the texture for the explosion effect"], order = 6, values = textureValues,
                    set = Setter(RefreshParticles), disabled = ExplosionOff,
                },
            },
        },

        rippleHeader = { type = "header", name = "Click Ripples", order = 12 },
        ripples = {
            type = "group", name = "Click Ripples", order = 13, inline = true,
            args = {
                rippleEnabled = {
                    type = "toggle", name = "Enable Click Ripples", order = 1,
                    desc = "Show an expanding ring wherever you click.",
                    set = Setter(RefreshRipples),
                },
                rippleButtons = {
                    type = "select", name = "Trigger On", order = 2,
                    desc = "Which mouse buttons create a ripple.",
                    values = { both = "Left and Right Click", left = "Left Click Only", right = "Right Click Only" },
                    disabled = RippleOff,
                },
                rippleLeftColor = {
                    type = "color", name = "Left Click Color", order = 3,
                    get = ColorGetter, set = ColorSetter(), disabled = RippleOff,
                },
                rippleRightColor = {
                    type = "color", name = "Right Click Color", order = 4,
                    get = ColorGetter, set = ColorSetter(), disabled = RippleOff,
                },
                rippleTexture = {
                    type = "select", name = "Ripple Texture", order = 5, values = textureValues,
                    set = Setter(RefreshRipples), disabled = RippleOff,
                },
                rippleStartSize = {
                    type = "range", name = "Start Size (px)", order = 6, min = 4, max = 128, step = 1,
                    disabled = RippleOff,
                },
                rippleEndSize = {
                    type = "range", name = "End Size (px)", order = 7, min = 16, max = 400, step = 2,
                    disabled = RippleOff,
                },
                rippleDuration = {
                    type = "range", name = "Duration (s)", order = 8, min = 0.1, max = 2, step = 0.05,
                    disabled = RippleOff,
                },
            },
        },

        appearanceHeader = { type = "header", name = L["Appearance Settings"], order = 20 },
        appearance = {
            type = "group", name = L["Appearance"], order = 21, inline = true,
            args = {
                texture = {
                    type = "select", name = L["Texture"], desc = L["Select the texture for the cursor glow"], order = 1, values = textureValues,
                    set = Setter(ApplyMainTexture),
                },
                color = {
                    type = "color", name = L["Color"], desc = L["Select the color for the texture"], order = 2, hasAlpha = false,
                    get = ColorGetter, set = ColorSetter(RefreshColors),
                },
                useClassColor = {
                    type = "execute", name = "Use Class Color", order = 2.1,
                    func = function()
                        P().color = GetDefaultClassColor()
                        RefreshColors()
                    end,
                },
                opacity = {
                    type = "range", name = L["Opacity"], desc = L["Adjust the opacity of the texture"], order = 3, min = 0, max = 1, step = 0.01,
                },
                rotationEnabled = {
                    type = "toggle", name = "Enable Rotation", desc = "Slowly rotate the main cursor texture.", order = 3.1,
                    set = Setter(function() if not P().rotationEnabled then ResetRotation() end end),
                },
                rotationSpeed = {
                    type = "range", name = "Rotation Speed", desc = "Degrees per second for rotation.", order = 3.2, min = 5, max = 360, step = 5,
                    disabled = function() return not P().rotationEnabled end,
                },
                bounceEnabled = {
                    type = "toggle", name = "Enable Bounce", desc = "Make the cursor glow move up and down.", order = 3.3,
                },
                bounceSpeed = {
                    type = "range", name = "Bounce Speed", desc = "Number of up and down cycles per second.", order = 3.4, min = 0.2, max = 5, step = 0.1,
                    disabled = function() return not P().bounceEnabled end,
                },
                bounceAmplitude = {
                    type = "range", name = "Bounce Amplitude", desc = "Vertical distance (pixels) of the bounce.", order = 3.5, min = 2, max = 64, step = 1,
                    disabled = function() return not P().bounceEnabled end,
                },
                spacerAppearance1 = { type = "description", name = " ", order = 4 },
                staticSizeEnabled = {
                    type = "toggle", name = "Static Size (Always Use Maximum)",
                    desc = "If enabled, the cursor will always use the maximum size, regardless of movement.",
                    order = 4.5,
                },
                minSize = {
                    type = "range", name = L["Minimum Size"], desc = L["Set the minimum size of the texture"], order = 5, min = 16, max = 256, step = 1,
                    disabled = function() return P().staticSizeEnabled end,
                },
                maxSize = {
                    type = "range", name = L["Maximum Size"], desc = L["Set the maximum size of the texture"], order = 6, min = 16, max = 256, step = 1,
                },
            },
        },

        elasticHeader = { type = "header", name = "Elastic Follow", order = 22 },
        elastic = {
            type = "group", name = "Elastic Follow", order = 23, inline = true,
            args = {
                elasticEnabled = {
                    type = "toggle", name = "Enable Elastic Follow", order = 1,
                    desc = "The glow chases your cursor on a spring instead of sitting exactly on it.",
                },
                elasticStiffness = {
                    type = "range", name = "Stiffness", order = 2, min = 20, max = 600, step = 5,
                    desc = "Higher values chase the cursor more tightly.",
                    disabled = ElasticOff,
                },
                elasticBounciness = {
                    type = "range", name = "Bounciness", order = 3, min = 0, max = 0.9, step = 0.05,
                    desc = "How much the glow overshoots before settling. At 0 it settles smoothly with no bounce.",
                    disabled = ElasticOff,
                },
                elasticTailFollowsGlow = {
                    type = "toggle", name = "Tail Follows Glow", order = 4,
                    desc = "When on, the tail trails the elastic glow. When off, it trails your real cursor position.",
                    disabled = ElasticOff,
                },
            },
        },

        colorCycleHeader = { type = "header", name = "Color Cycling", order = 24 },
        colorCycle = {
            type = "group", name = "Color Cycling", order = 25, inline = true,
            args = {
                colorCycleEnabled = {
                    type = "toggle", name = "Enable Color Cycling", order = 1,
                    desc = "Animate the main glow color. Replaces the static color while enabled.",
                    set = Setter(RefreshColors),
                },
                colorCycleMode = {
                    type = "select", name = "Mode", order = 2,
                    desc = "Rainbow cycles through every hue. Breathe fades between your main color and a second color.",
                    values = { rainbow = "Rainbow", breathe = "Breathe (Main and Second Color)" },
                    disabled = CycleOff,
                },
                colorCycleSecondColor = {
                    type = "color", name = "Second Color", order = 3,
                    get = ColorGetter, set = ColorSetter(),
                    disabled = function() return not (P().colorCycleEnabled and P().colorCycleMode == "breathe") end,
                },
                colorCycleSpeed = {
                    type = "range", name = "Cycle Speed", order = 4, min = 0.05, max = 2, step = 0.05,
                    desc = "Full color cycles per second.",
                    disabled = CycleOff,
                },
                colorCycleTail = {
                    type = "toggle", name = "Apply to Tail", order = 5,
                    desc = "The tail uses the cycling color too. Tail styles with their own colors (Rainbow, Fire, Electric) are not affected.",
                    disabled = CycleOff,
                },
            },
        },

        shakeHeader = { type = "header", name = "Shake to Find", order = 26 },
        shake = {
            type = "group", name = "Shake to Find", order = 27, inline = true,
            args = {
                shakeEnabled = {
                    type = "toggle", name = "Enable Shake to Find", order = 1,
                    desc = "Shake the mouse quickly side to side and the glow swells up so you can spot your cursor.",
                    set = Setter(UpdateAddonVisibility),
                },
                shakeSensitivity = {
                    type = "select", name = "Sensitivity", order = 2,
                    desc = "How easily a shake is detected.",
                    values = { low = "Low (hard shake)", medium = "Medium", high = "High (light shake)" },
                    disabled = ShakeOff,
                },
                shakeBoostSize = {
                    type = "range", name = "Boost Size (px)", order = 3, min = 64, max = 512, step = 8,
                    desc = "How big the glow grows when a shake is detected.",
                    disabled = ShakeOff,
                },
                shakeDuration = {
                    type = "range", name = "Duration (s)", order = 4, min = 0.3, max = 3, step = 0.1,
                    desc = "How long the glow stays enlarged before shrinking back.",
                    disabled = ShakeOff,
                },
                shakeCooldown = {
                    type = "range", name = "Cooldown (s)", order = 5, min = 0, max = 5, step = 0.1,
                    desc = "Minimum time after a shake ends before another can trigger. Helps avoid accidental triggers during fast flicks.",
                    disabled = ShakeOff,
                },
                shakeWhenHidden = {
                    type = "toggle", name = "Works While Glow Is Hidden", order = 6,
                    desc = "Lets Shake to Find work even when Combat Only mode has the glow hidden. Does nothing if the addon is set to Disabled.",
                    set = Setter(UpdateAddonVisibility), disabled = ShakeOff,
                },
            },
        },

        tailHeader = { type = "header", name = L["Tail Effect Settings"], order = 30 },
        tailSettings = {
            type = "group", name = L["Tail Effect"], order = 31, inline = true,
            args = {
                enableTail = {
                    type = "toggle", name = L["Enable Tail Effect"], desc = L["Toggle the tail effect behind the cursor"], order = 1,
                    set = Setter(function() if not P().enableTail then ResetTails() end end),
                },
                tailLength = {
                    type = "range", name = L["Tail Length"], desc = L["Adjust the length of the cursor tail"], order = 2, min = 10, max = MAX_TAIL_LENGTH, step = 1,
                    set = Setter(RebuildTails), disabled = TailOff,
                },
                numTails = {
                    type = "range", name = L["Number of Tails"], desc = L["Select the number of tails"], order = 3, min = 1, max = MAX_TAILS, step = 1,
                    set = Setter(RebuildTails), disabled = TailOff,
                },
                tailSpacing = {
                    type = "range", name = L["Tail Spacing"], desc = L["Adjust the spacing between multiple tails"], order = 4, min = 0, max = 50, step = 1,
                    disabled = TailOff,
                },
                tailEffectStyle = {
                    type = "select", name = "Tail Effect Style", desc = "Choose the animation style for the cursor tail.", order = 5,
                    values = tailStyleValues,
                    set = Setter(ResetTails), disabled = TailOff,
                },
                tailTaper = {
                    type = "toggle", name = "Taper Tail Size",
                    desc = "Shrink tail segments toward the end of the tail. Looks sleeker and is noticeably lighter on the GPU with long or multiple tails.",
                    order = 5.5, disabled = TailOff,
                },
                tailParticleSpeed = {
                    type = "range", name = "Particle Fade Speed", desc = "How quickly particles fade out (in seconds).", order = 6, min = 0.2, max = 2, step = 0.1,
                    disabled = TailOff,
                },
                tailParticleScatter = {
                    type = "range", name = "Particle Scatter", desc = "How much particles are randomly offset (in pixels).", order = 7, min = 0, max = 16, step = 1,
                    disabled = TailOff,
                },
                tailParticleWobble = {
                    type = "range", name = "Particle Wobble", desc = "Wobble strength for the particle tail (in pixels).", order = 8, min = 0, max = 20, step = 1,
                    disabled = TailOff,
                },
            },
        },

        pulseHeader = { type = "header", name = L["Pulse Effect Settings"], order = 40 },
        pulseSettings = {
            type = "group", name = L["Pulse Effect"], order = 41, inline = true,
            args = {
                pulseEnabled = {
                    type = "toggle", name = L["Enable Pulse Effect"], desc = L["Toggle the pulsing effect when cursor is stationary"], order = 1,
                },
                pulseMinSize = {
                    type = "range", name = L["Pulse Minimum Size"], desc = L["Set the minimum size of the pulse effect"], order = 2, min = 10, max = 150, step = 1,
                    disabled = PulseOff,
                },
                pulseMaxSize = {
                    type = "range", name = L["Pulse Maximum Size"], desc = L["Set the maximum size of the pulse effect"], order = 3, min = 20, max = 200, step = 1,
                    disabled = PulseOff,
                },
                pulseSpeed = {
                    type = "range", name = L["Pulse Speed"], desc = L["Adjust the speed of the pulsing effect"], order = 4, min = 0.1, max = 5, step = 0.1,
                    disabled = PulseOff,
                },
            },
        },

        accessibilityHeader = { type = "header", name = "Accessibility", order = 42 },
        accessibility = {
            type = "group", name = "Accessibility", order = 43, inline = true,
            args = {
                colorblindEnabled = {
                    type = "toggle", name = "Enable Colorblind Mode", order = 1,
                    desc = "Remap cursor, tail, sparkle and explosion colors so they stay easy to see and tell apart.",
                    set = Setter(RefreshColors),
                },
                colorblindMode = {
                    type = "select", name = "Colorblind Mode", order = 2,
                    desc = "Protanopia, Deuteranopia and Tritanopia swap your colors for the nearest bright color that type of color vision can distinguish. Achromatopsia converts to grayscale. High Contrast forces every color to white or yellow.",
                    values = {
                        none = "None",
                        protanopia = "Protanopia (red weak)",
                        deuteranopia = "Deuteranopia (green weak)",
                        tritanopia = "Tritanopia (blue weak)",
                        achromatopsia = "Achromatopsia (grayscale)",
                        highcontrast = "High Contrast",
                    },
                    set = Setter(RefreshColors),
                    disabled = function() return not P().colorblindEnabled end,
                },
                colorblindHighContrastThreshold = {
                    type = "range", name = "High Contrast Threshold", order = 3, min = 0, max = 1, step = 0.01,
                    desc = "Colors darker than this become white, brighter colors become yellow.",
                    set = Setter(RefreshColors),
                    disabled = function() return not (P().colorblindEnabled and P().colorblindMode == "highcontrast") end,
                },
            },
        },

        stationaryHeader = { type = "header", name = "Stationary Sparkles", order = 45 },
        stationarySparkles = {
            type = "group", name = "Stationary Sparkles", order = 46, inline = true,
            args = {
                stationarySparkleEnabled = {
                    type = "toggle", name = "Enable Sparkles While Idle", order = 1,
                    desc = "Emit small sparkles while the cursor is stationary.",
                    set = Setter(RefreshSparkles),
                },
                stationarySparkleColor = {
                    type = "color", name = "Sparkle Color", order = 2,
                    desc = "Color used for stationary sparkles.",
                    get = ColorGetter, set = ColorSetter(RefreshSparkles), disabled = SparkleOff,
                },
                stationarySparkleInterval = {
                    type = "range", name = "Sparkle Interval (s)", order = 3, min = 0.02, max = 1, step = 0.01,
                    desc = "Seconds between sparkle emission ticks while stationary.",
                    disabled = SparkleOff,
                },
                stationarySparklesPerTick = {
                    type = "range", name = "Sparkles Per Tick", order = 4, min = 1, max = 6, step = 1,
                    desc = "How many sparkles to spawn each tick.",
                    disabled = SparkleOff,
                },
                stationarySparklePoolCount = {
                    type = "range", name = "Pool Size", order = 5, min = 6, max = 128, step = 1,
                    desc = "Number of sparkle frames to keep in the pool (performance and density).",
                    set = Setter(RefreshSparkles), disabled = SparkleOff,
                },
                stationarySparkleSizeMin = {
                    type = "range", name = "Min Size (px)", order = 6, min = 2, max = 64, step = 1,
                    disabled = SparkleOff,
                },
                stationarySparkleSizeMax = {
                    type = "range", name = "Max Size (px)", order = 7, min = 2, max = 128, step = 1,
                    disabled = SparkleOff,
                },
                stationarySparkleOffset = {
                    type = "range", name = "Offset (px)", order = 8, min = 0, max = 64, step = 1,
                    desc = "Max random offset from the cursor center for each sparkle.",
                    disabled = SparkleOff,
                },
                stationarySparkleLifetime = {
                    type = "range", name = "Lifetime (s)", order = 9, min = 0.05, max = 5, step = 0.05,
                    disabled = SparkleOff,
                },
                stationarySparkleTexture = {
                    type = "select", name = "Sparkle Texture", order = 10, values = textureValues,
                    set = Setter(RefreshSparkles), disabled = SparkleOff,
                },
                stationarySparkleDimMain = {
                    type = "toggle", name = "Dim Main Texture While Sparkling", order = 11,
                    desc = "Reduce the main cursor texture alpha while stationary sparkles are active.",
                    disabled = SparkleOff,
                },
                stationarySparkleMainAlpha = {
                    type = "range", name = "Main Texture Alpha (multiplier)", order = 12, min = 0, max = 1, step = 0.01,
                    desc = "When dimming is enabled, the main texture alpha is multiplied by this value.",
                    disabled = function() return not (P().stationarySparkleEnabled and P().stationarySparkleDimMain) end,
                },
            },
        },

        performanceHeader = { type = "header", name = "Performance & Compatibility", order = 50 },
        performance = {
            type = "group", name = "Performance", order = 51, inline = true,
            args = {
                lowCPUMode = {
                    type = "toggle", name = "Low CPU Mode", order = 1,
                    desc = "Update less often and use a shorter tail for better performance on older computers.",
                    set = Setter(RebuildTails),
                },
                lowCPUUpdateInterval = {
                    type = "range", name = "Low CPU Update Interval (ms)", order = 2, min = 20, max = 500, step = 10,
                    desc = "Milliseconds between updates when Low CPU Mode is active.",
                    disabled = LowCPUOff,
                },
                lowCPUTailLength = {
                    type = "range", name = "Low CPU Tail Length", order = 3, min = 5, max = 60, step = 1,
                    desc = "Number of tail segments when Low CPU Mode is active.",
                    set = Setter(RebuildTails), disabled = LowCPUOff,
                },
                autoDisableLowFPS = {
                    type = "toggle", name = "Auto Disable on Low FPS", order = 5,
                    desc = "Automatically disable CursorGlow or switch to Low CPU Mode when framerate stays low, and restore it once framerate recovers.",
                    set = Setter(UpdateFPSWatcher),
                },
                lowFPSThreshold = {
                    type = "range", name = "Low FPS Threshold", order = 6, min = 10, max = 120, step = 1,
                    desc = "FPS threshold for the automatic fallback.",
                    disabled = FPSOff,
                },
                lowFPSFallback = {
                    type = "select", name = "Low FPS Fallback Mode", order = 7,
                    desc = "Choose what happens when FPS is low.",
                    values = { disable = "Disable CursorGlow", lowcpu = "Switch to Low CPU Mode" },
                    set = Setter(function() if fpsState then ExitFPSFallback() end end),
                    disabled = FPSOff,
                },
            },
        },
    },
}

-- Initialization

function CursorGlow:OnInitialize()
    self.db       = AceDB:New("CursorGlowDB", profileDefaults, true)
    self.dbChar   = AceDB:New("CursorGlowCharDB", charDefaults, true)
    self.dbGlobal = AceDB:New("CursorGlowGlobalDB", globalDefaults, true)

    -- Pick the profile before callbacks exist so this does not trigger a refresh
    if self.dbGlobal.global.profileEnabled then
        self.db:SetProfile("Global")
    elseif self.dbChar.char.lastSelectedProfile then
        self.db:SetProfile(self.dbChar.char.lastSelectedProfile)
    else
        self.db:SetProfile(CharacterProfileName())
    end

    if type(self.db.profile.minimap) ~= "table" then
        self.db.profile.minimap = { hide = false }
    end
    icon:Register(ADDON_NAME, minimapButton, self.db.profile.minimap)

    AceConfig:RegisterOptionsTable(ADDON_NAME, options)
    AceConfigDialog:SetDefaultSize(ADDON_NAME, 900, 800)
    local _, categoryID = AceConfigDialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)
    if categoryID ~= nil then
        self._settingsCategoryID = categoryID
    end

    local profilesOptions = AceDBOptions:GetOptionsTable(self.db)
    AceConfig:RegisterOptionsTable("CursorGlow Profiles", profilesOptions)
    AceConfigDialog:AddToBlizOptions("CursorGlow Profiles", "Profiles", ADDON_NAME)

    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied",  "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset",   "OnProfileChanged")

    self:RegisterChatCommand("cursorglow", "OpenSettings")

    inCombat = UnitAffectingCombat("player") and true or false
    self:ApplySettings()
end

-- Events

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if not CursorGlow.db then return end

    if event == "GLOBAL_MOUSE_DOWN" then
        if arg1 == "LeftButton" then
            TriggerExplosion()
        end
        TriggerRipple(arg1)
    elseif event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
        UpdateAddonVisibility()
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
        UpdateAddonVisibility()
    else
        -- PLAYER_ENTERING_WORLD or ZONE_CHANGED_NEW_AREA
        inCombat = UnitAffectingCombat("player") and true or false
        ResetMotionState()
        ResetTails()
        ClearIdleSparkles(true)
        UpdateAddonVisibility()
    end
end)

-- Per frame update

local lowCPUAcc = 0

-- Counts horizontal direction reversals. Enough long swings inside the window starts a shake.
local function UpdateShake(dxUI, now, p)
    local cfg = SHAKE_PROFILES[p.shakeSensitivity] or SHAKE_PROFILES.medium
    local dist = abs(dxUI)
    if dist < 0.5 then return end
    local sign = (dxUI > 0) and 1 or -1

    if shakeLastSign == 0 or sign == shakeLastSign then
        shakeLastSign = sign
        shakeTravel = shakeTravel + dist
        return
    end

    -- Direction reversed: only count it if the previous swing was long enough
    if shakeTravel >= cfg.travel then
        shakeTimes[#shakeTimes + 1] = now
    end
    shakeLastSign = sign
    shakeTravel = dist

    while shakeTimes[1] and (now - shakeTimes[1]) > SHAKE_WINDOW do
        table.remove(shakeTimes, 1)
    end

    if #shakeTimes >= cfg.reversals and now >= shakeCooldownEnd then
        shakeStart = now
        shakeCooldownEnd = now + (tonumber(p.shakeDuration) or 1.2) + (tonumber(p.shakeCooldown) or 1.5)
        for i = #shakeTimes, 1, -1 do shakeTimes[i] = nil end
    end
end

-- 0 when no shake is active, ramps to 1 fast, holds, then eases back to 0
local function ShakeEnvelope(now, p)
    local duration = max(tonumber(p.shakeDuration) or 1.2, 0.2)
    local t = (now - shakeStart) / duration
    if t < 0 or t >= 1 then return 0 end
    if t < 0.15 then return t / 0.15 end
    if t < 0.6 then return 1 end
    return 1 - (t - 0.6) / 0.4
end


-- Returns true while mouselook is hiding the glow. Fades out, then comes back instantly with fresh state.
local function HandleMouselook(p, elapsed)
    if p.hideWhileMouselooking and IsMouselooking and IsMouselooking() then
        if not wasMouselooking then
            wasMouselooking = true
            ClearIdleSparkles(true)
            zzzFont:Hide()
        end
        local fadeTime = tonumber(p.mouselookFadeTime) or 0.15
        if fadeTime <= 0 then
            mouselookAlpha = 0
        else
            mouselookAlpha = max(0, mouselookAlpha - elapsed / fadeTime)
        end
        frame:SetAlpha(mouselookAlpha)
        return true
    elseif wasMouselooking then
        wasMouselooking = false
        mouselookAlpha = 1
        frame:SetAlpha(1)
        ResetMotionState()
        ResetTails()
    end
    return false
end

-- Draws only the shake boost while the glow is otherwise hidden
local function DrawPassiveShake(p, x, y, shakeE)
    if shakeE > 0 then
        local s = max((tonumber(p.shakeBoostSize) or 256) * shakeE, 1)
        texture:SetVertexColor(mainR, mainG, mainB, 1)
        texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        texture:SetSize(s, s)
        texture:SetAlpha(tonumber(p.opacity) or 1)
        if not texture:IsShown() then texture:Show() end
    elseif texture:IsShown() then
        texture:Hide()
    end
end

-- Returns the current main color, animated when Color Cycling is on
local function ComputeCycleColor(p, now)
    if not p.colorCycleEnabled then
        return mainR, mainG, mainB
    end
    local cycleSpeed = tonumber(p.colorCycleSpeed) or 0.25
    local cr, cg, cb
    if p.colorCycleMode == "breathe" then
        local k = (sin(now * cycleSpeed * TWO_PI) + 1) / 2
        local sr, sg, sb = UnpackColor(p.colorCycleSecondColor, 1, 0.2, 0.8)
        cr, cg, cb = ResolveColor(baseR + (sr - baseR) * k, baseG + (sg - baseG) * k, baseB + (sb - baseB) * k)
    else
        cr, cg, cb = ResolveColor(HSVtoRGB((now * cycleSpeed) % 1, 1, 1))
    end
    texture:SetVertexColor(cr, cg, cb, 1)
    return cr, cg, cb
end

-- Damped spring integrated in small fixed steps for stability. Returns glow x, y and whether it is still settling.
local function UpdateElastic(p, x, y, elapsed)
    if not p.elasticEnabled then
        glowX = nil
        return x, y, false
    end
    if not glowX then
        glowX, glowY, glowVX, glowVY = x, y, 0, 0
    end
    local k = Clamp(p.elasticStiffness or 150, 10, 1000)
    local bounce = Clamp(p.elasticBounciness or 0.35, 0, 0.9)
    local damping = 2 * sqrt(k) * (1 - bounce)
    local remaining = min(elapsed, 0.25)
    while remaining > 0 do
        local h = min(remaining, 1 / 120)
        glowVX = glowVX + (k * (x - glowX) - damping * glowVX) * h
        glowVY = glowVY + (k * (y - glowY) - damping * glowVY) * h
        glowX = glowX + glowVX * h
        glowY = glowY + glowVY * h
        remaining = remaining - h
    end
    local ox, oy = x - glowX, y - glowY
    if (ox * ox + oy * oy) < 0.25 and (glowVX * glowVX + glowVY * glowVY) < 25 then
        glowX, glowY, glowVX, glowVY = x, y, 0, 0
        return x, y, false
    end
    return glowX, glowY, true
end

local function DrawMainTexture(p, gx, gy, size, opacity, shakeE, now, scale, elapsed)
    local bounceY = 0
    if p.bounceEnabled then
        bounceY = sin(now * (p.bounceSpeed or 2) * TWO_PI) * (p.bounceAmplitude or 12) / scale
    end

    local alpha = opacity
    if shakeE <= 0 and p.stationarySparkleEnabled and p.stationarySparkleDimMain and stillTime > 0 then
        alpha = opacity * (p.stationarySparkleMainAlpha or 0.6)
    end

    texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", gx, gy + bounceY)
    texture:SetSize(size, size)
    texture:SetAlpha(alpha)
    if not texture:IsShown() then texture:Show() end

    if p.rotationEnabled then
        local angle = ((CursorGlow.rotationAngle or 0) + (p.rotationSpeed or 30) * DEG_TO_RAD * elapsed) % TWO_PI
        CursorGlow.rotationAngle = angle
        texture:SetRotation(angle)
    end
end

local function UpdateTails(p, tx, ty, tailMoving, tailSize, opacity, now, cr, cg, cb, elapsed)
    if tailMoving then
        tailStillTime = 0
    else
        tailStillTime = tailStillTime + elapsed
    end

    if not (p.enableTail and numTailsActive > 0) then
        if tailsDrawn then ResetTails() end
        return
    end

    ctxNow, ctxOp = now, opacity
    if p.colorCycleEnabled and p.colorCycleTail then
        ctxR, ctxG, ctxB = cr, cg, cb
    else
        ctxR, ctxG, ctxB = mainR, mainG, mainB
    end

    if tailMoving then
        ctxStyle   = p.tailEffectStyle or "classic"
        ctxFade    = max(tonumber(p.tailParticleSpeed) or 0.5, 0.05)
        ctxScatter = tonumber(p.tailParticleScatter) or 6
        ctxWobble  = tonumber(p.tailParticleWobble) or 5
        ctxSpacing = tonumber(p.tailSpacing) or 10
        ctxTaper   = p.tailTaper and true or false
        PushTails(tx, ty)
        DrawTails(tailSize)
    elseif tailsDrawn then
        if tailStillTime >= 1 then
            ResetTails()
        else
            FadeTails(tailSize, tailStillTime)
        end
    end
end

local function UpdateIdleExtras(p, moving, x, y, scale, now, elapsed)
    if not moving and p.stationarySparkleEnabled then
        sparkleAcc = sparkleAcc + elapsed
        if sparkleAcc >= (p.stationarySparkleInterval or 0.15) then
            sparkleAcc = 0
            for _ = 1, (p.stationarySparklesPerTick or 1) do
                SpawnIdleSparkle(x, y, scale)
            end
        end
    end

    if p.idleIndicatorEnabled and stillTime > (p.idleThreshold or 60) then
        zzzFont:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y + 30 + sin(now * 2) * 5)
        zzzFont:SetAlpha(0.5 + 0.5 * sin(now * 4))
        if not zzzFont:IsShown() then zzzFont:Show() end
    elseif zzzFont:IsShown() then
        zzzFont:Hide()
    end
end

local function OnUpdate(_, elapsed)
    local db = CursorGlow.db
    if not db then return end
    local p = db.profile

    -- Low CPU Mode: batch frames and run at the configured interval
    if p.lowCPUMode or fpsLowCPU then
        lowCPUAcc = lowCPUAcc + elapsed
        local interval = (tonumber(p.lowCPUUpdateInterval) or 100) / 1000
        if lowCPUAcc < interval then return end
        elapsed = lowCPUAcc
        lowCPUAcc = 0
    else
        lowCPUAcc = 0
    end
    if elapsed <= 0 then elapsed = 0.0001 end

    if HandleMouselook(p, elapsed) then return end

    local scale = UIParent:GetEffectiveScale()
    local rawX, rawY = GetCursorPosition()
    if rawX == 0 and rawY == 0 then return end
    local x, y = rawX / scale, rawY / scale

    if not prevX then prevX, prevY = rawX, rawY end
    local dX, dY = rawX - prevX, rawY - prevY
    local distance = (dX == 0 and dY == 0) and 0 or sqrt(dX * dX + dY * dY)
    local moving = distance > 0
    prevX, prevY = rawX, rawY

    local decay = 2048 ^ -elapsed
    speed = min(decay * speed + (1 - decay) * (distance / elapsed), 1024)

    local now = GetTime()

    -- Shake to Find
    local shakeE = 0
    if p.shakeEnabled then
        if moving then
            UpdateShake(dX / scale, now, p)
        end
        shakeE = ShakeEnvelope(now, p)
    end

    if glowPassive then
        DrawPassiveShake(p, x, y, shakeE)
        return
    end

    local opacity = tonumber(p.opacity) or 1
    local minSize = p.minSize or 16
    local maxSize = p.maxSize or 175

    -- Base size
    local size
    if p.staticSizeEnabled then
        size = maxSize
    elseif moving then
        size = max(min(speed / 6, maxSize), minSize)
    else
        size = minSize
    end

    -- Stillness and pulse
    local pulsing = false
    if moving then
        stillTime = 0
        pulseTime = 0
        ClearIdleSparkles()
    else
        stillTime = stillTime + elapsed
        if p.pulseEnabled and stillTime >= 0.5 then
            pulseTime = pulseTime + elapsed
            local pMin, pMax = p.pulseMinSize or 50, p.pulseMaxSize or 100
            local prog = (sin(pulseTime * (p.pulseSpeed or 1) * TWO_PI) + 1) / 2
            size = pMin + (pMax - pMin) * prog
            pulsing = true
        end
    end

    -- Tails keep the normal size, only the main glow gets the shake boost
    local tailSize = size
    if shakeE > 0 then
        local boost = tonumber(p.shakeBoostSize) or 256
        if boost > size then
            size = size + (boost - size) * shakeE
        end
    end

    local cr, cg, cb = ComputeCycleColor(p, now)
    local gx, gy, settling = UpdateElastic(p, x, y, elapsed)

    local showWhenStill = p.operationMode == "enabledAlwaysOnCursor"
    if moving or pulsing or showWhenStill or settling or shakeE > 0 then
        DrawMainTexture(p, gx, gy, size, opacity, shakeE, now, scale, elapsed)
    elseif texture:IsShown() then
        texture:Hide()
    end

    if p.elasticEnabled and p.elasticTailFollowsGlow then
        UpdateTails(p, gx, gy, moving or settling, tailSize, opacity, now, cr, cg, cb, elapsed)
    else
        UpdateTails(p, x, y, moving, tailSize, opacity, now, cr, cg, cb, elapsed)
    end

    UpdateIdleExtras(p, moving, x, y, scale, now, elapsed)
end

frame:SetScript("OnUpdate", OnUpdate)
