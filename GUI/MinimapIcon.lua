local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @class CompanionsTrackerConfig
local Config = ns.Config

--- @type CompanionsTrackerUtils
local Utils = ns.Utils

local L = ns.L

--- @class LibDBIcon.dataObject : GameTooltip
--- @diagnostic disable-next-line: assign-type-mismatch, missing-fields
local DataBorker = LibStub("LibDataBroker-1.1"):NewDataObject("CompanionsTrackerMinimapIcon", {
    type = "data source",
    label = "Companions Tracker",
    icon = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\draenor_logo",
    text = "",
})

--- @class LibDBIcon-1.0
local MinimapIcon = LibStub("LibDBIcon-1.0")
--- @type boolean
local AlreadyRegistered = false

--- Refreshes the minimap to be in line with the settings
function CompanionsTracker:RefreshMinimapIcon()
    if(not AlreadyRegistered) then
        return
    end

    -- Update icon
    local iconPath = Utils:GarrisonDataByID(Config.db.profile.minimap.quickAccessExpansionID).iconPath or "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\draenor_logo"
    MinimapIcon:GetMinimapButton("CompanionsTracker").icon:SetTexture(iconPath)
    -- Refresh Position and other data
    MinimapIcon:Refresh("CompanionsTracker", Config.db.profile.minimap)
end

--- Inits the minimap icon
function CompanionsTracker:InitMinimapIcon()
    if(not AlreadyRegistered) then
        MinimapIcon:Register("CompanionsTracker", DataBorker, Config.db.profile.minimap)
        AlreadyRegistered = true
        CompanionsTracker:RefreshMinimapIcon()
    end
end

function DataBorker:OnTooltipShow()
    self:AddLine("Companions Tracker " ..  Utils:ColorStr(C_AddOns.GetAddOnMetadata("CompanionsTracker", "Version"), {r = 0, g = 1.0, b = 0, a = 1}))
    self:AddLine(" ")
    self:AddLine((RED_FONT_COLOR_CODE .. "%s " .. NORMAL_FONT_COLOR_CODE .. "%s|r"):format(L["Left Click"], L["Opens the %s garrison landing page"]:format(Utils:GarrisonDataByID(Config.db.profile.minimap.quickAccessExpansionID).displayName)))
    self:AddLine((RED_FONT_COLOR_CODE .. "%s " .. NORMAL_FONT_COLOR_CODE .. "%s|r"):format(L["Right Click"], L["Open Options panel"]))
end


function DataBorker:OnClick(button, down)
    if(button == "LeftButton") then
        --Utils:OpenGarrisonWindow(Config.db.profile.minimap.quickAccessExpansionID)
        local f = ns.AceGUI:Create("ExpansionOverviewFrame")
        f:SetTitle(L["Companions Tracker"])
        f:SetPortraitTexture("Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\shadowlands_logo")
        local tabData = {}
        for _, data in ipairs(ns.Constants.GarrionData) do
            local id = data.garrisonID
            if(C_Garrison.GetGarrisonInfo(id) ~= nil) then
                table.insert(tabData, {
                    buttonIcon = data.iconPath,
                    bgTexture = data.frameBackground,
                    value = id,
                    text = data.displayName,
                    buttonColor = data.buttonBackgroundColor
                })
            end
        end

        f:SetTabsInfo(tabData)
        f:Show()
        f:SetCallback("OnHide", function()
            f:Release()
        end)

    elseif(button == "RightButton") then
        CompanionsTracker:OpenOptionsGUI()
    end
end