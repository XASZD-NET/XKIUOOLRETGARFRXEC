-- Obby Helper UI (Tier 1 - Tier 18) - Full Combined Edition
-- วางโค้ดนี้ไว้ใน LocalScript (เช่น StarterPlayerScripts หรือ StarterGui ใน Roblox Studio)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- 1. ข้อมูลเทคนิค Obby ตั้งแต่ Tier 1 - Tier 18
-- ==========================================
local TierTechniques = {
	[1] = {
		name = "Tier 1: Side Ladder Climb (ปีนบันไดข้างๆ)",
		desc = "ฝึกจับจังหวะเดินเฉียงเข้าบันไดด้านข้างแล้วกดกระโดดสลับทิศ เพื่อลดเวลาและไม่ติดขอบบน",
		assistType = "LadderAssist",
		targetStuds = 6,
		jumpBoost = 50,
		walkSpeed = 16,
		gravity = 196.2
	},
	[2] = {
		name = "Tier 2: 2-Studs Block Climb (ปีนบล็อกหนา 2 studs)",
		desc = "กระโดดเข้าหาขอบบล็อกหนา 2 studs ให้ชิดที่สุดแล้วกดกระโดดจังหวะต่อเนื่องเพื่อดึงตัวขึ้นบน",
		assistType = "EdgeAlign",
		targetStuds = 2,
		jumpBoost = 50,
		walkSpeed = 16,
		gravity = 196.2
	},
	[3] = {
		name = "Tier 3: 1. Wall hop & 2. Horizontal wall hop",
		desc = "กระโดดฟลิคกำแพงทั้งแบบปกติและแนวนอน (Horizontal wall hop ไม่ใช่ Wall flick)",
		assistType = "WallHopAssist",
		targetStuds = 8,
		jumpBoost = 52,
		walkSpeed = 17,
		gravity = 196.2
	},
	[4] = {
		name = "Tier 4: /e dance2 Glitch (บัค /e dance2)",
		desc = "ใช้คำสั่ง /e dance2 เพื่อปรับตำแหน่งหรือท่าทางตัวละครในจุดอับหรือช่องแคบเฉพาะจุด",
		assistType = "EmoteTrigger",
		targetStuds = 4,
		jumpBoost = 50,
		walkSpeed = 16,
		gravity = 196.2
	},
	[5] = {
		name = "Tier 5: 3. Vertical wall hop (Wall hop แนวตั้ง)",
		desc = "ไต่กำแพงในแนวตั้งขึ้นไปด้านบน รักษาจังหวะกระโดดและมุมกล้องให้ต่อเนื่อง",
		assistType = "VerticalHop",
		targetStuds = 10,
		jumpBoost = 53,
		walkSpeed = 17,
		gravity = 196.2
	},
	[6] = {
		name = "Tier 6: Ladder Flick Easy (ไรเดอร์ฟลิคแบบง่าย)",
		desc = "ปีนบันไดหันหน้าจอไปซ้ายหรือขวา (ห้ามหันหน้า/หลังตรง) กด Shift Lock แล้วกระโดดทันทีพร้อมฟลิค",
		assistType = "FlickGuide",
		targetStuds = 10,
		jumpBoost = 52,
		walkSpeed = 18,
		gravity = 196.2
	},
	[7] = {
		name = "Tier 7: 13 Studs Jump (กระโดด 13 studs)",
		desc = "ทำบนพื้นที่หนา 1 stud โรยตัวไปเกาะขอบให้ชิดด้านในที่สุดก่อนออกตัวกระโดดระยะไกล 13 studs",
		assistType = "DistanceMarker",
		targetStuds = 13,
		jumpBoost = 54,
		walkSpeed = 18,
		gravity = 196.2
	},
	[8] = {
		name = "Tier 8: 4. Low ceiling wall hop (เพดานต่ำ)",
		desc = "Wall hop ในพื้นที่เพดานต่ำ ต้องทำจังหวะให้ถี่ขึ้นเพื่อไม่ให้ติดเพดานจนเสียจังหวะ",
		assistType = "LowCeilingHop",
		targetStuds = 6,
		jumpBoost = 50,
		walkSpeed = 18,
		gravity = 196.2
	},
	[9] = {
		name = "Tier 9: 5. Wall hop stick out (มี wrap ยื่นคั่นกลาง)",
		desc = "ทำ Wall hop ต่อเนื่องโดยมีส่วนยื่นหรือ wrap คั่นกลางระหว่างแนวกําแพง",
		assistType = "StickOutHop",
		targetStuds = 9,
		jumpBoost = 53,
		walkSpeed = 18,
		gravity = 196.2
	},
	[10] = {
		name = "Tier 10: 6. Wall flick (ไม่กระโดด / รีเซ็ตแรงโน้มถ่วง)",
		desc = "คล้าย Wall hop แต่ไม่กระโดด ใช้ช่วยรีเซ็ตแรงโน้มถ่วงให้ตกช้าลงเมื่อถึงจุดหนึ่ง",
		assistType = "WallFlickReset",
		targetStuds = 11,
		jumpBoost = 50,
		walkSpeed = 18,
		gravity = 145.0
	},
	[11] = {
		name = "Tier 11: Ladder flick head hitter (2 Studs)",
		desc = "ใช้เพดาน/ขอบระยะ 2 studs กระแทกศีรษะช่วยจัดจังหวะขณะทำ Ladder flick ให้แม่นยำขึ้น",
		assistType = "HeadHitter",
		targetStuds = 2,
		jumpBoost = 52,
		walkSpeed = 18,
		gravity = 196.2
	},
	[12] = {
		name = "Tier 12: 7. Wall walk (สูตรปรับ 30 FPS)",
		desc = "ฟลิครัวๆ พร้อมเดินไปตามกำแพง (แนะนำซ้อมจังหวะที่ 30 FPS ตามหลักสูตรในคลิป)",
		assistType = "WallWalk30FPS",
		targetStuds = 12,
		jumpBoost = 50,
		walkSpeed = 19,
		gravity = 196.2
	},
	[13] = {
		name = "Tier 13: Freeze jump / 13.5 studs (ไม่ควรเกิน 14 studs)",
		desc = "เดินไปกำแพงที่จะทำบัค (ความสูงไม่ควรเกิน 14 studs) เพื่อโดดสูงหรือข้ามระยะ 13.5 studs",
		assistType = "HighJumpPractice",
		targetStuds = 13.5,
		jumpBoost = 62,
		walkSpeed = 18,
		gravity = 165.0
	},
	[14] = {
		name = "Tier 14: Tight Gap Squeeze (บัคมุดที่แคบ)",
		desc = "เดินเข้าชิดกำแพง เปิด Shift Lock แล้วขยับตรงขอบพร้อมกดกระโดดเพื่อแทรกตัวผ่านช่องแคบ",
		assistType = "ShiftLockHelper",
		targetStuds = 1.5,
		jumpBoost = 50,
		walkSpeed = 16,
		gravity = 196.2
	},
	[15] = {
		name = "Tier 15: Fling Glitch Mechanic (หลักการทำบัค Fling)",
		desc = "ใช้บล็อกยืนร่วมกับบล็อกกดหัวหรือพื้นที่จำกัดเพื่อสร้างแรงส่งตัวพุ่งไกลแบบควบคุมทิศทาง",
		assistType = "MomentumWatch",
		targetStuds = 16,
		jumpBoost = 65,
		walkSpeed = 19,
		gravity = 196.2
	},
	[16] = {
		name = "Tier 16: Wall flick + Wall hop Combo",
		desc = "สลับระหว่าง Wall flick รีเซ็ตการตก กับ Wall hop ไต่กำแพงในจังหวะเดียว",
		assistType = "ComboAssist",
		targetStuds = 14,
		jumpBoost = 54,
		walkSpeed = 19,
		gravity = 160.0
	},
	[17] = {
		name = "Tier 17: Ultra Wraparound & Flick Chain",
		desc = "ผสาน Warparound การอ้อมเสา และการฟลิคต่อเนื่องแบบไม่เสียโมเมนตัม",
		assistType = "CameraGuide",
		targetStuds = 15,
		jumpBoost = 56,
		walkSpeed = 20,
		gravity = 180.0
	},
	[18] = {
		name = "Tier 18: Master Obby Gauntlet (ครบทุกเทคนิค)",
		desc = "รวมทุกเทคนิคตั้งแต่ Tier 1-17 ทั้ง Wall hop, Wall flick, Wall walk, Head hitter และ 13.5+ studs",
		assistType = "MasterAssist",
		targetStuds = 15,
		jumpBoost = 60,
		walkSpeed = 21,
		gravity = 175.0
	}
}

