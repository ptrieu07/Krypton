-- KRYPTON - ENGLISH VERSION & TELEPORT TAB WITH PLAYER LIST
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Safe GUI Parent detection
local TargetParent = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
    if gethui then
        TargetParent = gethui()
    elseif game:GetService("CoreGui") then
        TargetParent = game:GetService("CoreGui")
    end
end)

if TargetParent:FindFirstChild("KryptonMain") then 
    TargetParent.KryptonMain:Destroy() 
end

if TargetParent:FindFirstChild("KryptonESP_Folder") then
    TargetParent.KryptonESP_Folder:Destroy()
end

local Config = {
    Speed = 16, Jump = 50, Fly = false, FlySpeed = 50,
    Noclip = false, Spin2D = false, Spin3D = false, SpinSpeed = 20,
    AntiFling = false, ClickTP = false, AutoTeleport = false, AutoTarget = "",
    
    -- AIMBOT CONFIG
    Aimbot = true, 
    AimPart = "HumanoidRootPart", 
    Smoothness = 1,              
    FOVSize = 30,                
    ShowFOV = true,
    HoldRightClickToAim = true,
    
    -- COMBINED ESP CONFIG
    PlayerESP = true,
    Brightness = 2, 
    FPSBoost = false
}

-- Right-Click listener for Aimbot
local IsHoldingRightClick = false
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsHoldingRightClick = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        IsHoldingRightClick = false
    end
end)

-- --- MM2 ROLE DETECTION ENGINE ---
local function GetPlayerRoleColor(player)
    local isMurderer = false
    local isSheriff = false

    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")

    local function scanTools(container)
        if not container then return end
        for _, item in pairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                if name:find("knife") or item:FindFirstChild("KnifeServer") or item:FindFirstChild("KnifeScript") then
                    isMurderer = true
                elseif name:find("gun") or name:find("revolver") or item:FindFirstChild("GunServer") or item:FindFirstChild("GunScript") then
                    isSheriff = true
                end
            end
        end
    end

    scanTools(char)
    scanTools(backpack)

    if isMurderer then
        return Color3.fromRGB(255, 30, 30), "Murderer"
    elseif isSheriff then
        return Color3.fromRGB(0, 150, 255), "Sheriff"
    else
        return Color3.fromRGB(0, 255, 120), "Innocent"
    end
end

-- --- DRAWING FOV CIRCLE ---
local FOVCircle
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.Color = Color3.fromRGB(255, 0, 0)
        FOVCircle.Filled = false
        FOVCircle.Transparency = 1
        FOVCircle.Visible = false
    end
end)

-- --- CUSTOM DRAG SYSTEM ---
local function MakeDraggable(dragPart, mainFrame)
    local dragging, dragStart, startPos
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then 
                    dragging = false 
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- --- UI MAIN FRAME ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KryptonMain"
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true
ScreenGui.Parent = TargetParent

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 650, 0, 420)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundTransparency = 1
MakeDraggable(TitleBar, MainFrame)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Text = "Krypton"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(0, 250, 1, 0)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1

-- --- INNER PANELS ---
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, -125)
Sidebar.Position = UDim2.new(0, 10, 0, 45)
Sidebar.BackgroundTransparency = 1

local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1, -160, 1, -125)
Content.Position = UDim2.new(0, 150, 0, 45)
Content.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", Content)
local ContentStroke = Instance.new("UIStroke", Content)
ContentStroke.Color = Color3.fromRGB(35, 35, 35)
ContentStroke.Thickness = 1

local Footer = Instance.new("Frame", MainFrame)
Footer.Size = UDim2.new(0.96, 0, 0, 65)
Footer.Position = UDim2.new(0.02, 0, 1, -75)
Footer.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Instance.new("UICorner", Footer)

local LogContainer = Instance.new("ScrollingFrame", Footer)
LogContainer.Size = UDim2.new(1, -20, 1, -10)
LogContainer.Position = UDim2.new(0, 10, 0, 5)
LogContainer.BackgroundTransparency = 1
LogContainer.ScrollBarThickness = 2

local LogLayout = Instance.new("UIListLayout", LogContainer)
LogLayout.Padding = UDim.new(0, 2)

