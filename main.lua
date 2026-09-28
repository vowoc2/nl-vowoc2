--=========================================================
-- NEVERLOSE UI — 1/12 (ФИКС: ScreenGui поверх всего + Watermark)
--=========================================================

if _G.NeverloseUILoaded then
    return warn("[NL] Уже запущено")
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
-- ✅ ИСПРАВЛЕНИЕ: ScreenGui поверх ВСЕГО (включая CoreGui)
--=========================================================
ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NL"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true

-- Пытаемся посадить в gethui() → потом CoreGui → потом PlayerGui
local parented = false
if type(gethui) == "function" then
    local ok, hui = pcall(gethui)
    if ok and hui then
        ScreenGui.Parent = hui
        parented = true
    end
end

if not parented then
    local ok = pcall(function() ScreenGui.Parent = CoreGui end)
    if ok then parented = true end
end

if not parented then
    ScreenGui.Parent = PG
end

pcall(function() ScreenGui.DisplayOrder = 999999 end)

-- Скрываем топбар Roblox во время работы скрипта (чтобы ничего не торчало)
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
-- ✅ ИСПРАВЛЕНИЕ WATERMARK: фиксированные размеры вместо AutomaticSize
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        wmDrag = true
        wmSM = Vector2.new(input.Position.X, input.Position.Y)
        local ap = WM.AbsolutePosition
        WM.AnchorPoint = Vector2.new(0, 0)
        WM.Position = UDim2.new(0, ap.X, 0, ap.Y)
        wmSP = Vector2.new(ap.X, ap.Y)
    end
end)

UIS.InputChanged:Connect(function(input)
    if wmDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = Vector2.new(input.Position.X, input.Position.Y) - wmSM
        local nx, ny = wmSP.X + d.X, wmSP.Y + d.Y
        local vp = Cam and Cam.ViewportSize or Vector2.new(1920, 1080)
        local ws = WM.AbsoluteSize
        nx = math.clamp(nx, 0, math.max(0, vp.X - ws.X))
        ny = math.clamp(ny, 0, math.max(0, vp.Y - ws.Y))
        WM.Position = UDim2.new(0, nx, 0, ny)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        wmDrag = false
    end
end)

--========== MAIN FRAME ==========
MainFrame = Instance.new("Frame")
local initSize = getMenuSize()
MainFrame.Size = UDim2.new(0, initSize.w, 0, initSize.h)
MainFrame.Position = UDim2.new(0.5, -initSize.w / 2, 0.5, -initSize.h / 2)
MainFrame.BackgroundColor3 = NL_DARK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
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
            t.btn.BackgroundTransparency = 1
            t.btn.TextColor3 = NL_DIM
            t.ind.Visible = false
        end
        b.BackgroundTransparency = 0.85
        b.BackgroundColor3 = NL_BLUE
        b.TextColor3 = NL_TEXT
        ind.Visible = true
        activeTab = name
        if contentFrame then contentFrame.Visible = false end
        if tabs[name] and tabs[name].content then
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

-- ✅ Создаём все вкладки заранее
local TAB_ORDER = {"Visuals", "Misc", "Teleport", "Cursor TP", "Baritone", "Fling", "HUD", "Config", "Settings"}
for _, name in ipairs(TAB_ORDER) do createTab(name) end

-- ✅ Хелпер контейнера вкладки
function makeTabContent(tabName)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 0)
    c.BackgroundTransparency = 1
    c.AutomaticSize = Enum.AutomaticSize.Y
    c.Visible = false
    c.ZIndex = 52
    c.Parent = ContentArea
    tabs[tabName].content = c
    return c
end

--========== BUILDERS ==========
function createColumn(parent)
    local col = Instance.new("Frame")
    col.Size = UDim2.new(0.5, -8, 0, 0)
    col.BackgroundTransparency = 1
    col.AutomaticSize = Enum.AutomaticSize.Y
    col.ZIndex = 52
    col.Parent = parent
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, 10)
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
    l.Parent = ct

    local p = Instance.new("UIPadding")
    p.PaddingBottom = UDim.new(0, 12)
    p.PaddingLeft = UDim.new(0, 10)
    p.PaddingRight = UDim.new(0, 10)
    p.Parent = ct

    return ct
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
    if btn then
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

--========== CHECKBOX ==========
function createCheckbox(parent, text, default, callback, bindAction)
    local cf = Instance.new("Frame")
    cf.Size = UDim2.new(1, 0, 0, 26)
    cf.BackgroundTransparency = 1
    cf.ZIndex = 54
    cf.Parent = parent

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -52, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = ""
    b.ZIndex = 55
    b.Parent = cf

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 16, 0, 16)
    box.Position = UDim2.new(0, 2, 0.5, -8)
    box.BackgroundColor3 = default and NL_BLUE or NL_DARKER
    box.BorderSizePixel = 0
    box.ZIndex = 55
    box.Parent = b

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 3)
    bc.Parent = box

    local bs = Instance.new("UIStroke")
    bs.Color = NL_BLUE
    bs.Thickness = 1
    bs.Transparency = default and 0 or 0.6
    bs.Parent = box
    registerAccent(bs, "Color")

    local ch = Instance.new("TextLabel")
    ch.Size = UDim2.new(1, 0, 1, 0)
    ch.BackgroundTransparency = 1
    ch.Text = "v"
    ch.TextColor3 = NL_WHITE
    ch.Font = Enum.Font.GothamBold
    ch.TextSize = 10
    ch.TextTransparency = default and 0 or 1
    ch.ZIndex = 56
    ch.Parent = box

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -24, 1, 0)
    lb.Position = UDim2.new(0, 24, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = text
    lb.TextColor3 = NL_TEXT
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.ZIndex = 55
    lb.Parent = b

    local bb = Instance.new("TextButton")
    bb.Size = UDim2.new(0, 46, 0, 20)
    bb.Position = UDim2.new(1, -46, 0.5, -10)
    bb.BackgroundColor3 = NL_DARKER
    bb.BorderSizePixel = 0
    bb.Text = "[None]"
    bb.TextColor3 = NL_DIM
    bb.Font = Enum.Font.Gotham
    bb.TextSize = 10
    bb.ZIndex = 56
    bb.Parent = cf

    local bbc = Instance.new("UICorner")
    bbc.CornerRadius = UDim.new(0, 3)
    bbc.Parent = bb

    local bbs = Instance.new("UIStroke")
    bbs.Color = NL_BLUE
    bbs.Thickness = 1
    bbs.Transparency = 0.7
    bbs.Parent = bb
    registerAccent(bbs, "Color")

    local state = default
    local cb = callback

    local function toggle()
        state = not state
        tween(box, 0.15, {BackgroundColor3 = state and NL_BLUE or NL_DARKER})
        tween(bs, 0.15, {Transparency = state and 0 or 0.6})
        tween(ch, 0.15, {TextTransparency = state and 0 or 1})
        if cb then pcall(cb, state) end
    end

    b.MouseButton1Click:Connect(toggle)
    if bindAction then BindCallbacks[bindAction] = toggle end

    bb.MouseButton1Click:Connect(function()
        startListeningForBind(bb, bindAction)
    end)
end

--========== SLIDER ==========
function createSlider(parent, text, min, max, default, callback, isColor, channel)
    min = tonumber(min) or 0
    max = tonumber(max) or 100
    default = tonumber(default) or min
    if max <= min then max = min + 1 end

    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(1, 0, 0, 40)
    sf.BackgroundTransparency = 1
    sf.ZIndex = 54
    sf.Parent = parent

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.6, 0, 0, 18)
    lb.Position = UDim2.new(0, 2, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = text
    lb.TextColor3 = NL_TEXT
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.ZIndex = 55
    lb.Parent = sf

    local chCol = NL_BLUE
    if isColor then
        if channel == "R" then chCol = Color3.fromRGB(255, 60, 60)
        elseif channel == "G" then chCol = Color3.fromRGB(60, 220, 60)
        elseif channel == "B" then chCol = Color3.fromRGB(60, 140, 255) end
    end

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0.4, -4, 0, 18)
    vl.Position = UDim2.new(0.6, 2, 0, 0)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(default)
    vl.TextColor3 = isColor and chCol or NL_BLUE
    vl.Font = Enum.Font.GothamBold
    vl.TextSize = 12
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.ZIndex = 55
    vl.Parent = sf
    if not isColor then registerAccent(vl, "TextColor3") end

    local tr = Instance.new("Frame")
    tr.Size = UDim2.new(1, -4, 0, 4)
    tr.Position = UDim2.new(0, 2, 0, 28)
    tr.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tr.BorderSizePixel = 0
    tr.ZIndex = 55
    tr.Parent = sf

    local trc = Instance.new("UICorner")
    trc.CornerRadius = UDim.new(1, 0)
    trc.Parent = tr

    local fl = Instance.new("Frame")
    fl.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fl.BackgroundColor3 = isColor and chCol or NL_BLUE
    fl.BorderSizePixel = 0
    fl.ZIndex = 56
    fl.Parent = tr
    if not isColor then registerAccent(fl, "BackgroundColor3") end

    local fc2 = Instance.new("UICorner")
    fc2.CornerRadius = UDim.new(1, 0)
    fc2.Parent = fl

    local th = Instance.new("Frame")
    th.Size = UDim2.new(0, 12, 0, 12)
    th.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    th.BackgroundColor3 = NL_WHITE
    th.BorderSizePixel = 0
    th.ZIndex = 57
    th.Parent = tr

    local thc = Instance.new("UICorner")
    thc.CornerRadius = UDim.new(1, 0)
    thc.Parent = th

    local v = default
    local dg = false
    local cb = callback

    local function upd(input)
        local rel = math.clamp((input.Position.X - tr.AbsolutePosition.X) / tr.AbsoluteSize.X, 0, 1)
        v = math.floor(min + (max - min) * rel + 0.5)
        local a = (v - min) / (max - min)
        fl.Size = UDim2.new(a, 0, 1, 0)
        th.Position = UDim2.new(a, -6, 0.5, -6)
        vl.Text = tostring(v)
        if cb then pcall(cb, v) end
    end

    tr.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dg = true
            upd(input)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dg and input.UserInputType == Enum.UserInputType.MouseMovement then
            upd(input)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dg = false
        end
    end)
