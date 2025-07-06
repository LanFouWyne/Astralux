--!nonstrict

--[[
	@author Jorsan
]]

-- Libraries
local Maid = loadstring(game:HttpGet('https://raw.githubusercontent.com/Quenty/NevermoreEngine/refs/heads/main/src/maid/src/Shared/Maid.lua'))()
local Signal = loadstring(game:HttpGet('https://raw.githubusercontent.com/stravant/goodsignal/refs/heads/master/src/init.lua'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- Create and configure blur effect
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
TweenService:Create(blur, TweenInfo.new(0.8, Enum.EasingStyle.Cubic), {Size = 24}):Play()

-- Create base GUI elements
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "InkGameLoader"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1

-- Create stylish background
local bg = Instance.new("Frame", frame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
bg.BackgroundTransparency = 1
bg.ZIndex = 0

-- Add gradient background
local bgGradient = Instance.new("UIGradient", bg)
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 0, 0))
})
bgGradient.Rotation = 45
TweenService:Create(bg, TweenInfo.new(0.8, Enum.EasingStyle.Cubic), {BackgroundTransparency = 0}):Play()

-- Create particle effects
for i = 1, 20 do
    local particle = Instance.new("Frame", bg)
    particle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    particle.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
    particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundTransparency = 0.8
    particle.ZIndex = 1
    
    -- Add glow to particles
    local particleGlow = Instance.new("UIGradient", particle)
    particleGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    
    -- Animate particles
    spawn(function()
        while particle.Parent do
            local randomDuration = math.random(2, 4)
            local newX = math.random()
            local newY = math.random()
            
            TweenService:Create(particle, TweenInfo.new(randomDuration, Enum.EasingStyle.Linear), {
                Position = UDim2.new(newX, 0, newY, 0),
                BackgroundTransparency = math.random(70, 90)/100
            }):Play()
            
            wait(randomDuration)
        end
    end)
end

-- Create animated lines
for i = 1, 8 do
    local line = Instance.new("Frame", bg)
    line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, math.random(), 0)
    line.BackgroundTransparency = 0.9
    line.ZIndex = 1
    
    -- Add gradient to lines
    local lineGradient = Instance.new("UIGradient", line)
    lineGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    lineGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    })
    
    -- Animate lines
    spawn(function()
        local offset = 0
        while line.Parent do
            TweenService:Create(lineGradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {
                Offset = Vector2.new(offset, 0)
            }):Play()
            offset = offset + 1
            if offset >= 1 then offset = 0 end
            wait(2)
        end
    end)
end

-- Create main glow effect
local glow = Instance.new("ImageLabel", frame)
glow.Size = UDim2.new(0, 800, 0, 200)
glow.Position = UDim2.new(0.5, -400, 0.5, -100)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://131274595"
glow.ImageColor3 = Color3.fromRGB(255, 0, 0)
glow.ImageTransparency = 1
glow.ZIndex = 1

-- Animate glow
TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Cubic), {ImageTransparency = 0.7}):Play()
spawn(function()
    while glow.Parent do
        TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 850, 0, 220)}):Play()
        wait(1)
        TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 800, 0, 200)}):Play()
        wait(1)
    end
end)

local word = "INK GAME"
local letters = {}

