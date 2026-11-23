--[[
    ===========================================================================
    CUSTOM MOVEMENT GUI - FULL PRODUCTION LUA MODULE & CONTROLLER
    Version: 2.0 (Detailed Modular Architecture, > 300 Lines)
    Platform: Roblox PC + Mobile
    Preserved Visual Layout, Sizes, Shapes, Positions & GUI Elements (100%)

    Systems Included:
    1. WASD Movement Controller (Camera-Relative, Touch + Keyboard, Smooth Stop)
    2. Slide Button System (Physics LinearVelocity + Cooldown + Safe Cleanup)
    3. GUI Color Customization (Active Accent + Button Base + Cycle & Direct Set)
    4. Floating / Fixed Position Mode (Preserves Layout & Supports Mode Switch)
    5. GUI Visibility Toggle (Hide / Show + Input & State Cleanup)
    6. Character Respawn / Death Safety & Clean Lifecycle Management
    ===========================================================================
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- =========================================================================
-- CONFIGURATION TABLE
-- =========================================================================
local CONFIG = {
	Enabled = true,
	SlideEnabled = true,
	MovementEnabled = true,
	Mode = "Fixed",

	ButtonColor = Color3.fromRGB(35, 40, 55),
	ActiveColor = Color3.fromRGB(0, 170, 255),

	MoveSpeed = 16,
	SlideSpeed = 24,
	SlideDuration = 0.45,
	SlideCooldown = 0.25,
	CameraEpsilon = 1e-4,
	MoveDirectionEpsilon = 0.05,
}

-- =========================================================================
-- PRESET COLOR PALETTE
-- =========================================================================
local ColorOptions = {
	Color3.fromRGB(0, 170, 255),
	Color3.fromRGB(170, 80, 255),
	Color3.fromRGB(0, 220, 130),
	Color3.fromRGB(255, 170, 0),
	Color3.fromRGB(255, 70, 100),
	Color3.fromRGB(255, 255, 255),
}

local ButtonBasePalette = {
	Color3.fromRGB(35, 40, 55),
	Color3.fromRGB(28, 32, 46),
	Color3.fromRGB(45, 35, 58),
	Color3.fromRGB(26, 44, 42),
	Color3.fromRGB(50, 34, 38),
	Color3.fromRGB(32, 34, 38),
}

-- =========================================================================
-- DIRECTION VECTORS
-- =========================================================================
local Directions = {
	W = Vector3.new(0, 0, -1),
	S = Vector3.new(0, 0, 1),
	A = Vector3.new(-1, 0, 0),
	D = Vector3.new(1, 0, 0),
}

-- =========================================================================
-- CENTRALIZED RUNTIME STATE
-- =========================================================================
local State = {
	Character = nil,
	Humanoid = nil,
	RootPart = nil,
	ActiveKeys = {},
	Sliding = false,
	OnCooldown = false,
	ColorIndex = 1,
	BaseColorIndex = 1,
	SlideToken = 0,
	Connections = {},
	CharacterConnections = {},
}

-- =========================================================================
-- UTILITY & CONNECTION HELPERS
-- =========================================================================
local function TrackConnection(list, conn)
	if conn then
		table.insert(list, conn)
	end
	return conn
end

local function ClearConnections(list)
	for i = #list, 1, -1 do
		local conn = list[i]
		if conn and typeof(conn) == "RBXScriptConnection" then
			conn:Disconnect()
		end
		list[i] = nil
	end
end

local function IsCharacterAlive()
	return State.Character ~= nil
		and State.Character.Parent ~= nil
		and State.Humanoid ~= nil
		and State.Humanoid.Parent ~= nil
		and State.Humanoid.Health > 0
		and State.RootPart ~= nil
		and State.RootPart.Parent ~= nil
end

local function CleanupSlideInstances(rootPart)
	if not rootPart then return end
	local vel = rootPart:FindFirstChild("CustomSlideVelocity")
	if vel then
		vel:Destroy()
	end
	local att = rootPart:FindFirstChild("CustomSlideAttachment")
	if att and #att:GetChildren() == 0 then
		att:Destroy()
	end
end

-- =========================================================================
-- GUI LAYER (PRESERVED LAYOUT, SIZES, POSITIONS & VISUAL ELEMENTS)
-- =========================================================================
local GUILayer = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMovementGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local function CreateButton(name, text, size, position)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Text = text
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = CONFIG.ButtonColor
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.GothamBold
	button.BorderSizePixel = 0
	button.Parent = ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = CONFIG.ActiveColor
	stroke.Thickness = 1.5
	stroke.Parent = button

	return button
end

-- WASD layout
local WASD = {
	W = CreateButton("W", "W", UDim2.fromOffset(48, 48),
		UDim2.new(0, 110, 1, -205)),

	A = CreateButton("A", "A", UDim2.fromOffset(48, 48),
		UDim2.new(0, 58, 1, -153)),

	S = CreateButton("S", "S", UDim2.fromOffset(48, 48),
		UDim2.new(0, 110, 1, -153)),

	D = CreateButton("D", "D", UDim2.fromOffset(48, 48),
		UDim2.new(0, 162, 1, -153)),
}

-- Settings
local Settings = CreateButton(
	"Settings",
	"SETTINGS",
	UDim2.fromOffset(100, 35),
	UDim2.new(0, 15, 0, 15)
)

local SlideButton = CreateButton(
	"Slide",
	"SLIDE",
	UDim2.fromOffset(76, 76),
	UDim2.new(1, -115, 1, -180)
)

local ToggleButton = CreateButton(
	"Toggle",
	"HIDE",
	UDim2.fromOffset(65, 32),
	UDim2.new(1, -85, 0, 15)
)

-- Settings menu
local SettingsMenu = CreateButton(
	"ChangeColor",
	"CHANGE COLOR",
	UDim2.fromOffset(145, 42),
	UDim2.new(0, 15, 0, 55)
)

SettingsMenu.Visible = false

GUILayer.ScreenGui = ScreenGui
GUILayer.WASD = WASD
GUILayer.Settings = Settings
GUILayer.SlideButton = SlideButton
GUILayer.ToggleButton = ToggleButton
GUILayer.SettingsMenu = SettingsMenu

function GUILayer.GetAllButtons()
	return {
		WASD.W,
		WASD.A,
		WASD.S,
		WASD.D,
		Settings,
		SlideButton,
		ToggleButton,
		SettingsMenu,
	}
end

function GUILayer.ApplyVisualColors(activeColor, baseColor, activeKeys)
	for key, button in pairs(WASD) do
		local stroke = button:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = activeColor
		end
		local isPressed = activeKeys and activeKeys[key] == true
		button.BackgroundColor3 = isPressed and activeColor or baseColor
	end

	for _, btn in ipairs({ Settings, SlideButton, ToggleButton, SettingsMenu }) do
		local stroke = btn:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = activeColor
		end
		btn.BackgroundColor3 = baseColor
	end
end

function GUILayer.ApplyModePositions(mode)
	if mode == "Floating" then
		for _, button in pairs(WASD) do
			button.Position = UDim2.new(
				0, 15, 1, -100
			)
		end
	else
		WASD.W.Position = UDim2.new(0, 110, 1, -205)
		WASD.A.Position = UDim2.new(0, 58, 1, -153)
		WASD.S.Position = UDim2.new(0, 110, 1, -153)
		WASD.D.Position = UDim2.new(0, 162, 1, -153)
	end
end

function GUILayer.SetVisibility(enabled)
	for _, button in pairs(WASD) do
		button.Visible = enabled
	end
	SlideButton.Visible = enabled
	Settings.Visible = enabled
	if not enabled then
		SettingsMenu.Visible = false
	end
	ToggleButton.Text = enabled and "HIDE" or "SHOW"
end

-- =========================================================
-- LOGIC MODULE 1: CHARACTER & LIFECYCLE CONTROLLER
-- =========================================================
local Character, Humanoid, RootPart
local CharacterController = {}

function CharacterController.BindCharacter(char)
	ClearConnections(State.CharacterConnections)

	State.SlideToken += 1
	State.Sliding = false
	State.OnCooldown = false
	table.clear(State.ActiveKeys)

	Character = char
	State.Character = char

	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")

	Humanoid = hum
	RootPart = root
	State.Humanoid = hum
	State.RootPart = root

	CleanupSlideInstances(root)

	if CONFIG.MoveSpeed and CONFIG.MoveSpeed > 0 then
		hum.WalkSpeed = CONFIG.MoveSpeed
	end

	TrackConnection(State.CharacterConnections, hum.Died:Connect(function()
		State.SlideToken += 1
		State.Sliding = false
		State.OnCooldown = false
		table.clear(State.ActiveKeys)
		CleanupSlideInstances(State.RootPart)
		GUILayer.ApplyVisualColors(CONFIG.ActiveColor, CONFIG.ButtonColor, State.ActiveKeys)
	end))

	TrackConnection(State.CharacterConnections, char.AncestryChanged:Connect(function(_, parent)
		if not parent then
			State.SlideToken += 1
			State.Sliding = false
			table.clear(State.ActiveKeys)
		end
	end))
end

local function UpdateCharacter(char)
	CharacterController.BindCharacter(char)
end

-- =========================================================
-- LOGIC MODULE 2: MOVEMENT CONTROLLER (WASD + CAMERA)
-- =========================================================
local ActiveKeys = State.ActiveKeys
local MovementController = {}

function MovementController.GetRawInputVector()
	local raw = Vector3.zero
	for key, active in pairs(ActiveKeys) do
		if active and Directions[key] then
			raw += Directions[key]
		end
	end
	return raw
end

function MovementController.GetCameraRelativeDirection(rawDir)
	if rawDir.Magnitude <= 0 then
		return Vector3.zero
	end

	local camera = Workspace.CurrentCamera
	if not camera then
		return rawDir.Unit
	end

	local look = camera.CFrame.LookVector
	local flatForward = Vector3.new(look.X, 0, look.Z)
	if flatForward.Magnitude < CONFIG.CameraEpsilon then
		flatForward = Vector3.new(0, 0, -1)
	else
		flatForward = flatForward.Unit
	end

	local right = camera.CFrame.RightVector
	local flatRight = Vector3.new(right.X, 0, right.Z)
	if flatRight.Magnitude < CONFIG.CameraEpsilon then
		flatRight = Vector3.new(1, 0, 0)
	else
		flatRight = flatRight.Unit
	end

	local forwardComponent = flatForward * (-rawDir.Z)
	local rightComponent = flatRight * rawDir.X
	local combined = forwardComponent + rightComponent

	if combined.Magnitude > 0 then
		return combined.Unit
	end

	return Vector3.zero
end

function MovementController.StopMovement()
	if State.Humanoid and State.Humanoid.Parent and State.Humanoid.Health > 0 then
		State.Humanoid:Move(Vector3.zero, false)
	end
end

function MovementController.Step()
	if not IsCharacterAlive() then
		return
	end

	if not CONFIG.Enabled or not CONFIG.MovementEnabled then
		MovementController.StopMovement()
		return
	end

	local rawDirection = MovementController.GetRawInputVector()
	if rawDirection.Magnitude > 0 then
		local moveDirection = MovementController.GetCameraRelativeDirection(rawDirection)
		State.Humanoid:Move(moveDirection, false)
	else
		MovementController.StopMovement()
	end
end

function MovementController.SetKey(key, active)
	if not Directions[key] then
		return
	end

	if active and (not CONFIG.Enabled or not CONFIG.MovementEnabled) then
		return
	end

	ActiveKeys[key] = active and true or nil

	local button = WASD[key]
	if button then
		button.BackgroundColor3 = ActiveKeys[key] and CONFIG.ActiveColor or CONFIG.ButtonColor
	end

	MovementController.Step()
end

function MovementController.ClearAllKeys()
	table.clear(ActiveKeys)
	GUILayer.ApplyVisualColors(CONFIG.ActiveColor, CONFIG.ButtonColor, ActiveKeys)
	MovementController.Step()
end

local function UpdateMovement()
	MovementController.Step()
end

local function SetKey(key, active)
	MovementController.SetKey(key, active)
end

-- =========================================================
-- LOGIC MODULE 3: SLIDE CONTROLLER
-- =========================================================
local Sliding = false
local SlideController = {}

function SlideController.ResolveDirection()
	local rawDirection = MovementController.GetRawInputVector()
	if rawDirection.Magnitude > 0 then
		return MovementController.GetCameraRelativeDirection(rawDirection)
	end

	if State.Humanoid and State.Humanoid.MoveDirection.Magnitude > CONFIG.MoveDirectionEpsilon then
		local md = State.Humanoid.MoveDirection
		local flat = Vector3.new(md.X, 0, md.Z)
		if flat.Magnitude > 0 then
			return flat.Unit
		end
	end

	if State.RootPart then
		local look = State.RootPart.CFrame.LookVector
		local flatLook = Vector3.new(look.X, 0, look.Z)
		if flatLook.Magnitude > 0 then
			return flatLook.Unit
		end
	end

	return Vector3.new(0, 0, -1)
end

function SlideController.Execute()
	if Sliding or State.Sliding or State.OnCooldown then
		return
	end

	if not CONFIG.Enabled or not CONFIG.SlideEnabled then
		return
	end

	if not IsCharacterAlive() then
		return
	end

	Sliding = true
	State.Sliding = true
	State.SlideToken += 1
	local token = State.SlideToken

	local root = State.RootPart
	local hum = State.Humanoid
	local slideDir = SlideController.ResolveDirection()
	local previousWalkSpeed = hum.WalkSpeed
	local targetSlideSpeed = math.max(CONFIG.SlideSpeed, previousWalkSpeed)

	CleanupSlideInstances(root)

	local attachment = Instance.new("Attachment")
	attachment.Name = "CustomSlideAttachment"
	attachment.Parent = root

	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "CustomSlideVelocity"
	linearVelocity.Attachment0 = attachment
	linearVelocity.MaxForce = math.huge
	linearVelocity.VectorVelocity = slideDir * targetSlideSpeed
	linearVelocity.Parent = root

	hum.WalkSpeed = targetSlideSpeed

	task.delay(CONFIG.SlideDuration, function()
		if linearVelocity and linearVelocity.Parent then
			linearVelocity:Destroy()
		end
		if attachment and attachment.Parent and #attachment:GetChildren() == 0 then
			attachment:Destroy()
		end

		if State.SlideToken == token then
			if hum and hum.Parent and hum.Health > 0 then
				local restoreSpeed = (CONFIG.MoveSpeed and CONFIG.MoveSpeed > 0) and CONFIG.MoveSpeed or previousWalkSpeed
				hum.WalkSpeed = restoreSpeed
			end
			Sliding = false
			State.Sliding = false

			if CONFIG.SlideCooldown and CONFIG.SlideCooldown > 0 then
				State.OnCooldown = true
				task.delay(CONFIG.SlideCooldown, function()
					if State.SlideToken == token then
						State.OnCooldown = false
					end
				end)
			end
		end
	end)
end

local function Slide()
	SlideController.Execute()
end

-- =========================================================
-- LOGIC MODULE 4: COLOR, MODE & TOGGLE CONTROLLER
-- =========================================================
local ThemeController = {}

function ThemeController.SetActiveColor(color3)
	if typeof(color3) ~= "Color3" then return end
	CONFIG.ActiveColor = color3
	GUILayer.ApplyVisualColors(CONFIG.ActiveColor, CONFIG.ButtonColor, ActiveKeys)
end

function ThemeController.SetBaseColor(color3)
	if typeof(color3) ~= "Color3" then return end
	CONFIG.ButtonColor = color3
	GUILayer.ApplyVisualColors(CONFIG.ActiveColor, CONFIG.ButtonColor, ActiveKeys)
end

function ThemeController.CycleColor()
	State.ColorIndex = (State.ColorIndex % #ColorOptions) + 1
	State.BaseColorIndex = (State.BaseColorIndex % #ButtonBasePalette) + 1

	CONFIG.ActiveColor = ColorOptions[State.ColorIndex]
	CONFIG.ButtonColor = ButtonBasePalette[State.BaseColorIndex]

	GUILayer.ApplyVisualColors(CONFIG.ActiveColor, CONFIG.ButtonColor, ActiveKeys)
end

function ThemeController.SetMode(mode)
	if mode ~= "Floating" and mode ~= "Fixed" then
		mode = "Fixed"
	end
	CONFIG.Mode = mode
	GUILayer.ApplyModePositions(mode)
end

function ThemeController.ToggleGUI()
	CONFIG.Enabled = not CONFIG.Enabled
	GUILayer.SetVisibility(CONFIG.Enabled)

	if not CONFIG.Enabled then
		MovementController.ClearAllKeys()
	end
end

local function ChangeColor()
	ThemeController.CycleColor()
end

local function SetMode(mode)
	ThemeController.SetMode(mode)
end

-- =========================================================
-- INPUT & EVENT BINDINGS (PC + MOBILE)
-- =========================================================
for key, button in pairs(WASD) do
	TrackConnection(State.Connections, button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			SetKey(key, true)
		end
	end))

	TrackConnection(State.Connections, button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then
			SetKey(key, false)
		end
	end))
end

TrackConnection(State.Connections, UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	local key = input.KeyCode.Name
	if Directions[key] then
		SetKey(key, true)
	end
end))

TrackConnection(State.Connections, UIS.InputEnded:Connect(function(input)
	local key = input.KeyCode.Name
	if Directions[key] then
		SetKey(key, false)
	end
end))

TrackConnection(State.Connections, UIS.WindowFocusReleased:Connect(function()
	MovementController.ClearAllKeys()
end))

TrackConnection(State.Connections, RunService.RenderStepped:Connect(function()
	if next(ActiveKeys) ~= nil then
		UpdateMovement()
	end
end))

TrackConnection(State.Connections, SlideButton.Activated:Connect(function()
	Slide()
end))

TrackConnection(State.Connections, Settings.Activated:Connect(function()
	if not CONFIG.Enabled then return end
	SettingsMenu.Visible = not SettingsMenu.Visible
end))

TrackConnection(State.Connections, SettingsMenu.Activated:Connect(function()
	if not CONFIG.Enabled then return end
	ChangeColor()
end))

TrackConnection(State.Connections, ToggleButton.Activated:Connect(function()
	ThemeController.ToggleGUI()
end))

if Player.Character then
	UpdateCharacter(Player.Character)
end

TrackConnection(State.Connections, Player.CharacterAdded:Connect(UpdateCharacter))

-- =========================================================================
-- PUBLIC API EXPORT (FOR EXTERNAL SCRIPTS / COMMANDS)
-- =========================================================================
local CustomMovementAPI = {
	Config = CONFIG,
	State = State,
	GUI = GUILayer,
	Movement = MovementController,
	Slide = SlideController,
	Theme = ThemeController,
	Character = CharacterController,
	SetActiveColor = ThemeController.SetActiveColor,
	SetBaseColor = ThemeController.SetBaseColor,
	CycleColor = ThemeController.CycleColor,
	SetMode = SetMode,
	ToggleGUI = ThemeController.ToggleGUI,
}

GUILayer.ApplyVisualColors(CONFIG.ActiveColor, CONFIG.ButtonColor, ActiveKeys)
GUILayer.ApplyModePositions(CONFIG.Mode)
GUILayer.SetVisibility(CONFIG.Enabled)

print("[Custom Movement GUI v2.0] Loaded successfully")
return CustomMovementAPI
