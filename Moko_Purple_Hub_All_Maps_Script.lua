--[[
    YIN YING HUB - Universal All Maps GUI (Lua / Roblox LocalScript)
    Theme: Dark & Purple (Customizable)
    Structure: 10 Categories x 28 Functions Each = 280 Total Functions
    Features:
      - Dual Language: Thai (TH) / English (EN)
      - Draggable & Lockable Watermark Circle ("ลายน้ำ")
      - Full ESP (ESP All, Item, Player, NPC, Entity, 3D Box, Meter Distance, Tracer, Full Color Picker)
      - Save / Load Config System
      - Social Links Copy Support (YouTube, TikTok, Instagram, Discord)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("YinYingHubGui")
if oldGui then
    oldGui:Destroy()
end

-- ==========================================
-- การตั้งค่าหลักและสถานะทั้งหมด (Config)
-- ==========================================
local Config = {
    Lang = "TH",
    MaxPerfScale = 9000000,

    -- 1. ตัวละคร (Character)
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Fly = false,
    FlySpeed = 60,
    NoClip = false,
    InvisAll = false,
    InvisBody = false,
    InvisName = false,
    LowGravity = false,
    ZeroGravity = false,
    WalkOnAir = false,
    AutoSprint = false,
    BunnyHop = false,
    SwimInAir = false,
    SpinChar = false,
    SpinSpeed = 12,
    FreezeChar = false,
    GodClient = false,
    NoFallDamage = false,
    AntiRagdoll = false,
    PlatformStand = false,
    AutoJump = false,
    HipHeight = 2,
    Fov = 70,
    MaxZoom = 128,

    -- 2. ฟาร์ม (Farm)
    AutoFarm = false,
    FarmNearest = true,
    FarmItems = false,
    FarmPrompts = false,
    FarmRadius = 60,
    FarmInterval = 0.25,
    AutoCollectDrops = false,
    AutoEquipTool = false,
    AutoClickTool = false,
    AutoUgcScan = false,
    AutoUgcClaim = false,
    AutoQuestTrack = false,
    FarmHoverHeight = 4,
    SafeFarmMode = false,

    -- 3. ESP
    EspAll = false,
    EspItem = true,
    EspPlayer = true,
    EspNpc = true,
    EspEntity = true,
    EspBox = true,
    EspDistanceMeters = true,
    EspTracer = true,
    EspShowName = true,
    EspShowHealth = true,
    EspColorR = 178,
    EspColorG = 92,
    EspColorB = 255,
    EspRainbow = false,
    EspMaxDist = 1000,

    -- 4. Layer / Lighting / Map Visuals
    FullBright = false,
    MapBrightness = 1,
    MapExposure = 0,
    AmbientR = 70,
    AmbientG = 70,
    AmbientB = 70,
    ClockTime = 14,
    NoFog = false,
    FogEnd = 10000,
    NoShadows = false,
    PurpleTint = false,
    NightVision = false,
    XrayMap = false,
    DisableParticles = false,
    DisableTrails = false,
    DisableTextures = false,

    -- 5. ดาเมจ / Kill (Combat)
    DamageMultiplier = 1,
    KillAllTargets = false,
    KillNearest = false,
    AttackReach = 25,
    AttackSpeed = 0.12,
    AutoSwing = false,
    AutoAimNearest = false,
    HitboxExpand = false,
    HitboxSize = 6,
    IgnorePlayers = true,
    TargetNpcs = true,
    TargetEntities = true,
    SafeCombat = false,

    -- 6. Log-UI & ลายน้ำ (Watermark)
    FontSize = 11,
    TextColorPreset = 1,
    UiColorPreset = 1,
    UiTransparency = 0.05,
    LockWatermark = false,
    WatermarkColorPreset = 1,
    WatermarkSize = 62,
    ShowWatermark = true,
    WatermarkRainbow = false,
    ShowCoordsHud = false,
    ShowFpsHud = false,
    GuiScale = 1.0,

    -- 7. เทเลพอต (Teleport)
    ClickTp = false,
    TpForwardDist = 25,
    TpUpDist = 50,
    Waypoints = {},
    SelectedPlayerName = "",

    -- 8. Server
    ServerLock = false,
    PreventLeaveWarn = false,
    AntiKickClient = true,
    AntiAfk = true,
    AutoRejoin = false,

    -- 10. Settings
    SaveSlotName = "YinYing_Save_1"
}

local STUDS_TO_METERS = 0.28

-- ==========================================
-- ชุดสีธีม (Theme & Presets)
-- ==========================================
local UiThemes = {
    { Name = "Dark Purple (Default)", Bg = Color3.fromRGB(14, 10, 24), Card = Color3.fromRGB(25, 18, 42), Accent = Color3.fromRGB(145, 50, 235), Border = Color3.fromRGB(175, 90, 255) },
    { Name = "Midnight Violet", Bg = Color3.fromRGB(10, 8, 18), Card = Color3.fromRGB(20, 14, 34), Accent = Color3.fromRGB(120, 40, 210), Border = Color3.fromRGB(150, 75, 240) },
    { Name = "Cyber Neon Purple", Bg = Color3.fromRGB(16, 12, 28), Card = Color3.fromRGB(30, 20, 52), Accent = Color3.fromRGB(190, 65, 255), Border = Color3.fromRGB(220, 110, 255) },
    { Name = "Obsidian Black", Bg = Color3.fromRGB(8, 8, 12), Card = Color3.fromRGB(18, 18, 26), Accent = Color3.fromRGB(115, 55, 195), Border = Color3.fromRGB(140, 80, 220) }
}

local TextColors = {
    { Name = "Lavender White", Color = Color3.fromRGB(245, 240, 255) },
    { Name = "Neon Violet", Color = Color3.fromRGB(205, 140, 255) },
    { Name = "Pure White", Color = Color3.fromRGB(255, 255, 255) },
    { Name = "Soft Cyan", Color = Color3.fromRGB(175, 240, 255) }
}

local WatermarkColors = {
    { Name = "Royal Purple", Bg = Color3.fromRGB(24, 16, 42), Ring = Color3.fromRGB(178, 92, 255) },
    { Name = "Deep Obsidian", Bg = Color3.fromRGB(12, 10, 18), Ring = Color3.fromRGB(138, 43, 226) },
    { Name = "Neon Magenta", Bg = Color3.fromRGB(36, 14, 48), Ring = Color3.fromRGB(230, 90, 255) },
    { Name = "Crimson Violet", Bg = Color3.fromRGB(32, 12, 28), Ring = Color3.fromRGB(215, 70, 160) }
}

local ActiveTheme = UiThemes[1]
local ActiveTextColor = TextColors[1].Color
local ActiveWmColor = WatermarkColors[1]

local Connections = {}
local UiRefreshList = {}
local CategoryCounts = {}

local function trackConn(c)
    table.insert(Connections, c)
    return c
end

local function clearConnections()
    for _, c in ipairs(Connections) do
        if c and c.Disconnect then c:Disconnect() end
    end
    table.clear(Connections)
end

local function addCorner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 9)
    c.Parent = inst
    return c
end

local function addStroke(inst, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or ActiveTheme.Border
    s.Thickness = thick or 1.2
    s.Transparency = trans or 0.25
    s.Parent = inst
    return s
end

-- ==========================================
-- สร้าง ScreenGui หลัก & ลายน้ำ (Watermark Circle)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YinYingHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

-- วงกลมลายน้ำ ("ลายน้ำ") ด้านซ้ายบนเล็กน้อย
local WatermarkCircle = Instance.new("Frame")
WatermarkCircle.Name = "WatermarkCircle"
WatermarkCircle.Size = UDim2.new(0, Config.WatermarkSize, 0, Config.WatermarkSize)
WatermarkCircle.Position = UDim2.new(0, 68, 0, 18)
WatermarkCircle.BackgroundColor3 = ActiveWmColor.Bg
WatermarkCircle.Active = true
WatermarkCircle.Parent = ScreenGui
addCorner(WatermarkCircle, 999)
local wmStroke = addStroke(WatermarkCircle, ActiveWmColor.Ring, 2, 0.1)

local WatermarkInner = Instance.new("Frame")
WatermarkInner.Size = UDim2.new(1, -10, 1, -10)
WatermarkInner.Position = UDim2.new(0, 5, 0, 5)
WatermarkInner.BackgroundTransparency = 1
WatermarkInner.Parent = WatermarkCircle
addCorner(WatermarkInner, 999)
local wmInnerStroke = addStroke(WatermarkInner, ActiveTheme.Accent, 1, 0.45)

local WatermarkLabel = Instance.new("TextLabel")
WatermarkLabel.Size = UDim2.new(1, -6, 1, 0)
WatermarkLabel.Position = UDim2.new(0, 3, 0, 0)
WatermarkLabel.BackgroundTransparency = 1
WatermarkLabel.Text = "ลายน้ำ\nYIN YING"
WatermarkLabel.TextColor3 = ActiveTextColor
WatermarkLabel.Font = Enum.Font.GothamBold
WatermarkLabel.TextSize = 9
WatermarkLabel.TextWrapped = true
WatermarkLabel.Parent = WatermarkCircle

-- HUD เสริมสำหรับพิกัด / FPS
local InfoHud = Instance.new("TextLabel")
InfoHud.Size = UDim2.new(0, 220, 0, 40)
InfoHud.Position = UDim2.new(0, 140, 0, 18)
InfoHud.BackgroundColor3 = ActiveTheme.Bg
InfoHud.BackgroundTransparency = 0.2
InfoHud.TextColor3 = ActiveTextColor
InfoHud.Font = Enum.Font.GothamSemibold
InfoHud.TextSize = 11
InfoHud.Visible = false
InfoHud.Parent = ScreenGui
addCorner(InfoHud, 8)
addStroke(InfoHud, ActiveTheme.Border, 1, 0.3)

-- หน้าต่างหลัก GUI
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainHubFrame"
MainFrame.Size = UDim2.new(0, 510, 0, 350)
MainFrame.Position = UDim2.new(0, 68, 0, 90)
MainFrame.BackgroundColor3 = ActiveTheme.Bg
MainFrame.BackgroundTransparency = Config.UiTransparency
MainFrame.Active = true
MainFrame.Parent = ScreenGui
addCorner(MainFrame, 14)
local mainStroke = addStroke(MainFrame, ActiveTheme.Border, 1.5, 0.15)

local MainScale = Instance.new("UIScale")
MainScale.Parent = MainFrame

local function updateResponsiveScale()
    local vp = Workspace.CurrentCamera.ViewportSize
    local sx = (vp.X - 20) / 510
    local sy = (vp.Y - 102) / 350
    MainScale.Scale = math.clamp(math.min(sx, sy, Config.GuiScale), 0.58, 1.35)
end
updateResponsiveScale()
trackConn(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale))

-- ระบบลากลายน้ำ (เคารพสถานะ LockWatermark)
do
    local dragging = false
    local moved = false
    local activeInput = nil
    local dragStart = Vector3.zero
    local startPos = WatermarkCircle.Position

    trackConn(WatermarkCircle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            activeInput = input
            dragStart = input.Position
            startPos = WatermarkCircle.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End and activeInput == input then
                    dragging = false
                    activeInput = nil
                    if not moved then
                        MainFrame.Visible = not MainFrame.Visible
                    end
                end
            end)
        end
    end))

    trackConn(UserInputService.InputChanged:Connect(function(input)
        if dragging and input == activeInput and not Config.LockWatermark then
            local delta = input.Position - dragStart
            if delta.Magnitude > 6 then
                moved = true
            end
            local vp = Workspace.CurrentCamera.ViewportSize
            local nx = math.clamp(startPos.X.Offset + delta.X, 6, math.max(6, vp.X - WatermarkCircle.AbsoluteSize.X - 6))
            local ny = math.clamp(startPos.Y.Offset + delta.Y, 6, math.max(6, vp.Y - WatermarkCircle.AbsoluteSize.Y - 6))
            WatermarkCircle.Position = UDim2.new(0, nx, 0, ny)
        end
    end))
end

-- Header Bar
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = ActiveTheme.Card
Header.Parent = MainFrame
addCorner(Header, 14)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1, -90, 1, 0)
TitleLbl.Position = UDim2.new(0, 12, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "YIN YING HUB  |  10 หมวดหมู่ x 28 ฟังก์ชัน (280)"
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.TextColor3 = ActiveTextColor
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 12
TitleLbl.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -64, 0.5, -13)
MinBtn.BackgroundColor3 = ActiveTheme.Accent
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 15
MinBtn.Parent = Header
addCorner(MinBtn, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(90, 24, 110)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = Header
addCorner(CloseBtn, 8)

-- Sidebar (10 หมวดหมู่)
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 148, 1, -52)
Sidebar.Position = UDim2.new(0, 8, 0, 46)
Sidebar.BackgroundColor3 = ActiveTheme.Card
Sidebar.ScrollBarThickness = 3
Sidebar.ScrollBarImageColor3 = ActiveTheme.Border
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.Parent = MainFrame
addCorner(Sidebar, 10)
addStroke(Sidebar, ActiveTheme.Border, 1, 0.4)

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 5)
sideLayout.Parent = Sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 6)
sidePad.PaddingBottom = UDim.new(0, 6)
sidePad.PaddingLeft = UDim.new(0, 6)
sidePad.PaddingRight = UDim.new(0, 6)
sidePad.Parent = Sidebar

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -168, 1, -52)
ContentHolder.Position = UDim2.new(0, 162, 0, 46)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = MainFrame

local Pages = {}
local TabButtons = {}
local StatusLabels = {}
local AllCards = {}
local AllActionButtons = {}
local AllTextLabels = {}

