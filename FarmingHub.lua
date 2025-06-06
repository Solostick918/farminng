-- LocalScript inside StarterGui

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local network = rs:WaitForChild("Network")

-- Modern GUI Styles
local COLORS = {
    PRIMARY = Color3.fromRGB(0, 170, 255),    -- Blue
    SECONDARY = Color3.fromRGB(40, 40, 40),   -- Dark Gray
    BACKGROUND = Color3.fromRGB(30, 30, 30),  -- Darker Gray
    TEXT = Color3.fromRGB(255, 255, 255),     -- White
    BORDER = Color3.fromRGB(60, 60, 60),      -- Border Gray
    SUCCESS = Color3.fromRGB(0, 255, 128),    -- Green
    WARNING = Color3.fromRGB(255, 170, 0),    -- Orange
    DANGER = Color3.fromRGB(255, 50, 50)      -- Red
}

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernFarmingGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = COLORS.BACKGROUND
mainFrame.BorderColor3 = COLORS.BORDER
mainFrame.BorderSizePixel = 1
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = COLORS.SECONDARY
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Modern Farming Hub"
title.TextColor3 = COLORS.TEXT
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = titleBar

-- Content Frame
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 6
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
contentFrame.Parent = mainFrame

-- Make GUI Draggable
local dragging, dragInput, dragStart, startPos
local UIS = game:GetService("UserInputService")

titleBar.InputBegan:Connect(function(input)
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

titleBar.InputChanged:Connect(function(input)
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

-- Button Creation Function
local function createButton(text, y, color, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, y)
    button.BackgroundColor3 = color or COLORS.PRIMARY
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.TEXT
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = contentFrame
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.1)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = color
    end)
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Section Header Function
local function createSectionHeader(text, y)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -20, 0, 30)
    header.Position = UDim2.new(0, 10, 0, y)
    header.BackgroundTransparency = 1
    header.Text = text
    header.TextColor3 = COLORS.TEXT
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = contentFrame
    return y + 35
end

-- Toggle Button Function
local function createToggleButton(text, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, y)
    button.BackgroundColor3 = COLORS.SECONDARY
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.TEXT
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = contentFrame
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = COLORS.SECONDARY:Lerp(Color3.new(1, 1, 1), 0.1)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = COLORS.SECONDARY
    end)
    
    local isRunning = false
    button.MouseButton1Click:Connect(function()
        isRunning = not isRunning
        button.Text = isRunning and text:gsub("Start", "Stop") or text
        button.BackgroundColor3 = isRunning and COLORS.SUCCESS or COLORS.SECONDARY
        callback(isRunning)
    end)
    
    return button
end

-- Initialize buttons
local y = 10

-- Aura Egg Merchant Section
y = createSectionHeader("Aura Egg Merchant", y)
local auraEggButton = createToggleButton("Start Aura Egg Merchant", y, function(isRunning)
    if isRunning then
        task.spawn(function()
            while isRunning do
                for i = 1, 6 do
                    local args = {
                        "AuraEggMerchant",
                        i
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("CustomMerchants_Purchase"):InvokeServer(unpack(args))
                    task.wait(0.5)
                end
                task.wait(2)
            end
        end)
    end
end)
y = y + 45

-- Farming Section
y = createSectionHeader("Farming", y)
local autoFarmButton = createToggleButton("Start Auto Farm", y, function(isRunning)
    if isRunning then
        task.spawn(function()
            while isRunning do
                game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Farming_AutoFarm"):FireServer()
                task.wait(2)
            end
        end)
    end
end)
y = y + 45

local autoPlantButton = createToggleButton("Start Auto Plant", y, function(isRunning)
    if isRunning then
        task.spawn(function()
            while isRunning do
                local args = {"7bd389d1c6c941dfa53e26e2c3e0910f"}
                game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("FarmingHold_Start"):FireServer(unpack(args))
                task.wait(2)
            end
        end)
    end
end)
y = y + 45

-- Settings Section
y = createSectionHeader("Settings", y)
local hideButton = createButton("Hide GUI", y, COLORS.WARNING, function()
    mainFrame.Visible = false
    local showButton = createButton("Show GUI", 0, COLORS.PRIMARY, function()
        mainFrame.Visible = true
        showButton:Destroy()
    end)
    showButton.Position = UDim2.new(0, 20, 0, 20)
    showButton.Parent = screenGui
end)
y = y + 45

local killButton = createButton("Kill Script", y, COLORS.DANGER, function()
    screenGui:Destroy()
end)
y = y + 45

-- Update canvas size
contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 10) 
