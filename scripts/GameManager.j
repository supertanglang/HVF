library GameManager initializer init /*
********************************************************************************
* 	Library for game control
*       Currently supported game mode:
*           -sp : shuffle player
*           -nv : no voting
*           -ni : no infighting
*
********************************************************************************
*
*   */ uses /*
*
*       */ UnitManager /*
*       */ ItemManager /*
*       */ Commands /*
*
*******************************************************************************/
	/***************************************************************************
	* Globals
	***************************************************************************/

	/***************************************************************************
	* Prerequisite Functions(private only)
	***************************************************************************/

	/***************************************************************************
	* Modules
	***************************************************************************/
	
	/***************************************************************************
	* Structs
	***************************************************************************/
	struct Game extends array
		    //private static method gameInfo
		// Perform action accoding to selected game mode    
		private static method performGameMode takes nothing returns nothing
		    if Params.flagGameModeSp then
		        call ShufflePlayer()
		    endif
		    
		endmethod
		
	    static method initialize takes nothing returns nothing
	        // call FogEnableOff()
            call BJDebugMsg(MSG_GameInitializing)
	        call TriggerSleepAction(2.0)
	        // For better performance, generate begin items/neutral unit at beginning
	        call UnitManager.createBeiginNeutralAggrUnits()
	        call ItemManager.createBeginMapItems()
	        call BJDebugMsg(MSG_GameInitializingDone)
	        //debug call BJDebugMsg("Waiting host for chosing game mode...")
	        
	        if GetHostPlayer() == GetLocalPlayer() then
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_YouAreHost)
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_PlsSelectGameMode)
	        else
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_HostIs + COLOR_YELLOW + GetPlayerName(GetHostPlayer())+ "|r")
	            call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_WaitHostSelectGameMode)
	        endif

	        call TriggerSleepAction(10.0)
	        call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Normal, MSG_WaitHostSelectGameMode)
	        // Disable game mode commands
	        call InvalidGameModeCommands()
	        
	        // Shuffle players
	        if Params.flagGameModeSp then
		        call ShufflePlayer()
		    endif
		    
		    // Enable game utils commands
		    call EnableGameUtilCommands()
		    
		    // Start event listener
		    call EventManager.listen()
	    endmethod
	    
	    static method start takes nothing returns nothing
	        // call FogEnableOn()
	        
	        call TriggerSleepAction(2.0)
	        if not Params.flagGameModeNv then
                // Vote for play time
                call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, CST_MSGDUR_Tips, MSG_VoteForPlayTime)
                call PlayTime.vote()
            else
                // No need to vote for play time, start game
                call PlayTime.setTime(CST_OT_PlayTime)
                call PlayTime.countdownStart()
            endif
	        
            // Init Farmer/Hunter units
	    endmethod
	endstruct
	/***************************************************************************
	* Common Use Functions
	***************************************************************************/
	
	/***************************************************************************
	* Functions that would be called on event fired
	***************************************************************************/
	
	/***************************************************************************
	* Functions that would be called on timer expired
	***************************************************************************/
	
	/***************************************************************************
	* Library Initiation
	***************************************************************************/
	private function init takes nothing returns nothing
	endfunction
endlibrary