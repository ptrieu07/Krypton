-- Krypton v0.01 | Final Functional Fix (ZIndex & Click Event Rectified)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Biến logic hệ thống
local customSpeed = 16
local customJump = 50
local spinSpeed = 0.3          
local targetStalk = nil
local autoTeleActive = false
local spinActive = false
local isMinimized = false
local isFullscreen = false
local noclip = false
local flying = false
local flySpeed = 60
local clickTPActive = false
local espActive = false 
local antiAfkActive = false
local fullbrightActive = false
local jesusActive = false
local customBrightness = 2 
local menuEnabled = true 
local bv, bg

-- Lưu thông số Lighting gốc
local origAmbient = Lighting.Ambient
local origOutdoorAmbient = Lighting.OutdoorAmbient
local origBrightness = Lighting.Brightness

-- --- BẢNG MÀU CHUẨN DARK ---
local KRYPTON_GREEN = Color3.fromRGB(50, 220, 100)      
local BG_MAIN = Color3.fromRGB(13, 13, 14)              
local BG_CONTAINER = Color3.fromRGB(18, 18, 20)        
local BG_BUTTON = Color3.fromRGB(26, 26, 29)            
local BG_BUTTON_HOVER = Color3.fromRGB(36, 36, 40)      
local TEXT_MAIN = Color3.fromRGB(230, 230, 230)        
local TEXT_DARK = Color3.fromRGB(140, 140, 145)

-- Cấu hình ScreenGui gốc
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KryptonSystemMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
end

local function applyHoverEffect(instance, normalBg, hoverBg, normalText, hoverText)
    instance.MouseEnter:Connect(function()
        TweenService:Create(instance, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = hoverBg or BG_BUTTON_HOVER,
            TextColor3 = hoverText or Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    instance.MouseLeave:Connect(function()
        TweenService:Create(instance, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = normalBg or BG_BUTTON,
            TextColor3 = normalText or TEXT_MAIN
        }):Play()
    end)
end

local defaultSize = UDim2.new(0, 720, 0, 490)
local defaultPos = UDim2.new(0.25, 0, 0.2, 0)

-- =========================================================
-- KHUNG CHÍNH MENU (MAIN FRAME)
-- =========================================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = defaultSize
MainFrame.Position = defaultPos
MainFrame.BackgroundColor3 = BG_MAIN
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui
addCorner(MainFrame, 12)
addStroke(MainFrame, Color3.fromRGB(40, 40, 42), 1)

-- Thanh Tiêu Đề (Title Bar)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundTransparency = 1
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 150, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Text = "KRYPTON"
Title.TextColor3 = KRYPTON_GREEN
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 3
Title.Parent = TitleBar

-- Bộ Ba Nút Điều Hướng Góp Phải (_, O, X)
local SystemButtonsFrame = Instance.new("Frame")
SystemButtonsFrame.Size = UDim2.new(0, 120, 1, 0)
SystemButtonsFrame.Position = UDim2.new(1, -130, 0, 0)
SystemButtonsFrame.BackgroundTransparency = 1
SystemButtonsFrame.ZIndex = 3
SystemButtonsFrame.Parent = TitleBar

local UIListNav = Instance.new("UIListLayout")
UIListNav.FillDirection = Enum.FillDirection.Horizontal
UIListNav.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListNav.VerticalAlignment = Enum.VerticalAlignment.Center
UIListNav.Padding = UDim.new(0, 15)
UIListNav.Parent = SystemButtonsFrame

local function createSysBtn(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 24, 0, 24)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = color
    btn.BackgroundTransparency = 1
    btn.Active = true
    btn.ZIndex = 4
    btn.Parent = SystemButtonsFrame
    return btn
end

local MinimizeBtn = createSysBtn("_", TEXT_MAIN)
local FullscreenBtn = createSysBtn("O", TEXT_MAIN)
local CloseBtn = createSysBtn("X", Color3.fromRGB(240, 90, 90))

-- =========================================================
-- KHUNG CHỨA NỘI DUNG CHÍNH (CONTENT AREA)
-- =========================================================
local ContentOuterFrame = Instance.new("Frame")
ContentOuterFrame.Size = UDim2.new(1, -30, 1, -125)
ContentOuterFrame.Position = UDim2.new(0, 15, 0, 45)
ContentOuterFrame.BackgroundTransparency = 1
ContentOuterFrame.BorderSizePixel = 0
ContentOuterFrame.ZIndex = 2
ContentOuterFrame.Parent = MainFrame

-- Cột chứa Tab Menu bên trái (Sidebar)
local TabSidebar = Instance.new("Frame")
TabSidebar.Size = UDim2.new(0, 140, 1, 0)
TabSidebar.BackgroundTransparency = 1
TabSidebar.ZIndex = 3
TabSidebar.Parent = ContentOuterFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 10)
TabListLayout.Parent = TabSidebar

