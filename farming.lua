-- LocalScript inside StarterGui

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local network = rs:WaitForChild("Network")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmingHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Flat, Neon Green Bordered GUI Styles
local BORDER_COLOR = Color3.fromRGB(0,255,128)
local BG_COLOR = Color3.fromRGB(20,20,20)
local TAB_BG = Color3.fromRGB(30,30,30)
local TAB_ACTIVE_BG = Color3.fromRGB(40,40,40)
local TAB_TEXT = Color3.fromRGB(220,220,220)
local SECTION_HEADER_BG = Color3.fromRGB(25,25,25)
local SECTION_HEADER_TEXT = Color3.fromRGB(0,255,128)
local BUTTON_BG = Color3.fromRGB(30,30,30)
local BUTTON_BORDER = Color3.fromRGB(0,255,128)
local BUTTON_TEXT = Color3.fromRGB(220,220,220)
local BUTTON_HOVER_BG = Color3.fromRGB(40,40,40)
local CHECKBOX_BG = Color3.fromRGB(30,30,30)
local CHECKBOX_BORDER = Color3.fromRGB(0,255,128)
local CHECKBOX_CHECKED = Color3.fromRGB(0,255,128)
local CHECKBOX_UNCHECKED = Color3.fromRGB(40,40,40)
local FONT = Enum.Font.SourceSans

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 320)
mainFrame.Position = UDim2.new(0, 200, 0, 120)
mainFrame.BackgroundColor3 = BG_COLOR
mainFrame.BorderColor3 = BORDER_COLOR
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Top Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 36)
tabBar.Position = UDim2.new(0, 0, 0, 0)
tabBar.BackgroundColor3 = BG_COLOR
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local tabs = {"Farming", "Mining", "Merchants"}
local tabFrames = {}
local selectedTab = "Farming"
local tabBtnX = 8
local tabBtnW = 80
for i, tabName in ipairs(tabs) do
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, tabBtnW, 0, 28)
	tabBtn.Position = UDim2.new(0, tabBtnX, 0, 4)
	tabBtn.BackgroundColor3 = (tabName == selectedTab) and TAB_ACTIVE_BG or TAB_BG
	tabBtn.BorderColor3 = BORDER_COLOR
	tabBtn.BorderSizePixel = 1
	tabBtn.TextColor3 = TAB_TEXT
	tabBtn.Font = FONT
	tabBtn.TextSize = 20
	tabBtn.Text = tabName
	tabBtn.Parent = tabBar
	tabBtn.MouseButton1Click:Connect(function()
		selectedTab = tabName
		for name, frame in pairs(tabFrames) do
			frame.Visible = (name == tabName)
		end
		for _, btn in ipairs(tabBar:GetChildren()) do
			if btn:IsA("TextButton") then
				btn.BackgroundColor3 = (btn.Text == selectedTab) and TAB_ACTIVE_BG or TAB_BG
			end
		end
	end)
	tabBtnX = tabBtnX + tabBtnW + 4
end

-- Section Header Helper
local function createSectionHeader(parent, text, y)
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -24, 0, 28)
	header.Position = UDim2.new(0, 12, 0, y)
	header.BackgroundColor3 = SECTION_HEADER_BG
	header.BorderColor3 = BORDER_COLOR
	header.BorderSizePixel = 1
	header.TextColor3 = SECTION_HEADER_TEXT
	header.Font = FONT
	header.TextSize = 18
	header.Text = text
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = parent
	return y + 36
end

-- Flat Button Helper (smaller)
local function createFlatButton(parent, text, y, color, borderColor, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 24)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = color or BUTTON_BG
	btn.BorderColor3 = borderColor or BUTTON_BORDER
	btn.BorderSizePixel = 1
	btn.TextColor3 = BUTTON_TEXT
	btn.Font = FONT
	btn.TextSize = 13
	btn.Text = text
	btn.Parent = parent
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = BUTTON_HOVER_BG
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = color or BUTTON_BG
	end)
	btn.MouseButton1Click:Connect(callback)
	return btn, y + 28
end

