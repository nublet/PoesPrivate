local addonName, addon = ...

local debounceMaximum = 120 -- 2 Minutes
local debounceMinimum = 0.05
local debounceQueue = {}
local oocQueue = {}

local function ErrorHandler(errMessage)
	local fullTrace = debug.traceback(tostring(errMessage), 2)

	geterrorhandler()(fullTrace)

	return errMessage
end

local function SafeCall(func, ...)
	if InCombatLockdown() then
		return false, "InCombatLockdown"
	end

	if C_Secrets.ShouldAurasBeSecret() then
		return false, "ShouldAurasBeSecret"
	end

	return xpcall(func, ErrorHandler, ...)
end

function addon:Debounce(key, delay, func)
	if oocQueue[key] then
		oocQueue[key] = func
		return
	end

	local entry = debounceQueue[key]
	local queueCalls = entry and entry.queueCalls + 1 or 1

	if entry and entry.timer then
		entry.timer:Cancel()
	end

	if queueCalls > 5 then
		debounceQueue[key] = nil

		if InCombatLockdown() or C_Secrets.ShouldAurasBeSecret() then
			oocQueue[key] = func
		else
			SafeCall(func)
		end

		return
	end

	delay = tonumber(delay) or 3
	delay = math.min(math.max(delay, debounceMinimum), debounceMaximum)

	local timer = C_Timer.NewTimer(delay, function()
		debounceQueue[key] = nil

		if InCombatLockdown() or C_Secrets.ShouldAurasBeSecret() then
			oocQueue[key] = func
		else
			SafeCall(func)
		end
	end)

	debounceQueue[key] = {
		timer = timer,
		queueCalls = queueCalls
	}
end

function addon:GetBagItems(itemID)
	local count = 0
	local slots = {}

	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.itemID == itemID then
				count = count + info.stackCount
				table.insert(slots, { bag = bag, slot = slot, count = info.stackCount })
			end
		end
	end

	return count, slots
end

function addon:GetNumberOrDefault(defaultValue, number)
	local valueNumber = addon:NormalizeNumber(number)

	if valueNumber then
		return valueNumber
	end

	return defaultValue
end

function addon:GetWarbankItems(itemID)
	local bankInfo = C_Bank.FetchDepositedItems(Enum.BankType.Account)
	local count = 0
	local slots = {}

	if bankInfo then
		for slotIndex, item in ipairs(bankInfo) do
			if item.itemID == itemID then
				count = count + item.stackCount
				table.insert(slots, { slot = slotIndex, count = item.stackCount })
			end
		end
	end

	return count, slots
end

function addon:IsAutoOpenItem(itemInfo)
	local bagItemName = C_Item.GetItemNameByID(itemInfo.itemID)

	for itemID, itemName in pairs(addon.autoOpenItems) do
		if itemInfo.itemID == itemID then
			return true
		end

		if bagItemName and bagItemName == itemName then
			return true
		end
	end

	return false
end

function addon:IsIgnoredItem(itemInfo)
	local bagItemName = C_Item.GetItemNameByID(itemInfo.itemID)

	for itemID, itemName in pairs(addon.ignoredItems) do
		if itemInfo.itemID == itemID then
			return true
		end

		if bagItemName and bagItemName == itemName then
			return true
		end
	end

	return false
end

function addon:NormalizeNumber(number)
	local valueString = ""

	if number then
		valueString = strtrim(number)
	end

	if valueString == "" then
		return -1
	end

	local valueNumber = tonumber(number) or -1

	if valueNumber < 0 then
		return -1
	end

	return valueNumber
end

function addon:NormalizeText(text)
	if not text then
		return ""
	end

	if text == "" then
		return ""
	end

	return text:lower():gsub("\r\n", "\n"):gsub("\r", "\n"):gsub("\n", "")
end

function addon:ProcessOocQueue()
	for key, func in pairs(oocQueue) do
		if InCombatLockdown() or C_Secrets.ShouldAurasBeSecret() then
		else
			SafeCall(func)
			oocQueue[key] = nil
		end
	end
end