local function AddLog(type, msg)
    pcall(function()
        local logLine = Instance.new("TextLabel", LogContainer)
        logLine.Size = UDim2.new(1, 0, 0, 16)
        logLine.BackgroundTransparency = 1
        logLine.Text = ">_  [" .. type .. "] " .. msg
        logLine.TextColor3 = (type == "SUCCESS") and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 255, 150)
        logLine.Font = Enum.Font.Code
        logLine.TextSize = 11
        logLine.TextXAlignment = Enum.TextXAlignment.Left
    end)
end

-- --- CONTROLS ---
local isMinimized = false
local function createControl(text, offset, callback)
    local btn = Instance.new("TextButton", TitleBar)
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.Position = UDim2.new(1, offset, 0, 2)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BackgroundTransparency = 1
    btn.MouseButton1Click:Connect(callback)
end

createControl("X", -35, function() 
    if FOVCircle then FOVCircle:Remove() end
    if TargetParent:FindFirstChild("KryptonESP_Folder") then
        TargetParent.KryptonESP_Folder:Destroy()
    end
    ScreenGui:Destroy() 
end)

createControl("—", -65, function() 
    isMinimized = not isMinimized
    Sidebar.Visible = not isMinimized
    Content.Visible = not isMinimized
    Footer.Visible = not isMinimized
    
    local targetSize = isMinimized and UDim2.new(0, 650, 0, 35) or UDim2.new(0, 650, 0, 420)
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- --- SMOOTH FLY ENGINE ---
local function StartFly()
    if not Config.Fly then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hrp or not hum then return end
    
    if hrp:FindFirstChild("KryFlyBV") then hrp.KryFlyBV:Destroy() end
    if hrp:FindFirstChild("KryFlyBG") then hrp.KryFlyBG:Destroy() end
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "KryFlyBV"
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp

    local bg = Instance.new("BodyGyro")
    bg.Name = "KryFlyBG"
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.P = 9000
    bg.CFrame = Camera.CFrame
    bg.Parent = hrp
    
    task.spawn(function()
        while Config.Fly and char and char.Parent and hrp and hrp.Parent and hum and hum.Parent do
            RunService.RenderStepped:Wait()
            
            hum.PlatformStand = true
            
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            
            bv.Velocity = dir * Config.FlySpeed
            bg.CFrame = Camera.CFrame
        end

        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        if hum then hum.PlatformStand = false end
    end)
end

-- --- REJOIN & SERVER HOP FUNCTIONS ---
local function RejoinServer()
    AddLog("INFO", "Reconnecting to old server...")
    if #Players:GetPlayers() <= 1 then
        LocalPlayer:Kick("\n[Krypton] Rejoining...")
        task.wait(0.5)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end

local function ServerHop()
    AddLog("INFO", "Finding another server...")
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    
    if success and result and result.data then
        local servers = {}
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
        else
            AddLog("ERROR", "No suitable server found!")
        end
    else
        AddLog("ERROR", "Failed to fetch server list!")
    end
end

-- --- TABS & COMPONENTS ---
local tabPanels = {}
local function createTab(name, index)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, (index-1)*36)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    Instance.new("UICorner", btn)
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Color3.fromRGB(45, 45, 45)
    
    local panel = Instance.new("ScrollingFrame", Content)
    panel.Size = UDim2.new(1, -20, 1, -20)
    panel.Position = UDim2.new(0, 10, 0, 10)
    panel.BackgroundTransparency = 1
    panel.Visible = (index == 1)
    panel.ScrollBarThickness = 2
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
        if callback then callback(Config[key]) end
    end)
end

local function addButton(tab, label, callback)
    local f = Instance.new("Frame", tabPanels[tab]); f.Size = UDim2.new(1, 0, 0, 32); f.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", btn)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

local function addSlider(tab, label, key, min, max, isFloat, callback)
    local f = Instance.new("Frame", tabPanels[tab]); f.Size = UDim2.new(1, 0, 0, 35); f.BackgroundTransparency = 1
    local displayVal = isFloat and string.format("%.2f", Config[key]) or Config[key]
    local l = Instance.new("TextLabel", f); l.Text = label .. " ["..displayVal.."]"; l.Size = UDim2.new(0, 150, 1, 0); l.TextColor3 = Color3.fromRGB(200, 200, 200); l.Font = Enum.Font.Gotham; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.BackgroundTransparency = 1
    local sBg = Instance.new("Frame", f); sBg.Size = UDim2.new(1, -160, 0, 4); sBg.Position = UDim2.new(0, 155, 0, 15); sBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45); Instance.new("UICorner", sBg)
    local fill = Instance.new("Frame", sBg); fill.Size = UDim2.new((Config[key]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 255, 120); Instance.new("UICorner", fill)
    
    local function update()
        local per = math.clamp((UserInputService:GetMouseLocation().X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(per, 0, 1, 0)
        local val = min + (max - min) * per
        if not isFloat then val = math.floor(val) end
        l.Text = label .. " ["..(isFloat and string.format("%.2f", val) or val).."]"
        Config[key] = val
        if callback then callback(val) end
    end

    sBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            update()
            local moveConn, releaseConn
            moveConn = UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement then update() end
            end)
            releaseConn = UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    moveConn:Disconnect()
                    releaseConn:Disconnect()
                end
            end)
        end
    end)
