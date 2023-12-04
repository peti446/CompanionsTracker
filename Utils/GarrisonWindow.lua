
local ns = select(2, ...)

--- @class CompanionsTrackerUtils
local Utils = ns.Utils

--- Opens the expansion ID garrison landing page
--- @param expansionID number
function Utils:OpenGarrisonWindow(expansionID)
    self:CloseAllGarisonWindows();

    -- Needed as Shadowlands has some issues ):
    if(GarrisonLandingPage) then
        local subPanelsToHide = {"SoulbindPanel", "CovenantCallings", "ArdenwealdGardeningPanel", "FollowerTab.CovenantFollowerPortraitFrame"}
        for _, panelName in ipairs(subPanelsToHide) do
            local stringNames = Utils:Split(panelName, ".")
            local panel = GarrisonLandingPage
            for _, name in ipairs(stringNames) do
                panel = panel and panel[name]
            end
            if(panel and panel ~= GarrisonLandingPage) then
                if(expansionID == Enum.GarrisonType.Type_9_0_Garrison) then
                    panel:Show()
                else
                    panel:Hide()
                end
            end
        end
    end

    ShowGarrisonLandingPage(expansionID)

    -- Blizzard ??????
    if(GarrisonLandingPageTab3) then
        GarrisonLandingPageTab3:SetScript("OnLeave", nil)
        GarrisonLandingPageTab3:SetScript("OnEnter", nil)
    end

end


--- Closes all garrison windows
function Utils:CloseAllGarisonWindows()
    if(GarrisonLandingPage) then
        HideUIPanel(GarrisonLandingPage)
    end

    if(MajorFactionRenownFrame) then
        HideUIPanel(MajorFactionRenownFrame)
    end
end