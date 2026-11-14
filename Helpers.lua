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

function addon:ProcessOocQueue()
	for key, func in pairs(oocQueue) do
		if InCombatLockdown() or C_Secrets.ShouldAurasBeSecret() then
		else
			SafeCall(func)
			oocQueue[key] = nil
		end
	end
end
