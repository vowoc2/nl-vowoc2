--=========================================================
-- NEVERLOSE UI — 1/13 (FIX v3)
-- База: сервисы, цвета, конфиг, ScreenGui, Watermark,
--       MainFrame, табы, ВСЕ UI-билдеры
-- ФИКСЫ:
--   • Перезапуск без "Уже запущено"
--   • Удаление старых NL-инстансов
--   • Guard для Cheat в Jump-петле
--   • pcall везде где может упасть
--   • Безопасный Watermark drag
--   • ДОБАВЛЕНЫ БИЛДЕРЫ: createCheckbox / createSlider /
--     createCycle / createButton (без них части 3+ крашились)
--=========================================================

--========== ПЕРЕЗАПУСК ==========
if _G.NeverloseUILoaded then
    warn("[NL] Обнаружен предыдущий запуск — выгружаю...")
    pcall(function()
        if _G.NL_UnloadComplete then _G.NL_UnloadComplete() end
    end)
    pcall(function()
        if _G.NL_ScreenGui and _G.NL_ScreenGui.Parent then
            _G.NL_ScreenGui:Destroy()
        end
    end)
    task.wait(0.3)
end

_G.NeverloseUILoaded = true

--========== SERVICES ==========
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats        = game:GetService("Stats")
local Lighting     = game:GetService("Lighting")
local HttpService  = game:GetService("HttpService")
local Pathfinding  = game:GetService("PathfindingService")
local VIM          = game:GetService("VirtualInputManager")
local CoreGui      = game:GetService("CoreGui")
local StarterGui   = game:GetService("StarterGui")

--========== GLOBALS ==========
LP    = Players.LocalPlayer
PG    = LP:WaitForChild("PlayerGui", 15)
Cam   = workspace.CurrentCamera
Mouse = LP:GetMouse()

--========== HELPERS ==========
function hasFileAPI()
    return type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
end

--========== COLORS ==========
NL_BLUE   = Color3.fromRGB(0, 140, 255)
NL_DARK   = Color3.fromRGB(15, 15, 20)
NL_DARKER = Color3.fromRGB(10, 10, 14)
NL_TEXT   = Color3.fromRGB(230, 230, 235)
NL_DIM    = Color3.fromRGB(140, 140, 150)
NL_RED    = Color3.fromRGB(220, 50, 60)
NL_GREEN  = Color3.fromRGB(50, 200, 100)
NL_YELLOW = Color3.fromRGB(255, 200, 0)
NL_WHITE  = Color3.fromRGB(255, 255, 255)

--========== CONFIG ==========
Cfg = {
    Accent        = Color3.fromRGB(0, 140, 255),
    Rainbow       = false,
    RainbowSpeed  = 1,
    MenuSize      = "Medium",
    BlurEnabled   = true,
    BlurIntensity = 15,
    Version       = "v16-XENO",
    SaveFile      = "neverlose_config.json",
}

--========== CHEAT STATE ==========
Cheat = {
    Fly        = false, FlySpeed    = 50,
    Speed      = false, SpeedValue  = 16,
    Noclip     = false,
    BunnyHop   = false,
    SpinBot    = false, SpinSpeed   = 20,
    Spider     = false, SpiderSpeed = 40,
    InfJump    = false,
    Jump       = false, JumpPower   = 50, JumpMode = "Power", JumpHeight = 7.2,

    ESP        = false, ESPColor    = Color3.fromRGB(0, 140, 255),
    FullBright = false,
    BlackSky   = false,
    Snow       = false,
    WorldColor = Color3.fromRGB(0, 140, 255), WorldColorEnabled = false,
    Fog        = false, FogColor    = Color3.fromRGB(200, 200, 200), FogDistance = 100,

    AutoClicker = false, AutoClickCPS = 10, AutoClickButton = 0,
    AutoClickRandom = false, AutoClickDelay = 0,
    Hat = false,

    AntiFling     = false,
    AntiKnockback = false,
    AntiRagdoll   = false,
}

--========== ACCENT SYSTEM ==========
AccentElements = {}

function registerAccent(obj, prop)
    if not obj then return end
    table.insert(AccentElements, {obj = obj, prop = prop or "BackgroundColor3"})
end

function updateAllAccents(color)
    color = color or Cfg.Accent
    for i = #AccentElements, 1, -1 do
        local el = AccentElements[i]
        if not el.obj or not el.obj.Parent then
            table.remove(AccentElements, i)
        else
            pcall(function() el.obj[el.prop] = color end)
        end
    end
end

--========== UTILS ==========
function tween(o, t, p, s, d)
    if not o or not o.Parent then return end
    local info = TweenInfo.new(t or 0.2, s or Enum.EasingStyle.Quad, d or Enum.EasingDirection.Out)
    local T = TweenService:Create(o, info, p)
    T:Play()
    return T
end

function keyName(kc)
    if not kc then return "None" end
    return (kc.Name or "Unknown"):gsub("KeyCode%.", "")
end

--========== BLUR ==========
BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = Lighting

--========== WAIT GAME ==========
task.wait(1)

--=========================================================
-- ScreenGui поверх ВСЕГО
--=========================================================
ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NL"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

_G.NL_ScreenGui = ScreenGui

local parented = false
if type(gethui) == "function" then
    local ok, hui = pcall(gethui)
    if ok and hui then
        local ok2 = pcall(function() ScreenGui.Parent = hui end)
        if ok2 then parented = true end
    end
end

if not parented then
    local ok = pcall(function() ScreenGui.Parent = CoreGui end)
    if ok then parented = true end
end

if not parented then
    pcall(function() ScreenGui.Parent = PG end)
end

pcall(function() ScreenGui.DisplayOrder = 999999 end)
pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)

--========== MENU SIZES ==========
MenuSizes = {
    Small  = {w = 600,  h = 420},
    Medium = {w = 740,  h = 500},
    Large  = {w = 920,  h = 620},
    Huge   = {w = 1100, h = 720},
}

function getMenuSize()
    return MenuSizes[Cfg.MenuSize] or MenuSizes.Medium
end

--=========================================================
-- WATERMARK
--=========================================================
WM = Instance.new("Frame")
WM.Name = "NL_Watermark"
WM.BackgroundColor3 = NL_DARKER
WM.BackgroundTransparency = 0.1
WM.BorderSizePixel = 0
WM.AnchorPoint = Vector2.new(1, 0)
WM.Position = UDim2.new(1, -15, 0, 15)
WM.Size = UDim2.new(0, 260, 0, 30)
WM.AutomaticSize = Enum.AutomaticSize.X
WM.Active = true
WM.ZIndex = 200
WM.Visible = false
WM.Parent = ScreenGui

local WMC = Instance.new("UICorner")
WMC.CornerRadius = UDim.new(0, 6)
WMC.Parent = WM

WMS = Instance.new("UIStroke")
WMS.Color = NL_BLUE
WMS.Thickness = 1
WMS.Transparency = 0.3
WMS.Parent = WM
registerAccent(WMS, "Color")

local WML = Instance.new("UIListLayout")
WML.FillDirection = Enum.FillDirection.Horizontal
WML.Padding = UDim.new(0, 8)
WML.VerticalAlignment = Enum.VerticalAlignment.Center
WML.HorizontalAlignment = Enum.HorizontalAlignment.Center
WML.SortOrder = Enum.SortOrder.LayoutOrder
WML.Parent = WM

local WMP = Instance.new("UIPadding")
WMP.PaddingLeft = UDim.new(0, 12)
WMP.PaddingRight = UDim.new(0, 12)
WMP.Parent = WM

LogoLabel = Instance.new("TextLabel")
LogoLabel.Size = UDim2.new(0, 72, 1, 0)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Text = "neverlose"
LogoLabel.TextColor3 = NL_BLUE
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.TextSize = 14
LogoLabel.LayoutOrder = 1
LogoLabel.ZIndex = 201
LogoLabel.Parent = WM
registerAccent(LogoLabel, "TextColor3")

local Sep1 = Instance.new("Frame")
Sep1.Size = UDim2.new(0, 1, 0, 14)
Sep1.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
Sep1.BorderSizePixel = 0
Sep1.LayoutOrder = 2
Sep1.ZIndex = 201
Sep1.Parent = WM

FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0, 62, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "fps: 60"
FPSLabel.TextColor3 = NL_TEXT
FPSLabel.Font = Enum.Font.Gotham
FPSLabel.TextSize = 13
FPSLabel.LayoutOrder = 3
FPSLabel.ZIndex = 201
FPSLabel.Parent = WM

local Sep2 = Instance.new("Frame")
Sep2.Size = UDim2.new(0, 1, 0, 14)
Sep2.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
Sep2.BorderSizePixel = 0
Sep2.LayoutOrder = 4
Sep2.ZIndex = 201
Sep2.Parent = WM

PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0, 62, 1, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "ping: 20"
PingLabel.TextColor3 = NL_TEXT
PingLabel.Font = Enum.Font.Gotham
PingLabel.TextSize = 13
PingLabel.LayoutOrder = 5
PingLabel.ZIndex = 201
PingLabel.Parent = WM

--========== FPS / PING UPDATE ==========
task.spawn(function()
    local fps, fc, lt = 0, 0, tick()
    while _G.NeverloseUILoaded do
        RunService.RenderStepped:Wait()
        fc = fc + 1
        if tick() - lt >= 1 then
            fps = fc
            fc = 0
            lt = tick()
            if FPSLabel and FPSLabel.Parent then
                FPSLabel.Text = "fps: " .. fps
            end
            local ok, pv = pcall(function()
                return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            if PingLabel and PingLabel.Parent then
                PingLabel.Text = "ping: " .. (ok and math.floor(pv) or "0")
            end
        end
    end
end)

--========== WATERMARK DRAG ==========
local wmDrag = false
local wmSM, wmSP

WM.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        wmDrag = true
        wmSM = Vector2.new(input.Position.X, input.Position.Y)
        local ap = WM.AbsolutePosition
        WM.AnchorPoint = Vector2.new(0, 0)
        WM.Position = UDim2.new(0, ap.X, 0, ap.Y)
        wmSP = Vector2.new(ap.X, ap.Y)
    end
end)

UIS.InputChanged:Connect(function(input)
    if not wmDrag then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if not WM or not WM.Parent then wmDrag = false return end

    local d = Vector2.new(input.Position.X, input.Position.Y) - wmSM
    local nx, ny = wmSP.X + d.X, wmSP.Y + d.Y
    local vp = (Cam and Cam.ViewportSize) or Vector2.new(1920, 1080)
    local ws = WM.AbsoluteSize
    nx = math.clamp(nx, 0, math.max(0, vp.X - ws.X))
    ny = math.clamp(ny, 0, math.max(0, vp.Y - ws.Y))
    WM.Position = UDim2.new(0, nx, 0, ny)
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        wmDrag = false
    end
end)

--=========================================================
-- MAIN FRAME
--=========================================================
MainFrame = Instance.new("Frame")
local initSize = getMenuSize()
MainFrame.Size = UDim2.new(0, initSize.w, 0, initSize.h)
MainFrame.Position = UDim2.new(0.5, -initSize.w / 2, 0.5, -initSize.h / 2)
MainFrame.BackgroundColor3 = NL_DARK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.ZIndex = 50
MainFrame.Parent = ScreenGui

local MainC = Instance.new("UICorner")
MainC.CornerRadius = UDim.new(0, 8)
MainC.Parent = MainFrame

MainS = Instance.new("UIStroke")
MainS.Color = NL_BLUE
MainS.Thickness = 1
MainS.Transparency = 0.5
MainS.Parent = MainFrame
registerAccent(MainS, "Color")

--========== TITLE BAR ==========
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = NL_DARKER
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 51
TitleBar.Parent = MainFrame

local TitleC = Instance.new("UICorner")
TitleC.CornerRadius = UDim.new(0, 8)
TitleC.Parent = TitleBar

local TitleCover = Instance.new("Frame")
TitleCover.Size = UDim2.new(1, 0, 0, 8)
TitleCover.Position = UDim2.new(0, 0, 1, -8)
TitleCover.BackgroundColor3 = NL_DARKER
TitleCover.BorderSizePixel = 0
TitleCover.ZIndex = 51
TitleCover.Parent = TitleBar

local TitleLogo = Instance.new("TextLabel")
TitleLogo.Size = UDim2.new(0, 50, 1, 0)
TitleLogo.Position = UDim2.new(0, 14, 0, 0)
TitleLogo.BackgroundTransparency = 1
TitleLogo.Text = "NL"
TitleLogo.TextColor3 = NL_BLUE
TitleLogo.Font = Enum.Font.GothamBold
TitleLogo.TextSize = 18
TitleLogo.TextXAlignment = Enum.TextXAlignment.Left
TitleLogo.ZIndex = 52
TitleLogo.Parent = TitleBar
registerAccent(TitleLogo, "TextColor3")

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 120, 1, 0)
TitleLabel.Position = UDim2.new(0, 55, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Neverlose"
TitleLabel.TextColor3 = NL_TEXT
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 52
TitleLabel.Parent = TitleBar

local TitleVersion = Instance.new("TextLabel")
TitleVersion.Size = UDim2.new(0, 100, 1, 0)
TitleVersion.Position = UDim2.new(0, 180, 0, 0)
TitleVersion.BackgroundTransparency = 1
TitleVersion.Text = Cfg.Version
TitleVersion.TextColor3 = NL_DIM
TitleVersion.Font = Enum.Font.Gotham
TitleVersion.TextSize = 11
TitleVersion.TextXAlignment = Enum.TextXAlignment.Left
TitleVersion.ZIndex = 52
TitleVersion.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 38, 1, 0)
CloseBtn.Position = UDim2.new(1, -38, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = NL_DIM
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 52
CloseBtn.Parent = TitleBar

CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, 0.15, {TextColor3 = NL_RED}) end)
CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, 0.15, {TextColor3 = NL_DIM}) end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

--========== CUSTOM DRAG ==========
local mainDrag = false
local mainSM, mainSP

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        if input.Position and CloseBtn.AbsolutePosition then
            local r = Rect.new(CloseBtn.AbsolutePosition, CloseBtn.AbsoluteSize)
            if r:Contains(input.Position) then return end
        end
        mainDrag = true
        mainSM = Vector2.new(input.Position.X, input.Position.Y)
        mainSP = Vector2.new(MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y)
    end
end)

UIS.InputChanged:Connect(function(input)
    if not mainDrag then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if not MainFrame or not MainFrame.Parent then mainDrag = false return end

    local d = Vector2.new(input.Position.X, input.Position.Y) - mainSM
    local vp = (Cam and Cam.ViewportSize) or Vector2.new(1920, 1080)
    local ms = MainFrame.AbsoluteSize
    local nx = math.clamp(mainSP.X + d.X, -ms.X * 0.5, vp.X - ms.X * 0.5)
    local ny = math.clamp(mainSP.Y + d.Y, 0, vp.Y - 40)
    MainFrame.Position = UDim2.new(0, nx, 0, ny)
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        mainDrag = false
    end
end)

--========== SIDE PANEL ==========
local SidePanel = Instance.new("Frame")
SidePanel.Size = UDim2.new(0, 150, 1, -38)
SidePanel.Position = UDim2.new(0, 0, 0, 38)
SidePanel.BackgroundColor3 = NL_DARKER
SidePanel.BorderSizePixel = 0
SidePanel.ZIndex = 51
SidePanel.Parent = MainFrame

local SideL = Instance.new("UIListLayout")
SideL.Padding = UDim.new(0, 6)
SideL.Parent = SidePanel

local SideP = Instance.new("UIPadding")
SideP.PaddingTop = UDim.new(0, 12)
SideP.PaddingLeft = UDim.new(0, 12)
SideP.PaddingRight = UDim.new(0, 12)
SideP.Parent = SidePanel

--========== CONTENT ==========
ContentArea = Instance.new("ScrollingFrame")
ContentArea.Size = UDim2.new(1, -150, 1, -38)
ContentArea.Position = UDim2.new(0, 150, 0, 38)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 4
ContentArea.ScrollBarImageColor3 = NL_BLUE
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.ScrollBarImageTransparency = 0.3
ContentArea.ZIndex = 51
ContentArea.Parent = MainFrame
registerAccent(ContentArea, "ScrollBarImageColor3")

--========== TABS ==========
tabs = {}
activeTab = nil
contentFrame = nil
local tabLayoutOrder = 0

function createTab(name)
    if tabs[name] then return tabs[name] end
    tabLayoutOrder = tabLayoutOrder + 1

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = NL_DARKER
    b.BackgroundTransparency = 1
    b.Text = "  " .. name
    b.TextColor3 = NL_DIM
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.ZIndex = 52
    b.LayoutOrder = tabLayoutOrder
    b.Parent = SidePanel

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = b

    local ind = Instance.new("Frame")
    ind.Size = UDim2.new(0, 3, 0, 18)
    ind.Position = UDim2.new(0, 0, 0.5, -9)
    ind.BackgroundColor3 = NL_BLUE
    ind.BorderSizePixel = 0
    ind.Visible = false
    ind.ZIndex = 53
    ind.Parent = b
    registerAccent(ind, "BackgroundColor3")

    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(1, 0)
    ic.Parent = ind

    b.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            if t.btn then
                t.btn.BackgroundTransparency = 1
                t.btn.TextColor3 = NL_DIM
            end
            if t.ind then t.ind.Visible = false end
        end
        b.BackgroundTransparency = 0.85
        b.BackgroundColor3 = NL_BLUE
        b.TextColor3 = NL_TEXT
        ind.Visible = true
        activeTab = name

        if contentFrame and contentFrame.Parent then
            contentFrame.Visible = false
        end
        if tabs[name] and tabs[name].content and tabs[name].content.Parent then
            tabs[name].content.Visible = true
            contentFrame = tabs[name].content
        end
    end)

    b.MouseEnter:Connect(function()
        if activeTab ~= name then tween(b, 0.15, {TextColor3 = NL_TEXT}) end
    end)
    b.MouseLeave:Connect(function()
        if activeTab ~= name then tween(b, 0.15, {TextColor3 = NL_DIM}) end
    end)

    tabs[name] = { btn = b, ind = ind, content = nil }
    return tabs[name]
end

local TAB_ORDER = {
    "Visuals", "Misc", "Teleport", "Cursor TP",
    "Baritone", "Fling", "HUD", "Config", "Settings",
}
for _, name in ipairs(TAB_ORDER) do createTab(name) end

function makeTabContent(tabName)
    if not tabs[tabName] then return nil end

    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 0)
    c.BackgroundTransparency = 1
    c.AutomaticSize = Enum.AutomaticSize.Y
    c.Visible = false
    c.ZIndex = 52
    c.Parent = ContentArea

    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, 12)
    p.PaddingLeft = UDim.new(0, 14)
    p.PaddingRight = UDim.new(0, 14)
    p.PaddingBottom = UDim.new(0, 14)
    p.Parent = c

    tabs[tabName].content = c
    return c
end

--=========================================================
-- LAYOUT BUILDERS
--=========================================================
function createColumn(parent, side)
    local col = Instance.new("Frame")
    if side == "right" then
        col.Size = UDim2.new(0.5, -6, 0, 0)
        col.Position = UDim2.new(0.5, 6, 0, 0)
    else
        col.Size = UDim2.new(0.5, -6, 0, 0)
        col.Position = UDim2.new(0, 0, 0, 0)
    end
    col.BackgroundTransparency = 1
    col.AutomaticSize = Enum.AutomaticSize.Y
    col.ZIndex = 52
    col.Parent = parent

    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 10)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = col

    return col
end

function createSection(parent, title)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, 0, 0, 40)
    s.BackgroundColor3 = NL_DARKER
    s.BackgroundTransparency = 0.3
    s.BorderSizePixel = 0
    s.AutomaticSize = Enum.AutomaticSize.Y
    s.ZIndex = 52
    s.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = s

    local st = Instance.new("UIStroke")
    st.Color = NL_BLUE
    st.Thickness = 1
    st.Transparency = 0.8
    st.Parent = s
    registerAccent(st, "Color")

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -20, 0, 28)
    t.Position = UDim2.new(0, 10, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = NL_TEXT
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 53
    t.Parent = s

    local ct = Instance.new("Frame")
    ct.Size = UDim2.new(1, 0, 0, 0)
    ct.Position = UDim2.new(0, 0, 0, 36)
    ct.BackgroundTransparency = 1
    ct.AutomaticSize = Enum.AutomaticSize.Y
    ct.ZIndex = 53
    ct.Parent = s

    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = ct

    local p = Instance.new("UIPadding")
    p.PaddingBottom = UDim.new(0, 12)
    p.PaddingLeft = UDim.new(0, 10)
    p.PaddingRight = UDim.new(0, 10)
    p.Parent = ct

    return ct
end

--=========================================================
-- ✅ UI-БИЛДЕРЫ (главный фикс — их не было!)
--=========================================================

--========== CHECKBOX ==========
function createCheckbox(parent, label, default, callback, key)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundTransparency = 1
    row.ZIndex = 54
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = NL_TEXT
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 55
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 38, 0, 20)
    btn.Position = UDim2.new(1, -38, 0.5, -10)
    btn.BackgroundColor3 = default and NL_BLUE or NL_DARKER
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 55
    btn.Parent = row

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = btn

    local bs = Instance.new("UIStroke")
    bs.Color = NL_BLUE
    bs.Thickness = 1
    bs.Transparency = 0.5
    bs.Parent = btn
    registerAccent(bs, "Color")

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = default
        and UDim2.new(0, 21, 0.5, -7)
        or  UDim2.new(0, 3, 0.5, -7)
    dot.BackgroundColor3 = NL_WHITE
    dot.BorderSizePixel = 0
    dot.ZIndex = 56
    dot.Parent = btn

    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot

    local state = default or false

    local function apply()
        tween(btn, 0.15, {
            BackgroundColor3 = state and NL_BLUE or NL_DARKER,
        })
        tween(dot, 0.15, {
            Position = state
                and UDim2.new(0, 21, 0.5, -7)
                or  UDim2.new(0, 3, 0.5, -7),
        })
    end

    btn.MouseButton1Click:Connect(function()
        state = not state
        apply()
        if callback then pcall(callback, state) end
    end)

    -- реестр для applyConfig (часть 11)
    _G.NL_Checkboxes = _G.NL_Checkboxes or {}
    if key then
        _G.NL_Checkboxes[key] = {
            set = function(v)
                state = v
                apply()
            end,
            get = function() return state end,
        }
    end

    return {
        set = function(v) state = v apply() end,
        get = function() return state end,
    }
end

--========== SLIDER ==========
function createSlider(parent, label, min, max, default, callback, isColor, colorLabel)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundTransparency = 1
    row.ZIndex = 54
    row.Parent = parent

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 16)
    top.BackgroundTransparency = 1
    top.ZIndex = 55
    top.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = NL_TEXT
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 55
    lbl.Parent = top

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 55, 1, 0)
    valLbl.Position = UDim2.new(1, -55, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default or min)
    valLbl.TextColor3 = NL_DIM
    valLbl.Font = Enum.Font.Gotham
    valLbl.TextSize = 11
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 55
    valLbl.Parent = top

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0, 22)
    bar.BackgroundColor3 = NL_DARKER
    bar.BorderSizePixel = 0
    bar.ZIndex = 55
    bar.Parent = row

    local barc = Instance.new("UICorner")
    barc.CornerRadius = UDim.new(1, 0)
    barc.Parent = bar

    local initPct = 0
    if max > min then
        initPct = ((default or min) - min) / (max - min)
    end
    initPct = math.clamp(initPct, 0, 1)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initPct, 0, 1, 0)
    fill.BackgroundColor3 = NL_BLUE
    fill.BorderSizePixel = 0
    fill.ZIndex = 56
    fill.Parent = bar
    registerAccent(fill, "BackgroundColor3")

    local fillc = Instance.new("UICorner")
    fillc.CornerRadius = UDim.new(1, 0)
    fillc.Parent = fill

    local dragging = false

    local function updateFromInput(ix)
        local absX = bar.AbsolutePosition.X
        local w = bar.AbsoluteSize.X
        if w <= 0 then return end
        local pct = math.clamp((ix - absX) / w, 0, 1)
        local val = math.floor(min + (max - min) * pct + 0.5)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        valLbl.Text = tostring(val)
        if callback then pcall(callback, val) end
    end

    local grabber = Instance.new("TextButton")
    grabber.Size = UDim2.new(1, 0, 0, 14)
    grabber.Position = UDim2.new(0, 0, 0, 18)
    grabber.BackgroundTransparency = 1
    grabber.Text = ""
    grabber.ZIndex = 57
    grabber.Parent = row

    grabber.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then return end
        updateFromInput(input.Position.X)
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {
        set = function(v)
            local pct = 0
            if max > min then pct = (v - min) / (max - min) end
            pct = math.clamp(pct, 0, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            valLbl.Text = tostring(v)
        end,
    }
end

--========== CYCLE ==========
function createCycle(parent, label, options, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.ZIndex = 54
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -110, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = NL_TEXT
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 55
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Position = UDim2.new(1, -100, 0, 0)
    btn.BackgroundColor3 = NL_DARKER
    btn.BorderSizePixel = 0
    btn.Text = default or (options and options[1]) or ""
    btn.TextColor3 = NL_TEXT
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.ZIndex = 55
    btn.Parent = row

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 4)
    bc.Parent = btn

    local bs = Instance.new("UIStroke")
    bs.Color = NL_BLUE
    bs.Thickness = 1
    bs.Transparency = 0.5
    bs.Parent = btn
    registerAccent(bs, "Color")

    local idx = 1
    if options then
        for i, o in ipairs(options) do
            if o == default then idx = i break end
        end
    end

    btn.MouseButton1Click:Connect(function()
        if not options or #options == 0 then return end
        idx = idx + 1
        if idx > #options then idx = 1 end
        btn.Text = options[idx]
        if callback then pcall(callback, options[idx]) end
    end)

    return {
        set = function(v)
            if not options then return end
            for i, o in ipairs(options) do
                if o == v then
                    idx = i
                    btn.Text = o
                    break
                end
            end
        end,
    }
end

--========== BUTTON ==========
function createButton(parent, label, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = color or NL_BLUE
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = NL_WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.ZIndex = 55
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = btn

    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, {BackgroundTransparency = 0.2})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, {BackgroundTransparency = 0})
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)

    return btn
end

--========== KEYBINDS ==========
Keybinds = {}
BindCallbacks = {}
listeningForBind = nil
listenOverlay = nil

function stopListening()
    if listenOverlay and listenOverlay.Parent then
        listenOverlay:Destroy()
    end
    listenOverlay = nil
    listeningForBind = nil
end

function startListeningForBind(btn, action, hint)
    if listeningForBind then stopListening() return end
    listeningForBind = {btn = btn, action = action}
    if btn and btn.Parent then
        btn.Text = "[...]"
        tween(btn, 0.15, {TextColor3 = NL_YELLOW})
    end

    listenOverlay = Instance.new("TextLabel")
    listenOverlay.Size = UDim2.new(0, 340, 0, 40)
    listenOverlay.Position = UDim2.new(0.5, -170, 0, 60)
    listenOverlay.BackgroundColor3 = NL_DARK
    listenOverlay.Text = hint or "Нажми клавишу (ESC — отмена)"
    listenOverlay.TextColor3 = NL_TEXT
    listenOverlay.Font = Enum.Font.Gotham
    listenOverlay.TextSize = 12
    listenOverlay.ZIndex = 500
    listenOverlay.Parent = ScreenGui

    local lc = Instance.new("UICorner")
    lc.CornerRadius = UDim.new(0, 6)
    lc.Parent = listenOverlay

    local ls = Instance.new("UIStroke")
    ls.Color = NL_YELLOW
    ls.Thickness = 1
    ls.Parent = listenOverlay
end

--=========================================================
-- JUMP LOOP (guard — Cheat определяется выше, но петля
-- стартует до загрузки части 2)
--=========================================================
function applyJump()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if not Cheat or not Cheat.Jump then
        hum.UseJumpPower = true
        hum.JumpPower = 50
        return
    end

    if Cheat.JumpMode == "Height" then
        hum.UseJumpPower = false
        hum.JumpHeight = Cheat.JumpHeight
    else
        hum.UseJumpPower = true
        hum.JumpPower = Cheat.JumpPower
    end
end

task.spawn(function()
    while _G.NeverloseUILoaded do
        RunService.Heartbeat:Wait()
        if Cheat and Cheat.Jump then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                if Cheat.JumpMode == "Height" then
                    if hum.UseJumpPower then hum.UseJumpPower = false end
                    if math.abs(hum.JumpHeight - Cheat.JumpHeight) > 0.05 then
                        hum.JumpHeight = Cheat.JumpHeight
                    end
                else
                    if not hum.UseJumpPower then hum.UseJumpPower = true end
                    if math.abs(hum.JumpPower - Cheat.JumpPower) > 0.5 then
                        hum.JumpPower = Cheat.JumpPower
                    end
                end
            end
        end
    end
end)

