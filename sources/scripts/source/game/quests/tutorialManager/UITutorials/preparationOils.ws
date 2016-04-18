/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state Oils in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var CAN_EQUIP, SELECT_TAB, EQUIP_OIL, ON_EQUIPPED, OILS_JOURNAL_ENTRY : name;
	private var isClosing : bool;
	
		default CAN_EQUIP 			= 'TutorialOilCanEquip1';
		default SELECT_TAB 			= 'TutorialOilCanEquip2';
		default EQUIP_OIL 			= 'TutorialOilCanEquip3';
		default ON_EQUIPPED 		= 'TutorialOilEquipped';
		default OILS_JOURNAL_ENTRY 	= 'TutorialJournalOils';	
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		ShowHint(CAN_EQUIP, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y);
		theGame.GetTutorialSystem().ActivateJournalEntry(OILS_JOURNAL_ENTRY);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(CAN_EQUIP);
		CloseHint(SELECT_TAB);
		CloseHint(EQUIP_OIL);
		CloseHint(ON_EQUIPPED);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		theGame.GetTutorialSystem().MarkMessageAsSeen(ON_EQUIPPED);
		
		FactsAdd("tut_ui_prep_oils");
		
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
		else if(hintName == ON_EQUIPPED)
		{
			QuitState();
		}
	}
	
	event OnOilTabSelected()
	{
		CloseHint(SELECT_TAB);
		theGame.GetTutorialSystem().MarkMessageAsSeen(SELECT_TAB);
		ShowHint(EQUIP_OIL, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y, ETHDT_Infinite);
	}
	
	event OnOilApplied()
	{
		CloseHint(EQUIP_OIL);
		ShowHint(ON_EQUIPPED, theGame.params.TUT_POS_INVENTORY_X, theGame.params.TUT_POS_INVENTORY_Y);
		theGame.GetTutorialSystem().MarkMessageAsSeen(ON_EQUIPPED);
	}
}

exec function tut_oil()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('OilsPreparation', '');
}