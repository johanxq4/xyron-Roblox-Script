local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local FlySpeed = 50
local Flying = false
local FlyToggleKey = Enum.KeyCode.F -- Fly aç/kapa tuşu

-- ESP ayarları
local ESPEnabled = true
local ESPColor = Color3.fromRGB(0, 255, 0)

-- Aimbot ayarları
local AimbotEnabled = true
local AimKey = Enum.UserInputType.MouseButton2 -- Sağ mouse tuşu ile hedefe nişan al

-- Fly için BodyVelocity objesi
local bodyVelocity

-- ESP kutuları
local Boxes = {}

-- Kutuları oluştur
local function CreateBox()
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESPColor
    box.Thickness = 2
    box.Filled = false
    return box
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
                if dist < closestDist and dist < 100 then -- max 100 piksel yarıçap
                    closestDist = dist
                    target = player
                end
            end
        end
    end

    return target
end

-- ESP güncellemesi
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

                if onScreen then
                    if not Boxes[player] then
                        Boxes[player] = CreateBox()
                    end
                    local box = Boxes[player]
                    box.Size = Vector2.new(50, 70)
                    box.Position = Vector2.new(screenPos.X - 25, screenPos.Y - 35)
                    box.Visible = true
                elseif Boxes[player] then
                    Boxes[player].Visible = false
                end
            elseif Boxes[player] then
                Boxes[player].Visible = false
            end
        end
    end
end)

-- Aimbot güncellemesi
RunService.RenderStepped:Connect(function()
    if AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local rootPos = target.Character.HumanoidRootPart.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, rootPos)
        end
    end
end)

-- Fly aç/kapa
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == FlyToggleKey then
            Flying = not Flying
            if Flying then
                if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                local hrp = LocalPlayer.Character.HumanoidRootPart
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bodyVelocity.Parent = hrp
            else
                if bodyVelocity then
                    bodyVelocity:Destroy()
                    bodyVelocity = nil
                end
            end
        end
    end
end)

-- Fly hareketi
RunService.Heartbeat:Connect(function()
    if Flying and bodyVelocity and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local direction = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        direction = direction.Unit * FlySpeed
        bodyVelocity.Velocity = direction
    end
end)