end

--========== CYCLE ==========
function createCycle(parent, text, options, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundTransparency = 1
    f.ZIndex = 54
    f.Parent = parent

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(0.55, 0, 1, 0)
    lb.Position = UDim2.new(0, 2, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = text
    lb.TextColor3 = NL_TEXT
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.ZIndex = 55
    lb.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.45, -4, 0, 22)
    b.Position = UDim2.new(0.55, 2, 0.5, -11)
    b.BackgroundColor3 = NL_DARKER
    b.BorderSizePixel = 0
    b.Text = default
    b.TextColor3 = NL_BLUE
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.ZIndex = 55
    b.Parent = f

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.Color = NL_BLUE
    s.Thickness = 1
    s.Transparency = 0.5
    s.Parent = b
    registerAccent(s, "Color")
    registerAccent(b, "TextColor3")

    local i = 1
    for k, o in ipairs(options) do
        if o == default then i = k break end
    end
    local cb = callback

    b.MouseButton1Click:Connect(function()
        i = i + 1
        if i > #options then i = 1 end
        b.Text = options[i]
        if cb then pcall(cb, options[i]) end
    end)

    b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundColor3 = NL_BLUE, TextColor3 = NL_TEXT}) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = NL_DARKER, TextColor3 = NL_BLUE}) end)
end

--========== BUTTON ==========
function createButton(parent, text, color, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = color or NL_BLUE
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = NL_WHITE
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.ZIndex = 55
    b.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = b

    b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0.2}) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0}) end)
    if callback then b.MouseButton1Click:Connect(callback) end
    return b
end

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

--========== JUMP APPLY ==========
function applyJump()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if not Cheat.Jump then
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
        if Cheat.Jump then
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

print("[NL] 1/12 — База загружена")
--=========================================================
-- NEVERLOSE UI — 2/12
-- Функции чита: Fly, Speed, Noclip, Bhop, Spin, Spider,
-- InfJump, FullBright, BlackSky, Snow, WorldColor, Fog,
-- AutoClicker, ESP, Cone Hat
--=========================================================

--========== FLY ==========
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

--========== SPEED ==========
function applySpeed()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Cheat.Speed and Cheat.SpeedValue or 16
    end
end

speedConn = RunService.Heartbeat:Connect(function()
    if not _G.NeverloseUILoaded then return end
    if not Cheat.Speed then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and math.abs(hum.WalkSpeed - Cheat.SpeedValue) > 0.5 then
        hum.WalkSpeed = Cheat.SpeedValue
    end
end)

--========== NOCLIP ==========
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

--========== BUNNY HOP ==========
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

--========== SPIN BOT ==========
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

--========== SPIDER ==========
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

--========== INFINITE JUMP ==========
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

--========== FULLBRIGHT ==========
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

--========== BLACK SKY ==========
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

--========== WORLD COLOR ==========
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

--========== FOG ==========
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

--========== SNOW ==========
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
        NumberSequenceKeypoint.new(1, 0.2)
    })
    emit.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.85, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    emit.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 230, 255))
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

--========== AUTO CLICKER ==========
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

--========== ESP ==========
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

--========== CONE HAT ==========
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

--========== RESPAWN ==========
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

print("[NL] 2/12 — Функции чита загружены")
--=========================================================
-- NEVERLOSE UI — 3/12
-- Вкладки: Visuals / Misc / Settings
--=========================================================

--=========================================================
-- VISUALS
--=========================================================
visualsContent = makeTabContent("Visuals")
visLeft  = createColumn(visualsContent); visLeft.Position  = UDim2.new(0, 0, 0, 0)
visRight = createColumn(visualsContent); visRight.Position = UDim2.new(0.5, 8, 0, 0)

-- Players
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

-- World
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

-- World Color
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

-- Fog
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
miscLeft  = createColumn(miscContent); miscLeft.Position  = UDim2.new(0, 0, 0, 0)
miscRight = createColumn(miscContent); miscRight.Position = UDim2.new(0.5, 8, 0, 0)

-- Movement
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
    if s then
        applySpeed()
    else
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end, "Speed")

createSlider(moveSec, "Speed Value", 16, 200, 16, function(v)
    Cheat.SpeedValue = v
    if Cheat.Speed then applySpeed() end
end)

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

-- Jump
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

-- Auto Clicker
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

-- Other
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

-- Protection
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
settingsInfo.Size = UDim2.new(1, -40, 0, 60)
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
unloadBtn.Position = UDim2.new(0.5, -130, 0, 140)
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