-- ==========================================
-- 2. สถานะของระบบช่วยเล่น (State)
-- ==========================================
local State = {
	MenuOpen = true,
	CurrentTier = 1,
	AssistEnabled = true,
	CustomSpeed = 16,
	CustomJump = 50,
	CustomGravity = 196.2,
	SavedCFrame = nil
}

if playerGui:FindFirstChild("ObbyTierHelperGui") then
	playerGui.ObbyTierHelperGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ObbyTierHelperGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ==========================================
-- 3. วงกลมลายน้ำลากได้ (Draggable Circle Watermark)
-- ==========================================
local watermarkBtn = Instance.new("TextButton")
watermarkBtn.Name = "WatermarkCircle"
watermarkBtn.Size = UDim2.new(0, 62, 0, 62)
watermarkBtn.Position = UDim2.new(0, 18, 0.35, 0)
watermarkBtn.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
watermarkBtn.BackgroundTransparency = 0.1
watermarkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
watermarkBtn.Font = Enum.Font.GothamBold
watermarkBtn.TextSize = 11
watermarkBtn.Text = "OBBY\nT1-18"
watermarkBtn.ZIndex = 20
watermarkBtn.Parent = screenGui
Instance.new("UICorner", watermarkBtn).CornerRadius = UDim.new(1, 0)

