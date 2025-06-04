-- LocalScript inside StarterGui

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local network = rs:WaitForChild("Network")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmingHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 260)
mainFrame.Position = UDim2.new(0, 200, 0, 120)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Custom Top Bar for Dragging
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 24)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

topBar.Active = true
topBar.Draggable = false

-- Custom drag logic
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

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 20, 0, 20)
minimizeButton.Position = UDim2.new(1, -24, 0, 2)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 12
minimizeButton.Text = "-"
minimizeButton.Parent = topBar

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	mainFrame.Visible = not minimized
	if minimized then
		if not screenGui:FindFirstChild("RestoreButton") then
			local restoreButton = Instance.new("TextButton")
			restoreButton.Name = "RestoreButton"
			restoreButton.Size = UDim2.new(0, 24, 0, 24)
			restoreButton.Position = UDim2.new(0, 200, 0, 120)
			restoreButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			restoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			restoreButton.Font = Enum.Font.SourceSansBold
			restoreButton.TextSize = 14
			restoreButton.Text = "+"
			restoreButton.Parent = screenGui
			restoreButton.MouseButton1Click:Connect(function()
				mainFrame.Visible = true
				minimized = false
				restoreButton:Destroy()
			end)
		end
	end
end)

-- Tabs
local tabs = {"Farming", "Mining", "Merchants"}
local tabFrames = {}
local selectedTab = "Farming"

local function switchTab(tabName)
	selectedTab = tabName
	for name, frame in pairs(tabFrames) do
		frame.Visible = (name == tabName)
	end
end

local tabY = 2
for i, tabName in ipairs(tabs) do
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, 60, 0, 20)
	tabBtn.Position = UDim2.new(0, 6 + (i-1)*64, 0, tabY)
	tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabBtn.Font = Enum.Font.SourceSansBold
	tabBtn.TextSize = 12
	tabBtn.Text = tabName
	tabBtn.Parent = topBar
	tabBtn.MouseButton1Click:Connect(function()
		switchTab(tabName)
	end)
end

-- Store toggle states and running threads
local toggles = {}
local runningThreads = {}
local killed = false

-- Hamburger Menu Helper
local function createHamburger(parent, posX, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 22, 0, 22)
	btn.Position = UDim2.new(0, posX, 0, 0)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.Text = "☰"
	btn.Parent = parent
	btn.AutoButtonColor = true
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Dropdown Helper
local function createDropdown(parent, y, items)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 120, 0, #items*20+4)
	frame.Position = UDim2.new(0, 30, 0, y)
	frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	frame.BorderSizePixel = 0
	frame.Parent = parent
	for i, item in ipairs(items) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -8, 0, 18)
		btn.Position = UDim2.new(0, 4, 0, 2+(i-1)*20)
		btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 12
		btn.Text = item.text
		btn.Parent = frame
		btn.MouseButton1Click:Connect(function()
			item.callback()
			frame:Destroy()
		end)
	end
	return frame
end

-- Farming Tab
local farmingFrame = Instance.new("Frame")
farmingFrame.Size = UDim2.new(1, -8, 1, -36)
farmingFrame.Position = UDim2.new(0, 4, 0, 32)
farmingFrame.BackgroundTransparency = 1
farmingFrame.Parent = mainFrame
tabFrames["Farming"] = farmingFrame

local farmingHeader = Instance.new("Frame")
farmingHeader.Size = UDim2.new(1, 0, 0, 22)
farmingHeader.Position = UDim2.new(0, 0, 0, 0)
farmingHeader.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
farmingHeader.Parent = farmingFrame

local farmingLabel = Instance.new("TextLabel")
farmingLabel.Size = UDim2.new(1, -28, 1, 0)
farmingLabel.Position = UDim2.new(0, 4, 0, 0)
farmingLabel.BackgroundTransparency = 1
farmingLabel.TextColor3 = Color3.fromRGB(255,255,255)
farmingLabel.Font = Enum.Font.SourceSansBold
farmingLabel.TextSize = 13
farmingLabel.Text = "Farming"
farmingLabel.TextXAlignment = Enum.TextXAlignment.Left
farmingLabel.Parent = farmingHeader

local farmingDropdown
createHamburger(farmingHeader, farmingHeader.Size.X.Offset-24, function()
	if farmingDropdown then farmingDropdown:Destroy() farmingDropdown = nil return end
	farmingDropdown = createDropdown(farmingHeader, 22, {
		{text = "Advanced Setting 1", callback = function() end},
		{text = "Advanced Setting 2", callback = function() end},
	})
end)

