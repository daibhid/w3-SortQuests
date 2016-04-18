/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state Dismantling in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION, ITEMS, COMPONENTS, COST, DISMANTLING : name;
	private var isClosing : bool;
	
		default DESCRIPTION 	= 'TutorialDismantleDescription';
		default ITEMS 			= 'TutorialDismantleItems';
		default COMPONENTS 		= 'TutorialDismantleComponents';
		default COST 			= 'TutorialDismantlePrice';
		default DISMANTLING 	= 'TutorialDismantleDismantling';		
		
	event OnEnterState( prevStateName : name )
	{	
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(DESCRIPTION, theGame.params.TUT_POS_INVENTORY_X, 0.32f, ETHDT_Input);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(DESCRIPTION);
		CloseHint(ITEMS);
		CloseHint(COMPONENTS);
		CloseHint(COST);
		CloseHint(DISMANTLING);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(DESCRIPTION);
		GameplayFactsRemove("tut_dismantle_cond");	
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == DESCRIPTION)
		{
			highlights.Resize(1);
			highlights[0].x = 0.1;
			highlights[0].y = 0.13;
			highlights[0].width = 0.3;
			highlights[0].height = 0.53;
						
			ShowHint(ITEMS, theGame.params.TUT_POS_INVENTORY_X, 0.32f, ETHDT_Input, highlights);
		}		
		else if(hintName == ITEMS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.43;
			highlights[0].y = 0.39;
			highlights[0].width = 0.23;
			highlights[0].height = 0.27;
						
			ShowHint(COMPONENTS, theGame.params.TUT_POS_INVENTORY_X, 0.32f, ETHDT_Input, highlights);
		}
		else if(hintName == COMPONENTS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.46;
			highlights[0].y = 0.3;
			highlights[0].width = 0.2;
			highlights[0].height = 0.15;
						
			ShowHint(COST, theGame.params.TUT_POS_INVENTORY_X, 0.32f, ETHDT_Input, highlights);
		}
		else if(hintName == COST)
		{
			ShowHint(DISMANTLING, theGame.params.TUT_POS_INVENTORY_X, 0.32f, ETHDT_Input);
		}
		else if(hintName == DISMANTLING)
		{
			QuitState();
		}
	}
}