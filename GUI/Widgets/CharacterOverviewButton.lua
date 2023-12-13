local ns = select(2, ...)
--- @type AceGUI-3.0
local AceGUI = ns.AceGUI
local Type, Version = "CharacterOverviewFrame", 1
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
    PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
    self:Fire("OnClick")
end

local function Constructor()
    local name = "CharacterOverviewButton" .. AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Button", name, UIParent)
    frame:Hide()
    frame:EnableMouse(true)
    frame:SetSize(174, 96)
    frame:SetFrameStrata("MEDIUM")
    frame:SetScript("OnEnter", Frame_OnEnter)
    frame:SetScript("OnLeave", Frame_OnLeave)
	frame:SetScript("OnMouseDown", Frame_OnMouseDown)
	frame:SetScript("OnMouseUp", Frame_OnMouseUp)

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", 5, -5)
    bg:SetPoint("BOTTOMRIGHT", -5, 5)
    bg:SetAtlas("spec-thumbnail-druid-restoration", true, "TRILINEAR")


    local title = frame:CreateFontString(nil, "OVERLAY", "QuestTitleFontBlackShadow")
    title:SetSize(150, 0)
    title:ClearAllPoints()
    title:SetPoint("TOP", 0, -15)

    local subText = {}
    local anchor = title
    for i = 1, 3 do
        local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetSize(150, 0)
        text:ClearAllPoints()
        text:SetPoint("TOP", anchor, "BOTTOM", 0, -5)
        text:SetText("Test")
        subText[i] = text
        anchor = text
    end


    local overlay = frame:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
    overlay:SetTexCoord(0.00195313, 0.34179688, 0.42871094, 0.5224604)
    overlay:SetAllPoints()

    local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetBlendMode("ADD")
    highlight:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
    highlight:SetTexCoord(0.34570313, 0.68554688, 0.33300781, 0.42675781)
    highlight:SetAllPoints()

    local depressed = frame:CreateTexture(nil, "HIGHLIGHT")
    depressed:SetBlendMode("BLEND")
    depressed:SetTexture("Interface\\EncounterJournal\\UI-EncounterJournalTextures")
    depressed:SetTexCoord(0.00195313, 0.34179688, 0.33300781, 0.42675781)
    frame:SetPushedTexture(depressed)
    frame:SetHighlightTexture(highlight)

    local widget = {
        frame = frame,
        type = Type,
        title = title,
        subText = subText,
        OnAcquire = function(self)
            self:ClearAllText()
        end,
        ["SetTitle"] = function(self, text)
            self.title:SetText(text)
        end,
        ["SetLineText"] = function(self, line, text)
            if(self.subText[line]) then
                self.subText[line]:SetText(text)
            end
        end,
        ["ClearAllText"] = function(self)
            self.title:SetText("")
            for _, text in ipairs(self.subText) do
                text:SetText("")
            end
        end,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)