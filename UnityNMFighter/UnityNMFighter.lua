--[[
Copyright © 2018, Daniel_H
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of UnityNMFighter nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Daniel_H BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]--

_addon.name = 'UnityNMFighter'
_addon.author = 'Daniel_H'
_addon.version = '1.0'
_addon.language = 'english'

variables = {}

AshitaCore:GetChatManager():QueueCommand('/bind !^R /release keys', 1)

-- -------------------------------------------------------------------------------------------------------------------------- --
-- USER CONFIGURATION ------------------------------------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------------------------------------------------------- --

-- 0 = None, 1 = Ring, 2 = Scroll, 3 = Spell
variables.WarpMethod = 0

-- The weaponskill to use, Example: Chant du Cygne
variables.weaponskill = 'None'

-- 1 = Attack, 2 = Pet Fight
variables.EngageType = 1 

-- boolean, true or false
variables.useCoffers = false

-- Pets name, example Ifrit
variables.Pet = 'None' 

-- Example: Flaming Crush or Tegmina Buffet
variables.PetWeaponskill = 'None' 

-- 0 = Melee, 1 = SMN
variables.modeActive = 0 

-- true or false, used for additional mules
variables.assistMode = false

-- If you use ENTERNITY set this to true
variables.EnternityActive = false

-- Shut Down game when capped. Replaces all other close actions
variables.ShutDownOnCap = false 

-- -------------------------------------------------------------------------------------------------------------------------- --
-- DON'T EDIT BELOW THIS LINE ----------------------------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------------------------------------------------------- --

variables.isRunning = false 
variables.fightActive = false 
variables.cofferName = 'None' 
variables.cofferCount = 0

require('UnityNM_tables')


-- /addon load unitynmfighter

-- All Ashita requirements needed
require 'common'
require 'timer'
require 'ffxi.targets'

-- Queue command functions.
function escapeOpen()
    AshitaCore:GetChatManager():QueueCommand('/sendkey ESCAPE down', -1)
end
function escapeClose()
    AshitaCore:GetChatManager():QueueCommand('/sendkey ESCAPE up', -1)
end
function targetNPC()
    return AshitaCore:GetChatManager():QueueCommand('/targetnpc', -1)
end
function pressTabOpen()
    AshitaCore:GetChatManager():QueueCommand('/sendkey TAB down', -1)
end
function pressTabClose()
    AshitaCore:GetChatManager():QueueCommand('/sendkey TAB up', -1)
end
function openEnter()
    AshitaCore:GetChatManager():QueueCommand('/sendkey RETURN down', -1)
end
function closeEnter()
    AshitaCore:GetChatManager():QueueCommand('/sendkey RETURN up', -1)
end
function advanceUpOpen()
    AshitaCore:GetChatManager():QueueCommand('/sendkey UP down', -1)
end
function advanceUpClose()
    AshitaCore:GetChatManager():QueueCommand('/sendkey UP up', -1)
end
function releaseKeys()
    AshitaCore:GetChatManager():QueueCommand('/release keys', -1)
    ashita.timer.once(4, unityFighterCombat)
end
function RingUse()
    AshitaCore:GetChatManager():QueueCommand('/item "Warp Ring" <me>', -1)
end
function Attack()
    player = AshitaCore:GetDataManager():GetPlayer(); 
    party = AshitaCore:GetDataManager():GetParty(); 
    Entity = AshitaCore:GetDataManager():GetEntity(); 
    if Entity:GetStatus(party:GetMemberTargetIndex(0)) ~= 1 then
        AshitaCore:GetChatManager():QueueCommand('/attack', 0); 
    end
end

function targetBT() 
    if variables.EngageType == 1 then
        AshitaCore:GetChatManager():QueueCommand('/attack <bt>', 1) 
    elseif variables.EngageType == 2 then
        if AshitaCore:GetDataManager():GetPlayer():GetMainJob() == 15 then
            AshitaCore:GetChatManager():QueueCommand('/pet Assault <bt>', 1)
        end
    end
end

local MainJob = AshitaCore:GetDataManager():GetPlayer():GetMainJob(); 
if MainJob == 15 then
    variables.modeActive = 1
elseif MainJob == 9 then
    variables.modeActive = 2
else
    variables.modeActive = 0
end

function performActions() 
    ashita.timer.once(0.2, escapeOpen)
    ashita.timer.once(0.5, escapeClose)
    ashita.timer.once(1.0, escapeOpen)
    ashita.timer.once(1.5, escapeClose)
    ashita.timer.once(2.0, runUnityFighter)
end

function unityFighterCombat()

    if variables.isRunning == true then

        player = AshitaCore:GetDataManager():GetPlayer(); 
        party = AshitaCore:GetDataManager():GetParty(); 
        Entity = AshitaCore:GetDataManager():GetEntity(); 

        playerBuffs = player:GetBuffs()

        confrontationActive = false
        for k, v in pairs(playerBuffs) do
            if v ~= -1 and v == 276 then
                confrontationActive = true
            end
        end

        if confrontationActive ~= true then -- CONFRONTATION IS DOWN, YOU ARE NOT IN A UNITY FIGHT
            print('no confrontation')
            ashita.timer.once(10, runUnityFighter)
        elseif confrontationActive == true then -- CONFRONTATION IS ACTIVE YOU ARE IN A UNITY FIGHT
            entityName = "None"
            entityManager = AshitaCore:GetDataManager():GetEntity(); 
            for index = 0, 4096, 1 do
                if table.contains(knownNM_Names, entityManager:GetName(index)) then
                    entityName = entityManager:GetName(index)
                    entityID = entityManager:GetServerId(index)
                    variables.cofferName = knownNM_Coffers[entityName]; 
                    break
                end
            end
            if variables.modeActive == 0 then -- MELEE COMBAT
                if Entity:GetStatus(party:GetMemberTargetIndex(0)) ~= 1 and confrontationActive == true then
                    if entityName ~= "None" then
                        AshitaCore:GetChatManager():QueueCommand('/target  '..entityID, 0); 
                        ashita.timer.once(1, Attack)
                    end
                elseif Entity:GetStatus(party:GetMemberTargetIndex(0)) == 1 and confrontationActive == true then
                    target = AshitaCore:GetDataManager():GetTarget(); 
                    spellData = AshitaCore:GetResourceManager():GetAbilityByName(variables.weaponskill, 0); 
                    
                    if party:GetMemberCurrentTP(0) > 1000 and variables.weaponskill ~= "None" and target:GetTargetHealthPercent() > 1 and player:HasWeaponSkill(spellData.Id) then
                        AshitaCore:GetChatManager():QueueCommand('/ws "'..variables.weaponskill..'" <t>', 0); 
                    end
                end
            elseif variables.modeActive == 1 then -- SUMMONER COMBAT
                

            end

            ashita.timer.once(1, unityFighterCombat)

        end

    end
end

function runUnityFighter()

    entityID = 0; 
    if variables.isRunning == true and variables.assistMode == false then -- ASSIST MODE OFF

        currentTarget = AshitaCore:GetDataManager():GetTarget():GetTargetName()

        if currentTarget ~= nil and currentTarget == 'Ethereal Junction' then
            openEnter()
            ashita.timer.once(0.5, closeEnter)
            if variables.EnternityActive == true then
                ashita.timer.once(2.9, advanceUpOpen)
                ashita.timer.once(3.4, advanceUpClose)
                ashita.timer.once(4.2, openEnter)
                ashita.timer.once(4.6, closeEnter)
                ashita.timer.once(5.0, releaseKeys)
            else
                ashita.timer.once(2.0, openEnter)
                ashita.timer.once(2.5, closeEnter)
                ashita.timer.once(2.9, advanceUpOpen)
                ashita.timer.once(3.4, advanceUpClose)
                ashita.timer.once(4.2, openEnter)
                ashita.timer.once(4.6, closeEnter)
                ashita.timer.once(5.0, releaseKeys)
            end
        else 
            entityManager2 = AshitaCore:GetDataManager():GetEntity(); 
            for index = 0, 4096, 1 do
                if entityManager2:GetName(index) ~= nil and entityManager2:GetName(index):lower() == 'ethereal junction' then
                    AshitaCore:GetChatManager():QueueCommand('/target '..entityManager2:GetServerId(index), 0); 
                    break; 
                end
            end

            ashita.timer.once(1, runUnityFighter)
        end
    elseif variables.isRunning == true and variables.AssistMode == true then -- ASSIST MODE ON, IGNORE THE SPAWN STEP JUST WAIT FOR THE NEXT STEP
        ashita.timer.once(1, runUnityFighter)
    else

    end


    return false; 


end

-- If Enabled, use all coffers.
function UseCoffer ()
    
    inventory = AshitaCore:GetDataManager():GetInventory(); 
    usedinv = 0; 

    for i = 1, inventory:GetContainerMax(0) do
        item = inv:GetItem(0, i - 1); 
        if (item ~= nil and item.Id ~= 0) then
            usedinv = usedinv + 1; 
        end
    end
    count = inv:GetContainerMax(0) - usedinv; 


    if variables.useCoffers == true and count >= 2 then
        if variables.cofferCount > 0 then
            AshitaCore:GetChatManager():QueueCommand('/item "'..variables.cofferName..'" <me>', 0); 
            variables.cofferCount = variables.cofferCount - 1; 
            ashita.timer.once(3, UseCoffer)
        else
            -- Once finished, if enabled, Warp.
            if variables.WarpMethod ~= 0 then
                Warp()
            else
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'All coffers were used, not found, or your inventory was full. Finished!')
            end
        end
    end
