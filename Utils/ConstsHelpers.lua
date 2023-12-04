local ns = select(2, ...)

--- @class CompanionsTrackerUtils
local Utils = ns.Utils

--- Gets the constant GarrisonData By ID
--- @param id number
--- @return GarrionData|nil
function Utils:GarrisonDataByID(id)
    for _, data in ipairs(ns.Constants.GarrionData) do
        if(data.garrisonID == id) then
            return data
        end
    end

    return nil
end