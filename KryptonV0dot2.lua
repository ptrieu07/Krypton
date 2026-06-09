-- KRYPTON - MINIMIZE FIX & OPTIMIZED
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

if PlayerGui:FindFirstChild("KryptonMain") then PlayerGui.KryptonMain:Destroy() end

local Config = {
    Fly = false, FlySpeed = 50, Speed = 16, Jump = 50,
    Spin2D = false, Spin3D = false, SpinSpeed = 10,
    Noclip = false, ClickTP = false, 
    AutoTeleport = false, AutoTarget = "",
    PlayerESP = false, Brightness = 2, FPSBoost = false
}

-- --- CUSTOM DRAG SYSTEM ---
local function MakeDraggable(dragPart, mainFrame)
    local dragging, dragStart, startPos
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- --- UI MAIN FRAME ---
local ScreenGui = Instance.new("ScreenGui", PlayerGui); ScreenGui.Name = "KryptonMain"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 650, 0, 420); MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12); MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Color = Color3.fromRGB(40, 40, 40); MainStroke.Thickness = 1

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundTransparency = 1
MakeDraggable(TitleBar, MainFrame)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Text = "KRYPTON"; TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 120); TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14; TitleLabel.Position = UDim2.new(0, 15, 0, 0); TitleLabel.Size = UDim2.new(0, 100, 1, 0); TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.BackgroundTransparency = 1

-- --- INNER PANELS ---
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, -125); Sidebar.Position = UDim2.new(0, 10, 0, 45); Sidebar.BackgroundTransparency = 1

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -160, 1, -125); Content.Position = UDim2.new(0, 150, 0, 45); Content.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", Content); local ContentStroke = Instance.new("UIStroke", Content); ContentStroke.Color = Color3.fromRGB(35, 35, 35); ContentStroke.Thickness = 1

local Footer = Instance.new("Frame", MainFrame)
Footer.Size = UDim2.new(0.96, 0, 0, 65); Footer.Position = UDim2.new(0.02, 0, 1, -75); Footer.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Instance.new("UICorner", Footer); local FooterStroke = Instance.new("UIStroke", Footer); FooterStroke.Color = Color3.fromRGB(30, 30, 30); FooterStroke.Thickness = 1

-- --- CONSOLE LOG ENGINE ---
local LogContainer = Instance.new("ScrollingFrame", Footer)
LogContainer.Size = UDim2.new(1, -20, 1, -10); LogContainer.Position = UDim2.new(0, 10, 0, 5); LogContainer.BackgroundTransparency = 1; LogContainer.ScrollBarThickness = 2
local LogLayout = Instance.new("UIListLayout", LogContainer); LogLayout.Padding = UDim.new(0, 2)

local function AddLog(type, msg)
    local logLine = Instance.new("TextLabel", LogContainer)
    logLine.Size = UDim2.new(1, 0, 0, 16); logLine.BackgroundTransparency = 1
    logLine.Text = ">_  [" .. type .. "] " .. msg
    logLine.TextColor3 = (type == "SUCCESS") and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 255, 150)
    logLine.Font = Enum.Font.Code; logLine.TextSize = 11; logLine.TextXAlignment = Enum.TextXAlignment.Left
    LogContainer.CanvasSize = UDim2.new(0, 0, 0, LogLayout.AbsoluteContentSize.Y)
    LogContainer.CanvasPosition = Vector2.new(0, LogLayout.AbsoluteContentSize.Y)
end

-- --- MINIMIZE & CLOSE LOGIC (FIXED) ---
local isMinimized = false
local function createControl(text, offset, callback)
    local btn = Instance.new("TextButton", TitleBar)
    btn.Size = UDim2.new(0, 30, 0, 30); btn.Position = UDim2.new(1, offset, 0, 2); btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.BackgroundTransparency = 1
    btn.MouseButton1Click:Connect(callback)
end

