local _AddonName, ns = ...

--- @class CompanionsTrackerUtils
local Utils = ns.Utils


function Utils:GetCurrentCharacterServerName()
    local name = UnitName("player")
    local server = GetRealmName()
    return name .. '-' .. server
end

function Utils:GetCurrentPlayerSpec()
    return select(1, PlayerUtil.GetCurrentSpecID())
end

function Utils:GetCurrentPlayerClass()
    return PlayerUtil.GetClassID()
end