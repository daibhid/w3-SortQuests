/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state CharacterDevelopmentFastMenu in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var PANEL, CHAR_DEV_OPEN : name;
	
		default PANEL 				= 'TutorialCharDevPanel';
		default CHAR_DEV_OPEN 		= 'TutorialCharDevOpen';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
	
		super.OnEnterState(prevStateName);
		
		CloseHint(CHAR_DEV_OPEN);
		
		highlights.Resize(1);
		highlights[0].x = 0.625;
		highlights[0].y = 0.42;
		highlights[0].width = 0.13;
		highlights[0].height = 0.15;
		
		ShowHint(PANEL, 0.5, 0.7, ETHDT_Infinite, highlights);
	}

	event OnLeaveState( nextStateName : name )
	{		
		CloseHint(PANEL);
		
		super.OnLeaveState(nextStateName);
	}		
}