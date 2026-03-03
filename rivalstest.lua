local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled


-- [[ SAFE UI PARENTING ]]
local function getSafeUIParent()
    local success, parent = pcall(function()
        if gethui then return gethui() end
        return CoreGui
    end)
    if success and parent then return parent end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local UIParent = getSafeUIParent()

-- [[ THEME & CONFIG ]]
local Theme = {
    BgDark       = Color3.fromRGB(22, 22, 26),
    BgMid        = Color3.fromRGB(30, 30, 36),
    BgButton     = Color3.fromRGB(42, 42, 50),
    BgButtonHov  = Color3.fromRGB(55, 55, 65),
    AccentCyan   = Color3.fromRGB(80, 220, 220),
    TextWhite    = Color3.fromRGB(255, 255, 255),
    TextGray     = Color3.fromRGB(170, 170, 185),
    TextDim      = Color3.fromRGB(110, 110, 130),
    ToggleOn     = Color3.fromRGB(80, 220, 180),
    ToggleOff    = Color3.fromRGB(70, 70, 85),
    Red          = Color3.fromRGB(239, 68, 68),
    Border       = Color3.fromRGB(60, 60, 75),
}

local KeyConfig = {
    HubName   = "Brandies Premium",
    KeyLink   = "https://brandieshub.work.gd/",
    VerifyAPI = "https://brandieshub.work.gd/api/verify?key=",
    FileName  = "BrandiesKey.txt"
}

-- [[ UTILITY FUNCTIONS ]]
local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.6
    s.Parent = parent
    return s
end

local function mkLabel(parent, text, size, color, font, xAlign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextSize = size or 14
    l.TextColor3 = color or Theme.TextWhite
    l.Font = font or Enum.Font.GothamSemibold
    l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function urlEncode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end)
        str = string.gsub(str, " ", "%%20")
    end
    return str
end

-- ==========================================
-- || 1. AUTO-SAVING KEY SYSTEM            ||
-- ==========================================
local function verifyKeyWithServer(key, onSuccess, onFail)
    local req = request or http_request or (syn and syn.request)
    if req then
        local gameName = "Unknown Game"
        pcall(function()
            gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
        end)
        local userName = LocalPlayer.Name
        local fullUrl = KeyConfig.VerifyAPI .. key .. "&user=" .. urlEncode(userName) .. "&game=" .. urlEncode(gameName)
        local success, res = pcall(function()
            return req({Url = fullUrl, Method = "GET"})
        end)
        if success and res and res.StatusCode == 200 and res.Body == "VALID" then
            onSuccess()
        else
            onFail("Failed! Key is invalid or expired.")
        end
    else
        onFail("Executor does not support HTTP requests.")
    end
end