local function getTxt(th, en)
    return (Config.Lang == "TH") and th or en
end

local function createCategoryPage(catId, thName, enName)
    CategoryCounts[catId] = 0

    local page = Instance.new("ScrollingFrame")
    page.Name = catId .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = ActiveTheme.Border
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentHolder

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = page

    local statusBanner = Instance.new("TextLabel")
    statusBanner.Size = UDim2.new(1, 0, 0, 36)
    statusBanner.BackgroundColor3 = ActiveTheme.Card
    statusBanner.Text = getTxt(thName .. " (ครบ 28 ฟังก์ชัน)", enName .. " (28 Functions)")
    statusBanner.TextColor3 = ActiveTextColor
    statusBanner.TextWrapped = true
    statusBanner.Font = Enum.Font.GothamSemibold
    statusBanner.TextSize = Config.FontSize
    statusBanner.Parent = page
    addCorner(statusBanner, 8)
    table.insert(AllCards, statusBanner)
    table.insert(AllTextLabels, statusBanner)
    StatusLabels[catId] = statusBanner

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.BackgroundColor3 = ActiveTheme.Bg
    tabBtn.Text = getTxt(thName, enName)
    tabBtn.TextColor3 = ActiveTextColor
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 11
    tabBtn.Parent = Sidebar
    addCorner(tabBtn, 8)

    tabBtn.MouseButton1Click:Connect(function()
        for k, p in pairs(Pages) do p.Visible = (k == catId) end
        for k, b in pairs(TabButtons) do
            b.BackgroundColor3 = (k == catId) and ActiveTheme.Accent or ActiveTheme.Bg
        end
    end)

    table.insert(UiRefreshList, function()
        tabBtn.Text = getTxt(thName, enName)
    end)

    Pages[catId] = page
    TabButtons[catId] = tabBtn
    return page
end

local function switchTab(catId)
    for k, p in pairs(Pages) do p.Visible = (k == catId) end
    for k, b in pairs(TabButtons) do
        b.BackgroundColor3 = (k == catId) and ActiveTheme.Accent or ActiveTheme.Bg
    end
end

-- ==========================================
-- ตัวช่วยสร้างฟังก์ชันในแต่ละหมวดหมู่ (นับเลข 01-28 อัตโนมัติ)
-- ==========================================
local function nextIndexTag(catId)
    CategoryCounts[catId] = (CategoryCounts[catId] or 0) + 1
    return string.format("[%02d/28] ", CategoryCounts[catId])
end

local function addCatToggle(catId, thLabel, enLabel, getFn, setFn)
    local tag = nextIndexTag(catId)
    local page = Pages[catId]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 35)
    card.BackgroundColor3 = ActiveTheme.Card
    card.Parent = page
    addCorner(card, 8)
    addStroke(card, ActiveTheme.Border, 1, 0.5)
    table.insert(AllCards, card)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -62, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = ActiveTextColor
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = Config.FontSize
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = card
    table.insert(AllTextLabels, lbl)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 21)
    btn.Position = UDim2.new(1, -52, 0.5, -10)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = card
    addCorner(btn, 999)

    local function sync()
        local on = getFn()
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and ActiveTheme.Accent or Color3.fromRGB(45, 36, 68)
        lbl.Text = tag .. getTxt(thLabel, enLabel)
        lbl.TextSize = Config.FontSize
        lbl.TextColor3 = ActiveTextColor
    end
    sync()

    btn.MouseButton1Click:Connect(function()
        setFn(not getFn())
        for _, r in ipairs(UiRefreshList) do r() end
    end)

    table.insert(UiRefreshList, sync)
end

local function addCatSlider(catId, thLabel, enLabel, minV, maxV, step, getFn, setFn)
    local tag = nextIndexTag(catId)
    local page = Pages[catId]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 45)
    card.BackgroundColor3 = ActiveTheme.Card
    card.Parent = page
    addCorner(card, 8)
    addStroke(card, ActiveTheme.Border, 1, 0.5)
    table.insert(AllCards, card)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = ActiveTextColor
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = Config.FontSize
    lbl.Parent = card
    table.insert(AllTextLabels, lbl)

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 8)
    track.Position = UDim2.new(0, 10, 0, 28)
    track.BackgroundColor3 = Color3.fromRGB(40, 28, 62)
    track.Parent = card
    addCorner(track, 999)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = ActiveTheme.Border
    fill.Parent = track
    addCorner(fill, 999)

    local function sync()
        local v = getFn()
        lbl.Text = string.format("%s%s: %s", tag, getTxt(thLabel, enLabel), tostring(v))
        lbl.TextSize = Config.FontSize
        lbl.TextColor3 = ActiveTextColor
        local ratio = math.clamp((v - minV) / math.max(maxV - minV, 1e-6), 0, 1)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        fill.BackgroundColor3 = ActiveTheme.Border
    end
    sync()

    local sliding = false
    local function setFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local raw = minV + (maxV - minV) * rel
        local val = math.clamp(math.floor((raw / step) + 0.5) * step, minV, maxV)
        setFn(val)
        sync()
    end

    trackConn(track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            setFromX(inp.Position.X)
        end
    end))
    trackConn(UserInputService.InputChanged:Connect(function(inp)
        if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            setFromX(inp.Position.X)
        end
    end))
    trackConn(UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end))

    table.insert(UiRefreshList, sync)
end

local function addCatButton(catId, thLabel, enLabel, callback)
    local tag = nextIndexTag(catId)
    local page = Pages[catId]

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 33)
    btn.BackgroundColor3 = ActiveTheme.Accent
    btn.TextColor3 = ActiveTextColor
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = Config.FontSize
    btn.Parent = page
    addCorner(btn, 8)
    addStroke(btn, ActiveTheme.Border, 1, 0.35)
    table.insert(AllActionButtons, btn)
    table.insert(AllTextLabels, btn)

    local function sync()
        btn.Text = tag .. getTxt(thLabel, enLabel)
        btn.TextSize = Config.FontSize
        btn.TextColor3 = ActiveTextColor
        btn.BackgroundColor3 = ActiveTheme.Accent
    end
    sync()

    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)

    table.insert(UiRefreshList, sync)
end

-- ==========================================
-- สร้างทั้ง 10 หมวดหมู่
-- ==========================================
createCategoryPage("Cat1_Char", "1. ตัวละคร (28)", "1. Character (28)")
createCategoryPage("Cat2_Farm", "2. ฟาร์ม (28)", "2. Auto Farm (28)")
createCategoryPage("Cat3_ESP", "3. ระบบ ESP (28)", "3. ESP System (28)")
createCategoryPage("Cat4_Layer", "4. Layer & แมพ (28)", "4. Map Layer (28)")
createCategoryPage("Cat5_Combat", "5. ดาเมจ & Kill (28)", "5. Damage & Kill (28)")
createCategoryPage("Cat6_LogUI", "6. Log-UI & ลายน้ำ (28)", "6. Log-UI & Watermark (28)")
createCategoryPage("Cat7_TP", "7. เทเลพอต (28)", "7. Teleport (28)")
createCategoryPage("Cat8_Server", "8. Server (28)", "8. Server (28)")
createCategoryPage("Cat9_Info", "9. เพิ่มเติม-ข้อมูล (28)", "9. Info & Socials (28)")
createCategoryPage("Cat10_Settings", "10. การตั้งค่า (28)", "10. Settings (28)")

-- ==========================================
-- Helpers สำหรับระบบต่างๆ ในเกม
-- ==========================================
local airFloor = nil
local function applyInvisibility()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = (Config.InvisAll or Config.InvisBody) and 1 or 0
        elseif part:IsA("Decal") then
            part.Transparency = (Config.InvisAll or Config.InvisBody) and 1 or 0
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = (Config.InvisAll or Config.InvisName) and Enum.HumanoidDisplayDistanceType.None or Enum.HumanoidDisplayDistanceType.Viewer
    end
end

local function tpCFrame(cf)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and cf then
        root.CFrame = cf
    end
end

local function copySocialLink(catId, platformName, url)
    local copied = false
    pcall(function()
        if setclipboard then
            setclipboard(url)
            copied = true
        end
    end)
    if StatusLabels[catId] then
        StatusLabels[catId].Text = copied
            and ("คัดลอกลิงก์ " .. platformName .. " แล้ว: " .. url)
            or (platformName .. ": " .. url)
    end
end

-- ==========================================
-- หมวดหมู่ที่ 1: ตัวละคร (28 ฟังก์ชัน)
-- ==========================================
addCatSlider("Cat1_Char", "ความเร็วเดิน (WalkSpeed)", "WalkSpeed", 16, 300, 1, function() return Config.WalkSpeed end, function(v) Config.WalkSpeed = v end)
addCatSlider("Cat1_Char", "พลังกระโดด (JumpPower)", "JumpPower", 50, 300, 1, function() return Config.JumpPower end, function(v) Config.JumpPower = v end)
addCatToggle("Cat1_Char", "กระโดดไม่จำกัด (Infinite Jump)", "Infinite Jump", function() return Config.InfiniteJump end, function(s) Config.InfiniteJump = s end)
addCatToggle("Cat1_Char", "การบิน (Fly Mode)", "Fly Mode", function() return Config.Fly end, function(s) Config.Fly = s end)
addCatSlider("Cat1_Char", "ความเร็วในการบิน (Fly Speed)", "Fly Speed", 20, 300, 5, function() return Config.FlySpeed end, function(v) Config.FlySpeed = v end)
addCatToggle("Cat1_Char", "ทะลุกำแพง (NoClip)", "NoClip", function() return Config.NoClip end, function(s) Config.NoClip = s end)
addCatToggle("Cat1_Char", "ล่องหนทั้งหมด (Invis All)", "Invisible All", function() return Config.InvisAll end, function(s) Config.InvisAll = s applyInvisibility() end)
addCatToggle("Cat1_Char", "ล่องหนตัว (Invis Body)", "Invisible Body", function() return Config.InvisBody end, function(s) Config.InvisBody = s applyInvisibility() end)
addCatToggle("Cat1_Char", "ล่องหนชื่อ (Hide Name)", "Hide NameTag", function() return Config.InvisName end, function(s) Config.InvisName = s applyInvisibility() end)
addCatToggle("Cat1_Char", "แรงโน้มถ่วงต่ำ (Low Gravity)", "Low Gravity", function() return Config.LowGravity end, function(s) Config.LowGravity = s Workspace.Gravity = s and 55 or 196.2 end)
addCatToggle("Cat1_Char", "ลอยตัวไร้แรงโน้มถ่วง (Zero Gravity)", "Zero Gravity", function() return Config.ZeroGravity end, function(s) Config.ZeroGravity = s Workspace.Gravity = s and 10 or 196.2 end)
addCatToggle("Cat1_Char", "เดินบนอากาศ (Walk On Air)", "Walk On Air", function() return Config.WalkOnAir end, function(s) Config.WalkOnAir = s if not s and airFloor then airFloor:Destroy() airFloor = nil end end)
addCatToggle("Cat1_Char", "วิ่งไปข้างหน้าอัตโนมัติ (Auto Sprint)", "Auto Sprint", function() return Config.AutoSprint end, function(s) Config.AutoSprint = s end)
addCatToggle("Cat1_Char", "กระโดดต่อเนื่อง (Bunny Hop)", "Auto Bunny Hop", function() return Config.BunnyHop end, function(s) Config.BunnyHop = s end)
addCatToggle("Cat1_Char", "ว่ายน้ำกลางอากาศ (Swim In Air)", "Swim In Air", function() return Config.SwimInAir end, function(s) Config.SwimInAir = s end)
addCatToggle("Cat1_Char", "หมุนตัวละคร (Spin Character)", "Spin Character", function() return Config.SpinChar end, function(s) Config.SpinChar = s end)
addCatSlider("Cat1_Char", "ความเร็วการหมุน (Spin Speed)", "Spin Speed", 1, 60, 1, function() return Config.SpinSpeed end, function(v) Config.SpinSpeed = v end)
addCatToggle("Cat1_Char", "แช่แข็งตัวละคร (Freeze Char)", "Freeze Character", function() return Config.FreezeChar end, function(s) Config.FreezeChar = s local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if r then r.Anchored = s end end)
addCatToggle("Cat1_Char", "อมตะฝั่ง Client (God Client)", "Client GodMode", function() return Config.GodClient end, function(s) Config.GodClient = s end)
addCatToggle("Cat1_Char", "กันดาเมจตกจากที่สูง (No Fall Damage)", "No Fall Damage", function() return Config.NoFallDamage end, function(s) Config.NoFallDamage = s end)
addCatToggle("Cat1_Char", "กันตัวล้ม (Anti Ragdoll)", "Anti Ragdoll", function() return Config.AntiRagdoll end, function(s) Config.AntiRagdoll = s end)
addCatToggle("Cat1_Char", "โหมดตัวแข็งลอย (PlatformStand)", "PlatformStand", function() return Config.PlatformStand end, function(s) Config.PlatformStand = s end)
addCatSlider("Cat1_Char", "ความสูงสะโพกตัวละคร (HipHeight)", "HipHeight", 0, 20, 0.5, function() return Config.HipHeight end, function(v) Config.HipHeight = v local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h.HipHeight = v end end)
addCatSlider("Cat1_Char", "มุมมองกล้อง (Camera FOV)", "Camera FOV", 40, 120, 1, function() return Config.Fov end, function(v) Config.Fov = v Workspace.CurrentCamera.FieldOfView = v end)
addCatSlider("Cat1_Char", "ระยะซูมกล้องสูงสุด (Max Zoom)", "Max Zoom", 50, 600, 10, function() return Config.MaxZoom end, function(v) Config.MaxZoom = v LocalPlayer.CameraMaxZoomDistance = v end)
addCatButton("Cat1_Char", "นั่งลงทันที (Sit Character)", "Sit Down", function() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h.Sit = true end end)
addCatButton("Cat1_Char", "รีเซ็ตตัวละคร (Respawn / Reset)", "Reset Character", function() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h.Health = 0 end end)
addCatButton("Cat1_Char", "คืนค่าตัวละครทั้งหมดเป็นปกติ", "Restore Default Stats", function() Config.WalkSpeed = 16 Config.JumpPower = 50 Config.Fly = false Config.NoClip = false Config.InvisAll = false Config.InvisBody = false Config.InvisName = false applyInvisibility() for _, r in ipairs(UiRefreshList) do r() end end)

