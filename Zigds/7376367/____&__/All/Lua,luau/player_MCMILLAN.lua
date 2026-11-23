-- LocalScript: player_MCMILLAN.lua
-- ตำแหน่งติดตั้ง: StarterPlayer -> StarterPlayerScripts
-- Theme: Dark Purple | Max Limit: 9,000,000
-- รายละเอียด:
--   1. ปรับค่า WalkSpeed, JumpPower และ FlySpeed สูงสุด 9,000,000 พร้อมปุ่มรีเซ็ตค่าเริ่มต้น
--   2. ระบบกระโดดไม่จำกัด (Infinite Jump), บินตามทิศทางกล้อง (Fly) และทะลุกำแพง (Noclip)
--   3. ลากย้ายได้ทั้งหน้าต่างหลัก (ผ่านแถบหัวข้อ) และปุ่มโลโก้วงกลมลอย รองรับทัชสกรีนและเมาส์
--   4. แสดงสถานะการทำงานแบบเรียลไทม์ + ปุ่มย่อ/ขยายเมนูและรีเซ็ตทุกโหมด

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- ค่าสถานะและตัวแปรเริ่มต้น
-- ==========================================
local MAX_LIMIT = 9000000
local DEFAULTS = {
	walkSpeed = 16,
	jumpPower = 50,
	flySpeed = 60,
}

local state = {
	walkSpeed = DEFAULTS.walkSpeed,
	jumpPower = DEFAULTS.jumpPower,
	infJump = false,
	fly = false,
	flySpeed = DEFAULTS.flySpeed,
	noclip = false,
	lastAction = "พร้อมใช้งาน",
}

local uiRefs = {
	speedBox = nil,
	jumpBox = nil,
	flyBox = nil,
	infJumpBtn = nil,
	flyBtn = nil,
	noclipBtn = nil,
	statusLabel = nil,
}

local function formatNum(n)
	local num = math.floor(tonumber(n) or 0)
	local sign = num < 0 and "-" or ""
	local s = tostring(math.abs(num))
	local r = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return sign .. (r:gsub("^,", ""))
end

local function setStatus(msg)
	state.lastAction = msg
	if uiRefs.statusLabel and uiRefs.statusLabel.Parent then
		local stamp = os.date("%H:%M:%S")
		uiRefs.statusLabel.Text = "[" .. stamp .. "] " .. msg
	end
end

-- ตัวช่วยลาก UI ที่รองรับทั้งทัชสกรีนและเมาส์ พร้อมแยกการคลิก
local function makeDraggable(targetFrame, dragHandle, onMovedCallback)
	local dragging = false
	local activeInput = nil
	local dragStart = Vector2.zero
	local startPos = targetFrame.Position
	local moved = false

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			activeInput = input
			dragStart = input.Position
			startPos = targetFrame.Position
			moved = false

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End and activeInput == input then
					dragging = false
					activeInput = nil
					if onMovedCallback then
						onMovedCallback(moved)
					end
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragging and activeInput == nil then
				activeInput = input
			end
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == activeInput then
			local delta = input.Position - dragStart
			if delta.Magnitude > 6 then
				moved = true
			end
			targetFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ล้าง GUI เก่าหากมีการรันซ้ำ
local oldGui = playerGui:FindFirstChild("BlackPurpleControlGui")
if oldGui then
	oldGui:Destroy()
end

-- ==========================================
-- 1. สร้าง UI (โทนสีดำ-ม่วง ลากได้ละเอียด)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlackPurpleControlGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ปุ่มโลโก้วงกลมลอย (ID: 1000125489) - ลากได้ + กดเปิด/ปิดหน้าต่าง
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "LogoToggle"
toggleBtn.Size = UDim2.new(0, 48, 0, 48)
toggleBtn.Position = UDim2.new(0, 14, 0, 14)
toggleBtn.BackgroundColor3 = Color3.fromRGB(18, 14, 26)
toggleBtn.Image = "rbxassetid://1000125489"
toggleBtn.AutoButtonColor = true
toggleBtn.Active = true
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(168, 85, 247)
btnStroke.Thickness = 2
btnStroke.Parent = toggleBtn

