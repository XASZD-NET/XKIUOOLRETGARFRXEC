-- =========================================================================
-- ชื่อไฟล์: GodMode_PurpleBlack_UI_All_In_One.lua
-- ตำแหน่งติดตั้ง: ServerScriptService (Script เดียวจบ ครบทั้งระบบ + UI)
-- รายละเอียด:
--   1. ระบบอมตะ เลือดสูงสุด 9,000,000 + กันดาเมจทุกชนิด + กันตกแมพ (Anti-Void)
--   2. หน้าต่าง UI โทนดำ-ม่วง (Purple-Black) ตัวหนังสือสีขาวล้วน คมชัด
--   3. ลากย้ายได้ทั้งหน้าต่างหลักและปุ่มลอย มีปุ่มย่อ/ขยาย, ตั้งจุดปลอดภัยใหม่
--      และวาร์ปกลับจุดปลอดภัยด้วยตัวเอง พร้อมแสดงข้อมูลตำแหน่งและสถานะละเอียด
-- =========================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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
		TextSub = Color3.fromRGB(205, 185, 240),     -- สีตัวหนังสือรายละเอียดรอง
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

local function formatPos(cf)
	if not cf then return "0, 0, 0" end
	local p = cf.Position
	return string.format("%d, %d, %d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z))
end

-- ตัวช่วยลาก UI ที่รองรับทั้งทัชสกรีนและเมาส์ พร้อมแยกการคลิก
local function attachDrag(targetGui, handleGui, onReleaseMoved)
	local dragging = false
	local activeInput = nil
	local dragStart = Vector2.zero
	local startPos = targetGui.Position
	local moved = false

	handleGui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			activeInput = input
			dragStart = input.Position
			startPos = targetGui.Position
			moved = false

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End and activeInput == input then
					dragging = false
					activeInput = nil
					if onReleaseMoved then
						onReleaseMoved(moved)
					end
				end
			end)
		end
	end)

	handleGui.InputChanged:Connect(function(input)
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
			targetGui.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
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

	-- ปุ่มลอยวงกลม (ลากได้ + แสดงตอนย่อหน้าต่าง UI เก็บไว้)
	local floatingBtn = Instance.new("TextButton")
	floatingBtn.Name = "FloatingOpenButton"
	floatingBtn.Size = UDim2.new(0, 50, 0, 50)
	floatingBtn.Position = UDim2.new(0, 16, 0, 24)
	floatingBtn.BackgroundColor3 = CONFIG.THEME.BgDark
	floatingBtn.Text = "GOD"
	floatingBtn.Font = Enum.Font.GothamBlack
	floatingBtn.TextSize = 13
	floatingBtn.TextColor3 = CONFIG.THEME.TextWhite
	floatingBtn.Visible = false
	floatingBtn.AutoButtonColor = true
	floatingBtn.Active = true
	floatingBtn.Parent = screenGui
	Instance.new("UICorner", floatingBtn).CornerRadius = UDim.new(1, 0)

	local floatStroke = Instance.new("UIStroke")
	floatStroke.Color = CONFIG.THEME.PurpleBorder
	floatStroke.Thickness = 2
	floatStroke.Parent = floatingBtn

	-- หน้าต่างหลัก (Main Window)
	local mainWindow = Instance.new("Frame")
	mainWindow.Name = "MainWindow"
	mainWindow.Size = UDim2.new(0, 330, 0, 326)
	mainWindow.Position = UDim2.new(0, 16, 0, 24)
	mainWindow.BackgroundColor3 = CONFIG.THEME.BgDark
	mainWindow.BorderSizePixel = 0
	mainWindow.ClipsDescendants = true
	mainWindow.Active = true
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

	-- แถบหัวข้อด้านบน (Top Header - ลากย้ายหน้าต่างได้)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundColor3 = CONFIG.THEME.BgHeader
	header.BorderSizePixel = 0
	header.Active = true
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
	titleLabel.Text = "GOD MODE • PURPLE PANEL PRO"
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

	-- กล่องแสดงแถบพลังชีวิตและรายละเอียดพิกัด (Health & Telemetry Card)
	local hpCard = Instance.new("Frame")
	hpCard.Name = "HealthCard"
	hpCard.Size = UDim2.new(1, 0, 0, 84)
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
	hpHeaderText.Position = UDim2.new(0, 10, 0, 5)
	hpHeaderText.Size = UDim2.new(0.55, 0, 0, 16)
	hpHeaderText.Font = Enum.Font.GothamBold
	hpHeaderText.TextSize = 11
	hpHeaderText.TextXAlignment = Enum.TextXAlignment.Left
	hpHeaderText.TextColor3 = CONFIG.THEME.TextWhite
	hpHeaderText.Text = "HEALTH & SHIELD STATUS"
	hpHeaderText.Parent = hpCard

	local hpPercentText = Instance.new("TextLabel")
	hpPercentText.Name = "PercentLabel"
	hpPercentText.BackgroundTransparency = 1
	hpPercentText.Position = UDim2.new(0.55, 0, 0, 5)
	hpPercentText.Size = UDim2.new(0.45, -10, 0, 16)
	hpPercentText.Font = Enum.Font.GothamBold
	hpPercentText.TextSize = 11
	hpPercentText.TextXAlignment = Enum.TextXAlignment.Right
	hpPercentText.TextColor3 = CONFIG.THEME.TextWhite
	hpPercentText.Text = "100%"
	hpPercentText.Parent = hpCard

	local barBack = Instance.new("Frame")
	barBack.Name = "BarBack"
	barBack.Position = UDim2.new(0, 10, 0, 24)
	barBack.Size = UDim2.new(1, -20, 0, 28)
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
	hpValueLabel.TextSize = 12
	hpValueLabel.TextColor3 = CONFIG.THEME.TextWhite
	hpValueLabel.ZIndex = 3
	hpValueLabel.Text = formatNumber(CONFIG.MAX_HP) .. " / " .. formatNumber(CONFIG.MAX_HP)
	hpValueLabel.Parent = barBack

	local coordLabel = Instance.new("TextLabel")
	coordLabel.Name = "CoordLabel"
	coordLabel.BackgroundTransparency = 1
	coordLabel.Position = UDim2.new(0, 10, 0, 56)
	coordLabel.Size = UDim2.new(1, -20, 0, 20)
	coordLabel.Font = Enum.Font.Code
	coordLabel.TextSize = 10
	coordLabel.TextXAlignment = Enum.TextXAlignment.Left
	coordLabel.TextTruncate = Enum.TextTruncate.AtEnd
	coordLabel.TextColor3 = CONFIG.THEME.TextSub
	coordLabel.Text = "POS: 0, 0, 0 | SAFE: 0, 0, 0"
	coordLabel.Parent = hpCard

	-- ฟังก์ชันตัวช่วยสร้างแถวสวิตช์เปิด-ปิด (Toggle Row)
	local function createToggleRow(titleText, yPos, defaultState)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 40)
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
		lbl.TextSize = 12
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

	-- สวิตช์ควบคุมฟังก์ชัน
	local godModeBtn = createToggleRow("โหมดอมตะ (God Mode)", 92, true)
	local antiVoidBtn = createToggleRow("กันตกแมพ (Anti-Void)", 138, true)

	-- แถวปุ่มบันทึกจุดปลอดภัยใหม่ + วาร์ปกลับจุดปลอดภัย
	local setSafeBtn = Instance.new("TextButton")
	setSafeBtn.Name = "SetSafeButton"
	setSafeBtn.Size = UDim2.new(0.42, -4, 0, 38)
	setSafeBtn.Position = UDim2.new(0, 0, 0, 186)
	setSafeBtn.BackgroundColor3 = CONFIG.THEME.BgCard
	setSafeBtn.Font = Enum.Font.GothamBold
	setSafeBtn.TextSize = 12
	setSafeBtn.TextColor3 = CONFIG.THEME.TextWhite
	setSafeBtn.Text = "📍 ปักจุดปลอดภัย"
	setSafeBtn.Parent = content
	Instance.new("UICorner", setSafeBtn).CornerRadius = UDim.new(0, 10)
	local setSafeStroke = Instance.new("UIStroke", setSafeBtn)
	setSafeStroke.Color = CONFIG.THEME.PurpleBorder
	setSafeStroke.Thickness = 1

	local safeTpBtn = Instance.new("TextButton")
	safeTpBtn.Name = "SafeTeleportButton"
	safeTpBtn.Size = UDim2.new(0.58, -4, 0, 38)
	safeTpBtn.Position = UDim2.new(0.42, 4, 0, 186)
	safeTpBtn.BackgroundColor3 = CONFIG.THEME.PurpleMain
	safeTpBtn.Font = Enum.Font.GothamBlack
	safeTpBtn.TextSize = 12
	safeTpBtn.TextColor3 = CONFIG.THEME.TextWhite
	safeTpBtn.Text = "⚡ วาร์ปกลับจุดปลอดภัย"
	safeTpBtn.Parent = content
	Instance.new("UICorner", safeTpBtn).CornerRadius = UDim.new(0, 10)

	local tpGrad = Instance.new("UIGradient")
	tpGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, CONFIG.THEME.PurpleMain),
		ColorSequenceKeypoint.new(1, CONFIG.THEME.PurpleBright),
	})
	tpGrad.Parent = safeTpBtn

	-- ลากได้ทั้งหน้าต่างหลัก (ผ่าน Header) และปุ่มลอย
	attachDrag(mainWindow, header, nil)

	local floatWasDragged = false
	attachDrag(floatingBtn, floatingBtn, function(didMove)
		floatWasDragged = didMove
		task.delay(0.05, function()
			floatWasDragged = false
		end)
	end)

	-- ระบบย่อ/ขยายหน้าต่าง UI
	minimizeBtn.MouseButton1Click:Connect(function()
		floatingBtn.Position = mainWindow.Position
		mainWindow.Visible = false
		floatingBtn.Visible = true
	end)

	floatingBtn.MouseButton1Click:Connect(function()
		if not floatWasDragged then
			mainWindow.Position = floatingBtn.Position
			floatingBtn.Visible = false
			mainWindow.Visible = true
		end
	end)

	return {
		gui = screenGui,
		barFill = barFill,
		hpValueLabel = hpValueLabel,
		hpPercentText = hpPercentText,
		coordLabel = coordLabel,
		godModeBtn = godModeBtn,
		antiVoidBtn = antiVoidBtn,
		setSafeBtn = setSafeBtn,
		safeTpBtn = safeTpBtn,
	}
