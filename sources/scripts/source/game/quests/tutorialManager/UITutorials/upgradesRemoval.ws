/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state UpgradesRemoval in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION, ITEMS, UPGRADES, COST, REMOVING : name;
	private var isClosing : bool;
	
		default DESCRIPTION 	= 'TutorialUpgRemovalDescription';
		default ITEMS 			= 'TutorialUpgRemovalItems';
		default UPGRADES 		= 'TutorialUpgRemovalUpgrades';
		default COST 			= 'TutorialUpgRemovalCost';
		default REMOVING 		= 'TutorialUpgRemovalRemoving';		
		
	event OnEnterState( prevStateName : name )
	{	
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		ShowHint(DESCRIPTION, theGame.params.TUT_POS_INVENTORY_X, 0.55f, ETHDT_Input);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(DESCRIPTION);
		CloseHint(ITEMS);
		CloseHint(UPGRADES);
		CloseHint(COST);
		CloseHint(REMOVING);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(DESCRIPTION);
		
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
			highlights[0].x = 0.06;
			highlights[0].y = 0.13;
			highlights[0].width = 0.3;
			highlights[0].height = 0.53;
						
			ShowHint(ITEMS, theGame.params.TUT_POS_INVENTORY_X, 0.55f, ETHDT_Input, highlights);
		}		
		else if(hintName == ITEMS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.42;
			highlights[0].y = 0.42;
			highlights[0].width = 0.2;
			highlights[0].height = 0.23;
						
			ShowHint(UPGRADES, theGame.params.TUT_POS_INVENTORY_X, 0.55f, ETHDT_Input, highlights);
		}
		else if(hintName == UPGRADES)
		{
			highlights.Resize(1);
			highlights[0].x = 0.45;
			highlights[0].y = 0.62;
			highlights[0].width = 0.13;
			highlights[0].height = 0.15;
						
			ShowHint(COST, theGame.params.TUT_POS_INVENTORY_X, 0.50f, ETHDT_Input, highlights);
		}
		else if(hintName == COST)
		{
			ShowHint(REMOVING, theGame.params.TUT_POS_INVENTORY_X, 0.55f, ETHDT_Input);
		}
		else if(hintName == REMOVING)
		{
			QuitState();
		}
	}
}