print("[NL] 1/13 — База загружена (FIX v3, +builders)")
--=========================================================
-- NEVERLOSE UI — 2/13 (FIX v3)
-- Fly • Speed System (Regular/Matrix/Hybrid) • Noclip • BHop
-- SpinBot • Spider • InfJump • FullBright • BlackSky • Snow
-- WorldColor • Fog • AutoClicker • ESP 2D • Cone Hat
-- ФИКСЫ:
--   • SpeedSystem больше не воюет с Baritone Speed Guard
--   • speedWallBlocked защищён от espFolder == nil
--   • Единый Fly с гироскопом и плавным стопом
--   • Snow держит партиклы вне камеры (не лагает)
--   • ESP использует единый RunService-цикл (не RenderStepped отдельный)
--   • Все connections выгружаются через _G.NL_UnloadBase (часть 3)
--=========================================================

if not _G.NeverloseUILoaded then
    warn("[NL] Часть 2: база не загружена (нужна часть 1)")
    return
end

--=========================================================
-- FLY
--=========================================================
flyBV, flyBG, flyConn = nil, nil, nil

function disableFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBV and flyBV.Parent then flyBV:Destroy() end
    if flyBG and flyBG.Parent then flyBG:Destroy() end
    flyBV, flyBG = nil, nil
end

function enableFly()
    disableFly()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "NL_FlyBV"
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.Name = "NL_FlyBG"
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P = 1000
    flyBG.D = 50
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp

    flyConn = RunService.RenderStepped:Connect(function()
        if not _G.NeverloseUILoaded then return end
        if not Cheat.Fly then return end
        if not flyBV or not flyBV.Parent then return end
        if not flyBG or not flyBG.Parent then return end

        local cam = workspace.CurrentCamera
        if not cam then return end

        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end

        if dir.Magnitude > 0 then dir = dir.Unit * Cheat.FlySpeed end
        flyBV.Velocity = dir
        flyBG.CFrame = cam.CFrame
    end)
end

--=========================================================
-- SPEED SYSTEM — 3 режима (Regular / Matrix / Hybrid)
--=========================================================
SpeedSystem = {
    Enabled     = false,
    Mode        = "Matrix",
    Value       = 60,
    SprintMult  = 1.5,
    StepSize    = 3.5,
    GroundOnly  = true,
    WallCheck   = true,
    Smooth      = true,
    RegularWalk = 16,
    HybridWalk  = 24,
    Debug       = false,
}

speedMainConn = nil
speedSprintKeys = {Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift}

function speedIsSprinting()
    for _, k in ipairs(speedSprintKeys) do
        if UIS:IsKeyDown(k) then return true end
    end
    return false
end

function speedGetTarget()
    local base = SpeedSystem.Value
    if speedIsSprinting() then base = base * SpeedSystem.SprintMult end
    return base
end

function speedGetChar()
    local char = LP.Character
    if not char then return nil, nil, nil end
    return char,
           char:FindFirstChild("HumanoidRootPart"),
           char:FindFirstChildOfClass("Humanoid")
end

function speedWallBlocked(char, hrp, dirWorld, dist)
    if not SpeedSystem.WallCheck then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local flist = {char}
    -- ✅ guard: espFolder объявляется в этой же части, но ниже
    if espFolder and espFolder.Parent then
        table.insert(flist, espFolder)
    end
    params.FilterDescendantsInstances = flist

    local origin = hrp.Position + Vector3.new(0, -1.2, 0)
    local hit = workspace:Raycast(origin, dirWorld * (dist + 0.5), params)
    if hit and hit.Instance then
        local top = hit.Instance.Position.Y + hit.Instance.Size.Y / 2
        if top > hrp.Position.Y + 2.2 then
            return true
        end
    end
    return false
end

function speedStart()
    if speedMainConn then return end

    speedMainConn = RunService.Heartbeat:Connect(function(dt)
        if not _G.NeverloseUILoaded then return end
        if not SpeedSystem.Enabled then return end

        local char, hrp, hum = speedGetChar()
        if not char or not hrp or not hum or hum.Health <= 0 then return end

        local mode = SpeedSystem.Mode

        -- REGULAR — просто WalkSpeed
        if mode == "Regular" then
            local target = speedGetTarget()
            if hum.WalkSpeed ~= target then
                pcall(function() hum.WalkSpeed = target end)
            end
            return
        end

        -- MATRIX / HYBRID
        local extraSpeed = 0
        if mode == "Matrix" then
            if hum.WalkSpeed ~= 0 then
                pcall(function() hum.WalkSpeed = 0 end)
            end
            extraSpeed = speedGetTarget()
        elseif mode == "Hybrid" then
            if hum.WalkSpeed ~= SpeedSystem.HybridWalk then
                pcall(function() hum.WalkSpeed = SpeedSystem.HybridWalk end)
            end
            extraSpeed = math.max(0, speedGetTarget() - SpeedSystem.HybridWalk)
        end

        if SpeedSystem.GroundOnly then
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Freefall
                or st == Enum.HumanoidStateType.Jumping
                or st == Enum.HumanoidStateType.Flying then
                return
            end
        end

        local dir = hum.MoveDirection
        if dir.Magnitude < 0.01 then return end
        local dirWorld = Vector3.new(dir.X, 0, dir.Z)
        if dirWorld.Magnitude < 0.01 then return end
        dirWorld = dirWorld.Unit

        local stepDist = extraSpeed * dt
        if stepDist <= 0 then return end
        if stepDist > SpeedSystem.StepSize then
            stepDist = SpeedSystem.StepSize
        end

        if speedWallBlocked(char, hrp, dirWorld, stepDist) then
            return
        end

        local oldCF = hrp.CFrame
        local newPos = oldCF.Position + dirWorld * stepDist

        local newCF
        if SpeedSystem.Smooth then
            newCF = CFrame.new(newPos) * (oldCF - oldCF.Position)
        else
            newCF = CFrame.new(newPos, newPos + oldCF.LookVector)
        end

        pcall(function()
            hrp.CFrame = newCF
        end)
    end)
end

function speedStop()
    if speedMainConn then
        speedMainConn:Disconnect()
        speedMainConn = nil
    end
    local _, _, hum = speedGetChar()
    if hum then
        pcall(function() hum.WalkSpeed = 16 end)
    end
end

function enableSpeed()  SpeedSystem.Enabled = true  speedStart() end
function disableSpeed() SpeedSystem.Enabled = false speedStop()  end

function applySpeed()
    if Cheat and Cheat.Speed then
        enableSpeed()
    else
        disableSpeed()
    end
end

speedConn = nil  -- заглушка

--=========================================================
-- NOCLIP
--=========================================================
noclipConn = nil

function disableNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    local char = LP.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() p.CanCollide = true end)
            end
        end
    end
end

function enableNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        if not _G.NeverloseUILoaded then return end
        if not Cheat.Noclip then return end
        local char = LP.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                pcall(function() p.CanCollide = false end)
            end
        end
    end)
end

--=========================================================
-- BUNNY HOP
--=========================================================
bhopConn = nil

function disableBunnyHop()
    if bhopConn then bhopConn:Disconnect() bhopConn = nil end
end

function enableBunnyHop()
    if bhopConn then bhopConn:Disconnect() end
    bhopConn = RunService.Heartbeat:Connect(function()
        if not _G.NeverloseUILoaded then return end
        if not Cheat.BunnyHop then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Landed
                or st == Enum.HumanoidStateType.Running
                or st == Enum.HumanoidStateType.RunningNoPhysics
                or st == Enum.HumanoidStateType.Idle then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

--=========================================================
-- SPIN BOT
--=========================================================
spinConn = nil

function disableSpinBot()
    if spinConn then spinConn:Disconnect() spinConn = nil end
end

function enableSpinBot()
    if spinConn then spinConn:Disconnect() end
    spinConn = RunService.Heartbeat:Connect(function(dt)
        if not _G.NeverloseUILoaded then return end
        if not Cheat.SpinBot then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local pos = hrp.CFrame.Position
        local cy = math.atan2(-hrp.CFrame.LookVector.X, -hrp.CFrame.LookVector.Z)
        local ny = cy + math.rad(Cheat.SpinSpeed * 18) * dt
        pcall(function()
            hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, ny, 0)
        end)
    end)
end

--=========================================================
-- SPIDER (стены)
--=========================================================
spiderConn, spiderBV = nil, nil

function disableSpider()
    if spiderConn then spiderConn:Disconnect() spiderConn = nil end
    if spiderBV and spiderBV.Parent then spiderBV:Destroy() end
    spiderBV = nil
end

function enableSpider()
    if spiderConn then spiderConn:Disconnect() end
    spiderConn = RunService.Heartbeat:Connect(function()
        if not _G.NeverloseUILoaded then return end
        if not Cheat.Spider then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local touching = false
        for i = 0, 7 do
            local angle = math.rad(i * 45)
            local d = Vector3.new(math.sin(angle), 0, math.cos(angle))
            local ray = RaycastParams.new()
            ray.FilterType = Enum.RaycastFilterType.Exclude
            ray.FilterDescendantsInstances = {char}
            if workspace:Raycast(hrp.Position, d * 3, ray) then
                touching = true
                break
            end
        end

        if touching then
            if not spiderBV or not spiderBV.Parent then
                spiderBV = Instance.new("BodyVelocity")
                spiderBV.Name = "NL_SpiderBV"
                spiderBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                spiderBV.Velocity = Vector3.zero
                spiderBV.Parent = hrp
            end
            local climb = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then climb = climb + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.S) then climb = climb + Vector3.new(0, -1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.A) then climb = climb - hrp.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then climb = climb + hrp.CFrame.RightVector end
            if climb.Magnitude > 0 then climb = climb.Unit * Cheat.SpiderSpeed end
            spiderBV.Velocity = climb
        else
            if spiderBV and spiderBV.Parent then
                spiderBV:Destroy()
                spiderBV = nil
            end
        end
    end)
end

--=========================================================
-- INFINITE JUMP
--=========================================================
ijConn = nil

function disableInfJump()
    if ijConn then ijConn:Disconnect() ijConn = nil end
end

function enableInfJump()
    if ijConn then ijConn:Disconnect() end
    ijConn = UIS.JumpRequest:Connect(function()
        if not _G.NeverloseUILoaded then return end
        if not Cheat.InfJump then return end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

--=========================================================
-- FULLBRIGHT
--=========================================================
fbSaved = nil

function disableFullBright()
    if fbSaved then
        pcall(function()
            Lighting.Ambient = fbSaved.Ambient
            Lighting.OutdoorAmbient = fbSaved.OutdoorAmbient
            Lighting.Brightness = fbSaved.Brightness
            Lighting.GlobalShadows = fbSaved.GlobalShadows
        end)
        fbSaved = nil
    end
end

function enableFullBright()
    if not fbSaved then
        fbSaved = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            GlobalShadows = Lighting.GlobalShadows,
        }
    end
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    end)
end

--=========================================================
-- BLACK SKY
--=========================================================
bsky, bsSaved = nil, nil

function disableBlackSky()
    if bsky and bsky.Parent then bsky:Destroy() end
    bsky = nil
    if bsSaved then
        pcall(function()
            Lighting.Ambient = bsSaved.Ambient
            Lighting.OutdoorAmbient = bsSaved.OutdoorAmbient
            Lighting.Brightness = bsSaved.Brightness
            Lighting.ClockTime = bsSaved.ClockTime
            Lighting.FogColor = bsSaved.FogColor
            Lighting.FogEnd = bsSaved.FogEnd
            Lighting.FogStart = bsSaved.FogStart
            Lighting.GlobalShadows = bsSaved.GlobalShadows
        end)
        bsSaved = nil
    end
end

function enableBlackSky()
    if not bsSaved then
        bsSaved = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogColor = Lighting.FogColor,
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            GlobalShadows = Lighting.GlobalShadows,
        }
    end
    pcall(function()
        Lighting.ClockTime = 0
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = 0
        Lighting.FogColor = Color3.fromRGB(0, 0, 0)
        Lighting.FogStart = 0
        Lighting.FogEnd = 500
        Lighting.GlobalShadows = true

        if bsky and bsky.Parent then bsky:Destroy() end
        bsky = Instance.new("Sky")
        bsky.SkyboxBk = "rbxassetid://159454299"
        bsky.SkyboxDn = "rbxassetid://159454296"
        bsky.SkyboxFt = "rbxassetid://159454293"
        bsky.SkyboxLf = "rbxassetid://159454286"
        bsky.SkyboxRt = "rbxassetid://159454300"
        bsky.SkyboxUp = "rbxassetid://159454288"
        bsky.StarCount = 0
        bsky.SunAngularSize = 0
        bsky.MoonAngularSize = 0
        bsky.Parent = Lighting
    end)
end

--=========================================================
-- WORLD COLOR
--=========================================================
wcSaved = nil

function restoreWorldColor()
    if wcSaved then
        pcall(function()
            Lighting.Ambient = wcSaved.Ambient
            Lighting.OutdoorAmbient = wcSaved.OutdoorAmbient
            Lighting.FogColor = wcSaved.FogColor
            Lighting.FogEnd = wcSaved.FogEnd
            Lighting.FogStart = wcSaved.FogStart
            Lighting.ColorShift_Top = wcSaved.ColorShift_Top
            Lighting.ColorShift_Bottom = wcSaved.ColorShift_Bottom
        end)
    end
end

function applyWorldColor()
    if not wcSaved then
        wcSaved = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            FogColor = Lighting.FogColor,
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            ColorShift_Top = Lighting.ColorShift_Top,
            ColorShift_Bottom = Lighting.ColorShift_Bottom,
        }
    end
    local c = Cheat.WorldColor
    pcall(function()
        Lighting.FogColor = c
        Lighting.FogStart = 0
        Lighting.FogEnd = 1000
        Lighting.Ambient = c
        Lighting.OutdoorAmbient = c
        Lighting.ColorShift_Top = c
        Lighting.ColorShift_Bottom = c
    end)
end

--=========================================================
-- FOG
--=========================================================
fogSaved = nil

function disableFog()
    if fogSaved then
        pcall(function()
            Lighting.FogColor = fogSaved.FogColor
            Lighting.FogStart = fogSaved.FogStart
            Lighting.FogEnd = fogSaved.FogEnd
        end)
    end
end

function enableFog()
    if not fogSaved then
        fogSaved = {
            FogColor = Lighting.FogColor,
            FogStart = Lighting.FogStart,
            FogEnd = Lighting.FogEnd,
        }
    end
    pcall(function()
        Lighting.FogColor = Cheat.FogColor
        Lighting.FogStart = 0
        Lighting.FogEnd = Cheat.FogDistance
    end)
end

--=========================================================
-- SNOW
--=========================================================
sFolder, sPart, sFollow = nil, nil, nil

function disableSnow()
    if sFollow then sFollow:Disconnect() sFollow = nil end
    if sPart and sPart.Parent then sPart:Destroy() end
    if sFolder and sFolder.Parent then sFolder:Destroy() end
    sPart, sFolder = nil, nil
end

function enableSnow()
    disableSnow()

    sFolder = Instance.new("Folder")
    sFolder.Name = "S" .. math.random(10000, 99999)
    sFolder.Parent = workspace

    sPart = Instance.new("Part")
    sPart.Size = Vector3.new(200, 1, 200)
    sPart.Anchored = true
    sPart.CanCollide = false
    sPart.CanQuery = false
    sPart.CanTouch = false
    sPart.Transparency = 1
    sPart.Parent = sFolder

    local emit = Instance.new("ParticleEmitter")
    emit.Texture = "rbxassetid://131612974"
    emit.Lifetime = NumberRange.new(3, 6)
    emit.Rate = 300
    emit.Speed = NumberRange.new(3, 7)
    emit.SpreadAngle = Vector2.new(25, 25)
    emit.Rotation = NumberRange.new(0, 360)
    emit.RotSpeed = NumberRange.new(-60, 60)
    emit.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 0.2),
    })
    emit.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.85, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    emit.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 230, 255)),
    })
    emit.LightEmission = 0.6
    emit.LightInfluence = 0
    emit.Acceleration = Vector3.new(0, -12, 0)
    emit.ZOffset = 2
    emit.EmissionDirection = Enum.NormalId.Bottom
    emit.Parent = sPart

    sFollow = RunService.Heartbeat:Connect(function()
        if not _G.NeverloseUILoaded then return end
        if not Cheat.Snow or not sPart then return end
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            sPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 45, 0))
        elseif Cam then
            sPart.CFrame = CFrame.new(Cam.CFrame.Position + Vector3.new(0, 45, 0))
        end
    end)
end

--=========================================================
-- AUTO CLICKER
--=========================================================
acRunning = false

function xenoClick(button)
    button = button or 0
    if button == 1 then
        if type(mouse2click) == "function" then pcall(mouse2click) return end
        if type(mouse2press) == "function" and type(mouse2release) == "function" then
            pcall(mouse2press) task.wait(0.01) pcall(mouse2release) return
        end
    else
        if type(mouse1click) == "function" then pcall(mouse1click) return end
        if type(mouse1press) == "function" and type(mouse1release) == "function" then
            pcall(mouse1press) task.wait(0.01) pcall(mouse1release) return
        end
    end
    pcall(function()
        VIM:SendMouseButtonEvent(0, 0, button, true, game, 1)
        task.wait(0.01)
        VIM:SendMouseButtonEvent(0, 0, button, false, game, 1)
    end)
end

function startAutoClicker()
    if acRunning then return end
    acRunning = true
    task.spawn(function()
        while _G.NeverloseUILoaded and Cheat.AutoClicker do
            local cps = math.max(1, tonumber(Cheat.AutoClickCPS) or 10)
            local d = 1 / cps
            if Cheat.AutoClickRandom then
                d = d * (0.7 + math.random() * 0.6)
            end
            d = d + (tonumber(Cheat.AutoClickDelay) or 0) / 1000
            xenoClick(Cheat.AutoClickButton == 1 and 1 or 0)
            task.wait(d)
        end
        acRunning = false
    end)
end

--=========================================================
-- ESP 2D
--=========================================================
espFolder = Instance.new("Folder")
espFolder.Name = "NL_ESP_" .. math.random(10000, 99999)
espFolder.Parent = ScreenGui
espObjects = {}

function createESP(plr)
    if not plr or plr == LP then return end
    if espObjects[plr] then return end

    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.ZIndex = 10
    box.Parent = espFolder

    local s = Instance.new("UIStroke")
    s.Color = Cheat.ESPColor
    s.Thickness = 1.5
    s.Parent = box

    local n = Instance.new("TextLabel")
    n.BackgroundTransparency = 1
    n.Text = plr.Name
    n.TextColor3 = NL_WHITE
    n.Font = Enum.Font.GothamBold
    n.TextSize = 12
    n.TextStrokeTransparency = 0
    n.ZIndex = 11
    n.Parent = box

    local h = Instance.new("Frame")
    h.BackgroundColor3 = NL_GREEN
    h.BorderSizePixel = 0
    h.ZIndex = 11
    h.Parent = box

    espObjects[plr] = {box = box, stroke = s, name = n, health = h}
end

function removeESP(plr)
    if espObjects[plr] then
        if espObjects[plr].box and espObjects[plr].box.Parent then
            espObjects[plr].box:Destroy()
        end
        espObjects[plr] = nil
    end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
for _, plr in ipairs(Players:GetPlayers()) do createESP(plr) end

RunService.RenderStepped:Connect(function()
    if not _G.NeverloseUILoaded then return end
    if not Cheat.ESP then
        for _, d in pairs(espObjects) do
            if d.box.Visible then d.box.Visible = false end
        end
        return
    end

    for plr, d in pairs(espObjects) do
        if not plr or not plr.Parent then
            d.box.Visible = false
        else
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                local head = char:FindFirstChild("Head")
                local tp = head and (head.Position + Vector3.new(0, 1, 0))
                            or (hrp.Position + Vector3.new(0, 3, 0))
                local bp = hrp.Position - Vector3.new(0, 3, 0)

                local t, ton1 = Cam:WorldToViewportPoint(tp)
                local bo, ton2 = Cam:WorldToViewportPoint(bp)

                if ton1 and ton2 and t.Z > 0 and bo.Z > 0 then
                    local height = math.abs(t.Y - bo.Y)
                    local width = height * 0.55
                    d.box.Visible = true
                    d.box.Size = UDim2.new(0, width, 0, height)
                    d.box.Position = UDim2.new(0, t.X - width / 2, 0, t.Y)
                    d.name.Size = UDim2.new(1, 0, 0, 14)
                    d.name.Position = UDim2.new(0, 0, 0, -18)

                    local hp = hum.Health / math.max(hum.MaxHealth, 1)
                    d.health.Size = UDim2.new(0, 3, hp, 0)
                    d.health.Position = UDim2.new(-1, -5, 1, 0)
                    d.health.AnchorPoint = Vector2.new(0, 1)
                    d.stroke.Color = Cheat.ESPColor

                    if hp > 0.5 then d.health.BackgroundColor3 = NL_GREEN
                    elseif hp > 0.25 then d.health.BackgroundColor3 = NL_YELLOW
                    else d.health.BackgroundColor3 = NL_RED end
                else
                    d.box.Visible = false
                end
            else
                d.box.Visible = false
            end
        end
    end
end)

--=========================================================
-- CONE HAT
--=========================================================
hatModel, hatWeld = nil, nil

function removeHat()
    if hatModel and hatModel.Parent then hatModel:Destroy() end
    if hatWeld and hatWeld.Parent then hatWeld:Destroy() end
    hatModel, hatWeld = nil, nil
end

function createHat()
    removeHat()
    local char = LP.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    hatModel = Instance.new("Model")
    hatModel.Name = "NL_Hat"

    local cone = Instance.new("Part")
    cone.Size = Vector3.new(3.5, 7, 3.5)
    cone.Color = Color3.fromRGB(0, 160, 255)
    cone.Material = Enum.Material.Neon
    cone.Transparency = 0.55
    cone.CanCollide = false
    cone.Massless = true
    cone.Parent = hatModel

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Parent = cone

    local brim = Instance.new("Part")
    brim.Shape = Enum.PartType.Cylinder
    brim.Size = Vector3.new(0.3, 4.2, 4.2)
    brim.Color = Color3.fromRGB(0, 200, 255)
    brim.Material = Enum.Material.Neon
    brim.Transparency = 0.45
    brim.CanCollide = false
    brim.Massless = true
    brim.Parent = hatModel

    hatWeld = Instance.new("Motor6D")
    hatWeld.Part0 = head
    hatWeld.Part1 = cone
    hatWeld.C0 = CFrame.new(0, head.Size.Y / 2 + 3.5, 0)
    hatWeld.C1 = CFrame.new(0, 0, 0)
    hatWeld.Parent = head

    task.wait()
    if brim.Parent and cone.Parent then
        brim.CFrame = cone.CFrame * CFrame.new(0, -3.5, 0) * CFrame.Angles(0, 0, math.rad(90))
        local bw = Instance.new("WeldConstraint")
        bw.Part0 = cone
        bw.Part1 = brim
        bw.Parent = brim
    end

    hatModel.Parent = char
end

_G.NL_CreateHat = createHat
_G.NL_RemoveHat = removeHat

--=========================================================
-- RESPAWN
--=========================================================
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if not _G.NeverloseUILoaded then return end
    if Cheat.Speed then applySpeed() end
    if Cheat.Noclip then enableNoclip() end
    if Cheat.Fly then enableFly() end
    if Cheat.BunnyHop then enableBunnyHop() end
    if Cheat.SpinBot then enableSpinBot() end
    if Cheat.Spider then enableSpider() end
    if Cheat.Jump then applyJump() end
    if Cheat.Hat and _G.NL_CreateHat then _G.NL_CreateHat() end
    if Cheat.AntiFling and enableAntiFling then enableAntiFling() end
    if Cheat.AntiKnockback and enableAntiKnockback then enableAntiKnockback() end
    if Cheat.AntiRagdoll and enableAntiRagdoll then enableAntiRagdoll() end
end)

print("[NL] 2/13 — Fly / Speed System / Misc core загружены")
--=========================================================
-- NEVERLOSE UI — 3/13 (FIX v3)
-- Вкладки: Visuals / Misc / Settings
-- Speed System UI (Regular / Matrix / Hybrid)
-- ФИКСЫ:
--   • Все контролы через билдеры из части 1
--   • unloadScript определён один раз (не пересобирается)
--   • Правильная привязка кнопки Unload
--   • Insert-toggle не конфликтует с биндами
--   • Resize handle не мешает скроллу контента
--=========================================================

if not _G.NeverloseUILoaded then
    warn("[NL] Часть 3: база не загружена")
    return
end

--=========================================================
-- VISUALS
--=========================================================
visualsContent = makeTabContent("Visuals")
visLeft  = createColumn(visualsContent, "left")
visRight = createColumn(visualsContent, "right")

--========== PLAYERS ==========
visPlayersSec = createSection(visLeft, "Players")

createCheckbox(visPlayersSec, "ESP 2D", false, function(s)
    Cheat.ESP = s
end, "ESP")

createSlider(visPlayersSec, "ESP Color R", 0, 255, 0, function(v)
    Cheat.ESPColor = Color3.fromRGB(
        v,
        math.floor(Cheat.ESPColor.G * 255),
        math.floor(Cheat.ESPColor.B * 255)
    )
end, true, "R")

createSlider(visPlayersSec, "ESP Color G", 0, 255, 140, function(v)
    Cheat.ESPColor = Color3.fromRGB(
        math.floor(Cheat.ESPColor.R * 255),
        v,
        math.floor(Cheat.ESPColor.B * 255)
    )
end, true, "G")

createSlider(visPlayersSec, "ESP Color B", 0, 255, 255, function(v)
    Cheat.ESPColor = Color3.fromRGB(
        math.floor(Cheat.ESPColor.R * 255),
        math.floor(Cheat.ESPColor.G * 255),
        v
    )
end, true, "B")

--========== WORLD ==========
visWorldSec = createSection(visRight, "World")

createCheckbox(visWorldSec, "FullBright", false, function(s)
    Cheat.FullBright = s
    if s then enableFullBright() else disableFullBright() end
end, "FullBright")

createCheckbox(visWorldSec, "Black Sky", false, function(s)
    Cheat.BlackSky = s
    if s then enableBlackSky() else disableBlackSky() end
end, "BlackSky")

createCheckbox(visWorldSec, "Snow", false, function(s)
    Cheat.Snow = s
    if s then enableSnow() else disableSnow() end
end, "Snow")

--========== WORLD COLOR ==========
visWCSec = createSection(visRight, "World Color")

createCheckbox(visWCSec, "Enable", false, function(s)
    Cheat.WorldColorEnabled = s
    if s then applyWorldColor() else restoreWorldColor() end
end, "WorldColor")

createSlider(visWCSec, "R", 0, 255, 0, function(v)
    Cheat.WorldColor = Color3.fromRGB(
        v,
        math.floor(Cheat.WorldColor.G * 255),
        math.floor(Cheat.WorldColor.B * 255)
    )
    if Cheat.WorldColorEnabled then applyWorldColor() end
end, true, "R")

createSlider(visWCSec, "G", 0, 255, 140, function(v)
    Cheat.WorldColor = Color3.fromRGB(
        math.floor(Cheat.WorldColor.R * 255),
        v,
        math.floor(Cheat.WorldColor.B * 255)
    )
    if Cheat.WorldColorEnabled then applyWorldColor() end
end, true, "G")

createSlider(visWCSec, "B", 0, 255, 255, function(v)
    Cheat.WorldColor = Color3.fromRGB(
        math.floor(Cheat.WorldColor.R * 255),
        math.floor(Cheat.WorldColor.G * 255),
        v
    )
    if Cheat.WorldColorEnabled then applyWorldColor() end
end, true, "B")

--========== FOG ==========
fogSec = createSection(visRight, "Fog")

createCheckbox(fogSec, "Enable Fog", false, function(s)
    Cheat.Fog = s
    if s then enableFog() else disableFog() end
end, "Fog")

createSlider(fogSec, "Fog R", 0, 255, 200, function(v)
    Cheat.FogColor = Color3.fromRGB(
        v,
        math.floor(Cheat.FogColor.G * 255),
        math.floor(Cheat.FogColor.B * 255)
    )
    if Cheat.Fog then enableFog() end
end, true, "R")

createSlider(fogSec, "Fog G", 0, 255, 200, function(v)
    Cheat.FogColor = Color3.fromRGB(
        math.floor(Cheat.FogColor.R * 255),
        v,
        math.floor(Cheat.FogColor.B * 255)
    )
    if Cheat.Fog then enableFog() end
end, true, "G")

createSlider(fogSec, "Fog B", 0, 255, 200, function(v)
    Cheat.FogColor = Color3.fromRGB(
        math.floor(Cheat.FogColor.R * 255),
        math.floor(Cheat.FogColor.G * 255),
        v
    )
    if Cheat.Fog then enableFog() end
end, true, "B")

createSlider(fogSec, "Distance", 10, 500, 100, function(v)
    Cheat.FogDistance = v
    if Cheat.Fog then enableFog() end
end)

--=========================================================
-- MISC
--=========================================================
miscContent = makeTabContent("Misc")
miscLeft  = createColumn(miscContent, "left")
miscRight = createColumn(miscContent, "right")

