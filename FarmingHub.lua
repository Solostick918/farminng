-- LocalScript inside StarterGui

local player = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local network = rs:WaitForChild("Network")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmingHubGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Flat, Neon Green Bordered GUI Styles
local BORDER_COLOR = Color3.fromRGB(0,255,128)
local BG_COLOR = Color3.fromRGB(20,20,20)
local TAB_BG = Color3.fromRGB(30,30,30)
local TAB_ACTIVE_BG = Color3.fromRGB(40,40,40)
local TAB_TEXT = Color3.fromRGB(220,220,220)
local SECTION_HEADER_BG = Color3.fromRGB(25,25,25)
local SECTION_HEADER_TEXT = Color3.fromRGB(0,255,128)
local BUTTON_BG = Color3.fromRGB(30,30,30)
local BUTTON_BORDER = Color3.fromRGB(0,255,128)
local BUTTON_TEXT = Color3.fromRGB(220,220,220)
local BUTTON_HOVER_BG = Color3.fromRGB(40,40,40)
local CHECKBOX_BG = Color3.fromRGB(30,30,30)
local CHECKBOX_BORDER = Color3.fromRGB(0,255,128)
local CHECKBOX_CHECKED = Color3.fromRGB(0,255,128)
local CHECKBOX_UNCHECKED = Color3.fromRGB(40,40,40)
local FONT = Enum.Font.SourceSans

-- Update color scheme for readability
local ACTIVE_BUTTON_COLOR = Color3.fromRGB(0, 170, 255)
local ACTIVE_BUTTON_TEXT = Color3.fromRGB(255,255,255)

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 320)
mainFrame.Position = UDim2.new(0, 200, 0, 120)
mainFrame.BackgroundColor3 = BG_COLOR
mainFrame.BorderColor3 = BORDER_COLOR
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Top Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 36)
tabBar.Position = UDim2.new(0, 0, 0, 0)
tabBar.BackgroundColor3 = BG_COLOR
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

-- Add Settings tab
local tabs = {"Farming", "Mining", "Merchants", "Settings"}

-- Draggable top bar
local dragging, dragInput, dragStart, startPos
local UIS = game:GetService("UserInputService")
tabBar.Active = true
tabBar.Draggable = false
tabBar.InputBegan:Connect(function(input)
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
tabBar.InputChanged:Connect(function(input)
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

-- Resizer (bottom right)
local resizer = Instance.new("Frame")
resizer.Size = UDim2.new(0, 16, 0, 16)
resizer.Position = UDim2.new(1, -16, 1, -16)
resizer.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
resizer.BorderSizePixel = 0
resizer.Parent = mainFrame
resizer.Active = true
local resizing = false
local resizeStart, frameStart
resizer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true
		resizeStart = input.Position
		frameStart = mainFrame.Size
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				resizing = false
			end
		end)
	end
end)
resizer.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		UIS.InputChanged:Connect(function(moveInput)
			if resizing and moveInput == input then
				local delta = moveInput.Position - resizeStart
				mainFrame.Size = UDim2.new(0, math.max(220, frameStart.X.Offset + delta.X), 0, math.max(220, frameStart.Y.Offset + delta.Y))
			end
		end)
	end
end)

-- Hide/Show GUI logic
local showBtn = Instance.new("TextButton")
showBtn.Size = UDim2.new(0, 60, 0, 28)
showBtn.Position = UDim2.new(0, 0, 0.5, -14)
showBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
showBtn.BorderColor3 = BORDER_COLOR
showBtn.BorderSizePixel = 1
showBtn.TextColor3 = BUTTON_TEXT
showBtn.Font = FONT
showBtn.TextSize = 13
showBtn.Text = "Show GUI"
showBtn.Visible = false
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