-- Flat Checkbox Helper (smaller)
local function createFlatCheckbox(parent, text, y, checkedCallback)
	local cbFrame = Instance.new("Frame")
	cbFrame.Size = UDim2.new(1, -20, 0, 22)
	cbFrame.Position = UDim2.new(0, 10, 0, y)
	cbFrame.BackgroundTransparency = 1
	cbFrame.Parent = parent
	local cb = Instance.new("TextButton")
	cb.Size = UDim2.new(0, 16, 0, 16)
	cb.Position = UDim2.new(0, 0, 0, 3)
	cb.BackgroundColor3 = CHECKBOX_UNCHECKED
	cb.BorderColor3 = CHECKBOX_BORDER
	cb.BorderSizePixel = 1
	cb.TextColor3 = CHECKBOX_CHECKED
	cb.Font = FONT
	cb.TextSize = 13
	cb.Text = ""
	cb.Parent = cbFrame
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 20, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = BUTTON_TEXT
	label.Font = FONT
	label.TextSize = 13
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = cbFrame
	local checked = false
	cb.MouseButton1Click:Connect(function()
		checked = not checked
		cb.Text = checked and "■" or ""
		cb.BackgroundColor3 = checked and CHECKBOX_CHECKED or CHECKBOX_UNCHECKED
		checkedCallback(checked)
	end)
	cb.MouseEnter:Connect(function()
		cb.BackgroundColor3 = checked and CHECKBOX_CHECKED or BUTTON_HOVER_BG
	end)
	cb.MouseLeave:Connect(function()
		cb.BackgroundColor3 = checked and CHECKBOX_CHECKED or CHECKBOX_UNCHECKED
	end)
	return cb, y + 22, function() return checked end, function(val)
		checked = val
		cb.Text = checked and "■" or ""
		cb.BackgroundColor3 = checked and CHECKBOX_CHECKED or CHECKBOX_UNCHECKED
	end
end

-- Scrollable Content Helper
local function createScrollableFrame(parent)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -40)
	scroll.Position = UDim2.new(0, 0, 0, 40)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
	scroll.ScrollBarThickness = 6
	scroll.Parent = parent
	return scroll
end

-- Debounce Helper
local function debounceToggle(stateTable, key)
	if stateTable[key] then return false end
	stateTable[key] = true
	task.delay(0.2, function() stateTable[key] = false end)
	return true
end

-- Efficient coroutine management
local runningLoops = {}
local function startLoop(key, func)
	if runningLoops[key] then return end
	runningLoops[key] = true
	task.spawn(function()
		while runningLoops[key] and not killed do
			func()
		end
	end)
end
local function stopLoop(key)
	runningLoops[key] = false
end

-- KILL SCRIPT cleans up everything
local function killScript()
	killed = true
	for k in pairs(runningLoops) do runningLoops[k] = false end
	screenGui:Destroy()
end

-- Store toggle states and running threads
local toggles = {}
local runningThreads = {}
local killed = false

-- Farming Tab
local farmingFrame = Instance.new("Frame")
farmingFrame.Size = UDim2.new(1, 0, 1, -40)
farmingFrame.Position = UDim2.new(0, 0, 0, 40)
farmingFrame.BackgroundTransparency = 1
farmingFrame.Parent = mainFrame
tabFrames["Farming"] = farmingFrame
local farmingScroll = createScrollableFrame(farmingFrame)
local y = 0
y = createSectionHeader(farmingScroll, "Auto Actions", y)

-- Start Auto Farm
local autoFarmState = {debounce = false, running = false, thread = nil}
local autoFarmBtn, y2 = createFlatButton(farmingScroll, "Start Auto Farm", y, BUTTON_BG, BUTTON_BORDER, function()
	if not debounceToggle(autoFarmState, "debounce") then return end
	autoFarmState.running = not autoFarmState.running
	autoFarmBtn.Text = autoFarmState.running and "Stop Auto Farm" or "Start Auto Farm"
	autoFarmBtn.BackgroundColor3 = autoFarmState.running and CHECKBOX_CHECKED or BUTTON_BG
	if autoFarmState.running then
		autoFarmState.thread = task.spawn(function()
			while autoFarmState.running and not killed do
				network:WaitForChild("Farming_AutoFarm"):FireServer()
				task.wait(2)
			end
		end)
	else
		if autoFarmState.thread then task.cancel(autoFarmState.thread) end
	end
end)
y = y2

-- Start Auto Plant Seeds
local autoPlantState = {debounce = false, running = false, thread = nil}
local autoPlantBtn, y2 = createFlatButton(farmingScroll, "Start Auto Plant Seeds", y, BUTTON_BG, BUTTON_BORDER, function()
	if not debounceToggle(autoPlantState, "debounce") then return end
	autoPlantState.running = not autoPlantState.running
	autoPlantBtn.Text = autoPlantState.running and "Stop Auto Plant Seeds" or "Start Auto Plant Seeds"
	autoPlantBtn.BackgroundColor3 = autoPlantState.running and CHECKBOX_CHECKED or BUTTON_BG
	if autoPlantState.running then
		autoPlantState.thread = task.spawn(function()
			local id = "7bd389d1c6c941dfa53e26e2c3e0910f"
			while autoPlantState.running and not killed do
				network:WaitForChild("FarmingHold_Start"):FireServer(id)
				task.wait(2)
			end
		end)
	else
		if autoPlantState.thread then task.cancel(autoPlantState.thread) end
	end
end)
y = y2

