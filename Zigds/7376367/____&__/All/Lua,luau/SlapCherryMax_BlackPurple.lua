--[[
    ===========================================================================
    SYSTEM: SLAP & CHERRY MAX HUB (BLACK & PURPLE EDITION)
    AUTHOR: Custom Script Generator
    THEME: Black & Neon Purple (Compact Top-Left Draggable UI)
    MAX CAP: 9,000,000 (9M)
    ===========================================================================
]]

-- บริการหลักของ Roblox (Roblox Services)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ลบ GUI เก่าหากมีการรันซ้ำ (Prevent Duplicate GUI)
local GuiName = "BlackPurpleSlapCherryHub"
local targetParent = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if targetParent:FindFirstChild(GuiName) then
    targetParent:FindFirstChild(GuiName):Destroy()
end

-- ============================================================================
-- 1. การตั้งค่าตัวแปรและขีดจำกัดสูงสุด (CONFIGURATION & LIMITS)
-- ============================================================================
local MAX_VALUE = 9000000 -- ประสิทธิภาพสูงสุด 9 ล้าน

local Config = {
    SlapPower = 50,           -- ค่าเริ่มต้นความแรงมือตบ / มะเขือเทศเชอรี่
    AttackSpeed = 50,         -- ค่าเริ่มต้นความเร็วในการตบ / ตอบสนอง
    FlingDistance = 50,       -- ค่าเริ่มต้นระยะดีดผู้เล่นตกแมพ (หน่วย: เมตร)
    AutoFling = false,        -- สถานะเปิด/ปิด ระบบดีดอัตโนมัติเมื่อเข้าใกล้
    AuraRange = 15,           -- ระยะตรวจจับอัตโนมัติรอบตัว (Studs)
    IsMinimized = false       -- สถานะย่อ/ขยายหน้าต่าง
}

-- ============================================================================
-- 2. การสร้างหน้าต่าง GUI โทนสีดำ-ม่วง (UI CONSTRUCTION)
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GuiName
ScreenGui.Parent = targetParent
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- กรอบหลัก (จัดวางมุมซ้ายบนขนาดกะทัดรัด)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 8, 18) -- ดำสนิทอมม่วงเข้ม
MainFrame.Position = UDim2.new(0, 14, 0, 14) -- ชิดซ้ายบนเล็กน้อย
MainFrame.Size = UDim2.new(0, 245, 0, 345)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(155, 50, 255) -- ขอบเรืองแสงสีม่วงนีออน
MainStroke.Thickness = 1.8
MainStroke.Parent = MainFrame

-- แถบหัวข้อด้านบน (Header Bar)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(26, 14, 42)
TopBar.Size = UDim2.new(1, 0, 0, 34)
TopBar.BorderSizePixel = 0

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

-- ไล่เฉดสีม่วง-ดำตรงหัวข้อ (UIGradient)
local TopGradient = Instance.new("UIGradient")
TopGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(75, 20, 130)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 32))
})
TopGradient.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Size = UDim2.new(1, -45, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "⚡ SLAP & CHERRY [9M]"
TitleLabel.TextColor3 = Color3.fromRGB(230, 190, 255)
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่มพับเก็บ / ขยายหน้าต่าง (Minimize Button)
local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Parent = TopBar
MinBtn.BackgroundColor3 = Color3.fromRGB(45, 20, 75)
MinBtn.Position = UDim2.new(1, -30, 0.5, -11)
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 15

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinBtn

-- ระบบลากย้ายหน้าต่าง (รองรับทั้งมือถือ Touch และคอมพิวเตอร์ Mouse)
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- พื้นที่บรรจุปุ่มและช่องกรอกค่า (Container)
local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 0, 0, 38)
Container.Size = UDim2.new(1, 0, 1, -38)