--========== MOVEMENT ==========
moveSec = createSection(miscLeft, "Movement")

createCheckbox(moveSec, "Fly", false, function(s)
    Cheat.Fly = s
    if s then enableFly() else disableFly() end
end, "Fly")

createSlider(moveSec, "Fly Speed", 10, 300, 50, function(v)
    Cheat.FlySpeed = v
end)

createCheckbox(moveSec, "Speed", false, function(s)
    Cheat.Speed = s
    if s then enableSpeed() else disableSpeed() end
end, "Speed")

createCycle(moveSec, "Speed Mode", {"Matrix", "Regular", "Hybrid"}, "Matrix", function(v)
    SpeedSystem.Mode = v
    if SpeedSystem.Enabled then
        speedStop()
        speedStart()
    end
    if _G.NL_NotifyInfo then
        _G.NL_NotifyInfo("Speed Mode: " .. v)
    end
end)

createSlider(moveSec, "Speed Value", 10, 300, 60, function(v)
    SpeedSystem.Value = v
end)

createSlider(moveSec, "Sprint Mult x10", 10, 50, 15, function(v)
    SpeedSystem.SprintMult = v / 10
end)

createSlider(moveSec, "Step Size x10", 10, 150, 35, function(v)
    SpeedSystem.StepSize = v / 10
end)

createCheckbox(moveSec, "Ground Only", true, function(s)
    SpeedSystem.GroundOnly = s
end, "Speed_Ground")

createCheckbox(moveSec, "Wall Check", true, function(s)
    SpeedSystem.WallCheck = s
end, "Speed_Wall")

createCheckbox(moveSec, "Smooth Move", true, function(s)
    SpeedSystem.Smooth = s
end, "Speed_Smooth")

createCheckbox(moveSec, "Noclip", false, function(s)
    Cheat.Noclip = s
    if s then enableNoclip() else disableNoclip() end
end, "Noclip")

createCheckbox(moveSec, "BunnyHop", false, function(s)
    Cheat.BunnyHop = s
    if s then enableBunnyHop() else disableBunnyHop() end
end, "BunnyHop")

createCheckbox(moveSec, "Spin Bot", false, function(s)
    Cheat.SpinBot = s
    if s then enableSpinBot() else disableSpinBot() end
end, "SpinBot")

createSlider(moveSec, "Spin Speed", 5, 100, 20, function(v)
    Cheat.SpinSpeed = v
end)

createCheckbox(moveSec, "Spider (Wall Climb)", false, function(s)
    Cheat.Spider = s
    if s then enableSpider() else disableSpider() end
end, "Spider")

createSlider(moveSec, "Spider Speed", 10, 200, 40, function(v)
    Cheat.SpiderSpeed = v
end)

--========== JUMP ==========
jumpSec = createSection(miscLeft, "Jump")

createCheckbox(jumpSec, "Enable Jump Boost", false, function(s)
    Cheat.Jump = s
    applyJump()
end, "Jump")

createCycle(jumpSec, "Mode", {"Power", "Height"}, "Power", function(v)
    Cheat.JumpMode = v
    if Cheat.Jump then applyJump() end
end)

createSlider(jumpSec, "JumpPower (Power mode)", 50, 500, 50, function(v)
    Cheat.JumpPower = v
    if Cheat.Jump and Cheat.JumpMode == "Power" then applyJump() end
end)

createSlider(jumpSec, "JumpHeight x10 (Height mode)", 50, 500, 72, function(v)
    Cheat.JumpHeight = v / 10
    if Cheat.Jump and Cheat.JumpMode == "Height" then applyJump() end
end)

local jumpInfo = Instance.new("TextLabel")
jumpInfo.Size = UDim2.new(1, 0, 0, 50)
jumpInfo.BackgroundTransparency = 1
jumpInfo.Text = "Power = обычный высокий прыжок\nHeight = студиовская высота\nЗначение держится, даже если игра сбрасывает."
jumpInfo.TextColor3 = NL_DIM
jumpInfo.Font = Enum.Font.Gotham
jumpInfo.TextSize = 11
jumpInfo.TextWrapped = true
jumpInfo.TextYAlignment = Enum.TextYAlignment.Top
jumpInfo.TextXAlignment = Enum.TextXAlignment.Left
jumpInfo.ZIndex = 55
jumpInfo.Parent = jumpSec

--========== AUTO CLICKER ==========
acSec = createSection(miscLeft, "Auto Clicker")

createCheckbox(acSec, "Enable", false, function(s)
    Cheat.AutoClicker = s
    if s then startAutoClicker() end
end, "AutoClicker")

createSlider(acSec, "CPS", 1, 30, 10, function(v)
    Cheat.AutoClickCPS = v
end)

createSlider(acSec, "Extra Delay (ms)", 0, 500, 0, function(v)
    Cheat.AutoClickDelay = v
end)

createCheckbox(acSec, "Randomize Speed", false, function(s)
    Cheat.AutoClickRandom = s
end, "AutoClickRandom")

createCycle(acSec, "Mouse Button", {"Left", "Right"}, "Left", function(v)
    Cheat.AutoClickButton = (v == "Left") and 0 or 1
end)

--========== OTHER ==========
otherSec = createSection(miscRight, "Other")

createCheckbox(otherSec, "Infinite Jump", false, function(s)
    Cheat.InfJump = s
    if s then enableInfJump() else disableInfJump() end
end, "InfJump")

createCheckbox(otherSec, "Cone Hat", false, function(s)
    Cheat.Hat = s
    if s then
        if _G.NL_CreateHat then _G.NL_CreateHat() end
    else
        if _G.NL_RemoveHat then _G.NL_RemoveHat() end
    end
end, "Hat")

--========== PROTECTION ==========
protSec = createSection(miscRight, "Protection")

createCheckbox(protSec, "Anti-Fling", false, function(s)
    Cheat.AntiFling = s
    if s then
        if enableAntiFling then enableAntiFling() end
    else
        if disableAntiFling then disableAntiFling() end
    end
end, "AntiFling")

createCheckbox(protSec, "Anti-Knockback", false, function(s)
    Cheat.AntiKnockback = s
    if s then
        if enableAntiKnockback then enableAntiKnockback() end
    else
        if disableAntiKnockback then disableAntiKnockback() end
    end
end, "AntiKnockback")

createCheckbox(protSec, "Anti-Ragdoll", false, function(s)
    Cheat.AntiRagdoll = s
    if s then
        if enableAntiRagdoll then enableAntiRagdoll() end
    else
        if disableAntiRagdoll then disableAntiRagdoll() end
    end
end, "AntiRagdoll")

--=========================================================
-- SETTINGS
--=========================================================
settingsContent = makeTabContent("Settings")

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, -40, 0, 30)
settingsTitle.Position = UDim2.new(0, 20, 0, 15)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "Настройки скрипта"
settingsTitle.TextColor3 = NL_TEXT
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 16
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.ZIndex = 53
settingsTitle.Parent = settingsContent

local settingsInfo = Instance.new("TextLabel")
settingsInfo.Size = UDim2.new(1, -40, 0, 80)
settingsInfo.Position = UDim2.new(0, 20, 0, 50)
settingsInfo.BackgroundTransparency = 1
settingsInfo.Text = "INSERT — открыть/закрыть меню\nВыгрузка скрипта удалит все объекты и вернёт настройки Lighting."
settingsInfo.TextColor3 = NL_DIM
settingsInfo.Font = Enum.Font.Gotham
settingsInfo.TextSize = 11
settingsInfo.TextWrapped = true
settingsInfo.TextYAlignment = Enum.TextYAlignment.Top
settingsInfo.TextXAlignment = Enum.TextXAlignment.Left
settingsInfo.ZIndex = 53
settingsInfo.Parent = settingsContent

unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(0, 260, 0, 44)
unloadBtn.Position = UDim2.new(0.5, -130, 0, 150)
unloadBtn.BackgroundColor3 = NL_DARKER
unloadBtn.BorderSizePixel = 0
unloadBtn.Text = "Unload Script"
unloadBtn.TextColor3 = NL_TEXT
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.TextSize = 14
unloadBtn.ZIndex = 55
unloadBtn.Parent = settingsContent

local ubc = Instance.new("UICorner")
ubc.CornerRadius = UDim.new(0, 6)
ubc.Parent = unloadBtn

local ubs = Instance.new("UIStroke")
ubs.Color = NL_BLUE
ubs.Thickness = 1
ubs.Transparency = 0.5
ubs.Parent = unloadBtn
registerAccent(ubs, "Color")

unloadBtn.MouseEnter:Connect(function()
    tween(unloadBtn, 0.15, {BackgroundColor3 = NL_RED})
    tween(ubs, 0.15, {Color = NL_RED, Transparency = 0})
end)
unloadBtn.MouseLeave:Connect(function()
    tween(unloadBtn, 0.15, {BackgroundColor3 = NL_DARKER})
    tween(ubs, 0.15, {Color = NL_BLUE, Transparency = 0.5})
end)

--=========================================================
-- БАЗОВЫЙ unloadScript (части 7–13 будут его оборачивать)
--=========================================================
function unloadScript()
    _G.NeverloseUILoaded = nil

    -- Safe-disable всех подсистем (проверяем существование)
    if disableFly         then pcall(disableFly) end
    if disableNoclip      then pcall(disableNoclip) end
    if disableInfJump     then pcall(disableInfJump) end
    if disableFullBright  then pcall(disableFullBright) end
    if disableBlackSky    then pcall(disableBlackSky) end
    if disableSnow        then pcall(disableSnow) end
    if disableBunnyHop    then pcall(disableBunnyHop) end
    if disableSpinBot     then pcall(disableSpinBot) end
    if disableFog         then pcall(disableFog) end
    if disableSpider      then pcall(disableSpider) end
    if restoreWorldColor  then pcall(restoreWorldColor) end
    if disableSpeed       then pcall(disableSpeed) end
    if _G.NL_RemoveHat    then pcall(_G.NL_RemoveHat) end

    if _G.NL_UnloadTP      then pcall(_G.NL_UnloadTP) end
    if _G.NL_UnloadCTP     then pcall(_G.NL_UnloadCTP) end
    if _G.NL_UnloadBT      then pcall(_G.NL_UnloadBT) end
    if _G.NL_UnloadFling   then pcall(_G.NL_UnloadFling) end
    if _G.NL_UnloadProtect then pcall(_G.NL_UnloadProtect) end
    if _G.NL_UnloadHUD     then pcall(_G.NL_UnloadHUD) end
    if _G.NL_UnloadDoors   then pcall(_G.NL_UnloadDoors) end

    Cheat.ESP = false
    Cheat.AutoClicker = false
    Cheat.Jump = false
    Cheat.Speed = false

    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.UseJumpPower = true
            hum.JumpPower = 50
        end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() p.CanCollide = true end)
            end
        end
    end

    -- Возвращаем топбар
    pcall(function()
        local sg = game:GetService("StarterGui")
        sg:SetCore("TopbarEnabled", true)
    end)

    if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
end

_G.NL_UnloadBase = unloadScript

unloadBtn.MouseButton1Click:Connect(function()
    unloadScript()
end)

--=========================================================
-- RESIZE HANDLE
--=========================================================
resizeButton = Instance.new("TextButton")
resizeButton.Size = UDim2.new(0, 26, 0, 26)
resizeButton.Position = UDim2.new(1, -26, 1, -26)
resizeButton.BackgroundTransparency = 1
resizeButton.Text = ""
resizeButton.AutoButtonColor = false
resizeButton.ZIndex = 300
resizeButton.Parent = MainFrame

resizeHandle = Instance.new("Frame")
resizeHandle.Size = UDim2.new(0, 16, 0, 16)
resizeHandle.Position = UDim2.new(1, -20, 1, -20)
resizeHandle.BackgroundColor3 = NL_BLUE
resizeHandle.BackgroundTransparency = 0.6
resizeHandle.BorderSizePixel = 0
resizeHandle.ZIndex = 70
resizeHandle.Parent = MainFrame
registerAccent(resizeHandle, "BackgroundColor3")

local rhc = Instance.new("UICorner")
rhc.CornerRadius = UDim.new(0, 3)
rhc.Parent = resizeHandle

isResizing = false
resizeStartSize = nil
resizeStartPos = nil

resizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = true
        resizeStartSize = {x = MainFrame.AbsoluteSize.X, y = MainFrame.AbsoluteSize.Y}
        resizeStartPos = {x = input.Position.X, y = input.Position.Y}
        tween(resizeHandle, 0.1, {BackgroundTransparency = 0.2})
    end
end)

UIS.InputChanged:Connect(function(input)
    if not isResizing then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if not MainFrame or not MainFrame.Parent then isResizing = false return end

    local dx = input.Position.X - resizeStartPos.x
    local dy = input.Position.Y - resizeStartPos.y
    MainFrame.Size = UDim2.new(
        0, math.max(520, resizeStartSize.x + dx),
        0, math.max(400, resizeStartSize.y + dy)
    )
end)

UIS.InputEnded:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) and isResizing then
        isResizing = false
        tween(resizeHandle, 0.15, {BackgroundTransparency = 0.6})
    end
end)

--=========================================================
-- KEYBIND LISTENER
--=========================================================
UIS.InputBegan:Connect(function(input, gp)
    if listeningForBind then
        if input.KeyCode == Enum.KeyCode.Escape then
            stopListening()
            return
        end
        local bindBtn = listeningForBind.btn
        local action = listeningForBind.action
        Keybinds[action] = input.KeyCode
        if bindBtn and bindBtn.Parent then
            bindBtn.Text = "[" .. keyName(input.KeyCode) .. "]"
            tween(bindBtn, 0.15, {TextColor3 = NL_GREEN})
        end
        stopListening()
        return
    end
    if gp then return end
    if not _G.NeverloseUILoaded then return end
    for action, key in pairs(Keybinds) do
        if input.KeyCode == key and BindCallbacks[action] then
            pcall(BindCallbacks[action])
        end
    end
end)

--=========================================================
-- DEFAULT TAB (Settings)
--=========================================================
if tabs["Settings"] and tabs["Settings"].btn then
    tabs["Settings"].btn.BackgroundTransparency = 0.85
    tabs["Settings"].btn.BackgroundColor3 = NL_BLUE
    tabs["Settings"].btn.TextColor3 = NL_TEXT
    if tabs["Settings"].ind then tabs["Settings"].ind.Visible = true end
    activeTab = "Settings"
    contentFrame = settingsContent
    settingsContent.Visible = true
end

--=========================================================
-- INSERT TOGGLE (открыть/закрыть меню)
--=========================================================
menuVisible = true
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not _G.NeverloseUILoaded then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuVisible = not menuVisible
        if MainFrame and MainFrame.Parent then
            MainFrame.Visible = menuVisible
        end
    end
end)

print("[NL] 3/13 — Visuals / Misc / Settings загружены")
--=========================================================
-- NEVERLOSE UI — 4/13 (FIX v3)
-- Вкладка Teleport: игроки, координаты, сохранение позиции
-- ФИКСЫ:
--   • Debounce на поиск (не пересобирает список на каждый символ)
--   • Один HP-loop вместо N потоков
--   • Refresh только когда вкладка активна
--   • Unload чистит refresh-поток
--   • Кэш аватаров (не дёргает CDN)
--   • HP-loop троттлится до 2 Hz
--   • Правильная очистка соединений
--=========================================================

if not _G.NeverloseUILoaded then
    warn("[NL] Часть 4: база не загружена")
    return
end

tpContent = makeTabContent("Teleport")
if not tpContent then
    warn("[NL] Часть 4: не удалось создать вкладку Teleport")
    return
end

tpLeft  = createColumn(tpContent, "left")
tpRight = createColumn(tpContent, "right")

--=========================================================
-- TELEPORT FUNCTIONS
--=========================================================
function tpToPlayer(plr)
    if not plr or plr == LP then return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local tc = plr.Character
    local tHRP = tc and tc:FindFirstChild("HumanoidRootPart")
    if not tHRP then return end
    pcall(function()
        myHRP.CFrame = tHRP.CFrame + Vector3.new(0, 3, 0)
    end)
end

function tpToCoords(x, y, z)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        hrp.CFrame = CFrame.new(Vector3.new(x, y, z))
    end)
end

--=========================================================
-- PLAYER LIST
--=========================================================
tpPlayersSec = createSection(tpLeft, "Игроки")

tpSearchBox = Instance.new("TextBox")
tpSearchBox.Size = UDim2.new(1, 0, 0, 32)
tpSearchBox.BackgroundColor3 = NL_DARKER
tpSearchBox.BorderSizePixel = 0
tpSearchBox.Text = ""
tpSearchBox.PlaceholderText = "Поиск игрока..."
tpSearchBox.PlaceholderColor3 = NL_DIM
tpSearchBox.TextColor3 = NL_TEXT
tpSearchBox.Font = Enum.Font.Gotham
tpSearchBox.TextSize = 12
tpSearchBox.ClearTextOnFocus = false
tpSearchBox.ZIndex = 54
tpSearchBox.Parent = tpPlayersSec

local tsc = Instance.new("UICorner")
tsc.CornerRadius = UDim.new(0, 6)
tsc.Parent = tpSearchBox

local tss = Instance.new("UIStroke")
tss.Color = NL_BLUE
tss.Thickness = 1
tss.Transparency = 0.6
tss.Parent = tpSearchBox
registerAccent(tss, "Color")

tpCountLabel = Instance.new("TextLabel")
tpCountLabel.Size = UDim2.new(1, 0, 0, 16)
tpCountLabel.BackgroundTransparency = 1
tpCountLabel.Text = "Игроков: 0"
tpCountLabel.TextColor3 = NL_DIM
tpCountLabel.Font = Enum.Font.Gotham
tpCountLabel.TextSize = 11
tpCountLabel.TextXAlignment = Enum.TextXAlignment.Left
tpCountLabel.ZIndex = 54
tpCountLabel.Parent = tpPlayersSec

tpListFrame = Instance.new("ScrollingFrame")
tpListFrame.Size = UDim2.new(1, 0, 0, 320)
tpListFrame.BackgroundTransparency = 1
tpListFrame.BorderSizePixel = 0
tpListFrame.ScrollBarThickness = 4
tpListFrame.ScrollBarImageColor3 = NL_BLUE
tpListFrame.ScrollBarImageTransparency = 0.3
tpListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
tpListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
tpListFrame.ZIndex = 54
tpListFrame.Parent = tpPlayersSec
registerAccent(tpListFrame, "ScrollBarImageColor3")

local tll = Instance.new("UIListLayout")
tll.Padding = UDim.new(0, 6)
tll.SortOrder = Enum.SortOrder.LayoutOrder
tll.Parent = tpListFrame

tpEntries = {}

--=========================================================
-- AVATAR CACHE
--=========================================================
local avatarCache = {}
local function getAvatarUrl(userId)
    if not avatarCache[userId] then
        avatarCache[userId] = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=48&h=48"
    end
    return avatarCache[userId]
end

--=========================================================
-- CREATE ENTRY
--=========================================================
function createTPEntry(plr)
    if plr == LP then return end
    if tpEntries[plr] and tpEntries[plr].Parent then
        tpEntries[plr]:Destroy()
    end

    local entry = Instance.new("TextButton")
    entry.Size = UDim2.new(1, 0, 0, 42)
    entry.BackgroundColor3 = NL_DARKER
    entry.BorderSizePixel = 0
    entry.Text = ""
    entry.AutoButtonColor = false
    entry.ZIndex = 55
    entry.Parent = tpListFrame

    local ec = Instance.new("UICorner")
    ec.CornerRadius = UDim.new(0, 6)
    ec.Parent = entry

    local es = Instance.new("UIStroke")
    es.Color = NL_BLUE
    es.Thickness = 1
    es.Transparency = 0.7
    es.Parent = entry
    registerAccent(es, "Color")

    local avatar = Instance.new("ImageLabel")
    avatar.Size = UDim2.new(0, 32, 0, 32)
    avatar.Position = UDim2.new(0, 5, 0.5, -16)
    avatar.BackgroundColor3 = NL_DARK
    avatar.BorderSizePixel = 0
    avatar.Image = getAvatarUrl(plr.UserId)
    avatar.ZIndex = 56
    avatar.Parent = entry

    local ac = Instance.new("UICorner")
    ac.CornerRadius = UDim.new(1, 0)
    ac.Parent = avatar

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, -110, 0, 18)
    nameL.Position = UDim2.new(0, 44, 0, 5)
    nameL.BackgroundTransparency = 1
    nameL.Text = plr.Name
    nameL.TextColor3 = NL_TEXT
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 12
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.TextTruncate = Enum.TextTruncate.AtEnd
    nameL.ZIndex = 56
    nameL.Parent = entry

    local hpL = Instance.new("TextLabel")
    hpL.Size = UDim2.new(1, -110, 0, 14)
    hpL.Position = UDim2.new(0, 44, 0, 23)
    hpL.BackgroundTransparency = 1
    hpL.Text = "HP: --"
    hpL.TextColor3 = NL_DIM
    hpL.Font = Enum.Font.Gotham
    hpL.TextSize = 10
    hpL.TextXAlignment = Enum.TextXAlignment.Left
    hpL.ZIndex = 56
    hpL.Parent = entry

    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 55, 0, 26)
    tpBtn.Position = UDim2.new(1, -60, 0.5, -13)
    tpBtn.BackgroundColor3 = NL_BLUE
    tpBtn.BorderSizePixel = 0
    tpBtn.Text = "TP"
    tpBtn.TextColor3 = NL_WHITE
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.TextSize = 11
    tpBtn.AutoButtonColor = false
    tpBtn.ZIndex = 57
    tpBtn.Parent = entry
    registerAccent(tpBtn, "BackgroundColor3")

    local tbc = Instance.new("UICorner")
    tbc.CornerRadius = UDim.new(0, 4)
    tbc.Parent = tpBtn

    tpBtn.MouseButton1Click:Connect(function()
        tpToPlayer(plr)
    end)

    entry.MouseButton1Click:Connect(function()
        tpToPlayer(plr)
    end)

    entry.MouseEnter:Connect(function()
        tween(entry, 0.15, {BackgroundTransparency = 0.3})
    end)
    entry.MouseLeave:Connect(function()
        tween(entry, 0.15, {BackgroundTransparency = 0})
    end)

    tpEntries[plr] = entry
end

--=========================================================
-- HP LOOP (единый для всех записей, 2 Hz)
--=========================================================
tpHpConn = RunService.Heartbeat:Connect(function()
    if not _G.NeverloseUILoaded then return end
    local now = tick()
    if not _G.NL_TPHpNext or now < _G.NL_TPHpNext then return end
    _G.NL_TPHpNext = now + 0.5

    for plr, entry in pairs(tpEntries) do
        if entry and entry.Parent then
            -- Ищем HP-лейбл (позиция 2 среди TextLabel)
            local hpL
            for _, c in ipairs(entry:GetChildren()) do
                if c:IsA("TextLabel") and c.Text:sub(1, 4) == "HP: " then
                    hpL = c
                    break
                end
            end
            if hpL then
                local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                if hum and plr.Parent then
                    hpL.Text = "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                else
                    hpL.Text = "HP: --"
                end
            end
        end
    end
end)

--=========================================================
-- REFRESH LIST
--=========================================================
local tpSearchDebounceToken = 0

function refreshTPList()
    for plr, e in pairs(tpEntries) do
        if e and e.Parent then e:Destroy() end
    end
    tpEntries = {}

    local filter = ""
    if tpSearchBox then
        filter = string.lower(tpSearchBox.Text or "")
    end

    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local name = string.lower(plr.Name)
            local display = string.lower(plr.DisplayName or "")
            if filter == ""
                or name:find(filter, 1, true)
                or display:find(filter, 1, true) then
                createTPEntry(plr)
                count = count + 1
            end
        end
    end

    if tpCountLabel and tpCountLabel.Parent then
        if filter ~= "" then
            tpCountLabel.Text = "Найдено: " .. count
        else
            tpCountLabel.Text = "Игроков: " .. count
        end
    end
end

--========== DEBOUNCED SEARCH ==========
tpSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    tpSearchDebounceToken = tpSearchDebounceToken + 1
    local myToken = tpSearchDebounceToken
    task.delay(0.25, function()
        if tpSearchDebounceToken ~= myToken then return end
        if not _G.NeverloseUILoaded then return end
        refreshTPList()
    end)
end)

--========== PLAYER EVENTS ==========
Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if not _G.NeverloseUILoaded then return end
    refreshTPList()
end)

Players.PlayerRemoving:Connect(function(plr)
    if tpEntries[plr] then
        if tpEntries[plr].Parent then tpEntries[plr]:Destroy() end
        tpEntries[plr] = nil
    end
    if tpCountLabel and tpCountLabel.Parent then
        local c = 0
        for _ in pairs(tpEntries) do c = c + 1 end
        tpCountLabel.Text = "Игроков: " .. c
    end
end)

--========== AUTO-REFRESH (только когда вкладка активна) ==========
task.spawn(function()
    while _G.NeverloseUILoaded do
        task.wait(5)
        if tpContent and tpContent.Parent and tpContent.Visible then
            local realCount = #Players:GetPlayers() - 1
            local cached = 0
            for _ in pairs(tpEntries) do cached = cached + 1 end
            if realCount ~= cached then
                refreshTPList()
            end
        end
    end
end)

refreshTPList()

--=========================================================
-- COORDINATES
--=========================================================
tpCoordsSec = createSection(tpRight, "Координаты")

local function makeCoordInput(label)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 30)
    f.BackgroundTransparency = 1
    f.ZIndex = 54
    f.Parent = tpCoordsSec

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 40, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = NL_TEXT
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 55
    l.Parent = f

    local t = Instance.new("TextBox")
    t.Size = UDim2.new(1, -45, 1, 0)
    t.Position = UDim2.new(0, 45, 0, 0)
    t.BackgroundColor3 = NL_DARKER
    t.BorderSizePixel = 0
    t.Text = "0"
    t.TextColor3 = NL_TEXT
    t.Font = Enum.Font.Gotham
    t.TextSize = 12
    t.ClearTextOnFocus = false
    t.ZIndex = 55
    t.Parent = f

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = t

    local s = Instance.new("UIStroke")
    s.Color = NL_BLUE
    s.Thickness = 1
    s.Transparency = 0.6
    s.Parent = t
    registerAccent(s, "Color")

    return t
end

boxX = makeCoordInput("X:")
boxY = makeCoordInput("Y:")
boxZ = makeCoordInput("Z:")
boxX.Text = "0"
boxY.Text = "50"
boxZ.Text = "0"

createButton(tpCoordsSec, "Телепорт по координатам", NL_BLUE, function()
    local x = tonumber(boxX.Text) or 0
    local y = tonumber(boxY.Text) or 50
    local z = tonumber(boxZ.Text) or 0
    tpToCoords(x, y, z)
end)

createButton(tpCoordsSec, "Взять мои координаты", NL_DARKER, function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        boxX.Text = tostring(math.floor(hrp.Position.X))
        boxY.Text = tostring(math.floor(hrp.Position.Y))
        boxZ.Text = tostring(math.floor(hrp.Position.Z))
    end
end)

createButton(tpCoordsSec, "Вверх на 100", NL_DARKER, function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 100, 0)
        end)
    end
end)

createButton(tpCoordsSec, "Вниз на 100", NL_DARKER, function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = hrp.CFrame + Vector3.new(0, -100, 0)
        end)
    end
end)

--=========================================================
-- SAVE POSITION
--=========================================================
tpSaveSec = createSection(tpRight, "Сохранение позиции")

savedPos = nil

savedLabel = Instance.new("TextLabel")
savedLabel.Size = UDim2.new(1, 0, 0, 20)
savedLabel.BackgroundTransparency = 1
savedLabel.Text = "Позиция: не сохранена"
savedLabel.TextColor3 = NL_DIM
savedLabel.Font = Enum.Font.Gotham
savedLabel.TextSize = 11
savedLabel.TextXAlignment = Enum.TextXAlignment.Left
savedLabel.ZIndex = 55
savedLabel.Parent = tpSaveSec

createButton(tpSaveSec, "Сохранить позицию", NL_BLUE, function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        savedPos = hrp.CFrame
        savedLabel.Text = string.format(
            "Сохранено: (%.0f, %.0f, %.0f)",
            hrp.Position.X, hrp.Position.Y, hrp.Position.Z
        )
        savedLabel.TextColor3 = NL_GREEN
    end
end)

createButton(tpSaveSec, "Вернуться в сохранённое", NL_GREEN, function()
    if not savedPos then
        savedLabel.Text = "Сначала сохрани позицию!"
        savedLabel.TextColor3 = NL_RED
        return
    end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = savedPos
        end)
    end
end)

--=========================================================
-- UNLOAD
--=========================================================
_G.NL_UnloadTP = function()
    for _, e in pairs(tpEntries) do
        if e and e.Parent then e:Destroy() end
    end
    tpEntries = {}
    if tpHpConn then
        tpHpConn:Disconnect()
        tpHpConn = nil
    end
end

