/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CR4MeditationClockMenu extends CR4MenuBase
{
	private var m_fxSetBlockMeditation		 	: CScriptedFlashFunction;
	private var m_fxSetCanMeditate			 	: CScriptedFlashFunction;
	private var m_fxSetGeraltBackgroundVisible	: CScriptedFlashFunction;
	private var canMeditateWait				 	: bool;
	private var m_fxSet24HRFormat			 	: CScriptedFlashFunction;
	private var isGameTimePaused			 	: bool;

	event  OnConfigUI()
	{	
		var commonMenu : CR4CommonMenu;
		var locCode : string;
		
		super.OnConfigUI();
		
		GetWitcherPlayer().MeditationClockStart(this);
		SendCurrentTimeToAS();
		m_fxSetBlockMeditation = m_flashModule.GetMemberFlashFunction( "SetBlockMeditation" );
		m_fxSet24HRFormat = m_flashModule.GetMemberFlashFunction( "Set24HRFormat" );
		m_fxSetGeraltBackgroundVisible = m_flashModule.GetMemberFlashFunction( "setGeraltBackgroundVisible" );
		
		
		
		theGame.Unpause("menus");		
		
		if(GetWitcherPlayer().CanMeditate() && GetWitcherPlayer().CanMeditateWait(true))
		{
			canMeditateWait = true;
			isGameTimePaused = false;			
		}
		else if(theGame.IsGameTimePaused())
		{
			canMeditateWait = false;
			isGameTimePaused = true;
		}
		
		if (canMeditateWait) 
		{
			commonMenu = (CR4CommonMenu)m_parentMenu;
			if (commonMenu)
			{
				commonMenu.SetMeditationMode(true);
			}
			
			m_fxSetGeraltBackgroundVisible.InvokeSelfOneArg(FlashArgBool(false)); 
		}
		
		 m_fxSetBlockMeditation.InvokeSelfOneArg(FlashArgBool(!canMeditateWait));
		
		
		
		locCode = GetCurrentTextLocCode();
		m_fxSet24HRFormat.InvokeSelfOneArg(FlashArgBool(locCode != "EN"));
		
		
		if(GameplayFactsQuerySum("GamePausedNotByUI") > 0 && !thePlayer.IsInCombat())
		{
			GetWitcherPlayer().MeditationRestoring(0);				
		}	
		
		
		
			theGame.Pause("menus");
		
	}
	
	event  OnClosingMenu()
	{
		var commonMenu : CR4CommonMenu;
		
		theGame.GetGuiManager().SendCustomUIEvent( 'ClosedMeditationClockMenu' );
		
		commonMenu = (CR4CommonMenu)m_parentMenu;
		if (commonMenu)
		{
			commonMenu.SetMeditationMode(false);
		}
	}
	
	event  OnCloseMenu()
	{
		if(thePlayer.GetCurrentStateName() == 'MeditationWaiting')
		{
			MeditatingEnd();
		}
		
		if (!theGame.IsPaused())
		{
			theGame.Pause("menus");
		}
		
		GetWitcherPlayer().MeditationClockStop();
		CloseMenu();
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}
	}
	
	function SetButtons()
	{
		AddInputBinding("panel_button_common_exit", "escape-gamepad_B", -1);
		super.SetButtons();
	}
	
	public function UpdateCurrentHours( ):void
	{
		var timeHours : int = GetCurrentDayTime( "hours" );
		var	timeMinutes : int = GetCurrentDayTime( "minutes" );
		m_flashValueStorage.SetFlashInt( "meditation.clock.hours.update", timeHours );
		m_flashValueStorage.SetFlashInt( "meditation.clock.minutes", timeMinutes );
	}
	
	public function SendCurrentTimeToAS():void
	{
		var  timeHours : int = GetCurrentDayTime( "hours" );
		var  timeMinutes : int = GetCurrentDayTime( "minutes" );
		
		m_flashValueStorage.SetFlashInt( "meditation.clock.hours", timeHours );
		m_flashValueStorage.SetFlashInt( "meditation.clock.minutes", timeMinutes );
	}
	
	event  OnMeditate( dayTime : float )
	{
		var medd : W3PlayerWitcherStateMeditation;
		
		if (!canMeditateWait)
		{
			ShowDisallowedNotification();			
		}
		else
		{		
			if (theGame.IsPaused())
			{
				theGame.Unpause("menus");
			}
			
			GetWitcherPlayer().Meditate();
			
			OnPlaySoundEvent( "gui_meditation_start" );
			
			LogChannel('CLOCK',"	** OnMeditate ** ");
			if(dayTime == GameTimeHours(theGame.GetGameTime()))
				return false;
			
			medd = (W3PlayerWitcherStateMeditation)thePlayer.GetCurrentState();
			medd.MeditationWait(CeilF(dayTime));
			
			
			StartWaiting();
		}
	} 
	
	event  OnMeditateBlocked()
	{
		ShowDisallowedNotification();
	}
	
	event  OnStopMeditate()
	{
		var waitt : W3PlayerWitcherStateMeditationWaiting;
	
		if(thePlayer.GetCurrentStateName() == 'MeditationWaiting')
		{
			waitt = (W3PlayerWitcherStateMeditationWaiting)thePlayer.GetCurrentState();
			if(waitt)
				waitt.RequestWaitStop();
		}
		
		MeditatingEnd();
	}
	
	function GetCurrentDayTime( type : string ) : int 
	{
		var gameTime : GameTime = theGame.GetGameTime();
		var currentDays : int;
		var currentHours : int;
		var currentMinutes : int;
		var currentTime : int;
		
		switch( type )
		{
			case "days" :
			{
				currentTime = GameTimeDays( gameTime );
				break;
			}
			case "hours" :
			{
				currentDays = GameTimeDays( gameTime );
				currentHours = GameTimeHours( gameTime );
				currentTime = currentHours ;
				break;
			}
			case "minutes" :
			{
				currentDays = GameTimeDays( gameTime );
				currentHours = GameTimeHours( gameTime );
				currentMinutes = GameTimeMinutes( gameTime );
				currentTime = currentMinutes;
				break;
			}	
		}
		return currentTime;
	}
	
	
	
	
	public function StartWaiting():void
	{
		theGame.GetCityLightManager().SetUpdateEnabled( false );
		m_flashValueStorage.SetFlashBool( "meditation.clock.blocked", true );
		SetMenuNavigationEnabled(false);
	}
	
	public function StopWaiting():void
	{
		m_flashValueStorage.SetFlashBool( "meditation.clock.blocked", false );
		SetMenuNavigationEnabled(true);
	}
	
	function MeditatingEnd()
	{
		theGame.GetCityLightManager().ForceUpdate();
		theGame.GetCityLightManager().SetUpdateEnabled( true );
		m_flashValueStorage.SetFlashBool( "meditation.clock.blocked", false );
		SetMenuNavigationEnabled(true);
	}
	
	function PlayOpenSoundEvent()
	{
		
		
	}
	
	private final function ShowDisallowedNotification()
	{		
		if(thePlayer.IsInCombat())
		{
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_combat"));
		}
		else
		{
			showNotification(GetLocStringByKeyExt( "menu_cannot_perform_action_now" ));
		}
		
		OnPlaySoundEvent("gui_global_denied");
	}
}