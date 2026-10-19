-- SethDetectorFishParry v1.8 FINAL | Solo MC + FAIL con daño
local ADDON = "SethDetectorFishParry"
local frame = CreateFrame("Frame")
local SPELL_FISH_CLICK = 57397

local fishCount = {}
local petOwner = {}
local mindControlled = {}
local lastDamager = {}

local MC_SPELLS = {[71289]=true,[71290]=true,[72027]=true,[72028]=true,[73020]=true}

local function SendAviso(msg)
    if not msg then return end
    if IsInRaid() then
        if IsRaidLeader() or IsRaidOfficer() then
            local ok = pcall(SendChatMessage, msg, "RAID_WARNING")
            if not ok then pcall(SendChatMessage, msg, "RAID") end
        else pcall(SendChatMessage, msg, "RAID") end
    else print(msg) end
end

local function GetOwner(petName, petGUID)
    if petName then local o = string.match(petName, "<(.+)>") if o then return o end end
    if petGUID and petOwner[petGUID] then return petOwner[petGUID] end
    return nil
end

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then print("|cFF00FF00Seth v1.8 FINAL|r - MC + FAIL daño ON") return end
    if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end
    local _, subEvent, _, sourceGUID, sourceName, _, destGUID, destName, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()
    if not subEvent then return end
    local _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,amount = CombatLogGetCurrentEventInfo()

    if subEvent == "SPELL_SUMMON" and sourceName and destGUID then petOwner[destGUID] = sourceName end

    if (subEvent == "SPELL_DAMAGE" or subEvent == "SWING_DAMAGE" or subEvent == "RANGE_DAMAGE" or subEvent == "SPELL_PERIODIC_DAMAGE") and string.find(destGUID or "", "Player") then
        lastDamager[destGUID] = {
            clean = GetOwner(sourceName, sourceGUID) or sourceName,
            spell = spellName or "Melee",
            amount = amount or 0
        }
    end

    if subEvent == "SPELL_CAST_SUCCESS" and spellId == SPELL_FISH_CLICK then
        fishCount[sourceName] = (fishCount[sourceName] or 0) + 1
        if fishCount[sourceName] > 4 then SendAviso("FESTIN: "..sourceName.." x"..fishCount[sourceName]) end
    end

    if subEvent == "SPELL_AURA_APPLIED" then
        local isMC = MC_SPELLS[spellId] or (spellName and (string.find(string.lower(spellName), "domin") or string.find(spellName, "Mente Dominada")))
        if isMC and string.find(destGUID or "", "Player") then
            mindControlled[destGUID] = {name = destName}
            SendAviso("MC: "..destName.."! -> POLY/FEAR/CICLON/STUN - NO MATAR!")
        end
    end

    if subEvent == "SPELL_AURA_REMOVED" then
        local isMC = MC_SPELLS[spellId] or (spellName and (string.find(string.lower(spellName), "domin") or string.find(spellName, "Mente Dominada")))
        if isMC and mindControlled[destGUID] then mindControlled[destGUID] = nil lastDamager[destGUID] = nil end
    end

    if subEvent == "UNIT_DIED" and mindControlled[destGUID] then
        local k = lastDamager[destGUID]
        if k then
            local dmgText = ""
            if k.amount > 0 then
                if k.amount >= 1000 then dmgText = string.format(" %.1fk", k.amount/1000)
                else dmgText = " "..k.amount end
            end
            SendAviso("MC FAIL: "..k.clean.." MATO a "..destName.."! "..k.spell..dmgText.."!")
        else
            SendAviso("MC FAIL: "..destName.." MURIO con MC!")
        end
        mindControlled[destGUID] = nil
    end
end)

SLASH_SDF1 = "/sdf"
SlashCmdList["SDF"] = function(msg)
    if msg == "testmc" then
        SendAviso("MC: Pepito! -> POLY/FEAR/CICLON/STUN - NO MATAR!")
        SendAviso("MC FAIL: XxWarxX MATO a Pepito! Torbellino 12.3k!")
    else print("/sdf testmc") end
end
