-- LocalScript inside StarterGui

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local network = rs:WaitForChild("Network")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmingHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Modernized GUI Styles
local BUTTON_COLOR = Color3.fromRGB(40, 40, 40)
local BUTTON_COLOR_ACTIVE = Color3.fromRGB(0, 170, 0)
local BUTTON_COLOR_DANGER = Color3.fromRGB(200, 40, 40)
local BUTTON_COLOR_SECONDARY = Color3.fromRGB(60, 60, 120)
local BUTTON_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local BUTTON_HOVER_COLOR = Color3.fromRGB(70, 70, 70)
local FRAME_BG = Color3.fromRGB(25, 25, 25)
local SECTION_HEADER_COLOR = Color3.fromRGB(50, 50, 50)
local CORNER_RADIUS = UDim.new(0, 8)

-- Main Frame (Resizable)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 370)
mainFrame.Position = UDim2.new(0, 200, 0, 120)
mainFrame.BackgroundColor3 = FRAME_BG
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = CORNER_RADIUS
mainCorner.Parent = mainFrame

-- Resizer (bottom right)
local resizer = Instance.new("Frame")
resizer.Size = UDim2.new(0, 16, 0, 16)
resizer.Position = UDim2.new(1, -16, 1, -16)
resizer.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
resizer.BorderSizePixel = 0
resizer.Parent = mainFrame
local resizerCorner = Instance.new("UICorner")
resizerCorner.CornerRadius = UDim.new(1, 0)
resizerCorner.Parent = resizer
resizer.Active = true

local resizing = false
local resizeStart, frameStart
resizer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true
		resizeStart = input.Position
		frameStart = mainFrame.Size
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				resizing = false
			end
		end)
	end
end)
resizer.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		local UIS = game:GetService("UserInputService")
		UIS.InputChanged:Connect(function(moveInput)
			if resizing and moveInput == input then
				local delta = moveInput.Position - resizeStart
				mainFrame.Size = UDim2.new(0, math.max(220, frameStart.X.Offset + delta.X), 0, math.max(220, frameStart.Y.Offset + delta.Y))
			end
		end)
	end
end)

-- Top Bar (Draggable)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = SECTION_HEADER_COLOR
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame
local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = CORNER_RADIUS
topBarCorner.Parent = topBar

topBar.Active = true
topBar.Draggable = false
local dragging, dragInput, dragStart, startPos
local UIS = game:GetService("UserInputService")
topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
topBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Tab Bar
local tabs = {"Farming", "Mining", "Merchants"}
local tabFrames = {}
local selectedTab = "Farming"
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 32)
tabBar.Position = UDim2.new(0, 0, 0, 0)
tabBar.BackgroundTransparency = 1
tabBar.Parent = topBar

local tabBtnX = 8
for i, tabName in ipairs(tabs) do
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, 80, 0, 28)
	tabBtn.Position = UDim2.new(0, tabBtnX, 0, 2)
	tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	tabBtn.TextColor3 = BUTTON_TEXT_COLOR
	tabBtn.Font = Enum.Font.SourceSansBold
	tabBtn.TextSize = 15
	tabBtn.Text = tabName
	tabBtn.Parent = tabBar
	local tabBtnCorner = Instance.new("UICorner")
	tabBtnCorner.CornerRadius = CORNER_RADIUS
	tabBtnCorner.Parent = tabBtn
	tabBtn.MouseEnter:Connect(function()
		tabBtn.BackgroundColor3 = BUTTON_HOVER_COLOR
	end)
	tabBtn.MouseLeave:Connect(function()
		tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end)
	tabBtn.MouseButton1Click:Connect(function()
		selectedTab = tabName
		for name, frame in pairs(tabFrames) do
			frame.Visible = (name == tabName)
		end
	end)
	tabBtnX = tabBtnX + 88
end

-- Section Header Helper
local function createSectionHeader(parent, text, y)
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -16, 0, 22)
	header.Position = UDim2.new(0, 8, 0, y)
	header.BackgroundColor3 = SECTION_HEADER_COLOR
	header.TextColor3 = BUTTON_TEXT_COLOR
	header.Font = Enum.Font.SourceSansBold
	header.TextSize = 14
	header.Text = text
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.BackgroundTransparency = 0.1
	header.Parent = parent
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = CORNER_RADIUS
	headerCorner.Parent = header
	return y + 28
end