print("[NL] 4/13 — Teleport загружен (FIX v3)")
--=========================================================
-- NEVERLOSE UI — 5/13 (FIX v3)
-- Вкладка Cursor TP: телепорт к курсору
-- ФИКСЫ:
--   • Убран лишний GetMouse() каждый кадр (кеш мыши)
--   • Hazard-check по имени, не по цвету (быстрее)
--   • Debounce на кнопку ТП (нельзя спамить)
--   • RaycastParams кэшируется и инвалидируется при смене espFolder
--   • Обработка случая, когда курсор смотрит в небо
--   • Unload реально чистит (не только UI)
--   • Cooldown защита от "телепорт в стену и застревание"
--=========================================================

if not _G.NeverloseUILoaded then
    warn("[NL] Часть 5: база не загружена")
    return
end

ctpContent = makeTabContent("Cursor TP")
if not ctpContent then
    warn("[NL] Часть 5: не удалось создать вкладку Cursor TP")
    return
end

ctpLeft  = createColumn(ctpContent, "left")
ctpRight = createColumn(ctpContent, "right")

--=========================================================
-- STATE
--=========================================================
ctpSettings = {
    heightOffset   = 3,
    maxDistance    = 500,
    useRaycast     = true,
    blockIfHazard  = false,
    cooldown       = 0.15,
    hazardKeywords = {
        "kill", "lava", "damage", "death", "spike",
        "hazard", "void", "fire", "trap",
    },
}

ctpLastTP = 0
ctpCachedRayParams = nil
ctpCachedEspFolder = nil

--=========================================================
-- HAZARD CHECK
--=========================================================
function ctpIsHazard(part)
    if not part or not ctpSettings.blockIfHazard then return false end
    local n = string.lower(part.Name or "")
    for _, kw in ipairs(ctpSettings.hazardKeywords) do
        if string.find(n, kw, 1, true) then return true end
    end
    return false
end

--=========================================================
-- RAYCAST PARAMS (кеш)
--=========================================================
function ctpGetRayParams()
    if ctpCachedRayParams
        and ctpCachedEspFolder == espFolder
        and ctpCachedEspFolder ~= nil then
        return ctpCachedRayParams
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    local list = {}
    if LP.Character then table.insert(list, LP.Character) end
    if espFolder and espFolder.Parent then table.insert(list, espFolder) end

    params.FilterDescendantsInstances = list

    ctpCachedRayParams = params
    ctpCachedEspFolder = espFolder
    return params
end

--=========================================================
-- GET POSITION UNDER CURSOR
--=========================================================
function getCursorWorldPos()
    local cam = workspace.CurrentCamera
    if not cam then return nil end

    -- ✅ Кешируем Mouse — не создаём каждый вызов
    local mouse = Mouse or LP:GetMouse()
    if not mouse then return nil end

    local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)

    if ctpSettings.useRaycast then
        local result = workspace:Raycast(
            ray.Origin,
            ray.Direction * ctpSettings.maxDistance,
            ctpGetRayParams()
        )
        if result then
            if ctpIsHazard(result.Instance) then return nil end
            return result.Position, result.Instance
        end
        -- Не попали ни во что — не ТП-аем
        return nil, nil
    end

    -- Без raycast — точка на луче в макс. дистанции
    return ray.Origin + ray.Direction * ctpSettings.maxDistance, nil
end

--=========================================================
-- TELEPORT TO CURSOR
--=========================================================
function tpToCursor()
    if not _G.NeverloseUILoaded then return end

    local now = tick()
    if now - ctpLastTP < ctpSettings.cooldown then return end
    ctpLastTP = now

    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pos = getCursorWorldPos()
    if not pos then
        if _G.NL_Notify then
            _G.NL_Notify("Курсор не на поверхности", NL_RED, 2)
        end
        return
    end

    pcall(function()
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, ctpSettings.heightOffset, 0))
    end)
end

_G.NL_TPToCursor = tpToCursor

--=========================================================
-- UI: MAIN
--=========================================================
ctpMainSec = createSection(ctpLeft, "Управление")

ctpContainer = Instance.new("Frame")
ctpContainer.Size = UDim2.new(1, 0, 0, 34)
ctpContainer.BackgroundTransparency = 1
ctpContainer.ZIndex = 54
ctpContainer.Parent = ctpMainSec

ctpBtn = Instance.new("TextButton")
ctpBtn.Size = UDim2.new(1, -52, 1, 0)
ctpBtn.BackgroundColor3 = NL_BLUE
ctpBtn.BorderSizePixel = 0
ctpBtn.Text = "Телепорт к курсору"
ctpBtn.TextColor3 = NL_WHITE
ctpBtn.Font = Enum.Font.GothamBold
ctpBtn.TextSize = 12
ctpBtn.AutoButtonColor = false
ctpBtn.ZIndex = 55
ctpBtn.Parent = ctpContainer
registerAccent(ctpBtn, "BackgroundColor3")

local ctpc = Instance.new("UICorner")
ctpc.CornerRadius = UDim.new(0, 5)
ctpc.Parent = ctpBtn

ctpBtn.MouseButton1Click:Connect(tpToCursor)
ctpBtn.MouseEnter:Connect(function()
    tween(ctpBtn, 0.15, {BackgroundTransparency = 0.2})
end)
ctpBtn.MouseLeave:Connect(function()
    tween(ctpBtn, 0.15, {BackgroundTransparency = 0})
end)

ctpBindBtn = Instance.new("TextButton")
ctpBindBtn.Size = UDim2.new(0, 46, 0, 22)
ctpBindBtn.Position = UDim2.new(1, -46, 0.5, -11)
ctpBindBtn.BackgroundColor3 = NL_DARKER
ctpBindBtn.BorderSizePixel = 0
ctpBindBtn.Text = "[None]"
ctpBindBtn.TextColor3 = NL_DIM
ctpBindBtn.Font = Enum.Font.Gotham
ctpBindBtn.TextSize = 10
ctpBindBtn.AutoButtonColor = false
ctpBindBtn.ZIndex = 56
ctpBindBtn.Parent = ctpContainer

local ctpc2 = Instance.new("UICorner")
ctpc2.CornerRadius = UDim.new(0, 3)
ctpc2.Parent = ctpBindBtn

local ctps = Instance.new("UIStroke")
ctps.Color = NL_BLUE
ctps.Thickness = 1
ctps.Transparency = 0.7
ctps.Parent = ctpBindBtn
registerAccent(ctps, "Color")

BindCallbacks["CTP_Teleport"] = tpToCursor

ctpBindBtn.MouseButton1Click:Connect(function()
    startListeningForBind(ctpBindBtn, "CTP_Teleport", "Нажми клавишу для ТП к курсору")
end)

--=========================================================
-- SETTINGS
--=========================================================
ctpSetSec = createSection(ctpLeft, "Настройки")

createSlider(ctpSetSec, "Высота над полом", 0, 20, 3, function(v)
    ctpSettings.heightOffset = v
end)

createSlider(ctpSetSec, "Макс. дистанция", 50, 2000, 500, function(v)
    ctpSettings.maxDistance = v
end)

createSlider(ctpSetSec, "Cooldown x100", 5, 100, 15, function(v)
    ctpSettings.cooldown = v / 100
end)

createCheckbox(ctpSetSec, "Raycast (к поверхности)", true, function(v)
    ctpSettings.useRaycast = v
end, "CTP_Raycast")

createCheckbox(ctpSetSec, "Блокировать опасные блоки", false, function(v)
    ctpSettings.blockIfHazard = v
end, "CTP_BlockHazard")

--=========================================================
-- QUICK ACTIONS
--=========================================================
ctpQuickSec = createSection(ctpRight, "Быстрые действия")

createButton(ctpQuickSec, "ТП к курсору", NL_BLUE, tpToCursor)

createButton(ctpQuickSec, "ТП вперёд на 50", NL_DARKER, function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 50
        end)
    end
end)

createButton(ctpQuickSec, "ТП назад на 50", NL_DARKER, function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = hrp.CFrame - hrp.CFrame.LookVector * 50
        end)
    end
end)

createButton(ctpQuickSec, "ТП вверх на 50", NL_DARKER, function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 50, 0)
        end)
    end
end)

createButton(ctpQuickSec, "ТП вниз на 50", NL_DARKER, function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = hrp.CFrame + Vector3.new(0, -50, 0)
        end)
    end
end)

--=========================================================
-- INFO
--=========================================================
ctpInfoSec = createSection(ctpRight, "Информация")

ctpInfoLabel = Instance.new("TextLabel")
ctpInfoLabel.Size = UDim2.new(1, 0, 0, 110)
ctpInfoLabel.BackgroundTransparency = 1
ctpInfoLabel.Text = "1. Наведи курсор на точку\n2. Нажми бинд (или кнопку)\n3. Телепортируешься туда\n\nRaycast ON — ТП к поверхности\nRaycast OFF — ТП в точку на луче\n\nCooldown защищает от спама."
ctpInfoLabel.TextColor3 = NL_DIM
ctpInfoLabel.Font = Enum.Font.Gotham
ctpInfoLabel.TextSize = 11
ctpInfoLabel.TextWrapped = true
ctpInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
ctpInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
ctpInfoLabel.ZIndex = 55
ctpInfoLabel.Parent = ctpInfoSec

--=========================================================
-- UNLOAD
--=========================================================
_G.NL_UnloadCTP = function()
    ctpCachedRayParams = nil
    ctpCachedEspFolder = nil

    if BindCallbacks["CTP_Teleport"] then
        BindCallbacks["CTP_Teleport"] = nil
    end
    if ctpContent and ctpContent.Parent then
        ctpContent:Destroy()
    end
end

print("[NL] 5/13 — Cursor TP загружен (FIX v3)")
--=========================================================
-- NEVERLOSE UI — 6/13 (FIX v3)
-- Вкладка Baritone: AI-навигация с паркуром и hazard-детектом
-- ФИКСЫ:
--   • SPEED GUARD: JumpPower/WalkSpeed не перебиваются вне Baritone
--   • Убран дубль task.wait(0.05) при lack of repath
--   • btMemory очистка по времени корректная
--   • Правильный фильтр для espFolder после пересоздания
--   • Unload корректный (btStop + все connections)
--   • btSpeedConn не воюет со SpeedSystem.Matrix
--   • pcall на всех Raycast (workspace может быть занят)
--=========================================================

if not _G.NeverloseUILoaded then
    warn("[NL] Часть 6: база не загружена")
    return
end

btContent = makeTabContent("Baritone")
if not btContent then
    warn("[NL] Часть 6: не удалось создать вкладку Baritone")
    return
end

btLeft  = createColumn(btContent, "left")
btRight = createColumn(btContent, "right")

--=========================================================
-- STATE
--=========================================================
btS = {
    speed = 28, slowSpeed = 14, fastSpeed = 36, jumpPower = 70,
    target = nil, running = false, showPath = true, autoJump = true, avoidKill = true,
    hazardColor = Color3.fromRGB(255, 0, 0), colorTol = 0.12,
    scanDist = 30, jumpMargin = 3, minJumpPower = 50, maxJumpPower = 350,
    autoRepath = true, repathTime = 0.5, stuckTime = 1.0, sidestepDist = 8,
    parkourMode = true, wallCheck = true, adaptivePath = true,
    newObjRange = 30, gapLookAhead = 10, maxGapJump = 40,
    smartBrain = true, simSteps = 20, simTimeStep = 0.05,
    rememberFails = true, memRadius = 8, memLifetime = 60,
    adaptiveSpeed = true, wallJump = true, backtrackAfter = 3,
    wpSpacing = 8, wpAdvance = 4, flightBoost = true, boostDuration = 0.2,
    debug = false,
}

function btLog(...)
    if btS.debug then print("[Baritone]", ...) end
end

--=========================================================
-- RUNTIME
--=========================================================
btLastRepath = 0
btLastPos = nil
btLastMoveTime = tick()
btCurrentWps = nil
btCurrentIdx = 1
btJumping = false
btNormalJump = btS.jumpPower
btNewObjFlag = false
btStuckCount = 0
btLockJumpPower = false
btMemory = {hazards = {}, fails = {}}
btMarker = nil
btMemFolder = nil
btTracerFolder = nil
btMoveLoopRunning = false

--=========================================================
-- CREATE WORKSPACE OBJECTS
--=========================================================
function btCreateWorkspaceObjects()
    if btMarker and btMarker.Parent then return end

    btMarker = Instance.new("Part")
    btMarker.Name = "NL_Marker_" .. math.random(10000, 99999)
    btMarker.Shape = Enum.PartType.Ball
    btMarker.Size = Vector3.new(2, 2, 2)
    btMarker.Anchored = true
    btMarker.CanCollide = false
    btMarker.CanQuery = false
    btMarker.CanTouch = false
    btMarker.Material = Enum.Material.SmoothPlastic
    btMarker.Color = Color3.fromRGB(0, 255, 120)
    btMarker.Transparency = 0.4
    btMarker.Parent = workspace

    btMemFolder = Instance.new("Folder")
    btMemFolder.Name = "NL_Mem_" .. math.random(1000, 9999)
    btMemFolder.Parent = workspace

    btTracerFolder = Instance.new("Folder")
    btTracerFolder.Name = "NL_Trace_" .. math.random(1000, 9999)
    btTracerFolder.Parent = workspace
end

--=========================================================
-- VISUALS
--=========================================================
function btDrawMemory()
    if not btMemFolder or not btMemFolder.Parent then return end
    for _, c in ipairs(btMemFolder:GetChildren()) do c:Destroy() end

    for _, m in ipairs(btMemory.hazards) do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(1.5, 1.5, 1.5)
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.Material = Enum.Material.SmoothPlastic
        p.Color = Color3.fromRGB(255, 60, 60)
        p.Transparency = 0.6
        p.Position = m.pos
        p.Parent = btMemFolder
    end

    for _, m in ipairs(btMemory.fails) do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(1.5, 1.5, 1.5)
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.Material = Enum.Material.SmoothPlastic
        p.Color = Color3.fromRGB(255, 180, 0)
        p.Transparency = 0.6
        p.Position = m.pos
        p.Parent = btMemFolder
    end
end

function btClearTracer()
    if not btTracerFolder or not btTracerFolder.Parent then return end
    for _, p in ipairs(btTracerFolder:GetChildren()) do p:Destroy() end
end

function btDrawPath(wps)
    btClearTracer()
    if not btS.showPath or not wps or not btTracerFolder or not btTracerFolder.Parent then
        return
    end

    for i = 1, #wps - 1 do
        local a, b = wps[i], wps[i + 1]
        local d = (a.Position - b.Position).Magnitude
        if d > 0.1 then
            local p = Instance.new("Part")
            p.Anchored = true
            p.CanCollide = false
            p.CanQuery = false
            p.CanTouch = false
            p.Material = Enum.Material.SmoothPlastic
            p.Color = (i == #wps - 1)
                and Color3.fromRGB(0, 255, 120)
                or  Color3.fromRGB(0, 170, 255)
            p.Transparency = 0.45
            p.Size = Vector3.new(0.3, 0.3, d)
            p.CFrame = CFrame.new(a.Position, b.Position) * CFrame.new(0, 0, -d / 2)
            p.Parent = btTracerFolder
        end
    end
end

--=========================================================
-- RAYCAST
--=========================================================
function btNewRayParams()
    local p = RaycastParams.new()
    p.FilterType = Enum.RaycastFilterType.Exclude
    local list = {}
    if LP.Character then table.insert(list, LP.Character) end
    if btMarker and btMarker.Parent then table.insert(list, btMarker) end
    if btTracerFolder and btTracerFolder.Parent then table.insert(list, btTracerFolder) end
    if btMemFolder and btMemFolder.Parent then table.insert(list, btMemFolder) end
    if espFolder and espFolder.Parent then table.insert(list, espFolder) end
    p.FilterDescendantsInstances = list
    return p
end

function btGetMousePos()
    local cam = workspace.CurrentCamera
    if not cam then return Vector3.new(0, 50, 0) end
    local mouse = Mouse or LP:GetMouse()
    if not mouse then return Vector3.new(0, 50, 0) end
    local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)
    local ok, hit = pcall(function()
        return workspace:Raycast(ray.Origin, ray.Direction * 1000, btNewRayParams())
    end)
    if ok and hit then return hit.Position end
    return ray.Origin + ray.Direction * 500
end

--=========================================================
-- HAZARD
--=========================================================
btKillKeywords = {
    "kill", "lava", "damage", "death", "spike",
    "hazard", "fire", "poison", "trap", "insta",
    "void", "burn", "dead",
}

function btIsHazard(part)
    if not part or not part.Parent then return false end
    if LP.Character and part:IsDescendantOf(LP.Character) then return false end
    if btMarker and part == btMarker then return false end
    if btTracerFolder and part:IsDescendantOf(btTracerFolder) then return false end
    if btMemFolder and part:IsDescendantOf(btMemFolder) then return false end

    local n = string.lower(part.Name or "")
    for _, kw in ipairs(btKillKeywords) do
        if string.find(n, kw, 1, true) then return true end
    end

    local ok1, h1, s1, v1 = pcall(function()
        return Color3.toHSV(btS.hazardColor)
    end)
    if not ok1 then return false end

    local ok2, h2, s2, v2 = pcall(function()
        return Color3.toHSV(part.Color)
    end)
    if not ok2 then return false end

    local dh = math.abs(h1 - h2)
    if dh > 0.5 then dh = 1 - dh end

    if dh < btS.colorTol and s2 > 0.4 and v2 > 0.4 and s1 > 0.3 then
        return true
    end
    return false
end

function btGroundBelow(pos, depth)
    depth = depth or 5
    local ok, res = pcall(function()
        return workspace:Raycast(
            pos + Vector3.new(0, 2, 0),
            Vector3.new(0, -depth, 0),
            btNewRayParams()
        )
    end)
    if not ok or not res then return nil, nil, false end
    return res.Position, res.Instance, btIsHazard(res.Instance)
end

--=========================================================
-- MEMORY
--=========================================================
function btMemAdd(list, pos)
    table.insert(list, {pos = pos, t = tick()})
    local now = tick()
    for i = #list, 1, -1 do
        if now - list[i].t > btS.memLifetime then
            table.remove(list, i)
        end
    end
    while #list > 100 do table.remove(list, 1) end
end

function btMemNear(list, pos, radius)
    for _, m in ipairs(list) do
        if (m.pos - pos).Magnitude < radius then return true end
    end
    return false
end

--=========================================================
-- SIMULATE JUMP
--=========================================================
function btSimulateJump(fromPos, dir, jp, sp)
    local g = workspace.Gravity
    if g <= 0 then g = 196.2 end
    local pos = fromPos
    local vel = Vector3.new(dir.X * sp, jp, dir.Z * sp)

    for i = 1, btS.simSteps do
        vel = vel - Vector3.new(0, g * btS.simTimeStep, 0)
        pos = pos + vel * btS.simTimeStep

        local _, hitPart, haz = btGroundBelow(pos, 3)
        if hitPart then
            if haz then return false, pos, "hazard" end
            if btMemNear(btMemory.hazards, pos, btS.memRadius) then
                return false, pos, "memory"
            end
            return true, pos, "ok"
        end
    end
    return false, pos, "no_land"
end

--=========================================================
-- DETECT
--=========================================================
function btPlatformWidth(hrp, dir)
    local side = dir:Cross(Vector3.new(0, 1, 0)).Unit
    local leftW, rightW = 0, 0
    for i = 1, 10 do
        local _, hit = btGroundBelow(hrp.Position + side * i, 4)
        if not hit then break end
        leftW = i
    end
    for i = 1, 10 do
        local _, hit = btGroundBelow(hrp.Position - side * i, 4)
        if not hit then break end
        rightW = i
    end
    return leftW + rightW
end

function btFanScanHazard(hrp, dir)
    local angles = {0, math.rad(25), -math.rad(25)}
    for _, a in ipairs(angles) do
        local d = (CFrame.Angles(0, a, 0) * dir).Unit

        local ok1, res1 = pcall(function()
            return workspace:Raycast(
                hrp.Position - Vector3.new(0, 2, 0),
                d * btS.scanDist,
                btNewRayParams()
            )
        end)
        if ok1 and res1 and btIsHazard(res1.Instance) then return true, d end

        local ok2, res2 = pcall(function()
            return workspace:Raycast(
                hrp.Position + Vector3.new(0, 1, 0),
                d * btS.scanDist,
                btNewRayParams()
            )
        end)
        if ok2 and res2 and btIsHazard(res2.Instance) then return true, d end
    end
    return false, nil
end

function btDetectGap(hrp, dir)
    if not btS.parkourMode then return nil end
    local edgeD, landD = nil, nil
    for d = 1, btS.maxGapJump + 5, 0.5 do
        local probe = hrp.Position + dir * d
        local _, hit = btGroundBelow(probe, 30)
        if not hit then
            if not edgeD then edgeD = d end
        else
            if edgeD then landD = d break end
        end
        if d > btS.gapLookAhead and not edgeD then break end
    end
    if edgeD and landD then return edgeD, landD - edgeD end
    return nil, nil
end

function btDetectWall(hrp, dir)
    if not btS.wallCheck then return nil end
    local origin = hrp.Position + Vector3.new(0, 1, 0)
    local ok, res = pcall(function()
        return workspace:Raycast(origin, dir * 5, btNewRayParams())
    end)
    if ok and res and res.Instance then
        local top = res.Instance.Position.Y + res.Instance.Size.Y / 2
        if top > hrp.Position.Y + 3 then return res.Instance end
    end
    return nil
end

--=========================================================
-- BOOST
--=========================================================
function btBoost(hrp, dir, speed, duration)
    local bv = Instance.new("BodyVelocity")
    bv.Name = "NL_Boost"
    bv.MaxForce = Vector3.new(1e5, 0, 1e5)
    bv.Velocity = Vector3.new(dir.X * speed, 0, dir.Z * speed)
    bv.Parent = hrp
    task.delay(duration or btS.boostDuration, function()
        if bv and bv.Parent then bv:Destroy() end
    end)
end

function btSmartJump(hrp, hum, dir, jp)
    if not hrp or not hum then return end
    btLockJumpPower = true
    if hum.UseJumpPower then hum.JumpPower = jp or btS.jumpPower end

    hum:MoveTo(hrp.Position + dir * 10)
    local t0 = tick()
    while tick() - t0 < 0.15 do
        task.wait()
        if hum.MoveDirection.Magnitude > 0.1 then break end
    end

    hum.Jump = true
    if btS.flightBoost then
        btBoost(hrp, dir, btS.speed, btS.boostDuration)
    end

    task.spawn(function()
        local t1 = tick()
        while tick() - t1 < 2 do
            task.wait(0.05)
            if not hrp or not hrp.Parent then break end
            local st = hum:GetState()
            if st ~= Enum.HumanoidStateType.Freefall
                and st ~= Enum.HumanoidStateType.Jumping
                and st ~= Enum.HumanoidStateType.Landed then
                break
            end
        end
        btLockJumpPower = false
    end)
end

--=========================================================
-- WORLD MONITOR
--=========================================================
btWorldConn = workspace.DescendantAdded:Connect(function(obj)
    if not _G.NeverloseUILoaded then return end
    if not btS.running or not btS.adaptivePath then return end
    if not obj:IsA("BasePart") then return end

    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if (obj.Position - hrp.Position).Magnitude < btS.newObjRange then
        btNewObjFlag = true
    end
end)

--=========================================================
-- BRAIN (hazard/parkour/wall при движении)
--=========================================================
btBrainConn = RunService.Heartbeat:Connect(function()
    if not _G.NeverloseUILoaded then return end
    if not btS.running then return end

    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Freefall
        or state == Enum.HumanoidStateType.Jumping then
        btJumping = true
        return
    end
    if btJumping then
        btJumping = false
        if hum.UseJumpPower and not btLockJumpPower then
            hum.JumpPower = btNormalJump
        end
    end

    local dir = hum.MoveDirection
    if dir.Magnitude < 0.1 then return end
    dir = dir.Unit

    local g = workspace.Gravity
    if g <= 0 then g = 196.2 end

    -- Hazard
    if btS.avoidKill then
        local haz, hazDir = btFanScanHazard(hrp, dir)
        if haz and hazDir then
            local startD, endD = nil, nil
            for d = 1, btS.scanDist, 1 do
                local origin = hrp.Position + hazDir * d - Vector3.new(0, 2, 0)
                local ok, res = pcall(function()
                    return workspace:Raycast(origin, Vector3.new(0, -3, 0), btNewRayParams())
                end)
                local h = ok and res and btIsHazard(res.Instance)
                if h and not startD then startD = d end
                if h then endD = d end
                if startD and not h and d > startD + 1 then break end
            end

            if startD then
                local totalDist = (endD or startD) + btS.jumpMargin
                local airDist = btS.speed * (2 * btS.jumpPower / g)

                if startD <= airDist * 0.5 then
                    local needJP = btS.jumpPower
                    if airDist < totalDist then
                        needJP = (totalDist * g) / (2 * btS.speed)
                        needJP = math.clamp(needJP, btS.minJumpPower, btS.maxJumpPower)
                    end

                    if btS.smartBrain then
                        local okSim = btSimulateJump(hrp.Position, dir, needJP, btS.speed)
                        if not okSim then
                            if btS.rememberFails then
                                btMemAdd(btMemory.fails, hrp.Position + dir * startD)
                            end
                            return
                        end
                    end

                    btSmartJump(hrp, hum, dir, needJP)
                    return
                end
            end
        end
    end

    -- Parkour
    if btS.parkourMode then
        local edgeD, gapW = btDetectGap(hrp, dir)
        if edgeD and gapW and edgeD <= 3 then
            local needJP = ((gapW + btS.jumpMargin) * g) / (2 * btS.speed)
            needJP = math.clamp(needJP, btS.minJumpPower, btS.maxJumpPower)

            if btS.smartBrain then
                local okSim = btSimulateJump(hrp.Position, dir, needJP, btS.speed)
                if not okSim then
                    if btS.rememberFails then
                        btMemAdd(btMemory.fails, hrp.Position + dir * edgeD)
                    end
                    needJP = btS.maxJumpPower
                    local ok2 = btSimulateJump(hrp.Position, dir, needJP, btS.speed)
                    if not ok2 then return end
                end
            end

            btSmartJump(hrp, hum, dir, needJP)
            return
        end
    end

    -- Wall jump
    local wall = btDetectWall(hrp, dir)
    if wall and btS.wallJump then
        btSmartJump(hrp, hum, dir, btS.jumpPower)
    end
end)

--=========================================================
-- PATHFINDING
--=========================================================
function btBuildPath(fromPos, targetPos)
    local ok, path = pcall(function()
        return Pathfinding:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = btS.autoJump or btS.parkourMode,
            WaypointSpacing = btS.wpSpacing,
        })
    end)
    if not ok or not path then return nil, nil end

    local okc = pcall(function() path:ComputeAsync(fromPos, targetPos) end)
    if okc and path.Status == Enum.PathStatus.Success then
        local wps = path:GetWaypoints()
        if wps and #wps > 0 then return path, wps end
    end
    return nil, nil
end

function btWpsHaveHazard(wps)
    if not wps then return false end
    for _, wp in ipairs(wps) do
        local _, _, haz = btGroundBelow(wp.Position, 6)
        if haz then return true end
        if btMemNear(btMemory.hazards, wp.Position, btS.memRadius) then return true end
    end
    return false
end

function btWpsBlocked(wps)
    if not wps or not btS.wallCheck then return false end
    for i = 1, #wps - 1 do
        local a, b = wps[i], wps[i + 1]
        local dir = (b.Position - a.Position)
        local dist = dir.Magnitude
        if dist > 0.5 then
            local ok, res = pcall(function()
                return workspace:Raycast(
                    a.Position + Vector3.new(0, 1, 0),
                    dir.Unit * dist,
                    btNewRayParams()
                )
            end)
            if ok and res and res.Instance and not btIsHazard(res.Instance) then
                local top = res.Instance.Position.Y + res.Instance.Size.Y / 2
                if top > a.Position.Y + 3 then return true end
            end
        end
    end
    return false
end

function btDoSidestep(hrp, hum)
    local dir = hum.MoveDirection
    if dir.Magnitude < 0.1 then dir = Vector3.new(0, 0, -1) end
    dir = dir.Unit
    local side = dir:Cross(Vector3.new(0, 1, 0)).Unit
    for _, mult in ipairs({1, -1}) do
        local probe = hrp.Position + side * mult * btS.sidestepDist
        local _, hit, haz = btGroundBelow(probe, 10)
        if hit and not haz then
            hum:MoveTo(probe)
            return true
        end
    end
    return false
end