local function createToggleButton_Farming(name, posY, loopFunc)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 130, 0, 18)
	button.Position = UDim2.new(0, 10, 0, posY)
	button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 11
	button.Text = "Start " .. name
	button.Parent = farmingFrame

	local isRunning = false
	toggles[name] = function() return isRunning and not killed end

	button.MouseButton1Click:Connect(function()
		isRunning = not isRunning
		if isRunning then
			button.Text = "Stop " .. name
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			local thread = task.spawn(function()
				loopFunc(function() return isRunning and not killed end)
			end)
			runningThreads[#runningThreads+1] = thread
		else
			button.Text = "Start " .. name
			button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		end
	end)
end

local y = 2
local spacing = 20
createToggleButton_Farming("FarmingMerchant (1-6)", y, function(isRunning)
	while isRunning() do
		for i = 1, 6 do
			network:WaitForChild("CustomMerchants_Purchase"):InvokeServer("FarmingMerchant", i)
			task.wait(0.3)
		end
		task.wait(1)
	end
end)
y = y + spacing
createToggleButton_Farming("StandardMerchant (1-6)", y, function(isRunning)
	while isRunning() do
		for i = 1, 6 do
			network:WaitForChild("CustomMerchants_Purchase"):InvokeServer("StandardMerchant", i)
			task.wait(0.3)
		end
		task.wait(1)
	end
end)
y = y + spacing
createToggleButton_Farming("Loot Chest Unlock (5)", y, function(isRunning)
	while isRunning() do
		network:WaitForChild("LootChest_Unlock"):InvokeServer(5, false)
		task.wait(2)
	end
end)
y = y + spacing
createToggleButton_Farming("AutoFarm", y, function(isRunning)
	while isRunning() do
		network:WaitForChild("Farming_AutoFarm"):FireServer()
		task.wait(2)
	end
end)
y = y + spacing
createToggleButton_Farming("FarmingHold_Start", y, function(isRunning)
	local id = "7bd389d1c6c941dfa53e26e2c3e0910f"
	while isRunning() do
		network:WaitForChild("FarmingHold_Start"):FireServer(id)
		task.wait(2)
	end
end)
y = y + spacing
createToggleButton_Farming("Potion Vending", y, function(isRunning)
	while isRunning() do
		network:WaitForChild("VendingMachines_Purchase"):InvokeServer("PotionVendingMachine")
		task.wait(2)
	end
end)
y = y + spacing
createToggleButton_Farming("Roll Egg", y, function(isRunning)
	while isRunning() do
		network:WaitForChild("Eggs_Roll"):InvokeServer()
		task.wait(2)
	end
end)

y = y + spacing + 4
local spyButton = Instance.new("TextButton")
spyButton.Size = UDim2.new(0, 130, 0, 18)
spyButton.Position = UDim2.new(0, 10, 0, y)
spyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
spyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spyButton.Font = Enum.Font.SourceSansBold
spyButton.TextSize = 11
spyButton.Text = "Remote Spy"
spyButton.Parent = farmingFrame
spyButton.MouseButton1Click:Connect(function()
	loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
end)

y = y + spacing + 4
local killButton = Instance.new("TextButton")
killButton.Size = UDim2.new(0, 130, 0, 18)
killButton.Position = UDim2.new(0, 10, 0, y)
killButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.Font = Enum.Font.SourceSansBold
killButton.TextSize = 11
killButton.Text = "🛑 KILL SCRIPT"
killButton.Parent = farmingFrame
killButton.MouseButton1Click:Connect(function()
	killed = true
	for key in pairs(toggles) do
		toggles[key] = function() return false end
	end
	screenGui:Destroy()
	if screenGui:FindFirstChild("RestoreButton") then
		screenGui.RestoreButton:Destroy()
	end
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

local miningDropdown
createHamburger(miningHeader, miningHeader.Size.X.Offset-24, function()
	if miningDropdown then miningDropdown:Destroy() miningDropdown = nil return end
	miningDropdown = createDropdown(miningHeader, 22, {
		{text = "Advanced Mining 1", callback = function() end},
		{text = "Advanced Mining 2", callback = function() end},
	})
end)

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

local merchantsDropdown
createHamburger(merchantsHeader, merchantsHeader.Size.X.Offset-24, function()
	if merchantsDropdown then merchantsDropdown:Destroy() merchantsDropdown = nil return end
	merchantsDropdown = createDropdown(merchantsHeader, 22, {
		{text = "Advanced Vendor 1", callback = function() end},
		{text = "Advanced Vendor 2", callback = function() end},
	})
end)

local merchantTypes = {
	{name = "MiningMerchant", count = 8},
	{name = "FishingMerchant", count = 6},
	{name = "IceFishingMerchant", count = 6}
}

local y3 = 2
for _, merchant in ipairs(merchantTypes) do
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 120, 0, 16)
	label.Position = UDim2.new(0, 10, 0, y3)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 11
	label.Text = merchant.name
	label.Parent = merchantsFrame
	y3 = y3 + 18
end

local autoBuyBtn = Instance.new("TextButton")
autoBuyBtn.Size = UDim2.new(0, 130, 0, 22)
autoBuyBtn.Position = UDim2.new(0, 10, 0, y3)
autoBuyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
autoBuyBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoBuyBtn.Font = Enum.Font.SourceSansBold
autoBuyBtn.TextSize = 13
autoBuyBtn.Text = "Auto Buy: OFF"
autoBuyBtn.Parent = merchantsFrame
local autoBuyActive = false
autoBuyBtn.MouseButton1Click:Connect(function()
	autoBuyActive = not autoBuyActive
	autoBuyBtn.Text = autoBuyActive and "Auto Buy: ON" or "Auto Buy: OFF"
	if autoBuyActive then
		task.spawn(function()
			while autoBuyActive and not killed do
				for _, merchant in ipairs(merchantTypes) do
					for i = 1, merchant.count do
						network:WaitForChild("CustomMerchants_Purchase"):InvokeServer(merchant.name, i)
						task.wait(0.2)
					end
				end
				task.wait(0.5)
			end
		end)
	end
end)

y3 = y3 + 28
local killButton3 = Instance.new("TextButton")
killButton3.Size = UDim2.new(0, 130, 0, 22)
killButton3.Position = UDim2.new(0, 10, 0, y3)
killButton3.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton3.Font = Enum.Font.SourceSansBold
killButton3.TextSize = 13
killButton3.Text = "🛑 KILL SCRIPT"
killButton3.Parent = merchantsFrame
killButton3.MouseButton1Click:Connect(function()
	killed = true
	for key in pairs(toggles) do
		toggles[key] = function() return false end
	end
	screenGui:Destroy()
	if screenGui:FindFirstChild("RestoreButton") then
		screenGui.RestoreButton:Destroy()
	end
end)

-- Show only the selected tab
switchTab(selectedTab)
