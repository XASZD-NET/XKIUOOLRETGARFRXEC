-- YINYANG HUB OLIVIA X VORTEX ENGINE DELTA 2.5 | Studio Edition (461x312)
-- แท็บ: Games / Farm / Character / ESP-AFK / Code / Settings
-- Roblox Studio LocalScript edition (วางใน StarterPlayerScripts หรือ StarterGui)
--
-- หมายเหตุด้านความปลอดภัย (คงไว้เหมือนเดิม):
-- 1) รายการ Loader ภายนอกแสดงเป็นข้อมูลเท่านั้น ไม่ดาวน์โหลดหรือรันโค้ดจาก URL
-- 2) ESP เป็นเครื่องมือ Debug ใน Studio เท่านั้น
-- 3) AFK แสดงสถานะ/แจ้งเตือนการไม่ใช้งาน ไม่จำลองอินพุตเพื่อหลบระบบ AFK
-- 4) Code tab แสดง/ตรวจข้อความเบื้องต้น ไม่รันโค้ดที่ผู้ใช้ป้อน
--
-- ปุ่ม RightShift = ซ่อน/แสดงหน้าต่าง | ฟังก์ชันตัวละคร/ฟาร์ม/ดาเมจ/ESP ใช้ได้เฉพาะ Roblox Studio

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("YinYangDeltaHub")
if oldGui then
	oldGui:Destroy() -- Destroying จะเรียก cleanup ของสคริปต์เก่าให้เอง
end

---------------------------------------------------------------------
-- 1. GAME CATEGORIES (ข้อมูลสำหรับแสดงผลเท่านั้น)
---------------------------------------------------------------------
local GameCategories = {
	{
		Category = "ขโมยไข่ (Steal An Egg)",
		Scripts = {
			{
				Name = "Steal A Eggs Loader",
				Desc = "miirandahub/loader/main/stealaeggs",
				Code = "-- External loader omitted; metadata only, not executable."
			},
			{
				Name = "Chilli Hub",
				Desc = "tienkhanh1/spicy/main/Chilli.lua",
				Code = "-- External loader omitted; metadata only, not executable."
			}
		}
	},
	{
		Category = "คู่แข่ง (Rivals)",
		Scripts = {
			{
				Name = "Luarmor Loader (2529a5f9...)",
				Desc = "api.luarmor.net/files/v3/loaders/2529a5f9dfddd5523ca4e22f21cceffa.lua",
				Code = "-- External loader omitted; metadata only, not executable."
			},
			{
				Name = "Aqua Hub",
				Desc = "flowauth.net/v1/loaders/Aqua-Hub.lua",
				Code = "-- External loader omitted; metadata only, not executable."
			}
		}
	},
	{
		Category = "บล็อกฟุต (Blox Fruits)",
		Scripts = {
			{
				Name = "Adonis Loader",
				Desc = "caubebietbuon/Misozz/main/Adonis.lua",
				Code = "-- External loader omitted; metadata only, not executable."
			}
		}
	},
	{
		Category = "ให้อาหารสัตว์ (Feed Pet)",
		Scripts = {
			{
				Name = "Auto Feed Pet Template",
				Desc = "เทมเพลตสำหรับพัฒนาในเกมของตนเอง",
				Code = '-- ตัวอย่างโครงสร้างสำหรับเกมของคุณเอง\n-- กำหนด RemoteEvent และเงื่อนไขฝั่ง Server ให้ตรงกับระบบเกม\nprint("Feed Pet template selected")'
			}
		}
	}
}

-- หมวดพิเศษ: รายการโปรด (สร้างจากปุ่ม ★ ในการ์ดสคริปต์)
local FavoritesCategory = {Category = "★ รายการโปรด", IsFavorites = true, Scripts = {}}
local Favorites = {} -- [scriptData] = true

---------------------------------------------------------------------
-- 2. CONFIG
---------------------------------------------------------------------
local Config = {
	AssetImage = "rbxassetid://109313395011601",
	Shape = "Square",
	StrokeThickness = 2,
	BgColor = Color3.fromRGB(48, 25, 110),
	AccentBlue = Color3.fromRGB(37, 99, 235),
	ButtonWhite = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(15, 23, 42),
	TextLight = Color3.fromRGB(255, 255, 255),
	TextMuted = Color3.fromRGB(71, 85, 105),

	WatermarkText = "YINYANG HUB OLIVIA X VORTEX ENGINE DELTA 2.5",
	WatermarkShortText = "VORTEX 2.5",
	WatermarkShape = "Square",
	WatermarkStroke = 2,
	WatermarkColor = Color3.fromRGB(59, 130, 246),

	EspEnabled = false,
	AfkEnabled = false,

	-- Character (ทดสอบตัวละครใน Studio)
	SpeedEnabled = false,
	SpeedValue = 50,
	JumpEnabled = false,
	JumpValue = 100,
	InfJumpEnabled = false,
	FlyEnabled = false,
	FlyValue = 60,
	AutoHealEnabled = false,
	HealValue = 10,
	GodEnabled = false,

	-- Auto Farm (ไอเทมในเกมของคุณ: ติด Tag หรือวางใน Folder ชื่อเดียวกัน)
	FarmEnabled = false,
	FarmMode = "Fly", -- "Fly" หรือ "Warp" (เลือกได้อย่างเดียว)
	FarmSpeed = 60,
	FarmTag = "YYH_Farm",

	AfkSeconds = 60,
	Language = "TH", -- "TH" หรือ "EN" (สลับได้ที่ Settings)
	DamageUnlocked = false,

	-- Damage (ทดสอบดาเมจกับศัตรูในเกมของคุณ ใน Studio)
	DamageEnabled = false,
	DamageValue = 1000,
	EnemyTag = "YYH_Enemy",
	Hotkey = Enum.KeyCode.RightShift,
	YouTubeURL = "https://youtube.com/@yin_ying_hub_script",
	TikTokURL = "https://tiktok.com/@yin_yang_hub_olivia"
}

local DAMAGE_MAX = 4.41004e21 -- 4,410,040,000,000,000,000,000 = 4,410.04Qi

-- ภาษา / Language: TR = ไทย -> English (ใช้ผ่าน L() และปุ่ม LANGUAGE ในหน้า Settings)
local TR = {
	["-- เลือกสคริปต์จากแท็บ Games เพื่อดูโค้ด"] = "-- Select a script from the Games tab to view its code",
	["วงเล็บ '%s' ไม่ตรงคู่ที่บรรทัด %d"] = "Bracket '%s' has no match at line %d",
	["วงเล็บ '%s' ที่บรรทัด %d ยังไม่ถูกปิด"] = "Bracket '%s' at line %d is not closed",
	["Lines: %d | Chars: %d | วงเล็บ: %s"] = "Lines: %d | Chars: %d | Brackets: %s",
	["\n⚠ พบคำสั่งที่โหลด/รันโค้ดภายนอก: "] = "\n⚠ Found external load/run commands: ",
	[" (ดูเท่านั้น ไม่รัน)"] = " (view only, not executed)",
	["เลือกข้อความทั้งหมดแล้ว (Ctrl+C เพื่อคัดลอก)"] = "All text selected (Ctrl+C to copy)",
	["🔍 ค้นหาสคริปต์ทุกหมวด..."] = "🔍 Search all scripts...",
	["%s\n(%d สคริปต์)"] = "%s\n(%d scripts)",
	[" — VIEW ONLY (ไม่รันโค้ด)"] = " — VIEW ONLY (code is not run)",
	["ไม่พบสคริปต์ที่ค้นหา"] = "No scripts found",
	["ยังไม่มีรายการโปรด\nกด ☆ ที่การ์ดสคริปต์เพื่อบันทึก"] = "No favorites yet\nTap ☆ on a script card to save it",
	["บันทึกลงรายการโปรดแล้ว"] = "Added to favorites",
	["นำออกจากรายการโปรดแล้ว"] = "Removed from favorites",
	["• Debug overlay ใช้ได้เฉพาะ Studio หรือเกมที่คุณเป็นเจ้าของ (แสดงชื่อ ระยะ เลือด)\n• AFK monitor วัดเวลาที่ไม่มีการกดเล่น แจ้งเตือนซ้ำทุกครบเวลาที่ตั้ง\n• ไม่จำลองการกดปุ่มเพื่อหลบระบบ AFK ของ Roblox"] = "• Debug overlay works only in Studio or a game you own (shows name, distance, health)\n• AFK monitor measures time without input and repeats the alert every set interval\n• Does not simulate key presses to dodge Roblox's AFK system",
	["Debug overlay ถูกปิด: ฟังก์ชันนี้จำกัดการใช้งานไว้ใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ"] = "Debug overlay disabled: this feature is limited to Roblox Studio or a game you own",
	["ใช้ได้เฉพาะใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ"] = "Only available in Roblox Studio or your own game",
	["%d ชม. %d นาที"] = "%d h %d min",
	["%d นาที %d วินาที"] = "%d min %d s",
	["%d วินาที"] = "%d s",
	["ไม่มีการใช้งาน: %s (แจ้งเตือนที่ %s)\nนานที่สุด: %s | แจ้งเตือนแล้ว: %d ครั้ง\nRoblox Idled: %d ครั้ง | ตรวจมาแล้ว: %s"] = "Idle: %s (alert at %s)\nLongest: %s | Alerts: %d\nRoblox Idled: %d | Monitored: %s",
	["⚠ AFK: ไม่มีการใช้งาน "] = "⚠ AFK: idle for ",
	["บันทึกการตั้งค่าแล้ว"] = "Settings saved",
	["รีเซ็ตเป็นค่าเริ่มต้นแล้ว (กด SAVE เพื่อบันทึก)"] = "Reset to defaults (press SAVE to keep)",
	["LINKS (แตะเพื่อเลือกข้อความ แล้วกด Ctrl+C)"] = "LINKS (tap to select, then Ctrl+C)",
	["แตะ Watermark หรือกด "] = "Tap the watermark or press ",
	[" = ซ่อน/แสดงหน้าต่าง"] = " = show/hide window",
	["ฟังก์ชันตัวละครใช้ได้เฉพาะใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ"] = "Character features are only available in Roblox Studio or your own game",
	["ฟังก์ชันตัวละครถูกปิด: จำกัดการใช้งานไว้ใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ (ใช้ทดสอบตัวละครในเกมของคุณ)"] = "Character features disabled: limited to Roblox Studio or a game you own (for testing your character in your own game)",
	["• SPEED/JUMP ปรับค่าตามสไลด์ และคืนค่าเดิมเมื่อปิด\n• FLY: WASD/จอยสติ๊กเคลื่อนที่ตามกล้อง, Space = ขึ้น, Shift = ลง\n• AUTO HEAL เพิ่มเลือดต่อเนื่อง / INFINITE HEALTH เลือดไม่จำกัด (ใน Play Solo; โหมดหลายผู้เล่นเซิร์ฟเวอร์ยังคุมเลือดจริง)"] = "• SPEED/JUMP follow the sliders and restore the original value when turned off\n• FLY: WASD/joystick moves relative to the camera, Space = up, Shift = down\n• AUTO HEAL restores health continuously / INFINITE HEALTH = unlimited health (Play Solo; on multiplayer servers the server still controls real health)",
	["\n🚀 COMBO: เปิด Speed + Jump + Infinite Jump — กดกระโดดเพื่อพุ่งไปข้างหน้า"] = "\n🚀 COMBO: Speed + Jump + Infinite Jump on — press jump to dash forward",
	["ITEM TAG / ชื่อ Folder ใน Workspace"] = "ITEM TAG / Folder name in Workspace",
	["• ใช้กับแมพของคุณ: ติด Tag (CollectionService) ให้ไอเทม หรือวางไว้ใน Folder ชื่อเดียวกับช่อง TAG\n• FLY = บินไปหาไอเทม / WARP = วาร์ปไปทับ (เลือกได้อย่างเดียว ไม่ทำพร้อมกัน)"] = "• For your own map: tag items with CollectionService or put them in a Folder with the same name as the TAG field\n• FLY = fly to the items / WARP = teleport onto them (pick one, not both)",
	["เช่น 4,410.04Qi"] = "e.g. 4,410.04Qi",
	["DAMAGE (ทดสอบกับศัตรูใน Studio) — สูงสุด "] = "DAMAGE (test on enemies in your game) — max ",
	["รูปแบบตัวเลขไม่ถูกต้อง"] = "Invalid number format",
	["ENEMY TAG / ชื่อ Folder ของศัตรู (ต้องมี Humanoid)"] = "ENEMY TAG / enemy Folder name (needs Humanoid)",
	["Damage ถูกปิด: จำกัดการใช้งานไว้ใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ"] = "Damage disabled: limited to Roblox Studio or a game you own",
	["DAMAGE: ON | %s ต่อครั้ง (ทุก %.1f วินาที, ระยะ %d studs)\nศัตรูในระยะ: %d | โจมตีแล้ว: %d ครั้ง"] = "DAMAGE: ON | %s per hit (every %.1f s, range %d studs)\nEnemies in range: %d | Hits: %d",
	["Auto Farm ถูกปิด: จำกัดการใช้งานไว้ใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ (ใช้ทดสอบแมพของคุณ)"] = "Auto Farm disabled: limited to Roblox Studio or a game you own (for testing your map)",
	["%.1f ครั้ง/วินาที"] = "%.1f per second",
	["FARM: %s | %s | %s\nพบไอเทม: %d | ไปถึงแล้ว: %d\nเป้าหมาย: %s"] = "FARM: %s | %s | %s\nItems found: %d | Visited: %d\nTarget: %s",
	["โหมดฟาร์ม: "] = "Farm mode: ",
	["ขโมยไข่ (Steal An Egg)"] = "Steal An Egg",
	["คู่แข่ง (Rivals)"] = "Rivals",
	["บล็อกฟุต (Blox Fruits)"] = "Blox Fruits",
	["ให้อาหารสัตว์ (Feed Pet)"] = "Feed Pet",
	["★ รายการโปรด"] = "★ Favorites",
	["เทมเพลตสำหรับพัฒนาในเกมของตนเอง"] = "Template for developing in your own game",
	["ADMIN CODE (ปลดล็อก Damage เท่านั้น)"] = "ADMIN CODE (unlocks Damage only)",
	["ใส่โค้ดจากแอดมิน"] = "Enter the admin code",
	["🔒 Damage ถูกล็อก — ขอโค้ดจากแอดมินผู้จัดทำ"] = "🔒 Damage is locked — ask the admin for the code",
	["🔓 Damage ปลดล็อกแล้ว"] = "🔓 Damage unlocked",
	["ปลดล็อก Damage แล้ว"] = "Damage unlocked",
	["โค้ดไม่ถูกต้อง"] = "Invalid code",
	["ลองใหม่อีกครั้งใน %d วินาที"] = "Try again in %d s",
	["Damage ถูกล็อก: ใส่โค้ดแอดมินที่ Settings (ช่องสุดท้าย)"] = "Damage is locked: enter the admin code in Settings (last field)",
	["DAMAGE: LOCKED — ใส่โค้ดแอดมินที่ Settings"] = "DAMAGE: LOCKED — enter the admin code in Settings",
	["ฟังก์ชันตัวละคร/ฟาร์ม/ESP/Damage ใช้ได้เฉพาะ Studio หรือเกมที่คุณเป็นเจ้าของ"] = "Character/Farm/ESP/Damage only work in Studio or a game you own",
}
local REV = {}
for thai, english in pairs(TR) do
	REV[english] = thai
