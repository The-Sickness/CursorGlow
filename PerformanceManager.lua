-- Handles adaptive performance controls for CursorGlow

PerformanceManager = {} -- Global variable

PerformanceManager.defaults = {
    performanceEnabled = true,
    autoPerformanceMode = true,
    performanceFPSThreshold = 30,
    maxParticles = 60,
    maxFPS = 120,
}

local inPerformanceMode = false

function PerformanceManager:ShouldReduceEffects()
    -- Wait until CursorGlow is defined and db is ready
    if not CursorGlow or not CursorGlow.db or not CursorGlow.db.profile.performanceEnabled then return false end
    if CursorGlow.db.profile.autoPerformanceMode then
        local currentFPS = GetFramerate()
        local threshold = CursorGlow.db.profile.performanceFPSThreshold or 30
        inPerformanceMode = currentFPS < threshold
        return inPerformanceMode
    end
    return false
end

function PerformanceManager:GetRecommendedParticleCount()
    if self:ShouldReduceEffects() then
        return math.floor((CursorGlow.db.profile.maxParticles or 60) * 0.5)
    else
        return CursorGlow.db.profile.maxParticles or 60
    end
end