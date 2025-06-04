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
mainFrame.Size = UDim2.new(0, 180, 0, 320)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 24, 0, 24)
minimizeButton.Position = UDim2.new(1, -28, 0, 4)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 16
minimizeButton.Text = "-"
minimizeButton.Parent = mainFrame

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	mainFrame.Visible = not minimized
	if minimized then
		-- Create a restore button in the corner of the screen
		if not screenGui:FindFirstChild("RestoreButton") then
			local restoreButton = Instance.new("TextButton")
			restoreButton.Name = "RestoreButton"
			restoreButton.Size = UDim2.new(0, 32, 0, 32)
			restoreButton.Position = UDim2.new(0, 10, 0, 10)
			restoreButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			restoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			restoreButton.Font = Enum.Font.SourceSansBold
			restoreButton.TextSize = 18
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

-- Store toggle states and running threads
local toggles = {}
local runningThreads = {}
local killed = false

-- Toggle Button Builder
local function createToggleButton(name, posY, loopFunc)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 140, 0, 24)
	button.Position = UDim2.new(0, 20, 0, posY)
	button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 13
	button.Text = "Start " .. name
	button.Parent = mainFrame

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

-- All Toggleable Features:
local y = 36
local spacing = 28
createToggleButton("FarmingMerchant (1-6)", y, function(isRunning)
	while isRunning() do
		for i = 1, 6 do
			network:WaitForChild("CustomMerchants_Purchase"):InvokeServer("FarmingMerchant", i)
			task.wait(0.3)
		end
		task.wait(1)
	end
end)
y = y + spacing
createToggleButton("StandardMerchant (1-6)", y, function(isRunning)
	while isRunning() do
		for i = 1, 6 do
			network:WaitForChild("CustomMerchants_Purchase"):InvokeServer("StandardMerchant", i)
			task.wait(0.3)
		end
		task.wait(1)
	end
end)
y = y + spacing
createToggleButton("Loot Chest Unlock (5)", y, function(isRunning)
	while isRunning() do
		network:WaitForChild("LootChest_Unlock"):InvokeServer(5, false)
		task.wait(2)
	end
end)
y = y + spacing
createToggleButton("AutoFarm", y, function(isRunning)
	while isRunning() do
		network:WaitForChild("Farming_AutoFarm"):FireServer()
		task.wait(2)
	end
end)
y = y + spacing
createToggleButton("FarmingHold_Start", y, function(isRunning)
	local id = "7bd389d1c6c941dfa53e26e2c3e0910f" -- Update ID if needed
	while isRunning() do
		network:WaitForChild("FarmingHold_Start"):FireServer(id)
		task.wait(2)
	end
end)
y = y + spacing
createToggleButton("Potion Vending", y, function(isRunning)
	while isRunning() do
		network:WaitForChild("VendingMachines_Purchase"):InvokeServer("PotionVendingMachine")
		task.wait(2)
	end
end)
y = y + spacing
createToggleButton("Roll Egg", y, function(isRunning)
	while isRunning() do
		network:WaitForChild("Eggs_Roll"):InvokeServer()
		task.wait(2)
	end
end)

y = y + spacing + 8
-- Remote Spy Button
local spyButton = Instance.new("TextButton")
spyButton.Size = UDim2.new(0, 140, 0, 24)
spyButton.Position = UDim2.new(0, 20, 0, y)
spyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
spyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spyButton.Font = Enum.Font.SourceSansBold
spyButton.TextSize = 13
spyButton.Text = "Remote Spy"
spyButton.Parent = mainFrame
spyButton.MouseButton1Click:Connect(function()
	loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))()
end)

y = y + spacing + 8
-- 🔴 Kill Script Button
local killButton = Instance.new("TextButton")
killButton.Size = UDim2.new(0, 140, 0, 24)
killButton.Position = UDim2.new(0, 20, 0, y)
killButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.Font = Enum.Font.SourceSansBold
killButton.TextSize = 13
killButton.Text = "🛑 KILL SCRIPT"
killButton.Parent = mainFrame

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