-- Khung hiển thị các nút chức năng bên phải (Pages Box)
local PageViewContainer = Instance.new("Frame")
PageViewContainer.Size = UDim2.new(1, -155, 1, 0)
PageViewContainer.Position = UDim2.new(0, 155, 0, 0)
PageViewContainer.BackgroundColor3 = BG_CONTAINER
PageViewContainer.BorderSizePixel = 0
PageViewContainer.ZIndex = 3
PageViewContainer.Parent = ContentOuterFrame
addCorner(PageViewContainer, 10)
addStroke(PageViewContainer, Color3.fromRGB(38, 38, 40), 1)

-- Tạo các Trang chứa Chức năng tương ứng
local Pages = {}
local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ZIndex = 4
    page.Parent = PageViewContainer
    
    local contentGrid = Instance.new("Frame")
    contentGrid.Name = "Grid"
    contentGrid.Size = UDim2.new(1, 0, 1, 0)
    contentGrid.BackgroundTransparency = 1
    contentGrid.ZIndex = 4
    contentGrid.Parent = page

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 158, 0, 44)
    gridLayout.CellPadding = UDim2.new(0, 14, 0, 14)
    gridLayout.Parent = contentGrid

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 16)
    padding.PaddingLeft = UDim.new(0, 16)
    padding.Parent = contentGrid

    Pages[name] = page
    return page
end

local MovementPage = createPage("Movement")
local PlayerPage = createPage("Player")
local MicsPage = createPage("Mics")

-- Logic chuyển đổi giữa các Tab
local function createTabButton(text, targetPageName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.BackgroundColor3 = BG_BUTTON
    btn.Text = "      " .. text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextColor3 = TEXT_MAIN
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Active = true
    btn.ZIndex = 4
    btn.Parent = TabSidebar
    addCorner(btn, 8)
    addStroke(btn, Color3.fromRGB(40, 40, 44), 1)

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 4, 0, 22)
    indicator.Position = UDim2.new(0, 10, 0, 11)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    indicator.Visible = false
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 5
    indicator.Parent = btn
    addCorner(indicator, 2)

    applyHoverEffect(btn, BG_BUTTON, BG_BUTTON_HOVER, TEXT_MAIN, Color3.fromRGB(255, 255, 255))

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, b in pairs(TabSidebar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = BG_BUTTON
                b.TextColor3 = TEXT_MAIN
                b:FindFirstChild("Indicator").Visible = false
            end
        end
        Pages[targetPageName].Visible = true
        btn.BackgroundColor3 = BG_BUTTON_HOVER
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        indicator.Visible = true
    end)

    return btn
end

local TabMove = createTabButton("Movement", "Movement")
local TabPlayer = createTabButton("Player", "Player")
local TabMics = createTabButton("Mics", "Mics")

Pages.Movement.Visible = true
TabMove:FindFirstChild("Indicator").Visible = true

-- =========================================================
-- KHU VỰC CONSOLE LOG NGANG RỘNG XUỐNG DƯỚI ĐÁY
-- =========================================================
local ConsoleFrame = Instance.new("Frame")
ConsoleFrame.Size = UDim2.new(1, -30, 0, 60)
ConsoleFrame.Position = UDim2.new(0, 15, 1, -75)
ConsoleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 11)
ConsoleFrame.BorderSizePixel = 0
ConsoleFrame.ZIndex = 3
ConsoleFrame.Parent = MainFrame
addCorner(ConsoleFrame, 8)
addStroke(ConsoleFrame, Color3.fromRGB(38, 38, 40), 1)

local ConsoleScroll = Instance.new("ScrollingFrame")
ConsoleScroll.Size = UDim2.new(1, -16, 1, -12)
ConsoleScroll.Position = UDim2.new(0, 8, 0, 6)
ConsoleScroll.BackgroundTransparency = 1
ConsoleScroll.ScrollBarThickness = 2
ConsoleScroll.ScrollBarImageColor3 = KRYPTON_GREEN
ConsoleScroll.ZIndex = 4
ConsoleScroll.Parent = ConsoleFrame

