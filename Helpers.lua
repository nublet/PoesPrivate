local addonName, addon = ...

local debounceMaximum = 120 -- 2 Minutes
local debounceMinimum = 0.05
local debounceQueue = {}

function addon:Debounce(key, delay, func)
    if InCombatLockdown() then
        return
    end

    delay = tonumber(delay) or 3
    delay = math.min(math.max(delay, debounceMinimum), debounceMaximum)

    local entry = debounceQueue[key]

    if entry and entry.timer then
        entry.timer.cancelled = true
    end

    entry = { cancelled = false }
    debounceQueue[key] = entry

    C_Timer.After(delay, function()
        if debounceQueue[key] == nil or entry.cancelled then
            return
        end

        debounceQueue[key] = nil

        func()
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
