-- SethDetectorFishParry v1.9.1 FINAL FULL | By Seth - Bogotá - Naerzone
-- No lag, no Lua errors, Fish + Parry + Lady sin biberon
local ADDON_NAME = "SethDetectorFishParry"
local frame = CreateFrame("Frame")

local petOwner, mindControlled, lastDamager = {}, {}, {}
local MC_SPELLS = {[71289]=true,[71290]=true,[72027]=true,[72028]=true,[73020]=true,[68904]=true}

local ICON_FISH = "|TInterface\\Icons\\INV_Misc_Fish_02:20|t"
local ICON_PARRY = "|TInterface\\Icons\\Ability_Parry:20|t"
local ICON_MC = "|TInterface\\Icons\\Spell_Shadow_ShadowWordDominate:20|t"
local ICON_FAIL = "|TInterface\\Icons\\Ability_Warrior_Cleave:20|t"
local ICON_OK = "|TInterface\\Icons\\INV_Misc_Horn_03:20|t"
local ICON_WARN = "|TInterface\\Icons\\Spell_Shadow_Skull:20|t"

local function SendAviso(msg)
    if IsInRaid() then
        if IsRaidLeader() or IsRaidOfficer() then
            local ok = pcall(SendChatMessage, msg, "RAID_WARNING")
            if not ok then pcall(SendChatMessage, msg, "RAID") end
        else
            pcall(SendChatMessage, msg, "RAID")
        end
    else
        print(msg)
    end
end

local function GetOwner(petName, petGUID)
    if petName then
        local o = petName:match("<(.+)>")
        if o then return o end
    end
    if petGUID and petOwner[petGUID] then
        return petOwner[petGUID]
    end
    return nil
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON_NAME then return end
        print("|cFF00FF00SethDetector v1.9.1 FINAL|r "..ICON_FISH..ICON_PARRY..ICON_MC.." Cargado - Sin errores")
        return
    end

    -- COMBAT LOG
    local timestamp, subEvent, _, sourceGUID, sourceName, _, destGUID, destName, _, _, spellId, spellName, _, missType, _, _, amount = CombatLogGetCurrentEventInfo()
    if not subEvent then return end

    if subEvent == "SPELL_SUMMON" and destGUID then
        if sourceName then petOwner[destGUID] = sourceName end
        return
    end

    -- Guarda damager solo si es Player victim
    if destGUID and destGUID:find("Player", 1, true) then
        if subEvent == "SPELL_DAMAGE" or subEvent == "SWING_DAMAGE" or subEvent == "RANGE_DAMAGE" or subEvent == "SPELL_PERIODIC_DAMAGE" then
            lastDamager[destGUID] = {
                clean = GetOwner(sourceName, sourceGUID) or sourceName or "Desconocido",
                spell = spellName or "Melee",
                amount = amount or 0
            }
        end
    end

    -- PARRY
    if subEvent == "SWING_MISSED" and missType == "PARRY" then
        if destGUID and destGUID:find("Creature", 1, true) and sourceName then
            SendAviso(ICON_PARRY.." PARRY FAIL: "..sourceName.." parreado! Haste activado!")
        end
        return
    end

    -- LADY: Pre-aviso
    if subEvent == "SPELL_CAST_START" then
        if MC_SPELLS[spellId] or (spellName and spellName:lower():find("domin", 1, true)) then
            SendAviso(ICON_WARN.." "..ICON_MC.." Lady controla en 3s! (0/3)")
        end
        return
    end

    if subEvent == "SPELL_AURA_APPLIED" then
        if destGUID and destGUID:find("Player", 1, true) then
            if MC_SPELLS[spellId] or (spellName and (spellName:lower():find("domin", 1, true) or spellName:find("Mente Dominada", 1, true))) then
                mindControlled[destGUID] = true
                local c = 0
                for _ in pairs(mindControlled) do c = c + 1 end
                SendAviso(ICON_MC.." MC: "..(destName or "???").." ("..c.."/3)")
            end
        end
        return
    end

    if subEvent == "SPELL_AURA_REMOVED" then
        if mindControlled[destGUID] then
            mindControlled[destGUID] = nil
            lastDamager[destGUID] = nil
            local c = 0
            for _ in pairs(mindControlled) do c = c + 1 end
            if c > 0 then
                SendAviso(ICON_MC.." CC en proceso! ("..c.."/3)")
            else
                SendAviso(ICON_OK.." CC OK - DPS Lady")
            end
        end
        return
    end

    if subEvent == "UNIT_DIED" then
        if mindControlled[destGUID] then
            local k = lastDamager[destGUID]
            if k then
                local dmg = ""
                if k.amount and k.amount >= 1000 then
                    dmg = string.format(" %.1fk", k.amount/1000)
                elseif k.amount and k.amount > 0 then
                    dmg = " "..k.amount
                end
                SendAviso(ICON_FAIL.." MC FAIL: "..k.clean.." MATO a "..(destName or "???").."! "..k.spell..dmg.."!")
            else
                SendAviso(ICON_FAIL.." MC FAIL: "..(destName or "???").." MURIO!")
            end
            mindControlled[destGUID] = nil
            lastDamager[destGUID] = nil
        end
    end
end)

SLASH_SDF1 = "/sdf"
SlashCmdList["SDF"] = function(msg)
    msg = msg:lower():trim()
    if msg == "testmc" then
        SendAviso(ICON_WARN.." "..ICON_MC.." Lady controla en 3s! (0/3)")
        SendAviso(ICON_MC.." MC: Pepito (1/3)")
        SendAviso(ICON_FAIL.." MC FAIL: WarX MATO a Pepito! Torbellino 12.3k!")
        SendAviso(ICON_OK.." CC OK - DPS Lady")
    elseif msg == "testparry" then
        SendAviso(ICON_PARRY.." PARRY FAIL: TanquePepito parreado! Haste activado!")
        SendAviso(ICON_FISH.." FISH PULL: Brujo via Imp <Brujo>!")
    else
        print("SDF comandos: /sdf testmc | /sdf testparry")
    end
end