local function kryptonLog(text, color)
    color = color or Color3.fromRGB(200, 200, 200)
    local timeString = os.date("%X")
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.Text = " [" .. timeString .. "] " .. text
    label.Font = Enum.Font.Code
    label.TextSize = 11
    label.TextColor3 = color
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.ZIndex = 5
    
    local currentLogs = ConsoleScroll:GetChildren()
    label.Position = UDim2.new(0, 0, 0, (#currentLogs) * 16)
    label.Parent = ConsoleScroll
    
    ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, (#currentLogs + 1) * 16)
    ConsoleScroll.CanvasPosition = Vector2.new(0, ConsoleScroll.CanvasSize.Y.Offset)
end

-- =========================================================
-- KHỞI TẠO NÚT BẤM CƯỚNG CHẾ THUỘC TÍNH ACTIVE & ZINDEX CỰC CAO
-- =========================================================
local function createGridButton(parentPage, text)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.TextColor3 = TEXT_MAIN
    btn.BackgroundColor3 = BG_BUTTON
    btn.BorderSizePixel = 0
    btn.Active = true
    btn.Selectable = true
    btn.ZIndex = 5 -- Ép ZIndex cao để chuột luôn tương tác trực tiếp được
    btn.Parent = parentPage:FindFirstChild("Grid")
    addCorner(btn, 6)
    addStroke(btn, Color3.fromRGB(40, 40, 45), 1)
    applyHoverEffect(btn)
    return btn
end

local function updateBtnVisual(btn, active, onText, offText)
    btn.Text = active and onText or offText
    btn.BackgroundColor3 = active and Color3.fromRGB(22, 60, 30) or BG_BUTTON
    btn.TextColor3 = active and KRYPTON_GREEN or TEXT_MAIN
end

local function createStatInputNonGrid(parentPage, labelName, defaultVal, xOffset, yOffset)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 158, 0, 44)
    container.Position = UDim2.new(0, xOffset, 0, yOffset)
    container.BackgroundTransparency = 1
    container.ZIndex = 4
    container.Parent = parentPage

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 55, 1, 0)
    label.Text = labelName
    label.TextColor3 = TEXT_DARK
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 11
    label.ZIndex = 5
    label.Parent = container

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -60, 1, -14)
    box.Position = UDim2.new(0, 55, 0, 7)
    box.Text = tostring(defaultVal)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.BackgroundColor3 = BG_MAIN
    box.TextColor3 = KRYPTON_GREEN
    box.BorderSizePixel = 0
    box.Active = true
    box.ZIndex = 5
    box.Parent = container
    addCorner(box, 4)
    addStroke(box, Color3.fromRGB(40, 40, 45), 1)
    applyHoverEffect(box, BG_MAIN, Color3.fromRGB(22, 22, 24), KRYPTON_GREEN, KRYPTON_GREEN)
    return box
end

-- --- KHỞI TẠO CÁC NÚT TAB MOVEMENT ---
local FlyBtn = createGridButton(Pages.Movement, "Fly: OFF")
local NoclipBtn = createGridButton(Pages.Movement, "Noclip: OFF")
local SpinBtn = createGridButton(Pages.Movement, "3D Spin: OFF")
local ClickTPBtn = createGridButton(Pages.Movement, "Click TP: OFF")
local AutoTpBtn = createGridButton(Pages.Movement, "Auto TP Target: OFF")
local JesusBtn = createGridButton(Pages.Movement, "Jesus Walk: OFF")

-- --- KHỞI TẠO CÁC NÚT TAB VISUAL ---
local EspBtn = createGridButton(Pages.Player, "Player ESP: OFF")
local FullbrightBtn = createGridButton(Pages.Player, "Fullbright: OFF")
local FpsBoostBtn = createGridButton(Pages.Player, "FPS Booster")

-- --- KHỞI TẠO TAB MICS ---
local AntiAfkBtn = createGridButton(Pages.Mics, "Anti-AFK: OFF")
Pages.Mics.Grid.Visible = true

local SpeedInput = createStatInputNonGrid(Pages.Mics, "Speed:", customSpeed, 188, 16)
local JumpInput = createStatInputNonGrid(Pages.Mics, "Jump:", customJump, 16, 74)
local SpinInput = createStatInputNonGrid(Pages.Mics, "Spin:", spinSpeed, 188, 74)
local BrightInput = createStatInputNonGrid(Pages.Mics, "Bright:", customBrightness, 16, 132)

