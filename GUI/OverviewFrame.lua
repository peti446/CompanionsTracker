local ns = select(2, ...)

--- @class CompanionsTracker
local CompanionsTracker = ns.CompanionsTracker

--- @type CompanionsTrackerConfig
local Config = ns.Config

--- @type CompanionsTrackerUtils
local Utils = ns.Utils

--- @type AceGUI-3.0
local AceGUI = ns.AceGUI

--- @class OverviewFrame
local OverviewFrame = {}

local L = ns.L
--- @type ExpansionsOverviewFrame?
local frame = nil

local function ReleaseFrame()
    if(frame == nil) then
        return
    end

    frame:ReleaseChildren()
    frame:Release()
    frame = nil
end

--- Shows the overview frame at the selcted expansion ID
---@param selectedExpansionID number The garrison expansionID to show, needs to always be passed in
function CompanionsTracker:ShowOverviewFrame(selectedExpansionID)
    if(frame ~= nil) then
        frame:SetSelectedTab(selectedExpansionID)
        frame:Show()
        return
    end

    --- @type GarrionData|nil
    local expansionData = Utils:GarrisonDataByID(selectedExpansionID)
    if(expansionData == nil) then
        Utils:Print("Invalid expansion ID on opening the overview frame, please contact the addon author")
        return
    end

    frame = ns.AceGUI:Create("ExpansionOverviewFrame")
    frame:SetCallback("OnHide", ReleaseFrame)
    frame:SetTitle(L["Companions Tracker"])
    frame:SetPortraitTexture(expansionData.iconPath)
    local tabData = {}
    for _, data in ipairs(ns.Constants.GarrionData) do
        table.insert(tabData, {
            buttonIcon = data.iconPath,
            bgTexture = data.frameBackground,
            value = data.garrisonID,
            text = data.displayName,
            buttonColor = data.buttonBackgroundColor
        })
    end
    frame:SetUserData("table", {
        space = 15,
        columns = {0,0,0,0}
    })
    frame:SetLayout("Table")
    frame:SetTabsInfo(tabData)
    frame:SetCallback("OnTabChanged", OverviewFrame.OnTabChanged)
    frame:SetCallback("RenderSubPath", OverviewFrame.RenderSubPath)
    frame:Show()
    frame:SetSelectedTab(selectedExpansionID)
end

local function RenderMissionsTab(self, _event, group)
    -- Clean up first so that we do not have any pending data
    self:ReleaseChildren()
    self:SetLayout("Fill")

    -- Create the scroll frame
    --- @type AceGUIContainer
    local scrollFrame = AceGUI:Create("ScrollFrame") --[[@as AceGUIContainer]]
    scrollFrame:SetLayout("List")
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetFullHeight(true)
    self:AddChild(scrollFrame)

    local charData = self:GetUserData("CharData")
    local dataEntries = Utils:Split(group, ",")
    local renderedData = false;
    local currentTime = time()
    for _, dataEntry in ipairs(dataEntries) do
        local data = charData[dataEntry]
        if(data ~= nil) then
            for _, followerTypeData in pairs(data) do
                for _, missionData in ipairs(followerTypeData) do
                    -- Update the mission data as time goes by
                    -- TODO: Move this to a timer
                    if(not missionData.isComplete and (missionData.missionEndTime or -1) < currentTime) then
                        missionData.isComplete = true
                    end

                    if(missionData.inProgress or missionData.isComplete or (missionData.offerEndTime or -1 < time())) then
                        ---@type BlizzardGarrisonLandingPageReportMissionTemplate
                        local missionFrame = AceGUI:Create("BlizzardGarrisonLandingPageReportMissionTemplate") --[[@as BlizzardGarrisonLandingPageReportMissionTemplate]]
                        missionFrame:SetMissionInfo(missionData)
                        scrollFrame:AddChild(missionFrame)
                        renderedData = true
                    end
                end
            end
        end
    end

    if(not renderedData) then


        --- @type Label
        local label = AceGUI:Create("Label") --[[@as Label]]
        label:SetText(GARRISON_EMPTY_IN_PROGRESS_LIST)
        label:SetColor(0.75, 0.75, 0.75)
        label:SetFontObject(GameFontNormalLarge2)
        label:SetJustifyH("CENTER")
        label:SetJustifyV("CENTER")
        label:SetFullWidth(true)
        label:SetFullHeight(true)
        scrollFrame:SetLayout("Fill")
        scrollFrame:AddChild(label)
        if(group == "missionsInProgress,missionsCompleted") then
            label:SetText(GARRISON_EMPTY_IN_PROGRESS_LIST)
        else
            label:SetText(L['No Misions available'])
        end
    end
