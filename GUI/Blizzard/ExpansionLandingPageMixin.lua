local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @type AceGUI-3.0
local AceGUI = ns.AceGUI

--- @Type CompanionsTrackerUtils
local Utils = ns.Utils

--- @type CompanionsTrackerConstants
local Constants = ns.Constants

local L = ns.L

--- @class ExpansionLandingPageMixin
local ExpansionLandingPageMixin = {
    RequieredAddon = "Blizzard_GarrisonUI"
}
CompanionsTracker.Mixins.ExpansionLandingPageMixin = ExpansionLandingPageMixin


--- Embed all necesary frames to the ExpansionLandingPage to show garrison landing page later
function ExpansionLandingPageMixin:Embed()
    CompanionsTracker:HookScript(ExpansionLandingPage, "OnShow", ExpansionLandingPageMixin.OnShow)
    CompanionsTracker:HookScript(ExpansionLandingPage, "OnHide", ExpansionLandingPageMixin.OnHide)
    CompanionsTracker:SecureHook("ShowGarrisonLandingPage", ExpansionLandingPageMixin.GarrisonLandingPageShown)
end

--- Call back to be called when a button value is changed
--- @param self ArchaeologyCheckButton
--- @param _event string
--- @param checked boolean
local function OnExpanionTabValueChanged(self, _event, checked)
    local expansionID = self:GetUserData("ExpansionID")
    if(checked) then
        Utils:OpenGarrisonWindow(expansionID)
    else
        Utils:CloseAllGarisonWindows()
    end
end

--- Call back to be called when the GarrisonLandingPage is shown
--- @param pageID number
function ExpansionLandingPageMixin.GarrisonLandingPageShown(pageID)
    if(not ExpansionLandingPageMixin.UI) then
        return
    end

    for _, child in pairs(ExpansionLandingPageMixin.UI.children) do
        child:SetChecked(child:GetUserData("ExpansionID") == pageID)
    end
end

local function OnMouseEnter(self)
    local expansionID = self:GetUserData("ExpansionID")
    --- @type GarrionData
    local data = Utils:GarrisonDataByID(expansionID)

    local currentTime = time()
    local numMissionsAvailable = 0
    local numMissionsInProgress = 0
    local numMissionsCompleted = 0
    for _, followerType in ipairs(data.followerTypes) do
        local availableMissionsData = C_Garrison.GetAvailableMissions(followerType) or {}
        for _, missionData in ipairs(availableMissionsData) do
            if(not missionData.inProgress and missionData.canStart) then
                numMissionsAvailable = numMissionsAvailable + 1
            end
        end

        for _, missionData in ipairs(C_Garrison.GetInProgressMissions(followerType) or {}) do
            if(missionData.missionEndTime > currentTime) then
                numMissionsInProgress = numMissionsInProgress + 1
            end
        end

        numMissionsCompleted = numMissionsCompleted + #C_Garrison.GetCompleteMissions(followerType)
    end

    GameTooltip:SetOwner(self.frame, "ANCHOR_RIGHT", 0, -75)
    GameTooltip:SetText(Utils:ColorStr(data.displayName, data.buttonBackgroundColor))

    if(numMissionsAvailable > 0) then
        GameTooltip:AddLine(L["Available missions: %s"]:format(Utils:ColorStr(tostring(numMissionsAvailable), 'FFAE5700')))
    else
        GameTooltip:AddLine(L["No available missions."])
    end

    if(numMissionsInProgress > 0) then
        GameTooltip:AddLine(L["In progress missions: %s"]:format(Utils:ColorStr(tostring(numMissionsInProgress), 'FFAE5700')))
    else
        GameTooltip:AddLine(L["No missions in progress"])
    end

    if(numMissionsCompleted > 0) then
        GameTooltip:AddLine(L["Completed missions: %s"]:format(Utils:ColorStr(tostring(numMissionsCompleted), 'FFAE5700')))
    end

    GameTooltip:Show()
end

--- Call back to be called when the ExpansionLandingPage is shown
function ExpansionLandingPageMixin:OnShow()
    ExpansionLandingPage:SetScale(0.95)
    --- @class AceGUISimpleGroup : AceGUIWidget
    --- @field frame Frame
    local group = AceGUI:Create("SimpleGroup")
    group:SetParent(ExpansionLandingPage)
    group:ClearAllPoints()
    group:SetHeight(400)
    group:SetWidth(100)
    group:SetPoint("TOPLEFT", ExpansionLandingPage, "TOPRIGHT", 0, -75)
    group:SetLayout("List")
    group.frame:Show()

    for _, data in ipairs(Constants.GarrionData) do
        local id = data.garrisonID
        if(C_Garrison.HasGarrison(id)) then
            --- @class ArchaeologyCheckButton
            --- @diagnostic disable-next-line: param-type-mismatch
            local currentTab = AceGUI:Create("ArchaeologyCheckButton")
            currentTab:SetImage(data.iconPath)
            if(data.buttonBackgroundColor) then
                currentTab:SetBackgroundColor(unpack(data.buttonBackgroundColor))
            end
            currentTab:SetUserData("ExpansionID", id)
            currentTab:SetCallback("OnValueChanged", OnExpanionTabValueChanged)
            currentTab:SetCallback("OnEnter", OnMouseEnter)
            currentTab:SetCallback("OnLeave", function()
                GameTooltip:Hide()
            end)
            group:AddChild(currentTab)
        end
    end

    --- @class AceGUISimpleGroup
    --- @field children ArchaeologyCheckButton[]
    ExpansionLandingPageMixin.UI = group
    RunNextFrame(function()
        ExpansionLandingPageMixin.UI:DoLayout()
    end)
end

--- Call back to be called when the ExpansionLandingPage is hidden, to clear up the UI
function ExpansionLandingPageMixin:OnHide()
    if(not ExpansionLandingPageMixin.UI) then
        return
    end
    -- Release the UI back to AceGUI
    ExpansionLandingPageMixin.UI:ReleaseChildren()
    ExpansionLandingPageMixin.UI:Release()
    ExpansionLandingPageMixin.UI = nil
end