-- =========================================================
-- POP-UP BẢNG CHỌN TARGET KHI BẤM AUTO TP (ZINDEX = 6)
-- =========================================================
local PlayerSelectFrame = Instance.new("Frame")
PlayerSelectFrame.Size = UDim2.new(0, 160, 0, 160)
PlayerSelectFrame.Position = UDim2.new(1, 15, 0, 0)
PlayerSelectFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 16)
PlayerSelectFrame.Visible = false
PlayerSelectFrame.ZIndex = 6
PlayerSelectFrame.Parent = MainFrame
addCorner(PlayerSelectFrame, 8)
addStroke(PlayerSelectFrame, Color3.fromRGB(45, 45, 50), 1)

local PLTitle = Instance.new("TextLabel")
PLTitle.Size = UDim2.new(1, 0, 0, 26)
PLTitle.Text = "  SELECT TARGET"
PLTitle.TextColor3 = KRYPTON_GREEN
PLTitle.BackgroundTransparency = 1
PLTitle.Font = Enum.Font.GothamBold
PLTitle.TextSize = 10
PLTitle.TextXAlignment = Enum.TextXAlignment.Left
PLTitle.ZIndex = 7
PLTitle.Parent = PlayerSelectFrame

local TargetScroll = Instance.new("ScrollingFrame")
TargetScroll.Size = UDim2.new(1, -10, 1, -32)
TargetScroll.Position = UDim2.new(0, 5, 0, 28)
TargetScroll.BackgroundTransparency = 1
TargetScroll.ScrollBarThickness = 2
TargetScroll.ScrollBarImageColor3 = KRYPTON_GREEN
TargetScroll.ZIndex = 7
TargetScroll.Parent = PlayerSelectFrame

-- =========================================================
-- HỆ THỐNG RED ESP ĐƯỜNG DẪN + TAG TÊN TRÊN ĐẦU
-- =========================================================
local tracerFolder = workspace:FindFirstChild("KryptonTracers") or Instance.new("Folder")
tracerFolder.Name = "KryptonTracers"
tracerFolder.Parent = workspace

local function cleanESP()
    tracerFolder:ClearAllChildren()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            if p.Character:FindFirstChild("KryptonESP") then p.Character.KryptonESP:Destroy() end
            if p.Character:FindFirstChild("KryptonNameTag") then p.Character.KryptonNameTag:Destroy() end
        end
    end
end

local function applyESP()
    if not espActive then cleanESP() return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Head") then
            local hrp = p.Character.HumanoidRootPart
            local head = p.Character.Head
            local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if not p.Character:FindFirstChild("KryptonESP") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "KryptonESP"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(255, 50, 50)
                highlight.Adornee = p.Character
                highlight.Parent = p.Character
            end
            
            if not p.Character:FindFirstChild("KryptonNameTag") then
                local bbGui = Instance.new("BillboardGui")
                bbGui.Name = "KryptonNameTag"
                bbGui.Size = UDim2.new(0, 140, 0, 26)
                bbGui.AlwaysOnTop = true
                bbGui.StudsOffset = Vector3.new(0, 3, 0)
                bbGui.Adornee = head
                
                local tagLabel = Instance.new("TextLabel")
                tagLabel.Size = UDim2.new(1, 0, 1, 0)
                tagLabel.BackgroundTransparency = 1
                tagLabel.Text = p.Name
                tagLabel.Font = Enum.Font.GothamBold
                tagLabel.TextSize = 11
                tagLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                tagLabel.TextStrokeTransparency = 0.3
                tagLabel.Parent = bbGui
                bbGui.Parent = p.Character
            end
            
            local tracerName = "Tracer_" .. p.Name
            local tracerPart = tracerFolder:FindFirstChild(tracerName)
            if onScreen then
                if not tracerPart then
                    tracerPart = Instance.new("Part")
                    tracerPart.Name = tracerName
                    tracerPart.Anchored = true; tracerPart.CanCollide = false
                    tracerPart.Transparency = 0.3; tracerPart.Color = Color3.fromRGB(255, 0, 0)
                    tracerPart.Material = Enum.Material.Neon; tracerPart.Size = Vector3.new(0.08, 0.08, 1)
                    tracerPart.Parent = tracerFolder
                end
                local origin = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 2, 0)
                if origin then
                    local distance = (hrp.Position - origin).Magnitude
                    tracerPart.Size = Vector3.new(0.08, 0.08, distance)
                    tracerPart.CFrame = CFrame.lookAt(origin, hrp.Position) * CFrame.new(0, 0, -distance/2)
                end
            else
                if tracerPart then tracerPart:Destroy() end
            end
        end
    end