local function tweenOutAndDestroy()
    -- Fade out particles and lines
    for _, child in pairs(bg:GetChildren()) do
        if child:IsA("Frame") then
            TweenService:Create(child, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        end
    end
    
    -- Fade out glow
    TweenService:Create(glow, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    
    -- Fade out letters with different delays
    for i, label in ipairs(letters) do
        TweenService:Create(label, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            TextTransparency = 1,
            TextSize = 20,
            Position = label.Position + UDim2.new(0, 0, 0.2, 0)
        }):Play()
        wait(0.05)
    end
    
    -- Fade out background and blur
    TweenService:Create(bg, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    TweenService:Create(blur, TweenInfo.new(0.8), {Size = 0}):Play()
    
    wait(0.8)
    screenGui:Destroy()
    blur:Destroy()
end

-- Create and animate letters
for i = 1, #word do
    local char = word:sub(i, i)
    
    local label = Instance.new("TextLabel")
    label.Text = char
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.fromRGB(255, 0, 0)
    label.TextTransparency = 1
    label.TextScaled = false
    label.TextSize = 20
    label.Size = UDim2.new(0, 65, 0, 65)
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.new(0.5, (i - (#word / 2 + 0.5)) * 70, 0.5, 50)
    label.BackgroundTransparency = 1
    label.ZIndex = 2
    label.Parent = frame
    
    -- Add gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 30, 30))
    })
    gradient.Rotation = 90
    gradient.Parent = label
    
    -- Create bounce-in animation
    local startPos = label.Position
    label.Position = label.Position + UDim2.new(0, 0, -0.5, 0)
    
    -- Sequence of tweens
    TweenService:Create(label, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, i * 0.1), {
        TextTransparency = 0,
        TextSize = 60,
        Position = startPos
    }):Play()
    
    -- Add hover effect
    spawn(function()
        while label.Parent do
            TweenService:Create(label, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = startPos + UDim2.new(0, 0, 0, math.random(-3, 3))
            }):Play()
            wait(1)
        end
    end)
    
    -- Add rotation to gradient
    spawn(function()
        local rotation = 90
        while label.Parent do
            gradient.Rotation = rotation
            rotation = rotation + 1
            if rotation >= 360 then rotation = 0 end
            wait(0.05)
        end
    end)
    
    table.insert(letters, label)
    wait(0.1)
end

wait(2.5)
tweenOutAndDestroy()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/LanFouWyne/Astralux/refs/heads/main/Library/Ui/AstraluxUI.lua"))()

-- Create Main Window using Astralux UI
local Window = Library:Window({
    Title = "INK Game by Jorsan",
    Desc = "Semi-automatic",
    Icon = 105059922903197,
    Theme = "Dark", 
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 580, 0, 460)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "INK Game"
    }
})

-- Create Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"})

MainTab:Section({ Title = "Game Features" })

-- Red Light Green Light God Mode
MainTab:Toggle({
    Title = "Red Light God Mode",
    Desc = "Prevents you from being eliminated during Red Light Green Light",
    Value = false,
    Callback = function(state)
        getgenv().Toggles.RedLightGodMode = state
    end
})

-- Glass Bridge ESP
MainTab:Toggle({
    Title = "Glass Bridge ESP",
    Desc = "Shows which glass panels are safe to step on",
    Value = false,
    Callback = function(state)
        getgenv().Toggles.GlassBridgeESP = state
    end
})

-- Tug of War Auto Pull
MainTab:Toggle({
    Title = "Tug of War Auto Pull",
    Desc = "Automatically pulls during Tug of War game",
    Value = false,
    Callback = function(state)
        getgenv().Toggles.TugOfWarAuto = state
    end
})

-- Dalgona Auto Complete
MainTab:Toggle({
    Title = "Dalgona Auto Complete",
    Desc = "Automatically completes the Dalgona cookie challenge",
    Value = false,
    Callback = function(state)
        getgenv().Toggles.DalgonaAuto = state
    end
})

-- Player Tab
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"})

PlayerTab:Section({ Title = "Player Modifications" })

-- WalkSpeed Toggle
PlayerTab:Toggle({
    Title = "Enable WalkSpeed",
    Desc = "Toggle custom walk speed",
    Value = false,
    Callback = function(state)
        getgenv().Toggles.EnableWalkSpeed = state
    end
})

-- WalkSpeed Slider
PlayerTab:Slider({
    Title = "Walk Speed",
    Desc = "Adjust player walk speed",
    Value = 16,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(value)
        getgenv().Options.WalkSpeed = value
    end
})

-- NoClip Toggle
PlayerTab:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Value = false,
    Callback = function(state)
        getgenv().Toggles.Noclip = state
    end
})

-- Helper function to create compatible notifications
local function notify(args)
    Window:Notify({
        Title = args.Title,
        Desc = args.Content,
        Time = args.Duration or 3
    })
end

-- Initialize the original system
local GameState = workspace.Values

local CurrentRunningFeature = nil
local GameChangedConnection = nil

local Features = {
    ["RedLightGreenLight"] = RedLightGreenLight,
    ["Dalgona"] = Dalgona,
    ["TugOfWar"] = TugOfWar,
    ["GlassBridge"] = GlassBridge
}

local function CleanupCurrentFeature()
    if CurrentRunningFeature then
        CurrentRunningFeature:Destroy()
        CurrentRunningFeature = nil
    end
end