-- ✅ ЕДИНСТВЕННАЯ функция unloadScript
function unloadScript()
    _G.NeverloseUILoaded = nil

    if disableFly then pcall(disableFly) end
    if disableNoclip then pcall(disableNoclip) end
    if disableInfJump then pcall(disableInfJump) end
    if disableFullBright then pcall(disableFullBright) end
    if disableBlackSky then pcall(disableBlackSky) end
    if disableSnow then pcall(disableSnow) end
    if disableBunnyHop then pcall(disableBunnyHop) end
    if disableSpinBot then pcall(disableSpinBot) end
    if disableFog then pcall(disableFog) end
    if disableSpider then pcall(disableSpider) end
    if restoreWorldColor then pcall(restoreWorldColor) end
    if _G.NL_RemoveHat then pcall(_G.NL_RemoveHat) end

    if _G.NL_UnloadTP then pcall(_G.NL_UnloadTP) end
    if _G.NL_UnloadCTP then pcall(_G.NL_UnloadCTP) end
    if _G.NL_UnloadBT then pcall(_G.NL_UnloadBT) end
    if _G.NL_UnloadFling then pcall(_G.NL_UnloadFling) end
    if _G.NL_UnloadProtect then pcall(_G.NL_UnloadProtect) end
    if _G.NL_UnloadHUD then pcall(_G.NL_UnloadHUD) end

    Cheat.ESP = false
    Cheat.AutoClicker = false
    Cheat.Jump = false

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

    -- ✅ Возвращаем топбар на место
    pcall(function()
        local sg = game:GetService("StarterGui")
        sg:SetCore("TopbarEnabled", true)
    end)

    if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
end

unloadBtn.MouseButton1Click:Connect(unloadScript)

--========== RESIZE HANDLE ==========
resizeButton = Instance.new("TextButton")
resizeButton.Size = UDim2.new(0, 26, 0, 26)
resizeButton.Position = UDim2.new(1, -26, 1, -26)
resizeButton.BackgroundTransparency = 1
resizeButton.Text = ""
resizeButton.ZIndex = 300
resizeButton.Parent = MainFrame

resizeHandle = Instance.new("Frame")
resizeHandle.Size = UDim2.new(0, 16, 0, 16)
resizeHandle.Position = UDim2.new(1, -16, 1, -16)
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isResizing = true
        resizeStartSize = {x = MainFrame.AbsoluteSize.X, y = MainFrame.AbsoluteSize.Y}
        resizeStartPos = {x = input.Position.X, y = input.Position.Y}
        tween(resizeHandle, 0.1, {BackgroundTransparency = 0.2})
    end
end)

UIS.InputChanged:Connect(function(input)
    if isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local dx = input.Position.X - resizeStartPos.x
        local dy = input.Position.Y - resizeStartPos.y
        MainFrame.Size = UDim2.new(
            0, math.max(520, resizeStartSize.x + dx),
            0, math.max(400, resizeStartSize.y + dy)
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and isResizing then
        isResizing = false
        tween(resizeHandle, 0.15, {BackgroundTransparency = 0.6})
    end
end)

--========== KEYBIND LISTENER ==========
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

--========== DEFAULT TAB ==========
tabs["Settings"].btn.BackgroundTransparency = 0.85
tabs["Settings"].btn.BackgroundColor3 = NL_BLUE
tabs["Settings"].btn.TextColor3 = NL_TEXT
tabs["Settings"].ind.Visible = true
activeTab = "Settings"
contentFrame = settingsContent
settingsContent.Visible = true

--========== INSERT TOGGLE ==========
menuVisible = true
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not _G.NeverloseUILoaded then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuVisible = not menuVisible
        MainFrame.Visible = menuVisible
    end
end)

print("[NL] 3/12 — Visuals / Misc / Settings загружены")
--=========================================================
-- NEVERLOSE UI — 4/12
-- Вкладка Teleport: список игроков, координаты, сохранение
--=========================================================
tpContent = makeTabContent("Teleport")
tpLeft  = createColumn(tpContent); tpLeft.Position  = UDim2.new(0, 0, 0, 0)
tpRight = createColumn(tpContent); tpRight.Position = UDim2.new(0.5, 8, 0, 0)

--========== TELEPORT FUNCTIONS ==========
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

--========== PLAYER LIST ==========
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
tpListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
tpListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
tpListFrame.ZIndex = 54
tpListFrame.Parent = tpPlayersSec
registerAccent(tpListFrame, "ScrollBarImageColor3")

local tll = Instance.new("UIListLayout")
tll.Padding = UDim.new(0, 6)
tll.Parent = tpListFrame

tpEntries = {}

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
    avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=48&h=48"
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

    tpEntries[plr] = entry

    task.spawn(function()
        while entry.Parent and _G.NeverloseUILoaded do
            local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            if hpL and hpL.Parent then
                if hum then
                    hpL.Text = "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                else
                    hpL.Text = "HP: --"
                end
            end
            task.wait(0.5)
        end
    end)
end

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
            if filter == "" or name:find(filter, 1, true) or display:find(filter, 1, true) then
                createTPEntry(plr)
                count = count + 1
            end
        end
    end
    if tpCountLabel and tpCountLabel.Parent then
        tpCountLabel.Text = "Игроков: " .. count
    end
end

tpSearchBox:GetPropertyChangedSignal("Text"):Connect(refreshTPList)

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    refreshTPList()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    refreshTPList()
end)

task.spawn(function()
    while _G.NeverloseUILoaded do
        task.wait(5)
        if tpContent and tpContent.Parent then
            refreshTPList()
        end
    end
end)

refreshTPList()

--========== COORDINATES ==========
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
boxX.Text = "0"
boxY = makeCoordInput("Y:")
boxY.Text = "50"
boxZ = makeCoordInput("Z:")
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

--========== SAVE POSITION ==========
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
        savedLabel.Text = string.format("Сохранено: (%.0f, %.0f, %.0f)",
            hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
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

--========== UNLOAD ==========
_G.NL_UnloadTP = function()
    for _, e in pairs(tpEntries) do
        if e and e.Parent then e:Destroy() end
    end
    tpEntries = {}
end

print("[NL] 4/12 — Teleport загружен")
--=========================================================
-- NEVERLOSE UI — 5/12
-- Вкладка Cursor TP: телепорт к курсору
--=========================================================
ctpContent = makeTabContent("Cursor TP")
ctpLeft  = createColumn(ctpContent); ctpLeft.Position  = UDim2.new(0, 0, 0, 0)
ctpRight = createColumn(ctpContent); ctpRight.Position = UDim2.new(0.5, 8, 0, 0)

--========== STATE ==========
ctpSettings = {
    heightOffset   = 3,
    maxDistance    = 500,
    useRaycast     = true,
    blockIfHazard  = false,
    hazardKeywords = {"kill", "lava", "damage", "death", "spike", "hazard", "void"},
}

--========== HAZARD CHECK ==========
function ctpIsHazard(part)
    if not part or not ctpSettings.blockIfHazard then return false end
    local n = string.lower(part.Name or "")
    for _, kw in ipairs(ctpSettings.hazardKeywords) do
        if string.find(n, kw, 1, true) then return true end
    end
    return false
end

--========== GET POSITION UNDER CURSOR ==========
function getCursorWorldPos()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local mouse = LP:GetMouse()
    if not mouse then return nil end

    local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)

    if ctpSettings.useRaycast then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local filterList = {}
        if LP.Character then table.insert(filterList, LP.Character) end
        if espFolder then table.insert(filterList, espFolder) end
        params.FilterDescendantsInstances = filterList

        local result = workspace:Raycast(ray.Origin, ray.Direction * ctpSettings.maxDistance, params)
        if result then
            if ctpIsHazard(result.Instance) then return nil end
            return result.Position, result.Instance
        end
    end

    return ray.Origin + ray.Direction * ctpSettings.maxDistance, nil
end

--========== TELEPORT TO CURSOR ==========
function tpToCursor()
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

--========== UI: MAIN ==========
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
ctpBtn.ZIndex = 55
ctpBtn.Parent = ctpContainer
registerAccent(ctpBtn, "BackgroundColor3")

local ctpc = Instance.new("UICorner")
ctpc.CornerRadius = UDim.new(0, 5)
ctpc.Parent = ctpBtn

ctpBtn.MouseButton1Click:Connect(tpToCursor)

