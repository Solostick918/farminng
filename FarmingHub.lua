-- LocalScript inside StarterGui

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local network = rs:WaitForChild("Network")

-- Define tabs
local tabs = {
    "Farming",
    "Mining",
    "Merchants",
    "Settings"
}

-- Modern GUI Styles
local COLORS = {
    PRIMARY = Color3.fromRGB(0, 170, 255),    -- Blue
    SECONDARY = Color3.fromRGB(40, 40, 40),   -- Dark Gray
    BACKGROUND = Color3.fromRGB(24, 24, 28),  -- Softer dark
    TEXT = Color3.fromRGB(240, 240, 240),     -- Light Gray
    BORDER = Color3.fromRGB(60, 60, 60),      -- Border Gray
    SUCCESS = Color3.fromRGB(0, 255, 128),    -- Green
    WARNING = Color3.fromRGB(255, 170, 0),    -- Orange
    DANGER = Color3.fromRGB(255, 50, 50),     -- Red
    TOPBAR = Color3.fromRGB(30, 40, 60)       -- Subtle blue-gray
}

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernFarmingGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 400)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = COLORS.BACKGROUND
mainFrame.BorderColor3 = COLORS.BORDER
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
mainFrame.ClipsDescendants = true
mainFrame.AnchorPoint = Vector2.new(0,0)
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Top Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = COLORS.TOPBAR
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 12)
barCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Farming Hub"
title.TextColor3 = COLORS.TEXT
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Content Frame
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -16, 1, -48)
contentFrame.Position = UDim2.new(0, 8, 0, 36)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 4
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
contentFrame.Parent = mainFrame
local contentPad = Instance.new("UIPadding")
contentPad.PaddingTop = UDim.new(0, 6)
contentPad.PaddingBottom = UDim.new(0, 6)
contentPad.PaddingLeft = UDim.new(0, 2)
contentPad.PaddingRight = UDim.new(0, 2)
contentPad.Parent = contentFrame

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
    button.Size = UDim2.new(1, 0, 0, 32)
    button.Position = UDim2.new(0, 0, 0, y)
    button.BackgroundColor3 = color or COLORS.PRIMARY
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.TEXT
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = contentFrame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = (color or COLORS.PRIMARY):Lerp(Color3.new(1, 1, 1), 0.08)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = color or COLORS.PRIMARY
    end)
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Section Header Function
local function createSectionHeader(text, y)
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 24)
    header.Position = UDim2.new(0, 0, 0, y)
    header.BackgroundTransparency = 1
    header.Text = text
    header.TextColor3 = COLORS.TEXT
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = contentFrame
    return y + 32
end

-- Toggle Button Function
local function createToggleButton(text, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 32)
    button.Position = UDim2.new(0, 0, 0, y)
    button.BackgroundColor3 = COLORS.SECONDARY
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.TEXT
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = contentFrame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = button
    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = COLORS.SECONDARY:Lerp(Color3.new(1, 1, 1), 0.08)
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

-- Checkbox Creation Function
local function createCheckbox(text, y)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 32)
    container.Position = UDim2.new(0, 0, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = contentFrame

    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0, 0, 0, 6)
    checkbox.BackgroundColor3 = COLORS.SECONDARY
    checkbox.BorderSizePixel = 0
    checkbox.Text = ""
    checkbox.Parent = container
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 4)
    checkCorner.Parent = checkbox

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.TEXT
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local isChecked = false
    checkbox.MouseButton1Click:Connect(function()
        isChecked = not isChecked
        checkbox.BackgroundColor3 = isChecked and COLORS.SUCCESS or COLORS.SECONDARY
    end)

    return container, function() return isChecked end
end

-- Radio Button Creation Function
local function createRadioButton(text, y, group)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 32)
    container.Position = UDim2.new(0, 0, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = contentFrame

    local radio = Instance.new("TextButton")
    radio.Size = UDim2.new(0, 20, 0, 20)
    radio.Position = UDim2.new(0, 0, 0, 6)
    radio.BackgroundColor3 = COLORS.SECONDARY
    radio.BorderSizePixel = 0
    radio.Text = ""
    radio.Parent = container
    local radioCorner = Instance.new("UICorner")
    radioCorner.CornerRadius = UDim.new(0, 10)
    radioCorner.Parent = radio

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.TEXT
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local isSelected = false
    radio.MouseButton1Click:Connect(function()
        if not isSelected then
            -- Deselect all other buttons in the group
            for _, btn in pairs(group) do
                if btn ~= radio then
                    btn.BackgroundColor3 = COLORS.SECONDARY
                    btn.isSelected = false
                end
            end
            isSelected = true
            radio.BackgroundColor3 = COLORS.SUCCESS
        end
    end)

    radio.isSelected = isSelected
    table.insert(group, radio)
    return container, function() return isSelected end
end

-- Show/Hide GUI Button
local showBtn = Instance.new("TextButton")
showBtn.Size = UDim2.new(0, 120, 0, 32)
showBtn.Position = UDim2.new(0.5, -60, 0, 20)
showBtn.BackgroundColor3 = COLORS.TOPBAR
showBtn.BorderSizePixel = 0
showBtn.TextColor3 = COLORS.TEXT
showBtn.Font = Enum.Font.GothamSemibold
showBtn.TextSize = 16
showBtn.Text = "Show GUI"
showBtn.Visible = false
local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 12)
showCorner.Parent = showBtn
showBtn.Parent = screenGui

