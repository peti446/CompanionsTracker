local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @class CompanionsTrackerUtils
local Utils = ns.Utils

--- @type CompanionsTrackerConfig
local Config = ns.Config

function CompanionsTracker:OnInitialize()
    Config:Init()
    self:RegisterOptionsGUI()

    -- Register Global Events
    self:RegisterEvent("ADDON_LOADED")

    Utils:DebugPrint("Addon Initializing")
end

function CompanionsTracker:OnEnable()
    Utils:DebugPrint("Addon Enabling")
    self:InitMinimapIcon()
    self.Mixins.ExpansionLandingPageMixin:Embed()

    local module = self:GetModule("GarrisonDataCollector") --[[@as GarrisonDataCollectorModule]]
    module:Enable()
    for _, data in ipairs(ns.Constants.GarrionData) do
        module:RegisterExpansion({
            garrisonType = data.garrisonID,
            followersID = data.followerTypes
        })
    end
end

function CompanionsTracker:OnDisable()
    Utils:DebugPrint("Addon disabling")


    self:DisableModule("GarrisonDataCollector")
end