local watermarkStroke = Instance.new("UIStroke")
watermarkStroke.Color = Color3.fromRGB(0, 210, 255)
watermarkStroke.Thickness = 2
watermarkStroke.Parent = watermarkBtn

local function makeDraggable(guiObject, onClickCallback)
	local dragging = false
	local dragInput = nil
	local dragStart = Vector2.zero
	local startPos = UDim2.new()
	local moved = 0

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = 0
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if moved < 8 and onClickCallback then
						onClickCallback()
					end
				end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			moved = math.max(moved, delta.Magnitude)
			guiObject.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ==========================================
-- 4. หน้าต่างหลักตามผัง UI
-- ==========================================
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 420, 0, 325)
mainWindow.Position = UDim2.new(0.5, -210, 0.5, -162)
mainWindow.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
mainWindow.BorderSizePixel = 0
mainWindow.ZIndex = 10
mainWindow.Parent = screenGui
Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(70, 82, 110)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainWindow

-- แถบ 1: [========··][400]
local topBar1 = Instance.new("Frame")
topBar1.Size = UDim2.new(1, -20, 0, 30)
topBar1.Position = UDim2.new(0, 10, 0, 8)
topBar1.BackgroundTransparency = 1
topBar1.Parent = mainWindow

local tierBadge = Instance.new("TextLabel")
tierBadge.Size = UDim2.new(0.72, -6, 1, 0)
tierBadge.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
tierBadge.TextColor3 = Color3.fromRGB(120, 220, 255)
tierBadge.Font = Enum.Font.GothamBold
tierBadge.TextSize = 12
tierBadge.Text = "[========··] Tier 1 / 18"
tierBadge.Parent = topBar1
Instance.new("UICorner", tierBadge).CornerRadius = UDim.new(0, 6)