end

-- --- PLAYER TELEPORT DROPDOWN WIDGET ---
local function addPlayerTeleporter(tab)
    local f = Instance.new("Frame", tabPanels[tab]); f.Size = UDim2.new(1, 0, 0, 32); f.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.Text = "Player Teleport List [Closed]"
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", btn)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    
    local listFrame = Instance.new("ScrollingFrame", tabPanels[tab])
    listFrame.Size = UDim2.new(1, 0, 0, 130)
    listFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.ScrollBarThickness = 2
    Instance.new("UICorner", listFrame)
    local listLayout = Instance.new("UIListLayout", listFrame)
    listLayout.Padding = UDim.new(0, 3)
    
    local isOpen = false
    
    local function refreshList()
        for _, child in pairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local pBtn = Instance.new("TextButton", listFrame)
                pBtn.Size = UDim2.new(1, 0, 0, 28)
                pBtn.Text = "  > " .. player.DisplayName .. " (@" .. player.Name .. ")"
                pBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
                pBtn.Font = Enum.Font.Gotham
                pBtn.TextSize = 12
                pBtn.TextXAlignment = Enum.TextXAlignment.Left
                pBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                Instance.new("UICorner", pBtn)
                
                pBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        local targetChar = player.Character
                        local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetHrp and myHrp then
                            myHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
                            AddLog("SUCCESS", "Teleported to " .. player.DisplayName)
                        else
                            AddLog("ERROR", "Target player is not available!")
                        end
                    end)
                end)
            end
        end
        listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 5)
    end
    
    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listFrame.Visible = isOpen
        btn.Text = isOpen and "Player Teleport List [Opened]" or "Player Teleport List [Closed]"
        if isOpen then
            refreshList()
        end
    end)
end

-- --- CREATING TABS (ORDER: Player, Aim, Visual, Teleport, Server) ---
createTab("Player", 1)
createTab("Aim", 2)
createTab("Visual", 3)
createTab("Teleport", 4)
createTab("Server", 5)

-- --- TAB 1: PLAYER ---
addSlider("Player", "WalkSpeed", "Speed", 16, 250, false, function(v) pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = v end) end)
addSlider("Player", "JumpPower", "Jump", 50, 500, false, function(v) pcall(function() LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end) end)
addSlider("Player", "Fly Speed", "FlySpeed", 10, 300, false, function() end)
addSlider("Player", "Spin Speed", "SpinSpeed", 1, 100, false, function() end)
addSwitch("Player", "Flight", "Fly", function(v) 
    if v then 
        StartFly() 
    else 
        pcall(function() 
            if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("KryFlyBV") then LocalPlayer.Character.HumanoidRootPart.KryFlyBV:Destroy() end 
            if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("KryFlyBG") then LocalPlayer.Character.HumanoidRootPart.KryFlyBG:Destroy() end 
            if LocalPlayer.Character.Humanoid then LocalPlayer.Character.Humanoid.PlatformStand = false end
        end) 
    end 
end)
addSwitch("Player", "Noclip", "Noclip", function() end)
addSwitch("Player", "Anti Fling", "AntiFling", function() end)
addSwitch("Player", "Spin 2D", "Spin2D", function(v) if v then Config.Spin3D = false end end)
addSwitch("Player", "Spin 3D", "Spin3D", function(v) if v then Config.Spin2D = false end end)

-- --- TAB 2: AIM ---
addSwitch("Aim", "Enable Aimbot", "Aimbot", function() end)
addSwitch("Aim", "Hold Right-Click to Aim", "HoldRightClickToAim", function() end)
addSwitch("Aim", "Show FOV Circle", "ShowFOV", function() end)
addSlider("Aim", "FOV Size", "FOVSize", 10, 400, false, function() end)
addSlider("Aim", "Smoothness", "Smoothness", 0.1, 1.0, true, function() end)

