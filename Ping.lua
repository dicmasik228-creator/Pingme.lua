-- ==================================================
-- ВИЗУАЛИЗАЦИЯ ТВОЕГО ПИНГА (БЕЛЫЙ КЛОН)
-- Показывает твоё реальное положение на сервере
-- ==================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local cloneModel = nil
local positionHistory = {} -- {positions, times}
local CLONE_DELAY = 0.3 -- задержка (под твой пинг)

-- СОЗДАНИЕ БЕЛОГО КЛОНА ТЕБЯ
local function createClone()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local clone = char:Clone()
    clone.Name = "MyPingClone"
    clone.Parent = workspace
    
    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = Color3.fromRGB(255, 255, 255)
            part.Material = Enum.Material.Neon
            part.Transparency = 0.4
            part.CanCollide = false
        elseif part:IsA("Humanoid") then
            part.WalkSpeed = 0
            part.JumpPower = 0
            part.PlatformStand = true
        elseif part:IsA("Accessory") or part:IsA("BaseScript") then
            part:Destroy()
        end
    end
    
    return clone
end

-- ОБНОВЛЕНИЕ ИСТОРИИ ПОЗИЦИЙ
local function updateHistory()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local now = tick()
    table.insert(positionHistory, {cframe = hrp.CFrame, time = now})
    
    -- Удаляем старые записи (старше 1 секунды)
    while #positionHistory > 0 and now - positionHistory[1].time > 1 do
        table.remove(positionHistory, 1)
    end
end

-- ОБНОВЛЕНИЕ ПОЗИЦИИ КЛОНА (с задержкой)
local function updateClone()
    if not cloneModel then return end
    
    local now = tick()
    local targetTime = now - CLONE_DELAY
    
    -- Ищем позицию с задержкой
    local targetPos = nil
    for i = #positionHistory, 1, -1 do
        if positionHistory[i].time <= targetTime then
            targetPos = positionHistory[i].cframe
            break
        end
    end
    
    if targetPos then
        local root = cloneModel:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = targetPos
        end
    end
end

-- ПЕРЕСОЗДАНИЕ КЛОНА ПРИ ПЕРЕРОЖДЕНИИ
local function recreateClone()
    if cloneModel then
        pcall(function() cloneModel:Destroy() end)
        cloneModel = nil
    end
    task.wait(0.5)
    cloneModel = createClone()
end

-- ==================================================
-- ОПТИМИЗАЦИЯ (каждые 5 секунд)
-- ==================================================
task.spawn(function()
    print("✅ Оптимизация запущена (каждые 5 сек)")
    while true do
        task.wait(5)
        collectgarbage("collect")
        collectgarbage("step", 50)
        
        -- Удаляем лишние эффекты
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
                v:Destroy()
            end
            if v:IsA("Beam") then
                v:Destroy()
            end
        end
        
        -- Настройки освещения
        Lighting.GlobalShadows = false
    end
end)

-- ==================================================
-- ЗАПУСК
-- ==================================================
cloneModel = createClone()

-- Каждый кадр обновляем историю и клона
RunService.Heartbeat:Connect(function()
    updateHistory()
    updateClone()
end)

-- При перерождении обновляем клон
LocalPlayer.CharacterAdded:Connect(function()
    recreateClone()
end)

print("✅ Визуализация твоего пинга запущена | Белый клон показывает твою реальную позицию")
