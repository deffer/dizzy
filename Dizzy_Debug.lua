Dizzy=Dizzy or {}

local function createWrapperFrame(name)
	local frame  = CreateFrame("Frame", name, UIParent)
	frame.width  = 500
	frame.height = 250
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetSize(frame.width, frame.height)
	frame:SetPoint("LEFT", UIParent, "LEFT", 10, 50)
	frame:SetBackdrop({
		bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile     = true,
		tileSize = 32,
		edgeSize = 32,
		insets   = { left = 8, right = 8, top = 8, bottom = 8 }
	})
	frame:SetBackdropColor(0, 0, 0, 1)
	frame:EnableMouse(true)
	frame:EnableMouseWheel(true)

	-- Make movable/resizable
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:SetMinResize(100, 100)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	return frame
end

local function createCloseButtonFor(frame)
	local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	closeButton:SetPoint("BOTTOM", 0, 10)
	closeButton:SetHeight(25)
	closeButton:SetWidth(70)
	closeButton:SetText("CLOSE")
	closeButton:SetScript("OnClick", function(self)
		--HideParentPanel(self)
		self:GetParent():Hide()
	end)
	return closeButton
end

local function createScrollingFrameFor(frame)
	local messageFrame = CreateFrame("ScrollingMessageFrame", nil, frame)
	messageFrame:SetPoint("CENTER", 15, 20)
	messageFrame:SetSize(frame.width, frame.height - 50)
	messageFrame:SetFontObject(GameFontNormal)
	messageFrame:SetTextColor(1, 1, 1, 1) -- default color
	messageFrame:SetJustifyH("LEFT")
	messageFrame:SetHyperlinksEnabled(true)
	messageFrame:SetFading(false)
	messageFrame:SetMaxLines(300)
	return messageFrame
end

local function createScrollbarFor(frame)
	local scrollBar = CreateFrame("Slider", nil, frame, "UIPanelScrollBarTemplate")
	scrollBar:SetPoint("RIGHT", frame, "RIGHT", -10, 10)
	scrollBar:SetSize(30, frame.height - 90)
	scrollBar:SetMinMaxValues(0, 9)
	scrollBar:SetValueStep(1)
	scrollBar.scrollStep = 1
	return scrollBar
end

Dizzy.CreateDebugFrame = function()
	local f = createWrapperFrame("DizzyDebugFrame")
	tinsert(UISpecialFrames, "DizzyDebugFrame")
	f.closeButton = createCloseButtonFor(f)
	f.messageFrame = createScrollingFrameFor(f)

	--for i = 1, 25 do
	--	f.messageFrame:AddMessage(i .. ". Here is a message!")
	--end
	--f.messageFrame:ScrollToBottom()
	--f.messageFrame:ScrollDown()
	--print(f.messageFrame:GetNumMessages(), f.messageFrame:GetNumLinesDisplayed())

	f.scrollBar = createScrollbarFor(f)
	f.scrollBar:SetScript("OnValueChanged", function(self, value)
		f.messageFrame:SetScrollOffset(select(2, f.scrollBar:GetMinMaxValues()) - value)
	end)
	f.scrollBar:SetValue(select(2, f.scrollBar:GetMinMaxValues()))

	f:SetScript("OnMouseWheel", function(self, delta)
		--print(f.messageFrame:GetNumMessages(), f.messageFrame:GetNumLinesDisplayed())

		local cur_val = f.scrollBar:GetValue()
		local min_val, max_val = f.scrollBar:GetMinMaxValues()

		if delta < 0 and cur_val < max_val then
			cur_val = math.min(max_val, cur_val + 1)
			f.scrollBar:SetValue(cur_val)
		elseif delta > 0 and cur_val > min_val then
			cur_val = math.max(min_val, cur_val - 1)
			f.scrollBar:SetValue(cur_val)
		end
	end)

	return f
end