-- Button Helper
local function createModernButton(parent, text, y, color, colorActive, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -32, 0, 32)
	btn.Position = UDim2.new(0, 16, 0, y)
	btn.BackgroundColor3 = color or BUTTON_COLOR
	btn.TextColor3 = BUTTON_TEXT_COLOR
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 15
	btn.Text = text
	btn.Parent = parent
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = CORNER_RADIUS
	btnCorner.Parent = btn
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = BUTTON_HOVER_COLOR
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = color or BUTTON_COLOR
	end)
	btn.MouseButton1Click:Connect(callback)
	return btn, y + 40
end

-- Scrollable Content Helper
local function createScrollableFrame(parent)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -40)
	scroll.Position = UDim2.new(0, 0, 0, 40)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
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
local autoFarmState = {debounce = false, running = false}
local autoFarmBtn, y2 = createModernButton(farmingScroll, "Start Auto Farm", y, BUTTON_COLOR, BUTTON_COLOR_ACTIVE, function()
	if not debounceToggle(autoFarmState, "debounce") then return end
	autoFarmState.running = not autoFarmState.running
	autoFarmBtn.Text = autoFarmState.running and "Stop Auto Farm" or "Start Auto Farm"
	autoFarmBtn.BackgroundColor3 = autoFarmState.running and BUTTON_COLOR_ACTIVE or BUTTON_COLOR
	if autoFarmState.running then
		startLoop("AutoFarm", function()
			network:WaitForChild("Farming_AutoFarm"):FireServer()
			task.wait(2)
		end)
	else
		stopLoop("AutoFarm")
	end
end)
y = y2

-- Start Auto Plant Seeds
local autoPlantState = {debounce = false, running = false}
local autoPlantBtn, y2 = createModernButton(farmingScroll, "Start Auto Plant Seeds", y, BUTTON_COLOR, BUTTON_COLOR_ACTIVE, function()
	if not debounceToggle(autoPlantState, "debounce") then return end
	autoPlantState.running = not autoPlantState.running
	autoPlantBtn.Text = autoPlantState.running and "Stop Auto Plant Seeds" or "Start Auto Plant Seeds"
	autoPlantBtn.BackgroundColor3 = autoPlantState.running and BUTTON_COLOR_ACTIVE or BUTTON_COLOR
	if autoPlantState.running then
		startLoop("AutoPlant", function()
			local id = "7bd389d1c6c941dfa53e26e2c3e0910f"
			network:WaitForChild("FarmingHold_Start"):FireServer(id)
			task.wait(2)
		end)
	else
		stopLoop("AutoPlant")
	end
end)
y = y2

-- Start Roll Egg
local rollEggState = {debounce = false, running = false}
local rollEggBtn, y2 = createModernButton(farmingScroll, "Start Roll Egg", y, BUTTON_COLOR, BUTTON_COLOR_ACTIVE, function()
	if not debounceToggle(rollEggState, "debounce") then return end
	rollEggState.running = not rollEggState.running
	rollEggBtn.Text = rollEggState.running and "Stop Roll Egg" or "Start Roll Egg"
	rollEggBtn.BackgroundColor3 = rollEggState.running and BUTTON_COLOR_ACTIVE or BUTTON_COLOR
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
local spyBtn, y2 = createModernButton(farmingScroll, "Remote Spy", y, BUTTON_COLOR_SECONDARY, BUTTON_COLOR_ACTIVE, function()
	loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
end)
y = y2

-- KILL SCRIPT
local killBtn, y2 = createModernButton(farmingScroll, "🛑 KILL SCRIPT", y, BUTTON_COLOR_DANGER, BUTTON_COLOR_DANGER, function()
	killScript()
end)

-- Mining Tab
local miningFrame = Instance.new("Frame")
miningFrame.Size = UDim2.new(1, -8, 1, -36)
miningFrame.Position = UDim2.new(0, 4, 0, 32)
miningFrame.BackgroundTransparency = 1
miningFrame.Parent = mainFrame
miningFrame.Visible = false
tabFrames["Mining"] = miningFrame

local miningHeader = Instance.new("Frame")
miningHeader.Size = UDim2.new(1, 0, 0, 22)
miningHeader.Position = UDim2.new(0, 0, 0, 0)
miningHeader.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
miningHeader.Parent = miningFrame

local miningLabel = Instance.new("TextLabel")
miningLabel.Size = UDim2.new(1, -28, 1, 0)
miningLabel.Position = UDim2.new(0, 4, 0, 0)
miningLabel.BackgroundTransparency = 1
miningLabel.TextColor3 = Color3.fromRGB(255,255,255)
miningLabel.Font = Enum.Font.SourceSansBold
miningLabel.TextSize = 13
miningLabel.Text = "Mining"
miningLabel.TextXAlignment = Enum.TextXAlignment.Left
miningLabel.Parent = miningHeader

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
local mineAllBox

local y2 = 2
for _, oreId in ipairs(oreOrder) do
	local cb = Instance.new("TextButton")
	cb.Size = UDim2.new(0, 16, 0, 16)
	cb.Position = UDim2.new(0, 10, 0, y2)
	cb.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	cb.BorderSizePixel = 1
	cb.BorderColor3 = Color3.fromRGB(180, 180, 180)
	cb.TextColor3 = Color3.fromRGB(40,40,40)
	cb.Font = Enum.Font.SourceSansBold
	cb.TextSize = 13
	cb.Text = ""
	cb.Parent = miningFrame
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 60, 0, 16)
	label.Position = UDim2.new(0, 30, 0, y2)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 11
	label.Text = oreNames[oreId]
	label.Parent = miningFrame
	local checked = false
	cb.MouseButton1Click:Connect(function()
		checked = not checked
		cb.Text = checked and "✔" or ""
		cb.TextColor3 = checked and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40,40,40)
	end)
	oreCheckboxes[oreId] = function() return checked end
	y2 = y2 + 18