-- กรอบเมนูหลัก (ขนาดกะทัดรัด รายละเอียดครบ)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainPanel"
mainFrame.Size = UDim2.new(0, 264, 0, 356)
mainFrame.Position = UDim2.new(0, 14, 0, 70)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 11, 20)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(139, 92, 246)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- แถบหัวข้อ (ใช้เป็นจุดลากย้ายหน้าต่างหลัก)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 18, 45)
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -66, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "⚡ PLAYER PANEL • MAX 9M"
titleText.TextColor3 = Color3.fromRGB(235, 210, 255)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 12
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local miniBtn = Instance.new("TextButton")
miniBtn.Name = "MinimizeBtn"
miniBtn.Size = UDim2.new(0, 24, 0, 24)
miniBtn.Position = UDim2.new(1, -56, 0.5, -12)
miniBtn.BackgroundColor3 = Color3.fromRGB(65, 35, 110)
miniBtn.Text = "-"
miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 14
miniBtn.Parent = titleBar
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 6)

local resetAllBtn = Instance.new("TextButton")
resetAllBtn.Name = "ResetAllBtn"
resetAllBtn.Size = UDim2.new(0, 24, 0, 24)
resetAllBtn.Position = UDim2.new(1, -28, 0.5, -12)
resetAllBtn.BackgroundColor3 = Color3.fromRGB(95, 28, 85)
resetAllBtn.Text = "↺"
resetAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetAllBtn.Font = Enum.Font.GothamBold
resetAllBtn.TextSize = 13
resetAllBtn.Parent = titleBar
Instance.new("UICorner", resetAllBtn).CornerRadius = UDim.new(0, 6)

-- แถบสถานะด้านบนสุดของเนื้อหา
local statusBar = Instance.new("Frame")
statusBar.Name = "StatusBar"
statusBar.Size = UDim2.new(1, -16, 0, 22)
statusBar.Position = UDim2.new(0, 8, 0, 42)
statusBar.BackgroundColor3 = Color3.fromRGB(22, 16, 34)
statusBar.BorderSizePixel = 0
statusBar.Parent = mainFrame
Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -10, 1, 0)
statusLabel.Position = UDim2.new(0, 5, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "สถานะ: พร้อมใช้งาน (จำกัดสูงสุด 9,000,000)"
statusLabel.TextColor3 = Color3.fromRGB(216, 180, 254)
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 10
statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusBar
uiRefs.statusLabel = statusLabel

-- Container สำหรับจัดเรียงปุ่มและช่องกรอก
local container = Instance.new("ScrollingFrame")
container.Name = "ControlsContainer"
container.Size = UDim2.new(1, -16, 1, -72)
container.Position = UDim2.new(0, 8, 0, 68)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 3
container.ScrollBarImageColor3 = Color3.fromRGB(168, 85, 247)
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = container

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 6)
end)

-- ฟังก์ชันสร้างช่องกรอกตัวเลข (รองรับสูงสุด 9,000,000 + ปุ่มรีเซ็ตค่าเริ่มต้น)
local function createInputRow(labelText, defaultValue, order, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 38)
	row.BackgroundColor3 = Color3.fromRGB(24, 19, 34)
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.Parent = container

	local rCorner = Instance.new("UICorner")
	rCorner.CornerRadius = UDim.new(0, 8)
	rCorner.Parent = row

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.45, 0, 1, 0)
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = Color3.fromRGB(240, 235, 250)
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.36, 0, 0, 24)
	box.Position = UDim2.new(0.47, 0, 0.5, -12)
	box.BackgroundColor3 = Color3.fromRGB(38, 26, 58)
	box.Text = tostring(defaultValue)
	box.PlaceholderText = "0 - 9M"
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.GothamBold
	box.TextSize = 11
	box.ClearTextOnFocus = false
	box.Parent = row
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

	local defBtn = Instance.new("TextButton")
	defBtn.Size = UDim2.new(0, 26, 0, 24)
	defBtn.Position = UDim2.new(1, -30, 0.5, -12)
	defBtn.BackgroundColor3 = Color3.fromRGB(52, 36, 80)
	defBtn.Text = tostring(defaultValue)
	defBtn.TextColor3 = Color3.fromRGB(216, 180, 254)
	defBtn.Font = Enum.Font.GothamBold
	defBtn.TextSize = 9
	defBtn.Parent = row
	Instance.new("UICorner", defBtn).CornerRadius = UDim.new(0, 6)

	local function applyValue(rawNum)
		local clamped = math.clamp(rawNum, 0, MAX_LIMIT)
		box.Text = tostring(clamped)
		callback(clamped)
		setStatus(labelText .. " = " .. formatNum(clamped))
	end

	box.FocusLost:Connect(function()
		local num = tonumber(box.Text)
		if num then
			applyValue(num)
		else
			box.Text = tostring(defaultValue)
			setStatus("ค่าไม่ถูกต้อง คืนค่า " .. labelText .. " เป็น " .. tostring(defaultValue))
		end
	end)

	defBtn.MouseButton1Click:Connect(function()
		applyValue(defaultValue)
	end)

	return box
