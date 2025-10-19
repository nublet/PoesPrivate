local addonName, addon = ...

local debounceMaximum = 120 -- 2 Minutes
local debounceMinimum = 0.05
local debounceQueue = {}

local function SafeCall(func, ...)
	if InCombatLockdown() then
		return false, "InCombatLockdown"
	end
	local ok, err = pcall(func, ...)
	if not ok then
		if err and not err:match("ADDON_ACTION_BLOCKED") then
			geterrorhandler()(err)
		end
	end
	return ok, err
end

function addon:Debounce(key, delay, func)
	local entry      = debounceQueue[key]
	local queueCalls = entry and entry.queueCalls + 1 or 1

	if entry then
		entry.isCancelled = true
		if entry.timer then
			entry.timer:Cancel()
		end
	end

	if queueCalls > 5 then
		debounceQueue[key] = nil

		if InCombatLockdown() then
			return
		end

		SafeCall(func)

		return
	end

	delay = tonumber(delay) or 3
	delay = math.min(math.max(delay, debounceMinimum), debounceMaximum)

	entry = {
		isCancelled = false,
		queueCalls = queueCalls
	}

	entry.timer = C_Timer.NewTimer(delay, function()
		local existing = debounceQueue[key]

		debounceQueue[key] = nil

		if existing == nil or entry.isCancelled then
			return
		end

		if InCombatLockdown() then
			return
		end

		SafeCall(func)
	end)

	debounceQueue[key] = entry
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
