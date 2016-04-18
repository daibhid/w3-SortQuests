/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
struct SUISavedData
{
	var panelName : name;
	var selectedTag : name;
	
	
	var openedCategories : array<name>;
	var gridItem : SItemUniqueId;
	var slotID : int;
	var selectedModule : int;
};

struct SGlossaryEntry
{
	var panelName : name;
	var newEntry : CJournalBase;
	var tag : name;
};

struct SMappinEntry
{
	var newMappin : name;
	var newMappinType : name;
};

struct SCraftingFilters
{
	var showCraftable : bool; default showCraftable = true;
	var showMissingIngre : bool; default showMissingIngre = true;
	var showAlreadyCrafted : bool; default showAlreadyCrafted = true;
}

struct SEnchantmentFilters
{
	var showHasIngredients : bool; default showHasIngredients = true;
	var showMissingIngredients : bool; default showMissingIngredients = true;
	var showLevel1 : bool; default showLevel1 = true;
	var showLevel2 : bool; default showLevel2 = true;
	var showLevel3 : bool; default showLevel3 = true;
}

import struct SGuiEnhancementInfo
{
	import var enhancedItem : name;
	import var enhancement : name;
}

enum EUserDialogButtons
{
	UDB_Ok,
	UDB_OkCancel,
	UDB_YesNo,
	UDB_None
}
 
enum EUniqueMessageIDs
{
	UMID_SignedOut = 666,
	UMID_ControllerDisconnected = 789,
	UMID_KinectMissing = 667,
	UMID_QuitGameMessage = 69,
	UMID_SigningInPleaseWait = 668,
	UMID_UserSettingsCorrupted = 777,
	UMID_CorruptedSaveDataOverwrite = 778,
	UMID_LoadingFailed = 779,
	UMID_SaveCompatWarning = 780,
	UMID_MissingContentOnLoadError = 218793,
	UMID_MissingContentOnDialogError = 129038,
	UMID_LoadingFailedDamagedData = 865,
	UMID_ForceManualSaveWindow = 129039,
	UMID_GraphicsRefreshing = 9999,
	UMID_QuestBlockMessage = 10
}

enum ELockedControlScheme
{
	LCS_None,
	LCS_Gamepad,
	LCS_KbMouse
}

