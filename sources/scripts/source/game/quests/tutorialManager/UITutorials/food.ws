/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state Food in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var SELECT_TAB, SELECT_FOOD, EQUIP_FOOD, USAGE : name;
	private var isClosing : bool;	
	
		default SELECT_TAB 		= 'TutorialFoodSelectTab';
		default SELECT_FOOD 	= 'TutorialFoodSelectFood';
		default EQUIP_FOOD 		= 'TutorialFoodEquip';
		default USAGE 			= 'TutorialFoodUsage';
		
	event OnEnterState( prevStateName : name )
	{
		var witcher : W3PlayerWitcher;
		var currentTab : int;
		var hasFood : bool;
		var item : SItemUniqueId;
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		hasFood = false;
		witcher = GetWitcherPlayer();
		
		
		if(witcher.GetItemEquippedOnSlot(EES_Potion1, item))
		{
			if(witcher.inv.IsItemFood(item))
				hasFood = true;
		}
		
		if(!hasFood && witcher.GetItemEquippedOnSlot(EES_Potion2, item))
		{
			if(witcher.inv.IsItemFood(item))
				hasFood = true;
		}
		
		if(!hasFood && witcher.GetItemEquippedOnSlot(EES_Potion3, item))
		{
			if(witcher.inv.IsItemFood(item))
				hasFood = true;
		}
		
		if(!hasFood && witcher.GetItemEquippedOnSlot(EES_Potion4, item))
		{
			if(witcher.inv.IsItemFood(item))
				hasFood = true;
		}
		
		if(hasFood)
		{
			ShowHint(USAGE, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y-0.1f);
		}
		else
		{
			
			if( witcher.inv.GetItemQuantityByTag('Edibles') == 0 )
			{
				witcher.inv.AddAnItem('Bread', 1, true, false);
			}
			
			currentTab = ( (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).GetCurrentlySelectedTab();
			if(currentTab == InventoryMenuTab_Potions)
			{
				OnPotionTabSelected();
			}
			else
			{
				highlights.Resize(1);
				highlights[0].x = 0.09;
				highlights[0].y = 0.145;
				highlights[0].width = 0.06;
				highlights[0].height = 0.09;
		
				ShowHint(SELECT_TAB, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y-0.1f, ETHDT_Infinite, highlights);
			}
		}		
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(SELECT_TAB);
		CloseHint(SELECT_FOOD);
		CloseHint(EQUIP_FOOD);
		CloseHint(USAGE);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;		
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == USAGE)
		{
			QuitState();
		}
	}
	
	event OnPotionTabSelected()
	{
		CloseHint(SELECT_TAB);
		
		ShowHint(SELECT_FOOD, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y-0.1f, ETHDT_Infinite);
	}
	
	event OnSelectedItem(itemId : SItemUniqueId)
	{
		if(IsCurrentHint(SELECT_FOOD) && thePlayer.inv.IsItemFood(itemId))
		{
			
			CloseHint(SELECT_FOOD);
			ShowHint(EQUIP_FOOD, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y-0.1f, ETHDT_Infinite);
		}
		else if(IsCurrentHint(EQUIP_FOOD) && !thePlayer.inv.IsItemFood(itemId))
		{
			
			CloseHint(EQUIP_FOOD);
			ShowHint(SELECT_FOOD, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y-0.1f, ETHDT_Infinite);
		}
	}
	
	event OnFoodEquipped()
	{
		CloseHint(EQUIP_FOOD);
		ShowHint(USAGE, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y-0.1f);
	}
}