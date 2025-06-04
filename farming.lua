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

-- Farming Tab
local farmingFrame = Instance.new("Frame")
farmingFrame.Size = UDim2.new(1, -8, 1, -36)
farmingFrame.Position = UDim2.new(0, 4, 0, 32)
farmingFrame.BackgroundTransparency = 1
farmingFrame.Parent = mainFrame
tabFrames["Farming"] = farmingFrame

local y = 10
local spacing = 28

-- Start Auto Farm
local autoFarmBtn = Instance.new("TextButton")
autoFarmBtn.Size = UDim2.new(0, 170, 0, 24)
autoFarmBtn.Position = UDim2.new(0, 10, 0, y)
autoFarmBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
autoFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFarmBtn.Font = Enum.Font.SourceSansBold
autoFarmBtn.TextSize = 13
autoFarmBtn.Text = "Start Auto Farm"
autoFarmBtn.Parent = farmingFrame

local autoFarmRunning = false
autoFarmBtn.MouseButton1Click:Connect(function()
	autoFarmRunning = not autoFarmRunning
	if autoFarmRunning then
		autoFarmBtn.Text = "Stop Auto Farm"
		autoFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		task.spawn(function()
			while autoFarmRunning and not killed do
				network:WaitForChild("Farming_AutoFarm"):FireServer()
				task.wait(2)
			end
		end)
	else
		autoFarmBtn.Text = "Start Auto Farm"
		autoFarmBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end)

y = y + spacing
-- Start Auto Plant Seeds
local autoPlantBtn = Instance.new("TextButton")
autoPlantBtn.Size = UDim2.new(0, 170, 0, 24)
autoPlantBtn.Position = UDim2.new(0, 10, 0, y)
autoPlantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
autoPlantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoPlantBtn.Font = Enum.Font.SourceSansBold
autoPlantBtn.TextSize = 13
autoPlantBtn.Text = "Start Auto Plant Seeds"
autoPlantBtn.Parent = farmingFrame

local autoPlantRunning = false
autoPlantBtn.MouseButton1Click:Connect(function()
	autoPlantRunning = not autoPlantRunning
	if autoPlantRunning then
		autoPlantBtn.Text = "Stop Auto Plant Seeds"
		autoPlantBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		local id = "7bd389d1c6c941dfa53e26e2c3e0910f"
		task.spawn(function()
			while autoPlantRunning and not killed do
				network:WaitForChild("FarmingHold_Start"):FireServer(id)
				task.wait(2)
			end
		end)
	else
		autoPlantBtn.Text = "Start Auto Plant Seeds"
		autoPlantBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end)

y = y + spacing
-- Start Roll Egg
local rollEggBtn = Instance.new("TextButton")
rollEggBtn.Size = UDim2.new(0, 170, 0, 24)
rollEggBtn.Position = UDim2.new(0, 10, 0, y)
rollEggBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
rollEggBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rollEggBtn.Font = Enum.Font.SourceSansBold
rollEggBtn.TextSize = 13
rollEggBtn.Text = "Start Roll Egg"
rollEggBtn.Parent = farmingFrame

local rollEggRunning = false
rollEggBtn.MouseButton1Click:Connect(function()
	rollEggRunning = not rollEggRunning
	if rollEggRunning then
		rollEggBtn.Text = "Stop Roll Egg"
		rollEggBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		task.spawn(function()
			while rollEggRunning and not killed do
				network:WaitForChild("Eggs_Roll"):InvokeServer()
				task.wait(2)
			end
		end)
	else
		rollEggBtn.Text = "Start Roll Egg"
		rollEggBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end)

y = y + spacing
-- Remote Spy
local spyButton = Instance.new("TextButton")
spyButton.Size = UDim2.new(0, 170, 0, 24)
spyButton.Position = UDim2.new(0, 10, 0, y)
spyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
spyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spyButton.Font = Enum.Font.SourceSansBold
spyButton.TextSize = 13
spyButton.Text = "Remote Spy"
spyButton.Parent = farmingFrame
spyButton.MouseButton1Click:Connect(function()
	loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
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
