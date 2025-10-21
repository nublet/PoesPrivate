local addonName, addon = ...

local fireworksMinimum = 1
local fireworksMaximum = 25
local frameResult
local frameSpinner
local triggerWords = { "spin", "games begin", "roll", "feeling lucky" }

local rollValuesFirst = {}
rollValuesFirst[1] = "Time to talk about fight club! Playing for envelope "
rollValuesFirst[3] = "Trivia time! Playing for envelope "
rollValuesFirst[7] = "Trivia time! Playing for envelope "
rollValuesFirst[9] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[11] = "Trivia time! Playing for envelope "
rollValuesFirst[12] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[13] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[14] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[17] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[18] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[19] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[22] = "Challenge mode! Playing for envelope "
rollValuesFirst[23] = "Trivia time! Playing for envelope "
rollValuesFirst[25] = "Challenge mode! Playing for envelope "
rollValuesFirst[27] = "Time to talk about fight club! Playing for envelope "
rollValuesFirst[28] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[30] = "Challenge mode! Playing for envelope "
rollValuesFirst[31] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[32] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[34] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[35] = "Time for the mane event! Playing for envelope "
rollValuesFirst[37] = "Challenge mode! Playing for envelope "
rollValuesFirst[40] = "Time for the mane event! Playing for envelope "
rollValuesFirst[41] = "Challenge mode! Playing for envelope "
rollValuesFirst[46] = "Time for the mane event! Playing for envelope "
rollValuesFirst[47] = "Trivia time! Playing for envelope "
rollValuesFirst[48] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[49] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[52] = "Time to talk about fight club! Playing for envelope "
rollValuesFirst[53] = "Time to talk about fight club! Playing for envelope "
rollValuesFirst[55] = "Trivia time! Playing for envelope "
rollValuesFirst[56] = "Time for the mane event! Playing for envelope "
rollValuesFirst[58] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[60] = "Challenge mode! Playing for envelope "
rollValuesFirst[62] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[66] = "Challenge mode! Playing for envelope "
rollValuesFirst[69] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[73] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[77] = "Trivia time! Playing for envelope "
rollValuesFirst[79] = "Trivia time! Playing for envelope "
rollValuesFirst[84] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[85] = "Challenge mode! Playing for envelope "
rollValuesFirst[87] = "Time for the mane event! Playing for envelope "
rollValuesFirst[88] = "Trivia time! Playing for envelope "
rollValuesFirst[89] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[90] = "Challenge mode! Playing for envelope "
rollValuesFirst[94] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[95] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[97] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[101] = "Time to talk about fight club! Playing for envelope "
rollValuesFirst[102] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[103] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[104] = "Time for the mane event! Playing for envelope "
rollValuesFirst[106] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[109] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[111] = "Trivia time! Playing for envelope "
rollValuesFirst[113] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[115] = "Time to talk about fight club! Playing for envelope "
rollValuesFirst[116] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[117] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[120] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[121] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[122] = "Scavenger Hunt - you have 15 seconds! Playing for envelope "
rollValuesFirst[123] = "Trivia time! Playing for envelope "
rollValuesFirst[125] = "Trivia time! Playing for envelope "
rollValuesFirst[126] = "Who needs gold anyway! Playing for envelope "
rollValuesFirst[128] = "Challenge mode! Playing for envelope "
rollValuesFirst[129] = "Trivia time! Playing for envelope "
rollValuesFirst[130] = "Trivia time! Playing for envelope "