import class CR4GuiManager extends CGuiManager
{
	private var lastOpenedCommonMenuName : name;
	
	private var isColorBlindMode:bool; 
	
	saved var displayedObjectivesGUID : array<CGUID>;
	
	saved var UISavedData : array<SUISavedData>;
	
	private var signoutOccurred : bool;
	default signoutOccurred = false;
	
	private var signInChangeInProgress : bool;
	default signInChangeInProgress = false;
	
	private var isDuringFirstStartup : bool;
	default isDuringFirstStartup = true;
	
	private var ignoreControllerDisconnectionEvents : bool;
	default ignoreControllerDisconnectionEvents = true;
	
	private var controllerDisconnected : bool;
	default controllerDisconnected = false;
	
	public var potalConfirmationPending : bool;
	default potalConfirmationPending = false;
	private var pendingPortalConfirmationPauseParam : bool;
	default pendingPortalConfirmationPauseParam = false;
	
	public var mouseCursorRequestStack : int;
	default mouseCursorRequestStack = 0;
	
	private var tutHideCounter		 : int;
	private var tutForcedhideCounter : int;
	
	protected var guiSceneController : CR4GuiSceneController;
	protected var hudEventController : CR4HudEventController;
	
	public var lastRequestedCreditsIndex : int;
	
	saved var NewestItems : array<SItemUniqueId>;
	saved var GlossaryEntries : array<SGlossaryEntry>;
	saved var AlchemyEntries : array<SGlossaryEntry>;
	saved var CraftingEntries : array<SGlossaryEntry>;
	saved var SkillsEntries : array<ESkill>;
	saved var MappinEntries : array<SMappinEntry>;
	saved var CraftingFilters : SCraftingFilters;
	saved var AlchemyFiltters : SCraftingFilters;
	saved var EnchantmentFilters : SEnchantmentFilters;
	saved var PinnedCraftingRecipe : name;
	saved var InventorySortingMode : int;
	
	private var bUsePortal : bool;
	private var bUsePortalAnswered : bool;
	private var horseUnmountFeedbackActive : bool;
	
	private var hideMessageRequestId:int;

	private var bKinectMessageAlreadyShown : bool;
	default bKinectMessageAlreadyShown = false;
	
	private var m_cachedHold:bool;
	private var m_cachedHold_gpadKeyCode:int;
	private var m_cachedHold_kbKeyCode:int;
	private var m_cachedHold_label:string;
	private var m_cachedHold_holdDuration:float;
	private var m_cachedHold_intName:name;
	
	private var inGameConfigBufferedWrapper : CInGameConfigBufferedWrapper;

	import final function IsAnyMenu() : bool;
	import final function GetRootMenu() : CR4Menu;
	import final function GetPopup( popupName : name ) : CR4Popup;
	import final function GetPopupList( out popupNames : array< name > );
	import final function SendCustomUIEvent( eventName : name );
	
	
	import final function SetSceneEntityTemplate( template : CEntityTemplate , optional animationName : name );
	import final function ApplyAppearanceToSceneEntity( appearanceName : name );
	import final function UpdateSceneEntityItems( items : array< name >, enhancements : array< SGuiEnhancementInfo > );
	import final function SetSceneCamera( cameraPosition : Vector, cameraRotation : EulerAngles );
	import final function SetupSceneCamera( lookAtPos : Vector, cameraRotation : EulerAngles, distance : float, fov : float );
	import final function SetEntityTransform( position : Vector, rotation : EulerAngles, scale : Vector );
	import final function SetSceneEnvironmentAndSunPosition( envDef : CEnvironmentDefinition, sunRotation : EulerAngles );
	import final function EnableScenePhysics( enable : bool );
	import final function SetBackgroundTexture( texture : CResource );
	
	event  OnGameStart( newOrRestored : bool )
	{
		var ingameMenu : CR4IngameMenu;
		
		ingameMenu = (CR4IngameMenu)theGame.GetGuiManager().GetRootMenu();
	
		if ( newOrRestored )
		{
			hideMessageRequestId = -1;
			lastOpenedCommonMenuName = '';
			displayedObjectivesGUID.Clear();
			
			UISavedData.Clear();
			
			NewestItems.Clear();
			GlossaryEntries.Clear();
			SkillsEntries.Clear();
			MappinEntries.Clear();
			AlchemyEntries.Clear();
			CraftingEntries.Clear();		
		
			tutHideCounter = 0;
			tutForcedhideCounter = 0;
			
			m_cachedHold = false;
		}
	}
	
	event  OnGameEnd()
	{
	}

	event  OnWorldStart( newOrRestored : bool )
	{
	}

	event  OnWorldEnd()
	{
	}
	
	event  OnFailedCreateMenu()
	{
	}
	
	public function RequestCreditsMenu(creditsIndex : int)
	{
		var rootMenu : CR4Menu;
		var ingameMenu : CR4IngameMenu;
		
		lastRequestedCreditsIndex = creditsIndex;
		rootMenu = theGame.GetGuiManager().GetRootMenu();
		if ( rootMenu )
		{
			ingameMenu = (CR4IngameMenu)rootMenu.GetSubMenu();
			if ( ingameMenu )
			{
				ingameMenu.OnRequestSubMenu( 'CreditsMenu' );
			}
		}
		else
		{
			theGame.RequestMenu( 'CreditsMenu' );
		}
	}
	
	public function GetInGameConfigBufferedWrapper() : CInGameConfigBufferedWrapper
	{
		if (!inGameConfigBufferedWrapper)
		{
			inGameConfigBufferedWrapper = new CInGameConfigBufferedWrapper in this;
			inGameConfigBufferedWrapper.inGameConfig = theGame.GetInGameConfigWrapper();
		}
		
		return inGameConfigBufferedWrapper;
	}
	
	public function SetCraftingFilters(showHasIngre : bool, showMissingIngre : bool, showAlreadyCrafted : bool )
	{
		CraftingFilters.showCraftable = showHasIngre;
		CraftingFilters.showMissingIngre = showMissingIngre;
		CraftingFilters.showAlreadyCrafted = showAlreadyCrafted;
	}
	
	public function GetCraftingFilters() : SCraftingFilters
	{
		
		if (CraftingFilters.showCraftable == false && CraftingFilters.showMissingIngre == false && CraftingFilters.showAlreadyCrafted == false)
		{
			CraftingFilters.showCraftable = true;
			CraftingFilters.showMissingIngre = true;
			CraftingFilters.showAlreadyCrafted = true;
		}
		
		return CraftingFilters;
	}
	
	public function SetAlchemyFiltters(showHasIngre : bool, showMissingIngre : bool, showAlreadyCrafted : bool )
	{
		AlchemyFiltters.showCraftable = showHasIngre;
		AlchemyFiltters.showMissingIngre = showMissingIngre;
		AlchemyFiltters.showAlreadyCrafted = showAlreadyCrafted;
	}
	
	public function GetAlchemyFiltters() : SCraftingFilters
	{
		
		if (AlchemyFiltters.showCraftable == false && AlchemyFiltters.showMissingIngre == false && AlchemyFiltters.showAlreadyCrafted == false)
		{
			AlchemyFiltters.showCraftable = true;
			AlchemyFiltters.showMissingIngre = true;
			AlchemyFiltters.showAlreadyCrafted = true;
		}
		
		return AlchemyFiltters;
	}
	
	public function SetEnchantmentFilters(showHasIngredients : bool, showMissingIngredients : bool, showLevel1 : bool, showLevel2 : bool, showLevel3 : bool) : void
	{
		EnchantmentFilters.showHasIngredients = showHasIngredients;
		EnchantmentFilters.showMissingIngredients = showMissingIngredients;
		EnchantmentFilters.showLevel1 = showLevel1;
		EnchantmentFilters.showLevel2 = showLevel2;
		EnchantmentFilters.showLevel3 = showLevel3;
	}
	
	public function GetEnchantmentFilters() : SEnchantmentFilters
	{
		
		if (EnchantmentFilters.showHasIngredients == false && EnchantmentFilters.showMissingIngredients == false && 
			EnchantmentFilters.showLevel1 == false && EnchantmentFilters.showLevel2 == false && EnchantmentFilters.showLevel3 == false)
		{
			EnchantmentFilters.showHasIngredients = true;
			EnchantmentFilters.showMissingIngredients = true;
			EnchantmentFilters.showLevel1 = true;
			EnchantmentFilters.showLevel2 = true;
			EnchantmentFilters.showLevel3 = true;
		}
		
		return EnchantmentFilters;	
	}
	
	public function SetPinnedCraftingRecipe(tag : name):void
	{
		PinnedCraftingRecipe = tag;
	}
	
	public function SetInventorySortingMode(value : int):void
	{
		InventorySortingMode = value;
	}
	
	public function GetInventorySortingMode() : int
	{
		return InventorySortingMode;
	}
	
	protected function FinalizeConfigBuffer(keepValues : bool):void
	{
		var buffer : CInGameConfigBufferedWrapper;
		var menuBase : CR4MenuBase;
		var ingameMenu : CR4IngameMenu;
		var hud : CR4ScriptedHud;
		
		buffer = GetInGameConfigBufferedWrapper();
		
		if (buffer.buffer.Size() > 0) 
		{
			if (keepValues)
			{
				buffer.ClearBuffer();
				theGame.SaveUserSettings();
			}
			else
			{
				buffer.UndoAndFlushBuffer();
				theGame.SaveUserSettings();
				
				menuBase = (CR4MenuBase)GetRootMenu();
				if (menuBase)
				{
					ingameMenu = (CR4IngameMenu)(menuBase.GetSubMenu());
					
					if (ingameMenu)
					{
						ingameMenu.ReopenMenu();
					}
				}
			}
		}
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.RefreshHudConfiguration();
		}
	}
	
	public function GetLockedControlScheme():ELockedControlScheme
	{
		var inGameConfigWrapper : CInGameConfigWrapper;
		var configValue : ELockedControlScheme;
		
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		configValue = (int)inGameConfigWrapper.GetVarValue('Hidden', 'LockControlScheme');
		
		return configValue;
	}
	
	public function GetCommonMenu() : CR4CommonMenu
	{
		return ( CR4CommonMenu )GetRootMenu();
	}	
	
	public function GetSceneController() : CR4GuiSceneController
	{
		if ( !guiSceneController )
		{
			guiSceneController = new CR4GuiSceneController in this;
		}
		
		return guiSceneController;
	}

	public function GetHudEventController() : CR4HudEventController
	{
		if ( !hudEventController )
		{
			hudEventController = new CR4HudEventController in this;
		}
		
		return hudEventController;
	}
	
	public function OnEnteredStartScreen() : void
	{
		var startScreenMenu : CR4StartScreenMenu;
		
		ignoreControllerDisconnectionEvents = true;
		
		if( signInChangeInProgress )
		{
			
			
			HideUserDialog( UMID_SigningInPleaseWait );
			
			startScreenMenu = (CR4StartScreenMenu)(GetRootMenu());
			if( startScreenMenu )
			{
				startScreenMenu.setWaitingText();
			}
		}
		
		UpdateSignoutMessagePending();
	}
	
	public function OnEnteredConfigScreen() : void
	{
		SetIsDuringFirstStartup( false );
		ignoreControllerDisconnectionEvents = false;
	}
	
	public function OnEnteredMainMenu() : void
	{
		ignoreControllerDisconnectionEvents = false;
		
		if (controllerDisconnected)
		{
			ShowControllerDisconnectionMessage();
		}
	}
	
	public function OnControllerDisconnected() : void
	{
		if( theGame.isUserSignedIn() )
		{
			controllerDisconnected = true;
			ShowControllerDisconnectionMessage();
			theGame.ToggleUserProfileManagerInputProcessing( true );
		}
	}
	
	public function OnControllerReconnected() : void
	{
		HideUserDialog( UMID_ControllerDisconnected );
		controllerDisconnected = false;
	}
	
	public function ShowControllerDisconnectionMessage() : void
	{
		var title : string;
		var message : string;
		
		if( !ignoreControllerDisconnectionEvents )
		{
			switch( theGame.GetPlatform() )
			{
			case Platform_PS4:
				title = "msg_controller_disconnected_title_PS4";
				message = "error_message_no_controller_ps4";
				break;
				
			case Platform_Xbox1:
				title = "msg_controller_disconnected_title_X1";
				message = "error_message_no_controller_x1";
				break;
				
			default:
				title = "msg_controller_disconnected_title";
				message = "error_message_no_controller_x1";
			}
			
			ShowUserDialog( UMID_ControllerDisconnected, title, message, UDB_None );
		}
	}
	
	public function OnSignInStarted() : void
	{
		var startScreenMenu : CR4StartScreenMenu;
		
		signInChangeInProgress = true;
		
		startScreenMenu = (CR4StartScreenMenu)(GetRootMenu());
		if (startScreenMenu)
		{
			startScreenMenu.setWaitingText();
		}
		else
		{
			ShowUserDialog( UMID_SigningInPleaseWait, "", "panel_please_wait", UDB_None );
		}
	}
	
	public function OnSignInCancelled() : void
	{
		var menuBase : CR4MenuBase;
		var startScreenMenu : CR4StartScreenMenu;
		var ingameMenu : CR4IngameMenu;
		
		signInChangeInProgress = false;
		
		HideUserDialog( UMID_SigningInPleaseWait );
		theGame.ToggleUserProfileManagerInputProcessing( true );
		
		menuBase = (CR4MenuBase)GetRootMenu();
		
		startScreenMenu = (CR4StartScreenMenu)(menuBase);
		if (startScreenMenu)
		{
			startScreenMenu.setStandardtext();
			UpdateSignoutMessagePending();
		}
		else
		{
			ingameMenu = (CR4IngameMenu)(menuBase.GetSubMenu());
			if( ingameMenu )
			{
				ingameMenu.OnUserSignInCancelled();
			}
		}
	}
	
	public function OnSignIn():void
	{
		var menuBase : CR4MenuBase;
		var startScreenMenu : CR4StartScreenMenu;
		var ingameMenu : CR4IngameMenu;
		
		signInChangeInProgress = false;
		
		menuBase = (CR4MenuBase)GetRootMenu();
		
		startScreenMenu = (CR4StartScreenMenu)(menuBase);
		if (startScreenMenu) 
		{
			startScreenMenu.startFade();
		}
		else
		{
			ingameMenu = (CR4IngameMenu)(menuBase.GetSubMenu());
			if( ingameMenu )
			{
				ingameMenu.OnUserSignIn();
			}
			
			HideUserDialog( UMID_SigningInPleaseWait );
			theGame.ToggleUserProfileManagerInputProcessing( true );
		}
	}
	
	public function OnSignOut():void
	{
		signoutOccurred = true;
		
		
		theGame.ToggleUserProfileManagerInputProcessing( true );
	}
	
	public function ShowKinectMessage():void
	{
		var kinectRecognizer : CR4KinectSpeechRecognizerListenerScriptProxy;
		var localisedMessage : string;
		
		if (theGame.GetPlatform() != Platform_Xbox1)
		{
			return;
		}
		
		
		if( bKinectMessageAlreadyShown )
		{
			return;
		}
		
		kinectRecognizer = theGame.GetKinectSpeechRecognizer();
		
		if (!kinectRecognizer.IsSupported())
		{
			localisedMessage = GetLocStringByKeyExt( "error_message_kinect_not_supported" );
		
			bKinectMessageAlreadyShown = true;
			ShowNotification( localisedMessage, 9000 );
			theSound.SoundEvent("gui_global_denied");
		}
	}
	
	public function SetIsDuringFirstStartup( firstStartup : bool ) : void
	{
		isDuringFirstStartup = firstStartup;
	}
	
	public function UpdateSignoutMessagePending() : void
	{
		if ( signoutOccurred && !isDuringFirstStartup && !signInChangeInProgress )
		{
			signoutOccurred = false;
			ShowUserDialog( UMID_SignedOut, "", "error_message_sign_in_change", UDB_Ok );
		}
	}
	
	public function TryQuitGame() : void
	{
		ShowUserDialog(UMID_QuitGameMessage, "", "error_message_exit_game", UDB_OkCancel);
	}
	
	public function OnUserSettingsCorrupted() : void
	{
		ShowUserDialog( UMID_UserSettingsCorrupted, "", "error_message_settings_corrupted", UDB_Ok );
	}
	
	
	
	public function OnLoadingFailed( sres : ESessionRestoreResult, missingContent : array< name > ) : void
	{
		var specialMsgText : string;
		var i:int;
		var contentKey : string;
		var len : int;
		var len_minus_one : int;
		var htmlNewline:string;
		htmlNewline = "&#10;";
		
		if (sres == RESTORE_DataCorrupted)
		{
			if (theGame.GetPlatform() == Platform_PS4)
			{
				ShowUserDialog( UMID_LoadingFailed, "", "error_message_damaged_save_PS4", UDB_Ok );
			}
			else
			{
				ShowUserDialog( UMID_LoadingFailed, "", "error_message_damaged_save", UDB_Ok );
			}	
		}
		else if (sres == RESTORE_MissingContent)
		{
			ShowUserDialog( UMID_LoadingFailed, "", "error_message_new_game_not_ready", UDB_Ok );
		}
		else if (sres == RESTORE_InternalError || sres == RESTORE_NoGameDefinition)
		{
			if (theGame.GetPlatform() == Platform_PS4)
			{
				ShowUserDialog( UMID_LoadingFailed, "", "error_message_damaged_save_unavailable_ps4", UDB_Ok );
			}
			else
			{
				ShowUserDialog( UMID_LoadingFailed, "", "error_message_damaged_save_unavailable", UDB_Ok );
			}
		}
		else if (sres == RESTORE_DLCRequired)
		{
			if (theGame.GetPlatform() == Platform_PS4)
			{
				specialMsgText = GetLocStringByKeyExt("error_message_loadsave_missing_dlc_error_ps4");
			}
			else
			{
				specialMsgText = GetLocStringByKeyExt("error_message_loadsave_missing_dlc_error_x1");
			}
			
			specialMsgText += ":" + htmlNewline;
			len = missingContent.Size();
			len_minus_one = len - 1;
			
			for (i = 0; i < len; i += 1)
			{
				contentKey = "content_name_" + NameToString(missingContent[i]);
				specialMsgText += GetLocStringByKeyExt(contentKey);
				
				if (i < len_minus_one)
				{
					specialMsgText += htmlNewline;
				}
			}
			
			ShowUserDialogAdv( UMID_LoadingFailed, "", specialMsgText, false, UDB_Ok );
		}
		else if (sres == RESTORE_WrongGameVersion)
		{
			ShowUserDialog( UMID_LoadingFailed, "", "error_save_from_newer_version", UDB_Ok );
		}
		else
		{
			ShowUserDialog( UMID_LoadingFailed, "", "error_message_damaged_save_unavailable", UDB_Ok );		
		}
	}
	
	public function OnCorruptedSaveDataOverwrite() : void
	{
		ShowUserDialog( UMID_CorruptedSaveDataOverwrite, "", "error_message_corrupted_save_overwrite", UDB_OkCancel );
	}
	
	public function HideTutorial(value:bool, forced:bool):void
	{
		var tutorialPopupRef : CR4TutorialPopup;
		
		if (!forced)
		{
			if (value)
			{
				tutHideCounter =  tutHideCounter + 1;
			}
			else
			{
				tutHideCounter =  tutHideCounter - 1;
			}
		}
		else
		{
			if (value)
			{
				tutForcedhideCounter =  tutForcedhideCounter + 1;
			}
			else
			{
				tutForcedhideCounter =  tutForcedhideCounter - 1;
			}
		}
		tutorialPopupRef = (CR4TutorialPopup) GetPopup('TutorialPopup');
		if (tutorialPopupRef)
		{
			tutorialPopupRef.SetInvisible(tutHideCounter > 0, tutForcedhideCounter > 0);
		}
	}

	public function GetTutorialVisibility(out hidden:bool, out forceHidden:bool):void
	{
		hidden = tutHideCounter > 0;
		forceHidden = tutForcedhideCounter > 0;
	}
	
	
	
	import final function PlayFlashbackVideoAsync( videoFile : string, optional looped : bool );
	
	
	import final function CancelFlashbackVideo();

	event OnCanSkipChanged( newVal : bool )
	{
		var hud : CR4ScriptedHud;
		var dialogModule : CR4HudModuleDialog;
		
		LogChannel( 'Gui', "CR4GuiManager::OnCanSkipChanged " + newVal );
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		if (hud)
		{
			dialogModule = hud.GetDialogModule();
			
			if (dialogModule)
			{
				dialogModule.UpdateCanBeSkipped(newVal);
			}
		}
	}


	

	event  OnSwipe( swipe : int ) 
	{
		var outKeys : array< name >;
		var lastMenuName : name;
		var allowOpen : bool;
		
		LogChannel( 'Gui', "CR4GuiManager::OnSwipe " + swipe );

		if ( theGame.IsBlackscreenOrFading() || theGame.IsDialogOrCutscenePlaying() )
		{
			return false;
		}
		
		if ( swipe == 2 || swipe == 3 ) 
		{
			if(thePlayer.IsActionAllowed(EIAB_OpenMap))
				theGame.RequestMenuWithBackground( 'MapMenu', 'CommonMenu' );
				
			
		}
	}
	
	public function SetLastOpenedCommonMenuName( menuName : name )
	{
		lastOpenedCommonMenuName = menuName;
	}

	public function GetLastOpenedCommonMenuName() : name
	{
		return lastOpenedCommonMenuName;
	}
	
	public function FindDisplayedObjectiveGUID( guid : CGUID ) : bool
	{
		if( displayedObjectivesGUID.FindFirst( guid ) > -1 )
		{
			return true;
		}
		return false;
	}	

	public function SaveDisplayedObjectiveGUID( guid : CGUID ) : void
	{
		if( !FindDisplayedObjectiveGUID( guid ) )
		{
			displayedObjectivesGUID.PushBack( guid );
		}
	}
	
	public function UpdateUISavedData( panelName : name, openedCategories : array<name>, selectedTag : name, selectedModule : int, optional gridItem : SItemUniqueId, optional slotID : int ) : void
	{
		var i : int;
		
		for( i = 0; i < UISavedData.Size(); i += 1 )
		{
			if( UISavedData[i].panelName == panelName )
			{
				UISavedData[i].openedCategories = openedCategories;
				UISavedData[i].selectedTag = selectedTag;
				UISavedData[i].gridItem = gridItem;
				UISavedData[i].slotID = slotID;
				UISavedData[i].selectedModule = selectedModule;
				LogChannel('Saved',panelName+" UISavedData.selectedModule "+selectedModule+" "+selectedTag+" "+openedCategories[0]);
				return;
			}
		}
		AddNewUISavedData( panelName, openedCategories, selectedTag, selectedModule, gridItem, slotID );
	}
	
	public function AddNewUISavedData( panelName : name, openedCategories : array<name>, selectedTag : name, selectedModule : int, optional gridItem : SItemUniqueId, optional slotID : int ) : void
	{
		var newUIData : SUISavedData;
		
		newUIData.panelName = panelName;
		newUIData.openedCategories = openedCategories;
		newUIData.selectedTag = selectedTag;
		newUIData.gridItem = gridItem;
		newUIData.slotID = slotID;
		newUIData.selectedModule = selectedModule;
		LogChannel('Saved',panelName+" UISavedData.selectedModule "+selectedModule+" "+selectedTag+" "+openedCategories[0]);
		
		UISavedData.PushBack(newUIData);
	}
	
	public function RemoveUISavedData( panelName : name ) : void
	{
		var i : int;
		for( i = 0; i < UISavedData.Size(); i += 1 )
		{
			if( UISavedData[i].panelName == panelName )
			{
				UISavedData.Erase(i);
				return ;
			}
		}
	}
	
	public function GetUISavedData( panelName : name ) : SUISavedData
	{
		var i : int;
		var emptyUIData : SUISavedData;
		for( i = 0; i < UISavedData.Size(); i += 1 )
		{
			if( UISavedData[i].panelName == panelName )
			{
				LogChannel('Loaded',UISavedData[i].panelName+" UISavedData[i].selectedModule "+UISavedData[i].selectedModule+" "+UISavedData[i].selectedTag+" "+UISavedData[i].openedCategories[0]);
				return UISavedData[i];
			}
		}
		return emptyUIData;
	}
	
	public var lastMessageData : W3MessagePopupData;
	
	public function GetHideMessageRequestId():int
	{
		return hideMessageRequestId;
	}
	
	
	public function ShowUserDialog( messageId : int, title : string, message : string, type : EUserDialogButtons)
	{
		if( messageId != UMID_ControllerDisconnected )
		{
			theGame.ToggleUserProfileManagerInputProcessing( false );
		}
		
		ShowProgressDialog(messageId, title, message, true, type, -1, UMPT_None, '');
	}
	
	public function ShowUserDialogAdv(messageId : int, title : string, message : string, localizationNeeded:bool, type : EUserDialogButtons)
	{
		if( messageId != UMID_ControllerDisconnected )
		{
			theGame.ToggleUserProfileManagerInputProcessing( false );
		}
		
		ShowProgressDialog(messageId, title, message, localizationNeeded, type, -1, UMPT_None, '');
	}
	
	public function ShowProgressDialog( messageId : int, title : string, message : string, localizationNeeded:bool, type : EUserDialogButtons, progressValue:float, progressType:EUserMessageProgressType, progressTag:name)
	{
		var messageData 	: W3MessagePopupData;
		var messagePopupRef : CR4MessagePopup;
		
		LogChannel('SYS_MESSAGE', "ShowUserDialog; messageId: " + messageId);
		messageData = new W3MessagePopupData in this;
		messageData.titleText = title;
		messageData.messageText = message;
		messageData.autoLocalize = localizationNeeded;
		messageData.messageId = messageId;
		messageData.progress = progressValue;
		messageData.progressType = progressType;
		messageData.progressTag = progressTag;
		
		
		if (messageId == UMID_ControllerDisconnected)
		{
			messageData.priority = 1;
		}
		else		
		{
			messageData.priority = 0;
		}
		messageData.setActionsByType(type);
		
		lastMessageData = messageData;
		
		messagePopupRef = (CR4MessagePopup)GetPopup('MessagePopup');
		if (!messagePopupRef)
		{
			theGame.RequestPopup( 'MessagePopup',  messageData );
			hideMessageRequestId = -1;
		}
		else
		{
			messagePopupRef.ShowMessage( messageData );
		}
	}
	
	public function UpdateUserDialogProgress( messageId : int, progressValue : float ) : void
	{
		var messagePopupRef : CR4MessagePopup;
		
		messagePopupRef = (CR4MessagePopup)GetPopup('MessagePopup');
		if (messagePopupRef && messagePopupRef.GetCurrentMsgId() == messageId)
		{
			
			
			messagePopupRef.DisplayProgressBar(progressValue, UMPT_Content); 
		}
		else
		{
			
		}
	}
	
	public function HideUserDialog( messageId : int ) : void
	{
		var messagePopupRef  : CR4MessagePopup;
		
		messagePopupRef = (CR4MessagePopup)GetPopup('MessagePopup');
		if (messagePopupRef)
		{
			messagePopupRef.HideMessage(messageId);
		}
		else
		{
			hideMessageRequestId = messageId;
		}
	}
	
	public function UserDialogCallback( messageId : int, actionId : EUserMessageAction ) : void
	{
		var ingameMenu 		: CR4IngameMenu;
		var menuBase 		: CR4MenuBase;
		var hud 			: CR4ScriptedHud;
		var initData 		: W3MenuInitData;
		var numSaveSlots 	: int;
		var saveGames		: array< SSavegameInfo >;
		var currentSave		: SSavegameInfo;
		var numSavesAdded	: int;
		
		var i				: int;
		
		if (messageId == UMID_QuitGameMessage && actionId == UMA_Ok)
		{
			theGame.RequestEndGame();
		}
		else if (messageId == UMID_MissingContentOnDialogError)
		{
			hud = (CR4ScriptedHud)(theGame.GetHud());
			
			if (hud)
			{
				hud.HandleDialogClosed(messageId);
			}
		}
		else if (messageId == UMID_LoadingFailedDamagedData)
		{
			menuBase = (CR4MenuBase)GetRootMenu();
			ingameMenu = (CR4IngameMenu)(menuBase.GetSubMenu());
			if( ingameMenu )
			{
				ingameMenu.OnSaveLoadingFailed();
			}
		}
		else if (messageId == UMID_ForceManualSaveWindow)
		{
			if( actionId == UMA_Ok )
			{
				initData = new W3MenuInitData in this;
				initData.setDefaultState('SaveGame');
				
				
				theGame.RequestMenu( 'IngameMenu', initData );
			}
			else
			{
				HideUserDialog(messageId);
			}
		}
		else if (messageId == UMID_GraphicsRefreshing)
		{
			FinalizeConfigBuffer(actionId == UMA_Ok);
		}
		
		LogChannel('SYS_MESSAGE', "UserDialogCallback; messageId: " + messageId + "; actionId: " + actionId);
		theGame.OnUserDialogCallback( messageId, actionId );
		
		theGame.ToggleUserProfileManagerInputProcessing( true );
	}
	
	public function OnMessageHiding( messageId : int )
	{
		var ingameMenu 		: CR4IngameMenu;
		var menuBase 		: CR4MenuBase;
		
		if (messageId == UMID_GraphicsRefreshing)
		{
			FinalizeConfigBuffer(false);
		}
	}
	
	public function ShowNotification(messageText : string, optional duration : float) : void
	{
		var notificationData : W3NotificationData;
		var overlayPopupRef  : CR4OverlayPopup;
		
		overlayPopupRef = (CR4OverlayPopup)GetPopup('OverlayPopup');
		if (!overlayPopupRef)
		{
			notificationData = new W3NotificationData in this;
			notificationData.messageText = messageText;
			notificationData.duration = duration;
			theGame.RequestPopup( 'OverlayPopup',  notificationData );
		}
		else
		{
			overlayPopupRef.ShowNotification(messageText, duration);
		}
	}
	
	public function RequestMouseCursor(showMouseCursor : bool) : void
	{
		var notificationData : W3NotificationData;
		var overlayPopupRef  : CR4OverlayPopup;
		
		if (showMouseCursor)
		{
			mouseCursorRequestStack += 1;
		}
		else if (mouseCursorRequestStack > 0)
		{
			mouseCursorRequestStack -= 1;
		}
		
		overlayPopupRef = (CR4OverlayPopup)GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.RequestMouseCursor(showMouseCursor);
		}
	}
	
	public function ForceHideMouseCursor(value : bool) : void
	{
		var notificationData : W3NotificationData;
		var overlayPopupRef  : CR4OverlayPopup;
		
		overlayPopupRef = (CR4OverlayPopup)GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.ForceHideMouseCursor(value);
		}
	}
	
	public function ShowLoadingIndicator():void
	{
		var overlayPopupRef  : CR4OverlayPopup;
		overlayPopupRef = (CR4OverlayPopup)GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.ShowLoadingIndicator();
		}
	}
	
	
	public function HideLoadingIndicator(optional immediateHide : bool):void
	{
		var overlayPopupRef  : CR4OverlayPopup;
		overlayPopupRef = (CR4OverlayPopup)GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.HideLoadingIndicator(immediateHide);
		}
	}
	
	public function ShowSavingIndicator():void
	{
		var overlayPopupRef  : CR4OverlayPopup;
		overlayPopupRef = (CR4OverlayPopup)GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.ShowSavingIndicator();
		}
	}
	
	
	public function HideSavingIndicator(optional immediateHide : bool):void
	{
		var overlayPopupRef  : CR4OverlayPopup;
		overlayPopupRef = (CR4OverlayPopup)GetPopup('OverlayPopup');
		if (overlayPopupRef)
		{
			overlayPopupRef.HideSavingIndicator(immediateHide);
		}
	}
	
	public function UpdateDismountAvailable(blocked:bool):void
	{
		if (!blocked)
		{
			if (horseUnmountFeedbackActive)
			{
				EnableHudHoldIndicator_Impl(IK_Pad_B_CIRCLE, IK_None, "panel_input_action_horsedismount", 0.4, 'HorseDismount');
			}
		}
		else
		{
			DisableHudHoldIndicator_Impl();
		}
	}
	
	public function EnableHudHoldIndicator(gpadKeyCode:int, kbKeyCode:int, label:string, holdDuration:float, optional intName:name):void
	{
		var processRequest : bool;
		processRequest = true;
		
		if (label == "panel_input_action_horsedismount")
		{
			horseUnmountFeedbackActive = true;
			
			if (!thePlayer.IsActionAllowed( EIAB_DismountVehicle ))
			{
				processRequest = false;
			}
		}
		
		if (processRequest)
		{
			EnableHudHoldIndicator_Impl(gpadKeyCode, kbKeyCode, label, holdDuration, intName);
		}
	}
	
	public function EnableHudHoldIndicator_Impl(gpadKeyCode:int, kbKeyCode:int, label:string, holdDuration:float, optional intName:name):void
	{
		var hud : CR4ScriptedHud;
		var intrModule : CR4HudModuleInteractions;
		var result : bool;
		
		result = false;
		hud = (CR4ScriptedHud)theGame.GetHud();
		if( hud )
		{			
			intrModule = (CR4HudModuleInteractions)hud.GetHudModule("InteractionsModule");
			if (intrModule)
			{
				result = true;
				intrModule.EnableHoldIndicator(gpadKeyCode, kbKeyCode, label, holdDuration, intName);
			}			
		}
		if (!result)
		{
			m_cachedHold = true;
			m_cachedHold_gpadKeyCode = gpadKeyCode;
			m_cachedHold_kbKeyCode = kbKeyCode;
			m_cachedHold_label = label;
			m_cachedHold_holdDuration = holdDuration;
			m_cachedHold_intName = intName;
		}
		else
		{
			m_cachedHold = false;
		}
	}
	
	
	public function checkHoldIndicator():void
	{
		if (m_cachedHold)
		{
			EnableHudHoldIndicator_Impl(m_cachedHold_gpadKeyCode, m_cachedHold_kbKeyCode, m_cachedHold_label, m_cachedHold_holdDuration, m_cachedHold_intName);
			m_cachedHold = false;
		}
	}
	
	public function DisableHudHoldIndicator():void
	{
		
		
			horseUnmountFeedbackActive = false;
		
		
		DisableHudHoldIndicator_Impl();	
	}
	
	private function DisableHudHoldIndicator_Impl():void
	{
		var hud : CR4ScriptedHud;
		var intrModule : CR4HudModuleInteractions;
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if( hud )
		{
			intrModule = (CR4HudModuleInteractions)hud.GetHudModule("InteractionsModule");
			intrModule.DisableHoldIndicator();
		}
	}
	
	public function RegisterNewItem( item : SItemUniqueId )
	{
		var _inv : CInventoryComponent;
		var tags : array<name>;
		
		if(GetWitcherPlayer())
		{
			_inv = GetWitcherPlayer().GetInventory();
			if( _inv.IsIdValid(item) )
			{
				if( _inv.ItemHasTag( item, 'NoShow' ) || _inv.GetItemName(item) == 'Bodkin Bolt' ||  _inv.GetItemName(item) == 'Harpoon Bolt')
				{
					return;
				}
				if( NewestItems.Size() > 2 )
				{
					NewestItems.Erase( 2 );
				}
				NewestItems.Insert( 0, item );
			}
		}
	}
	
	public function GetNewestItems() : array < SItemUniqueId >
	{
		return NewestItems;
	}
		
	public function RegisterNewGlossaryEntry( newEntry : CJournalBase, panelName : name, optional tag : name )
	{
		var glossaryEntry : SGlossaryEntry;
		if( GlossaryEntries.Size() > 2 )
		{
			GlossaryEntries.Erase( 2 );
		}
		glossaryEntry.tag = tag;
		glossaryEntry.panelName = panelName;
		glossaryEntry.newEntry = newEntry;
		GlossaryEntries.Insert( 0, glossaryEntry );
	}
		
	public function GetNewGlossaryEntries() : array < SGlossaryEntry >
	{
		return GlossaryEntries;
	}
		
	public function RegisterNewAlchemyEntry( tag : name )
	{
		var alchemyEntry : SGlossaryEntry;
		if( AlchemyEntries.Size() > 2 )
		{
			AlchemyEntries.Erase( 2 );
		}
		alchemyEntry.tag = tag;
		alchemyEntry.panelName = 'panel_title_alchemy';
		AlchemyEntries.Insert( 0, alchemyEntry );
	}
		
	public function GetNewAlchemyEntries() : array < SGlossaryEntry >
	{
		return AlchemyEntries;
	}

	public function RegisterNewSkillEntry( newSkill : ESkill )
	{
		if( SkillsEntries.Size() > 2 )
		{
			SkillsEntries.Erase( 2 );
		}
		SkillsEntries.Insert( 0, newSkill );
	}
		
	public function GetNewSkillsEntries() : array < ESkill >
	{
		return SkillsEntries;
	}

	public function RegisterNewMappinEntry( newMappin : name, newMappinType : name )
	{
		var mappinEntry : SMappinEntry;
		var hasTheSameName : bool;
		if( MappinEntries.Size() > 2 )
		{
			MappinEntries.Erase( 2 );
		}
		mappinEntry.newMappin = newMappin;
		if( newMappin != newMappinType )
		{
			mappinEntry.newMappinType = newMappinType;
			hasTheSameName = false;
		}
		else
		{
			hasTheSameName = true;
			mappinEntry.newMappinType = '';
		}
		if( MappinEntries.FindFirst(mappinEntry) == -1 || hasTheSameName )
		{
			MappinEntries.Insert( 0, mappinEntry );
		}
	}
		
	public function GetNewMappinEntries() : array < SMappinEntry >
	{
		return MappinEntries;
	}	

	public function SetUsePortal( usePortal : bool, popupAnswered : bool ) : void
	{
		bUsePortal = usePortal;
		bUsePortalAnswered = popupAnswered;
	}
	
	public function GetUsePortal() : bool
	{
		return bUsePortal;
	}
	
	public function GetUsePortalAnswered() : bool
	{
		return bUsePortalAnswered;
	}
	
	public function ResumePortalConfirmationPendingMessage() : void
	{
		if (potalConfirmationPending)
		{
			potalConfirmationPending = false;
			DisplayPortalConfirmationPopup(pendingPortalConfirmationPauseParam, true);
		}
	}
	
	public function DisplayPortalConfirmationPopup( pause : bool, allowInMenu : bool ) : void
	{
		var LEVEL_REQUAREMENT_GAME : int = 22;
		var LEVEL_REQUAREMENT_GAMEPLUS : int = 52;		
		var arrInt : array<int>;
		
		var popupData : W3PortalConfirmationPopupData;
		
		if (IsAnyMenu() && !allowInMenu)
		{
			potalConfirmationPending = true;
			pendingPortalConfirmationPauseParam = pause;
		}
		else
		{
			popupData = new W3PortalConfirmationPopupData in this;
			
			if (FactsQuerySum("NewGamePlus") > 0 )
			{
				arrInt.PushBack(LEVEL_REQUAREMENT_GAMEPLUS);
			}
			else
			{
				arrInt.PushBack(LEVEL_REQUAREMENT_GAME);
			}
			
			popupData.SetMessageText(GetLocStringByKeyExtWithParams("panel_portal_confirmation_popup_text", arrInt));
			popupData.SetMessageTitle(GetLocStringByKeyExt("panel_portal_confirmation_popup_title"));			
			popupData.BlurBackground = true;
			popupData.PauseGame = pause;
			
			theGame.RequestMenu('PopupMenu', popupData);
		}
	}
	
	public function IsModalPopupShown() : bool
	{
		var messagePopupRef : CR4MessagePopup;
		var tutorialPopupRef : CR4TutorialPopup;
		
		messagePopupRef = (CR4MessagePopup)GetPopup('MessagePopup');
		tutorialPopupRef = (CR4TutorialPopup)GetPopup('TutorialPopup');
		
		return messagePopupRef || tutorialPopupRef;
	}	

	public function DisplayLockedSavePopup() : void
	{
		if ( theGame.GetPlatform() == Platform_Xbox1 )
		{
			ShowNotification( GetLocStringByKeyExt("panel_hud_message_savelock_x1") );
		}
		else if ( theGame.GetPlatform() == Platform_PS4 )
		{
			ShowNotification( GetLocStringByKeyExt("panel_hud_message_savelock_ps4") );
		}
		else
		{
			ShowNotification( GetLocStringByKeyExt("panel_hud_message_savelock") );
		}
		
		theSound.SoundEvent("gui_global_denied");
	}
	
	public function DisplayGameSaveErrorOutOfDiskSpace() : void
	{
		ShowNotification( GetLocStringByKeyExt("panel_hud_message_outofdiskspace") );
		theSound.SoundEvent("gui_global_denied");
	}
	
	public function DisplayRestartGameToApplyAllChanges() : void
	{
		ShowNotification( GetLocStringByKeyExt("panel_hud_message_restarttoapplychanges") );
	}
	
	public function DisplayNewDlcInstalled( message : string) : void
	{
		ShowUserDialog( 0, "", message, UDB_Ok );
	}
	
	public function SetIgnoreControllerDisconnectionEvents( set : bool )
	{
		ignoreControllerDisconnectionEvents = set;
	}
}

