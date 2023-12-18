local ns = select(2, ...)
--- @type AceGUI-3.0
local AceGUI = ns.AceGUI
local Utils = ns.Utils
local Type, Version = "ExpansionOverviewFrame", 1
if not AceGUI or (AceGUI:GetWidgetCount(Type) or 0) >= Version then return end

--- @class ExpansionsOverviewFrame : AceGUIWidget
local WidgetMethods = {}


--- Gets the value from tab data
---@param self table
---@param value any
---@return {buttonIcon: string, buttonColor?: table, bgTexture: string, value: any, text: string, buttonRef: frame}|nil The tab data table or nill if nothing was found
local function GetTabDataFromValue(self, value)
    for _, tabData in pairs(self.tabsData) do
        if tabData.value == value then
            return tabData
        end
    end

    return nil
end


function WidgetMethods.OnAcquire(self)
    self.frame:SetParent(UIParent)
    self.frame:SetFrameStrata("MEDIUM")
    self.scrollFrame.frame:Show()

    self:ApplyStatus()
    self:SetTitle()
    self:SetTabsInfo({})
    self:Show()
end

function WidgetMethods.Show(self)
    self.frame:Show()
    self.buttonsFrameGroup.frame:Show()
end

function WidgetMethods.Hide(self)
    self.frame:Hide()
    self.buttonsFrameGroup.frame:Hide()
end

function WidgetMethods.SetTitle(self, title)
    self.frame:SetTitle(title)
end

function WidgetMethods.SetPortraitTexture(self, path)
    self.frame:SetPortraitTextureRaw(path)
end

local function OnCheckButtonValueChanged(button, _event, checked)
    --- @type ExpansionsOverviewFrame
    local self = button:GetUserData("self")
    local value = button:GetUserData("Value")

    -- Reset the state of all the other buttons
    local allButtons = self.buttonsFrameGroup.children;
    for _, b in pairs(allButtons) do
        b:SetChecked(b == button)
    end

    -- Update the content of the content and background
    -- Find in the data table the one with the value
    local tabData = GetTabDataFromValue(self, value)
    if tabData then
        self.expanionBackground:SetAtlas(tabData.bgTexture, true, "TRILINEAR")
        self.expansionTitle:SetText(tabData.text)
        self:SetPortraitTexture(tabData.buttonIcon)
        self:SetNavBarPath(tabData.value)
    end
    self.frame.obj:Fire("OnTabChanged", value)
    self.selectedTab = value
end

function WidgetMethods.SetSelectedTab(self, tabValue)
    local tabData = GetTabDataFromValue(self, tabValue)
    if tabData == nil then
        Utils:DebugPrint("Failed to find tab data for value: " .. tabValue)
        return
    end

    OnCheckButtonValueChanged(tabData.buttonRef, nil, true)
end

