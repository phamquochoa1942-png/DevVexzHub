-- ╔══════════════════════════════════════════════════╗
-- ║  VEXZ HUB - FLUENT UI (FIXED ALL)              ║
-- ║  Fast Attack + Auto Quest + Bring Mob          ║
-- ╚══════════════════════════════════════════════════╝

-- =====================================================
-- FLUENT UI (CÓ PCALL CHỐNG LỖI)
-- =====================================================
local Fluent, SaveManager, InterfaceManager

local success1, err1 = pcall(function()
    Fluent = loadstring(game:HttpGet(
        "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
    ))()
end)
if not success1 then
    warn("[Vexz Hub] Fluent load failed:", err1)
    pcall(function()
        Fluent = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/dawid-scripts/Fluent/main/main.lua"
        ))()
    end)
end

if Fluent then
    pcall(function()
        SaveManager = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"
        ))()
    end)
    pcall(function()
        InterfaceManager = loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"
        ))()
    end)
end

if not Fluent then
    print("[Vexz Hub] FATAL: Cannot load Fluent UI. Script stopped.")
    return
end

-- =====================================================
-- SERVICES
-- =====================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- =====================================================
-- WORLD DETECTION
-- =====================================================
local PlaceId = game.PlaceId
local World1 = false
local World2 = false
local World3 = false

if PlaceId == 2753915549 then World1 = true
elseif PlaceId == 4442272183 then World2 = true
elseif PlaceId == 7449423635 then World3 = true
end

-- =====================================================
-- FAST ATTACK (FIX: Tăng tốc độ đánh - delay 0.05)
-- =====================================================
_G.FastAttack = true

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
        print("[Fast Attack] Hooked RE/RegisterHit, HASH:", HASH)
    end)
else
    print("[Fast Attack] WARNING: RE/RegisterHit not found, using default HASH")
end

local function GetAllBladeHits()
    local hits = {}
    local char = LP.Character
    if not char then return hits end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return hits end
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return hits end
    for _, v in ipairs(enemies:GetChildren()) do
        if v:IsA("Model") then
            local hum = v:FindFirstChildOfClass("Humanoid")
            local er = v:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and er and (root.Position - er.Position).Magnitude <= 65 then
                table.insert(hits, v)
            end
        end
    end
    return hits
end

local function FastAttack()
    local bladehits = {}
    for _, v in ipairs(GetAllBladeHits()) do table.insert(bladehits, v) end
    if #bladehits == 0 then return end
    local args = {[1] = nil, [2] = {}, [4] = HASH}
    for r, v in ipairs(bladehits) do
        if Register_Attack then Register_Attack:FireServer(0) end
        if not args[1] then args[1] = v:FindFirstChild("Head") or v:FindFirstChild("HumanoidRootPart") end
        args[2][r] = {[1] = v, [2] = v:FindFirstChild("HumanoidRootPart")}
    end
    if Register_Hit then
        Register_Hit:FireServer(unpack(args))
    end
end

-- FIX: Tăng tốc độ đánh từ task.wait() xuống task.wait(0.05)
task.spawn(function() while _G.FastAttack do pcall(FastAttack) task.wait(0.05) end end)