-- ฟังก์ชันสร้างช่องปรับค่าพร้อมปุ่ม Reset 50 และ Max 9M
local function CreateControlSection(titleText, defaultVal, yPos, onUpdate)
    local Section = Instance.new("Frame")
    Section.Parent = Container
    Section.BackgroundTransparency = 1
    Section.Position = UDim2.new(0, 10, 0, yPos)
    Section.Size = UDim2.new(1, -20, 0, 56)

    local Label = Instance.new("TextLabel")
    Label.Parent = Section
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = titleText
    Label.TextColor3 = Color3.fromRGB(215, 195, 240)
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local InputBox = Instance.new("TextBox")
    InputBox.Parent = Section
    InputBox.BackgroundColor3 = Color3.fromRGB(24, 15, 36)
    InputBox.Position = UDim2.new(0, 0, 0, 21)
    InputBox.Size = UDim2.new(0.58, 0, 0, 28)
    InputBox.Font = Enum.Font.GothamBold
    InputBox.Text = tostring(defaultVal)
    InputBox.PlaceholderText = "50 - 9000000"
    InputBox.TextColor3 = Color3.fromRGB(190, 120, 255)
    InputBox.TextSize = 12
    InputBox.ClearTextOnFocus = false

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 6)
    BoxCorner.Parent = InputBox

    local BoxStroke = Instance.new("UIStroke")
    BoxStroke.Color = Color3.fromRGB(100, 40, 175)
    BoxStroke.Thickness = 1
    BoxStroke.Parent = InputBox

    -- ปุ่มคืนค่าเริ่มต้น (50)
    local DefBtn = Instance.new("TextButton")
    DefBtn.Parent = Section
    DefBtn.BackgroundColor3 = Color3.fromRGB(38, 22, 58)
    DefBtn.Position = UDim2.new(0.61, 0, 0, 21)
    DefBtn.Size = UDim2.new(0.18, 0, 0, 28)
    DefBtn.Font = Enum.Font.GothamBold
    DefBtn.Text = "50"
    DefBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
    DefBtn.TextSize = 11

    local DefCorner = Instance.new("UICorner")
    DefCorner.CornerRadius = UDim.new(0, 6)
    DefCorner.Parent = DefBtn

    -- ปุ่มปรับสูงสุด (9M)
    local MaxBtn = Instance.new("TextButton")
    MaxBtn.Parent = Section
    MaxBtn.BackgroundColor3 = Color3.fromRGB(115, 30, 205)
    MaxBtn.Position = UDim2.new(0.81, 0, 0, 21)
    MaxBtn.Size = UDim2.new(0.19, 0, 0, 28)
    MaxBtn.Font = Enum.Font.GothamBold
    MaxBtn.Text = "9M"
    MaxBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MaxBtn.TextSize = 11

    local MaxCorner = Instance.new("UICorner")
    MaxCorner.CornerRadius = UDim.new(0, 6)
    MaxCorner.Parent = MaxBtn

    -- อัปเดตค่าเมื่อพิมพ์เสร็จ
    InputBox.FocusLost:Connect(function()
        local parsed = tonumber(InputBox.Text)
        if parsed then
            parsed = math.clamp(parsed, 1, MAX_VALUE)
            InputBox.Text = tostring(parsed)
            onUpdate(parsed)
        else
            InputBox.Text = tostring(defaultVal)
            onUpdate(defaultVal)
        end
    end)

    DefBtn.MouseButton1Click:Connect(function()
        InputBox.Text = "50"
        onUpdate(50)
    end)

    MaxBtn.MouseButton1Click:Connect(function()
        InputBox.Text = tostring(MAX_VALUE)
        onUpdate(MAX_VALUE)
    end)
end

-- สร้างส่วนควบคุม 3 รายการหลัก
CreateControlSection("1. ความแรง มือตบ / มะเขือเทศเชอรี่:", Config.SlapPower, 4, function(val)
    Config.SlapPower = val
end)

CreateControlSection("2. ความเร็วในการตบ / ตอบสนอง:", Config.AttackSpeed, 64, function(val)
    Config.AttackSpeed = val
end)

CreateControlSection("3. ระยะดีดผู้เล่นตกแมพ (หน่วย: เมตร):", Config.FlingDistance, 124, function(val)
    Config.FlingDistance = val
end)

-- ปุ่มเปิด/ปิด ระบบดีดตกแมพอัตโนมัติ (Auto Fling Aura)
local AutoFlingBtn = Instance.new("TextButton")
AutoFlingBtn.Name = "AutoFlingBtn"
AutoFlingBtn.Parent = Container
AutoFlingBtn.BackgroundColor3 = Color3.fromRGB(38, 18, 62)
AutoFlingBtn.Position = UDim2.new(0, 10, 0, 190)
AutoFlingBtn.Size = UDim2.new(1, -20, 0, 32)
AutoFlingBtn.Font = Enum.Font.GothamBold
AutoFlingBtn.Text = "🔮 ระบบดีดตกแมพออโต้: ปิด (OFF)"
AutoFlingBtn.TextColor3 = Color3.fromRGB(255, 110, 140)
AutoFlingBtn.TextSize = 11

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 6)
AutoCorner.Parent = AutoFlingBtn