end
local function L(text)
	if Config.Language == "EN" then
		return TR[text] or text
	end
	return text
end

-- รหัสแอดมินปลดล็อก Damage (เก็บเป็นค่า hash ไม่ใช่ข้อความตรง ๆ)
-- หมายเหตุ: เป็นการล็อกฝั่งไคลเอนต์ ป้องกันการใช้ผิดโดยไม่ตั้งใจ ไม่ใช่ระบบความปลอดภัยจริง
local ADMIN_CODE_HASH = 404071526
local function HashCode(text)
	local hash = 5381
	for index = 1, #text do
		hash = (hash * 33 + string.byte(text, index)) % 4294967296
	end
	return hash
end

local Themes = {
	{Name = "PURPLE", Color = Color3.fromRGB(48, 25, 110), Accent = Color3.fromRGB(37, 99, 235)},
	{Name = "BLUE", Color = Color3.fromRGB(15, 35, 90), Accent = Color3.fromRGB(0, 170, 255)},
	{Name = "BLACK", Color = Color3.fromRGB(20, 20, 28), Accent = Color3.fromRGB(120, 80, 255)},
	{Name = "DARK", Color = Color3.fromRGB(35, 35, 45), Accent = Color3.fromRGB(160, 160, 180)}
}
local WatermarkColors = {
	{Name = "BLUE", Color = Color3.fromRGB(59, 130, 246)},
	{Name = "PURPLE", Color = Color3.fromRGB(168, 85, 247)},
	{Name = "GREEN", Color = Color3.fromRGB(34, 197, 94)},
	{Name = "RED", Color = Color3.fromRGB(239, 68, 68)},
	{Name = "WHITE", Color = Color3.fromRGB(255, 255, 255)}
}
local ThemeIndex = 1
local WatermarkColorIndex = 1

-- บันทึก/โหลดการตั้งค่าไว้ที่ Attribute ของผู้เล่น (คงอยู่ตลอดเซสชัน แม้รันสคริปต์ซ้ำ; ไม่ข้ามการเข้าเกมครั้งใหม่)
local function SaveConfig()
	pcall(function()
		LocalPlayer:SetAttribute("YYH_Theme", ThemeIndex)
		LocalPlayer:SetAttribute("YYH_Shape", Config.Shape)
		LocalPlayer:SetAttribute("YYH_Stroke", Config.StrokeThickness)
		LocalPlayer:SetAttribute("YYH_WmShape", Config.WatermarkShape)
		LocalPlayer:SetAttribute("YYH_WmStroke", Config.WatermarkStroke)
		LocalPlayer:SetAttribute("YYH_WmColor", WatermarkColorIndex)
		LocalPlayer:SetAttribute("YYH_Lang", Config.Language)
	end)
end

local function LoadConfig()
	pcall(function()
		local themeIndex = LocalPlayer:GetAttribute("YYH_Theme")
		if type(themeIndex) == "number" and Themes[themeIndex] then
			ThemeIndex = themeIndex
		end
		local language = LocalPlayer:GetAttribute("YYH_Lang")
		if language == "TH" or language == "EN" then
			Config.Language = language
		end
		if LocalPlayer:GetAttribute("YYH_DmgUnlocked") == ADMIN_CODE_HASH then
			Config.DamageUnlocked = true
		end
		local colorIndex = LocalPlayer:GetAttribute("YYH_WmColor")
		if type(colorIndex) == "number" and WatermarkColors[colorIndex] then
			WatermarkColorIndex = colorIndex
		end
		local shape = LocalPlayer:GetAttribute("YYH_Shape")
		if shape == "Square" or shape == "Circle" then
			Config.Shape = shape
		end
		local wmShape = LocalPlayer:GetAttribute("YYH_WmShape")
		if wmShape == "Square" or wmShape == "Circle" then
			Config.WatermarkShape = wmShape
		end
		local stroke = LocalPlayer:GetAttribute("YYH_Stroke")
		if type(stroke) == "number" then
			Config.StrokeThickness = math.clamp(math.floor(stroke), 1, 6)
		end
		local wmStroke = LocalPlayer:GetAttribute("YYH_WmStroke")
		if type(wmStroke) == "number" then
			Config.WatermarkStroke = math.clamp(math.floor(wmStroke), 1, 6)
		end
	end)
	Config.BgColor = Themes[ThemeIndex].Color
	Config.AccentBlue = Themes[ThemeIndex].Accent
	Config.WatermarkColor = WatermarkColors[WatermarkColorIndex].Color
end
LoadConfig()

---------------------------------------------------------------------
-- 3. CORE: CONNECTIONS, GUI ROOT, BINDINGS
---------------------------------------------------------------------
local Connections = {}
local function Track(connection)
	table.insert(Connections, connection)
	return connection
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YinYangDeltaHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Binding = คุณสมบัติที่คำนวณจาก Config ทุกครั้งที่เรียก Refresh()
-- ทำให้เปลี่ยนธีม/รูปทรง/เส้นขอบได้ครบทุกองค์ประกอบ โดยไม่ทับสีที่ตั้งใจให้ต่างกัน
local Bindings = {}

local function Bind(object, property, getter)
	table.insert(Bindings, {Object = object, Property = property, Getter = getter})
	object[property] = getter()
end

local function Refresh()
	for index = #Bindings, 1, -1 do
		local binding = Bindings[index]
		if binding.Object:IsDescendantOf(ScreenGui) then
			binding.Object[binding.Property] = binding.Getter()
		else
			table.remove(Bindings, index) -- วัตถุถูกลบแล้ว
		end
	end
end

---------------------------------------------------------------------
-- 4. HELPERS
---------------------------------------------------------------------
local function New(className, properties, parent)
	local object = Instance.new(className)
	for property, value in pairs(properties or {}) do
		object[property] = value
	end
	object.Parent = parent
	return object
end

-- large = เฟรมใหญ่ (โหมด Circle จะใช้มุมโค้งมากแทนทรงแคปซูลเต็มตัว)
local function Corner(object, radius, large)
	local corner = New("UICorner", nil, object)
	Bind(corner, "CornerRadius", function()
		if Config.Shape == "Circle" then
			return large and UDim.new(0, 24) or UDim.new(1, 0)
		end
		return UDim.new(0, radius or 8)
	end)
	return corner
end

-- thickness: ตัวเลขคงที่ หรือ nil เพื่อใช้ Config.StrokeThickness
local function Stroke(object, color, thickness)
	local stroke = New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, object)
	Bind(stroke, "Color", function()
		return color or Config.AccentBlue
	end)
	Bind(stroke, "Thickness", function()
		return thickness or Config.StrokeThickness
	end)
	return stroke
end

local function MakeDraggable(handle, target)
	local dragging = false
	local dragInput, dragStart, startPosition

	Track(handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragInput = input
			dragStart = input.Position
			startPosition = target.AbsolutePosition

			local endConnection
			endConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					endConnection:Disconnect()
				end
			end)
		end
	end))

	Track(UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		-- เมาส์: ใช้ MouseMovement (ตำแหน่งปัจจุบัน) / ทัช: ใช้ input เดิมที่อัปเดตตำแหน่ง
		local valid = input.UserInputType == Enum.UserInputType.MouseMovement
			or (input.UserInputType == Enum.UserInputType.Touch and input == dragInput)
		if not valid then
			return
		end

		local delta = input.Position - dragStart
		local screen = ScreenGui.AbsoluteSize
		local size = target.AbsoluteSize
		local x = math.clamp(startPosition.X + delta.X, -(size.X - 60), screen.X - 60)
		local y = math.clamp(startPosition.Y + delta.Y, 0, screen.Y - 40)
		target.Position = UDim2.fromOffset(x, y)
	end))
end

local function MakeButton(parent, text, size, position)
	local button = New("TextButton", {
		Size = size,
		Position = position,
		BackgroundColor3 = Config.ButtonWhite,
		TextColor3 = Config.TextDark,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		Text = text,
		AutoButtonColor = true
	}, parent)
	Corner(button, 6)
	Stroke(button)
	return button
end

-- ปุ่มสลับ ON/OFF ที่อ่านสถานะจาก getState() เสมอ
local function MakeToggle(parent, label, size, position, getState)
	local button = MakeButton(parent, "", size, position)
	Bind(button, "Text", function()
		local name = type(label) == "function" and label() or label
		return name .. (getState() and " : ON" or " : OFF")
	end)
	Bind(button, "BackgroundColor3", function()
		return getState() and Config.AccentBlue or Config.ButtonWhite
	end)
	Bind(button, "TextColor3", function()
		return getState() and Config.TextLight or Config.TextDark
	end)
	return button
end

local function MakeHeader(parent, text)
	return New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Config.TextLight,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	}, parent)
end

