local addonName, addon = ...

local completedQuests = {}
local completedQuestsIsFirst = true
local questInformation = {}
local ordersUpdated = false

local function CheckCompletedQuest(questID)
	local questTitle = C_QuestLog.GetTitleForQuestID(questID)
	local chatMessage = "Quest completed: [" .. questID .. "] " .. questTitle

	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		C_ChatInfo.SendChatMessage(chatMessage, "INSTANCE_CHAT")
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		C_ChatInfo.SendChatMessage(chatMessage, "PARTY")
	else
		C_ChatInfo.SendChatMessage(chatMessage, "SAY")
	end
end

local function CheckQuestProgress(attemptNumber, questID)
	local objectives = C_QuestLog.GetQuestObjectives(questID)
	if not objectives then
		if attemptNumber >= 5 then
			print("\124cFF0088FFpoesPrivate: \124r Failed to get quest objectives:", questID)
			return
		end

		addon:Debounce("questProgress_" .. questID, 5, function()
			CheckQuestProgress(attemptNumber + 1, questID)
		end)

		return
	end

	local questTable = questInformation[questID] or {}

	questTable.isComplete = questTable.isComplete or false
	questTable.questValues = questTable.questValues or {}

	if questTable.isComplete then
		return
	end

	questTable.isComplete = true

	local wasUpdated = false

	for index, objective in ipairs(objectives) do
		local objectiveKey = questID .. ":" .. index

		local OldQuestValue = questTable.questValues[objectiveKey] or ""
		local NewQuestValue

		if objective.finished then
			NewQuestValue = "Complete"
		else
			questTable.isComplete = false

			if objective.text == nil or objective.text == "" then
				NewQuestValue = tostring(objective.numFulfilled or 0)
			else
				NewQuestValue = objective.text
			end
		end

		if not NewQuestValue then
			NewQuestValue = ""
		end

		if OldQuestValue ~= "" and OldQuestValue ~= NewQuestValue then
			wasUpdated = true
		end

		questTable.questValues[objectiveKey] = NewQuestValue
	end

	if questTable.isComplete and wasUpdated then
		addon:Debounce("checkCompletedQuest_" .. questID, 1, function()
			CheckCompletedQuest(questID)
		end)
	end

	if questTable.isComplete then
		C_QuestLog.AddQuestWatch(questID)
	elseif wasUpdated then
		C_QuestLog.AddQuestWatch(questID)
		C_QuestLog.SetSelectedQuest(questID)
	end

	questInformation[questID] = questTable
end

local function ExportMounts()
	PoesBarsMounts = {}

	for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
		local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected, mountID, isSteadyFlight =
			C_MountJournal.GetMountInfoByID(mountID)
		local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview =
			C_MountJournal.GetMountInfoExtraByID(mountID)

		table.insert(PoesBarsMounts, {
			name = name,
			spellID = spellID,
			icon = icon,
			isActive = isActive,
			isUsable = isUsable,
			sourceType = sourceType,
			isFavorite = isFavorite,
			isFactionSpecific = isFactionSpecific,
			faction = faction,
			shouldHideOnChar = shouldHideOnChar,
			isCollected = isCollected,
			mountID = mountID,
			isSteadyFlight = isSteadyFlight,
			creatureDisplayInfoID = creatureDisplayInfoID,
			description = description,
			source = source,
			isSelfMount = isSelfMount,
			mountTypeID = mountTypeID,
			uiModelSceneID = uiModelSceneID,
			animID = animID,
			spellVisualKitID = spellVisualKitID,
			disablePlayerMountPreview = disablePlayerMountPreview
		})
	end

	print("\124cFF0088FFpoesPrivate: \124r ExportMounts Complete.")
end

