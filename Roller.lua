	--Copyright (c) 2016, Selindrile
--All rights reserved.

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
--DISCLAIMED. IN NO EVENT SHALL THOMAS ROGERS BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'Roller'
_addon.version = '1.8'
_addon.author = 'Selindrile, thanks to: Balloon and Lorand'
_addon.commands = {'roller','roll'}

require('luau')
chat = require('chat')
chars = require('chat.chars')
packets = require('packets')

defaults = {}
defaults.Roll_ind_1 = 17
defaults.Roll_ind_2 = 19
zonedelay = 6

lastRoll = 0

settings = config.load(defaults)

windower.register_event('addon command',function (...)
    cmd = {...}
	if cmd[1] == nil or cmd[1]:lower() == "rolls" then

		if autoroll == true then
			windower.add_to_chat(7,'Automatic Rolling is ON.')
		else
			windower.add_to_chat(7,'Automatic Rolling is OFF.')
		end

		windower.add_to_chat(7,'Roll 1: '..Rollindex[settings.Roll_ind_1]..'')
		windower.add_to_chat(7,'Roll 2: '..Rollindex[settings.Roll_ind_2]..'')
		
    else
		if cmd[1]:lower() == "help" then
			windower.add_to_chat(7,'To start or stop auto rolling type //roller roll')
			windower.add_to_chat(7,'To set rolls use //roller roll# rollname')
		
		elseif cmd[1]:lower() == "rollcall" then
				if zonedelay > 5 then doRoll() end
				windower.send_command('@wait 10;roller rollcall')
				zonedelay = zonedelay + 1
		elseif cmd[1]:lower() == "start" or cmd[1]:lower() == "go" or cmd[1]:lower() == "begin" or cmd[1]:lower() == "enable" or cmd[1]:lower() == "on" or cmd[1]:lower() == "engage" then
			zonedelay = 6
			if autoroll == false then
				autoroll = true
				windower.add_to_chat(7,'Enabling Automatic Rolling.')
				doRoll()
			elseif autoroll == true then
				windower.add_to_chat(7,'Automatic Rolling already enabled.')
			end
		elseif cmd[1]:lower() == "stop" or cmd[1]:lower() == "quit" or cmd[1]:lower() == "end" or cmd[1]:lower() == "disable" or cmd[1]:lower() == "off" or cmd[1]:lower() == "disengage" then
			zonedelay = 6
			if autoroll == true then
				autoroll = false
				windower.add_to_chat(7,'Disabling Automatic Rolling.')
			elseif autoroll == false then
				windower.add_to_chat(7,'Automatic Rolling already disabled.')
			end
		elseif cmd[1]:lower() == "roll" then
			zonedelay = 6
			if autoroll == false then
				autoroll = true
				windower.add_to_chat(7,'Enabling Automatic Rolling.')
				doRoll()
			elseif autoroll == true then
				autoroll = false 
				windower.add_to_chat(7,'Disabling Automatic Rolling.')
			end

		elseif cmd[1]:lower() == "melee" or cmd[1]:lower() == "tp" then
			settings.Roll_ind_1 = 12
			settings.Roll_ind_2 = 8
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			config.save(settings)
			
		elseif cmd[1]:lower() == "acc" or cmd[1]:lower() == "highacc" then
			settings.Roll_ind_1 = 12
			settings.Roll_ind_2 = 11
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			config.save(settings)
		
		elseif cmd[1]:lower() == "ws" or cmd[1]:lower() == "wsd" then
			settings.Roll_ind_1 = 8
			settings.Roll_ind_2 = 1
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			config.save(settings)
		
		elseif cmd[1]:lower() == "nuke" or cmd[1]:lower() == "burst" then
			settings.Roll_ind_1 = 4
			settings.Roll_ind_2 = 5
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			config.save(settings)
		
		elseif cmd[1]:lower() == "pet" or cmd[1]:lower() == "petphy" then
			settings.Roll_ind_1 = 9
			settings.Roll_ind_2 = 14
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			config.save(settings)
		
		elseif cmd[1]:lower() == "petnuke" or cmd[1]:lower() == "petmagic" then
			settings.Roll_ind_1 = 18
			settings.Roll_ind_2 = 28
			windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			config.save(settings)
		
		elseif cmd[1]:lower() == "roll1" then
			local rollchange = false
			if cmd[2] == nil then windower.add_to_chat(7,'Roll 1: '..Rollindex[settings.Roll_ind_1]..'') return
			elseif cmd[2]:lower():startswith("warlock") or cmd[2]:lower():startswith("macc") or cmd[2]:lower():startswith("magic ac") or cmd[2]:lower():startswith("rdm") then settings.Roll_ind_1 = 5 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("fight") or cmd[2]:lower():startswith("double") or cmd[2]:lower():startswith("dbl") or cmd[2]:lower():startswith("war") then settings.Roll_ind_1 = 1 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("monk") or cmd[2]:lower():startswith("subtle") or cmd[2]:lower():startswith("mnk") then settings.Roll_ind_1 = 2 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("heal") or cmd[2]:lower():startswith("cure") or cmd[2]:lower():startswith("whm") then settings.Roll_ind_1 = 3 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("wizard") or cmd[2]:lower():startswith("matk") or cmd[2]:lower():startswith("magic at") or cmd[2]:lower():startswith("blm") then settings.Roll_ind_1 = 4 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("rogue") or cmd[2]:lower():startswith("crit") or cmd[2]:lower():startswith("thf") then settings.Roll_ind_1 = 6 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("gallant") or cmd[2]:lower():startswith("def") or cmd[2]:lower():startswith("pld") then settings.Roll_ind_1 = 7 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("chaos") or cmd[2]:lower():startswith("attack") or cmd[2]:lower():startswith("atk") or cmd[2]:lower():startswith("drk") then settings.Roll_ind_1 = 8 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("beast") or cmd[2]:lower():startswith("pet at") or cmd[2]:lower():startswith("bst") then settings.Roll_ind_1 = 9 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("choral") or cmd[2]:lower():startswith("inter") or cmd[2]:lower():startswith("spell inter") or cmd[2]:lower():startswith("brd") then settings.Roll_ind_1 = 10 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("hunt") or cmd[2]:lower():startswith("acc") or  cmd[2]:lower():startswith("rng") then settings.Roll_ind_1 = 11 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("sam") or cmd[2]:lower():startswith("stp") or cmd[2]:lower():startswith("store") then settings.Roll_ind_1 = 12 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("nin") or cmd[2]:lower():startswith("eva") then settings.Roll_ind_1 = 13 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("drach") or cmd[2]:lower():startswith("pet ac") or cmd[2]:lower():startswith("drg") then settings.Roll_ind_1 = 14 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("evoke") or cmd[2]:lower():startswith("refresh") or cmd[2]:lower():startswith("smn") then settings.Roll_ind_1 = 15 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("magus") or cmd[2]:lower():startswith("mdb") or cmd[2]:lower():startswith("magic d") or cmd[2]:lower():startswith("blu") then settings.Roll_ind_1 = 16 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("cor") or cmd[2]:lower():startswith("exp") then settings.Roll_ind_1 = 17 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("pup") or cmd[2]:lower():startswith("pet m") then settings.Roll_ind_1 = 18 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("dance") or cmd[2]:lower():startswith("regen") or cmd[2]:lower():startswith("dnc") then settings.Roll_ind_1 = 19 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("sch") or cmd[2]:lower():startswith("conserve m") then settings.Roll_ind_1 = 20 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("bolt") or cmd[2]:lower():startswith("move") or cmd[2]:lower():startswith("flee") or cmd[2]:lower():startswith("speed") then settings.Roll_ind_1 = 21 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("cast") or cmd[2]:lower():startswith("fast") or cmd[2]:lower():startswith("fc") then settings.Roll_ind_1 = 22 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("course") or cmd[2]:lower():startswith("snap") then settings.Roll_ind_1 = 23 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("blitz") or cmd[2]:lower():startswith("delay") then settings.Roll_ind_1 = 24 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("tact") or cmd[2]:lower():startswith("regain") then settings.Roll_ind_1 = 25 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("all") or cmd[2]:lower():startswith("skillchain") then settings.Roll_ind_1 = 26 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("miser") or cmd[2]:lower():startswith("save tp") or cmd[2]:lower():startswith("conserve t") then settings.Roll_ind_1 = 27 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("companion") or cmd[2]:lower():startswith("pet r") then settings.Roll_ind_1 = 28 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("avenge") or cmd[2]:lower():startswith("counter") then settings.Roll_ind_1 = 29 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("natural") or cmd[2]:lower():startswith("enhance") or cmd[2]:lower():startswith("duration") then settings.Roll_ind_1 = 30 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("run") or cmd[2]:lower():startswith("meva") or cmd[2]:lower():startswith("magic e") then settings.Roll_ind_1 = 31 config.save(settings) rollchange = true
			end
			
			if rollchange == true then
				windower.add_to_chat(7,'Setting Roll 1 to: '..Rollindex[settings.Roll_ind_1]..'')
			else
				windower.add_to_chat(7,'Invalid roll name, Roll 1 remains: '..Rollindex[settings.Roll_ind_1]..'')
			end

		elseif cmd[1]:lower() == "roll2" then
			local rollchange = false
			if cmd[2] == nil then windower.add_to_chat(7,'Roll 1: '..Rollindex[settings.Roll_ind_2]..'') return
			elseif cmd[2]:lower():startswith("warlock") or cmd[2]:lower():startswith("macc") or cmd[2]:lower():startswith("magic ac") or cmd[2]:lower():startswith("rdm") then settings.Roll_ind_2 = 5 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("fight") or cmd[2]:lower():startswith("double") or cmd[2]:lower():startswith("dbl") or cmd[2]:lower():startswith("war") then settings.Roll_ind_2 = 1 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("monk") or cmd[2]:lower():startswith("subtle") or cmd[2]:lower():startswith("mnk") then settings.Roll_ind_2 = 2 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("heal") or cmd[2]:lower():startswith("cure") or cmd[2]:lower():startswith("whm") then settings.Roll_ind_2 = 3 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("wizard") or cmd[2]:lower():startswith("matk") or cmd[2]:lower():startswith("magic at") or cmd[2]:lower():startswith("blm") then settings.Roll_ind_2 = 4 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("rogue") or cmd[2]:lower():startswith("crit") or cmd[2]:lower():startswith("thf") then settings.Roll_ind_2 = 6 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("gallant") or cmd[2]:lower():startswith("def") or cmd[2]:lower():startswith("pld") then settings.Roll_ind_2 = 7 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("chaos") or cmd[2]:lower():startswith("attack") or cmd[2]:lower():startswith("atk") or cmd[2]:lower():startswith("drk") then settings.Roll_ind_2 = 8 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("beast") or cmd[2]:lower():startswith("pet at") or cmd[2]:lower():startswith("bst") then settings.Roll_ind_2 = 9 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("choral") or cmd[2]:lower():startswith("inter") or cmd[2]:lower():startswith("spell inter") or cmd[2]:lower():startswith("brd") then settings.Roll_ind_2 = 10 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("hunt") or cmd[2]:lower():startswith("acc") or  cmd[2]:lower():startswith("rng") then settings.Roll_ind_2 = 11 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("sam") or cmd[2]:lower():startswith("stp") or cmd[2]:lower():startswith("store") then settings.Roll_ind_2 = 12 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("nin") or cmd[2]:lower():startswith("eva") then settings.Roll_ind_2 = 13 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("drach") or cmd[2]:lower():startswith("pet ac") or cmd[2]:lower():startswith("drg") then settings.Roll_ind_2 = 14 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("evoke") or cmd[2]:lower():startswith("refresh") or cmd[2]:lower():startswith("smn") then settings.Roll_ind_2 = 15 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("magus") or cmd[2]:lower():startswith("mdb") or cmd[2]:lower():startswith("magic d") or cmd[2]:lower():startswith("blu") then settings.Roll_ind_2 = 16 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("cor") or cmd[2]:lower():startswith("exp") then settings.Roll_ind_2 = 17 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("pup") or cmd[2]:lower():startswith("pet m") then settings.Roll_ind_2 = 18 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("dance") or cmd[2]:lower():startswith("regen") or cmd[2]:lower():startswith("dnc") then settings.Roll_ind_2 = 19 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("sch") or cmd[2]:lower():startswith("conserve m") then settings.Roll_ind_2 = 20 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("bolt") or cmd[2]:lower():startswith("move") or cmd[2]:lower():startswith("flee") or cmd[2]:lower():startswith("speed") then settings.Roll_ind_2 = 21 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("cast") or cmd[2]:lower():startswith("fast") or cmd[2]:lower():startswith("fc") then settings.Roll_ind_2 = 22 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("course") or cmd[2]:lower():startswith("snap") then settings.Roll_ind_2 = 23 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("blitz") or cmd[2]:lower():startswith("delay") then settings.Roll_ind_2 = 24 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("tact") or cmd[2]:lower():startswith("regain") then settings.Roll_ind_2 = 25 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("all") or cmd[2]:lower():startswith("skillchain") then settings.Roll_ind_2 = 26 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("miser") or cmd[2]:lower():startswith("save tp") or cmd[2]:lower():startswith("conserve t") then settings.Roll_ind_2 = 27 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("companion") or cmd[2]:lower():startswith("pet r") then settings.Roll_ind_2 = 28 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("avenge") or cmd[2]:lower():startswith("counter") then settings.Roll_ind_2 = 29 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("natural") or cmd[2]:lower():startswith("enhance") or cmd[2]:lower():startswith("duration") then settings.Roll_ind_2 = 30 config.save(settings) rollchange = true
			elseif cmd[2]:lower():startswith("run") or cmd[2]:lower():startswith("meva") or cmd[2]:lower():startswith("magic e") then settings.Roll_ind_2 = 31 config.save(settings) rollchange = true
			end
			
			if rollchange == true then
				windower.add_to_chat(7,'Setting Roll 2 to: '..Rollindex[settings.Roll_ind_2]..'')
			else
				windower.add_to_chat(7,'Invalid roll name, Roll 2 remains: '..Rollindex[settings.Roll_ind_2]..'')
			end
         end
        
    end
end)