--=========================================================
-- MOVEMENT LOOP
--=========================================================
function btMovementLoop()
    if btMoveLoopRunning then return end
    btMoveLoopRunning = true
    btLog("Цикл движения запущен")

    while _G.NeverloseUILoaded and btS.running do
        local char = LP.Character
        if not char or not char.Parent then
            task.wait(0.2)
        else
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if not hrp or not hum or hum.Health <= 0 then
                task.wait(0.2)
            elseif hum.PlatformStand then
                hum.PlatformStand = false
            elseif not btS.target then
                task.wait(0.2)
            else
                -- Проверяем, не стоим ли на hazard
                if tick() % 3 < 0.06 then
                    local _, hit, haz = btGroundBelow(hrp.Position, 6)
                    if hit and not haz then
                        btMemAdd(btMemory.hazards, hrp.Position)
                    end
                end

                -- Дошли до цели?
                if (hrp.Position - btS.target).Magnitude < 4 then
                    break
                end

                -- Адаптивная скорость
                if btS.adaptiveSpeed then
                    local dir = hum.MoveDirection
                    if dir.Magnitude > 0.1 then
                        local w = btPlatformWidth(hrp, dir.Unit)
                        local targetSpeed = btS.speed
                        if w <= 3 then targetSpeed = btS.slowSpeed
                        elseif w >= 10 then targetSpeed = btS.fastSpeed end
                        if hum.WalkSpeed ~= targetSpeed then
                            hum.WalkSpeed = targetSpeed
                        end
                    end
                end

                -- Anti-stuck
                local moving = hrp.AssemblyLinearVelocity.Magnitude > 2
                    or (btLastPos and (hrp.Position - btLastPos).Magnitude > 0.5)

                if moving then
                    btLastMoveTime = tick()
                    btLastPos = hrp.Position
                else
                    if tick() - btLastMoveTime > btS.stuckTime then
                        btStuckCount = btStuckCount + 1
                        local dir = hum.MoveDirection
                        if dir.Magnitude < 0.1 then dir = Vector3.new(0, 0, -1) end

                        btSmartJump(hrp, hum, dir.Unit, btS.jumpPower)
                        task.wait(0.2)

                        if not btDoSidestep(hrp, hum) then
                            hum:MoveTo(hrp.Position - dir.Unit * 5)
                        end

                        if btStuckCount >= btS.backtrackAfter then
                            local back = hrp.Position - (btS.target - hrp.Position).Unit * 8
                            hum:MoveTo(back)
                            task.wait(0.5)
                            btStuckCount = 0
                        end

                        btCurrentWps, btCurrentIdx = nil, 1
                        btLastMoveTime = tick()
                    end
                end

                -- Repath?
                local needRepath = false
                if not btCurrentWps or btCurrentIdx > #btCurrentWps then
                    needRepath = true
                elseif btS.autoRepath then
                    if btS.avoidKill and btWpsHaveHazard(btCurrentWps) then needRepath = true end
                    if btS.wallCheck and btWpsBlocked(btCurrentWps) then needRepath = true end
                    if btNewObjFlag then
                        btNewObjFlag = false
                        needRepath = true
                    end
                end

                if needRepath and tick() - btLastRepath >= btS.repathTime then
                    btLastRepath = tick()
                    local _, wps = btBuildPath(hrp.Position, btS.target)
                    if wps then
                        btCurrentWps, btCurrentIdx = wps, 1
                        btDrawPath(wps)
                    else
                        btCurrentWps = {{
                            Position = btS.target,
                            Action = Enum.PathWaypointAction.Walk,
                        }}
                        btCurrentIdx = 1
                        btDrawPath(btCurrentWps)
                    end
                end

                -- Идём по waypoints
                if btCurrentWps and btCurrentIdx <= #btCurrentWps then
                    while btCurrentIdx < #btCurrentWps do
                        local dCur = (hrp.Position - btCurrentWps[btCurrentIdx].Position).Magnitude
                        local dNext = (hrp.Position - btCurrentWps[btCurrentIdx + 1].Position).Magnitude
                        if dNext < dCur then
                            btCurrentIdx = btCurrentIdx + 1
                        else
                            break
                        end
                    end

                    local wp = btCurrentWps[btCurrentIdx]
                    if wp.Action == Enum.PathWaypointAction.Jump and btS.autoJump then
                        local d = hum.MoveDirection
                        if d.Magnitude < 0.1 then
                            d = (wp.Position - hrp.Position)
                            d = Vector3.new(d.X, 0, d.Z).Unit
                        end
                        btSmartJump(hrp, hum, d, btS.jumpPower)
                    end

                    hum:MoveTo(wp.Position)

                    if (hrp.Position - wp.Position).Magnitude < btS.wpAdvance then
                        btCurrentIdx = btCurrentIdx + 1
                    end
                end

                task.wait(0.05)
            end
        end
    end

    btS.running = false
    btMoveLoopRunning = false
    if btMarker then btMarker.Transparency = 0.4 end
    btClearTracer()
end

--=========================================================
-- CONTROL
--=========================================================
function btPlacePoint()
    btCreateWorkspaceObjects()
    local pos = btGetMousePos()
    btS.target = pos
    if btMarker then btMarker.Position = pos end
    btCurrentWps, btCurrentIdx = nil, 1
    btLastRepath = 0
    if _G.NL_Notify then _G.NL_Notify("Точка поставлена", NL_BLUE, 2) end
end

function btStart()
    btCreateWorkspaceObjects()
    if not btS.target then
        warn("[Baritone] Нет цели")
        if _G.NL_Notify then _G.NL_Notify("Сначала поставь точку", NL_RED, 2) end
        return
    end
    if btS.running then return end

    btS.running = true
    if btMarker then btMarker.Transparency = 0.8 end
    btCurrentWps, btCurrentIdx = nil, 1
    btLastRepath = 0
    btLastMoveTime = tick()
    btLastPos = nil
    btNewObjFlag = false
    btStuckCount = 0

    task.spawn(btMovementLoop)
    if _G.NL_Notify then _G.NL_Notify("Baritone: старт", NL_GREEN, 2) end
end

function btStop()
    btS.running = false
    btCurrentWps = nil
    btClearTracer()

    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then hum:MoveTo(hrp.Position) end
    end
    if _G.NL_Notify then _G.NL_Notify("Baritone: стоп", NL_YELLOW, 2) end
end

function btReset()
    btS.target = nil
    if btMarker then btMarker.Position = Vector3.new(0, -500, 0) end
    btCurrentWps = nil
    btClearTracer()
    btMemory.hazards = {}
    btMemory.fails = {}
    btDrawMemory()
    if _G.NL_Notify then _G.NL_Notify("Baritone: сброс", NL_DIM, 2) end
end

function btClearMemory()
    btMemory.hazards = {}
    btMemory.fails = {}
    btDrawMemory()
    if _G.NL_Notify then _G.NL_Notify("Память очищена", NL_GREEN, 2) end
end

--=========================================================
-- SPEED GUARD (не воюет со SpeedSystem)
--=========================================================
btSpeedConn = RunService.Heartbeat:Connect(function()
    if not _G.NeverloseUILoaded then return end
    if not btS.running then return end

    -- ✅ Не трогаем WalkSpeed если SpeedSystem в Matrix — он сам управляет
    if SpeedSystem and SpeedSystem.Enabled and SpeedSystem.Mode == "Matrix" then
        return
    end

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if not btS.adaptiveSpeed and hum.WalkSpeed ~= btS.speed then
            hum.WalkSpeed = btS.speed
        end
        if not btLockJumpPower and hum.UseJumpPower and hum.JumpPower ~= btS.jumpPower then
            hum.JumpPower = btS.jumpPower
        end
    end
end)

--=========================================================
-- BINDABLE BUTTON HELPER
--=========================================================
function btMakeBindableButton(parent, label, callback, color, bindAction)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundTransparency = 1
    container.ZIndex = 54
    container.Parent = parent

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -52, 1, 0)
    btn.BackgroundColor3 = color or NL_BLUE
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = NL_WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.ZIndex = 55
    btn.Parent = container

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 5)
    bc.Parent = btn

    btn.MouseEnter:Connect(function() tween(btn, 0.15, {BackgroundTransparency = 0.2}) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.15, {BackgroundTransparency = 0}) end)
    btn.MouseButton1Click:Connect(callback)

    local bb = Instance.new("TextButton")
    bb.Size = UDim2.new(0, 46, 0, 22)
    bb.Position = UDim2.new(1, -46, 0.5, -11)
    bb.BackgroundColor3 = NL_DARKER
    bb.BorderSizePixel = 0
    bb.Text = "[None]"
    bb.TextColor3 = NL_DIM
    bb.Font = Enum.Font.Gotham
    bb.TextSize = 10
    bb.AutoButtonColor = false
    bb.ZIndex = 56
    bb.Parent = container

    local bbc = Instance.new("UICorner")
    bbc.CornerRadius = UDim.new(0, 3)
    bbc.Parent = bb

    local bbs = Instance.new("UIStroke")
    bbs.Color = NL_BLUE
    bbs.Thickness = 1
    bbs.Transparency = 0.7
    bbs.Parent = bb
    registerAccent(bbs, "Color")

    if bindAction then BindCallbacks[bindAction] = callback end

    bb.MouseButton1Click:Connect(function()
        startListeningForBind(bb, bindAction)
    end)
end

--=========================================================
-- UI: MAIN
--=========================================================
btSecMain = createSection(btLeft, "Управление")

createCheckbox(btSecMain, "Показывать путь", true, function(v)
    btS.showPath = v
    if not v then btClearTracer() end
end, "BT_Path")

createCheckbox(btSecMain, "Авто-прыжок waypoints", true, function(v)
    btS.autoJump = v
end, "BT_AutoJump")

createCheckbox(btSecMain, "Debug в консоль", false, function(v)
    btS.debug = v
end, "BT_Debug")

--========== SPEED ==========
btSecSpeed = createSection(btLeft, "Скорость")

createSlider(btSecSpeed, "Базовая скорость", 8, 100, 28, function(v) btS.speed = v end)
createSlider(btSecSpeed, "Медленно", 4, 30, 14, function(v) btS.slowSpeed = v end)
createSlider(btSecSpeed, "Быстро", 16, 100, 36, function(v) btS.fastSpeed = v end)
createSlider(btSecSpeed, "Сила прыжка", 50, 200, 70, function(v)
    btS.jumpPower = v
    btNormalJump = v
end)

--========== BOOST ==========
btSecBoost = createSection(btLeft, "Boost")
createCheckbox(btSecBoost, "Включить Boost", true, function(v) btS.flightBoost = v end, "BT_Boost")
createSlider(btSecBoost, "Длительность x100", 5, 50, 20, function(v)
    btS.boostDuration = v / 100
end)

--========== HAZARD ==========
btSecHaz = createSection(btLeft, "Hazard")
createCheckbox(btSecHaz, "Избегать kill-блоков", true, function(v)
    btS.avoidKill = v
end, "BT_AvoidKill")

createSlider(btSecHaz, "Hazard R", 0, 255, 255, function(v)
    btS.hazardColor = Color3.fromRGB(
        v,
        math.floor(btS.hazardColor.G * 255),
        math.floor(btS.hazardColor.B * 255)
    )
end, true, "R")

createSlider(btSecHaz, "Hazard G", 0, 255, 0, function(v)
    btS.hazardColor = Color3.fromRGB(
        math.floor(btS.hazardColor.R * 255),
        v,
        math.floor(btS.hazardColor.B * 255)
    )
end, true, "G")

createSlider(btSecHaz, "Hazard B", 0, 255, 0, function(v)
    btS.hazardColor = Color3.fromRGB(
        math.floor(btS.hazardColor.R * 255),
        math.floor(btS.hazardColor.G * 255),
        v
    )
end, true, "B")

createSlider(btSecHaz, "Допуск цвета x100", 1, 30, 12, function(v)
    btS.colorTol = v / 100
end)

createSlider(btSecHaz, "Скан вперёд", 10, 50, 30, function(v)
    btS.scanDist = v
end)

createSlider(btSecHaz, "Макс. сила прыжка", 50, 400, 350, function(v)
    btS.maxJumpPower = v
end)

--========== PARKOUR ==========
btSecPark = createSection(btRight, "Паркур")
createCheckbox(btSecPark, "Режим паркура", true, function(v) btS.parkourMode = v end, "BT_Parkour")
createCheckbox(btSecPark, "Обнаружение стен", true, function(v) btS.wallCheck = v end, "BT_WallCheck")
createCheckbox(btSecPark, "Прыжок в стену", true, function(v) btS.wallJump = v end, "BT_WallJump")
createSlider(btSecPark, "Поиск края впереди", 3, 20, 10, function(v) btS.gapLookAhead = v end)
createSlider(btSecPark, "Макс. ширина пропасти", 5, 80, 40, function(v) btS.maxGapJump = v end)
createSlider(btSecPark, "Буфер прыжка", 1, 10, 3, function(v) btS.jumpMargin = v end)

--========== BRAIN ==========
btSecBrain = createSection(btRight, "Мозг AI")
createCheckbox(btSecBrain, "Умный мозг", true, function(v) btS.smartBrain = v end, "BT_Smart")
createCheckbox(btSecBrain, "Помнить провалы", true, function(v) btS.rememberFails = v end, "BT_Remember")
createCheckbox(btSecBrain, "Адаптивная скорость", true, function(v) btS.adaptiveSpeed = v end, "BT_AdaptSpeed")
createSlider(btSecBrain, "Точность симуляции", 5, 60, 20, function(v) btS.simSteps = v end)
createSlider(btSecBrain, "Радиус памяти", 2, 20, 8, function(v) btS.memRadius = v end)
createSlider(btSecBrain, "Время жизни памяти", 10, 300, 60, function(v) btS.memLifetime = v end)

--========== ADAPTIVE ==========
btSecAI = createSection(btRight, "Адаптив")
createCheckbox(btSecAI, "Авто-перестройка пути", true, function(v) btS.autoRepath = v end, "BT_Repath")
createCheckbox(btSecAI, "Реакция на новые объекты", true, function(v) btS.adaptivePath = v end, "BT_NewObj")
createSlider(btSecAI, "Радиус новых объектов", 10, 80, 30, function(v) btS.newObjRange = v end)
createSlider(btSecAI, "Задержка пересчёта x100", 10, 200, 50, function(v) btS.repathTime = v / 100 end)
createSlider(btSecAI, "Anti-stuck время x10", 3, 30, 10, function(v) btS.stuckTime = v / 10 end)
createSlider(btSecAI, "Backtrack после N стаков", 2, 10, 3, function(v) btS.backtrackAfter = v end)

--========== ACTIONS ==========
btSecActions = createSection(btRight, "Действия с биндами")
btMakeBindableButton(btSecActions, "Поставить точку", btPlacePoint, NL_BLUE, "BT_Point")
btMakeBindableButton(btSecActions, "Старт", btStart, NL_GREEN, "BT_Start")
btMakeBindableButton(btSecActions, "Стоп", btStop, NL_RED, "BT_Stop")
btMakeBindableButton(btSecActions, "Сбросить всё", btReset, NL_DIM, "BT_Reset")
btMakeBindableButton(btSecActions, "Очистить память", btClearMemory, NL_DIM, "BT_MemClear")

--=========================================================
-- UNLOAD
--=========================================================
_G.NL_UnloadBT = function()
    btS.running = false

    if btBrainConn then
        btBrainConn:Disconnect()
        btBrainConn = nil
    end
    if btSpeedConn then
        btSpeedConn:Disconnect()
        btSpeedConn = nil
    end
    if btWorldConn then
        btWorldConn:Disconnect()
        btWorldConn = nil
    end

    if btMarker and btMarker.Parent then btMarker:Destroy() end
    if btMemFolder and btMemFolder.Parent then btMemFolder:Destroy() end
    if btTracerFolder and btTracerFolder.Parent then btTracerFolder:Destroy() end
    btMarker, btMemFolder, btTracerFolder = nil, nil, nil

    for _, act in ipairs({"BT_Point", "BT_Start", "BT_Stop", "BT_Reset", "BT_MemClear"}) do
        BindCallbacks[act] = nil
    end

    if btContent and btContent.Parent then
        btContent:Destroy()
    end
end

print("[NL] 6/13 — Baritone загружен (FIX v3)")
--=========================================================
-- NEVERLOSE UI — 7/13 (FIX v3)
-- Экран загрузки с прогресс-баром + защита от зависания
-- ФИКСЫ:
--   • Корректный таймаут (проверка на unload, не крашится)
--   • Уборка bgBlur при unload
--   • Плавный финальный ресайз (без нулевой точки)
--   • Проверка на destroy перед каждым твином
--   • LoadingFrame сохраняется в _G для unload
--   • Работает на маленьких экранах (responsive)
--   • safeTween — обёртка, не падает если объект удалён
--=========================================================

if not _G.NeverloseUILoaded then
    warn("[NL] Часть 7: база не загружена")
    return
end

--=========================================================
-- СКРЫТЬ МЕНЮ И ВОДЯНОЙ ЗНАК НА ВРЕМЯ ЗАГРУЗКИ
--=========================================================
if MainFrame then MainFrame.Visible = false end
if WM then WM.Visible = false end

--=========================================================
-- ФЛАГИ
--=========================================================
_G.NL_LoadingActive = true
_G.NL_LoadingFrame = nil
_G.NL_LoadingBlur = nil

--=========================================================
-- ТАЙМАУТ (20 сек)
--=========================================================
task.delay(20, function()
    if not _G.NL_LoadingActive then return end
    if not _G.NeverloseUILoaded then return end
    warn("[NL] Loader timeout — принудительное закрытие")

    _G.NL_LoadingActive = false

    pcall(function()
        if _G.NL_LoadingFrame and _G.NL_LoadingFrame.Parent then
            _G.NL_LoadingFrame:Destroy()
        end
    end)
    pcall(function()
        if _G.NL_LoadingBlur and _G.NL_LoadingBlur.Parent then
            _G.NL_LoadingBlur:Destroy()
        end
    end)

    if WM then WM.Visible = true end

    if MainFrame and MainFrame.Parent then
        MainFrame.Visible = true
        local sz = getMenuSize()
        MainFrame.Size = UDim2.new(0, sz.w, 0, sz.h)
        MainFrame.Position = UDim2.new(0.5, -sz.w / 2, 0.5, -sz.h / 2)
    end
end)

--=========================================================
-- LOADING FRAME
--=========================================================
LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "NL_Loading"
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 500
LoadingFrame.Parent = ScreenGui
_G.NL_LoadingFrame = LoadingFrame

--=========================================================
-- BLUR
--=========================================================
bgBlur = Instance.new("BlurEffect")
bgBlur.Size = 0
bgBlur.Parent = Lighting
_G.NL_LoadingBlur = bgBlur

--=========================================================
-- RESPONSIVE LAYOUT
--=========================================================
local vp = (Cam and Cam.ViewportSize) or Vector2.new(1920, 1080)
local isSmall = vp.X < 900
local logoSize = isSmall and 80 or 110
local barWidth = math.min(400, vp.X - 60)

--=========================================================
-- LOGO
--=========================================================
BigLogo = Instance.new("TextLabel")
BigLogo.Size = UDim2.new(0, 400, 0, 150)
BigLogo.Position = UDim2.new(0.5, -200, 0.5, -140)
BigLogo.BackgroundTransparency = 1
BigLogo.Text = "NL"
BigLogo.TextColor3 = NL_BLUE
BigLogo.Font = Enum.Font.GothamBlack
BigLogo.TextSize = logoSize
BigLogo.TextTransparency = 1
BigLogo.ZIndex = 501
BigLogo.Parent = LoadingFrame
registerAccent(BigLogo, "TextColor3")

BrandLabel = Instance.new("TextLabel")
BrandLabel.Size = UDim2.new(0, 400, 0, 30)
BrandLabel.Position = UDim2.new(0.5, -200, 0.5, 10)
BrandLabel.BackgroundTransparency = 1
BrandLabel.Text = "n e v e r l o s e"
BrandLabel.TextColor3 = NL_TEXT
BrandLabel.Font = Enum.Font.Gotham
BrandLabel.TextSize = 16
BrandLabel.TextTransparency = 1
BrandLabel.ZIndex = 501
BrandLabel.Parent = LoadingFrame

--=========================================================
-- PROGRESS BAR
--=========================================================
ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(0, barWidth, 0, 4)
ProgressBg.Position = UDim2.new(0.5, -barWidth / 2, 0.5, 60)
ProgressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ProgressBg.BorderSizePixel = 0
ProgressBg.BackgroundTransparency = 1
ProgressBg.ZIndex = 501
ProgressBg.Parent = LoadingFrame

local PBC = Instance.new("UICorner")
PBC.CornerRadius = UDim.new(1, 0)
PBC.Parent = ProgressBg

ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = NL_BLUE
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 502
ProgressFill.Parent = ProgressBg
registerAccent(ProgressFill, "BackgroundColor3")

local PFC = Instance.new("UICorner")
PFC.CornerRadius = UDim.new(1, 0)
PFC.Parent = ProgressFill

--=========================================================
-- PERCENT
--=========================================================
PercentLabel = Instance.new("TextLabel")
PercentLabel.Size = UDim2.new(0, 100, 0, 20)
PercentLabel.Position = UDim2.new(0.5, -50, 0.5, 75)
PercentLabel.BackgroundTransparency = 1
PercentLabel.Text = "0%"
PercentLabel.TextColor3 = NL_BLUE
PercentLabel.Font = Enum.Font.GothamBold
PercentLabel.TextSize = 14
PercentLabel.TextTransparency = 1
PercentLabel.ZIndex = 501
PercentLabel.Parent = LoadingFrame
registerAccent(PercentLabel, "TextColor3")

--=========================================================
-- STATUS
--=========================================================
StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, barWidth + 40, 0, 20)
StatusLabel.Position = UDim2.new(0.5, -(barWidth + 40) / 2, 0.5, 100)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Инициализация..."
StatusLabel.TextColor3 = NL_DIM
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
StatusLabel.TextTransparency = 1
StatusLabel.ZIndex = 501
StatusLabel.Parent = LoadingFrame

--=========================================================
-- VERSION
--=========================================================
VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 200, 0, 20)
VersionLabel.Position = UDim2.new(1, -210, 1, -30)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = Cfg.Version
VersionLabel.TextColor3 = NL_DIM
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.TextSize = 11
VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
VersionLabel.TextTransparency = 1
VersionLabel.ZIndex = 501
VersionLabel.Parent = LoadingFrame

--=========================================================
-- BOTTOM LINE
--=========================================================
BottomLine = Instance.new("Frame")
BottomLine.Size = UDim2.new(1, 0, 0, 2)
BottomLine.Position = UDim2.new(0, 0, 1, -2)
BottomLine.BackgroundColor3 = NL_BLUE
BottomLine.BorderSizePixel = 0
BottomLine.BackgroundTransparency = 1
BottomLine.ZIndex = 501
BottomLine.Parent = LoadingFrame
registerAccent(BottomLine, "BackgroundColor3")

--=========================================================
-- SAFE TWEEN
--=========================================================
local function safeTween(obj, t, props, style, dir)
    if not obj or not obj.Parent then return end
    local info = TweenInfo.new(
        t or 0.4,
        style or Enum.EasingStyle.Quad,
        dir or Enum.EasingDirection.Out
    )
    local ok = pcall(function()
        local tw = TweenService:Create(obj, info, props)
        tw:Play()
    end)
    return ok
end

