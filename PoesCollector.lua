local addonName, addon = ...

local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("font", "Naowh", [[Interface\FONTS\Naowh.ttf]])

local character = {}
local defaultPoesCollector = {
	version = 9158,
	chars = {},
}

function ClearActionBars()
	for i = 1, 180 do
		PickupAction(i)
		PutItemInBackpack()
		ClearCursor()
	end
end

function GetGoldString(copper)
	copper = tonumber(copper or 0)

	local copperString = format(" %02d", (copper % 100)) .. "|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t"
	local gold = floor(copper / 10000)
	local goldString = ""
	local isNegative = false
	local silverString = format(" %02d", (floor(copper / 100) % 100)) ..
		"|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t"

	if gold == 0 then
		goldString = "0"
	end

	if gold < 0 then
		isNegative = true
		gold = abs(gold)
	end

	while (gold > 1000) do
		goldString = ", " .. format("%03d", (gold % 1000)) .. goldString
		gold = floor(gold / 1000)
	end

	goldString = gold .. goldString

	if isNegative then
		goldString = "-" .. goldString
	end

	return strjoin("", goldString, "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", silverString, copperString)
end

function ListActionBars()
	local numGeneral, numCharacter = GetNumMacros()

	for slot = 1, 180 do
		local actionType, actionID, actionSubType = GetActionInfo(slot)
		local actionText = GetActionText(slot)

		if actionType then
			if actionType == "companion" then
				print("LoadSpell(", slot, ",", actionID, ")")
			elseif actionType == "item" then
				print("LoadItem(", slot, ",", actionID, ")")
			elseif actionType == "macro" then
				local macroName, macroIcon, macroBody = GetMacroInfo(actionText)

				print("LoadMacro(", slot, ",", actionID, ",\"", macroName, "\")", ", actionText:", actionText)
			elseif actionType == "spell" then
				print("LoadSpell(", slot, ",", actionID, ")")
			elseif actionType == "summonmount" then
				local mountID = tonumber(actionID) or -1
				if mountID > 0 then
					local _, spellID = C_MountJournal.GetMountInfoByID(mountID)

					print("LoadSpell(", slot, ",", spellID, ")")
				end
			else
				print("actionType:", actionType)
			end
		end
	end
end

