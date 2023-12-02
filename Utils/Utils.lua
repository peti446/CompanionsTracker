local AddonName, ns = ...

--- @class CompanionsTrackerUtils
local Utils = {}
ns.Utils = Utils

--- Get amount of repetition of one string in another
--- @param s string The string
--- @param c string The string to be searched for repetitions
--- @return number Amount of c in s
function Utils:Repeats(s,c)
    local _,n = s:gsub(c,"")
    return n
end

--- Finds the index of the last occurrence of a specific streing
--- @param str string The string to be search
--- @param value string The search value
--- @return number|nil
function Utils:FindLastInString(str, value)
    local i=str:match(".*"..value.."()")
    if i==nil then return nil else return i-1 end
end

---Splits a strng and returns a table
---@param inputstr string the string to separate
---@param sep string separator
---@return table
function Utils:Split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

--- Prints any text to the chat, only if debug is enabled
--- @vararg any
function Utils:DebugPrint(...)
    if(type(ns.Config.db) ~= "table" or ns.Config.db.profile.debug) then
        self:Print(" ", "|cFFFF0000(DEBUG)|r", ...)
    end
end

--- Prints a table only if debug is enabled
---@param tbl table
---@param indent number
function Utils:DebugPrintTable(tbl, indent)
    if(type(ns.Config.db) == "table" and not ns.Config.db.profile.debug) then
        return
    end

    if(tbl == nil) then
        self:DebugPrint("Table is null")
        return
    end

    if not indent or indent <= 1 then
        indent = 1
        self:DebugPrint("Table:")
        print("{")
    end

    if type(tbl) == "table" then
        for k, v in pairs(tbl) do
            local formatting =  string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                print(formatting .. "{")
                self:DebugPrintTable(v, indent+1)
            else
                print(formatting .. tostring(v))
            end
        end
    end
    print(string.rep("  ", max(indent - 1, 0)) .. "}")
end

--- Print any text to the chat
--- @vararg any
function Utils:Print(...)
---@diagnostic disable-next-line: undefined-field
    local msg = string.join(" ","|cFF029CFC["..AddonName.."]|r", tostringall(... or "nil"));
    DEFAULT_CHAT_FRAME:AddMessage(msg);
end

--- Prints a table into the chat
--- @param tbl table
--- @param indent number
function Utils:PrintTable(tbl, indent)
    if(type(ns.Config.db) == "table" and not ns.Config.db.profile.debug) then
        return
    end

    if(tbl == nil) then
        self:Print("Table is null")
        return
    end

    if not indent or indent <= 1 then
        indent = 1
        self:Print("Table:")
        print("{")
    end

    if type(tbl) == "table" then
        for k, v in pairs(tbl) do
            local formatting =  string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                print(formatting .. "{")
                self:PrintTable(v, indent+1)
            else
                print(formatting .. tostring(v))
            end
        end
    end
    print(string.rep("  ", max(indent - 1, 0)) .. "}")
end