windower.register_event('load', function()

	autoroll = false

	buffId = S{309} + S(res.buffs:english(string.endswith-{' Roll'})):map(table.get-{'en'})
	
    Rollindex = {'Fighter\'s Roll','Monk\'s Roll','Healer\'s Roll','Wizard\'s Roll','Warlock\'s Roll','Rogue\'s Roll','Gallant\'s Roll','Chaos Roll','Beast Roll',
				 'Choral Roll','Hunter\'s Roll','Samurai Roll','Ninja Roll','Drachen Roll','Evoker\'s Roll','Magus\'s Roll','Corsair\'s Roll','Puppet Roll',
				 'Dancer\'s Roll','Scholar\'s Roll','Bolter\'s Roll','Caster\'s Roll','Courser\'s Roll','Blitzer\'s Roll','Tactician\'s Roll','Allies\' Roll',
				 'Miser\'s Roll','Companion\'s Roll','Avenger\'s Roll','Naturalist\'s Roll','Runeist\'s Roll'}
				 
    local rollInfoTemp = {
        -- Okay, this goes 1-11 boost, Bust effect, Effect, Lucky, +1 Phantom Roll Effect, Bonus Equipment and Effect,
        ['Chaos'] = {6,8,9,25,11,13,16,3,17,19,31,"-4", '% Attack!', 4, 8},
        ['Fighter\'s'] = {2,2,3,4,12,5,6,7,1,9,18,'-4','% Double-Attack!', 5, 9},
        ['Wizard\'s'] = {4,6,8,10,25,12,14,17,2,20,30, "-10", ' MAB', 5, 9},
        ['Evoker\'s'] = {1,1,1,1,3,2,2,2,1,3,4,'-1', ' Refresh!',5, 9},
        ['Rogue\'s'] = {2,2,3,4,12,5,6,6,1,8,14,'-6', '% Critical Hit Rate!', 5, 9},
        ['Corsair\'s'] = {10, 11, 11, 12, 20, 13, 15, 16, 8, 17, 24, '-6', '% Experience Bonus',5, 9},
        ['Hunter\'s'] = {10,13,15,40,18,20,25,5,27,30,50,'-?', ' Accuracy Bonus',4, 8},
        ['Magus\'s'] = {5,20,6,8,9,3,10,13,14,15,25,'-8',' Magic Defense Bonus',2, 6},
        ['Healer\'s'] = {3,4,12,5,6,7,1,8,9,10,16,'-4','% Cure Potency',3, 7},
        ['Drachen'] = {10,13,15,40,18,20,25,5,28,30,50,'-8',' Pet: Accuracy Bonus',4, 8},
        ['Choral'] = {8,42,11,15,19,4,23,27,31,35,50,'+25', '- Spell Interruption Rate',2, 6},
        ['Monk\'s'] = {8,10,32,12,14,15,4,20,22,24,40,'-?', ' Subtle Blow', 3, 7},
        ['Beast'] = {6,8,9,25,11,13,16,3,17,19,31,'-10', '% Pet: Attack Bonus',4, 8},
        ['Samurai'] = {7,32,10,12,14,4,16,20,22,24,40,'-10',' Store TP Bonus',2, 6},
        ['Warlock\'s'] = {2,3,4,12,5,6,7,1,8,9,15,'-5',' Magic Accuracy Bonus',4, 8},
        ['Puppet'] = {5,8,35,11,14,18,2,22,26,30,40,'-8',' Pet: Magic Attack Bonus',3, 7},
        ['Gallant\'s'] = {4,5,15,6,7,8,3,9,10,11,20,'-10','% Defense Bonus', 3, 7},
        ['Dancer\'s'] = {3,4,12,5,6,7,1,8,9,10,16,'-4',' Regen',3, 7},
        ['Bolter\'s'] = {0.3,0.3,0.8,0.4,0.4,0.5,0.5,0.6,0.2,0.7,1.0,'-8','% Movement Speed',3, 9},
        ['Caster\'s'] = {6,15,7,8,9,10,5,11,12,13,20,'-10','% Fast Cast',2, 7},
        ['Tactician\'s'] = {10,10,10,10,30,10,10,0,20,20,40,'-10',' Regain',5, 8},
        ['Miser\'s'] = {30,50,70,90,200,110,20,130,150,170,250,'0',' Save TP',5, 7},
        ['Ninja'] = {4,5,5,14,6,7,9,2,10,11,18,'-10',' Evasion Bonus',4, 8},
        ['Scholar\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Conserve MP',2, 6},
        ['Allies\''] = {6,7,17,9,11,13,15,17,17,5,17,'?','% Skillchain Damage',3, 10},
        ['Companion\'s'] = {{4,20},{20, 50},{6,20},{8, 20},{10,30},{12,30},{14,30},{16,40},{18, 40}, {3,10},{30, 70},'-?',' Pet: Regen/Regain',2, 10},
        ['Avenger\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Counter Rate',4, 8},
        ['Blitzer\'s'] = {2,3.4,4.5,11.3,5.3,6.4,7.2,8.3,1.5,10.2,12.1,'-?', '% Attack delay reduction',4, 9},
        ['Courser\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Snapshot',3, 9},
        ['Runeist\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Magic Evasion',4, 8},
        ['Naturalist\'s'] = {'?','?','?','?','?','?','?','?','?','?','?','?',' Enhancing Magic Duration',3, 7}
    }

    rollInfo = {}
    for key, val in pairs(rollInfoTemp) do
        rollInfo[res.job_abilities:with('english', key .. ' Roll').id] = {key, unpack(val)}
    end
    
    settings = config.load(defaults)
	
	windower.send_command('@wait 20;roller rollcall')

end)