function LoadActionBars()
	-- Action Bar 1
	LoadMacro(5, "UseGear")
	-- Action Bar 2
	LoadMacro(63, "Kick")
	LoadItem(65, 188152)
	LoadMacro(71, "PotHealthstone")
	-- Action Bar 3
	LoadSpell(52, 460905)
	LoadMacro(57, "Trinket")
	-- Action Bar 4
	LoadMacro(25, "Leave Party")
	LoadMacro(27, "PotHP")
	LoadMacro(28, "TBE: Random Toy")
	LoadMacro(35, "Inspect")
	LoadMacro(36, "ClearTarget")
	-- Action Bar 5
	LoadMacro(37, "ResetInstances")
	LoadSpell(39, 1236723)
	LoadSpell(40, 13262)
	-- Action Bar 6
	LoadMacro(145, "LFGTeleport")
	LoadMacro(146, "FocusMark")
	-- LoadMacro(147, "_LegionRemix")
	LoadSpell(148, 390392) -- Herbalism
	LoadSpell(148, 442615) -- Skinning
	LoadSpell(148, 388213) -- Mining
	LoadMacro(149, "FocusMark")
	LoadSpell(150, 423395) -- Herbalism
	LoadSpell(150, 440977) -- Skinning
	LoadSpell(150, 423394) -- Mining
	LoadItem(151, 85500)
	LoadSpell(152, 376912)
	LoadMacro(154, "PotDPS")
	LoadMacro(155, "FocusClear")
	-- Action Bar 7
	LoadItem(158, 193000)
	LoadMacro(159, " ")
	LoadSpell(160, 134359)
	LoadSpell(161, 1224048)
	LoadSpell(164, 446052)
	LoadMacro(165, "Mark")
	LoadItem(166, 275988)
	LoadSpell(167, 466133)
	LoadMacro(168, "ToggleBars")
	-- Action Bar 8
	LoadMacro(169, "MountRandom")
	LoadMacro(170, "TBE: Random Toy")
	LoadMacro(172, "MountLongBoi")
	LoadMacro(175, "Mount2Person")
	LoadMacro(178, "MountYak")

	-- Dragonriding
	LoadSpell(121, 372608)
	LoadSpell(122, 372610)
	LoadSpell(123, 361584)
	LoadSpell(124, 425782)
	LoadSpell(125, 403092)
	LoadSpell(126, 374990)

	-- Racials - Alliance
	LoadSpell(58, 265221) -- Dark Iron Dwarf - Fireblood
	LoadSpell(58, 59547) -- Draenei - Gift of the Naaru
	LoadSpell(58, 20594) -- Dwarf - Stoneform
	LoadSpell(58, 436344) -- Earthen - Azerite Surge
	LoadSpell(58, 20589) -- Gnome - Escape Artist
	LoadSpell(58, 59752) -- Human - Will to Survive
	LoadSpell(58, 287712) -- Kul Tiran - Haymaker
	LoadSpell(58, 255647) -- Lightforged Draenei - Light's Judgment
	LoadSpell(58, 312924) -- Mechagnome - Hyper Organic Light Originator
	LoadSpell(58, 58984) -- Night Elf - Shadowmeld
	LoadSpell(58, 256948) -- Void Elf - Spatial Rift
	-- Racials - Horde
	LoadSpell(58, 69179) -- Blood Elf - Arcane Torrent
	LoadSpell(58, 202719) -- Blood Elf - Arcane Torrent
	LoadSpell(58, 69041) -- Goblin - Rocket Barrage
	LoadSpell(58, 255654) -- Highmountain Tauren - Bull Rush
	LoadSpell(58, 274738) -- Mag'har Orc - Ancestral Call
	LoadSpell(58, 260364) -- Nightborne - Arcane Pules
	LoadSpell(58, 20572) -- Orc - Blood Fury
	LoadSpell(58, 107079) -- Pandaren - Quaking Palm
	LoadSpell(58, 20549) -- Tauren - War Stomp
	LoadSpell(58, 26297) -- Troll - Berserking
	LoadSpell(58, 7744) -- Undead - Will of the Forsaken
	LoadSpell(58, 256948) -- Void Elf - Spatial Rift
	LoadSpell(58, 312411) -- Vulpera - Bag of Tricks
	LoadSpell(58, 291944) -- Zandalari Troll - Regeneratin'
end

function LoadItem(actionSlot, itemId)
	ClearCursor()
	C_Item.PickupItem(itemId)
	--if GetCursorInfo()then
	PlaceAction(actionSlot)
	--end
end

function LoadMacro(actionSlot, macroName)
	ClearCursor()
	if macroName then
		local macroSlot = GetMacroIndexByName(macroName)

		if macroSlot and macroSlot > 0 then
			PickupMacro(macroSlot)
			if GetCursorInfo() then
				PlaceAction(actionSlot)
			end
		end
	end
end

function LoadCompanion(actionSlot, companionIndex, companionType)
	ClearCursor()
	PickupCompanion(companionType, companionIndex)
	if GetCursorInfo() then
		PlaceAction(actionSlot)
	end
end

function LoadSpell(actionSlot, spellId)
	ClearCursor()
	C_Spell.PickupSpell(spellId)
	if GetCursorInfo() then
		PlaceAction(actionSlot)
	end
end

function LoadToy(actionSlot, toyId)
	ClearCursor()
	C_ToyBox.PickupToyBoxItem(toyId)
	--if GetCursorInfo()then
	PlaceAction(actionSlot)
	--end
end