exec function exePopup() : bool
{
	return theGame.GetGuiManager().IsModalPopupShown();
}

function ExtractStringFromCSV( str : string ) : string
{
	var index, len : int;
	var result : string;

	result = str;
	len = StrLen( result );

	index = StrFindFirst( result, "<" );
	if ( index > -1 )
	{
		result = StrRight( result, len - index - 1 );
	}
	index = StrFindLast( result, ">" );
	if ( index > -1 )
	{
		result = StrLeft( result, index );
	}
	return result;
}

exec function testBlockPrep(block:bool)
{
	if (block)
	{
		thePlayer.BlockAction(EIAB_OpenPreparation, 'test_blocker');
	}
	else
	{
		thePlayer.UnblockAction(EIAB_OpenPreparation, 'test_blocker');
	}
}

exec function testBlockMap(block:bool)
{
	if (block)
	{
		thePlayer.BlockAction(EIAB_OpenMap, 'test_blocker');
	}
	else
	{
		thePlayer.UnblockAction(EIAB_OpenMap, 'test_blocker');
	}
}

exec function testBlockInventory(block:bool)
{
	if (block)
	{
		thePlayer.BlockAction(EIAB_OpenInventory, 'test_blocker');
	}
	else
	{
		thePlayer.UnblockAction(EIAB_OpenInventory, 'test_blocker');
	}
}

