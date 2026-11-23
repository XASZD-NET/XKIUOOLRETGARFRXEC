-- =========================================================================
-- ชื่อไฟล์: GodMode_PurpleBlack_UI_All_In_One.lua
-- ตำแหน่งติดตั้ง: ServerScriptService (Script เดียวจบ ครบทั้งระบบ + UI)
-- รายละเอียด: 
--   1. ระบบอมตะ เลือดสูงสุด 9,000,000 + กันดาเมจทุกชนิด + กันตกแมพ (Anti-Void)
--   2. หน้าต่าง UI โทนดำ-ม่วง (Purple-Black) ตัวหนังสือสีขาวล้วน คมชัด
--   3. มีปุ่มย่อ/ขยายหน้าต่าง (Minimize), ปุ่มลอยเปิดหน้าต่าง, สวิตช์เปิด-ปิดโหมดต่างๆ
--      และปุ่มกดวาร์ปกลับจุดปลอดภัยด้วยตัวเอง
-- =========================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ==================== ตั้งค่าหลัก (ปรับแต่งได้ตรงนี้) ====================
local CONFIG = {
	MAX_HP = 9000000,            -- เลือดสูงสุดเริ่มต้น
	VOID_Y = -200,               -- ความลึกที่ถือว่าตกแมพ (จะดึงกลับจุดปลอดภัยอัตโนมัติ)
	SAFE_OFFSET = Vector3.new(0, 4, 0),
	TWEEN_SPEED = 0.2,
	
	-- โทนสี UI (ดำ-ม่วง + ตัวหนังสือสีขาว)
	THEME = {
		BgDark = Color3.fromRGB(10, 8, 15),          -- ดำอมม่วงเข้ม (พื้นหลังหลัก)
		BgCard = Color3.fromRGB(18, 13, 28),         -- ดำม่วง (การ์ดย่อย)
		BgHeader = Color3.fromRGB(24, 16, 40),       -- ม่วงเข้ม (แถบหัวข้อ)
		PurpleMain = Color3.fromRGB(130, 55, 245),   -- ม่วงหลัก
		PurpleBright = Color3.fromRGB(185, 105, 255),-- ม่วงสว่าง (ไล่เฉด)
		PurpleBorder = Color3.fromRGB(145, 70, 255), -- สีเส้นขอบเรืองแสง
		ToggleOff = Color3.fromRGB(36, 28, 52),      -- สีปุ่มตอนปิด
		TextWhite = Color3.fromRGB(255, 255, 255),   -- ตัวหนังสือสีขาวล้วน
	}
}

-- ฟังก์ชันจัดรูปแบบตัวเลขใส่ลูกน้ำ (เช่น 9,000,000)
local function formatNumber(n)
	local num = math.floor(tonumber(n) or 0)
	local sign = num < 0 and "-" or ""
	local s = tostring(math.abs(num))
	local r = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return sign .. (r:gsub("^,", ""))
end

