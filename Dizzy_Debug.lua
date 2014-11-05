Dizzy=Dizzy or {}

local function createWrapperFrame(name)
	local frame  = CreateFrame("Frame", name, UIParent)
	frame.width  = 500
	frame.height = 250
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:SetSize(frame.width, frame.height)
	frame:SetPoint("LEFT", UIParent, "LEFT", 10, 150)
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

local function createReloadButtonFor(frame)
	local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	closeButton:SetPoint("BOTTOMLEFT", frame, 10, 10)
	closeButton:SetHeight(25)
	closeButton:SetWidth(90)
	closeButton:SetText("Reload UI")
	closeButton:SetScript("OnClick", function(self)
		ReloadUI()
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
	scrollBar:SetMinMaxValues(0, 20)
	scrollBar:SetValueStep(1)
	scrollBar.scrollStep = 1
	return scrollBar
end

local createDebugFrame = function()
	local f = createWrapperFrame("DizzyDebugFrame")
	tinsert(UISpecialFrames, "DizzyDebugFrame")
	f.closeButton = createCloseButtonFor(f)
	f.reloadButton = createReloadButtonFor(f)
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

	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_ENTERING_WORLD" then
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

	local n = 0
	local f = EnumerateFrames()
	while (f) do
		if f:IsVisible() and (verbose or MouseIsOver(f)) then
			if (f:GetName() or f:GetID() ~=0) then
				frame:AddMessage(tostring(f:GetName()) .. " - " .. tostring(f:GetID()))
			else
				n = n+1
			end
		end
		f = EnumerateFrames(f)
	end
	
	if n>0 then
		frame:AddMessage("Also "..tostring(n) .. " unidentifiable frame(s)")
	end
end

Dizzy.DebugShowGlobal = function (pattern)
	if string.find(pattern, "^[%w_]+$") then
		local obj = _G[pattern]
		if obj then  Dizzy.DebugShowObject(obj)  else Dizzy.Debug("Object "..pattern.." not found in globals") 	end	
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
		
	for k in pairs(t) do
		frame:AddMessage(""..type(k).." "..(type(k)=="table" and "{}" or tostring(k)))		
	end
end