local speedStatBox = Instance.new("TextButton")
speedStatBox.Size = UDim2.new(0.28, 0, 1, 0)
speedStatBox.Position = UDim2.new(0.72, 0, 0, 0)
speedStatBox.BackgroundColor3 = Color3.fromRGB(38, 45, 62)
speedStatBox.TextColor3 = Color3.fromRGB(255, 225, 110)
speedStatBox.Font = Enum.Font.GothamBold
speedStatBox.TextSize = 12
speedStatBox.Text = "[400]"
speedStatBox.Parent = topBar1
Instance.new("UICorner", speedStatBox).CornerRadius = UDim.new(0, 6)

-- สไลเดอร์ 1: -----------·----↓
local slider1Frame = Instance.new("Frame")
slider1Frame.Size = UDim2.new(1, -20, 0, 22)
slider1Frame.Position = UDim2.new(0, 10, 0, 42)
slider1Frame.BackgroundTransparency = 1
slider1Frame.Parent = mainWindow

local line1 = Instance.new("Frame")
line1.Size = UDim2.new(1, -32, 0, 3)
line1.Position = UDim2.new(0, 4, 0.5, -1)
line1.BackgroundColor3 = Color3.fromRGB(95, 108, 138)
line1.BorderSizePixel = 0
line1.Parent = slider1Frame

local knob1 = Instance.new("TextButton")
knob1.Size = UDim2.new(0, 14, 0, 14)
knob1.Position = UDim2.new(0, 0, 0.5, -7)
knob1.BackgroundColor3 = Color3.fromRGB(0, 210, 255)
knob1.Text = ""
knob1.Parent = slider1Frame
Instance.new("UICorner", knob1).CornerRadius = UDim.new(1, 0)

local arrow1Btn = Instance.new("TextButton")
arrow1Btn.Size = UDim2.new(0, 22, 0, 22)
arrow1Btn.Position = UDim2.new(1, -22, 0, 0)
arrow1Btn.BackgroundColor3 = Color3.fromRGB(35, 42, 58)
arrow1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
arrow1Btn.Font = Enum.Font.GothamBold
arrow1Btn.TextSize = 13
arrow1Btn.Text = "↓"
arrow1Btn.Parent = slider1Frame
Instance.new("UICorner", arrow1Btn).CornerRadius = UDim.new(0, 6)

-- แถบ 2: [========··][=]
local topBar2 = Instance.new("Frame")
topBar2.Size = UDim2.new(1, -20, 0, 28)
topBar2.Position = UDim2.new(0, 10, 0, 68)
topBar2.BackgroundTransparency = 1
topBar2.Parent = mainWindow

local modeStatusLabel = Instance.new("TextLabel")
modeStatusLabel.Size = UDim2.new(0.78, -6, 1, 0)
modeStatusLabel.BackgroundColor3 = Color3.fromRGB(28, 33, 45)
modeStatusLabel.TextColor3 = Color3.fromRGB(160, 255, 175)
modeStatusLabel.Font = Enum.Font.GothamSemibold
modeStatusLabel.TextSize = 11
modeStatusLabel.Text = "[========··] Assist: ON"
modeStatusLabel.Parent = topBar2
Instance.new("UICorner", modeStatusLabel).CornerRadius = UDim.new(0, 6)

local toggleSwitchBtn = Instance.new("TextButton")
toggleSwitchBtn.Size = UDim2.new(0.22, 0, 1, 0)
toggleSwitchBtn.Position = UDim2.new(0.78, 0, 0, 0)
toggleSwitchBtn.BackgroundColor3 = Color3.fromRGB(45, 130, 95)
toggleSwitchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleSwitchBtn.Font = Enum.Font.GothamBold
toggleSwitchBtn.TextSize = 12
toggleSwitchBtn.Text = "[=]"
toggleSwitchBtn.Parent = topBar2
Instance.new("UICorner", toggleSwitchBtn).CornerRadius = UDim.new(0, 6)

