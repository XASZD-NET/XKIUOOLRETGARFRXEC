-- Lua Script: Edit_code_fixed.lua (รองรับการพิมพ์/วางและรันโค้ด Lua / Luau ในช่องแก้ไขโค้ด)
-- Theme: Dark Purple | Text: White

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")

local function GetGuiParent()
	local ok = pcall(function()
		local testFolder = Instance.new("Folder")
		testFolder.Name = "_TestParent"
		testFolder.Parent = CoreGui
		testFolder:Destroy()
	end)
	if ok then
		return CoreGui
	end
	return PlayerGui
end

local GuiParent = GetGuiParent()
if GuiParent:FindFirstChild("LuaCodeEditorGUI") then
	GuiParent.LuaCodeEditorGUI:Destroy()
end

-- ระบบตัวแปรหลัก
local SavedList = {}
local SelectedSaveIndex = nil
local MaxSaveCount = 600
local AutoEnabled = false
local RunSpeed = 50
local TotalRuns = 0

-- ฟังก์ชันสร้างระบบลากที่เสถียรทั้งมือถือและเมาส์
local function MakeDraggable(targetFrame, dragHandle, onMovedCallback)
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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LuaCodeEditorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local okParent = pcall(function()
	ScreenGui.Parent = GuiParent
end)
if not okParent or not ScreenGui.Parent then
	ScreenGui.Parent = PlayerGui
end

-- ปุ่มวงกลมลอยข้างหน้าต่าง (หมุนช้าๆ + ลากได้ + กดเปิด/ปิดหน้าต่าง)
local CircleBtn = Instance.new("ImageButton")
CircleBtn.Name = "CircleToggle"
CircleBtn.Size = UDim2.new(0, 52, 0, 52)
CircleBtn.Position = UDim2.new(0.5, 165, 0.5, -210)
CircleBtn.BackgroundColor3 = Color3.fromRGB(24, 14, 42)
CircleBtn.Image = ""
CircleBtn.AutoButtonColor = true
CircleBtn.Active = true
CircleBtn.Parent = ScreenGui

Instance.new("UICorner", CircleBtn).CornerRadius = UDim.new(1, 0)
local CircleStroke = Instance.new("UIStroke", CircleBtn)
CircleStroke.Color = Color3.fromRGB(165, 65, 255)
CircleStroke.Thickness = 2.5

local CircleIcon = Instance.new("TextLabel")
CircleIcon.Size = UDim2.new(1, 0, 1, 0)
CircleIcon.BackgroundTransparency = 1
CircleIcon.Text = "☯"
CircleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
CircleIcon.Font = Enum.Font.GothamBold
CircleIcon.TextSize = 24
CircleIcon.Parent = CircleBtn

RunService.RenderStepped:Connect(function(dt)
	if CircleBtn and CircleBtn.Parent then
		CircleBtn.Rotation = (CircleBtn.Rotation + dt * 35) % 360
	end
end)

local circleWasDragged = false
MakeDraggable(CircleBtn, CircleBtn, function(didMove)
	circleWasDragged = didMove
	task.delay(0.05, function()
		circleWasDragged = false
	end)
end)

-- หน้าต่างหลัก (310 x 430)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainWindow"
MainFrame.Size = UDim2.new(0, 310, 0, 430)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -215)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 12, 24)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

CircleBtn.MouseButton1Click:Connect(function()
	if not circleWasDragged then
		MainFrame.Visible = not MainFrame.Visible
	end
end)

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(138, 43, 226)
MainStroke.Thickness = 2

-- แถบหัวหน้าต่าง (ลากย้ายหน้าต่างได้ทั้งแถบ)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 38)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 18, 46)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

MakeDraggable(MainFrame, TopBar, nil)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -54, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "⚡ LUA EDITOR PRO • LUAU"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 13
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(90, 25, 130)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- 1. ช่องแก้ไขโค้ด + ข้อมูลบรรทัด/ตัวอักษร + ปุ่มล้าง/คัดลอก + แถบสถานะ
local EditorFrame = Instance.new("Frame")
EditorFrame.Size = UDim2.new(1, -16, 0, 126)
EditorFrame.Position = UDim2.new(0, 8, 0, 44)
EditorFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
EditorFrame.Parent = MainFrame
Instance.new("UICorner", EditorFrame).CornerRadius = UDim.new(0, 8)
local EditorStroke = Instance.new("UIStroke", EditorFrame)
EditorStroke.Color = Color3.fromRGB(95, 40, 155)
EditorStroke.Thickness = 1.5

