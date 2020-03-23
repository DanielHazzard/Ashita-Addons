_addon.name = "AutoBurst"
_addon.author = "Daniel_H"
_addon.version = "1.2 Ashita"
_addon_description = ""
require "common"
require "timer"
require "ffxi.recast"

-- CUSTOM VARIABLES
EnableBursting = false
isCasting = false
zoning_bool = false

SkillchainID = {
  [288] = "Light",
  [289] = "Darkness",
  [387] = "Gravitation",
  [388] = "Fragmentation",
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
  [767] = "Radiance",
  [770] = "Umbra",
  [386] = "Darkness",
  [385] = "Light",
  [290] = "Gravitation",
  [291] = "Fragmentation",
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
  [769] = "Radiance",
  [768] = "Umbra"
}

-- Load CONFIGURATION file
require("AutoBurst_config")

party = AshitaCore:GetDataManager():GetParty()
player = AshitaCore:GetDataManager():GetPlayer()
activeBuffs = AshitaCore:GetDataManager():GetPlayer():GetBuffs()
entity = AshitaCore:GetDataManager():GetEntity()
target = AshitaCore:GetDataManager():GetTarget()

resource = AshitaCore:GetResourceManager()

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

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function SpellRecast(x) -- x = STRING NAME OF THE SPELL
  SpellData = AshitaCore:GetResourceManager():GetSpellByName(x, 0)
  DebugMessage("Current recast: " .. ashita.ffxi.recast.get_spell_recast_by_index(SpellData.Index))
  return ashita.ffxi.recast.get_spell_recast_by_index(SpellData.Index)
end

function AbilityRecasts(x)
  AbilityData = AshitaCore:GetResourceManager():GetAbilityByName(x, 0)
  DebugMessage("Current ability recast: " .. AbilityData.RecastDelay)
  return AbilityData.RecastDelay
end

function HasSpell(x)
  DebugMessage("Checking if you have the spell. " .. x .. " " .. AshitaCore:GetDataManager():GetPlayer():HasSpell(x))
  return AshitaCore:GetDataManager():GetPlayer():HasSpell(x)
end

function HasAbility(x)
  DebugMessage(
  "Checking if you have the ability. " .. x .. " " .. AshitaCore:GetDataManager():GetPlayer():HasAbility(x)
  )
  return AshitaCore:GetDataManager():GetPlayer():HasAbility(x)
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
  SpellData = AshitaCore:GetResourceManager():GetSpellByName(spell_name, 0)
  JobID = player:GetMainJob()
  DebugMessage("Checking data on the spell: " .. spell_name)
  ThreeLetterJob = JobIDs[JobID]
  if SpellData.LevelRequired[JobID] ~= nil then
    DebugMessage("Level required: " .. SpellData.LevelRequired[JobID])
    if (SpellData.LevelRequired[JobID] ~= -1) and (SpellData.LevelRequired[JobID] >= 100) then
      if SpellData.LevelRequired[JobID] == 100 and JobPoints_SPENT[ThreeLetterJob] >= 100 then
        return true
      elseif SpellData.LevelRequired[JobID] == 550 and JobPoints_SPENT[ThreeLetterJob] >= 550 then
        return true
      elseif SpellData.LevelRequired[JobID] == 1200 and JobPoints_SPENT[ThreeLetterJob] >= 1200 then
        return true
      else
        return false
      end
    elseif SpellData.LevelRequired[JobID] ~= -1 and SpellData.LevelRequired[JobID] <= player:GetMainJobLevel() then
      return true
    elseif SpellData.LevelRequired[JobID] ~= -1 and SpellData.LevelRequired[JobID] <= player:GetSubJobLevel() then
      return true
    end
    return false
  end
  return false
end

function CanUseAbility(ability_name)
  return false
end

function ComparePartyID(partyIndex)
  return true
end

function CheckIfBurstingAllowed()
  JobShorthand = JobIDs[player:GetMainJob()]
  if table.contains(BurstJobs, JobShorthand) then
    if CheckIfPlayerDisabled() == false then
      return true
    else
      return false
    end
  end
  return false
