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
--- @field imagePath string
--- @field backbroundColor table
--- @field garrisonID number
--- @field displayName string
Constants.GarrionData = {
    {
        imagePath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\draenor_logo",
        backbroundColor = {1.0, 0.0, 0.0},
        garrisonID = Enum.GarrisonType.Type_6_0_Garrison,
        displayName = L["Draenor"],
    },
    {
        imagePath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\legion_logo",
        backbroundColor = {0.0, 1.0, 0.0},
        garrisonID = Enum.GarrisonType.Type_7_0_Garrison,
        displayName = L["Legion"],
    },
    {
        imagePath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\bfa_logo",
        backbroundColor = {1, 1, 1},
        garrisonID = Enum.GarrisonType.Type_8_0_Garrison,
        displayName = L["Battle for Azeroth"],
    },
    {
        imagePath = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\shadowlands_logo",
        backbroundColor = {1.0, 0.47, 0.33},
        garrisonID = Enum.GarrisonType.Type_9_0_Garrison,
        displayName = L["Shadowlands"],
    },
}
-- Sad, this is because of Toshrael ):
table.sort(Constants.GarrionData, function(a, b) return a.garrisonID < b.garrisonID end)