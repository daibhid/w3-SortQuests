/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/





class IngameMenuStructureCreator
{
	public var parentMenu 				: CR4IngameMenu;
	public var m_flashValueStorage		: CScriptedFlashValueStorage;
	public var m_flashConstructor 		: CScriptedFlashObject;
	
	protected function CreateMenuItem(id : string, label : string, tag : int, type : int, createEmptyChildList : bool, optional listTitle : string) : CScriptedFlashObject
	{
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_label : string;
		
		l_label = GetLocStringByKeyExt(label);
		
		if (l_label == "")
		{
			l_label = "#" + label;
		}
		
		l_DataFlashObject = m_flashConstructor.CreateFlashObject("red.game.witcher3.menus.mainmenu.IngameMenuEntry");
		l_DataFlashObject.SetMemberFlashString( "id", id);
		l_DataFlashObject.SetMemberFlashString(  "label", l_label );		
		l_DataFlashObject.SetMemberFlashUInt(  "tag", tag );
		l_DataFlashObject.SetMemberFlashUInt( "type", type );	
		
		if (listTitle)
		{
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt(listTitle) );
		}
		else
		{
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt(label) );
		}
		
		if (createEmptyChildList)
		{
			l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		}
		
		return l_DataFlashObject;
	}
	
	function PopulateMenuData() : CScriptedFlashArray
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_subDataFlashObject	: CScriptedFlashObject;
		var l_titleString			: string;
		
		l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		if (parentMenu.isMainMenu)
		{
			if (hasSaveDataToLoad())
			{
				
				l_DataFlashObject = CreateMenuItem("continue", "panel_continue", NameToFlashUInt('Continue'), IGMActionType_LoadLastSave, true);
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
				
			}
			
			
			if ((theGame.CanStartStandaloneDLC('ep1') && theGame.GetDLCManager().IsEP1Available()) || theGame.GetDLCManager().IsNewGamePlusAvailable())
			{
				l_DataFlashObject = CreateMenuItem("NewGame", "panel_newgame", NameToFlashUInt('NewGame'), IGMActionType_MenuHolder, false, "panel_newgame");
				l_ChildMenuFlashArray = CreateNewGameListArray();
			}
			else
			{
				l_DataFlashObject = CreateMenuItem("NewGame", "panel_newgame", NameToFlashUInt('NewGame'), IGMActionType_MenuHolder, false, "newgame_difficulty");
				l_ChildMenuFlashArray = CreateDifficultyListArray(0);
			}
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		else
		{
			
			l_DataFlashObject = CreateMenuItem("resume", "panel_resume", NameToFlashUInt('Resume'), IGMActionType_Close, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		if (!parentMenu.isMainMenu)
		{
			
			if (theGame.GetPlatform() == Platform_Xbox1)
			{
				l_titleString = "panel_mainmenu_savegame_x1";
			}
			else if (theGame.GetPlatform() == Platform_PS4)
			{
				l_titleString = "panel_mainmenu_savegame_ps4";
			}
			else
			{
				l_titleString = "panel_mainmenu_savegame";
			}	
			
			l_DataFlashObject = CreateMenuItem("mainmenu_savegame", l_titleString, NameToFlashUInt('SaveGame'), IGMActionType_Save, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		if (hasSaveDataToLoad())
		{
			
			l_DataFlashObject = CreateMenuItem("mainmenu_loadgame", "panel_mainmenu_loadgame", NameToFlashUInt('LoadGame'), IGMActionType_Load, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		
		l_DataFlashObject = CreateMenuItem("mainmenu_options", "panel_mainmenu_options", NameToFlashUInt('Options'), IGMActionType_Options, true);
		l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
		
		
		if (!parentMenu.isMainMenu)
		{
			if( thePlayer.IsActionAllowed( EIAB_OpenGlossary ))
			{
				
				l_DataFlashObject = CreateMenuItem("mainmenu_Tutorials", "panel_mainmenu_tutorials", NameToFlashUInt('Tutorials'), IGMActionType_Tutorials, true);
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
				
			}
			
			
			if (theGame.GetGwintManager().GetHasDoneTutorial() || theGame.GetGwintManager().HasLootedCard())
			{
				l_DataFlashObject = CreateMenuItem("mainmenu_Gwent", "panel_mainmenu_gwent", NameToFlashUInt('Gwent'), IGMActionType_Gwint, true);
				l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			}
			
			
		}
		
		
		if (theGame.GetPlatform() == Platform_Xbox1)
		{
			l_DataFlashObject = CreateMenuItem("mainmenu_help", "panel_mainmenu_help", NameToFlashUInt('Help'), IGMActionType_Help, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
		}
		
		
		if (!parentMenu.isMainMenu)
		{
			
			l_DataFlashObject = CreateMenuItem("button_common_quittomainmenu", "panel_button_common_quittomainmenu", NameToFlashUInt('DLC'), IGMActionType_Quit, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		else if (theGame.GetDLCManager().IsAnyDLCAvailable())
		{
			
			l_DataFlashObject = CreateMenuItem("panel_dlc", "panel_dlc", NameToFlashUInt('QuitGame'), IGMActionType_MenuHolder, false);
			l_ChildMenuFlashArray = CreateDLCSubElements();
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		if (theGame.GetPlatform() == Platform_PC)
		{
			
			l_DataFlashObject = CreateMenuItem("button_closeGame", "menu_main_quit", NameToFlashUInt('CloseGame'), IGMActionType_CloseGame, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		if ( parentMenu.isMainMenu && theGame.IsDebugQuestMenuEnabled() && !theGame.IsFinalBuild() )
		{
			
			l_DataFlashObject = CreateMenuItem("debug_menu", "DBG Quest Menu", NameToFlashUInt('DebugMenu'), IGMActionType_DebugStartQuest, true);
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
			
		}
		
		return l_DataFlashArray;
	}
	
	protected function CreateNewGameListArray() : CScriptedFlashArray
	{
		var l_optionChildList 		: CScriptedFlashArray;
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		l_optionChildList = m_flashValueStorage.CreateTempFlashArray();
		
		
		l_DataFlashObject = CreateMenuItem("NewGame", "new_game_tw3", NameToFlashUInt('NewGame'), IGMActionType_MenuHolder, false, "newgame_difficulty");
		l_ChildMenuFlashArray = CreateDifficultyListArray(0);
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		l_DataFlashObject.SetMemberFlashString( "description", GetLocStringByKeyExt("panel_mainmenu_start_newgame_description") );
		
		l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		
		
		
		if (theGame.CanStartStandaloneDLC('ep1') && theGame.GetDLCManager().IsEP1Available())
		{
			l_DataFlashObject = CreateMenuItem("NewGame", "new_game_ep1", NameToFlashUInt('NewGameEP1'), IGMActionType_MenuHolder, false, "newgame_difficulty");
			l_ChildMenuFlashArray = CreateDifficultyListArray(IGMC_EP1_Save);
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			l_DataFlashObject.SetMemberFlashString( "description", GetLocStringByKeyExt("panel_mainmenu_start_ep1_description") );
			
			l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		}
		
		
		if (theGame.GetDLCManager().IsNewGamePlusAvailable())
		{
			l_DataFlashObject = CreateMenuItem("NewGame", "newgame_plus", NameToFlashUInt('NewGamePlus'), IGMActionType_MenuHolder, false, "newgame_difficulty");
			l_ChildMenuFlashArray = CreateDifficultyListArray(IGMC_New_game_plus);
			l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
			l_DataFlashObject.SetMemberFlashString( "description", GetLocStringByKeyExt("panel_mainmenu_start_ngplus_description") );
			l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		}
		
		return l_optionChildList;
	}
	
	protected function CreateDifficultyListArray(initialTag:int) : CScriptedFlashArray
	{
		var l_optionChildList : CScriptedFlashArray;
		
		l_optionChildList = m_flashValueStorage.CreateTempFlashArray();
		
		AddDifficulyOptionItem(initialTag, EDM_Easy, l_optionChildList);
		AddDifficulyOptionItem(initialTag, EDM_Medium, l_optionChildList);
		AddDifficulyOptionItem(initialTag, EDM_Hard, l_optionChildList);
		AddDifficulyOptionItem(initialTag, EDM_Hardcore, l_optionChildList);
		
		return l_optionChildList;
	}
	
	protected function AddDifficulyOptionItem(tag:int, difficulty:EDifficultyMode, parentArray:CScriptedFlashArray):void
	{
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var displayName				: string;
		var descriptionText			: string;
		
		var lastHolder 				: bool;
		
		if ((tag & IGMC_EP1_Save) == IGMC_EP1_Save)
		{
			lastHolder = true;
		}
		else
		{
			lastHolder = false;
		}
		
		switch (difficulty)
		{
		case EDM_Easy:
			displayName = "panel_mainmenu_dificulty_easy_title";
			descriptionText = "panel_mainmenu_dificulty_easy_description";
			break;
		case EDM_Medium:
			displayName = "panel_mainmenu_dificulty_normal_title";
			descriptionText = "panel_mainmenu_dificulty_normaldescription_description";
			break;
		case EDM_Hard:
			displayName = "panel_mainmenu_dificulty_hard_title";
			descriptionText = "panel_mainmenu_dificulty_hard_description";
			break;
		case EDM_Hardcore:
			displayName = "panel_mainmenu_dificulty_hardcore_title";
			descriptionText = "panel_mainmenu_dificulty_hardcore_description";
			break;
		}
		
		tag += difficulty;
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_Tutorials");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", tag );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt(displayName) );
		l_DataFlashObject.SetMemberFlashString(  "description", GetLocStringByKeyExt(descriptionText) );
		
		
		if (lastHolder)
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_NewGame );
		}
		else
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
		}
		
		l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
		if ((tag & IGMC_New_game_plus) == IGMC_New_game_plus)
		{
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_import") );
			AddNewgameSimulateImportOption(tag, l_ChildMenuFlashArray);
		}
		else if (!lastHolder)
		{
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_tutorials") );
			AddNewgameTutorialOption(tag, l_ChildMenuFlashArray);
		}
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		parentArray.PushBackFlashObject(l_DataFlashObject);
	}
	
	protected function AddNewgameTutorialOption(tag : int, parentArray : CScriptedFlashArray) : void
	{
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var currentTag : int;
		
		
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_Tutorials");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", 1 );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_option_value_on") );
		l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_import") );
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
		
		l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
		currentTag = tag;
		currentTag += IGMC_Tutorials_On;
		AddNewgameSimulateImportOption(currentTag, l_ChildMenuFlashArray);
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		parentArray.PushBackFlashObject(l_DataFlashObject);
		
		
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_Tutorials");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", 0 );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_option_value_off") );
		l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_import") );
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
		
		l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
		currentTag = tag;
		AddNewgameSimulateImportOption(currentTag, l_ChildMenuFlashArray);
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		parentArray.PushBackFlashObject(l_DataFlashObject);
	}
	
	protected function AddNewgameSimulateImportOption(tag:int, parentArray : CScriptedFlashArray) : void
	{
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var savesToImport : array< SSavegameInfo >;
		var currentTag : int;
		
		
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_simulate_on");
		
		currentTag = tag;
		currentTag += IGMC_Simulate_Import;
		l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_option_value_on") );
		
		if ((tag & IGMC_New_game_plus) == IGMC_New_game_plus)
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_plus") );
			AddNewGamePlusOption(currentTag, l_ChildMenuFlashArray);
		}
		else
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_NewGame );
		}
		
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		parentArray.PushBackFlashObject(l_DataFlashObject);
		
		
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_simulate_off");
		
		currentTag = tag;
		l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_option_value_off") );	
		
		if ((tag & IGMC_New_game_plus) == IGMC_New_game_plus)
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_MenuHolder );
			l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_plus") );
			AddNewGamePlusOption(currentTag, l_ChildMenuFlashArray);
		}
		else
		{
			l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_NewGame );
		}
		
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		parentArray.PushBackFlashObject(l_DataFlashObject);
		
		
		if (theGame.GetPlatform() == Platform_PC)
		{
			theGame.ListW2SavedGames( savesToImport );
			
			if (savesToImport.Size() != 0)
			{
				currentTag = tag;
				currentTag += IGMC_Import_Save;
				l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
				l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_import_witcher_two");
				l_DataFlashObject.SetMemberFlashUInt(  "tag", currentTag );
				l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_importsave") );
	
				if ((tag & IGMC_New_game_plus) == IGMC_New_game_plus)
				{
					l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_ImportSave );
					l_DataFlashObject.SetMemberFlashString( "listTitle", GetLocStringByKeyExt("newgame_plus") );
					AddNewGamePlusOption(currentTag, l_ChildMenuFlashArray);
				}
				else
				{
					l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_ImportSave );
				}
				
				l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
				parentArray.PushBackFlashObject(l_DataFlashObject);
			}
		}
	}
	
	protected function AddNewGamePlusOption(tag:int, parentArray : CScriptedFlashArray):void
	{
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "panel_common_ok");
		
		l_DataFlashObject.SetMemberFlashUInt(  "tag", tag );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_continue") );
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_NewGamePlus );
		
		l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		parentArray.PushBackFlashObject(l_DataFlashObject);
	}
	
	protected function CreateImortedSaveGamesArray() : CScriptedFlashArray
	{
		var i 				: int;
		var flashObject		: CScriptedFlashObject;
		var savedGames		: CScriptedFlashArray;
		var savedGamesList	: array< SSavegameInfo >;
	
		savedGames = m_flashValueStorage.CreateTempFlashArray();
		
		theGame.ListW2SavedGames( savedGamesList );
		for ( i = 0; i < savedGamesList.Size(); i += 1 )
		{
			flashObject = m_flashValueStorage.CreateTempFlashObject();
			flashObject.SetMemberFlashString( "id", savedGamesList[ i ].filename );
			flashObject.SetMemberFlashString( "label", savedGamesList[ i ].filename );
			flashObject.SetMemberFlashString( "tag", i );
			flashObject.SetMemberFlashString( "iconPath", "" );
			flashObject.SetMemberFlashString( "description", "");
			savedGames.PushBackFlashObject( flashObject );
		}	
		
		return savedGames;
	}
	
	protected function CreateDLCSubElements() : CScriptedFlashArray
	{
		var l_optionChildList 	: CScriptedFlashArray;
		var i				  	: int;
		var dlcOptionIndex		: int;
		var l_DataFlashObject	: CScriptedFlashObject;
		var hasChildOptions		: bool;
		var inGameConfigWrapper	: CInGameConfigWrapper;
		var groupName			: name;
		
		hasChildOptions = false;
		dlcOptionIndex = -1;
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		
		l_optionChildList = m_flashValueStorage.CreateTempFlashArray();
		
		l_DataFlashObject = CreateMenuItem("installed_dlc", "panel_mainmenu_installed_dlc", NameToFlashUInt('InstalledDLC'), IGMActionType_InstalledDLC, true);
		l_optionChildList.PushBackFlashObject(l_DataFlashObject);
		
		for (i = 0; i < inGameConfigWrapper.GetGroupsNum(); i += 1)
		{
			groupName = inGameConfigWrapper.GetGroupName(i);
			if (groupName == 'DLC')
			{
				dlcOptionIndex = i;
				break;
			}
		}
		
		if (dlcOptionIndex != -1)
		{
			l_DataFlashObject = CreateMenuItem("dlc_options", "panel_mainmenu_options", NameToFlashUInt('DLCOptions'), IGMActionType_MenuLastHolder, true);
			hasChildOptions = IngameMenu_FillSubMenuOptionsList(m_flashValueStorage, dlcOptionIndex, 'DLC', l_DataFlashObject);
			if (hasChildOptions)
			{
				l_optionChildList.PushBackFlashObject(l_DataFlashObject);
			}
		}
		
		return l_optionChildList;
	}
}