end

function AssistPlayer(player_name)
  QueueCmd("/assist " .. player_name)

  ashita.timer.once(2 + ExtendedDelay, RunBurst_Part2, prop)
end

function RunAssistCmd(prop)
  Assisted_Name = "" -- SET NAME TO BLANK FIRST TO BLOCK ANY POSSIBLE CROSS OVER
  AssistName = string.lower(AssistedPlayer)

  if AssistName ~= "" and AssistName ~= "none" and AssistName ~= "party" then
    DebugMessage("Specified target is set: " .. AssistedPlayer .. ", attempting /assist.")

    -- ASSIST TARGET IS SET AS SOMETHING OTHER THAN BLANK, NONE OR PARTY SO GRAB THE ENTITY DATA
    for index = 0, 4096, 1 do
      if entity:GetName(index) == AssistedPlayer then
        Assisted_Name = entity:GetName(index)
        DebugMessage("Located target: " .. entity:GetName(index))
        break
      end
    end
  else
    DebugMessage("Specified target is not set running party check.")
    for i = 0, 17 do
      AssistedIndex = AshitaCore:GetDataManager():GetParty():GetMemberTargetIndex(i)
      if entity:GetStatus(AssistedIndex) == 1 then
        Assisted_Name = entity:GetName(index)
        DebugMessage("Located target: " .. entity:GetName(index))
        break
      end
    end
  end

  if Assisted_Name ~= "" then
    AssistPlayer(Assisted_Name)
  end
end

function RunBurst(prop)
  DebugMessage("Skillchain located: " .. SkillchainID[prop])
  if CheckIfBurstingAllowed() == true and not isCasting == true then -- IF PLAYER IS ONE OF THE CORRECT JOBS THEN ENABLE BURSTING.
    DebugMessage("Burst possible.")
    -- ASSIST THE SPECIFIED TARGET OR SEARCH THE PARTY TO GRAB THE TARGET
    RunAssistCmd(prop)
  end
end

function RunBurst_Part2(prop)
  Chain = SkillchainID[prop]
  completed_Spell = ""
  if target:GetTargetName() ~= nil then
    locatedTarget = target:GetTargetName()
    DebugMessage("Current Target: " .. locatedTarget)
    -- Darkness / Darkness / Umbra / Umbra / Compression / Compression / Gravitation / Gravitation
    if
    (Chain == "darkness" or Chain == "umbra" or Chain == "compression" or Chain == "gravitation") and
    BuffActive(1) ~= true and
    table.contains(KnownMP_monsters, target:GetTargetName()) and
    party:GetPartyMemberMP(0) <= Aspir_MPAmount
    then
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
      prop = SkillchainID[ashita.bits.unpack_be(data, 299, 10)]
      if prop then
        RunBurst(prop)
      end
    elseif category == 4 and IsPartyMember(actor) then -- SPELL TARGET 1, ACTION 1, ADDED EFFECT MESSAGE ( PACKET 150+32+44 ) LOOKING FOR 291
      AddedEffect = ashita.bits.unpack_be(data, 271, 1)
      -- EITHER: 0 = FALSE, 1 = TRUE
      if AddedEffect == 1 then
        prop = ashita.bits.unpack_be(data, 299, 10)
        if SkillchainID[prop] then
          RunBurst(prop)
        end
      end
    elseif (category == 13 or category == 11) and IsPetPartyMember(actor) then -- PET
      AddedEffect = ashita.bits.unpack_be(data, 271, 1)
      -- EITHER: 0 = FALSE, 1 = TRUE
      if AddedEffect == 1 then
        prop = ashita.bits.unpack_be(data, 299, 10)
        if SkillchainID[prop] then
          RunBurst(prop)
        end
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

function DebugMessage(message)
  if DebugMode then
    print("\31\200[\31\05AutoBurst\31\200]\31\207 " .. message)
  end
end

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