-- สไลเดอร์ 2: -----------·----↓
local slider2Frame = Instance.new("Frame")
slider2Frame.Size = UDim2.new(1, -20, 0, 22)
slider2Frame.Position = UDim2.new(0, 10, 0, 100)
slider2Frame.BackgroundTransparency = 1
slider2Frame.Parent = mainWindow

local line2 = Instance.new("Frame")
line2.Size = UDim2.new(1, -32, 0, 3)
line2.Position = UDim2.new(0, 4, 0.5, -1)
line2.BackgroundColor3 = Color3.fromRGB(95, 108, 138)
line2.BorderSizePixel = 0
line2.Parent = slider2Frame

local knob2 = Instance.new("TextButton")
knob2.Size = UDim2.new(0, 14, 0, 14)
knob2.Position = UDim2.new(0.35, 0, 0.5, -7)
knob2.BackgroundColor3 = Color3.fromRGB(255, 200, 70)
knob2.Text = ""
knob2.Parent = slider2Frame
Instance.new("UICorner", knob2).CornerRadius = UDim.new(1, 0)

local arrow2Btn = Instance.new("TextButton")
arrow2Btn.Size = UDim2.new(0, 22, 0, 22)
arrow2Btn.Position = UDim2.new(1, -22, 0, 0)
arrow2Btn.BackgroundColor3 = Color3.fromRGB(35, 42, 58)
arrow2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
arrow2Btn.Font = Enum.Font.GothamBold
arrow2Btn.TextSize = 13
arrow2Btn.Text = "↓"
arrow2Btn.Parent = slider2Frame
Instance.new("UICorner", arrow2Btn).CornerRadius = UDim.new(0, 6)

-- กรอบเนื้อหา: ______________________. | ... | ——————————————·
local contentBox = Instance.new("Frame")
contentBox.Size = UDim2.new(1, -20, 0, 188)
contentBox.Position = UDim2.new(0, 10, 0, 128)
contentBox.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
contentBox.BorderSizePixel = 0
contentBox.Parent = mainWindow
Instance.new("UICorner", contentBox).CornerRadius = UDim.new(0, 10)
local contentStroke = Instance.new("UIStroke", contentBox)
contentStroke.Color = Color3.fromRGB(60, 72, 96)
contentStroke.Thickness = 1

local techTitleLabel = Instance.new("TextLabel")
techTitleLabel.Size = UDim2.new(1, -16, 0, 22)
techTitleLabel.Position = UDim2.new(0, 8, 0, 6)
techTitleLabel.BackgroundTransparency = 1
techTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
techTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
techTitleLabel.Font = Enum.Font.GothamBold
techTitleLabel.TextSize = 12
techTitleLabel.Text = ""
techTitleLabel.Parent = contentBox

local techDescLabel = Instance.new("TextLabel")
techDescLabel.Size = UDim2.new(1, -16, 0, 48)
techDescLabel.Position = UDim2.new(0, 8, 0, 28)
techDescLabel.BackgroundTransparency = 1
techDescLabel.TextWrapped = true
techDescLabel.TextXAlignment = Enum.TextXAlignment.Left
techDescLabel.TextYAlignment = Enum.TextYAlignment.Top
techDescLabel.TextColor3 = Color3.fromRGB(205, 214, 232)
techDescLabel.Font = Enum.Font.Gotham
techDescLabel.TextSize = 11
techDescLabel.Text = ""
techDescLabel.Parent = contentBox

-- เกจ: =====================·||←[300]
local meterRow = Instance.new("Frame")
meterRow.Size = UDim2.new(1, -16, 0, 24)
meterRow.Position = UDim2.new(0, 8, 0, 80)
meterRow.BackgroundTransparency = 1
meterRow.Parent = contentBox

