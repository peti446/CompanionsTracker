local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @class LibDBIcon.dataObject
--- @diagnostic disable-next-line: assign-type-mismatch, missing-fields
local DataBorker = LibStub("LibDataBroker-1.1"):NewDataObject("CompanionsTrackerMinimapIcon", {
    type = "data source",
    label = "Companions Tracker",
    --icon = "Interface\\AddOns\\CompanionsTracker\\Media\\Icons\\companionstracker-minimap-icon",
    text = "a",
})

--- @class LibDBIcon-1.0
--local MinimapIcon = LibStub("LibDBIcon-1.0")
--- @type boolean
local AlreadyRegistered = false

--- Refreshes the minimap to be in line with the settings
function CompanionsTracker:RefreshMinimapIcon()
    if(not AlreadyRegistered) then
        return
    end

    --MinimapIcon:Refresh("CompanionsTracker", Config.db.profile.minimap)
end

--- Inits the minimap icon
function CompanionsTracker:InitMinimapIcon()
    --if(not AlreadyRegistered) then
        --MinimapIcon:Register("CompanionsTracker", DataBorker, Config.db.profile.minimap)
    --end
end

function DataBorker:OnTooltipShow()

end

function DataBorker:OnClick(button, down)

end