-- SethDetectorFishParry v1.2 | Filtro solo bosses con Parry Haste peligroso
local ADDON = "SethDetectorFishParry"
local frame = CreateFrame("Frame")
local SPELL_FISH_CLICK = 57397
local SPELL_FISH_CREATE = 57426
local ITEM_FISH = 43015
local PARRY_WINDOW = 2.0

local fishCount = {}
local lastParry = {}
local cachedFishName = "Festín de Pescado"
local enabled = {fish = true, parry = true}

-- FILTRO: Solo estos bosses tienen Parry Haste peligroso en 3.3.5a
local BOSS_CON_PARRY = {
    [36612] = true, -- Lord Tuétano / Marrowgar
    [36855] = true, -- Sindragosa
    [39863] = true, -- Halion 25 (Ruby Sanctum)
    [40142] = true, -- Halion 25H
    [36626] = true, -- Festergut (por si lo quieres, lo dejamos)
    [36627] = true, -- Rotface
}
-- Si quieres SOLO los 3 top, deja solo estos 3 IDs activos arriba y comenta el resto

local function GetMobIdFromGUID(guid)
    if not guid then return 0 end
    -- GUID 3.3.5a: 0xF13000366C00000001 -> el ID es el del medio
    local id = tonumber(strsub(guid, 9, 12), 16) or tonumber(strsub(guid, 7, 10), 16) or 0)
    -- Fallback por nombre para servidores privados con GUID raro (Naerzone)
    if id == 0 and guid then
        id = tonumber(select(3, strfind(guid, "%-.-%-.-%-.-%-(%d+)%-")) or 0)
    end
    return id
end

local function SendAvisoInteligente(msg)
    if not msg or msg == "" then return end
    msg = tostring(msg)
    if IsInRaid() then
        local isLeader = IsRaidLeader() or IsRaidOfficer() or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
        if isLeader then
            local ok = pcall(SendChatMessage, msg, "RAID_WARNING")
            if not ok then pcall(SendChatMessage, msg, "RAID") end
        else
            pcall(SendChatMessage, msg, "RAID")
        end
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
    print("|cFFFFFF00[SethDetector]|r Contador "..cachedFishName.." reiniciado ("..(motivo or "")..")")
end

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        print("|cFF00FF00SethDetectorFishParry v1.2|r ON - Filtro: Tuétano/Sindragosa/Halion | /sdf para config")
        return
    end
    if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
        local _, tipo = IsInInstance()
        if tipo == "raid" or tipo == "party" then ResetFish("zona") table.wipe(lastParry) end
        return
    end
    if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end

    local _, subEvent, _, sourceGUID, sourceName, _, destGUID, destName, _, _, spellId, _, _, _, _, missType, _, amount = CombatLogGetCurrentEventInfo()
    if not subEvent or not sourceName then return end
    local now = GetTime()

    -- FISH
    if enabled.fish and subEvent == "SPELL_CAST_SUCCESS" and spellId == SPELL_FISH_CLICK then
        if sourceName == UnitName("player") or UnitInRaid(sourceName) or UnitInParty(sourceName) or not IsInGroup() then
            fishCount[sourceName] = (fishCount[sourceName] or 0) + 1
            if fishCount[sourceName] > 4 then
                local ok, link = pcall(GetSpellLink, SPELL_FISH_CLICK)
                local spellLink = (ok and link) and link or cachedFishName
                SendAvisoInteligente("ESTÁ TROLLEANDO: "..sourceName.." CLICKEÓ EN "..spellLink.." "..fishCount[sourceName].." VECES!")
            end
        end
    end
    if enabled.fish and (spellId == SPELL_FISH_CREATE and subEvent == "SPELL_CREATE") then ResetFish("nuevo festín") end

    -- PARRY HASTE CON FILTRO
    if enabled.parry then
        if subEvent == "SWING_MISSED" and missType == "PARRY" then
            -- FILTRO: ¿Es uno de los bosses peligrosos?
            local mobId = GetMobIdFromGUID(sourceGUID)
            -- Fallback por nombre para Naerzone (a veces GUID custom)
            local isBossFiltrado = BOSS_CON_PARRY[mobId] or string.find(sourceName, "Tuétano") or string.find(sourceName, "Marrowgar") or string.find(sourceName, "Sindragosa") or string.find(sourceName, "Halion")
            if isBossFiltrado then
                lastParry[sourceGUID] = {time = now, victim = destName, bossName = sourceName, mobId = mobId}
            end
        end
        if (subEvent == "SWING_DAMAGE" or subEvent == "SPELL_DAMAGE") and lastParry[sourceGUID] then
            local data = lastParry[sourceGUID]
            local diff = now - data.time
            if diff <= PARRY_WINDOW and diff > 0.1 then
                local damage = amount or 0
                if damage > 4000 then
                    SendAvisoInteligente("PARRY HASTE: "..data.bossName.." hizo PARRY a "..data.victim.." y pegó "..damage.." a "..destName.." en "..string.format("%.2f", diff).."s!")
                end
                lastParry[sourceGUID] = nil
            elseif diff > PARRY_WINDOW then
                lastParry[sourceGUID] = nil
            end
        end
    end
end)

SLASH_SDF1 = "/sdf"
SlashCmdList["SDF"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "fish" then enabled.fish = not enabled.fish print("Fish: "..(enabled.fish and "ON" or "OFF"))
    elseif msg == "parry" then enabled.parry = not enabled.parry print("Parry: "..(enabled.parry and "ON" or "OFF"))
    elseif msg == "reset" then ResetFish("comando") table.wipe(lastParry)
    elseif msg == "test" then SendAvisoInteligente("TEST: PARRY HASTE: Sindragosa hizo PARRY a TestWar y pegó 18200 a TestTank en 0.65s!")
    else print("/sdf fish | /sdf parry | /sdf reset | /sdf test") end
end
