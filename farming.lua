-- LocalScript inside StarterGui

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local network = rs:WaitForChild("Network")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmingHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Store toggle states
local toggles = {}

-- Toggle Button Builder
local function createToggleButton(name, posY, loopFunc)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 250, 0, 40)
	button.Position = UDim2.new(0.5, -125, 0, posY)
	button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 18
	button.Text = "Start " .. name
	button.Parent = screenGui

	local isRunning = false
	toggles[name] = function() return isRunning end

	button.MouseButton1Click:Connect(function()
		isRunning = not isRunning
		if isRunning then
			button.Text = "Stop " .. name
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			task.spawn(function()
				loopFunc(function() return isRunning end)
			end)
		else
			button.Text = "Start " .. name
			button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		end
	end)
end

-- All Toggleable Features:

createToggleButton("FarmingMerchant (1-6)", 50, function(isRunning)
	while isRunning() do
		for i = 1, 6 do
			network:WaitForChild("CustomMerchants_Purchase"):InvokeServer("FarmingMerchant", i)
			task.wait(0.3)
		end
		task.wait(1)
	end
end)

createToggleButton("StandardMerchant (1-6)", 100, function(isRunning)
	while isRunning() do
		for i = 1, 6 do
			network:WaitForChild("CustomMerchants_Purchase"):InvokeServer("StandardMerchant", i)
			task.wait(0.3)
		end
		task.wait(1)
	end
end)

createToggleButton("Loot Chest Unlock (5)", 150, function(isRunning)
	while isRunning() do
		network:WaitForChild("LootChest_Unlock"):InvokeServer(5, false)
		task.wait(2)
	end
end)

createToggleButton("AutoFarm", 200, function(isRunning)
	while isRunning() do
		network:WaitForChild("Farming_AutoFarm"):FireServer()
		task.wait(2)
	end
end)

createToggleButton("FarmingHold_Start", 250, function(isRunning)
	local id = "7bd389d1c6c941dfa53e26e2c3e0910f" -- Update ID if needed
	while isRunning() do
		network:WaitForChild("FarmingHold_Start"):FireServer(id)
		task.wait(2)
	end
end)

createToggleButton("Potion Vending", 300, function(isRunning)
	while isRunning() do
		network:WaitForChild("VendingMachines_Purchase"):InvokeServer("PotionVendingMachine")
		task.wait(2)
	end
end)

createToggleButton("Roll Egg", 350, function(isRunning)
	while isRunning() do
		network:WaitForChild("Eggs_Roll"):InvokeServer()
		task.wait(2)
	end
end)

-- 🔴 Kill Script Button
local killButton = Instance.new("TextButton")
killButton.Size = UDim2.new(0, 250, 0, 40)
killButton.Position = UDim2.new(0.5, -125, 0, 400)
killButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.Font = Enum.Font.SourceSansBold
killButton.TextSize = 18
killButton.Text = "🛑 KILL SCRIPT"
killButton.Parent = screenGui

killButton.MouseButton1Click:Connect(function()
	for key in pairs(toggles) do
		toggles[key] = function() return false end
	end
	screenGui:Destroy()
end)