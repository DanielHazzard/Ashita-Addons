_addon.name = "AutoBurst"
_addon.author = "Daniel_H"
_addon.version = "1.2 Ashita"
_addon_description = ""

require "common"
require "timer"
require "ffxi.recast"

-- CUSTOM VARIABLES
isCasting = false
zoning_bool = false

SkillchainID = {
  [288] = "Light",
  [289] = "Darkness",
  [290] = "Gravitation",
  [291] = "Fragmentation",
  [292] = "Distortion",
  [293] = "Fusion",
  [294] = "Compression",
  [295] = "Liquefaction",
  [296] = "Induration",
  [297] = "Reverberation",
  [298] = "Transfixion",
  [299] = "Scission",
  [300] = "Detonation",
  [301] = "Impaction",
  [385] = "Light",
  [386] = "Darkness",
  [387] = "Gravitation",
  [388] = "Fragmentation",
  [389] = "Distortion",
  [390] = "Fusion",
  [391] = "Compression",
  [392] = "Liquefaction",
  [393] = "Induration",
  [394] = "Reverberation",
  [395] = "Transfixion",
  [396] = "Scission",
  [397] = "Detonation",
  [398] = "Impaction",
  [767] = "Radiance",
  [768] = "Umbra",
  [769] = "Radiance",
  [770] = "Umbra"
}

-- Load CONFIGURATION file
require("AutoBurst_config")

party = AshitaCore:GetDataManager():GetParty()
player = AshitaCore:GetDataManager():GetPlayer()
activeBuffs = AshitaCore:GetDataManager():GetPlayer():GetBuffs()
entity = AshitaCore:GetDataManager():GetEntity()
target = AshitaCore:GetDataManager():GetTarget()
resources = AshitaCore:GetResourceManager()
items = AshitaCore:GetDataManager():GetInventory()

JobIDs = {
  [0] = "NON",
  [1] = "WAR",
  [2] = "MNK",
  [3] = "WHM",
  [4] = "BLM",
  [5] = "RDM",
  [6] = "THF",
  [7] = "PLD",
  [8] = "DRK",
  [9] = "BST",
  [10] = "BRD",
  [11] = "RNG",
  [12] = "SAM",
  [13] = "NIN",
  [14] = "DRG",
  [15] = "SMN",
  [16] = "BLU",
  [17] = "COR",
  [18] = "PUP",
  [19] = "DNC",
  [20] = "SCH",
  [21] = "GEO",
  [22] = "RUN",
  [23] = "MON"
}

function DebugMessage(message)
  if DebugMode then
    print("\31\200[\31\05AutoBurst\31\200]\31\207 " .. message)
  end
end

DebugMessage("Debug mode enabled.")

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function SpellRecast(x) -- x = STRING NAME OF THE SPELL
  SpellData = resources:GetSpellByName(x, 0)
  DebugMessage("Current recast: " .. ashita.ffxi.recast.get_spell_recast_by_index(SpellData.Index))
  return ashita.ffxi.recast.get_spell_recast_by_index(SpellData.Index)
end

function AbilityRecasts(x)
  AbilityData = resources:GetAbilityByName(x, 0)
  DebugMessage("Current ability recast: " .. AbilityData.RecastDelay)
  return AbilityData.RecastDelay
end

function BuffActive(BuffID)
  for i = 0, 32 do
    if activeBuffs[i] == BuffID then
      return true
    else
      return false
    end
  end
end

function CheckIfPlayerDisabled()
  if BuffActive(0) == true then -- KO
    return true
  elseif BuffActive(2) == true then -- SLEEP
    return true
  elseif BuffActive(6) == true then -- SILENCE
    return true
  elseif BuffActive(7) == true then -- PETRIFICATION
    return true
  elseif BuffActive(10) == true then -- STUN
    return true
  elseif BuffActive(14) == true then -- CHARM
    return true
  elseif BuffActive(28) == true then -- TERRORIZE
    return true
  elseif BuffActive(29) == true then -- MUTE
    return true
  elseif BuffActive(193) == true then -- LULLABY
    return true
  elseif BuffActive(262) == true then -- OMERTA
    return true
  end
  return false
end