-- ==================== สร้างหน้าต่าง UI (ดำ-ม่วง ตัวหนังสือขาว) ====================
local function createPurpleBlackUI(player)
	local playerGui = player:WaitForChild("PlayerGui")
	local oldGui = playerGui:FindFirstChild("GodModePurpleBlackUI")
	if oldGui then
		oldGui:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GodModePurpleBlackUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	-- ปุ่มลอยวงกลม (แสดงตอนย่อหน้าต่าง UI เก็บไว้)
	local floatingBtn = Instance.new("TextButton")
	floatingBtn.Name = "FloatingOpenButton"
	floatingBtn.Size = UDim2.new(0, 48, 0, 48)
	floatingBtn.Position = UDim2.new(0, 16, 0, 24)
	floatingBtn.BackgroundColor3 = CONFIG.THEME.BgDark
	floatingBtn.Text = "UI"
	floatingBtn.Font = Enum.Font.GothamBlack
	floatingBtn.TextSize = 15
	floatingBtn.TextColor3 = CONFIG.THEME.TextWhite
	floatingBtn.Visible = false
	floatingBtn.AutoButtonColor = true
	floatingBtn.Parent = screenGui
	Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(1, 0)

	local floatStroke = Instance.new("UIStroke")
	floatStroke.Color = CONFIG.THEME.PurpleBorder
	floatStroke.Thickness = 2
	floatStroke.Parent = floatingBtn

	-- หน้าต่างหลัก (Main Window)
	local mainWindow = Instance.new("Frame")
	mainWindow.Name = "MainWindow"
	mainWindow.Size = UDim2.new(0, 320, 0, 275)
	mainWindow.Position = UDim2.new(0, 16, 0, 24)
	mainWindow.BackgroundColor3 = CONFIG.THEME.BgDark
	mainWindow.BorderSizePixel = 0
	mainWindow.ClipsDescendants = true
	mainWindow.Parent = screenGui
	Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 14)

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = CONFIG.THEME.PurpleBorder
	mainStroke.Thickness = 2
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.Parent = mainWindow

	local bgGradient = Instance.new("UIGradient")
	bgGradient.Rotation = 135
	bgGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 11, 26)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 8, 15)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 12, 36)),
	})
	bgGradient.Parent = mainWindow

	-- แถบหัวข้อด้านบน (Top Header - สามารถลากย้ายหน้าต่างได้)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundColor3 = CONFIG.THEME.BgHeader
	header.BorderSizePixel = 0
	header.Parent = mainWindow

	local headerLine = Instance.new("Frame")
	headerLine.Name = "BottomLine"
	headerLine.Size = UDim2.new(1, 0, 0, 1)
	headerLine.Position = UDim2.new(0, 0, 1, -1)
	headerLine.BackgroundColor3 = CONFIG.THEME.PurpleBorder
	headerLine.BackgroundTransparency = 0.4
	headerLine.BorderSizePixel = 0
	headerLine.Parent = header

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "WindowTitle"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 14, 0, 0)
	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextColor3 = CONFIG.THEME.TextWhite
	titleLabel.Text = "GOD MODE • PURPLE PANEL"
	titleLabel.Parent = header

	-- ปุ่มย่อหน้าต่าง (-)
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Name = "MinimizeButton"
	minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
	minimizeBtn.Position = UDim2.new(1, -36, 0.5, -14)
	minimizeBtn.BackgroundColor3 = CONFIG.THEME.PurpleMain
	minimizeBtn.Text = "-"
	minimizeBtn.Font = Enum.Font.GothamBlack
	minimizeBtn.TextSize = 16
	minimizeBtn.TextColor3 = CONFIG.THEME.TextWhite
	minimizeBtn.Parent = header
	Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

	-- พื้นที่เนื้อหาภายในหน้าต่าง
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Position = UDim2.new(0, 12, 0, 48)
	content.Size = UDim2.new(1, -24, 1, -56)
	content.Parent = mainWindow

	-- กล่องแสดงแถบพลังชีวิต (Health Card)
	local hpCard = Instance.new("Frame")
	hpCard.Name = "HealthCard"
	hpCard.Size = UDim2.new(1, 0, 0, 68)
	hpCard.Position = UDim2.new(0, 0, 0, 0)
	hpCard.BackgroundColor3 = CONFIG.THEME.BgCard
	hpCard.BorderSizePixel = 0
	hpCard.Parent = content
	Instance.new("UICorner", hpCard).CornerRadius = UDim.new(0, 10)

	local hpCardStroke = Instance.new("UIStroke")
	hpCardStroke.Color = CONFIG.THEME.PurpleMain
	hpCardStroke.Transparency = 0.5
	hpCardStroke.Thickness = 1
	hpCardStroke.Parent = hpCard

	local hpHeaderText = Instance.new("TextLabel")
	hpHeaderText.BackgroundTransparency = 1
	hpHeaderText.Position = UDim2.new(0, 10, 0, 6)
	hpHeaderText.Size = UDim2.new(0.5, 0, 0, 18)
	hpHeaderText.Font = Enum.Font.GothamBold
	hpHeaderText.TextSize = 12
	hpHeaderText.TextXAlignment = Enum.TextXAlignment.Left
	hpHeaderText.TextColor3 = CONFIG.THEME.TextWhite
	hpHeaderText.Text = "HEALTH STATUS"
	hpHeaderText.Parent = hpCard

	local hpPercentText = Instance.new("TextLabel")
	hpPercentText.Name = "PercentLabel"
	hpPercentText.BackgroundTransparency = 1
	hpPercentText.Position = UDim2.new(0.5, 0, 0, 6)
	hpPercentText.Size = UDim2.new(0.5, -10, 0, 18)
	hpPercentText.Font = Enum.Font.GothamBold
	hpPercentText.TextSize = 12
	hpPercentText.TextXAlignment = Enum.TextXAlignment.Right
	hpPercentText.TextColor3 = CONFIG.THEME.TextWhite
	hpPercentText.Text = "100%"
	hpPercentText.Parent = hpCard

	local barBack = Instance.new("Frame")
	barBack.Name = "BarBack"
	barBack.Position = UDim2.new(0, 10, 0, 28)
	barBack.Size = UDim2.new(1, -20, 0, 30)
	barBack.BackgroundColor3 = CONFIG.THEME.BgDark
	barBack.BorderSizePixel = 0
	barBack.ClipsDescendants = true
	barBack.Parent = hpCard
	Instance.new("UICorner", barBack).CornerRadius = UDim.new(0, 8)

	local barFill = Instance.new("Frame")
	barFill.Name = "BarFill"
	barFill.Size = UDim2.new(1, 0, 1, 0)
	barFill.BackgroundColor3 = CONFIG.THEME.TextWhite
	barFill.BorderSizePixel = 0
	barFill.Parent = barBack
	Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 8)

	local barGrad = Instance.new("UIGradient")
	barGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, CONFIG.THEME.PurpleMain),
		ColorSequenceKeypoint.new(1, CONFIG.THEME.PurpleBright),
	})
	barGrad.Parent = barFill

	local hpValueLabel = Instance.new("TextLabel")
	hpValueLabel.Name = "HpValueLabel"
	hpValueLabel.BackgroundTransparency = 1
	hpValueLabel.Size = UDim2.new(1, 0, 1, 0)
	hpValueLabel.Font = Enum.Font.GothamBold
	hpValueLabel.TextSize = 13
	hpValueLabel.TextColor3 = CONFIG.THEME.TextWhite
	hpValueLabel.ZIndex = 3
	hpValueLabel.Text = formatNumber(CONFIG.MAX_HP) .. " / " .. formatNumber(CONFIG.MAX_HP)
	hpValueLabel.Parent = barBack

	-- ฟังก์ชันตัวช่วยสร้างแถวสวิตช์เปิด-ปิด (Toggle Row)
	local function createToggleRow(titleText, yPos, defaultState)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 42)
		row.Position = UDim2.new(0, 0, 0, yPos)
		row.BackgroundColor3 = CONFIG.THEME.BgCard
		row.BorderSizePixel = 0
		row.Parent = content
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

		local rowStroke = Instance.new("UIStroke")
		rowStroke.Color = CONFIG.THEME.PurpleMain
		rowStroke.Transparency = 0.65
		rowStroke.Thickness = 1
		rowStroke.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Position = UDim2.new(0, 12, 0, 0)
		lbl.Size = UDim2.new(1, -85, 1, 0)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextColor3 = CONFIG.THEME.TextWhite
		lbl.Text = titleText
		lbl.Parent = row

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 62, 0, 26)
		btn.Position = UDim2.new(1, -72, 0.5, -13)
		btn.BackgroundColor3 = defaultState and CONFIG.THEME.PurpleMain or CONFIG.THEME.ToggleOff
		btn.Font = Enum.Font.GothamBlack
		btn.TextSize = 12
		btn.TextColor3 = CONFIG.THEME.TextWhite
		btn.Text = defaultState and "ON" or "OFF"
		btn.Parent = row
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

		return btn
	end

	-- สร้างปุ่มควบคุมฟังก์ชันในหน้าต่าง UI
	local godModeBtn = createToggleRow("โหมดอมตะ (God Mode)", 76, true)
	local antiVoidBtn = createToggleRow("กันตกแมพ (Anti-Void)", 124, true)

	-- ปุ่มวาร์ปกลับจุดปลอดภัยด้วยตัวเอง (Manual Safe Teleport)
	local safeTpBtn = Instance.new("TextButton")
	safeTpBtn.Name = "SafeTeleportButton"
	safeTpBtn.Size = UDim2.new(1, 0, 0, 38)
	safeTpBtn.Position = UDim2.new(0, 0, 0, 172)
	safeTpBtn.BackgroundColor3 = CONFIG.THEME.PurpleMain
	safeTpBtn.Font = Enum.Font.GothamBlack
	safeTpBtn.TextSize = 13
	safeTpBtn.TextColor3 = CONFIG.THEME.TextWhite
	safeTpBtn.Text = "วาร์ปกลับจุดปลอดภัย (Safe Point)"
	safeTpBtn.Parent = content
	Instance.new("UICorner", safeTpBtn).CornerRadius = UDim.new(0, 10)

	local tpGrad = Instance.new("UIGradient")
	tpGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, CONFIG.THEME.PurpleMain),
		ColorSequenceKeypoint.new(1, CONFIG.THEME.PurpleBright),
	})
	tpGrad.Parent = safeTpBtn

	-- ระบบย่อ/ขยายหน้าต่าง UI
	minimizeBtn.MouseButton1Click:Connect(function()
		mainWindow.Visible = false
		floatingBtn.Visible = true
	end)

	floatingBtn.MouseButton1Click:Connect(function()
		floatingBtn.Visible = false
		mainWindow.Visible = true
	end)

	-- ระบบลากย้ายหน้าต่าง UI (รองรับทั้งเมาส์และหน้าจอสัมผัสมือถือ)
	local dragging = false
	local dragInput, dragStart, startPos

	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainWindow.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			mainWindow.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	return {
		gui = screenGui,
		barFill = barFill,
		hpValueLabel = hpValueLabel,
		hpPercentText = hpPercentText,
		godModeBtn = godModeBtn,
		antiVoidBtn = antiVoidBtn,
		safeTpBtn = safeTpBtn,
	}