-- Start Roll Egg
local rollEggState = {debounce = false, running = false}
local rollEggBtn, y2 = createFlatButton(farmingScroll, "Start Roll Egg", y, BUTTON_BG, BUTTON_BORDER, function()
	if not debounceToggle(rollEggState, "debounce") then return end
	rollEggState.running = not rollEggState.running
	rollEggBtn.Text = rollEggState.running and "Stop Roll Egg" or "Start Roll Egg"
	rollEggBtn.BackgroundColor3 = rollEggState.running and BUTTON_BG or BUTTON_BG
	if rollEggState.running then
		startLoop("RollEgg", function()
			network:WaitForChild("Eggs_Roll"):InvokeServer()
			task.wait(2)
		end)
	else
		stopLoop("RollEgg")
	end
end)
y = y2

-- Remote Spy
local spyBtn, y2 = createFlatButton(farmingScroll, "Remote Spy", y, BUTTON_BG, BUTTON_BORDER, function()
	loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
end)
y = y2

-- KILL SCRIPT
local killBtn, y2 = createFlatButton(farmingScroll, "🛑 KILL SCRIPT", y, BUTTON_BG, BUTTON_BORDER, function()
	killScript()
end)

-- Mining Tab
local miningFrame = Instance.new("Frame")
miningFrame.Size = UDim2.new(1, 0, 1, -40)
miningFrame.Position = UDim2.new(0, 0, 0, 40)
miningFrame.BackgroundTransparency = 1
miningFrame.Parent = mainFrame
miningFrame.Visible = false
tabFrames["Mining"] = miningFrame
local miningScroll = createScrollableFrame(miningFrame)
local yM = 0
yM = createSectionHeader(miningScroll, "Mining Ores", yM)

local oreNames = {
	[6] = "Dirt",
	[5] = "Stone",
	[3] = "Ruby",
	[2] = "Platinum",
	[1] = "Gold",
	[4] = "Emerald",
	[9] = "Amethyst",
	[7] = "Runic"
}
local oreOrder = {6,5,3,2,1,4,9,7}
local oreCheckboxes = {}
local mineAllChecked = false
local checkboxes = {}

local y = yM
for _, oreId in ipairs(oreOrder) do
	local cb, newY, getChecked, setChecked = createFlatCheckbox(miningScroll, oreNames[oreId], y, function(val) end)
	oreCheckboxes[oreId] = getChecked
	checkboxes[oreId] = setChecked
	y = newY
end
local cb, newY, getChecked, setChecked = createFlatCheckbox(miningScroll, "Mine All", y, function(val)
	mineAllChecked = val
	for _, setFn in pairs(checkboxes) do
		setFn(val)
	end
end)
local mineAllBox = cb
mineAllBox.MouseButton1Click:Connect(function()
	mineAllChecked = not mineAllChecked
	for _, setFn in pairs(checkboxes) do
		setFn(mineAllChecked)
	end
end)
y = newY

-- Auto Mine Button
local autoMineState = {debounce = false, running = false}
local autoMineBtn, y2 = createFlatButton(miningScroll, "Auto Mine: OFF", y, BUTTON_BG, BUTTON_BORDER, function()
	if not debounceToggle(autoMineState, "debounce") then return end
	autoMineState.running = not autoMineState.running
	autoMineBtn.Text = autoMineState.running and "Auto Mine: ON" or "Auto Mine: OFF"
	autoMineBtn.BackgroundColor3 = autoMineState.running and BUTTON_BG or BUTTON_BG
	if autoMineState.running then
		startLoop("AutoMine", function()
			if mineAllChecked then
				for _, oreId in ipairs(oreOrder) do
					network:WaitForChild("Mining_Attack"):InvokeServer(oreId)
					task.wait(0.2)
				end
			else
				for _, oreId in ipairs(oreOrder) do
					if oreCheckboxes[oreId]() then
						network:WaitForChild("Mining_Attack"):InvokeServer(oreId)
						task.wait(0.2)
					end
				end
			end
			task.wait(0.5)
		end)
	else
		stopLoop("AutoMine")
	end
end)
y = y2