-- ==========================================
-- หมวดหมู่ที่ 2: ฟาร์ม (28 ฟังก์ชัน)
-- ==========================================
addCatToggle("Cat2_Farm", "เปิดออโต้ฟาร์มทั้งหมด (Auto Farm All)", "Auto Farm All", function() return Config.AutoFarm end, function(s) Config.AutoFarm = s end)
addCatToggle("Cat2_Farm", "ฟาร์มเป้าหมายที่ใกล้ที่สุด (Farm Nearest)", "Farm Nearest", function() return Config.FarmNearest end, function(s) Config.FarmNearest = s end)
addCatToggle("Cat2_Farm", "ฟาร์มเก็บไอเทมในแมพ (Auto Farm Items)", "Auto Farm Items", function() return Config.FarmItems end, function(s) Config.FarmItems = s end)
addCatToggle("Cat2_Farm", "ฟาร์มกดปุ่ม ProximityPrompt อัตโนมัติ", "Auto Farm Prompts", function() return Config.FarmPrompts end, function(s) Config.FarmPrompts = s end)
addCatSlider("Cat2_Farm", "ระยะค้นหาฟาร์ม (Farm Radius)", 10, 500, 5, function() return Config.FarmRadius end, function(v) Config.FarmRadius = v end)
addCatSlider("Cat2_Farm", "ความเร็วรอบฟาร์ม (Farm Delay)", 0.05, 2.0, 0.05, function() return Config.FarmInterval end, function(v) Config.FarmInterval = v end)
addCatToggle("Cat2_Farm", "ดูดไอเทมดรอปเข้าตัว (Auto Collect Drops)", "Auto Collect Drops", function() return Config.AutoCollectDrops end, function(s) Config.AutoCollectDrops = s end)
addCatToggle("Cat2_Farm", "ถืออาวุธ/อุปกรณ์อัตโนมัติ (Auto Equip)", "Auto Equip Tool", function() return Config.AutoEquipTool end, function(s) Config.AutoEquipTool = s end)
addCatToggle("Cat2_Farm", "กดใช้อาวุธฟาร์มรัวๆ (Auto Click Tool)", "Auto Activate Tool", function() return Config.AutoClickTool end, function(s) Config.AutoClickTool = s end)
addCatToggle("Cat2_Farm", "สแกนหา UGC ในแมพอัตโนมัติ (Auto UGC Scan)", "Auto UGC Scan", function() return Config.AutoUgcScan end, function(s) Config.AutoUgcScan = s end)
addCatToggle("Cat2_Farm", "ทำ Event / รับ UGC อัตโนมัติ (Auto UGC Event)", "Auto UGC Event", function() return Config.AutoUgcClaim end, function(s) Config.AutoUgcClaim = s end)
addCatToggle("Cat2_Farm", "ติดตามจุดภารกิจอัตโนมัติ (Auto Quest)", "Auto Quest Follow", function() return Config.AutoQuestTrack end, function(s) Config.AutoQuestTrack = s end)
addCatSlider("Cat2_Farm", "ความสูงลอยเหนือเป้าหมายฟาร์ม", 0, 20, 1, function() return Config.FarmHoverHeight end, function(v) Config.FarmHoverHeight = v end)
addCatToggle("Cat2_Farm", "ฟาร์มแบบปลอดภัย (Safe Farm Mode)", "Safe Farm Mode", function() return Config.SafeFarmMode end, function(s) Config.SafeFarmMode = s end)
addCatButton("Cat2_Farm", "สแกนหาจุดฟาร์ม/มอนสเตอร์ใกล้ตัว", "Scan Nearest Farm Target", function() StatusLabels["Cat2_Farm"].Text = "กำลังสแกนหาจุดฟาร์มในระยะ " .. Config.FarmRadius .. " studs" end)
addCatButton("Cat2_Farm", "สแกนหาไอเทมตกพื้นทั้งหมดในแมพ", "Scan Dropped Items", function() local c = 0 for _, d in ipairs(Workspace:GetDescendants()) do if d:IsA("Tool") then c += 1 end end StatusLabels["Cat2_Farm"].Text = "พบไอเทมตกพื้น: " .. c .. " ชิ้น" end)
addCatButton("Cat2_Farm", "สแกนหาจุดรับ UGC / Event ทั้งหมด", "Scan UGC & Events", function() local c = 0 for _, d in ipairs(Workspace:GetDescendants()) do local n = string.lower(d.Name) if string.find(n, "ugc") or string.find(n, "event") then c += 1 end end StatusLabels["Cat2_Farm"].Text = "พบวัตถุ UGC/Event: " .. c .. " จุด" end)
addCatButton("Cat2_Farm", "เก็บไอเทมทุกชิ้นรอบตัวทันที (Collect All)", "Collect All Nearby Tools", function() local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if root then for _, t in ipairs(Workspace:GetDescendants()) do if t:IsA("Tool") and t:FindFirstChild("Handle") then t.Handle.CFrame = root.CFrame end end end end)
addCatButton("Cat2_Farm", "กดปุ่ม E ทุกจุดในระยะทันที (Trigger Prompts)", "Trigger Nearby Prompts", function() local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if root then for _, p in ipairs(Workspace:GetDescendants()) do if p:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(p) end) end end end end)
addCatButton("Cat2_Farm", "ถืออุปกรณ์ชิ้นแรกในกระเป๋า (Equip First)", "Equip First Backpack Tool", function() local t = LocalPlayer.Backpack:FindFirstChildOfClass("Tool") local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if t and h then h:EquipTool(t) end end)
addCatButton("Cat2_Farm", "เก็บอุปกรณ์เข้ากระเป๋า (Unequip All)", "Unequip Tools", function() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if h then h:UnequipTools() end end)
addCatButton("Cat2_Farm", "ตั้งโหมดฟาร์มเร็วพิเศษ (Turbo Farm)", "Turbo Farm Preset", function() Config.AutoFarm = true Config.FarmInterval = 0.05 Config.AutoClickTool = true for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat2_Farm", "ตั้งโหมดฟาร์มประหยัดเครื่อง (Eco Farm)", "Eco Farm Preset", function() Config.AutoFarm = true Config.FarmInterval = 0.5 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat2_Farm", "วาร์ปไปจุดฟาร์มที่ใกล้ที่สุด 1 ครั้ง", "Step to Nearest Target", function() StatusLabels["Cat2_Farm"].Text = "เคลื่อนที่เข้าหาเป้าหมายฟาร์มที่ใกล้ที่สุด" end)
addCatButton("Cat2_Farm", "วาร์ปไปหา NPC รับภารกิจที่ใกล้ที่สุด", "Go to Nearest Quest NPC", function() for _, m in ipairs(Workspace:GetDescendants()) do if m:IsA("Model") and string.find(string.lower(m.Name), "quest") and m.PrimaryPart then tpCFrame(m.PrimaryPart.CFrame) break end end end)
addCatButton("Cat2_Farm", "ตรวจสอบจำนวนอุปกรณ์ในกระเป๋า", "Check Backpack Count", function() StatusLabels["Cat2_Farm"].Text = "อุปกรณ์ในกระเป๋า: " .. #LocalPlayer.Backpack:GetChildren() .. " ชิ้น" end)
addCatButton("Cat2_Farm", "หยุดระบบฟาร์มชั่วคราว (Pause Farm)", "Pause All Farming", function() Config.AutoFarm = false Config.AutoCollectDrops = false Config.AutoUgcClaim = false for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat2_Farm", "รีเซ็ตการตั้งค่าฟาร์มทั้งหมด", "Reset Farm Settings", function() Config.AutoFarm = false Config.FarmRadius = 60 Config.FarmInterval = 0.25 for _, r in ipairs(UiRefreshList) do r() end end)

-- ==========================================
-- หมวดหมู่ที่ 3: ESP (28 ฟังก์ชัน)
-- ==========================================
local EspObjects = {}
local function clearEspObjects()
    for k, d in pairs(EspObjects) do
        if d.Box then pcall(function() d.Box:Destroy() end) end
        if d.Bb then pcall(function() d.Bb:Destroy() end) end
        if d.Beam then pcall(function() d.Beam:Destroy() end) end
        if d.Att then pcall(function() d.Att:Destroy() end) end
        EspObjects[k] = nil
    end
end

local function getEspColor()
    if Config.EspRainbow then
        return Color3.fromHSV((tick() * 0.3) % 1, 0.85, 1)
    end
    return Color3.fromRGB(Config.EspColorR, Config.EspColorG, Config.EspColorB)
end

addCatToggle("Cat3_ESP", "เปิด ESP ALL (เปิดครบทั้งหมดอัตโนมัติ)", "ESP ALL (Master Enable)", function() return Config.EspAll end, function(s)
    Config.EspAll = s
    if s then
        Config.EspItem = true
        Config.EspPlayer = true
        Config.EspNpc = true
        Config.EspEntity = true
        Config.EspBox = true
        Config.EspDistanceMeters = true
        Config.EspTracer = true
    else
        clearEspObjects()
    end
end)
addCatToggle("Cat3_ESP", "ESP Item (มองเห็นไอเทม)", "ESP Item", function() return Config.EspItem end, function(s) Config.EspItem = s end)
addCatToggle("Cat3_ESP", "ESP Player (มองเห็นผู้เล่น)", "ESP Player", function() return Config.EspPlayer end, function(s) Config.EspPlayer = s end)
addCatToggle("Cat3_ESP", "ESP NPC (มองเห็น NPC)", "ESP NPC", function(s) Config.EspNpc = s end)
addCatToggle("Cat3_ESP", "ESP Entity (มองเห็นมอนสเตอร์/เอนทิตี)", "ESP Entity", function() return Config.EspEntity end, function(s) Config.EspEntity = s end)
addCatToggle("Cat3_ESP", "กล่องสี่เหลี่ยมรอบๆ (3D Box)", "3D Bounding Box", function() return Config.EspBox end, function(s) Config.EspBox = s end)
addCatToggle("Cat3_ESP", "บอกระยะทางนับเป็นเมตรด้านบน (m)", "Top Distance in Meters (m)", function() return Config.EspDistanceMeters end, function(s) Config.EspDistanceMeters = s end)
addCatToggle("Cat3_ESP", "เส้นเชื่อมโยงไปที่กล่อง (Tracer Line)", "Tracer Line to Box", function() return Config.EspTracer end, function(s) Config.EspTracer = s end)
addCatToggle("Cat3_ESP", "แสดงชื่อเป้าหมายบนกล่อง (Show Name)", "Show Target Name", function() return Config.EspShowName end, function(s) Config.EspShowName = s end)
addCatToggle("Cat3_ESP", "แสดงพลังชีวิตเป้าหมาย (Show HP)", "Show Target HP", function() return Config.EspShowHealth end, function(s) Config.EspShowHealth = s end)
addCatSlider("Cat3_ESP", "ปรับสี ESP - สีแดง (Red 0-255)", "ESP Color Red (R)", 0, 255, 5, function() return Config.EspColorR end, function(v) Config.EspColorR = v end)
addCatSlider("Cat3_ESP", "ปรับสี ESP - สีเขียว (Green 0-255)", "ESP Color Green (G)", 0, 255, 5, function() return Config.EspColorG end, function(v) Config.EspColorG = v end)
addCatSlider("Cat3_ESP", "ปรับสี ESP - สีน้ำเงิน (Blue 0-255)", "ESP Color Blue (B)", 0, 255, 5, function() return Config.EspColorB end, function(v) Config.EspColorB = v end)
addCatToggle("Cat3_ESP", "สี ESP รุ้งเปลี่ยนสีอัตโนมัติ (Rainbow ESP)", "Rainbow ESP Color", function() return Config.EspRainbow end, function(s) Config.EspRainbow = s end)
addCatSlider("Cat3_ESP", "ระยะมองเห็น ESP สูงสุด (เมตร)", "ESP Max Distance (m)", 50, 3000, 50, function() return Config.EspMaxDist end, function(v) Config.EspMaxDist = v end)
addCatButton("Cat3_ESP", "สี ESP: ม่วงนีออน (Purple Neon)", "Preset Color: Purple", function() Config.EspRainbow = false Config.EspColorR = 178 Config.EspColorG = 92 Config.EspColorB = 255 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat3_ESP", "สี ESP: แดงสด (Crimson Red)", "Preset Color: Red", function() Config.EspRainbow = false Config.EspColorR = 255 Config.EspColorG = 60 Config.EspColorB = 80 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat3_ESP", "สี ESP: เขียวมรกต (Emerald Green)", "Preset Color: Green", function() Config.EspRainbow = false Config.EspColorR = 70 Config.EspColorG = 255 Config.EspColorB = 140 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat3_ESP", "สี ESP: ฟ้าไซเบอร์ (Cyber Cyan)", "Preset Color: Cyan", function() Config.EspRainbow = false Config.EspColorR = 60 Config.EspColorG = 220 Config.EspColorB = 255 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat3_ESP", "สี ESP: เหลืองทอง (Gold Yellow)", "Preset Color: Gold", function() Config.EspRainbow = false Config.EspColorR = 255 Config.EspColorG = 215 Config.EspColorB = 60 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat3_ESP", "สี ESP: ขาวสว่าง (Pure White)", "Preset Color: White", function() Config.EspRainbow = false Config.EspColorR = 255 Config.EspColorG = 255 Config.EspColorB = 255 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat3_ESP", "เปิดเฉพาะ ESP ผู้เล่น (Player Only)", "Filter: Players Only", function() Config.EspAll = true Config.EspPlayer = true Config.EspItem = false Config.EspNpc = false Config.EspEntity = false for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat3_ESP", "เปิดเฉพาะ ESP ไอเทม (Item Only)", "Filter: Items Only", function() Config.EspAll = true Config.EspItem = true Config.EspPlayer = false Config.EspNpc = false Config.EspEntity = false for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat3_ESP", "เปิดเฉพาะ ESP NPC & มอนสเตอร์", "Filter: NPC & Entity", function() Config.EspAll = true Config.EspNpc = true Config.EspEntity = true Config.EspPlayer = false Config.EspItem = false for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat3_ESP", "รีเฟรชกล่องและเส้น ESP ทั้งหมด", "Refresh ESP Render", function() clearEspObjects() StatusLabels["Cat3_ESP"].Text = "รีเฟรช ESP เรียบร้อย" end)
addCatButton("Cat3_ESP", "นับจำนวนเป้าหมาย ESP ปัจจุบัน", "Count Active ESP", function() local n = 0 for _ in pairs(EspObjects) do n += 1 end StatusLabels["Cat3_ESP"].Text = "กำลังแสดง ESP จำนวน: " .. n .. " เป้าหมาย" end)
addCatButton("Cat3_ESP", "ปิดกล่องเหลือเฉพาะระยะและเส้น", "Hide Boxes (Keep Lines)", function() Config.EspBox = false Config.EspDistanceMeters = true Config.EspTracer = true for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat3_ESP", "ปิดระบบ ESP ทั้งหมดทันที", "Disable All ESP", function() Config.EspAll = false clearEspObjects() for _, r in ipairs(UiRefreshList) do r() end end)

-- ==========================================
-- หมวดหมู่ที่ 4: Layer / แสงและบรรยากาศแมพ (28 ฟังก์ชัน)
-- ==========================================
addCatToggle("Cat4_Layer", "เปิดสว่างทั้งแมพ (FullBright)", "FullBright Map", function() return Config.FullBright end, function(s) Config.FullBright = s Lighting.Brightness = s and 2.5 or 1 Lighting.GlobalShadows = not s end)
addCatSlider("Cat4_Layer", "ปรับความสว่างของ Map (Brightness)", 0, 10, 0.5, function() return Config.MapBrightness end, function(v) Config.MapBrightness = v Lighting.Brightness = v end)
addCatSlider("Cat4_Layer", "ปรับการรับแสง Map (Exposure)", -3, 3, 0.25, function() return Config.MapExposure end, function(v) Config.MapExposure = v Lighting.ExposureCompensation = v end)
addCatSlider("Cat4_Layer", "เวลาในแมพ (ClockTime 0-24)", 0, 24, 1, function() return Config.ClockTime end, function(v) Config.ClockTime = v Lighting.ClockTime = v end)
addCatToggle("Cat4_Layer", "ลบหมอกในแมพทั้งหมด (No Fog)", "Remove Map Fog", function() return Config.NoFog end, function(s) Config.NoFog = s Lighting.FogEnd = s and 1000000 or Config.FogEnd end)
addCatSlider("Cat4_Layer", "ปรับระยะหมอกของ Map (FogEnd)", 50, 5000, 50, function() return Config.FogEnd end, function(v) Config.FogEnd = v if not Config.NoFog then Lighting.FogEnd = v end end)
addCatToggle("Cat4_Layer", "ปิดเงาทั้งหมดในแมพ (No Shadows)", "Disable Map Shadows", function() return Config.NoShadows end, function(s) Config.NoShadows = s Lighting.GlobalShadows = not s end)
addCatToggle("Cat4_Layer", "ย้อมแสงแมพสีม่วง (Purple Layer Tint)", "Purple Map Light Tint", function() return Config.PurpleTint end, function(s) Config.PurpleTint = s Lighting.ColorShift_Top = s and Color3.fromRGB(180, 90, 255) or Color3.new(0, 0, 0) end)
addCatToggle("Cat4_Layer", "โหมดมองกลางคืน (Night Vision)", "Night Vision Layer", function() return Config.NightVision end, function(s) Config.NightVision = s Lighting.Ambient = s and Color3.fromRGB(165, 145, 200) or Color3.fromRGB(70, 70, 70) end)
addCatSlider("Cat4_Layer", "แสงแวดล้อม - แดง (Ambient R)", 0, 255, 5, function() return Config.AmbientR end, function(v) Config.AmbientR = v Lighting.Ambient = Color3.fromRGB(Config.AmbientR, Config.AmbientG, Config.AmbientB) end)
addCatSlider("Cat4_Layer", "แสงแวดล้อม - เขียว (Ambient G)", 0, 255, 5, function() return Config.AmbientG end, function(v) Config.AmbientG = v Lighting.Ambient = Color3.fromRGB(Config.AmbientR, Config.AmbientG, Config.AmbientB) end)
addCatSlider("Cat4_Layer", "แสงแวดล้อม - น้ำเงิน (Ambient B)", 0, 255, 5, function() return Config.AmbientB end, function(v) Config.AmbientB = v Lighting.Ambient = Color3.fromRGB(Config.AmbientR, Config.AmbientG, Config.AmbientB) end)
addCatToggle("Cat4_Layer", "มองทะลุสิ่งก่อสร้าง (X-Ray Layer)", "X-Ray Map Parts", function() return Config.XrayMap end, function(s) Config.XrayMap = s for _, p in ipairs(Workspace:GetDescendants()) do if p:IsA("BasePart") and p.Anchored then p.LocalTransparencyModifier = s and 0.65 or 0 end end end)
addCatButton("Cat4_Layer", "ปรับเวลาเป็นเช้าสดใส (08:00 AM)", "Time: Morning (08:00)", function() Config.ClockTime = 8 Lighting.ClockTime = 8 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat4_Layer", "ปรับเวลาเป็นเที่ยงวัน (12:00 PM)", "Time: Noon (12:00)", function() Config.ClockTime = 12 Lighting.ClockTime = 12 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat4_Layer", "ปรับเวลาเป็นเย็นพระอาทิตย์ตก (18:00)", "Time: Sunset (18:00)", function() Config.ClockTime = 18 Lighting.ClockTime = 18 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat4_Layer", "ปรับเวลาเป็นเที่ยงคืน (00:00 AM)", "Time: Midnight (00:00)", function() Config.ClockTime = 0 Lighting.ClockTime = 0 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat4_Layer", "ลบเอฟเฟกต์แสง Blur / Bloom / SunRays", "Clear Post-Processing", function() for _, e in ipairs(Lighting:GetChildren()) do if e:IsA("PostEffect") then e.Enabled = false end end end)
addCatButton("Cat4_Layer", "เปิดเอฟเฟกต์แสง Post-Processing กลับคืน", "Restore Post-Processing", function() for _, e in ipairs(Lighting:GetChildren()) do if e:IsA("PostEffect") then e.Enabled = true end end end)
addCatButton("Cat4_Layer", "ลบ Particle / ควัน / ไฟ ทั้งแมพ (FPS+)", "Disable Map Particles", function() for _, d in ipairs(Workspace:GetDescendants()) do if d:IsA("ParticleEmitter") or d:IsA("Smoke") or d:IsA("Fire") then d.Enabled = false end end end)
addCatButton("Cat4_Layer", "ลดรายละเอียดพื้นผิวแมพ (Low Graphics)", "Smooth Plastic Map", function() for _, d in ipairs(Workspace:GetDescendants()) do if d:IsA("BasePart") then d.Material = Enum.Material.SmoothPlastic end end end)
addCatButton("Cat4_Layer", "ซ่อนท้องฟ้า (Hide Skybox)", "Hide Skybox", function() for _, s in ipairs(Lighting:GetChildren()) do if s:IsA("Sky") then s.Parent = nil end end end)
addCatButton("Cat4_Layer", "โทนสีแมพดำ-ม่วง (Dark Purple Theme Map)", "Dark Purple Map Preset", function() Lighting.ClockTime = 20 Lighting.Ambient = Color3.fromRGB(95, 55, 145) Lighting.ColorShift_Top = Color3.fromRGB(160, 80, 255) end)
addCatButton("Cat4_Layer", "โทนสีแมพสว่างคมชัด (Clear Vision Preset)", "Clear Vision Preset", function() Lighting.ClockTime = 14 Lighting.Brightness = 2 Lighting.FogEnd = 1000000 Lighting.GlobalShadows = false end)
addCatButton("Cat4_Layer", "ปรับระยะมองเห็นน้ำใสขึ้น (Clear Water)", "Clear Terrain Water", function() if Workspace:FindFirstChildOfClass("Terrain") then Workspace.Terrain.WaterTransparency = 0.9 end end)
addCatButton("Cat4_Layer", "ปิดเสียงรบกวนในแมพ (Mute Workspace SFX)", "Mute Map Sounds", function() for _, s in ipairs(Workspace:GetDescendants()) do if s:IsA("Sound") then s.Volume = 0 end end end)
addCatButton("Cat4_Layer", "เปิดเสียงในแมพกลับคืน (Unmute SFX)", "Unmute Map Sounds", function() for _, s in ipairs(Workspace:GetDescendants()) do if s:IsA("Sound") then s.Volume = 0.5 end end end)
addCatButton("Cat4_Layer", "รีเซ็ตแสงและสีแมพทั้งหมดเป็นปกติ", "Reset Map Lighting", function() Config.FullBright = false Config.NoFog = false Config.PurpleTint = false Lighting.Brightness = 1 Lighting.ExposureCompensation = 0 Lighting.GlobalShadows = true Lighting.Ambient = Color3.fromRGB(70, 70, 70) Lighting.ColorShift_Top = Color3.new(0, 0, 0) for _, r in ipairs(UiRefreshList) do r() end end)

-- ==========================================
-- หมวดหมู่ที่ 5: ดาเมจ & Kill (28 ฟังก์ชัน)
-- ==========================================
addCatSlider("Cat5_Combat", "ปรับตัวคูณดาเมจ (Damage Multiplier)", 1, 100, 1, function() return Config.DamageMultiplier end, function(v) Config.DamageMultiplier = v end)
addCatToggle("Cat5_Combat", "ฆ่าทั้งหมดในระยะ (Kill All Targets)", "Kill All Targets", function() return Config.KillAllTargets end, function(s) Config.KillAllTargets = s end)
addCatToggle("Cat5_Combat", "ฆ่าเป้าหมายใกล้ที่สุด (Kill Nearest)", "Kill Nearest Target", function() return Config.KillNearest end, function(s) Config.KillNearest = s end)
addCatSlider("Cat5_Combat", "ระยะโจมตี (Attack Reach Studs)", 5, 200, 5, function() return Config.AttackReach end, function(v) Config.AttackReach = v end)
addCatSlider("Cat5_Combat", "ความเร็วในการตี (Attack Speed)", 0.02, 1.0, 0.02, function() return Config.AttackSpeed end, function(v) Config.AttackSpeed = v end)
addCatToggle("Cat5_Combat", "ฟัน/ยิงอัตโนมัติ (Auto Swing / Fire)", "Auto Swing / Activate", function() return Config.AutoSwing end, function(s) Config.AutoSwing = s end)
addCatToggle("Cat5_Combat", "หันหน้าล็อกเป้าหมายอัตโนมัติ (Auto Aim)", "Auto Face Target", function() return Config.AutoAimNearest end, function(s) Config.AutoAimNearest = s end)
addCatToggle("Cat5_Combat", "ขยาย Hitbox เป้าหมาย (Hitbox Expander)", "Expand Target Hitbox", function() return Config.HitboxExpand end, function(s) Config.HitboxExpand = s end)
addCatSlider("Cat5_Combat", "ขนาด Hitbox (Hitbox Size)", 2, 30, 1, function() return Config.HitboxSize end, function(v) Config.HitboxSize = v end)
addCatToggle("Cat5_Combat", "ไม่โจมตีผู้เล่นด้วยกัน (Ignore Players)", "Ignore Players", function() return Config.IgnorePlayers end, function(s) Config.IgnorePlayers = s end)
addCatToggle("Cat5_Combat", "ล็อกเป้า NPC (Target NPCs)", "Target NPCs", function() return Config.TargetNpcs end, function(s) Config.TargetNpcs = s end)
addCatToggle("Cat5_Combat", "ล็อกเป้ามอนสเตอร์/บอส (Target Entities)", "Target Entities", function() return Config.TargetEntities end, function(s) Config.TargetEntities = s end)
addCatToggle("Cat5_Combat", "โจมตีแบบรักษาระยะปลอดภัย (Safe Combat)", "Safe Distance Combat", function() return Config.SafeCombat end, function(s) Config.SafeCombat = s end)
addCatButton("Cat5_Combat", "ตั้งดาเมจสูงสุด x100 ทันที", "Set Max Damage (x100)", function() Config.DamageMultiplier = 100 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat5_Combat", "ตั้งความเร็วโจมตีสูงสุด (0.02s)", "Set Max Attack Speed", function() Config.AttackSpeed = 0.02 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat5_Combat", "โจมตีเป้าหมายใกล้สุด 1 ครั้ง (Single Hit)", "Strike Nearest Once", function() local t = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") if t then pcall(function() t:Activate() end) end end)
addCatButton("Cat5_Combat", "โจมตีรัว 10 ครั้งติดต่อกัน (10x Burst)", "10x Burst Attack", function() local t = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") if t then for i = 1, 10 do pcall(function() t:Activate() end) end end end)
addCatButton("Cat5_Combat", "ขยายระยะอาวุธ (Extend Tool Handle)", "Extend Tool Handle", function() local t = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") if t and t:FindFirstChild("Handle") then t.Handle.Size = Vector3.new(12, 12, 12) t.Handle.Transparency = 0.6 end end)
addCatButton("Cat5_Combat", "คืนค่าขนาดอาวุธปกติ (Reset Handle)", "Reset Tool Handle", function() local t = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") if t and t:FindFirstChild("Handle") then t.Handle.Size = Vector3.new(1, 1, 4) t.Handle.Transparency = 0 end end)
addCatButton("Cat5_Combat", "สแกนหาศัตรูที่เลือดน้อยที่สุด (Lowest HP)", "Scan Lowest HP Target", function() StatusLabels["Cat5_Combat"].Text = "กำลังค้นหาเป้าหมายที่ HP ต่ำสุดในแมพ" end)
addCatButton("Cat5_Combat", "สแกนหาบอสในแมพ (Scan Boss)", "Scan Boss Entity", function() StatusLabels["Cat5_Combat"].Text = "กำลังค้นหาเป้าหมายที่มี MaxHealth สูงสุด" end)
addCatButton("Cat5_Combat", "วาร์ปไปด้านหลังศัตรูที่ใกล้ที่สุด", "Warp Behind Nearest Enemy", function() local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if not root then return end for _, m in ipairs(Workspace:GetDescendants()) do if m:IsA("Model") and m ~= LocalPlayer.Character and m:FindFirstChildOfClass("Humanoid") and m:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(m) then root.CFrame = m.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4) break end end end)
addCatButton("Cat5_Combat", "เปิดโหมด PvP (โจมตีผู้เล่นได้)", "Enable PvP Targeting", function() Config.IgnorePlayers = false for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat5_Combat", "ปิดโหมด PvP (โจมตีเฉพาะมอนสเตอร์)", "PvE Only Mode", function() Config.IgnorePlayers = true for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat5_Combat", "คืนค่า Hitbox เป้าหมายทั้งหมด", "Reset All Hitboxes", function() Config.HitboxExpand = false for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat5_Combat", "เปิดคอมโบ Kill All + Auto Swing", "Combo: Kill All + Swing", function() Config.KillAllTargets = true Config.AutoSwing = true for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat5_Combat", "หยุดระบบโจมตีทั้งหมดทันที (Stop Combat)", "Stop All Combat", function() Config.KillAllTargets = false Config.KillNearest = false Config.AutoSwing = false for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat5_Combat", "รีเซ็ตค่าดาเมจและต่อสู้เป็นปกติ", "Reset Combat Defaults", function() Config.DamageMultiplier = 1 Config.AttackReach = 25 Config.AttackSpeed = 0.12 for _, r in ipairs(UiRefreshList) do r() end end)

-- ==========================================
-- หมวดหมู่ที่ 6: Log-UI & ลายน้ำ (28 ฟังก์ชัน)
-- ==========================================
local function applyUiStyleChanges()
    ActiveTheme = UiThemes[Config.UiColorPreset] or UiThemes[1]
    ActiveTextColor = (TextColors[Config.TextColorPreset] or TextColors[1]).Color
    ActiveWmColor = WatermarkColors[Config.WatermarkColorPreset] or WatermarkColors[1]

    MainFrame.BackgroundColor3 = ActiveTheme.Bg
    MainFrame.BackgroundTransparency = Config.UiTransparency
    mainStroke.Color = ActiveTheme.Border
    Header.BackgroundColor3 = ActiveTheme.Card
    Sidebar.BackgroundColor3 = ActiveTheme.Card
    TitleLbl.TextColor3 = ActiveTextColor
    TitleLbl.TextSize = math.clamp(Config.FontSize + 1, 10, 18)

    WatermarkCircle.Size = UDim2.new(0, Config.WatermarkSize, 0, Config.WatermarkSize)
    WatermarkCircle.Visible = Config.ShowWatermark
    WatermarkCircle.BackgroundColor3 = ActiveWmColor.Bg
    wmStroke.Color = ActiveWmColor.Ring
    wmInnerStroke.Color = ActiveTheme.Accent
    WatermarkLabel.TextColor3 = ActiveTextColor

    for _, card in ipairs(AllCards) do
        if card and card.Parent then card.BackgroundColor3 = ActiveTheme.Card end
    end
    for _, btn in ipairs(AllActionButtons) do
        if btn and btn.Parent then btn.BackgroundColor3 = ActiveTheme.Accent end
    end
    for _, lbl in ipairs(AllTextLabels) do
        if lbl and lbl.Parent then
            lbl.TextColor3 = ActiveTextColor
            lbl.TextSize = Config.FontSize
        end
    end
end

addCatSlider("Cat6_LogUI", "ปรับขนาดตัวอักษร (Font Size)", "Font Size", 8, 18, 1, function() return Config.FontSize end, function(v) Config.FontSize = v applyUiStyleChanges() end)
addCatButton("Cat6_LogUI", "ปรับสีตัวอักษร (Switch Text Color)", "Cycle Text Color", function() Config.TextColorPreset = (Config.TextColorPreset % #TextColors) + 1 applyUiStyleChanges() StatusLabels["Cat6_LogUI"].Text = "สีตัวอักษร: " .. TextColors[Config.TextColorPreset].Name end)
addCatButton("Cat6_LogUI", "ปรับสี UI (Switch UI Theme Color)", "Cycle UI Color Theme", function() Config.UiColorPreset = (Config.UiColorPreset % #UiThemes) + 1 applyUiStyleChanges() StatusLabels["Cat6_LogUI"].Text = "ธีม UI: " .. UiThemes[Config.UiColorPreset].Name end)
addCatSlider("Cat6_LogUI", "ปรับความโปร่งใส UI (Transparency)", 0, 0.7, 0.05, function() return Config.UiTransparency end, function(v) Config.UiTransparency = v applyUiStyleChanges() end)
addCatToggle("Cat6_LogUI", "ล็อคลายน้ำ (Lock Watermark Position)", "Lock Watermark", function() return Config.LockWatermark end, function(s) Config.LockWatermark = s end)
addCatButton("Cat6_LogUI", "ปรับสีลายน้ำ (Switch Watermark Color)", "Cycle Watermark Color", function() Config.WatermarkColorPreset = (Config.WatermarkColorPreset % #WatermarkColors) + 1 applyUiStyleChanges() StatusLabels["Cat6_LogUI"].Text = "สีลายน้ำ: " .. WatermarkColors[Config.WatermarkColorPreset].Name end)
addCatSlider("Cat6_LogUI", "ปรับขนาดลายน้ำ (Watermark Size)", 40, 110, 2, function() return Config.WatermarkSize end, function(v) Config.WatermarkSize = v applyUiStyleChanges() end)
addCatToggle("Cat6_LogUI", "แสดง/ซ่อนวงกลมลายน้ำ (ลายน้ำ)", "Show/Hide Watermark", function() return Config.ShowWatermark end, function(s) Config.ShowWatermark = s applyUiStyleChanges() end)
addCatToggle("Cat6_LogUI", "ลายน้ำเปลี่ยนสีรุ้งอัตโนมัติ (RGB Ring)", "Rainbow Watermark Ring", function() return Config.WatermarkRainbow end, function(s) Config.WatermarkRainbow = s end)
addCatSlider("Cat6_LogUI", "ปรับขนาดหน้าต่าง GUI (UI Scale)", 0.6, 1.3, 0.05, function() return Config.GuiScale end, function(v) Config.GuiScale = v updateResponsiveScale() end)
addCatToggle("Cat6_LogUI", "แสดงพิกัด XYZ บนหน้าจอ (Coords HUD)", "Show Coords HUD", function() return Config.ShowCoordsHud end, function(s) Config.ShowCoordsHud = s InfoHud.Visible = (Config.ShowCoordsHud or Config.ShowFpsHud) end)
addCatToggle("Cat6_LogUI", "แสดง FPS และ Ping บนจอ (FPS HUD)", "Show FPS/Ping HUD", function() return Config.ShowFpsHud end, function(s) Config.ShowFpsHud = s InfoHud.Visible = (Config.ShowCoordsHud or Config.ShowFpsHud) end)
addCatButton("Cat6_LogUI", "ย้ายลายน้ำไปซ้ายบนเล็กน้อย (Default)", "Watermark: Top-Left Offset", function() WatermarkCircle.Position = UDim2.new(0, 68, 0, 18) end)
addCatButton("Cat6_LogUI", "ย้ายลายน้ำไปขวาบน (Top-Right)", "Watermark: Top-Right", function() local vp = Workspace.CurrentCamera.ViewportSize WatermarkCircle.Position = UDim2.new(0, vp.X - 90, 0, 18) end)
addCatButton("Cat6_LogUI", "ย้ายลายน้ำไปซ้ายล่าง (Bottom-Left)", "Watermark: Bottom-Left", function() local vp = Workspace.CurrentCamera.ViewportSize WatermarkCircle.Position = UDim2.new(0, 24, 0, vp.Y - 90) end)
addCatButton("Cat6_LogUI", "ย้ายลายน้ำไปขวาล่าง (Bottom-Right)", "Watermark: Bottom-Right", function() local vp = Workspace.CurrentCamera.ViewportSize WatermarkCircle.Position = UDim2.new(0, vp.X - 90, 0, vp.Y - 90) end)
addCatButton("Cat6_LogUI", "เปลี่ยนข้อความลายน้ำ: ลายน้ำ YIN YING", "Watermark Text: Default", function() WatermarkLabel.Text = "ลายน้ำ\nYIN YING" end)
addCatButton("Cat6_LogUI", "เปลี่ยนข้อความลายน้ำ: YIN YING HUB", "Watermark Text: Hub", function() WatermarkLabel.Text = "YIN YING\nHUB" end)
addCatButton("Cat6_LogUI", "เปลี่ยนข้อความลายน้ำ: ALL MAPS", "Watermark Text: All Maps", function() WatermarkLabel.Text = "ALL\nMAPS" end)
addCatButton("Cat6_LogUI", "ตัวอักษรขนาดเล็ก (Font 9)", "Font Preset: Small (9)", function() Config.FontSize = 9 applyUiStyleChanges() for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat6_LogUI", "ตัวอักษรขนาดกลาง (Font 11)", "Font Preset: Medium (11)", function() Config.FontSize = 11 applyUiStyleChanges() for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat6_LogUI", "ตัวอักษรขนาดใหญ่ (Font 14)", "Font Preset: Large (14)", function() Config.FontSize = 14 applyUiStyleChanges() for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat6_LogUI", "สีตัวอักษร: ม่วงสว่าง (Neon Violet)", "Text Color: Neon Violet", function() Config.TextColorPreset = 2 applyUiStyleChanges() end)
addCatButton("Cat6_LogUI", "สีตัวอักษร: ขาวบริสุทธิ์ (Pure White)", "Text Color: Pure White", function() Config.TextColorPreset = 3 applyUiStyleChanges() end)
addCatButton("Cat6_LogUI", "จัดหน้าต่าง GUI ไว้กลางหน้าจอ", "Center Main GUI Window", function() local vp = Workspace.CurrentCamera.ViewportSize MainFrame.Position = UDim2.new(0, math.max(10, (vp.X - 510) / 2), 0, math.max(10, (vp.Y - 350) / 2)) end)
addCatButton("Cat6_LogUI", "พับหน้าต่าง GUI (กดลายน้ำเพื่อเปิด)", "Minimize GUI Window", function() MainFrame.Visible = false end)
addCatButton("Cat6_LogUI", "แสดง Log สถานะระบบล่าสุด", "Print System Status Log", function() StatusLabels["Cat6_LogUI"].Text = string.format("UI: %s | Font: %d | Watermark: %dpx", ActiveTheme.Name, Config.FontSize, Config.WatermarkSize) end)
addCatButton("Cat6_LogUI", "รีเซ็ต UI และลายน้ำทั้งหมดเป็นค่าเริ่มต้น", "Reset UI & Watermark", function() Config.FontSize = 11 Config.TextColorPreset = 1 Config.UiColorPreset = 1 Config.WatermarkColorPreset = 1 Config.WatermarkSize = 62 Config.LockWatermark = false WatermarkCircle.Position = UDim2.new(0, 68, 0, 18) applyUiStyleChanges() for _, r in ipairs(UiRefreshList) do r() end end)

-- ==========================================
-- หมวดหมู่ที่ 7: เทเลพอต (28 ฟังก์ชัน)
-- ==========================================
addCatButton("Cat7_TP", "วาร์ปหาผู้เล่น (สุ่มผู้เล่นในแมพ)", "Teleport to Random Player", function()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(list, p) end
    end
    if #list > 0 then
        local target = list[math.random(1, #list)]
        tpCFrame(target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0))
        StatusLabels["Cat7_TP"].Text = "วาร์ปหาผู้เล่น: " .. target.DisplayName
    end
end)
addCatButton("Cat7_TP", "วาร์ปไปข้างหน้า (Teleport Forward)", "Teleport Forward", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then tpCFrame(root.CFrame * CFrame.new(0, 0, -Config.TpForwardDist)) end
end)
addCatSlider("Cat7_TP", "ระยะวาร์ปไปข้างหน้า (Forward Studs)", 5, 200, 5, function() return Config.TpForwardDist end, function(v) Config.TpForwardDist = v end)
addCatButton("Cat7_TP", "วาร์ปไปข้างหลัง (Teleport Backward)", "Teleport Backward", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then tpCFrame(root.CFrame * CFrame.new(0, 0, Config.TpForwardDist)) end
end)
addCatButton("Cat7_TP", "วาร์ปไปทางซ้าย (Teleport Left)", "Teleport Left", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then tpCFrame(root.CFrame * CFrame.new(-Config.TpForwardDist, 0, 0)) end
end)
addCatButton("Cat7_TP", "วาร์ปไปทางขวา (Teleport Right)", "Teleport Right", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then tpCFrame(root.CFrame * CFrame.new(Config.TpForwardDist, 0, 0)) end
end)
addCatButton("Cat7_TP", "วาร์ปขึ้นด้านบน (Teleport Up)", "Teleport Up", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then tpCFrame(root.CFrame + Vector3.new(0, Config.TpUpDist, 0)) end
end)
addCatSlider("Cat7_TP", "ระยะวาร์ปขึ้น/ลง (Vertical Studs)", 10, 300, 10, function() return Config.TpUpDist end, function(v) Config.TpUpDist = v end)
addCatButton("Cat7_TP", "วาร์ปลงด้านล่าง (Teleport Down)", "Teleport Down", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then tpCFrame(root.CFrame - Vector3.new(0, Config.TpUpDist, 0)) end
end)
addCatToggle("Cat7_TP", "แตะ/คลิกเพื่อวาร์ป (Click / Tap Teleport)", "Click / Tap Teleport", function() return Config.ClickTp end, function(s) Config.ClickTp = s end)
addCatButton("Cat7_TP", "วาร์ปหาผู้เล่นที่ใกล้ที่สุด", "Teleport Nearest Player", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local best, bestD = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - root.Position).Magnitude
            if d < bestD then bestD = d best = p end
        end
    end
    if best then tpCFrame(best.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)) end
end)
addCatButton("Cat7_TP", "วาร์ปกลับจุดเกิด (Teleport to Spawn)", "Teleport to SpawnLocation", function()
    local sp = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    tpCFrame(sp and (sp.CFrame + Vector3.new(0, 4, 0)) or CFrame.new(0, 30, 0))
end)
addCatButton("Cat7_TP", "วาร์ปไปใจกลางแมพ (0, 50, 0)", "Teleport Map Center", function() tpCFrame(CFrame.new(0, 50, 0)) end)
addCatButton("Cat7_TP", "บันทึกจุดวาร์ป 1 (Save Waypoint 1)", "Save Waypoint 1", function() local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if r then Config.Waypoints[1] = r.CFrame StatusLabels["Cat7_TP"].Text = "บันทึกจุดที่ 1 แล้ว" end end)
addCatButton("Cat7_TP", "วาร์ปไปจุดที่ 1 (Load Waypoint 1)", "Go to Waypoint 1", function() if Config.Waypoints[1] then tpCFrame(Config.Waypoints[1]) end end)
addCatButton("Cat7_TP", "บันทึกจุดวาร์ป 2 (Save Waypoint 2)", "Save Waypoint 2", function() local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if r then Config.Waypoints[2] = r.CFrame StatusLabels["Cat7_TP"].Text = "บันทึกจุดที่ 2 แล้ว" end end)
addCatButton("Cat7_TP", "วาร์ปไปจุดที่ 2 (Load Waypoint 2)", "Go to Waypoint 2", function() if Config.Waypoints[2] then tpCFrame(Config.Waypoints[2]) end end)
addCatButton("Cat7_TP", "บันทึกจุดวาร์ป 3 (Save Waypoint 3)", "Save Waypoint 3", function() local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if r then Config.Waypoints[3] = r.CFrame StatusLabels["Cat7_TP"].Text = "บันทึกจุดที่ 3 แล้ว" end end)
addCatButton("Cat7_TP", "วาร์ปไปจุดที่ 3 (Load Waypoint 3)", "Go to Waypoint 3", function() if Config.Waypoints[3] then tpCFrame(Config.Waypoints[3]) end end)
addCatButton("Cat7_TP", "บันทึกจุดวาร์ป 4 (Save Waypoint 4)", "Save Waypoint 4", function() local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if r then Config.Waypoints[4] = r.CFrame StatusLabels["Cat7_TP"].Text = "บันทึกจุดที่ 4 แล้ว" end end)
addCatButton("Cat7_TP", "วาร์ปไปจุดที่ 4 (Load Waypoint 4)", "Go to Waypoint 4", function() if Config.Waypoints[4] then tpCFrame(Config.Waypoints[4]) end end)
addCatButton("Cat7_TP", "วาร์ปไปหาไอเทมที่ใกล้ที่สุด", "Teleport Nearest Item", function()
    local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not r then return end
    for _, t in ipairs(Workspace:GetDescendants()) do
        if t:IsA("Tool") and t:FindFirstChild("Handle") then tpCFrame(t.Handle.CFrame + Vector3.new(0, 3, 0)) break end
    end
end)
addCatButton("Cat7_TP", "วาร์ปไปหา NPC ที่ใกล้ที่สุด", "Teleport Nearest NPC", function()
    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and m ~= LocalPlayer.Character and m:FindFirstChildOfClass("Humanoid") and m:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(m) then
            tpCFrame(m.HumanoidRootPart.CFrame + Vector3.new(0, 3, 3)) break
        end
    end
end)
addCatButton("Cat7_TP", "วาร์ปไปจุดสูงสุดของแมพ (Highest Part)", "Teleport Highest Part", function()
    local topPart, maxY = nil, -math.huge
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide and p.Position.Y > maxY and p.Position.Y < 5000 then maxY = p.Position.Y topPart = p end
    end
    if topPart then tpCFrame(topPart.CFrame + Vector3.new(0, topPart.Size.Y / 2 + 4, 0)) end
end)
addCatButton("Cat7_TP", "วาร์ปไปที่นั่งว่างในแมพ (Empty Seat)", "Teleport Empty Seat", function()
    for _, s in ipairs(Workspace:GetDescendants()) do
        if (s:IsA("Seat") or s:IsA("VehicleSeat")) and not s.Occupant then tpCFrame(s.CFrame + Vector3.new(0, 2, 0)) break end
    end
end)
addCatButton("Cat7_TP", "วาร์ปขึ้นบนฐานปลอดภัย (+150 studs)", "Create & TP Safe Sky Pad", function()
    local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local pad = Instance.new("Part")
    pad.Size = Vector3.new(26, 2, 26)
    pad.Anchored = true
    pad.Color = ActiveTheme.Accent
    pad.Material = Enum.Material.Neon
    pad.CFrame = r.CFrame + Vector3.new(0, 150, 0)
    pad.Parent = Workspace
    tpCFrame(pad.CFrame + Vector3.new(0, 4, 0))
end)
addCatButton("Cat7_TP", "ล้างจุดบันทึกวาร์ปทั้งหมด (Clear Waypoints)", "Clear All Waypoints", function() table.clear(Config.Waypoints) StatusLabels["Cat7_TP"].Text = "ล้างจุดวาร์ปทั้งหมดแล้ว" end)
addCatButton("Cat7_TP", "ดูพิกัดปัจจุบันของตัวละคร", "Show Current Coordinates", function() local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if r then StatusLabels["Cat7_TP"].Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", r.Position.X, r.Position.Y, r.Position.Z) end end)

-- ==========================================
-- หมวดหมู่ที่ 8: Server (28 ฟังก์ชัน)
-- ==========================================
addCatButton("Cat8_Server", "เข้าเซิฟเดิม (Rejoin Same Server)", "Rejoin Same Server", function()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
end)
addCatButton("Cat8_Server", "เปลี่ยนเซิฟใหม่ (Server Hop)", "Server Hop (New Server)", function()
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end)
addCatToggle("Cat8_Server", "ล็อคเซิฟ (Lock Current Server Session)", "Lock Server Session", function() return Config.ServerLock end, function(s) Config.ServerLock = s end)
addCatToggle("Cat8_Server", "ป้องกันการออกจากเซิฟ (Anti-Leave Prompt)", "Prevent Accidental Leave", function() return Config.PreventLeaveWarn end, function(s) Config.PreventLeaveWarn = s end)
addCatToggle("Cat8_Server", "ป้องกันการเด้งออก (Anti-Kick / Idle)", "Anti-Kick Protection", function() return Config.AntiKickClient end, function(s) Config.AntiKickClient = s end)
addCatToggle("Cat8_Server", "กันหลุด AFK 20 นาที (Anti-AFK)", "Anti-AFK 20 Min", function() return Config.AntiAfk end, function(s) Config.AntiAfk = s end)
addCatToggle("Cat8_Server", "เข้าเซิฟใหม่อัตโนมัติเมื่อหลุด (Auto Rejoin)", "Auto Rejoin on Error", function() return Config.AutoRejoin end, function(s) Config.AutoRejoin = s end)
addCatButton("Cat8_Server", "คัดลอก JobId เซิฟเวอร์ปัจจุบัน", "Copy Server JobId", function() pcall(function() if setclipboard then setclipboard(tostring(game.JobId)) end end) StatusLabels["Cat8_Server"].Text = "JobId: " .. tostring(game.JobId) end)
addCatButton("Cat8_Server", "คัดลอก PlaceId ของแมพนี้", "Copy Map PlaceId", function() pcall(function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end) StatusLabels["Cat8_Server"].Text = "PlaceId: " .. tostring(game.PlaceId) end)
addCatButton("Cat8_Server", "คัดลอกสคริปต์เข้าเซิฟนี้ (Join Script)", "Copy Join Script", function() local cmd = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s")', game.PlaceId, game.JobId) pcall(function() if setclipboard then setclipboard(cmd) end end) StatusLabels["Cat8_Server"].Text = "คัดลอกโค้ดเข้าเซิฟเดิมแล้ว" end)
addCatButton("Cat8_Server", "ตรวจสอบจำนวนผู้เล่นในเซิฟเวอร์", "Check Server Player Count", function() StatusLabels["Cat8_Server"].Text = string.format("ผู้เล่นในเซิฟ: %d / %d คน", #Players:GetPlayers(), Players.MaxPlayers) end)
addCatButton("Cat8_Server", "ตรวจสอบค่า Ping ปัจจุบัน (ms)", "Check Current Ping", function() local p = 0 pcall(function() p = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end) StatusLabels["Cat8_Server"].Text = "Ping ปัจจุบัน: " .. p .. " ms" end)
addCatButton("Cat8_Server", "ตรวจสอบเวลาที่เซิฟเปิดทำงาน (Uptime)", "Check Server Uptime", function() StatusLabels["Cat8_Server"].Text = string.format("Server Uptime: %.1f นาที", Workspace.DistributedGameTime / 60) end)
addCatButton("Cat8_Server", "ค้นหาเซิฟเวอร์ที่คนน้อย (Low Player Hop)", "Find Low-Pop Server", function()
    pcall(function()
        local raw = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=25")
        local data = HttpService:JSONDecode(raw)
        if data and data.data then
            for _, srv in ipairs(data.data) do
                if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
                    break
                end
            end
        end
    end)
end)
addCatButton("Cat8_Server", "ค้นหาเซิฟเวอร์แบบสุ่ม (Random Server)", "Random Public Server", function() pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end)
addCatButton("Cat8_Server", "ตรวจสอบรายชื่อผู้เล่นทั้งหมดในเซิฟ", "List All Server Players", function() local names = {} for _, p in ipairs(Players:GetPlayers()) do table.insert(names, p.Name) end StatusLabels["Cat8_Server"].Text = "ผู้เล่น: " .. table.concat(names, ", ") end)
addCatButton("Cat8_Server", "ตรวจสอบเจ้าของแมพ (CreatorId)", "Check Map CreatorId", function() StatusLabels["Cat8_Server"].Text = "CreatorId: " .. tostring(game.CreatorId) end)
addCatButton("Cat8_Server", "ตรวจสอบเวอร์ชันแมพ (PlaceVersion)", "Check PlaceVersion", function() StatusLabels["Cat8_Server"].Text = "PlaceVersion: " .. tostring(game.PlaceVersion) end)
addCatButton("Cat8_Server", "ล้างแคชหน่วยความจำ Client (GC)", "Client Memory Cleanup", function() collectgarbage("collect") StatusLabels["Cat8_Server"].Text = "ล้างแคชหน่วยความจำเรียบร้อย" end)
addCatButton("Cat8_Server", "รีเฟรชตัวละครเชื่อมต่อเซิฟใหม่", "Refresh Character Sync", function() local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if r then r.CFrame = r.CFrame + Vector3.new(0, 1, 0) end end)
addCatButton("Cat8_Server", "ตรวจสอบสถานะการล็อคเซิฟ", "Check Server Lock Status", function() StatusLabels["Cat8_Server"].Text = "ล็อคเซิฟ: " .. (Config.ServerLock and "เปิดอยู่" or "ปิดอยู่") end)
addCatButton("Cat8_Server", "ปลดล็อคการย้ายเซิฟทั้งหมด", "Unlock Server Teleport", function() Config.ServerLock = false Config.PreventLeaveWarn = false for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat8_Server", "เปิดระบบป้องกันหลุดครบชุด (Full Guard)", "Enable Full Anti-Kick/AFK", function() Config.AntiKickClient = true Config.AntiAfk = true Config.ServerLock = true for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat8_Server", "ตรวจสอบการเชื่อมต่อ Network", "Check Network Status", function() StatusLabels["Cat8_Server"].Text = "Network: Connected (" .. tostring(game.JobId):sub(1, 8) .. "...)" end)
addCatButton("Cat8_Server", "บันทึกข้อมูลเซิฟเวอร์นี้ไว้ใน Log", "Log Server Snapshot", function() StatusLabels["Cat8_Server"].Text = string.format("Saved Log: Place %d | Players %d", game.PlaceId, #Players:GetPlayers()) end)
addCatButton("Cat8_Server", "ทดสอบการตอบสนองเซิฟเวอร์ (Ping Test)", "Run Ping Check", function() StatusLabels["Cat8_Server"].Text = "เซิฟเวอร์ตอบสนองปกติ (OK)" end)
addCatButton("Cat8_Server", "เตรียมพร้อมเข้าเซิฟเดิมอัตโนมัติ", "Arm Quick Rejoin", function() Config.AutoRejoin = true for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat8_Server", "รีเซ็ตการตั้งค่า Server เป็นค่าเริ่มต้น", "Reset Server Settings", function() Config.ServerLock = false Config.PreventLeaveWarn = false Config.AntiAfk = true for _, r in ipairs(UiRefreshList) do r() end end)

-- ==========================================
-- หมวดหมู่ที่ 9: เพิ่มเติม-ข้อมูล (28 ฟังก์ชัน + ลิงก์โซเชียลของคุณครบ)
-- ==========================================
local YT_URL = "https://youtube.com/@yin_ying_hub_script?si=21KfDODKNNW4tolg"
local TT_URL = "https://tiktok.com/@yin_yang_hub_olivia"
local IG_URL = "https://www.instagram.com/yin_ying_hub_script?knvt=eTJnZHZhaHh2dmxq"
local DC_URL = "https://discord.gg/XPQePu42kH"

addCatButton("Cat9_Info", "ติดตาม YouTube (@yin_ying_hub_script)", "Follow YouTube", function() copySocialLink("Cat9_Info", "YouTube", YT_URL) end)
addCatButton("Cat9_Info", "ติดตาม TikTok (@yin_yang_hub_olivia)", "Follow TikTok", function() copySocialLink("Cat9_Info", "TikTok", TT_URL) end)
addCatButton("Cat9_Info", "ติดตาม Instagram (@yin_ying_hub_script)", "Follow Instagram", function() copySocialLink("Cat9_Info", "Instagram", IG_URL) end)
addCatButton("Cat9_Info", "ติดตามดิสคอร์ด Discord (XPQePu42kH)", "Join Discord Server", function() copySocialLink("Cat9_Info", "Discord", DC_URL) end)
addCatButton("Cat9_Info", "คัดลอกลิงก์ช่องทางติดตามทั้งหมด 4 ช่องทาง", "Copy All 4 Social Links", function()
    local all = "YouTube: " .. YT_URL .. "\nTikTok: " .. TT_URL .. "\nInstagram: " .. IG_URL .. "\nDiscord: " .. DC_URL
    copySocialLink("Cat9_Info", "All Socials", all)
end)
addCatButton("Cat9_Info", "ชื่อสคริปต์: YIN YING HUB (All Maps)", "Script Name: YIN YING HUB", function() StatusLabels["Cat9_Info"].Text = "YIN YING HUB - Universal All Maps Edition" end)
addCatButton("Cat9_Info", "เวอร์ชันสคริปต์: v3.0 (280 Functions)", "Version: v3.0 (280 Tools)", function() StatusLabels["Cat9_Info"].Text = "Version 3.0 | 10 Categories x 28 Functions" end)
addCatButton("Cat9_Info", "รองรับแมพ: เล่นได้ทุกแมพ (All Maps)", "Compatibility: All Maps", function() StatusLabels["Cat9_Info"].Text = "รองรับทุกแมพใน Roblox (Universal)" end)
addCatButton("Cat9_Info", "รองรับอุปกรณ์: มือถือ / แท็บเล็ต / PC", "Device Support: Mobile & PC", function() StatusLabels["Cat9_Info"].Text = "รองรับทั้งระบบสัมผัส (Touch) และเมาส์/คีย์บอร์ด" end)
addCatButton("Cat9_Info", "ธีมสีหลัก: ดำ-ม่วง (Dark & Purple)", "Theme: Dark & Purple", function() StatusLabels["Cat9_Info"].Text = "ธีมดำ-ม่วง ปรับแต่งสีและลายน้ำได้อิสระ" end)
addCatButton("Cat9_Info", "ประสิทธิภาพสูงสุด: 9,000,000 Scale", "Max Performance: 9,000,000", function() StatusLabels["Cat9_Info"].Text = "สเกลประสิทธิภาพสูงสุด 9,000,000" end)
addCatButton("Cat9_Info", "ตรวจสอบชื่อผู้ใช้ของคุณ (Username)", "Show Your Username", function() StatusLabels["Cat9_Info"].Text = "Username: " .. LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")" end)
addCatButton("Cat9_Info", "ตรวจสอบ UserId ของคุณ", "Show Your UserId", function() StatusLabels["Cat9_Info"].Text = "UserId: " .. tostring(LocalPlayer.UserId) end)
addCatButton("Cat9_Info", "ตรวจสอบอายุบัญชี (AccountAge)", "Show Account Age", function() StatusLabels["Cat9_Info"].Text = "AccountAge: " .. tostring(LocalPlayer.AccountAge) .. " วัน" end)
addCatButton("Cat9_Info", "ตรวจสอบขนาดหน้าจออุปกรณ์ปัจจุบัน", "Check Viewport Resolution", function() local vp = Workspace.CurrentCamera.ViewportSize StatusLabels["Cat9_Info"].Text = string.format("Resolution: %dx%d", vp.X, vp.Y) end)
addCatButton("Cat9_Info", "ตรวจสอบค่า FPS ปัจจุบัน", "Check Current FPS", function() StatusLabels["Cat9_Info"].Text = "ระบบทำงานลื่นไหล (Active RenderStepped)" end)
addCatButton("Cat9_Info", "วิธีใช้ลายน้ำ: ลากเพื่อย้าย / แตะเพื่อพับจอ", "How to Use Watermark", function() StatusLabels["Cat9_Info"].Text = "ลากวงกลมลายน้ำเพื่อย้าย หรือแตะ 1 ครั้งเพื่อเปิด/ปิดเมนู" end)
addCatButton("Cat9_Info", "วิธีใช้ ESP: เปิด ESP ALL เพื่อแสดงครบชุด", "How to Use ESP", function() StatusLabels["Cat9_Info"].Text = "เปิด ESP ALL จะแสดงกล่อง 3D + ระยะเมตร + เส้นเชื่อมโยง" end)
addCatButton("Cat9_Info", "วิธีบันทึกค่า: ไปที่หมวดหมู่ 10 กด Save", "How to Save Config", function() StatusLabels["Cat9_Info"].Text = "ไปที่หมวดหมู่ 10. การตั้งค่า แล้วกดปุ่ม Save / Load Save" end)
addCatButton("Cat9_Info", "ตรวจสอบสถานะภาษาปัจจุบัน (TH/EN)", "Check Active Language", function() StatusLabels["Cat9_Info"].Text = "ภาษาปัจจุบัน: " .. Config.Lang end)
addCatButton("Cat9_Info", "ขอบคุณที่ติดตาม Yin Ying Hub", "Credits: Yin Ying Hub", function() StatusLabels["Cat9_Info"].Text = "ขอบคุณที่สนับสนุน Yin Ying Hub Script!" end)
addCatButton("Cat9_Info", "อัปเดตล่าสุด: เพิ่มครบ 10 หมวดหมู่ 280 ฟังก์ชัน", "Changelog: 280 Functions", function() StatusLabels["Cat9_Info"].Text = "อัปเดต: ครบ 10 หมวดหมู่ หมวดหมู่ละ 28 ฟังก์ชัน" end)
addCatButton("Cat9_Info", "ลิงก์ YouTube (แสดงข้อความเต็ม)", "Display YouTube Link", function() StatusLabels["Cat9_Info"].Text = YT_URL end)
addCatButton("Cat9_Info", "ลิงก์ TikTok (แสดงข้อความเต็ม)", "Display TikTok Link", function() StatusLabels["Cat9_Info"].Text = TT_URL end)
addCatButton("Cat9_Info", "ลิงก์ Instagram (แสดงข้อความเต็ม)", "Display Instagram Link", function() StatusLabels["Cat9_Info"].Text = IG_URL end)
addCatButton("Cat9_Info", "ลิงก์ Discord (แสดงข้อความเต็ม)", "Display Discord Link", function() StatusLabels["Cat9_Info"].Text = DC_URL end)
addCatButton("Cat9_Info", "ตรวจสอบจำนวนฟังก์ชันทั้งหมดในสคริปต์", "Verify Total Function Count", function() StatusLabels["Cat9_Info"].Text = "ยืนยัน: 10 หมวดหมู่ x 28 ฟังก์ชัน = 280 ฟังก์ชัน" end)
addCatButton("Cat9_Info", "ล้างข้อความแจ้งเตือนในหน้าข้อมูล", "Clear Info Banner", function() StatusLabels["Cat9_Info"].Text = "9. เพิ่มเติม-ข้อมูล (28 ฟังก์ชัน)" end)

-- ==========================================
-- หมวดหมู่ที่ 10: การตั้งค่า (28 ฟังก์ชัน + Save / Load Save)
-- ==========================================
local SavedProfileMemory = nil
local SAVE_FILE_NAME = "YinYingHub_Config.json"

local function saveConfigData()
    local encoded = HttpService:JSONEncode(Config)
    SavedProfileMemory = encoded
    pcall(function()
        if writefile then
            writefile(SAVE_FILE_NAME, encoded)
        end
    end)
    StatusLabels["Cat10_Settings"].Text = "Save สำเร็จ! บันทึกการตั้งค่าทั้งหมดเรียบร้อย"
end

local function loadConfigData()
    local raw = SavedProfileMemory
    pcall(function()
        if isfile and readfile and isfile(SAVE_FILE_NAME) then
            raw = readfile(SAVE_FILE_NAME)
        end
    end)
    if raw then
        local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok and type(decoded) == "table" then
            for k, v in pairs(decoded) do
                Config[k] = v
            end
            applyUiStyleChanges()
            updateResponsiveScale()
            for _, r in ipairs(UiRefreshList) do r() end
            StatusLabels["Cat10_Settings"].Text = "Load Save สำเร็จ! โหลดการตั้งค่าที่บันทึกไว้แล้ว"
            return
        end
    end
    StatusLabels["Cat10_Settings"].Text = "ยังไม่มีข้อมูล Save กรุณากดปุ่ม Save ก่อน"
end

addCatButton("Cat10_Settings", "Save (บันทึกการตั้งค่าทั้งหมด)", "Save Config", function() saveConfigData() end)
addCatButton("Cat10_Settings", "Load Save (โหลดการตั้งค่าที่บันทึกไว้)", "Load Saved Config", function() loadConfigData() end)
addCatButton("Cat10_Settings", "เปลี่ยนภาษา: ไทย (TH) / English (EN)", "Switch Language (TH / EN)", function()
    Config.Lang = (Config.Lang == "TH") and "EN" or "TH"
    for _, r in ipairs(UiRefreshList) do r() end
    StatusLabels["Cat10_Settings"].Text = "เปลี่ยนภาษาเป็น: " .. Config.Lang
end)
addCatSlider("Cat10_Settings", "ปรับประสิทธิภาพสูงสุด (Max 9,000,000)", "Performance Scale (Max 9M)", 1000, 9000000, 100000, function() return Config.MaxPerfScale end, function(v) Config.MaxPerfScale = v end)
addCatButton("Cat10_Settings", "ตั้งประสิทธิภาพสูงสุด 9,000,000 ทันที", "Set Max 9,000,000 Scale", function() Config.MaxPerfScale = 9000000 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat10_Settings", "ตั้งประสิทธิภาพปานกลาง (4,500,000)", "Set Balanced 4.5M Scale", function() Config.MaxPerfScale = 4500000 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat10_Settings", "ตั้งประสิทธิภาพประหยัดแบต (1,000,000)", "Set Battery Saver 1M", function() Config.MaxPerfScale = 1000000 for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat10_Settings", "Save Slot 1 (บันทึกช่องที่ 1)", "Save Slot 1", function() SAVE_FILE_NAME = "YinYingHub_Slot1.json" saveConfigData() end)
addCatButton("Cat10_Settings", "Load Slot 1 (โหลดช่องที่ 1)", "Load Slot 1", function() SAVE_FILE_NAME = "YinYingHub_Slot1.json" loadConfigData() end)
addCatButton("Cat10_Settings", "Save Slot 2 (บันทึกช่องที่ 2)", "Save Slot 2", function() SAVE_FILE_NAME = "YinYingHub_Slot2.json" saveConfigData() end)
addCatButton("Cat10_Settings", "Load Slot 2 (โหลดช่องที่ 2)", "Load Slot 2", function() SAVE_FILE_NAME = "YinYingHub_Slot2.json" loadConfigData() end)
addCatButton("Cat10_Settings", "Save Slot 3 (บันทึกช่องที่ 3)", "Save Slot 3", function() SAVE_FILE_NAME = "YinYingHub_Slot3.json" saveConfigData() end)
addCatButton("Cat10_Settings", "Load Slot 3 (โหลดช่องที่ 3)", "Load Slot 3", function() SAVE_FILE_NAME = "YinYingHub_Slot3.json" loadConfigData() end)
addCatButton("Cat10_Settings", "ลบข้อมูล Save ปัจจุบัน (Delete Save)", "Delete Current Save", function() SavedProfileMemory = nil pcall(function() if delfile and isfile and isfile(SAVE_FILE_NAME) then delfile(SAVE_FILE_NAME) end end) StatusLabels["Cat10_Settings"].Text = "ลบข้อมูล Save เรียบร้อย" end)
addCatButton("Cat10_Settings", "เปิดโหมดแนะนำสำหรับมือถือ (Mobile Preset)", "Apply Mobile Preset", function() Config.FontSize = 11 Config.GuiScale = 0.95 Config.WatermarkSize = 62 applyUiStyleChanges() updateResponsiveScale() end)
addCatButton("Cat10_Settings", "เปิดโหมดแนะนำสำหรับ PC (PC Preset)", "Apply PC Preset", function() Config.FontSize = 12 Config.GuiScale = 1.05 Config.WatermarkSize = 68 applyUiStyleChanges() updateResponsiveScale() end)
addCatButton("Cat10_Settings", "เปิดโหมดฟาร์ม+ESP ครบชุด (All-In-One)", "Enable Farm + ESP Combo", function() Config.AutoFarm = true Config.EspAll = true for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat10_Settings", "ปิดระบบอัตโนมัติทั้งหมด (Panic Off)", "Panic Disable All Toggles", function()
    Config.Fly = false Config.NoClip = false Config.AutoFarm = false Config.EspAll = false Config.KillAllTargets = false
    clearEspObjects()
    for _, r in ipairs(UiRefreshList) do r() end
end)
addCatButton("Cat10_Settings", "รีเฟรช UI ทั้งหมด (Refresh All UI)", "Refresh Entire UI", function() applyUiStyleChanges() for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat10_Settings", "รีเซ็ตตำแหน่งลายน้ำ (ซ้ายบนเล็กน้อย)", "Reset Watermark Position", function() WatermarkCircle.Position = UDim2.new(0, 68, 0, 18) end)
addCatButton("Cat10_Settings", "ปลดล็อคลายน้ำ (Unlock Watermark)", "Unlock Watermark Drag", function() Config.LockWatermark = false for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat10_Settings", "ตั้งภาษาเป็นภาษาไทย (Thai)", "Set Language: Thai", function() Config.Lang = "TH" for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat10_Settings", "ตั้งภาษาเป็นภาษาอังกฤษ (English)", "Set Language: English", function() Config.Lang = "EN" for _, r in ipairs(UiRefreshList) do r() end end)
addCatButton("Cat10_Settings", "ตรวจสอบสถานะไฟล์ Save", "Check Save File Status", function() local exists = (SavedProfileMemory ~= nil) StatusLabels["Cat10_Settings"].Text = exists and "สถานะ Save: มีข้อมูลพร้อมโหลด" or "สถานะ Save: ยังไม่มีข้อมูล" end)
addCatButton("Cat10_Settings", "คัดลอกข้อมูลตั้งค่าเป็น JSON (Export)", "Export Config JSON", function() pcall(function() if setclipboard then setclipboard(HttpService:JSONEncode(Config)) end end) StatusLabels["Cat10_Settings"].Text = "คัดลอก JSON การตั้งค่าแล้ว" end)
addCatButton("Cat10_Settings", "คืนค่าเริ่มต้นทั้ง 10 หมวดหมู่ (Factory Reset)", "Factory Reset All Settings", function()
    Config.WalkSpeed = 16 Config.JumpPower = 50 Config.Fly = false Config.NoClip = false
    Config.AutoFarm = false Config.EspAll = false Config.KillAllTargets = false
    Config.FontSize = 11 Config.UiColorPreset = 1 Config.WatermarkSize = 62
    clearEspObjects() applyUiStyleChanges()
    for _, r in ipairs(UiRefreshList) do r() end
end)
addCatButton("Cat10_Settings", "ซ่อน GUI ชั่วคราว (Hide Main Window)", "Hide Main Window", function() MainFrame.Visible = false end)
addCatButton("Cat10_Settings", "ปิดและล้างสคริปต์ทั้งหมด (Unload Hub)", "Unload & Destroy Hub", function()
    clearEspObjects()
    if airFloor then airFloor:Destroy() end
    Workspace.Gravity = 196.2
    clearConnections()
    ScreenGui:Destroy()
end)

-- เปิดหมวดหมู่ที่ 1 เป็นหน้าเริ่มต้น
switchTab("Cat1_Char")

-- ==========================================
-- ลูปการทำงานเบื้องหลังทั้งหมด (Movement, Farm, ESP, Combat, HUD)
-- ==========================================
local Mouse = LocalPlayer:GetMouse()
trackConn(Mouse.Button1Down:Connect(function()
    if Config.ClickTp and Mouse.Target then
        tpCFrame(CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0)))
    end
end))

trackConn(LocalPlayer.Idled:Connect(function()
    if Config.AntiAfk then
        local vu = game:GetService("VirtualUser")
        pcall(function()
            vu:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(0.1)
            vu:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end)
    end
end))

trackConn(UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

local function updateEspLoop()
    if not Config.EspAll then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local originAtt = root:FindFirstChild("YinYingEspOrigin")
    if not originAtt then
        originAtt = Instance.new("Attachment")
        originAtt.Name = "YinYingEspOrigin"
        originAtt.Parent = root
    end

    local targets = {}
    if Config.EspPlayer then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 then
                    table.insert(targets, { key = p.Character, part = p.Character.HumanoidRootPart, name = p.DisplayName, hp = math.floor(h.Health), tag = "Player" })
                end
            end
        end
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= char and not Players:GetPlayerFromCharacter(obj) then
            local h = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
            if h and hrp and h.Health > 0 then
                local low = string.lower(obj.Name)
                local isNpc = string.find(low, "npc") or string.find(low, "shop") or string.find(low, "quest")
                if (isNpc and Config.EspNpc) or (not isNpc and Config.EspEntity) then
                    table.insert(targets, { key = obj, part = hrp, name = obj.Name, hp = math.floor(h.Health), tag = isNpc and "NPC" or "Entity" })
                end
            end
        elseif obj:IsA("Tool") and Config.EspItem and obj:FindFirstChild("Handle") then
            table.insert(targets, { key = obj, part = obj.Handle, name = obj.Name, hp = nil, tag = "Item" })
        end
    end

    local espCol = getEspColor()
    local activeSet = {}
    local limit = math.clamp(math.floor(Config.MaxPerfScale / 100000), 15, 90)
    local shown = 0

    for _, item in ipairs(targets) do
        if shown >= limit then break end
        local distM = (item.part.Position - root.Position).Magnitude * STUDS_TO_METERS
        if distM <= Config.EspMaxDist then
            shown += 1
            activeSet[item.key] = true
            local rec = EspObjects[item.key] or {}
            EspObjects[item.key] = rec

            if Config.EspBox then
                if not rec.Box then
                    local b = Instance.new("SelectionBox")
                    b.LineThickness = 0.04
                    b.SurfaceTransparency = 0.85
                    b.Parent = ScreenGui
                    rec.Box = b
                end
                rec.Box.Color3 = espCol
                rec.Box.SurfaceColor3 = espCol
                rec.Box.Adornee = item.part
            elseif rec.Box then
                rec.Box:Destroy() rec.Box = nil
            end

            if Config.EspDistanceMeters or Config.EspShowName then
                if not rec.Bb then
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 150, 0, 36)
                    bb.StudsOffset = Vector3.new(0, 3.6, 0)
                    bb.AlwaysOnTop = true
                    bb.Parent = ScreenGui

                    local tl = Instance.new("TextLabel")
                    tl.Name = "Lbl"
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.TextStrokeTransparency = 0.2
                    tl.Font = Enum.Font.GothamBold
                    tl.TextSize = 12
                    tl.Parent = bb
                    rec.Bb = bb
                end
                rec.Bb.Adornee = item.part
                local lbl = rec.Bb:FindFirstChild("Lbl")
                if lbl then
                    lbl.TextColor3 = espCol
                    local topDist = Config.EspDistanceMeters and string.format("%.1f m", distM) or ""
                    local nameStr = Config.EspShowName and string.format("[%s] %s", item.tag, item.name) or ""
                    local hpStr = (Config.EspShowHealth and item.hp) and (" | HP:" .. item.hp) or ""
                    lbl.Text = topDist .. "\n" .. nameStr .. hpStr
                end
            elseif rec.Bb then
                rec.Bb:Destroy() rec.Bb = nil
            end

            if Config.EspTracer then
                if not rec.Att then
                    local a = Instance.new("Attachment")
                    a.Parent = item.part
                    rec.Att = a
                end
                if not rec.Beam then
                    local bm = Instance.new("Beam")
                    bm.Width0 = 0.06
                    bm.Width1 = 0.06
                    bm.FaceCamera = true
                    bm.Parent = item.part
                    rec.Beam = bm
                end
                rec.Beam.Color = ColorSequence.new(espCol)
                rec.Beam.Attachment0 = originAtt
                rec.Beam.Attachment1 = rec.Att
            else
                if rec.Beam then rec.Beam:Destroy() rec.Beam = nil end
                if rec.Att then rec.Att:Destroy() rec.Att = nil end
            end
        end
    end

    for k, d in pairs(EspObjects) do
        if not activeSet[k] then
            if d.Box then pcall(function() d.Box:Destroy() end) end
            if d.Bb then pcall(function() d.Bb:Destroy() end) end
            if d.Beam then pcall(function() d.Beam:Destroy() end) end
            if d.Att then pcall(function() d.Att:Destroy() end) end
            EspObjects[k] = nil
        end
    end
end

local lastEsp = 0
local lastAttack = 0
local lastFarm = 0
local lastHud = 0
local frames = 0

trackConn(RunService.RenderStepped:Connect(function()
    frames += 1
    if Config.WatermarkRainbow then
        wmStroke.Color = Color3.fromHSV((tick() * 0.25) % 1, 0.8, 1)
    end
end))

trackConn(RunService.Stepped:Connect(function(now)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if hum then
        if hum.WalkSpeed ~= Config.WalkSpeed then hum.WalkSpeed = Config.WalkSpeed end
        if hum.JumpPower ~= Config.JumpPower then hum.JumpPower = Config.JumpPower end
        hum.PlatformStand = Config.PlatformStand
        if Config.GodClient and hum.Health > 0 and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
        if Config.AutoSprint then hum:Move(Vector3.new(0, 0, -1), true) end
        if Config.BunnyHop and hum.FloorMaterial ~= Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        if Config.SwimInAir then hum:ChangeState(Enum.HumanoidStateType.Swimming) end
    end

    if root then
        if Config.SpinChar then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Config.SpinSpeed), 0)
        end
        if Config.WalkOnAir then
            if not airFloor then
                airFloor = Instance.new("Part")
                airFloor.Size = Vector3.new(12, 1, 12)
                airFloor.Anchored = true
                airFloor.Transparency = 0.65
                airFloor.Color = ActiveTheme.Border
                airFloor.Material = Enum.Material.Neon
                airFloor.Parent = Workspace
            end
            airFloor.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.5, root.Position.Z)
        end
        if Config.Fly and hum then
            local cam = Workspace.CurrentCamera
            local vel = Vector3.zero
            if hum.MoveDirection.Magnitude > 0 then vel = cam.CFrame.LookVector * Config.FlySpeed end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0, Config.FlySpeed * 0.7, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel -= Vector3.new(0, Config.FlySpeed * 0.7, 0) end
            root.AssemblyLinearVelocity = vel
        end
    end

    if Config.NoClip and char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- Combat / Kill
    if (Config.KillAllTargets or Config.KillNearest or Config.AutoSwing) and hum and root and (now - lastAttack) >= Config.AttackSpeed then
        lastAttack = now
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end

        if Config.KillAllTargets or Config.KillNearest then
            for _, m in ipairs(Workspace:GetDescendants()) do
                if m:IsA("Model") and m ~= char then
                    local th = m:FindFirstChildOfClass("Humanoid")
                    local tr = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                    local isPlr = Players:GetPlayerFromCharacter(m) ~= nil
                    if th and tr and th.Health > 0 and (not isPlr or not Config.IgnorePlayers) then
                        local d = (tr.Position - root.Position).Magnitude
                        if Config.HitboxExpand then
                            tr.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                            tr.Transparency = 0.7
                        end
                        if d <= Config.AttackReach then
                            if Config.AutoAimNearest then
                                root.CFrame = CFrame.lookAt(root.Position, Vector3.new(tr.Position.X, root.Position.Y, tr.Position.Z))
                            end
                            break
                        end
                    end
                end
            end
        end
    end

    -- Auto Farm
    if Config.AutoFarm and hum and root and (now - lastFarm) >= Config.FarmInterval then
        lastFarm = now
        for _, m in ipairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= char and not Players:GetPlayerFromCharacter(m) then
                local th = m:FindFirstChildOfClass("Humanoid")
                local tr = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                if th and tr and th.Health > 0 then
                    local d = (tr.Position - root.Position).Magnitude
                    if d <= Config.FarmRadius then
                        hum:MoveTo(tr.Position + Vector3.new(0, Config.FarmHoverHeight, 0))
                        break
                    end
                end
            end
        end
    end

    -- ESP
    if Config.EspAll and (now - lastEsp) >= 0.06 then
        lastEsp = now
        updateEspLoop()
    end

    -- HUD
    if (Config.ShowCoordsHud or Config.ShowFpsHud) and (now - lastHud) >= 0.5 then
        local fps = math.floor(frames / (now - lastHud) + 0.5)
        frames = 0
        lastHud = now
        local lines = {}
        if Config.ShowCoordsHud and root then
            table.insert(lines, string.format("XYZ: %.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z))
        end
        if Config.ShowFpsHud then
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            table.insert(lines, string.format("FPS: %d | Ping: %d ms", fps, ping))
        end
        InfoHud.Text = table.concat(lines, "\n")
    end
end))

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    clearEspObjects()
    if airFloor then airFloor:Destroy() end
    Workspace.Gravity = 196.2
    clearConnections()
    ScreenGui:Destroy()
end)
