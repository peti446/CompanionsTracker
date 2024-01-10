local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @class CompanionsTrackerConfig
local Config = ns.Config

--- @type CompanionsTrackerUtils
local Utils = ns.Utils

--- @class OverviewFrame
local OverviewFrame = {}

local L = ns.L
local frame = nil


local function ReleaseFrame()
    if(frame == nil) then
        return
    end

    frame:ReleaseChildren()
    frame:Release()
    frame = nil
end

--- Shows the overview frame at the selcted expansion ID
---@param selectedExpansionID number The garrison expansionID to show, needs to always be passed in
function CompanionsTracker:ShowOverviewFrame(selectedExpansionID)
    if(frame ~= nil) then
        frame:SetSelectedTab(selectedExpansionID)
        frame:Show()
        return
    end

    --- @type GarrionData|nil
    local expansionData = Utils:GarrisonDataByID(selectedExpansionID)
    if(expansionData == nil) then
        Utils:Print("Invalid expansion ID on opening the overview frame, please contact the addon author")
        return
    end

    frame = ns.AceGUI:Create("ExpansionOverviewFrame")
    frame:SetCallback("OnHide", ReleaseFrame)
    frame:SetTitle(L["Companions Tracker"])
    frame:SetPortraitTexture(expansionData.iconPath)
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
    frame:SetTabsInfo(tabData)

    frame:Show()
    frame:SetSelectedTab(selectedExpansionID)
end

