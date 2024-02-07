local ns = select(2, ...)
--- @type AceGUI-3.0
local AceGUI = ns.AceGUI
--- @type CompanionsTrackersEnums
local ConstantEnums = ns.Constants.Enums;
local Type, Version = "BlizzardGarrisonLandingPageReportShipmentStatusTemplate", 1
if not AceGUI or (AceGUI:GetWidgetCount(Type) or 0) >= Version then return end

local function Frame_OnEnter(frame)
    frame.obj:Fire("OnEnter")
    GarrisonLandingPageReportShipment_OnEnter(frame)
end

local function Frame_OnLeave(frame)
	frame.obj:Fire("OnLeave")
    GameTooltip:Hide();
end

local function Frame_OnClick(frame)
    frame.obj:Fire("OnClick")
end

--- @class BlizzardGarrisonLandingPageReportShipmentStatusTemplate : AceGUIWidget
--- @field frame GarrisonLandingPageReportShipmentStatusTemplate
local methods = {}

function methods:SetHeight(height)

end

function methods:SetWidth(width)

end

function methods:OnAcquire()
    self.frame:Show()

     ---@type GarrisonLandingPageReportShipmentStatusTemplate
    local shipmentFrame = self.frame
    shipmentFrame.Name:SetText("")
    shipmentFrame.Count:SetText("")
    shipmentFrame.Icon:Show()
    shipmentFrame.Border:Show()
    shipmentFrame.BG:Hide()
    shipmentFrame.Done:Hide()
    shipmentFrame.Swipe:SetCooldownUNIX(0, 0);

end

function methods:SetScale(number)
    self.frame:SetScale(number)
end

--- Sets the information of the mission
---@param shipmentType CompanionsTrackerShipmentType
---@param info table
function methods:SetShipmentInfo(shipmentType, info)
    self.data = info

    ---@type GarrisonLandingPageReportShipmentStatusTemplate
    local shipmentFrame = self.frame
    local applyMask = shipmentType ~= ConstantEnums.ShipmentTypes.SHIPMENT_TYPE_FOLLOWER

    if (applyMask) then
		SetPortraitToTexture(shipmentFrame.Icon, info.texture);
	else
		shipmentFrame.Icon:SetTexture(info.texture);
	end

	shipmentFrame.Name:SetText(info.name);
	shipmentFrame.buildingID = info.buildingID;
	shipmentFrame.containerID = info.containerID;
	shipmentFrame.plotID = info.plotID;
	shipmentFrame.shipmentType = shipmentType;
	if (info.shipmentsTotal) then
		if (shipmentType ~= ConstantEnums.ShipmentTypes.SHIPMENT_TYPE_TALENT) then
            ---@diagnostic disable-next-line: redundant-parameter
			shipmentFrame.Count:SetFormattedText(GARRISON_LANDING_SHIPMENT_COUNT, info.shipmentsReady, info.shipmentsTotal);
		end
		if ((info.shipmentsReady or 0) == info.shipmentsTotal) then
			shipmentFrame.Swipe:SetCooldownUNIX(0, 0);
			shipmentFrame.Done:Show();
			shipmentFrame.Border:Hide();
            shipmentFrame.BG:Hide();
		else
			shipmentFrame.BG:Show();
            shipmentFrame.Border:Show();
			shipmentFrame.Swipe:SetCooldownUNIX(info.creationTime, info.duration);
		end
	end
end

local function Constructor()
    if(not C_AddOns.IsAddOnLoaded('Blizzard_GarrisonUI')) then
        C_AddOns.LoadAddOn('Blizzard_GarrisonUI')
    end

    local name = "CompanionsTracker_" .. AceGUI:GetNextWidgetNum(Type)

    --- @type GarrisonLandingPageReportShipmentStatusTemplate
    local frame = CreateFrame("Button", name, UIParent, "GarrisonLandingPageReportShipmentStatusTemplate") --[[@as GarrisonLandingPageReportShipmentStatusTemplate]]
    frame:Hide()
    frame:EnableMouse(true)
    frame:SetFrameStrata("MEDIUM")
    frame:SetScript("OnEnter", Frame_OnEnter)
    frame:SetScript("OnLeave", Frame_OnLeave)
    frame:SetScript("OnClick", Frame_OnClick)

    --- @type BlizzardGarrisonLandingPageReportShipmentStatusTemplate
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