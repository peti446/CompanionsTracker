local ns = select(2, ...)
--- @class NotificationsModule : AceTimer-3.0, AceModule
local Notifications = ns.CompanionsTracker:NewModule("Notifications", "AceTimer-3.0")

local function Setup(frame, classID, characterName, missionName)
    local className = select(2, GetClassInfo(classID))
    frame.icon:SetAtlas("ClassHall-Circle-" .. className)
    frame.title:SetText(missionName)
    frame.characterText:SetText(C_ClassColor.GetClassColor(className):WrapTextInColorCode(characterName))
end

function Notifications:OnInitialize()
    self.alertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("CompanionsTrackerMissionNotification", Setup, 3, 15)
    self.registeredTimer = {}
    self.disabledCharacters = {}
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
                local id = self:ScheduleTimer("ShowNotification", timeLeft, classID, characterName, expansionID, missionName)
                table.insert(self.registeredTimer, id)
            else
                self:ShowNotification(classID, characterName, expansionID, missionName)
            end
        end
    end

    for _, missionDataList in ipairs(garrisonData.missionsCompleted or {}) do
        for _, missionData in ipairs(missionDataList) do
            local missionName = missionData.missionName
            self:ShowNotification(classID, characterName, expansionID, missionName)
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
        self.alertSystem:AddAlert(classID, characterName, missionName)
    end
end