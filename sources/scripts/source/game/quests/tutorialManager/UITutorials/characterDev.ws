/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state CharacterDevelopment in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var OPEN_CHAR_DEV, LEVELING, SKILLS, BUY_SKILL, SKILL_EQUIPPING, EQUIP_SKILL, SKILL_UNEQUIPPING, GROUPS : name;
	private var isClosing : bool;
	
		default OPEN_CHAR_DEV 		= 'TutorialCharDevOpen';
		default LEVELING 			= 'TutorialCharDevGainingLevels';
		default SKILLS 				= 'TutorialCharDevSkillPoints';
		default BUY_SKILL 			= 'TutorialCharDevBuySkill';
		default SKILL_EQUIPPING 	= 'TutorialCharDevSkillEquipping';
		default EQUIP_SKILL 		= 'TutorialCharDevEquipSkill';
		default SKILL_UNEQUIPPING 	= 'TutorialCharDevSkillUnequipping';
		default GROUPS				= 'TutorialCharDevGroups';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		
		CloseHint(OPEN_CHAR_DEV);
		ShowHint(LEVELING, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y);
		
		
		theGame.GetTutorialSystem().uiHandler.UnregisterUIHint('CharacterDevelopmentFastMenu');
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(OPEN_CHAR_DEV);
		CloseHint(LEVELING);
		CloseHint(SKILLS);
		CloseHint(BUY_SKILL);
		CloseHint(SKILL_EQUIPPING);
		CloseHint(EQUIP_SKILL);
		CloseHint(SKILL_UNEQUIPPING);
		CloseHint(GROUPS);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(BUY_SKILL);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_SKILL);
		
		super.OnLeaveState(nextStateName);
	}
		
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == LEVELING)
		{
			highlights.Resize(1);
			highlights[0].x = 0.03;
			highlights[0].y = 0.19;
			highlights[0].width = 0.23;
			highlights[0].height = 0.15;
						
			ShowHint(SKILLS, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, , highlights);
		}
		else if(hintName == SKILLS)
		{
			highlights.Resize(1);
			
					
			highlights[0].x = 0.085;
			highlights[0].y = 0.13;
			highlights[0].width = 0.155;
			highlights[0].height = 0.12;
			
			ShowHint(GROUPS, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, , highlights);
		}
		else if(hintName == GROUPS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.1;
			highlights[0].y = 0.285;
			highlights[0].width = 0.21;
			highlights[0].height = 0.35;
			
			ShowHint(BUY_SKILL, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Infinite, highlights);
		}
		else if(hintName == SKILL_EQUIPPING)
		{
			highlights.Resize(1);
			highlights[0].x = 0.43;
			highlights[0].y = 0.143;
			highlights[0].width = 0.08;
			highlights[0].height = 0.3;
			
			ShowHint(EQUIP_SKILL, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Infinite, highlights);
		}
		else if(hintName == SKILL_UNEQUIPPING)
		{
			QuitState();
		}
	}
	
	public final function OnBoughtSkill(skill : ESkill)
	{
		var highlights : array<STutorialHighlight>;
		
		CloseHint(BUY_SKILL);
		theGame.GetTutorialSystem().MarkMessageAsSeen(BUY_SKILL);
		
		highlights.Resize(4);
		
		highlights[0].x = 0.43;
		highlights[0].y = 0.143;
		highlights[0].width = 0.08;
		highlights[0].height = 0.3;
				
		highlights[1].x = 0.52;
		highlights[1].y = 0.143;
		highlights[1].width = 0.08;
		highlights[1].height = 0.3;
				
		highlights[2].x = 0.52;
		highlights[2].y = 0.49;
		highlights[2].width = 0.08;
		highlights[2].height = 0.3;
				
		highlights[3].x = 0.43;
		highlights[3].y = 0.49;
		highlights[3].width = 0.08;
		highlights[3].height = 0.3;
					
		ShowHint(SKILL_EQUIPPING, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, , highlights);
	}
	
	public final function EquippedSkill()
	{
		var i, size : int;
		
		CloseHint(EQUIP_SKILL);
		theGame.GetTutorialSystem().MarkMessageAsSeen(EQUIP_SKILL);
		ShowHint(SKILL_UNEQUIPPING, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y);
		
		
		size = EnumGetMax('EInputActionBlock')+1;
		for(i=0; i<size; i+=1)
		{
			thePlayer.UnblockAction(i, 'lvlup_tutorial');
		}
	}
}

exec function tut_chd()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('characterDev', '');
}