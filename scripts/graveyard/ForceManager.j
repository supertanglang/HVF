/* !!! IT'S DEAD */

library ForceManager initializer init/* v0.0.1 Xandria
*/  uses 	 Alloc         /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-alloc-alternative-221493/[/url]
*/           PlayerManager /* [url]http://www.hiveworkshop.com/forums/jass-resources-412/snippet-error-message-239210/[/url]
*/           PlayerAlliance /*
*************************************************************************************
* 	HVF Force management : For use of managing HuntersVsFarmers forces
*
*************************************************************************************

CreateNeutralPassiveBuildings
call SetPlayerMaxHeroesAllowed(1,GetLocalPlayer())
*************************************************************************************/

	globals
		private force fcFarmers = null // Force Farmer
        private force fcHunters = null	// Force Hunter
        private integer iNbrFarmers	// Number of Farmer
        private integer iNbrHunters	// Number of Hunter
        
        // For local use, adding gold/lumber to player
        private integer iGold = 0
        private integer iLumber = 0
    endglobals
    
    struct Force extends array
    
    	static method addFarmer takes player p returns nothing
    		call ForceAddPlayer(fcFarmers, p)
    	endmethod
    	
    	static method addHunter takes player p returns nothing
    		call ForceAddPlayer(fcHunters, p)
    	endmethod
    	
    	static method removeFarmer takes player p returns nothing
    		call ForceRemovePlayer(fcFarmers, p)
    	endmethod
    	
    	static method removeHunter takes player p returns nothing
    		call ForceRemovePlayer(fcHunters, p)
    	endmethod
    	
    	static method isFarmer takes player p returns boolean
    		return IsPlayerInForce(p, fcFarmers)
    	endmethod
    	
    	static method isHunter takes player p returns boolean
    		return IsPlayerInForce(p, fcHunters)                                          
    	endmethod
    	
    	static method getFarmerForce takes player p returns force
    		return fcFarmers
    	endmethod
    	
    	static method getHunterForce takes player p returns force
    		return fcHunters
    	endmethod
    	
    	static method getHunterCount takes nothing returns integer
    		return iNbrHunters
    	endmethod
    	
    	static method getFarmerCount takes nothing returns integer
    		return iNbrFarmers
    	endmethod
    	
    	static method inSameForce takes player p, player p2 returns boolean
    		if isFarmer(p)  then
    			if isFarmer(p2) then
    				return true
    			endif
    		else
    			if isHunter(p2) then
    				return true
    			endif
    		endif
    		return false
    	endmethod
    	
    	// Enumeration Method
    	static method addGoldEnum takes player p returns nothing
    		call AdjustPlayerStateSimpleBJ(GetEnumPlayer(), PLAYER_STATE_GOLD_GATHERED, iGold)
    	endmethod
    	
    	static method addLumberEnum takes player p returns nothing
    		call AdjustPlayerStateSimpleBJ(GetEnumPlayer(), PLAYER_STATE_RESOURCE_LUMBER, iLumber)
    	endmethod
    	
    	static method addGoldToForce takes force fc, integer gold returns nothing
    		set iGold = gold
    		call ForForce(fc, function this.addGoldEnum)
    	endmethod
    	
    	static method addLumberToForce takes force fc, integer lumber returns nothing
    		set iLumber = lumber
    		call ForForce(fc, function this.addLumberEnum)
    	endmethod
    	
    	static method addGoldToPlayer takes player p, integer gold returns nothing
    		call AdjustPlayerStateSimpleBJ(p, PLAYER_STATE_GOLD_GATHERED, gold)
    	endmethod
    	
    	static method addLumberToPlayer takes player p, integer lumber returns nothing
    		call AdjustPlayerStateSimpleBJ(p, PLAYER_STATE_GOLD_GATHERED, lumber)
    	endmethod
    	
    	private static method setupTeam takes nothing returns nothing
    		local ActivePlayer ap = ActivePlayer[ActivePlayer.first]
    		
    		loop
    			exitwhen ap.end
    			if isFarmer(ap.get) then
    				call SetPlayerTeam(ap.get, 0)
    			else
    				call SetPlayerTeam(ap.get, 1)
    			endif
    			set ap = ap.next
    		endloop
    		
    	endmethod
    	
    	// Temporary solution
    	private static method setupAlly takes nothing returns nothing
    		local ActivePlayer sourcePlayer = ActivePlayer[ActivePlayer.first]
    		local ActivePlayer targetPlayer
    		
    		loop
    			exitwhen sourcePlayer.end
    			set targetPlayer = sourcePlayer.next
    			loop
    				exitwhen targetPlayer.end
    				if inSameForce(sourcePlayer.get, targetPlayer.get) then
    					call Ally( sourcePlayer.get, targetPlayer.get, ALLIANCE_NEUTRAL_VISION)
    				else 
    					call Ally( sourcePlayer.get, targetPlayer.get, ALLIANCE_UNALLIED)
    				endif
    				set targetPlayer = targetPlayer.next
    			endloop
    			set sourcePlayer = sourcePlayer.next
    		endloop
    		
    	endmethod
    	
    	static method shufflePlayer takes nothing returns nothing
    		local ActivePlayer ap = ActivePlayer[ActivePlayer.first]
    		local integer iPlayerNbr = ActivePlayer.count
    		local integer iFarmerCount = 0
    		local integer iHunterCount = 0
    		local integer iHunterMaxNbr
    		local integer m
    		local integer n
    		
    		debug call BJDebugMsg("Shuffling players!")
    		
    		// Calculate number of hunters/farmers
    		set m = iPlayerNbr/3
    		set n = iPlayerNbr - (m*3)
    		
    		set iHunterMaxNbr = m
    		if n != 0 then
    			set iHunterMaxNbr = iHunterMaxNbr + 1
    		endif
    		set iNbrHunters = iHunterMaxNbr
    		set iNbrFarmers = iPlayerNbr - iNbrHunters
    		
    		// Clear force
    		call ForceClear(fcFarmers)
    		call ForceClear(fcHunters)
    		call Hunters.clear()
    		call Farmers.clear()
    		
    		loop
    			exitwhen ap.end
    			if iHunterCount < iNbrHunters and iFarmerCount < iNbrFarmers then
    				if GetRandomInt(0,1) == 1 then
    					debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Hunters")
    					call addHunter(ap.get)
    					set iHunterCount = iHunterCount + 1
    				else
    					debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Farmers")
						call addFarmer(ap.get)
						set iFarmerCount = iFarmerCount + 1
					endif
				else
					if iFarmerCount == iNbrFarmers then
						debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Hunters")
    					call addHunter(ap.get)
    					set iHunterCount = iHunterCount + 1
					else
						debug call BJDebugMsg("Shuffling player:" + GetPlayerName(ap.get) + " to Farmers")
						call addFarmer(ap.get)
						set iFarmerCount = iFarmerCount + 1
					endif
    			endif
    			set ap = ap.next
    		endloop
    		
    		debug call BJDebugMsg("Shuffling finished! Number of Farmers:" + I2S(iNbrFarmers) + ", Number of Hunters:" +I2S(iNbrHunters))
    		
    		// re-assemble team and alliance after shuffling
    		call setupTeam()
    		call setupAlly()
    		
    	endmethod
    	
    	// It has default game alliance
    	static method defaultSetting takes nothing returns nothing
    		local ActivePlayer ap = ActivePlayer[ActivePlayer.first]
    		loop
    			// Set max allowed hero to 1
    			call SetPlayerTechMaxAllowed(CST_INT_MAX_HEROS, CST_INT_TECHID_HERO, ap.get)
    			if GetPlayerId(ap.get) > 5 and GetPlayerId(ap.get) < 10 then
    				debug call BJDebugMsg("Grouping player:" + GetPlayerName(ap.get) + " to Hunters")
    				call ForceAddPlayer(fcHunters, ap.get)
    				set iNbrHunters = iNbrHunters + 1
    			else
    				debug call BJDebugMsg("Grouping player:" + GetPlayerName(ap.get) + " to Farmers")
    				call ForceAddPlayer(fcFarmers, ap.get)
    				set iNbrFarmers = iNbrFarmers + 1
    			endif
        		
        		set ap = ap.next
        		exitwhen ap.end
        	endloop
    	endmethod
    	
    	// Do clean-up work for leaving player
    	private static method removePlayer takes nothing returns boolean
    		local player pLeave = GetTriggerPlayer()
    		local boolean bIsHunter = isHunter(pLeave)
    		
    		// remove player from group
    		if bIsHunter then
    			debug call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Hunters")
    			call removeHunter(pLeave)
    		else
				debug call BJDebugMsg("Removing player:" + GetPlayerName(pLeave) + " from Farmers")
				call removeFarmer(pLeave)
			endif
			
			// remove unit of this player
			// or share control/vision of leaving player with other playing players?
			
    		set pLeave = null
    		return false
    	endmethod
    	
    	private static method onInit takes nothing returns nothing
    		// Register a leave action callback of player leave event
    		call Players.LEAVE.register(Filter(function thistype.removePlayer))
    	endmethod
    endstruct
    
    private function init takes nothing returns nothing
    	set fcFarmers = CreateForce()
    	set fcFarmers = CreateForce()
    	
    	// Grouping players to Hunters/Farmers force by default
    	call Force.defaultSetting()
    endfunction
endlibrary