end

-- If enabled, after you have capped sparks and (if enabled) used all coffers 
-- run the command to warp.
function Warp()
    if variables.WarpMethod == 1 then -- Ring
        AshitaCore:GetChatManager():QueueCommand('/equip ring1 "Warp Ring"', 0); 
        ashita.timer.once (11.0, RingUse)
        print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Attempting to use Warp Ring.')
    elseif variables.WarpMethod == 2 then -- Scroll
        AshitaCore:GetChatManager():QueueCommand('/item "Instant Warp" <me>', 0); 
        print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Attempting to use Instant Warp.')
    elseif variables.WarpMethod == 3 then -- Spell
        AshitaCore:GetChatManager():QueueCommand('/ma "Warp" <me>', 0); 
        print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Attempting to use Warp spell.')
    end
end

-- Run closer, use coffers and warp if enabled.
function run_Closer()

    if variables.ShutDownOnCap == true then
        AshitaCore:GetChatManager():QueueCommand('/shutdown', 1)
    else
        player = AshitaCore:GetDataManager():GetPlayer(); 
        playerBuffs = player:GetBuffs()

        confrontationActive = false
        for k, v in pairs(playerBuffs) do
            if v ~= -1 and v == 276 then
                confrontationActive = true
            end
        end

        if confrontationActive == true then
            ashita.timer.once (4, run_Closer)
        else
            if variables.useCoffers == true and variables.cofferName ~= "None" then
                inv = AshitaCore:GetDataManager():GetInventory()
                for index = 1, inv:GetContainerMax(0), 1 do
                    local item = inv:GetItem(0, index); 
                    if (item['Id'] == knownNM_CoffersID[variables.cofferName]) then
                        variables.cofferCount = variables.cofferCount + item['Count']; 
                    end
                end
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Attempting to use all '..variables.cofferName..' ('..variables.cofferCount..')')
                UseCoffer()
            elseif variables.useCoffers == false and variables.warptype ~= 0 then
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Use coffers is disabled, attempting to warp.')
                Warp()
            end
        end

    end