windower.register_event('action', function(act)

	if not autoroll or haveBuff('amnesia') or haveBuff('impairment') then return end

    if act.category == 6 and table.containskey(rollInfo, act.param) then

        rollActor = act.actor_id
        local rollID = act.param
		if rollID == 177 then return end
        local rollNum = act.targets[1].actions[1].param
		local player = windower.ffxi.get_player()

		if act.actor_id == player.id then
			--If roll is lucky or 11 returns.
			
			if rollNum == rollInfo[rollID][15] or rollNum == 11 then
				lastRoll = rollNum
				return
			end
			
			if player.main_job == 'COR' then
				
				local abil_recasts = windower.ffxi.get_ability_recasts()
				local available_ja = S(windower.ffxi.get_abilities().job_abilities)
				--windower.add_to_chat(7,'Double-Up Recast: '..abil_recasts[194]..'')
				if available_ja:contains(177) and abil_recasts[197] == 0 and rollNum == 10 then
					windower.send_command('wait 1;input /ja "Snake Eye" <me>;wait 4;input /ja "Double-Up" <me>')
				elseif available_ja:contains(177) and abil_recasts[197] == 0 and rollNum == (rollInfo[rollID][15] - 1) then
					windower.send_command('wait 1;input /ja "Snake Eye" <me>;wait 4;input /ja "Double-Up" <me>')
				elseif available_ja:contains(177) and abil_recasts[197] == 0 and rollNum > 6 and rollNum == rollInfo[rollID][16] then
					windower.send_command('wait 1;input /ja "Snake Eye" <me>;wait 4;input /ja "Double-Up" <me>')
				elseif available_ja:contains(178) and abil_recasts[198] == 0 and not haveBuff('Crooked Cards') and rollNum < 9 then
					windower.send_command('wait 5;input /ja "Double-Up" <me>')
				elseif rollNum < 6 or lastRoll == 11 then
					windower.send_command('wait 5;input /ja "Double-Up" <me>')
				else
					lastRoll = rollNum
				end
			
			elseif rollNum < 6 then
				windower.send_command('@wait 5;input /ja "Double-Up" <me>')
			end
		end
	end
end)

