local ns = select(2, ...)

--- @type CompanionsTrackerUtils
local Utils = ns.Utils

--- @class GarrisonDataCollectorModule : AceHook-3.0, AceEvent-3.0, AceBucket-3.0, AceModule
local GarrisonDataCollector = ns.CompanionsTracker:NewModule("GarrisonDataCollector", "AceEvent-3.0", "AceHook-3.0", "AceBucket-3.0")

--- @private
function GarrisonDataCollector:OnEnable()
    GarrisonDataCollector:RegisterBucketEvent({"GARRISON_MISSION_LIST_UPDATE"}, 1, "GARRISON_MISSION_LIST_UPDATE")
    GarrisonDataCollector:RegisterBucketEvent({"GARRISON_FOLLOWER_LIST_UPDATE"}, 1, "GARRISON_FOLLOWER_LIST_UPDATE")
    GarrisonDataCollector:RegisterBucketEvent({"GARRISON_LANDINGPAGE_SHIPMENTS", "GARRISON_TALENT_UPDATE", "GARRISON_TALENT_COMPLETE"}, 1, "UPDATE_SHIPMENTS_DATA")
    GarrisonDataCollector:RegisterBucketEvent({"GARRISON_SHIPMENT_RECEIVED"}, 1, "GARRISON_SHIPMENT_RECEIVED")
    GarrisonDataCollector:RegisterEvent("SHIPMENT_UPDATE")


    self.garrisonsData = {}
    self.garrisonTypesTracked = {}
    self.garrisonFollowersTracked = {}
    self.followerTypeToGarrisonType = {}
end

--- @private
function GarrisonDataCollector:OnDisable()
    GarrisonDataCollector:UnregisterAllBuckets()
    GarrisonDataCollector:UnregisterEvent("SHIPMENT_UPDATE")
end


--- Adds a new garrison type to be tracked
--- @param data {garrisonType:number, followersID: number[]} The expansion data to be tracked
function GarrisonDataCollector:RegisterExpansion(data)
    if(type(data) ~= "table") then
        Utils:DebugPrint("Invalid data passed to RegisterExpansion")
        return
    end

    if(Utils:TableHasValue(self.garrisonTypesTracked, data.garrisonType)) then
        Utils:DebugPrint("Garrison type already registered")
        return
    end

    -- Data storage
    table.insert(self.garrisonTypesTracked, data.garrisonType)
    self.garrisonsData[data.garrisonType] = self.garrisonsData[data.garrisonType] or {}
    for _, followerID in ipairs(data.followersID) do
        table.insert(self.garrisonFollowersTracked, followerID)
        self.followerTypeToGarrisonType[followerID] = data.garrisonType
    end

    C_Garrison.RequestLandingPageShipmentInfo()

    Utils:DebugPrint(("Registered expansion with id %d"):format(data.garrisonType))
    Utils:DebugPrint("Followers registered:")
    Utils:DebugPrintTable(data.followersID)
end

function GarrisonDataCollector:GetData()
    return self.garrisonsData
end

--- @private
function GarrisonDataCollector:GARRISON_MISSION_LIST_UPDATE(followerTypeArray)
    local currentTime = time()
    local updatedData = false
    for id, _amount in pairs(followerTypeArray) do
        if(not Utils:TableHasValue(self.garrisonFollowersTracked, id)) then
            Utils:DebugPrint(("Missions type %d not tracked"):format(id))
            return
        end

        Utils:DebugPrint(("Updating data for missions of type %d"):format(id))

        local missionsAvailable = C_Garrison.GetAvailableMissions(id)
        local missionsInProgress = {}
        local missionsCompleted =  {}
        for _, mission in ipairs(C_Garrison.GetInProgressMissions(id) or {}) do
            if(mission.missionEndTime <= currentTime) then
                table.insert(missionsCompleted, mission)
            else
                table.insert(missionsInProgress, mission)
            end
        end

        local garrisonID = self.followerTypeToGarrisonType[id]
        self.garrisonsData[garrisonID] = self.garrisonsData[garrisonID] or {}
        self.garrisonsData[garrisonID].missionsAvailable = self.garrisonsData[garrisonID].missionsAvailable or {}
        self.garrisonsData[garrisonID].missionsInProgress = self.garrisonsData[garrisonID].missionsInProgress or {}
        self.garrisonsData[garrisonID].missionsCompleted = self.garrisonsData[garrisonID].missionsCompleted or {}
        self.garrisonsData[garrisonID].missionsAvailable[id] = missionsAvailable
        self.garrisonsData[garrisonID].missionsInProgress[id] = missionsInProgress
        self.garrisonsData[garrisonID].missionsCompleted[id] = missionsCompleted

        updatedData = true;
    end

    if(updatedData) then
        self:SendMessage(ns.CompanionsTracker.Events.GarrionDataUpdated, self.garrisonsData)
    end
