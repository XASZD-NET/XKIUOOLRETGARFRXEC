local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

local url = "https://raw.githubusercontent.com/XASZD-NET/XKIUOOLRETGARFRXEC/refs/heads/main/Moko%20Purple%20Hub%20All%20Maps%20Script%20(1).txt"

-- สร้างหน้าต่างโหลด (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MokoLoadingScreen"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.Parent = playerGui

-- พื้นหลังทึบเต็มจอ บังตรงกลางและบล็อกการกดปุ่มด้านหลัง
local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Size = UDim2.fromScale(1, 1)
bg.Position = UDim2.fromScale(0, 0)
bg.BackgroundColor3 = Color3.fromRGB(15, 12, 24)
bg.BorderSizePixel = 0
bg.Active = true -- ดักจับคลิก/สัมผัส ไม่ให้ทะลุไปทำอย่างอื่น
bg.Parent = screenGui

-- กล่องตรงกลาง
local centerBox = Instance.new("Frame")
centerBox.Size = UDim2.new(0.85, 0, 0, 170)
centerBox.Position = UDim2.fromScale(0.5, 0.5)
centerBox.AnchorPoint = Vector2.new(0.5, 0.5)
centerBox.BackgroundColor3 = Color3.fromRGB(28, 22, 45)
centerBox.BorderSizePixel = 0
centerBox.Parent = bg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = centerBox

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(145, 70, 255)
stroke.Thickness = 2
stroke.Parent = centerBox

-- ข้อความหัวข้อ / สถานะการโหลดฟังก์ชัน
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -24, 0, 32)
titleLabel.Position = UDim2.new(0, 12, 0, 16)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "MOKO PURPLE HUB - LOADING FUNCTIONS"
titleLabel.TextColor3 = Color3.fromRGB(215, 180, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = centerBox

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 24)
statusLabel.Position = UDim2.new(0, 12, 0, 52)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "กำลังโหลดฟังก์ชัน..."
statusLabel.TextColor3 = Color3.fromRGB(190, 180, 210)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = centerBox

-- แถบโหลดแบบขีด [||||||] + ตัวเลข %
local barLabel = Instance.new("TextLabel")
barLabel.Size = UDim2.new(1, -24, 0, 42)
barLabel.Position = UDim2.new(0, 12, 0, 92)
barLabel.BackgroundTransparency = 1
barLabel.Text = "[                                                            ]0%"
barLabel.TextColor3 = Color3.fromRGB(175, 95, 255)
barLabel.TextScaled = true
barLabel.Font = Enum.Font.Code
barLabel.Parent = centerBox

-- ฟังก์ชันสร้างแถบขีด [||||||] ตามเปอร์เซ็นต์
local totalBars = 60
local function formatBar(percent)
    local clamped = math.clamp(percent, 0, 100)
    local filled = math.floor((clamped / 100) * totalBars + 0.5)
    local barStr = string.rep("|", filled) .. string.rep(" ", totalBars - filled)
    return string.format("[%s]%d%%", barStr, math.floor(clamped))
end

local steps = {
    "กำลังเตรียมระบบและตรวจสอบสภาพแวดล้อม...",
    "กำลังโหลดฟังก์ชันหลักของฮับ...",
    "กำลังจัดเตรียมฟีเจอร์สำหรับทุกแมพ...",
    "กำลังตรวจสอบความพร้อมของสคริปต์..."
}

-- โหลด 0% -> 100% ใช้เวลาประมาณ 15-20 วินาที
local totalDuration = math.random(15, 20)
local elapsed = 0

while elapsed < totalDuration do
    local dt = task.wait(0.1)
    elapsed += dt
    local progress = math.clamp((elapsed / totalDuration) * 100, 0, 100)
    barLabel.Text = formatBar(progress)

    local stepIndex = math.clamp(math.floor((progress / 100) * #steps) + 1, 1, #steps)
    statusLabel.Text = steps[stepIndex]
end

barLabel.Text = formatBar(100)
statusLabel.Text = "กำลังเปิดใช้งานสคริปต์..."
task.wait(0.4)

-- ดึงและรันสคริปต์จากลิงก์
local success, response = pcall(function()
    return game:HttpGet(url)
end)

-- ปิดหน้าต่างโหลดก่อนรันสคริปต์หลัก
screenGui:Destroy()

if success and response then
    local func, loadErr = loadstring(response)
    if func then
        func()
    else
        warn("โหลดโค้ดเข้ามาได้ แต่ compile ไม่ผ่าน: " .. tostring(loadErr))
    end
else
    warn("ดาวน์โหลดสคริปต์ไม่สำเร็จ: " .. tostring(response))
end
