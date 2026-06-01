-- ПРОСТОЙ ТЕСТ 2 (работает везде)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local marker = nil
local history = {}
local DELAY = 0.3

-- Ждём персонажа
local function waitChar()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    return LocalPlayer.Character
end

-- Создаём простую сферу вместо клона
local function createMarker()
    if marker then marker:Destroy() end
    
    marker = Instance.new("Part")
    marker.Name = "PingMarker"
    marker.Size = Vector3.new(2, 2, 2)
    marker.Shape = Enum.PartType.Ball
    marker.Color = Color3.fromRGB(255, 255, 255)
    marker.Material = Enum.Material.Neon
    marker.Transparency = 0.3
    marker.CanCollide = false
    marker.Parent = workspace
    
    print("✅ Маркер создан (белая сфера)")
end

-- Сохраняем позицию
local function savePosition()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    table.insert(history, {pos = hrp.Position, time = tick()})
    
    while #history > 0 and tick() - history[1].time > 1 do
        table.remove(history, 1)
    end
end

-- Двигаем маркер
local function moveMarker()
    if not marker then return end
    local now = tick()
    local targetTime = now - DELAY
    
    local targetPos = nil
    for i = #history, 1, -1 do
        if history[i].time <= targetTime then
            targetPos = history[i].pos
            break
        end
    end
    
    if targetPos then
        marker.Position = targetPos
    end
end

-- Запуск
waitChar()
createMarker()

RunService.Heartbeat:Connect(function()
    savePosition()
    moveMarker()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    createMarker()
end)

print("✅ Визуализация пинга запущена | Белая сфера показывает твою реальную позицию")