-- =====================================================
-- ORIGINAL QUEST DATA (FIX: Level 1-9 Bandit)
-- =====================================================
QuestCheck = function()
    local I = game.Players.LocalPlayer.Data.Level.Value
    if World1 then
        if I == 1 or I <= 9 then
            Mon = "Bandit"
            Qdata = 1
            Qname = "BanditQuest1"
            NameMon = "Bandit"
            PosM = CFrame.new(1045.9626464844, 27.002508163452, 1560.8203125)
            PosQ = CFrame.new(1059.37195, 15.4495068, 1550.4231, 0.939700544, -0, -0.341998369, 0, 1, -0, 0.341998369, 0, 0.939700544)
        elseif I == 10 or I <= 14 then
            Mon = "Monkey"; Qdata = 1; Qname = "JungleQuest"; NameMon = "Monkey"
            PosQ = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, 0, -1, 0, 0)
            PosM = CFrame.new(-1448.5180664062, 67.853012084961, 11.465796470642)
        elseif I == 15 or I <= 29 then
            Mon = "Gorilla"; Qdata = 2; Qname = "JungleQuest"; NameMon = "Gorilla"
            PosQ = CFrame.new(-1598.08911, 35.5501175, 153.377838, 0, 0, 1, 0, 1, 0, -1, 0, 0)
            PosM = CFrame.new(-1129.8836669922, 40.46354675293, -525.42370605469)
        elseif I == 30 or I <= 39 then
            Mon = "Pirate"; Qdata = 1; Qname = "BuggyQuest1"; NameMon = "Pirate"
            PosQ = CFrame.new(-1141.07483, 4.10001802, 3831.5498, .965929627, 0, -0.258804798, 0, 1, 0, .258804798, 0, .965929627)
            PosM = CFrame.new(-1103.5134277344, 13.752052307129, 3896.0910644531)
        elseif I == 40 or I <= 59 then
            Mon = "Brute"; Qdata = 2; Qname = "BuggyQuest1"; NameMon = "Brute"
            PosQ = CFrame.new(-1141.07483, 4.10001802, 3831.5498, .965929627, 0, -0.258804798, 0, 1, 0, .258804798, 0, .965929627)
            PosM = CFrame.new(-1140.0837402344, 14.809885025024, 4322.9213867188)
        elseif I == 60 or I <= 74 then
            Mon = "Desert Bandit"; Qdata = 1; Qname = "DesertQuest"; NameMon = "Desert Bandit"
            PosQ = CFrame.new(894.488647, 5.14000702, 4392.43359, .819155693, 0, -0.573571265, 0, 1, 0, .573571265, 0, .819155693)
            PosM = CFrame.new(924.7998046875, 6.4486746788025, 4481.5859375)
        elseif I == 75 or I <= 89 then
            Mon = "Desert Officer"; Qdata = 2; Qname = "DesertQuest"; NameMon = "Desert Officer"
            PosQ = CFrame.new(894.488647, 5.14000702, 4392.43359, .819155693, 0, -0.573571265, 0, 1, 0, .573571265, 0, .819155693)
            PosM = CFrame.new(1608.2822265625, 8.6142244338989, 4371.0073242188)
        elseif I == 90 or I <= 99 then
            Mon = "Snow Bandit"; Qdata = 1; Qname = "SnowQuest"; NameMon = "Snow Bandit"
            PosQ = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, .939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
            PosM = CFrame.new(1354.3479003906, 87.272773742676, -1393.9465332031)
        elseif I == 100 or I <= 119 then
            Mon = "Snowman"; Qdata = 2; Qname = "SnowQuest"; NameMon = "Snowman"
            PosQ = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, 0, .939684391, 0, 1, 0, -0.939684391, 0, -0.342042685)
            PosM = CFrame.new(1201.6412353515625, 144.57958984375, -1550.0670166015625)
        elseif I == 120 or I <= 149 then
            Mon = "Chief Petty Officer"; Qdata = 1; Qname = "MarineQuest2"; NameMon = "Chief Petty Officer"
            PosQ = CFrame.new(-5039.58643, 27.3500385, 4324.68018, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            PosM = CFrame.new(-4881.2309570312, 22.652044296265, 4273.7524414062)
        elseif I == 150 or I <= 174 then
            Mon = "Sky Bandit"; Qdata = 1; Qname = "SkyQuest"; NameMon = "Sky Bandit"
            PosQ = CFrame.new(-4839.53027, 716.368591, -2619.44165, .866007268, 0, .500031412, 0, 1, 0, -0.500031412, 0, .866007268)
            PosM = CFrame.new(-4953.20703125, 295.74420166016, -2899.2290039062)
        elseif I == 175 or I <= 189 then
            Mon = "Dark Master"; Qdata = 2; Qname = "SkyQuest"; NameMon = "Dark Master"
            PosQ = CFrame.new(-4839.53027, 716.368591, -2619.44165, .866007268, 0, .500031412, 0, 1, 0, -0.500031412, 0, .866007268)
            PosM = CFrame.new(-5259.8447265625, 391.39767456055, -2229.0354003906)
        elseif I == 190 or I <= 209 then
            Mon = "Prisoner"; Qdata = 1; Qname = "PrisonerQuest"; NameMon = "Prisoner"
            PosQ = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, .995993316, -2.06384709e-09, -0.0894274712)
            PosM = CFrame.new(5098.9736328125, -0.3204058110714, 474.23733520508)
        elseif I == 210 or I <= 249 then
            Mon = "Dangerous Prisoner"; Qdata = 2; Qname = "PrisonerQuest"; NameMon = "Dangerous Prisoner"
            PosQ = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.00292918e-09, -0.995993316, 1.60817859e-09, 1, -5.16744869e-09, .995993316, -2.06384709e-09, -0.0894274712)
            PosM = CFrame.new(5654.5634765625, 15.633401870728, 866.29919433594)
        elseif I == 250 or I <= 274 then
            Mon = "Toga Warrior"; Qdata = 1; Qname = "ColosseumQuest"; NameMon = "Toga Warrior"
            PosQ = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, .857167721, 0, -0.515037298)
            PosM = CFrame.new(-1820.21484375, 51.683856964111, -2740.6650390625)
        elseif I == 275 or I <= 299 then
            Mon = "Gladiator"; Qdata = 2; Qname = "ColosseumQuest"; NameMon = "Gladiator"
            PosQ = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, 0, -0.857167721, 0, 1, 0, .857167721, 0, -0.515037298)
            PosM = CFrame.new(-1292.8381347656, 56.380882263184, -3339.0314941406)
        elseif I == 300 or I <= 324 then
            Boubty = false
            Mon = "Military Soldier"; Qdata = 1; Qname = "MagmaQuest"; NameMon = "Military Soldier"
            PosQ = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, .866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
            PosM = CFrame.new(-5411.1645507812, 11.081554412842, 8454.29296875)
        elseif I == 325 or I <= 374 then
            Mon = "Military Spy"; Qdata = 2; Qname = "MagmaQuest"; NameMon = "Military Spy"
            PosQ = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, 0, .866048813, 0, 1, 0, -0.866048813, 0, -0.499959469)
            PosM = CFrame.new(-5802.8681640625, 86.262413024902, 8828.859375)
        elseif I == 375 or I <= 399 then
            Mon = "Fishman Warrior"; Qdata = 1; Qname = "FishmanQuest"; NameMon = "Fishman Warrior"
            PosQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            PosM = CFrame.new(60878.30078125, 18.482830047607, 1543.7574462891)
        elseif I == 400 or I <= 449 then
            Mon = "Fishman Commando"; Qdata = 2; Qname = "FishmanQuest"; NameMon = "Fishman Commando"
            PosQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            PosM = CFrame.new(61922.6328125, 18.482830047607, 1493.9343261719)
        elseif I == 450 or I <= 474 then
            Mon = "God's Guard"; Qdata = 1; Qname = "SkyExp1Quest"; NameMon = "God's Guard"
            PosQ = CFrame.new(-4721.88867, 843.874695, -1949.96643, .996191859, 0, -0.0871884301, 0, 1, 0, .0871884301, 0, .996191859)
            PosM = CFrame.new(-4710.04296875, 845.27697753906, -1927.3079833984)
        elseif I == 475 or I <= 524 then
            Mon = "Shanda"; Qdata = 2; Qname = "SkyExp1Quest"; NameMon = "Shanda"
            PosQ = CFrame.new(-7859.09814, 5544.19043, -381.476196, -0.422592998, 0, .906319618, 0, 1, 0, -0.906319618, 0, -0.422592998)
            PosM = CFrame.new(-7678.4897460938, 5566.4038085938, -497.21560668945)
        elseif I == 525 or I <= 549 then
            Mon = "Royal Squad"; Qdata = 1; Qname = "SkyExp2Quest"; NameMon = "Royal Squad"
            PosQ = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            PosM = CFrame.new(-7624.2524414062, 5658.1333007812, -1467.3542480469)
        elseif I == 550 or I <= 624 then
            Mon = "Royal Soldier"; Qdata = 2; Qname = "SkyExp2Quest"; NameMon = "Royal Soldier"
            PosQ = CFrame.new(-7906.81592, 5634.6626, -1411.99194, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            PosM = CFrame.new(-7836.7534179688, 5645.6640625, -1790.6236572266)
        elseif I == 625 or I <= 649 then
            Mon = "Galley Pirate"; Qdata = 1; Qname = "FountainQuest"; NameMon = "Galley Pirate"
            PosQ = CFrame.new(5259.81982, 37.3500175, 4050.0293, .087131381, 0, .996196866, 0, 1, 0, -0.996196866, 0, .087131381)
            PosM = CFrame.new(5551.0219726562, 78.901351928711, 3930.4128417969)
        elseif I >= 650 and I <= 699 then
            Mon = "Galley Captain"; Qdata = 2; Qname = "FountainQuest"; NameMon = "Galley Captain"
            PosQ = CFrame.new(5259.81982, 37.3500175, 4050.0293, .087131381, 0, .996196866, 0, 1, 0, -0.996196866, 0, .087131381)
            PosM = CFrame.new(5441.9516601562, 42.502059936523, 4950.09375)
        end
    elseif World2 then
        if I == 700 or I <= 724 then
            Mon = "Raider"; Qdata = 1; Qname = "Area1Quest"; NameMon = "Raider"
            PosQ = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, .974368095, 0, -0.22495985)
            PosM = CFrame.new(-728.32672119141, 52.779319763184, 2345.7705078125)
        elseif I == 725 or I <= 774 then
            Mon = "Mercenary"; Qdata = 2; Qname = "Area1Quest"; NameMon = "Mercenary"
            PosQ = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, 0, -0.974368095, 0, 1, 0, .974368095, 0, -0.22495985)
            PosM = CFrame.new(-1004.3244018555, 80.158866882324, 1424.6193847656)
        elseif I == 775 or I <= 799 then
            Mon = "Swan Pirate"; Qdata = 1; Qname = "Area2Quest"; NameMon = "Swan Pirate"
            PosQ = CFrame.new(638.43811, 71.769989, 918.282898, .139203906, 0, .99026376, 0, 1, 0, -0.99026376, 0, .139203906)
            PosM = CFrame.new(1068.6643066406, 137.61428833008, 1322.1060791016)
        elseif I == 800 or I <= 874 then
            Mon = "Factory Staff"; Qname = "Area2Quest"; Qdata = 2; NameMon = "Factory Staff"
            PosQ = CFrame.new(632.698608, 73.1055908, 918.666321, -0.0319722369, 8.96074881e-10, -0.999488771, 1.36326533e-10, 1, 8.92172336e-10, .999488771, -1.07732087e-10, -0.0319722369)
            PosM = CFrame.new(73.078674316406, 81.863441467285, -27.470672607422)
        elseif I == 875 or I <= 899 then
            Mon = "Marine Lieutenant"; Qdata = 1; Qname = "MarineQuest3"; NameMon = "Marine Lieutenant"
            PosQ = CFrame.new(-2440.79639, 71.7140732, -3216.06812, .866007268, 0, .500031412, 0, 1, 0, -0.500031412, 0, .866007268)
            PosM = CFrame.new(-2821.3723144531, 75.897277832031, -3070.0891113281)
        elseif I == 900 or I <= 949 then
            Mon = "Marine Captain"; Qdata = 2; Qname = "MarineQuest3"; NameMon = "Marine Captain"
            PosQ = CFrame.new(-2440.79639, 71.7140732, -3216.06812, .866007268, 0, .500031412, 0, 1, 0, -0.500031412, 0, .866007268)
            PosM = CFrame.new(-1861.2310791016, 80.176582336426, -3254.6975097656)
        elseif I == 950 or I <= 974 then
            Mon = "Zombie"; Qdata = 1; Qname = "ZombieQuest"; NameMon = "Zombie"
            PosQ = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, .95628953, 0, -0.29242146)
            PosM = CFrame.new(-5657.7768554688, 78.969734191895, -928.68701171875)
        elseif I == 975 or I <= 999 then
            Mon = "Vampire"; Qdata = 2; Qname = "ZombieQuest"; NameMon = "Vampire"
            PosQ = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, 0, -0.95628953, 0, 1, 0, .95628953, 0, -0.29242146)
            PosM = CFrame.new(-6037.66796875, 32.184638977051, -1340.6597900391)
        elseif I == 1000 or I <= 1049 then
            Mon = "Snow Trooper"; Qdata = 1; Qname = "SnowMountainQuest"; NameMon = "Snow Trooper"
            PosQ = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, .92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)
            PosM = CFrame.new(549.14733886719, 427.38705444336, -5563.6987304688)
        elseif I == 1050 or I <= 1099 then
            Mon = "Winter Warrior"; Qdata = 2; Qname = "SnowMountainQuest"; NameMon = "Winter Warrior"
            PosQ = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, 0, .92718488, 0, 1, 0, -0.92718488, 0, -0.374604106)
            PosM = CFrame.new(1142.7451171875, 475.63980102539, -5199.4165039062)
        elseif I == 1100 or I <= 1124 then
            Mon = "Lab Subordinate"; Qdata = 1; Qname = "IceSideQuest"; NameMon = "Lab Subordinate"
            PosQ = CFrame.new(-6064.06885, 15.2422857, -4902.97852, .453972578, 0, -0.891015649, 0, 1, 0, .891015649, 0, .453972578)
            PosM = CFrame.new(-5707.4716796875, 15.951709747314, -4513.3920898438)
        elseif I == 1125 or I <= 1174 then
            Mon = "Horned Warrior"; Qdata = 2; Qname = "IceSideQuest"; NameMon = "Horned Warrior"
            PosQ = CFrame.new(-6064.06885, 15.2422857, -4902.97852, .453972578, 0, -0.891015649, 0, 1, 0, .891015649, 0, .453972578)
            PosM = CFrame.new(-6341.3666992188, 15.951770782471, -5723.162109375)
        elseif I == 1175 or I <= 1199 then
            Mon = "Magma Ninja"; Qdata = 1; Qname = "FireSideQuest"; NameMon = "Magma Ninja"
            PosQ = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, .469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
            PosM = CFrame.new(-5449.6728515625, 76.658744812012, -5808.2006835938)
        elseif I == 1200 or I <= 1249 then
            Mon = "Lava Pirate"; Qdata = 2; Qname = "FireSideQuest"; NameMon = "Lava Pirate"
            PosQ = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, 0, .469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
            PosM = CFrame.new(-5213.3315429688, 49.737880706787, -4701.451171875)
        elseif I == 1250 or I <= 1274 then
            Mon = "Ship Deckhand"; Qdata = 1; Qname = "ShipQuest1"; NameMon = "Ship Deckhand"
            PosQ = CFrame.new(1037.80127, 125.092171, 32911.6016)
            PosM = CFrame.new(1212.0111083984, 150.79205322266, 33059.24609375)
        elseif I == 1275 or I <= 1299 then
            Mon = "Ship Engineer"; Qdata = 2; Qname = "ShipQuest1"; NameMon = "Ship Engineer"
            PosQ = CFrame.new(1037.80127, 125.092171, 32911.6016)
            PosM = CFrame.new(919.47863769531, 43.544013977051, 32779.96875)
        elseif I == 1300 or I <= 1324 then
            Mon = "Ship Steward"; Qdata = 1; Qname = "ShipQuest2"; NameMon = "Ship Steward"
            PosQ = CFrame.new(968.80957, 125.092171, 33244.125)
            PosM = CFrame.new(919.43853759766, 129.55599975586, 33436.03515625)
        elseif I == 1325 or I <= 1349 then
            Mon = "Ship Officer"; Qdata = 2; Qname = "ShipQuest2"; NameMon = "Ship Officer"
            PosQ = CFrame.new(968.80957, 125.092171, 33244.125)
            PosM = CFrame.new(1036.0179443359, 181.4390411377, 33315.7265625)
        elseif I == 1350 or I <= 1374 then
            Mon = "Arctic Warrior"; Qdata = 1; Qname = "FrostQuest"; NameMon = "Arctic Warrior"
            PosQ = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, .358349502, 0, -0.933587909)
            PosM = CFrame.new(5966.24609375, 62.970020294189, -6179.3828125)
        elseif I == 1375 or I <= 1424 then
            Mon = "Snow Lurker"; Qdata = 2; Qname = "FrostQuest"; NameMon = "Snow Lurker"
            PosQ = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, 0, -0.358349502, 0, 1, 0, .358349502, 0, -0.933587909)
            PosM = CFrame.new(5407.0737304688, 69.194374084473, -6880.8803710938)
        elseif I == 1425 or I <= 1449 then
            Mon = "Sea Soldier"; Qdata = 1; Qname = "ForgottenQuest"; NameMon = "Sea Soldier"
            PosQ = CFrame.new(-3054.44458, 235.544281, -10142.8193, .990270376, 0, -0.13915664, 0, 1, 0, .13915664, 0, .990270376)
            PosM = CFrame.new(-3028.2236328125, 64.674514770508, -9775.4267578125)
        elseif I >= 1450 and I <= 1499 then
            Mon = "Water Fighter"; Qdata = 2; Qname = "ForgottenQuest"; NameMon = "Water Fighter"
            PosQ = CFrame.new(-3054.44458, 235.544281, -10142.8193, .990270376, 0, -0.13915664, 0, 1, 0, .13915664, 0, .990270376)
            PosM = CFrame.new(-3352.9013671875, 285.01556396484, -10534.841796875)
        end
    elseif World3 then
        if I == 1500 or I <= 1524 then
            Mon = "Pirate Millionaire"; Qdata = 1; Qname = "PiratePortQuest"; NameMon = "Pirate Millionaire"
            PosQ = CFrame.new(-290.07, 42.90, 5581.59); PosM = CFrame.new(-246.00, 47.31, 5584.10)
        elseif I == 1525 or I <= 1574 then
            Mon = "Pistol Billionaire"; Qdata = 2; Qname = "PiratePortQuest"; NameMon = "Pistol Billionaire"
            PosQ = CFrame.new(-290.07, 42.90, 5581.59); PosM = CFrame.new(-187.33, 86.24, 6013.51)
        elseif I == 1575 or I <= 1599 then
            Mon = "Dragon Crew Warrior"; Qdata = 1; Qname = "DragonCrewQuest"; NameMon = "Dragon Crew Warrior"
            PosQ = CFrame.new(6737.06055,127.417763,-712.300659,-0.463954359,-7.19574755e-09,0.885859072,7.69187665e-08,1,4.84078626e-08,-0.885859072,9.05982276e-08,-0.463954359)
            PosM = CFrame.new(6709.76367,52.3442993,-1139.02966,-0.763515472,0,0.645789504,0,1,0,-0.645789504,0,-0.763515472)
        elseif I == 1600 or I <= 1624 then
            Mon = "Dragon Crew Archer"; Qdata = 2; Qname = "DragonCrewQuest"; NameMon = "Dragon Crew Archer"
            PosQ = CFrame.new(6737.06055,127.417763,-712.300659,-0.463954359,-7.19574755e-09,0.885859072,7.69187665e-08,1,4.84078626e-08,-0.885859072,9.05982276e-08,-0.463954359)
            PosM = CFrame.new(6668.76172,481.376923,329.12207,-0.121787429,0,-0.992556155,0,1,0,0.992556155,0,-0.121787429)
        elseif I == 1625 or I <= 1649 then
            Mon = "Hydra Enforcer"; Qname = "VenomCrewQuest"; Qdata = 1; NameMon = "Hydra Enforcer"
            PosQ = CFrame.new(5206.40185546875, 1004.10498046875, 748.3504638671875)
            PosM = CFrame.new(4547.11523, 1003.10217, 334.194824, 0.388810456, -0, -0.921317935, 0, 1, -0, 0.921317935, 0, 0.388810456)
        elseif I == 1650 or I <= 1699 then
            Mon = "Venomous Assailant"; Qname = "VenomCrewQuest"; Qdata = 2; NameMon = "Venomous Assailant"
            PosQ = CFrame.new(5206.40185546875, 1004.10498046875, 748.3504638671875)
            PosM = CFrame.new(4674.92676, 1134.82654, 996.308838, 0.731321394, -0, -0.682033002, 0, 1, -0, 0.682033002, 0, 0.731321394)
        elseif I == 1700 or I <= 1724 then
            Mon = "Marine Commodore"; Qdata = 1; Qname = "MarineTreeIsland"; NameMon = "Marine Commodore"
            PosQ = CFrame.new(2180.54126, 27.8156815, -6741.5498, -0.965929747, 0, .258804798, 0, 1, 0, -0.258804798, 0, -0.965929747)
            PosM = CFrame.new(2286.0078125, 73.133918762207, -7159.8090820312)
        elseif I == 1725 or I <= 1774 then
            Mon = "Marine Rear Admiral"; NameMon = "Marine Rear Admiral"; Qname = "MarineTreeIsland"; Qdata = 2
            PosQ = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813)
            PosM = CFrame.new(3656.7736816406, 160.52406311035, -7001.5986328125)
        elseif I == 1775 or I <= 1799 then
            Mon = "Fishman Raider"; Qdata = 1; Qname = "DeepForestIsland3"; NameMon = "Fishman Raider"
            PosQ = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, .469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
            PosM = CFrame.new(-10407.526367188, 331.76263427734, -8368.5166015625)
        elseif I == 1800 or I <= 1824 then
            Mon = "Fishman Captain"; Qdata = 2; Qname = "DeepForestIsland3"; NameMon = "Fishman Captain"
            PosQ = CFrame.new(-10581.6563, 330.872955, -8761.18652, -0.882952213, 0, .469463557, 0, 1, 0, -0.469463557, 0, -0.882952213)
            PosM = CFrame.new(-10994.701171875, 352.38140869141, -9002.1103515625)
        elseif I == 1825 or I <= 1849 then
            Mon = "Forest Pirate"; Qdata = 1; Qname = "DeepForestIsland"; NameMon = "Forest Pirate"
            PosQ = CFrame.new(-13234.04, 331.488495, -7625.40137, .707134247, 0, -0.707079291, 0, 1, 0, .707079291, 0, .707134247)
            PosM = CFrame.new(-13274.478515625, 332.37814331055, -7769.5805664062)
        elseif I == 1850 or I <= 1899 then
            Mon = "Mythological Pirate"; Qdata = 2; Qname = "DeepForestIsland"; NameMon = "Mythological Pirate"
            PosQ = CFrame.new(-13234.04, 331.488495, -7625.40137, .707134247, 0, -0.707079291, 0, 1, 0, .707079291, 0, .707134247)
            PosM = CFrame.new(-13680.607421875, 501.08154296875, -6991.189453125)
        elseif I == 1900 or I <= 1924 then
            Mon = "Jungle Pirate"; Qdata = 1; Qname = "DeepForestIsland2"; NameMon = "Jungle Pirate"
            PosQ = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, .996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
            PosM = CFrame.new(-12256.16015625, 331.73828125, -10485.836914062)
        elseif I == 1925 or I <= 1974 then
            Mon = "Musketeer Pirate"; Qdata = 2; Qname = "DeepForestIsland2"; NameMon = "Musketeer Pirate"
            PosQ = CFrame.new(-12680.3818, 389.971039, -9902.01953, -0.0871315002, 0, .996196866, 0, 1, 0, -0.996196866, 0, -0.0871315002)
            PosM = CFrame.new(-13457.904296875, 391.54565429688, -9859.177734375)
        elseif I == 1975 or I <= 1999 then
            Mon = "Reborn Skeleton"; Qdata = 1; Qname = "HauntedQuest1"; NameMon = "Reborn Skeleton"
            PosQ = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, 0, -1, 0, 0)
            PosM = CFrame.new(-8763.7236328125, 165.72299194336, 6159.8618164062)
        elseif I == 2000 or I <= 2024 then
            Mon = "Living Zombie"; Qdata = 2; Qname = "HauntedQuest1"; NameMon = "Living Zombie"
            PosQ = CFrame.new(-9479.2168, 141.215088, 5566.09277, 0, 0, 1, 0, 1, 0, -1, 0, 0)
            PosM = CFrame.new(-10144.131835938, 138.6266784668, 5838.0888671875)
        elseif I == 2025 or I <= 2049 then
            Mon = "Demonic Soul"; Qdata = 1; Qname = "HauntedQuest2"; NameMon = "Demonic Soul"
            PosQ = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            PosM = CFrame.new(-9505.8720703125, 172.10482788086, 6158.9931640625)
        elseif I == 2050 or I <= 2074 then
            Mon = "Posessed Mummy"; Qdata = 2; Qname = "HauntedQuest2"; NameMon = "Posessed Mummy"
            PosQ = CFrame.new(-9516.99316, 172.017181, 6078.46533, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            PosM = CFrame.new(-9582.0224609375, 6.2515273094177, 6205.478515625)
        elseif I == 2075 or I <= 2099 then
            Mon = "Peanut Scout"; Qdata = 1; Qname = "NutsIslandQuest"; NameMon = "Peanut Scout"
            PosQ = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            PosM = CFrame.new(-2143.2419433594, 47.721984863281, -10029.995117188)
        elseif I == 2100 or I <= 2124 then
            Mon = "Peanut President"; Qdata = 2; Qname = "NutsIslandQuest"; NameMon = "Peanut President"
            PosQ = CFrame.new(-2104.3908691406, 38.104167938232, -10194.21875, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            PosM = CFrame.new(-1859.3540039062, 38.103168487549, -10422.4296875)
        elseif I == 2125 or I <= 2149 then
            Mon = "Ice Cream Chef"; Qdata = 1; Qname = "IceCreamIslandQuest"; NameMon = "Ice Cream Chef"
            PosQ = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            PosM = CFrame.new(-872.24658203125, 65.81957244873, -10919.95703125)
        elseif I == 2150 or I <= 2199 then
            Mon = "Ice Cream Commander"; Qdata = 2; Qname = "IceCreamIslandQuest"; NameMon = "Ice Cream Commander"
            PosQ = CFrame.new(-820.64825439453, 65.819526672363, -10965.795898438, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            PosM = CFrame.new(-558.06103515625, 112.04895782471, -11290.774414062)
        elseif I == 2200 or I <= 2224 then
            Mon = "Cookie Crafter"; Qdata = 1; Qname = "CakeQuest1"; NameMon = "Cookie Crafter"
            PosQ = CFrame.new(-2021.32007, 37.7982254, -12028.7295, .957576931, -8.80302053e-08, .288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, .957576931)
            PosM = CFrame.new(-2374.13671875, 37.798263549805, -12125.30859375)
        elseif I == 2225 or I <= 2249 then
            Mon = "Cake Guard"; Qdata = 2; Qname = "CakeQuest1"; NameMon = "Cake Guard"
            PosQ = CFrame.new(-2021.32007, 37.7982254, -12028.7295, .957576931, -8.80302053e-08, .288177818, 6.9301187e-08, 1, 7.51931211e-08, -0.288177818, -5.2032135e-08, .957576931)
            PosM = CFrame.new(-1598.3070068359, 43.773197174072, -12244.581054688)
        elseif I == 2250 or I <= 2274 then
            Mon = "Baking Staff"; Qdata = 1; Qname = "CakeQuest2"; NameMon = "Baking Staff"
            PosQ = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, .250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
            PosM = CFrame.new(-1887.8099365234, 77.618507385254, -12998.350585938)
        elseif I == 2275 or I <= 2299 then
            Mon = "Head Baker"; Qdata = 2; Qname = "CakeQuest2"; NameMon = "Head Baker"
            PosQ = CFrame.new(-1927.91602, 37.7981339, -12842.5391, -0.96804446, 4.22142143e-08, .250778586, 4.74911062e-08, 1, 1.49904711e-08, -0.250778586, 2.64211941e-08, -0.96804446)
            PosM = CFrame.new(-2216.1882324219, 82.884521484375, -12869.293945312)
        elseif I == 2300 or I <= 2324 then
            Mon = "Cocoa Warrior"; Qdata = 1; Qname = "ChocQuest1"; NameMon = "Cocoa Warrior"
            PosQ = CFrame.new(233.22836303711, 29.876001358032, -12201.233398438)
            PosM = CFrame.new(-21.553283691406, 80.574996948242, -12352.387695312)
        elseif I == 2325 or I <= 2349 then
            Mon = "Chocolate Bar Battler"; Qdata = 2; Qname = "ChocQuest1"; NameMon = "Chocolate Bar Battler"
            PosQ = CFrame.new(233.22836303711, 29.876001358032, -12201.233398438)
            PosM = CFrame.new(582.59057617188, 77.188095092773, -12463.162109375)
        elseif I == 2350 or I <= 2374 then
            Mon = "Sweet Thief"; Qdata = 1; Qname = "ChocQuest2"; NameMon = "Sweet Thief"
            PosQ = CFrame.new(150.50663757324, 30.693693161011, -12774.502929688)
            PosM = CFrame.new(165.1884765625, 76.058853149414, -12600.836914062)
        elseif I == 2375 or I <= 2399 then
            Mon = "Candy Rebel"; Qdata = 2; Qname = "ChocQuest2"; NameMon = "Candy Rebel"
            PosQ = CFrame.new(150.50663757324, 30.693693161011, -12774.502929688)
            PosM = CFrame.new(134.86563110352, 77.247680664062, -12876.547851562)
        elseif I == 2400 or I <= 2449 then
            Mon = "Candy Pirate"; Qdata = 1; Qname = "CandyQuest1"; NameMon = "Candy Pirate"
            PosQ = CFrame.new(-1150.0400390625, 20.378934860229, -14446.334960938)
            PosM = CFrame.new(-1310.5003662109, 26.016523361206, -14562.404296875)
        elseif I == 2450 or I <= 2474 then
            Mon = "Isle Outlaw"; Qdata = 1; Qname = "TikiQuest1"; NameMon = "Isle Outlaw"
            PosQ = CFrame.new(-16548.8164, 55.6059914, -172.8125, .213092566, 0, -0.977032006, 0, 1, 0, .977032006, 0, .213092566)
            PosM = CFrame.new(-16479.900390625, 226.6117401123, -300.31143188477)
        elseif I == 2475 or I <= 2499 then
            Mon = "Island Boy"; Qdata = 2; Qname = "TikiQuest1"; NameMon = "Island Boy"
            PosQ = CFrame.new(-16548.8164, 55.6059914, -172.8125, .213092566, 0, -0.977032006, 0, 1, 0, .977032006, 0, .213092566)
            PosM = CFrame.new(-16849.396484375, 192.86505126953, -150.78532409668)
        elseif I == 2500 or I <= 2524 then
            Mon = "Sun-kissed Warrior"; Qdata = 1; Qname = "TikiQuest2"; NameMon = "kissed Warrior"
            PosM = CFrame.new(-16347, 64, 984); PosQ = CFrame.new(-16538, 55, 1049)
        elseif I == 2525 or I <= 2550 then
            Mon = "Isle Champion"; Qdata = 2; Qname = "TikiQuest2"; NameMon = "Isle Champion"
            PosQ = CFrame.new(-16541.0215, 57.3082275, 1051.46118, .0410757065, 0, -0.999156058, 0, 1, 0, .999156058, 0, .0410757065)
            PosM = CFrame.new(-16602.1015625, 130.38734436035, 1087.2456054688)
        elseif I == 2551 or I <= 2574 then
            Mon = "Serpent Hunter"; Qdata = 1; Qname = "TikiQuest3"; NameMon = "Serpent Hunter"
            PosQ = CFrame.new(-16668.03,105.32,1568.60); PosM = CFrame.new(-16645.64,163.09,1352.87)
        elseif I >= 2575 and I <= 2599 then
            Mon = "Skull Slayer"; Qdata = 2; Qname = "TikiQuest3"; NameMon = "Skull Slayer"
            PosQ = CFrame.new(-16668.03,105.32,1568.60); PosM = CFrame.new(-16709.49,419.68,1751.09)
        elseif I >= 2600 and I <= 2624 then
            PosQ = CFrame.new(10778.875, -2087.72437, 9265.18359, 0.934615612, -9.33109447e-08, -0.355659455, 9.17655143e-08, 1, -2.12154276e-08, 0.355659455, -1.28090019e-08, 0.934615612)
            Mon = "Reef Bandit"; Qdata = 1; Qname = "SubmergedQuest1"; NameMon = "Reef Bandit"
            PosM = CFrame.new(11019.1318, -2146.06812, 9342.3916, -0.719955266, -1.74275385e-08, 0.69402045, 5.76556367e-08, 1, 8.49211546e-08, -0.69402045, 1.01153624e-07, -0.719955266)
        elseif I >= 2625 and I <= 2649 then
            PosQ = CFrame.new(10778.875, -2087.72437, 9265.18359, 0.934615612, -9.33109447e-08, -0.355659455, 9.17655143e-08, 1, -2.12154276e-08, 0.355659455, -1.28090019e-08, 0.934615612)
            Mon = "Coral Pirate"; Qdata = 2; Qname = "SubmergedQuest1"; NameMon = "Coral Pirate"
            PosM = CFrame.new(10808.6006, -2030.36145, 9364.2334, -0.775185347, -0.0359364748, 0.6307109, 0.0615428537, 0.989336014, 0.132010356, -0.628728986, 0.141148239, -0.764707148)
        elseif I >= 2650 and I <= 2674 then
            PosQ = CFrame.new(10880.6855, -2086.20044, 10032.624, -0.321384728, 9.87648434e-08, -0.946948707, 7.13271007e-08, 1, 8.00902953e-08, 0.946948707, -4.18033075e-08, -0.321384728)
            Mon = "Sea Chanter"; Qdata = 1; Qname = "SubmergedQuest2"; NameMon = "Sea Chanter"
            PosM = CFrame.new(10671.2715, -2057.59155, 10047.2588, -0.846484065, -3.11045447e-08, 0.532414079, -5.55383117e-08, 1, -2.98785316e-08, -0.532414079, -5.48610757e-08, -0.846484065)
        elseif I >= 2675 and I <= 2699 then
            PosQ = CFrame.new(10880.6855, -2086.20044, 10032.624, -0.321384728, 9.87648434e-08, -0.946948707, 7.13271007e-08, 1, 8.00902953e-08, 0.946948707, -4.18033075e-08, -0.321384728)
            Mon = "Ocean Prophet"; Qdata = 2; Qname = "SubmergedQuest2"; NameMon = "Ocean Prophet"
            PosM = CFrame.new(11008.5195, -2007.72839, 10223.0791, -0.688615739, 2.33523378e-09, -0.725126445, 2.99292546e-09, 1, 3.78221315e-10, 0.725126445, -1.90980032e-09, -0.688615739)
        elseif I >= 2700 and I <= 2724 then
            PosQ = CFrame.new(9640.08789, -1992.44507, 9613.65234, -0.957327187, 4.11991223e-08, 0.289006323, 1.5775445e-08, 1, -9.02985846e-08, -0.289006323, -8.18860855e-08, -0.957327187)
            Mon = "High Disciple"; Qdata = 1; Qname = "SubmergedQuest3"; NameMon = "High Disciple"
            PosM = CFrame.new(9750.41602, -1966.93884, 9753.36035, -0.749824047, 5.57797613e-08, -0.661637306, 2.03500754e-08, 1, 6.1243199e-08, 0.661637306, 3.24572511e-08, -0.749824047)
        elseif I >= 2725 then
            PosQ = CFrame.new(9640.08789, -1992.44507, 9613.65234, -0.957327187, 4.11991223e-08, 0.289006323, 1.5775445e-08, 1, -9.02985846e-08, -0.289006323, -8.18860855e-08, -0.957327187)
            Mon = "Grand Devotee"; Qdata = 2; Qname = "SubmergedQuest3"; NameMon = "Grand Devotee"
            PosM = CFrame.new(9611.70508, -1993.47119, 9882.68848, -0.591375351, 4.14332426e-08, -0.806396425, 4.73774868e-08, 1, 1.66361875e-08, 0.806396425, -2.83668058e-08, -0.591375351)
        end
    end
end

-- =====================================================
-- STATE
-- =====================================================
local StartFarm = false
local BringMobEnabled = false
local MaxBringCount = 2
local FarmPos = nil
local CurrentMob = nil
local activeFlyConn = nil
local noFallConn = nil
local LastQuestLevel = 0

-- =====================================================
-- TWEEN TO
-- =====================================================
local function tweenTo(targetCF, speed)
    speed = speed or 250
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    workspace.Gravity = 0
    if hum then hum.WalkSpeed = 0; hum.JumpPower = 0; hum.PlatformStand = true; hum.AutoRotate = false end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = false end
    end
    if activeFlyConn then activeFlyConn:Disconnect(); activeFlyConn = nil end
    local arrived = false
    activeFlyConn = RunService.RenderStepped:Connect(function(dt)
        if not root or not root.Parent then activeFlyConn:Disconnect(); activeFlyConn = nil; arrived = true; return end
        local diff = targetCF.Position - root.Position
        local dist = diff.Magnitude
        if dist < 3 then
            root.CFrame = targetCF; root.Velocity = Vector3.zero; root.AssemblyLinearVelocity = Vector3.zero
            activeFlyConn:Disconnect(); activeFlyConn = nil; arrived = true; return
        end
        local step = math.min(speed * dt, dist)
        root.CFrame = CFrame.new(root.Position + diff.Unit * step)
        root.Velocity = Vector3.zero; root.AssemblyLinearVelocity = Vector3.zero
    end)
    local t = 0
    repeat task.wait(0.05); t = t + 0.05 until arrived or t >= 10
    workspace.Gravity = 196.2
    if hum then hum.WalkSpeed = 16; hum.JumpPower = 50; hum.PlatformStand = false; hum.AutoRotate = true end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = true end
    end
end

-- =====================================================
-- NOFALL
-- =====================================================
local function startNoFall(mob)
    if noFallConn then noFallConn:Disconnect(); noFallConn = nil end
    workspace.Gravity = 0
    noFallConn = RunService.RenderStepped:Connect(function()
        if not StartFarm then noFallConn:Disconnect(); noFallConn = nil; return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not mob or not mob.Parent then noFallConn:Disconnect(); noFallConn = nil; return end
        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
        local mobHum = mob:FindFirstChildOfClass("Humanoid")
        if not mobRoot or not mobHum or mobHum.Health <= 0 then noFallConn:Disconnect(); noFallConn = nil; return end
        if root then
            root.CFrame = mobRoot.CFrame * CFrame.new(0, 15, 0)
            root.Velocity = Vector3.zero; root.AssemblyLinearVelocity = Vector3.zero
        end
    end)
end

local function stopNoFall()
    if noFallConn then noFallConn:Disconnect(); noFallConn = nil end
    workspace.Gravity = 196.2
    local char = LP.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16; hum.JumpPower = 50; hum.PlatformStand = false end
    end
end

-- =====================================================
-- FIND MOB
-- =====================================================
local function GetNearestMob(TargetName)
    local char = LP.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local Closest, Dist = nil, math.huge
    local Enemies = workspace:FindFirstChild("Enemies")
    if not Enemies then return nil end
    for _, Mob in pairs(Enemies:GetChildren()) do
        if not Mob:IsA("Model") then continue end
        local hum = Mob:FindFirstChildOfClass("Humanoid")
        local hrp = Mob:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not hrp then continue end
        if Mob.Name ~= TargetName then continue end
        local d = (hrp.Position - root.Position).Magnitude
        if d < Dist then Dist = d; Closest = Mob end
    end
    return Closest
end

-- =====================================================
-- BRING MOB (FIX: Kết hợp StartFarm)
-- =====================================================
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if not BringMobEnabled or not StartFarm or not FarmPos then return end
            local char = LP.Character
            if not char then return end
            local myHRP = char:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            
            local mobName = Mon
            if not mobName then
                pcall(function() QuestCheck() end)
                mobName = Mon
            end
            if not mobName then return end
            
            local hasPlayer = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local pHRP = p.Character:FindFirstChild("HumanoidRootPart")
                    if pHRP and (pHRP.Position - myHRP.Position).Magnitude <= 400 then hasPlayer = true; break end
                end
            end
            if hasPlayer then return end

            pcall(function() sethiddenproperty(LP, "SimulationRadius", math.huge) end)

            local brought = 0
            for _, v in ipairs(workspace.Enemies:GetChildren()) do
                if brought >= MaxBringCount then break end
                if not v:IsA("Model") then continue end
                local hum = v:FindFirstChild("Humanoid")
                local hrp = v:FindFirstChild("HumanoidRootPart")
                if not hum or hum.Health <= 0 or not hrp then continue end
                if v.Name ~= mobName then continue end
                local dist = (hrp.Position - FarmPos).Magnitude
                if dist > 8 and dist <= 350 then
                    task.spawn(function()
                        pcall(function()
                            if dist > 150 then hrp.CFrame = CFrame.new(FarmPos + Vector3.new(0, 3, 0)); task.wait(0.05) end
                            local tween = TweenService:Create(hrp, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(FarmPos)})
                            hrp.CanCollide = false; hrp.Size = Vector3.new(60, 60, 60)
                            hrp.Velocity = Vector3.zero; hrp.AssemblyLinearVelocity = Vector3.zero
                            hum.WalkSpeed = 0; hum.JumpPower = 0
                            if v:FindFirstChild("Head") then v.Head.CanCollide = false end
                            pcall(function() local anim = hum:FindFirstChild("Animator"); if anim then anim:Destroy() end end)
                            tween:Play()
                        end)
                    end)
                    brought = brought + 1
                end
            end
        end)
    end
end)

