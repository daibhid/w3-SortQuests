/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state Crafting in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SCHEMATICS, ITEM_DESCRIPTION, COMPONENTS, PRICE, CRAFTSMEN, DISMANTLING : name;
	private var isClosing : bool;
	
		default SCHEMATICS 			= 'TutorialCraftingSchematicsList';
		default ITEM_DESCRIPTION 	= 'TutorialCraftingItemDescription';
		default COMPONENTS 			= 'TutorialCraftingComponents';
		default PRICE 				= 'TutorialCraftingPrice';
		default CRAFTSMEN 			= 'TutorialCraftingCraftsmen';
		default DISMANTLING			= 'TutorialCraftingDismantling';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		highlights.Resize(1);
		highlights[0].x = 0.06;
		highlights[0].y = 0.14;
		highlights[0].width = 0.33;
		highlights[0].height = 0.8;
			
		ShowHint(SCHEMATICS, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, ETHDT_Input, highlights);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SCHEMATICS);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(SCHEMATICS);
		CloseHint(ITEM_DESCRIPTION);
		CloseHint(COMPONENTS);
		CloseHint(PRICE);
		CloseHint(CRAFTSMEN);
		CloseHint(DISMANTLING);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SCHEMATICS);
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == SCHEMATICS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.68;
			highlights[0].y = 0.14;
			highlights[0].width = 0.29;
			highlights[0].height = 0.375;
			
			ShowHint(ITEM_DESCRIPTION, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, ETHDT_Input, highlights);
		}
		else if(hintName == ITEM_DESCRIPTION)
		{
			highlights.Resize(1);
			highlights[0].x = 0.4;
			highlights[0].y = 0.19;
			highlights[0].width = 0.275;
			highlights[0].height = 0.48;
			
			ShowHint(COMPONENTS, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, ETHDT_Input, highlights);
		}
		else if(hintName == COMPONENTS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.42;
			highlights[0].y = 0.7;
			highlights[0].width = 0.25;
			highlights[0].height = 0.2;
			
			ShowHint(PRICE, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, ETHDT_Input, highlights);
		}
		else if(hintName == PRICE)
		{
			ShowHint(CRAFTSMEN, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, ETHDT_Input);
		}
		else if(hintName == CRAFTSMEN)
		{
			ShowHint(DISMANTLING, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, ETHDT_Input);
		}
		else if(hintName == DISMANTLING)
		{
			QuitState();
		}
	}
}

exec function tut_craft()
{
	GetWitcherPlayer().AddCraftingSchematic('No Mans Land sword 3 schematic');
	thePlayer.inv.AddAnItem('Steel ingot', 6);
	thePlayer.inv.AddAnItem('Leather straps', 8);
	thePlayer.inv.AddAnItem('Timber', 10);
	thePlayer.inv.AddAnItem('Oil', 10);
	thePlayer.inv.AddAnItem('Hardened timber', 5);
	thePlayer.AddMoney(45);
}