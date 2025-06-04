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
mainFrame.Size = UDim2.new(0, 170, 0, 230)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 20, 0, 20)
minimizeButton.Position = UDim2.new(1, -24, 0, 4)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 12
minimizeButton.Text = "-"
minimizeButton.Parent = mainFrame

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	mainFrame.Visible = not minimized
	if minimized then
		if not screenGui:FindFirstChild("RestoreButton") then
			local restoreButton = Instance.new("TextButton")
			restoreButton.Name = "RestoreButton"
			restoreButton.Size = UDim2.new(0, 24, 0, 24)
			restoreButton.Position = UDim2.new(0, 10, 0, 10)
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

local tabY = 4
for i, tabName in ipairs(tabs) do
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, 50, 0, 18)
	tabBtn.Position = UDim2.new(0, 4 + (i-1)*54, 0, tabY)
	tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabBtn.Font = Enum.Font.SourceSansBold
	tabBtn.TextSize = 12
	tabBtn.Text = tabName
	tabBtn.Parent = mainFrame
	tabBtn.MouseButton1Click:Connect(function()
		switchTab(tabName)
	end)
end

-- Store toggle states and running threads
local toggles = {}
local runningThreads = {}
local killed = false

-- Farming Tab (reuse previous farming toggles)
local farmingFrame = Instance.new("Frame")
farmingFrame.Size = UDim2.new(1, -8, 1, -28)
farmingFrame.Position = UDim2.new(0, 4, 0, 26)
farmingFrame.BackgroundTransparency = 1
farmingFrame.Parent = mainFrame
tabFrames["Farming"] = farmingFrame

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
miningFrame.Size = UDim2.new(1, -8, 1, -28)
miningFrame.Position = UDim2.new(0, 4, 0, 26)
miningFrame.BackgroundTransparency = 1
miningFrame.Parent = mainFrame
miningFrame.Visible = false
tabFrames["Mining"] = miningFrame

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
	cb.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	cb.TextColor3 = Color3.fromRGB(255,255,255)
	cb.Font = Enum.Font.SourceSans
	cb.TextSize = 11
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
	end)
	oreCheckboxes[oreId] = function() return checked end
	y2 = y2 + 18
end

mineAllBox = Instance.new("TextButton")
mineAllBox.Size = UDim2.new(0, 16, 0, 16)
mineAllBox.Position = UDim2.new(0, 10, 0, y2)
mineAllBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
mineAllBox.TextColor3 = Color3.fromRGB(255,255,255)
mineAllBox.Font = Enum.Font.SourceSans
mineAllBox.TextSize = 11
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
merchantsFrame.Size = UDim2.new(1, -8, 1, -28)
merchantsFrame.Position = UDim2.new(0, 4, 0, 26)
merchantsFrame.BackgroundTransparency = 1
merchantsFrame.Parent = mainFrame
merchantsFrame.Visible = false
tabFrames["Merchants"] = merchantsFrame

local merchantTypes = {
	{name = "MiningMerchant", count = 8},
	{name = "FishingMerchant", count = 6},
	{name = "IceFishingMerchant", count = 6}
}
local merchantCheckboxes = {}
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
	y3 = y3 + 16
	for i = 1, merchant.count do
		local cb = Instance.new("TextButton")
		cb.Size = UDim2.new(0, 16, 0, 16)
		cb.Position = UDim2.new(0, 20 + (i-1)*18, 0, y3)
		cb.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		cb.TextColor3 = Color3.fromRGB(255,255,255)
		cb.Font = Enum.Font.SourceSans
		cb.TextSize = 11
		cb.Text = ""
		cb.Parent = merchantsFrame
		local checked = false
		cb.MouseButton1Click:Connect(function()
			checked = not checked
			cb.Text = checked and "✔" or ""
		end)
		merchantCheckboxes[merchant.name .. i] = function() return checked end
	end
	y3 = y3 + 18
end

local autoBuyBtn = Instance.new("TextButton")
autoBuyBtn.Size = UDim2.new(0, 90, 0, 18)
autoBuyBtn.Position = UDim2.new(0, 10, 0, y3)
autoBuyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
autoBuyBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoBuyBtn.Font = Enum.Font.SourceSansBold
autoBuyBtn.TextSize = 11
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
						if merchantCheckboxes[merchant.name .. i]() then
							network:WaitForChild("CustomMerchants_Purchase"):InvokeServer(merchant.name, i)
							task.wait(0.2)
						end
					end
				end
				task.wait(0.5)
			end
		end)
	end
end)

y3 = y3 + 24
local killButton3 = Instance.new("TextButton")
killButton3.Size = UDim2.new(0, 90, 0, 18)
killButton3.Position = UDim2.new(0, 10, 0, y3)
killButton3.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton3.Font = Enum.Font.SourceSansBold
killButton3.TextSize = 11
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
