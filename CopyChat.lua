local CopyChatFrame
local CopyChatFrameEditBox

local function CreateCopyButton(frame)
    local copyButton = CreateFrame("Button", nil, frame)
    copyButton:SetSize(20, 20)
    copyButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    copyButton:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
    copyButton:SetHighlightTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Highlight")
    copyButton:SetPushedTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Down")

    copyButton:SetScript("OnClick", function()
        local lines = {}
        for i = 1, frame:GetNumMessages() do
            local message = frame:GetMessageInfo(i)
            if message then
                table.insert(lines, message)
            end
        end
        local text = table.concat(lines, "\n")

        if not CopyChatFrameEditBox then
            CopyChatFrame = CreateFrame("Frame", "CopyChatFrame", UIParent, "BackdropTemplate")
            CopyChatFrame:SetSize(700, 400)
            CopyChatFrame:SetPoint("CENTER")
            CopyChatFrame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            CopyChatFrame:SetMovable(true)
            CopyChatFrame:EnableMouse(true)
            CopyChatFrame:RegisterForDrag("LeftButton")
            CopyChatFrame:SetScript("OnDragStart", CopyChatFrame.StartMoving)
            CopyChatFrame:SetScript("OnDragStop", CopyChatFrame.StopMovingOrSizing)

            -- ScrollFrame
            local scrollFrame = CreateFrame("ScrollFrame", "CopyChatScrollFrame", CopyChatFrame,
                "UIPanelScrollFrameTemplate")
            scrollFrame:SetPoint("TOPLEFT", 10, -10)
            scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

            -- EditBox inside the ScrollFrame
            local eb = CreateFrame("EditBox", "CopyChatFrameEditBox", scrollFrame)
            eb:SetMultiLine(true)
            eb:SetFontObject(ChatFontNormal)
            eb:SetAutoFocus(true)
            eb:SetWidth(660)
            eb:SetScript("OnEscapePressed", function() CopyChatFrame:Hide() end)

            scrollFrame:SetScrollChild(eb)

            CopyChatFrame.editBox = eb
            CopyChatFrame:Hide()
        end

        CopyChatFrameEditBox:SetText(text)
        CopyChatFrameEditBox:HighlightText()
        CopyChatFrame:Show()
    end)
end

-- Hook all chat frames
for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G["ChatFrame" .. i]
    if frame then
        CreateCopyButton(frame)
    end
end