end

-- ==================== ระบบตัวละครและสถานะผู้เล่น ====================
local function onPlayerAdded(player)
	local ui = createPurpleBlackUI(player)

	local state = {
		godMode = true,
		antiVoid = true,
	}

	local currentCharacter = nil
	local currentHumanoid = nil
	local currentRoot = nil
	local safeCFrame = nil

	local function refreshCoords()
		if not ui or not ui.gui.Parent then return end
		local curStr = currentRoot and currentRoot.Parent and formatPos(currentRoot.CFrame) or "N/A"
		local safeStr = safeCFrame and formatPos(safeCFrame) or "N/A"
		ui.coordLabel.Text = "POS: " .. curStr .. " | SAFE: " .. safeStr
	end

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
		refreshCoords()

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

		if state.godMode then
			applyGodStats()
		end
		updateHealthBar(true)

		table.insert(connections, humanoid.HealthChanged:Connect(function(hp)
			if not isActive or isHealing then return end
			if state.godMode and hp < CONFIG.MAX_HP then
				applyGodStats()
			end
			updateHealthBar(false)
		end))

		table.insert(connections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
			if not isActive or isHealing then return end
			if state.godMode and humanoid.MaxHealth ~= CONFIG.MAX_HP then
				applyGodStats()
			end
			updateHealthBar(false)
		end))

		table.insert(connections, humanoid.Died:Connect(function()
			if not isActive or not state.godMode then return end
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			applyGodStats()
			updateHealthBar(true)
		end))

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

		-- ลูปกันตกแมพ + อัปเดตพิกัด + บันทึกจุดปลอดภัยอัตโนมัติเมื่อยืนพื้นนิ่ง
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
				refreshCoords()
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

	ui.setSafeBtn.MouseButton1Click:Connect(function()
		if currentRoot and currentRoot.Parent then
			safeCFrame = currentRoot.CFrame + CONFIG.SAFE_OFFSET
			refreshCoords()
		end
	end)

	ui.safeTpBtn.MouseButton1Click:Connect(function()
		if currentRoot and currentRoot.Parent and safeCFrame then
			currentRoot.AssemblyLinearVelocity = Vector3.zero
			currentRoot.AssemblyAngularVelocity = Vector3.zero
			currentRoot.CFrame = safeCFrame
			refreshCoords()
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
