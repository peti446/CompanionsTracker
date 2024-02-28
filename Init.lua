local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @type CompanionsTrackerUtils
local Utils = ns.Utils

---@type CompanionsTrackerConstants
local Constants = ns.Constants

--- @type CompanionsTrackerConfig
local Config = ns.Config

function CompanionsTracker:OnInitialize()
    Config:Init()
    self:RegisterOptionsGUI()

    -- Register Global Events
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("GARRISON_UPDATE")

    Utils:DebugPrint("Addon Initializing")
end

function CompanionsTracker:OnEnable()
    Utils:DebugPrint("Addon Enabling")
    self:InitMinimapIcon()
    self.Mixins.ExpansionLandingPageMixin:Embed()
    self:RegisterMessage(self.Events.GarrionDataUpdated)

    local module = self:GetModule("Notifications") --[[@as NotificationsModule]]
    if(Config.db.global.notifications.enabled) then
        module:Enable()
    else
        module:Disable()
    end

    -- Set the state for each character/expansion
    for id, data in pairs(Config.db.global.notifications.expansions) do
        for name, enabled in pairs(data) do
            if(name ~= "enabled") then
                module:SetCharacterState(name, id, enabled)
            else
                module:SetExpansionEnabled(id, enabled)
            end
        end
    end

    -- Register all characters
    for name, data in pairs(Config.db.global.GarrisonsData or {}) do
        for _, constData in ipairs(Constants.GarrionData) do
            if(name ~= Utils:GetCurrentCharacterServerName() and type(data[constData.garrisonID]) == "table") then
                module:RegisterCharacter(name, constData.garrisonID, data[constData.garrisonID], data.classID)
            end
        end
    end
end

function CompanionsTracker:OnDisable()
    Utils:DebugPrint("Addon disabling")


    self:DisableModule("GarrisonDataCollector")
    self:DisableModule("Notifications")
end