--- Sets the tab data for the widget
--- @param tabsData {buttonIcon: string, buttonColor?: table, bgTexture: string, value: any, text: string}[]
function WidgetMethods.SetTabsInfo(self, tabsData)
    self.buttonsFrameGroup:ReleaseChildren()
    if(self.tabsData) then
        for _, data in pairs(self.tabsData) do
            data.buttonRef = nil
        end
    end
    self.tabsData = tabsData

    for _, data in pairs(tabsData) do
        data.buttonRef = self:AddTab(data)
    end

    if(#self.tabsData >= 1) then
        self:SetSelectedTab(self.tabsData[1].value)
    end
    self.buttonsFrameGroup.frame:SetScale(1.35)
    RunNextFrame(function()
        self.buttonsFrameGroup:DoLayout()
    end)
end

--- Creates a tab for the widget
--- @param data {buttonIcon: string, buttonColor?: table, bgTexture: string, value: any, text: string}
--- @return ArchaeologyCheckButton the tab button created
function WidgetMethods.AddTab(self, data)
    --- @class ArchaeologyCheckButton
    local currentTab = AceGUI:Create("ArchaeologyCheckButton")
    currentTab:SetImage(data.buttonIcon)
    if(data.buttonColor) then
        currentTab:SetBackgroundColor(unpack(data.buttonColor))
    end
    currentTab:SetUserData("Value", data.value)
    currentTab:SetUserData("self", self)
    currentTab:SetCallback("OnValueChanged", OnCheckButtonValueChanged)
    self.buttonsFrameGroup:AddChild(currentTab)
    return currentTab
end

function WidgetMethods.SetStatusTable(self, status)
    assert(type(status) == "table")
    self.status = status
    self:ApplyStatus()
end

function WidgetMethods.ApplyStatus(self)
    local status = self.status or self.localstatus
    local frame = self.frame
    frame:ClearAllPoints()
    if status.top and status.left then
        frame:SetPoint("TOP", UIParent, "BOTTOM", 0, status.top)
        frame:SetPoint("LEFT", UIParent, "LEFT", status.left, 0)
    else
        frame:SetPoint("CENTER")
    end
end

--- Set the nav bar path, the path is / separated and needs to be the value of the tabs data, if it does not exists it will fail
---@param self ExpansionsOverviewFrame
function WidgetMethods.SetNavBarPath(self, ...)
    local args = SafePack(...)

    if(#args == 0) then
        Utils:DebugPrint("Path is null")
        return
    end

    if(self.navBar.navList) then
        NavBar_Reset(self.navBar)
        self.navBar.navList = nil
    end


    -- TODO: NEed to switch form only value to data text and type to allow for custom path with data ^^
    local homeButtonTabData = GetTabDataFromValue(self, args[1]);
    if not homeButtonTabData then
        Utils:DebugPrint("Failed to find tab data for home path: " .. args[1])
        return
    end

    local homeData = {
		name = homeButtonTabData.text,
		OnClick = function()
            self:SetSelectedTab(homeButtonTabData.value)
		end,
	}

	NavBar_Initialize(self.navBar, "NavButtonTemplate", homeData, self.navBar.home, self.navBar.overflow)
    args[1] = nil
    args['n'] = nil
    for _, section in pairs(args) do
        local tableData = GetTabDataFromValue(self, section)
        if not tableData then
            Utils:DebugPrint("Failed to find tab data for path: " .. section)
            return
        end

        local data = {
            name = tableData.text,
            id = section,
            OnClick = function()
            end,
        }
        NavBar_AddButton(self.navBar, data)
    end

end

-- Events!
local function Frame_OnShow(frame)
	frame.obj:Fire("OnShow")
end

local function Frame_OnClose(frame)
	frame.obj:Fire("OnClose")
end

local function Frame_OnEnter(frame)
    frame.obj:Fire("OnEnter")
end

local function Frame_OnLeave(frame)
    frame.obj:Fire("OnLeave")
end

local function Frame_OnMouseDown(frame)
	AceGUI:ClearFocus()
end

local function Title_OnMouseDown(frame)
	frame:GetParent():StartMoving()
	AceGUI:ClearFocus()
end

local function MoverSizer_OnMouseUp(mover)
	local frame = mover:GetParent()
	frame:StopMovingOrSizing()
    local self = frame.obj
	local status = self.status or self.localstatus
	status.top = frame:GetTop()
	status.left = frame:GetLeft()
end

local function Constructor()
    local name = "CompanionsTracker" .. Type .. AceGUI:GetNextWidgetNum(Type)

    --- @class Frame : PortraitFrameTemplate
    local frame = CreateFrame("Frame", name, UIParent, "PortraitFrameTemplate")
    frame:Hide()
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:SetFrameStrata("MEDIUM")
    frame:SetFrameLevel(100)
    frame:SetToplevel(true)
    frame:SetSize(800, 496)
    frame:SetPoint("CENTER")
    frame:SetScript("OnShow", Frame_OnShow)
	frame:SetScript("OnHide", Frame_OnClose)
    frame:SetScript("OnEnter", Frame_OnEnter)
    frame:SetScript("OnLeave", Frame_OnLeave)
    frame:SetScript("OnMouseDown", Frame_OnMouseDown)


    frame.TitleContainer:EnableMouse(true)
	frame.TitleContainer:SetScript("OnMouseDown", Title_OnMouseDown)
	frame.TitleContainer:SetScript("OnMouseUp", MoverSizer_OnMouseUp)


    local navBar = CreateFrame("Frame", nil, nil, "NavBarTemplate")
    navBar:SetParent(frame)
    navBar:SetSize(500, 34)
    navBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 61, -22)
    do
        local borderLeftCorner = navBar:CreateTexture(nil, "BORDER", "UI-Frame-InnerBotLeftCorner", -5)
        borderLeftCorner:ClearAllPoints()
        borderLeftCorner:SetPoint("BOTTOMLEFT", -3, -3)

        local borderRightCorner = navBar:CreateTexture(nil, "BORDER", "UI-Frame-InnerBotRight", -5)
        borderRightCorner:ClearAllPoints()
        borderRightCorner:SetPoint("BOTTOMRIGHT", 3, -3)

        local borderBottom = navBar:CreateTexture(nil, "BORDER", "_UI-Frame-InnerBotTile", -5)
        borderBottom:ClearAllPoints()
        borderBottom:SetPoint("BOTTOMLEFT", borderLeftCorner, "BOTTOMRIGHT")
        borderBottom:SetPoint("BOTTOMRIGHT", borderRightCorner, "BOTTOMLEFT")

        local leftBorder = navBar:CreateTexture(nil, "BORDER", "!UI-Frame-InnerLeftTile", -5)
        leftBorder:ClearAllPoints()
        leftBorder:SetPoint("TOPLEFT", -3, 0)
        leftBorder:SetPoint("BOTTOMLEFT", borderLeftCorner, "TOPLEFT")

        local rightBorder = navBar:CreateTexture(nil, "BORDER", "!UI-Frame-InnerRightTile", -5)
        rightBorder:ClearAllPoints()
        rightBorder:SetPoint("TOPRIGHT", 3, 0)
        rightBorder:SetPoint("BOTTOMRIGHT", borderRightCorner, "TOPRIGHT")
    end

    --- @class AceGUISimpleGroup : AceGUIWidget
    local buttonsFrameGroup = AceGUI:Create("SimpleGroup")
    buttonsFrameGroup.frame:SetParent(frame)
    buttonsFrameGroup:ClearAllPoints()
    buttonsFrameGroup:SetHeight(400)
    buttonsFrameGroup:SetWidth(100)
    buttonsFrameGroup:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, -75)
    buttonsFrameGroup:SetLayout("List")
    buttonsFrameGroup.frame:Show()


    local inset = CreateFrame("Frame", nil, nil, "InsetFrameTemplate")
    inset:SetParent(frame)
    inset:ClearAllPoints()
    inset:SetPoint("TOPRIGHT", -4, -60)
    inset:SetPoint("BOTTOMLEFT", 4, 5)

    local characterListFrame = CreateFrame("Frame", nil, nil)
    characterListFrame:SetParent(inset)
    characterListFrame:ClearAllPoints()
    characterListFrame:SetPoint("TOPLEFT", 0, -2)
    characterListFrame:SetPoint("BOTTOMRIGHT", -3, 0)

    local expanionBackground = characterListFrame:CreateTexture(nil, "BACKGROUND")
    expanionBackground:SetTexture("Interface\\EncounterJournal\\UI-EJ-Cataclysm")
    expanionBackground:SetAllPoints(characterListFrame, true)

    --- @type AceGUIScrollFrame
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame.frame:SetParent(characterListFrame)
    scrollFrame:SetLayout("Table")
    scrollFrame:SetUserData("table", {
        space = 15,
        columns = {0,0,0,0}
    })
    scrollFrame:ClearAllPoints()
    scrollFrame:SetPoint("TOPLEFT", characterListFrame, 14, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", characterListFrame, 0, 5)
    scrollFrame.scrollbar:SetPoint("BOTTOMLEFT", characterListFrame, "BOTTOMRIGHT", -4, 16)

    local expansionTitle =  characterListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2")
    expansionTitle:SetParent(characterListFrame)
    expansionTitle:ClearAllPoints()
    expansionTitle:SetPoint("TOPLEFT", 20, -15)
    expansionTitle:SetText("Expansion Name")
    expansionTitle:SetJustifyV("BOTTOM")
    expansionTitle:SetJustifyH("CENTER")

    --- @class ExpansionsOverviewFrame : AceGUIWidget
    --- @field status table|nil
    local widget = {
        localstatus = {},
        tabsData = {},
        frame = frame,
        navBar = navBar,
        expanionBackground = expanionBackground,
        expansionTitle = expansionTitle,
        scrollFrame = scrollFrame,
        content = scrollFrame.content,
        selectedTab = nil,
        buttonsFrameGroup = buttonsFrameGroup,
		type = Type
    }

	for method, func in pairs(WidgetMethods) do
		widget[method] = func
    end

    return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)