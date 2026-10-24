-- SethDetectorFishParry v1.16.0
-- Sin spam, con logs y resumen por jugador
-- WOTLK 3.3.5

local ADDON = "SethDetectorFishParry"
local frame = CreateFrame("Frame")

local stats = {
    parry = {},
    festin = {},
    manada = {},
    mc = {},
}

local lastWarn = {}
local festinCount = {}
local manadaReported = {}

local settings = {
    manada = true,
    festin = true,
    parry = true,
    mc = true,
}

local MC_SPELLS = {
    [71289] = true,
    [71290] = true,
    [72027] = true,
    [72028] = true,
    [73020] = true,
    [68904] = true,
}

local FESTIN_SPELLS = {
    [57301] = true,
    [57426] = true,
    [57291] = true,
    [57302] = true,
    [58465] = true,
    [58474] = true,
    [58506] = true,
    [57025] = true,
}

local ASPECTO_MANADA = 13159

local ICON_MANADA = "|TInterface\\Icons\\Ability_Mount_JungleTiger:20|t"
local ICON_PARRY = "|TInterface\\Icons\\Ability_Parry:20|t"
local ICON_MC = "|TInterface\\Icons\\Spell_Shadow_ShadowWordDominate:20|t"
local ICON_FESTIN = "|TInterface\\Icons\\INV_Misc_Food_64:20|t"
local ICON_CHEF = "|TInterface\\Icons\\Achievement_Profession_Cooking:20|t"

local FESTIN_MSGS = {
    "%s comio del festin! x1",
    "%s cata pescados, deja uno para los demas! x2",
    "%s, el festin no es tu banco de peces! x3",
    "%s confirmado oficial del festin. Te pagan por click? x4",
    "%s, si sigue asi, deja sin trabajo al de cocina! x5",
    "%s, Chef del Ano! Suelta el festin del raid! x6",
}

local function AddStat(kind, name)
    if not name or name == "" then return end
    stats[kind][name] = (stats[kind][name] or 0) + 1
end

local function ClearStats()
    wipe(stats.parry)
    wipe(stats.festin)
    wipe(stats.manada)
    wipe(stats.mc)
end

