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
	* Neither the name of Gobbiebox nor the
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
]] --

_addon.name = 'Gobbiebox'
_addon.author = 'Daniel_H'
_addon.version = '1.0'
_addon.language = 'english'

-- LIST OF KNOWN GOBBIEBOX NPCS
NPCs = { 'habitox', 'mystrix', 'bountibox', 'specilox', 'arbitrix', 'funtrox', 'sweepstox', 'priztrix', 'wondrix', 'rewardox', 'winrix' }

-- CURRENT TOTAL OF KEYS
AB_Keys = 0
SP_Keys = 0
ANV_Keys = 0

-- ERROR CHECKER INT
ErrorChecker = 0

-- The variable to check whether a command is up or not
blockTrades = false

-- The variable to check whether the automator is running or not
automatorRunning = false

-- REQUIREMENTS
require 'common'
require 'timer'
require 'ffxi.targets'

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function beginTrade()

    -- ENTITY MANAGER VARIABLE
    entityManager = AshitaCore:GetDataManager():GetEntity();

    if automatorRunning == true then
        -- If blockTrades is false then search for the goblin and trade an item to begin the process
        -- Otherwise, do nothing for 5 seconds
        if blockTrades == false then
            -- Get your current target
            currentTarget = AshitaCore:GetDataManager():GetTarget():GetTargetName()
            -- Current target is NOT a goblin, so search for one and target it
            if currentTarget == nil or not table.contains(NPCs, currentTarget:lower()) then
                for index = 0, 4096, 1 do
                    -- If the entity name is in the NPCs table then continue
                    if entityManager:GetName(index) ~= nil and table.contains(NPCs, entityManager:GetName(index):lower()) then
                        -- Target the goblin specified.
                        AshitaCore:GetChatManager():QueueCommand('/target ' .. entityManager:GetServerId(index), 0);
                        break;
                    end
                end
                -- Wait two seconds and run this function again
                ashita.timer.once(2, beginTrade)
            elseif currentTarget ~= nil and table.contains(NPCs, currentTarget:lower()) then
                -- Target is a goblin so trade keys if possible
                if ashita.ffxi.targets.get_target('t').Distance < 6 then
                    if ANV_Keys > 0 then
                        -- First trade #ANV Keys
                        AshitaCore:GetChatManager():QueueCommand('/item "Dial Key #ANV" <t>', 1)
                        blockTrades = true
                        if ANV_Keys > 0 then
                            ANV_Keys = ANV_Keys - 1
                        end
                    elseif AB_Keys > 0 then
                        -- Now trade AB Keys
                        AshitaCore:GetChatManager():QueueCommand('/item "Dial Key #AB" <t>', 1)
                        blockTrades = true
                        if AB_Keys > 0 then
                            AB_Keys = AB_Keys - 1
                        end
                    elseif SP_Keys > 0 then
                        -- Finally trade SP Keys
                        AshitaCore:GetChatManager():QueueCommand('/item "SP Gobbie Key" <t>', 1)
                        blockTrades = true
                        if SP_Keys > 0 then
                            SP_Keys = SP_Keys - 1
                        end
                    else
                        -- None found, stop the automator
                        print('\31\200[\31\05Gobbiebox Automator\31\200]\31\207 ' .. 'No keys were found in your inventory, stopping.')
                        automatorRunning = false
                    end
                else
                    print('\31\200[\31\05Gobbiebox Automator\31\200]\31\207 ' .. 'Too far from the Goblin, stopping automator.')
                    automatorRunning = false
                end
            end
        end
    end
end

function updateKeys()

    SP_Keys = 0
    ANV_Keys = 0
    AB_Keys = 0

    inv = AshitaCore:GetDataManager():GetInventory()
    for index = 1, inv:GetContainerMax(0), 1 do
        local item = inv:GetItem(0, index);
        if (item['Id'] == 9274) then
            -- #ANV KEY
            ANV_Keys = ANV_Keys + item['Count']
        elseif (item['Id'] == 9217) then
            -- AB KEY
            AB_Keys = AB_Keys + item['Count']
        elseif (item['Id'] == 8973) then
            -- SP Key
            SP_Keys = SP_Keys + item['Count']
        end
    end
end

ashita.register_event('incoming_text', function(mode, message)
    if message ~= nil then
        messageLowercase = message:lower();
        if messageLowercase:find('oy, would you get a look at yer') then
            blockTrades = true
        elseif messageLowercase:find('obtained: ') then
            blockTrades = false;
            ashita.timer.once(4, beginTrade)
        end
    end
    return false;
end);

ashita.register_event('command', function(command, ntype)
    -- Get the arguments of the command..
    local args = command:args();
    if (args[1]:lower() ~= '/gobbiebox' and args[1]:lower() ~= '/gb') then
        return false
    else
        if (#args == 2 and args[2] == 'start') then
            -- Start the bot, but first set the variable to true so the automator can run
            automatorRunning = true
            blockTrades = false
            -- Update KEY quantity
            updateKeys()
            -- Show a message with the current count of keys.
            print('\31\200[\31\05Gobbiebox Automator\31\200]\31\207 ' .. 'Starting Automator: ' .. ANV_Keys .. ' #ANV Keys - ' .. AB_Keys .. ' AB Keys - ' .. SP_Keys .. ' SP Keys')
            -- Begin trading
            beginTrade()
        elseif (#args == 2 and args[2] == 'stop') then
            -- Show a message indicating the automator has been stopped.
            print('\31\200[\31\05Gobbiebox Automator\31\200]\31\207 ' .. 'Stopped.')
            -- Stop the automator, this is done easily by simply setting the variable to false
            automatorRunning = false
        end
    end
    return false
end);