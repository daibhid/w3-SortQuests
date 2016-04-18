/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state ArmorUpgrades in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var TAB, UPGRADE, ITEM : name;
	
		default TAB 		= 'TutorialArmorSocketsSelectTab';
		default UPGRADE 	= 'TutorialArmorSocketsSelectUpgrade';
		default ITEM 		= 'TutorialArmorSocketsSelectItem';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		var currentTab : int;
		
		super.OnEnterState(prevStateName);
		
		currentTab = ( (CR4InventoryMenu) ((CR4MenuBase)theGame.GetGuiManager().GetRootMenu()).GetLastChild() ).GetCurrentlySelectedTab();
		
		if(currentTab != InventoryMenuTab_Weapons)
		{
			highlights.Resize(1);
			highlights[0].x = 0.045;
			highlights[0].y = 0.145;
			highlights[0].width = 0.06;
			highlights[0].height = 0.09;
				
			ShowHint(TAB, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite, highlights);
		}
		else
		{
			ShowHint(UPGRADE, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
		}
	}
			
	event OnLeaveState( nextStateName : name )
	{
		CloseHint(TAB);
		CloseHint(UPGRADE);
		CloseHint(ITEM);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(TAB);
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnSelectingArmor()
	{
		CloseHint(UPGRADE);
		ShowHint(ITEM, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnSelectingArmorAborted()
	{
		CloseHint(ITEM);
		ShowHint(UPGRADE, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnUpgradedItem()
	{
		QuitState();
	}
	
	event OnTabSelected()
	{
		CloseHint(TAB);
		ShowHint(UPGRADE, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
	}
}

exec function tut_arm_upg()
{
	thePlayer.inv.AddAnItem('Steel plate',3);
	GetWitcherPlayer().AddPoints(EExperiencePoint, 50000, false );
	thePlayer.inv.AddAnItem('Medium armor 11',1);
}