local meterTrack = Instance.new("Frame")
meterTrack.Size = UDim2.new(0.72, -6, 0, 10)
meterTrack.Position = UDim2.new(0, 0, 0.5, -5)
meterTrack.BackgroundColor3 = Color3.fromRGB(45, 52, 70)
meterTrack.Parent = meterRow
Instance.new("UICorner", meterTrack).CornerRadius = UDim.new(1, 0)

local meterFill = Instance.new("Frame")
meterFill.Size = UDim2.new(0.45, 0, 1, 0)
meterFill.BackgroundColor3 = Color3.fromRGB(0, 210, 255)
meterFill.Parent = meterTrack
Instance.new("UICorner", meterFill).CornerRadius = UDim.new(1, 0)

local meterValueBtn = Instance.new("TextButton")
meterValueBtn.Size = UDim2.new(0.28, 0, 1, 0)
meterValueBtn.Position = UDim2.new(0.72, 0, 0, 0)
meterValueBtn.BackgroundColor3 = Color3.fromRGB(36, 44, 62)
meterValueBtn.TextColor3 = Color3.fromRGB(130, 245, 255)
meterValueBtn.Font = Enum.Font.GothamBold
meterValueBtn.TextSize = 11
meterValueBtn.Text = "||←[300]"
meterValueBtn.Parent = meterRow
Instance.new("UICorner", meterValueBtn).CornerRadius = UDim.new(0, 6)

-- แถวปุ่มเปลี่ยน Tier และเปิดใช้
local actionRow = Instance.new("Frame")
actionRow.Size = UDim2.new(1, -16, 0, 34)
actionRow.Position = UDim2.new(0, 8, 0, 110)
actionRow.BackgroundTransparency = 1
actionRow.Parent = contentBox

local prevTierBtn = Instance.new("TextButton")
prevTierBtn.Size = UDim2.new(0.22, -4, 1, 0)
prevTierBtn.Position = UDim2.new(0, 0, 0, 0)
prevTierBtn.BackgroundColor3 = Color3.fromRGB(38, 45, 62)
prevTierBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
prevTierBtn.Font = Enum.Font.GothamBold
prevTierBtn.TextSize = 11
prevTierBtn.Text = "< Tier"
prevTierBtn.Parent = actionRow
Instance.new("UICorner", prevTierBtn).CornerRadius = UDim.new(0, 6)

local practiceBtn = Instance.new("TextButton")
practiceBtn.Size = UDim2.new(0.54, -4, 1, 0)
practiceBtn.Position = UDim2.new(0.22, 2, 0, 0)
practiceBtn.BackgroundColor3 = Color3.fromRGB(32, 95, 145)
practiceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
practiceBtn.Font = Enum.Font.GothamBold
practiceBtn.TextSize = 11
practiceBtn.Text = "ใช้ค่าช่วยของ Tier นี้"
practiceBtn.Parent = actionRow
Instance.new("UICorner", practiceBtn).CornerRadius = UDim.new(0, 6)

local nextTierBtn = Instance.new("TextButton")
nextTierBtn.Size = UDim2.new(0.24, 0, 1, 0)
nextTierBtn.Position = UDim2.new(0.76, 0, 0, 0)
nextTierBtn.BackgroundColor3 = Color3.fromRGB(38, 45, 62)
nextTierBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nextTierBtn.Font = Enum.Font.GothamBold
nextTierBtn.TextSize = 11
nextTierBtn.Text = "Tier >"
nextTierBtn.Parent = actionRow
Instance.new("UICorner", nextTierBtn).CornerRadius = UDim.new(0, 6)