local function ExportPets()
	PoesBarsPets = {}

	local numPets, numOwned = C_PetJournal.GetNumPets()

	for i = 1, numPets do
		local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable =
			C_PetJournal.GetPetInfoByIndex(i)

		table.insert(PoesBarsPets, {
			petID = petID,
			speciesID = speciesID,
			owned = owned,
			customName = customName,
			level = level,
			favorite = favorite,
			isRevoked = isRevoked,
			speciesName = speciesName,
			icon = icon,
			petType = petType,
			companionID = companionID,
			tooltip = tooltip,
			description = description,
			isWild = isWild,
			canBattle = canBattle,
			isTradeable = isTradeable,
			isUnique = isUnique,
			obtainable = obtainable
		})
	end

	print("\124cFF0088FFpoesPrivate: \124r ExportPets Complete.")
end

local function ExportProfession()
	if not C_TradeSkillUI.IsTradeSkillReady() then
		print("\124cFF0088FFpoesPrivate: \124r C_TradeSkillUI NOT Ready.")
		return
	end

	local TempDB = {}

	for _, id in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
		local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)

		table.insert(TempDB, C_TradeSkillUI.GetRecipeSchematic(id, false))
		table.insert(TempDB, C_TradeSkillUI.GetRecipeSchematic(id, true))
	end

	local professionInfo = C_TradeSkillUI.GetBaseProfessionInfo()
	-- profession				Enum.Profession?	
	-- professionID				number	TradeSkillLineID of the parent tradeskill (i.e. Alchemy if this skill is Legion Alchemy)
	-- sourceCounter			number	Added in 10.1.0
	-- professionName			string	Localized name of the parent tradeskill.
	-- expansionName			string	Bugged, always appears "Unknown".
	-- skillLevel				number	Current skill level.
	-- maxSkillLevel			number	Maximum attainable skill level.
	-- skillModifier			number	Modifiers to the skill level (such as +mining, +cooking, etc).
	-- isPrimaryProfession		boolean	
	-- parentProfessionID		number?	
	-- parentProfessionName		string?

	if professionInfo then
		if professionInfo.profession then
			if professionInfo.profession == 0 then -- First Aid
				PoesBarsFirstAid = TempDB
			elseif professionInfo.profession == 1 then -- Blacksmithing
				PoesBarsBlacksmithing = TempDB
			elseif professionInfo.profession == 2 then -- Leatherworking
				PoesBarsLeatherworking = TempDB
			elseif professionInfo.profession == 3 then -- Alchemy
				PoesBarsAlchemy = TempDB
			elseif professionInfo.profession == 4 then -- Herbalism
				PoesBarsHerbalism = TempDB
			elseif professionInfo.profession == 5 then -- Cooking
				PoesBarsCooking = TempDB
			elseif professionInfo.profession == 6 then -- Mining
				PoesBarsMining = TempDB
			elseif professionInfo.profession == 7 then -- Tailoring
				PoesBarsTailoring = TempDB
			elseif professionInfo.profession == 8 then -- Engineering
				PoesBarsEngineering = TempDB
			elseif professionInfo.profession == 9 then -- Enchanting
				PoesBarsEnchanting = TempDB
			elseif professionInfo.profession == 10 then -- Fishing
				PoesBarsFishing = TempDB
			elseif professionInfo.profession == 11 then -- Skinning
				PoesBarsSkinning = TempDB
			elseif professionInfo.profession == 12 then -- Jewelcrafting
				PoesBarsJewelcrafting = TempDB
			elseif professionInfo.profession == 13 then -- Inscription
				PoesBarsInscription = TempDB
			elseif professionInfo.profession == 14 then -- Archaeology
				PoesBarsArchaeology = TempDB
			end
		end
	end

	print("\124cFF0088FFpoesPrivate: \124r ExportProfession Complete.", professionInfo.profession, professionInfo.professionName)
end

local function ExportToys()
	PoesBarsToys = {}

	local numToys = C_ToyBox.GetNumToys()

	for i = 1, numToys do
		local indexItemID = C_ToyBox.GetToyFromIndex(i)

		if indexItemID then
			local itemID, toyName, icon, isFavorite, hasFanfare, itemQuality = C_ToyBox.GetToyInfo(indexItemID)
			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent =
				C_Item.GetItemInfo(indexItemID)

			table.insert(PoesBarsToys, {
				indexItemID = indexItemID,
				toyName = toyName,
				icon = icon,
				isFavorite = isFavorite,
				hasFanfare = hasFanfare,
				itemQuality = itemQuality,
				expansionID = expansionID
			})
		end
	end

	print("\124cFF0088FFpoesPrivate: \124r ExportToys Complete.")
