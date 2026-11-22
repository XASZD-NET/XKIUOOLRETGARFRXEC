-- LocalScript: วางไว้ใน StarterPlayer -> StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ค่าสถานะและตัวแปรเริ่มต้น
local MAX_LIMIT = 9000000
local state = {
	walkSpeed = 16,
	jumpPower = 50,
	infJump = false,
	fly = false,
	flySpeed = 60,
	noclip = false
}

-- ==========================================
-- 1. สร้าง UI (โทนสีดำ-ม่วง มุมซ้ายบน)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BlackPurpleControlGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- ปุ่มโลโก้ขนาดเล็กมุมซ้ายบน (ID: 1000125489)
local toggleBtn = Instance.new("ImageButton")
toggleBtn.Name = "LogoToggle"
toggleBtn.Size = UDim2.new(0, 42, 0, 42)
toggleBtn.Position = UDim2.new(0, 12, 0, 12)
toggleBtn.BackgroundColor3 = Color3.fromRGB(18, 14, 26)
toggleBtn.Image = "rbxassetid://1000125489"
toggleBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(168, 85, 247)
btnStroke.Thickness = 2
btnStroke.Parent = toggleBtn

-- กรอบเมนูหลัก (ขนาดกะทัดรัด)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainPanel"
mainFrame.Size = UDim2.new(0, 230, 0, 275)
mainFrame.Position = UDim2.new(0, 12, 0, 62)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 11, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- ลากย้ายตำแหน่งได้
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(139, 92, 246)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- แถบหัวข้อ
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 18, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -16, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "⚡ PLAYER PANEL (MAX 9M)"
titleText.TextColor3 = Color3.fromRGB(216, 180, 254)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 12
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Container สำหรับจัดเรียงปุ่มและช่องกรอก
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -16, 1, -40)
container.Position = UDim2.new(0, 8, 0, 36)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = container

-- ฟังก์ชันสร้างช่องกรอกตัวเลข (รองรับสูงสุด 9,000,000)
local function createInputRow(labelText, defaultValue, order, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 32)
	row.BackgroundColor3 = Color3.fromRGB(24, 19, 34)
	row.LayoutOrder = order
	row.Parent = container

	local rCorner = Instance.new("UICorner")
	rCorner.CornerRadius = UDim.new(0, 6)
	rCorner.Parent = row

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.52, 0, 1, 0)
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = Color3.fromRGB(235, 230, 245)
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.42, 0, 0, 22)
	box.Position = UDim2.new(0.55, 0, 0.5, -11)
	box.BackgroundColor3 = Color3.fromRGB(38, 26, 58)
	box.Text = tostring(defaultValue)
	box.PlaceholderText = "0 - 9M"
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.GothamBold
	box.TextSize = 11
	box.ClearTextOnFocus = false
	box.Parent = row

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 4)
	bCorner.Parent = box

	box.FocusLost:Connect(function()
		local num = tonumber(box.Text)
		if num then
			num = math.clamp(num, 0, MAX_LIMIT)
			box.Text = tostring(num)
			callback(num)
		else
			box.Text = tostring(defaultValue)
		end
	end)
end

-- ฟังก์ชันสร้างปุ่มเปิด/ปิด (Toggle)
local function createToggleRow(labelText, order, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(24, 19, 34)
	btn.Text = labelText .. " : ปิด (OFF)"
	btn.TextColor3 = Color3.fromRGB(180, 170, 195)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.LayoutOrder = order
	btn.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local isOn = false
	btn.MouseButton1Click:Connect(function()
		isOn = not isOn
		if isOn then
			btn.BackgroundColor3 = Color3.fromRGB(126, 34, 206)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Text = labelText .. " : เปิด (ON)"
		else
			btn.BackgroundColor3 = Color3.fromRGB(24, 19, 34)
			btn.TextColor3 = Color3.fromRGB(180, 170, 195)
			btn.Text = labelText .. " : ปิด (OFF)"
		end
		callback(isOn)
	end)
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
		bodyGyro.P = 9e4
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.CFrame = root.CFrame
		bodyGyro.Parent = root

		bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bodyVel.Velocity = Vector3.zero
		bodyVel.Parent = root
	else
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
		if bodyVel then bodyVel:Destroy() bodyVel = nil end
		if hum then hum.PlatformStand = false end
	end
end

-- ลูปอัปเดตความเร็ว, กระโดด, บิน และทะลุ (Noclip)
RunService.Stepped:Connect(function()
	local char = player.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	if hum then
		hum.WalkSpeed = state.walkSpeed
		hum.UseJumpPower = true
		hum.JumpPower = state.jumpPower
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
			-- เคลื่อนที่ไปตามทิศทางกล้องและปุ่มเดิน (รองรับทั้งมือถือและคีย์บอร์ด)
			local lookVec = cam.CFrame.LookVector
			local rightVec = cam.CFrame.RightVector
			local forwardAmount = moveDir:Dot(Vector3.new(lookVec.X, 0, lookVec.Z).Unit)
			local rightAmount = moveDir:Dot(Vector3.new(rightVec.X, 0, rightVec.Z).Unit)

			if tostring(forwardAmount) == "nan" then forwardAmount = 0 end
			if tostring(rightAmount) == "nan" then rightAmount = 0 end

			local flyDir = (lookVec * forwardAmount) + (rightVec * rightAmount)
			bodyVel.Velocity = flyDir * state.flySpeed
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
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

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

-- ==========================================
-- 3. เชื่อมต่อปุ่ม UI เข้ากับฟังก์ชัน
-- ==========================================
createInputRow("ความเร็ว (Speed)", 16, 1, function(val)
	state.walkSpeed = val
end)

createInputRow("กระโดด (Jump)", 50, 2, function(val)
	state.jumpPower = val
end)

createToggleRow("กระโดดไม่จำกัด", 3, function(on)
	state.infJump = on
end)

createToggleRow("บิน (Fly)", 4, function(on)
	setFly(on)
end)

createInputRow("ความเร็วบิน", 60, 5, function(val)
	state.flySpeed = val
end)

createToggleRow("ทะลุ (Noclip)", 6, function(on)
	setNoclip(on)
end)

-- ปุ่มโลโก้กดเปิด/ปิดหน้าต่างเมนู
toggleBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- รีเซ็ตสถานะบินเมื่อตัวละครเกิดใหม่
player.CharacterAdded:Connect(function()
	if state.fly then
		setFly(false)
	end
end)
