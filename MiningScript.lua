-- LocalScript inside StarterGui

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local dropsEvent = rs:WaitForChild("Events"):WaitForChild("Drops"):WaitForChild("Collect")

-- Drop IDs to collect
local DROP_IDS = {
    15462268,
    15464032,
    54  -- DataCost item
}

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OreScannerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

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
title.Text = "Ore Scanner"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = titleBar

-- Scan Button
local scanButton = Instance.new("TextButton")
scanButton.Size = UDim2.new(0, 120, 0, 36)
scanButton.Position = UDim2.new(0.5, -60, 0, 50)
scanButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
scanButton.BorderSizePixel = 0
scanButton.Text = "Scan Ores"
scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
scanButton.Font = Enum.Font.GothamSemibold
scanButton.TextSize = 14
scanButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = scanButton

-- Results Frame
local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Size = UDim2.new(1, -20, 0, 380)
resultsFrame.Position = UDim2.new(0, 10, 0, 100)
resultsFrame.BackgroundTransparency = 1
resultsFrame.BorderSizePixel = 0
resultsFrame.ScrollBarThickness = 4
resultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsFrame.Parent = mainFrame

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

-- Function to create result entry
local function createResultEntry(text, y)
    local entry = Instance.new("TextLabel")
    entry.Size = UDim2.new(1, 0, 0, 30)
    entry.Position = UDim2.new(0, 0, 0, y)
    entry.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    entry.BorderSizePixel = 0
    entry.Text = text
    entry.TextColor3 = Color3.fromRGB(255, 255, 255)
    entry.Font = Enum.Font.Gotham
    entry.TextSize = 14
    entry.TextXAlignment = Enum.TextXAlignment.Left
    entry.Parent = resultsFrame
    
    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 4)
    entryCorner.Parent = entry
    
    return entry
end

-- Scan function
local function scanOres()
    -- Clear previous results
    for _, child in pairs(resultsFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local y = 0
    local spacing = 35
    
    -- Scan for block regions
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():match("block") and obj:IsA("Model") then
            createResultEntry("Found Block Region: " .. obj.Name, y)
            y = y + spacing
            
            -- Scan children of block region
            for _, child in pairs(obj:GetDescendants()) do
                if child:IsA("BasePart") then
                    local info = string.format("  - Part: %s (BrickId: %s, Material: %s)", 
                        child.Name, 
                        child.BrickId, 
                        child.Material.Name)
                    createResultEntry(info, y)
                    y = y + spacing
                end
            end
        end
    end
    
    -- Update canvas size
    resultsFrame.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- Connect scan button
scanButton.MouseButton1Click:Connect(scanOres)

-- Hover effects
scanButton.MouseEnter:Connect(function()
    scanButton.BackgroundColor3 = Color3.fromRGB(0, 150, 235)
end)

scanButton.MouseLeave:Connect(function()
    scanButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
end)

-- Auto Collect Function
task.spawn(function()
    while true do
        for _, dropId in ipairs(DROP_IDS) do
            local args = {
                {
                    dropId
                }
            }
            dropsEvent:FireServer(unpack(args))
        end
        task.wait(0.1) -- Small delay between collection attempts
    end
end)

-- Function to print object information
local function printObjectInfo(obj)
    print("Found object:", obj.Name)
    print("  Class:", obj.ClassName)
    print("  Position:", obj.Position)
    if obj:IsA("BasePart") then
        print("  BrickId:", obj.BrickId)
        print("  Material:", obj.Material.Name)
    end
    print("  Properties:")
    for _, prop in pairs(obj:GetProperties()) do
        local success, value = pcall(function() return obj[prop] end)
        if success then
            print("    " .. prop .. ":", value)
        end
    end
    print("-------------------")
end

-- Scan workspace for potential ores
print("Scanning workspace for ores...")
print("-------------------")

-- Check for an Ores folder
local oresFolder = workspace:FindFirstChild("Ores")
if oresFolder then
    print("Found Ores folder!")
    for _, obj in pairs(oresFolder:GetDescendants()) do
        printObjectInfo(obj)
    end
else
    print("No Ores folder found, scanning all parts...")
    -- Scan all parts in workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            -- Check if it might be an ore based on name or properties
            if obj.Name:lower():match("ore") or 
               obj.Name:lower():match("dirt") or 
               obj.Name:lower():match("stone") or
               obj.Material.Name:lower():match("stone") or
               obj.Material.Name:lower():match("dirt") then
                printObjectInfo(obj)
            end
        end
    end
end

-- Also check ReplicatedStorage for any ore-related configurations
print("\nChecking ReplicatedStorage for ore configurations...")
print("-------------------")
for _, obj in pairs(rs:GetDescendants()) do
    if obj:IsA("ModuleScript") or obj:IsA("StringValue") then
        if obj.Name:lower():match("ore") or 
           obj.Name:lower():match("mining") or 
           obj.Name:lower():match("dirt") then
            print("Found potential ore configuration:", obj.Name)
            print("  Path:", obj:GetFullName())
            print("-------------------")
        end
    end
end

print("\nScan complete! Check the output window for results.") 
