/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state CharDevMutagens in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var DESCRIPTION, SELECT_TAB, EQUIP, BONUSES, MATCH_SKILL_COLOR, MULTIPLE_SKILLS, WRONG_COLOR, POTIONS, MUTAGENS_JOURNAL : name;
	private var isClosing : bool;
	private var savedEquippedSkills : array<STutorialSavedSkill>;					
	
		default DESCRIPTION 		= 'TutorialMutagenDescription';
		default SELECT_TAB			= 'TutorialMutagenSelectTab';
		default EQUIP				= 'TutorialMutagenEquip';
		default BONUSES				= 'TutorialMutagenBonuses';
		default MATCH_SKILL_COLOR	= 'TutorialMutagenMatchSkillColor';
		default MULTIPLE_SKILLS		= 'TutorialMutagenMultipleSkills';
		default WRONG_COLOR			= 'TutorialMutagenWrongColor';
		default POTIONS				= 'TutorialMutagenPotions';
		default MUTAGENS_JOURNAL	= 'TutorialJournalCharDevMutagens';
		
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		ShowHint(DESCRIPTION, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Input);		
		
		theGame.GetTutorialSystem().ActivateJournalEntry(MUTAGENS_JOURNAL);
	}
			
	event OnLeaveState( nextStateName : name )
	{		
		isClosing = true;
		
		CloseHint(DESCRIPTION);
		CloseHint(SELECT_TAB);
		CloseHint(EQUIP);
		CloseHint(BONUSES);
		CloseHint(MATCH_SKILL_COLOR);
		CloseHint(MULTIPLE_SKILLS);
		CloseHint(WRONG_COLOR);
		CloseHint(POTIONS);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(DESCRIPTION);
		
		GetWitcherPlayer().TutorialMutagensCleanupTempSkills(savedEquippedSkills);
		
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
			highlights[0].x = 0.265;
			highlights[0].y = 0.13;
			highlights[0].width = 0.07;
			highlights[0].height = 0.12;
			
			ShowHint(SELECT_TAB, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Infinite, highlights);
		}
		else if(hintName == EQUIP)
		{
			highlights.Resize(1);
			highlights[0].x = 0.33;
			highlights[0].y = 0.37;
			highlights[0].width = 0.22;
			highlights[0].height = 0.13;
			
			savedEquippedSkills = GetWitcherPlayer().TutorialMutagensUnequipPlayerSkills();
			
			ShowHint(BONUSES, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Input, highlights);
		}
		else if(hintName == BONUSES)
		{
			highlights.Resize(2);
						
			highlights[0].x = 0.33;
			highlights[0].y = 0.37;
			highlights[0].width = 0.22;
			highlights[0].height = 0.13;
			
			highlights[1].x = 0.42;
			highlights[1].y = 0.14;
			highlights[1].width = 0.1;
			highlights[1].height = 0.13;
			
			GetWitcherPlayer().TutorialMutagensEquipOneGoodSkill();
			
			ShowHint(MATCH_SKILL_COLOR, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Input, highlights);
		}
		else if(hintName == MATCH_SKILL_COLOR)
		{
			highlights.Resize(2);
			
			highlights[0].x = 0.33;
			highlights[0].y = 0.37;
			highlights[0].width = 0.22;
			highlights[0].height = 0.13;
			
			highlights[1].x = 0.42;
			highlights[1].y = 0.225;
			highlights[1].width = 0.1;
			highlights[1].height = 0.13;
			
			GetWitcherPlayer().TutorialMutagensEquipOneGoodOneBadSkill();
			
			ShowHint(WRONG_COLOR, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Input, highlights);
		}
		else if(hintName == WRONG_COLOR)
		{
			highlights.Resize(1);
			
			highlights[0].x = 0.33;
			highlights[0].y = 0.37;
			highlights[0].width = 0.22;
			highlights[0].height = 0.13;
			
			GetWitcherPlayer().TutorialMutagensEquipThreeGoodSkills();
			
			ShowHint(MULTIPLE_SKILLS, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Input, highlights);
		}		
		else if(hintName == MULTIPLE_SKILLS)
		{
			ShowHint(POTIONS, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Input);
		}
		else if(hintName == POTIONS)
		{
			QuitState();
		}
	}

	public final function SelectedMutagensTab()
	{
		var highlights : array<STutorialHighlight>;
		
		if(IsCurrentHint(SELECT_TAB))
		{
			CloseHint(SELECT_TAB);
			
			highlights.Resize(2);
			highlights[0].x = 0.09;
			highlights[0].y = 0.285;
			highlights[0].width = 0.235;
			highlights[0].height = 0.38;
			
			highlights[1].x = 0.355;
			highlights[1].y = 0.21;
			highlights[1].width = 0.1;
			highlights[1].height = 0.16;
						
			ShowHint(EQUIP, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Infinite, highlights);
		}
	}
	
	public final function EquippedMutagen()
	{
		var highlights : array<STutorialHighlight>;
		
		CloseHint(EQUIP);
		
		highlights.Resize(1);		
		highlights[0].x = 0.03;
		highlights[0].y = 0.25;
		highlights[0].width = 0.23;
		highlights[0].height = 0.15;
			
		ShowHint(BONUSES, theGame.params.TUT_POS_CHAR_DEV_X, theGame.params.TUT_POS_CHAR_DEV_Y, ETHDT_Input, highlights);
	}
}




exec function tut_ch_m(optional color : ESkillColor, optional equipSkillsFirst : bool)
{
	GetWitcherPlayer().AddPoints(EExperiencePoint, 1500, false );
	
	if(equipSkillsFirst)
	{
		skilleq_internal(S_Alchemy_s01, 1);
		skilleq_internal(S_Alchemy_s02, 2);
		skilleq_internal(S_Sword_s01, 3);
	}
	
	if(color == SC_None || color == SC_Yellow)
		color = SC_Green;
		
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
		
	if(color == SC_Green)
		thePlayer.inv.AddAnItem('Ekimma mutagen',1);
	else if(color == SC_Blue)
		thePlayer.inv.AddAnItem('Fogling 1 mutagen',1);
	else if(color == SC_Red)
		thePlayer.inv.AddAnItem('Doppler mutagen',1);
	
	TutorialScript('charDevMutagens', '');
}