local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

function CompanionsTracker:ADDON_LOADED(_event, name)
    for _, data in ipairs(CompanionsTracker.Mixins) do
        if(data.RequiredAddon == name) then
            data:Embed()
        end
    end
end