function PoesCollectorCommands(msg, editbox)
	if InCombatLockdown() then
		return
	end

	if msg == "clear" then
		ClearActionBars()
	elseif msg == "clearall" or msg == "ca" then
		ClearActionBars()
	elseif msg == "drop" then
		for i = 1, C_QuestLog.GetNumQuestLogEntries() do
			C_QuestLog.SetSelectedQuest(C_QuestLog.GetInfo(i).questID)
			C_QuestLog.SetAbandonQuest()
			C_QuestLog.AbandonQuest()
		end
	elseif msg == "list" then
		ListActionBars()
	elseif msg == "load" then
		SetProfiles("Poesboi")
		LoadActionBars()
	elseif msg == "reset" then
		SetProfiles("Poesboi")
		ClearActionBars()
		LoadActionBars()
	elseif msg == "share" then
		print("\124cFF0088FFpoesCollector: \124r Sharing Quests...")
		ShareCurrentQuests(1)
	elseif msg == "toggle" then
		ToggleActionBars()
	else
		print("\124cFF0088FFpoesCollector: \124r Unknown Command:", msg)
	end
end

function SetProfiles(profileName)
	local AceAddon = LibStub("AceAddon-3.0", true)
	if not AceAddon then
		print("\124cFF0088FFpoesPrivate: \124r AceAddon-3.0 NOT Loaded.")
		return
	end

	for addonName, addonObject in pairs(AceAddon.addons) do
		if addonObject.db and addonObject.db.SetProfile then
			local currentProfile = addonObject.db:GetCurrentProfile()

			if currentProfile ~= profileName then
				print("\124cFF0088FFpoesPrivate: \124r Updated Profile For " .. addonName .. " To " .. profileName)
				pcall(function() addonObject.db:SetProfile(profileName) end)
			end
		end
	end
end

function SetTrackingOptions()
	for i = 0, C_Minimap.GetNumTrackingTypes(), 1 do
		local info = C_Minimap.GetTrackingInfo(i)
		-- DevTools_Dump(info)

		if info then
			if not info.active then
				local shouldEnable = false;

				if info.name == "Ammunition" then
					shouldEnable = true;
				elseif info.name == "Auctioneer" then
					shouldEnable = true;
				elseif info.name == "Banker" then
					shouldEnable = true;
				elseif info.name == "Barber" then
					shouldEnable = true;
				elseif info.name == "Battlemaster" then
					shouldEnable = true;
				elseif info.name == "Class Trainer" then
					shouldEnable = true;
				elseif info.name == "Find Fish" then
					shouldEnable = true;
				elseif info.name == "Find Herbs" then
					shouldEnable = true;
				elseif info.name == "Find Minerals" then
					shouldEnable = true;
				elseif info.name == "Flight Master" then
					shouldEnable = true;
				elseif info.name == "Focus Target" then
					shouldEnable = true;
				elseif info.name == "Food & Drink" then
					shouldEnable = true;
				elseif info.name == "Innkeeper" then
					shouldEnable = true;
				elseif info.name == "Item Upgrade" then
					shouldEnable = true;
				elseif info.name == "Low-Level Quests" then
					shouldEnable = false;
				elseif info.name == "Mailbox" then
					shouldEnable = true;
				elseif info.name == "Points of Interest" then
					shouldEnable = true;
				elseif info.name == "Poisons" then
					shouldEnable = true;
				elseif info.name == "Profession Trainers" then
					shouldEnable = true;
				elseif info.name == "Reagents" then
					shouldEnable = true;
				elseif info.name == "Repair" then
					shouldEnable = true;
				elseif info.name == "Stable Master" then
					shouldEnable = true;
				elseif info.name == "Target" then
					shouldEnable = true;
				elseif info.name == "Track Digsites" then
					shouldEnable = true;
				elseif info.name == "Track Pets" then
					shouldEnable = true;
				elseif info.name == "Track Quest POIs" then
					shouldEnable = true;
				elseif info.name == "Track Warboards" then
					shouldEnable = true;
				elseif info.name == "Transmogrifier" then
					shouldEnable = true;
				elseif info.name == "Warband Completed Quests" then
					shouldEnable = true;
				elseif info.name == "Sense Undead" then
					-- shouldEnable = true;
				elseif info.name == "Track Beasts" then
				elseif info.name == "Track Demons" then
				elseif info.name == "Track Dragonkin" then
				elseif info.name == "Track Elementals" then
				elseif info.name == "Track Giants" then
				elseif info.name == "Track Hidden" then
					shouldEnable = true;
				elseif info.name == "Track Humanoids" then
				elseif info.name == "Track Mechanicals" then
				elseif info.name == "Track Undead" then
				else
					print("\124cFF0088FFpoesCollector: \124r", "Unhandled tracking name:", info.name)
				end

				if shouldEnable then
					C_Minimap.SetTracking(i, true)
					print("\124cFF0088FFpoesCollector: \124r", info.name, "Enabled.")
				end
			end
		end
	end
