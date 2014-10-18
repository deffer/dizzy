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

local createDebugFrame = function()
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

	f:RegisterEvent("PLAYER_LOGIN")
	f:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			self:Show()
		end
	end)

	return f
end

Dizzy.CreateDebugFrame = function()
	Dizzy.DebugFrame = createDebugFrame()
end

Dizzy.Debug = function(text)
	if (Dizzy.DebugFrame) then
		Dizzy.DebugFrame.messageFrame:AddMessage(text)
	else
		DEFAULT_CHAT_FRAME:AddMessage(text)
	end
end

Dizzy.DebugShowFrames = function()
	local f = EnumerateFrames()

	local frame = DEFAULT_CHAT_FRAME
	local verbose = false
	if (Dizzy.DebugFrame) then
		frame = Dizzy.DebugFrame.messageFrame
		verbose = true

		-- also display info about debug frame
		local width, height = Dizzy.DebugFrame:GetSize()
		local layout = ""..Dizzy.DebugFrame:GetFrameStrata().." "..width.."x"..height
		local visibility = "hidden"
		if Dizzy.DebugFrame:IsVisible() then visibility = "visible" end
		DEFAULT_CHAT_FRAME:AddMessage("Debug frame is "..visibility.." ("..layout..")")
	end

	while f do
		if frame:IsVisible() and (verbose or MouseIsOver(f)) then
			frame:AddMessage(f:GetName() .. " - " .. f:GetID())
		end
		f = EnumerateFrames(frame)
	end
end

Dizzy.DebugShowGlobal = function (pattern)
	if string.find(pattern, "^[^%w_]+$") then
		local obj = _G[pattern]
		if obj then Dizzy.DebugShowObject(obj) else Dizzy.Debug("Object "..pattern.." not found in globals") end
	else
		-- its a pattern. scan all _G for anything that matches. don't show more that 200
		local count = 0;
		Dizzy.Debug("Patterns are not supported yet")
	end
end

Dizzy.DebugShowObject = function(t)
	local frame = DEFAULT_CHAT_FRAME
	if (Dizzy.DebugFrame) then
		frame = Dizzy.DebugFrame.messageFrame
	end

	local s={}
	local n=0
	for k in pairs(t) do
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		frame:AddMessage(""..v.." "..(type(v)=="table" and "{}" or tostring(v)))
	end
end