local function MakeSlider(parent, position, size, label, min, max, key)
	local track = New("Frame", {
		Size = size,
		Position = position,
		BackgroundColor3 = Config.ButtonWhite,
		BorderSizePixel = 0,
		Active = true
	}, parent)
	Corner(track, 6)
	Stroke(track)

	local fill = New("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Config.AccentBlue,
		BorderSizePixel = 0
	}, track)
	Corner(fill, 6)
	Bind(fill, "BackgroundColor3", function()
		return Config.AccentBlue
	end)

	local text = New("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		TextColor3 = Config.TextLight,
		TextStrokeColor3 = Color3.new(0, 0, 0),
		TextStrokeTransparency = 0.4,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		ZIndex = 2
	}, track)

	local function render()
		local value = Config[key]
		fill.Size = UDim2.fromScale(math.clamp((value - min) / (max - min), 0, 1), 1)
		text.Text = string.format("%s: %d", label, value)
	end
	render()

	local scroller = parent:IsA("ScrollingFrame") and parent or nil
	local sliding = false
	local dragInput
	local function setFromX(x)
		local t = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		Config[key] = math.floor(min + t * (max - min) + 0.5)
		render()
	end

	Track(track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			if scroller then
				scroller.ScrollingEnabled = false
			end
			dragInput = input
			setFromX(input.Position.X)
			local endConnection
			endConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					sliding = false
					if scroller then
						scroller.ScrollingEnabled = true
					end
					endConnection:Disconnect()
				end
			end)
		end
	end))
	Track(UserInputService.InputChanged:Connect(function(input)
		if not sliding then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or (input.UserInputType == Enum.UserInputType.Touch and input == dragInput) then
			setFromX(input.Position.X)
		end
	end))
	return track
end

---------------------------------------------------------------------
-- 5. WATERMARK
---------------------------------------------------------------------
local WatermarkFrame = New("Frame", {
	Name = "WatermarkFrame",
	Size = UDim2.fromOffset(210, 44),
	Position = UDim2.fromOffset(14, 14),
	BackgroundColor3 = Config.ButtonWhite,
	BorderSizePixel = 0
}, ScreenGui)

local WatermarkImage = New("ImageLabel", {
	Name = "WatermarkImage",
	BackgroundTransparency = 1,
	Image = Config.AssetImage,
	ScaleType = Enum.ScaleType.Fit
}, WatermarkFrame)

local WatermarkLabel = New("TextLabel", {
	BackgroundTransparency = 1,
	Text = Config.WatermarkText,
	TextColor3 = Config.TextDark,
	Font = Enum.Font.GothamBold,
	TextTruncate = Enum.TextTruncate.AtEnd
}, WatermarkFrame)

local function IsWmCircle()
	return Config.WatermarkShape == "Circle"
end

Bind(WatermarkFrame, "Size", function()
	return IsWmCircle() and UDim2.fromOffset(96, 96) or UDim2.fromOffset(340, 44)
end)
Bind(WatermarkImage, "Size", function()
	return IsWmCircle() and UDim2.fromOffset(54, 54) or UDim2.fromOffset(34, 34)
end)
Bind(WatermarkImage, "Position", function()
	return IsWmCircle() and UDim2.new(0.5, -27, 0, 7) or UDim2.fromOffset(5, 5)
end)
Bind(WatermarkLabel, "Size", function()
	return IsWmCircle() and UDim2.new(1, -8, 0, 24) or UDim2.new(1, -48, 1, 0)
end)
Bind(WatermarkLabel, "Position", function()
	return IsWmCircle() and UDim2.new(0, 4, 1, -25) or UDim2.fromOffset(44, 0)
end)
Bind(WatermarkLabel, "Text", function()
	return IsWmCircle() and Config.WatermarkShortText or Config.WatermarkText
end)
Bind(WatermarkLabel, "TextWrapped", IsWmCircle)
Bind(WatermarkLabel, "TextSize", function()
	return IsWmCircle() and 10 or 11
end)

local WatermarkCorner = New("UICorner", nil, WatermarkFrame)
Bind(WatermarkCorner, "CornerRadius", function()
	return IsWmCircle() and UDim.new(1, 0) or UDim.new(0, 8)
end)
local WatermarkStroke = New("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, WatermarkFrame)
Bind(WatermarkStroke, "Color", function()
	return Config.WatermarkColor
end)
Bind(WatermarkStroke, "Thickness", function()
	return Config.WatermarkStroke
end)

MakeDraggable(WatermarkFrame, WatermarkFrame)

---------------------------------------------------------------------
-- 6. MAIN WINDOW
---------------------------------------------------------------------
local WINDOW_W, WINDOW_H = 461, 312

local MainFrame = New("Frame", {
	Name = "MainFrame",
	Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
	BackgroundColor3 = Config.BgColor,
	BorderSizePixel = 0
}, ScreenGui)
Bind(MainFrame, "BackgroundColor3", function()
	return Config.BgColor
end)
Corner(MainFrame, 10, true)
Stroke(MainFrame)

-- ย่อขนาดอัตโนมัติบนจอเล็ก/มือถือ
local WindowScale = New("UIScale", nil, MainFrame)
local function UpdateScale()
	local screen = ScreenGui.AbsoluteSize
	if screen.X <= 0 or screen.Y <= 0 then
		return
	end
	WindowScale.Scale = math.clamp(math.min(screen.X / (WINDOW_W + 20), screen.Y / (WINDOW_H + 20)), 0.5, 1)
end
Track(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateScale))
UpdateScale()

do -- วางกึ่งกลางจอตอนเริ่ม
	local screen = ScreenGui.AbsoluteSize
	local scale = WindowScale.Scale
	MainFrame.Position = UDim2.fromOffset(
		math.max(0, (screen.X - WINDOW_W * scale) / 2),
		math.max(0, (screen.Y - WINDOW_H * scale) / 2)
	)
end

-- แตะ Watermark (ไม่ลาก) = ซ่อน/แสดงหน้าต่างหลัก
do
	local pressPosition
	local function isPointer(input)
		return input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
	end
	Track(WatermarkFrame.InputBegan:Connect(function(input)
		if isPointer(input) then
			pressPosition = input.Position
		end
	end))
	Track(WatermarkFrame.InputEnded:Connect(function(input)
		if isPointer(input) and pressPosition then
			local moved = (input.Position - pressPosition).Magnitude
			pressPosition = nil
			if moved < 8 then
				MainFrame.Visible = not MainFrame.Visible
			end
		end
	end))
end

local TopBar = New("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, 34),
	BackgroundColor3 = Config.AccentBlue,
	BorderSizePixel = 0
}, MainFrame)
Bind(TopBar, "BackgroundColor3", function()
	return Config.AccentBlue
end)
Corner(TopBar, 10, true)
MakeDraggable(TopBar, MainFrame)

New("ImageLabel", {
	Name = "HubIcon",
	Size = UDim2.fromOffset(24, 24),
	Position = UDim2.fromOffset(7, 5),
	BackgroundTransparency = 1,
	Image = Config.AssetImage,
	ScaleType = Enum.ScaleType.Fit
}, TopBar)

New("TextLabel", {
	Size = UDim2.new(1, -108, 1, 0),
	Position = UDim2.fromOffset(38, 0),
	BackgroundTransparency = 1,
	Text = "YINYANG HUB OLIVIA X VORTEX ENGINE DELTA 2.5",
	TextColor3 = Config.TextLight,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Left
}, TopBar)

local MinBtn = New("TextButton", {
	Size = UDim2.fromOffset(26, 24),
	Position = UDim2.new(1, -60, 0.5, -12),
	BackgroundColor3 = Config.ButtonWhite,
	TextColor3 = Config.TextDark,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	Text = "-"
}, TopBar)
Corner(MinBtn, 6)

local CloseBtn = New("TextButton", {
	Size = UDim2.fromOffset(26, 24),
	Position = UDim2.new(1, -30, 0.5, -12),
	BackgroundColor3 = Config.ButtonWhite,
	TextColor3 = Config.TextDark,
	Font = Enum.Font.GothamBold,
	TextSize = 12,
	Text = "X"
}, TopBar)
Corner(CloseBtn, 6)

local TabBar = New("Frame", {
	Name = "TabBar",
	Size = UDim2.new(1, -12, 0, 28),
	Position = UDim2.fromOffset(6, 38),
	BackgroundTransparency = 1
}, MainFrame)
New("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 6)
}, TabBar)

local BodyHolder = New("Frame", {
	Name = "BodyHolder",
	Size = UDim2.new(1, -12, 1, -74),
	Position = UDim2.fromOffset(6, 70),
	BackgroundTransparency = 1
}, MainFrame)

-- Toast (แจ้งเตือนสั้น ๆ มุมล่างของหน้าต่าง)
local Toast = New("TextLabel", {
	Name = "Toast",
	AnchorPoint = Vector2.new(0.5, 1),
	Size = UDim2.fromOffset(300, 24),
	Position = UDim2.new(0.5, 0, 1, -8),
	BackgroundColor3 = Config.TextDark,
	BackgroundTransparency = 1,
	TextTransparency = 1,
	TextColor3 = Config.TextLight,
	Font = Enum.Font.GothamBold,
	TextSize = 11,
	Text = "",
	ZIndex = 50
}, MainFrame)
Corner(Toast, 6)

local toastId = 0
local function ShowToast(text)
	toastId += 1
	local id = toastId
	Toast.Text = text
	Toast.BackgroundTransparency = 0.1
	Toast.TextTransparency = 0
	task.delay(2, function()
		if id ~= toastId or not Toast.Parent then
			return
		end
		TweenService:Create(Toast, TweenInfo.new(0.3), {
			BackgroundTransparency = 1,
			TextTransparency = 1
		}):Play()
	end)
end

local Pages = {}
local TabButtons = {}
local CurrentTab = "Games"

local function CreatePage(name)
	local page = New("Frame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false
	}, BodyHolder)
	Pages[name] = page
	return page
end

local function CreateScrollPage(name, canvasHeight)
	local page = New("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.fromOffset(0, canvasHeight),
		Visible = false
	}, BodyHolder)
	-- เว้นขอบให้เส้นขอบ (UIStroke) ไม่ถูกตัด และไม่ให้แถบเลื่อนทับปุ่ม
	New("UIPadding", {
		PaddingLeft = UDim.new(0, 3),
		PaddingRight = UDim.new(0, 9),
		PaddingTop = UDim.new(0, 3),
		PaddingBottom = UDim.new(0, 6)
	}, page)
	Pages[name] = page
	return page
end

local function SwitchTab(name)
	CurrentTab = name
	for pageName, page in pairs(Pages) do
		page.Visible = pageName == name
	end
	Refresh()
end