-- Tab switching function
local tabFrames = {}
local selectedTab = "Farming"
local tabBtnX = 4
local tabBtnW = 72
for i, tabName in ipairs(tabs) do
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, tabBtnW, 0, 24)
	tabBtn.Position = UDim2.new(0, tabBtnX, 0, 4)
	tabBtn.BackgroundColor3 = (tabName == selectedTab) and TAB_ACTIVE_BG or TAB_BG
	tabBtn.BorderColor3 = BORDER_COLOR
	tabBtn.BorderSizePixel = 1
	tabBtn.TextColor3 = TAB_TEXT
	tabBtn.Font = FONT
	tabBtn.TextSize = 16
	tabBtn.Text = tabName
	tabBtn.Parent = tabBar
	tabBtn.MouseButton1Click:Connect(function()
		selectedTab = tabName
		for name, frame in pairs(tabFrames) do
			frame.Visible = (name == tabName)
		end
		for _, btn in ipairs(tabBar:GetChildren()) do
			if btn:IsA("TextButton") then
				btn.BackgroundColor3 = (btn.Text == selectedTab) and TAB_ACTIVE_BG or TAB_BG
			end
		end
	end)
	tabBtnX = tabBtnX + tabBtnW + 2
end

-- Section Header Helper
local function createSectionHeader(parent, text, y)
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -12, 0, 18)
	header.Position = UDim2.new(0, 6, 0, y)
	header.BackgroundColor3 = SECTION_HEADER_BG
	header.BorderColor3 = BORDER_COLOR
	header.BorderSizePixel = 1
	header.TextColor3 = SECTION_HEADER_TEXT
	header.Font = FONT
	header.TextSize = 13
	header.Text = text
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = parent
	return y + 20
end

-- Flat Button Helper (smaller)
local function createFlatButton(parent, text, y, color, borderColor, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -12, 0, 18)
	btn.Position = UDim2.new(0, 6, 0, y)
	btn.BackgroundColor3 = color or BUTTON_BG
	btn.BorderColor3 = borderColor or BUTTON_BORDER
	btn.BorderSizePixel = 1
	btn.TextColor3 = BUTTON_TEXT
	btn.Font = FONT
	btn.TextSize = 12
	btn.Text = text
	btn.Parent = parent
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = BUTTON_HOVER_BG
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = color or BUTTON_BG
	end)
	btn.MouseButton1Click:Connect(callback)
	return btn, y + 20
end

-- Flat Checkbox Helper (smaller)
local function createFlatCheckbox(parent, text, y, checkedCallback)
	local cbFrame = Instance.new("Frame")
	cbFrame.Size = UDim2.new(1, -20, 0, 22)
	cbFrame.Position = UDim2.new(0, 10, 0, y)
	cbFrame.BackgroundTransparency = 1
	cbFrame.Parent = parent
	local cb = Instance.new("TextButton")
	cb.Size = UDim2.new(0, 16, 0, 16)
	cb.Position = UDim2.new(0, 0, 0, 3)
	cb.BackgroundColor3 = CHECKBOX_UNCHECKED
	cb.BorderColor3 = CHECKBOX_BORDER
	cb.BorderSizePixel = 1
	cb.TextColor3 = CHECKBOX_CHECKED
	cb.Font = FONT
	cb.TextSize = 13
	cb.Text = ""
	cb.Parent = cbFrame
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 20, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = BUTTON_TEXT
	label.Font = FONT
	label.TextSize = 13
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = cbFrame
	local checked = false
	cb.MouseButton1Click:Connect(function()
		checked = not checked
		cb.Text = checked and "■" or ""
		cb.BackgroundColor3 = checked and CHECKBOX_CHECKED or CHECKBOX_UNCHECKED
		checkedCallback(checked)
	end)
	cb.MouseEnter:Connect(function()
		cb.BackgroundColor3 = checked and CHECKBOX_CHECKED or BUTTON_HOVER_BG
	end)
	cb.MouseLeave:Connect(function()
		cb.BackgroundColor3 = checked and CHECKBOX_CHECKED or CHECKBOX_UNCHECKED
	end)
	return cb, y + 22, function() return checked end, function(val)
		checked = val
		cb.Text = checked and "■" or ""
		cb.BackgroundColor3 = checked and CHECKBOX_CHECKED or CHECKBOX_UNCHECKED
	end
end

-- Scrollable Content Helper
local function createScrollableFrame(parent)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -40)
	scroll.Position = UDim2.new(0, 0, 0, 40)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.CanvasSize = UDim2.new(0, 0, 0, 800)
	scroll.ScrollBarThickness = 6
	scroll.Parent = parent
	return scroll
