local ns = select(2, ...)
--- @type AceGUI-3.0
local AceGUI = ns.AceGUI
local Type, Version = "ArchaeologyCheckButton", 1

if not AceGUI or (AceGUI:GetWidgetCount(Type) or 0) >= Version then return end
local function Frame_OnEnter(frame)
    frame.obj:Fire("OnEnter")
end

local function Frame_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function Frame_OnMouseDown(frame)
end

local function Frame_OnMouseUp(frame)
	local self = frame.obj
    self:ToggleChecked()
    if self.checked then
        PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
    else
        PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
    end
    self:Fire("OnValueChanged", self.checked)
end

--- @class ArchaeologyCheckButton : AceGUIWidget
local methods =
{
	["OnAcquire"] = function(self)
        self.frame:Show()
        self:SetChecked(false)
    end,
    ["GetChecked"] = function(self)
        return self.checked
    end,
    ["SetChecked"] = function(self, checked)
        self.checked = checked
        self.frame:SetWidth(checked and 55 or 45)
        self.frame:SetHeight(45)

        if(checked) then
            self.highlight:SetTexCoord(0.85546875, 0.97851563, 0.00390625, 0.22656250)
            self.background:SetTexCoord(0.85546875, 0.97851563, 0.00390625, 0.22656250)
        else
            self.highlight:SetTexCoord(0.21484375, 0.30859375, 0.56250000, 0.78515625)
            self.background:SetTexCoord(0.21484375, 0.30859375, 0.56250000, 0.78515625)
        end
    end,
    ["ToggleChecked"] = function(self)
        local value = self:GetChecked()
        self:SetChecked(not value)
    end,
    ["SetImage"] = function (self, path, ...)
		local image = self.image
		image:SetTexture(path)

		if image:GetTexture() then
			local n = select("#", ...)
			if n == 4 or n == 8 then
				image:SetTexCoord(...)
			else
				image:SetTexCoord(0, 1, 0, 1)
			end
		end
    end,
    ["SetBackgroundColor"] = function(self, r, g, b, a)
        a = a or 1
        self.background:SetVertexColor(r, g, b, a)
    end
}


local function Constructor()
    local name = "AceGUI30" .. Type .. AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Button", name, UIParent)
    frame:Hide()
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", Frame_OnEnter)
    frame:SetScript("OnLeave", Frame_OnLeave)
	frame:SetScript("OnMouseDown", Frame_OnMouseDown)
	frame:SetScript("OnMouseUp", Frame_OnMouseUp)

	local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Archeology\\ArchaeologyParts")
    background:SetAllPoints(frame, true)

	local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetTexture("Interface\\Archeology\\ArchaeologyParts")
	highlight:SetBlendMode("ADD")
    highlight:SetVertexColor(1, 1, 1, 0.2)
    highlight:SetAllPoints(frame, true)

    local image = frame:CreateTexture(nil, "ARTWORK")
    image:SetWidth(25)
    image:SetHeight(25)
    image:SetPoint("CENTER", background, "CENTER", -6, 0)

    --- @class ArchaeologyCheckButton : AceGUIWidget
    local widget = {
        frame = frame,
        highlight = highlight,
        background = background,
        image = image,
		type  = Type,
        checked = false
    }

	for method, func in pairs(methods) do
        --- @diagnostic disable-next-line: assign-type-mismatch
		widget[method] = func
    end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)