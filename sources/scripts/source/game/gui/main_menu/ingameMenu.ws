/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




enum InGameMenuActionType
{
	IGMActionType_CommonMenu 		= 0,
	IGMActionType_Close		 		= 1,
	IGMActionType_MenuHolder 		= 2,
	IGMActionType_MenuLastHolder	= 3,
	IGMActionType_Load 				= 4,
	IGMActionType_Save 				= 5,
	IGMActionType_Quit			 	= 6,
	IGMActionType_Preset 			= 7,
	IGMActionType_Toggle 			= 8,
	IGMActionType_List 				= 9,
	IGMActionType_Slider 			= 10,
	IGMActionType_LoadLastSave 		= 11,
	IGMActionType_Tutorials 		= 12,
	IGMActionType_Credits 			= 13,
	IGMActionType_Help 				= 14,
	IGMActionType_Controls 			= 15,
	IGMActionType_ControllerHelp 	= 16,
	IGMActionType_NewGame 			= 17,
	IGMActionType_CloseGame 		= 18,
	IGMActionType_UIRescale 		= 19,
	IGMActionType_Gamma 			= 20,
	IGMActionType_DebugStartQuest 	= 21,
	IGMActionType_Gwint 			= 22,
	IGMActionType_ImportSave 		= 23,
	IGMActionType_KeyBinds 			= 24,
	IGMActionType_Back				= 25,
	IGMActionType_NewGamePlus		= 26,
	IGMActionType_InstalledDLC		= 27,
	
	IGMActionType_Options 			= 100
};

enum EIngameMenuConstants
{
	IGMC_Difficulty_mask	= 	7,   
	IGMC_Tutorials_On		= 	1024,
	IGMC_Simulate_Import 	= 	2048,
	IGMC_Import_Save		= 	4096,
	IGMC_EP1_Save			=   8192,
	IGMC_New_game_plus		=   16384
}

struct newGameConfig
{
	var tutorialsOn : bool;
	var difficulty : int;
	var simulate_import : bool;
	var import_save_index : int;
}

class CR4IngameMenu extends CR4MenuBase
{
	protected var mInGameConfigWrapper	: CInGameConfigWrapper;
	protected var inGameConfigBufferedWrapper : CInGameConfigBufferedWrapper;
	
	protected var currentNewGameConfig 	: newGameConfig;
	
	private var m_fxNavigateBack		: CScriptedFlashFunction;
	private var m_fxSetIsMainMenu		: CScriptedFlashFunction;
	private var m_fxSetCurrentUsername  : CScriptedFlashFunction;
	private var m_fxSetVersion			: CScriptedFlashFunction;
	private var m_fxShowHelp			: CScriptedFlashFunction;
	private var m_fxSetVisible			: CScriptedFlashFunction;
	private var m_fxSetPanelMode		: CScriptedFlashFunction;
	private var m_fxRemoveOption		: CScriptedFlashFunction;
	private var m_fxSetGameLogoLanguage	: CScriptedFlashFunction;
	private var m_fxUpdateOptionValue	: CScriptedFlashFunction;
	private var m_fxUpdateInputFeedback	: CScriptedFlashFunction;
	private var m_fxOnSaveScreenshotRdy : CScriptedFlashFunction;
	private var m_fxSetIgnoreInput		: CScriptedFlashFunction;
	private var m_fxForceEnterCurEntry	: CScriptedFlashFunction;
	private var m_fxForceBackgroundVis	: CScriptedFlashFunction;
	private var m_fxSetHardwareCursorOn : CScriptedFlashFunction;
	
	private var m_fxSetExpansionText	: CScriptedFlashFunction;
	
	protected var loadConfPopup			: W3ApplyLoadConfirmation;
	protected var saveConfPopup			: W3SaveGameConfirmation;
	protected var newGameConfPopup		: W3NewGameConfirmation;
	protected var actionConfPopup		: W3ActionConfirmation;
	protected var deleteConfPopup		: W3DeleteSaveConf;
	protected var diffChangeConfPopup	: W3DifficultyChangeConfirmation;
	protected var isShowingSaveList		: bool; default isShowingSaveList = false;
	protected var isShowingLoadList		: bool; default isShowingLoadList = false;
	
	protected var smartKeybindingEnabled : bool; default smartKeybindingEnabled = true;
	
	public var m_structureCreator		: IngameMenuStructureCreator;
	
	protected var isInLoadselector		: bool; default isInLoadselector = false;
	protected var swapAcceptCancelChanged : bool; default swapAcceptCancelChanged = false;
	protected var EnableUberMovement : bool; default EnableUberMovement = false;
	
	protected var shouldRefreshKinect	: bool; default shouldRefreshKinect = false;
	public var isMainMenu 				: bool;
	
	protected var managingPause		: bool; default managingPause = false;
	
	protected var updateInputDeviceRequired : bool; default updateInputDeviceRequired = false;
	
	protected var hasChangedOption		: bool;
	default hasChangedOption = false;
	
	private var ignoreInput				: bool;
	default ignoreInput = false;
	
	public var disableAccountPicker	: bool;
	default disableAccountPicker = false;
	
	protected var lastSetTag : int;
	
	protected var currentLangValue		: string;
	protected var lastUsedLangValue		: string;
	protected var currentSpeechLang		: string;
	protected var lastUsedSpeechLang	: string;
	private var languageName 			: string;
	
	private var panelMode 				: bool; default panelMode = false;
	
	public var lastSetDifficulty		: int;
	