end

-- Custom commands 

ashita.register_event('incoming_text', function(mode, message)
    if message ~= nil then
        messageLowercase = message:lower(); 
        if messageLowercase:find('no one in your party has set the') then
            variables.isRunning = false
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'You have not set the Records of Eminence objective, cancelling.')
        elseif messageLowercase:find('unity accolades to join the fray') then
            variables.isRunning = false
            print = ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'You or a party member lack the required unity points to benefit this battle, cancelling.')
        elseif messageLowercase:find('eminence, and now possess a total of 99999') then
            variables.isRunning = false
            run_Closer()
            print = ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'You have capped your sparks. Stopping the addon and running the closing functions.')
        elseif messageLowercase:find('you have completed the following records of eminence objective: subjugation') then
            variables.isRunning = false; 
            run_Closer()
        end
    end
    return false; 
end); 

ashita.register_event('command', function(command, ntype)
    -- Get the arguments of the command..
    local args = command:args(); 
    if (args[1]:lower() ~= '/unmfighter' and args[1]:lower() ~= '/unitynmfighter' and args[1]:lower() ~= '/unmf') then
        return false; 
    else
        if (#args == 2 and args[2] == 'help') then
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'AVAILABLE OPTIONS: unmf, unmfighter, unitynmfighter')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. '     /unmfighter start - Starts running UnityNMFighter.')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. '     /unmfighter stop - Stops running UnityNMFighter.')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. '     /unmfighter enternity # - true or false')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. '     /unmfighter shutdownoncap # - When you cap sparks /shutdown (true or false)')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. '     /unmfighter weaponskill # - Sets the weaponskill to use when in combat')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. '     /unmfighter engagetype # - Sets the engage type. Options: 1 = Melee or 2 = Pet')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. '     /unmfighter warptype # - Sets the warp type. Options: 0 (None), 1 (Ring), 2 (Scroll) or 3 (Spell)')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. '     /unmfighter pet # - Sets the Pet to use. Example: Ifrit')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. '     /unmfighter usecoffers # - Use coffers before warp. (true or false).')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. '     /unmfighter petweaponskill # - Sets the pet action to use when available. Example: Flaming Crush')
        elseif (#args == 2 and args[2]:lower() == 'start' and variables.isRunning ~= true) then
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Beginning Unity NM Fighter.')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Should any keys get stuck while using UnityNMFighter, Press CTR + ALT + R')
            variables.isRunning = true; 
            performActions()
        elseif (#args == 2 and args[2]:lower() == 'stop' and variables.isRunning ~= false) then
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Stopping Unity NM Fighter.')
            variables.isRunning = false
            ashita.timer.once(1, run_Closer)
        elseif (#args > 2 and args[2]:lower() == 'shutdownoncap') then
            if args[3]:lower() == 'true' then
                variables.ShutDownOnCap = true
            else
                variables.ShutDownOnCap = false
            end
        elseif (#args > 2 and args[2]:lower() == 'weaponskill') then
            generated_weaponskill = ""
            for i = 3, #args, 1 do
                if i == 1 then
                    generated_weaponskill = args[i]
                else
                    generated_weaponskill = generated_weaponskill..' '..args[i]
                end
            end
            variables.weaponskill = trim(generated_weaponskill)
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Weaponskill set: '..variables.weaponskill)
        elseif (#args > 2 and args[2]:lower() == 'pet') then
            generated_pet = ""
            for i = 3, #args, 1 do
                if i == 1 then
                    generated_pet = args[i]
                else
                    generated_pet = generated_pet..' '..args[i]
                end
            end
            variables.Pet = generated_pet
        elseif (#args > 2 and args[2]:lower() == 'petweaponskill') then
            generated_petWS = ""
            for i = 3, #args, 1 do
                if i == 1 then
                    generated_petWS = args[i]
                else
                    generated_petWS = generated_petWS..' '..args[i]
                end
            end
            variables.PetWeaponskill = trim(generated_petWS)
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Pet Weaponskill set: '..variables.PetWeaponskill)
        elseif (#args > 2 and args[2]:lower() == 'engagetype') then
            variables.EngageType = args[3]
        elseif (#args > 2 and args[2]:lower() == 'warpmethod') then
            variables.WarpMethod = args[3]
        elseif (#args > 2 and args[2]:lower() == 'usecoffers') then
            if args[3]:lower() == 'true' then
                variables.useCoffers = true
            else
                variables.useCoffers = false
            end
        elseif (#args > 2 and args[2]:lower() == 'enternity') then
            if args[3]:lower() == 'true' then
                variables.EnternityActive = true
            else
                variables.EnternityActive = false
            end
        elseif (#args > 2 and args[2]:lower() == 'assistmode') then
            if args[3]:lower() == 'true' then
                variables.assistMode = true
            else
                variables.assistMode = false
            end
        elseif (#args == 2 and args[2]:lower() == 'check') then
            if variables.isRunning == true then
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'isRunning: \31\059true\31\207    true / false')
            else
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'isRunning: \31\059false\31\207   true / false')
            end
            if variables.assistMode == true then
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'AssistMode: \31\059true\31\207    true / false')
            else
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'AssistMode: \31\059false\31\207   true / false')
            end
            if variables.EnternityActive == true then
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'EnternityActive: \31\059true\31\207    true / false')
            else
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'EnternityActive: \31\059false\31\207   true / false')
            end
            if variables.ShutDownOnCap == true then
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Shutdown on Capped: \31\059true\31\207    true / false')
            else
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Shutdown on Capped: \31\059false\31\207   true / false')
            end
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Weaponskill name: \31\059'..variables.weaponskill)
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Engage type: \31\059'..variables.EngageType..'\31\207      1 = melee / 2 = petmelee')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Mode active: \31\059'..variables.modeActive.. '\31\207      0 = Melee, 1 = SMN')
            if variables.useCoffers == true then
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'useCoffers: \31\059true\31\207   true / false')
            else
                print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'useCoffers: \31\059false\31\207  true / false')
            end
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Warp type: \31\059'..variables.WarpMethod.. '\31\207      0 = none, 1 = Ring, 2 = Scroll or 3 = Spell')
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Pet name: \31\059'..variables.Pet)
            print ('\31\200[\31\05UnityNMFighter\31\200]\31\207 ' .. 'Pet weaponskill:\31\059'..variables.PetWeaponskill)
        end
    end
    return true; 
end); 