end

--- @private
function GarrisonDataCollector:GARRISON_FOLLOWER_LIST_UPDATE(followerTypeArray)
    local updatedData = false
    for id, _amount in pairs(followerTypeArray) do
        if(not Utils:TableHasValue(self.garrisonFollowersTracked, id)) then
            Utils:DebugPrint(("Followers type %d not tracked"):format(id))
            return
        end

        Utils:DebugPrint(("Updating data for followers of type %d"):format(id))

        local followers = C_Garrison.GetFollowers(id)
        local garrisonID = self.followerTypeToGarrisonType[id]
        self.garrisonsData[garrisonID] = self.garrisonsData[garrisonID] or {}
        self.garrisonsData[garrisonID].followers = self.garrisonsData[garrisonID].followers or {}
        self.garrisonsData[garrisonID].followers[id] = followers

        updatedData = true;
    end

    if(updatedData) then
        self:SendMessage(ns.CompanionsTracker.Events.GarrionDataUpdated, self.garrisonsData)
    end
end

--- @private
function GarrisonDataCollector:UPDATE_SHIPMENTS_DATA()
    for _, garrisonType in ipairs(self.garrisonTypesTracked) do
        local buildings = C_Garrison.GetBuildings(garrisonType) or {}
        local followerShipments = C_Garrison.GetFollowerShipments(garrisonType) or {}
        local looseShipments = C_Garrison.GetLooseShipments(garrisonType) or {}
        local talentTreeIDs = C_Garrison.GetTalentTreeIDsByClassID(garrisonType, select(3, UnitClass("player"))) or {}
        local completeTalentID = C_Garrison.GetCompleteTalent(garrisonType)

        self.garrisonsData[garrisonType] = self.garrisonsData[garrisonType] or {}
        local garrisonData = self.garrisonsData[garrisonType]
        wipe(garrisonData.buildingsShipment or {})
        wipe(garrisonData.followersShipments or {})
        wipe(garrisonData.looseShipments or {})

        for _, building in ipairs(buildings) do
            local buildingID = building.buildingID;
            if ( buildingID) then
                local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemIcon, itemQuality, itemID = C_Garrison.GetLandingPageShipmentInfo(buildingID);
                if ( name and shipmentCapacity > 0 ) then
                    garrisonData.buildingsShipment = garrisonData.buildingsShipment or {}
                    garrisonData.buildingsShipment[buildingID] = {C_Garrison.GetLandingPageShipmentInfo(buildingID)}
                end
            end
        end

        for _, followerShipmentID in ipairs(followerShipments) do
            local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, _, _, _, _, followerID = C_Garrison.GetLandingPageShipmentInfoByContainerID(followerShipmentID);
            if ( name and shipmentCapacity > 0) then
                garrisonData.followersShipments = garrisonData.followersShipments or {}
                garrisonData.followersShipments[followerShipmentID] =  {C_Garrison.GetLandingPageShipmentInfoByContainerID(followerShipmentID)}
            end
        end

        for _, loseShipmentID in ipairs(looseShipments) do
            local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString = C_Garrison.GetLandingPageShipmentInfoByContainerID(loseShipmentID);
            if ( name and shipmentCapacity > 0 ) then
                garrisonData.looseShipments = garrisonData.looseShipments or {}
                garrisonData.looseShipments[loseShipmentID] =  {C_Garrison.GetLandingPageShipmentInfoByContainerID(loseShipmentID)}
            end
        end

        if (talentTreeIDs) then
            for _, treeID in ipairs(talentTreeIDs) do
                local treeInfo = C_Garrison.GetTalentTreeInfo(treeID);
                for _, talent in ipairs(treeInfo.talents) do
                    if talent.isBeingResearched or talent.id == completeTalentID then
                        if(talent.startTime + talent.researchDuration > GetTime()) then
                            garrisonData.talentBeingResearched = garrisonData.talentBeingResearched or {}
                            garrisonData.talentBeingResearched[treeID] = garrisonData.talentBeingResearched[treeID] or {}
                            garrisonData.talentBeingResearched[treeID][talent.id] = talent
                        end
                    end
                end
            end
        end

    end

    self:SendMessage(ns.CompanionsTracker.Events.GarrionDataUpdated, self.garrisonsData)
end


--- @private
function GarrisonDataCollector:GARRISON_SHIPMENT_RECEIVED()
    self:SHIPMENT_UPDATE(true)
end

--- @private
--- @param created boolean?
function GarrisonDataCollector:SHIPMENT_UPDATE(created)
    if(created) then
        C_Garrison.RequestLandingPageShipmentInfo()
    end
end