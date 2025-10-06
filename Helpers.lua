local addonName, addon = ...

local cooldownMaximum = 120 -- 2 Minutes
local cooldownMinimum = 0.05
local cooldownQueue = {}

function addon:DebouncePrivate(key, delay, func)
	if type(delay) ~= "number" or delay ~= delay then
		delay = 3
	elseif delay < cooldownMinimum then
		delay = cooldownMinimum
	elseif delay > cooldownMaximum then
		delay = cooldownMaximum
	end

	local entry = cooldownQueue[key]

	if entry and entry.timer then
		entry.timer.cancelled = true
	end

	entry = { cancelled = false }
	cooldownQueue[key] = entry

	C_Timer.After(delay, function()
		if entry.cancelled then
			return
		end

		cooldownQueue[key] = nil

		local ok, err = pcall(func)
		if not ok then
			geterrorhandler()(err)
		end
	end)
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
