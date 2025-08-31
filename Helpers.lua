local addonName, addon = ...

local DebounceTimers = {}

function addon:Debounce(key, delay, func)
	-- Cancel any existing timer for this key
	if DebounceTimers[key] then
		DebounceTimers[key]:Cancel()
	end

	-- Create a new timer and store it
	DebounceTimers[key] = C_Timer.NewTimer(delay, function()
		func()
		DebounceTimers[key] = nil
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
