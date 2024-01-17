local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @type CompanionsTrackerConfig
local Config = ns.Config

--- @type CompanionsTrackerUtils
local Utils = ns.Utils

function CompanionsTracker:ADDON_LOADED(_event, name)
    for _, data in ipairs(CompanionsTracker.Mixins) do
        if(data.RequiredAddon == name) then
            data:Embed()
        end
    end
end


function CompanionsTracker:CompanionsTracker_GarrionDataUpdated(_event, data)
    Config.db.global.GarrisonsData = Config.db.global.GarrisonsData or {}
    Config.db.global.GarrisonsData[Utils:GetCurrentCharacterServerName()] = Utils:TableConcatStr(data, {
        specID = Utils:GetCurrentPlayerSpec(),
        classID = Utils:GetCurrentPlayerClass(),
    })
end