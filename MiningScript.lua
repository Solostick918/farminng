-- LocalScript inside StarterGui

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local remoteEvent = rs:WaitForChild("RemoteEvent")

-- Debug print to verify RemoteEvent connection
print("RemoteEvent found:", remoteEvent.Name)

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

-- Mining block IDs
local MINING_BLOCKS = {
    "p1143", "p721", "p727", "p734", "p741", "p748", "p755", "p1146", 
    "p1145", "p1170", "p1167", "p708", "p728", "p700", "p701", "p699", 
    "p714", "p715"
}

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MiningGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 200)
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
title.Text = "Mining Hub"
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
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
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

-- Initialize buttons
local y = 8

-- Auto Mining Section
local autoMineButton = createToggleButton("Start Auto Mining", y, function(isRunning)
    if isRunning then
        print("Auto mining started")
        task.spawn(function()
            while isRunning do
                for _, blockId in ipairs(MINING_BLOCKS) do
                    if not isRunning then break end
                    local args = {
                        {
                            id = "d",
                            brickId = blockId
                        }
                    }
                    print("Attempting to mine block:", blockId)
                    remoteEvent:FireServer(unpack(args))
                    task.wait(0.3) -- Delay between mining attempts
                end
                task.wait(0.5) -- Delay before starting the next cycle
            end
        end)
    else
        print("Auto mining stopped")
    end
end)
y = y + 45

-- Settings Section
local hideButton = createToggleButton("Hide GUI", y, function(isRunning)
    mainFrame.Visible = not isRunning
end)
y = y + 45

-- Update canvas size
contentFrame.CanvasSize = UDim2.new(0, 0, 0, y + 8) 