-- --- TAB 3: VISUAL ---
addSlider("Visual", "Brightness", "Brightness", 0, 10, false, function(v) Lighting.Brightness = v end)
addSwitch("Visual", "Player ESP", "PlayerESP", function() end)
addSwitch("Visual", "FPS Boost", "FPSBoost", function(v)
    if v then 
        for _, obj in pairs(workspace:GetDescendants()) do if obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic end end
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = true
    end
end)

-- --- TAB 4: TELEPORT ---
addSwitch("Teleport", "Click TP (Ctrl+LClick)", "ClickTP", function() end)
addSwitch("Teleport", "Auto Above-Head TP", "AutoTeleport", function() end)
addPlayerTeleporter("Teleport")

-- --- TAB 5: SERVER ---
addButton("Server", "Rejoin Server", function() RejoinServer() end)
addButton("Server", "Server Hop", function() ServerHop() end)

-- --- AIMBOT ENGINE ---
local function GetClosestTargetInFOV()
    local closestPart = nil
    local shortestDistance = Config.FOVSize
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local targetPart = player.Character:FindFirstChild(Config.AimPart) or player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
            
            if hum and hum.Health > 0 and targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist <= shortestDistance then
                        shortestDistance = dist
                        closestPart = targetPart
                    end
                end
            end
        end
    end
    return closestPart
end

-- --- CORE ALL-IN-ONE ESP SYSTEM ---
local ESP_Folder = Instance.new("Folder")
ESP_Folder.Name = "KryptonESP_Folder"
ESP_Folder.Parent = TargetParent

local ESP_Cache = {}

local function ClearPlayerESP(player)
    if ESP_Cache[player] then
        if ESP_Cache[player].Tracer then pcall(function() ESP_Cache[player].Tracer:Remove() end) end
        if ESP_Cache[player].Box then pcall(function() ESP_Cache[player].Box:Remove() end) end
        if ESP_Cache[player].Highlight then ESP_Cache[player].Highlight:Destroy() end
        if ESP_Cache[player].Billboard then ESP_Cache[player].Billboard:Destroy() end
        ESP_Cache[player] = nil
    end
end

local function BuildESPForPlayer(player)
    if player == LocalPlayer then return end

    local function CreateElements(char)
        ClearPlayerESP(player)
        if not char then return end

        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end

        local hl = Instance.new("Highlight")
        hl.Name = player.Name .. "_HL"
        hl.Adornee = char
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Enabled = Config.PlayerESP
        hl.Parent = ESP_Folder

        local bg = Instance.new("BillboardGui")
        bg.Name = player.Name .. "_Name"
        bg.Adornee = hrp
        bg.Size = UDim2.new(0, 160, 0, 30)
        bg.StudsOffset = Vector3.new(0, 3.8, 0)
        bg.AlwaysOnTop = true
        bg.Enabled = Config.PlayerESP
        bg.Parent = ESP_Folder

        local tl = Instance.new("TextLabel", bg)
        tl.Size = UDim2.new(1, 0, 1, 0)
        tl.Text = player.DisplayName
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 13
        tl.BackgroundTransparency = 1
        local tStroke = Instance.new("UIStroke", tl)
        tStroke.Color = Color3.fromRGB(0, 0, 0)
        tStroke.Thickness = 1.5

        local tracer = nil
        local box = nil
        pcall(function()
            if Drawing and Drawing.new then
                tracer = Drawing.new("Line")
                tracer.Thickness = 1.5
                tracer.Transparency = 1
                tracer.Visible = false

                box = Drawing.new("Square")
                box.Thickness = 1.5
                box.Filled = false
                box.Transparency = 1
                box.Visible = false
            end
        end)

        ESP_Cache[player] = {
            Highlight = hl,
            Billboard = bg,
            Tracer = tracer,
            Box = box,
            Character = char,
            HRP = hrp,
            TextLabel = tl
        }
    end

    if player.Character then CreateElements(player.Character) end
    player.CharacterAdded:Connect(CreateElements)
end

for _, p in pairs(Players:GetPlayers()) do BuildESPForPlayer(p) end
Players.PlayerAdded:Connect(BuildESPForPlayer)
Players.PlayerRemoving:Connect(ClearPlayerESP)

