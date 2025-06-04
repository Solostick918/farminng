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
mainFrame.Size = UDim2.new(0, 270, 0, 380)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 18
minimizeButton.Text = "-"
minimizeButton.Parent = mainFrame

local contentVisible = true
minimizeButton.MouseButton1Click:Connect(function()
	contentVisible = not contentVisible
	for _, child in ipairs(mainFrame:GetChildren()) do
		if child ~= minimizeButton then
			child.Visible = contentVisible
		end
	end
	minimizeButton.Text = contentVisible and "-" or "+"
end)

-- Store toggle states
local toggles = {}

-- Toggle Button Builder
local function createToggleButton(name, posY, loopFunc)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 210, 0, 32)
	button.Position = UDim2.new(0, 20, 0, posY)
	button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 16
	button.Text = "Start " .. name
	button.Parent = mainFrame

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
local y = 45
local spacing = 37
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

y = y + spacing + 10
-- 🔴 Kill Script Button
local killButton = Instance.new("TextButton")
killButton.Size = UDim2.new(0, 210, 0, 32)
killButton.Position = UDim2.new(0, 20, 0, y)
killButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.Font = Enum.Font.SourceSansBold
killButton.TextSize = 16
killButton.Text = "🛑 KILL SCRIPT"
killButton.Parent = mainFrame

killButton.MouseButton1Click:Connect(function()
	for key in pairs(toggles) do
		toggles[key] = function() return false end
	end
	screenGui:Destroy()
end)
