local ns = select(2, ...)
local Type, Version = "GarrisonBackgroundGroup", 1
local AceGUI = ns.AceGUI
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local name = "CompanionsTracker" .. Type .. AceGUI:GetNextWidgetNum(Type)

	--- @type Frame
	local frame = CreateFrame("Frame", name, UIParent)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")




	-- Create the textures
	local TL = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
    TL:SetAtlas("GarrLanding-lowerleft", true)
	TL:SetTexCoord(0, 1, 1, 0)
	TL:SetPoint("TOPLEFT", frame, -6, 7)
    local TR = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
    TR:SetAtlas("GarrLanding-lowerright", true)
	TR:SetTexCoord(0, 1, 1, 0)
    TR:SetPoint("TOPRIGHT",frame, 6, 7)
    local BL = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
    BL:SetAtlas("GarrLanding-lowerleft", true)
    BL:SetPoint("BOTTOMLEFT",frame, -6, -7)
    local BR = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
    BR:SetAtlas("GarrLanding-lowerright", true)
    BR:SetPoint("BOTTOMRIGHT",frame, 6, -7)
    local T = frame:CreateTexture(nil, "BACKGROUND")
    T:SetAtlas("GarLanding-Bottom", true)
	T:SetTexCoord(0, 1, 1, 0)
    T:SetPoint("TOPLEFT", TL, "TOPRIGHT", 0, -2)
    T:SetPoint("TOPRIGHT", TR, "TOPLEFT", 0, -2)
    local B = frame:CreateTexture(nil, "BACKGROUND")
    B:SetAtlas("GarLanding-Bottom", true)
    B:SetPoint("BOTTOMLEFT", BL, "BOTTOMRIGHT", 0, 2)
    B:SetPoint("BOTTOMRIGHT", BR, "BOTTOMLEFT", 0, 2)
    local L = frame:CreateTexture(nil, "BACKGROUND")
    L:SetAtlas("GarLanding-Left", true)
    L:SetPoint("TOPLEFT", TL, "BOTTOMLEFT", 2, 0)
    L:SetPoint("BOTTOMLEFT", BL, "TOPLEFT", 2, 0)
    local R = frame:CreateTexture(nil, "BACKGROUND")
    R:SetAtlas("GarLanding-Right", true)
    R:SetPoint("TOPRIGHT", TR, "BOTTOMRIGHT", -1, 0)
    R:SetPoint("BOTTOMRIGHT", BR, "TOPRIGHT", -1, 0)
	local Middle = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
	Middle:SetAtlas("GarrLanding-MiddleTile", true)
	Middle:SetHorizTile(true)
	Middle:SetVertTile(true)
	Middle:SetPoint("TOPLEFT", frame, 25, -25)
	Middle:SetPoint("BOTTOMRIGHT", frame, -25, 25)

	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", frame, 30, -25)
	content:SetPoint("BOTTOMRIGHT", frame, 30, 25)

	--- @class GarrisonBackgroundGroup : AceGUIContainer
	local widget = {
		frame     = frame,
		content   = content,
		type      = Type,
		["OnAcquire"] = function(self)
			self:SetWidth(300)
			self:SetHeight(100)
		end,
		["LayoutFinished"] = function(self, width, height)
			if self.noAutoHeight then return end
			self:SetHeight(height or 0)
		end,
		["OnWidthSet"] = function(self, width)
			local content = self.content
			content:SetWidth(width)
			content.width = width
		end,
		["OnHeightSet"] = function(self, height)
			local content = self.content
			content:SetHeight(height)
			content.height = height
		end
	}

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