end

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
	LoadMacro(147, "_LegionRemix")
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

function MarkParty()
	local ROLEMARKS = { ["TANK"] = 6, ["HEALER"] = 5 }
	local role = UnitGroupRolesAssigned("player")

	if role then
		if ROLEMARKS[role] then
			SetRaidTarget("player", ROLEMARKS[role])
		end
	end

	for i = 1, 4 do
		local role = UnitGroupRolesAssigned("party" .. i)

		if role then
			local unit = "party" .. i

			if ROLEMARKS[role] then
				SetRaidTarget(unit, ROLEMARKS[role])

				local localizedClass, englishClass, classIndex = UnitClass("player")
				local macroSlot

				if role == "HEALER" then
					macroSlot = GetMacroIndexByName("Freedom")
					if macroSlot and macroSlot > 0 then
						EditMacro(macroSlot, "Freedom", 134400,
							"#showtooltip" ..
							string.char(10) ..
							"/cast [@mouseover, exists, help][@focus, exists, help][@Trustfall, exists][@" ..
							unit .. ", exists][] Blessing of Freedom")
					end

					macroSlot = GetMacroIndexByName("Innervate")
					if macroSlot and macroSlot > 0 then
						EditMacro(macroSlot, "Innervate", 134400,
							"#showtooltip" ..
							string.char(10) ..
							"/cast [@mouseover, exists, help][@focus, exists, help][@" .. unit .. ", exists][] Innervate")
					end
				end

				if role == "TANK" then
					macroSlot = GetMacroIndexByName("Misdirection")
					if macroSlot and macroSlot > 0 then
						EditMacro(macroSlot, "Misdirection", 132180,
							"#showtooltip" ..
							string.char(10) ..
							"/cast [@mouseover, exists, help][@focus, exists, help][@Brann Bronzebeard, exists, help][@" ..
							unit .. ", exists][@targettarget, exists, help][@Pet, nodead, exists][] Misdirection")
					end

					macroSlot = GetMacroIndexByName("Sacrifice")
					if macroSlot and macroSlot > 0 then
						EditMacro(macroSlot, "Sacrifice", 134400,
							"#showtooltip" ..
							string.char(10) ..
							"/cast [@mouseover, exists, help][@focus, exists, help][@" ..
							unit .. ", exists][@targettarget, exists, help][] Blessing of Sacrifice")
					end

					macroSlot = GetMacroIndexByName("Tricks")
					if macroSlot and macroSlot > 0 then
						EditMacro(macroSlot, "Tricks", 134400,
							"#showtooltip" ..
							string.char(10) ..
							"/cast [@mouseover, exists, help][@focus, exists, help][@Brann Bronzebeard, exists, help][@" ..
							unit .. ", exists][@targettarget, exists, help][] Tricks of the Trade")
					end
				end
			end
		end
	end
end

function ScanBagItems()
	if UnitOnTaxi("player") then
		return
	end

	if InCombatLockdown() then
		return
	end

	for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
			local itemInfo = C_Container.GetContainerItemInfo(bagID, slotID)
			if itemInfo and not itemInfo.isLocked then
				if not addon:IsIgnoredItem(itemInfo) then
					if itemInfo.hasLoot then
						C_Timer.After(0.5, function()
							if InCombatLockdown() then
								return
							end

							C_Container.UseContainerItem(bagID, slotID)
						end)

						return
					end

					if addon:IsAutoOpenItem(itemInfo) then
						C_Timer.After(0.5, function()
							if InCombatLockdown() then
								return
							end

							C_Container.UseContainerItem(bagID, slotID)
						end)

						return
					end
				end
			end
		end
	end
end