local function ShowKeyUI(onSuccessCallback)
    pcall(function()
        if UIParent:FindFirstChild("UniversalKeySystem") then
            UIParent.UniversalKeySystem:Destroy()
        end
    end)

    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "UniversalKeySystem"
    KeyGui.ResetOnSpawn = false
    KeyGui.Parent = UIParent

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 360, 0, 225)
    MainFrame.Position = UDim2.new(0.5, -180, 0.5, -112)
    MainFrame.BackgroundColor3 = Theme.BgDark
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = KeyGui
    corner(MainFrame, 12)
    stroke(MainFrame, Theme.AccentCyan, 1.5, 0.4)

    local Title = mkLabel(MainFrame, KeyConfig.HubName .. "  —  Auth", 15, Theme.TextWhite, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    Title.Size = UDim2.new(1, 0, 0, 42)
    Title.TextYAlignment = Enum.TextYAlignment.Center

    local Div = Instance.new("Frame")
    Div.Size = UDim2.new(1, -30, 0, 1)
    Div.Position = UDim2.new(0, 15, 0, 42)
    Div.BackgroundColor3 = Theme.Border
    Div.BackgroundTransparency = 0.3
    Div.BorderSizePixel = 0
    Div.Parent = MainFrame

    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(1, -30, 0, 40)
    KeyInput.Position = UDim2.new(0, 15, 0, 54)
    KeyInput.BackgroundColor3 = Theme.BgMid
    KeyInput.TextColor3 = Theme.TextWhite
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.PlaceholderColor3 = Theme.TextDim
    KeyInput.Font = Enum.Font.Code
    KeyInput.TextSize = 14
    KeyInput.Text = ""
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = MainFrame
    corner(KeyInput, 8)
    stroke(KeyInput, Theme.Border, 1, 0.5)

    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(0, 155, 0, 36)
    CopyBtn.Position = UDim2.new(0, 15, 0, 106)
    CopyBtn.BackgroundColor3 = Theme.BgButton
    CopyBtn.Text = "Get Key Link"
    CopyBtn.TextColor3 = Theme.TextWhite
    CopyBtn.Font = Enum.Font.GothamSemibold
    CopyBtn.TextSize = 13
    CopyBtn.Parent = MainFrame
    corner(CopyBtn, 8)
    stroke(CopyBtn, Theme.Border, 1, 0.5)

    local VerifyBtn = Instance.new("TextButton")
    VerifyBtn.Size = UDim2.new(0, 155, 0, 36)
    VerifyBtn.Position = UDim2.new(1, -170, 0, 106)
    VerifyBtn.BackgroundColor3 = Theme.AccentCyan
    VerifyBtn.Text = "Verify Key"
    VerifyBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
    VerifyBtn.Font = Enum.Font.GothamBold
    VerifyBtn.TextSize = 13
    VerifyBtn.Parent = MainFrame
    corner(VerifyBtn, 8)

    local StatusText = mkLabel(MainFrame, "Waiting for input...", 12, Theme.TextDim, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    StatusText.Size = UDim2.new(1, 0, 0, 22)
    StatusText.Position = UDim2.new(0, 0, 0, 154)
    StatusText.TextYAlignment = Enum.TextYAlignment.Center

    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    CopyBtn.MouseEnter:Connect(function() tween(CopyBtn, {BackgroundColor3 = Theme.BgButtonHov}) end)
    CopyBtn.MouseLeave:Connect(function() tween(CopyBtn, {BackgroundColor3 = Theme.BgButton}) end)
    CopyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(KeyConfig.KeyLink)
            StatusText.Text = "Copied URL to clipboard!"
            StatusText.TextColor3 = Theme.AccentCyan
        end
    end)

    VerifyBtn.MouseButton1Click:Connect(function()
        local inputKey = KeyInput.Text
        if inputKey == "" then
            StatusText.Text = "Please enter a key first."
            StatusText.TextColor3 = Theme.Red
            return
        end
        StatusText.Text = "Checking key with server..."
        StatusText.TextColor3 = Theme.TextGray

        verifyKeyWithServer(inputKey, function()
            StatusText.Text = "Success! Loading..."
            StatusText.TextColor3 = Theme.AccentCyan
            _G.BrandiesKeyVerified = true
            if writefile then pcall(function() writefile(KeyConfig.FileName, inputKey) end) end
            task.wait(1)
            KeyGui:Destroy()
            onSuccessCallback()
        end, function(errMsg)
            StatusText.Text = errMsg
            StatusText.TextColor3 = Theme.Red
        end)
    end)
end

local function RunKeySystem(onSuccessCallback)
    if _G.BrandiesKeyVerified then onSuccessCallback(); return end
    if readfile and isfile and isfile(KeyConfig.FileName) then
        local savedKey = readfile(KeyConfig.FileName)
        verifyKeyWithServer(savedKey, function()
            _G.BrandiesKeyVerified = true
            onSuccessCallback()
        end, function()
            if delfile then pcall(function() delfile(KeyConfig.FileName) end) end
            ShowKeyUI(onSuccessCallback)
        end)
        return
    end
    ShowKeyUI(onSuccessCallback)
end

-- ==========================================
-- || 2. MAIN HUB (RIVALS OPTIMIZED)       ||
-- ==========================================
RunKeySystem(function()

    -- [[ CONFIGURATION SYSTEM ]]
    local ConfigName = "BrandiesUniversalConfig.json"
    local Config = {
        -- ESP
        ESPEnabled    = false,
        PlayerBoxes   = false,
        PlayerChams   = false,
        Distance      = false,
        ESPTeamCheck  = false,
        ESPRange      = 1500,
        -- NEW: Skeleton & Health Bar ESP
        SkeletonESP   = false,
        HealthBarESP  = false,
        -- Aimbot
        AimbotEnabled = false,
        AimbotKey     = Enum.UserInputType.MouseButton2,
        ShowFOV       = false,
        FOVRadius     = 150,
        Smoothness    = 0,
        TargetLock    = false,
        AimTeamCheck  = false,
        AimPart       = "Head",
        WallCheckMode = "off",
        -- NEW: Silent Aim
        SilentAim     = false,
        SilentAimKey  = Enum.UserInputType.MouseButton2,
        -- NEW: Hitbox Expander
        HitboxExpand  = false,
        HitboxSize    = 5,   -- max allowed: 5
        -- Settings
        HideKey       = Enum.KeyCode.RightShift,
        AutoSave      = false,
    }

    local function SaveConfig()
        if writefile then pcall(function() writefile(ConfigName, HttpService:JSONEncode(Config)) end) end
    end
    local function LoadConfig()
        if readfile and isfile and isfile(ConfigName) then
            pcall(function()
                local decoded = HttpService:JSONDecode(readfile(ConfigName))
                for k, v in pairs(decoded) do if Config[k] ~= nil then Config[k] = v end end
            end)
        end
    end
    local function DeleteConfig()
        if delfile and isfile and isfile(ConfigName) then pcall(function() delfile(ConfigName) end) end
    end
    task.spawn(function() while task.wait(5) do if Config.AutoSave then SaveConfig() end end end)
    LoadConfig()

    -- [[ DRAWING CACHE ]]
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Theme.AccentCyan
    FOVCircle.Thickness = 1.5
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.8
    FOVCircle.NumSides = 64

    -- ════════════════════════════════════════════
    -- ESP CACHE: boxes, distance, chams,
    --            + skeleton lines, health bar
    -- ════════════════════════════════════════════
    local espCache = {}
    local currentTarget = nil
    local isHoldingAim  = false

    -- Skeleton joint pairs (R6 + R15 compatible names)
    -- Each pair is {partA, partB}; if a part doesn't exist it's just skipped.
    local SKELETON_PAIRS = {
        -- Spine
        {"Head",        "UpperTorso"},
        {"UpperTorso",  "LowerTorso"},
        {"LowerTorso",  "HumanoidRootPart"},
        -- Arms
        {"UpperTorso",  "RightUpperArm"},
        {"RightUpperArm","RightLowerArm"},
        {"RightLowerArm","RightHand"},
        {"UpperTorso",  "LeftUpperArm"},
        {"LeftUpperArm","LeftLowerArm"},
        {"LeftLowerArm","LeftHand"},
        -- Legs
        {"LowerTorso",  "RightUpperLeg"},
        {"RightUpperLeg","RightLowerLeg"},
        {"RightLowerLeg","RightFoot"},
        {"LowerTorso",  "LeftUpperLeg"},
        {"LeftUpperLeg","LeftLowerLeg"},
        {"LeftLowerLeg","LeftFoot"},
        -- R6 fallbacks (Torso instead of UpperTorso/LowerTorso)
        {"Head",   "Torso"},
        {"Torso",  "Right Arm"},
        {"Right Arm","Right Hand"},  -- some games split arms
        {"Torso",  "Left Arm"},
        {"Left Arm","Left Hand"},
        {"Torso",  "Right Leg"},
        {"Right Leg","Right Foot"},
        {"Torso",  "Left Leg"},
        {"Left Leg","Left Foot"},
    }

    local function createESP(player)
        if espCache[player] then return end

        -- Box
        local box = Drawing.new("Square")
        box.Thickness = 1.5; box.Filled = false
        box.Color = Color3.fromRGB(255, 255, 255)

        -- Distance / name label
        local distText = Drawing.new("Text")
        distText.Size = 16; distText.Center = true; distText.Outline = true
        distText.Color = Color3.fromRGB(255, 255, 255)

        -- ── HEALTH BAR: two vertical rectangles (bg + fill) ──
        local hpBg = Drawing.new("Square")
        hpBg.Filled = true
        hpBg.Color  = Color3.fromRGB(20, 20, 20)
        hpBg.Transparency = 0.35

        local hpFill = Drawing.new("Square")
        hpFill.Filled = true
        hpFill.Color  = Color3.fromRGB(80, 220, 80)  -- starts green; updated each frame

        -- ── SKELETON: one Line drawing per joint pair ──
        local skeleLines = {}
        for _ = 1, #SKELETON_PAIRS do
            local line = Drawing.new("Line")
            line.Thickness = 1
            line.Visible   = false
            line.Color     = Color3.fromRGB(255, 255, 255)
            table.insert(skeleLines, line)
        end

        espCache[player] = {
            box        = box,
            distText   = distText,
            cham       = nil,
            hpBg       = hpBg,
            hpFill     = hpFill,
            skeleLines = skeleLines,
        }
    end

    local function removeESP(player)
        if not espCache[player] then return end
        local o = espCache[player]
        pcall(function() o.box:Remove() end)
        pcall(function() o.distText:Remove() end)
        pcall(function() o.hpBg:Remove() end)
        pcall(function() o.hpFill:Remove() end)
        for _, line in ipairs(o.skeleLines) do pcall(function() line:Remove() end) end
        if o.cham then pcall(function() o.cham:Destroy() end) end
        espCache[player] = nil
    end

    Players.PlayerAdded:Connect(createESP)
    Players.PlayerRemoving:Connect(removeESP)
    for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then createESP(v) end end

    pcall(function()
        if UIParent:FindFirstChild("BrandiesNewHub") then UIParent.BrandiesNewHub:Destroy() end
        if _G.RenderLoop then _G.RenderLoop:Disconnect() end
    end)

    -- ════════════════════════════════════════════
    -- HITBOX EXPANDER SYSTEM
    -- Scales the HumanoidRootPart (HRP) of each
    -- enemy to HitboxSize so projectiles/raycasts
    -- register on a bigger collision box.
    -- We only touch HRP — not visual parts — so
    -- the player model looks normal.
    -- ════════════════════════════════════════════
    local hitboxOriginals = {}   -- { [player] = originalSize }

    local function applyHitbox(player)
        if player == LocalPlayer then return end
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        -- Save original if not already saved
        if not hitboxOriginals[player] then
            hitboxOriginals[player] = hrp.Size
        end
        local s = math.clamp(Config.HitboxSize, 1, 5)  -- hard cap at 5
        hrp.Size = Vector3.new(s, s, s)
    end

    local function restoreHitbox(player)
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hitboxOriginals[player] then
            hrp.Size = hitboxOriginals[player]
        end
        hitboxOriginals[player] = nil
    end

    local function restoreAllHitboxes()
        for _, player in pairs(Players:GetPlayers()) do
            restoreHitbox(player)
        end
    end

    -- Re-apply on respawn
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(0.1)  -- wait a frame for HRP to be created
            if Config.HitboxExpand then applyHitbox(player) end
        end)
    end)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function()
                task.wait(0.1)
                if Config.HitboxExpand then applyHitbox(player) end
            end)
        end
    end

    -- ════════════════════════════════════════════
    -- SILENT AIM SYSTEM
    -- Hooks the projectile/tool fire remote so the
    -- server receives the enemy's position instead
    -- of where the local player actually aimed.
    -- Works by wrapping __newindex on the fire
    -- method of tools in the character.
    --
    -- How it works:
    --   1. We find the closest enemy within FOV
    --   2. When the player fires, we swap the
    --      target CFrame/position to the enemy
    --      before the remote reaches the server
    --   3. Visually the crosshair doesn't move
    -- ════════════════════════════════════════════
    local silentAimConnection = nil
    local isHoldingSilent     = false

    local function getSilentTarget(Camera)
        -- Reuse same FOV logic as aimbot
        local bestTarget, bestDist = nil, Config.FOVRadius
        local mousePos = UserInputService:GetMouseLocation()
        local center   = Vector2.new(mousePos.X, mousePos.Y)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                local targetPart = char and (char:FindFirstChild(Config.AimPart) or char:FindFirstChild("HumanoidRootPart"))
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if targetPart and hum and hum.Health > 0 then
                    local passTeam = not (Config.AimTeamCheck and isSameTeam(player))
                    if passTeam then
                        local sp, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d < bestDist then bestDist = d; bestTarget = targetPart end
                        end
                    end
                end
            end
        end
        return bestTarget
    end

    -- Hook every RemoteEvent FireServer / UnreliableRemoteEvent FireServer
    -- in the tool the local player is holding.
    -- We intercept the first CFrame or Vector3 argument and replace it with
    -- the enemy part's CFrame/position.
    local safeHookMT = nil

    local function hookSilentAim()
        if not (hookmetatable or hookfunction) then return end  -- executor must support hookmetatable
        if safeHookMT then return end  -- already hooked

        local mt = getrawmetatable(game)
        if not mt then return end

        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = function(self, ...)
            local method = getnamecallmethod()
            -- Only intercept FireServer on RemoteEvents / UnreliableRemotes
            if Config.SilentAim and isHoldingSilent and
               (method == "FireServer" or method == "Fire") and
               (self:IsA("RemoteEvent") or self:IsA("UnreliableRemoteEvent")) then

                local Camera = Workspace.CurrentCamera
                local target = Camera and getSilentTarget(Camera)
                if target then
                    -- Rebuild args: swap any CFrame/Vector3 with target position
                    local args = {...}
                    local newArgs = {}
                    local replaced = false
                    for i, arg in ipairs(args) do
                        if not replaced then
                            if typeof(arg) == "CFrame" then
                                newArgs[i] = CFrame.new(target.Position)
                                replaced = true
                            elseif typeof(arg) == "Vector3" then
                                newArgs[i] = target.Position
                                replaced = true
                            else
                                newArgs[i] = arg
                            end
                        else
                            newArgs[i] = arg
                        end
                    end
                    return oldNamecall(self, table.unpack(newArgs))
                end
            end
            return oldNamecall(self, ...)
        end
        setreadonly(mt, true)
        safeHookMT = mt
    end

    local function unhookSilentAim()
        -- We keep the hook active but Config.SilentAim gates it,
        -- so toggling off is instant and safe.
    end

    -- ════════════════════════════════════════════
    -- TEAM CHECK (unchanged from original)
    -- ════════════════════════════════════════════
    local function isSameTeam(player)
        if player == LocalPlayer then return true end
        if LocalPlayer.Team ~= nil and player.Team ~= nil then
            if LocalPlayer.Team == player.Team then return true end
        end
        local attrNames = {"Team","team","TeamId","TeamID","teamId","teamID"}
        for _, attr in ipairs(attrNames) do
            local myAttr    = LocalPlayer:GetAttribute(attr)
            local theirAttr = player:GetAttribute(attr)
            if myAttr ~= nil and theirAttr ~= nil then
                local ms = tostring(myAttr); local ts = tostring(theirAttr)
                if ms ~= "" and ms ~= "0" and ms ~= "None" and ms ~= "nil" then
                    if ms == ts then return true end
                end
            end
        end
        local myTV = LocalPlayer:FindFirstChild("Team") or LocalPlayer:FindFirstChild("team")
        local thTV = player:FindFirstChild("Team") or player:FindFirstChild("team")
        if myTV and thTV and myTV:IsA("ValueBase") and thTV:IsA("ValueBase") then
            local ms = tostring(myTV.Value); local ts = tostring(thTV.Value)
            if ms ~= "" and ms ~= "0" and ms ~= "None" and ms ~= "nil" then
                if ms == ts then return true end
            end
        end
        return false
    end

    local function checkWall(targetPart, Camera)
        if Config.WallCheckMode ~= "check" then return true end
        local char = LocalPlayer.Character
        if not char then return false end
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char, targetPart.Parent}
        rayParams.IgnoreWater = true
        local ray = Workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, rayParams)
        return ray == nil
    end

    local function getAimbotTarget(Camera)
        local bestTarget, bestDistance = nil, Config.FOVRadius
        local mousePos = UserInputService:GetMouseLocation()
        local center = Vector2.new(mousePos.X, mousePos.Y)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                local targetPart = char and (char:FindFirstChild(Config.AimPart) or char:FindFirstChild("HumanoidRootPart"))
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if targetPart and hum and hum.Health > 0 then
                    local passTeamCheck = not (Config.AimTeamCheck and isSameTeam(player))
                    if passTeamCheck and checkWall(targetPart, Camera) then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if dist < bestDistance then bestDistance = dist; bestTarget = targetPart end
                        end
                    end
                end
            end
        end
        return bestTarget
    end

    -- ════════════════════════════════════════════
    -- MAIN RENDER LOOP
    -- ════════════════════════════════════════════
    _G.RenderLoop = RunService.RenderStepped:Connect(function(deltaTime)
        local Camera = Workspace.CurrentCamera
        if not Camera then return end

        local mouseLoc = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mouseLoc.X, mouseLoc.Y)
        FOVCircle.Radius   = Config.FOVRadius
        FOVCircle.Visible  = Config.ShowFOV and Config.AimbotEnabled

        -- ── HITBOX EXPANDER: apply/restore every frame ───────
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if Config.HitboxExpand then
                        local s = math.clamp(Config.HitboxSize, 1, 5)  -- hard cap at 5
                        hrp.Size = Vector3.new(s, s, s)
                        hrp.Transparency = 0.8   -- faint box visible for debugging; set 1 to fully hide
                    elseif hitboxOriginals[player] then
                        hrp.Size = hitboxOriginals[player]
                        hrp.Transparency = 1
                        hitboxOriginals[player] = nil
                    end
                end
            end
        end

        -- ── AIMBOT ───────────────────────────────────────────
        if Config.AimbotEnabled and isHoldingAim then
            if Config.TargetLock and currentTarget and currentTarget.Parent then
                local hum = currentTarget.Parent:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 or not checkWall(currentTarget, Camera) then
                    currentTarget = getAimbotTarget(Camera)
                end
            else
                currentTarget = getAimbotTarget(Camera)
            end

            if currentTarget then
                local targetPos = currentTarget.Position
                if mousemoverel and not isMobile then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                    if onScreen then
                        local center = UserInputService:GetMouseLocation()
                        local diffX = screenPos.X - center.X
                        local diffY = screenPos.Y - center.Y
                        local smoothFactor = (Config.Smoothness <= 0) and 1 or math.clamp(1 - (Config.Smoothness / 100), 0.01, 1)
                        mousemoverel(diffX * smoothFactor * 0.6, diffY * smoothFactor * 0.6)
                    end
                else
                    local camUp = Camera.CFrame.UpVector
                    local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos, camUp)
                    if Config.Smoothness <= 0 then
                        Camera.CFrame = targetCFrame
                    else
                        local alpha = math.clamp(1 - (Config.Smoothness / 100), 0.01, 1)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
                    end
                end
            end
        else
            currentTarget = nil
        end

        -- ── ESP + SKELETON + HEALTH BAR ──────────────────────
        for player, objs in pairs(espCache) do
            local char  = player.Character
            local hrp   = char and char:FindFirstChild("HumanoidRootPart")
            local hum   = char and char:FindFirstChildOfClass("Humanoid")
            local isAlive = hrp and hum and hum.Health > 0

            local dist3D  = hrp and math.floor((Camera.CFrame.Position - hrp.Position).Magnitude) or 0
            local passDist = dist3D <= Config.ESPRange
            local passTeam = not (Config.ESPTeamCheck and isAlive and isSameTeam(player))

            local shouldDraw = Config.ESPEnabled and isAlive and passTeam and passDist

            -- ── CHAMS ──
            if shouldDraw and Config.PlayerChams then
                if not objs.cham or objs.cham.Parent ~= char then
                    if objs.cham then objs.cham:Destroy() end
                    objs.cham = Instance.new("Highlight")
                    objs.cham.Name = "BrandiesESP_Cham"
                    objs.cham.FillTransparency = 0.5
                    objs.cham.OutlineTransparency = 0
                    objs.cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    objs.cham.Parent = char
                end
                local isEnemy = not isSameTeam(player)
                local teamColor = isEnemy and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 140, 255)
                objs.cham.Enabled = true
                objs.cham.FillColor = teamColor
                objs.cham.OutlineColor = teamColor
            else
                if objs.cham then objs.cham.Enabled = false end
            end

            if shouldDraw then
                local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local head = char:FindFirstChild("Head")
                local isEnemy = not isSameTeam(player)
                local teamColor = isEnemy and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 140, 255)

                if onScreen and head then
                    local headSP = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legSP  = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(legSP.Y - headSP.Y)
                    local width  = height / 2
                    local boxTop = math.min(headSP.Y, legSP.Y)
                    local boxLeft = headSP.X - width / 2

                    -- ── BOX ──
                    if Config.PlayerBoxes then
                        objs.box.Size     = Vector2.new(width, height)
                        objs.box.Position = Vector2.new(boxLeft, boxTop)
                        objs.box.Visible  = true
                        objs.box.Color    = teamColor
                    else
                        objs.box.Visible = false
                    end

                    -- ── DISTANCE TEXT ──
                    if Config.Distance then
                        objs.distText.Text     = "[" .. dist3D .. "m]"
                        objs.distText.Position = Vector2.new(headSP.X, boxTop - 18)
                        objs.distText.Visible  = true
                        objs.distText.Color    = teamColor
                    else
                        objs.distText.Visible = false
                    end

                    -- ════════════════════════════════════════
                    -- HEALTH BAR ESP
                    -- Draws a vertical bar to the LEFT of the
                    -- box. Bar height = box height.
                    -- Color shifts green → yellow → red based
                    -- on health percentage.
                    -- ════════════════════════════════════════
                    if Config.HealthBarESP then
                        local barW   = 4
                        local barGap = 3                      -- gap between box and bar
                        local barX   = boxLeft - barW - barGap
                        local barY   = boxTop
                        local hpPct  = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

                        -- Background (dark, full height)
                        objs.hpBg.Size     = Vector2.new(barW, height)
                        objs.hpBg.Position = Vector2.new(barX, barY)
                        objs.hpBg.Visible  = true

                        -- Fill (colored, shrinks from bottom as HP drops)
                        local fillH = height * hpPct
                        objs.hpFill.Size     = Vector2.new(barW, fillH)
                        objs.hpFill.Position = Vector2.new(barX, barY + (height - fillH))
                        objs.hpFill.Visible  = true

                        -- Shift color: green (100%) → yellow (50%) → red (0%)
                        local r = math.clamp(2 * (1 - hpPct), 0, 1)
                        local g = math.clamp(2 * hpPct,       0, 1)
                        objs.hpFill.Color = Color3.new(r, g, 0)
                    else
                        objs.hpBg.Visible   = false
                        objs.hpFill.Visible = false
                    end

                    -- ════════════════════════════════════════
                    -- SKELETON ESP
                    -- Projects each joint pair to screen space
                    -- and draws a line between them.
                    -- Lines that have an off-screen endpoint
                    -- or missing part are hidden.
                    -- ════════════════════════════════════════
                    if Config.SkeletonESP then
                        for i, pair in ipairs(SKELETON_PAIRS) do
                            local line  = objs.skeleLines[i]
                            local partA = char:FindFirstChild(pair[1])
                            local partB = char:FindFirstChild(pair[2])

                            if partA and partB then
                                local spA, onA = Camera:WorldToViewportPoint(partA.Position)
                                local spB, onB = Camera:WorldToViewportPoint(partB.Position)
                                if onA and onB then
                                    line.From    = Vector2.new(spA.X, spA.Y)
                                    line.To      = Vector2.new(spB.X, spB.Y)
                                    line.Color   = teamColor
                                    line.Visible = true
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        end
                    else
                        for _, line in ipairs(objs.skeleLines) do line.Visible = false end
                    end

                else
                    -- Off screen: hide everything
                    objs.box.Visible      = false
                    objs.distText.Visible = false
                    objs.hpBg.Visible     = false
                    objs.hpFill.Visible   = false
                    for _, line in ipairs(objs.skeleLines) do line.Visible = false end
                end
            else
                -- ESP off or player dead/filtered
                objs.box.Visible      = false
                objs.distText.Visible = false
                objs.hpBg.Visible     = false
                objs.hpFill.Visible   = false
                for _, line in ipairs(objs.skeleLines) do line.Visible = false end
                if objs.cham then objs.cham.Enabled = false end
            end
        end
    end)

    -- Hook silent aim after loop starts
    task.spawn(hookSilentAim)

    -- ==========================================
    -- || UI CONSTRUCTION                      ||
    -- ==========================================
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BrandiesNewHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = UIParent

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0.04, 0, 0.08, 0)
    ToggleBtn.BackgroundColor3 = Theme.BgMid
    ToggleBtn.Text = "B"
    ToggleBtn.TextColor3 = Theme.AccentCyan
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextScaled = true
    ToggleBtn.ZIndex = 10
    ToggleBtn.Parent = ScreenGui
    corner(ToggleBtn, 14)
    stroke(ToggleBtn, Theme.AccentCyan, 1.5, 0.4)

    local MobileAimBtn = Instance.new("TextButton")
    MobileAimBtn.Size = UDim2.new(0, 55, 0, 55)
    MobileAimBtn.Position = UDim2.new(0.8, 0, 0.6, 0)
    MobileAimBtn.BackgroundColor3 = Theme.Red
    MobileAimBtn.TextColor3 = Theme.TextWhite
    MobileAimBtn.Text = "AIM"
    MobileAimBtn.Font = Enum.Font.GothamBold
    MobileAimBtn.TextScaled = true
    MobileAimBtn.Visible = false
    MobileAimBtn.ZIndex = 10
    MobileAimBtn.Parent = ScreenGui
    corner(MobileAimBtn, 30)
    stroke(MobileAimBtn, Theme.TextWhite, 2, 0.3)

    do
        local dragging, dragStart, startPos
        ToggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (input.Position - dragStart).X, startPos.Y.Scale, startPos.Y.Offset + (input.Position - dragStart).Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
    end

    do
        local aimDrag, aimStart, aimPos
        MobileAimBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isHoldingAim = true
                aimDrag = true; aimStart = input.Position; aimPos = MobileAimBtn.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then aimDrag = false; isHoldingAim = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if aimDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                MobileAimBtn.Position = UDim2.new(aimPos.X.Scale, aimPos.X.Offset + (input.Position - aimStart).X, aimPos.Y.Scale, aimPos.Y.Offset + (input.Position - aimStart).Y)
            end
        end)
    end

    -- MAIN FRAME
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 560, 0, 520)   -- taller to fit new sections
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -260)
    MainFrame.BackgroundColor3 = Theme.BgDark
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui
    corner(MainFrame, 16)
    stroke(MainFrame, Theme.Border, 1.5, 0.3)

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 22)),
    })
    grad.Rotation = 135
    grad.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 48)
    TopBar.BackgroundColor3 = Theme.BgMid
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    corner(TopBar, 16)

    local TopBarFill = Instance.new("Frame")
    TopBarFill.Size = UDim2.new(1, 0, 0.5, 0)
    TopBarFill.Position = UDim2.new(0, 0, 0.5, 0)
    TopBarFill.BackgroundColor3 = Theme.BgMid
    TopBarFill.BorderSizePixel = 0
    TopBarFill.Parent = TopBar

    local TopBarLine = Instance.new("Frame")
    TopBarLine.Size = UDim2.new(1, 0, 0, 1)
    TopBarLine.Position = UDim2.new(0, 0, 1, -1)
    TopBarLine.BackgroundColor3 = Theme.Border
    TopBarLine.BackgroundTransparency = 0.4
    TopBarLine.BorderSizePixel = 0
    TopBarLine.Parent = TopBar

    local LogoIcon = mkLabel(TopBar, "B", 22, Theme.AccentCyan, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    LogoIcon.Size = UDim2.new(0, 36, 1, 0)
    LogoIcon.Position = UDim2.new(0, 8, 0, 0)
    LogoIcon.TextYAlignment = Enum.TextYAlignment.Center
    LogoIcon.ZIndex = 2

    local HubTitle = mkLabel(TopBar, "Brandies Premium", 15, Theme.TextWhite, Enum.Font.GothamBold)
    HubTitle.Size = UDim2.new(0, 260, 1, 0)
    HubTitle.Position = UDim2.new(0, 48, 0, 0)
    HubTitle.TextYAlignment = Enum.TextYAlignment.Center
    HubTitle.ZIndex = 2

    local topBtnDefs = {{text = "Home", w = 62}, {text = "X", w = 36, accent = true}}
    local tbX = 560
    for i = #topBtnDefs, 1, -1 do
        local b = topBtnDefs[i]
        tbX = tbX - b.w - 6
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, b.w, 0, 30)
        btn.Position = UDim2.new(0, tbX, 0, 9)
        btn.BackgroundColor3 = b.accent and Theme.Red or Theme.BgButton
        btn.Text = b.text
        btn.TextColor3 = Theme.TextWhite
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.ZIndex = 3
        btn.Parent = TopBar
        corner(btn, 8)
        if not b.accent then stroke(btn, Theme.Border, 1, 0.5) end
        btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = b.accent and Color3.fromRGB(200, 40, 40) or Theme.BgButtonHov}) end)
        btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = b.accent and Theme.Red or Theme.BgButton}) end)
        if b.text == "X" then btn.MouseButton1Click:Connect(function() MainFrame.Visible = false end) end
    end

    do
        local dragging, dragInput, dragStart, startPos
        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = MainFrame.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        TopBar.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -12, 1, -56)
    ScrollFrame.Position = UDim2.new(0, 6, 0, 52)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 3
    ScrollFrame.ScrollBarImageColor3 = Theme.AccentCyan
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Parent = MainFrame

    local ScrollLayout = Instance.new("UIListLayout")
    ScrollLayout.Padding = UDim.new(0, 10)
    ScrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ScrollLayout.Parent = ScrollFrame

    local ScrollPad = Instance.new("UIPadding")
    ScrollPad.PaddingTop = UDim.new(0, 10)
    ScrollPad.PaddingBottom = UDim.new(0, 14)
    ScrollPad.PaddingLeft = UDim.new(0, 10)
    ScrollPad.PaddingRight = UDim.new(0, 10)
    ScrollPad.Parent = ScrollFrame

    -- [[ UI ELEMENT BUILDERS ]] (unchanged from original)
    local function createSection(title)
        local sec = Instance.new("Frame")
        sec.Size = UDim2.new(1, 0, 0, 28)
        sec.BackgroundTransparency = 1
        sec.Parent = ScrollFrame
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0.5, 0)
        line.BackgroundColor3 = Theme.Border
        line.BackgroundTransparency = 0.2
        line.BorderSizePixel = 0
        line.Parent = sec
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(0, 0, 1, 0)
        bg.AutomaticSize = Enum.AutomaticSize.X
        bg.BackgroundColor3 = Theme.BgDark
        bg.BorderSizePixel = 0
        bg.Parent = sec
        local lbl = mkLabel(bg, "  " .. title .. "  ", 11, Theme.AccentCyan, Enum.Font.GothamBold)
        lbl.Size = UDim2.new(0, 0, 1, 0)
        lbl.AutomaticSize = Enum.AutomaticSize.X
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        return sec
    end

    local function createGrid()
        local grid = Instance.new("Frame")
        grid.Size = UDim2.new(1, 0, 0, 0)
        grid.AutomaticSize = Enum.AutomaticSize.Y
        grid.BackgroundTransparency = 1
        grid.Parent = ScrollFrame
        local layout = Instance.new("UIGridLayout")
        layout.CellSize = UDim2.new(0.5, -6, 0, 38)
        layout.CellPadding = UDim2.new(0, 6, 0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = grid
        return grid
    end

    local function createFullRow()
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 0)
        row.AutomaticSize = Enum.AutomaticSize.Y
        row.BackgroundTransparency = 1
        row.Parent = ScrollFrame
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Parent = row
        return row
    end

    local function createToggle(parent, labelText, configKey, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = Theme.BgMid
        row.BorderSizePixel = 0
        row.Parent = parent
        corner(row, 9); stroke(row, Theme.Border, 1, 0.55)
        local lbl = mkLabel(row, labelText, 12, Theme.TextWhite, Enum.Font.GothamSemibold)
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        local trackBg = Instance.new("Frame")
        trackBg.Size = UDim2.new(0, 42, 0, 22)
        trackBg.Position = UDim2.new(1, -50, 0.5, -11)
        trackBg.BackgroundColor3 = Config[configKey] and Theme.ToggleOn or Theme.ToggleOff
        trackBg.BorderSizePixel = 0
        trackBg.Parent = row
        corner(trackBg, 11)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = Config[configKey] and UDim2.new(0, 23, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        knob.BackgroundColor3 = Theme.TextWhite
        knob.BorderSizePixel = 0
        knob.Parent = trackBg
        corner(knob, 8)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = row
        btn.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            tween(trackBg, {BackgroundColor3 = Config[configKey] and Theme.ToggleOn or Theme.ToggleOff})
            tween(knob, {Position = Config[configKey] and UDim2.new(0, 23, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
            if callback then callback(Config[configKey]) end
        end)
    end

    local function createSlider(parent, labelText, maxVal, configKey, decimals)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 52)
        row.BackgroundColor3 = Theme.BgMid
        row.BorderSizePixel = 0
        row.Parent = parent
        corner(row, 9); stroke(row, Theme.Border, 1, 0.55)
        local lbl = mkLabel(row, labelText .. ": " .. tostring(Config[configKey]), 12, Theme.TextWhite, Enum.Font.GothamSemibold)
        lbl.Size = UDim2.new(1, -16, 0, 22)
        lbl.Position = UDim2.new(0, 10, 0, 5)
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -20, 0, 8)
        track.Position = UDim2.new(0, 10, 0, 34)
        track.BackgroundColor3 = Theme.BgButton
        track.BorderSizePixel = 0
        track.Parent = row
        corner(track, 4)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(Config[configKey] / maxVal, 0, 1, 0)
        fill.BackgroundColor3 = Theme.AccentCyan
        fill.BorderSizePixel = 0
        fill.Parent = track
        corner(fill, 4)
        local sliderBtn = Instance.new("TextButton")
        sliderBtn.Size = UDim2.new(1, 0, 1, 10)
        sliderBtn.Position = UDim2.new(0, 0, 0, -5)
        sliderBtn.BackgroundTransparency = 1
        sliderBtn.Text = ""
        sliderBtn.Parent = track
        local isDragging = false
        local function updateSlider(input)
            local rx = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local pct = rx / track.AbsoluteSize.X
            fill.Size = UDim2.new(pct, 0, 1, 0)
            local val = pct * maxVal
            val = decimals and (math.floor(val * 100) / 100) or math.floor(val)
            Config[configKey] = val
            lbl.Text = labelText .. ": " .. tostring(val)
        end
        sliderBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true; updateSlider(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSlider(input) end
        end)
    end

    local function createDropdown(parent, labelText, options, configKey)
        local ITEM_H = 34
        local currentLabel = options[1].label
        for _, opt in ipairs(options) do if opt.value == Config[configKey] then currentLabel = opt.label; break end end
        local collapsed = true
        local wrapper = Instance.new("Frame")
        wrapper.Size = UDim2.new(1, 0, 0, 44)
        wrapper.BackgroundTransparency = 1
        wrapper.ClipsDescendants = false
        wrapper.ZIndex = 5
        wrapper.Parent = parent
        local header = Instance.new("Frame")
        header.Size = UDim2.new(1, 0, 0, 44)
        header.BackgroundColor3 = Theme.BgMid
        header.BorderSizePixel = 0
        header.ZIndex = 5
        header.Parent = wrapper
        corner(header, 9); stroke(header, Theme.Border, 1, 0.55)
        local lblLeft = mkLabel(header, labelText, 12, Theme.TextWhite, Enum.Font.GothamSemibold)
        lblLeft.Size = UDim2.new(0.44, 0, 1, 0)
        lblLeft.Position = UDim2.new(0, 10, 0, 0)
        lblLeft.TextYAlignment = Enum.TextYAlignment.Center
        lblLeft.ZIndex = 6
        local selectedLbl = mkLabel(header, currentLabel, 11, Theme.AccentCyan, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
        selectedLbl.Size = UDim2.new(0, 135, 1, 0)
        selectedLbl.Position = UDim2.new(1, -158, 0, 0)
        selectedLbl.TextYAlignment = Enum.TextYAlignment.Center
        selectedLbl.ZIndex = 6
        local arrow = mkLabel(header, "▼", 11, Theme.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        arrow.Size = UDim2.new(0, 22, 1, 0)
        arrow.Position = UDim2.new(1, -24, 0, 0)
        arrow.TextYAlignment = Enum.TextYAlignment.Center
        arrow.ZIndex = 6
        local totalListHeight = #options * ITEM_H + 6
        local listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(1, 0, 0, totalListHeight)
        listFrame.Position = UDim2.new(0, 0, 0, 48)
        listFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
        listFrame.BorderSizePixel = 0
        listFrame.Visible = false
        listFrame.ZIndex = 50
        listFrame.Parent = wrapper
        corner(listFrame, 9); stroke(listFrame, Theme.AccentCyan, 1, 0.45)
        local listPad = Instance.new("UIPadding")
        listPad.PaddingTop = UDim.new(0, 3); listPad.PaddingBottom = UDim.new(0, 3)
        listPad.PaddingLeft = UDim.new(0, 4); listPad.PaddingRight = UDim.new(0, 4)
        listPad.Parent = listFrame
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = listFrame
        for _, opt in ipairs(options) do
            local isSelected = (opt.value == Config[configKey])
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, ITEM_H)
            itemBtn.BackgroundColor3 = Theme.BgButton
            itemBtn.BackgroundTransparency = isSelected and 0 or 1
            itemBtn.Text = opt.label
            itemBtn.TextColor3 = isSelected and Theme.AccentCyan or Theme.TextGray
            itemBtn.Font = Enum.Font.GothamSemibold
            itemBtn.TextSize = 12
            itemBtn.ZIndex = 51
            itemBtn.Parent = listFrame
            corner(itemBtn, 7)
            local capturedOpt = opt
            itemBtn.MouseEnter:Connect(function()
                if capturedOpt.value ~= Config[configKey] then tween(itemBtn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.BgButtonHov}); itemBtn.TextColor3 = Theme.TextWhite end
            end)
            itemBtn.MouseLeave:Connect(function()
                if capturedOpt.value ~= Config[configKey] then tween(itemBtn, {BackgroundTransparency = 1}); itemBtn.TextColor3 = Theme.TextGray end
            end)
            itemBtn.MouseButton1Click:Connect(function()
                Config[configKey] = capturedOpt.value; selectedLbl.Text = capturedOpt.label
                for _, child in ipairs(listFrame:GetChildren()) do
                    if child:IsA("TextButton") then child.BackgroundTransparency = 1; child.TextColor3 = Theme.TextGray end
                end
                itemBtn.BackgroundTransparency = 0; itemBtn.BackgroundColor3 = Theme.BgButton; itemBtn.TextColor3 = Theme.AccentCyan
                collapsed = true; listFrame.Visible = false; arrow.Text = "▼"
                wrapper.Size = UDim2.new(1, 0, 0, 44)
            end)
        end
        local headerBtn = Instance.new("TextButton")
        headerBtn.Size = UDim2.new(1, 0, 1, 0)
        headerBtn.BackgroundTransparency = 1
        headerBtn.Text = ""
        headerBtn.ZIndex = 7
        headerBtn.Parent = header
        headerBtn.MouseButton1Click:Connect(function()
            collapsed = not collapsed; listFrame.Visible = not collapsed; arrow.Text = collapsed and "▼" or "▲"
            wrapper.Size = collapsed and UDim2.new(1, 0, 0, 44) or UDim2.new(1, 0, 0, 44 + 4 + totalListHeight)
        end)
    end

    local function createKeybind(parent, labelText, configKey)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = Theme.BgMid
        row.BorderSizePixel = 0
        row.Parent = parent
        corner(row, 9); stroke(row, Theme.Border, 1, 0.55)
        local lbl = mkLabel(row, labelText, 12, Theme.TextGray, Enum.Font.GothamSemibold)
        lbl.Size = UDim2.new(0.58, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        local BindBtn = Instance.new("TextButton")
        BindBtn.Size = UDim2.new(0, 110, 0, 26)
        BindBtn.Position = UDim2.new(1, -118, 0.5, -13)
        BindBtn.BackgroundColor3 = Theme.BgButton
        BindBtn.Text = (type(Config[configKey]) == "userdata") and Config[configKey].Name or tostring(Config[configKey])
        BindBtn.TextColor3 = Theme.AccentCyan
        BindBtn.Font = Enum.Font.GothamBold
        BindBtn.TextSize = 11
        BindBtn.Parent = row
        corner(BindBtn, 7); stroke(BindBtn, Theme.AccentCyan, 1, 0.6)
        local isBinding = false
        BindBtn.MouseButton1Click:Connect(function()
            isBinding = true; BindBtn.Text = "Press key..."
            tween(BindBtn, {BackgroundColor3 = Theme.BgButtonHov})
        end)
        UserInputService.InputBegan:Connect(function(input)
            if isBinding then
                isBinding = false
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    Config[configKey] = input.KeyCode; BindBtn.Text = input.KeyCode.Name
                elseif input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.MouseButton2
                    or input.UserInputType == Enum.UserInputType.MouseButton3 then
                    Config[configKey] = input.UserInputType; BindBtn.Text = input.UserInputType.Name
                end
                tween(BindBtn, {BackgroundColor3 = Theme.BgButton})
            end
        end)
    end

    local function createButton(parent, labelText, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = Theme.BgButton
        btn.Text = labelText
        btn.TextColor3 = Theme.TextWhite
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = parent
        corner(btn, 9); stroke(btn, Theme.AccentCyan, 1.5, 0.4)
        btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Theme.BgButtonHov}) end)
        btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Theme.BgButton}) end)
        btn.MouseButton1Click:Connect(callback)
    end

    -- ===================== UI LAYOUT =====================

    -- ── ESP ──────────────────────────────────────────────────
    createSection("  ESP  ")
    local espGrid = createGrid()
    createToggle(espGrid, "Enable ESP",     "ESPEnabled")
    createToggle(espGrid, "Player Boxes",   "PlayerBoxes")
    createToggle(espGrid, "Player Chams",   "PlayerChams")
    createToggle(espGrid, "Show Distance",  "Distance")
    createToggle(espGrid, "ESP Team Check", "ESPTeamCheck")
    -- NEW toggles in the same grid
    createToggle(espGrid, "Skeleton ESP",   "SkeletonESP")
    createToggle(espGrid, "Health Bar ESP", "HealthBarESP")

    local espFullRow = createFullRow()
    createSlider(espFullRow, "Max Range (m)", 3000, "ESPRange", false)

    -- ── AIMBOT ───────────────────────────────────────────────
    createSection("  AIMBOT  ")
    local aimGrid = createGrid()
    createToggle(aimGrid, "Enable Aimbot",  "AimbotEnabled", function(state)
        if isMobile then MobileAimBtn.Visible = state end
    end)
    createToggle(aimGrid, "Show FOV Circle","ShowFOV")
    createToggle(aimGrid, "Target Lock",    "TargetLock")
    createToggle(aimGrid, "Aim Team Check", "AimTeamCheck")

    local aimDropdowns = createFullRow()
    createDropdown(aimDropdowns, "Aim Part", {
        {label = "Head",  value = "Head"},
        {label = "Torso", value = "HumanoidRootPart"},
    }, "AimPart")
    createDropdown(aimDropdowns, "Wall Check", {
        {label = "Off  (Aim Through Walls)",  value = "off"},
        {label = "On  (Skip Walled Targets)", value = "check"},
    }, "WallCheckMode")

    local aimSliders = createFullRow()
    createSlider(aimSliders, "FOV Radius",             500, "FOVRadius",  false)
    createSlider(aimSliders, "Smoothness (0=Instant)", 100, "Smoothness", false)

    local aimBindRow = createFullRow()
    createKeybind(aimBindRow, "Aim Keybind", "AimbotKey")

    -- ════════════════════════════════════════════
    -- NEW SECTION: SILENT AIM
    -- ════════════════════════════════════════════
    createSection("  SILENT AIM  ")
    local saGrid = createGrid()
    createToggle(saGrid, "Enable Silent Aim", "SilentAim", function(state)
        isHoldingSilent = state
        if state then
            hookSilentAim()
        end
    end)

    local saBindRow = createFullRow()
    createKeybind(saBindRow, "Silent Aim Key", "SilentAimKey")

    -- Wire the keybind for silent aim hold mode
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and Config.SilentAim then
            local isKey = (input.KeyCode == Config.SilentAimKey) or (input.UserInputType == Config.SilentAimKey)
            if isKey then isHoldingSilent = true end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if Config.SilentAim then
            local isKey = (input.KeyCode == Config.SilentAimKey) or (input.UserInputType == Config.SilentAimKey)
            if isKey then isHoldingSilent = false end
        end
    end)

    -- ════════════════════════════════════════════
    -- NEW SECTION: HITBOX EXPANDER
    -- ════════════════════════════════════════════
    createSection("  HITBOX EXPANDER  ")
    local hbGrid = createGrid()
    createToggle(hbGrid, "Enable Hitbox Expand", "HitboxExpand", function(state)
        if not state then
            -- Restore all hitboxes immediately when toggled off
            restoreAllHitboxes()
        end
    end)

    local hbSliders = createFullRow()
    createSlider(hbSliders, "Hitbox Size", 5, "HitboxSize", false)

    -- ── SETTINGS ─────────────────────────────────────────────
    createSection("  SETTINGS  ")
    local settingsBindRow = createFullRow()
    createKeybind(settingsBindRow, "Hide Menu Key", "HideKey")
    local settingsGrid = createGrid()
    createToggle(settingsGrid, "Auto-Save Config", "AutoSave")
    local settingsBtns = createFullRow()
    createButton(settingsBtns, "Save Config",   function() SaveConfig() end)
    createButton(settingsBtns, "Load Config",   function() LoadConfig() end)
    createButton(settingsBtns, "Delete Config", function() DeleteConfig() end)

    -- Player info bar
    local infoBar = Instance.new("Frame")
    infoBar.Size = UDim2.new(1, -20, 0, 42)
    infoBar.BackgroundColor3 = Theme.BgMid
    infoBar.BorderSizePixel = 0
    infoBar.Parent = ScrollFrame
    corner(infoBar, 9); stroke(infoBar, Theme.Border, 1, 0.5)
    local avatarLbl = mkLabel(infoBar, "👤", 20, Theme.TextWhite, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    avatarLbl.Size = UDim2.new(0, 38, 1, 0)
    avatarLbl.Position = UDim2.new(0, 4, 0, 0)
    avatarLbl.TextYAlignment = Enum.TextYAlignment.Center
    local playerNameLbl = mkLabel(infoBar, LocalPlayer.Name, 13, Theme.TextWhite, Enum.Font.GothamSemibold)
    playerNameLbl.Size = UDim2.new(1, -50, 1, 0)
    playerNameLbl.Position = UDim2.new(0, 46, 0, 0)
    playerNameLbl.TextYAlignment = Enum.TextYAlignment.Center

    ToggleBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp then
            local isAimKey = (input.KeyCode == Config.AimbotKey) or (input.UserInputType == Config.AimbotKey)
            if isAimKey then
                isHoldingAim = true
            elseif input.KeyCode == Config.HideKey then
                MainFrame.Visible = not MainFrame.Visible
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        local isAimKey = (input.KeyCode == Config.AimbotKey) or (input.UserInputType == Config.AimbotKey)
        if isAimKey then isHoldingAim = false end
    end)

    MainFrame.Position = UDim2.new(0.5, -280, 0.6, -260)
    MainFrame.BackgroundTransparency = 1
    tween(MainFrame, {Position = UDim2.new(0.5, -280, 0.5, -260), BackgroundTransparency = 0}, 0.3)

    print("[BrandiesHub] Loaded successfully. New: Silent Aim | Hitbox Expander | Skeleton ESP | Health Bar ESP")
end)
