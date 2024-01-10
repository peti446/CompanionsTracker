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

    -- Data storage
    table.insert(self.garrisonTypesTracked, data.garrisonType)
    for _, followerID in ipairs(data.followersID) do
        table.insert(self.garrisonFollowersTracked, followerID)
        self.followerTypeToGarrisonType[followerID] = data.garrisonType
    end

    C_Garrison.RequestLandingPageShipmentInfo()
end


--- @private
function GarrisonDataCollector:GARRISON_MISSION_LIST_UPDATE(followerTypeArray)
    local currentTime = time()
    for id, _amount in ipairs(followerTypeArray) do
        if(not Utils:TableHasValue(self.garrisonFollowersTracked, id)) then
            return
        end

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
        self.garrisonsData[garrisonID][id] = self.garrisonsData[garrisonID][id] or {}
        self.garrisonsData[garrisonID][id].missionsAvailable = missionsAvailable
        self.garrisonsData[garrisonID][id].missionsInProgress = missionsInProgress
        self.garrisonsData[garrisonID][id].missionsCompleted = missionsCompleted
    end
end

--- @private
function GarrisonDataCollector:GARRISON_FOLLOWER_LIST_UPDATE(followerTypeArray)
    for id, _amount in ipairs(followerTypeArray) do
        if(not Utils:TableHasValue(self.garrisonFollowersTracked, id)) then
            return
        end
        local followers = C_Garrison.GetFollowers(id)
        local garrisonID = self.followerTypeToGarrisonType[id]
        self.garrisonsData[garrisonID] = self.garrisonsData[garrisonID] or {}
        self.garrisonsData[garrisonID][id] = self.garrisonsData[garrisonID][id] or {}
        self.garrisonsData[garrisonID][id].followers = followers
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
                    garrisonData.buildingsShipment[buildingID] = C_Garrison.GetLandingPageShipmentInfo(buildingID)
                end
            end
        end

        for _, followerShipmentID in ipairs(followerShipments) do
            local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, _, _, _, _, followerID = C_Garrison.GetLandingPageShipmentInfoByContainerID(followerShipmentID);
            if ( name and shipmentCapacity > 0) then
                garrisonData.followersShipments = garrisonData.followersShipments or {}
                garrisonData.followersShipments[followerShipmentID] = C_Garrison.GetLandingPageShipmentInfoByContainerID(followerShipmentID)
            end
        end

        for _, loseShipmentID in ipairs(looseShipments) do
            local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString = C_Garrison.GetLandingPageShipmentInfoByContainerID(loseShipmentID);
            if ( name and shipmentCapacity > 0 ) then
                garrisonData.looseShipments = garrisonData.looseShipments or {}
                garrisonData.looseShipments[loseShipmentID] = C_Garrison.GetLandingPageShipmentInfoByContainerID(loseShipmentID)
            end
        end

        if (talentTreeIDs) then
            for _, treeID in ipairs(talentTreeIDs) do
                local treeInfo = C_Garrison.GetTalentTreeInfo(treeID);
                for _, talent in ipairs(treeInfo.talents) do
                    if talent.isBeingResearched or talent.id == completeTalentID then
                    end
                end
            end
        end
    end
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