local function CurrentGameChanged()
    warn("Current game: " .. GameState.CurrentGame.Value)
    
    CleanupCurrentFeature()
    
    local Feature = Features[GameState.CurrentGame.Value]
    if not Feature then return end

    CurrentRunningFeature = Feature.new(Window)
    CurrentRunningFeature:Start()
end

-- Setup connections
GameChangedConnection = GameState.CurrentGame:GetPropertyChangedSignal("Value"):Connect(CurrentGameChanged)
CurrentGameChanged()

notify{
    Title = "Script Loaded",
    Content = "Enjoy!",
    Duration = 5
}

Window:SelectTab(1)

-- @class RedLightGreenLight
local RedLightGreenLight = {}
RedLightGreenLight.__index = RedLightGreenLight

function RedLightGreenLight.new(UIManager)
    local self = setmetatable({}, RedLightGreenLight)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    self._Maid:GiveTask(function()
        self._IsGreenLight = nil
        self._LastRootPartCFrame = nil
    end)

    return self
end

function RedLightGreenLight:Start()
    local Client = Players.LocalPlayer
    local TrafficLightImage = Client.PlayerGui:WaitForChild("ImpactFrames"):WaitForChild("TrafficLightEmpty")

    self._IsGreenLight = TrafficLightImage.Image == ReplicatedStorage.Effects.Images.TrafficLights.GreenLight.Image

    local RootPart = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
    self._LastRootPartCFrame = RootPart and RootPart.CFrame
    
    self._Maid:GiveTask(ReplicatedStorage.Remotes.Effects.OnClientEvent:Connect(function(EffectsData)
        if EffectsData.EffectName ~= "TrafficLight" then return end

        self._IsGreenLight = EffectsData.GreenLight == true

        local RootPart = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")
        self._LastRootPartCFrame = RootPart and RootPart.CFrame
    end))

    local OriginalNamecall
    OriginalNamecall = hookfunction(getrawmetatable(game).__namecall, newcclosure(function(Instance, ...)
        local Args = {...}

        if getnamecallmethod() == "FireServer" and Instance.ClassName == "RemoteEvent" and Instance.Name == "rootCFrame" then
            if self._UIManager:GetToggleValue("RedLightGodMode") and self._IsGreenLight == false and self._LastRootPartCFrame then
                -- Send cached CFrame data when it's red light
                Args[1] = self._LastRootPartCFrame
                return OriginalNamecall(Instance, unpack(Args))
            end
        end

        return OriginalNamecall(Instance, ...)
    end))

    self._Maid:GiveTask(function()
        hookfunction(getrawmetatable(game).__namecall, OriginalNamecall)
    end)

    warn("RLGL feature started!")
end

function RedLightGreenLight:Destroy()
    warn("RLGL feature destroyed!")
    self._Maid:Destroy()
end

-- @class Dalgona
local Dalgona = {}
Dalgona.__index = Dalgona

function Dalgona.new(UIManager)
    local self = setmetatable({}, Dalgona)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    return self
end

function Dalgona:Start()
    local DalgonaClientModule = game.ReplicatedStorage.Modules.Games.DalgonaClient

    local function CompleteDalgona()
        --[[
            Search for the callback of RunService.RenderStepped
             containing an upvalue used to keep track of the amount of successful clicks
             for the Dalgona challenge.

            Setting this upvalue (amount of successful clicks) to a large number
             will allow it to pass the Dalgona challenge checks.
        ]]

        if not self._UIManager:GetToggleValue("DalgonaAuto") then return end

        for _, Value in ipairs(getreg()) do
            if typeof(Value) == "function" and islclosure(Value) then
                if getfenv(Value).script == DalgonaClientModule then
                    if getinfo(Value).nups == 54 then
                        setupvalue(Value, 15, 9e9)
                        break
                    end
                end
            end
        end
    end
    
    local OriginalDalgonaFunction
    OriginalDalgonaFunction = hookfunction(require(DalgonaClientModule), function(...)
        task.delay(3, CompleteDalgona)        
        return OriginalDalgonaFunction(...)
    end)

    self._Maid:GiveTask(function()
        hookfunction(require(DalgonaClientModule), OriginalDalgonaFunction)
        self._UIManager.Toggles.DalgonaAuto:OnChanged(function() end)
    end)
    
    self._UIManager.Toggles.DalgonaAuto:OnChanged(CompleteDalgona)
    
    warn("Dalgona feature started!")