function CanUseSpell(spell_name)
  SpellData = resources:GetSpellByName(spell_name, 0)
  JobID = player:GetMainJob()
  DebugMessage("Checking data on the spell: " .. spell_name .. " Current MP: " .. party:GetMemberCurrentMP(0))
  ThreeLetterJob = JobIDs[JobID]
  if party:GetMemberCurrentMP(0) > SpellData.ManaCost then
    DebugMessage("MP check has passed for the spell, " .. spell_name)
    if SpellData.LevelRequired[JobID] ~= nil then
      DebugMessage("Level required for the JOB: " .. ThreeLetterJob .. " " .. spell_name .. " " .. SpellData.LevelRequired[JobID])
      if (SpellData.LevelRequired[JobID] ~= -1) and (SpellData.LevelRequired[JobID] >= 100) then
        DebugMessage("Job Point spell check, " .. spell_name)
        if SpellData.LevelRequired[JobID] == 100 and JobPoints_SPENT[ThreeLetterJob] >= 100 then
          DebugMessage("Job Point spell check, PASSED " .. spell_name)
          return true
        elseif SpellData.LevelRequired[JobID] == 550 and JobPoints_SPENT[ThreeLetterJob] >= 550 then
          DebugMessage("Job Point spell check, PASSED " .. spell_name)
          return true
        elseif SpellData.LevelRequired[JobID] == 1200 and JobPoints_SPENT[ThreeLetterJob] >= 1200 then
          DebugMessage("Job Point spell check, PASSED " .. spell_name)
          return true
        else
          DebugMessage("Job Point spell check, FAILED " .. spell_name)
          return false
        end
      elseif SpellData.LevelRequired[JobID] ~= -1 and SpellData.LevelRequired[JobID] <= player:GetMainJobLevel() then
        DebugMessage("MAIN JOB check passed, " .. spell_name)
        return true
      elseif SpellData.LevelRequired[JobID] ~= -1 and SpellData.LevelRequired[JobID] <= player:GetSubJobLevel() then
        DebugMessage("SUB JOB check passed, " .. spell_name)
        return true
      end
      DebugMessage("Spell check #1, FAILED " .. spell_name)
      return false
    end
    DebugMessage("Spell check #2, FAILED " .. spell_name)
    return false
  else
    DebugMessage("MP check has failed for the spell, " .. spell_name)
    return false
  end
end

function CanUseAbility(ability_name)
  return false
end

function CheckIfBurstingAllowed()
  JobShorthand = JobIDs[player:GetMainJob()]
  if table.contains(BurstJobs, JobShorthand) then
    if CheckIfPlayerDisabled() == false then
      return true
    else
      DebugMessage("Burst control is blocked due to a status ailment.")
      return false
    end
  end
  return false
end

function ItemCheck(items_ID)
  for ind = 1, items:GetContainerMax(0) do
    local item = items:GetItem(0, ind)
    if (item ~= nil and item.Id == items_ID and item.Count > 0) then
      return true
    end
  end
  return false
end

function RunAssistCmd(prop, TargetID)
  DebugMessage("Setting target: " .. TargetID)
  AshitaCore:GetChatManager():QueueCommand("/target " .. TargetID, 0)
  ashita.timer.once(2 + ExtendedDelay, RunBurst_Part2, prop, TargetID)
end

function RunBurst(prop, TargetID)
  DebugMessage("Skillchain located: " .. SkillchainID[prop])
  if CheckIfBurstingAllowed() == true and not isCasting == true then -- IF PLAYER IS ONE OF THE CORRECT JOBS THEN ENABLE BURSTING.
    DebugMessage("Burst possible.")
    RunAssistCmd(prop, TargetID)
  end
end

function RunBurst_Part2(prop, TargetID)
  Chain = SkillchainID[prop]
  completed_Spell = ""
  if target:GetTargetName() ~= nil and target:GetTargetHealthPercent() >= 1 then
    locatedTarget = target:GetTargetName()
    DebugMessage("Current Target: " .. locatedTarget)
    -- Darkness / Darkness / Umbra / Umbra / Compression / Compression / Gravitation / Gravitation
    if Chain == "Darkness" or Chain == "Umbra" or Chain == "Compression" or Chain == "Gravitation" and BuffActive(1) ~= true and table.contains(KnownMP_monsters, target:GetTargetName()) and party:GetPartyMemberMP(0) <= Aspir_MPAmount then
      print("\31\200\31\05Low MP Notice: \31\200\31\207 Attempting to recover MP with Aspir.")
      if CanUseSpell("Aspir III") and SpellRecast("Aspir III") == 0 then
        completed_Spell = "Aspir III"
      elseif CanUseSpell("Aspir II") and SpellRecast("Aspir II") == 0 then
        completed_Spell = "Aspir II"
      elseif CanUseSpell("Aspir") and SpellRecast("Aspir") == 0 then
        completed_Spell = "Aspir"
      end
    else
      -- SINCE ASPIR IS NOT NEEDED OR NOT POSSIBLE ON THE SET ENEMY CONTINUE ONTO THE BURST ACTION
      for i, v in ipairs(TierOrder) do
        if v == "I" then
          generatedSpell = BurstMagic[Chain]
        else
          generatedSpell = BurstMagic[Chain] .. " " .. v
        end
        DebugMessage("Checking spell, " .. generatedSpell)
        if CanUseSpell(generatedSpell) == true and SpellRecast(generatedSpell) == 0 then
          DebugMessage("Spell can be used. " .. generatedSpell)
          completed_Spell = generatedSpell
          break
        end
      end
    end
    if completed_Spell ~= "" then
      generatedString = '/ma "' .. completed_Spell .. '" <t>'
      DebugMessage("Attempting cast: (" .. generatedString .. ")")
      QueueCmd(generatedString)
    end
  end
  return false