local EditorScroll = Instance.new("ScrollingFrame")
EditorScroll.Size = UDim2.new(1, -8, 1, -54)
EditorScroll.Position = UDim2.new(0, 4, 0, 4)
EditorScroll.BackgroundTransparency = 1
EditorScroll.CanvasSize = UDim2.new(0, 0, 4, 0)
EditorScroll.ScrollBarThickness = 4
EditorScroll.ScrollBarImageColor3 = Color3.fromRGB(145, 60, 235)
EditorScroll.Parent = EditorFrame

local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(1, -6, 1, 0)
CodeInput.BackgroundTransparency = 1
CodeInput.Text = ""
CodeInput.PlaceholderText = "ใส่โค้ด Lua / Luau เพื่อรัน..."
CodeInput.PlaceholderColor3 = Color3.fromRGB(160, 140, 190)
CodeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CodeInput.Font = Enum.Font.Code
CodeInput.TextSize = 12
CodeInput.TextXAlignment = Enum.TextXAlignment.Left
CodeInput.TextYAlignment = Enum.TextYAlignment.Top
CodeInput.MultiLine = true
CodeInput.ClearTextOnFocus = false
CodeInput.Parent = EditorScroll

-- แถบแสดงสถานะ / แจ้งเตือนบนหน้าจอ
local StatusBar = Instance.new("Frame")
StatusBar.Name = "StatusBar"
StatusBar.Size = UDim2.new(1, -12, 0, 16)
StatusBar.Position = UDim2.new(0, 6, 1, -46)
StatusBar.BackgroundColor3 = Color3.fromRGB(24, 15, 38)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = EditorFrame
Instance.new("UICorner", StatusBar).CornerRadius = UDim.new(0, 4)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -8, 1, 0)
StatusLabel.Position = UDim2.new(0, 4, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "สถานะ: พร้อมรับโค้ดในช่องแก้ไข | รันแล้ว 0 ครั้ง"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 10
StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusBar

local function SetStatus(msg, isError)
	local stamp = os.date("%H:%M:%S")
	StatusLabel.Text = "[" .. stamp .. "] " .. msg .. " | รัน: " .. tostring(TotalRuns)
	if isError then
		StatusBar.BackgroundColor3 = Color3.fromRGB(75, 18, 45)
		EditorStroke.Color = Color3.fromRGB(220, 55, 115)
	else
		StatusBar.BackgroundColor3 = Color3.fromRGB(24, 15, 38)
		EditorStroke.Color = Color3.fromRGB(95, 40, 155)
	end
end

local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 56, 0, 20)
ClearBtn.Position = UDim2.new(0, 6, 1, -24)
ClearBtn.BackgroundColor3 = Color3.fromRGB(85, 25, 125)
ClearBtn.Text = "ล้างโค้ด"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 10
ClearBtn.Parent = EditorFrame
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 5)
ClearBtn.MouseButton1Click:Connect(function()
	CodeInput.Text = ""
	CodeInput:ReleaseFocus()
	SetStatus("ล้างโค้ดในช่องแก้ไขแล้ว", false)
end)

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 56, 0, 20)
CopyBtn.Position = UDim2.new(0, 66, 1, -24)
CopyBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 95)
CopyBtn.Text = "คัดลอก"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 10
CopyBtn.Parent = EditorFrame
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 5)
CopyBtn.MouseButton1Click:Connect(function()
	if type(setclipboard) == "function" then
		setclipboard(CodeInput.Text)
		SetStatus("คัดลอกโค้ดลงคลิปบอร์ดแล้ว", false)
	else
		SetStatus("ตัวรันไม่รองรับ setclipboard", true)
	end
end)