-- แถวปุ่มเซฟจุดฝึกซ้อม (Checkpoint)
local cpRow = Instance.new("Frame")
cpRow.Size = UDim2.new(1, -16, 0, 30)
cpRow.Position = UDim2.new(0, 8, 0, 150)
cpRow.BackgroundTransparency = 1
cpRow.Parent = contentBox

local savePosBtn = Instance.new("TextButton")
savePosBtn.Size = UDim2.new(0.49, 0, 1, 0)
savePosBtn.Position = UDim2.new(0, 0, 0, 0)
savePosBtn.BackgroundColor3 = Color3.fromRGB(48, 65, 92)
savePosBtn.TextColor3 = Color3.fromRGB(220, 238, 255)
savePosBtn.Font = Enum.Font.GothamBold
savePosBtn.TextSize = 11
savePosBtn.Text = "เซฟจุดซ้อม (Save Pos)"
savePosBtn.Parent = cpRow
Instance.new("UICorner", savePosBtn).CornerRadius = UDim.new(0, 6)

local loadPosBtn = Instance.new("TextButton")
loadPosBtn.Size = UDim2.new(0.49, 0, 1, 0)
loadPosBtn.Position = UDim2.new(0.51, 0, 0, 0)
loadPosBtn.BackgroundColor3 = Color3.fromRGB(45, 85, 75)
loadPosBtn.TextColor3 = Color3.fromRGB(220, 255, 235)
loadPosBtn.Font = Enum.Font.GothamBold
loadPosBtn.TextSize = 11
loadPosBtn.Text = "กลับจุดซ้อม (Load Pos)"
loadPosBtn.Parent = cpRow
Instance.new("UICorner", loadPosBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- 5. อัปเดตสถานะและตัวละคร
-- ==========================================
local function applyCharacterAssist()
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if State.AssistEnabled then
		humanoid.WalkSpeed = State.CustomSpeed
		humanoid.UseJumpPower = true
		humanoid.JumpPower = State.CustomJump
		workspace.Gravity = State.CustomGravity
	else
		humanoid.WalkSpeed = 16
		humanoid.UseJumpPower = true
		humanoid.JumpPower = 50
		workspace.Gravity = 196.2
	end
end

local function refreshUI()
	local tierData = TierTechniques[State.CurrentTier] or TierTechniques[1]
	tierBadge.Text = string.format("[========··] Tier %d / 18", State.CurrentTier)
	techTitleLabel.Text = tierData.name
	techDescLabel.Text = tierData.desc

	local tierRatio = (State.CurrentTier - 1) / 17
	knob1.Position = UDim2.new(tierRatio * 0.85, 0, 0.5, -7)

	local meterVal = math.clamp(math.floor((State.CustomJump - 40) * 10), 100, 500)
	speedStatBox.Text = string.format("[%d]", math.floor(State.CustomSpeed * 25))
	meterValueBtn.Text = string.format("||←[%d]", meterVal)
	meterFill.Size = UDim2.new(math.clamp((meterVal - 100) / 400, 0.08, 1), 0, 1, 0)

	if State.AssistEnabled then
		toggleSwitchBtn.BackgroundColor3 = Color3.fromRGB(45, 130, 95)
		toggleSwitchBtn.Text = "[=]"
		modeStatusLabel.TextColor3 = Color3.fromRGB(160, 255, 175)
		modeStatusLabel.Text = string.format("[========··] %s | %.1f studs", tierData.assistType, tierData.targetStuds)
	else
		toggleSwitchBtn.BackgroundColor3 = Color3.fromRGB(125, 45, 55)
		toggleSwitchBtn.Text = "[OFF]"
		modeStatusLabel.TextColor3 = Color3.fromRGB(255, 155, 165)
		modeStatusLabel.Text = "[========··] Assist: OFF"
	end

	local jumpRatio = math.clamp((State.CustomJump - 45) / 35, 0, 1)
	knob2.Position = UDim2.new(jumpRatio * 0.85, 0, 0.5, -7)
end

local function selectTier(newTier)
	State.CurrentTier = math.clamp(newTier, 1, 18)
	local data = TierTechniques[State.CurrentTier]
	State.CustomJump = data.jumpBoost
	State.CustomSpeed = data.walkSpeed
	State.CustomGravity = data.gravity
	applyCharacterAssist()
	refreshUI()
end

-- ==========================================
-- 6. การควบคุมปุ่มและสไลเดอร์
-- ==========================================
local function toggleMainWindow()
	State.MenuOpen = not State.MenuOpen
	mainWindow.Visible = State.MenuOpen
	watermarkStroke.Color = State.MenuOpen and Color3.fromRGB(0, 210, 255) or Color3.fromRGB(255, 180, 60)
end

makeDraggable(watermarkBtn, toggleMainWindow)
makeDraggable(mainWindow, nil)

toggleSwitchBtn.MouseButton1Click:Connect(function()
	State.AssistEnabled = not State.AssistEnabled
	applyCharacterAssist()
	refreshUI()
end)

prevTierBtn.MouseButton1Click:Connect(function()
	selectTier(State.CurrentTier - 1)
end)

nextTierBtn.MouseButton1Click:Connect(function()
	selectTier(State.CurrentTier + 1)
end)

arrow1Btn.MouseButton1Click:Connect(function()
	selectTier(State.CurrentTier + 1)
end)

arrow2Btn.MouseButton1Click:Connect(function()
	State.CustomJump = math.clamp(State.CustomJump + 2, 45, 85)
	applyCharacterAssist()
	refreshUI()
end)

speedStatBox.MouseButton1Click:Connect(function()
	State.CustomSpeed = (State.CustomSpeed >= 24) and 16 or (State.CustomSpeed + 2)
	applyCharacterAssist()
	refreshUI()
end)

meterValueBtn.MouseButton1Click:Connect(function()
	local data = TierTechniques[State.CurrentTier]
	State.CustomJump = data.jumpBoost
	State.CustomSpeed = data.walkSpeed
	State.CustomGravity = data.gravity
	applyCharacterAssist()
	refreshUI()
end)

practiceBtn.MouseButton1Click:Connect(function()
	State.AssistEnabled = true
	selectTier(State.CurrentTier)
	practiceBtn.Text = "กำลังใช้ Tier " .. State.CurrentTier .. "!"
	task.delay(1.2, function()
		practiceBtn.Text = "ใช้ค่าช่วยของ Tier นี้"
	end)
end)

savePosBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		State.SavedCFrame = root.CFrame
		savePosBtn.Text = "บันทึกจุดแล้ว!"
		task.delay(1.0, function()
			savePosBtn.Text = "เซฟจุดซ้อม (Save Pos)"
		end)
	end
end)

loadPosBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root and State.SavedCFrame then
		root.AssemblyLinearVelocity = Vector3.zero
		root.CFrame = State.SavedCFrame
	end
end)

local draggingSlider1 = false
knob1.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingSlider1 = true
	end
end)

local draggingSlider2 = false
knob2.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingSlider2 = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingSlider1 = false
		draggingSlider2 = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if draggingSlider1 then
			local relX = math.clamp((input.Position.X - line1.AbsolutePosition.X) / math.max(line1.AbsoluteSize.X, 1), 0, 1)
			local chosenTier = math.floor(relX * 17 + 0.5) + 1
			if chosenTier ~= State.CurrentTier then
				selectTier(chosenTier)
			end
		elseif draggingSlider2 then
			local relX = math.clamp((input.Position.X - line2.AbsolutePosition.X) / math.max(line2.AbsoluteSize.X, 1), 0, 1)
			State.CustomJump = math.floor(45 + relX * 35)
			applyCharacterAssist()
			refreshUI()
		end
	end
end)

player.CharacterAdded:Connect(function()
	task.wait(0.25)
	applyCharacterAssist()
end)

selectTier(1)