-- =====================================================
-- MAIN FARM LOOP
-- =====================================================
task.spawn(function()
    while true do
        task.wait(0.2)
        if not StartFarm then
            if CurrentMob then stopNoFall(); CurrentMob = nil end
            LastQuestLevel = 0
            continue
        end

        local currentLevel = LP.Data.Level.Value

        pcall(function() QuestCheck() end)
        local qName = Qname; local qLevel = Qdata; local qPos = PosQ; local mPos = PosM; local mobName = Mon; local nameMon = NameMon
        if not qName or not qPos or not mobName then task.wait(1); continue end

        local questVisible, questTitle = false, ""
        pcall(function()
            local main = LP.PlayerGui:FindFirstChild("Main")
            if main then
                local qFrame = main:FindFirstChild("Quest")
                if qFrame then
                    questVisible = qFrame.Visible
                    for _, v in ipairs(qFrame:GetDescendants()) do
                        if v:IsA("TextLabel") and v.Name == "Title" and v.Text ~= "" then questTitle = v.Text; break end
                    end
                end
            end
        end)

        if questVisible and questTitle ~= "" and LastQuestLevel > 0 then
            if currentLevel ~= LastQuestLevel then
                if not questTitle:find(nameMon) then
                    pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest") end)
                    task.wait(0.5); questVisible = false; LastQuestLevel = 0
                else
                    LastQuestLevel = currentLevel
                end
            end
        end

        if not questVisible then
            tweenTo(qPos, 250); task.wait(0.5)
            pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", qName, qLevel) end)
            task.wait(0.5)
            LastQuestLevel = currentLevel
            if mPos then tweenTo(mPos, 300); task.wait(0.3) end
            continue
        end

        if LastQuestLevel == 0 then LastQuestLevel = currentLevel end

        if CurrentMob then
            local mh = CurrentMob:FindFirstChildOfClass("Humanoid")
            if not CurrentMob.Parent or not mh or mh.Health <= 0 then
                stopNoFall(); CurrentMob = nil
                LastQuestLevel = 0
            end
        end

        if not CurrentMob then CurrentMob = GetNearestMob(mobName) end

        if not CurrentMob then
            if mPos then tweenTo(mPos, 200) end
            task.wait(0.5); continue
        end

        local mobRoot = CurrentMob:FindFirstChild("HumanoidRootPart")
        if not mobRoot then CurrentMob = nil; continue end

        FarmPos = mobRoot.Position
        tweenTo(mobRoot.CFrame * CFrame.new(0, 15, 0), 300)
        startNoFall(CurrentMob)

        repeat
            task.wait(0.1)
            if not CurrentMob or not CurrentMob.Parent then break end
            local mh2 = CurrentMob:FindFirstChildOfClass("Humanoid")
            if not mh2 or mh2.Health <= 0 then break end
            if CurrentMob:FindFirstChild("HumanoidRootPart") then FarmPos = CurrentMob.HumanoidRootPart.Position end
        until not StartFarm

        stopNoFall(); CurrentMob = nil
    end
end)