end

-- ฟังก์ชันสร้างปุ่มเปิด/ปิด (Toggle) พร้อมแอนิเมชันสี
local function createToggleRow(labelText, order, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(24, 19, 34)
	btn.Text = labelText .. " : ปิด (OFF)"
	btn.TextColor3 = Color3.fromRGB(190, 180, 205)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.LayoutOrder = order
	btn.Parent = container
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke", btn)
	stroke.Color = Color3.fromRGB(95, 60, 155)
	stroke.Transparency = 0.5
	stroke.Thickness = 1

	local isOn = false
	local function setVisual(stateBool)
		isOn = stateBool
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isOn and Color3.fromRGB(126, 34, 206) or Color3.fromRGB(24, 19, 34)
		}):Play()
		btn.TextColor3 = isOn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 180, 205)
		btn.Text = labelText .. (isOn and " : เปิด (ON)" or " : ปิด (OFF)")
	end

	btn.MouseButton1Click:Connect(function()
		setVisual(not isOn)
		callback(isOn)
		setStatus(labelText .. (isOn and " -> เปิดใช้งาน" or " -> ปิดใช้งาน"))
	end)

	return btn, setVisual
end

-- ==========================================
-- 2. ระบบการทำงานของแต่ละฟังก์ชัน
-- ==========================================

-- ระบบบิน (Fly)
local bodyGyro, bodyVel
local function setFly(enabled)
	state.fly = enabled
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if enabled and root and hum then
		hum.PlatformStand = true
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.Name = "PlayerPanelGyro"
		bodyGyro.P = 9e4
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.CFrame = root.CFrame
		bodyGyro.Parent = root

		bodyVel = Instance.new("BodyVelocity")
		bodyVel.Name = "PlayerPanelVel"
		bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bodyVel.Velocity = Vector3.zero
		bodyVel.Parent = root
	else
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
		if bodyVel then bodyVel:Destroy() bodyVel = nil end
		if hum then hum.PlatformStand = false end
	end
end

-- คืนค่า Noclip เมื่อปิดใช้งาน
local function setNoclip(enabled)
	state.noclip = enabled
	if not enabled and player.Character then
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.CanCollide = true
			end
		end
	end
end

