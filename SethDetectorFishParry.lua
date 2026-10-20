-- SethDetectorFishParry v1.11.1 MANADA FINAL | By Seth
local ADDON = "SethDetectorFishParry"
local frame = CreateFrame("Frame")
local petOwner, mindControlled = {}, {}
local festinCount = {}
local MC_SPELLS = {[71289]=true,[71290]=true,[72027]=true,[72028]=true,[73020]=true,[68904]=true}
local FESTIN_SPELLS = {[57301]=true,[57426]=true,[57291]=true,[57302]=true,[58465]=true,[58474]=true,[58506]=true,[57025]=true}
local ASPECTO_MANADA = 13159

local ICON_FESTIN = "|TInterface\\Icons\\INV_Misc_Food_64:20|t"
local ICON_CHEF = "|TInterface\\Icons\\Achievement_Profession_Cooking:20|t"
local ICON_PARRY = "|TInterface\\Icons\\Ability_Parry:20|t"
local ICON_MC = "|TInterface\\Icons\\Spell_Shadow_ShadowWordDominate:20|t"
local ICON_FAIL = "|TInterface\\Icons\\Ability_Warrior_Cleave:20|t"
local ICON_OK = "|TInterface\\Icons\\INV_Misc_Horn_03:20|t"
local ICON_MANADA = "|TInterface\\Icons\\Ability_Mount_JungleTiger:20|t"

local FESTIN_MSGS = {
    "%s comio del festin! [Cocina] x1",
    "%s esta haciendo cata de pescados, deja uno para los demas! x2",
    "%s, el festin no es tu banco de peces! Controla ese click! x3",
    "%s confirmado como catador oficial del festin. Te pagan por click? x4",
    "%s, si sigues asi le vas a dejar sin trabajo al de Cocina [450]! x5",
    "%s, Te nombramos Chef del Ano! Pero suelta el festin que es del raid! x6"
}

local manadaReported = {}

local function GetColoredName(name, guid)
    local color = "|cFFFFFFFF"
    local class = nil
    if guid then local _, engClass = GetPlayerInfoByGUID(guid) class = engClass end
    if not class and name then local _, engClass = UnitClass(name) class = engClass end
    if class and RAID_CLASS_COLORS[class] then local c=RAID_CLASS_COLORS[class] color=string.format("|cFF%02x%02x%02x", c.r*255, c.g*255, c.b*255) end
    return color..(name or "???").."|r"
end

local function SendBanda(msg) if IsInRaid() then pcall(SendChatMessage, msg, "RAID") else print(msg) end end
local function SendRW(msg) 
    if not IsInRaid() then return end
    if IsRaidLeader() or IsRaidOfficer() or UnitIsGroupLeader("player") then
        pcall(SendChatMessage, msg, "RAID_WARNING") 
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("ENCOUNTER_START")

frame:SetScript("OnEvent", function(_, event, arg1)
    if event=="ADDON_LOADED" and arg1==ADDON then print("|cFF00FF00Seth v1.11.1|r "..ICON_MANADA.." MANADA + FESTIN ON") return end
    
    if event=="PLAYER_REGEN_DISABLED" or event=="ENCOUNTER_START" then
        manadaReported = {}
        if IsInRaid() then
            for i=1, GetNumGroupMembers() do
                local name = GetRaidRosterInfo(i)
                if name then
                    local unit = "raid"..i
                    if UnitExists(unit) then
                        for j=1,40 do
                            local buffName, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, j)
                            if not buffName then break end
                            if spellId==ASPECTO_MANADA and not manadaReported[name] then
                                manadaReported[name]=true
                                local colored = GetColoredName(name)
                                SendBanda(ICON_MANADA.." "..colored.." Señor Cazador tu aspecto de Manada ¡Perjudica a la Raid!..")
                                SendRW(name.." ¡Quita Manada! Perjudica a la Raid!")
                            end
                        end
                    end
                end
            end
        end
        return
    end

    local _,subEvent,_,sourceGUID,sourceName,_,destGUID,destName,_,_,spellId,spellName=CombatLogGetCurrentEventInfo()
    if not subEvent then return end
    if subEvent=="SPELL_SUMMON" and destGUID and sourceName then petOwner[destGUID]=sourceName return end

    if subEvent=="SPELL_AURA_APPLIED" and spellId==ASPECTO_MANADA then
        if sourceName and not manadaReported[sourceName] and (InCombatLockdown() or IsEncounterInProgress()) then
            manadaReported[sourceName]=true
            local colored = GetColoredName(sourceName, sourceGUID)
            SendBanda(ICON_MANADA.." "..colored.." Señor Cazador tu aspecto de Manada ¡Perjudica a la Raid!..")
            SendRW(sourceName.." ¡Quita Manada! Perjudica a la Raid!")
        end
        return
    end
    if subEvent=="SPELL_AURA_REMOVED" and spellId==ASPECTO_MANADA and sourceName then manadaReported[sourceName]=nil return end

    if subEvent=="SPELL_AURA_APPLIED" and FESTIN_SPELLS[spellId] then
        if destGUID and destGUID:find("Player",1,true) and destName then
            festinCount[destName]=(festinCount[destName] or 0)+1
            local c=festinCount[destName]
            local colored=GetColoredName(destName, destGUID)
            if c<=6 then local icon=(c==1) and ICON_FESTIN or ICON_CHEF SendBanda(icon.." FESTIN: "..string.format(FESTIN_MSGS[c], colored))
            else SendBanda(ICON_CHEF.." FESTIN: Un hambriento en banda! "..colored.." x"..c.."!") end
        end
        return
    end

    if subEvent=="SWING_MISSED" then
        local _,_,_,_,_,_,_,_,_,_,_,_,missType = CombatLogGetCurrentEventInfo()
        if missType=="PARRY" and destGUID and destGUID:find("Creature",1,true) and sourceName then
            SendBanda(ICON_PARRY.." PARRY FAIL: "..GetColoredName(sourceName, sourceGUID).." parreado!")
        end
        return
    end

    if subEvent=="SPELL_CAST_START" and (MC_SPELLS[spellId] or (spellName and spellName:lower():find("domin",1,true))) then SendBanda(ICON_MC.." Lady controla en 3s! (0/3)") return end
    if subEvent=="SPELL