	event  OnConfigUI()
	{
		var initDataObject 		: W3MenuInitData;
		var commonIngameMenu 	: CR4CommonIngameMenu;
		var commonMainMenu 		: CR4CommonMainMenu;
		var commonMainMenuEp1	: CR4CommonMainMenuEp1;
		var deathScreenMenu 	: CR4DeathScreenMenu;
		var audioLanguageName 	: string;
		var tempLanguageName 	: string;
		var username 			: string;
		var lootPopup			: CR4LootPopup;
		var ep1StatusText		: string;
		var ep2StatusText		: string;
		
		super.OnConfigUI();
		
		m_fxNavigateBack = m_flashModule.GetMemberFlashFunction("handleNavigateBack");
		m_fxSetIsMainMenu = m_flashModule.GetMemberFlashFunction("setIsMainMenu");
		m_fxSetCurrentUsername = m_flashModule.GetMemberFlashFunction("setCurrentUsername");
		m_fxSetVersion = m_flashModule.GetMemberFlashFunction("setVersion");
		m_fxShowHelp = m_flashModule.GetMemberFlashFunction("showHelpPanel");		
		m_fxSetVisible = m_flashModule.GetMemberFlashFunction("setVisible");
		m_fxSetPanelMode = m_flashModule.GetMemberFlashFunction("setPanelMode");
		m_fxRemoveOption = m_flashModule.GetMemberFlashFunction("removeOption"); 
		m_fxSetGameLogoLanguage = m_flashModule.GetMemberFlashFunction( "setGameLogoLanguage" );
		m_fxUpdateOptionValue = m_flashModule.GetMemberFlashFunction( "updateOptionValue" );
		m_fxUpdateInputFeedback = m_flashModule.GetMemberFlashFunction( "updateInputFeedback" );
		m_fxOnSaveScreenshotRdy = m_flashModule.GetMemberFlashFunction( "onSaveScreenshotLoaded" );
		m_fxSetIgnoreInput = m_flashModule.GetMemberFlashFunction( "setIgnoreInput" );
		m_fxForceEnterCurEntry = m_flashModule.GetMemberFlashFunction( "forceEnterCurrentEntry" );
		m_fxForceBackgroundVis = m_flashModule.GetMemberFlashFunction( "setForceBackgroundVisible" );
		m_fxSetHardwareCursorOn = m_flashModule.GetMemberFlashFunction( "setHardwareCursorOn" );
		
		m_fxSetExpansionText = m_flashModule.GetMemberFlashFunction( "setExpansionText" );
		
		m_structureCreator = new IngameMenuStructureCreator in this;
		m_structureCreator.parentMenu = this;
		m_structureCreator.m_flashValueStorage = m_flashValueStorage;
		m_structureCreator.m_flashConstructor = m_flashValueStorage.CreateTempFlashObject();
		
		m_hideTutorial = false;
		m_forceHideTutorial = false;
		disableAccountPicker = false;
		
		theGame.LoadHudSettings();
		
		mInGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		inGameConfigBufferedWrapper = theGame.GetGuiManager().GetInGameConfigBufferedWrapper();
		
		lootPopup = (CR4LootPopup)theGame.GetGuiManager().GetPopup('LootPopup');
			
		if (lootPopup)
		{
			lootPopup.ClosePopup();
		}
		
		commonIngameMenu = (CR4CommonIngameMenu)(GetParent());
		commonMainMenu = (CR4CommonMainMenu)(GetParent());
		commonMainMenuEp1 = (CR4CommonMainMenuEp1)(GetParent());
		deathScreenMenu = (CR4DeathScreenMenu)(GetParent());
		
		if (commonIngameMenu)
		{
			isMainMenu = false;
			panelMode = false;
			mInGameConfigWrapper.ActivateScriptTag('inGame');
			mInGameConfigWrapper.DeactivateScriptTag('mainMenu');
			if ((!thePlayer.IsAlive() && !thePlayer.OnCheckUnconscious()) || theGame.HasBlackscreenRequested() || theGame.IsDialogOrCutscenePlaying())
			{
				CloseMenu();
				return true;
			}
		}
		else if (commonMainMenu || commonMainMenuEp1)
		{
			isMainMenu = true;
			panelMode = false;
			mInGameConfigWrapper.ActivateScriptTag('mainMenu');
			mInGameConfigWrapper.DeactivateScriptTag('inGame');
			
			if (theGame.GetDLCManager().IsEP1Available() && theGame.GetInGameConfigWrapper().GetVarValue('Hidden', 'HasSeenEP1WelcomeMessage') == "false")
			{
				theGame.GetInGameConfigWrapper().SetVarValue('Hidden', 'HasSeenEP1WelcomeMessage', "true");
				
				showBigMessage();
			}
			
			
			
			if (theGame.GetDLCManager().IsEP1Available())
			{
				ep1StatusText = GetLocStringByKeyExt("expansion_status_installed");
			}
			else
			{
				ep1StatusText = GetLocStringByKeyExt("expansion_status_available");
			}
			
			if (theGame.GetDLCManager().IsEP2Available())
			{
				ep2StatusText = GetLocStringByKeyExt("expansion_status_installed");
			}
			else
			{
				ep2StatusText = GetLocStringByKeyExt("expansion_status_coming_soon");
			}
			
			m_fxSetExpansionText.InvokeSelfTwoArgs(FlashArgString(ep1StatusText), FlashArgString(ep2StatusText));
			
			if (theGame.AreConfigResetInThisSession() && !theGame.HasShownConfigChangedMessage())
			{
				showNotification(GetLocStringByKeyExt("update_warning_message"));
				OnPlaySoundEvent("gui_global_denied");
				theGame.SetHasShownConfigChangedMessage(true);
			}
		}
		else if (deathScreenMenu)
		{
			isMainMenu = false;
			panelMode = true;
			mInGameConfigWrapper.DeactivateScriptTag('mainMenu');
			mInGameConfigWrapper.DeactivateScriptTag('inGame');
			
			deathScreenMenu.HideInputFeedback();
			
			if (hasSaveDataToLoad())
			{
				isInLoadselector = true;
				SendLoadData();
				m_fxSetPanelMode.InvokeSelfOneArg(FlashArgBool(true));
			}
			else
			{
				CloseMenu();
			}
		}
		else
		{
			initDataObject = (W3MenuInitData)GetMenuInitData();
			
			if (initDataObject && initDataObject.getDefaultState() == 'SaveGame')
			{
				isMainMenu = false;
				panelMode = true;
				
				managingPause = true;
				theInput.StoreContext( 'EMPTY_CONTEXT' );
				theGame.Pause('IngameMenu');
				
				mInGameConfigWrapper.DeactivateScriptTag('mainMenu');
				mInGameConfigWrapper.DeactivateScriptTag('inGame');
				
				SendSaveData();
				m_fxSetPanelMode.InvokeSelfOneArg(FlashArgBool(true));
			}
		}
		
		IngameMenu_UpdateDLCScriptTags();
		
		if (!panelMode)
		{
			m_fxSetIsMainMenu.InvokeSelfOneArg(FlashArgBool(isMainMenu)); 
			if (isMainMenu)
			{
				username = FixStringForFont(theGame.GetActiveUserDisplayName());
				m_fxSetCurrentUsername.InvokeSelfOneArg(FlashArgString(username));
				
				m_fxSetVersion.InvokeSelfOneArg(FlashArgString(theGame.GetApplicationVersion()));
			}
			theGame.GetSecondScreenManager().SendGameMenuOpen();
			
			lastSetDifficulty = theGame.GetDifficultyLevel();
			
			currentLangValue = mInGameConfigWrapper.GetVarValue('Localization', 'Virtual_Localization_text');
			lastUsedLangValue = currentLangValue;
			
			currentSpeechLang = mInGameConfigWrapper.GetVarValue('Localization', 'Virtual_Localization_speech');
			lastUsedSpeechLang = currentSpeechLang;
			
			theGame.GetGameLanguageName(audioLanguageName,tempLanguageName);
			if( tempLanguageName != languageName )
			{
				languageName = tempLanguageName;
				m_fxSetGameLogoLanguage.InvokeSelfOneArg( FlashArgString(languageName) );
			}
			
			PopulateMenuData();
		}
	}
	
	event OnRefresh()
	{
		var audioLanguageName 	: string;
		var tempLanguageName 	: string;
		var overlayPopupRef  	: CR4OverlayPopup;
		var username 			: string;
		var hud 				: CR4ScriptedHud;
		var ep1StatusText		: string;
		var ep2StatusText		: string;
		
		
		currentLangValue = mInGameConfigWrapper.GetVarValue('Localization', 'Virtual_Localization_text');
		lastUsedLangValue = currentLangValue;
			
		currentSpeechLang = mInGameConfigWrapper.GetVarValue('Localization', 'Virtual_Localization_speech');
		lastUsedSpeechLang = currentSpeechLang;
		
		if (isMainMenu)
		{
			username = FixStringForFont(theGame.GetActiveUserDisplayName());
			m_fxSetCurrentUsername.InvokeSelfOneArg(FlashArgString(username));
			
			PopulateMenuData();
			
			
			
			
			
			
			
		}
		
		UpdateAcceptCancelSwaping();
		SetPlatformType(theGame.GetPlatform());
		hud = (CR4ScriptedHud)(theGame.GetHud());
		if (hud)
		{
			hud.UpdateAcceptCancelSwaping();
		}
		
		overlayPopupRef = (CR4OverlayPopup) theGame.GetGuiManager().GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.UpdateAcceptCancelSwaping();
		}
		
