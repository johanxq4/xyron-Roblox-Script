-- Gerekli servisleri tanımlayın
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local ESPColor = Color3.fromRGB(0, 255, 0)
local AimbotEnabled = true

-- Gui Oluşturma
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.ResetOnSpawn = false
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 220)
Frame.Position = UDim2.new(0, 100, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(43, 13, 97)

-- Buton fonksiyonu
local function createButton(name, posY, func)
    local button = Instance.new("TextButton", Frame)
    button.Size = UDim2.new(0, 180, 0, 40)
    button.Position = UDim2.new(0, 10, 0, posY)
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(66, 49, 137)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.MouseButton1Click:Connect(func)
end

-- ESP
local ESPActive = false
local function enableESP()
    if ESPActive then return end
    ESPActive = true
    RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local part = player.Character:FindFirstChild("HumanoidRootPart")
                if part and not part:FindFirstChild("ESPBox") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "ESPBox"
                    box.Size = Vector3.new(4, 6, 1)
                    box.Color3 = ESPColor
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Adornee = part
                    box.Parent = part
                end
            end
        end
    end)
end

-- En yakın düşmanı bul
local function GetClosestEnemy()
    local closestDist = math.huge
    local target = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < closestDist and dist < 100 then
                    closestDist = dist
                    target = player
                end
            end
        end
    end
    return target
end

-- Aimbot
local function enableAimbot()
    RunService.RenderStepped:Connect(function()
        if AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetClosestEnemy()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local rootPos = target.Character.HumanoidRootPart.Position
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, rootPos)
            end
        end
    end)
end

-- Fly
local function enableFly()
    local char = LocalPlayer.Character
    local hrp = char:WaitForChild("HumanoidRootPart")
    local bg = Instance.new("BodyGyro", hrp)
    local bv = Instance.new("BodyVelocity", hrp)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then
            bv.Velocity = Vector3.new(0, 50, 0)
        end
    end)
end

-- Auto Farm
local function enableAutoFarm()
    task.spawn(function()
        while true do
            task.wait(1)
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("TouchTransmitter") and v.Parent then
                    pcall(function()
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v.Parent, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, v.Parent, 1)
                    end)
                end
            end
        end
    end)
end

-- Butonları ekle
createButton("ESP Aç", 10, enableESP)
createButton("Aimbot (RMB)", 60, enableAimbot)
createButton("Fly", 110, enableFly)
createButton("AutoFarm", 160, enableAutoFarm)
