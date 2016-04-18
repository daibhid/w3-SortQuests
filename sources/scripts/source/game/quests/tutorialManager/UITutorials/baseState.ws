/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state TutHandlerBaseState in W3TutorialManagerUIHandler
{
	protected var defaultTutorialMessage : STutorialMessage;
	private var currentlyShownHint : name;
	
	event OnEnterState(prevStateName : name)
	{	
		
		defaultTutorialMessage.type = ETMT_Hint;
		defaultTutorialMessage.forceToQueueFront = true;
		defaultTutorialMessage.canBeShownInMenus = true;
		defaultTutorialMessage.canBeShownInDialogs = true;
		defaultTutorialMessage.hintPositionType = ETHPT_DefaultUI;
		defaultTutorialMessage.disableHorizontalResize = true;
	}
	
	event OnLeaveState( nextStateName : name )
	{
		
		theGame.GetTutorialSystem().uiHandler.UnregisterUIHint(GetStateName());
	}
	
	protected final function QuitState()
	{
		var entersNew : bool;
		
		
		if(this != theGame.GetTutorialSystem().uiHandler.GetCurrentState())
			return;
		
		
		entersNew = theGame.GetTutorialSystem().uiHandler.UnregisterUIHint(GetStateName());
		
		
		if(!entersNew)
			virtual_parent.GotoState('Tutorial_Idle');
	}
	
	protected final function CloseHint(n : name)
	{
		theGame.GetTutorialSystem().HideTutorialHint(n);
		
		currentlyShownHint = '';
	}
	
	protected final function IsCurrentHint(h : name) : bool
	{
		return currentlyShownHint == h;
	}
	
	protected final function ShowHint(tutorialScriptName : name, optional x : float, optional y : float, optional durationType : ETutorialHintDurationType, optional highlights : array<STutorialHighlight>, optional fullscreen : bool, optional isHudTutorial : bool)
	{
		var tut : STutorialMessage;
	
		tut = defaultTutorialMessage;
		tut.tutorialScriptTag = tutorialScriptName;		
		tut.highlightAreas = highlights;
		tut.forceToQueueFront = true;	
		tut.canBeShownInMenus = true;
		tut.isHUDTutorial = isHudTutorial;
		tut.disableHorizontalResize = true;
		
		if(x != 0 || y != 0)
		{			
			tut.hintPositionType = ETHPT_Custom;
		}
		else
		{
			tut.hintPositionType = ETHPT_DefaultGlobal;
		}
		
		tut.hintPosX = x;
		tut.hintPosY = y;
		
		if(durationType == ETHDT_NotSet)
			tut.hintDurationType = ETHDT_Input;
		else
			tut.hintDurationType = durationType;
		
		if(fullscreen)
		{
			tut.blockInput = true;
			tut.pauseGame = true;
			tut.fullscreen = true;
		}
				
		theGame.GetTutorialSystem().DisplayTutorial(tut);
		currentlyShownHint = tutorialScriptName;
	}
	
	
	
	
	
	
	event OnMenuClosing(menuName : name) 	{}
	event OnMenuClosed(menuName : name) 	{}
	event OnMenuOpening(menuName : name) 	{}
	event OnMenuOpened(menuName : name) 	{}
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool) {}
}