		theGame.GetGameLanguageName(audioLanguageName,tempLanguageName);
		if( tempLanguageName != languageName )
		{
			languageName = tempLanguageName;
			m_fxSetGameLogoLanguage.InvokeSelfOneArg( FlashArgString(languageName) );
			m_fxUpdateInputFeedback.InvokeSelf();
			if (overlayPopupRef)
			{
				overlayPopupRef.UpdateButtons();
			}
		}
		
		
		{
			if (theGame.GetDLCManager().IsEP1Available())
			{
				ep1StatusText = GetLocStringByKeyExt("expansion_status_installed");
			}
			else
			{
				ep1StatusText = GetLocStringByKeyExt("expansion_status_available");
			}
			
			if (theGame.GetDLCManager().IsEP2Available())
			{
				ep2StatusText = GetLocStringByKeyExt("expansion_status_installed");
			}
			else
			{
				ep2StatusText = GetLocStringByKeyExt("expansion_status_coming_soon");
			}
			
			m_fxSetExpansionText.InvokeSelfTwoArgs(FlashArgString(ep1StatusText), FlashArgString(ep2StatusText));
		}
		setArabicAligmentMode();
	}
	
	function OnRequestSubMenu( menuName: name, optional initData : IScriptable )
	{
		RequestSubMenu(menuName, initData);
		m_fxSetVisible.InvokeSelfOneArg(FlashArgBool(false));
	}
	
	function ChildRequestCloseMenu()
	{
		m_fxSetVisible.InvokeSelfOneArg(FlashArgBool(true));
	}
	
	event OnCloseMenu() 
	{
		CloseMenu();
	}
	
	public function ReopenMenu()
	{
		var commonInGameMenu : CR4CommonIngameMenu;
		var commonMainMenu : CR4CommonMainMenu;
		var commonMainMenuEp1 : CR4CommonMainMenuEp1;
		
		commonInGameMenu = (CR4CommonIngameMenu)m_parentMenu;
		if(commonInGameMenu)
		{
			commonInGameMenu.reopenRequested = true;
		}
		
		commonMainMenuEp1 = (CR4CommonMainMenuEp1)m_parentMenu;
		if (commonMainMenuEp1)
		{
			commonMainMenuEp1.reopenRequested = true;
		}
		
		commonMainMenu = (CR4CommonMainMenu)m_parentMenu;
		if (commonMainMenu)
		{
			commonMainMenu.reopenRequested = true;
		}
		
		CloseMenu();
	}
		
	event  OnClosingMenu()
	{
		var commonInGameMenu : CR4CommonIngameMenu;
		var commonMainMenu : CR4CommonMainMenu;
		var commonMainMenuEp1 : CR4CommonMainMenuEp1;
		var deathScreenMenu : CR4DeathScreenMenu;
		var controlsFeedbackModule : CR4HudModuleControlsFeedback;
		var interactionModule : CR4HudModuleInteractions;
		var hud : CR4ScriptedHud;
		
		SaveChangedSettings();
		
		theGame.GetSecondScreenManager().SendGameMenuClose();
		super.OnClosingMenu();
		
		
		hud = (CR4ScriptedHud)(theGame.GetHud());
		if (hud)
		{
			controlsFeedbackModule = (CR4HudModuleControlsFeedback)(hud.GetHudModule(NameToString('ControlsFeedbackModule')));
			if (controlsFeedbackModule)
			{
				controlsFeedbackModule.ForceModuleUpdate();
			}
			
			interactionModule = (CR4HudModuleInteractions)(hud.GetHudModule(NameToString('InteractionsModule')));
			if (interactionModule)
			{
				interactionModule.ForceUpdateModule();
			}
		}
		
		if (managingPause)
		{
			managingPause = false;
			theInput.RestoreContext( 'EMPTY_CONTEXT', true );
			theGame.Unpause('IngameMenu');
		}
		
		if (theGame.GetGuiManager().potalConfirmationPending)
		{
			theGame.GetGuiManager().ResumePortalConfirmationPendingMessage();
		}
		
		if (m_structureCreator)
		{
			delete m_structureCreator;
		}
		
		if (loadConfPopup)
		{
			delete loadConfPopup;
		}
		
		if (saveConfPopup)
		{
			delete saveConfPopup;
		}
		
		if (actionConfPopup)
		{
			delete actionConfPopup;
		}
		
		if (newGameConfPopup)
		{
			delete newGameConfPopup;
		}
		
		if (deleteConfPopup)
		{
			delete deleteConfPopup;
		}
		
		if (diffChangeConfPopup)
		{
			delete diffChangeConfPopup;
		}
		
		commonInGameMenu = (CR4CommonIngameMenu)m_parentMenu;
		if(commonInGameMenu)
		{
			commonInGameMenu.ChildRequestCloseMenu();
			return true;
		}
		
		commonMainMenu = (CR4CommonMainMenu)m_parentMenu;
		if (commonMainMenu)
		{
			commonMainMenu.ChildRequestCloseMenu();
			return true;
		}
		
		commonMainMenuEp1 = (CR4CommonMainMenuEp1)m_parentMenu;
		if (commonMainMenuEp1)
		{
			commonMainMenuEp1.ChildRequestCloseMenu();
			return true;
		}
		
		deathScreenMenu = (CR4DeathScreenMenu)m_parentMenu;
		if (deathScreenMenu)
		{
			deathScreenMenu.ChildRequestCloseMenu();
			return true;
		}
	}
	
	
	protected function CloseCurrentPopup():void
	{
		if (loadConfPopup)
		{
			loadConfPopup.ClosePopupOverlay();
		}
		else if (saveConfPopup)
		{
			saveConfPopup.ClosePopupOverlay();
		}		
		else if (actionConfPopup)
		{
			actionConfPopup.ClosePopupOverlay();
		}		
		else if (newGameConfPopup)
		{
			newGameConfPopup.ClosePopupOverlay();
		}		
		else if (deleteConfPopup)
		{
			deleteConfPopup.ClosePopupOverlay();
		}		
		else if (diffChangeConfPopup)
		{
			diffChangeConfPopup.ClosePopupOverlay();
		}
	}
	
	public function SetIgnoreInput(value : bool) : void
	{
		if (value != ignoreInput)
		{
			ignoreInput = value;
			m_fxSetIgnoreInput.InvokeSelfOneArg( FlashArgBool(value) );
		}
	}
	
	public function OnUserSignIn() : void
	{
		SetIgnoreInput(false);
		CloseCurrentPopup();
	}
	
	public function OnUserSignInCancelled() : void
	{
		SetIgnoreInput(false);
		CloseCurrentPopup();
	}
	
	public function OnSaveLoadingFailed() : void
	{
		SetIgnoreInput(false);
		CloseCurrentPopup();
	}
	
	event  OnItemActivated( actionType:int, menuTag:int ) : void
	{
		var l_DataFlashArray : CScriptedFlashArray;
		
		if (ignoreInput)
		{
			m_fxNavigateBack.InvokeSelf();
		}
		else
		{
			switch (actionType)
			{
			case IGMActionType_CommonMenu:
				theGame.RequestMenu( 'CommonMenu' );
				break;
			case IGMActionType_MenuHolder:
				
				
				m_initialSelectionsToIgnore = 1;
				OnPlaySoundEvent( "gui_global_panel_open" );
				break;
			case IGMActionType_MenuLastHolder:
				m_initialSelectionsToIgnore = 1;
				OnPlaySoundEvent( "gui_global_panel_open" );
				break;
			case IGMActionType_Load:
				if (hasSaveDataToLoad())
				{
					SendLoadData();
				}
				else
				{
					
					m_fxNavigateBack.InvokeSelf();
				}
				isInLoadselector = true;
				break;
			case IGMActionType_Save:
				if ( !theGame.AreSavesLocked() )
				{
					SendSaveData();
				}
				else
				{
					m_fxNavigateBack.InvokeSelf();
					theGame.GetGuiManager().DisplayLockedSavePopup();
				}
				isInLoadselector = false;
				break;
			case IGMActionType_Quit:
				if (theGame.GetPlatform() == Platform_Xbox1)
				{
					ShowActionConfPopup(IGMActionType_Quit, "", GetLocStringByKeyExt("error_message_exit_game_x1"));
				}
				else if (theGame.GetPlatform() == Platform_PS4)
				{
					ShowActionConfPopup(IGMActionType_Quit, "", GetLocStringByKeyExt("error_message_exit_game_ps4"));
				}
				else
				{
					ShowActionConfPopup(IGMActionType_Quit, "", GetLocStringByKeyExt("error_message_exit_game"));
				}
				break;
			case IGMActionType_Toggle:
				break;
			case IGMActionType_List:
				break;
			case IGMActionType_Slider:
				break;
			case IGMActionType_LoadLastSave:
				LoadLastSave();
				break;
			case IGMActionType_Close:
				
				break;
			case IGMActionType_Tutorials:
				theGame.RequestMenuWithBackground( 'GlossaryTutorialsMenu', 'CommonMenu' );
				break;
			case IGMActionType_Credits:
				theGame.GetGuiManager().RequestCreditsMenu(menuTag);
				break;
			case IGMActionType_Help:
				showHelpPanel();
				break;
			case IGMActionType_Options:
				if (theGame.GetPlatform() == Platform_PC)
				{
					m_fxSetHardwareCursorOn.InvokeSelfOneArg(FlashArgBool(mInGameConfigWrapper.GetVarValue('Rendering', 'HardwareCursor')));
				}
				l_DataFlashArray = IngameMenu_FillOptionsSubMenuData(m_flashValueStorage, isMainMenu);
				
				m_initialSelectionsToIgnore = 1;
				OnPlaySoundEvent( "gui_global_panel_open" );
				
				m_flashValueStorage.SetFlashArray( "ingamemenu.options.entries", l_DataFlashArray );
				break;
			case IGMActionType_ControllerHelp:
				SendControllerData();
				break;
			case IGMActionType_NewGame:
				TryStartNewGame(menuTag);
				break;
			case IGMActionType_NewGamePlus:
				fetchNewGameConfigFromTag(menuTag);
				SendNewGamePlusSaves();
				break;
			case IGMActionType_InstalledDLC:
				SendInstalledDLCList();
				break;
			case IGMActionType_UIRescale:
				SendRescaleData();
				break;
			case IGMActionType_DebugStartQuest:
				RequestSubMenu( 'MainDbgStartQuestMenu', GetMenuInitData() );
				break;
			case IGMActionType_Gwint:
				GetRootMenu().CloseMenu();
				theGame.RequestMenu( 'DeckBuilder' );
				break;
			case IGMActionType_ImportSave:
				lastSetTag = menuTag;
				fetchNewGameConfigFromTag( menuTag );
				SendImportSaveData( );
				break;
			case IGMActionType_CloseGame:
				if (!isMainMenu)
				{
					ShowActionConfPopup(IGMActionType_CloseGame, "", GetLocStringByKeyExt("error_message_exit_game"));
				}
				else
				{
					theGame.RequestExit();
				}
				break;
			case IGMActionType_KeyBinds:
				SendKeybindData();
				break;
			}
		}
	}
	
	public function HandleLoadGameFailed():void
	{
		disableAccountPicker = false;
		SetIgnoreInput(false);
	}
	
	protected function showBigMessage():void
	{
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "tfTitle1", GetLocStringByKeyExt("ep1_installed_information_title_1") );
		l_DataFlashObject.SetMemberFlashString( "tfTitle2", GetLocStringByKeyExt("ep1_installed_information_title_2") );
		
		l_DataFlashObject.SetMemberFlashString( "tfTitlePath1", GetLocStringByKeyExt("ep1_installed_information_title_path_1") );
		l_DataFlashObject.SetMemberFlashString( "tfTitlePath2", GetLocStringByKeyExt("ep1_installed_information_title_path_2") );
		l_DataFlashObject.SetMemberFlashString( "tfTitlePath3", GetLocStringByKeyExt("ep1_installed_information_title_path_3") );
		
		l_DataFlashObject.SetMemberFlashString( "tfDescPath1", GetLocStringByKeyExt("ep1_installed_information_title_path_1_description") );
		l_DataFlashObject.SetMemberFlashString( "tfDescPath2", GetLocStringByKeyExt("ep1_installed_information_title_path_2_description") );
		l_DataFlashObject.SetMemberFlashString( "tfDescPath3", GetLocStringByKeyExt("ep1_installed_information_title_path_3_description") );
		
		l_DataFlashObject.SetMemberFlashString( "tfWarning", GetLocStringByKeyExt("ep1_installed_information_warning_level") );
		l_DataFlashObject.SetMemberFlashString( "tfGoodLuck", GetLocStringByKeyExt("ep1_installed_information_good_luck") );
		
		m_flashValueStorage.SetFlashObject( "ingamemenu.bigMessage", l_DataFlashObject );
	}
	
	
	protected function LoadLastSave():void
	{
		if (theGame.GetGuiManager().GetPopup('MessagePopup') && theGame.GetGuiManager().lastMessageData.messageId == UMID_ControllerDisconnected)
		{
			return;
		}
		
		SetIgnoreInput(true);
		
		if (isMainMenu)
		{
			disableAccountPicker = true;
		}
		
		theGame.LoadLastGameInit();
	}
	
	protected function ShowActionConfPopup(action : int, title : string, description : string) : void
	{
		if (actionConfPopup)
		{
			delete actionConfPopup;
		}
		
		actionConfPopup = new W3ActionConfirmation in this;
		actionConfPopup.SetMessageTitle(title);
		actionConfPopup.SetMessageText(description);
		actionConfPopup.actionID = action;
		actionConfPopup.menuRef = this;
		actionConfPopup.BlurBackground = true;
			
		RequestSubMenu('PopupMenu', actionConfPopup);
	}
	
	public function OnActionConfirmed(action:int) : void
	{
		var parentMenu : CR4MenuBase;
		
		parentMenu = (CR4MenuBase)GetParent();
		
		switch (action)
		{
		case IGMActionType_Quit:
			{
				parentMenu.OnCloseMenu();
				theGame.RequestEndGame();
				break;
			}
		case IGMActionType_CloseGame:
			{
				theGame.RequestExit();
				break;
			}
		}
	}
	
	event  OnPresetApplied(groupId:name, targetPresetIndex:int)
	{
		hasChangedOption = true;
		IngameMenu_ChangePresetValue(groupId, targetPresetIndex, this);
		
		if (groupId == 'Rendering' && !isMainMenu)
		{
			m_fxForceBackgroundVis.InvokeSelfOneArg(FlashArgBool(true));
		}
	}
	
	public function UpdateOptions(groupId:name)
	{
		var optionChangeContainer : CScriptedFlashObject;
		
		optionChangeContainer = m_flashValueStorage.CreateTempFlashObject();
		IngameMenu_GatherOptionUpdatedValues(groupId, optionChangeContainer, m_flashValueStorage);
		
		m_flashValueStorage.SetFlashObject( "ingamemenu.optionValueChanges", optionChangeContainer );
	}
	
	event  OnOptionValueChanged(groupId:int, optionName:name, optionValue:string)
	{
		var groupName:name;
		var hud : CR4ScriptedHud;
		var isValid : bool;
		var isBuffered : bool;
		
		hasChangedOption = true;
		
		OnPlaySoundEvent( "gui_global_switch" );
		
		if (groupId == NameToFlashUInt('SpecialSettingsGroupId'))
		{
			HandleSpecialValueChanged(optionName, optionValue);
			return true;
		}
		
		if (optionName == 'HardwareCursor')
		{
			isValid = optionValue;
			m_fxSetHardwareCursorOn.InvokeSelfOneArg(FlashArgBool(isValid));
		}
		
		if (optionName == 'SwapAcceptCancel')
		{
			swapAcceptCancelChanged = true;
		}
		
		if (optionName == 'EnableUberMovement')
		{
			if ( optionValue == "1" )
				theGame.EnableUberMovement( true );
			else
				theGame.EnableUberMovement( false );
		}
		
		if (optionName == 'GwentDifficulty')
		{
			if ( optionValue == "0" )
				FactsSet( 'gwent_difficulty' , 1 );
			else if ( optionValue == "1" )
				FactsSet( 'gwent_difficulty' , 2 );
			else if ( optionValue == "2" )
				FactsSet( 'gwent_difficulty' , 3 );
			
			return true;
		}
		
		if (optionName == 'HardwareCursor')
		{
			updateInputDeviceRequired = true;
		}
		
		groupName = mInGameConfigWrapper.GetGroupName(groupId);
		
		
		isBuffered = mInGameConfigWrapper.DoGroupHasTag( groupName, 'buffered' );
		if( isBuffered == false )
		{
			isBuffered = mInGameConfigWrapper.DoVarHasTag( groupName, optionName, 'buffered' );
		}
		
		if( isBuffered == true )
		{
			inGameConfigBufferedWrapper.SetVarValue(groupName, optionName, optionValue);
		}
		else
		{
			mInGameConfigWrapper.SetVarValue(groupName, optionName, optionValue);
		}
		
		theGame.OnConfigValueChanged(optionName, optionValue);
		
		if (groupName == 'Hud' || optionName == 'Subtitles')
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			
			if (hud)
			{
				hud.UpdateHudConfig(optionName, true);
			}
		}
		
		if (groupName == 'Localization')
		{
			if (optionName == 'Virtual_Localization_text')
			{
				currentLangValue = optionValue;
			}
			else if (optionName == 'Virtual_Localization_speech')
			{
				currentSpeechLang = optionValue;
			}
		}
		
		if (groupName == 'Rendering' && !isMainMenu)
		{
			m_fxForceBackgroundVis.InvokeSelfOneArg(FlashArgBool(true));
		}
		
		if (groupName == 'Rendering' && optionName == 'PreserveSystemGamma')
		{
			theGame.GetGuiManager().DisplayRestartGameToApplyAllChanges();
		}
	}
	
	protected function HandleSpecialValueChanged(optionName:name, optionValue:string):void
	{
		var intValue : int;
		
		if (optionName == 'GameDifficulty')
		{
			intValue = StringToInt(optionValue, 1);
			
			lastSetDifficulty = intValue + 1;
		}
	}
	
	public function OnGraphicsUpdated(keepChanges:bool):void
	{
		
		
		
		
		
	}
	
	event  OnOptionPanelNavigateBack()
	{
		var graphicChangesPending:bool;
		var hud : CR4ScriptedHud;
		
		if (inGameConfigBufferedWrapper.AnyBufferedVarHasTag('refreshViewport'))
		{
			inGameConfigBufferedWrapper.ApplyNewValues();
			theGame.GetGuiManager().ShowProgressDialog(UMID_GraphicsRefreshing, "", "message_text_confirm_option_changes", true, UDB_OkCancel, 100, UMPT_GraphicsRefresh, '');
			ReopenMenu();
			return true;
		}
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.RefreshHudConfiguration();
		}
	}
	
	event  OnNavigatedBack()
	{
		var lowestDifficultyUsed : EDifficultyMode;
		var hud : CR4ScriptedHud;
		var overlayPopupRef : CR4OverlayPopup;
		var confirmResult : int;
		
		hud = (CR4ScriptedHud)(theGame.GetHud());
		overlayPopupRef = (CR4OverlayPopup) theGame.GetGuiManager().GetPopup('OverlayPopup');
		
		if( inGameConfigBufferedWrapper.IsEmpty() == false )
		{
			if (!inGameConfigBufferedWrapper.AnyBufferedVarHasTag('refreshViewport'))
			{
				inGameConfigBufferedWrapper.FlushBuffer();
			}
			
			hasChangedOption = true;
		}
		
		if (currentLangValue != lastUsedLangValue || lastUsedSpeechLang != currentSpeechLang)
		{
			lastUsedLangValue = currentLangValue;
			lastUsedSpeechLang = currentSpeechLang;
			theGame.ReloadLanguage();
			
		}
		
		if (swapAcceptCancelChanged)
		{
			swapAcceptCancelChanged = false;
			UpdateAcceptCancelSwaping();
			
			if (hud)
			{
				hud.UpdateAcceptCancelSwaping();
			}
			
			if (overlayPopupRef)
			{
				overlayPopupRef.UpdateAcceptCancelSwaping();
			}
		}
		
		isShowingSaveList = false;
		isShowingLoadList = false;
		
		OnPlaySoundEvent( "gui_global_panel_close" );
		
		lowestDifficultyUsed = theGame.GetLowestDifficultyUsed();
		
		
		
		if (!isMainMenu && theGame.GetDifficultyLevel() != lastSetDifficulty && lowestDifficultyUsed > lastSetDifficulty && lowestDifficultyUsed > EDM_Medium)
		{
			diffChangeConfPopup = new W3DifficultyChangeConfirmation in this;
			
			diffChangeConfPopup.SetMessageTitle("");
			
			if (theGame.GetPlatform() == Platform_PS4)
			{
				diffChangeConfPopup.SetMessageText(GetLocStringByKeyExt("difficulty_change_warning_message_PS4"));
			}
			else
			{
				diffChangeConfPopup.SetMessageText(GetLocStringByKeyExt("difficulty_change_warning_message_X1"));
			}
			
			diffChangeConfPopup.menuRef = this;
			diffChangeConfPopup.targetDifficulty = lastSetDifficulty;
			diffChangeConfPopup.BlurBackground = true;
			
			RequestSubMenu('PopupMenu', diffChangeConfPopup);
		}
		else if (lastSetDifficulty != theGame.GetDifficultyLevel())
		{
			theGame.SetDifficultyLevel(lastSetDifficulty);
			theGame.OnDifficultyChanged(lastSetDifficulty);
		}
		
		SaveChangedSettings();
		
		if (overlayPopupRef && updateInputDeviceRequired)
		{
			updateInputDeviceRequired = false;
			overlayPopupRef.UpdateInputDevice();
		}
	}
	
	public function CancelDifficultyChange() : void
	{
		var difficultyIndex:int;
		var difficultyIndexAsString:string;
		
		lastSetDifficulty = theGame.GetDifficultyLevel();
		
		difficultyIndex = lastSetDifficulty - 1;
		difficultyIndexAsString = "" + difficultyIndex;
		m_fxUpdateOptionValue.InvokeSelfTwoArgs(FlashArgUInt(NameToFlashUInt('GameDifficulty')), FlashArgString(difficultyIndexAsString));
	}
	
	protected function SaveChangedSettings()
	{
		if (hasChangedOption)
		{
			hasChangedOption = false;
			theGame.SaveUserSettings();
		}
	}
	
	event  OnProfileChange()
	{
		if( !disableAccountPicker )
		{
			SetIgnoreInput(true);
			theGame.ChangeActiveUser();
		}
	}
	
	event  OnSaveGameCalled(type : ESaveGameType, saveArrayIndex : int)
	{
		var saves : array< SSavegameInfo >;
		var currentSave : SSavegameInfo;
		
		ignoreInput = true; 
		
		if ( theGame.AreSavesLocked() )
		{
			theGame.GetGuiManager().DisplayLockedSavePopup();
			SetIgnoreInput(false);
			return false;
		}
	
		if (saveArrayIndex >= 0)
		{
			if (saveConfPopup)
			{
				delete saveConfPopup;
			}
			
			theGame.ListSavedGames( saves );
			currentSave = saves[ saveArrayIndex ];
			
			saveConfPopup = new W3SaveGameConfirmation in this;
			saveConfPopup.SetMessageTitle("");
			if (theGame.GetPlatform() == Platform_Xbox1)
			{
				saveConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_overwrite_save_x1"));
			}
			else if (theGame.GetPlatform() == Platform_PS4)
			{
				saveConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_overwrite_save_ps4"));
			}
			else
			{
				saveConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_overwrite_save"));
			}
			saveConfPopup.menuRef = this;
			saveConfPopup.type = currentSave.slotType;
			saveConfPopup.slot = currentSave.slotIndex;
			saveConfPopup.BlurBackground = true;
				
			RequestSubMenu('PopupMenu', saveConfPopup);
		}
		else
		{
			executeSave(type, -1);
			SetIgnoreInput(false);
		}
	}
	
	public function executeSave(type : ESaveGameType, slot : int)
	{
		var hadLoadable:bool;
		
		hadLoadable = hasSaveDataToLoad();
		
		theGame.SaveGame(type, slot);
		m_fxNavigateBack.InvokeSelf();
	}
	
	event  OnLoadGameCalled(type : ESaveGameType, saveListIndex : int)
	{
		var saveGameRef : SSavegameInfo;
		var saveGames		: array< SSavegameInfo >;
		
		if (ignoreInput)
		{
			return false;
		}
		
		disableAccountPicker = true;
		
		if (loadConfPopup)
		{
			delete loadConfPopup;
		}
		
		theGame.ListSavedGames( saveGames );
		saveGameRef = saveGames[saveListIndex];
		
		if (panelMode || (isMainMenu && !hasValidAutosaveData()))
		{
			LoadSaveRequested(saveGameRef);
		}
		else
		{
			loadConfPopup = new W3ApplyLoadConfirmation in this;
			
			if (theGame.GetPlatform() == Platform_Xbox1)
			{
				loadConfPopup.SetMessageTitle(GetLocStringByKeyExt("panel_mainmenu_popup_load_title_x1"));
			}
			else if (theGame.GetPlatform() == Platform_PS4)
			{
				loadConfPopup.SetMessageTitle(GetLocStringByKeyExt("panel_mainmenu_popup_load_title_ps4"));
			}
			else
			{
				loadConfPopup.SetMessageTitle(GetLocStringByKeyExt("panel_mainmenu_popup_load_title"));			
			}
			
			if (isMainMenu)
			{
				if (theGame.GetPlatform() == Platform_Xbox1)
				{
					loadConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_load_game_main_menu_x1"));
				}
				else if (theGame.GetPlatform() == Platform_PS4)
				{
					loadConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_load_game_main_menu_ps4"));
				}
				else
				{
					loadConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_load_game_main_menu"));
				}
			}
			else
			{
				if (theGame.GetPlatform() == Platform_Xbox1)
				{
					loadConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_load_game_x1"));
				}
				else if (theGame.GetPlatform() == Platform_PS4)
				{
					loadConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_load_game_ps4"));
				}
				else
				{
					loadConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_load_game"));
				}
			}
			loadConfPopup.menuRef = this;
			loadConfPopup.saveSlotRef = saveGameRef;
			loadConfPopup.BlurBackground = true;
			
			SetIgnoreInput(true);
					
			RequestSubMenu('PopupMenu', loadConfPopup);
		}
	}
	
	public function LoadSaveRequested(saveSlotRef : SSavegameInfo) : void
	{	
		if (theGame.GetGuiManager().GetPopup('MessagePopup') && theGame.GetGuiManager().lastMessageData.messageId == UMID_ControllerDisconnected)
		{
			SetIgnoreInput(false);
			disableAccountPicker = false;
			return;
		}
		
		SetIgnoreInput(true);
		
		if (isMainMenu)
		{
			disableAccountPicker = true;
		}
		
		theGame.LoadGameInit( saveSlotRef );
	}
	
	event  OnImportGameCalled(menuTag:int):void
	{
		var savesToImport : array< SSavegameInfo >;
		var difficulty:int;
		var tutorialsEnabled:bool;
		var simulateImport:bool;
		var maskResult:int;
		var progress : float;
		
		if (!theGame.IsContentAvailable('launch0'))
		{
			progress = theGame.ProgressToContentAvailable('launch0');
			theSound.SoundEvent("gui_global_denied");
			theGame.GetGuiManager().ShowProgressDialog(0, "", "error_message_new_game_not_ready", true, UDB_Ok, progress, UMPT_Content, 'launch0');
			
		}
		else
		{
			theGame.ListW2SavedGames( savesToImport );
			
			if ( menuTag < savesToImport.Size() )
			{
				disableAccountPicker = true;
				
				theGame.ClearInitialFacts();
				
				if (theGame.ImportSave( savesToImport[ menuTag ] ))
				{
					currentNewGameConfig.import_save_index = menuTag;
					
					if ((lastSetTag & IGMC_New_game_plus) == IGMC_New_game_plus)
					{
						m_fxForceEnterCurEntry.InvokeSelf();
					}
					else
					{
						
						theGame.SetDifficultyLevel(currentNewGameConfig.difficulty);
						TutorialMessagesEnable(currentNewGameConfig.tutorialsOn);
						
						if ( theGame.RequestNewGame( theGame.GetNewGameDefinitionFilename() ) )
						{
							OnPlaySoundEvent("gui_global_game_start");
							OnPlaySoundEvent("mus_intro_usm");
							GetRootMenu().CloseMenu();
						}
					}
				}
				else
				{
					showNotification(GetLocStringByKeyExt("import_witcher_two_failed"));
					OnPlaySoundEvent("gui_global_denied");
				}
			}
		}
	}
	
	event  OnNewGamePlusCalled(saveListIndex:int):void
	{
		var startGameStatus : ENewGamePlusStatus;
		var saveGameRef 	: SSavegameInfo;
		var saveGames		: array< SSavegameInfo >;
		var errorMessage 	: string;
		var progress : float;
		
		var requiredContent : name = 'content12';
		
		ignoreInput = true; 
		
		if (!theGame.IsContentAvailable(requiredContent))
		{
			progress = theGame.ProgressToContentAvailable(requiredContent);
			theSound.SoundEvent("gui_global_denied");
			SetIgnoreInput(false);
			theGame.GetGuiManager().ShowProgressDialog(0, "", "error_message_new_game_not_ready", true, UDB_Ok, progress, UMPT_Content, requiredContent);
		}
		else
		{
			disableAccountPicker = true;
			
			theGame.ListSavedGames( saveGames );
			saveGameRef = saveGames[saveListIndex];
			
			if (currentNewGameConfig.import_save_index == -1 && currentNewGameConfig.simulate_import)
			{
				theGame.AddInitialFact("simulate_import_ingame");
			}
			
			theGame.SetDifficultyLevel(currentNewGameConfig.difficulty);
			
			TutorialMessagesEnable(currentNewGameConfig.tutorialsOn);
			
			startGameStatus = theGame.StartNewGamePlus(saveGameRef);
			
			if (startGameStatus == NGP_Success)
			{
				theGame.GetGuiManager().RequestMouseCursor(false);
				OnPlaySoundEvent("gui_global_game_start");
				OnPlaySoundEvent("mus_intro_usm");
				GetRootMenu().CloseMenu();
			}
			else
			{
				errorMessage = "";
				SetIgnoreInput(false);
				disableAccountPicker = false;
				
				switch (startGameStatus)
				{
				case NGP_Invalid:
					errorMessage = GetLocStringByKeyExt("newgame_plus_error_invalid");
					break;
				case NGP_CantLoad:
					errorMessage = GetLocStringByKeyExt("newgame_plus_error_cantload");
					break;
				case NGP_TooOld:
					errorMessage = GetLocStringByKeyExt("newgame_plus_error_too_old");
					break;
				case NGP_RequirementsNotMet:
					errorMessage = GetLocStringByKeyExt("newgame_plus_error_requirementnotmet");
					break;
				case NGP_InternalError:
					errorMessage = GetLocStringByKeyExt("newgame_plus_error_internalerror");
					break;
				case NGP_ContentRequired:
					errorMessage = GetLocStringByKeyExt("newgame_plus_error_contentrequired");
					break;
				}
				
				showNotification(errorMessage);
				OnPlaySoundEvent("gui_global_denied");
			}
		}
	}
	
	event  OnDeleteSaveCalled(type : ESaveGameType, saveListIndex : int, isSaveMode:bool)
	{
		if (ignoreInput)
		{
			return false;
		}
		
		SetIgnoreInput(true);
		
		disableAccountPicker = true;
		
		if (deleteConfPopup)
		{
			delete deleteConfPopup;
		}
		
		deleteConfPopup = new W3DeleteSaveConf in this;
		deleteConfPopup.SetMessageTitle("");
		if (theGame.GetPlatform() == Platform_Xbox1)
		{
			deleteConfPopup.SetMessageText(GetLocStringByKeyExt("panel_mainmenu_confirm_delete_text_x1"));
		}
		else if (theGame.GetPlatform() == Platform_PS4)
		{
			deleteConfPopup.SetMessageText(GetLocStringByKeyExt("panel_mainmenu_confirm_delete_text_ps4"));
		}
		else
		{
			deleteConfPopup.SetMessageText(GetLocStringByKeyExt("panel_mainmenu_confirm_delete_text"));
		}
		deleteConfPopup.menuRef = this;
		deleteConfPopup.type = type;
		deleteConfPopup.slot = saveListIndex;
		deleteConfPopup.saveMode = isSaveMode;
		deleteConfPopup.BlurBackground = true;
			
		RequestSubMenu('PopupMenu', deleteConfPopup);
	}
	
	public function DeleteSave(type : ESaveGameType, saveListIndex : int, isSaveMode:bool)
	{
		var saves : array< SSavegameInfo >;
		var currentSave : SSavegameInfo;
		var numSavesBeforeDelete : int;
		
		theGame.ListSavedGames( saves );
		
		numSavesBeforeDelete = saves.Size();
		
		if (saveListIndex < saves.Size())
		{
			currentSave = saves[ saveListIndex ];
			theGame.DeleteSavedGame(currentSave);
		}
		
		if (numSavesBeforeDelete <= 1)
		{
			m_fxRemoveOption.InvokeSelfOneArg(FlashArgInt(NameToFlashUInt('Continue')));
			m_fxRemoveOption.InvokeSelfOneArg(FlashArgInt(NameToFlashUInt('LoadGame')));
			
			if (isInLoadselector)
			{
				m_fxNavigateBack.InvokeSelf();
			}
			else
			{
				SendSaveData();
			}
		}
		else
		{
			if (isSaveMode)
			{
				SendSaveData();
			}
			else if (hasSaveDataToLoad())
			{
				SendLoadData();
			}
		}
	}
	
	protected function showHelpPanel() : void
	{
		m_fxNavigateBack.InvokeSelf();
		
		theGame.DisplaySystemHelp();
	}
	
	public function TryStartNewGame(optionsArray : int):void
	{
		var progress : float;
		
		if (!theGame.IsContentAvailable('launch0'))
		{
			progress = theGame.ProgressToContentAvailable('launch0');
			theSound.SoundEvent("gui_global_denied");
			theGame.GetGuiManager().ShowProgressDialog(0, "", "error_message_new_game_not_ready", true, UDB_Ok, progress, UMPT_Content, 'launch0');
		}
		else
		{
			fetchNewGameConfigFromTag(optionsArray);
			
			if ((optionsArray & IGMC_EP1_Save) == IGMC_EP1_Save)
			{
				
				theGame.InitStandaloneDLCLoading('ep1', currentNewGameConfig.difficulty);
			}
			else
			{
				if (hasValidAutosaveData())
				{
					if (newGameConfPopup)
					{
						delete newGameConfPopup;
					}
					
					newGameConfPopup = new W3NewGameConfirmation in this;
					newGameConfPopup.SetMessageTitle("");
					if (theGame.GetPlatform() == Platform_Xbox1)
					{
						newGameConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_start_game_x1"));	
					}
					else if (theGame.GetPlatform() == Platform_PS4)
					{
						newGameConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_start_game_ps4"));	
					}
					else
					{
						newGameConfPopup.SetMessageText(GetLocStringByKeyExt("error_message_start_game"));	
					}
					newGameConfPopup.menuRef = this;
					newGameConfPopup.BlurBackground = true;
						
					RequestSubMenu('PopupMenu', newGameConfPopup);
				}
				else
				{
					NewGameRequested();
				}
			}
		}
	}
	
	protected function fetchNewGameConfigFromTag(optionsTag : int):void
	{
		var maskResult:int;
		
		currentNewGameConfig.difficulty = optionsTag & IGMC_Difficulty_mask;
		
		maskResult = optionsTag & IGMC_Tutorials_On;
		currentNewGameConfig.tutorialsOn = (maskResult == IGMC_Tutorials_On);
		
		maskResult = optionsTag & IGMC_Import_Save;
		if (maskResult != IGMC_Import_Save)
		{
			currentNewGameConfig.import_save_index = -1;
		}
		
		maskResult = optionsTag & IGMC_Simulate_Import;
		currentNewGameConfig.simulate_import = (maskResult == IGMC_Simulate_Import);
	}
	
	public function NewGameRequested():void
	{
		disableAccountPicker = true;
		
		if (currentNewGameConfig.import_save_index == -1)
		{
			theGame.ClearInitialFacts();
		}
		
		if (currentNewGameConfig.import_save_index == -1 && currentNewGameConfig.simulate_import)
		{
			theGame.AddInitialFact("simulate_import_ingame");
		}
		
		theGame.SetDifficultyLevel(currentNewGameConfig.difficulty);
		
		TutorialMessagesEnable(currentNewGameConfig.tutorialsOn);
		
		StartNewGame();
	}
	
	event  OnUpdateRescale(hScale : float, vScale : float)
	{
		var hud : CR4ScriptedHud;
		var needRescale : bool;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		needRescale = false;
		
		if( theGame.GetUIHorizontalFrameScale() != hScale )
		{
			theGame.SetUIHorizontalFrameScale(hScale);
			mInGameConfigWrapper.SetVarValue('Hidden', 'uiHorizontalFrameScale', FloatToString(hScale));
			needRescale = true;
			hasChangedOption = true;
		}	
		if( theGame.GetUIVerticalFrameScale() != vScale )
		{
			theGame.SetUIVerticalFrameScale(vScale);
			mInGameConfigWrapper.SetVarValue('Hidden', 'uiVerticalFrameScale', FloatToString(vScale));
			needRescale = true;
			hasChangedOption = true;
		}	
		
		if( needRescale && hud ) 
		{
			hud.RescaleModules();
		}
	}
	
	public function ShowTutorialChosen(enabled:bool):void
	{
		TutorialMessagesEnable(enabled);
		
		StartNewGame();
	}
	
	public function StartNewGame():void
	{
		if (theGame.GetGuiManager().GetPopup('MessagePopup') && theGame.GetGuiManager().lastMessageData.messageId == UMID_ControllerDisconnected)
		{
			return;
		}
		
		if ( theGame.RequestNewGame( theGame.GetNewGameDefinitionFilename() ) )
		{
			theGame.GetGuiManager().RequestMouseCursor(false);
			OnPlaySoundEvent("gui_global_game_start");
			OnPlaySoundEvent("mus_intro_usm");
			GetRootMenu().CloseMenu();
		}
	}
	
	function PopulateMenuData()
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_subDataFlashObject	: CScriptedFlashObject;
		
		l_DataFlashArray = m_structureCreator.PopulateMenuData();
		
		m_flashValueStorage.SetFlashArray( "ingamemenu.entries", l_DataFlashArray );
	}
	
	protected function addInLoadOption():void
	{
		var l_DataFlashObject 		: CScriptedFlashObject;
		var l_ChildMenuFlashArray	: CScriptedFlashArray;
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		l_DataFlashObject.SetMemberFlashString( "id", "mainmenu_loadgame");
		l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt('LoadGame') );
		l_DataFlashObject.SetMemberFlashString(  "label", GetLocStringByKeyExt("panel_mainmenu_loadgame") );	
		
		l_DataFlashObject.SetMemberFlashUInt( "type", IGMActionType_Load );	
		
		l_ChildMenuFlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_DataFlashObject.SetMemberFlashArray( "subElements", l_ChildMenuFlashArray );
		
		m_flashValueStorage.SetFlashObject( "ingamemenu.addloading", l_DataFlashObject );
	}
	
	event  OnBack()
	{
		CloseMenu();
	}
	
	public function HasSavesToImport() : bool
	{
		var savesToImport : array< SSavegameInfo >;
		
		theGame.ListW2SavedGames( savesToImport );
		return savesToImport.Size() != 0;
	}

	protected function SendImportSaveData()
	{
		var dataFlashArray 	: CScriptedFlashArray;
		
		dataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		IngameMenu_PopulateImportSaveData(m_flashValueStorage, dataFlashArray);
		
		m_initialSelectionsToIgnore = 1;
		OnPlaySoundEvent( "gui_global_panel_open" );
		
		isShowingSaveList = true;
		m_flashValueStorage.SetFlashArray( "ingamemenu.importSlots", dataFlashArray );
	}
	
	protected function hasValidAutosaveData() : bool
	{
		var currentSave	: SSavegameInfo;
		var num : int;
		var i : int;
		
		num = theGame.GetNumSaveSlots( SGT_AutoSave );
		for ( i = 0; i < num; i = i + 1 )
		{
			if ( theGame.GetSaveInSlot( SGT_AutoSave, i, currentSave ) )
			{
				return true;
			}
		}
		
		num = theGame.GetNumSaveSlots( SGT_CheckPoint );
		for ( i = 0; i < num; i = i + 1 )
		{
			if ( theGame.GetSaveInSlot( SGT_CheckPoint, i, currentSave ) )
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function HandleSaveListUpdate():void
	{
		if (isShowingSaveList)
		{
			SendSaveData();
		}
		else if (isShowingLoadList)
		{
			SendLoadData();
		}
		
		if (hasSaveDataToLoad())
		{
			addInLoadOption();
		}
	}
	
	protected function SendLoadData():void
	{
		var dataFlashArray 	: CScriptedFlashArray;
		
		dataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		PopulateSaveDataForSlotType(-1, dataFlashArray, false);
		
		m_initialSelectionsToIgnore = 1;
		OnPlaySoundEvent( "gui_global_panel_open" );
		
		if (dataFlashArray.GetLength() == 0)
		{
			m_fxNavigateBack.InvokeSelf();
		}
		else
		{
			isShowingLoadList = true;
			m_flashValueStorage.SetFlashArray( "ingamemenu.loadSlots", dataFlashArray );
		}
	}
	
	
	protected function SendSaveData():void
	{
		var dataFlashArray 	: CScriptedFlashArray;
		
		dataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		
		
		PopulateSaveDataForSlotType(SGT_Manual, dataFlashArray, true);
		
		m_initialSelectionsToIgnore = 1;
		OnPlaySoundEvent( "gui_global_panel_open" );
		
		isShowingSaveList = true;
		m_flashValueStorage.SetFlashArray( "ingamemenu.saveSlots", dataFlashArray );
		
		if ( theGame.ShouldShowSaveCompatibilityWarning() )
		{
			theGame.GetGuiManager().ShowUserDialog( UMID_SaveCompatWarning, "", "error_save_not_compatible", UDB_Ok );
		}
	}
	
	protected function SendNewGamePlusSaves():void
	{
		var dataFlashArray 	: CScriptedFlashArray;
		
		dataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		PopulateSaveDataForSlotType(-1, dataFlashArray, false);
		
		theGame.GetGuiManager().ShowUserDialog(0, "", "message_new_game_plus_reminder", UDB_Ok);
		
		if (dataFlashArray.GetLength() == 0)
		{
			OnPlaySoundEvent("gui_global_denied");
			showNotification(GetLocStringByKeyExt("mainmenu_newgame_plus_no_saves"));
			m_fxNavigateBack.InvokeSelf();
		}
		else
		{
			m_initialSelectionsToIgnore = 1;
			OnPlaySoundEvent( "gui_global_panel_open" );
			m_flashValueStorage.SetFlashArray( "ingamemenu.newGamePlusSlots", dataFlashArray );
		}
	}
	
	protected function PopulateSaveDataForSlotType(saveType:int, parentObject:CScriptedFlashArray, allowEmptySlot:bool):void
	{
		IngameMenu_PopulateSaveDataForSlotType(m_flashValueStorage, saveType, parentObject, allowEmptySlot);
	}
	
	event  OnLoadSaveImageCancelled():void
	{
		theGame.FreeScreenshotData();
	}
	
	event  OnScreenshotDataRequested(saveIndex:int):void
	{
		var targetSaveInfo 	: SSavegameInfo;
		var saveGames		: array< SSavegameInfo >;
		
		theGame.ListSavedGames( saveGames );
		
		if (saveIndex >= 0 && saveIndex < saveGames.Size())
		{
			targetSaveInfo = saveGames[saveIndex];
			
			theGame.RequestScreenshotData(targetSaveInfo);
		}
	}
	
	event  OnCheckScreenshotDataReady():void
	{
		if (theGame.IsScreenshotDataReady())
		{
			m_fxOnSaveScreenshotRdy.InvokeSelf();
		}
	}
	
	protected function SendInstalledDLCList():void
	{
		var currentData : CScriptedFlashObject;
		var dataArray : CScriptedFlashArray;
		var dlcManager : CDLCManager;
		var i : int;
		var dlcList : array<name>;
		
		var currentName : string;
		var currentDesc : string;
		
		
		
		dataArray = m_flashValueStorage.CreateTempFlashArray();
		
		dlcManager = theGame.GetDLCManager();
		dlcManager.GetDLCs(dlcList);
		
		for (i = 0; i < dlcList.Size(); i += 1)
		{
			
			
				currentData = m_flashValueStorage.CreateTempFlashObject();
				
				currentName = GetLocStringByKeyExt( "content_name_" + NameToString(dlcList[i]) );
				currentDesc = "";
				
				if (currentName != "")
				{
					currentData.SetMemberFlashString("label", currentName);
					currentData.SetMemberFlashString("desc", currentDesc);
					
					dataArray.PushBackFlashObject(currentData);
				}
			
		}
		
		
		
		m_flashValueStorage.SetFlashArray("ingamemenu.installedDLCs", dataArray);
	}
	
	protected function SendRescaleData():void
	{
		var currentData : CScriptedFlashObject;
		
		currentData = m_flashValueStorage.CreateTempFlashObject();
		
		currentData.SetMemberFlashNumber("initialHScale", theGame.GetUIHorizontalFrameScale() );
		currentData.SetMemberFlashNumber("initialVScale", theGame.GetUIVerticalFrameScale() );
		
		m_flashValueStorage.SetFlashObject("ingamemenu.uirescale", currentData);
	}
	
	protected function SendControllerData():void
	{
		var dataFlashArray : CScriptedFlashArray;
		
		if ( (W3ReplacerCiri)thePlayer )
		{
			dataFlashArray = InGameMenu_CreateControllerDataCiri(m_flashValueStorage);
		}
		else
		{
			dataFlashArray = InGameMenu_CreateControllerData(m_flashValueStorage);
		}
		
		m_flashValueStorage.SetFlashArray( "ingamemenu.gamepad.mappings", dataFlashArray );
	}
	
	protected function SendKeybindData():void
	{
		var dataFlashArray : CScriptedFlashArray;
		
		dataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		
		IngameMenu_GatherKeybindData(dataFlashArray, m_flashValueStorage);
		
		m_flashValueStorage.SetFlashArray( "ingamemenu.keybindValues", dataFlashArray );
	}
	
	event  OnClearKeybind(keybindTag:name):void
	{
		hasChangedOption = true;
		mInGameConfigWrapper.SetVarValue('PCInput', keybindTag, "IK_None;IK_None"); 
		SendKeybindData();
	}
	
	
	
	protected function GetKeybindGroupTag(keybindName : name) : name
	{
		if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap1'))
		{
			return 'input_overlap1';
		}
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap2'))
		{
			return 'input_overlap2';
		}
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap3'))
		{
			return 'input_overlap3';
		}
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap4'))
		{
			return 'input_overlap4';
		}
		else if (mInGameConfigWrapper.DoVarHasTag('PCInput', keybindName, 'input_overlap5'))
		{
			return 'input_overlap5';
		}
		
		return '';
	}
	
	event  OnChangeKeybind(keybindTag:name, newKeybindValue:EInputKey):void
	{
		var newSettingString : string;
		var exisitingKeybind : name;
		var groupIndex : int;
		var keybindChangedMessage : string;
		var numKeybinds : int;
		var i : int;
		var currentBindingTag : name;
		
		var iterator_KeybindName : name;
		var iterator_KeybindKey : string;
		
		hasChangedOption = true;
		
		newSettingString = newKeybindValue;
		
		
		
		{
			groupIndex = IngameMenu_GetPCInputGroupIndex();
		
			if (groupIndex != -1)
			{
				numKeybinds = mInGameConfigWrapper.GetVarsNumByGroupName('PCInput');
				currentBindingTag = GetKeybindGroupTag(keybindTag);
				
				for (i = 0; i < numKeybinds; i += 1)
				{
					iterator_KeybindName = mInGameConfigWrapper.GetVarName(groupIndex, i);
					iterator_KeybindKey = mInGameConfigWrapper.GetVarValue('PCInput', iterator_KeybindName);
					
					iterator_KeybindKey = StrReplace(iterator_KeybindKey, ";IK_None", ""); 
					iterator_KeybindKey = StrReplace(iterator_KeybindKey, "IK_None;", "");
					
					if (iterator_KeybindKey == newSettingString && iterator_KeybindName != keybindTag && 
						(currentBindingTag == '' || currentBindingTag != GetKeybindGroupTag(iterator_KeybindName)))
					{
						if (keybindChangedMessage != "")
						{
							keybindChangedMessage += ", ";
						}
						keybindChangedMessage += IngameMenu_GetLocalizedKeybindName(iterator_KeybindName);
						OnClearKeybind(iterator_KeybindName);
					}
				}
			}
			
			if (keybindChangedMessage != "")
			{
				keybindChangedMessage += " </br>" + GetLocStringByKeyExt("key_unbound_message");
				showNotification(keybindChangedMessage);
			}
		}
		
		newSettingString = newKeybindValue + ";IK_None"; 
		mInGameConfigWrapper.SetVarValue('PCInput', keybindTag, newSettingString);
		SendKeybindData();
	}
	
	event  OnSmartKeybindEnabledChanged(value:bool):void
	{
		smartKeybindingEnabled = value;
	}
	
	event  OnInvalidKeybindTried(keyCode:EInputKey):void
	{
		showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_now"));
		OnPlaySoundEvent("gui_global_denied");
	}
	
	event  OnLockedKeybindTried():void
	{
		showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_now"));
		OnPlaySoundEvent("gui_global_denied");
	}
	
	event  OnResetKeybinds():void
	{
		mInGameConfigWrapper.ResetGroupToDefaults('PCInput');
		SendKeybindData();
		showNotification(inGameMenu_TryLocalize("menu_option_reset_successful"));
		
		hasChangedOption = true;
	}
	
	function PlayOpenSoundEvent()
	{
	}
}
