--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of RollTracker nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.
--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL Daniel_H BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
_addon.author = 'Daniel_H';
_addon.name = 'THTracker';
_addon.version = '1.0.0';

require 'common'
require 'logging'

require 'imguidef'; 

DebugMode = true

local default_config = 
{
	 window =
    {
        x = 300,
        y = 100,
        w = 200,
        h = 70,
    },
};
local TH_config = default_config;

local enemyName = ""
local currentTH = 0

-- --------------------------------------------------------------------------------------------------------------------

ashita.register_event('load', function()
    -- Load the configuration file..
    TH_config = ashita.settings.load_merged(_addon.path .. '/settings/settings.json', TH_config);
end);

-- --------------------------------------------------------------------------------------------------------------------

ashita.register_event('unload', function()
    -- Save the configuration file..
    ashita.settings.save(_addon.path .. '/settings/settings.json', TH_config);
end);

-- --------------------------------------------------------------------------------------------------------------------

function Debug(Message)
	if DebugMode == true then
		print('\31\200[\31\05THTracker DEBUG:\31\200]\31\190 ' .. Message)
	end
end

-- --------------------------------------------------------------------------------------------------------------------

ashita.register_event('render', function()

	playerJob = AshitaCore:GetDataManager():GetPlayer():GetMainJob()

	if playerJob == 6 or playerJob == 11 then  -- Only show if the player is either main THF or RNG.
	   imgui.SetNextWindowSize(TH_config.window.w, TH_config.window.h, ImGuiSetCond_Always);
	   imgui.SetNextWindowPos(TH_config.window.y, TH_config.window.x);
    		if (imgui.Begin('Treasure Hunter Tracker') == false) then
        		imgui.End();
        		return;
    		end

    		if enemyName == "" then
    			imgui.Text("No enemy.")
    			imgui.End();
    		else
	    		imgui.Text(enemyName)
	 		imgui.Separator();
			imgui.Text('Treasure Hunter: '..currentTH)
	  		imgui.End();
  		end
  	end
end)

-- --------------------------------------------------------------------------------------------------------------------

ashita.register_event('incoming_text', function(mode, message, modifiedmode, modifiedmessage, blocked)
	if playerJob == 6 or playerJob == 11 then -- No point in running if the player is neither a THF nor RNG.
		name, TH = string.match(message, 'Additional effect: Treasure Hunter effectiveness against[%s%a%a%a]- (.*) increases to (%d+).')
		if name and TH then
			Debug(name.." "..TH)
			enemyName = name
			currentTH = TH
		end
	    if message:find('defeats '..enemyName) then
	    		Debug('DEAD')
			enemyName = ""
			currentTH = 0
	    end
	end
    return false;
end);

-- --------------------------------------------------------------------------------------------------------------------

ashita.register_event('command', function(cmd, nType) 
	local args = cmd:args();

	-- Ensure it's a fastcraft command.
	if (args[1] ~= '/thtracker') then
		return false;
	end

	-- Make sure we have enough args to begin with.
	if (#args < 2) then
		print('\31\200[\31\05THTracker:\31\200]\31\190 ' .. '/thtracker size HEIGHT WIDTH')
		print('\31\200[\31\05THTracker:\31\200]\31\190 ' .. '/thtracker pos Y X')
		return false;
	end

	if (args[2] == 'size' and #args > 3) then
		TH_config.window.h = args[3]
		TH_config.window.w = args[4]
		return true;
	elseif (args[2] == 'save') then
    		ashita.settings.save(_addon.path .. '/settings/settings.json', TH_config);
	elseif (args[2] == 'pos' and #args > 3) then
		TH_config.window.y = args[3]
		TH_config.window.x = args[4]
		return true;
	end

	return false;
end);