end

mineAllBox = Instance.new("TextButton")
mineAllBox.Size = UDim2.new(0, 16, 0, 16)
mineAllBox.Position = UDim2.new(0, 10, 0, y2)
mineAllBox.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
mineAllBox.BorderSizePixel = 1
mineAllBox.BorderColor3 = Color3.fromRGB(180, 180, 180)
mineAllBox.TextColor3 = Color3.fromRGB(40,40,40)
mineAllBox.Font = Enum.Font.SourceSansBold
mineAllBox.TextSize = 13
mineAllBox.Text = ""
mineAllBox.Parent = miningFrame
local mineAllLabel = Instance.new("TextLabel")
mineAllLabel.Size = UDim2.new(0, 60, 0, 16)
mineAllLabel.Position = UDim2.new(0, 30, 0, y2)
mineAllLabel.BackgroundTransparency = 1
mineAllLabel.TextColor3 = Color3.fromRGB(255,255,255)
mineAllLabel.Font = Enum.Font.SourceSans
mineAllLabel.TextSize = 11
mineAllLabel.Text = "Mine All"
mineAllLabel.Parent = miningFrame
local mineAllChecked = false
mineAllBox.MouseButton1Click:Connect(function()
	mineAllChecked = not mineAllChecked
	mineAllBox.Text = mineAllChecked and "✔" or ""
	mineAllBox.TextColor3 = mineAllChecked and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(40,40,40)
end)
y2 = y2 + 20

local autoMineBtn = Instance.new("TextButton")
autoMineBtn.Size = UDim2.new(0, 90, 0, 18)
autoMineBtn.Position = UDim2.new(0, 10, 0, y2)
autoMineBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
autoMineBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoMineBtn.Font = Enum.Font.SourceSansBold
autoMineBtn.TextSize = 11
autoMineBtn.Text = "Auto Mine: OFF"
autoMineBtn.Parent = miningFrame
local miningActive = false
autoMineBtn.MouseButton1Click:Connect(function()
	miningActive = not miningActive
	autoMineBtn.Text = miningActive and "Auto Mine: ON" or "Auto Mine: OFF"
	if miningActive then
		task.spawn(function()
			while miningActive and not killed do
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
			end
		end)
	end
end)

y2 = y2 + 24
local killButton2 = Instance.new("TextButton")
killButton2.Size = UDim2.new(0, 90, 0, 18)
killButton2.Position = UDim2.new(0, 10, 0, y2)
killButton2.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton2.Font = Enum.Font.SourceSansBold
killButton2.TextSize = 11
killButton2.Text = "🛑 KILL SCRIPT"
killButton2.Parent = miningFrame
killButton2.MouseButton1Click:Connect(function()
	killed = true
	for key in pairs(toggles) do
		toggles[key] = function() return false end
	end
	screenGui:Destroy()
	if screenGui:FindFirstChild("RestoreButton") then
		screenGui.RestoreButton:Destroy()
	end
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
