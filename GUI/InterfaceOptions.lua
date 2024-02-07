local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @type CompanionsTrackerConfig
local Config = ns.Config

--- @type CompanionsTrackerUtils
local Utils = ns.Utils

--- @type table
local L = ns.L

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--- @class InterfaceOptions
--- @field frame table|nil
local InterfaceOptions = {
    frame = nil
}

-- 04/12/2023
-- Amelia please no pizzza con piña gracias


local myOptionsTable = {
    name = "Companions Tracker",
    handler = InterfaceOptions,
    type = "group",
    args = {
        general_group = {
            name = L["General Settings"],
            type = "group",
            order = 0,
            args = {
                minimap_hide = {
                    name = L["Hide minimap icon"],
                    desc = L["Hides/Shows the minimap icon"],
                    descStyle = "inline",
                    width = "full",
                    type = "toggle",
                    set = "SetMinimapHidden",
                    get = "GetMinimapHidden",
                },
                show_server_name = {
                    name = L["Show server name"],
                    desc = L["Shows/Hides the server name in the character list"],
                    descStyle = "inline",
                    width = "full",
                    type = "toggle",
                    set = "SetShowServerName",
                    get = "GetShowServerName",
                },
                minimap_on_click_expansion_open = {
                    name = L["Left Click on minimap to open expansion"],
                    desc = L["Defines what expansion page will open when left clicking the minimap icon"],
                    width = "full",
                    type = "select",
                    style = "dropdown",
                    values = function()
                        local values = {}
                        for _, data in ipairs(ns.Constants.GarrionData) do
                            values[data.garrisonID] = Utils:GetIconStr(data.iconPath, 24, 24) .. " " .. data.displayName
                        end

                        return values
                    end,
                    set = "SetMinimapOnClickExpansionOpen",
                    get = "GetMinimapOnClickExpansionOpen",
                }
            },
        },
        debug_group = {
            name = L["Debug Settings"],
            type = "group",
            order = 1,
            args = {
                debug_messages = {
                    name = L["Show debug messages"],
                    desc = L["Enables/Disables the addon printing debug messages to the chat"],
                    descStyle = "inline",
                    width = "full",
                    type = "toggle",
                    set = "SetDebugMessages",
                    get = "GetDebugMessages",
                },
            },
        }
    }
}

function CompanionsTracker:RegisterOptionsGUI()
    AceConfig:RegisterOptionsTable("CompanionsTracker", myOptionsTable)
    InterfaceOptions.frame = AceConfigDialog:AddToBlizOptions("CompanionsTracker", "Companions Tracker")
end

function CompanionsTracker:OpenOptionsGUI()
    InterfaceOptionsFrame_OpenToCategory(InterfaceOptions.frame)
end

function InterfaceOptions:SetMinimapHidden(_, value)
    Config.db.profile.minimap.hide = value
    CompanionsTracker:RefreshMinimapIcon()
end

function InterfaceOptions:GetMinimapHidden(_)
    return Config.db.profile.minimap.hide
end

function InterfaceOptions:SetMinimapOnClickExpansionOpen(_, value)
    Config.db.profile.minimap.quickAccessExpansionID = value
    CompanionsTracker:RefreshMinimapIcon()
end

function InterfaceOptions:GetMinimapOnClickExpansionOpen(_)
    return Config.db.profile.minimap.quickAccessExpansionID
end

function InterfaceOptions:SetDebugMessages(_, value)
    Config.db.profile.debug = value
end

function InterfaceOptions:GetDebugMessages(_)
    return Config.db.profile.debug
end

function InterfaceOptions:GetShowServerName(_)
    return Config.db.profile.showServerName
end

function InterfaceOptions:SetShowServerName(_, value)
    Config.db.profile.showServerName = value
end