local ns = select(2, ...)
--- @type AceGUI-3.0
local AceGUI = ns.AceGUI
local Type, Version = "BlizzardGarrisonLandingPageReportMissionTemplate", 1
if not AceGUI or (AceGUI:GetWidgetCount(Type) or 0) >= Version then return end

local function Frame_OnEnter(frame)
    frame.obj:Fire("OnEnter")
end

local function Frame_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function Frame_OnClick(frame)
    frame.obj:Fire("OnClick")
    frame.GetElementData = function(self) return self.obj:GetElementData() end
    GarrisonLandingPageReportMission_OnClick(frame, '')
end

--- @class BlizzardGarrisonLandingPageReportMissionTemplate : AceGUIWidget
--- @field frame Button
local methods = {}


function methods:OnAcquire()
    self.frame:Show()
end

function methods:GetElementData()
    return self.data
end

--- Sets the information of the mission
---@param info table
function methods:SetMissionInfo(info)
    self.data = info

    if(info.inProgress) then
        GarrisonLandingPageReportList_InitButton(self.frame, info)
    else
        GarrisonLandingPageReportList_InitButtonAvailable(self.frame, info)
    end
end

local function Constructor()
    if(not C_AddOns.IsAddOnLoaded('Blizzard_GarrisonUI')) then
        C_AddOns.LoadAddOn('Blizzard_GarrisonUI')
    end

    local name = "CompanionsTracker_" .. AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Button", name, UIParent, "GarrisonLandingPageReportMissionTemplate") --[[@as Button]]
    frame:Hide()
    frame:SetWidth(425)
    frame:EnableMouse(true)
    frame:SetFrameStrata("MEDIUM")
    frame:SetScript("OnEnter", Frame_OnEnter)
    frame:SetScript("OnLeave", Frame_OnLeave)
    frame:SetScript("OnClick", Frame_OnClick)

    --- @type BlizzardGarrisonLandingPageReportMissionTemplate
    local widget = {
        frame = frame,
        type = Type,
    }

    for method, func in pairs(methods) do
        widget[method] = func
    end

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)