end

-- Tab switching function
local function switchTab(tabName)
	for name, frame in pairs(tabFrames) do
		frame.Visible = (name == tabName)
	end
	for _, btn in ipairs(tabBar:GetChildren()) do
		if btn:IsA("TextButton") then
			btn.BackgroundColor3 = (btn.Text == tabName) and TAB_ACTIVE_BG or TAB_BG
		end
	end
end

-- Helper for toggle buttons
local running = {}

-- Update makeToggleButton to use readable blue for active
function makeToggleButton(parent, label, y, loopFunc)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 24)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = BUTTON_BG
	btn.BorderColor3 = BUTTON_BORDER
	btn.BorderSizePixel = 1
	btn.TextColor3 = BUTTON_TEXT
	btn.Font = FONT
	btn.TextSize = 13
	btn.Text = "Start " .. label
	btn.Parent = parent
	running[label] = false
	btn.MouseButton1Click:Connect(function()
		running[label] = not running[label]
		btn.Text = (running[label] and "Stop " or "Start ") .. label
		btn.BackgroundColor3 = running[label] and ACTIVE_BUTTON_COLOR or BUTTON_BG
		btn.TextColor3 = running[label] and ACTIVE_BUTTON_TEXT or BUTTON_TEXT
		if running[label] then
			task.spawn(function()
				while running[label] do
					loopFunc()
				end
			end)
		end
	end)
	return btn, y + 28
end

-- Farming Tab (no merchants, no remote spy)
local farmingFrame = Instance.new("Frame")
farmingFrame.Size = UDim2.new(1, 0, 1, -40)
farmingFrame.Position = UDim2.new(0, 0, 0, 40)
farmingFrame.BackgroundTransparency = 1
farmingFrame.Parent = mainFrame
tabFrames["Farming"] = farmingFrame
local farmingScroll = createScrollableFrame(farmingFrame)
local y = 0
y = createSectionHeader(farmingScroll, "Auto Actions", y)

local autoFarmBtn, y2 = makeToggleButton(farmingScroll, "Auto Farm", y, function()
	network:WaitForChild("Farming_AutoFarm"):FireServer()
	task.wait(2)
end)
y = y2
local autoPlantBtn, y2 = makeToggleButton(farmingScroll, "Auto Plant Seeds", y, function()
	local args = {"7bd389d1c6c941dfa53e26e2c3e0910f"}
	network:WaitForChild("FarmingHold_Start"):FireServer(unpack(args))
	task.wait(2)
end)
y = y2
local rollEggBtn, y2 = makeToggleButton(farmingScroll, "Roll Egg", y, function()
	network:WaitForChild("Eggs_Roll"):InvokeServer()
	task.wait(2)
end)
y = y2
local lootChestBtn, y2 = makeToggleButton(farmingScroll, "Loot Chest Unlock (5)", y, function()
	local args = {5, false}
	network:WaitForChild("LootChest_Unlock"):InvokeServer(unpack(args))
	task.wait(2)
end)
y = y2

-- Settings Tab
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(1, 0, 1, -40)
settingsFrame.Position = UDim2.new(0, 0, 0, 40)
settingsFrame.BackgroundTransparency = 1
settingsFrame.Parent = mainFrame
tabFrames["Settings"] = settingsFrame
local settingsScroll = createScrollableFrame(settingsFrame)
local yS = 0
yS = createSectionHeader(settingsScroll, "Settings", yS)
local hideBtn, yS2 = createFlatButton(settingsScroll, "Hide UI", yS, BUTTON_BG, BUTTON_BORDER, hideGUI)
yS = yS2
local killBtn, yS2 = createFlatButton(settingsScroll, "🛑 KILL SCRIPT", yS, BUTTON_BG, BUTTON_BORDER, function()
	for k in pairs(running) do running[k] = false end
	screenGui:Destroy()
end)
yS = yS2
local function reloadScript()
	for k in pairs(running) do running[k] = false end
	screenGui:Destroy()
	local url = "https://raw.githubusercontent.com/Solostick918/farminng/refs/heads/Solostick918-patch-1/FarmingHub.lua"
	local success, result = pcall(function()
		loadstring(game:HttpGet(url))()
	end)
	if not success then
		warn("Failed to reload script:", result)
	end
