--- @class CompanionsTrackerNamespace
local ns = select(2, ...)

--- @class CompanionsTracker : AceAddon, AceEvent-3.0, AceHook-3.0
--- @field Mixins table<string, table>
local CompanionsTracker = LibStub("AceAddon-3.0"):NewAddon("CompanionsTracker", "AceEvent-3.0", "AceHook-3.0")
--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):GetLocale("CompanionsTracker")
--- @type LibDBIcon-1.0
local LibDBIcon = LibStub("LibDBIcon-1.0")
--- @type AceGUI-3.0
local AceGUI = LibStub("AceGUI-3.0")

--- @class CompanionsTrackerConstants
--- @field GarrionData table<number, GarrionData>
local Constants = {}

ns.CompanionsTracker = CompanionsTracker;
ns.L = L
ns.LibDBIcon = LibDBIcon
ns.AceGUI = AceGUI
ns.Constants = Constants

--@debug@
_G.CompanionsTracker = ns
--@end-debug@

-- Set up other namespace variables
CompanionsTracker.Mixins = {}



-- Constants

--- @class GarrionData
--- @field iconPath string
--- @field buttonBackgroundColor table
--- @field garrisonID number
--- @field displayName string
--- @field followerTypes table<number, number>
Constants.GarrionData = {
    {
        iconPath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\draenor_logo",
        frameBackground = "UI-EJ-WarlordsofDraenor",
        buttonBackgroundColor = {1.0, 0.0, 0.0},
        garrisonID = Enum.GarrisonType.Type_6_0_Garrison,
        displayName = L["Draenor"],
        followerTypes = {Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower, Enum.GarrisonFollowerType.FollowerType_6_0_Boat}
    },
    {
        iconPath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\legion_logo",
        frameBackground = "UI-EJ-legion",
        buttonBackgroundColor = {0.0, 1.0, 0.0},
        garrisonID = Enum.GarrisonType.Type_7_0_Garrison,
        displayName = L["Legion"],
        followerTypes = {Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower}
    },
    {
        iconPath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\bfa_logo",
        frameBackground = "UI-EJ-BattleforAzeroth",
        buttonBackgroundColor = {1, 1, 1},
        garrisonID = Enum.GarrisonType.Type_8_0_Garrison,
        displayName = L["Battle for Azeroth"],
        followerTypes = {Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower}
    },
    {
        iconPath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\shadowlands_logo",
        frameBackground = "UI-EJ-Shadowlands",
        buttonBackgroundColor = {1.0, 0.47, 0.33},
        garrisonID = Enum.GarrisonType.Type_9_0_Garrison,
        displayName = L["Shadowlands"],
        followerTypes = {Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower}
    },
}
-- Sad, this is because of Toshrael ):
table.sort(Constants.GarrionData, function(a, b) return a.garrisonID < b.garrisonID end)