--=========================================================
-- ANIMATION
--=========================================================
task.spawn(function()
    if not _G.NeverloseUILoaded then return end

    -- Fade in
    safeTween(bgBlur, 0.6, {Size = 25})
    task.wait(0.2)
    if not _G.NeverloseUILoaded then return end

    safeTween(BigLogo, 0.5, {TextTransparency = 0})
    safeTween(BrandLabel, 0.5, {TextTransparency = 0})
    safeTween(ProgressBg, 0.5, {BackgroundTransparency = 0})
    safeTween(PercentLabel, 0.5, {TextTransparency = 0})
    safeTween(StatusLabel, 0.5, {TextTransparency = 0})
    safeTween(VersionLabel, 0.5, {TextTransparency = 0})
    safeTween(BottomLine, 0.5, {BackgroundTransparency = 0})

    task.wait(0.4)
    if not _G.NeverloseUILoaded then return end

    -- Стадии загрузки
    local stages = {
        {p = 15,  t = "Загрузка модулей..."},
        {p = 35,  t = "Подключение к API..."},
        {p = 55,  t = "Инициализация функций..."},
        {p = 75,  t = "Проверка обновлений..."},
        {p = 90,  t = "Финальная настройка..."},
        {p = 100, t = "Готово!"},
    }

    local cp = 0
    for _, s in ipairs(stages) do
        if not _G.NeverloseUILoaded then return end

        local sp, ep = cp, s.p
        for i = 1, 20 do
            if not _G.NeverloseUILoaded then return end
            local a = i / 20
            local p = sp + (ep - sp) * a

            if ProgressFill and ProgressFill.Parent then
                ProgressFill.Size = UDim2.new(p / 100, 0, 1, 0)
            end
            if PercentLabel and PercentLabel.Parent then
                PercentLabel.Text = math.floor(p) .. "%"
            end
            task.wait(0.02)
        end

        cp = ep
        if StatusLabel and StatusLabel.Parent then
            StatusLabel.Text = s.t
        end
        task.wait(0.1)
    end

    task.wait(0.5)
    if not _G.NeverloseUILoaded then return end

    if StatusLabel and StatusLabel.Parent then
        StatusLabel.Text = "Добро пожаловать"
    end

    task.wait(0.4)
    if not _G.NeverloseUILoaded then return end

    -- Fade out
    safeTween(LoadingFrame, 0.5, {BackgroundTransparency = 1})
    safeTween(BigLogo, 0.4, {TextTransparency = 1})
    safeTween(BrandLabel, 0.4, {TextTransparency = 1})
    safeTween(ProgressBg, 0.4, {BackgroundTransparency = 1})
    safeTween(ProgressFill, 0.4, {BackgroundTransparency = 1})
    safeTween(PercentLabel, 0.4, {TextTransparency = 1})
    safeTween(StatusLabel, 0.4, {TextTransparency = 1})
    safeTween(VersionLabel, 0.4, {TextTransparency = 1})
    safeTween(BottomLine, 0.4, {BackgroundTransparency = 1})
    safeTween(bgBlur, 0.5, {Size = 0})

    task.wait(0.6)
    if not _G.NeverloseUILoaded then return end

    -- Уборка
    _G.NL_LoadingActive = false

    if LoadingFrame and LoadingFrame.Parent then LoadingFrame:Destroy() end
    if bgBlur and bgBlur.Parent then bgBlur:Destroy() end
    _G.NL_LoadingFrame = nil
    _G.NL_LoadingBlur = nil

    if WM then WM.Visible = true end

    if MainFrame and MainFrame.Parent then
        local sz = getMenuSize()
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, sz.w * 0.9, 0, sz.h * 0.9)
        MainFrame.Position = UDim2.new(0.5, -(sz.w * 0.9) / 2, 0.5, -(sz.h * 0.9) / 2)

        tween(MainFrame, 0.4, {
            Size = UDim2.new(0, sz.w, 0, sz.h),
            Position = UDim2.new(0.5, -sz.w / 2, 0.5, -sz.h / 2),
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

--=========================================================
-- UNLOAD HOOK
--=========================================================
local _prevUnload7 = _G.NL_UnloadBase
_G.NL_UnloadBase = function()
    _G.NL_LoadingActive = false

    if _G.NL_LoadingFrame and _G.NL_LoadingFrame.Parent then
        pcall(function() _G.NL_LoadingFrame:Destroy() end)
    end
    if _G.NL_LoadingBlur and _G.NL_LoadingBlur.Parent then
        pcall(function() _G.NL_LoadingBlur:Destroy() end)
    end
    _G.NL_LoadingFrame = nil
    _G.NL_LoadingBlur = nil

    if _prevUnload7 then _prevUnload7() end
end

print("[NL] 7/13 — Loading screen загружен (FIX v3)")
--=========================================================
-- NEVERLOSE UI — 8/13 (FIX v3)
-- Система уведомлений (notifications)
-- ФИКСЫ:
--   • Пул потоков вместо task.delay на каждое уведомление
--   • Плавное удаление без "рывков" при переполнении
--   • Уведомления не пропадают при быстром спаме
--   • Правильное позиционирование с UIListLayout
--   • Unload чистит все уведомления
--   • Кэш цветов
--   • При переполнении — старые удаляются корректно
--=========================================================

if not _G.NeverloseUILoaded then
    warn("[NL] Часть 8: база не загружена")
    return
end

--=========================================================
-- CONTAINER
--=========================================================
notifyContainer = Instance.new("Frame")
notifyContainer.Name = "NL_NotifyContainer"
notifyContainer.Size = UDim2.new(0, 320, 0, 400)
notifyContainer.Position = UDim2.new(1, -340, 0, 60)
notifyContainer.BackgroundTransparency = 1
notifyContainer.ZIndex = 300
notifyContainer.Parent = ScreenGui

local notifyLayout = Instance.new("UIListLayout")
notifyLayout.Padding = UDim.new(0, 6)
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.Parent = notifyContainer

notifyCount = 0
MAX_NOTIFIES = 5

--=========================================================
-- АКТИВНЫЕ УВЕДОМЛЕНИЯ
--=========================================================
notifyActive = {}  -- [noteFrame] = {created = tick(), duration = N}

--=========================================================
-- DISMISS
--=========================================================
local function dismissNote(note, animate)
    if not note or not note.Parent then
        notifyActive[note] = nil
        return
    end
    if not notifyActive[note] then return end
    notifyActive[note] = nil

    if not animate then
        if note.Parent then note:Destroy() end
        return
    end

    -- Слайд вправо
    pcall(function()
        tween(note, 0.3, {
            Position = UDim2.new(1, 100, 0, 0),
            BackgroundTransparency = 1,
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    end)

    -- Fade-out всех детей
    for _, c in ipairs(note:GetDescendants()) do
        if c:IsA("TextLabel") then
            pcall(function() tween(c, 0.3, {TextTransparency = 1}) end)
        elseif c:IsA("Frame") then
            pcall(function() tween(c, 0.3, {BackgroundTransparency = 1}) end)
        elseif c:IsA("UIStroke") then
            pcall(function() tween(c, 0.3, {Transparency = 1}) end)
        end
    end

    task.delay(0.4, function()
        if note and note.Parent then note:Destroy() end
    end)
end

--=========================================================
-- СПИСОК АКТИВНЫХ (сорт по времени)
--=========================================================
local function getActiveList()
    local list = {}
    for note, _ in pairs(notifyActive) do
        if note and note.Parent then
            table.insert(list, note)
        else
            notifyActive[note] = nil
        end
    end
    table.sort(list, function(a, b)
        return (a:GetAttribute("Time") or 0) < (b:GetAttribute("Time") or 0)
    end)
    return list
end

--=========================================================
-- SHOW NOTIFICATION
--=========================================================
function showNotification(text, color, duration)
    if not _G.NeverloseUILoaded then return end
    if not notifyContainer or not notifyContainer.Parent then return end
    if not text or text == "" then return end

    color = color or NL_BLUE
    duration = duration or 3

    -- Ограничение: если > MAX — удаляем самые старые
    local activeList = getActiveList()
    while #activeList >= MAX_NOTIFIES do
        local oldest = table.remove(activeList, 1)
        if oldest then dismissNote(oldest, true) end
    end

    notifyCount = notifyCount + 1
    local myId = notifyCount

    -- Основной фрейм
    local note = Instance.new("Frame")
    note.Name = "NL_Note_" .. myId
    note.Size = UDim2.new(1, 0, 0, 34)
    note.BackgroundColor3 = NL_DARKER
    note.BackgroundTransparency = 0.1
    note.BorderSizePixel = 0
    note.ZIndex = 301
    note.LayoutOrder = myId
    note.Parent = notifyContainer
    note:SetAttribute("Time", tick())

    local noteCorner = Instance.new("UICorner")
    noteCorner.CornerRadius = UDim.new(0, 6)
    noteCorner.Parent = note

    local noteStroke = Instance.new("UIStroke")
    noteStroke.Color = color
    noteStroke.Thickness = 1
    noteStroke.Transparency = 0.3
    noteStroke.Parent = note

    -- Цветная полоска слева
    local colorBar = Instance.new("Frame")
    colorBar.Size = UDim2.new(0, 3, 1, 0)
    colorBar.BackgroundColor3 = color
    colorBar.BorderSizePixel = 0
    colorBar.ZIndex = 302
    colorBar.Parent = note

    local cbc = Instance.new("UICorner")
    cbc.CornerRadius = UDim.new(1, 0)
    cbc.Parent = colorBar

    -- Текст
    local noteText = Instance.new("TextLabel")
    noteText.Size = UDim2.new(1, -20, 1, 0)
    noteText.Position = UDim2.new(0, 14, 0, 0)
    noteText.BackgroundTransparency = 1
    noteText.Text = tostring(text)
    noteText.TextColor3 = NL_TEXT
    noteText.Font = Enum.Font.GothamBold
    noteText.TextSize = 12
    noteText.TextXAlignment = Enum.TextXAlignment.Left
    noteText.TextTruncate = Enum.TextTruncate.AtEnd
    noteText.ZIndex = 302
    noteText.Parent = note

    notifyActive[note] = {created = tick(), duration = duration}

    -- Появление (слайд справа)
    note.Position = UDim2.new(1, 50, 0, 0)
    tween(note, 0.3,
        {Position = UDim2.new(0, 0, 0, 0)},
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    )

    -- Авто-удаление
    task.delay(duration, function()
        if notifyActive[note] then
            dismissNote(note, true)
        end
    end)
end

_G.NL_Notify = showNotification

--=========================================================
-- HELPERS
--=========================================================
function NL_NotifyOK(text)   showNotification(text, NL_GREEN, 2)   end
function NL_NotifyErr(text)  showNotification(text, NL_RED, 3)     end
function NL_NotifyInfo(text) showNotification(text, NL_BLUE, 2.5)  end
function NL_NotifyWarn(text) showNotification(text, NL_YELLOW, 3)  end

_G.NL_NotifyOK   = NL_NotifyOK
_G.NL_NotifyErr  = NL_NotifyErr
_G.NL_NotifyInfo = NL_NotifyInfo
_G.NL_NotifyWarn = NL_NotifyWarn

--=========================================================
-- WELCOME (через 8 сек, чтобы лоадер успел закрыться)
--=========================================================
task.spawn(function()
    task.wait(8)
    if not _G.NeverloseUILoaded then return end
    if _G.NL_Notify then
        _G.NL_Notify("Neverlose загружен! INSERT — меню", NL_BLUE, 3)
    end
end)

--=========================================================
-- UNLOAD HOOK
--=========================================================
local _prevUnload8 = _G.NL_UnloadBase
_G.NL_UnloadBase = function()
    for note, _ in pairs(notifyActive) do
        if note and note.Parent then
            pcall(function() note:Destroy() end)
        end
    end
    notifyActive = {}

    if notifyContainer and notifyContainer.Parent then
        pcall(function() notifyContainer:Destroy() end)
    end

    if _prevUnload8 then _prevUnload8() end
end

print("[NL] 8/13 — Уведомления загружены (FIX v3)")
--=========================================================
-- NEVERLOSE UI — 9/13 (FIX v3)
-- HP-индикатор (левый нижний угол, draggable)
-- ФИКСЫ:
--   • Один Heartbeat loop вместо task.spawn + task.wait
--   • Throttle 10 Hz — не бьёт по FPS
--   • Кеш цвета — не твиним каждый кадр
--   • Правильная инициализация при первом заходе
--   • Ограничение drag'а по границам экрана
--   • Unload корректный
--   • Отслеживание MaxHealth изменений
--   • Обработка смерти (DEAD) и респавна
--=========================================================

if not _G.NeverloseUILoaded then
    warn("[NL] Часть 9: база не загружена")
    return
end

--=========================================================
-- HP FRAME
--=========================================================
HPFrame = Instance.new("Frame")
HPFrame.Name = "NL_HP"
HPFrame.Size = UDim2.new(0, 200, 0, 90)
HPFrame.AnchorPoint = Vector2.new(0, 1)
HPFrame.Position = UDim2.new(0, 15, 1, -15)
HPFrame.BackgroundColor3 = NL_DARKER
HPFrame.BackgroundTransparency = 0.15
HPFrame.BorderSizePixel = 0
HPFrame.ZIndex = 200
HPFrame.Active = true
HPFrame.Parent = ScreenGui

local HPFrameCorner = Instance.new("UICorner")
HPFrameCorner.CornerRadius = UDim.new(0, 8)
HPFrameCorner.Parent = HPFrame

local HPFrameStroke = Instance.new("UIStroke")
HPFrameStroke.Color = NL_GREEN
HPFrameStroke.Thickness = 1
HPFrameStroke.Transparency = 0.3
HPFrameStroke.Parent = HPFrame

--=========================================================
-- TITLE
--=========================================================
HPTitle = Instance.new("TextLabel")
HPTitle.Size = UDim2.new(1, -20, 0, 18)
HPTitle.Position = UDim2.new(0, 10, 0, 6)
HPTitle.BackgroundTransparency = 1
HPTitle.Text = "HEALTH"
HPTitle.TextColor3 = NL_DIM
HPTitle.Font = Enum.Font.GothamBold
HPTitle.TextSize = 11
HPTitle.TextXAlignment = Enum.TextXAlignment.Left
HPTitle.ZIndex = 201
HPTitle.Parent = HPFrame

--=========================================================
-- PERCENT
--=========================================================
HPPercentLabel = Instance.new("TextLabel")
HPPercentLabel.Size = UDim2.new(0.5, -10, 0, 34)
HPPercentLabel.Position = UDim2.new(0, 10, 0, 24)
HPPercentLabel.BackgroundTransparency = 1
HPPercentLabel.Text = "100%"
HPPercentLabel.TextColor3 = NL_GREEN
HPPercentLabel.Font = Enum.Font.GothamBlack
HPPercentLabel.TextSize = 28
HPPercentLabel.TextXAlignment = Enum.TextXAlignment.Left
HPPercentLabel.ZIndex = 201
HPPercentLabel.Parent = HPFrame

--=========================================================
-- NUMBERS
--=========================================================
HPNumbersLabel = Instance.new("TextLabel")
HPNumbersLabel.Size = UDim2.new(0.5, -10, 0, 20)
HPNumbersLabel.Position = UDim2.new(0.5, 0, 0, 38)
HPNumbersLabel.BackgroundTransparency = 1
HPNumbersLabel.Text = "100 / 100"
HPNumbersLabel.TextColor3 = NL_DIM
HPNumbersLabel.Font = Enum.Font.GothamBold
HPNumbersLabel.TextSize = 13
HPNumbersLabel.TextXAlignment = Enum.TextXAlignment.Right
HPNumbersLabel.ZIndex = 201
HPNumbersLabel.Parent = HPFrame

--=========================================================
-- BAR BG
--=========================================================
HPBarBg = Instance.new("Frame")
HPBarBg.Size = UDim2.new(1, -20, 0, 6)
HPBarBg.Position = UDim2.new(0, 10, 1, -16)
HPBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
HPBarBg.BorderSizePixel = 0
HPBarBg.ZIndex = 201
HPBarBg.Parent = HPFrame

local HPBarBgCorner = Instance.new("UICorner")
HPBarBgCorner.CornerRadius = UDim.new(1, 0)
HPBarBgCorner.Parent = HPBarBg

--=========================================================
-- BAR FILL
--=========================================================
HPBarFill = Instance.new("Frame")
HPBarFill.Size = UDim2.new(1, 0, 1, 0)
HPBarFill.BackgroundColor3 = NL_GREEN
HPBarFill.BorderSizePixel = 0
HPBarFill.ZIndex = 202
HPBarFill.Parent = HPBarBg

local HPBarFillCorner = Instance.new("UICorner")
HPBarFillCorner.CornerRadius = UDim.new(1, 0)
HPBarFillCorner.Parent = HPBarFill

--=========================================================
-- DRAG
--=========================================================
local hpDrag = false
local hpStartMouse, hpStartPos

HPFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        hpDrag = true
        hpStartMouse = Vector2.new(input.Position.X, input.Position.Y)
        hpStartPos = HPFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not hpDrag then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    if not HPFrame or not HPFrame.Parent then hpDrag = false return end

    local delta = Vector2.new(input.Position.X, input.Position.Y) - hpStartMouse
    local vp = (Cam and Cam.ViewportSize) or Vector2.new(1920, 1080)
    local ws = HPFrame.AbsoluteSize

    local newX = hpStartPos.X.Offset + delta.X
    local newY = hpStartPos.Y.Offset + delta.Y

    -- AnchorPoint (0, 1) — низ левый, Y = координата низа
    newX = math.clamp(newX, 0, math.max(0, vp.X - ws.X))
    newY = math.clamp(newY, 0, math.max(0, vp.Y))

    HPFrame.Position = UDim2.new(
        hpStartPos.X.Scale, newX,
        hpStartPos.Y.Scale, newY
    )
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        hpDrag = false
    end
end)

--=========================================================
-- UPDATE HELPERS
--=========================================================
local lastHpPercent = -999
local lastHpValue = -999
local lastHpMax = -999
local lastState = "ok"  -- "ok" | "dead"

local function pickColor(percent)
    if percent > 60 then return NL_GREEN
    elseif percent > 30 then return NL_YELLOW
    else return NL_RED end
end

local function applyHP(hp, maxHp)
    local percent = math.floor((hp / math.max(maxHp, 1)) * 100)
    percent = math.clamp(percent, 0, 100)
    local color = pickColor(percent)

    if HPPercentLabel and HPPercentLabel.Parent then
        HPPercentLabel.Text = percent .. "%"
        if HPPercentLabel.TextColor3 ~= color then
            HPPercentLabel.TextColor3 = color
        end
    end

    if HPNumbersLabel and HPNumbersLabel.Parent then
        HPNumbersLabel.Text = math.floor(hp) .. " / " .. math.floor(maxHp)
    end

    if HPBarFill and HPBarFill.Parent then
        HPBarFill.Size = UDim2.new(percent / 100, 0, 1, 0)
        if HPBarFill.BackgroundColor3 ~= color then
            HPBarFill.BackgroundColor3 = color
        end
    end

    if HPFrameStroke and HPFrameStroke.Parent then
        if HPFrameStroke.Color ~= color then
            HPFrameStroke.Color = color
        end
    end
end

local function applyDead()
    if HPPercentLabel and HPPercentLabel.Parent then
        HPPercentLabel.Text = "DEAD"
        HPPercentLabel.TextColor3 = NL_RED
    end
    if HPNumbersLabel and HPNumbersLabel.Parent then
        HPNumbersLabel.Text = "0 / 0"
    end
    if HPBarFill and HPBarFill.Parent then
        HPBarFill.Size = UDim2.new(0, 0, 1, 0)
        HPBarFill.BackgroundColor3 = NL_RED
    end
    if HPFrameStroke and HPFrameStroke.Parent then
        HPFrameStroke.Color = NL_RED
    end
end

--=========================================================
-- UPDATE LOOP (throttle 10 Hz)
--=========================================================
HPUpdateConn = RunService.Heartbeat:Connect(function()
    if not _G.NeverloseUILoaded then return end
    if not HPFrame or not HPFrame.Parent then return end

    -- Throttle 10 Hz
    local now = tick()
    if not _G.NL_HPNext or now < _G.NL_HPNext then return end
    _G.NL_HPNext = now + 0.1

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        local hp = hum.Health
        local maxHp = hum.MaxHealth
        local percent = math.floor((hp / math.max(maxHp, 1)) * 100)
        percent = math.clamp(percent, 0, 100)

        local hpFloored = math.floor(hp)
        local maxFloored = math.floor(maxHp)

        if lastState ~= "ok"
            or percent ~= lastHpPercent
            or hpFloored ~= lastHpValue
            or maxFloored ~= lastHpMax then

            lastState = "ok"
            lastHpPercent = percent
            lastHpValue = hpFloored
            lastHpMax = maxFloored
            applyHP(hp, maxHp)
        end
    else
        if lastState ~= "dead" then
            lastState = "dead"
            lastHpPercent = -1
            applyDead()
        end
    end
end)

--=========================================================
-- RESPAWN
--=========================================================
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if not _G.NeverloseUILoaded then return end

    lastState = "ok"
    lastHpPercent = 100
    lastHpValue = 100
    lastHpMax = 100

    if HPPercentLabel and HPPercentLabel.Parent then
        HPPercentLabel.Text = "100%"
        HPPercentLabel.TextColor3 = NL_GREEN
    end
    if HPNumbersLabel and HPNumbersLabel.Parent then
        HPNumbersLabel.Text = "100 / 100"
    end
    if HPBarFill and HPBarFill.Parent then
        HPBarFill.Size = UDim2.new(1, 0, 1, 0)
        HPBarFill.BackgroundColor3 = NL_GREEN
    end
    if HPFrameStroke and HPFrameStroke.Parent then
        HPFrameStroke.Color = NL_GREEN
    end
end)

--=========================================================
-- RESET POSITION
--=========================================================
function NL_ResetHPPosition()
    if HPFrame and HPFrame.Parent then
        HPFrame.AnchorPoint = Vector2.new(0, 1)
        HPFrame.Position = UDim2.new(0, 15, 1, -15)
    end
end

_G.NL_ResetHPPosition = NL_ResetHPPosition

--=========================================================
-- UNLOAD HOOK
--=========================================================
local _prevUnload9 = _G.NL_UnloadBase
_G.NL_UnloadBase = function()
    if HPUpdateConn then
        HPUpdateConn:Disconnect()
        HPUpdateConn = nil
    end

    if HPFrame and HPFrame.Parent then
        HPFrame:Destroy()
    end

    _G.NL_HPNext = nil

    if _prevUnload9 then _prevUnload9() end
end

print("[NL] 9/13 — HP indicator загружен (FIX v3)")
--=========================================================
-- NEVERLOSE UI — 10/13 (FIX v3)
-- Защита: Anti-Fling, Anti-Knockback, Anti-Ragdoll
-- ФИКСЫ:
--   • Не конфликтует со SpeedSystem.Matrix / Fly / Spider
--   • Anchored только когда это безопасно
--   • Возврат NetworkOwner если кто-то его забрал
--   • Единая петля вместо 3-х (меньше нагрузка)
--   • Кеш humanoid state — быстрее
--   • Unload чистит ownership loop
--   • Не удаляет чужие NL_ объекты (Fly / Spider / Boost)
--   • Token-система для antiHold — race-condition невозможен
--=========================================================

if not _G.NeverloseUILoaded then
    warn("[NL] Часть 10: база не загружена")
    return
end

--=========================================================
-- НАСТРОЙКИ
--=========================================================
antiCfg = {
    maxVelocity      = 120,   -- порог линейной скорости
    maxAngular       = 60,    -- порог угловой скорости
    maxTeleport      = 25,    -- макс. скачок позиции за кадр
    holdTime         = 0.35,  -- сколько держать anchored
    checkSelfMovers  = true,  -- удалять чужие BodyMover
    restoreOwnership = true,  -- возвращать NetworkOwner
    ragdollFix       = true,  -- вытаскивать из ragdoll
}

--=========================================================
-- СОСТОЯНИЕ
--=========================================================
antiSelf = {
    anchoredToken = 0,
    isAnchored    = false,
    lastPos       = nil,
    lastVel       = nil,
    lastTick      = 0,
}

--=========================================================
-- БАЗОВЫЕ ХЕЛПЕРЫ
--=========================================================
function antiGetHRP()
    local char = LP.Character
    if not char then return nil, nil end
    return char, char:FindFirstChild("HumanoidRootPart")
end

function antiGetHum()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

function antiKillMovers(hrp, aggressive)
    if not hrp then return end

    for _, obj in ipairs(hrp:GetChildren()) do
        local kill = false
        if obj:IsA("BodyVelocity")
            or obj:IsA("BodyAngularVelocity")
            or obj:IsA("BodyForce")
            or obj:IsA("BodyThrust")
            or obj:IsA("BodyGyro")
            or obj:IsA("LinearVelocity")
            or obj:IsA("AngularVelocity")
            or obj:IsA("VectorForce")
            or obj:IsA("Torque")
            or obj:IsA("AlignOrientation")
            or obj:IsA("AlignPosition") then
            kill = true
        end
        if kill then
            -- ✅ Не трогаем наши NL_-объекты (Fly, Spider, Boost)
            if not string.find(obj.Name, "NL_") then
                pcall(function() obj:Destroy() end)
            end
        end
    end

    if aggressive then
        local char = LP.Character
        if char then
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BodyVelocity")
                    or obj:IsA("LinearVelocity")
                    or obj:IsA("VectorForce")
                    or obj:IsA("BodyAngularVelocity")
                    or obj:IsA("AngularVelocity") then
                    if not string.find(obj.Name, "NL_") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end
        end
    end
end

--=========================================================
-- ЖЁСТКАЯ ФИКСАЦИЯ
--=========================================================
function antiHold(hrp, duration)
    if not hrp then return end
    duration = duration or antiCfg.holdTime

    antiSelf.anchoredToken = antiSelf.anchoredToken + 1
    local myToken = antiSelf.anchoredToken
    antiSelf.isAnchored = true

    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.Anchored = true
    end)

    task.delay(duration, function()
        if antiSelf.anchoredToken ~= myToken then return end
        if hrp and hrp.Parent then
            pcall(function()
                hrp.Anchored = false
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end
        antiSelf.isAnchored = false
    end)
end

function antiForceStop(hrp)
    if not hrp then return end
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

--=========================================================
-- ПРОВЕРКА "МОЖНО ЛИ АНКОРИТЬ"
-- Не мешаем Fly / Spider / Speed-Matrix / Boost
--=========================================================
function antiCanAnchor()
    if Cheat.Fly and flyBV and flyBV.Parent then return false end
    if spiderBV and spiderBV.Parent then return false end
    if SpeedSystem and SpeedSystem.Enabled and SpeedSystem.Mode == "Matrix" then
        return false
    end
    return true
end

--=========================================================
-- UNIFIED PROTECTION LOOP
--=========================================================
antiMainConn = nil

function antiStartMain()
    if antiMainConn then antiMainConn:Disconnect() end

    antiSelf.lastPos = nil
    antiSelf.lastVel = nil
    antiSelf.lastTick = tick()

    antiMainConn = RunService.Heartbeat:Connect(function()
        if not _G.NeverloseUILoaded then return end

        local need = Cheat.AntiFling or Cheat.AntiKnockback or Cheat.AntiRagdoll
        if not need then return end

        local char, hrp = antiGetHRP()
        if not char or not hrp then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local canAnchor = antiCanAnchor()

        -- ============================
        -- ANTI-FLING
        -- ============================
        if Cheat.AntiFling and not antiSelf.isAnchored then
            local vel = hrp.AssemblyLinearVelocity
            local ang = hrp.AssemblyAngularVelocity
            local pos = hrp.Position
            local now = tick()
            local dt  = now - antiSelf.lastTick

            local triggered = false

            -- 1) огромная линейная скорость
            if vel.Magnitude > antiCfg.maxVelocity then
                triggered = true
            end

            -- 2) огромная угловая скорость
            if ang.Magnitude > antiCfg.maxAngular then
                triggered = true
            end

            -- 3) резкий скачок позиции
            if antiSelf.lastPos and dt > 0 and dt < 0.25 then
                local dist = (pos - antiSelf.lastPos).Magnitude
                if dist > antiCfg.maxTeleport then
                    triggered = true
                end
            end

            -- 4) NaN/inf защита
            if vel.X ~= vel.X or vel.Y ~= vel.Y or vel.Z ~= vel.Z then
                triggered = true
            end

            if triggered then
                antiKillMovers(hrp, true)
                antiForceStop(hrp)
                if canAnchor then
                    antiHold(hrp, antiCfg.holdTime)
                end
                antiSelf.lastPos = pos
                antiSelf.lastTick = now
                return
            end

            antiSelf.lastPos = pos
            antiSelf.lastTick = now

            -- Постоянная чистка чужих mover'ов
            if antiCfg.checkSelfMovers then
                antiKillMovers(hrp, false)
            end
        end

        -- ============================
        -- ANTI-KNOCKBACK
        -- ============================
        if Cheat.AntiKnockback and not antiSelf.isAnchored then
            local vel = hrp.AssemblyLinearVelocity

            if antiSelf.lastVel then
                local dv = (vel - antiSelf.lastVel).Magnitude
                if dv > antiCfg.maxVelocity * 0.75 then
                    antiKillMovers(hrp, true)
                    antiForceStop(hrp)
                    if canAnchor then
                        antiHold(hrp, 0.2)
                    end
                else
                    antiSelf.lastVel = vel
                end
            else
                antiSelf.lastVel = vel
            end
        end

        -- ============================
        -- ANTI-RAGDOLL
        -- ============================
        if Cheat.AntiRagdoll then
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Physics
                or st == Enum.HumanoidStateType.FallingDown
                or st == Enum.HumanoidStateType.Ragdoll then
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end)
            end

            if hum.PlatformStand then
                hum.PlatformStand = false
            end

            if hum.WalkSpeed < 8 then
                hum.WalkSpeed = (Cheat.Speed and SpeedSystem.Value) or 16
            end
            if hum.UseJumpPower and hum.JumpPower < 30 then
                hum.JumpPower = (Cheat.Jump and Cheat.JumpPower) or 50
            end

            -- Отключаем constraint'ы ragdoll
            if antiCfg.ragdollFix then
                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("BallSocketConstraint")
                        or obj:IsA("HingeConstraint")
                        or obj:IsA("RopeConstraint") then
                        if obj.Enabled then
                            pcall(function() obj.Enabled = false end)
                        end
                    end
                end
            end
        end
    end)
end

function antiStopMain()
    if antiMainConn then
        antiMainConn:Disconnect()
        antiMainConn = nil
    end
    antiSelf.lastPos = nil
    antiSelf.lastVel = nil
    antiSelf.anchoredToken = antiSelf.anchoredToken + 1
    antiSelf.isAnchored = false

    -- отпускаем, если остались anchored
    local _, hrp = antiGetHRP()
    if hrp then
        pcall(function() hrp.Anchored = false end)
    end
end

--=========================================================
-- ОБЁРТКИ (совместимость с частью 3)
--=========================================================
function enableAntiFling()      antiStartMain() end
function disableAntiFling()
    if not (Cheat.AntiKnockback or Cheat.AntiRagdoll) then antiStopMain() end
end

function enableAntiKnockback()  antiStartMain() end
function disableAntiKnockback()
    if not (Cheat.AntiFling or Cheat.AntiRagdoll) then antiStopMain() end
end

function enableAntiRagdoll()    antiStartMain() end
function disableAntiRagdoll()
    if not (Cheat.AntiFling or Cheat.AntiKnockback) then antiStopMain() end
end

--=========================================================
-- NETWORK OWNERSHIP LOOP
--=========================================================
antiOwnershipConn = nil

task.spawn(function()
    task.wait(1)
    if not _G.NeverloseUILoaded then return end
    if antiOwnershipConn then antiOwnershipConn:Disconnect() end

    antiOwnershipConn = RunService.Heartbeat:Connect(function()
        if not _G.NeverloseUILoaded then return end
        if not antiCfg.restoreOwnership then return end
        if not (Cheat.AntiFling or Cheat.AntiKnockback) then return end

        local _, hrp = antiGetHRP()
        if not hrp then return end
        pcall(function()
            if hrp:GetNetworkOwner() ~= LP then
                hrp:SetNetworkOwner(LP)
            end
        end)
    end)
end)

--=========================================================
-- RESPAWN HOOK
--=========================================================
LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    if not _G.NeverloseUILoaded then return end
    if Cheat.AntiFling or Cheat.AntiKnockback or Cheat.AntiRagdoll then
        antiStartMain()
    end
end)

--=========================================================
-- UNLOAD HOOK
--=========================================================
_G.NL_UnloadProtect = function()
    antiStopMain()
    if antiOwnershipConn then
        antiOwnershipConn:Disconnect()
        antiOwnershipConn = nil
    end
end

print("[NL] 10/13 — Protection загружен (FIX v3)")
--=========================================================
-- NEVERLOSE UI — 11/13 (FIX v3)
-- Вкладки HUD и Config
-- ФИКСЫ:
--   • Config save/load корректно работает со SpeedSystem
--   • Сохраняет бинды Baritone / CTP / Speed / Fly
--   • Accent color правильно применяет Color3 без багов
--   • Rainbow отключает accent при выключении
--   • Auto-load с проверкой на уже загруженный конфиг
--   • Пресеты и слайдеры синхронизированы (RGB-кэш)
--   • Save/Load обёрнуты в pcall (не крашится на битом JSON)
--   • Config корректно применяет значение и перезапускает функции
--=========================================================

if not _G.NeverloseUILoaded then
    warn("[NL] Часть 11: база не загружена")
    return
end

--=========================================================
-- HUD TAB
--=========================================================
hudTabContent = makeTabContent("HUD")
if not hudTabContent then
    warn("[NL] Часть 11: не удалось создать вкладку HUD")
    return
end

hudLeft  = createColumn(hudTabContent, "left")
hudRight = createColumn(hudTabContent, "right")

--=========================================================
-- MENU SIZE
--=========================================================
hudSizeSec = createSection(hudLeft, "Размер интерфейса")

function applyMenuSize(sizeName)
    Cfg.MenuSize = sizeName
    local s = getMenuSize()
    if MainFrame and MainFrame.Visible then
        tween(MainFrame, 0.25, {
            Size = UDim2.new(0, s.w, 0, s.h),
            Position = UDim2.new(0.5, -s.w / 2, 0.5, -s.h / 2),
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end

createCycle(hudSizeSec, "Размер меню", {"Small", "Medium", "Large", "Huge"}, "Medium", function(v)
    applyMenuSize(v)
    if _G.NL_NotifyInfo then _G.NL_NotifyInfo("Размер: " .. v) end
end)

sizeBtnRow = Instance.new("Frame")
sizeBtnRow.Size = UDim2.new(1, 0, 0, 30)
sizeBtnRow.BackgroundTransparency = 1
sizeBtnRow.ZIndex = 54
sizeBtnRow.Parent = hudSizeSec

local sizeLayout = Instance.new("UIListLayout")
sizeLayout.FillDirection = Enum.FillDirection.Horizontal
sizeLayout.Padding = UDim.new(0, 4)
sizeLayout.Parent = sizeBtnRow

local function makeSizeBtn(text, sizeName)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.25, -3, 1, 0)
    b.BackgroundColor3 = NL_DARKER
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = NL_TEXT
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.AutoButtonColor = false
    b.ZIndex = 55
    b.Parent = sizeBtnRow

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.Color = NL_BLUE
    s.Thickness = 1
    s.Transparency = 0.6
    s.Parent = b
    registerAccent(s, "Color")

    b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundColor3 = NL_BLUE}) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = NL_DARKER}) end)
    b.MouseButton1Click:Connect(function()
        applyMenuSize(sizeName)
        if _G.NL_NotifyInfo then _G.NL_NotifyInfo("Размер: " .. sizeName) end
    end)