-- ลูปอัปเดตความเร็ว, กระโดด, บิน และทะลุ (Noclip)
RunService.Stepped:Connect(function()
	local char = player.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	if hum then
		if hum.WalkSpeed ~= state.walkSpeed then
			hum.WalkSpeed = state.walkSpeed
		end
		if not hum.UseJumpPower then
			hum.UseJumpPower = true
		end
		if hum.JumpPower ~= state.jumpPower then
			hum.JumpPower = state.jumpPower
		end
	end

	-- ระบบทะลุกำแพง (Noclip)
	if state.noclip then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end

	-- ระบบควบคุมทิศทางขณะบิน
	if state.fly and root and bodyGyro and bodyVel and hum then
		local cam = workspace.CurrentCamera
		local moveDir = hum.MoveDirection
		bodyGyro.CFrame = cam.CFrame

		if moveDir.Magnitude > 0 then
			local lookFlat = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
			local rightFlat = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
			local lookUnit = lookFlat.Magnitude > 0.001 and lookFlat.Unit or Vector3.new(0, 0, -1)
			local rightUnit = rightFlat.Magnitude > 0.001 and rightFlat.Unit or Vector3.new(1, 0, 0)

			local forwardAmount = moveDir:Dot(lookUnit)
			local rightAmount = moveDir:Dot(rightUnit)
			local flyDir = (cam.CFrame.LookVector * forwardAmount) + (rightUnit * rightAmount)

			if flyDir.Magnitude > 0.001 then
				bodyVel.Velocity = flyDir.Unit * state.flySpeed
			else
				bodyVel.Velocity = Vector3.zero
			end
		else
			bodyVel.Velocity = Vector3.zero
		end
	end
end)

-- ระบบกระโดดไม่จำกัด (Infinite Jump)
UserInputService.JumpRequest:Connect(function()
	if state.infJump then
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- ==========================================
-- 3. เชื่อมต่อปุ่ม UI เข้ากับฟังก์ชัน
-- ==========================================
uiRefs.speedBox = createInputRow("ความเร็วเดิน", DEFAULTS.walkSpeed, 1, function(val)
	state.walkSpeed = val
end)

uiRefs.jumpBox = createInputRow("พลังกระโดด", DEFAULTS.jumpPower, 2, function(val)
	state.jumpPower = val
end)

local _, setInfJumpVisual = createToggleRow("กระโดดไม่จำกัด", 3, function(on)
	state.infJump = on
end)

local _, setFlyVisual = createToggleRow("บิน (Fly)", 4, function(on)
	setFly(on)
end)

uiRefs.flyBox = createInputRow("ความเร็วบิน", DEFAULTS.flySpeed, 5, function(val)
	state.flySpeed = val
end)

local _, setNoclipVisual = createToggleRow("ทะลุกำแพง (Noclip)", 6, function(on)
	setNoclip(on)
end)

-- ระบบลากย้ายทั้งปุ่มโลโก้และหน้าต่างหลัก (ผ่านแถบหัวข้อ)
local logoWasDragged = false
makeDraggable(toggleBtn, toggleBtn, function(didMove)
	logoWasDragged = didMove
	task.delay(0.05, function()
		logoWasDragged = false
	end)
end)

makeDraggable(mainFrame, titleBar, nil)

toggleBtn.MouseButton1Click:Connect(function()
	if not logoWasDragged then
		mainFrame.Visible = not mainFrame.Visible
		setStatus(mainFrame.Visible and "แสดงหน้าต่างเมนู" or "ซ่อนหน้าต่างเมนู")
	end
end)

miniBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	setStatus("ย่อหน้าต่างเมนูลงปุ่มโลโก้")
end)

resetAllBtn.MouseButton1Click:Connect(function()
	state.walkSpeed = DEFAULTS.walkSpeed
	state.jumpPower = DEFAULTS.jumpPower
	state.flySpeed = DEFAULTS.flySpeed
	state.infJump = false
	state.fly = false
	state.noclip = false

	if uiRefs.speedBox then uiRefs.speedBox.Text = tostring(DEFAULTS.walkSpeed) end
	if uiRefs.jumpBox then uiRefs.jumpBox.Text = tostring(DEFAULTS.jumpPower) end
	if uiRefs.flyBox then uiRefs.flyBox.Text = tostring(DEFAULTS.flySpeed) end

	setInfJumpVisual(false)
	setFlyVisual(false)
	setNoclipVisual(false)
	setFly(false)
	setNoclip(false)
	setStatus("รีเซ็ตค่าและโหมดทั้งหมดกลับสู่ค่าเริ่มต้นแล้ว")
end)

-- รีเซ็ตสถานะบินเมื่อตัวละครเกิดใหม่
player.CharacterAdded:Connect(function()
	if state.fly then
		setFly(false)
		setFlyVisual(false)
	end
	setStatus("โหลดตัวละครใหม่เรียบร้อย")
end)