-- --- MAIN RENDER LOOP ---
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    if FOVCircle then
        FOVCircle.Visible = Config.ShowFOV and Config.Aimbot
        FOVCircle.Radius = Config.FOVSize
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end

    -- Aimbot
    if Config.Aimbot then
        local shouldAim = true
        if Config.HoldRightClickToAim and not IsHoldingRightClick then shouldAim = false end

        if shouldAim then
            local target = GetClosestTargetInFOV()
            if target then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, math.clamp(Config.Smoothness, 0.1, 1))
            end
        end
    end

    -- ALL-IN-ONE ESP UPDATE
    for player, data in pairs(ESP_Cache) do
        local isAlive = data.Character and data.Character.Parent and data.HRP and data.HRP.Parent
        
        if isAlive and Config.PlayerESP then
            local roleColor, roleName = GetPlayerRoleColor(player)

            if data.Highlight then 
                data.Highlight.Enabled = true 
                data.Highlight.Adornee = data.Character
                data.Highlight.FillColor = roleColor
            end

            if data.Billboard and data.TextLabel then 
                data.Billboard.Enabled = true 
                data.Billboard.Adornee = data.HRP
                data.TextLabel.TextColor3 = roleColor
                data.TextLabel.Text = player.DisplayName .. " [" .. roleName .. "]"
            end

            local screenPos, onScreen = Camera:WorldToViewportPoint(data.HRP.Position)

            -- TRACER
            if data.Tracer then
                if onScreen then
                    data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    data.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    data.Tracer.Color = roleColor
                    data.Tracer.Visible = true
                else
                    data.Tracer.Visible = false
                end
            end

            -- RECTANGLE BOX ESP
            if data.Box then
                if onScreen then
                    local head = data.Character:FindFirstChild("Head")
                    if head then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(data.HRP.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 1.6

                        data.Box.Size = Vector2.new(width, height)
                        data.Box.Position = Vector2.new(screenPos.X - width / 2, headPos.Y)
                        data.Box.Color = roleColor
                        data.Box.Visible = true
                    else
                        data.Box.Visible = false
                    end
                else
                    data.Box.Visible = false
                end
            end
        else
            if data.Highlight then data.Highlight.Enabled = false end
            if data.Billboard then data.Billboard.Enabled = false end
            if data.Tracer then data.Tracer.Visible = false end
            if data.Box then data.Box.Visible = false end
        end
    end
end)

-- --- NOCLIP ENGINE ---
RunService.Stepped:Connect(function()
    if Config.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- --- CLICK TP ENGINE ---
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if Config.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = LocalPlayer:GetMouse()
        if mouse and mouse.Hit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
            AddLog("INFO", "Click TP Executed")
        end
    end
end)

-- --- SPIN, SPEED & PHYSICS ENFORCER ENGINE ---
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hum then
        if Config.Speed ~= 16 and hum.WalkSpeed ~= Config.Speed then hum.WalkSpeed = Config.Speed end
        if Config.Jump ~= 50 and hum.JumpPower ~= Config.Jump then hum.UseJumpPower = true; hum.JumpPower = Config.Jump end
    end

    if hrp and hum then
        -- SPIN ENGINE (BodyAngularVelocity with adjustable Speed slider)
        local bav = hrp:FindFirstChild("KrySpinBav")
        if Config.Spin2D or Config.Spin3D then
            hum.AutoRotate = false
            if not bav then
                bav = Instance.new("BodyAngularVelocity")
                bav.Name = "KrySpinBav"
                bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bav.P = 12500
                bav.Parent = hrp
            end
            
            local speedMultiplier = Config.SpinSpeed * 5
            if Config.Spin2D then
                bav.AngularVelocity = Vector3.new(0, speedMultiplier, 0)
            elseif Config.Spin3D then
                bav.AngularVelocity = Vector3.new(speedMultiplier, speedMultiplier, speedMultiplier)
            end
        else
            hum.AutoRotate = true
            if bav then bav:Destroy() end
        end

        if Config.AntiFling and (hrp.AssemblyLinearVelocity.Magnitude > 100 or hrp.AssemblyAngularVelocity.Magnitude > 100) then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
end)

-- --- LISTEN FOR RESPAWN ---
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then hum.WalkSpeed = Config.Speed; hum.UseJumpPower = true; hum.JumpPower = Config.Jump end
    if Config.Fly then task.wait(0.2); StartFly() end
    AddLog("INFO", "Settings re-applied on Respawn")
end)

AddLog("SUCCESS", "Krypton Ready!")
