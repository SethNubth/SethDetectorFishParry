-- SethDetectorFishParry v1.0 | Naerzone Edition
-- Modulo 1: FishClicker | Modulo 2: Parry Haste Damage
local ADDON = "SethDetectorFishParry"
local frame = CreateFrame("Frame")

-- CONFIG
local SPELL_FISH_CLICK = 57397
local SPELL_FISH_CREATE = 57426
local ITEM_FISH = 43015
local PARRY_WINDOW = 2.0 -- 2 seg ventana de Parry Haste

-- DATA
local fishCount = {}
local lastParry = {} -- [bossGUID] = {time, victim}
local cachedFishName = "Festín de Pescado"
local enabled = {fish = true, parry = true}

-- FUNCIONES BASE
local function SendBanda(msg)
    if not msg or msg == "" then return end
    msg = tostring(msg)
    if IsInRaid() then
        pcall(SendChatMessage, msg, "RAID")
    elseif IsInGroup() then
        pcall(SendChatMessage, msg, "PARTY")
    else
        print("|cFF00FF00[SethDetector]|r "..msg)
    end
end

local function ResetFish(motivo)
    table.wipe(fishCount)
    local ok, name = pcall(function() return select(2, GetItemInfo(ITEM_FISH)) end)
    if ok and name then cachedFishName = name end
    print("|cFFFFFF00[SethDetector]|r Contador de "..cachedFishName.." reiniciado ("..(motivo or "reset")..")")
end

-- EVENTOS
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        print("|cFF00FF00SethDetectorFishParry v1.0|r cargado. Comandos: /sdf fish, /sdf parry, /sdf test | Alertas en /BANDA")
        return
    end

    if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
        local _, tipo = IsInInstance()
        if tipo == "raid" or tipo == "party" then
            ResetFish("cambio de zona")
            table.wipe(lastParry)
        end
        return
    end

    if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end

    local timestamp, subEvent, _, sourceGUID, sourceName, _, destGUID, destName, _, _, spellId, _, _, _, _, missType, _, amount = CombatLogGetCurrentEventInfo()
    if not subEvent or not sourceName then return end
    local now = GetTime()

    -- ========== MODULO 1: FISH CLICKER (ESPAÑOL + BANDA) ==========
    if enabled.fish then
        if subEvent == "SPELL_CAST_SUCCESS" and spellId == SPELL_FISH_CLICK then
            if sourceName == UnitName("player") or UnitInRaid(sourceName) or UnitInParty(sourceName) or not IsInGroup() then
                fishCount[sourceName] = (fishCount[sourceName] or 0) + 1
                if fishCount[sourceName] > 4 then
                    local ok, link = pcall(GetSpellLink, SPELL_FISH_CLICK)
                    local spellLink = (ok and link) and link or cachedFishName
                    local msg = "ESTÁ TROLLEANDO: "..sourceName.." CLICKEÓ EN "..spellLink.." "..fishCount[sourceName].." VECES!"
                    SendBanda(msg)
                end
            end
        end
        if (spellId == SPELL_FISH_CREATE and subEvent == "SPELL_CREATE") or (sourceName == UnitName("player") and subEvent == "UNIT_DIED") then
            ResetFish("nuevo festín")
        end
    end

    -- ========== MODULO 2: PARRY HASTE POR DAÑO HECHO ==========
    if enabled.parry then
        -- 1. Boss hace Parry
        if subEvent == "SWING_MISSED" and missType == "PARRY" then
            -- source = boss, dest = jugador que fue parreado
            lastParry[sourceGUID] = {time = now, victim = destName, bossName = sourceName}
        end

        -- 2. Boss pega después del Parry (daño hasteado)
        if (subEvent == "SWING_DAMAGE" or subEvent == "SPELL_DAMAGE" or subEvent == "RANGE_DAMAGE") and lastParry[sourceGUID] then
            local data = lastParry[sourceGUID]
            local diff = now - data.time
            if diff <= PARRY_WINDOW and diff > 0.1 then
                local damage = amount or 0
                if damage > 4000 then -- Solo daño relevante a tanque
                    local msg = "PARRY HASTE: "..data.bossName.." hizo PARRY a "..data.victim.." y pegó "..damage.." a "..destName.." en "..string.format("%.2f", diff).."s!"
                    SendBanda(msg)
                end
                lastParry[sourceGUID] = nil -- Limpia para no spamear
            elseif diff > PARRY_WINDOW then
                lastParry[sourceGUID] = nil
            end
        end
    end
end)

-- COMANDOS /sdf
SLASH_SDF1 = "/sdf"
SLASH_SDF2 = "/sethfish"
SlashCmdList["SDF"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "fish" then
        enabled.fish = not enabled.fish
        print("Fish Detector: "..(enabled.fish and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))
    elseif msg == "parry" then
        enabled.parry = not enabled.parry
        print("Parry Haste Detector: "..(enabled.parry and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"))
    elseif msg == "reset" then
        ResetFish("comando")
        table.wipe(lastParry)
    elseif msg == "test" then
        SendBanda("TEST: ESTÁ TROLLEANDO: TestPlayer CLICKEÓ EN "..cachedFishName.." 6 VECES!")
        SendBanda("TEST: PARRY HASTE: Sindragosa hizo PARRY a TestWar y pegó 18200 a TestTank en 0.65s!")
    else
        print("|cFF00FF00SethDetectorFishParry comandos:|r")
        print("/sdf fish - ON/OFF detector festín")
        print("/sdf parry - ON/OFF detector parry haste")
        print("/sdf reset - Reinicia contadores")
        print("/sdf test - Prueba mensajes en /BANDA")
    end
end
