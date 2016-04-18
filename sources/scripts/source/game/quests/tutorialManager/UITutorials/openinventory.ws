/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state OpenInventory in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_FAST_MENU, OPEN_INVENTORY : name;
	
		default OPEN_FAST_MENU = 'TutorialFoodOpenFastMenu';
		default OPEN_INVENTORY = 'TutorialFoodOpenInventory';
	
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		
		CloseHint(OPEN_FAST_MENU);
		
		
		highlights.Resize(1);
		highlights[0].x = 0.295;
		highlights[0].y = 0.4;
		highlights[0].width = 0.15;
		highlights[0].height = 0.18;
		
		ShowHint(OPEN_INVENTORY, 0.35f, 0.6f, ETHDT_Infinite, highlights);	
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CloseHint(OPEN_INVENTORY);
		
		super.OnLeaveState(nextStateName);
	}	
}