local tabNames = {"Games", "Farm", "Character", "ESP-AFK", "Code", "Settings"}
local tabWidth = (WINDOW_W - 12 - 6 * (#tabNames - 1)) / #tabNames
for _, tabName in ipairs(tabNames) do
	local button = New("TextButton", {
		Name = tabName .. "Tab",
		Size = UDim2.fromOffset(tabWidth, 28),
		BackgroundColor3 = Config.ButtonWhite,
		TextColor3 = Config.TextDark,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		Text = tabName
	}, TabBar)
	Corner(button, 6)
	Stroke(button)
	Bind(button, "BackgroundColor3", function()
		return CurrentTab == tabName and Config.AccentBlue or Config.ButtonWhite
	end)
	Bind(button, "TextColor3", function()
		return CurrentTab == tabName and Config.TextLight or Config.TextDark
	end)
	TabButtons[tabName] = button
	Track(button.MouseButton1Click:Connect(function()
		SwitchTab(tabName)
	end))
end

---------------------------------------------------------------------
-- 7. CODE PAGE (สร้างก่อน เพราะหน้า Games ส่งข้อความมาที่นี่)
---------------------------------------------------------------------
local CodePage = CreatePage("Code")
MakeHeader(CodePage, "YIN YANG CODE VIEWER")

local CodeBox = New("TextBox", {
	Name = "CodeBox",
	Size = UDim2.new(1, 0, 0, 112),
	Position = UDim2.fromOffset(0, 24),
	BackgroundColor3 = Config.ButtonWhite,
	TextColor3 = Config.TextDark,
	Font = Enum.Font.Code,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextWrapped = false,
	MultiLine = true,
	ClearTextOnFocus = false,
	ClipsDescendants = true,
	PlaceholderText = L("-- เลือกสคริปต์จากแท็บ Games เพื่อดูโค้ด"),
	Text = 'print("YIN YANG HUB")'
}, CodePage)
Corner(CodeBox, 6)
Stroke(CodeBox)
New("UIPadding", {PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4)}, CodeBox)

local CodeStatus = New("TextLabel", {
	Name = "CodeStatus",
	Size = UDim2.new(1, 0, 0, 44),
	Position = UDim2.fromOffset(0, 140),
	BackgroundTransparency = 1,
	Text = "Status: VIEW ONLY",
	TextColor3 = Config.TextLight,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top
}, CodePage)

local CodeCheck = MakeButton(CodePage, "CHECK TEXT", UDim2.new(0.32, 0, 0, 30), UDim2.fromOffset(0, 192))
local CodeSelect = MakeButton(CodePage, "SELECT ALL", UDim2.new(0.32, 0, 0, 30), UDim2.new(0.34, 0, 0, 192))
local CodeClear = MakeButton(CodePage, "CLEAR", UDim2.new(0.32, 0, 0, 30), UDim2.new(0.68, 0, 0, 192))

-- ตรวจข้อความเบื้องต้น (ไม่ใช่ตัวคอมไพล์ และไม่รันโค้ด)
local RiskPatterns = {
	{"loadstring", "loadstring"},
	{"HttpGet", "HttpGet"},
	{"HttpService", "HttpService"},
	{"getgenv", "getgenv"},
	{"setclipboard", "setclipboard"},
	{"require%s*%(%s*%d+", "require(ID)"}
}

local function StripNoise(source)
	source = source:gsub("%-%-%[%[.-%]%]", "")
	source = source:gsub("%-%-[^\n]*", "")
	source = source:gsub("%[%[.-%]%]", '""')
	source = source:gsub('"[^"\n]*"', '""')
	source = source:gsub("'[^'\n]*'", '""')
	return source
end

local function CheckBrackets(clean)
	local pairsMap = {[")"] = "(", ["]"] = "[", ["}"] = "{"}
	local stack = {}
	local line = 1
	for char in clean:gmatch(".") do
		if char == "\n" then
			line += 1
		elseif char == "(" or char == "[" or char == "{" then
			table.insert(stack, {char = char, line = line})
		elseif pairsMap[char] then
			local top = table.remove(stack)
			if not top or top.char ~= pairsMap[char] then
				return false, string.format(L("วงเล็บ '%s' ไม่ตรงคู่ที่บรรทัด %d"), char, line)
			end
		end
	end
	if #stack > 0 then
		local top = stack[#stack]
		return false, string.format(L("วงเล็บ '%s' ที่บรรทัด %d ยังไม่ถูกปิด"), top.char, top.line)
	end
	return true
end

local function AnalyzeSource(source)
	if source:match("^%s*$") then
		return "Status: EMPTY"
	end
	local _, newlines = source:gsub("\n", "")
	local lines = newlines + 1
	local ok, problem = CheckBrackets(StripNoise(source))

	local found = {}
	for _, pattern in ipairs(RiskPatterns) do
		if source:find(pattern[1]) then
			table.insert(found, pattern[2])
		end
	end

	local text = string.format(L("Lines: %d | Chars: %d | วงเล็บ: %s"), lines, #source, ok and "OK" or problem)
	if #found > 0 then
		text ..= L("\n⚠ พบคำสั่งที่โหลด/รันโค้ดภายนอก: ") .. table.concat(found, ", ") .. L(" (ดูเท่านั้น ไม่รัน)")
	else
		text ..= "\nTEXT LOADED - NOT EXECUTED"
	end
	return text
end

Track(CodeCheck.MouseButton1Click:Connect(function()
	CodeStatus.Text = AnalyzeSource(CodeBox.Text or "")
end))

Track(CodeSelect.MouseButton1Click:Connect(function()
	CodeBox:CaptureFocus()
	CodeBox.SelectionStart = 1
	CodeBox.CursorPosition = #CodeBox.Text + 1
	ShowToast(L("เลือกข้อความทั้งหมดแล้ว (Ctrl+C เพื่อคัดลอก)"))
end))

Track(CodeClear.MouseButton1Click:Connect(function()
	CodeBox.Text = ""
	CodeStatus.Text = "Status: CLEARED"
end))

---------------------------------------------------------------------
-- 8. GAMES PAGE (หมวดหมู่ + ค้นหา + รายการโปรด)
---------------------------------------------------------------------
local GamesPage = CreatePage("Games")

local CatScroll = New("ScrollingFrame", {
	Size = UDim2.new(0, 145, 1, 0),
	BackgroundColor3 = Config.AccentBlue,
	ScrollBarThickness = 3,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new()
}, GamesPage)
Bind(CatScroll, "BackgroundColor3", function()
	return Config.AccentBlue
end)
Corner(CatScroll, 8)
Stroke(CatScroll, Config.ButtonWhite)
local CatList = New("UIListLayout", {Padding = UDim.new(0, 5)}, CatScroll)
New("UIPadding", {
	PaddingTop = UDim.new(0, 6),
	PaddingLeft = UDim.new(0, 6),
	PaddingRight = UDim.new(0, 6)
}, CatScroll)

local SearchBox = New("TextBox", {
	Name = "SearchBox",
	Size = UDim2.new(1, -153, 0, 26),
	Position = UDim2.fromOffset(153, 0),
	BackgroundColor3 = Config.ButtonWhite,
	TextColor3 = Config.TextDark,
	PlaceholderText = L("🔍 ค้นหาสคริปต์ทุกหมวด..."),
	Text = "",
	ClearTextOnFocus = false,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextXAlignment = Enum.TextXAlignment.Left
}, GamesPage)
Corner(SearchBox, 6)
Stroke(SearchBox)
New("UIPadding", {PaddingLeft = UDim.new(0, 8)}, SearchBox)

local ScriptScroll = New("ScrollingFrame", {
	Size = UDim2.new(1, -153, 1, -32),
	Position = UDim2.fromOffset(153, 32),
	BackgroundColor3 = Config.ButtonWhite,
	ScrollBarThickness = 4,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new()
}, GamesPage)
Corner(ScriptScroll, 8)
Stroke(ScriptScroll)
local ScriptList = New("UIListLayout", {Padding = UDim.new(0, 6)}, ScriptScroll)
New("UIPadding", {
	PaddingTop = UDim.new(0, 6),
	PaddingLeft = UDim.new(0, 6),
	PaddingRight = UDim.new(0, 6)
}, ScriptScroll)

local function BindCanvas(scroll, layout)
	local function update()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
	end
	Track(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update))
	update()
end
BindCanvas(CatScroll, CatList)
BindCanvas(ScriptScroll, ScriptList)

local CurrentCategory = GameCategories[1]
local CategoryButtons = {}
local RenderScripts -- forward declaration

local function RebuildFavorites()
	table.clear(FavoritesCategory.Scripts)
	for _, category in ipairs(GameCategories) do
		for _, scriptData in ipairs(category.Scripts) do
			if Favorites[scriptData] then
				table.insert(FavoritesCategory.Scripts, scriptData)
			end
		end
	end
end

local function CategoryLabel(category)
	return string.format(L("%s\n(%d สคริปต์)"), L(category.Category), #category.Scripts)
end

local function ShowScriptDetails(scriptData)
	CodeBox.Text = scriptData.Code or ""
	CodeStatus.Text = "Selected: " .. scriptData.Name .. L(" — VIEW ONLY (ไม่รันโค้ด)")
	SwitchTab("Code")
end

RenderScripts = function()
	for _, child in ipairs(ScriptScroll:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	local query = string.lower(SearchBox.Text or "")
	local results = {}
	if query ~= "" then
		for _, category in ipairs(GameCategories) do
			for _, scriptData in ipairs(category.Scripts) do
				local haystack = string.lower(scriptData.Name .. " " .. scriptData.Desc .. " " .. category.Category)
				if haystack:find(query, 1, true) then
					table.insert(results, scriptData)
				end
			end
		end
	else
		results = CurrentCategory.Scripts
	end

	if #results == 0 then
		New("TextLabel", {
			Size = UDim2.new(1, -2, 0, 50),
			BackgroundTransparency = 1,
			Text = query ~= "" and L("ไม่พบสคริปต์ที่ค้นหา")
				or L("ยังไม่มีรายการโปรด\nกด ☆ ที่การ์ดสคริปต์เพื่อบันทึก"),
			TextColor3 = Config.TextMuted,
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextWrapped = true
		}, ScriptScroll)
		return
	end

	for _, scriptData in ipairs(results) do
		local card = New("Frame", {
			Size = UDim2.new(1, -2, 0, 66),
			BackgroundColor3 = Config.ButtonWhite,
			BorderSizePixel = 0
		}, ScriptScroll)
		Corner(card, 6)
		Stroke(card)

		New("TextLabel", {
			Size = UDim2.new(1, -92, 0, 20),
			Position = UDim2.fromOffset(8, 5),
			BackgroundTransparency = 1,
			Text = scriptData.Name,
			TextColor3 = Config.TextDark,
			Font = Enum.Font.GothamBold,
			TextSize = 11,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left
		}, card)

		New("TextLabel", {
			Size = UDim2.new(1, -92, 0, 34),
			Position = UDim2.fromOffset(8, 26),
			BackgroundTransparency = 1,
			Text = L(scriptData.Desc),
			TextColor3 = Config.TextMuted,
			Font = Enum.Font.Gotham,
			TextSize = 10,
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top
		}, card)

		local viewButton = New("TextButton", {
			Size = UDim2.fromOffset(74, 26),
			Position = UDim2.new(1, -82, 0, 6),
			BackgroundColor3 = Config.AccentBlue,
			TextColor3 = Config.TextLight,
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			Text = "VIEW"
		}, card)
		Corner(viewButton, 6)
		Bind(viewButton, "BackgroundColor3", function()
			return Config.AccentBlue
		end)
		viewButton.MouseButton1Click:Connect(function()
			ShowScriptDetails(scriptData)
		end)

		local favButton = New("TextButton", {
			Size = UDim2.fromOffset(74, 24),
			Position = UDim2.new(1, -82, 0, 36),
			BackgroundColor3 = Config.ButtonWhite,
			TextColor3 = Config.TextDark,
			Font = Enum.Font.GothamBold,
			TextSize = 10,
			Text = Favorites[scriptData] and "★ SAVED" or "☆ SAVE"
		}, card)
		Corner(favButton, 6)
		Stroke(favButton)
		favButton.MouseButton1Click:Connect(function()
			Favorites[scriptData] = not Favorites[scriptData] or nil
			RebuildFavorites()
			CategoryButtons[FavoritesCategory].Text = CategoryLabel(FavoritesCategory)
			ShowToast(Favorites[scriptData] and L("บันทึกลงรายการโปรดแล้ว") or L("นำออกจากรายการโปรดแล้ว"))
			RenderScripts()
		end)
	end
end

local function MakeCategoryButton(category)
	local button = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Config.ButtonWhite,
		TextColor3 = Config.TextDark,
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextWrapped = true,
		Text = CategoryLabel(category)
	}, CatScroll)
	Corner(button, 6)
	Stroke(button, Config.BgColor)
	Bind(button, "BackgroundColor3", function()
		return CurrentCategory == category and Config.AccentBlue or Config.ButtonWhite
	end)
	Bind(button, "TextColor3", function()
		return CurrentCategory == category and Config.TextLight or Config.TextDark
	end)
	CategoryButtons[category] = button
	Track(button.MouseButton1Click:Connect(function()
		CurrentCategory = category
		SearchBox.Text = "" -- ล้างคำค้นหา (จะ render ผ่าน signal ด้านล่าง)
		RenderScripts()
		Refresh()
	end))
end

MakeCategoryButton(FavoritesCategory)
for _, category in ipairs(GameCategories) do
	MakeCategoryButton(category)
end

Track(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	RenderScripts()
end))

---------------------------------------------------------------------
-- 9. ESP-AFK PAGE
---------------------------------------------------------------------
local EspAfkPage = CreatePage("ESP-AFK")
-- โหมดนักพัฒนา: Roblox Studio หรือเกมที่ผู้เล่นเป็นเจ้าของ (ทดสอบบนมือถือในเกมตัวเองได้)
local function IsPlaceOwner()
	local ok, result = pcall(function()
		if game.CreatorId == 0 then
			return false
		end
		if game.CreatorType == Enum.CreatorType.User then
			return game.CreatorId == LocalPlayer.UserId
		end
		return LocalPlayer:GetRankInGroup(game.CreatorId) >= 255
	end)
	return ok and result == true
end
local IsOwnerGame = (not RunService:IsStudio()) and IsPlaceOwner()
local IsStudio = RunService:IsStudio() or IsOwnerGame

local EspToggle = MakeToggle(EspAfkPage, "Studio Debug Overlay", UDim2.new(1, 0, 0, 38), UDim2.fromOffset(0, 4), function()
	return Config.EspEnabled
end)
local AfkToggle = MakeToggle(EspAfkPage, "AFK MONITOR", UDim2.new(0.4, 0, 0, 36), UDim2.fromOffset(0, 46), function()
	return Config.AfkEnabled
end)
MakeSlider(EspAfkPage, UDim2.new(0.42, 0, 0, 46), UDim2.new(0.58, 0, 0, 36), "Alert (s)", 10, 600, "AfkSeconds")

local AfkBarTrack = New("Frame", {
	Size = UDim2.new(1, 0, 0, 12),
	Position = UDim2.fromOffset(0, 88),
	BackgroundColor3 = Config.ButtonWhite,
	BorderSizePixel = 0
}, EspAfkPage)
Corner(AfkBarTrack, 6)
Stroke(AfkBarTrack, nil, 1)
local AfkBarFill = New("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = Config.AccentBlue,
	BorderSizePixel = 0
}, AfkBarTrack)
Corner(AfkBarFill, 6)
Bind(AfkBarFill, "BackgroundColor3", function()
	return Config.AccentBlue
end)

