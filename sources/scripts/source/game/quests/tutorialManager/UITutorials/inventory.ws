/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state Inventory in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var PAPERDOLL, BAG, TABS, STATS, STATS_DETAILS, EQUIPPING : name;
	private var isClosing : bool;
	
		default PAPERDOLL 		= 'TutorialInventoryPaperdoll';
		default BAG 			= 'TutorialInventoryBag';
		default TABS 			= 'TutorialInventoryTabs';
		default STATS 			= 'TutorialInventoryStats';
		default STATS_DETAILS 	= 'TutorialInventoryStatsMore';
		default EQUIPPING 		= 'TutorialInventoryEquipping';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		BlockPanels(true);
		
		highlights.Resize(1);
		highlights[0].x = 0.38;
		highlights[0].y = 0.12;
		highlights[0].width = 0.26;
		highlights[0].height = 0.62;
			
		ShowHint(PAPERDOLL, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, , highlights);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		BlockPanels(false);
		
		CloseHint(PAPERDOLL);
		CloseHint(BAG);
		CloseHint(TABS);
		CloseHint(STATS);
		CloseHint(STATS_DETAILS);
		CloseHint(EQUIPPING);
		
		super.OnLeaveState(nextStateName);
	}
	
	private final function BlockPanels(block : bool)
	{
		if(block)
		{
			thePlayer.BlockAction(EIAB_FastTravel, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_MeditationWaiting, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenMap, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenCharacterPanel, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenJournal, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenAlchemy, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenGwint, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenFastMenu, 'tutorial_inventory');
			thePlayer.BlockAction(EIAB_OpenGlossary, 'tutorial_inventory');
		}
		else
		{
			thePlayer.UnblockAction(EIAB_FastTravel, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_MeditationWaiting, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenMap, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenCharacterPanel, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenJournal, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenAlchemy, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenGwint, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenFastMenu, 'tutorial_inventory');
			thePlayer.UnblockAction(EIAB_OpenGlossary, 'tutorial_inventory');
		}
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;
		
		if(closedByParentMenu || isClosing)
			return true;
				
		else if(hintName == PAPERDOLL)
		{
			highlights.Resize(1);
			highlights[0].x = 0.045;
			highlights[0].y = 0.21;
			highlights[0].width = 0.295;
			highlights[0].height = 0.4;
			
			ShowHint(BAG, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, , highlights);
		}
		else if(hintName == BAG)
		{
			highlights.Resize(1);
			highlights[0].x = 0.05;
			highlights[0].y = 0.13;
			highlights[0].width = 0.26;
			highlights[0].height = 0.12;
			
			ShowHint(TABS, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, , highlights);
		}
		else if(hintName == TABS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.67;
			highlights[0].y = 0.72;
			highlights[0].width = 0.27;
			highlights[0].height = 0.18;
			
			ShowHint(STATS, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, , highlights);
		}
		else if(hintName == STATS)
		{
		
			ShowHint(EQUIPPING, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y);
		}
		else if(hintName == EQUIPPING)
		{
			QuitState();
		}
	}
}

exec function tut_inv()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('inventory', '');
}