-- SethDetectorFishParry v1.16.2 FESTIN INFINITO
-- Sin freeze, sin spam, festin x7...x99 divertido
-- WOTLK 3.3.5 - By Seth + Fix

local ADDON = "SethDetectorFishParry"
local frame = CreateFrame("Frame")

local stats = {parry={}, festin={}, manada={}, mc={}}
local lastWarn, festinCount, manadaReported = {}, {}, {}
local settings = {manada=true, festin=true, parry=true, mc=true}

local MC_SPELLS = {[71289]=true,[71290]=true,[72027]=true,[72028]=true,[73020]=true,[68904]=true}
local FESTIN_SPELLS = {[57301]=true,[57426]=true,[57291]=true,[57302]=true,[58465]=true,[58474]=true,[58506]=true,[57025]=true}
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

local function GetFestinMsg(count, coloredName)
    if count <= 6 then
        return string.format(FESTIN_MSGS[count], coloredName)
    elseif count == 7 then
        return string.format("%s ¡Ya 7! ¡Deja para el tanque! x7", coloredName)
    elseif count == 8 then
        return string.format("%s ¡8 festines! ¿Stock para Naxx? x8", coloredName)
    elseif count == 9 then
        return string.format("%s ¡9! Tragón oficial de la guild! x9", coloredName)
    elseif count >= 10 and count < 15 then
        return string.format("%s ¡¡x%d!! ¡Cocina [450] sin trabajo! x%d", coloredName, count, count)
    elseif count >= 15 and count < 20 then
        return string.format("%s ¡¡¡x%d!!! ¡BANEEN AL HAMBRE! x%d", coloredName, count, count)
    else
        return string.format("%s ¡¡¡x%d!!! ¡¡¡BOSS COMIENDO!!! ¡Wipe por hambre! x%d", coloredName, count, count)
    end
end

local function AddStat(kind, name) if not name or name=="" then return end stats[kind][name]=(stats[kind][name] or 0)+1 end
local function ClearStats() wipe(stats.parry) wipe(stats.festin) wipe(stats.manada) wipe(stats.mc) wipe(festinCount) print("|cFF00FF00[Seth]|r Stats limpiados.") end
local function GetColoredName(name, guid)
    local color="|cFFFFFFFF" local class=nil
    if guid then local _, engClass=GetPlayerInfoByGUID(guid) class=engClass end
    if not class and name then local _, engClass=UnitClass(name) class=engClass end
    if class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then local c=RAID_CLASS_COLORS[class] color=string.format("|cFF%02x%02x%02x",c.r*255,c.g*255,c.b*255) end
    return color..(name or "???").."|r"
end
local function SendRaid(msg) if not msg or msg=="" then return end if IsInRaid() then pcall(SendChatMessage,msg,"RAID") else print(msg) end end
local function SendRaidWarning(msg) if not msg or msg=="" then return end if not IsInRaid() then return end if IsRaidLeader() or IsRaidOfficer() or UnitIsGroupLeader("player") then pcall(SendChatMessage,msg,"RAID_WARNING") end end
local function ShouldWarn(key, seconds) local now=GetTime() if lastWarn[key] and (now-lastWarn[key])<seconds then return false end lastWarn[key]=now return true end
local function WarnManadaOnce(playerName, guid)
    if not playerName or manadaReported[playerName] then return end manadaReported[playerName]=true AddStat("manada",playerName)
    local key=playerName..":manada" if ShouldWarn(key,30) and settings.manada then
        SendRaid(ICON_MANADA.." "..GetColoredName(playerName,guid).." Señor Cazador tu aspecto de Manada ¡Perjudica a la Raid!..")
        SendRaidWarning(playerName.." ¡Quita Manada! Perjudica a la Raid!") end
end
local function PrintStatsSummary()
    print("=== SethDetectorFishParry Stats ===")
    for _, kind in ipairs({"parry","festin","manada","mc"}) do
        local list={} for name,count in pairs(stats[kind]) do table.insert(list,{name=name,count=count}) end
        table.sort(list,function(a,b) return a.count>b.count end)
        if #list==0 then print(kind..": ninguno") else print("["..kind.."]") for i=1,#list do print("  "..list[i].name.." -> "..list[i].count) end end
    end
end

SLASH_SETHDETECTORFISHPARRY1="/seth" SLASH_SETHDETECTORFISHPARRY2="/sethdfp"
SlashCmdList["SETHDETECTORFISHPARRY"]=function(msg)
    msg=(msg or ""):gsub("^%s+",""):gsub("%s+$","")
    if msg=="stats" then PrintStatsSummary()
    elseif msg=="clear" then ClearStats()
    elseif msg=="status" then print("Manada="..tostring(settings.manada).." Festin="..tostring(settings.festin).." Parry="..tostring(settings.parry).." MC="..tostring(settings.mc))
    elseif msg=="manada" then settings.manada=not settings.manada print("Manada="..tostring(settings.manada))
    elseif msg=="festin" then settings.festin=not settings.festin print("Festin="..tostring(settings.festin))
    elseif msg=="parry" then settings.parry=not settings.parry print("Parry="..tostring(settings.parry))
    elseif msg=="mc" then settings.mc=not settings.mc print("MC="..tostring(settings.mc))
    elseif msg=="help" then print("/seth stats | /seth clear | /seth status | /seth manada/festin/parry/mc")
    else PrintStatsSummary() end
end

frame:RegisterEvent("ADDON_LOADED") frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") frame:RegisterEvent("PLAYER_REGEN_DISABLED") frame:RegisterEvent("ENCOUNTER_START")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event=="ADDON_LOADED" and arg1==ADDON then print("|cFF00FF00SethDetectorFishParry|r v1.16.2 FESTIN INFINITO - ON - /seth") return end
    if event=="PLAYER_REGEN_DISABLED" or event=="ENCOUNTER_START" then manadaReported={} return end
    if event~="COMBAT_LOG_EVENT_UNFILTERED" then return end
    local _, subEvent, _, sourceGUID, sourceName, _, destGUID, destName, _, _, spellId, spellName, _, _, missType=CombatLogGetCurrentEventInfo()
    if not subEvent then return end
    if subEvent=="SPELL_AURA_APPLIED" and spellId==ASPECTO_MANADA then
        if sourceName and (InCombatLockdown() or IsEncounterInProgress()) then WarnManadaOnce(sourceName, sourceGUID) end return
    end
    if subEvent=="SPELL_AURA_REMOVED" and spellId==ASPECTO_MANADA and sourceName then manadaReported[sourceName]=nil return end
    if subEvent=="SPELL_AURA_APPLIED" and FESTIN_SPELLS[spellId] and settings.festin then
        if destGUID and destGUID:find("Player",1,true) and destName then
            festinCount[destName]=(festinCount[destName] or 0)+1 AddStat("festin",destName)
            local c=festinCount[destName]
            local msg=GetFestinMsg(c, GetColoredName(destName,destGUID))
            local icon=(c==1) and ICON_FESTIN or ICON_CHEF
            SendRaid(icon.." FESTIN: "..msg)
        end return
    end
    if subEvent=="SWING_MISSED" and settings.parry and missType=="PARRY" and sourceName then AddStat("parry",sourceName) return end
    if subEvent=="SPELL_CAST_START" and settings.mc and (MC_SPELLS[spellId] or (spellName and spellName:lower():find("domin",1,true))) then AddStat("mc",sourceName or "Lady") end
end)