createControl("X", -35, function() ScreenGui:Destroy() end)
createControl("—", -65, function() 
    isMinimized = not isMinimized
    
    -- Crucial Bugfix: Hide layout structures immediately to avoid negative position bleed
    Sidebar.Visible = not isMinimized
    Content.Visible = not isMinimized
    Footer.Visible = not isMinimized
    
    local targetSize = isMinimized and UDim2.new(0, 650, 0, 35) or UDim2.new(0, 650, 0, 420)
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

-- --- TABS CREATOR ---
local tabPanels = {}
local function createTab(name, index)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 35); btn.Position = UDim2.new(0, 0, 0, (index-1)*40); btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.Gotham; btn.TextSize = 13
    Instance.new("UICorner", btn); local bStroke = Instance.new("UIStroke", btn); bStroke.Color = Color3.fromRGB(45, 45, 45); bStroke.Thickness = 1
    
    local panel = Instance.new("ScrollingFrame", Content)
    panel.Size = UDim2.new(1, -20, 1, -20); panel.Position = UDim2.new(0, 10, 0, 10); panel.BackgroundTransparency = 1; panel.Visible = (index == 1); panel.ScrollBarThickness = 0
    Instance.new("UIListLayout", panel).Padding = UDim.new(0, 8)
    tabPanels[name] = panel
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(tabPanels) do v.Visible = false end
        panel.Visible = true
    end)
end

local function addSwitch(tab, label, key, callback)
    local f = Instance.new("Frame", tabPanels[tab]); f.Size = UDim2.new(1, 0, 0, 30); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = label; l.Size = UDim2.new(0, 200, 1, 0); l.TextColor3 = Color3.fromRGB(220, 220, 220); l.Font = Enum.Font.Gotham; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left; l.BackgroundTransparency = 1
    local b = Instance.new("TextButton", f); b.Size = UDim2.new(0, 40, 0, 20); b.Position = UDim2.new(1, -45, 0, 5); b.Text = ""
    b.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    b.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        b.BackgroundColor3 = Config[key] and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(40, 40, 40)
        AddLog("SUCCESS", label .. " turned " .. (Config[key] and "ON" or "OFF"))
        callback(Config[key])
    end)
end

