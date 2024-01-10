local ns = select(2, ...)

--- @type CompanionsTrackerUtils
local Utils = ns.Utils

--- @class CompanionsTrackerConfig
local Config = ns.Config or {}
ns.Config = Config

--- @type AceDBObject-3.0
local Defaults =
{
    global =
    {
        ["Version"] = -1,
    },
    profile =
    {
        ["Version"] = -1,
        ["debug"] = false,
        ["minimap"] =
        {
            ["hide"] = false,
            ["quickAccessExpansionID"] = Enum.GarrisonType.Type_9_0_Garrison,
        }
    },
    char =
    {
        ["Version"] = -1,
    }
}
--- @type AceDBObject-3.0
Config.db = {}

--- Initialize the DB
function Config:Init()
    Config.db = LibStub("AceDB-3.0"):New("CompanionsTrackerDB", Defaults)
    self:Update()
end

-- IF version has 2 . it concatenates the last dots so 3.1.1 = 3.11 and 3.0.1 = 3.01 ect
-- 3.0.0 -> 3.0030 (this is release)
-- 3.0.0b -> 3.0020
-- 3.0.0b1 -> 3.0021
-- 3.0.0a -> 3.0010
-- 3.0.0a1 -> 3.0011
local function GetVersionNumber(str)
    if(str == nil) then
        return 0.0
    end

    if(type(str) == "string") then
        if(str:match('^v%d+%.%d+%.%d+a?b?%d*$') == nil) then
            Utils:Print("Invalid version string: " .. str)
            return -1
        end

        str = string.gsub(str, "v", "")
        -- Remove beta and alpha form string and add respective number to the str
        local extraNumber = 0.003
        local typeMatch, subVer = string.match(str, "([ab])(%d*)")
        if(subVer == nil or #subVer == 0) then
           subVer = 0
        end

        if(typeMatch == "b") then
            -- The maximum of betas we can have is 9
            extraNumber = 0.002 + tonumber('0.000' .. subVer)
            str = string.gsub(str, "b(%d*)", "")
        elseif(typeMatch == "a") then
            extraNumber = 0.001 + tonumber('0.000' .. subVer)
            str = string.gsub(str, "a(%d*)", "")
        end

        -- Conver .0.0 to .00
        if(Utils:Repeats(str, "%.") == 2) then
            local index = Utils:FindLastInString(str, "%.")
            str = string.sub( str, 1, index-1) .. string.sub( str, index+1)
        end

        str = tonumber(str) + extraNumber
    end

    return str
end

--[===[@non-debug@
Config.InternalVersion = GetVersionNumber("@project-version@")
--@end-non-debug@]===]
--@debug@
Config.InternalVersion = GetVersionNumber("v0.1.5")
--@end-debug@


--- Updates the config to the latest version and converts any data necesary
function Config:Update()
    --Get old version string
    local globalConfigVersion = GetVersionNumber(self.db.global.Version)
    local profileConfigVerison = GetVersionNumber(self.db.profile.Version)
    local characterConfigVerison = GetVersionNumber(self.db.profile.Version)

    --Update Global table
    if(globalConfigVersion ~= -1 and globalConfigVersion ~= self.InternalVersion) then
    end

    -- Update profile table
    if(profileConfigVerison ~= -1 and profileConfigVerison ~= self.InternalVersion) then
    end

    -- Update character table
    if(characterConfigVerison ~= -1 and characterConfigVerison ~= self.InternalVersion) then

    end

    -- Lastly we update the verison of the config
    self.db.global.Version = self.InternalVersion
    self.db.profile.Version = self.InternalVersion
    self.db.char.Version = self.InternalVersion
end