local AutoStroke = Instance.new("UIStroke")
AutoStroke.Color = Color3.fromRGB(110, 40, 185)
AutoStroke.Thickness = 1
AutoStroke.Parent = AutoFlingBtn

-- ปุ่มกดดีดผู้เล่นรอบตัวให้ตกแมพทันที (Instant Fling)
local InstantFlingBtn = Instance.new("TextButton")
InstantFlingBtn.Name = "InstantFlingBtn"
InstantFlingBtn.Parent = Container
InstantFlingBtn.BackgroundColor3 = Color3.fromRGB(130, 35, 225)
InstantFlingBtn.Position = UDim2.new(0, 10, 0, 230)
InstantFlingBtn.Size = UDim2.new(1, -20, 0, 34)
InstantFlingBtn.Font = Enum.Font.GothamBold
InstantFlingBtn.Text = "💥 ดีดผู้เล่นใกล้ตัวตกแมพทันที"
InstantFlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InstantFlingBtn.TextSize = 12

local InstantCorner = Instance.new("UICorner")
InstantCorner.CornerRadius = UDim.new(0, 6)
InstantCorner.Parent = InstantFlingBtn

-- ข้อความแสดงสถานะด้านล่าง
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = Container
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0, 270)
StatusLabel.Size = UDim2.new(1, -20, 0, 24)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "สถานะ: พร้อมใช้งาน (ค่าเริ่มต้น 50)"
StatusLabel.TextColor3 = Color3.fromRGB(165, 140, 200)
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- การทำงานของปุ่มพับเก็บ GUI
MinBtn.MouseButton1Click:Connect(function()
    Config.IsMinimized = not Config.IsMinimized
    if Config.IsMinimized then
        MinBtn.Text = "+"
        TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 245, 0, 34)
        }):Play()
    else
        MinBtn.Text = "-"
        TweenService:Create(MainFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 245, 0, 345)
        }):Play()
    end
end)

-- สลับโหมด Auto Fling
AutoFlingBtn.MouseButton1Click:Connect(function()
    Config.AutoFling = not Config.AutoFling
    if Config.AutoFling then
        AutoFlingBtn.Text = "🔮 ระบบดีดตกแมพออโต้: เปิด (ON)"
        AutoFlingBtn.TextColor3 = Color3.fromRGB(110, 255, 165)
        AutoFlingBtn.BackgroundColor3 = Color3.fromRGB(65, 25, 115)
        StatusLabel.Text = "สถานะ: กำลังตรวจจับผู้เล่นรอบตัว..."
    else
        AutoFlingBtn.Text = "🔮 ระบบดีดตกแมพออโต้: ปิด (OFF)"
        AutoFlingBtn.TextColor3 = Color3.fromRGB(255, 110, 140)
        AutoFlingBtn.BackgroundColor3 = Color3.fromRGB(38, 18, 62)
        StatusLabel.Text = "สถานะ: ปิดระบบดีดอัตโนมัติ"
    end
end)

-- ============================================================================
-- 3. ระบบคำนวณฟิสิกส์และการทำงานหลัก (CORE COMBAT & FLING ENGINE)
-- ============================================================================

-- แปลงหน่วยเมตรเป็น Studs ของ Roblox (1 เมตร ≈ 3.571 Studs)
local function ConvertMetersToStuds(meters)
    return meters * 3.571
end