end

function OverviewFrame.UpdateMissionsList()
    if(not frame) then return end

    local tabGroup = frame.missionsTabGroup
    local tabStatus = tabGroup.status or tabGroup.localstatus;
    RenderMissionsTab(tabGroup, nil, tabStatus.selected)
end

function OverviewFrame.RenderSubPath(frame, _event, insertFrame, path)
    insertFrame:ReleaseChildren()

    -- Check the path
    if(path == nil or  #path == 0) then
        Utils:Print("Invalid path value on rendering sub path for overview frame, please contact the addon author. Value got is:" .. path)
        return
    end

    local charData = Config.db.global.GarrisonsData[path[2].id][path[2].userData.garrisonID]

    -- Create the background group
    --- @type GarrisonBackgroundGroup
    local garrisonGroup = AceGUI:Create("GarrisonBackgroundGroup") --[[@as GarrisonBackgroundGroup]]
    garrisonGroup:SetLayout("Flow")
    insertFrame:AddChild(garrisonGroup)

    -- Create the missions tab
    --- @type TabGroup
    local missionsTabGroup = AceGUI:Create("TabGroup") --[[@as TabGroup]]
    missionsTabGroup:SetLayout("Flow")
    missionsTabGroup:SetTabs({
        {
            text = L["In progress"],
            value = "missionsInProgress,missionsCompleted"
        },
        {
            text = L["Available"],
            value = "missionsAvailable"
        }
    })
    missionsTabGroup:SetCallback("OnGroupSelected", RenderMissionsTab)
    missionsTabGroup:SetWidth(440)
    missionsTabGroup:SetFullHeight(true)
    missionsTabGroup:SetUserData("CharData", charData)

    local showCompletedTab = false
    for _, data in pairs(charData.missionsCompleted or {}) do
        if(#data > 0) then
            showCompletedTab = true
            break
        end
    end
    if(not showCompletedTab) then
        for _,data in pairs(charData.missionsInProgress or {}) do
            if(#data > 0) then
                showCompletedTab = true
                break
            end
        end
    end
    if(showCompletedTab) then
        missionsTabGroup:SelectTab("missionsInProgress,missionsCompleted")
    else
        missionsTabGroup:SelectTab("missionsAvailable")
    end
    garrisonGroup:AddChild(missionsTabGroup)

    -- Save so we can rerender
    frame.missionsTabGroup = missionsTabGroup
    missionsTabGroup:SetUserData("BucketHandler", CompanionsTracker:RegisterBucketEvent({"GET_ITEM_INFO_RECEIVED"}, 1, OverviewFrame.UpdateMissionsList))
    missionsTabGroup:SetCallback("OnRelease", function(self)
        -- Clear up the data
        CompanionsTracker:UnregisterBucket(self:GetUserData("BucketHandler"))
        frame.missionsTabGroup = nil
    end)

    -- Create shipments data
    --- @type AceGUIContainer
    local shipmentsGroup = AceGUI:Create("SimpleGroup") --[[@as AceGUIContainer]]
    garrisonGroup:AddChild(shipmentsGroup)
    shipmentsGroup:SetUserData("table", {columns = {3.3, 3.3, 3.3}, space = 30, alignH = 40})
    shipmentsGroup:SetLayout("Table")
    shipmentsGroup:SetPoint("TOPLEFT", missionsTabGroup.frame, "TOPRIGHT", 0, -20)
    shipmentsGroup:SetFullHeight(true)
    for type, dataArray in pairs(charData.shipmentsData or {}) do
        for _, data in ipairs(dataArray) do
            ---@type BlizzardGarrisonLandingPageReportShipmentStatusTemplate
            local shipmentFrame = AceGUI:Create("BlizzardGarrisonLandingPageReportShipmentStatusTemplate") --[[@as BlizzardGarrisonLandingPageReportShipmentStatusTemplate]]
            shipmentFrame:SetShipmentInfo(type, data)
            shipmentFrame:SetScale(0.8)
            shipmentsGroup:AddChild(shipmentFrame)
        end
    end
end

function OverviewFrame.OnCharacterbuttonClicked(button)
    if(frame == nil) then
        return
    end

    local function GetPathData(garrisonID, name)
        local subButtomData  = {
            name = name,
            id = name,
            userData = {
                garrisonID = garrisonID,
                otherCharacters = {
                }
            },
        }

        -- Populate the other characters field
        for otherName, data in pairs(Config.db.global.GarrisonsData) do
            if(otherName ~= name) then
                local garrisonData = data[garrisonID]
                if(garrisonData ~= nil) then
                    tinsert(subButtomData.userData.otherCharacters,
                    {
                        text = otherName,
                        id = otherName,
                        func = function (self, id, _navNar)
                            frame:SetNavBarPath(unpack(GetPathData(self.owner.data.userData.garrisonID, id)))
                        end
                    })
                end
            end
        end

        -- If we have childs we add the list function to return them
        if(#subButtomData.userData.otherCharacters > 0) then
            subButtomData.listFunc = function(self)
                return self.data.userData.otherCharacters
            end
        end
        return {garrisonID, subButtomData }
    end

    frame:SetNavBarPath(unpack(GetPathData(button:GetUserData("garrisonID"), button:GetUserData("characterName"))))
end

function OverviewFrame.OnTabChanged(frame, _event, value)
    local allData = Config.db.global.GarrisonsData
    if(allData == nil or frame == nil) then
        return
    end

    frame:ReleaseChildren()
    for name, data in pairs(allData) do
        local garrisonData = data[value]
        if(garrisonData ~= nil) then
            local sanitizedName = name
            if(not Config.db.profile.showServerName) then
                sanitizedName = Utils:Split(name, "-")[1]
            end
            --- @type CharacterOverviewButton
            local button = AceGUI:Create("CharacterOverviewFrame")  --[[@as CharacterOverviewButton]]
            button:SetTitle(sanitizedName)
            button:SetBackgroundAtlas(ns.TextureUtils:GetSpecThumbnailTexture(data.specID), true, "TRILINEAR")
            button:SetUserData("garrisonID", value)
            button:SetUserData("characterName", name)
            button:SetCallback("OnClick", OverviewFrame.OnCharacterbuttonClicked)

            local missionsCompleted = 0
            local missionsInProgress = 0
            local missionsAvailable = 0
            local currentTime = time()
            for _, followerTypeData in pairs(garrisonData.missionsAvailable or {}) do
                for _, missionData in ipairs(followerTypeData) do
                    if(missionData.offerEndTime and missionData.offerEndTime > currentTime) then
                        missionsAvailable = missionsAvailable + 1
                    end
                end
            end
            for _, followerTypeData in pairs(garrisonData.missionsCompleted or {}) do
                missionsCompleted = missionsCompleted + #followerTypeData
            end
            for _, followerTypeData in pairs(garrisonData.missionsInProgress or {}) do
                for _, missionData in ipairs(followerTypeData) do
                    if(missionData.missionEndTime > currentTime) then
                        missionsInProgress = missionsInProgress + 1
                    else
                        missionsCompleted = missionsCompleted + 1
                    end
                end
            end

            local index = 1;
            if(missionsInProgress > 0) then
                button:SetLineText(index, L["In progress missions: %s"]:format(Utils:ColorStr(tostring(missionsInProgress), 'FFFF8400')))
                index = 2;
            end

            if(missionsCompleted > 0) then
                button:SetLineText(index, L["Completed missions: %s"]:format(Utils:ColorStr(tostring(missionsCompleted), 'FFFF8400')))
                index = index + 1;
            end

            if(index == 1) then
                button:SetLineText(1, L["No missions in progress or completed"])
                if( missionsAvailable > 0) then
                    button:SetLineText(2, L["Missions Available: %s"]:format(Utils:ColorStr(tostring(missionsAvailable), 'FFFF8400')))
                end
            end

            frame:AddChild(button)
        end
    end
end