end

function QueueCmd(Command)
  AshitaCore:GetChatManager():QueueCommand(Command, 0)
end

function IsPetPartyMember(index)
  for i = 0, 16 do
    if party:GetMemberName(i) ~= nil then
      indx2 = party:GetMemberTargetIndex(i)
      if entity:GetPetTargetIndex(indx2) ~= nil then
        if entity:GetServerId(entity:GetPetTargetIndex(indx2)) == index then
          return true
        end
      end
    end
  end
  return false
end

function IsPartyMember(index)
  for i = 0, 16 do
    if party:GetMemberName(i) ~= nil and party:GetMemberServerId(i) == index then
      return true
    end
  end
  return false
end

function RunPacketAction(id, size, data)
  if (id == 0xB) then
    DebugMessage("Currently zoning.")
    zoning_bool = true
  elseif (id == 0xA and zoning_bool) then
    DebugMessage("No longer zoning.")
    zoning_bool = false
  end
  if not zoning_bool and id == 0x28 then
    actor = struct.unpack("I", data, 6)
    category = ashita.bits.unpack_be(data, 82, 4)
    if category == 3 and IsPartyMember(actor) then -- WEAPONSKILL
      DebugMessage("Weaponskill located.")
      AddedEffect = ashita.bits.unpack_be(data, 271, 1)
      if AddedEffect == 1 then
        prop = ashita.bits.unpack_be(data, 299, 10)
        DebugMessage("A prop was located, " .. prop)
        TargetID = ashita.bits.unpack_be(data, 150, 32)
        RunBurst(prop, TargetID)
      end
    elseif category == 4 and IsPartyMember(actor) then -- SPELL TARGET 1, ACTION 1, ADDED EFFECT MESSAGE ( PACKET 150+32+44 ) LOOKING FOR 291
      AddedEffect = ashita.bits.unpack_be(data, 271, 1)
      -- EITHER: 0 = FALSE, 1 = TRUE
      if AddedEffect == 1 then
        prop = ashita.bits.unpack_be(data, 299, 10)
        DebugMessage("A prop was located, " .. prop)
        TargetID = ashita.bits.unpack_be(data, 150, 32)
        RunBurst(prop, TargetID)
      end
    elseif (category == 13 or category == 11) and IsPetPartyMember(actor) then -- PET
      AddedEffect = ashita.bits.unpack_be(data, 271, 1)
      -- EITHER: 0 = FALSE, 1 = TRUE
      if AddedEffect == 1 then
        prop = ashita.bits.unpack_be(data, 299, 10)
        DebugMessage("A prop was located, " .. prop)
        TargetID = ashita.bits.unpack_be(data, 150, 32)
        RunBurst(prop, TargetID)
      end
    end
  end
end

function EntityName(target_id)
end

ashita.register_event(
  "incoming_packet",
  function(id, size, data)
    RunPacketAction(id, size, data)
    return false
  end
)

ashita.register_event(
  "mpmax_change",
  function(old, new)
    if Aspir_NoBurst == true and party:GetPartyMemberMP(0) <= Aspir_MPAmount and BuffActive(1) ~= true then
      RunAssistCmd()
      -- CANCEL THE RUN BURST ID SKILLCHAIN IS SOMEHOW EMPTY
      if target:GetTargetName() ~= nil and table.contains(KnownMP_monsters, target:GetTargetName()) then
        if CanUseSpell("Aspir III") and SpellRecast("Aspir III") == true then
          completed_Spell = "Aspir III"
        elseif CanUseSpell("Aspir II") and SpellRecast("Aspir II") == true then
          completed_Spell = "Aspir II"
        elseif CanUseSpell("Aspir") and SpellRecast("Aspir") == true then
          completed_Spell = "Aspir"
        end
        if completed_Spell ~= "" then
          generatedString = '/ma "' .. completed_Spell .. '" <t>'
          DebugMessage("Attempting cast: (" .. generatedString .. ")")
          ashita.timer.once(2 + ExtendedDelay, QueueCmd, generatedString)
        end
      end
    end
  end
)

ashita.register_event(
  "gain_buff",
  function(buff_ID)
    if BuffActive(6) and AttemptSilenceRemoval == true then
      if UseEchoDrops == true and ItemCheck(4151) > 0 then
        QueueCmd('/item "Echo Drops" <me>')
      elseif UseCatholicon == true and ItemCheck(4206) > 0 then
        QueueCmd('/item "Catholicon" <me>')
      elseif UseVicarsDrink == true and ItemCheck(5439) > 0 then
        QueueCmd('/item "Vicar\'s Drink" <me>')
      elseif UseRemedyOintment == true and ItemCheck(5326) > 0 then
        QueueCmd('/item "Remedy Ointment" <me>')
      elseif UseRemedy == true and ItemCheck(4155) > 0 then
        QueueCmd('/item "Remedy" <me>')
      end
    end
  end
)