local AfkStatus = New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 58),
	Position = UDim2.fromOffset(0, 104),
	BackgroundTransparency = 1,
	TextColor3 = Config.TextLight,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Text = "AFK monitor: DISABLED"
}, EspAfkPage)

local EspInfo = New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 68),
	Position = UDim2.fromOffset(0, 166),
	BackgroundColor3 = Config.AccentBlue,
	TextColor3 = Config.TextLight,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextWrapped = true,
	Text = L("• Debug overlay ใช้ได้เฉพาะ Studio หรือเกมที่คุณเป็นเจ้าของ (แสดงชื่อ ระยะ เลือด)\n• AFK monitor วัดเวลาที่ไม่มีการกดเล่น แจ้งเตือนซ้ำทุกครบเวลาที่ตั้ง\n• ไม่จำลองการกดปุ่มเพื่อหลบระบบ AFK ของ Roblox")
}, EspAfkPage)
Bind(EspInfo, "BackgroundColor3", function()
	return Config.AccentBlue
end)
Corner(EspInfo, 8)
Stroke(EspInfo, Config.ButtonWhite)

-- ---------- ESP (Studio เท่านั้น) ----------
local ESPData = {} -- [player] = {Gui = BillboardGui?, Label = TextLabel?}

local function ClearESP(player)
	local data = ESPData[player]
	if data and data.Gui then
		data.Gui:Destroy()
		data.Gui = nil
		data.Label = nil
	end
end

local function BuildESP(player, character)
	ClearESP(player)
	local root = character:WaitForChild("HumanoidRootPart", 5)
	if not root or not ScreenGui.Parent or player.Character ~= character or not ESPData[player] then
		return
	end

	local gui = New("BillboardGui", {
		Name = "YinYangStudioDebug",
		Adornee = root,
		Size = UDim2.fromOffset(150, 34),
		StudsOffset = Vector3.new(0, 3.2, 0),
		AlwaysOnTop = true,
		ResetOnSpawn = false,
		Enabled = Config.EspEnabled
	}, ScreenGui)

	local label = New("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.25,
		BackgroundColor3 = Config.BgColor,
		TextColor3 = Config.TextLight,
		TextStrokeTransparency = 0.3,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		Text = player.DisplayName
	}, gui)
	Bind(label, "BackgroundColor3", function()
		return Config.BgColor
	end)
	Corner(label, 5)
	Stroke(label, nil, 1)

	ESPData[player].Gui = gui
	ESPData[player].Label = label
end

local function AttachPlayer(player)
	if player == LocalPlayer or ESPData[player] or not IsStudio then
		return
	end
	ESPData[player] = {}
	Track(player.CharacterAdded:Connect(function(character)
		task.spawn(BuildESP, player, character)
	end))
	Track(player.CharacterRemoving:Connect(function()
		ClearESP(player)
	end))
	if player.Character then
		task.spawn(BuildESP, player, player.Character)
	end
end

local function SetESP(enabled)
	Config.EspEnabled = enabled
	for _, data in pairs(ESPData) do
		if data.Gui then
			data.Gui.Enabled = enabled
		end
	end
	Refresh()
end

local function UpdateESP()
	local myCharacter = LocalPlayer.Character
	local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
	for player, data in pairs(ESPData) do
		local gui, label = data.Gui, data.Label
		if gui and label and gui.Adornee then
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local hp = humanoid and string.format(" | HP %d", math.floor(humanoid.Health)) or ""
			if myRoot then
				local studs = (myRoot.Position - gui.Adornee.Position).Magnitude
				label.Text = string.format("%s\n%.1f studs%s", player.DisplayName, studs, hp)
			else
				label.Text = player.DisplayName .. hp
			end
		end
	end
end

Track(EspToggle.MouseButton1Click:Connect(function()
	if not IsStudio then
		EspInfo.Text = L("Debug overlay ถูกปิด: ฟังก์ชันนี้จำกัดการใช้งานไว้ใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ")
		ShowToast(L("ใช้ได้เฉพาะใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ"))
		return
	end
	SetESP(not Config.EspEnabled)
end))

-- ---------- AFK monitor ----------
local lastInputAt = os.clock()
local afkAlertStep = 1 -- แจ้งเตือนซ้ำเมื่อ idle ถึง AfkSeconds x step
local afkLongest = 0
local afkAlerts = 0
local idledCount = 0
local afkStartedAt = os.clock()

local function FormatDuration(seconds)
	seconds = math.floor(seconds)
	if seconds >= 3600 then
		return string.format(L("%d ชม. %d นาที"), seconds // 3600, (seconds % 3600) // 60)
	elseif seconds >= 60 then
		return string.format(L("%d นาที %d วินาที"), seconds // 60, seconds % 60)
	end
	return string.format(L("%d วินาที"), seconds)
end

local function MarkActive(input)
	if input then
		local inputType = input.UserInputType
		if inputType == Enum.UserInputType.Accelerometer or inputType == Enum.UserInputType.Gyro then
			return -- เซนเซอร์ขยับเองบนมือถือ ไม่นับเป็นการใช้งาน
		end
	end
	if Config.AfkEnabled then
		afkLongest = math.max(afkLongest, os.clock() - lastInputAt)
	end
	lastInputAt = os.clock()
	afkAlertStep = 1
end
Track(UserInputService.InputBegan:Connect(MarkActive))
Track(UserInputService.InputChanged:Connect(MarkActive))

Track(AfkToggle.MouseButton1Click:Connect(function()
	Config.AfkEnabled = not Config.AfkEnabled
	if Config.AfkEnabled then
		afkLongest, afkAlerts, idledCount = 0, 0, 0
		afkStartedAt = os.clock()
		lastInputAt = os.clock()
		afkAlertStep = 1
		AfkStatus.Text = "AFK monitor: ENABLED"
	else
		AfkStatus.Text = "AFK monitor: DISABLED"
		AfkBarFill.Size = UDim2.fromScale(0, 1)
	end
	Refresh()
end))

Track(LocalPlayer.Idled:Connect(function()
	idledCount += 1
end))

local function UpdateAfk()
	if not Config.AfkEnabled then
		return
	end
	local now = os.clock()
	local idle = now - lastInputAt
	local threshold = Config.AfkSeconds
	AfkBarFill.Size = UDim2.fromScale(math.clamp(idle / threshold, 0, 1), 1)

	AfkStatus.Text = string.format(
		L("ไม่มีการใช้งาน: %s (แจ้งเตือนที่ %s)\nนานที่สุด: %s | แจ้งเตือนแล้ว: %d ครั้ง\nRoblox Idled: %d ครั้ง | ตรวจมาแล้ว: %s"),
		FormatDuration(idle), FormatDuration(threshold),
		FormatDuration(math.max(afkLongest, idle)), afkAlerts,
		idledCount, FormatDuration(now - afkStartedAt)
	)

	if idle >= threshold * afkAlertStep then
		afkAlertStep += 1
		afkAlerts += 1
		ShowToast(L("⚠ AFK: ไม่มีการใช้งาน ") .. FormatDuration(idle))
	end
end

---------------------------------------------------------------------
-- 10. SETTINGS PAGE
---------------------------------------------------------------------
do -- ห่อส่วน Settings ไว้ใน block เพื่อไม่ให้ตัวแปร local เกินขีดจำกัด 200 ตัวของ Luau
local SettingsPage = CreateScrollPage("Settings", 352)
MakeHeader(SettingsPage, "YINYANG HUB SETTINGS")

local function SettingButton(text, xScale, y)
	return MakeButton(SettingsPage, text, UDim2.new(0.48, 0, 0, 28), UDim2.new(xScale, 0, 0, y))
end

local ShapeButton = SettingButton("", 0, 24)
local StrokeButton = SettingButton("", 0.52, 24)
local ColorButton = SettingButton("", 0, 54)
local WatermarkButton = SettingButton("", 0.52, 54)
local WatermarkStrokeButton = SettingButton("", 0, 84)
local WatermarkColorButton = SettingButton("", 0.52, 84)
local SaveButton = SettingButton("SAVE CONFIG", 0, 114)
local ResetButton = SettingButton("RESET CONFIG", 0.52, 114)

Bind(ShapeButton, "Text", function()
	return "UI SHAPE: " .. string.upper(Config.Shape)
end)
Bind(StrokeButton, "Text", function()
	return "STROKE: " .. Config.StrokeThickness
end)
Bind(ColorButton, "Text", function()
	return "THEME: " .. Themes[ThemeIndex].Name
end)
Bind(WatermarkButton, "Text", function()
	return "WATERMARK: " .. string.upper(Config.WatermarkShape)
end)
Bind(WatermarkStrokeButton, "Text", function()
	return "WM STROKE: " .. Config.WatermarkStroke
end)
Bind(WatermarkColorButton, "Text", function()
	return "WM COLOR: " .. WatermarkColors[WatermarkColorIndex].Name
end)

Track(ShapeButton.MouseButton1Click:Connect(function()
	Config.Shape = Config.Shape == "Square" and "Circle" or "Square"
	Refresh()
end))
Track(StrokeButton.MouseButton1Click:Connect(function()
	Config.StrokeThickness = Config.StrokeThickness % 6 + 1
	Refresh()
end))
Track(ColorButton.MouseButton1Click:Connect(function()
	ThemeIndex = ThemeIndex % #Themes + 1
	Config.BgColor = Themes[ThemeIndex].Color
	Config.AccentBlue = Themes[ThemeIndex].Accent
	Refresh()
end))
Track(WatermarkButton.MouseButton1Click:Connect(function()
	Config.WatermarkShape = Config.WatermarkShape == "Square" and "Circle" or "Square"
	Refresh()
end))
Track(WatermarkStrokeButton.MouseButton1Click:Connect(function()
	Config.WatermarkStroke = Config.WatermarkStroke % 6 + 1
	Refresh()
end))
Track(WatermarkColorButton.MouseButton1Click:Connect(function()
	WatermarkColorIndex = WatermarkColorIndex % #WatermarkColors + 1
	Config.WatermarkColor = WatermarkColors[WatermarkColorIndex].Color
	Refresh()
end))

Track(SaveButton.MouseButton1Click:Connect(function()
	SaveConfig()
	ShowToast(L("บันทึกการตั้งค่าแล้ว"))
end))

Track(ResetButton.MouseButton1Click:Connect(function()
	ThemeIndex = 1
	WatermarkColorIndex = 1
	Config.Shape = "Square"
	Config.StrokeThickness = 2
	Config.WatermarkShape = "Square"
	Config.WatermarkStroke = 2
	Config.BgColor = Themes[1].Color
	Config.AccentBlue = Themes[1].Accent
	Config.WatermarkColor = WatermarkColors[1].Color
	Refresh()
	ShowToast(L("รีเซ็ตเป็นค่าเริ่มต้นแล้ว (กด SAVE เพื่อบันทึก)"))
end))

local LangButton = SettingButton("", 0, 144)
local EnvButton = SettingButton("", 0.52, 144)
Bind(LangButton, "Text", function()
	return "LANGUAGE: " .. (Config.Language == "EN" and "ENGLISH" or "ไทย")
end)
Bind(EnvButton, "Text", function()
	if RunService:IsStudio() then
		return "ENV: STUDIO"
	end
	return IsOwnerGame and "ENV: OWN GAME" or "ENV: PUBLIC (LIMITED)"
end)

local function ApplyLanguage()
	local map = Config.Language == "EN" and TR or REV
	for _, object in ipairs(ScreenGui:GetDescendants()) do
		if object:IsA("TextLabel") or object:IsA("TextButton") then
			local translated = map[object.Text]
			if translated then
				object.Text = translated
			end
		elseif object:IsA("TextBox") then
			local translated = map[object.PlaceholderText]
			if translated then
				object.PlaceholderText = translated
			end
		end
	end
end

Track(LangButton.MouseButton1Click:Connect(function()
	Config.Language = Config.Language == "EN" and "TH" or "EN"
	pcall(function()
		LocalPlayer:SetAttribute("YYH_Lang", Config.Language)
	end)
	ApplyLanguage()
	for category, button in pairs(CategoryButtons) do
		button.Text = CategoryLabel(category)
	end
	RenderScripts()
	Refresh()
	ShowToast(Config.Language == "EN" and "Language: English" or "ภาษา: ไทย")
end))

Track(EnvButton.MouseButton1Click:Connect(function()
	ShowToast(L("ฟังก์ชันตัวละคร/ฟาร์ม/ESP/Damage ใช้ได้เฉพาะ Studio หรือเกมที่คุณเป็นเจ้าของ"))
end))

New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 178),
	BackgroundTransparency = 1,
	Text = L("LINKS (แตะเพื่อเลือกข้อความ แล้วกด Ctrl+C)"),
	TextColor3 = Config.TextLight,
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left
}, SettingsPage)

