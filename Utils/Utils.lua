
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

--- Converts a icon path to a string that can be used in the chat to display the icon
--- @param iconPath string
--- @param width number
--- @param height number
--- @return string
function Utils:GetIconStr(iconPath, width, height)
    return string.format("|T%s:%d:%d|t", iconPath, width, height)
end

--- Colors the given string with the given color
---@param color string|table{r:number, g:number, b:number, a?:number}|table{[1]:number, [2]:number, [3]:number, [4]?:number}
---@param text string
---@return string
function Utils:ColorStr(text, color)
    if(type(color) == "table") then
        color = string.format("%02x%02x%02x%02x", (color.a or color[4] or 1) * 255, (color.r or color[1]) * 255, (color.g or color[2]) * 255, (color.b or color[3]) * 255)
    end
    return string.format("|c%s%s|r", color, text)
end

--- Checks if an element is in an array like table
---@param table table
---@param element any
---@return boolean
function Utils:TableHasValue(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

--- Prints any text to the chat, only if debug is enabled
--- @vararg any
function Utils:DebugPrint(...)
    if(type(ns.Config.db) ~= "table" or ns.Config.db.profile.debug) then
        self:Print(" " .. "|cFFFF0000(DEBUG)|r" .. tostringall(... or "nil"))
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