local function hideGUI()
    mainFrame.Visible = false
    showBtn.Visible = true
end
local function showGUI()
    mainFrame.Visible = true
    showBtn.Visible = false
end
showBtn.MouseButton1Click:Connect(showGUI)

-- Initialize buttons
local y = 8

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
                end
            end
        end)
    end
end)
y = y + 45

-- Aura Merchant Section
y = createSectionHeader("Aura Merchant", y)
local auraMerchantButton = createToggleButton("Start Aura Merchant", y, function(isRunning)
    if isRunning then
        task.spawn(function()
            while isRunning do
                for i = 1, 10 do
                    local args = {
                        i
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AuraMerchant_Purchase"):InvokeServer(unpack(args))
                end
            end
        end)
    end
end)
y = y + 45

-- Aura Crafting Section
y = createSectionHeader("Aura Crafting", y)
local auraCraftButton = createToggleButton("Start Aura Crafting", y, function(isRunning)
    if isRunning then
        task.spawn(function()
            while isRunning do
                local args = {
                    "Aura Shard"
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AuraCrafting_Craft"):InvokeServer(unpack(args))
            end
        end)
    end
end)
y = y + 45

-- Farming Merchant Section
y = createSectionHeader("Farming Merchant", y)
local farmingMerchantButton = createToggleButton("Start Farming Merchant", y, function(isRunning)
    if isRunning then
        task.spawn(function()
            while isRunning do
                for i = 1, 6 do
                    local args = {
                        "FarmingMerchant",
                        i
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("CustomMerchants_Purchase"):InvokeServer(unpack(args))
                end
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

-- Egg Rolling Section
y = createSectionHeader("Egg Rolling", y)
local eggRollButton = createToggleButton("Start Egg Rolling", y, function(isRunning)
    if isRunning then
        task.spawn(function()
            while isRunning do
                game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Eggs_Roll"):InvokeServer()
            end
        end)
    end
end)
y = y + 45

-- Aura Scrap Machine Section
y = createSectionHeader("Aura Scrap Machine", y)
local earthCheckbox, getEarthChecked = createCheckbox("Earth", y)
y = y + 40
local windCheckbox, getWindChecked = createCheckbox("Wind", y)
y = y + 40
local newCheckbox, getNewChecked = createCheckbox("New Aura", y)
y = y + 40

local isScrapRunning = false
local scrapButton = createToggleButton("Start Aura Scrap", y, function(isRunning)
    isScrapRunning = isRunning
    if isRunning then
        task.spawn(function()
            while isScrapRunning do
                if getEarthChecked() then
                    -- Try 99 first
                    local args = {
                        {
                            ["301239fbd66a449b87fde7c06d4a5a6d"] = 99
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AuraScrapMachine_Activate"):InvokeServer(unpack(args))
                    task.wait(0.5)
                    -- Then try 3
                    local args = {
                        {
                            ["301239fbd66a449b87fde7c06d4a5a6d"] = 3
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AuraScrapMachine_Activate"):InvokeServer(unpack(args))
                end
                if getWindChecked() then
                    -- Try 99 first
                    local args = {
                        {
                            ["65f467a05622437595ae2f6320b5d77b"] = 99
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AuraScrapMachine_Activate"):InvokeServer(unpack(args))
                    task.wait(0.5)
                    -- Then try 3
                    local args = {
                        {
                            ["65f467a05622437595ae2f6320b5d77b"] = 3
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AuraScrapMachine_Activate"):InvokeServer(unpack(args))
                end
                if getNewChecked() then
                    local args = {
                        {
                            ["bda3ac6b817b4abd9c97c729f6791b9b"] = 40
                        }
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("AuraScrapMachine_Activate"):InvokeServer(unpack(args))
                end
                task.wait(1)
            end
        end)
    end
end)
y = y + 45

-- Settings Section
y = createSectionHeader("Settings", y)
local hideButton = createButton("Hide GUI", y, COLORS.WARNING, function()
    hideGUI()
end)
y = y + 45

local killButton = createButton("Kill Script", y, COLORS.DANGER, function()
    screenGui:Destroy()
end)
y = y + 45

-- Update canvas size
contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 8) 