local function LinkBox(text, y)
	local box = New("TextBox", {
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.fromOffset(0, y),
		BackgroundColor3 = Config.ButtonWhite,
		TextColor3 = Config.TextDark,
		Font = Enum.Font.Code,
		TextSize = 11,
		Text = text,
		TextEditable = false,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left
	}, SettingsPage)
	Corner(box, 6)
	Stroke(box)
	New("UIPadding", {PaddingLeft = UDim.new(0, 8)}, box)
	Track(box.Focused:Connect(function()
		box.SelectionStart = 1
		box.CursorPosition = #box.Text + 1
	end))
	return box
end
LinkBox(Config.YouTubeURL, 196)
LinkBox(Config.TikTokURL, 222)

local HotkeyLabel = New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.fromOffset(0, 250),
	BackgroundTransparency = 1,
	TextColor3 = Config.TextLight,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left
}, SettingsPage)
Bind(HotkeyLabel, "Text", function()
	return L("แตะ Watermark หรือกด ") .. Config.Hotkey.Name .. L(" = ซ่อน/แสดงหน้าต่าง")
end)

-- ช่องสุดท้าย: โค้ดแอดมินปลดล็อก Damage (ล็อกเฉพาะ Damage ฟังก์ชันอื่นทำงานปกติ)
New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.fromOffset(0, 272),
	BackgroundTransparency = 1,
	Text = L("ADMIN CODE (ปลดล็อก Damage เท่านั้น)"),
	TextColor3 = Config.TextLight,
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left
}, SettingsPage)

local AdminBox = New("TextBox", {
	Size = UDim2.new(1, 0, 0, 28),
	Position = UDim2.fromOffset(0, 290),
	BackgroundColor3 = Config.ButtonWhite,
	TextColor3 = Config.TextDark,
	Font = Enum.Font.Code,
	TextSize = 12,
	Text = "",
	PlaceholderText = L("ใส่โค้ดจากแอดมิน"),
	ClearTextOnFocus = true,
	TextXAlignment = Enum.TextXAlignment.Left
}, SettingsPage)
Corner(AdminBox, 6)
Stroke(AdminBox)
New("UIPadding", {PaddingLeft = UDim.new(0, 8)}, AdminBox)

local AdminStatus = New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.fromOffset(0, 322),
	BackgroundTransparency = 1,
	TextColor3 = Config.TextLight,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left
}, SettingsPage)
Bind(AdminStatus, "Text", function()
	if Config.DamageUnlocked then
		return L("🔓 Damage ปลดล็อกแล้ว")
	end
	return L("🔒 Damage ถูกล็อก — ขอโค้ดจากแอดมินผู้จัดทำ")
end)

local adminFails, adminLockedUntil = 0, 0
Track(AdminBox.FocusLost:Connect(function()
	local entered = AdminBox.Text:match("^%s*(.-)%s*$")
	AdminBox.Text = ""
	if entered == "" then
		return
	end
	local now = os.clock()
	if now < adminLockedUntil then
		ShowToast(string.format(L("ลองใหม่อีกครั้งใน %d วินาที"), math.ceil(adminLockedUntil - now)))
		return
	end
	if HashCode(entered) == ADMIN_CODE_HASH then
		Config.DamageUnlocked = true
		adminFails = 0
		pcall(function()
			LocalPlayer:SetAttribute("YYH_DmgUnlocked", ADMIN_CODE_HASH)
		end)
		ShowToast(L("ปลดล็อก Damage แล้ว"))
	else
		adminFails += 1
		if adminFails >= 5 then
			adminFails = 0
			adminLockedUntil = now + 30 -- ใส่ผิด 5 ครั้งรอ 30 วินาที
		end
		ShowToast(L("โค้ดไม่ถูกต้อง"))
	end
	Refresh()
end))
end

---------------------------------------------------------------------
-- CHARACTER PAGE (Speed / Jump / Infinite Jump / Fly) - Studio เท่านั้น
---------------------------------------------------------------------
local CharacterPage = CreateScrollPage("Character", 338)

local function StudioOnlyToggle(button, key, onEnable)
	Track(button.MouseButton1Click:Connect(function()
		if not IsStudio then
			ShowToast(L("ฟังก์ชันตัวละครใช้ได้เฉพาะใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ"))
			return
		end
		Config[key] = not Config[key]
		if Config[key] and onEnable then
			onEnable()
		end
		Refresh()
	end))
end

local SpeedToggle = MakeToggle(CharacterPage, "SPEED", UDim2.new(0.4, 0, 0, 36), UDim2.fromOffset(0, 4), function()
	return Config.SpeedEnabled
end)
MakeSlider(CharacterPage, UDim2.new(0.42, 0, 0, 4), UDim2.new(0.58, 0, 0, 36), "WalkSpeed", 16, 250, "SpeedValue")

local JumpToggle = MakeToggle(CharacterPage, "JUMP", UDim2.new(0.4, 0, 0, 36), UDim2.fromOffset(0, 46), function()
	return Config.JumpEnabled
end)
MakeSlider(CharacterPage, UDim2.new(0.42, 0, 0, 46), UDim2.new(0.58, 0, 0, 36), "JumpPower", 0, 250, "JumpValue")

local InfJumpToggle = MakeToggle(CharacterPage, "INFINITE JUMP", UDim2.new(1, 0, 0, 36), UDim2.fromOffset(0, 88), function()
	return Config.InfJumpEnabled
end)

local FlyToggle = MakeToggle(CharacterPage, "FLY", UDim2.new(0.4, 0, 0, 36), UDim2.fromOffset(0, 130), function()
	return Config.FlyEnabled
end)
MakeSlider(CharacterPage, UDim2.new(0.42, 0, 0, 130), UDim2.new(0.58, 0, 0, 36), "Fly Speed", 0, 250, "FlyValue")

local HealToggle = MakeToggle(CharacterPage, "AUTO HEAL", UDim2.new(0.4, 0, 0, 36), UDim2.fromOffset(0, 172), function()
	return Config.AutoHealEnabled
end)
MakeSlider(CharacterPage, UDim2.new(0.42, 0, 0, 172), UDim2.new(0.58, 0, 0, 36), "Heal HP/s", 1, 100, "HealValue")

local GodToggle = MakeToggle(CharacterPage, "INFINITE HEALTH", UDim2.new(1, 0, 0, 36), UDim2.fromOffset(0, 214), function()
	return Config.GodEnabled
end)

StudioOnlyToggle(SpeedToggle, "SpeedEnabled")
StudioOnlyToggle(JumpToggle, "JumpEnabled")
StudioOnlyToggle(InfJumpToggle, "InfJumpEnabled")
StudioOnlyToggle(FlyToggle, "FlyEnabled", function()
	Config.FarmEnabled = false -- บิน (Fly) กับ Auto Farm เลือกพร้อมกันไม่ได้
end)
StudioOnlyToggle(HealToggle, "AutoHealEnabled")
StudioOnlyToggle(GodToggle, "GodEnabled")

local CharInfo = New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 70),
	Position = UDim2.fromOffset(0, 258),
	BackgroundTransparency = 1,
	TextColor3 = Config.TextLight,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top
}, CharacterPage)

local function ComboActive()
	return Config.SpeedEnabled and Config.JumpEnabled and Config.InfJumpEnabled
end

Bind(CharInfo, "Text", function()
	if not IsStudio then
		return L("ฟังก์ชันตัวละครถูกปิด: จำกัดการใช้งานไว้ใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ (ใช้ทดสอบตัวละครในเกมของคุณ)")
	end
	local text = L("• SPEED/JUMP ปรับค่าตามสไลด์ และคืนค่าเดิมเมื่อปิด\n• FLY: WASD/จอยสติ๊กเคลื่อนที่ตามกล้อง, Space = ขึ้น, Shift = ลง\n• AUTO HEAL เพิ่มเลือดต่อเนื่อง / INFINITE HEALTH เลือดไม่จำกัด (ใน Play Solo; โหมดหลายผู้เล่นเซิร์ฟเวอร์ยังคุมเลือดจริง)")
	if ComboActive() then
		text ..= L("\n🚀 COMBO: เปิด Speed + Jump + Infinite Jump — กดกระโดดเพื่อพุ่งไปข้างหน้า")
	end
	return text
end)

-- ---------- ตรรกะตัวละคร ----------
local Original = setmetatable({}, {__mode = "k"}) -- [humanoid] = ค่าดั้งเดิม
local SpeedApplied = setmetatable({}, {__mode = "k"})
local JumpApplied = setmetatable({}, {__mode = "k"})
local GodApplied = setmetatable({}, {__mode = "k"})
local Fly = {}

local function GetCharacter()
	local character = LocalPlayer.Character
	if not character then
		return nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if humanoid and humanoid.Health > 0 and root then
		return humanoid, root
	end
	return nil, nil
end

local function Remember(humanoid)
	if not Original[humanoid] then
		Original[humanoid] = {
			WalkSpeed = humanoid.WalkSpeed,
			JumpPower = humanoid.JumpPower,
			UseJumpPower = humanoid.UseJumpPower,
			MaxHealth = humanoid.MaxHealth
		}
	end
end

local function StopFly()
	for _, name in ipairs({"Velocity", "Align", "Attachment"}) do
		if Fly[name] then
			Fly[name]:Destroy()
			Fly[name] = nil
		end
	end
	if Fly.Humanoid and Fly.Humanoid.Parent then
		Fly.Humanoid.PlatformStand = false
	end
	Fly.Humanoid = nil
end

local function StartFly(humanoid, root)
	StopFly()
	local attachment = New("Attachment", {Name = "YYH_FlyAttachment"}, root)
	local velocity = New("LinearVelocity", {
		Name = "YYH_FlyVelocity",
		Attachment0 = attachment,
		MaxForce = math.huge,
		VelocityConstraintMode = Enum.VelocityConstraintMode.Vector,
		RelativeTo = Enum.ActuatorRelativeTo.World,
		VectorVelocity = Vector3.zero
	}, root)
	local align = New("AlignOrientation", {
		Name = "YYH_FlyAlign",
		Mode = Enum.OrientationAlignmentMode.OneAttachment,
		Attachment0 = attachment,
		MaxTorque = math.huge,
		Responsiveness = 60,
		RigidityEnabled = false,
		CFrame = root.CFrame.Rotation
	}, root)
	humanoid.PlatformStand = true
	Fly.Attachment, Fly.Velocity, Fly.Align, Fly.Humanoid = attachment, velocity, align, humanoid