end

function Dalgona:Destroy()
    warn("Dalgona feature destroyed!")
    self._Maid:Destroy()
end

-- @class TugOfWar
local TugOfWar = {}
TugOfWar.__index = TugOfWar

function TugOfWar.new(UIManager)
    local self = setmetatable({}, TugOfWar)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    return self
end

function TugOfWar:Start()
    local TemporaryReachedBindableRemote = ReplicatedStorage.Remotes.TemporaryReachedBindable
    
    local PULL_RATE = 0.025
    local VALID_PULL_DATA = {
        ["QTEGood"] = true
    }

    self._Maid:GiveTask(task.spawn(function()
        while task.wait(PULL_RATE) do
            if self._UIManager:GetToggleValue("TugOfWarAuto") then
                TemporaryReachedBindableRemote:FireServer(VALID_PULL_DATA)
            end
        end
    end))

    warn("TugOfWar feature started!")
end

function TugOfWar:Destroy()
    warn("TugOfWar feature destroyed!")
    self._Maid:Destroy()
end

-- @class GlassBridge
local GlassBridge = {}
GlassBridge.__index = GlassBridge

function GlassBridge.new(UIManager)
    local self = setmetatable({}, GlassBridge)

    self._UIManager = UIManager
    self._Maid = Maid.new()

    return self
end

function GlassBridge:Start()
    local GlassHolder = workspace.GlassBridge.GlassHolder

    local function SetupGlassPart(GlassPart)
        local CanEnableGlassBridgeESP = self._UIManager:GetToggleValue("GlassBridgeESP")
        if not CanEnableGlassBridgeESP then
            GlassPart.Color = Color3.fromRGB(106, 106, 106)
            GlassPart.Transparency = 0.45
            GlassPart.Material = Enum.Material.SmoothPlastic
        else
            -- Game owner is quite funny :skull:
            local Color = GlassPart:GetAttribute("exploitingisevil") and Color3.fromRGB(248, 87, 87) or Color3.fromRGB(28, 235, 87)
            GlassPart.Color = Color
            GlassPart.Transparency = 0
            GlassPart.Material = Enum.Material.Neon
        end
    end
    
    self._UIManager.Toggles.GlassBridgeESP:OnChanged(function()
        for _, PanelPair in ipairs(GlassHolder:GetChildren()) do
            for _, Panel in ipairs(PanelPair:GetChildren()) do
                local GlassPart = Panel:FindFirstChild("glasspart")
                if GlassPart then
                    task.defer(SetupGlassPart, GlassPart)
                end
            end
        end
    end)

    self._Maid:GiveTask(GlassHolder.DescendantAdded:Connect(function(Descendant)
        if Descendant.Name == "glasspart" and Descendant:IsA("BasePart") then
            task.defer(SetupGlassPart, Descendant)
        end
    end))

    self._Maid:GiveTask(function()
        self._UIManager.Toggles.GlassBridgeESP:OnChanged(function() end)
    end)

    warn("GlassBridge feature started!")
end

function GlassBridge:Destroy()
    warn("GlassBridge feature destroyed!")
    self._Maid:Destroy()
end

-- @class UIManager
local UIManager = {}
UIManager.__index = UIManager

function UIManager.new()
    local self = setmetatable({}, UIManager)
    
    self._Maid = Maid.new()
    self._Library = nil
    self._Window = nil
    self._Tabs = {}
    
    self.IsDestroyed = false

    -- Load and initialize the UI
    self:_LoadLibrary()
    
    self.Toggles = getgenv().Toggles
    self.Options = getgenv().Options

    self:_CreateWindow()
    self:_SetupTabs()
    
    self._Maid:GiveTask(function()
        self.IsDestroyed = true
        self._Library:Unload()
        
        -- Clear references
        self._Library = nil
        self._Window = nil
        self._Tabs = nil
        self.Toggles = nil
        self.Options = nil

        -- Terminate the script
        shared._InkGameScriptState.Cleanup()
    end)
    
    return self
end

function UIManager:_LoadLibrary()
    self._Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkClpher/RBX-Scripts/refs/heads/main/UI-Libraries/LinoriaUI.luau'))()
    if not self._Library then
        error("Failed to load LinoriaLib")
    end
end