end
local reloadBtn, yS3 = createFlatButton(settingsScroll, "🔄 Reload Script", yS, BUTTON_BG, BUTTON_BORDER, reloadScript)
yS = yS3

-- Game Optimizations Section
local yOpt = createSectionHeader(settingsScroll, "Game Optimizations", yS)

-- Enable All Optimizations Button
local function enableAllOptimizations()
	if not particlesDisabled then setParticlesDisabled(true) particleBtn.Text = "Enable Particle Effects" end
	if not effectsDisabled then setEffectsDisabled(true) effectsBtn.Text = "Enable Post-Processing Effects" end
	if not animsDisabled then setAnimsDisabled(true) animBtn.Text = "Enable Local Animations" end
	if not petsHidden then setPetsHidden(true) petsBtn.Text = "Show Other Players' Pets" end
	if not accessoriesHidden then setAccessoriesHidden(true) accBtn.Text = "Show Accessories" end
	if not decorHidden then setDecorHidden(true) decorBtn.Text = "Show Decorative Objects" end
	if not soundsMuted then setSoundsMuted(true) soundBtn.Text = "Unmute Sounds" end
	if not uiAnimDisabled then setUIAnimDisabled(true) uiAnimBtn.Text = "Enable UI Animations" end
	if not renderLow then setRenderLow(true) renderBtn.Text = "Restore Render Distance" end
	if not decalsDisabled then setDecalsDisabled(true) decalBtn.Text = "Enable Decals" end
	if not lightingLow then setLightingLow(true) lightingBtn.Text = "Restore Lighting Quality" end
	if not unusedGuiRemoved then setUnusedGuiRemoved(true) unusedGuiBtn.Text = "Restore Unused GUI" end
	if not unusedScriptsRemoved then setUnusedScriptsRemoved(true) unusedScriptsBtn.Text = "Restore Unused Scripts" end
	if not unusedModelsRemoved then setUnusedModelsRemoved(true) unusedModelsBtn.Text = "Restore Unused Models" end
	if not unusedGuisRemoved then setUnusedGuisRemoved(true) unusedGuisBtn.Text = "Restore Unused Guis" end
end
local allBtn, yOptAll = createFlatButton(settingsScroll, "Enable All Optimizations", yOpt, BUTTON_BG, BUTTON_BORDER, enableAllOptimizations)

-- 1. Disable Particle Effects
local particlesDisabled = false
local function setParticlesDisabled(val)
	particlesDisabled = val
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
			obj.Enabled = not val
		end
	end
end
local particleBtn, yOpt2 = createFlatButton(settingsScroll, "Disable Particle Effects", yOpt, BUTTON_BG, BUTTON_BORDER, function()
	setParticlesDisabled(not particlesDisabled)
	particleBtn.Text = (particlesDisabled and "Enable Particle Effects") or "Disable Particle Effects"
end)

-- 2. Remove Post-Processing Effects
local effectsDisabled = false
local postEffects = {"BlurEffect", "BloomEffect", "SunRaysEffect", "ColorCorrectionEffect", "DepthOfFieldEffect"}
local function setEffectsDisabled(val)
	effectsDisabled = val
	for _, effectName in ipairs(postEffects) do
		local effect = game.Lighting:FindFirstChild(effectName)
		if effect then
			effect.Enabled = not val
		end
	end
end
local effectsBtn, yOpt3 = createFlatButton(settingsScroll, "Disable Post-Processing Effects", yOpt2, BUTTON_BG, BUTTON_BORDER, function()
	setEffectsDisabled(not effectsDisabled)
	effectsBtn.Text = (effectsDisabled and "Enable Post-Processing Effects") or "Disable Post-Processing Effects"
end)

