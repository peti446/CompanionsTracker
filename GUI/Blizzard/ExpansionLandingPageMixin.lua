local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @type AceGUI-3.0
local AceGUI = ns.AceGUI

--- @class ExpansionLandingPageMixin
local ExpansionLandingPageMixin = {
    RequieredAddon = "Blizzard_GarrisonUI"
}
CompanionsTracker.Mixins.ExpansionLandingPageMixin = ExpansionLandingPageMixin

--- @class GarrionData
--- @field imagePath string
--- @field backbroundColor table|nil
--- @field garrisonID number
local GarrionData = {
    {
        imagePath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\draenor_logo",
        backbroundColor = {1.0, 0.0, 0.0},
        garrisonID = Enum.GarrisonType.Type_6_0_Garrison,
    },
    {
        imagePath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\legion_logo",
        backbroundColor = {0.0, 1.0, 0.0},
        garrisonID = Enum.GarrisonType.Type_7_0_Garrison,
    },
    {
        imagePath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\bfa_logo",
        backbroundColor = {1, 1, 1},
        garrisonID = Enum.GarrisonType.Type_8_0_Garrison,
    },
    {
        imagePath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\shadowlands_logo",
        backbroundColor = {1.0, 0.47, 0.33},
        garrisonID = Enum.GarrisonType.Type_9_0_Garrison,
    },
}
-- Sad, this is because of Toshrael ):
table.sort(GarrionData, function(a, b) return a.garrisonID < b.garrisonID end)

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
    if(GarrisonLandingPage) then
        HideUIPanel(GarrisonLandingPage)
    end

    if(MajorFactionRenownFrame) then
        HideUIPanel(MajorFactionRenownFrame)
    end

    if(checked) then
        -- Needed as Shadowlands has some issues ):
        if(GarrisonLandingPage) then
            local subPanelsToHide = {"SoulbindPanel", "CovenantCallings", "ArdenwealdGardeningPanel"}
            for _, panelName in ipairs(subPanelsToHide) do
                local panel = GarrisonLandingPage[panelName]
                if(panel) then
                    if(expansionID == Enum.GarrisonType.Type_9_0_Garrison) then
                        panel:Show()
                    else
                        panel:Hide()
                    end
                end
            end
        end

        ShowGarrisonLandingPage(expansionID)
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

    for _, data in ipairs(GarrionData) do
        local id = data.garrisonID
        if(C_Garrison.GetGarrisonInfo(id) ~= nil) then
            --- @class ArchaeologyCheckButton
            --- @diagnostic disable-next-line: param-type-mismatch
            local currentTab = AceGUI:Create("ArchaeologyCheckButton")
            currentTab:SetImage(data.imagePath)
            if(data.backbroundColor) then
                currentTab:SetBackgroundColor(unpack(data.backbroundColor))
            end
            currentTab:SetUserData("ExpansionID", id)
            currentTab:SetCallback("OnValueChanged", OnExpanionTabValueChanged)
            group:AddChild(currentTab)
        end
    end

    --- @class AceGUISimpleGroup
    --- @field children ArchaeologyCheckButton[]
    ExpansionLandingPageMixin.UI = group
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