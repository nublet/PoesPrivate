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
