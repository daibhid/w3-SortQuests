/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state Map in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_MAP, DESCRIPTION, JUMP_TO_OBJECTIVE, NAVIGATE, QUEST_PINS : name;
	private var isClosing : bool;
	
		default OPEN_MAP 			= 'TutorialMapOpenMap';
		default DESCRIPTION 		= 'TutorialMapDescription';
		default JUMP_TO_OBJECTIVE 	= 'TutorialMapJumpToObjective';
		default NAVIGATE 			= 'TutorialMapNavigate';
		default QUEST_PINS 			= 'TutorialMapQuestPins';
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		
		CloseHint(OPEN_MAP);
		
		ShowHint(DESCRIPTION, 0.63f, 0.5f, ETHDT_Input);	
	}
	
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(DESCRIPTION);
		CloseHint(JUMP_TO_OBJECTIVE);
		CloseHint(NAVIGATE);
		CloseHint(QUEST_PINS);
		
		super.OnLeaveState(nextStateName);
	}	
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		if(closedByParentMenu || isClosing)
		{
			return true;
		}		
		else if(hintName == DESCRIPTION)
		{
			ShowHint(JUMP_TO_OBJECTIVE, 0.63f, 0.5f, ETHDT_Input);
		}
		else if(hintName == JUMP_TO_OBJECTIVE)
		{
			ShowHint(NAVIGATE, 0.63f, 0.5f, ETHDT_Input);
		}
		else if(hintName == NAVIGATE)
		{
			ShowHint(QUEST_PINS, 0.63f, 0.5f, ETHDT_Input);
		}
		else if(hintName == QUEST_PINS)
		{
			QuitState();
		}
	}
}
