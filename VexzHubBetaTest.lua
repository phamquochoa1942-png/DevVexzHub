-- M1 Fruit Auto — by Quoc Hoa
-- Tự nhận diện fruit → M1 spam + Hitbox Aura xa + đánh nhanh
_G.M1Auto  = true
_G.AuraSize = 30  -- thay đổi size hitbox (studs)

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local VIM               = game:GetService("VirtualInputManager")
local LP                = Players.LocalPlayer

local M1_REMOTE_NAMES = {
    "LeftClickRemote","M1Remote","AttackRemote",
    "HitRemote","ClickRemote","FightRemote",
}

local function findFruitRemote(char)
    if not char then return nil, nil end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Folder") or obj:IsA("Model") or obj:IsA("Tool") then
            for _, rName in ipairs(M1_REMOTE_NAMES) do
                local remote = obj:FindFirstChild(rName)
                if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                    return remote, obj.Name
                end
            end
        end
    end
    return nil, nil
end

local function getAttackVector(targetPos)
    local c = LP.Character; if not c then return Vector3.new(0,0,-1) end
    local r = c:FindFirstChild("HumanoidRootPart"); if not r then return Vector3.new(0,0,-1) end
    local d = targetPos - r.Position
    return d.Magnitude > 0.01 and d.Unit or Vector3.new(0,0,-1)
end

local function getNearestTarget()
    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not r then return nil end
    local best, bestD = nil, math.huge
    local function check(folder)
        if not folder then return end
        for _, e in ipairs(folder:GetChildren()) do
            if not e:IsA("Model") or e.Name == LP.Name then continue end
            local h  = e:FindFirstChildOfClass("Humanoid")
            local er = e:FindFirstChild("HumanoidRootPart")
            if not h or h.Health <= 0 or not er then continue end
            local d = (r.Position - er.Position).Magnitude
            if d < bestD then bestD = d; best = e end
        end
    end
    check(workspace:FindFirstChild("Enemies"))
    check(workspace:FindFirstChild("Characters"))
    return best
end

-- =====================================================
-- FRUIT HITBOX AURA
-- Mở rộng BasePart trong fruit folder → M1 chạm từ xa
-- Loop Heartbeat vì game hay reset size về gốc
-- =====================================================
local origSizes    = {}
local auraConn     = nil
local auraFolder   = nil

local function expandHitbox(char, folderName)
    if not char or not folderName then return end
    local folder = char:FindFirstChild(folderName)
    if not folder then return end
    local sz = _G.AuraSize or 30
    for _, p in ipairs(folder:GetDescendants()) do
        if p:IsA("BasePart") then
            if not origSizes[p] then origSizes[p] = p.Size end
            pcall(function() p.Size = Vector3.new(sz, sz, sz) end)
        end
    end
end

local function restoreHitbox()
    for p, s in pairs(origSizes) do
        pcall(function() if p and p.Parent then p.Size = s end end)
    end
    origSizes = {}
end

local function startAura(folderName)
    if auraConn then auraConn:Disconnect() end
    auraFolder = folderName
    auraConn = RunService.Heartbeat:Connect(function()
        if not _G.M1Auto then
            restoreHitbox()
            auraConn:Disconnect(); auraConn = nil
            return
        end
        expandHitbox(LP.Character, auraFolder)
    end)
    print(("[M1Auto] Aura ON | Size: %d | Fruit: %s"):format(_G.AuraSize or 30, folderName))
end

local function stopAura()
    if auraConn then auraConn:Disconnect(); auraConn = nil end
    auraFolder = nil
    restoreHitbox()
    print("[M1Auto] Aura OFF")
end

-- =====================================================
-- M1 FIRE
-- =====================================================
local comboIdx = 0
local function fireM1(remote, targetPos)
    if not remote then return end
    local dir = getAttackVector(targetPos)
    -- Format Kitsune: (vector, comboIndex, true)
    pcall(function() remote:FireServer(dir, comboIdx % 4, true) end)
    -- Format fallback: (vector, true)
    pcall(function() remote:FireServer(dir, true) end)
    comboIdx += 1
    VIM:SendMouseButtonEvent(0,0,0,true,game,1)
    VIM:SendMouseButtonEvent(0,0,0,false,game,1)
end

-- =====================================================
-- MAIN LOOP
-- =====================================================
local lastFruit = nil

RunService.Heartbeat:Connect(function()
    if not _G.M1Auto then stopAura(); return end

    local char = LP.Character; if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local remote, fruitName = findFruitRemote(char)

    if remote then
        -- Fruit thay đổi → restart aura với folder mới
        if fruitName ~= lastFruit then
            lastFruit = fruitName
            startAura(fruitName)
            print(("[M1Auto] Fruit: %s"):format(fruitName))
        end

        local target = getNearestTarget()
        if not target then return end
        local tr = target:FindFirstChild("HumanoidRootPart")
        if not tr then return end

        fireM1(remote, tr.Position)
    else
        -- Không có fruit → fist + restore hitbox
        if lastFruit then
            lastFruit = nil
            stopAura()
            print("[M1Auto] Không có fruit — fist mode")
        end

        local target = getNearestTarget()
        if target then
            local tr = target:FindFirstChild("HumanoidRootPart")
            local root = char:FindFirstChild("HumanoidRootPart")
            if tr and root then
                root.CFrame = CFrame.lookAt(root.Position, tr.Position)
            end
        end
        VIM:SendMouseButtonEvent(0,0,0,true,game,1)
        VIM:SendMouseButtonEvent(0,0,0,false,game,1)
    end
end)

print("╔══════════════════════════════════════════╗")
print("║  M1 Fruit Auto — by Quoc Hoa            ║")
print("║  Fruit Hitbox Aura: mở rộng hitbox xa   ║")
print("║  Thay size: _G.AuraSize = 50            ║")
print("║  Tắt: _G.M1Auto = false                 ║")
print("╚══════════════════════════════════════════╝")
 