ctpBindBtn = Instance.new("TextButton")
ctpBindBtn.Size = UDim2.new(0, 46, 0, 22)
ctpBindBtn.Position = UDim2.new(1, -46, 0.5, -11)
ctpBindBtn.BackgroundColor3 = NL_DARKER
ctpBindBtn.BorderSizePixel = 0
ctpBindBtn.Text = "[None]"
ctpBindBtn.TextColor3 = NL_DIM
ctpBindBtn.Font = Enum.Font.Gotham
ctpBindBtn.TextSize = 10
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

--========== SETTINGS ==========
ctpSetSec = createSection(ctpLeft, "Настройки")

createSlider(ctpSetSec, "Высота над полом", 0, 20, 3, function(v)
    ctpSettings.heightOffset = v
end)

createSlider(ctpSetSec, "Макс. дистанция", 50, 2000, 500, function(v)
    ctpSettings.maxDistance = v
end)

createCheckbox(ctpSetSec, "Raycast (к поверхности)", true, function(v)
    ctpSettings.useRaycast = v
end, "CTP_Raycast")

createCheckbox(ctpSetSec, "Блокировать опасные блоки", false, function(v)
    ctpSettings.blockIfHazard = v
end, "CTP_BlockHazard")

--========== QUICK ACTIONS ==========
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

--========== INFO ==========
ctpInfoSec = createSection(ctpRight, "Информация")

ctpInfoLabel = Instance.new("TextLabel")
ctpInfoLabel.Size = UDim2.new(1, 0, 0, 100)
ctpInfoLabel.BackgroundTransparency = 1
ctpInfoLabel.Text = "1. Наведи курсор на точку\n2. Нажми бинд (или кнопку)\n3. Телепортируешься туда\n\nRaycast ON — ТП к поверхности\nRaycast OFF — ТП в точку на луче"
ctpInfoLabel.TextColor3 = NL_DIM
ctpInfoLabel.Font = Enum.Font.Gotham
ctpInfoLabel.TextSize = 11
ctpInfoLabel.TextWrapped = true
ctpInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
ctpInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
ctpInfoLabel.ZIndex = 55
ctpInfoLabel.Parent = ctpInfoSec

--========== UNLOAD ==========
_G.NL_UnloadCTP = function()
    if ctpContent and ctpContent.Parent then
        ctpContent:Destroy()
    end
end

print("[NL] 5/12 — Cursor TP загружен")
--=========================================================
-- NEVERLOSE UI — 6/12
-- Вкладка Baritone: AI-навигация с паркуром и hazard-детектом
--=========================================================
btContent = makeTabContent("Baritone")
btLeft  = createColumn(btContent); btLeft.Position  = UDim2.new(0, 0, 0, 0)
btRight = createColumn(btContent); btRight.Position = UDim2.new(0.5, 8, 0, 0)

--========== STATE ==========
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

function btLog(...) if btS.debug then print("[Baritone]", ...) end end

--========== RUNTIME ==========
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

--========== CREATE WORKSPACE OBJECTS ==========
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

--========== VISUALS ==========
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
    if not btS.showPath or not wps or not btTracerFolder or not btTracerFolder.Parent then return end

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
            p.Color = (i == #wps - 1) and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(0, 170, 255)
            p.Transparency = 0.45
            p.Size = Vector3.new(0.3, 0.3, d)
            p.CFrame = CFrame.new(a.Position, b.Position) * CFrame.new(0, 0, -d / 2)
            p.Parent = btTracerFolder
        end
    end
end

--========== RAYCAST ==========
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
    local mouse = LP:GetMouse()
    if not mouse then return Vector3.new(0, 50, 0) end
    local ray = cam:ScreenPointToRay(mouse.X, mouse.Y)
    local hit = workspace:Raycast(ray.Origin, ray.Direction * 1000, btNewRayParams())
    if hit then return hit.Position end
    return ray.Origin + ray.Direction * 500
end

--========== HAZARD ==========
btKillKeywords = {
    "kill", "lava", "damage", "death", "spike",
    "hazard", "fire", "poison", "trap", "insta",
    "void", "burn", "dead"
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
    local res = workspace:Raycast(
        pos + Vector3.new(0, 2, 0),
        Vector3.new(0, -depth, 0),
        btNewRayParams()
    )
    if not res then return nil, nil, false end
    return res.Position, res.Instance, btIsHazard(res.Instance)
end

--========== MEMORY ==========
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

--========== SIMULATE JUMP ==========
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

--========== DETECT ==========
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

        local res1 = workspace:Raycast(
            hrp.Position - Vector3.new(0, 2, 0),
            d * btS.scanDist,
            btNewRayParams()
        )
        if res1 and btIsHazard(res1.Instance) then return true, d end

        local res2 = workspace:Raycast(
            hrp.Position + Vector3.new(0, 1, 0),
            d * btS.scanDist,
            btNewRayParams()
        )
        if res2 and btIsHazard(res2.Instance) then return true, d end
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
    local res = workspace:Raycast(origin, dir * 5, btNewRayParams())
    if res and res.Instance then
        local top = res.Instance.Position.Y + res.Instance.Size.Y / 2
        if top > hrp.Position.Y + 3 then return res.Instance end
    end
    return nil
end

--========== BOOST ==========
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

--========== WORLD MONITOR ==========
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

--========== BRAIN ==========
btBrainConn = RunService.Heartbeat:Connect(function()
    if not _G.NeverloseUILoaded then return end
    if not btS.running then return end

    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
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
                local res = workspace:Raycast(origin, Vector3.new(0, -3, 0), btNewRayParams())
                local h = res and btIsHazard(res.Instance)
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

--========== PATHFINDING ==========
function btBuildPath(fromPos, targetPos)
    local path = Pathfinding:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = btS.autoJump or btS.parkourMode,
        WaypointSpacing = btS.wpSpacing,
    })

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
            local res = workspace:Raycast(
                a.Position + Vector3.new(0, 1, 0),
                dir.Unit * dist,
                btNewRayParams()
            )
            if res and res.Instance and not btIsHazard(res.Instance) then
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

--========== MOVEMENT LOOP ==========
function btMovementLoop()
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
                if tick() % 3 < 0.06 then
                    local _, hit, haz = btGroundBelow(hrp.Position, 6)
                    if hit and not haz then
                        btMemAdd(btMemory.hazards, hrp.Position)
                    end
                end

                if (hrp.Position - btS.target).Magnitude < 4 then
                    break
                end

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
                        btCurrentWps = {{Position = btS.target, Action = Enum.PathWaypointAction.Walk}}
                        btCurrentIdx = 1
                        btDrawPath(btCurrentWps)
                    end
                end

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
    if btMarker then btMarker.Transparency = 0.4 end
    btClearTracer()
end

--========== CONTROL ==========
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

--========== SPEED GUARD ==========
btSpeedConn = RunService.Heartbeat:Connect(function()
    if not _G.NeverloseUILoaded then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if not btS.adaptiveSpeed and btS.running and hum.WalkSpeed ~= btS.speed then
            hum.WalkSpeed = btS.speed
        end
        if not btLockJumpPower and hum.UseJumpPower and hum.JumpPower ~= btS.jumpPower then
            hum.JumpPower = btS.jumpPower
        end
    end
end)

--========== BINDABLE BUTTON HELPER ==========
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

--========== UI: MAIN ==========
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
createSlider(btSecBoost, "Длительность x100", 5, 50, 20, function(v) btS.boostDuration = v / 100 end)

--========== HAZARD ==========
btSecHaz = createSection(btLeft, "Hazard")
createCheckbox(btSecHaz, "Избегать kill-блоков", true, function(v) btS.avoidKill = v end, "BT_AvoidKill")

createSlider(btSecHaz, "Hazard R", 0, 255, 255, function(v)
    btS.hazardColor = Color3.fromRGB(v, math.floor(btS.hazardColor.G * 255), math.floor(btS.hazardColor.B * 255))
end, true, "R")

createSlider(btSecHaz, "Hazard G", 0, 255, 0, function(v)
    btS.hazardColor = Color3.fromRGB(math.floor(btS.hazardColor.R * 255), v, math.floor(btS.hazardColor.B * 255))
end, true, "G")

createSlider(btSecHaz, "Hazard B", 0, 255, 0, function(v)
    btS.hazardColor = Color3.fromRGB(math.floor(btS.hazardColor.R * 255), math.floor(btS.hazardColor.G * 255), v)
end, true, "B")

createSlider(btSecHaz, "Допуск цвета x100", 1, 30, 12, function(v) btS.colorTol = v / 100 end)
createSlider(btSecHaz, "Скан вперёд", 10, 50, 30, function(v) btS.scanDist = v end)
createSlider(btSecHaz, "Макс. сила прыжка", 50, 400, 350, function(v) btS.maxJumpPower = v end)

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

--========== UNLOAD ==========
_G.NL_UnloadBT = function()
    btStop()
    if btBrainConn then btBrainConn:Disconnect() end
    if btSpeedConn then btSpeedConn:Disconnect() end
    if btWorldConn then btWorldConn:Disconnect() end
    if btMarker and btMarker.Parent then btMarker:Destroy() end
    if btMemFolder and btMemFolder.Parent then btMemFolder:Destroy() end
    if btTracerFolder and btTracerFolder.Parent then btTracerFolder:Destroy() end
end

print("[NL] 6/12 — Baritone загружен")
--=========================================================
-- NEVERLOSE UI — 7/12
-- Экран загрузки с прогресс-баром + защита от зависания
--=========================================================

-- Скрываем меню и водяной знак на время загрузки
if MainFrame then MainFrame.Visible = false end
if WM then WM.Visible = false end

-- ✅ Таймаут: если лоадер жив 20 сек — принудительно закрываем
task.delay(20, function()
    if LoadingFrame and LoadingFrame.Parent then
        warn("[NL] Loader timeout — принудительное закрытие")
        pcall(function() LoadingFrame:Destroy() end)
        if bgBlur and bgBlur.Parent then
            pcall(function() bgBlur:Destroy() end)
        end
        if WM then WM.Visible = true end
        if MainFrame then
            MainFrame.Visible = true
            local sz = getMenuSize()
            MainFrame.Size = UDim2.new(0, sz.w, 0, sz.h)
            MainFrame.Position = UDim2.new(0.5, -sz.w / 2, 0.5, -sz.h / 2)
        end
    end
end)

LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "NL_Loading"
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 500
LoadingFrame.Parent = ScreenGui

bgBlur = Instance.new("BlurEffect")
bgBlur.Size = 0
bgBlur.Parent = Lighting

--========== LOGO ==========
BigLogo = Instance.new("TextLabel")
BigLogo.Size = UDim2.new(0, 400, 0, 150)
BigLogo.Position = UDim2.new(0.5, -200, 0.5, -140)
BigLogo.BackgroundTransparency = 1
BigLogo.Text = "NL"
BigLogo.TextColor3 = NL_BLUE
BigLogo.Font = Enum.Font.GothamBlack
BigLogo.TextSize = 110
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

--========== PROGRESS BAR ==========
ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(0, 400, 0, 4)
ProgressBg.Position = UDim2.new(0.5, -200, 0.5, 60)
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

--========== PERCENT ==========
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

--========== STATUS ==========
StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 400, 0, 20)
StatusLabel.Position = UDim2.new(0.5, -200, 0.5, 100)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Инициализация..."
StatusLabel.TextColor3 = NL_DIM
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextTransparency = 1
StatusLabel.ZIndex = 501
StatusLabel.Parent = LoadingFrame

