local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @type CompanionsTrackerConfig
local Config = ns.Config

--- @type CompanionsTrackerUtils
local Utils = ns.Utils

--- @type CompanionsTrackerConstants
local Constants = ns.Constants

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
        notifications = {
            name = L["Notifications Settings"],
            type = "group",
            order = 1,
            set = "SimpleSetGlobal",
            get = "SimpleGetGlobal",
            args = {
                header = {
                    type = "header",
                    order = 0,
                    name = L["Notifications Configurations"],
                },
                label = {
                    type = "description",
                    order = 1,
                    name = CreateColor(1,0,0):WrapTextInColorCode(L["These settings are global and will affect all characters on this account."]),
                },
                enabled = {
                    name = L["Enable Notifications"],
                    desc = L["Enables/Disables notifications on missions completion of other characters"],
                    order = 2,
                    width = "full",
                    type = "toggle",
                    set = "SetNotifications",
                },
                disableInInstances = {
                    name = L["Disable in instances"],
                    desc =  "(Not yet implemented)" .. L["Disables notifications when the player is in a instance group"],
                    descStyle  = "inline",
                    order = 3,
                    width = "full",
                    type = "toggle",
                },
                combatEndDelay = {
                    name = L["Delay after combat to show notifications"],
                    desc = L["The time in seconds to wait after combat to show the notifications"],
                    order = 4,
                    width = "full",
                    type = "range",
                    softMin = 0,
                    softMax = 120,
                },
                expansions_config = {
                    name = L["Expansions Notifications Configurations"],
                    desc = L["Configure the notifications for expansion"],
                    type = "group",
                    order = 4,
                    childGroups = "tab",
                    get = function(info)
                        local value = Config.db.global.notifications.expansions[tonumber(info[#info-1])] and Config.db.global.notifications.expansions[tonumber(info[#info-1])][info[#info]]
                        if(type(value) == "boolean") then
                            return value
                        end
                        return true
                    end,
                    set = function(info, value)
                        Config.db.global.notifications.expansions[tonumber(info[#info-1])] = Config.db.global.notifications.expansions[tonumber(info[#info-1])] or {}
                        Config.db.global.notifications.expansions[tonumber(info[#info-1])][info[#info]] = value
                        -- Update the notification module for notifications
                        local module = CompanionsTracker:GetModule("Notifications")  --[[@as NotificationsModule]]
                        if(not module:IsEnabled()) then
                            return
                        end
                        if(info[#info] == "enabled") then
                            module:SetExpansionEnabled(tonumber(info[#info-1]), value)
                        else
                            module:SetCharacterState(info[#info], tonumber(info[#info-1]), value)
                        end
                    end,
                    hidden = function()
                        return not Config.db.global.notifications
                    end,
                }
            },
        },
        debug_group = {
            name = L["Debug Settings"],
            type = "group",
            order = 2,
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

setmetatable(myOptionsTable.args.notifications.args.expansions_config, {__index = function(_table, key)
    if(key ~= "args") then return nil end

    local finalTable = {}
    for _, expansionsData in ipairs(Constants.GarrionData) do
        local expansionSettings = {
            name = expansionsData.displayName,
            type = "group",
            args = {
                enabled = {
                    name = L["Enable Notifications"],
                    desc = L["Enables/Disables notifications for this expansion"],
                    width = "full",
                    type = "toggle",
                    order = 0,
                },
                header = {
                    type = "header",
                    order = 1,
                    name = L["Per Character Configurations"],
                },
                label = {
                    type = "description",
                    order = 2,
                    name = L["Select the characters you want to show notifications for this expansion"],
                },
                reset = {
                    name = L["Reset"],
                    desc = L["Resets the notifications for this expansion to the default settings"],
                    type = "execute",
                    order = 3,
                    func = function(info)
                        local enabled = Config.db.global.notifications.expansions[tonumber(info[#info-1])] and Config.db.global.notifications.expansions[tonumber(info[#info-1])].enabled
                        Config.db.global.notifications.expansions[tonumber(info[#info-1])] = {
                            enabled = enabled
                        }
                    end,
                },

            }
        }

        local i = 4
        for name, _ in pairs(Config.db.global.GarrisonsData) do
            local charCheckbox = {
                name =  function(info)
                    local value = Config.db.global.notifications.expansions[tonumber(info[#info-1])] and Config.db.global.notifications.expansions[tonumber(info[#info-1])][info[#info]]
                    if(type(value) ~= "boolean") then
                        value = true
                    end
                    return value and CreateColor(0, 1, 0):WrapTextInColorCode(name) or CreateColor(1, 0, 0):WrapTextInColorCode(name)
                end,
                order = i,
                width = "full",
                type = "toggle",
            }
            i = i + 1
            expansionSettings.args[name] = charCheckbox
        end

        finalTable[tostring(expansionsData.garrisonID)] = expansionSettings
    end

    return finalTable
end })

function CompanionsTracker:RegisterOptionsGUI()
    AceConfig:RegisterOptionsTable("CompanionsTracker", myOptionsTable, {"/companionstracker", "/ct"})
    InterfaceOptions.frame = AceConfigDialog:AddToBlizOptions("CompanionsTracker", "Companions Tracker")
end

function CompanionsTracker:OpenOptionsGUI()
    InterfaceOptionsFrame_OpenToCategory(InterfaceOptions.frame)
end

function InterfaceOptions:SimpleSetGlobal(info, value)
    local db = Config.db.global or {}
    for i, k in ipairs(info) do
        if(i < #info) then
            db = db[k]
        end
    end

    db[info[#info]] = value
end

function InterfaceOptions:SimpleGetGlobal(info)
    local db = Config.db.global or {}
    for i, k in ipairs(info) do
        if(i < #info) then
            db = db[k]
        end
    end

    return db[info[#info]]
end

function InterfaceOptions:SimpleSetProfile(info, value)
    local db = Config.db.profile or {}
    for i, k in ipairs(info) do
        if(i < #info) then
            db = db[k]
        end
    end

    db[info[#info]] = value
end

function InterfaceOptions:SimpleGetProfile(info)
    local db = Config.db.profile or {}
    for i, k in ipairs(info) do
        if(i < #info) then
            db = db[k]
        end
    end

    return db[info[#info]]
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

function InterfaceOptions:SetNotifications(_, value)
    Config.db.global.notifications.enabled = value
    local module = CompanionsTracker:GetModule("Notifications")  --[[@as NotificationsModule]]
    if(value) then
        module:Enable()
    else
        module:Disable()
    end
end