end

function ShareCurrentQuests(questLogId)
	local info = C_QuestLog.GetInfo(questLogId)

	if not info then
		print("\124cFF0088FFpoesPrivate: \124r Complete. Count:", questLogId)
		return
	end

	if not info.isHeader then
		QuestLogPushQuest()
	end

	C_Timer.After(1, function() ShareCurrentQuests(questLogId + 1) end)
end

function ToggleActionBars()
	if InCombatLockdown() or C_Secrets.ShouldAurasBeSecret() then
		return
	end

	local bars = { MainActionBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight, MultiBar5, PetActionBar, StanceBar }
	local isShown = MultiBarBottomLeft:IsShown()
	local visibilityMain = isShown and "[advflyable,mounted][advflyable,form:3][bonusbar:5][overridebar][possessbar][vehicleui] show; hide" or "show"
	local visibilityOther = isShown and "hide" or "show"

	for i = 1, #bars do
		local bar = bars[i]

		if bar then
			UnregisterStateDriver(bar, "visibility")

			if i == 1 then
				RegisterStateDriver(bar, "visibility", visibilityMain)
			else
				if visibilityOther == "hide" then
					bar:SetAlpha(0)
				else
					bar:SetAlpha(1)
				end

				RegisterStateDriver(bar, "visibility", visibilityOther)
			end
		end
	end

	MultiBar6:SetAlpha(1)
	RegisterStateDriver(MultiBar6, "visibility", "show")

	MultiBar7:SetAlpha(1)
	RegisterStateDriver(MultiBar7, "visibility", "show")
end