function ScanCompletedQuests()
	local knownQuestIDs = {
		82939, -- Fungal Folly
		82942, -- The Spiral Weave
		82944, -- Earthcrawl Mines
		85187, -- Excavation Site 9

		84294, -- Enchanting
		84295, -- Enchanting

		86371, -- Delver's Bounty
		87286 -- Underpin
	}

	-- Function to check if a questID is in the knownQuestIDs list
	local function isKnownQuest(questID)
		for _, id in ipairs(knownQuestIDs) do
			if id == questID then
				return true
			end
		end
		return false
	end

	for questID = 0, 200000 do
		if C_QuestLog.IsQuestFlaggedCompleted(questID) and not completedQuests[questID] then
			completedQuests[questID] = true

			if isKnownQuest(questID) or completedQuestsIsFirst then
			else
				local questTitle = C_QuestLog.GetTitleForQuestID(questID)

				if questTitle then
					print("\124cFF0088FFpoesPrivate: \124r Quest completed: [" .. questID .. "] " .. questTitle)
				else
					local questTagInfo = C_QuestLog.GetQuestTagInfo(questID)
					if questTagInfo then
						print("\124cFF0088FFpoesPrivate: \124r Quest completed: [" .. questTagInfo.tagName .. "]" .. questTitle)
					else
						print("\124cFF0088FFpoesPrivate: \124r Quest completed: [" .. questID .. "] Unknown Quest")
					end
				end
			end
		end
	end

	completedQuestsIsFirst = false
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

				if info.name == "Auctioneer" then
					shouldEnable = true;
				elseif info.name == "Banker" then
					shouldEnable = true;
				elseif info.name == "Barber" then
					shouldEnable = true;
				elseif info.name == "Battlemaster" then
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
					print("\124cFF0088FFpoesPrivate: \124r", "Unhandled tracking name:", info.name)
				end

				if shouldEnable then
					C_Minimap.SetTracking(i, true)
					print("\124cFF0088FFpoesPrivate: \124r", info.name, "Enabled.")
				end
			end
		end
	end
end

function ShareCurrentQuest(questLogId)
	local info = C_QuestLog.GetInfo(questLogId)

	if not info then
		print("\124cFF0088FFpoesPrivate: \124r Complete. Count:", questLogId)
		return
	end

	if not info.isHeader then
		QuestLogPushQuest()
	end

	C_Timer.After(1, function() ShareCurrentQuest(questLogId + 1) end)
end

function ToggleActionBars()
	if InCombatLockdown() then
		return
	end

	--local bars, E = { 1, 3, 4, 5, 6, 13 }, unpack(_G["ElvUI"])

	--local newState1 = E.db.actionbar["bar3"].visibility
	--local newState2

	--if newState1 == "show" then
	--newState1 = "hide"
	--newState2 = "[vehicleui][overridebar] show;hide"
	--else
	--newState1 = "show"
	--newState2 = "show"
	--end

	--for _, n in pairs(bars) do
	--if n == 1 then
	--E.db.actionbar["bar" .. n].visibility = newState2
	--else
	--E.db.actionbar["bar" .. n].visibility = newState1
	--end
	--E.ActionBars:PositionAndSizeBar("bar" .. n)
	--end

	local bars = { MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight, MultiBar5,
		PetActionBar, StanceBar }
	local isShown = MultiBarBottomLeft:IsShown()
	local visibilityMain = isShown and "hide" or "[vehicleui][overridebar][possessbar] hide; show"
	local visibilityOther = isShown and "hide" or "show"

	for index, bar in ipairs(bars) do
		UnregisterStateDriver(bar, "visibility")

		if index == 1 then
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