-- ฟังก์ชันสร้างแรงส่งดีดเป้าหมายให้กระเด็นพ้นขอบแมพ
local function ExecuteFling(targetCharacter, originPosition)
    local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
    local targetHum = targetCharacter:FindFirstChildOfClass("Humanoid")
    if not targetHRP or not targetHum or targetHum.Health <= 0 then return end

    -- คำนวณทิศทางการกระเด็นออกจากตัวเรา
    local diff = (targetHRP.Position - originPosition)
    local direction = (diff.Magnitude > 0.01) and diff.Unit or Vector3.new(0, 0, -1)

    -- คำนวณแรงรวมจากความแรงมือตบ + ระยะทางเป้าหมาย (เมตร -> Studs)
    local targetStuds = ConvertMetersToStuds(Config.FlingDistance)
    local launchVelocity = Config.SlapPower + targetStuds

    -- ยกตัวเป้าหมายขึ้นเล็กน้อยเพื่อไม่ให้ติดพื้นแมพ และส่งแรงพุ่งไปข้างหน้า
    local upwardBoost = math.clamp(launchVelocity * 0.3, 60, 1500000)
    local finalVector = (direction * launchVelocity) + Vector3.new(0, upwardBoost, 0)

    -- ใช้ BodyVelocity เพื่อส่งแรงกระแทกฉับพลัน
    local bv = Instance.new("BodyVelocity")
    bv.Name = "SlapCherryFlingForce"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = finalVector
    bv.Parent = targetHRP

    -- ลบแรงออกหลังส่งตัวเสร็จเพื่อป้องกันอาการค้าง
    Debris:AddItem(bv, 0.25)
end

-- ปุ่มกดดีดผู้เล่นใกล้ตัวทันที
InstantFlingBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- ระยะตรวจจับเป้าหมายรอบตัว (ขั้นต่ำ 25 Studs และขยายตามระยะที่ตั้งไว้สูงสุด 250 Studs)
    local scanRadius = math.clamp(ConvertMetersToStuds(Config.FlingDistance), 25, 250)
    local hitCount = 0

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and (targetHRP.Position - hrp.Position).Magnitude <= scanRadius then
                ExecuteFling(player.Character, hrp.Position)
                hitCount = hitCount + 1
            end
        end
    end

    StatusLabel.Text = string.format("ดีดเป้าหมาย %d คน (ระยะ %d ม.)", hitCount, Config.FlingDistance)
end)

-- ฟังก์ชันปรับแต่งค่าภายใน Tool (มือตบ / มะเขือเทศเชอรี่)
local function ModifyEquippedTool(tool)
    if not tool then return end

    for _, obj in ipairs(tool:GetDescendants()) do
        -- ปรับค่า NumberValue / IntValue ที่เกี่ยวข้องกับความแรงและความเร็ว
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "power") or string.find(nameLower, "force") or string.find(nameLower, "knockback") or string.find(nameLower, "slap") then
                obj.Value = Config.SlapPower
            elseif string.find(nameLower, "speed") or string.find(nameLower, "cooldown") or string.find(nameLower, "delay") or string.find(nameLower, "cd") then
                -- ยิ่งค่า AttackSpeed สูง Cooldown จะยิ่งเข้าใกล้ 0
                obj.Value = math.max(0.0001, 1 / (Config.AttackSpeed / 5))
            end
        end
    end

    -- รองรับการปรับ Attribute ของ Tool รุ่นใหม่
    local attrs = tool:GetAttributes()
    for attrName, _ in pairs(attrs) do
        local lowerAttr = string.lower(attrName)
        if string.find(lowerAttr, "power") or string.find(lowerAttr, "force") or string.find(lowerAttr, "knockback") then
            tool:SetAttribute(attrName, Config.SlapPower)
        elseif string.find(lowerAttr, "speed") or string.find(lowerAttr, "cooldown") then
            tool:SetAttribute(attrName, math.max(0.0001, 1 / (Config.AttackSpeed / 5)))
        end
    end
end

-- ลูปประมวลผลแบบ Real-time ทุกเฟรม (Heartbeat)
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    -- 1. อัปเดตความแรงและความเร็วของ มือตบ / มะเขือเทศเชอรี่ ที่ถืออยู่
    local activeTool = char:FindFirstChildOfClass("Tool")
    if activeTool then
        ModifyEquippedTool(activeTool)
    end

    -- 2. เร่งความเร็วแอนิเมชันการตบ/ขว้างตามค่า AttackSpeed (สูงสุด 9M)
    if humanoid and Config.AttackSpeed > 50 then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local speedMultiplier = math.clamp(Config.AttackSpeed / 50, 1, 250)
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(speedMultiplier)
            end
        end
    end

    -- 3. ระบบดีดตกแมพอัตโนมัติเมื่อผู้เล่นอื่นเข้าใกล้
    if Config.AutoFling and hrp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and (targetHRP.Position - hrp.Position).Magnitude <= Config.AuraRange then
                    ExecuteFling(player.Character, hrp.Position)
                end
            end
        end
    end
end)