local MetaInfoLabel = Instance.new("TextLabel")
MetaInfoLabel.Size = UDim2.new(0, 160, 0, 20)
MetaInfoLabel.Position = UDim2.new(1, -166, 1, -24)
MetaInfoLabel.BackgroundTransparency = 1
MetaInfoLabel.Text = "1 บรรทัด | 0 ตัวอักษร  ____✍️"
MetaInfoLabel.TextColor3 = Color3.fromRGB(185, 145, 255)
MetaInfoLabel.Font = Enum.Font.Code
MetaInfoLabel.TextSize = 10
MetaInfoLabel.TextXAlignment = Enum.TextXAlignment.Right
MetaInfoLabel.Parent = EditorFrame

local function UpdateEditorMeta()
	local txt = CodeInput.Text
	local _, newlines = txt:gsub("\n", "")
	local lines = (#txt == 0) and 1 or (newlines + 1)
	MetaInfoLabel.Text = tostring(lines) .. " บรรทัด | " .. tostring(#txt) .. " อักษร  ____✍️"
end
CodeInput:GetPropertyChangedSignal("Text"):Connect(UpdateEditorMeta)

-- 2. ปุ่ม RUN และ สวิตช์ AUTO
local ActionRow = Instance.new("Frame")
ActionRow.Size = UDim2.new(1, -16, 0, 34)
ActionRow.Position = UDim2.new(0, 8, 0, 176)
ActionRow.BackgroundTransparency = 1
ActionRow.Parent = MainFrame

local RunBtn = Instance.new("TextButton")
RunBtn.Size = UDim2.new(0.47, 0, 1, 0)
RunBtn.Position = UDim2.new(0, 0, 0, 0)
RunBtn.BackgroundColor3 = Color3.fromRGB(125, 40, 215)
RunBtn.Text = "▶ RUN"
RunBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunBtn.Font = Enum.Font.GothamBold
RunBtn.TextSize = 13
RunBtn.Parent = ActionRow
Instance.new("UICorner", RunBtn).CornerRadius = UDim.new(0, 8)

local AutoFrame = Instance.new("Frame")
AutoFrame.Size = UDim2.new(0.50, 0, 1, 0)
AutoFrame.Position = UDim2.new(0.50, 0, 0, 0)
AutoFrame.BackgroundColor3 = Color3.fromRGB(26, 18, 42)
AutoFrame.Parent = ActionRow
Instance.new("UICorner", AutoFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", AutoFrame).Color = Color3.fromRGB(95, 40, 155)

local AutoText = Instance.new("TextLabel")
AutoText.Size = UDim2.new(0.62, 0, 1, 0)
AutoText.Position = UDim2.new(0, 7, 0, 0)
AutoText.BackgroundTransparency = 1
AutoText.Text = "AUTO: OFF"
AutoText.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoText.Font = Enum.Font.GothamBold
AutoText.TextSize = 11
AutoText.TextXAlignment = Enum.TextXAlignment.Left
AutoText.Parent = AutoFrame

local AutoSwitch = Instance.new("TextButton")
AutoSwitch.Size = UDim2.new(0, 38, 0, 20)
AutoSwitch.Position = UDim2.new(1, -43, 0.5, -10)
AutoSwitch.BackgroundColor3 = Color3.fromRGB(60, 50, 80)
AutoSwitch.Text = ""
AutoSwitch.Parent = AutoFrame
Instance.new("UICorner", AutoSwitch).CornerRadius = UDim.new(1, 0)

local SwitchDot = Instance.new("Frame")
SwitchDot.Size = UDim2.new(0, 14, 0, 14)
SwitchDot.Position = UDim2.new(0, 3, 0.5, -7)
SwitchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SwitchDot.Parent = AutoSwitch
Instance.new("UICorner", SwitchDot).CornerRadius = UDim.new(1, 0)

-- 3. แถบปรับความเร็วการรัน (1 - 100)
local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(1, -16, 0, 44)
SpeedFrame.Position = UDim2.new(0, 8, 0, 216)
SpeedFrame.BackgroundColor3 = Color3.fromRGB(24, 16, 38)
SpeedFrame.Parent = MainFrame
Instance.new("UICorner", SpeedFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", SpeedFrame).Color = Color3.fromRGB(85, 35, 140)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -16, 0, 18)
SpeedLabel.Position = UDim2.new(0, 8, 0, 2)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "⚡ ความเร็วในการรัน: 50 / 100 (หน่วง ~0.77s)"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Font = Enum.Font.GothamSemibold
SpeedLabel.TextSize = 11
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedFrame

local SliderTrack = Instance.new("TextButton")
SliderTrack.Size = UDim2.new(1, -16, 0, 10)
SliderTrack.Position = UDim2.new(0, 8, 0, 25)
SliderTrack.BackgroundColor3 = Color3.fromRGB(45, 30, 70)
SliderTrack.Text = ""
SliderTrack.AutoButtonColor = false
SliderTrack.Parent = SpeedFrame
Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)

local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(0.5, 0, 1, 0)
SliderBar.BackgroundColor3 = Color3.fromRGB(165, 65, 255)
SliderBar.Parent = SliderTrack
Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

local sliding = false
local function SetSpeedFromInput(input)
	local ratio = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
	RunSpeed = math.max(1, math.floor(ratio * 100))
	local delaySec = math.max(0.02, (101 - RunSpeed) * 0.015)
	SliderBar.Size = UDim2.new(RunSpeed / 100, 0, 1, 0)
	SpeedLabel.Text = string.format("⚡ ความเร็วในการรัน: %d / 100 (หน่วง %.2fs)", RunSpeed, delaySec)
end

SliderTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		sliding = true
		SetSpeedFromInput(input)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		SetSpeedFromInput(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		sliding = false
	end
end)

-- 4. ระบบบันทึกโค้ดทั้งหมด (สูงสุด 600) + ค้นหา + บันทึก / ลบรายการ / ยกเลิก
local SaveFrame = Instance.new("Frame")
SaveFrame.Size = UDim2.new(1, -16, 0, 156)
SaveFrame.Position = UDim2.new(0, 8, 0, 266)
SaveFrame.BackgroundColor3 = Color3.fromRGB(20, 14, 32)
SaveFrame.Parent = MainFrame
Instance.new("UICorner", SaveFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", SaveFrame).Color = Color3.fromRGB(95, 40, 155)

local SaveTitle = Instance.new("TextLabel")
SaveTitle.Size = UDim2.new(0.58, 0, 0, 18)
SaveTitle.Position = UDim2.new(0, 8, 0, 2)
SaveTitle.BackgroundTransparency = 1
SaveTitle.Text = "💾 บันทึกโค้ด (0 / 600)"
SaveTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveTitle.Font = Enum.Font.GothamBold
SaveTitle.TextSize = 11
SaveTitle.TextXAlignment = Enum.TextXAlignment.Left
SaveTitle.Parent = SaveFrame

local SearchInput = Instance.new("TextBox")
SearchInput.Size = UDim2.new(0.38, 0, 0, 18)
SearchInput.Position = UDim2.new(0.60, 0, 0, 3)
SearchInput.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
SearchInput.Text = ""
SearchInput.PlaceholderText = "ค้นหา..."
SearchInput.PlaceholderColor3 = Color3.fromRGB(145, 125, 175)
SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchInput.Font = Enum.Font.Code
SearchInput.TextSize = 10
SearchInput.ClearTextOnFocus = false
SearchInput.Parent = SaveFrame
Instance.new("UICorner", SearchInput).CornerRadius = UDim.new(0, 4)

local SaveInput = Instance.new("TextBox")
SaveInput.Size = UDim2.new(1, -16, 0, 22)
SaveInput.Position = UDim2.new(0, 8, 0, 22)
SaveInput.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
SaveInput.Text = ""
SaveInput.PlaceholderText = "วางโค้ดที่ต้องการบันทึก (หรือปล่อยว่างเพื่อดึงจากช่องบน)..."
SaveInput.PlaceholderColor3 = Color3.fromRGB(150, 130, 180)
SaveInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveInput.Font = Enum.Font.Code
SaveInput.TextSize = 10
SaveInput.MultiLine = true
SaveInput.ClearTextOnFocus = false
SaveInput.Parent = SaveFrame
Instance.new("UICorner", SaveInput).CornerRadius = UDim.new(0, 5)

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.31, 0, 0, 22)
SaveBtn.Position = UDim2.new(0, 8, 0, 48)
SaveBtn.BackgroundColor3 = Color3.fromRGB(115, 35, 195)
SaveBtn.Text = "บันทึก"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.TextSize = 11
SaveBtn.Parent = SaveFrame
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 5)

local DelSelectedBtn = Instance.new("TextButton")
DelSelectedBtn.Size = UDim2.new(0.31, 0, 0, 22)
DelSelectedBtn.Position = UDim2.new(0.345, 0, 0, 48)
DelSelectedBtn.BackgroundColor3 = Color3.fromRGB(95, 25, 65)
DelSelectedBtn.Text = "ลบรายการ"
DelSelectedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DelSelectedBtn.Font = Enum.Font.GothamBold
DelSelectedBtn.TextSize = 11
DelSelectedBtn.Parent = SaveFrame
Instance.new("UICorner", DelSelectedBtn).CornerRadius = UDim.new(0, 5)

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(0.31, 0, 0, 22)
CancelBtn.Position = UDim2.new(0.68, -8, 0, 48)
CancelBtn.BackgroundColor3 = Color3.fromRGB(65, 35, 85)
CancelBtn.Text = "ยกเลิก"
CancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CancelBtn.Font = Enum.Font.GothamBold
CancelBtn.TextSize = 11
CancelBtn.Parent = SaveFrame
Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 5)

local SaveScroll = Instance.new("ScrollingFrame")
SaveScroll.Size = UDim2.new(1, -16, 0, 74)
SaveScroll.Position = UDim2.new(0, 8, 0, 74)
SaveScroll.BackgroundColor3 = Color3.fromRGB(12, 8, 20)
SaveScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SaveScroll.ScrollBarThickness = 4
SaveScroll.ScrollBarImageColor3 = Color3.fromRGB(145, 60, 235)
SaveScroll.Parent = SaveFrame
Instance.new("UICorner", SaveScroll).CornerRadius = UDim.new(0, 5)

local SaveLayout = Instance.new("UIListLayout")
SaveLayout.Padding = UDim.new(0, 3)
SaveLayout.Parent = SaveScroll

-- ฟังก์ชันและระบบรันโค้ด Lua / Luau จากช่องแก้ไขโค้ด
local function GetCompiler()
	if type(loadstring) == "function" then
		return loadstring
	end
	if type(getgenv) == "function" then
		local g = getgenv()
		if g and type(g.loadstring) == "function" then
			return g.loadstring
		end
	end
	return nil
end

local function PrepareLuauCode(rawCode)
	return rawCode
end

local function RunEditorCode(rawCode)
	if not rawCode or rawCode:match("^%s*$") then
		SetStatus("⚠️ ไม่รัน: ไม่มีโค้ดในช่องแก้ไขโค้ด", true)
		return false, "EMPTY_EDITOR"
	end

	local compiler = GetCompiler()
	if not compiler then
		SetStatus("❌ ไม่รองรับ: ตัวรันไม่มี loadstring", true)
		return false, "NO_COMPILER"
	end

	local codeToCompile = PrepareLuauCode(rawCode)
	local okCompile, chunkOrErr = pcall(compiler, codeToCompile)
	if not okCompile or type(chunkOrErr) ~= "function" then
		SetStatus("❌ ผิดไวยากรณ์: " .. tostring(chunkOrErr), true)
		return false, tostring(chunkOrErr)
	end

	TotalRuns += 1
	task.spawn(function()
		local okExec, execErr = pcall(chunkOrErr)
		if okExec then
			SetStatus("✅ รันโค้ดสำเร็จแล้ว", false)
		else
			SetStatus("❌ Runtime Error: " .. tostring(execErr), true)
			warn("[Editor Run Error]: " .. tostring(execErr))
		end
	end)
	return true, "OK"
end

RunBtn.MouseButton1Click:Connect(function()
	local ok = RunEditorCode(CodeInput.Text)
	RunBtn.Text = ok and "✅ RUN" or "▶ RUN"
	task.wait(0.5)
	RunBtn.Text = "▶ RUN"
end)

AutoSwitch.MouseButton1Click:Connect(function()
	AutoEnabled = not AutoEnabled
	if AutoEnabled then
		AutoText.Text = "AUTO: ON"
		AutoText.TextColor3 = Color3.fromRGB(200, 140, 255)
		TweenService:Create(AutoSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(145, 50, 245)}):Play()
		TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(1, -17, 0.5, -7)}):Play()
		SetStatus("🔄 AUTO RUN เปิดอยู่", false)
	else
		AutoText.Text = "AUTO: OFF"
		AutoText.TextColor3 = Color3.fromRGB(255, 255, 255)
		TweenService:Create(AutoSwitch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 50, 80)}):Play()
		TweenService:Create(SwitchDot, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -7)}):Play()
		SetStatus("⏹ AUTO RUN ปิดแล้ว", false)
	end