-- =====================================================
-- FLUENT UI
-- =====================================================
local Window = Fluent:CreateWindow({
    Title       = "Vexz Hub",
    SubTitle    = "Blox Fruit",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 440),
    Acrylic     = true,
    Theme       = "Pink",
    MinimizeKey = Enum.KeyCode.RightShift,
})

local Tabs = {
    Farm   = Window:AddTab({ Title = "Farm",   Icon = "swords" }),
    Mob    = Window:AddTab({ Title = "Mob",    Icon = "zap" }),
    Misc   = Window:AddTab({ Title = "Misc",   Icon = "settings" }),
}

-- =====================================================
-- TAB FARM
-- =====================================================
Tabs.Farm:AddSection("Auto Farm")
Tabs.Farm:AddToggle("StartFarm", {
    Title       = "Start Farm",
    Description = "Auto Quest + Farm Level",
    Default     = false,
}):OnChanged(function(v) StartFarm = v end)

-- =====================================================
-- TAB MOB
-- =====================================================
Tabs.Mob:AddSection("Bring Mob")
Tabs.Mob:AddToggle("BringMob", {
    Title       = "Bring Mob",
    Description = "Keo quai ve 1 cho (Can bat Start Farm)",
    Default     = false,
}):OnChanged(function(v) BringMobEnabled = v end)
Tabs.Mob:AddSlider("BringCount", {
    Title = "Bring Mob Count", Min = 2, Max = 6, Rounding = 1, Default = 2,
}):OnChanged(function(v) MaxBringCount = v end)

