local ns = select(2, ...)

--- @class CompanionsTracker : AceAddon, AceEvent-3.0, AceTimer-3.0, AceSerializer-3.0, AceComm-3.0, AceBucket-3.0, AceHook-3.0
--- @field Mixins table<string, table>
local CompanionsTracker = LibStub("AceAddon-3.0"):NewAddon("CompanionsTracker", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0", "AceComm-3.0", "AceBucket-3.0", "AceHook-3.0")
--- @type AceLocale-3.0
local L = LibStub("AceLocale-3.0"):GetLocale("CompanionsTracker")
--- @type LibDBIcon-1.0
local LibDBIcon = LibStub("LibDBIcon-1.0")
--- @type AceGUI-3.0
local AceGUI = LibStub("AceGUI-3.0")

ns.CompanionsTracker = CompanionsTracker;
ns.L = L
ns.LibDBIcon = LibDBIcon
ns.AceGUI = AceGUI

--@debug@
_G.CompanionsTracker = CompanionsTracker
--@end-debug@

-- Set up other namespace variables
CompanionsTracker.Mixins = {}
