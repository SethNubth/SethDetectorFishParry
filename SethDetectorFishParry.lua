-- SethDetectorFishParry v1.9 | Lady sin biberón - By Seth
local ADDON = "SethDetectorFishParry"
local frame = CreateFrame("Frame")
local fishCount, petOwner, mindControlled, lastDamager = {}, {}, {}, {}
local MC_SPELLS = {[71289]=true,[71290]=true,[72027]=true,[72028]=true,[73020]=true}

local function SendAviso(msg)
    if IsInRaid() then
        if IsRaidLeader() or IsRaidOfficer() then
            local ok = pcall(SendChatMessage, msg, "RAID_WARNING")
            if not ok then pcall(SendChatMessage, msg, "RAID") end
        else pcall(SendChatMessage, msg, "RAID") end
    else print(msg) end
end

local function GetOwner(petName, petGUID)
    if petName then local o = petName:match("<(.+)>") if o then return o end end
    if petGUID and petOwner[petGUID] then return petOwner[petGUID] end
    return nil
end

frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then print("|cFF00FF00Seth v1.9|r - Lady sin biberon ON") return end
    if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end
    local _, subEvent, _, sourceGUID, sourceName, _, destGUID, destName, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()
    if not subEvent then return end
    local _,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,amount = CombatLogGetCurrentEventInfo()

    if subEvent == "SPELL_SUMMON" and destGUID then petOwner[destGUID] = sourceName end

    if (subEvent == "SPELL_DAMAGE" or subEvent == "SWING_DAMAGE" or subEvent == "RANGE_DAMAGE" or subEvent == "SPELL_PERIODIC_DAMAGE") and destGUID:find("Player") then
        lastDamager[destGUID] = {clean = GetOwner(sourceName, sourceGUID) or sourceName, spell = spellName or "Melee", amount = amount or 0}
    end

    -- Pre-aviso 3s
    if subEvent == "SPELL_CAST_START" then
        local isMC = MC_SPELLS[spellId] or (spellName and spellName:lower():find("domin"))
        if isMC then SendAviso("¡ATENCION! Lady controla en 3s! (0/3)") end
    end

    -- MC entra
    if subEvent == "SPELL_AURA_APPLIED" then
        local isMC = MC_SPELLS[spellId] or (spellName and (spellName:lower():find("domin") or spellName:find("Mente Dominada")))
        if isMC and destGUID:find("Player") then
            mindControlled[destGUID] = true
            local c = 0 for _ in pairs(mindControlled) do c = c + 1 end
            SendAviso("MC: "..destName.." ("..c.."/3)")
        end
    end

    -- MC sale
    if subEvent == "SPELL_AURA_REMOVED" and mindControlled[destGUID] then
        mindControlled[destGUID] = nil
        lastDamager[destGUID] = nil
        local c = 0 for _ in pairs(mindControlled) do c = c + 1 end
        if c > 0 then SendAviso("CC en proceso! ("..c.."/3)") else SendAviso("CC OK - DPS Lady") end
    end

    -- MC muere = FAIL con daño
    if subEvent == "UNIT_DIED" and mindControlled[destGUID] then
        local k = lastDamager[destGUID]
        if k then
            local dmg = k.amount >= 1000 and string.format(" %.1fk", k.amount/1000) or (k.amount > 0 and " "..k.amount or "")
            SendAviso("MC FAIL: "..k.clean.." MATO a "..destName.."! "..k.spell..dmg.."!")
        else
            SendAviso("MC FAIL: "..destName.." MURIO!")
        end
        mindControlled[destGUID] = nil
    end
end)

SLASH_SDF1 = "/sdf"
SlashCmdList["SDF"] = function(m) if m=="testmc" then SendAviso("¡ATENCION! Lady controla en 3s! (0/3)") SendAviso("MC: Pepito (1/3)") SendAviso("MC FAIL: WarX MATO a Pepito! Torbellino 12.3k!") end