-- =====================================================
-- TAB MISC
-- =====================================================
Tabs.Misc:AddSection("Settings")
Tabs.Misc:AddParagraph({ Title = "Phim tat", Content = "RightShift — An/Hien UI" })

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("VexzHub")
SaveManager:SetFolder("VexzHub/configs")
SaveManager:BuildConfigSection(Tabs.Misc)
InterfaceManager:BuildInterfaceSection(Tabs.Misc)

-- =====================================================
-- LOGO
-- =====================================================
task.spawn(function()
    task.wait(0.5)
    local pGui = LP:WaitForChild("PlayerGui")
    for _, gui in ipairs(pGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Name == "Title" then
                    local logo = Instance.new("ImageLabel")
                    logo.Image = "rbxassetid://93384558628762"
                    logo.Size = UDim2.new(0, 24, 0, 24)
                    logo.Position = UDim2.new(0, -30, 0.5, -12)
                    logo.BackgroundTransparency = 1
                    local logoCorner = Instance.new("UICorner"); logoCorner.CornerRadius = UDim.new(1, 0); logoCorner.Parent = logo
                    logo.ZIndex = 10; logo.Parent = v.Parent
                    break
                end
            end
        end
    end
end)

-- =====================================================
-- FLOATING TOGGLE BUTTON
-- =====================================================
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "ControlGUI"

local toggleButton = Instance.new("ImageButton", screenGui)
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0.02, 0, 0.22, 0)
toggleButton.Image = "rbxassetid://93384558628762"
toggleButton.BackgroundTransparency = 1
toggleButton.Active = true
toggleButton.Draggable = false

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleButton

local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        toggleButton.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

SaveManager:LoadAutoloadConfig()
Window:SelectTab(1)

print("[Vexz Hub] Loaded! Fast Attack: ON (0.05s) | Auto Quest: Ready | Bring Mob: Ready | Floating Button: Added") 