function UIManager:_CreateWindow()
    self._Window = self._Library:CreateWindow({
        Title = "Ink Game Cheats | Script Author: Jorsan | UI Library: Linoria",
        Center = true,
        AutoShow = true,
        TabPadding = 8,
        MenuFadeTime = 0.2,
        Size = UDim2.new(0, 500, 0, 400)
    })
end

function UIManager:_SetupTabs()
    -- Create tabs
    self._Tabs = {
        Main = self._Window:AddTab("Main"),
        Player = self._Window:AddTab("Player"),
        Settings = self._Window:AddTab("Settings")
    }
    
    -- Setup tabs
    self:_SetupMainCheatsTab()
    self:_SetupPlayerTab()
    self:_SetupSettingsTab()
end

function UIManager:_SetupMainCheatsTab()
    local GameCheats = self._Tabs.Main:AddLeftGroupbox("Game Features")
    
    -- Red Light Green Light God Mode
    GameCheats:AddToggle("RedLightGodMode", {
        Text = "Red Light God Mode",
        Default = false,
        Tooltip = "Prevents you from being eliminated during Red Light Green Light"
    })
    
    -- Glass Bridge ESP
    GameCheats:AddToggle("GlassBridgeESP", {
        Text = "Glass Bridge ESP",
        Default = false,
        Tooltip = "Shows which glass panels are safe to step on"
    })
    
    -- Tug of War Auto Pull
    GameCheats:AddToggle("TugOfWarAuto", {
        Text = "Tug of War Auto Pull",
        Default = false,
        Tooltip = "Automatically pulls during Tug of War game"
    })
    
    -- Dalgona Auto Complete
    GameCheats:AddToggle("DalgonaAuto", {
        Text = "Dalgona Auto Complete",
        Default = false,
        Tooltip = "Automatically completes the Dalgona cookie challenge"
    })
    
    -- Add divider and status
    GameCheats:AddDivider()
    GameCheats:AddLabel("Status: Ready")
end

function UIManager:_SetupPlayerTab()
    local PlayerSettings = self._Tabs.Player:AddLeftGroupbox("Player Modifications")

    -- NoClip Toggle
    PlayerSettings:AddToggle("EnableWalkSpeed", {
        Text = "Enable WalkSpeed",
        Default = false
    })

    -- WalkSpeed Changer
    PlayerSettings:AddSlider("WalkSpeed", {
        Text = "Walk Speed",
        Default = 16,
        Min = 1,
        Max = 100,
        Rounding = 0,
        Compact = false,
        Suffix = " studs/s"
    })

    -- Add divider
    PlayerSettings:AddDivider()

    -- NoClip Toggle
    PlayerSettings:AddToggle("Noclip", {
        Text = "Noclip",
        Default = false,
        Tooltip = "Walk through walls"
    })

    -- Setup character cheats
    local Client = Players.LocalPlayer
    local CharacterMaid = Maid.new()

    self._Maid:GiveTask(CharacterMaid)

    local function OnCharacterAdded(Character)
        CharacterMaid:DoCleaning()
        local Humanoid = Character:WaitForChild("Humanoid")
        
        local CachedBaseParts = {}
        for _, Object in ipairs(Character:GetDescendants()) do
            if Object:IsA("BasePart") then
                table.insert(CachedBaseParts, Object)
            end
        end

        CharacterMaid:GiveTask(Character.DescendantAdded:Connect(function(Descendant)
            if Descendant:IsA("BasePart") then
                table.insert(CachedBaseParts, Descendant)
            end
        end))
        
        local function ChangeWalkSpeed()
            if not self:GetToggleValue("EnableWalkSpeed") then return end
            local NewWalkSpeed = self:GetOptionValue("WalkSpeed")
            if not NewWalkSpeed then return end
        
            Humanoid.WalkSpeed = NewWalkSpeed
        end
        
        CharacterMaid:GiveTask(Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(ChangeWalkSpeed))

        local NoclippedBaseParts = {}
        CharacterMaid:GiveTask(RunService.Stepped:Connect(function()
            if not self:GetToggleValue("Noclip") then
                for BasePart, _ in NoclippedBaseParts do
                    NoclippedBaseParts[BasePart] = nil
                    BasePart.CanCollide = true
                end
                return
            end

            for _, BasePart in ipairs(CachedBaseParts) do
                if BasePart.CanCollide then
                    NoclippedBaseParts[BasePart] = true
                    BasePart.CanCollide = false
                end
            end
        end))
        
        CharacterMaid:GiveTask(function()
            for BasePart, _ in NoclippedBaseParts do
                NoclippedBaseParts[BasePart] = nil
                BasePart.CanCollide = true
            end
        end)

        self.Toggles.EnableWalkSpeed:OnChanged(ChangeWalkSpeed)
        self.Options.WalkSpeed:OnChanged(ChangeWalkSpeed)
    end

    self._Maid:GiveTask(function()
        self.Toggles.EnableWalkSpeed:OnChanged(function() end)
        self.Options.WalkSpeed:OnChanged(function() end)
    end)
    
    self._Maid:GiveTask(Client.CharacterAdded:Connect(OnCharacterAdded))
    
    if Client.Character then
        task.spawn(OnCharacterAdded, Client.Character)
    end