--========== VERSION ==========
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

--========== BOTTOM LINE ==========
BottomLine = Instance.new("Frame")
BottomLine.Size = UDim2.new(1, 0, 0, 2)
BottomLine.Position = UDim2.new(0, 0, 1, -2)
BottomLine.BackgroundColor3 = NL_BLUE
BottomLine.BorderSizePixel = 0
BottomLine.BackgroundTransparency = 1
BottomLine.ZIndex = 501
BottomLine.Parent = LoadingFrame
registerAccent(BottomLine, "BackgroundColor3")

--========== ANIMATION ==========
task.spawn(function()
    -- Fade in
    tween(bgBlur, 0.6, {Size = 25})
    task.wait(0.2)
    if not _G.NeverloseUILoaded then return end

    tween(BigLogo, 0.5, {TextTransparency = 0})
    tween(BrandLabel, 0.5, {TextTransparency = 0})
    tween(ProgressBg, 0.5, {BackgroundTransparency = 0})
    tween(PercentLabel, 0.5, {TextTransparency = 0})
    tween(StatusLabel, 0.5, {TextTransparency = 0})
    tween(VersionLabel, 0.5, {TextTransparency = 0})
    tween(BottomLine, 0.5, {BackgroundTransparency = 0})

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
    tween(LoadingFrame, 0.5, {BackgroundTransparency = 1})
    tween(BigLogo, 0.4, {TextTransparency = 1})
    tween(BrandLabel, 0.4, {TextTransparency = 1})
    tween(ProgressBg, 0.4, {BackgroundTransparency = 1})
    tween(ProgressFill, 0.4, {BackgroundTransparency = 1})
    tween(PercentLabel, 0.4, {TextTransparency = 1})
    tween(StatusLabel, 0.4, {TextTransparency = 1})
    tween(VersionLabel, 0.4, {TextTransparency = 1})
    tween(BottomLine, 0.4, {BackgroundTransparency = 1})
    tween(bgBlur, 0.5, {Size = 0})

    task.wait(0.6)

    if LoadingFrame and LoadingFrame.Parent then LoadingFrame:Destroy() end
    if bgBlur and bgBlur.Parent then bgBlur:Destroy() end

    if WM then WM.Visible = true end

    if MainFrame then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

        local sz = getMenuSize()
        tween(MainFrame, 0.4, {
            Size = UDim2.new(0, sz.w, 0, sz.h),
            Position = UDim2.new(0.5, -sz.w / 2, 0.5, -sz.h / 2)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

print("[NL] 7/12 — Loading screen загружен")
--=========================================================
-- NEVERLOSE UI — 8/12
-- Система уведомлений (notifications)
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

--========== SHOW NOTIFICATION ==========
function showNotification(text, color, duration)
    if not _G.NeverloseUILoaded then return end
    if not notifyContainer or not notifyContainer.Parent then return end
    if not text or text == "" then return end

    color = color or NL_BLUE
    duration = duration or 3

    -- Лимит: если больше 5 — удаляем самое старое
    local existing = {}
    for _, c in ipairs(notifyContainer:GetChildren()) do
        if c:IsA("Frame") then table.insert(existing, c) end
    end
    if #existing >= MAX_NOTIFIES then
        table.sort(existing, function(a, b)
            return (a:GetAttribute("Time") or 0) < (b:GetAttribute("Time") or 0)
        end)
        if existing[1] and existing[1].Parent then existing[1]:Destroy() end
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

    -- Появление (слайд справа)
    note.Position = UDim2.new(1, 50, 0, 0)
    tween(note, 0.3, {Position = UDim2.new(0, 0, 0, 0)},
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Исчезновение
    task.delay(duration, function()
        if not note or not note.Parent then return end
        tween(note, 0.3, {
            Position = UDim2.new(1, 100, 0, 0),
            BackgroundTransparency = 1
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(noteText, 0.3, {TextTransparency = 1})
        tween(noteStroke, 0.3, {Transparency = 1})
        tween(colorBar, 0.3, {BackgroundTransparency = 1})
        task.wait(0.4)
        if note and note.Parent then note:Destroy() end
    end)
end

_G.NL_Notify = showNotification

--========== HELPERS ==========
function NL_NotifyOK(text)   showNotification(text, NL_GREEN, 2)   end
function NL_NotifyErr(text)  showNotification(text, NL_RED, 3)     end
function NL_NotifyInfo(text) showNotification(text, NL_BLUE, 2.5)  end
function NL_NotifyWarn(text) showNotification(text, NL_YELLOW, 3)  end

_G.NL_NotifyOK   = NL_NotifyOK
_G.NL_NotifyErr  = NL_NotifyErr
_G.NL_NotifyInfo = NL_NotifyInfo
_G.NL_NotifyWarn = NL_NotifyWarn

--========== WELCOME ==========
task.spawn(function()
    task.wait(8)
    if not _G.NeverloseUILoaded then return end
    if _G.NL_Notify then
        _G.NL_Notify("Neverlose загружен! INSERT — меню", NL_BLUE, 3)
    end
end)

print("[NL] 8/12 — Уведомления загружены")
--=========================================================
-- NEVERLOSE UI — 9/12
-- HP-индикатор (левый нижний угол, draggable)
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

--========== TITLE ==========
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

--========== PERCENT ==========
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

--========== NUMBERS ==========
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

--========== BAR BG ==========
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

--========== BAR FILL ==========
HPBarFill = Instance.new("Frame")
HPBarFill.Size = UDim2.new(1, 0, 1, 0)
HPBarFill.BackgroundColor3 = NL_GREEN
HPBarFill.BorderSizePixel = 0
HPBarFill.ZIndex = 202
HPBarFill.Parent = HPBarBg

local HPBarFillCorner = Instance.new("UICorner")
HPBarFillCorner.CornerRadius = UDim.new(1, 0)
HPBarFillCorner.Parent = HPBarFill

--========== DRAG ==========
local hpDrag = false
local hpStartMouse, hpStartPos

HPFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        hpDrag = true
        hpStartMouse = Vector2.new(input.Position.X, input.Position.Y)
        hpStartPos = HPFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if hpDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - hpStartMouse
        HPFrame.Position = UDim2.new(
            hpStartPos.X.Scale, hpStartPos.X.Offset + delta.X,
            hpStartPos.Y.Scale, hpStartPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        hpDrag = false
    end
end)

--========== UPDATE ==========
lastHpPercent = -999
lastHpValue = -999
lastHpMax = -999

function updateHPDirect(hp, maxHp)
    local percent = math.floor((hp / math.max(maxHp, 1)) * 100)
    percent = math.clamp(percent, 0, 100)

    local color
    if percent > 60 then color = NL_GREEN
    elseif percent > 30 then color = NL_YELLOW
    else color = NL_RED end

    if HPPercentLabel and HPPercentLabel.Parent then
        HPPercentLabel.Text = percent .. "%"
        HPPercentLabel.TextColor3 = color
    end
    if HPNumbersLabel and HPNumbersLabel.Parent then
        HPNumbersLabel.Text = math.floor(hp) .. " / " .. math.floor(maxHp)
    end
    if HPBarFill and HPBarFill.Parent then
        HPBarFill.Size = UDim2.new(percent / 100, 0, 1, 0)
        HPBarFill.BackgroundColor3 = color
    end
    if HPFrameStroke and HPFrameStroke.Parent then
        HPFrameStroke.Color = color
    end
end

--========== UPDATE LOOP ==========
task.spawn(function()
    while _G.NeverloseUILoaded do
        task.wait(0.1)
        if not HPFrame or not HPFrame.Parent then break end

        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hum then
            local hp = hum.Health
            local maxHp = hum.MaxHealth
            local percent = math.floor((hp / math.max(maxHp, 1)) * 100)
            percent = math.clamp(percent, 0, 100)

            if percent ~= lastHpPercent
                or math.floor(hp) ~= lastHpValue
                or math.floor(maxHp) ~= lastHpMax then

                lastHpPercent = percent
                lastHpValue = math.floor(hp)
                lastHpMax = math.floor(maxHp)

                updateHPDirect(hp, maxHp)
            end
        else
            -- Мёртв / нет персонажа
            if lastHpPercent ~= -1 then
                lastHpPercent = -1
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
        end
    end
end)

--========== RESPAWN ==========
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    lastHpPercent = -999
    lastHpValue = -999
    lastHpMax = -999

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

--========== RESET POSITION ==========
function NL_ResetHPPosition()
    if HPFrame and HPFrame.Parent then
        HPFrame.AnchorPoint = Vector2.new(0, 1)
        HPFrame.Position = UDim2.new(0, 15, 1, -15)
    end
end

_G.NL_ResetHPPosition = NL_ResetHPPosition

print("[NL] 9/12 — HP indicator загружен")
--=========================================================
-- NEVERLOSE UI — 10/12
-- Защита: Anti-Fling, Anti-Knockback, Anti-Ragdoll
--=========================================================

--========== ANTI-FLING ==========
antiFlingConn = nil
antiFlingLastPos = nil
antiFlingLastTick = 0
antiFlingMaxVel = 200
antiFlingMaxTeleport = 100

function enableAntiFling()
    if antiFlingConn then antiFlingConn:Disconnect() end
    antiFlingLastPos = nil
    antiFlingLastTick = tick()

    antiFlingConn = RunService.Heartbeat:Connect(function()
        if not _G.NeverloseUILoaded then return end
        if not Cheat.AntiFling then return end

        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local now = tick()

        -- Скорость
        local vel = hrp.AssemblyLinearVelocity
        if vel.Magnitude > antiFlingMaxVel then
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
        end

        -- Телепорт
        if antiFlingLastPos and (now - antiFlingLastTick) < 0.15 then
            local dist = (hrp.Position - antiFlingLastPos).Magnitude
            if dist > antiFlingMaxTeleport then
                pcall(function()
                    hrp.CFrame = CFrame.new(antiFlingLastPos)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end)
            end
        end

        antiFlingLastPos = hrp.Position
        antiFlingLastTick = now

        -- Удаляем чужие BodyMover'ы (кроме NL_)
        for _, obj in ipairs(hrp:GetChildren()) do
            if obj:IsA("BodyVelocity")
                or obj:IsA("BodyAngularVelocity")
                or obj:IsA("BodyForce")
                or obj:IsA("BodyThrust")
                or obj:IsA("BodyGyro")
                or obj:IsA("LinearVelocity")
                or obj:IsA("AngularVelocity")
                or obj:IsA("VectorForce")
                or obj:IsA("Torque") then
                if not string.find(obj.Name, "NL_") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

function disableAntiFling()
    if antiFlingConn then
        antiFlingConn:Disconnect()
        antiFlingConn = nil
    end
    antiFlingLastPos = nil
end

--========== ANTI-KNOCKBACK ==========
antiKbConn = nil
antiKbLastVel = nil
antiKbMaxDelta = 80

function enableAntiKnockback()
    if antiKbConn then antiKbConn:Disconnect() end
    antiKbLastVel = nil

    antiKbConn = RunService.Heartbeat:Connect(function()
        if not _G.NeverloseUILoaded then return end
        if not Cheat.AntiKnockback then return end

        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Удаляем чужие BodyMover'ы
        for _, obj in ipairs(hrp:GetChildren()) do
            if obj:IsA("BodyVelocity")
                or obj:IsA("BodyForce")
                or obj:IsA("BodyThrust")
                or obj:IsA("LinearVelocity")
                or obj:IsA("VectorForce") then
                if not string.find(obj.Name, "NL_") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end

        -- Сглаживание резких скачков скорости
        local vel = hrp.AssemblyLinearVelocity
        if antiKbLastVel then
            local dv = (vel - antiKbLastVel).Magnitude
            if dv > antiKbMaxDelta then
                pcall(function()
                    hrp.AssemblyLinearVelocity = antiKbLastVel * 0.3
                end)
            end
        end
        antiKbLastVel = hrp.AssemblyLinearVelocity
    end)
end

function disableAntiKnockback()
    if antiKbConn then
        antiKbConn:Disconnect()
        antiKbConn = nil
    end
    antiKbLastVel = nil
end

--========== ANTI-RAGDOLL ==========
antiRagConn = nil

function enableAntiRagdoll()
    if antiRagConn then antiRagConn:Disconnect() end

    antiRagConn = RunService.Heartbeat:Connect(function()
        if not _G.NeverloseUILoaded then return end
        if not Cheat.AntiRagdoll then return end

        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        -- Вытаскиваем из ragdoll
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

        -- Отключаем суставы физики
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BallSocketConstraint")
                or obj:IsA("HingeConstraint") then
                if obj.Enabled then
                    pcall(function() obj.Enabled = false end)
                end
            end
        end

        -- Восстанавливаем скорость/прыжок если сброшены
        if hum.WalkSpeed < 8 then
            hum.WalkSpeed = Cheat.Speed and Cheat.SpeedValue or 16
        end
        if hum.UseJumpPower and hum.JumpPower < 30 then
            hum.JumpPower = Cheat.Jump and Cheat.JumpPower or 50
        end
    end)
end

function disableAntiRagdoll()
    if antiRagConn then
        antiRagConn:Disconnect()
        antiRagConn = nil
    end
end

--========== RESPAWN HOOK ==========
LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    if not _G.NeverloseUILoaded then return end
    if Cheat.AntiFling then enableAntiFling() end
    if Cheat.AntiKnockback then enableAntiKnockback() end
    if Cheat.AntiRagdoll then enableAntiRagdoll() end
end)

--========== UNLOAD ==========
_G.NL_UnloadProtect = function()
    if antiFlingConn then antiFlingConn:Disconnect() antiFlingConn = nil end
    if antiKbConn then antiKbConn:Disconnect() antiKbConn = nil end
    if antiRagConn then antiRagConn:Disconnect() antiRagConn = nil end
end

print("[NL] 10/12 — Protection загружен")
--=========================================================
-- NEVERLOSE UI — 11/12
-- Вкладки HUD и Config
--=========================================================

--=========================================================
-- HUD
--=========================================================
hudTabContent = makeTabContent("HUD")
hudLeft  = createColumn(hudTabContent); hudLeft.Position  = UDim2.new(0, 0, 0, 0)
hudRight = createColumn(hudTabContent); hudRight.Position = UDim2.new(0.5, 8, 0, 0)

--========== MENU SIZE ==========
hudSizeSec = createSection(hudLeft, "Размер интерфейса")

function applyMenuSize(sizeName)
    Cfg.MenuSize = sizeName
    local s = getMenuSize()
    if MainFrame and MainFrame.Visible then
        tween(MainFrame, 0.25, {
            Size = UDim2.new(0, s.w, 0, s.h),
            Position = UDim2.new(0.5, -s.w / 2, 0.5, -s.h / 2)
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

--========== BLUR ==========
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

--========== POSITION ==========
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

--========== ACCENT COLOR ==========
hudColorSec = createSection(hudRight, "Цвет интерфейса")

createSlider(hudColorSec, "Red", 0, 255, 0, function(v)
    Cfg.Accent = Color3.fromRGB(
        v,
        math.floor(Cfg.Accent.G * 255),
        math.floor(Cfg.Accent.B * 255)
    )
    NL_BLUE = Cfg.Accent
    updateAllAccents(Cfg.Accent)
end, true, "R")

createSlider(hudColorSec, "Green", 0, 255, 140, function(v)
    Cfg.Accent = Color3.fromRGB(
        math.floor(Cfg.Accent.R * 255),
        v,
        math.floor(Cfg.Accent.B * 255)
    )
    NL_BLUE = Cfg.Accent
    updateAllAccents(Cfg.Accent)
end, true, "G")

createSlider(hudColorSec, "Blue", 0, 255, 255, function(v)
    Cfg.Accent = Color3.fromRGB(
        math.floor(Cfg.Accent.R * 255),
        math.floor(Cfg.Accent.G * 255),
        v
    )
    NL_BLUE = Cfg.Accent
    updateAllAccents(Cfg.Accent)
end, true, "B")

--========== PRESETS ==========
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
    pb.ZIndex = 55
    pb.Parent = hudPresetsFrame

    local pbc = Instance.new("UICorner")
    pbc.CornerRadius = UDim.new(0, 5)
    pbc.Parent = pb

    pb.MouseButton1Click:Connect(function()
        Cfg.Accent = preset.c
        NL_BLUE = preset.c
        updateAllAccents(preset.c)
        if _G.NL_Notify then
            _G.NL_Notify("Цвет: " .. preset.n, preset.c, 2)
        end
    end)
end

--========== RAINBOW ==========
hudRainbowSec = createSection(hudRight, "Радуга")

createCheckbox(hudRainbowSec, "Радужный перелив", false, function(v)
    Cfg.Rainbow = v
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
    Cfg.Accent = c
    NL_BLUE = c
    for _, el in ipairs(AccentElements) do
        pcall(function() el.obj[el.prop] = c end)
    end
end)

--=========================================================
-- CONFIG
--=========================================================
cfgContent = makeTabContent("Config")
cfgLeft  = createColumn(cfgContent); cfgLeft.Position  = UDim2.new(0, 0, 0, 0)
cfgRight = createColumn(cfgContent); cfgRight.Position = UDim2.new(0.5, 8, 0, 0)

CONFIG_FILE = Cfg.SaveFile or "neverlose_config.json"

--========== COLLECT ==========
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

    if btS then
        for k, v in pairs(btS) do
            if type(v) == "boolean" or type(v) == "number" then
                cfg["B_" .. k] = v
            end
        end
    end

    cfg.Keybinds = {}
    for action, key in pairs(Keybinds) do
        if key then cfg.Keybinds[action] = key.Name end
    end

    return cfg
end

--========== APPLY ==========
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
        elseif prefix == "B_" and btS and btS[key] ~= nil then
            btS[key] = value
        end
    end

    if Cheat.Fly then enableFly() end
    if Cheat.Noclip then enableNoclip() end
    if Cheat.Speed then applySpeed() end
    if Cheat.BunnyHop then enableBunnyHop() end
    if Cheat.SpinBot then enableSpinBot() end
    if Cheat.Spider then enableSpider() end
    if Cheat.InfJump then enableInfJump() end
    if Cheat.FullBright then enableFullBright() end
    if Cheat.BlackSky then enableBlackSky() end
    if Cheat.Snow then enableSnow() end
    if Cheat.Fog then enableFog() end
    if Cheat.WorldColorEnabled then applyWorldColor() end
    if Cheat.AutoClicker then startAutoClicker() end
    if Cheat.Hat and _G.NL_CreateHat then _G.NL_CreateHat() end
    if Cheat.Jump then applyJump() end

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

--========== SAVE ==========
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

--========== LOAD ==========
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

--========== DELETE ==========
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

--========== CONFIG UI ==========
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

--========== INFO ==========
cfgInfoSec = createSection(cfgRight, "Информация")

local cfgInfoLabel = Instance.new("TextLabel")
cfgInfoLabel.Size = UDim2.new(1, 0, 0, 180)
cfgInfoLabel.BackgroundTransparency = 1
cfgInfoLabel.Text = "Config сохраняет:\n• Все вкл/выкл функции\n• Слайдеры (скорости, силы, цвета)\n• Цвета (ESP, World, Fog, Accent)\n• Размер меню\n• Бинды клавиш\n• Настройки Baritone\n\nАвтозагрузка: если файл\n'neverlose_config.json' есть,\nон загрузится через 12 сек."
cfgInfoLabel.TextColor3 = NL_DIM
cfgInfoLabel.Font = Enum.Font.Gotham
cfgInfoLabel.TextSize = 11
cfgInfoLabel.TextWrapped = true
cfgInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
cfgInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
cfgInfoLabel.ZIndex = 55
cfgInfoLabel.Parent = cfgInfoSec

--========== API CHECK ==========
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

--========== AUTO LOAD ==========
task.spawn(function()
    task.wait(12)
    if not _G.NeverloseUILoaded then return end
    if not hasFileAPI() then return end
    if isfile(CONFIG_FILE) then
        print("[NL] Найдена сохранённая конфигурация, загружаю...")
        loadConfig(CONFIG_FILE)
    end
end)

--========== UNLOAD ==========
_G.NL_UnloadHUD = function()
    if rainbowConn then rainbowConn:Disconnect() end
end

print("[NL] 11/12 — HUD + Config загружены")
--=========================================================
-- NEVERLOSE UI — 12/12
-- Fling + финальная сборка
--=========================================================

--========== FLING STATE ==========
flingPower = 50000
flingEnabled = false
autoFlingEnabled = false
autoFlingRange = 20
tpFlingEnabled = false
protectSelf = true

--========== SELF PROTECTION ==========
selfProtectConn = nil
selfProtectToken = 0

function lockSelf()
    if not protectSelf then return end
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    selfProtectToken = selfProtectToken + 1
    local myToken = selfProtectToken

    pcall(function() myHRP.Anchored = true end)

    task.delay(0.5, function()
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

--========== DO FLING ==========
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

--========== TP + FLING ==========
function tpFling(plr)
    if not _G.NeverloseUILoaded then return end
    if not plr or plr == LP then return end

    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local tChar = plr.Character
    local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not tHRP then return end

    if protectSelf then
        for _, p in ipairs(myChar:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function() p.CanCollide = false end)
            end
        end
    end

    lockSelf()

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

    if protectSelf then
        task.wait(0.2)
        for _, p in ipairs(myChar:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                pcall(function() p.CanCollide = true end)
            end
        end
    end
end

--========== RIGHT CLICK ==========
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not _G.NeverloseUILoaded then return end
    if not tpFlingEnabled then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton2 then return end

    local mouse = LP:GetMouse()
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

--========== AUTO FLING ==========
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

--========== FLING TAB ==========
flingTab = makeTabContent("Fling")
flingCol1 = createColumn(flingTab); flingCol1.Position = UDim2.new(0, 0, 0, 0)
flingCol2 = createColumn(flingTab); flingCol2.Position = UDim2.new(0.5, 8, 0, 0)

--========== FLING SECTION ==========
flingSec1 = createSection(flingCol1, "Fling")

createCheckbox(flingSec1, "Включить Fling (авто)", false, function(s)
    flingEnabled = s
end, "FL_En")

createCheckbox(flingSec1, "Автофлинг в радиусе", false, function(s)
    autoFlingEnabled = s
    if _G.NL_Notify then
        _G.NL_Notify(s and "Автофлинг ВКЛ" or "Автофлинг ВЫКЛ",
            s and NL_GREEN or NL_RED, 2)
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
flingAllBtn.ZIndex = 55
flingAllBtn.Parent = flingSec1

local fb1 = Instance.new("UICorner")
fb1.CornerRadius = UDim.new(0, 5)
fb1.Parent = flingAllBtn

flingAllBtn.MouseButton1Click:Connect(function()
    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    lockSelf()
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
        _G.NL_Notify(s and "ПКМ — флинг" or "ПКМ отключён",
            s and NL_GREEN or NL_DIM, 2)
    end
end, "FL_Tp")

local flingInfo = Instance.new("TextLabel")
flingInfo.Size = UDim2.new(1, 0, 0, 100)
flingInfo.BackgroundTransparency = 1
flingInfo.Text = "Наведи на игрока → ПКМ → он улетит.\n\nТы НЕ улетишь, потому что:\n• Заморозка на 0.5 сек\n• Телепорт рядом, не внутрь\n• Коллизия выключена на время"
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
flingList.CanvasSize = UDim2.new(0, 0, 0, 0)
flingList.AutomaticCanvasSize = Enum.AutomaticSize.Y
flingList.ZIndex = 54
flingList.Parent = flingSec3
registerAccent(flingList, "ScrollBarImageColor3")

local fl = Instance.new("UIListLayout")
fl.Padding = UDim.new(0, 4)
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
    refreshFlingList()
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    refreshFlingList()
end)

--========== UNLOAD ==========
_G.NL_UnloadFling = function()
    flingEnabled = false
    autoFlingEnabled = false
    tpFlingEnabled = false
    unlockSelf()
end

--=========================================================
-- ФИНАЛЬНАЯ СБОРКА
--=========================================================

--========== UNLOAD COMPOSITE ==========
local _baseUnload = unloadScript
unloadScript = function()
    if _G.NL_UnloadHUD then pcall(_G.NL_UnloadHUD) end
    if _G.NL_UnloadFling then pcall(_G.NL_UnloadFling) end
    if _G.NL_UnloadProtect then pcall(_G.NL_UnloadProtect) end
    if _G.NL_UnloadBT then pcall(_G.NL_UnloadBT) end
    if _G.NL_UnloadTP then pcall(_G.NL_UnloadTP) end
    if _G.NL_UnloadCTP then pcall(_G.NL_UnloadCTP) end
    if _baseUnload then pcall(_baseUnload) end
end

--========== HOTKEYS ==========
UIS.InputBegan:Connect(function(input, gp)
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

--========== ACTIVE LIST ==========
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
ALLayout.Parent = ALList

function AL_MakeLabel(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 14)
    l.BackgroundTransparency = 1
    l.Text = "• " .. text
    l.TextColor3 = NL_TEXT
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 202
    l.Parent = ALList
    return l
end

function AL_GetActive()
    local list = {}
    if Cheat.ESP then table.insert(list, "ESP") end
    if Cheat.Fly then table.insert(list, "Fly") end
    if Cheat.Noclip then table.insert(list, "Noclip") end
    if Cheat.Speed then table.insert(list, "Speed") end
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
    if autoFlingEnabled then table.insert(list, "Auto-Fling") end
    if tpFlingEnabled then table.insert(list, "ПКМ-Флинг") end
    return list
end

AL_Labels = {}
AL_LastCount = -1

task.spawn(function()
    while _G.NeverloseUILoaded do
        task.wait(0.5)
        if not ActiveListFrame or not ActiveListFrame.Parent then break end
        local active = AL_GetActive()
        if #active ~= AL_LastCount then
            AL_LastCount = #active
            for _, l in ipairs(AL_Labels) do
                if l and l.Parent then l:Destroy() end
            end
            AL_Labels = {}
            for _, name in ipairs(active) do
                table.insert(AL_Labels, AL_MakeLabel(name))
            end
            ActiveListFrame.Visible = #active > 0
        end
    end
end)

--========== FINAL CHECK ==========
task.spawn(function()
    task.wait(14)
    if not _G.NeverloseUILoaded then return end

    local missing = {}
    local required = {
        "Visuals", "Misc", "Teleport", "Cursor TP",
        "Baritone", "Fling", "HUD", "Config", "Settings"
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

--========== FINAL PRINT ==========
print("")
print("========================================")
print("   NEVERLOSE UI — 12/12 ЗАГРУЖЕНО")
print("   XENO EDITION")
print("========================================")
print("  INSERT        - меню")
print("  RightShift    - автофлинг вкл/выкл")
print("  RightControl  - ПКМ-флинг вкл/выкл")
print("  ПКМ           - флинг цели")
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