-- KILL SCRIPT
local killBtn2, y2 = createFlatButton(miningScroll, "🛑 KILL SCRIPT", y, BUTTON_BG, BUTTON_BORDER, function()
	killScript()
end)

-- Merchants Tab
local merchantsFrame = Instance.new("Frame")
merchantsFrame.Size = UDim2.new(1, -8, 1, -36)
merchantsFrame.Position = UDim2.new(0, 4, 0, 32)
merchantsFrame.BackgroundTransparency = 1
merchantsFrame.Parent = mainFrame
merchantsFrame.Visible = false
tabFrames["Merchants"] = merchantsFrame

local merchantsHeader = Instance.new("Frame")
merchantsHeader.Size = UDim2.new(1, 0, 0, 22)
merchantsHeader.Position = UDim2.new(0, 0, 0, 0)
merchantsHeader.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
merchantsHeader.Parent = merchantsFrame

local merchantsLabel = Instance.new("TextLabel")
merchantsLabel.Size = UDim2.new(1, -28, 1, 0)
merchantsLabel.Position = UDim2.new(0, 4, 0, 0)
merchantsLabel.BackgroundTransparency = 1
merchantsLabel.TextColor3 = Color3.fromRGB(255,255,255)
merchantsLabel.Font = Enum.Font.SourceSansBold
merchantsLabel.TextSize = 13
merchantsLabel.Text = "Merchants"
merchantsLabel.TextXAlignment = Enum.TextXAlignment.Left
merchantsLabel.Parent = merchantsHeader

local merchantTypes = {
	{name = "MiningMerchant", count = 8},
	{name = "FishingMerchant", count = 6},
	{name = "IceFishingMerchant", count = 6}
}

local y3 = 10
local spacing3 = 28

-- Start Potion Vending
local potionBtn = Instance.new("TextButton")
potionBtn.Size = UDim2.new(0, 170, 0, 24)
potionBtn.Position = UDim2.new(0, 10, 0, y3)
potionBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
potionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
potionBtn.Font = Enum.Font.SourceSansBold
potionBtn.TextSize = 13
potionBtn.Text = "Start Potion Vending"
potionBtn.Parent = merchantsFrame

local potionRunning = false
potionBtn.MouseButton1Click:Connect(function()
	potionRunning = not potionRunning
	if potionRunning then
		potionBtn.Text = "Stop Potion Vending"
		potionBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		task.spawn(function()
			while potionRunning and not killed do
				network:WaitForChild("VendingMachines_Purchase"):InvokeServer("PotionVendingMachine")
				task.wait(2)
			end
		end)
	else
		potionBtn.Text = "Start Potion Vending"
		potionBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end)

y3 = y3 + spacing3
-- Start MiningMerchant (1-8)
local miningMerchantBtn = Instance.new("TextButton")
miningMerchantBtn.Size = UDim2.new(0, 170, 0, 24)
miningMerchantBtn.Position = UDim2.new(0, 10, 0, y3)
miningMerchantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
miningMerchantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miningMerchantBtn.Font = Enum.Font.SourceSansBold
miningMerchantBtn.TextSize = 13
miningMerchantBtn.Text = "Start MiningMerchant (1-8)"
miningMerchantBtn.Parent = merchantsFrame

local miningMerchantRunning = false
miningMerchantBtn.MouseButton1Click:Connect(function()
	miningMerchantRunning = not miningMerchantRunning
	if miningMerchantRunning then
		miningMerchantBtn.Text = "Stop MiningMerchant (1-8)"
		miningMerchantBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		task.spawn(function()
			while miningMerchantRunning and not killed do
				for i = 1, 8 do
					network:WaitForChild("CustomMerchants_Purchase"):InvokeServer("MiningMerchant", i)
					task.wait(0.1)
				end
				task.wait(1)
			end
		end)
	else
		miningMerchantBtn.Text = "Start MiningMerchant (1-8)"
		miningMerchantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end)

y3 = y3 + spacing3
-- Start FarmingMerchant (1-6)
local farmMerchantBtn = Instance.new("TextButton")
farmMerchantBtn.Size = UDim2.new(0, 170, 0, 24)
farmMerchantBtn.Position = UDim2.new(0, 10, 0, y3)
farmMerchantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
farmMerchantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
farmMerchantBtn.Font = Enum.Font.SourceSansBold
farmMerchantBtn.TextSize = 13
farmMerchantBtn.Text = "Start FarmingMerchant (1-6)"
farmMerchantBtn.Parent = merchantsFrame

