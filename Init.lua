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
end

function CompanionsTracker:OnDisable()
    Utils:DebugPrint("Addon disabling")
end