local rollValuesSecond = {}
rollValuesSecond[1] = ". Duel highest roller in group. No win, no open"
rollValuesSecond[3] = ". Name everyone's doggos in Shits"
rollValuesSecond[7] = ". ?" --ducktective
rollValuesSecond[9] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[11] = ". Where is Trustfall?"
rollValuesSecond[12] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[13] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[14] = ". Without using your feet, find something blue"
rollValuesSecond[17] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[18] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[19] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[22] = ". Complete a remix key with only 1 spell bound"
rollValuesSecond[23] = ". ?" --easily distracted
rollValuesSecond[25] = ". Don't GTFO - stand in all the shinies for a key"
rollValuesSecond[27] = ". Duel highest roller in group. No win, no open"
rollValuesSecond[28] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[30] = ". Complete a remix raid - put on everything that drops, regardless of type, or usefulness"
rollValuesSecond[31] = ". "
rollValuesSecond[32] = ". "
rollValuesSecond[34] = ". "
rollValuesSecond[35] = ". Mount off with the highest roller in group. No win, no open"
rollValuesSecond[37] = ". Complete a remix raid as tank, only ranged attacks allowed"
rollValuesSecond[40] = ". Mount off with the highest roller in group. No win, no open"
rollValuesSecond[41] = ". Complete a remix key with no addons & ui turned off"
rollValuesSecond[46] = ". Mount off with the highest roller in group. No win, no open"
rollValuesSecond[47] = ". Frogtastic?" --wednesday
rollValuesSecond[48] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[49] = ". "
rollValuesSecond[52] = ". Duel highest roller in group. No win, no open"
rollValuesSecond[53] = ". Duel highest roller in group. No win, no open"
rollValuesSecond[55] = ". ?" --your did it
rollValuesSecond[56] = ". Mount off with the highest roller in group. No win, no open"
rollValuesSecond[58] = ". "
rollValuesSecond[60] = ". Complete a remix key after moving all keybinds 2 keys right (Hide bars)"
rollValuesSecond[62] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[66] = ". "
rollValuesSecond[69] = ". "
rollValuesSecond[73] = ". "
rollValuesSecond[77] = ". ?" --crayons
rollValuesSecond[79] = ". Swapblasters suck"
rollValuesSecond[84] = ". "
rollValuesSecond[85] = ". "
rollValuesSecond[87] = ". Mount off with the highest roller in group. No win, no open"
rollValuesSecond[88] = ". " -- arguing
rollValuesSecond[89] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[90] = ". "
rollValuesSecond[94] = ". "
rollValuesSecond[95] = ". "
rollValuesSecond[97] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[101] = ". Duel highest roller in group. No win, no open"
rollValuesSecond[102] = ". "
rollValuesSecond[103] = ". "
rollValuesSecond[104] = ". Mount off with the highest roller in group. No win, no open"
rollValuesSecond[106] = ". "
rollValuesSecond[109] = ". "
rollValuesSecond[111] = ". ?" --side quest adhd
rollValuesSecond[113] = ". "
rollValuesSecond[115] = ". Duel highest roller in group. No win, no open"
rollValuesSecond[116] = ". "
rollValuesSecond[117] = ". "
rollValuesSecond[120] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[121] = ". "
rollValuesSecond[122] = ". "
rollValuesSecond[123] = ". ?" --task failed successfully
rollValuesSecond[125] = ". ?" --dramatic
rollValuesSecond[126] = ". Death roll 1000 with a group member. No win, no open"
rollValuesSecond[128] = ". "
rollValuesSecond[129] = ". Coop de gracie"
rollValuesSecond[130] = ". 7-10 business days"

local LSM = LibStub("LibSharedMedia-3.0")
local font = LSM:Fetch("font", "Naowh") or "Fonts\\FRIZQT__.TTF"

local function CreateFirework()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(32, 32)
	frame:SetPoint("CENTER", math.random(-1720, 1720), math.random(-720, 720))

	local tex = frame:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	tex:SetTexture("Interface\\Cooldown\\star4") -- A decent built-in starburst texture
	tex:SetVertexColor(math.random(), math.random(), math.random())
	tex:SetBlendMode("ADD")

	-- Animation group
	local ag = tex:CreateAnimationGroup()
	local scale = ag:CreateAnimation("Scale")
	scale:SetScale(math.random(5, 20), math.random(5, 20))
	scale:SetDuration(3)
	scale:SetSmoothing("OUT")

	local fade = ag:CreateAnimation("Alpha")
	fade:SetFromAlpha(1)
	fade:SetToAlpha(0)
	fade:SetStartDelay(0.5)
	fade:SetDuration(6)
	fade:SetSmoothing("IN")

	ag:SetScript("OnFinished", function()
		frame:Hide()
		frame:SetParent(nil)
	end)

	ag:Play()
end

local function OnEvent(self, event, ...)
	if event == "CHAT_MSG_BN_WHISPER" or event == "CHAT_MSG_WHISPER" then
		local text, playerName, languageName, channelName, playerName2, specialFlags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, guid, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, suppressRaidIcons = ...
		if not text then
			return
		end

		text = addon:NormalizeText(text)

		for _, word in ipairs(triggerWords) do
			word = addon:NormalizeText(word)
			if text:find(word) then
				addon:Debounce("showSpinner", 1, function()
					frameSpinner:Show()
				end)

				return true
			end
		end
	end
end