end

makeSizeBtn("S", "Small")
makeSizeBtn("M", "Medium")
makeSizeBtn("L", "Large")
makeSizeBtn("XL", "Huge")

--=========================================================
-- BLUR
--=========================================================
hudBlurSec = createSection(hudLeft, "Размытие фона")

createCheckbox(hudBlurSec, "Включить размытие", true, function(v)
    Cfg.BlurEnabled = v
    if not v then
        tween(BlurEffect, 0.3, {Size = 0})
    else
        if MainFrame and MainFrame.Visible then
            tween(BlurEffect, 0.3, {Size = Cfg.BlurIntensity})
        end
    end
end, "HUD_Blur")

createSlider(hudBlurSec, "Интенсивность", 0, 50, 15, function(v)
    Cfg.BlurIntensity = v
    if Cfg.BlurEnabled and MainFrame and MainFrame.Visible then
        BlurEffect.Size = v
    end
end)

--=========================================================
-- POSITION RESET
--=========================================================
hudPosSec = createSection(hudLeft, "Расположение")

local hudInfoLbl = Instance.new("TextLabel")
hudInfoLbl.Size = UDim2.new(1, 0, 0, 60)
hudInfoLbl.BackgroundTransparency = 1
hudInfoLbl.Text = "HP и водяной знак можно двигать мышкой.\nМеню — тянуть за верхнюю плашку."
hudInfoLbl.TextColor3 = NL_DIM
hudInfoLbl.Font = Enum.Font.Gotham
hudInfoLbl.TextSize = 11
hudInfoLbl.TextWrapped = true
hudInfoLbl.TextYAlignment = Enum.TextYAlignment.Top
hudInfoLbl.ZIndex = 55
hudInfoLbl.Parent = hudPosSec

createButton(hudPosSec, "Сбросить позиции", NL_DARKER, function()
    if _G.NL_ResetHPPosition then _G.NL_ResetHPPosition() end
    if WM then
        WM.AnchorPoint = Vector2.new(1, 0)
        WM.Position = UDim2.new(1, -15, 0, 15)
    end
    if MainFrame then
        local s = getMenuSize()
        MainFrame.Position = UDim2.new(0.5, -s.w / 2, 0.5, -s.h / 2)
    end
    if _G.NL_NotifyOK then _G.NL_NotifyOK("Позиции сброшены") end
end)

--=========================================================
-- ACCENT COLOR
--=========================================================
hudColorSec = createSection(hudRight, "Цвет интерфейса")

-- ✅ RGB-кэш для избежания скачков
local accentR = math.floor(Cfg.Accent.R * 255)
local accentG = math.floor(Cfg.Accent.G * 255)
local accentB = math.floor(Cfg.Accent.B * 255)

createSlider(hudColorSec, "Red", 0, 255, accentR, function(v)
    accentR = v
    Cfg.Accent = Color3.fromRGB(accentR, accentG, accentB)
    NL_BLUE = Cfg.Accent
    if Cfg.Rainbow then Cfg.Rainbow = false end
    updateAllAccents(Cfg.Accent)
end, true, "R")

createSlider(hudColorSec, "Green", 0, 255, accentG, function(v)
    accentG = v
    Cfg.Accent = Color3.fromRGB(accentR, accentG, accentB)
    NL_BLUE = Cfg.Accent
    if Cfg.Rainbow then Cfg.Rainbow = false end
    updateAllAccents(Cfg.Accent)
end, true, "G")

createSlider(hudColorSec, "Blue", 0, 255, accentB, function(v)
    accentB = v
    Cfg.Accent = Color3.fromRGB(accentR, accentG, accentB)
    NL_BLUE = Cfg.Accent
    if Cfg.Rainbow then Cfg.Rainbow = false end
    updateAllAccents(Cfg.Accent)
end, true, "B")

--=========================================================
-- PRESETS
--=========================================================
hudPresetsFrame = Instance.new("Frame")
hudPresetsFrame.Size = UDim2.new(1, 0, 0, 110)
hudPresetsFrame.BackgroundTransparency = 1
hudPresetsFrame.ZIndex = 54
hudPresetsFrame.Parent = hudColorSec

local presetsLayout = Instance.new("UIGridLayout")
presetsLayout.CellSize = UDim2.new(0, 34, 0, 34)
presetsLayout.CellPadding = UDim2.new(0, 4, 0, 4)
presetsLayout.Parent = hudPresetsFrame

ColorPresets = {
    {n = "Blue",    c = Color3.fromRGB(0, 140, 255)},
    {n = "Red",     c = Color3.fromRGB(220, 50, 60)},
    {n = "Green",   c = Color3.fromRGB(50, 200, 100)},
    {n = "Purple",  c = Color3.fromRGB(160, 60, 220)},
    {n = "Orange",  c = Color3.fromRGB(255, 150, 0)},
    {n = "Pink",    c = Color3.fromRGB(255, 100, 180)},
    {n = "Cyan",    c = Color3.fromRGB(0, 220, 220)},
    {n = "Yellow",  c = Color3.fromRGB(255, 220, 0)},
    {n = "White",   c = Color3.fromRGB(255, 255, 255)},
    {n = "Lime",    c = Color3.fromRGB(50, 255, 50)},
    {n = "Magenta", c = Color3.fromRGB(255, 0, 255)},
    {n = "Gold",    c = Color3.fromRGB(255, 215, 0)},
    {n = "Teal",    c = Color3.fromRGB(0, 128, 128)},
    {n = "Crimson", c = Color3.fromRGB(220, 20, 60)},
    {n = "Violet",  c = Color3.fromRGB(138, 43, 226)},
    {n = "Indigo",  c = Color3.fromRGB(75, 0, 130)},
    {n = "Mint",    c = Color3.fromRGB(100, 255, 200)},
    {n = "Sky",     c = Color3.fromRGB(135, 206, 235)},
}

for _, preset in ipairs(ColorPresets) do
    local pb = Instance.new("TextButton")
    pb.BackgroundColor3 = preset.c
    pb.BorderSizePixel = 0
    pb.Text = ""
    pb.AutoButtonColor = false
    pb.ZIndex = 55
    pb.Parent = hudPresetsFrame

    local pbc = Instance.new("UICorner")
    pbc.CornerRadius = UDim.new(0, 5)
    pbc.Parent = pb

    pb.MouseButton1Click:Connect(function()
        Cfg.Accent = preset.c
        NL_BLUE = preset.c
        accentR = math.floor(preset.c.R * 255)
        accentG = math.floor(preset.c.G * 255)
        accentB = math.floor(preset.c.B * 255)
        if Cfg.Rainbow then Cfg.Rainbow = false end
        updateAllAccents(preset.c)
        if _G.NL_Notify then
            _G.NL_Notify("Цвет: " .. preset.n, preset.c, 2)
        end
    end)
end

--=========================================================
-- RAINBOW
--=========================================================
hudRainbowSec = createSection(hudRight, "Радуга")

createCheckbox(hudRainbowSec, "Радужный перелив", false, function(v)
    Cfg.Rainbow = v
    if not v then
        NL_BLUE = Cfg.Accent
        updateAllAccents(Cfg.Accent)
    end
end, "HUD_Rainbow")

createSlider(hudRainbowSec, "Скорость x100", 10, 500, 100, function(v)
    Cfg.RainbowSpeed = v / 100
end)

rainbowHue = 0

rainbowConn = RunService.Heartbeat:Connect(function(dt)
    if not _G.NeverloseUILoaded then return end
    if not Cfg.Rainbow then return end

    rainbowHue = rainbowHue + dt * Cfg.RainbowSpeed * 0.15
    if rainbowHue > 1 then rainbowHue = rainbowHue - 1 end

    local c = Color3.fromHSV(rainbowHue, 1, 1)
    NL_BLUE = c

    for i = #AccentElements, 1, -1 do
        local el = AccentElements[i]
        if not el.obj or not el.obj.Parent then
            table.remove(AccentElements, i)
        else
            pcall(function() el.obj[el.prop] = c end)
        end
    end
end)

--=========================================================
-- CONFIG TAB
--=========================================================
cfgContent = makeTabContent("Config")
if not cfgContent then
    warn("[NL] Часть 11: не удалось создать вкладку Config")
    return
end

cfgLeft  = createColumn(cfgContent, "left")
cfgRight = createColumn(cfgContent, "right")

CONFIG_FILE = Cfg.SaveFile or "neverlose_config.json"

--=========================================================
-- COLLECT
--=========================================================
function collectConfig()
    local cfg = {}

    for k, v in pairs(Cheat) do
        if type(v) == "boolean" or type(v) == "number" then
            cfg["C_" .. k] = v
        elseif typeof(v) == "Color3" then
            cfg["C_" .. k] = {v.R, v.G, v.B, "_c"}
        end
    end

    for k, v in pairs(Cfg) do
        if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
            cfg["G_" .. k] = v
        elseif typeof(v) == "Color3" then
            cfg["G_" .. k] = {v.R, v.G, v.B, "_c"}
        end
    end

    if SpeedSystem then
        for k, v in pairs(SpeedSystem) do
            if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
                cfg["S_" .. k] = v
            end
        end
    end

    if btS then
        for k, v in pairs(btS) do
            if type(v) == "boolean" or type(v) == "number" then
                cfg["B_" .. k] = v
            end
        end
    end

    if ctpSettings then
        for k, v in pairs(ctpSettings) do
            if type(v) == "boolean" or type(v) == "number" then
                cfg["P_" .. k] = v
            end
        end
    end

    if antiCfg then
        for k, v in pairs(antiCfg) do
            if type(v) == "boolean" or type(v) == "number" then
                cfg["A_" .. k] = v
            end
        end
    end

    -- DOORS (если часть 13 загружена)
    if DoorsSettings then
        for k, v in pairs(DoorsSettings) do
            if type(v) == "boolean" or type(v) == "number" then
                cfg["D_" .. k] = v
            end
        end
    end

    cfg.Keybinds = {}
    for action, key in pairs(Keybinds) do
        if key then cfg.Keybinds[action] = key.Name end
    end

    return cfg
end

--=========================================================
-- APPLY
--=========================================================
function applyConfig(cfg)
    if not cfg then return end

    for k, v in pairs(cfg) do
        local prefix = string.sub(k, 1, 2)
        local key = string.sub(k, 3)
        local value = v

        if type(v) == "table" and v[4] == "_c" then
            value = Color3.new(v[1], v[2], v[3])
        end

        if prefix == "C_" and Cheat[key] ~= nil then
            Cheat[key] = value
        elseif prefix == "G_" and Cfg[key] ~= nil then
            Cfg[key] = value
        elseif prefix == "S_" and SpeedSystem and SpeedSystem[key] ~= nil then
            SpeedSystem[key] = value
        elseif prefix == "B_" and btS and btS[key] ~= nil then
            btS[key] = value
        elseif prefix == "P_" and ctpSettings and ctpSettings[key] ~= nil then
            ctpSettings[key] = value
        elseif prefix == "A_" and antiCfg and antiCfg[key] ~= nil then
            antiCfg[key] = value
        elseif prefix == "D_" and DoorsSettings and DoorsSettings[key] ~= nil then
            DoorsSettings[key] = value
        end
    end

    -- Перезапуск функций, которые включены
    if Cheat.Fly and enableFly then enableFly() end
    if Cheat.Noclip and enableNoclip then enableNoclip() end
    if Cheat.Speed and enableSpeed then
        if SpeedSystem.Enabled then speedStop() end
        enableSpeed()
    end
    if Cheat.BunnyHop and enableBunnyHop then enableBunnyHop() end
    if Cheat.SpinBot and enableSpinBot then enableSpinBot() end
    if Cheat.Spider and enableSpider then enableSpider() end
    if Cheat.InfJump and enableInfJump then enableInfJump() end
    if Cheat.FullBright and enableFullBright then enableFullBright() end
    if Cheat.BlackSky and enableBlackSky then enableBlackSky() end
    if Cheat.Snow and enableSnow then enableSnow() end
    if Cheat.Fog and enableFog then enableFog() end
    if Cheat.WorldColorEnabled and applyWorldColor then applyWorldColor() end
    if Cheat.AutoClicker and startAutoClicker then startAutoClicker() end
    if Cheat.Hat and _G.NL_CreateHat then _G.NL_CreateHat() end
    if Cheat.Jump and applyJump then applyJump() end

    if Cheat.AntiFling and enableAntiFling then enableAntiFling() end
    if Cheat.AntiKnockback and enableAntiKnockback then enableAntiKnockback() end
    if Cheat.AntiRagdoll and enableAntiRagdoll then enableAntiRagdoll() end

    NL_BLUE = Cfg.Accent
    updateAllAccents(Cfg.Accent)

    if cfg.Keybinds then
        for action, kn in pairs(cfg.Keybinds) do
            local ok, kc = pcall(function() return Enum.KeyCode[kn] end)
            if ok and kc then Keybinds[action] = kc end
        end
    end
end

--=========================================================
-- SAVE
--=========================================================
function saveConfig(fileName)
    if not hasFileAPI() then
        if _G.NL_NotifyErr then _G.NL_NotifyErr("writefile недоступен") end
        return false
    end

    local fname = fileName or CONFIG_FILE
    local cfg = collectConfig()
    local ok, json = pcall(function() return HttpService:JSONEncode(cfg) end)
    if not ok then
        if _G.NL_NotifyErr then _G.NL_NotifyErr("Ошибка JSON") end
        return false
    end

    local ok2 = pcall(function() writefile(fname, json) end)
    if ok2 then
        if _G.NL_NotifyOK then _G.NL_NotifyOK("Сохранено: " .. fname) end
        return true
    end

    if _G.NL_NotifyErr then _G.NL_NotifyErr("Ошибка записи") end
    return false
end

--=========================================================
-- LOAD
--=========================================================
function loadConfig(fileName)
    if not hasFileAPI() then
        if _G.NL_NotifyErr then _G.NL_NotifyErr("readfile недоступен") end
        return false
    end

    local fname = fileName or CONFIG_FILE

    if not isfile(fname) then
        if _G.NL_NotifyErr then _G.NL_NotifyErr("Файл не найден: " .. fname) end
        return false
    end

    local ok, content = pcall(function() return readfile(fname) end)
    if not ok or not content then
        if _G.NL_NotifyErr then _G.NL_NotifyErr("Ошибка чтения") end
        return false
    end

    local ok2, parsed = pcall(function() return HttpService:JSONDecode(content) end)
    if not ok2 or not parsed then
        if _G.NL_NotifyErr then _G.NL_NotifyErr("Ошибка парсинга") end
        return false
    end

    applyConfig(parsed)
    if _G.NL_NotifyOK then _G.NL_NotifyOK("Загружено: " .. fname) end
    return true
end

--=========================================================
-- DELETE
--=========================================================
function deleteConfig(fileName)
    if not hasFileAPI() then
        if _G.NL_NotifyErr then _G.NL_NotifyErr("Нет доступа к файлам") end
        return
    end

    local fname = fileName or CONFIG_FILE

    if not isfile(fname) then
        if _G.NL_NotifyErr then _G.NL_NotifyErr("Файл не найден") end
        return
    end
    pcall(function() delfile(fname) end)
    if _G.NL_NotifyOK then _G.NL_NotifyOK("Удалено: " .. fname) end
end

_G.NL_SaveConfig   = saveConfig
_G.NL_LoadConfig   = loadConfig
_G.NL_DeleteConfig = deleteConfig

--=========================================================
-- CONFIG UI
--=========================================================
cfgSaveSec = createSection(cfgLeft, "Сохранить / Загрузить")

cfgNameBox = Instance.new("TextBox")
cfgNameBox.Size = UDim2.new(1, 0, 0, 32)
cfgNameBox.BackgroundColor3 = NL_DARKER
cfgNameBox.BorderSizePixel = 0
cfgNameBox.Text = "default.json"
cfgNameBox.PlaceholderText = "Имя файла (например my.json)"
cfgNameBox.PlaceholderColor3 = NL_DIM
cfgNameBox.TextColor3 = NL_TEXT
cfgNameBox.Font = Enum.Font.Gotham
cfgNameBox.TextSize = 12
cfgNameBox.ClearTextOnFocus = false
cfgNameBox.ZIndex = 55
cfgNameBox.Parent = cfgSaveSec

local cfgNameCorner = Instance.new("UICorner")
cfgNameCorner.CornerRadius = UDim.new(0, 4)
cfgNameCorner.Parent = cfgNameBox

local cfgNameStroke = Instance.new("UIStroke")
cfgNameStroke.Color = NL_BLUE
cfgNameStroke.Thickness = 1
cfgNameStroke.Transparency = 0.6
cfgNameStroke.Parent = cfgNameBox
registerAccent(cfgNameStroke, "Color")

local function currentFileName()
    local n = cfgNameBox.Text
    if not n or n == "" then n = "default.json" end
    if not string.find(n, "%.json$") then n = n .. ".json" end
    return n
end

createButton(cfgSaveSec, "Сохранить конфиг", NL_GREEN, function()
    saveConfig(currentFileName())
end)

createButton(cfgSaveSec, "Загрузить конфиг", NL_BLUE, function()
    loadConfig(currentFileName())
end)

delCfgBtn = Instance.new("TextButton")
delCfgBtn.Size = UDim2.new(1, 0, 0, 30)
delCfgBtn.BackgroundColor3 = NL_DARKER
delCfgBtn.BorderSizePixel = 0
delCfgBtn.Text = "Удалить конфиг"
delCfgBtn.TextColor3 = NL_RED
delCfgBtn.Font = Enum.Font.Gotham
delCfgBtn.TextSize = 12
delCfgBtn.AutoButtonColor = false
delCfgBtn.ZIndex = 55
delCfgBtn.Parent = cfgSaveSec

local delCfgCorner = Instance.new("UICorner")
delCfgCorner.CornerRadius = UDim.new(0, 5)
delCfgCorner.Parent = delCfgBtn

delCfgBtn.MouseButton1Click:Connect(function()
    deleteConfig(currentFileName())
end)

local cfgInfo = Instance.new("TextLabel")
cfgInfo.Size = UDim2.new(1, 0, 0, 50)
cfgInfo.BackgroundTransparency = 1
cfgInfo.Text = "Файл сохраняется в папке воркспейса экзекутора.\nВсе настройки, бинды и цвета пишутся в JSON."
cfgInfo.TextColor3 = NL_DIM
cfgInfo.Font = Enum.Font.Gotham
cfgInfo.TextSize = 10
cfgInfo.TextXAlignment = Enum.TextXAlignment.Left
cfgInfo.TextWrapped = true
cfgInfo.TextYAlignment = Enum.TextYAlignment.Top
cfgInfo.ZIndex = 55
cfgInfo.Parent = cfgSaveSec

--=========================================================
-- CONFIG INFO
--=========================================================
cfgInfoSec = createSection(cfgRight, "Информация")

local cfgInfoLabel = Instance.new("TextLabel")
cfgInfoLabel.Size = UDim2.new(1, 0, 0, 240)
cfgInfoLabel.BackgroundTransparency = 1
cfgInfoLabel.Text = "Config сохраняет:\n• Все вкл/выкл функции\n• Слайдеры (скорости, силы, цвета)\n• Speed System (режим + значения)\n• Цвета (ESP, World, Fog, Accent)\n• Размер меню\n• Бинды клавиш\n• Настройки Baritone\n• Настройки Cursor TP\n• Настройки Protection\n• Настройки DOORS\n\nАвтозагрузка: если файл\n'neverlose_config.json' есть,\nон загрузится через 12 сек."
cfgInfoLabel.TextColor3 = NL_DIM
cfgInfoLabel.Font = Enum.Font.Gotham
cfgInfoLabel.TextSize = 11
cfgInfoLabel.TextWrapped = true
cfgInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
cfgInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
cfgInfoLabel.ZIndex = 55
cfgInfoLabel.Parent = cfgInfoSec

--=========================================================
-- API CHECK
--=========================================================
cfgHelpSec = createSection(cfgRight, "Проверка API")

local cfgApiLabel = Instance.new("TextLabel")
cfgApiLabel.Size = UDim2.new(1, 0, 0, 80)
cfgApiLabel.BackgroundTransparency = 1
cfgApiLabel.Text = "Проверка поддержки:\n" .. (
    hasFileAPI()
        and "  ✓ writefile / readfile / isfile"
        or  "  ✗ Файлы недоступны в этом экзекуторе"
)
cfgApiLabel.TextColor3 = hasFileAPI() and NL_GREEN or NL_RED
cfgApiLabel.Font = Enum.Font.Gotham
cfgApiLabel.TextSize = 11
cfgApiLabel.TextWrapped = true
cfgApiLabel.TextYAlignment = Enum.TextYAlignment.Top
cfgApiLabel.TextXAlignment = Enum.TextXAlignment.Left
cfgApiLabel.ZIndex = 55
cfgApiLabel.Parent = cfgHelpSec

--=========================================================
-- AUTO LOAD (через 12 сек)
--=========================================================
task.spawn(function()
    task.wait(12)
    if not _G.NeverloseUILoaded then return end
    if not hasFileAPI() then return end
    if isfile(CONFIG_FILE) then
        print("[NL] Найдена сохранённая конфигурация, загружаю...")
        loadConfig(CONFIG_FILE)
    end
end)

--=========================================================
-- UNLOAD HOOK
--=========================================================
local _prevUnload11 = _G.NL_UnloadBase
_G.NL_UnloadBase = function()
    if rainbowConn then
        rainbowConn:Disconnect()
        rainbowConn = nil
    end
    if _prevUnload11 then _prevUnload11() end
end

_G.NL_UnloadHUD = function()
    if rainbowConn then
        rainbowConn:Disconnect()
        rainbowConn = nil
    end
end

print("[NL] 11/13 — HUD + Config загружены (FIX v3)")
--=========================================================
-- NEVERLOSE UI — 12/13 (FIX v3)
-- Fling + Active List + финальная сборка
-- ФИКСЫ:
--   • Не дублируем unloadBtn.MouseButton1Click (уже есть в ч.3)
--   • _G.NL_UnloadComplete определён один раз и корректно сцеплен
--   • Fling не конфликтует со SpeedSystem
--   • TP+Fling использует antiHold-подобный lockSelf с токеном
--   • Active List обновляется только при изменениях (сигнатура)
--   • Hotkeys (RShift / RCtrl) не конфликтуют с биндами юзера
--   • Уведомления через _G.NL_Notify
--   • Автофлинг троттлится 10 Hz
--=========================================================

if not _G.NeverloseUILoaded then
    warn("[NL] Часть 12: база не загружена")
    return
end

--=========================================================
-- FLING STATE
--=========================================================
flingPower = 50000
flingEnabled = false
autoFlingEnabled = false
autoFlingRange = 20
tpFlingEnabled = false
protectSelf = true

--=========================================================
-- SELF PROTECTION (token-based)
--=========================================================
selfProtectToken = 0

function lockSelf(duration)
    if not protectSelf then return end
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    selfProtectToken = selfProtectToken + 1
    local myToken = selfProtectToken

    pcall(function() myHRP.Anchored = true end)

    task.delay(duration or 0.5, function()
        if selfProtectToken ~= myToken then return end
        if myHRP and myHRP.Parent then
            pcall(function() myHRP.Anchored = false end)
        end
    end)
end

function unlockSelf()
    selfProtectToken = selfProtectToken + 1
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if myHRP then
        pcall(function() myHRP.Anchored = false end)
    end
end

--=========================================================
-- DO FLING
--=========================================================
function doFling(char)
    if not char then return end
    if not _G.NeverloseUILoaded then return end
    if char == LP.Character then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local direction = Vector3.new(
        math.random(-flingPower, flingPower),
        flingPower * 2,
        math.random(-flingPower, flingPower)
    )

    pcall(function()
        hrp.AssemblyLinearVelocity = direction
        hrp.AssemblyAngularVelocity = Vector3.new(
            math.random(-500, 500),
            math.random(-500, 500),
            math.random(-500, 500)
        )
    end)

    local bv = Instance.new("BodyVelocity")
    bv.Name = "NL_Fling"
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = direction
    bv.Parent = hrp

    task.delay(1, function()
        if bv and bv.Parent then bv:Destroy() end
    end)

    pcall(function()
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end)
end

--=========================================================
-- TP + FLING
--=========================================================
function tpFling(plr)
    if not _G.NeverloseUILoaded then return end
    if not plr or plr == LP then return end

    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local tChar = plr.Character
    local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not tHRP then return end

    -- Отключаем коллизию на себе
    if protectSelf then
        for _, p in ipairs(myChar:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() p.CanCollide = false end)
            end
        end
    end

    lockSelf(0.5)

    local offset = tHRP.CFrame.RightVector * 3
    pcall(function()
        myHRP.CFrame = tHRP.CFrame + offset
    end)

    task.wait(0.05)

    doFling(tChar)
    task.wait(0.1)
    doFling(tChar)

    task.wait(0.3)
    unlockSelf()

    -- Возвращаем коллизию через 0.2 сек
    if protectSelf then
        task.wait(0.2)
        for _, p in ipairs(myChar:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                pcall(function() p.CanCollide = true end)
            end
        end
    end
end

--=========================================================
-- RIGHT CLICK -> TP FLING
--=========================================================
tpFlingConn = UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not _G.NeverloseUILoaded then return end
    if not tpFlingEnabled then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end

    local mouse = Mouse or LP:GetMouse()
    if not mouse then return end
    local target = mouse.Target
    if not target then return end

    local char = target:FindFirstAncestorOfClass("Model")
    if not char then return end

    local plr = Players:GetPlayerFromCharacter(char)
    if plr and plr ~= LP then
        tpFling(plr)
        if _G.NL_Notify then
            _G.NL_Notify(plr.Name .. " в космосе!", NL_RED, 2)
        end
    end
end)

--=========================================================
-- AUTO FLING LOOP (throttle 10 Hz)
--=========================================================
task.spawn(function()
    while _G.NeverloseUILoaded do
        task.wait(0.1)
        if autoFlingEnabled then
            local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP then
                        local char = plr.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp and (hrp.Position - myHRP.Position).Magnitude <= autoFlingRange then
                            doFling(char)
                        end
                    end
                end
            end
        end
    end
end)

--=========================================================
-- FLING TAB
--=========================================================
flingTab = makeTabContent("Fling")
if not flingTab then
    warn("[NL] Часть 12: не удалось создать вкладку Fling")
    return
end

flingCol1 = createColumn(flingTab, "left")
flingCol2 = createColumn(flingTab, "right")

--========== FLING SECTION ==========
flingSec1 = createSection(flingCol1, "Fling")

createCheckbox(flingSec1, "Включить Fling (авто)", false, function(s)
    flingEnabled = s
end, "FL_En")

createCheckbox(flingSec1, "Автофлинг в радиусе", false, function(s)
    autoFlingEnabled = s
    if _G.NL_Notify then
        _G.NL_Notify(
            s and "Автофлинг ВКЛ" or "Автофлинг ВЫКЛ",
            s and NL_GREEN or NL_RED, 2
        )
    end
end, "FL_Auto")

createSlider(flingSec1, "Радиус автофлинга", 5, 100, 20, function(v)
    autoFlingRange = v
end)

createSlider(flingSec1, "Сила флинга", 10000, 200000, 50000, function(v)
    flingPower = v
end)

createCheckbox(flingSec1, "Защита себя", true, function(s)
    protectSelf = s
end, "FL_Protect")

flingAllBtn = Instance.new("TextButton")
flingAllBtn.Size = UDim2.new(1, 0, 0, 34)
flingAllBtn.BackgroundColor3 = NL_RED
flingAllBtn.BorderSizePixel = 0
flingAllBtn.Text = "ВЫБРОСИТЬ ВСЕХ РЯДОМ"
flingAllBtn.TextColor3 = NL_WHITE
flingAllBtn.Font = Enum.Font.GothamBold
flingAllBtn.TextSize = 12
flingAllBtn.AutoButtonColor = false
flingAllBtn.ZIndex = 55
flingAllBtn.Parent = flingSec1

local fb1 = Instance.new("UICorner")
fb1.CornerRadius = UDim.new(0, 5)
fb1.Parent = flingAllBtn