local function OnEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		if PoesCollector == nil or PoesCollector.version < defaultPoesCollector.version then
			PoesCollector = defaultPoesCollector
		end

		local guid = UnitGUID('player')
		if not guid then
			return
		end

		character.regionName = GetCurrentRegion()
		character.charFaction = select(1, UnitFactionGroup('player'))
		character.charName = guid
		character.charClassID = select(3, UnitClass('player'))

		local nameFirst, nameSecond = UnitFullName('player')

		character.charData = PoesCollector.chars[character.charName] or {}
		character.charData.nameFirst = nameFirst
		character.charData.nameSecond = nameSecond

		PoesCollector.chars[character.charName] = character.charData
	elseif event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
		local msg = ...

		local factionName = msg:lower():match("reputation with (.+) increased")

		if factionName then
			for i = 1, C_Reputation.GetNumFactions() do
				local factionData = C_Reputation.GetFactionDataByIndex(i)
				if factionData then
					if factionData.name:lower() == factionName and not factionData.isHeader then
						C_Reputation.SetWatchedFactionByIndex(i)
						break
					end
				end
			end
		end
	elseif event == "MERCHANT_SHOW" then
		if not CanMerchantRepair() then
			return
		end

		local cost, canRepair = GetRepairAllCost()
		if cost <= 0 then
			return
		end
		if not canRepair then
			return
		end

		local playerMoney = GetMoney()
		local canUseGuild, guildMoney = CanGuildBankRepair()

		if canUseGuild and (not guildMoney or guildMoney >= cost) then
			RepairAllItems(true)
			print("\124cFF0088FFpoesCollector: \124r", "Repaired using guild funds:", GetGoldString(cost))
		elseif playerMoney >= cost then
			RepairAllItems(false)
			print("\124cFF0088FFpoesCollector: \124r", "Repaired using personal gold:", GetGoldString(cost))
		else
			print("\124cFF0088FFpoesCollector: \124r", "Not enough gold (guild or personal) to repair gear!")
		end
	elseif event == "MINIMAP_UPDATE_TRACKING" then
		addon:Debounce("SetTrackingOptions", 3, function()
			SetTrackingOptions()
		end)
	elseif event == "PLAYER_ENTERING_WORLD" then
		character.charData.copper = GetMoney()
		character.charData.lastSeen = time()
	elseif event == "PLAYER_LOGIN" then
		C_CVar.SetCVar("alwaysCompareItems", 1)
		C_CVar.SetCVar("displaySpellActivationOverlays", 1)
		C_CVar.SetCVar("outlineModeShowLootEffectWhenDisabled", 1)
		C_CVar.SetCVar("spellActivationOverlayOpacity", 0.65)
		C_CVar.SetCVar("TurnSpeed", 150)

		C_CVar.RegisterCVar("addonProfilerEnabled", 1)
		C_CVar.SetCVar("addonProfilerEnabled", 0)

		PetFrame:UnregisterEvent("UNIT_COMBAT")
		PlayerFrame:UnregisterEvent("UNIT_COMBAT")
		TargetFrame:UnregisterEvent("UNIT_COMBAT")

		IconIntroTracker.RegisterEvent = function() end
		IconIntroTracker:UnregisterEvent('SPELL_PUSHED_TO_ACTIONBAR')

		CharacterFrame:ClearAllPoints()
		CharacterFrame:SetPoint("TOPLEFT", UIParent, "CENTER", -270, 105)

		addon:Debounce("PLAYER_LOGIN", 3, function()
			ToggleActionBars()

			local numEntries = C_QuestLog.GetNumQuestLogEntries()

			for i = 1, numEntries do
				local questInfo = C_QuestLog.GetInfo(i)
				if questInfo and not questInfo.isHeader and questInfo.questID then
					if C_QuestLog.GetQuestWatchType(questInfo.questID) then
						C_QuestLog.RemoveQuestWatch(questInfo.questID)
					end
				end
			end
		end)

		addon:Debounce("SetTrackingOptions", 3, function()
			SetTrackingOptions()
		end)
	elseif event == "PLAYER_LOGOUT" then
		character.charData.lastSeen = time()
	elseif event == "PLAYER_MONEY" then
		character.charData.copper = GetMoney()
	elseif event == "PLAYER_REGEN_ENABLED" then
		addon:ProcessOocQueue()
	elseif event == "SPELL_PUSHED_TO_ACTIONBAR" then
		if InCombatLockdown() or C_Secrets.ShouldAurasBeSecret() then
			return
		end

		local spellID, slotIndex, slotPos = ...

		ClearCursor()
		PickupAction(slotIndex)
		ClearCursor()
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		addon:Debounce("SetTrackingOptions", 3, function()
			SetTrackingOptions()
		end)
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
f:RegisterEvent("MERCHANT_SHOW")
f:RegisterEvent("MINIMAP_UPDATE_TRACKING")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("PLAYER_MONEY")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:SetScript("OnEvent", OnEvent)

f:SetSize(1, 1)
f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
f:Hide()

SLASH_PBC1 = "/pbc"
SlashCmdList["PBC"] = PoesCollectorCommands

SLASH_RELOADUI1 = "/rl"
SlashCmdList["RELOADUI"] = function()
	ReloadUI()
end