end

local function UpdateFly(humanoid, root, auto, targetPos)
	if not Fly.Attachment or Fly.Attachment.Parent ~= root then
		StartFly(humanoid, root)
	end
	if auto then
		-- โหมดฟาร์ม: บินไปหาเป้าหมายเอง (ชะลอเมื่อใกล้ถึง) ไม่มีเป้าหมาย = ลอยนิ่ง
		local velocity = Vector3.zero
		if targetPos then
			local offset = targetPos - root.Position
			local distance = offset.Magnitude
			if distance > 1 then
				velocity = offset.Unit * math.min(Config.FarmSpeed, distance * 8)
				local flat = Vector3.new(offset.X, 0, offset.Z)
				if flat.Magnitude > 0.5 then
					Fly.Align.CFrame = CFrame.lookAt(Vector3.zero, flat)
				end
			end
		end
		Fly.Velocity.VectorVelocity = velocity
		return
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local look = camera.CFrame.LookVector
	local flatLook = Vector3.new(look.X, 0, look.Z)
	local move = humanoid.MoveDirection
	local vertical = 0

	if move.Magnitude > 0.05 and flatLook.Magnitude > 0.01 then
		-- เดินหน้า/ถอยหลังตามกล้อง: เงยกล้องขึ้นแล้วเดินหน้า = ไต่ขึ้น
		vertical += look.Y * move:Dot(flatLook.Unit)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		vertical += 1
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		vertical -= 1
	end

	local direction = move + Vector3.new(0, vertical, 0)
	if direction.Magnitude > 1 then
		direction = direction.Unit
	end
	Fly.Velocity.VectorVelocity = direction * Config.FlyValue
	if flatLook.Magnitude > 0.01 then
		Fly.Align.CFrame = CFrame.lookAt(Vector3.zero, flatLook)
	end
end

-- ---------- Auto Farm (ไอเทมในเกมของคุณ) ----------
local Farm = {
	Target = nil,
	Ignored = setmetatable({}, {__mode = "k"}), -- [part] = เวลาที่จะกลับมาเลือกได้อีก
	Found = 0,
	Collected = 0,
	ReachedAt = nil,
	LastWarp = 0,
	NextPick = 0
}

local function ToPart(instance)
	local part
	if instance:IsA("BasePart") then
		part = instance
	elseif instance:IsA("Model") then
		part = instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
	end
	local character = LocalPlayer.Character
	if part and part:IsDescendantOf(workspace) and not (character and part:IsDescendantOf(character)) then
		return part
	end
	return nil
end

local function GatherFarmTargets()
	local list, seen = {}, {}
	local function add(instance)
		local part = ToPart(instance)
		if part and not seen[part] then
			seen[part] = true
			table.insert(list, part)
		end
	end
	for _, instance in ipairs(CollectionService:GetTagged(Config.FarmTag)) do
		add(instance)
	end
	local folder = workspace:FindFirstChild(Config.FarmTag)
	if folder then
		for _, instance in ipairs(folder:GetDescendants()) do
			if instance:IsA("BasePart") then
				add(instance)
			end
		end
	end
	return list
end

local function PickFarmTarget(root)
	local now = os.clock()
	local list = GatherFarmTargets()
	Farm.Found = #list
	local best, bestDistance
	for _, part in ipairs(list) do
		local ignoredUntil = Farm.Ignored[part]
		if not ignoredUntil or now >= ignoredUntil then
			local distance = (part.Position - root.Position).Magnitude
			if not bestDistance or distance < bestDistance then
				best, bestDistance = part, distance
			end
		end
	end
	return best
end

local function MarkVisited(now)
	Farm.Collected += 1
	Farm.Ignored[Farm.Target] = now + 3 -- ไอเทมที่เกิดใหม่จะถูกเลือกได้อีกหลัง 3 วินาที
	Farm.Target = nil
	Farm.ReachedAt = nil
end

-- คืนตำแหน่งเป้าหมายสำหรับโหมดบิน (โหมดวาร์ปทำงานในฟังก์ชันนี้เลย)
local function UpdateFarm(root)
	local now = os.clock()
	if Farm.Target and not Farm.Target:IsDescendantOf(workspace) then
		Farm.Target = nil
	end
	if not Farm.Target then
		if now < Farm.NextPick then
			return nil
		end
		Farm.NextPick = now + 0.25
		Farm.Target = PickFarmTarget(root)
		Farm.ReachedAt = nil
		if not Farm.Target then
			return nil
		end
	end

	local position = Farm.Target.Position
	if Config.FarmMode == "Warp" then
		local interval = 1 / math.max(Config.FarmSpeed / 25, 0.1) -- ครั้ง/วินาที = ความเร็ว / 25
		if now - Farm.LastWarp >= interval then
			Farm.LastWarp = now
			root.CFrame = CFrame.new(position + Vector3.new(0, 1.5, 0)) * root.CFrame.Rotation
			root.AssemblyLinearVelocity = Vector3.zero
			MarkVisited(now)
		end
		return nil
	end

	if (position - root.Position).Magnitude <= 5 then
		Farm.ReachedAt = Farm.ReachedAt or now
		if now - Farm.ReachedAt >= 0.3 then
			MarkVisited(now)
		end
	else
		Farm.ReachedAt = nil
	end
	return position
end

local function ApplyCharacter(dt)
	if not IsStudio then
		return
	end
	local humanoid, root = GetCharacter()
	if not humanoid then
		StopFly()
		return
	end

	if Config.SpeedEnabled then
		Remember(humanoid)
		humanoid.WalkSpeed = Config.SpeedValue
		SpeedApplied[humanoid] = true
	elseif SpeedApplied[humanoid] then
		humanoid.WalkSpeed = Original[humanoid].WalkSpeed
		SpeedApplied[humanoid] = nil
	end

	if Config.JumpEnabled then
		Remember(humanoid)
		humanoid.UseJumpPower = true
		humanoid.JumpPower = Config.JumpValue
		JumpApplied[humanoid] = true
	elseif JumpApplied[humanoid] then
		humanoid.UseJumpPower = Original[humanoid].UseJumpPower
		humanoid.JumpPower = Original[humanoid].JumpPower
		JumpApplied[humanoid] = nil
	end

	local farmFly = Config.FarmEnabled and Config.FarmMode == "Fly"
	local farmTarget
	if Config.FarmEnabled then
		farmTarget = UpdateFarm(root)
	end
	if farmFly then
		UpdateFly(humanoid, root, true, farmTarget)
	elseif Config.FlyEnabled and not Config.FarmEnabled then
		UpdateFly(humanoid, root, false)
	elseif Fly.Attachment then
		StopFly()
	end

	if Config.GodEnabled then
		Remember(humanoid)
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
		GodApplied[humanoid] = true
	elseif GodApplied[humanoid] then
		humanoid.MaxHealth = Original[humanoid].MaxHealth
		GodApplied[humanoid] = nil
	end
	if Config.AutoHealEnabled and not Config.GodEnabled and humanoid.Health < humanoid.MaxHealth then
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + Config.HealValue * dt)
	end
end

local function ReleaseCharacter()
	StopFly()
	for humanoid, values in pairs(Original) do
		if humanoid.Parent then
			humanoid.WalkSpeed = values.WalkSpeed
			humanoid.UseJumpPower = values.UseJumpPower
			humanoid.JumpPower = values.JumpPower
			humanoid.MaxHealth = values.MaxHealth
		end
	end
end

Track(RunService.Heartbeat:Connect(ApplyCharacter))

-- Infinite Jump (+ COMBO พุ่งไปข้างหน้าเมื่อเปิด Speed + Jump + Infinite Jump พร้อมกัน)
Track(UserInputService.JumpRequest:Connect(function()
	if not IsStudio or not Config.InfJumpEnabled then
		return
	end
	local humanoid, root = GetCharacter()
	if not humanoid then
		return
	end
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

	if ComboActive() and not Config.FlyEnabled then
		task.defer(function()
			if not root.Parent then
				return
			end
			local look = root.CFrame.LookVector
			local forward = Vector3.new(look.X, 0, look.Z)
			if forward.Magnitude < 0.01 then
				return
			end
			root.AssemblyLinearVelocity = forward.Unit * (Config.SpeedValue * 1.5)
				+ Vector3.new(0, math.max(Config.JumpValue, 30), 0)
		end)
	end
end))

---------------------------------------------------------------------
-- FARM PAGE (Auto Farm ไอเทมในเกมของคุณ - Studio เท่านั้น)
---------------------------------------------------------------------
local FarmPage = CreateScrollPage("Farm", 432)

local FarmToggle = MakeToggle(FarmPage, "AUTO FARM", UDim2.new(0.5, 0, 0, 36), UDim2.fromOffset(0, 4), function()
	return Config.FarmEnabled
end)
local FarmModeBtn = MakeButton(FarmPage, "", UDim2.new(0.48, 0, 0, 36), UDim2.new(0.52, 0, 0, 4))
Bind(FarmModeBtn, "Text", function()
	return "MODE: " .. string.upper(Config.FarmMode)
end)
MakeSlider(FarmPage, UDim2.fromOffset(0, 46), UDim2.new(1, 0, 0, 34), "Farm Speed", 5, 250, "FarmSpeed")

New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.fromOffset(0, 86),
	BackgroundTransparency = 1,
	Text = L("ITEM TAG / ชื่อ Folder ใน Workspace"),
	TextColor3 = Config.TextLight,
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left
}, FarmPage)

local FarmTagBox = New("TextBox", {
	Size = UDim2.new(1, 0, 0, 26),
	Position = UDim2.fromOffset(0, 104),
	BackgroundColor3 = Config.ButtonWhite,
	TextColor3 = Config.TextDark,
	Font = Enum.Font.Code,
	TextSize = 11,
	Text = Config.FarmTag,
	PlaceholderText = "YYH_Farm",
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left
}, FarmPage)
Corner(FarmTagBox, 6)
Stroke(FarmTagBox)
New("UIPadding", {PaddingLeft = UDim.new(0, 8)}, FarmTagBox)

local FarmStatus = New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 48),
	Position = UDim2.fromOffset(0, 134),
	BackgroundTransparency = 1,
	TextColor3 = Config.TextLight,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Text = ""
}, FarmPage)

local FarmInfo = New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 52),
	Position = UDim2.fromOffset(0, 184),
	BackgroundColor3 = Config.AccentBlue,
	TextColor3 = Config.TextLight,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextWrapped = true,
	Text = L("• ใช้กับแมพของคุณ: ติด Tag (CollectionService) ให้ไอเทม หรือวางไว้ใน Folder ชื่อเดียวกับช่อง TAG\n• FLY = บินไปหาไอเทม / WARP = วาร์ปไปทับ (เลือกได้อย่างเดียว ไม่ทำพร้อมกัน)")
}, FarmPage)
Bind(FarmInfo, "BackgroundColor3", function()
	return Config.AccentBlue
end)
Corner(FarmInfo, 8)
Stroke(FarmInfo, Config.ButtonWhite)

-- ---------- Damage (ทดสอบกับศัตรูในเกมของคุณ) ----------
local DamageSuffixes = {
	{1e18, "Qi"}, {1e15, "Qa"}, {1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}
}
local SuffixLookup = {k = 1e3, m = 1e6, b = 1e9, t = 1e12, qa = 1e15, qi = 1e18}

local function CommaNumber(text)
	local whole, fraction = text:match("^(%d+)(%.?%d*)$")
	if not whole then
		return text
	end
	whole = whole:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	return whole .. fraction
end

-- 4.41004e21 -> "4,410.04Qi" (แสดงสูงสุดที่หน่วย Qi)
local function FormatBig(value)
	if value < 1000 then
		return CommaNumber(string.format("%d", math.floor(value + 0.5)))
	end
	for _, entry in ipairs(DamageSuffixes) do
		if value >= entry[1] then
			return CommaNumber(string.format("%.2f", value / entry[1])) .. entry[2]
		end
	end
	return tostring(value)