local function GetColoredName(name, guid)
    local color = "|cFFFFFFFF"
    local class = nil

    if guid then
        local _, engClass = GetPlayerInfoByGUID(guid)
        class = engClass
    end

    if not class and name then
        local _, engClass = UnitClass(name)
        class = engClass
    end

    if class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
        local c = RAID_CLASS_COLORS[class]
        color = string.format("|cFF%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
    end

    return color .. (name or "???") .. "|r"
end

local function SendRaid(msg)
    if not msg or msg == "" then return end
    if IsInRaid() then
        pcall(SendChatMessage, msg, "RAID")
    else
        print(msg)
    end
end

local function SendRaidWarning(msg)
    if not msg or msg == "" then return end
    if not IsInRaid() then return end
    if IsRaidLeader() or IsRaidOfficer() or UnitIsGroupLeader("player") then
        pcall(SendChatMessage, msg, "RAID_WARNING")
    end
end

local function ShouldWarn(key, seconds)
    local now = GetTime()
    if lastWarn[key] and (now - lastWarn[key]) < seconds then
        return false
    end
    lastWarn[key] = now
    return true
end

local function IsHunterName(name)
    if not name then return false end
    local _, class = UnitClass(name)
    return class == "HUNTER"
end

local function WarnManadaOnce(playerName, guid)
    if not playerName then return end
    if manadaReported[playerName] then return end
    manadaReported[playerName] = true

    AddStat("manada", playerName)

    local colored = GetColoredName(playerName, guid)
    local key = playerName .. ":manada"

    if ShouldWarn(key, 30) then
        SendRaid(ICON_MANADA .. " " .. colored .. " Señor Cazador tu aspecto de Manada ¡Perjudica a la Raid!..")
        SendRaidWarning(playerName .. " ¡Quita Manada! Perjudica a la Raid!")
    end
end

local function PrintStatsSummary()
    print("=== SethDetectorFishParry Stats ===")
    for _, kind in ipairs({"parry", "festin", "manada", "mc"}) do
        local list = {}
        for name, count in pairs(stats[kind]) do
            table.insert(list, { name = name, count = count })
        end

        table.sort(list, function(a, b)
            return a.count > b.count
        end)

        if #list == 0 then
            print(kind .. ": ninguno")
        else
            print("[" .. kind .. "]")
            for i = 1, #list do
                print("  " .. list[i].name .. " -> " .. list[i].count)
            end
        end
    end
end

local function SlashHandler(msg)
    msg = (msg or ""):gsub("^%s+", ""):gsub("%s+$", "")

    if msg == "stats" then
        PrintStatsSummary()
    elseif msg == "clear" then
        ClearStats()
        print("Stats limpiados.")
    elseif msg == "status" then
        print("Manada=" .. tostring(settings.manada) .. " Festin=" .. tostring(settings.festin) .. " Parry=" .. tostring(settings.parry) .. " MC=" .. tostring(settings.mc))
    elseif msg == "manada" then
        settings.manada = not settings.manada
        print("Manada = " .. tostring(settings.manada))
    elseif msg == "festin" then
        settings.festin = not settings.festin
        print("Festin = " .. tostring(settings.festin))
    elseif msg == "parry" then
        settings.parry = not settings.parry
        print("Parry = " .. tostring(settings.parry))
    elseif msg == "mc" then
        settings.mc = not settings.mc
        print("MC = " .. tostring(settings.mc))
    elseif msg == "help" then
        print("/seth stats | /seth clear | /seth status")
    else
        PrintStatsSummary()
    end
end

SLASH_SETHDETECTORFISHPARRY1 = "/seth"
SLASH_SETHDETECTORFISHPARRY2 = "/sethdfp"
SlashCmdList["SETHDETECTORFISHPARRY"] = SlashHandler

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        print("|cFF00FF00SethDetectorFishParry|r ON")
        return
    end

    if event == "PLAYER_REGEN_DISABLED" or event == "ENCOUNTER_START" then
        manadaReported = {}
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        ClearStats()
        return
    end

    if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then
        return
    end

    local _, subEvent, _, sourceGUID, sourceName, _, destGUID, destName, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()
    if not subEvent then
        return
    end

    if subEvent == "SPELL_AURA_APPLIED" and spellId == ASPECTO_MANADA then
        if sourceName and IsHunterName(sourceName) and (InCombatLockdown() or IsEncounterInProgress()) then
            WarnManadaOnce(sourceName, sourceGUID)
        end
        return
    end

    if subEvent == "SPELL_AURA_REMOVED" and spellId == ASPECTO_MANADA and sourceName then
        manadaReported[sourceName] = nil
        return
    end

    if subEvent == "SPELL_AURA_APPLIED" and FESTIN_SPELLS[spellId] and settings.festin then
        if destGUID and destGUID:find("Player", 1, true) and destName then
            festinCount[destName] = (festinCount[destName] or 0) + 1
            AddStat("festin", destName)
            local c = festinCount[destName]
            if c <= 6 then
                local icon = (c == 1) and ICON_FESTIN or ICON_CHEF
                SendRaid(icon .. " FESTIN: " .. string.format(FESTIN_MSGS[c], GetColoredName(destName, destGUID)))
            else
                SendRaid(ICON_CHEF .. " FESTIN: Un hambriento en banda! " .. GetColoredName(destName, destGUID) .. " x" .. c .. "!")
            end
        end
        return
    end

    if subEvent == "SWING_MISSED" and settings.parry then
        local _, _, _, _, _, _, _, _, _, _, _, _, missType = CombatLogGetCurrentEventInfo()
        if missType == "PARRY" and sourceName then
            AddStat("parry", sourceName)
        end
        return
    end

    if subEvent == "SPELL_CAST_START" and settings.mc then
        if MC_SPELLS[spellId] or (spellName and spellName:lower():find("domin", 1, true)) then
            AddStat("mc", sourceName)
        end
    end
end)