local function addSlider(tab, label, key, min, max, callback)
    local f = Instance.new("Frame", tabPanels[tab]); f.Size = UDim2.new(1, 0, 0, 35); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Text = label .. " ["..Config[key].."]"; l.Size = UDim2.new(0, 150, 1, 0); l.TextColor3 = Color3.fromRGB(200, 200, 200); l.Font = Enum.Font.Gotham; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.BackgroundTransparency = 1
    local sBg = Instance.new("Frame", f); sBg.Size = UDim2.new(1, -160, 0, 4); sBg.Position = UDim2.new(0, 155, 0, 15); sBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", sBg)
    local fill = Instance.new("Frame", sBg); fill.Size = UDim2.new((Config[key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 255, 120); Instance.new("UICorner", fill)
    sBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local function update()
                local per = math.clamp((UserInputService:GetMouseLocation().X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(per, 0, 1, 0)
                local val = math.floor(min + (max - min) * per)
                l.Text = label .. " ["..val.."]"; Config[key] = val; callback(val)
            end
            local conn; conn = UserInputService.InputChanged:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
            UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end end)
            update()
        end
    end)
end

-- --- GENERATE CONTENT TABS ---
createTab("Player", 1)
createTab("Teleport", 2)
createTab("Visual", 3)

-- Player Features
addSlider("Player", "WalkSpeed", "Speed", 16, 250, function(v) pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = v end) end)
addSlider("Player", "JumpPower", "Jump", 50, 500, function(v) pcall(function() LocalPlayer.Character.Humanoid.JumpPower = v end) end)
addSlider("Player", "Fly Speed", "FlySpeed", 10, 300, function() end)
addSlider("Player", "Spin Speed", "SpinSpeed", 0, 150, function() end)
addSwitch("Player", "Flight", "Fly", function(v) 
    local hrp = LocalPlayer.Character.HumanoidRootPart
    if v then
        local bv = Instance.new("BodyVelocity", hrp); bv.Name = "KryFly"; bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        task.spawn(function()
            while Config.Fly do RunService.RenderStepped:Wait()
                local v = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - Camera.CFrame.LookVector end
                bv.Velocity = v * Config.FlySpeed
            end
            bv:Destroy()
        end)
    end
end)
addSwitch("Player", "Noclip", "Noclip", function() end)
addSwitch("Player", "Spin 2D", "Spin2D", function(v) if v then Config.Spin3D = false end end)
addSwitch("Player", "Spin 3D", "Spin3D", function(v) if v then Config.Spin2D = false end end)

-- Teleport Features
addSwitch("Teleport", "Click TP (Ctrl+LClick)", "ClickTP", function() end)
addSwitch("Teleport", "Auto Above-Head TP", "AutoTeleport", function() end)
local TargetBtn = Instance.new("TextButton", tabPanels["Teleport"])
TargetBtn.Size = UDim2.new(1, 0, 0, 30); TargetBtn.Text = "Select Target Player"; TargetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); TargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", TargetBtn)
TargetBtn.MouseButton1Click:Connect(function()
    local plrs = Players:GetPlayers()
    local p = plrs[math.random(1, #plrs)]
    if p ~= LocalPlayer then Config.AutoTarget = p.Name; TargetBtn.Text = "Target: "..p.Name; AddLog("INFO", "Target set to "..p.Name) end
end)

-- Visual Features
addSlider("Visual", "Brightness", "Brightness", 0, 10, function(v) Lighting.Brightness = v end)
addSwitch("Visual", "ESP Player", "PlayerESP", function() end)
addSwitch("Visual", "FPS Boost", "FPSBoost", function(v)
    if v then 
        for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end end
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = true
    end
end)

-- --- HIGH VISIBILITY ESP CORE ---
local EspFolder = Instance.new("Folder", workspace); EspFolder.Name = "KryptonESP"
RunService.RenderStepped:Connect(function()
    EspFolder:ClearAllChildren()
    if not Config.PlayerESP then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            -- Box Highlight (Thick outline for clear detection)
            local box = Instance.new("Highlight", EspFolder)
            box.Adornee = p.Character; box.FillTransparency = 1; box.OutlineColor = Color3.fromRGB(255, 0, 0); box.OutlineThickness = 4
            
            -- High Definition Text Label
            local bg = Instance.new("BillboardGui", EspFolder)
            bg.Adornee = hrp; bg.Size = UDim2.new(0, 150, 0, 50); bg.StudsOffset = Vector3.new(0, 4, 0); bg.AlwaysOnTop = true
            local tl = Instance.new("TextLabel", bg)
            tl.Size = UDim2.new(1, 0, 1, 0); tl.Text = p.Name; tl.TextColor3 = Color3.fromRGB(255, 255, 255); tl.Font = Enum.Font.GothamBold; tl.TextSize = 15; tl.BackgroundTransparency = 1
            local tStroke = Instance.new("UIStroke", tl); tStroke.Color = Color3.fromRGB(0, 0, 0); tStroke.Thickness = 1.5
        end
    end
end)

-- --- ENGINE TICK LOOPS ---
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        if Config.Spin2D then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Config.SpinSpeed), 0) end
        if Config.Spin3D then hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(Config.SpinSpeed), math.rad(Config.SpinSpeed), math.rad(Config.SpinSpeed)) end
        if Config.AutoTeleport and Config.AutoTarget ~= "" then
            local t = Players:FindFirstChild(Config.AutoTarget)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then 
                hrp.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0) 
            end
        end
    end
end)

AddLog("SUCCESS", "Krypton Framework Loaded Successfully")
AddLog("INFO", "Ready to execute scripts")
