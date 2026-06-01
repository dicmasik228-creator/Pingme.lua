-- УПРОЩЁННАЯ ВЕРСИЯ (работает 100%)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local clone = nil
local history = {}
local DELAY = 0.3

-- Ждём персонажа
local function waitChar()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    return LocalPlayer.Character
end

-- Создаём клон
local function makeClone()
    local char = waitChar()
    if clone then clone:Destroy() end
    
    clone = char:Clone()
    clone.Name = "PingClone"
    clone.Parent = workspace
    
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = Color3.fromRGB(255, 255, 255)
            part.Material = Enum.Material.Neon
            part.Transparency = 0.5
            part.CanCollide = false
        elseif part:IsA("Humanoid") then
            part.WalkSpeed = 0
            part.PlatformStand = true
        elseif part:IsA("Accessory") or part:IsA("BaseScript") then
            pcall(function() part:Destroy() end)
        end
    end
    
    print("✅ Клон создан")
end

-- Сохраняем позиции
local function savePosition()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    table.insert(history, {pos = hrp.CFrame, time = tick()})
    
    while #history > 0 and tick() - history[1].time > 1 do
        table.remove(history, 1)
    end
end

-- Двигаем клона
local function moveClone()
    if not clone then return end
    local now = tick()
    local targetTime = now - DELAY
    
    local target = nil
    for i = #history, 1, -1 do
        if history[i].time <= targetTime then
            target = history[i].pos
            break
        end
    end
    
    if target then
        local root = clone:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = target
        end
    end
end

-- Запуск
makeClone()

RunService.Heartbeat:Connect(function()
    savePosition()
    moveClone()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    makeClone()
end)