exec function testBlockJournal(block:bool)
{
	if (block)
	{
		thePlayer.BlockAction(EIAB_OpenJournal, 'test_blocker');
	}
	else
	{
		thePlayer.UnblockAction(EIAB_OpenJournal, 'test_blocker');
	}
}

exec function testBlockCharacter(block:bool)
{
	if (block)
	{
		thePlayer.BlockAction(EIAB_OpenCharacterPanel, 'test_blocker');
	}
	else
	{
		thePlayer.UnblockAction(EIAB_OpenCharacterPanel, 'test_blocker');
	}
}

exec function testBlockGlossary(block:bool)
{
	if (block)
	{
		thePlayer.BlockAction(EIAB_OpenGlossary, 'test_blocker');
	}
	else
	{
		thePlayer.UnblockAction(EIAB_OpenGlossary, 'test_blocker');
	}
}

exec function testBlockAlchemy(block:bool)
{
	if (block)
	{
		thePlayer.BlockAction(EIAB_OpenAlchemy, 'test_blocker');
	}
	else
	{
		thePlayer.UnblockAction(EIAB_OpenAlchemy, 'test_blocker');
	}
}

exec function testBlockMeditation(block:bool)
{
	if (block)
	{
		thePlayer.BlockAction(EIAB_OpenMeditation, 'test_blocker');
	}
	else
	{
		thePlayer.UnblockAction(EIAB_OpenMeditation, 'test_blocker');
	}
}

exec function testBlockMeditateAction(block:bool)
{
	if (block)
	{
		thePlayer.BlockAction(EIAB_MeditationWaiting, 'test_blocker');
	}
	else
	{
		thePlayer.UnblockAction(EIAB_MeditationWaiting, 'test_blocker');
	}
}

exec function testBlockDismount(block:bool)
{
	if (block)
	{
		thePlayer.BlockAction(EIAB_DismountVehicle, 'test_blocker');
	}
	else
	{
		thePlayer.UnblockAction(EIAB_DismountVehicle, 'test_blocker');
	}
}