function PoesBarsCommands(msg, editbox)
	local titleIndex = GetCurrentTitle()
	local titleName, isPlayerTitle = GetTitleName(titleIndex)

	if titleName ~= "Predator " then
		for i = 1, GetNumTitles() do
			titleName, isPlayerTitle = GetTitleName(i)
			if titleName and titleName == "Predator " then
				SetCurrentTitle(i)
				print("\124cFF0088FFpoesPrivate: \124r Title changed to", titleName)
				break
			end
		end
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
	elseif msg == "exportAll" then
		ExportMounts()
		ExportPets()
		ExportToys()
	elseif msg == "exportMounts" then
		ExportMounts()
	elseif msg == "exportPets" then
		ExportPets()
	elseif msg == "exportProfession" then
		ExportProfession()
	elseif msg == "exportToys" then
		ExportToys()
	elseif msg == "list" then
		ListActionBars()
	elseif msg == "load" then
		SetProfiles("Poesboi")
		LoadActionBars()
	elseif msg == "mark" then
		MarkParty()
	elseif msg == "open" then
		ScanBagItems()
	elseif msg == "reset" then
		SetProfiles("Poesboi")
		ClearActionBars()
		LoadActionBars()
	elseif msg == "setBuddy" then
		local castTarget = GetUnitName("mouseover", true) or GetUnitName("target", true) or GetUnitName("party1", true)
		if not castTarget then
			castTarget = "player"
		end

		local spellName = C_Spell.GetSpellName(10060)
		local text = '#showtooltip ' .. spellName .. string.char(10) .. "/cast [@mouseover,exists,help][@" .. castTarget .. ",exists,help][@focus, exists, help][] " .. spellName

		local macroSlot = GetMacroIndexByName("PiBuddy")
		if macroSlot and macroSlot > 0 then
			EditMacro(macroSlot, "PiBuddy", 135939, text)
		else
			CreateMacro("PiBuddy", 135939, text)
		end
		print("\124cFF0088FFpoesPrivate: \124r PiBuddy set to " .. castTarget)
	elseif msg == "share" then
		print("\124cFF0088FFpoesPrivate: \124r Sharing Quests...")
		ShareCurrentQuest(1)
	elseif msg == "toggle" then
		ToggleActionBars()
	else
		print("\124cFF0088FFpoesPrivate: \124r Unknown Command:", msg)
	end
end

SLASH_PB1 = "/pb"

SlashCmdList["PB"] = PoesBarsCommands

