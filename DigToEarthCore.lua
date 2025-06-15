-- Dig to Earth's Core Script

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")

-- Global running flag
_G.DigToEarthCoreRunning = true

-- Safe WaitForChild function with timeout and warning
local function safeWaitForChild(parent, childName, timeout)
    local obj = parent:WaitForChild(childName, timeout or 10)
    if not obj then
        warn(childName .. " not found in " .. parent:GetFullName() .. " after " .. (timeout or 10) .. " seconds!")
    end
    return obj
end

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DigToEarthCoreGUI"
gui.Parent = game.CoreGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.BorderSizePixel = 0
title.Text = "Dig to Earth's Core"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

-- Make GUI Draggable
local dragging, dragInput, dragStart, startPos
local UIS = game:GetService("UserInputService")

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Button Creation Function
local function createButton(text, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 30)
    button.Position = UDim2.new(0.05, 0, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = frame
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Create Buttons
local y = 40

-- Gem Farm
createButton("Start Gem Farm", y, function()
    task.spawn(function()
        local remotes = safeWaitForChild(rs, "Remotes", 10)
        if not remotes then return end
        local event = safeWaitForChild(remotes, "GemEvent", 10)
        if not event then return end
        while _G.DigToEarthCoreRunning do
            local args = {
                11,
                "bye"
            }
            event:FireServer(unpack(args))
            task.wait(1)
        end
    end)
end)
y = y + 40

-- Treasure Farm
createButton("Start Treasure Farm", y, function()
    task.spawn(function()
        local remotes = safeWaitForChild(rs, "Remotes", 10)
        if not remotes then return end
        local event = safeWaitForChild(remotes, "TreasureEvent", 10)
        if not event then return end
        while _G.DigToEarthCoreRunning do
            local treasures = {
                "Chest2", "Fossil", "Cup2", "Cauldron", "Coffin", "Vault", "Vase", "Barrel", "TallVault"
            }
            for _, name in ipairs(treasures) do
                if not _G.DigToEarthCoreRunning then break end
                local args = {name}
                event:FireServer(unpack(args))
                task.wait(0.2)
            end
        end
    end)
end)
y = y + 40

-- Kill Script
createButton("Kill Script", y, function()
    _G.DigToEarthCoreRunning = false
    gui:Destroy()
end) 