end

-- รองรับ "4,410.04Qi", "4.41Qa", "1e21", "4410040000000000000000"
local function ParseBig(text)
	text = string.lower(((text or ""):gsub("[%s,]", "")))
	local number = tonumber(text)
	if not number then
		local mantissa, suffix = text:match("^([%d%.]+)(%a+)$")
		local multiplier = suffix and SuffixLookup[suffix]
		number = mantissa and multiplier and tonumber(mantissa) and tonumber(mantissa) * multiplier
	end
	if not number or number ~= number then
		return nil
	end
	return math.clamp(number, 0, DAMAGE_MAX)
end

local DamageToggle = MakeToggle(FarmPage, function()
	return Config.DamageUnlocked and "DAMAGE" or "DAMAGE [LOCKED]"
end, UDim2.new(0.4, 0, 0, 34), UDim2.fromOffset(0, 262), function()
	return Config.DamageEnabled
end)

local DamageBox = New("TextBox", {
	Size = UDim2.new(0.58, 0, 0, 34),
	Position = UDim2.new(0.42, 0, 0, 262),
	BackgroundColor3 = Config.ButtonWhite,
	TextColor3 = Config.TextDark,
	Font = Enum.Font.Code,
	TextSize = 12,
	Text = FormatBig(Config.DamageValue),
	PlaceholderText = L("เช่น 4,410.04Qi"),
	ClearTextOnFocus = false
}, FarmPage)
Corner(DamageBox, 6)
Stroke(DamageBox)

local DamageHeader = New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.fromOffset(0, 244),
	BackgroundTransparency = 1,
	Text = L("DAMAGE (ทดสอบกับศัตรูใน Studio) — สูงสุด ") .. FormatBig(DAMAGE_MAX),
	TextColor3 = Config.TextLight,
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left
}, FarmPage)

Bind(DamageHeader, "Text", function()
	return L("DAMAGE (ทดสอบกับศัตรูใน Studio) — สูงสุด ") .. FormatBig(DAMAGE_MAX)
end)

local function SetDamage(value)
	Config.DamageValue = math.clamp(value, 0, DAMAGE_MAX)
	DamageBox.Text = FormatBig(Config.DamageValue)
end

local DamageTimes = MakeButton(FarmPage, "x10", UDim2.new(0.32, 0, 0, 28), UDim2.fromOffset(0, 302))
local DamageDiv = MakeButton(FarmPage, "÷10", UDim2.new(0.32, 0, 0, 28), UDim2.new(0.34, 0, 0, 302))
local DamageMax = MakeButton(FarmPage, "MAX", UDim2.new(0.32, 0, 0, 28), UDim2.new(0.68, 0, 0, 302))
Track(DamageTimes.MouseButton1Click:Connect(function()
	SetDamage(math.max(Config.DamageValue, 1) * 10)
end))
Track(DamageDiv.MouseButton1Click:Connect(function()
	SetDamage(Config.DamageValue / 10)
end))
Track(DamageMax.MouseButton1Click:Connect(function()
	SetDamage(DAMAGE_MAX)
end))
Track(DamageBox.FocusLost:Connect(function()
	local value = ParseBig(DamageBox.Text)
	if value then
		SetDamage(value)
	else
		ShowToast(L("รูปแบบตัวเลขไม่ถูกต้อง"))
		DamageBox.Text = FormatBig(Config.DamageValue)
	end
end))

New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.fromOffset(0, 336),
	BackgroundTransparency = 1,
	Text = L("ENEMY TAG / ชื่อ Folder ของศัตรู (ต้องมี Humanoid)"),
	TextColor3 = Config.TextLight,
	Font = Enum.Font.GothamBold,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left
}, FarmPage)

local EnemyTagBox = New("TextBox", {
	Size = UDim2.new(1, 0, 0, 26),
	Position = UDim2.fromOffset(0, 354),
	BackgroundColor3 = Config.ButtonWhite,
	TextColor3 = Config.TextDark,
	Font = Enum.Font.Code,
	TextSize = 11,
	Text = Config.EnemyTag,
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left
}, FarmPage)
Corner(EnemyTagBox, 6)
Stroke(EnemyTagBox)
New("UIPadding", {PaddingLeft = UDim.new(0, 8)}, EnemyTagBox)
Track(EnemyTagBox.FocusLost:Connect(function()
	local text = EnemyTagBox.Text:match("^%s*(.-)%s*$")
	if text == "" then
		text = "YYH_Enemy"
	end
	Config.EnemyTag = text
	EnemyTagBox.Text = text
end))

local DamageStatus = New("TextLabel", {
	Size = UDim2.new(1, 0, 0, 32),
	Position = UDim2.fromOffset(0, 386),
	BackgroundTransparency = 1,
	TextColor3 = Config.TextLight,
	Font = Enum.Font.Gotham,
	TextSize = 10,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Text = "DAMAGE: OFF"
}, FarmPage)

local DAMAGE_RANGE, DAMAGE_INTERVAL = 25, 0.5
local damageHits, damageInRange, lastDamageAt = 0, 0, 0

local function GatherEnemies()
	local humanoids, seen = {}, {}
	local function add(instance)
		local humanoid = instance:IsA("Humanoid") and instance or instance:FindFirstChildOfClass("Humanoid")
		if humanoid and not seen[humanoid] and humanoid.Health > 0
			and not Players:GetPlayerFromCharacter(humanoid.Parent) then -- ไม่โจมตีผู้เล่น
			seen[humanoid] = true
			table.insert(humanoids, humanoid)
		end
	end
	for _, instance in ipairs(CollectionService:GetTagged(Config.EnemyTag)) do
		add(instance)
	end
	local folder = workspace:FindFirstChild(Config.EnemyTag)
	if folder then
		for _, instance in ipairs(folder:GetChildren()) do
			add(instance)
		end
	end
	return humanoids
end

local function UpdateDamage()
	if not IsStudio then
		DamageStatus.Text = L("Damage ถูกปิด: จำกัดการใช้งานไว้ใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ")
		return
	end
	if not Config.DamageUnlocked then
		Config.DamageEnabled = false
		DamageStatus.Text = L("DAMAGE: LOCKED — ใส่โค้ดแอดมินที่ Settings")
		return
	end
	if not Config.DamageEnabled then
		DamageStatus.Text = "DAMAGE: OFF"
		return
	end
	local _, root = GetCharacter()
	damageInRange = 0
	if root then
		local now = os.clock()
		local ready = now - lastDamageAt >= DAMAGE_INTERVAL
		for _, humanoid in ipairs(GatherEnemies()) do
			local part = humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart")
			if part and (part.Position - root.Position).Magnitude <= DAMAGE_RANGE then
				damageInRange += 1
				if ready then
					humanoid:TakeDamage(Config.DamageValue)
					damageHits += 1
				end
			end
		end
		if ready then
			lastDamageAt = now
		end
	end
	DamageStatus.Text = string.format(L("DAMAGE: ON | %s ต่อครั้ง (ทุก %.1f วินาที, ระยะ %d studs)\nศัตรูในระยะ: %d | โจมตีแล้ว: %d ครั้ง"),
		FormatBig(Config.DamageValue), DAMAGE_INTERVAL, DAMAGE_RANGE, damageInRange, damageHits)
end

Track(DamageToggle.MouseButton1Click:Connect(function()
	if not IsStudio then
		ShowToast(L("ฟังก์ชันตัวละครใช้ได้เฉพาะใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ"))
		return
	end
	if not Config.DamageUnlocked then
		ShowToast(L("Damage ถูกล็อก: ใส่โค้ดแอดมินที่ Settings (ช่องสุดท้าย)"))
		return
	end
	Config.DamageEnabled = not Config.DamageEnabled
	Refresh()
end))

local function UpdateFarmStatus()
	if not IsStudio then
		FarmStatus.Text = L("Auto Farm ถูกปิด: จำกัดการใช้งานไว้ใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ (ใช้ทดสอบแมพของคุณ)")
		return
	end
	local speedText = Config.FarmMode == "Warp"
		and string.format(L("%.1f ครั้ง/วินาที"), Config.FarmSpeed / 25)
		or string.format("%d studs/s", Config.FarmSpeed)
	FarmStatus.Text = string.format(
		L("FARM: %s | %s | %s\nพบไอเทม: %d | ไปถึงแล้ว: %d\nเป้าหมาย: %s"),
		Config.FarmEnabled and "ON" or "OFF", string.upper(Config.FarmMode), speedText,
		Farm.Found, Farm.Collected, Farm.Target and Farm.Target.Name or "-"
	)
end

StudioOnlyToggle(FarmToggle, "FarmEnabled", function()
	Config.FlyEnabled = false -- Auto Farm กับ Fly (ปุ่มบินเอง) ไม่ทำพร้อมกัน
	Farm.Target = nil
	Farm.NextPick = 0
end)

Track(FarmModeBtn.MouseButton1Click:Connect(function()
	Config.FarmMode = Config.FarmMode == "Fly" and "Warp" or "Fly"
	Farm.Target = nil
	Farm.ReachedAt = nil
	Refresh()
	ShowToast(L("โหมดฟาร์ม: ") .. string.upper(Config.FarmMode))
end))

Track(FarmTagBox.FocusLost:Connect(function()
	local text = FarmTagBox.Text:match("^%s*(.-)%s*$")
	if text == "" then
		text = "YYH_Farm"
	end
	Config.FarmTag = text
	FarmTagBox.Text = text
	Farm.Target = nil
	Farm.NextPick = 0
end))

---------------------------------------------------------------------
-- 11. WINDOW CONTROL + LOOP + CLEANUP
---------------------------------------------------------------------
local minimized = false
Track(MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	BodyHolder.Visible = not minimized
	TabBar.Visible = not minimized
	MinBtn.Text = minimized and "+" or "-"
	TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Size = UDim2.fromOffset(WINDOW_W, minimized and 34 or WINDOW_H)
	}):Play()
end))

Track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Config.Hotkey then
		MainFrame.Visible = not MainFrame.Visible
	end
end))

-- ลูปเดียว อัปเดตทุก 0.2 วินาที (แทน RenderStepped ทุกเฟรม)
local accumulator = 0
Track(RunService.Heartbeat:Connect(function(dt)
	accumulator += dt
	if accumulator < 0.2 then
		return
	end
	accumulator = 0
	if Config.EspEnabled then
		UpdateESP()
	end
	UpdateAfk()
	UpdateFarmStatus()
	UpdateDamage()
end))

Track(Players.PlayerAdded:Connect(AttachPlayer))
Track(Players.PlayerRemoving:Connect(function(player)
	ClearESP(player)
	ESPData[player] = nil
end))

local function Cleanup()
	Config.EspEnabled = false
	Config.AfkEnabled = false
	ScreenGui:Destroy()
end

-- ไม่ว่าจะปิดด้วยปุ่ม X, รันสคริปต์ซ้ำ หรือ GUI ถูกลบ → ตัดการเชื่อมต่อทั้งหมดเสมอ
ScreenGui.Destroying:Connect(function()
	ReleaseCharacter()
	for _, connection in ipairs(Connections) do
		connection:Disconnect()
	end
	table.clear(Connections)
	table.clear(ESPData)
	table.clear(Bindings)
end)

Track(CloseBtn.MouseButton1Click:Connect(Cleanup))

---------------------------------------------------------------------
-- 12. INITIALIZE
---------------------------------------------------------------------
if IsStudio then
	for _, player in ipairs(Players:GetPlayers()) do
		AttachPlayer(player)
	end
else
	EspInfo.Text = L("Debug overlay ถูกปิด: ฟังก์ชันนี้จำกัดการใช้งานไว้ใน Roblox Studio หรือเกมที่คุณเป็นเจ้าของ")
end

RebuildFavorites()
RenderScripts()
SwitchTab("Games")

print("================================")
print(" YINYANG HUB OLIVIA X VORTEX ENGINE DELTA 2.5")
print(" Studio Edition - LocalScript")
print(" UI: 461 x 312")
print(" Status: INITIALIZED")
print("================================")