end

EspBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    updateBtnVisual(EspBtn, espActive, "Player ESP: ACTIVE", "Player ESP: OFF")
    if not espActive then cleanESP() end
    kryptonLog(espActive and "Da bat He thong ESP dinh vi mau do." or "Da tat ESP.", KRYPTON_GREEN)
end)

RunService.RenderStepped:Connect(function() if espActive then applyESP() end end)

-- =========================================================
-- LOGIC HOẠT ĐỘNG KHÔNG LỖI CHO NÚT AUTO TELEPORT TARGET
-- =========================================================
AutoTpBtn.MouseButton1Click:Connect(function()
    autoTeleActive = not autoTeleActive
    PlayerSelectFrame.Visible = autoTeleActive
    updateBtnVisual(AutoTpBtn, autoTeleActive, "Auto TP: CHOOSE TARGET", "Auto TP Target: OFF")
    if not autoTeleActive then targetStalk = nil AutoTpBtn.Text = "Auto TP Target: OFF" end
end)

RunService.Heartbeat:Connect(function()
    if autoTeleActive and targetStalk and targetStalk.Parent and targetStalk.Character and targetStalk.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetStalk.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

-- =========================================================
-- ĐỒNG BỘ TOÀN BỘ LOGIC CÁC TÍNH NĂNG KHÁC CỦA HUB
-- =========================================================
MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ContentOuterFrame.Visible = not isMinimized
    ConsoleFrame.Visible = not isMinimized
    PlayerSelectFrame.Visible = (not isMinimized and autoTeleActive)
    MainFrame.Size = isMinimized and UDim2.new(0, MainFrame.Size.X.Offset, 0, 40) or (isFullscreen and UDim2.new(1, 0, 1, 0) or defaultSize)
    MinimizeBtn.Text = isMinimized and "+" or "−"
end)

FullscreenBtn.MouseButton1Click:Connect(function()
    if isMinimized then return end
    isFullscreen = not isFullscreen
    if isFullscreen then
        MainFrame.Position = UDim2.new(0, 0, 0, 0)
        MainFrame.Size = UDim2.new(1, 0, 1, 0)
    else
        MainFrame.Size = defaultSize; MainFrame.Position = defaultPos
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    flying = false; spinActive = false; autoTeleActive = false; noclip = false; fullbrightActive = false; espActive = false; jesusActive = false
    if bv then bv:Destroy() end if bg then bg:Destroy() end
    cleanESP()
    Lighting.Ambient = origAmbient; Lighting.OutdoorAmbient = origOutdoorAmbient; Lighting.Brightness = origBrightness
    ScreenGui:Destroy()
end)

JesusBtn.MouseButton1Click:Connect(function()
    jesusActive = not jesusActive
    updateBtnVisual(JesusBtn, jesusActive, "Jesus Walk: ON", "Jesus Walk: OFF")
end)

RunService.Stepped:Connect(function()
    if jesusActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") and (v.Name:lower():find("water") or v.Material == Enum.Material.Water) then v.CanCollide = true end
        end
    end
end)

AntiAfkBtn.MouseButton1Click:Connect(function()
    antiAfkActive = not antiAfkActive
    updateBtnVisual(AntiAfkBtn, antiAfkActive, "Anti-AFK: ACTIVE", "Anti-AFK: OFF")
end)

local virtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if antiAfkActive then
        virtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.2)
        virtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

local function applyFullbright()
    if fullbrightActive then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255); Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255); Lighting.Brightness = customBrightness
    end
end

FullbrightBtn.MouseButton1Click:Connect(function()
    fullbrightActive = not fullbrightActive
    updateBtnVisual(FullbrightBtn, fullbrightActive, "Fullbright: ON", "Fullbright: OFF")
    if fullbrightActive then applyFullbright() else
        Lighting.Ambient = origAmbient; Lighting.OutdoorAmbient = origOutdoorAmbient; Lighting.Brightness = origBrightness
    end
end)

BrightInput.FocusLost:Connect(function()
    local val = tonumber(BrightInput.Text)
    if val then customBrightness = val; if fullbrightActive then applyFullbright() end end
end)

FpsBoostBtn.MouseButton1Click:Connect(function()
    Lighting.GlobalShadows = false
    for _, v in pairs(workspace:GetDescendants()) do
        pcall(function()
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end)
    end
    FpsBoostBtn.Text = "FPS BOOSTED!"
end)

FlyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    updateBtnVisual(FlyBtn, flying, "Fly: ACTIVE", "Fly: OFF")
    if flying then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1e5, 1e5, 1e5); bv.Parent = hrp
            bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5); bg.Parent = hrp
            task.spawn(function()
                while flying and character and hrp.Parent do
                    RunService.RenderStepped:Wait()
                    local velocity = Vector3.new(0,0,0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - Camera.CFrame.RightVector end
                    bv.Velocity = (velocity.Magnitude > 0) and (velocity.Unit * flySpeed) or Vector3.new(0,0,0)
                    bg.CFrame = Camera.CFrame
                end
            end)
        end
    else
        if bv then bv:Destroy() end if bg then bg:Destroy() end
    end
end)

SpinBtn.MouseButton1Click:Connect(function()
    spinActive = not spinActive
    updateBtnVisual(SpinBtn, spinActive, "3D Spin: ACTIVE", "3D Spin: OFF")
    if spinActive then
        task.spawn(function()
            local rX, rY, rZ = 0, 0, 0
            while spinActive do
                RunService.RenderStepped:Wait()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    rX = rX + (spinSpeed * 0.6); rY = rY + spinSpeed; rZ = rZ + (spinSpeed * 0.3)
                    char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position) * CFrame.Angles(rX, rY, rZ)
                end
            end
        end)
    end
end)

NoclipBtn.MouseButton1Click:Connect(function() noclip = not noclip updateBtnVisual(NoclipBtn, noclip, "Noclip: ACTIVE", "Noclip: OFF") end)
RunService.Stepped:Connect(function() if noclip and LocalPlayer.Character then for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)
ClickTPBtn.MouseButton1Click:Connect(function() clickTPActive = not clickTPActive updateBtnVisual(ClickTPBtn, clickTPActive, "Click TP: ACTIVE", "Click TP: OFF") end)
UserInputService.InputBegan:Connect(function(i) if clickTPActive and i.UserInputType == Enum.UserInputType.MouseButton1 and Mouse.Hit and LocalPlayer.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)) end end)

local function applyCustomStats(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hum.WalkSpeed = customSpeed
        if hum.UseJumpPower then hum.JumpPower = customJump else hum.JumpHeight = (customJump ^ 2) / (2 * workspace.Gravity) end
    end
end

SpeedInput.FocusLost:Connect(function() local val = tonumber(SpeedInput.Text) if val then customSpeed = val; if LocalPlayer.Character then applyCustomStats(LocalPlayer.Character) end end end)
JumpInput.FocusLost:Connect(function() local val = tonumber(JumpInput.Text) if val then customJump = val; if LocalPlayer.Character then applyCustomStats(LocalPlayer.Character) end end end)
SpinInput.FocusLost:Connect(function() local val = tonumber(SpinInput.Text) if val then spinSpeed = val end end)
LocalPlayer.CharacterAdded:Connect(function(char) task.wait(0.5) applyCustomStats(char) end)

-- Phím tắt ẩn hiện Menu nhanh [Ctrl + E]
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        menuEnabled = not menuEnabled; MainFrame.Visible = menuEnabled
    end
end)

-- Đồng bộ cập nhật danh sách người chơi thực tế trong Server
local function updatePlayerList()
    for _, child in pairs(TargetScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local y = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -5, 0, 28)
            pBtn.Position = UDim2.new(0, 0, 0, y)
            pBtn.BackgroundColor3 = (targetStalk == p) and Color3.fromRGB(40, 20, 20) or BG_BUTTON
            pBtn.Text = "  @" .. p.Name
            pBtn.Font = Enum.Font.GothamSemibold; pBtn.TextSize = 10
            pBtn.TextColor3 = (targetStalk == p) and Color3.fromRGB(255, 50, 50) or TEXT_MAIN
            pBtn.TextXAlignment = Enum.TextXAlignment.Left; pBtn.BorderSizePixel = 0
            pBtn.Active = true
            pBtn.ZIndex = 8
            pBtn.Parent = TargetScroll
            addCorner(pBtn, 4)

            pBtn.MouseButton1Click:Connect(function()
                targetStalk = p
                kryptonLog("Target Lock: @" .. p.Name, Color3.fromRGB(255, 50, 50))
                AutoTpBtn.Text = "Auto TP: @" .. p.Name
                updatePlayerList()
            end)
            y = y + 32
        end
    end
    TargetScroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()
kryptonLog("turn on krypton.", KRYPTON_GREEN)
