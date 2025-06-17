-- LocalScript inside StarterGui

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local weaponHitRE = rs:WaitForChild("RemoteEvents"):WaitForChild("WeaponHitRE")
local hitTreesRE = rs:WaitForChild("RemoteEvents"):WaitForChild("HitTreesRE")
local nextDungeonRE = rs:WaitForChild("RemoteEvents"):WaitForChild("NextDungeonRE")
local onlineRewardRF = rs:WaitForChild("RemoteFunctions"):WaitForChild("OnlineRewardRF")

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ChopChopConquerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Chop Chop Conquer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = titleBar

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

-- Function to create toggle button
local function createToggleButton(text, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 40)
    button.Position = UDim2.new(0.05, 0, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    local isRunning = false
    
    button.MouseButton1Click:Connect(function()
        isRunning = not isRunning
        button.Text = isRunning and text:gsub("Start", "Stop") or text
        button.BackgroundColor3 = isRunning and Color3.fromRGB(0, 255, 128) or Color3.fromRGB(40, 40, 40)
        callback(isRunning)
    end)
    
    return button, isRunning
end

-- Auto Battle Variables
local isAutoBattleRunning = false
local autoBattleThread = nil

-- Try finding the Npc folder safely
local function findNpcFolder()
    local success, npcFolder = pcall(function()
        local dungeonsWorld = workspace:WaitForChild("DungeonsWorld", 5)
        for _, level1 in ipairs(dungeonsWorld:GetChildren()) do
            for _, level2 in ipairs(level1:GetChildren()) do
                if level2:FindFirstChild("Npc") then
                    return level2.Npc
                end
            end
        end
    end)
    return success and npcFolder or nil
end

-- Auto Battle Function
local function startAutoBattle()
    if autoBattleThread then
        task.cancel(autoBattleThread)
    end
    
    autoBattleThread = task.spawn(function()
        while isAutoBattleRunning do
            local npcFolder = findNpcFolder()
            if npcFolder then
                local monsters = npcFolder:GetChildren()
                if #monsters > 0 then
                    for _, monster in ipairs(monsters) do
                        if not isAutoBattleRunning then break end
                        if monster:IsA("Model") then
                            local args = {monster}
                            local attackData = {
                                ownerType = "Character",
                                currentAttacks = { Common = true }
                            }
                            weaponHitRE:FireServer(args, attackData)
                            task.wait(0.2)
                        end
                    end
                else
                    task.wait(2)
                end
            else
                task.wait(3)
            end
        end
    end)
end

-- Auto Chop Variables
local isAutoChopRunning = false
local autoChopThread = nil

-- Auto Chop Function
local function startAutoChop()
    if autoChopThread then
        task.cancel(autoChopThread)
    end
    
    autoChopThread = task.spawn(function()
        while isAutoChopRunning do
            local args = {
                {
                    HitPos = Vector3.new(2976.930419921875, 623.164794921875, -349.7132568359375),
                    TreeInstance = workspace:WaitForChild("Trees"):WaitForChild("tree3"),
                    IsExplodeDiamond = false,
                    AutoCut = true,
                    AutoCutEquip = true,
                    isExplodeEquip = false
                }
            }
            hitTreesRE:FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end

-- Create Toggle Buttons (moved after kill button)
local autoBattleButton = createToggleButton("Start Auto Battle", 100, function(isRunning)
    isAutoBattleRunning = isRunning
    if isRunning then
        startAutoBattle()
    end
end)

local autoChopButton = createToggleButton("Start Auto Chop", 150, function(isRunning)
    isAutoChopRunning = isRunning
    if isRunning then
        startAutoChop()
    end
end)

-- DEBUG KILL BUTTON (always visible, top right of screen)
local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.new(0, 120, 0, 50)
killBtn.Position = UDim2.new(1, -130, 0, 10)
killBtn.AnchorPoint = Vector2.new(0, 0)
killBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killBtn.Text = "KILL SCRIPT"
killBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
killBtn.Font = Enum.Font.GothamBold
killBtn.TextSize = 20
killBtn.ZIndex = 1000
killBtn.Parent = game.Players.LocalPlayer.PlayerGui

killBtn.MouseButton1Click:Connect(function()
    -- Stop all running threads and set flags to false
    if autoBattleThread then
        task.cancel(autoBattleThread)
        autoBattleThread = nil
    end
    if autoChopThread then
        task.cancel(autoChopThread)
        autoChopThread = nil
    end
    isAutoBattleRunning = false
    isAutoChopRunning = false
    -- Remove GUI and kill button
    if screenGui then screenGui:Destroy() end
    killBtn:Destroy()
end)

print("Kill button created!") 