local function OnEvent(self, event, ...)
	if event == "BAG_UPDATE_DELAYED" then
		addon:Debounce("scanBagItems", 1.5, function()
			ScanBagItems()
		end)
		addon:Debounce("scanCompletedQuests", 5, function()
			ScanCompletedQuests()
		end)
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
	elseif event == "MINIMAP_UPDATE_TRACKING" then
		addon:Debounce("SetTrackingOptions", 1, function()
			SetTrackingOptions()
		end)
	elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
		if event == "PLAYER_ENTERING_WORLD" then
			addon:Debounce("PlayerEnteringWorld", 1, function()
				local CT, ach = C_ContentTracking, Enum.ContentTrackingType.Achievement
				for i, id in ipairs(CT.GetTrackedIDs(ach)) do
					local _, n, _, c = GetAchievementInfo(id)
					if c then
						print("\124cFF0088FFpoesPrivate: \124r Clearing completed/tracked achieve:", n)
						CT.StopTracking(ach, id, 1)
					end
				end

				for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
					for slotIndex = 1, C_Container.GetContainerNumSlots(bagID) do
						local itemLink = C_Container.GetContainerItemLink(bagID, slotIndex)
						local itemID = itemLink and C_Item.GetItemInfoInstant(itemLink)

						if itemID then
							if itemID == 6948 or itemID == 223988 then
								ClearCursor()
								C_Container.PickupContainerItem(bagID, slotIndex)
								print("\124cFF0088FFpoesPrivate: \124r", "Hearthstone FOUND.")
							end
						end
					end
				end
			end)
		end

		addon:Debounce("ZoneChanged", 1, function()
			local inInstance, instanceType = IsInInstance()

			if inInstance then
				if instanceType == "party" then
					MarkParty()
				elseif instanceType == "scenario" then
					local macroSlot = GetMacroIndexByName("Misdirection")
					if macroSlot and macroSlot > 0 then
						EditMacro(macroSlot, "Misdirection", 132180, "#showtooltip" .. string.char(10) .. "/cast [@mouseover, exists, help][@focus, exists, help][@Brann Bronzebeard, exists, help][@Pet, nodead, exists][] Misdirection")
					end

					macroSlot = GetMacroIndexByName("Tricks")
					if macroSlot and macroSlot > 0 then
						EditMacro(macroSlot, "Tricks", 134400, "#showtooltip" .. string.char(10) .. "/cast [@mouseover, exists, help][@focus, exists, help][@Brann Bronzebeard, exists, help][@Pet, nodead, exists][] Tricks of the Trade")
					end
				end
			end
		end)

		addon:Debounce("SetTrackingOptions", 1, function()
			SetTrackingOptions()
		end)
	elseif event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" then
		local id = ...

		if id == Enum.PlayerInteractionType.Banker or Enum.PlayerInteractionType.AccountBanker then
			if C_Bank.CanDepositMoney(Enum.BankType.Account) == false then
				return
			end

			local playerName, playerRealm = UnitFullName("player")
			local playerLevel = UnitLevel("player")
			local warBankGold = C_Bank.FetchDepositedMoney(Enum.BankType.Account)

			local keepCopper = 200000000
			if playerName == "Prðblems" then
				keepCopper = 5000000
			elseif playerName == "Prðbléms" then
				keepCopper = 5000000
			elseif playerName == "Prðblèms" then
				keepCopper = 5000000
			elseif playerName == "Prðblëms" then
				keepCopper = 5000000
			elseif playerName == "Problems" then
				keepCopper = 5000000
			elseif playerName == "Probléms" then
				keepCopper = 5000000
			elseif playerLevel == 70 then
				keepCopper = 1500000
			elseif playerLevel < 70 then
				keepCopper = 0
			elseif playerLevel < 80 then
				keepCopper = 5000000
			end

			local copperDifference = GetMoney() - keepCopper

			if copperDifference > 0 then
				C_Bank.DepositMoney(Enum.BankType.Account, copperDifference)
				print("\124cFF0088FFpoesPrivate: \124r", "Deposited", GetGoldString(copperDifference), "to Warbank.")
			elseif copperDifference < 0 then
				copperDifference = abs(copperDifference)
				C_Bank.WithdrawMoney(Enum.BankType.Account, copperDifference)
				print("\124cFF0088FFpoesPrivate: \124r", "Withdrew", GetGoldString(copperDifference), "from Warbank.")
			end

			-- if playerLevel == 80 then
			-- 	for itemID, desiredCount in pairs(addon.keepItems) do
			-- 		local bagCount, bagSlots = addon:GetBagItems(itemID)
			-- 		local bankCount, bankSlots = addon:GetWarbankItems(itemID)

			-- 		local countDifference = bagCount - desiredCount

			-- 		if countDifference == 0 then
			-- 			break
			-- 		end

			-- 		if countDifference > 0 then
			-- 			local toDeposit = countDifference

			-- 			for _, slotData in ipairs(bagSlots) do
			-- 				if toDeposit <= 0 then
			-- 					break
			-- 				end

			-- 				local moveCount = math.min(toDeposit, slotData.count)
			-- 				local itemLocation = ItemLocation:CreateFromBagAndSlot(slotData.bag, slotData.slot)
			-- 				C_Bank.DepositItem(Enum.BankType.Account, itemLocation, moveCount)
			-- 				print("\124cFF0088FFpoesPrivate: \124r", "Deposited", moveCount, "of", itemID, "to Warbank.")

			-- 				toDeposit = toDeposit - moveCount
			-- 			end
			-- 		else
			-- 			local toWithdraw = math.min(-countDifference, bankCount)

			-- 			for _, slotData in ipairs(bankSlots) do
			-- 				if toWithdraw <= 0 then
			-- 					break
			-- 				end

			-- 				local moveCount = math.min(toWithdraw, slotData.count)
			-- 				local itemLocation = ItemLocation:CreateFromBankSlot(Enum.BankType.Account, slotData.slot)
			-- 				C_Bank.WithdrawItem(Enum.BankType.Account, itemLocation, moveCount)
			-- 				print("\124cFF0088FFpoesPrivate: \124r", "Withdrew", moveCount, "of", itemID, "from Warbank.")
			-- 				toWithdraw = toWithdraw - moveCount
			-- 			end
			-- 		end
			-- 	end
			-- end
		end
	elseif event == "QUEST_LOG_CRITERIA_UPDATE" then
		local questID, specificTreeID, description, numFulfilled, numRequired = ...

		addon:Debounce("questProgress_" .. questID, 5, function()
			CheckQuestProgress(1, questID)
		end)
	elseif event == "QUEST_LOG_UPDATE" or event == "TASK_PROGRESS_UPDATE" then
		addon:Debounce("QUEST_LOG_UPDATE", 5, function()
			for questLogIndex = 1, C_QuestLog.GetNumQuestLogEntries() do
				local info = C_QuestLog.GetInfo(questLogIndex)

				if info and not info.isHeader then
					local objectives = C_QuestLog.GetQuestObjectives(info.questID)

					addon:Debounce("questProgress_" .. info.questID, 5, function()
						CheckQuestProgress(1, info.questID)
					end)
				end
			end
		end)
	elseif event == "QUEST_REMOVED" then
		local questID = ...

		if C_QuestLog.IsComplete(questID) then
			addon:Debounce("checkCompletedQuest_" .. questID, 1, function()
				CheckCompletedQuest(questID)
			end)
		end
	elseif event == "QUEST_TURNED_IN" then
		addon:Debounce("scanBagItems", 1.5, function()
			ScanBagItems()
		end)
	elseif event == "QUEST_WATCH_UPDATE" then
		local questID = ...

		addon:Debounce("questProgress_" .. questID, 5, function()
			CheckQuestProgress(1, questID)
		end)
	elseif event == "SPELL_PUSHED_TO_ACTIONBAR" then
		if not InCombatLockdown() then
			local spellID, slotIndex, slotPos = ...

			ClearCursor()
			PickupAction(slotIndex)
			ClearCursor()
		end
	elseif event == "TRADE_SKILL_LIST_UPDATE" then
		if ordersUpdated then
			return
		end

		local profTab = ProfessionsFrame:GetTab()

		if profTab == 3 then
			ordersUpdated = true

			--C_TradeSkillUI.SetShowUnlearned(false)

			addon:Debounce("RequestOrders", 1, function()
				ProfessionsFrame.OrdersPage:RequestOrders(nil, false, false)
			end)
		end
	elseif event == "VARIABLES_LOADED" then
		addon:Debounce("VariablesLoaded", 5, function()
			C_CVar.SetCVar("alwaysCompareItems", 1)
			C_CVar.SetCVar("displaySpellActivationOverlays", 1)
			C_CVar.SetCVar("spellActivationOverlayOpacity", 0.65)

			C_CVar.RegisterCVar("addonProfilerEnabled", 1)
			C_CVar.SetCVar("addonProfilerEnabled", 0)

			PetFrame:UnregisterEvent("UNIT_COMBAT")
			PlayerFrame:UnregisterEvent("UNIT_COMBAT")
			TargetFrame:UnregisterEvent("UNIT_COMBAT")

			IconIntroTracker.RegisterEvent = function() end
			IconIntroTracker:UnregisterEvent('SPELL_PUSHED_TO_ACTIONBAR')

			ScanCompletedQuests()
			ToggleActionBars()
		end)
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("BAG_UPDATE_DELAYED")
f:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
f:RegisterEvent("MINIMAP_UPDATE_TRACKING")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
f:RegisterEvent("QUEST_LOG_CRITERIA_UPDATE")
f:RegisterEvent("QUEST_LOG_UPDATE")
f:RegisterEvent("QUEST_REMOVED")
f:RegisterEvent("QUEST_TURNED_IN")
f:RegisterEvent("QUEST_WATCH_UPDATE")
f:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
f:RegisterEvent("TASK_PROGRESS_UPDATE")
f:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:SetScript("OnEvent", OnEvent)

f:SetSize(1, 1)
f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
f:Hide()