end

-- ==================== ระบบตัวละครและสถานะผู้เล่น ====================
local function onPlayerAdded(player)
	local ui = createPurpleBlackUI(player)

	-- สถานะเปิด/ปิดของแต่ละระบบประจำตัวผู้เล่น
	local state = {
		godMode = true,
		antiVoid = true,
	}

	local currentCharacter = nil
	local currentHumanoid = nil
	local currentRoot = nil
	local safeCFrame = nil

	local function updateToggleVisual(button, isOn)
		button.Text = isOn and "ON" or "OFF"
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = isOn and CONFIG.THEME.PurpleMain or CONFIG.THEME.ToggleOff
		}):Play()
	end

	local function bindCharacter(character)
		currentCharacter = character
		local humanoid = character:WaitForChild("Humanoid")
		local root = character:WaitForChild("HumanoidRootPart")
		currentHumanoid = humanoid
		currentRoot = root
		safeCFrame = root.CFrame + CONFIG.SAFE_OFFSET

		local connections = {}
		local isActive = true
		local isHealing = false
		local activeTween = nil

		local function cleanup()
			if not isActive then return end
			isActive = false
			if activeTween then
				activeTween:Cancel()
				activeTween = nil
			end
			for _, conn in ipairs(connections) do
				if conn.Connected then
					conn:Disconnect()
				end
			end
			table.clear(connections)
		end

		local function syncForceField()
			local ff = character:FindFirstChild("PurpleGodShield")
			if state.godMode then
				if not ff then
					ff = Instance.new("ForceField")
					ff.Name = "PurpleGodShield"
					ff.Visible = false
					ff.Parent = character
				end
			else
				if ff then
					ff:Destroy()
				end
			end
		end

		local function applyGodStats()
			if not state.godMode or isHealing or not humanoid.Parent then
				return
			end
			isHealing = true
			humanoid.BreakJointsOnDeath = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			if humanoid.MaxHealth ~= CONFIG.MAX_HP then
				humanoid.MaxHealth = CONFIG.MAX_HP
			end
			if humanoid.Health < CONFIG.MAX_HP then
				humanoid.Health = CONFIG.MAX_HP
			end
			syncForceField()
			isHealing = false
		end

		local function updateHealthBar(instant)
			if not ui or not ui.gui.Parent then return end
			local maxHp = math.max(humanoid.MaxHealth, 1)
			local curHp = math.clamp(humanoid.Health, 0, maxHp)
			local ratio = math.clamp(curHp / maxHp, 0, 1)

			ui.hpValueLabel.Text = formatNumber(curHp) .. " / " .. formatNumber(maxHp)
			ui.hpPercentText.Text = tostring(math.floor(ratio * 100)) .. "%"

			if activeTween then
				activeTween:Cancel()
				activeTween = nil
			end

			local targetSize = UDim2.new(ratio, 0, 1, 0)
			if instant then
				ui.barFill.Size = targetSize
			else
				activeTween = TweenService:Create(
					ui.barFill,
					TweenInfo.new(CONFIG.TWEEN_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Size = targetSize }
				)
				activeTween:Play()
			end
		end

		-- ตั้งค่าเริ่มต้นเมื่อเกิดตัวละคร
		if state.godMode then
			applyGodStats()
		end
		updateHealthBar(true)

		-- ดักจับการเปลี่ยนแปลงเลือด
		table.insert(connections, humanoid.HealthChanged:Connect(function(hp)
			if not isActive or isHealing then return end
			if state.godMode and hp < CONFIG.MAX_HP then
				applyGodStats()
			end
			updateHealthBar(false)
		end))

		-- ดักจับการเปลี่ยนแปลง MaxHealth
		table.insert(connections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			if not isActive or isHealing then return end
			if state.godMode and humanoid.MaxHealth ~= CONFIG.MAX_HP then
				applyGodStats()
			end
			updateHealthBar(false)
		end))

		-- กันตายฉุกเฉินเมื่อเปิดโหมดอมตะ
		table.insert(connections, humanoid.Died:Connect(function()
			if not isActive or not state.godMode then return end
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			applyGodStats()
			updateHealthBar(true)
		end))

		-- อัปเดตสถานะเมื่อกดปุ่มใน UI
		local godClickConn = ui.godModeBtn.MouseButton1Click:Connect(function()
			if not isActive then return end
			if state.godMode then
				applyGodStats()
			else
				syncForceField()
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
				humanoid.MaxHealth = 100
				humanoid.Health = math.min(humanoid.Health, 100)
			end
			updateHealthBar(false)
		end)
		table.insert(connections, godClickConn)

		table.insert(connections, character.AncestryChanged:Connect(function(_, parent)
			if not parent then cleanup() end
		end))
		table.insert(connections, character.Destroying:Connect(cleanup))

		-- ลูปกันตกแมพ + บันทึกจุดปลอดภัยล่าสุด
		task.spawn(function()
			while isActive and character.Parent and humanoid.Parent and root.Parent do
				if state.antiVoid and root.Position.Y < CONFIG.VOID_Y then
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
					root.CFrame = safeCFrame
					if state.godMode then
						applyGodStats()
					end
					updateHealthBar(true)
				elseif humanoid.FloorMaterial ~= Enum.Material.Air and root.AssemblyLinearVelocity.Magnitude < 25 then
					safeCFrame = root.CFrame + CONFIG.SAFE_OFFSET
				end
				task.wait(0.2)
			end
		end)
	end

	-- เชื่อมปุ่ม UI หลักของ Player
	ui.godModeBtn.MouseButton1Click:Connect(function()
		state.godMode = not state.godMode
		updateToggleVisual(ui.godModeBtn, state.godMode)
	end)

	ui.antiVoidBtn.MouseButton1Click:Connect(function()
		state.antiVoid = not state.antiVoid
		updateToggleVisual(ui.antiVoidBtn, state.antiVoid)
	end)

	ui.safeTpBtn.MouseButton1Click:Connect(function()
		if currentRoot and currentRoot.Parent and safeCFrame then
			currentRoot.AssemblyLinearVelocity = Vector3.zero
			currentRoot.AssemblyAngularVelocity = Vector3.zero
			currentRoot.CFrame = safeCFrame
		end
	end)

	player.CharacterAdded:Connect(bindCharacter)
	if player.Character then
		task.spawn(bindCharacter, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end
