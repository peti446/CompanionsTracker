local ns = select(2, ...)
--- @class NotificationsModule : AceTimer-3.0, AceEvent-3.0, AceModule
local Notifications = ns.CompanionsTracker:NewModule("Notifications", "AceTimer-3.0", "AceEvent-3.0")
--- @type AceLocale-3.0
local L = ns.L

--- @class CompanionsTrackerConfig
local Config = ns.Config

local function Setup(frame, classID, characterName, missionName)
    local className = select(2, GetClassInfo(classID))
    frame.icon:SetAtlas("ClassHall-Circle-" .. className)
    frame.title:SetText(missionName)
    frame.characterText:SetText(C_ClassColor.GetClassColor(className):WrapTextInColorCode(characterName))
end

function Notifications:OnInitialize()
    self.alertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("CompanionsTrackerMissionNotification", Setup, 4, 15)
    self.registeredTimer = {}
    self.disabledCharacters = {}
    self.pendingNotifications = {}
end

function Notifications:OnDisable()
    for _, id in ipairs(self.registeredTimer) do
        self:CancelTimer(id)
    end
end

--- Gets if a character is enabled for a specific expansion id
---@param expansionID number The expansion ID
---@param characterName string The name of the character
---@return boolean
function Notifications:IsCharacterEnabled(expansionID, characterName)
    if(not self:IsEnabled()) then
        return false
    end

    local expansionData = self.disabledCharacters[expansionID]
    if(expansionData) then
        if(expansionData.enabled == false) then
            return false
        end
        if(type(expansionData.charsName[characterName]) == "boolean") then
            return expansionData.charsName[characterName]
        end
        return true
    end
    return true
end

--- Set an exapnsion enabled or disabled
---@param expansionID number The expansion ID
---@param enabled boolean The enable status of the exapnsion
function Notifications:SetExpansionEnabled(expansionID, enabled)
    self.disabledCharacters[expansionID] = self.disabledCharacters[expansionID] or {}
    self.disabledCharacters[expansionID].enabled = enabled
end

--- Sets a caracter state
---@param characterName string The character name
---@param expansionID number The expansion ID
---@param enabled boolean The enable status of the character
function Notifications:SetCharacterState(characterName, expansionID, enabled)
    self.disabledCharacters[expansionID] = self.disabledCharacters[expansionID] or {}
    self.disabledCharacters[expansionID].charsName = self.disabledCharacters[expansionID].charsName or {}
    self.disabledCharacters[expansionID].charsName[characterName] = enabled
end

--- Registers missions to show as a notification
---@param characterName string
---@param expansionID number The expansion ID
---@param garrisonData table The garrison data
function Notifications:RegisterCharacter(characterName, expansionID, garrisonData, classID)
    for _, missionDataList in ipairs(garrisonData.missionsInProgress or {}) do
        for _, missionData in ipairs(missionDataList) do
            local missionName = missionData.name
            local timeLeft = missionData.missionEndTime - time()
            if(timeLeft > 0 and not missionData.completed) then
                ---@diagnostic disable-next-line: param-type-mismatch
                local id = self:ScheduleTimer("ShowNotification", timeLeft, classID, characterName, expansionID, missionName)
                table.insert(self.registeredTimer, id)
            else
                self:ShowNotification(classID, characterName, expansionID, missionName)
            end
        end
    end

    for _, missionDataList in ipairs(garrisonData.missionsCompleted or {}) do
        for _, missionData in ipairs(missionDataList) do
            local missionName = missionData.name
            self:ShowNotification(classID, characterName, expansionID, missionName)
        end
    end


    -- Do shipments notifiactionr registration
    for _type, shipmentDataList in pairs(garrisonData.shipmentsData) do
        for _, shipmentData in ipairs(shipmentDataList) do
            if(shipmentData.duration ~= nil) then
                local missionName = L['Shipmnet: %s']:format(shipmentData.name)
                local timeLeft = shipmentData.duration - time()
                if(timeLeft <= 0) then
                    self:ShowNotification(classID, characterName, expansionID, shipmentData.name)
                else
                    local index = 0
                    while index < shipmentData.shipmentsTotal do
                        ---@diagnostic disable-next-line: param-type-mismatch
                        local id = self:ScheduleTimer("ShowNotification", timeLeft + (index*shipmentData.duration), classID, characterName, expansionID, missionName)
                        table.insert(self.registeredTimer, id)
                        index = index + 1
                    end
                end
            end
        end
    end
end

---Displays the notification if the character is enabled
---@param classID number
---@param characterName string
---@param expansionID number
---@param missionName string
---@private
function Notifications:ShowNotification(classID, characterName, expansionID, missionName)
    if(self:IsCharacterEnabled(expansionID, characterName)) then
        if(not UnitAffectingCombat("player")) then
            self.alertSystem:AddAlert(classID, characterName, missionName)
        else
            table.insert(self.pendingNotifications, {classID, characterName, expansionID, missionName})
            self:RegisterEvent("PLAYER_REGEN_ENABLED", "ShowPendingNotifications")
        end
    end
end


---@private
function Notifications:ShowPendingNotifications()
    for _, data in ipairs(self.pendingNotifications) do
        if(Config.db.global.notifications.combatEndDelay > 0) then
            ---@diagnostic disable-next-line: param-type-mismatch
            self:ScheduleTimer("ShowNotification", Config.db.global.notifications.combatEndDelay, unpack(data))
        else
            self.alertSystem:AddAlert(unpack(data))
        end
    end
    self.pendingNotifications = {}
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end