end)

task.spawn(function()
	while ScreenGui and ScreenGui.Parent do
		local waitTime = math.max(0.02, (101 - RunSpeed) * 0.015)
		task.wait(waitTime)
		if AutoEnabled then
			if CodeInput.Text ~= "" and not CodeInput.Text:match("^%s*$") then
				RunEditorCode(CodeInput.Text)
			end
		end
	end
end)

local function RefreshSaveList()
	for _, child in ipairs(SaveScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local query = SearchInput.Text:lower()
	for i, itemCode in ipairs(SavedList) do
		local singleLine = itemCode:gsub("[\r\n]+", " ")
		if query == "" or singleLine:lower():find(query, 1, true) then
			local itemBtn = Instance.new("TextButton")
			itemBtn.Size = UDim2.new(1, -6, 0, 20)
			itemBtn.BackgroundColor3 = (SelectedSaveIndex == i) and Color3.fromRGB(95, 40, 155) or Color3.fromRGB(35, 22, 58)
			local mark = (SelectedSaveIndex == i) and "★ " or ""
			itemBtn.Text = mark .. tostring(i) .. ". " .. singleLine
			itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			itemBtn.Font = Enum.Font.Code
			itemBtn.TextSize = 10
			itemBtn.TextXAlignment = Enum.TextXAlignment.Left
			itemBtn.TextTruncate = Enum.TextTruncate.AtEnd
			itemBtn.Parent = SaveScroll
			Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)

			itemBtn.MouseButton1Click:Connect(function()
				SelectedSaveIndex = i
				CodeInput.Text = itemCode
				RefreshSaveList()
				SetStatus("โหลดโค้ดลำดับที่ " .. tostring(i) .. " ลงช่องแก้ไขแล้ว", false)
			end)
		end
	end

	SaveScroll.CanvasSize = UDim2.new(0, 0, 0, SaveLayout.AbsoluteContentSize.Y + 6)
	SaveTitle.Text = "💾 บันทึกโค้ด (" .. tostring(#SavedList) .. " / " .. tostring(MaxSaveCount) .. ")"
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(RefreshSaveList)

SaveBtn.MouseButton1Click:Connect(function()
	local textToSave = SaveInput.Text
	if textToSave == "" or textToSave:match("^%s*$") then
		textToSave = CodeInput.Text
	end
	if textToSave == "" or textToSave:match("^%s*$") then
		SetStatus("⚠️ ไม่มีโค้ดให้บันทึก", true)
		return
	end
	if #SavedList >= MaxSaveCount then
		SetStatus("⚠️ บันทึกครบ " .. tostring(MaxSaveCount) .. " รายการแล้ว", true)
		return
	end
	table.insert(SavedList, textToSave)
	SelectedSaveIndex = #SavedList
	SaveInput.Text = ""
	RefreshSaveList()
	SetStatus("บันทึกโค้ดแล้ว (" .. tostring(#SavedList) .. "/" .. tostring(MaxSaveCount) .. ")", false)
end)

DelSelectedBtn.MouseButton1Click:Connect(function()
	if SelectedSaveIndex and SavedList[SelectedSaveIndex] then
		local removedIdx = SelectedSaveIndex
		table.remove(SavedList, removedIdx)
		SelectedSaveIndex = nil
		RefreshSaveList()
		SetStatus("ลบรายการที่ " .. tostring(removedIdx) .. " แล้ว", false)
	else
		SetStatus("⚠️ เลือกรายการที่ต้องการลบก่อน", true)
	end
end)

CancelBtn.MouseButton1Click:Connect(function()
	SaveInput.Text = ""
	SearchInput.Text = ""
	SelectedSaveIndex = nil
	SaveInput:ReleaseFocus()
	RefreshSaveList()
	SetStatus("ยกเลิกการพิมพ์และรีเซ็ตตัวเลือกแล้ว", false)
end)