function addon:InitializeSpinner()
	frameResult = CreateFrame("Frame", nil, UIParent)
	frameResult:EnableKeyboard(false)
	frameResult:EnableMouse(false)
	frameResult:EnableMouseWheel(false)
	frameResult:SetFrameStrata("DIALOG")
	frameResult:SetPoint("CENTER", 0, 0)
	frameResult:SetSize(900, 900)

	frameResult.textCenter = frameResult:CreateFontString(nil, "OVERLAY")
	frameResult.textCenter:SetAllPoints(frameResult)
	frameResult.textCenter:SetFont(font, 60, "OUTLINE")
	frameResult.textCenter:SetJustifyH("CENTER")
	frameResult.textCenter:SetNonSpaceWrap(false)
	frameResult.textCenter:SetShadowColor(0, 0, 0, 1)
	frameResult.textCenter:SetShadowOffset(0, 0)
	frameResult.textCenter:SetWidth(frameResult:GetWidth())
	frameResult.textCenter:SetWordWrap(true)

	frameSpinner = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
	frameSpinner:EnableKeyboard(false)
	frameSpinner:EnableMouse(true)
	frameSpinner:EnableMouseWheel(false)
	frameSpinner:RegisterEvent("CHAT_MSG_BN_WHISPER")
	frameSpinner:RegisterEvent("CHAT_MSG_WHISPER")
	frameSpinner:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
	frameSpinner:SetFrameStrata("DIALOG")
	frameSpinner:SetHitRectInsets(0, 0, 0, 0)
	frameSpinner:SetPoint("CENTER", 0, 0)
	frameSpinner:SetPropagateKeyboardInput(true)
	frameSpinner:SetSize(900, 900)

	frameSpinner:SetScript("OnEvent", OnEvent)
	frameSpinner:SetScript("OnClick", function()
		frameSpinner:Hide()
		SaveView(1)
		MoveViewRightStart(8)

		C_Timer.After(4, function()
			MoveViewRightStop()
			SetView(1)

			local rollValue = math.random(1, 130)

			if rollValuesFirst[rollValue] then
				frameResult.textCenter:SetText(rollValuesFirst[rollValue] .. rollValue .. rollValuesSecond[rollValue])
			else
				frameResult.textCenter:SetText("AMAGAD instant win! Open envelope " .. rollValue .. ".")
			end

			C_Timer.After(1, function()
				for i = fireworksMinimum, fireworksMaximum do
					C_Timer.After(math.random() * 0.5, CreateFirework)
				end
			end)

			C_Timer.After(3, function()
				for i = fireworksMinimum, fireworksMaximum do
					C_Timer.After(math.random() * 0.5, CreateFirework)
				end
			end)

			C_Timer.After(6, function()
				for i = fireworksMinimum, fireworksMaximum do
					C_Timer.After(math.random() * 0.5, CreateFirework)
				end
			end)

			C_Timer.After(9, function()
				for i = fireworksMinimum, fireworksMaximum do
					C_Timer.After(math.random() * 0.5, CreateFirework)
				end
			end)

			C_Timer.After(10, function()
				frameResult:Hide()
			end)

			frameResult:Show()
		end)
	end)

	frameSpinner.textBottom = frameSpinner:CreateFontString(nil, "OVERLAY")
	frameSpinner.textBottom:SetFont(font, 60, "OUTLINE")
	frameSpinner.textBottom:SetPoint("TOP", frameSpinner, "BOTTOM", 0, 0)
	frameSpinner.textBottom:SetShadowColor(0, 0, 0, 1)
	frameSpinner.textBottom:SetShadowOffset(0, 0)
	frameSpinner.textBottom:SetText("^ Click the Spinner ^")
	frameSpinner.textBottom:SetTextColor(1, 1, 1, 1)

	frameSpinner.textTop = frameSpinner:CreateFontString(nil, "OVERLAY")
	frameSpinner.textTop:SetFont(font, 80, "OUTLINE")
	frameSpinner.textTop:SetPoint("BOTTOM", frameSpinner, "TOP", 0, 0)
	frameSpinner.textTop:SetShadowColor(0, 0, 0, 1)
	frameSpinner.textTop:SetShadowOffset(0, 0)
	frameSpinner.textTop:SetText("Winner Winner")
	frameSpinner.textTop:SetTextColor(1, 1, 1, 1)

	frameSpinner.textureIcon = frameSpinner:CreateTexture(nil, "ARTWORK")
	frameSpinner.textureIcon:SetAllPoints(frameSpinner)
	frameSpinner.textureIcon:SetTexture(132369)

	frameSpinner:Hide()
end