function haveBuff(...)
	local args = S{...}:map(string.lower)
	local player = windower.ffxi.get_player()
	if (player ~= nil) and (player.buffs ~= nil) then
		for _,bid in pairs(player.buffs) do
			local buff = res.buffs[bid]
			if args:contains(buff.en:lower()) then
				return true
			end
		end
	end
	return false
end

Cities = S{
    "Ru'Lude Gardens",
    "Upper Jeuno",
    "Lower Jeuno",
    "Port Jeuno",
    "Port Windurst",
    "Windurst Waters",
    "Windurst Woods",
    "Windurst Walls",
    "Heavens Tower",
    "Port San d'Oria",
    "Northern San d'Oria",
    "Southern San d'Oria",
	"Chateau d'Oraguille",
    "Port Bastok",
    "Bastok Markets",
    "Bastok Mines",
    "Metalworks",
    "Aht Urhgan Whitegate",
	"The Colosseum",
    "Tavanazian Safehold",
    "Nashmau",
    "Selbina",
    "Mhaura",
	"Rabao",
    "Norg",
    "Kazham",
    "Eastern Adoulin",
    "Western Adoulin",
	"Celennia Memorial Library",
	"Mog Garden",
	"Leafallia"
}

function doRoll()
	if Cities:contains(res.zones[windower.ffxi.get_info().zone].english) then return end
	if not autoroll or haveBuff('amnesia') or haveBuff('impairment') then return end
	local player = windower.ffxi.get_player()
	if not (player.main_job == 'COR' or player.sub_job == 'COR') then return end
	local status = res.statuses[windower.ffxi.get_player().status].english
	if not (status == 'Idle' or status == 'Engaged') then return end
	if haveBuff('Sneak') or haveBuff('Invisible') then return end
	local abil_recasts = windower.ffxi.get_ability_recasts()

	if player.main_job == 'COR' and abil_recasts[198] > 0 and abil_recasts[197] > 0 and abil_recasts[196] == 0 then windower.send_command('input /ja "Random Deal" <me>') return end
	if player.main_job == 'COR' and haveBuff('Bust') then windower.send_command('input /ja "Fold" <me>') return end
	if abil_recasts[193] > 0 then return end

	if not haveBuff(Rollindex[settings.Roll_ind_1]) then
		if player.main_job == 'COR' and player.main_job_level > 94 and abil_recasts[96] == 0 then 
			windower.send_command('input /ja "Crooked Cards" <me>;wait 2;input /ja "'..Rollindex[settings.Roll_ind_1]..'" <me>')
		else
			windower.send_command('input /ja "'..Rollindex[settings.Roll_ind_1]..'" <me>')
		end
		
	elseif player.main_job == 'COR' and not haveBuff(Rollindex[settings.Roll_ind_2]) then
		windower.send_command('input /ja "'..Rollindex[settings.Roll_ind_2]..'" <me>')
	end

end

windower.register_event('lose buff', doRoll)

windower.register_event('zone change', function()
	zonedelay = 0
	autoroll = false
end)