local farmMerchantRunning = false
farmMerchantBtn.MouseButton1Click:Connect(function()
	farmMerchantRunning = not farmMerchantRunning
	if farmMerchantRunning then
		farmMerchantBtn.Text = "Stop FarmingMerchant (1-6)"
		farmMerchantBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		task.spawn(function()
			while farmMerchantRunning and not killed do
				for i = 1, 6 do
					network:WaitForChild("CustomMerchants_Purchase"):InvokeServer("FarmingMerchant", i)
					task.wait(0.1)
				end
				task.wait(1)
			end
		end)
	else
		farmMerchantBtn.Text = "Start FarmingMerchant (1-6)"
		farmMerchantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end)

y3 = y3 + spacing3
-- Start StandardMerchant (1-6)
local stdMerchantBtn = Instance.new("TextButton")
stdMerchantBtn.Size = UDim2.new(0, 170, 0, 24)
stdMerchantBtn.Position = UDim2.new(0, 10, 0, y3)
stdMerchantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
stdMerchantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stdMerchantBtn.Font = Enum.Font.SourceSansBold
stdMerchantBtn.TextSize = 13
stdMerchantBtn.Text = "Start StandardMerchant (1-6)"
stdMerchantBtn.Parent = merchantsFrame

local stdMerchantRunning = false
stdMerchantBtn.MouseButton1Click:Connect(function()
	stdMerchantRunning = not stdMerchantRunning
	if stdMerchantRunning then
		stdMerchantBtn.Text = "Stop StandardMerchant (1-6)"
		stdMerchantBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		task.spawn(function()
			while stdMerchantRunning and not killed do
				for i = 1, 6 do
					network:WaitForChild("CustomMerchants_Purchase"):InvokeServer("StandardMerchant", i)
					task.wait(0.1)
				end
				task.wait(1)
			end
		end)
	else
		stdMerchantBtn.Text = "Start StandardMerchant (1-6)"
		stdMerchantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end)

y3 = y3 + spacing3
-- Start FishingMerchant (1-6)
local fishingMerchantBtn = Instance.new("TextButton")
fishingMerchantBtn.Size = UDim2.new(0, 170, 0, 24)
fishingMerchantBtn.Position = UDim2.new(0, 10, 0, y3)
fishingMerchantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
fishingMerchantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fishingMerchantBtn.Font = Enum.Font.SourceSansBold
fishingMerchantBtn.TextSize = 13
fishingMerchantBtn.Text = "Start FishingMerchant (1-6)"
fishingMerchantBtn.Parent = merchantsFrame

local fishingMerchantRunning = false
fishingMerchantBtn.MouseButton1Click:Connect(function()
	fishingMerchantRunning = not fishingMerchantRunning
	if fishingMerchantRunning then
		fishingMerchantBtn.Text = "Stop FishingMerchant (1-6)"
		fishingMerchantBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		task.spawn(function()
			while fishingMerchantRunning and not killed do
				for i = 1, 6 do
					network:WaitForChild("CustomMerchants_Purchase"):InvokeServer("FishingMerchant", i)
					task.wait(0.1)
				end
				task.wait(1)
			end
		end)
	else
		fishingMerchantBtn.Text = "Start FishingMerchant (1-6)"
		fishingMerchantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end)

y3 = y3 + spacing3
-- Start IceFishingMerchant (1-6)
local iceFishingMerchantBtn = Instance.new("TextButton")
iceFishingMerchantBtn.Size = UDim2.new(0, 170, 0, 24)
iceFishingMerchantBtn.Position = UDim2.new(0, 10, 0, y3)
iceFishingMerchantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
iceFishingMerchantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
iceFishingMerchantBtn.Font = Enum.Font.SourceSansBold
iceFishingMerchantBtn.TextSize = 13
iceFishingMerchantBtn.Text = "Start IceFishingMerchant (1-6)"
iceFishingMerchantBtn.Parent = merchantsFrame

local iceFishingMerchantRunning = false
iceFishingMerchantBtn.MouseButton1Click:Connect(function()
	iceFishingMerchantRunning = not iceFishingMerchantRunning
	if iceFishingMerchantRunning then
		iceFishingMerchantBtn.Text = "Stop IceFishingMerchant (1-6)"
		iceFishingMerchantBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		task.spawn(function()
			while iceFishingMerchantRunning and not killed do
				for i = 1, 6 do
					network:WaitForChild("CustomMerchants_Purchase"):InvokeServer("IceFishingMerchant", i)
					task.wait(0.1)
				end
				task.wait(1)
			end
		end)
	else
		iceFishingMerchantBtn.Text = "Start IceFishingMerchant (1-6)"
		iceFishingMerchantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end)

-- Show only the selected tab
switchTab(selectedTab)
