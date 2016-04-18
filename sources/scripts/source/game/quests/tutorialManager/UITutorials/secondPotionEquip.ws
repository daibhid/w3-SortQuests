/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state SecondPotionEquip in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var CAN_EQUIP, SELECT_TAB, EQUIP_POTION : name;
	private var isClosing : bool;
	
		default CAN_EQUIP 		= 'TutorialPotionCanEquip1';
		default SELECT_TAB 		= 'TutorialPotionCanEquip2';
		default EQUIP_POTION 	= 'TutorialPotionCanEquip3';
	
	event OnEnterState( prevStateName : name )
	{
		var currentTab : int;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		theGame.GetTutorialSystem().UnmarkMessageAsSeen(EQUIP_POTION);
		
		currentTab = ( (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).GetCurrentlySelectedTab();
		if(currentTab == InventoryMenuTab_Potions)
		{
			OnPotionTabSelected();
		}
		else
		{
			ShowHint(CAN_EQUIP, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y);
		}
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(CAN_EQUIP);
		CloseHint(SELECT_TAB);
		CloseHint(EQUIP_POTION);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(CAN_EQUIP);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_POTION);
		
		GameplayFactsRemove("tutorial_equip_potion");
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;		
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == CAN_EQUIP)
		{
			highlights.Resize(1);
			highlights[0].x = 0.09;
			highlights[0].y = 0.145;
			highlights[0].width = 0.06;
			highlights[0].height = 0.09;
			
			ShowHint(SELECT_TAB, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite, highlights);
		}		
	}
	
	event OnPotionTabSelected()
	{
		CloseHint(SELECT_TAB);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		
		ShowHint(EQUIP_POTION, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnPotionEquipped(potionItemName : name)
	{
		QuitState();
	}
}