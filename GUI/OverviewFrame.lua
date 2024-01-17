local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @type CompanionsTrackerConfig
local Config = ns.Config

--- @type CompanionsTrackerUtils
local Utils = ns.Utils


--- @type AceGUI-3.0
local AceGUI = ns.AceGUI

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
        if(C_Garrison.HasGarrison(id)) then
            table.insert(tabData, {
                buttonIcon = data.iconPath,
                bgTexture = data.frameBackground,
                value = id,
                text = data.displayName,
                buttonColor = data.buttonBackgroundColor
            })
        end
    end
    frame:SetUserData("table", {
        space = 15,
        columns = {0,0,0,0}
    })
    frame:SetLayout("Table")
    frame:SetTabsInfo(tabData)
    frame:SetCallback("OnTabChanged", OverviewFrame.OnTabChanged)
    frame:Show()
    frame:SetSelectedTab(selectedExpansionID)
end


--- Copy from https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_ClassTalentUI/Blizzard_ClassTalentSpecTab.lua
local SPEC_TEXTURE_FORMAT = "spec-thumbnail-%s";
local SPEC_FORMAT_STRINGS = {
	[62] = "mage-arcane",
	[63] = "mage-fire",
	[64] = "mage-frost",
	[65] = "paladin-holy",
	[66] = "paladin-protection",
	[70] = "paladin-retribution",
	[71] = "warrior-arms",
	[72] = "warrior-fury",
	[73] = "warrior-protection",
	[102] = "druid-balance",
	[103] = "druid-feral",
	[104] = "druid-guardian",
	[105] = "druid-restoration",
	[250] = "deathknight-blood",
	[251] = "deathknight-frost",
	[252] = "deathknight-unholy",
	[253] = "hunter-beastmastery",
	[254] = "hunter-marksmanship",
	[255] = "hunter-survival",
	[256] = "priest-discipline",
	[257] = "priest-holy",
	[258] = "priest-shadow",
	[259] = "rogue-assassination",
	[260] = "rogue-outlaw",
	[261] = "rogue-subtlety",
	[262] = "shaman-elemental",
	[263] = "shaman-enhancement",
	[264] = "shaman-restoration",
	[265] = "warlock-affliction",
	[266] = "warlock-demonology",
	[267] = "warlock-destruction",
	[268] = "monk-brewmaster",
	[269] = "monk-windwalker",
	[270] = "monk-mistweaver",
	[577] = "demonhunter-havoc",
	[581] = "demonhunter-vengeance",
	[1467] = "evoker-devastation",
	[1468] = "evoker-preservation",
	[1473] = "evoker-augmentation",
}


function OverviewFrame:OnTabChanged(_event, value)
    local allData = Config.db.global.GarrisonsData
    if(allData == nil or frame == nil) then
        return
    end

    frame:ReleaseChildren()
    for name, data in pairs(allData) do
        --- @type CharacterOverviewButton
        local button = AceGUI:Create("CharacterOverviewFrame")  --[[@as CharacterOverviewButton]]
        button:SetTitle(name)
        button:SetBackgroundAtlas(SPEC_TEXTURE_FORMAT:format(SPEC_FORMAT_STRINGS[data.specID]), true, "TRILINEAR")
        frame:AddChild(button)
    end
end