-- 3. Speed Up/Stop Local Animations
local animsDisabled = false
local function setAnimsDisabled(val)
	animsDisabled = val
	local char = player.Character or player.CharacterAdded:Wait()
	for _, track in ipairs(char:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
		if val then
			track:AdjustSpeed(100)
		else
			track:AdjustSpeed(1)
		end
	end
end
local animBtn, yOpt4 = createFlatButton(settingsScroll, "Speed Up/Stop Local Animations", yOpt3, BUTTON_BG, BUTTON_BORDER, function()
	setAnimsDisabled(not animsDisabled)
	animBtn.Text = (animsDisabled and "Enable Local Animations") or "Speed Up/Stop Local Animations"
end)

-- 4. Hide Other Players' Pets
local petsHidden = false
local function setPetsHidden(val)
	petsHidden = val
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.Name == "Pet" and obj:FindFirstChild("Owner") and obj.Owner.Value ~= player.Name then
			obj.Parent = val and nil or workspace
		end
	end
end
local petsBtn, yOpt5 = createFlatButton(settingsScroll, "Hide Other Players' Pets", yOpt4, BUTTON_BG, BUTTON_BORDER, function()
	setPetsHidden(not petsHidden)
	petsBtn.Text = (petsHidden and "Show Other Players' Pets") or "Hide Other Players' Pets"
end)

-- 5. Hide Accessories
local accessoriesHidden = false
local function setAccessoriesHidden(val)
	accessoriesHidden = val
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Accessory") then
			obj.Handle.Transparency = val and 1 or 0
		end
	end
end
local accBtn, yOpt6 = createFlatButton(settingsScroll, "Hide Accessories", yOpt5, BUTTON_BG, BUTTON_BORDER, function()
	setAccessoriesHidden(not accessoriesHidden)
	accBtn.Text = (accessoriesHidden and "Show Accessories") or "Hide Accessories"
end)

-- 6. Hide Decorative Map Objects
local decorHidden = false
local function setDecorHidden(val)
	decorHidden = val
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name:lower():find("tree") or obj.Name:lower():find("rock") or obj.Name:lower():find("bush") then
			obj.Transparency = val and 1 or 0
			obj.CanCollide = not val
		end
	end
end
local decorBtn, yOpt7 = createFlatButton(settingsScroll, "Hide Decorative Map Objects", yOpt6, BUTTON_BG, BUTTON_BORDER, function()
	setDecorHidden(not decorHidden)
	decorBtn.Text = (decorHidden and "Show Decorative Objects") or "Hide Decorative Map Objects"
end)

-- 7. Mute Non-Essential Sounds
local soundsMuted = false
local function setSoundsMuted(val)
	soundsMuted = val
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Sound") and (obj.Name:lower():find("music") or obj.Name:lower():find("pet") or obj.Name:lower():find("ambience")) then
			obj.Volume = val and 0 or 1
		end
	end
end
local soundBtn, yOpt8 = createFlatButton(settingsScroll, "Mute Non-Essential Sounds", yOpt7, BUTTON_BG, BUTTON_BORDER, function()
	setSoundsMuted(not soundsMuted)
	soundBtn.Text = (soundsMuted and "Unmute Sounds") or "Mute Non-Essential Sounds"
end)

-- 8. Disable UI Animations
local uiAnimDisabled = false
local function setUIAnimDisabled(val)
	uiAnimDisabled = val
	for _, obj in ipairs(screenGui:GetDescendants()) do
		if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") then
			obj.TweenPosition = function(...) obj.Position = select(2, ...) end
			obj.TweenSize = function(...) obj.Size = select(2, ...) end
		end
	end
end
local uiAnimBtn, yOpt9 = createFlatButton(settingsScroll, "Disable UI Animations", yOpt8, BUTTON_BG, BUTTON_BORDER, function()
	setUIAnimDisabled(not uiAnimDisabled)
	uiAnimBtn.Text = (uiAnimDisabled and "Enable UI Animations") or "Disable UI Animations"
end)

-- 9. Lower Render Distance
local renderLow = false
local function setRenderLow(val)
	renderLow = val
	local cam = workspace.CurrentCamera
	if cam then
		cam.FarPlane = val and 200 or 1000
	end
end
local renderBtn, yOpt10 = createFlatButton(settingsScroll, "Lower Render Distance", yOpt9, BUTTON_BG, BUTTON_BORDER, function()
	setRenderLow(not renderLow)
	renderBtn.Text = (renderLow and "Restore Render Distance") or "Lower Render Distance"
end)

-- 10. Disable/Replace High-Res Decals
local decalsDisabled = false
local function setDecalsDisabled(val)
	decalsDisabled = val
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Decal") or obj:IsA("Texture") then
			obj.Transparency = val and 1 or 0
		end
	end
end
local decalBtn, yOpt11 = createFlatButton(settingsScroll, "Disable High-Res Decals", yOpt10, BUTTON_BG, BUTTON_BORDER, function()
	setDecalsDisabled(not decalsDisabled)
	decalBtn.Text = (decalsDisabled and "Enable Decals") or "Disable High-Res Decals"
end)

-- 11. Force Low-Quality Lighting
local lightingLow = false
local function setLightingLow(val)
	lightingLow = val
	if val then
		game.Lighting.Technology = Enum.Technology.Compatibility
	else
		game.Lighting.Technology = Enum.Technology.ShadowMap
	end
end
local lightingBtn, yOpt12 = createFlatButton(settingsScroll, "Force Low-Quality Lighting", yOpt11, BUTTON_BG, BUTTON_BORDER, function()
	setLightingLow(not lightingLow)
	lightingBtn.Text = (lightingLow and "Restore Lighting Quality") or "Force Low-Quality Lighting"
end)

-- 12. Remove Unused GUI Elements
local unusedGuiRemoved = false
local function setUnusedGuiRemoved(val)
	unusedGuiRemoved = val
	for _, obj in ipairs(screenGui:GetDescendants()) do
		if (obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextLabel")) and not obj.Visible then
			obj.Parent = val and nil or screenGui
		end
	end
end
local unusedGuiBtn, yOpt13 = createFlatButton(settingsScroll, "Remove Unused GUI Elements", yOpt12, BUTTON_BG, BUTTON_BORDER, function()
	setUnusedGuiRemoved(not unusedGuiRemoved)
	unusedGuiBtn.Text = (unusedGuiRemoved and "Restore Unused GUI") or "Remove Unused GUI Elements"
end)

-- 13. Remove Unused Scripts in StarterGui
local unusedScriptsRemoved = false
local function setUnusedScriptsRemoved(val)
	unusedScriptsRemoved = val
	for _, obj in ipairs(player.PlayerGui:GetDescendants()) do
		if obj:IsA("LocalScript") and not obj.Enabled then
			obj.Parent = val and nil or player.PlayerGui
		end
	end
end
local unusedScriptsBtn, yOpt14 = createFlatButton(settingsScroll, "Remove Unused Scripts", yOpt13, BUTTON_BG, BUTTON_BORDER, function()
	setUnusedScriptsRemoved(not unusedScriptsRemoved)
	unusedScriptsBtn.Text = (unusedScriptsRemoved and "Restore Unused Scripts") or "Remove Unused Scripts"
end)

-- 14. Remove Unused Models in Workspace
local unusedModelsRemoved = false
local function setUnusedModelsRemoved(val)
	unusedModelsRemoved = val
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and not obj:FindFirstChild("Pet") and not obj:FindFirstChild("Humanoid") and not obj:FindFirstChild("Map") then
			obj.Parent = val and nil or workspace
		end
	end
end
local unusedModelsBtn, yOpt15 = createFlatButton(settingsScroll, "Remove Unused Models", yOpt14, BUTTON_BG, BUTTON_BORDER, function()
	setUnusedModelsRemoved(not unusedModelsRemoved)
	unusedModelsBtn.Text = (unusedModelsRemoved and "Restore Unused Models") or "Remove Unused Models"
end)

-- 15. Remove Unused BillboardGuis/SurfaceGuis
local unusedGuisRemoved = false
local function setUnusedGuisRemoved(val)
	unusedGuisRemoved = val
	for _, obj in ipairs(workspace:GetDescendants()) do
		if (obj:IsA("BillboardGui") or obj:IsA("SurfaceGui")) and not obj.Enabled then
			obj.Parent = val and nil or workspace
		end
	end
end
local unusedGuisBtn, yOpt16 = createFlatButton(settingsScroll, "Remove Unused Billboard/SurfaceGuis", yOpt15, BUTTON_BG, BUTTON_BORDER, function()
	setUnusedGuisRemoved(not unusedGuisRemoved)
	unusedGuisBtn.Text = (unusedGuisRemoved and "Restore Unused Guis") or "Remove Unused Billboard/SurfaceGuis"
end)

-- Mining Tab
local miningFrame = Instance.new("Frame")
miningFrame.Size = UDim2.new(1, 0, 1, -40)
miningFrame.Position = UDim2.new(0, 0, 0, 40)
miningFrame.BackgroundTransparency = 1
miningFrame.Parent = mainFrame
miningFrame.Visible = false
tabFrames["Mining"] = miningFrame
local miningScroll = createScrollableFrame(miningFrame)
local yM = 0
yM = createSectionHeader(miningScroll, "Mining Ores", yM)

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
local selectedOres = {}
local mineAllActive = false
local oreButtons = {}

-- Grid layout for ore buttons
local gridCols = 3
local gridCellW = 90
local gridCellH = 28
local gridStartX = 10
local gridStartY = yM
for i, oreId in ipairs(oreOrder) do
	local col = ((i-1) % gridCols)
	local row = math.floor((i-1) / gridCols)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, gridCellW, 0, gridCellH)
	btn.Position = UDim2.new(0, gridStartX + col * (gridCellW + 6), 0, gridStartY + row * (gridCellH + 6))
	btn.BackgroundColor3 = BUTTON_BG
	btn.BorderColor3 = BUTTON_BORDER
	btn.BorderSizePixel = 1
	btn.TextColor3 = BUTTON_TEXT
	btn.Font = FONT
	btn.TextSize = 13
	btn.Text = oreNames[oreId]
	btn.Parent = miningScroll
	oreButtons[oreId] = btn
	selectedOres[oreId] = false
	btn.MouseButton1Click:Connect(function()
		if not mineAllActive then
			selectedOres[oreId] = not selectedOres[oreId]
			btn.BackgroundColor3 = selectedOres[oreId] and ACTIVE_BUTTON_COLOR or BUTTON_BG
			btn.TextColor3 = selectedOres[oreId] and ACTIVE_BUTTON_TEXT or BUTTON_TEXT
		end
	end)
end
local gridRows = math.ceil(#oreOrder / gridCols)
local mineAllBtn = Instance.new("TextButton")
mineAllBtn.Size = UDim2.new(1, -20, 0, 28)
mineAllBtn.Position = UDim2.new(0, 10, 0, gridStartY + gridRows * (gridCellH + 6) + 8)
mineAllBtn.BackgroundColor3 = BUTTON_BG
mineAllBtn.BorderColor3 = BUTTON_BORDER
mineAllBtn.BorderSizePixel = 1
mineAllBtn.TextColor3 = BUTTON_TEXT
mineAllBtn.Font = FONT
mineAllBtn.TextSize = 13
mineAllBtn.Text = "Mine All: OFF"
mineAllBtn.Parent = miningScroll
mineAllBtn.MouseButton1Click:Connect(function()
	mineAllActive = not mineAllActive
	mineAllBtn.BackgroundColor3 = mineAllActive and ACTIVE_BUTTON_COLOR or BUTTON_BG
	mineAllBtn.TextColor3 = mineAllActive and ACTIVE_BUTTON_TEXT or BUTTON_TEXT
	mineAllBtn.Text = mineAllActive and "Mine All: ON" or "Mine All: OFF"
	for oreId, btn in pairs(oreButtons) do
		btn.AutoButtonColor = not mineAllActive
		btn.BackgroundColor3 = (mineAllActive and Color3.fromRGB(50,50,50)) or (selectedOres[oreId] and ACTIVE_BUTTON_COLOR or BUTTON_BG)
		btn.TextColor3 = (mineAllActive and Color3.fromRGB(120,120,120)) or (selectedOres[oreId] and ACTIVE_BUTTON_TEXT or BUTTON_TEXT)
	end
end)
local y = mineAllBtn.Position.Y.Offset + mineAllBtn.Size.Y.Offset + 8

local autoMineBtn, y2 = makeToggleButton(miningScroll, "Auto Mine", y, function()
	if mineAllActive then
		for _, oreId in ipairs(oreOrder) do
			local args = {oreId}
			network:WaitForChild("Mining_Attack"):InvokeServer(unpack(args))
			task.wait(0.2)
		end
	else
		for _, oreId in ipairs(oreOrder) do
			if selectedOres[oreId] then
				local args = {oreId}
				network:WaitForChild("Mining_Attack"):InvokeServer(unpack(args))
				task.wait(0.2)
			end
		end
	end
	task.wait(0.5)
end)
y = y2

-- Merchants Tab
local merchantsFrame = Instance.new("Frame")
merchantsFrame.Size = UDim2.new(1, 0, 1, -40)
merchantsFrame.Position = UDim2.new(0, 0, 0, 40)
merchantsFrame.BackgroundTransparency = 1
merchantsFrame.Parent = mainFrame
merchantsFrame.Visible = false
tabFrames["Merchants"] = merchantsFrame
local merchantsScroll = createScrollableFrame(merchantsFrame)
local y3 = 0

local function makeMerchantToggle(label, count, y, merchantName)
	return makeToggleButton(merchantsScroll, label, y, function()
		for i = 1, count do
			local args = {merchantName, i}
			network:WaitForChild("CustomMerchants_Purchase"):InvokeServer(unpack(args))
			task.wait(0.1)
		end
		task.wait(1)
	end)
end

local miningMerchantBtn, y3b = makeMerchantToggle("MiningMerchant (1-8)", 8, y3, "MiningMerchant")
y3 = y3b
local farmMerchantBtn, y3b = makeMerchantToggle("FarmingMerchant (1-6)", 6, y3, "FarmingMerchant")
y3 = y3b
local stdMerchantBtn, y3b = makeMerchantToggle("StandardMerchant (1-6)", 6, y3, "StandardMerchant")
y3 = y3b
local fishingMerchantBtn, y3b = makeMerchantToggle("FishingMerchant (1-6)", 6, y3, "FishingMerchant")
y3 = y3b
local iceFishingMerchantBtn, y3b = makeMerchantToggle("IceFishingMerchant (1-6)", 6, y3, "IceFishingMerchant")
y3 = y3b

switchTab(selectedTab)

-- Make resizer frames for all edges/corners
local resizerEdges = {"TopLeft", "Top", "TopRight", "Right", "BottomRight", "Bottom", "BottomLeft", "Left"}
for _, edge in ipairs(resizerEdges) do
	local edgeFrame = Instance.new("Frame")
	edgeFrame.Name = "Resizer" .. edge
	edgeFrame.Size = UDim2.new(0, 10, 0, 10)
	edgeFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	edgeFrame.BorderSizePixel = 0
	edgeFrame.Parent = mainFrame
	edgeFrame.Active = true
	-- Position each edge/corner appropriately (pseudo, adjust as needed)
	if edge == "TopLeft" then edgeFrame.Position = UDim2.new(0, 0, 0, 0)
	elseif edge == "Top" then edgeFrame.Position = UDim2.new(0.5, -5, 0, 0)
	elseif edge == "TopRight" then edgeFrame.Position = UDim2.new(1, -10, 0, 0)
	elseif edge == "Right" then edgeFrame.Position = UDim2.new(1, -10, 0.5, -5)
	elseif edge == "BottomRight" then edgeFrame.Position = UDim2.new(1, -10, 1, -10)
	elseif edge == "Bottom" then edgeFrame.Position = UDim2.new(0.5, -5, 1, -10)
	elseif edge == "BottomLeft" then edgeFrame.Position = UDim2.new(0, 0, 1, -10)
	elseif edge == "Left" then edgeFrame.Position = UDim2.new(0, 0, 0.5, -5)
	end
	-- Add resizing logic for each edge/corner (reuse existing resizing logic, but for each frame)
end

-- Ensure all settings fit in the visible area by default (no scrolling needed)
settingsScroll.CanvasSize = UDim2.new(0, 0, 0, 220) 