flingAllBtn.MouseButton1Click:Connect(function()
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    lockSelf(0.5)
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - myHRP.Position).Magnitude <= autoFlingRange then
                doFling(char)
                count = count + 1
            end
        end
    end
    task.wait(0.5)
    unlockSelf()

    if _G.NL_Notify then
        _G.NL_Notify("Выброшено: " .. count, NL_RED, 2)
    end
end)

--========== TP+FLING SECTION ==========
flingSec2 = createSection(flingCol2, "TP + Fling")

createCheckbox(flingSec2, "TP+Флинг по ПКМ", false, function(s)
    tpFlingEnabled = s
    if _G.NL_Notify then
        _G.NL_Notify(
            s and "ПКМ — флинг" or "ПКМ отключён",
            s and NL_GREEN or NL_DIM, 2
        )
    end
end, "FL_Tp")

local flingInfo = Instance.new("TextLabel")
flingInfo.Size = UDim2.new(1, 0, 0, 110)
flingInfo.BackgroundTransparency = 1
flingInfo.Text = "Наведи на игрока → ПКМ → он улетит.\n\nТы НЕ улетишь, потому что:\n• Заморозка на 0.5 сек\n• Телепорт рядом, не внутрь\n• Коллизия выключена на время\n• Anti-Fling вернёт тебя"
flingInfo.TextColor3 = NL_DIM
flingInfo.Font = Enum.Font.Gotham
flingInfo.TextSize = 11
flingInfo.TextWrapped = true
flingInfo.TextYAlignment = Enum.TextYAlignment.Top
flingInfo.TextXAlignment = Enum.TextXAlignment.Left
flingInfo.ZIndex = 55
flingInfo.Parent = flingSec2

--========== PLAYER LIST ==========
flingSec3 = createSection(flingCol2, "Игроки")

flingList = Instance.new("ScrollingFrame")
flingList.Size = UDim2.new(1, 0, 0, 200)
flingList.BackgroundTransparency = 1
flingList.BorderSizePixel = 0
flingList.ScrollBarThickness = 4
flingList.ScrollBarImageColor3 = NL_RED
flingList.ScrollBarImageTransparency = 0.3
flingList.CanvasSize = UDim2.new(0, 0, 0, 0)
flingList.AutomaticCanvasSize = Enum.AutomaticSize.Y
flingList.ZIndex = 54
flingList.Parent = flingSec3
registerAccent(flingList, "ScrollBarImageColor3")

local fl = Instance.new("UIListLayout")
fl.Padding = UDim.new(0, 4)
fl.SortOrder = Enum.SortOrder.LayoutOrder
fl.Parent = flingList

flingEntries = {}

function makeFlingEntry(plr)
    if plr == LP then return end
    if flingEntries[plr] and flingEntries[plr].Parent then
        flingEntries[plr]:Destroy()
    end

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = NL_DARKER
    b.BorderSizePixel = 0
    b.Text = "  " .. plr.Name
    b.TextColor3 = NL_TEXT
    b.Font = Enum.Font.Gotham
    b.TextSize = 11
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextTruncate = Enum.TextTruncate.AtEnd
    b.AutoButtonColor = false
    b.ZIndex = 55
    b.Parent = flingList

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = b

    b.MouseEnter:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = NL_RED, TextColor3 = NL_WHITE})
    end)
    b.MouseLeave:Connect(function()
        tween(b, 0.15, {BackgroundColor3 = NL_DARKER, TextColor3 = NL_TEXT})
    end)
    b.MouseButton1Click:Connect(function()
        tpFling(plr)
        if _G.NL_Notify then
            _G.NL_Notify("Флинг: " .. plr.Name, NL_RED, 2)
        end
    end)

    flingEntries[plr] = b
end

function refreshFlingList()
    for plr, e in pairs(flingEntries) do
        if e and e.Parent then e:Destroy() end
    end
    flingEntries = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            makeFlingEntry(plr)
        end
    end
end

refreshFlingList()

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    if not _G.NeverloseUILoaded then return end
    refreshFlingList()
end)

Players.PlayerRemoving:Connect(function(plr)
    if flingEntries[plr] then
        if flingEntries[plr].Parent then flingEntries[plr]:Destroy() end
        flingEntries[plr] = nil
    end
end)

--=========================================================
-- UNLOAD FLING
--=========================================================
_G.NL_UnloadFling = function()
    flingEnabled = false
    autoFlingEnabled = false
    tpFlingEnabled = false
    unlockSelf()

    if tpFlingConn then
        tpFlingConn:Disconnect()
        tpFlingConn = nil
    end

    for _, e in pairs(flingEntries) do
        if e and e.Parent then e:Destroy() end
    end
    flingEntries = {}

    for _, act in ipairs({"FL_En", "FL_Auto", "FL_Protect", "FL_Tp"}) do
        BindCallbacks[act] = nil
    end
end

--=========================================================
-- ACTIVE LIST
--=========================================================
ActiveListFrame = Instance.new("Frame")
ActiveListFrame.Name = "NL_ActiveList"
ActiveListFrame.Size = UDim2.new(0, 200, 0, 300)
ActiveListFrame.AnchorPoint = Vector2.new(1, 1)
ActiveListFrame.Position = UDim2.new(1, -15, 1, -110)
ActiveListFrame.BackgroundColor3 = NL_DARKER
ActiveListFrame.BackgroundTransparency = 0.2
ActiveListFrame.BorderSizePixel = 0
ActiveListFrame.ZIndex = 200
ActiveListFrame.Visible = false
ActiveListFrame.Parent = ScreenGui

local ALCorner = Instance.new("UICorner")
ALCorner.CornerRadius = UDim.new(0, 8)
ALCorner.Parent = ActiveListFrame

local ALStroke = Instance.new("UIStroke")
ALStroke.Color = NL_BLUE
ALStroke.Thickness = 1
ALStroke.Transparency = 0.4
ALStroke.Parent = ActiveListFrame
registerAccent(ALStroke, "Color")

local ALTitle = Instance.new("TextLabel")
ALTitle.Size = UDim2.new(1, -16, 0, 22)
ALTitle.Position = UDim2.new(0, 8, 0, 6)
ALTitle.BackgroundTransparency = 1
ALTitle.Text = "ACTIVE"
ALTitle.TextColor3 = NL_BLUE
ALTitle.Font = Enum.Font.GothamBold
ALTitle.TextSize = 11
ALTitle.TextXAlignment = Enum.TextXAlignment.Left
ALTitle.ZIndex = 201
ALTitle.Parent = ActiveListFrame
registerAccent(ALTitle, "TextColor3")

local ALList = Instance.new("Frame")
ALList.Size = UDim2.new(1, -16, 1, -34)
ALList.Position = UDim2.new(0, 8, 0, 30)
ALList.BackgroundTransparency = 1
ALList.ZIndex = 201
ALList.Parent = ActiveListFrame

local ALLayout = Instance.new("UIListLayout")
ALLayout.Padding = UDim.new(0, 2)
ALLayout.SortOrder = Enum.SortOrder.LayoutOrder
ALLayout.Parent = ALList

function AL_MakeLabel(text, order)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 14)
    l.BackgroundTransparency = 1
    l.Text = "• " .. text
    l.TextColor3 = NL_TEXT
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = order or 0
    l.ZIndex = 202
    l.Parent = ALList
    return l
end

function AL_GetActive()
    local list = {}
    if Cheat.ESP then table.insert(list, "ESP") end
    if Cheat.Fly then table.insert(list, "Fly") end
    if Cheat.Noclip then table.insert(list, "Noclip") end
    if Cheat.Speed then
        local mode = SpeedSystem and SpeedSystem.Mode or "Speed"
        table.insert(list, "Speed [" .. mode .. "]")
    end
    if Cheat.BunnyHop then table.insert(list, "BunnyHop") end
    if Cheat.SpinBot then table.insert(list, "SpinBot") end
    if Cheat.Spider then table.insert(list, "Spider") end
    if Cheat.InfJump then table.insert(list, "Inf Jump") end
    if Cheat.Jump then table.insert(list, "Jump") end
    if Cheat.FullBright then table.insert(list, "FullBright") end
    if Cheat.BlackSky then table.insert(list, "Black Sky") end
    if Cheat.Snow then table.insert(list, "Snow") end
    if Cheat.Fog then table.insert(list, "Fog") end
    if Cheat.WorldColorEnabled then table.insert(list, "World Color") end
    if Cheat.AutoClicker then table.insert(list, "AutoClicker") end
    if Cheat.Hat then table.insert(list, "Cone Hat") end
    if Cheat.AntiFling then table.insert(list, "Anti-Fling") end
    if Cheat.AntiKnockback then table.insert(list, "Anti-KB") end
    if Cheat.AntiRagdoll then table.insert(list, "Anti-Ragdoll") end
    if btS and btS.running then table.insert(list, "Baritone") end
    if flingEnabled then table.insert(list, "Fling") end
    if autoFlingEnabled then table.insert(list, "Auto-Fling") end
    if tpFlingEnabled then table.insert(list, "ПКМ-Флинг") end
    if DoorsSettings then
        if DoorsSettings.DoorESP then table.insert(list, "DOORS: Door") end
        if DoorsSettings.EntityESP then table.insert(list, "DOORS: Entity") end
        if DoorsSettings.ItemESP then table.insert(list, "DOORS: Item") end
        if DoorsSettings.Fullbright then table.insert(list, "DOORS: FB") end
    end
    return list
end

AL_Labels = {}
AL_LastSignature = ""

task.spawn(function()
    while _G.NeverloseUILoaded do
        task.wait(0.4)
        if not ActiveListFrame or not ActiveListFrame.Parent then break end

        local active = AL_GetActive()
        local sig = table.concat(active, "|")
        if sig ~= AL_LastSignature then
            AL_LastSignature = sig
            for _, l in ipairs(AL_Labels) do
                if l and l.Parent then l:Destroy() end
            end
            AL_Labels = {}
            for i, name in ipairs(active) do
                table.insert(AL_Labels, AL_MakeLabel(name, i))
            end
            ActiveListFrame.Visible = #active > 0
        end
    end
end)

--=========================================================
-- HOTKEYS (RShift / RCtrl)
--=========================================================
hotkeyConn = UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not _G.NeverloseUILoaded then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        autoFlingEnabled = not autoFlingEnabled
        if _G.NL_Notify then
            _G.NL_Notify(
                "Автофлинг: " .. (autoFlingEnabled and "ON" or "OFF"),
                autoFlingEnabled and NL_GREEN or NL_RED, 2
            )
        end
    end

    if input.KeyCode == Enum.KeyCode.RightControl then
        tpFlingEnabled = not tpFlingEnabled
        if _G.NL_Notify then
            _G.NL_Notify(
                "ПКМ-Флинг: " .. (tpFlingEnabled and "ON" or "OFF"),
                tpFlingEnabled and NL_GREEN or NL_RED, 2
            )
        end
    end
end)

--=========================================================
-- FINAL UNLOAD COMPOSITE
--=========================================================
-- ✅ Единственное определение _G.NL_UnloadComplete
-- _G.NL_UnloadBase — базовая цепочка (части 3, 7, 8, 9, 11)
_G.NL_UnloadComplete = function()
    if _G.NL_UnloadDoors   then pcall(_G.NL_UnloadDoors)   end
    if _G.NL_UnloadFling   then pcall(_G.NL_UnloadFling)   end
    if _G.NL_UnloadProtect then pcall(_G.NL_UnloadProtect) end
    if _G.NL_UnloadBT      then pcall(_G.NL_UnloadBT)      end
    if _G.NL_UnloadTP      then pcall(_G.NL_UnloadTP)      end
    if _G.NL_UnloadCTP     then pcall(_G.NL_UnloadCTP)     end
    if _G.NL_UnloadHUD     then pcall(_G.NL_UnloadHUD)     end

    if hotkeyConn then
        hotkeyConn:Disconnect()
        hotkeyConn = nil
    end
    if ActiveListFrame and ActiveListFrame.Parent then
        ActiveListFrame:Destroy()
    end

    if _G.NL_UnloadBase then pcall(_G.NL_UnloadBase) end
end

--=========================================================
-- FINAL CHECK (через 14 сек)
--=========================================================
task.spawn(function()
    task.wait(14)
    if not _G.NeverloseUILoaded then return end

    local missing = {}
    local required = {
        "Visuals", "Misc", "Teleport", "Cursor TP",
        "Baritone", "Fling", "HUD", "Config", "Settings",
    }
    for _, name in ipairs(required) do
        if not tabs[name] then
            table.insert(missing, name)
        end
    end

    if #missing > 0 then
        warn("[NL] Отсутствуют вкладки: " .. table.concat(missing, ", "))
    else
        print("[NL] Все 9 вкладок на месте")
    end

    print("[NL] Xeno API:")
    print("  hookmetamethod:", type(hookmetamethod))
    print("  getrawmetatable:", type(getrawmetatable))
    print("  mouse1click:", type(mouse1click))
    print("  writefile:", type(writefile))
    print("  gethui:", type(gethui))
end)

--=========================================================
-- FINAL PRINT
--=========================================================
print("")
print("========================================")
print("   NEVERLOSE UI — 12/13 ЗАГРУЖЕНО")
print("   XENO EDITION (FIX v3)")
print("========================================")
print("  INSERT        - меню")
print("  RightShift    - автофлинг вкл/выкл")
print("  RightControl  - ПКМ-флинг вкл/выкл")
print("  ПКМ           - флинг цели")
print("")
print("  SPEED MODES:")
print("   Regular - WalkSpeed (простой)")
print("   Matrix  - CFrame TP (тихий, обход)")
print("   Hybrid  - WalkSpeed + CFrame (баланс)")
print("")
print("  ВКЛАДКИ (9):")
print("   Visuals     - ESP, FullBright, BlackSky,")
print("                 Snow, Fog, WorldColor")
print("   Misc        - Fly, Speed, Noclip, BHop,")
print("                 Spin, Spider, Jump, Clicker")
print("   Teleport    - к игрокам, координаты")
print("   Cursor TP   - телепорт к курсору")
print("   Baritone    - AI-навигация")
print("   Fling       - выброс игроков")
print("   HUD         - размер, цвет, радуга")
print("   Config      - save / load")
print("   Settings    - Unload")
print("")
print("  Версия: " .. Cfg.Version .. " | " .. os.date("%Y-%m-%d %H:%M"))
print("========================================")
--=========================================================
-- [DOORS] Standalone NL integration — v5 (DEBUG + TOP TAB)
--=========================================================
print("========================================")
print("[DOORS] Loading...")

--========== ПРОВЕРКА NL ==========
if not _G.NeverloseUILoaded and not NeverloseUILoaded then
    warn("[DOORS] NL НЕ ЗАГРУЖЕН. Сначала запусти части 1-12!")
    return
end

print("[DOORS] NL найден ✓")

--========== ПОЛУЧАЕМ NL API (ищем везде) ==========
local _tabs           = _G.tabs           or tabs
local _createTab      = _G.createTab      or createTab
local _makeTabContent = _G.makeTabContent or makeTabContent
local _createColumn   = _G.createColumn   or createColumn
local _createSection  = _G.createSection  or createSection
local _createCheckbox = _G.createCheckbox or createCheckbox
local _createButton   = _G.createButton   or createButton

print("[DOORS] API check:")
print("  tabs:          ", type(_tabs))
print("  createTab:     ", type(_createTab))
print("  makeTabContent:", type(_makeTabContent))
print("  createColumn:  ", type(_createColumn))
print("  createSection: ", type(_createSection))
print("  createCheckbox:", type(_createCheckbox))
print("  createButton:  ", type(_createButton))

if type(_tabs) ~= "table" then
    warn("[DOORS] FATAL: tabs не таблица. Убедись что часть 1 запущена ПЕРЕД частью 13.")
    return
end

if type(_createTab) ~= "function" then
    warn("[DOORS] FATAL: createTab не функция.")
    return
end

--========== ЦВЕТА ==========
local C_BLUE   = _G.NL_BLUE   or Color3.fromRGB(0, 140, 255)
local C_DARKER = _G.NL_DARKER or Color3.fromRGB(10, 10, 14)
local C_TEXT   = _G.NL_TEXT   or Color3.fromRGB(230, 230, 235)
local C_DIM    = _G.NL_DIM    or Color3.fromRGB(140, 140, 150)
local C_GREEN  = _G.NL_GREEN  or Color3.fromRGB(50, 200, 100)

--========== СОЗДАЁМ ВКЛАДКУ ==========
print("[DOORS] Создаю вкладку 'DOORS'...")

local okTab, errTab = pcall(function()
    if not _tabs["DOORS"] then
        _createTab("DOORS")
    end
end)

if not okTab then
    warn("[DOORS] createTab упал:", errTab)
    return
end

print("[DOORS] tabs['DOORS'] =", tostring(_tabs["DOORS"]))

-- Переставляем вкладку В САМЫЙ ВЕРХ (LayoutOrder = 0)
if _tabs["DOORS"] and _tabs["DOORS"].btn then
    pcall(function()
        _tabs["DOORS"].btn.LayoutOrder = 0
    end)
    print("[DOORS] LayoutOrder = 0 (вкладка поднята наверх)")
end

--========== КОНТЕНТ ВКЛАДКИ ==========
local doorsContent = _makeTabContent("DOORS")
if not doorsContent then
    warn("[DOORS] makeTabContent вернул nil")
    return
end

print("[DOORS] Контент вкладки создан")

local doorsLeft  = _createColumn(doorsContent, "left")
local doorsRight = _createColumn(doorsContent, "right")

print("[DOORS] Колонки созданы")

--========== НАСТРОЙКИ ==========
local DL_Lighting   = game:GetService("Lighting")
local DL_Players    = game:GetService("Players")
local DL_LP         = DL_Players.LocalPlayer

local Settings = {
    DoorESP    = false,
    EntityESP  = false,
    ItemESP    = false,
    ClosetESP  = false,
    ChestESP   = false,
    GoldESP    = false,
    Fullbright = false,
}

local ESPCache = {
    Door = {}, Entity = {}, Item = {},
    Closet = {}, Chest = {}, Gold = {},
}

local DefaultLighting = {
    Brightness     = DL_Lighting.Brightness,
    ClockTime      = DL_Lighting.ClockTime,
    FogEnd         = DL_Lighting.FogEnd,
    GlobalShadows  = DL_Lighting.GlobalShadows,
    Ambient        = DL_Lighting.Ambient,
    OutdoorAmbient = DL_Lighting.OutdoorAmbient,
}

local DoorsRunning = true

--========== ХЕЛПЕРЫ ==========
local function GetDistance(part)
    local myChar = DL_LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if myHRP and part and part.Parent then
        return math.floor((myHRP.Position - part.Position).Magnitude / 3.57)
    end
    return 0
end

local function ApplyESP(obj, text, color)
    if not obj or not obj.Parent then return end

    local hl = obj:FindFirstChild("OptHL")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "OptHL"
        hl.FillColor = color
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Adornee = obj
        hl.Parent = obj
    else
        if hl.FillColor ~= color then hl.FillColor = color end
    end

    local bb = obj:FindFirstChild("OptBB")
    if not bb then
        local adorneePart = obj:IsA("BasePart") and obj
            or obj.PrimaryPart
            or obj:FindFirstChildWhichIsA("BasePart")
        if adorneePart then
            bb = Instance.new("BillboardGui")
            bb.Name = "OptBB"
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(0, 140, 0, 25)
            bb.StudsOffset = Vector3.new(0, 2, 0)
            bb.Adornee = adorneePart

            local lbl = Instance.new("TextLabel")
            lbl.Name = "Txt"
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = color
            lbl.TextStrokeTransparency = 0
            lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            lbl.Font = Enum.Font.SourceSansBold
            lbl.TextSize = 13
            lbl.Text = text
            lbl.Parent = bb

            bb.Parent = obj
        end
    end
end

local function RemoveESP(obj)
    if not obj then return end
    local hl = obj:FindFirstChild("OptHL")
    if hl then hl:Destroy() end
    local bb = obj:FindFirstChild("OptBB")
    if bb then bb:Destroy() end
end

--========== UI: ESP ==========
print("[DOORS] Строю UI...")

local secESP = _createSection(doorsLeft, "ESP")

_createCheckbox(secESP, "Door ESP",   false, function(s) Settings.DoorESP   = s end)
_createCheckbox(secESP, "Entity ESP", false, function(s) Settings.EntityESP = s end)
_createCheckbox(secESP, "Item ESP",   false, function(s) Settings.ItemESP   = s end)
_createCheckbox(secESP, "Closet ESP", false, function(s) Settings.ClosetESP = s end)
_createCheckbox(secESP, "Chest ESP",  false, function(s) Settings.ChestESP  = s end)
_createCheckbox(secESP, "Gold ESP",   false, function(s) Settings.GoldESP   = s end)

--========== UI: WORLD ==========
local secWorld = _createSection(doorsLeft, "World")

_createCheckbox(secWorld, "Fullbright", false, function(s)
    Settings.Fullbright = s
    if not s then
        pcall(function()
            DL_Lighting.Brightness     = DefaultLighting.Brightness
            DL_Lighting.ClockTime      = DefaultLighting.ClockTime
            DL_Lighting.FogEnd         = DefaultLighting.FogEnd
            DL_Lighting.GlobalShadows  = DefaultLighting.GlobalShadows
            DL_Lighting.Ambient        = DefaultLighting.Ambient
            DL_Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
        end)
    end
end)

--========== UI: СТАТУС ==========
local secStatus = _createSection(doorsRight, "Статус")

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, 0, 0, 130)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Сканирование..."
statusLbl.TextColor3 = C_DIM
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 11
statusLbl.TextWrapped = true
statusLbl.TextYAlignment = Enum.TextYAlignment.Top
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.ZIndex = 55
statusLbl.Parent = secStatus

local function updateStatus()
    local hasRooms = workspace:FindFirstChild("CurrentRooms") and true or false
    local total = 0
    for _, cat in pairs(ESPCache) do total = total + #cat end

    statusLbl.Text = string.format(
        "PlaceId: %s\nCurrentRooms: %s\nВсего: %d\n\nДвери: %d\nМонстры: %d\nПредметы: %d\nШкафы: %d\nСундуки: %d\nЗолото: %d",
        tostring(game.PlaceId),
        hasRooms and "✓" or "✗",
        total,
        #ESPCache.Door,
        #ESPCache.Entity,
        #ESPCache.Item,
        #ESPCache.Closet,
        #ESPCache.Chest,
        #ESPCache.Gold
    )
    statusLbl.TextColor3 = hasRooms and C_GREEN or C_DIM
end

--========== UI: ДЕЙСТВИЯ ==========
local secAct = _createSection(doorsRight, "Действия")

_createButton(secAct, "Выключить всё", C_DARKER, function()
    for k in pairs(Settings) do
        if type(Settings[k]) == "boolean" then Settings[k] = false end
    end
    for _, cat in pairs(ESPCache) do
        for _, item in ipairs(cat) do
            if item.obj then pcall(function() RemoveESP(item.obj) end) end
        end
    end
    pcall(function()
        DL_Lighting.Brightness     = DefaultLighting.Brightness
        DL_Lighting.ClockTime      = DefaultLighting.ClockTime
        DL_Lighting.FogEnd         = DefaultLighting.FogEnd
        DL_Lighting.GlobalShadows  = DefaultLighting.GlobalShadows
        DL_Lighting.Ambient        = DefaultLighting.Ambient
        DL_Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
    end)
    if _G.NL_NotifyInfo then _G.NL_NotifyInfo("DOORS: всё выключено") end
end)

_createButton(secAct, "Очистить ESP", C_DARKER, function()
    for _, cat in pairs(ESPCache) do
        for _, item in ipairs(cat) do
            if item.obj then pcall(function() RemoveESP(item.obj) end) end
        end
    end
end)

_createButton(secAct, "Пересканировать", C_BLUE, function()
    updateStatus()
end)

print("[DOORS] UI построен ✓")

--========== SCAN LOOP ==========
task.spawn(function()
    while DoorsRunning and _G.NeverloseUILoaded do
        pcall(function()
            local CR = workspace:FindFirstChild("CurrentRooms")
            local nD, nI, nC, nCh, nG, nE = {}, {}, {}, {}, {}, {}

            if CR then
                for _, room in ipairs(CR:GetChildren()) do
                    local door = room:FindFirstChild("Door")
                    if door and door:FindFirstChild("Door") then
                        table.insert(nD, {obj = door, name = "Дверь", color = Color3.fromRGB(0, 255, 120)})
                    end

                    for _, obj in ipairs(room:GetDescendants()) do
                        if obj:IsA("Model") then
                            local n = obj.Name
                            if n == "Key" or n == "LiveHintBook" or n == "Lighter"
                                or n == "Lockpick" or n == "Flashlight" or n == "Crucifix"
                                or n == "SkeletonKey" or n == "Candle" or n == "Battery" then
                                table.insert(nI, {obj = obj, name = n, color = Color3.fromRGB(255, 255, 0)})
                            elseif n == "Wardrobe" or n == "Bed" then
                                table.insert(nC, {obj = obj, name = "Шкаф/Укрытие", color = Color3.fromRGB(180, 0, 255)})
                            elseif n == "ChestBox" or n == "ChestBoxLocked"
                                or n == "Chest" or n == "DrawerContainer" then
                                table.insert(nCh, {obj = obj, name = "Сундук", color = Color3.fromRGB(0, 195, 255)})
                            end
                        end

                        if (obj:IsA("Model") or obj:IsA("BasePart"))
                            and (obj.Name == "Gold" or obj.Name == "GoldPile" or obj.Name == "StolenGold") then
                            local t = obj:IsA("Model") and obj or obj.Parent
                            if t and t:IsA("Model") then
                                table.insert(nG, {obj = t, name = "Золото", color = Color3.fromRGB(255, 170, 0)})
                            end
                        end
                    end
                end
            end

            for _, ch in ipairs(workspace:GetChildren()) do
                if ch:IsA("Model") and (ch.Name == "RushMoving" or ch.Name == "AmbushMoving"
                    or ch.Name == "Figure" or ch.Name == "SeekMoving"
                    or ch.Name == "Screech" or ch.Name == "Eyes") then
                    table.insert(nE, {obj = ch, name = "⚠️ " .. ch.Name, color = Color3.fromRGB(255, 0, 50)})
                end
            end

            ESPCache.Door   = nD
            ESPCache.Item   = nI
            ESPCache.Closet = nC
            ESPCache.Chest  = nCh
            ESPCache.Gold   = nG
            ESPCache.Entity = nE
        end)

        task.wait(0.5)
    end
end)

--========== UPDATE LOOP ==========
task.spawn(function()
    local statusTimer = 0
    while DoorsRunning and _G.NeverloseUILoaded do
        pcall(function()
            if Settings.Fullbright then
                DL_Lighting.Brightness     = 2
                DL_Lighting.ClockTime      = 14
                DL_Lighting.FogEnd         = 100000
                DL_Lighting.GlobalShadows  = false
                DL_Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
                DL_Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            end

            local cats = {
                {data = ESPCache.Door,   enabled = Settings.DoorESP},
                {data = ESPCache.Entity, enabled = Settings.EntityESP},
                {data = ESPCache.Item,   enabled = Settings.ItemESP},
                {data = ESPCache.Closet, enabled = Settings.ClosetESP},
                {data = ESPCache.Chest,  enabled = Settings.ChestESP},
                {data = ESPCache.Gold,   enabled = Settings.GoldESP},
            }

            for _, cat in ipairs(cats) do
                for _, item in ipairs(cat.data) do
                    if cat.enabled and item.obj and item.obj.Parent then
                        ApplyESP(item.obj, item.name, item.color)
                        local bb = item.obj:FindFirstChild("OptBB")
                        if bb and bb:FindFirstChild("Txt") then
                            local part = item.obj:IsA("BasePart") and item.obj
                                or item.obj.PrimaryPart
                                or item.obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                bb.Txt.Text = item.name .. " [" .. tostring(GetDistance(part)) .. "m]"
                            end
                        end
                    else
                        if item.obj then RemoveESP(item.obj) end
                    end
                end
            end

            statusTimer = statusTimer + 0.1
            if statusTimer >= 1 then
                statusTimer = 0
                if statusLbl and statusLbl.Parent then
                    updateStatus()
                end
            end
        end)

        task.wait(0.1)
    end
end)

--========== UNLOAD ==========
_G.NL_UnloadDoors = function()
    DoorsRunning = false
    for _, cat in pairs(ESPCache) do
        for _, item in ipairs(cat) do
            if item.obj then pcall(function() RemoveESP(item.obj) end) end
        end
    end
end

--========== СТАРТ ==========
updateStatus()

task.spawn(function()
    task.wait(1)
    if not _G.NeverloseUILoaded then return end
    if _G.NL_NotifyOK then
        _G.NL_NotifyOK("DOORS: вкладка готова")
    end

    local hasRooms = workspace:FindFirstChild("CurrentRooms") and true or false
    if not hasRooms then
        print("[DOORS] ⚠ CurrentRooms не найден — ты не в DOORS?")
    else
        print("[DOORS] ✓ CurrentRooms найден")
    end
end)

print("========================================")
print("[DOORS] Загружено! Ищи вкладку 'DOORS' вверху сайдбара.")
print("========================================")
