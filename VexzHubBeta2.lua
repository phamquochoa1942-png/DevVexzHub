_G.FastAttack = true

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local Modules = ReplicatedStorage:FindFirstChild("Modules")
local Net = Modules and Modules:FindFirstChild("Net")
local Register_Hit = Net and Net:FindFirstChild("RE/RegisterHit")
local Register_Attack = Net and Net:FindFirstChild("RE/RegisterAttack")

local HASH = "079baa9c"

if Register_Hit then
    pcall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local old = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            if self == Register_Hit then
                local a = {...}
                if type(a[4]) == "string" and #a[4] >= 6 then HASH = a[4] end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local function getRoot()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local _args = { nil, {}, HASH }
local _list = {}

-- =====================================================
-- Dùng RenderStepped thay vì while loop = nhanh hơn
-- Gửi 3 lần/frame thay vì 1
-- =====================================================
RunService.RenderStepped:Connect(function()
    if not _G.FastAttack then return end

    local root = getRoot()
    if not root then return end

    -- Scan
    local idx = 0
    for i = 1, #_list do _list[i] = nil end

    local E = workspace:FindFirstChild("Enemies")
    if E then
        local rx, ry, rz = root.Position.X, root.Position.Y, root.Position.Z
        for _, v in ipairs(E:GetChildren()) do
            if v:IsA("Model") then
                local h = v:FindFirstChildOfClass("Humanoid")
                local er = v:FindFirstChild("HumanoidRootPart")
                if h and h.Health > 0 and er then
                    local dx = rx - er.Position.X
                    local dy = ry - er.Position.Y
                    local dz = rz - er.Position.Z
                    if dx*dx + dy*dy + dz*dz <= 4225 then -- 65²
                        idx += 1
                        _list[idx] = { v, er, v:FindFirstChild("Head") or er }
                    end
                end
            end
        end
    end

    -- Scan người chơi
    for _, v in ipairs(workspace.Characters:GetChildren()) do
        if v.Name ~= LP.Name then
            local h = v:FindFirstChildOfClass("Humanoid")
            local er = v:FindFirstChild("HumanoidRootPart")
            if h and h.Health > 0 and er and (root.Position - er.Position).Magnitude <= 65 then
                idx += 1
                _list[idx] = { v, er, v:FindFirstChild("Head") or er }
            end
        end
    end

    if idx == 0 then return end

    -- Gửi ×3 lần mỗi frame
    for _ = 1, 3 do
        _args[2] = {}
        _args[1] = _list[1][3]
        _args[4] = HASH

        for r = 1, idx do
            if Register_Attack then
                Register_Attack:FireServer(0)
            end
            _args[2][r] = { _list[r][1], _list[r][2] }
        end

        if Register_Hit then
            pcall(function()
                Register_Hit:FireServer(unpack(_args))
            end)
        end
    end
end)

local function CancelAnims()
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            for _, t in ipairs(h:GetPlayingAnimationTracks()) do
                t:Stop(0)
            end
        end
    end
end

task.spawn(function()
    while _G.FastAttack do
        CancelAnims()
        task.wait(0.001)
    end
end)

print("[Fast Attack] ON | Dual Remote ×3 | Hash:", HASH) 