end

function UIManager:_SetupSettingsTab()
    local MenuSettings = self._Tabs.Settings:AddLeftGroupbox("Menu Settings")
    
    MenuSettings:AddButton({
        Text = "Unload/Destroy Script",
        Func = function()
            self:Destroy()
        end,
        Tooltip = "Completely removes and destroys the script"
    })
end

function UIManager:GetToggleValue(ToggleName)
    if self.Toggles and self.Toggles[ToggleName] then
        return self.Toggles[ToggleName].Value
    end
    return false
end

function UIManager:GetOptionValue(OptionName)
    if self.Options and self.Options[OptionName] then
        return self.Options[OptionName].Value
    end
    
    return nil
end

function UIManager:Notify(Text, Duration)
    if not self._Library then return end
    self._Library:Notify(Text, Duration)
end

function UIManager:Destroy()
    if self.IsDestroyed then return end
    self._Maid:Destroy()
    
    warn("UIManager destroyed successfully!")
end

-- Validate game
assert(game.GameId == 7008097940, "Invalid Game!")

-- Setup Global State
if not shared._InkGameScriptState then
    shared._InkGameScriptState = {
        IsScriptExecuted = false,
        IsScriptReady = false,
        ScriptReady = Signal.new(),
        Cleanup = function() end
    }
end

local GlobalScriptState = shared._InkGameScriptState

-- Handle script re-execution
if GlobalScriptState.IsScriptExecuted then
    if not GlobalScriptState.IsScriptReady then
        GlobalScriptState.ScriptReady:Wait()
        if GlobalScriptState.IsScriptReady then return end
    end
    GlobalScriptState.Cleanup()
end

GlobalScriptState.IsScriptExecuted = true

-- Main
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local UI = UIManager.new()
local GameState = workspace.Values

local CurrentRunningFeature = nil
local GameChangedConnection = nil

local Features = {
    ["RedLightGreenLight"] = RedLightGreenLight,
    ["Dalgona"] = Dalgona,
    ["TugOfWar"] = TugOfWar,
    ["GlassBridge"] = GlassBridge
}

local function CleanupCurrentFeature()
    if CurrentRunningFeature then
        CurrentRunningFeature:Destroy()
        CurrentRunningFeature = nil
    end
end

local function CurrentGameChanged()
    warn("Current game: " .. GameState.CurrentGame.Value)
    
    CleanupCurrentFeature()
    
    local Feature = Features[GameState.CurrentGame.Value]
    if not Feature then return end

    CurrentRunningFeature = Feature.new(UI)
    CurrentRunningFeature:Start()
end

-- Setup connections
GameChangedConnection = GameState.CurrentGame:GetPropertyChangedSignal("Value"):Connect(CurrentGameChanged)
CurrentGameChanged()

-- Global cleanup function
GlobalScriptState.Cleanup = function()
    CleanupCurrentFeature()
    
    if GameChangedConnection then
        GameChangedConnection:Disconnect()
        GameChangedConnection = nil
    end
    
    if not UI.IsDestroyed then
        UI:Destroy()
    end
    
    GlobalScriptState.IsScriptReady = false
    GlobalScriptState.IsScriptExecuted = false
end

-- Mark as ready
GlobalScriptState.IsScriptReady = true
GlobalScriptState.ScriptReady:Fire()

UI:Notify("Script executed successfully!", 4)
UI:Notify("Script authored by: Astralux, enjoy!", 4)
