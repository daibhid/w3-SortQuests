/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




struct MappinTypeInfo
{
	var type    : name;
	var visible : bool;
	var amount	: int;  
}

class CR4MapMenu extends CR4MenuBase
{
	private var m_shownArea   : EAreaName;
	private var m_currentArea : EAreaName;
	
	private var m_discoveredPinsTypes : array<name>;
	private var m_currentPinTypes	  : array<MappinTypeInfo>;
	
	private var m_fxSetUserMapPinPosition : CScriptedFlashFunction;
	private var m_fxSetMapZooms : CScriptedFlashFunction;
	private var m_fxSetMapVisibilityBoundaries : CScriptedFlashFunction;
	private var m_fxSetMapScrollingBoundaries : CScriptedFlashFunction;
	private var m_fxSetMapSettings : CScriptedFlashFunction;
	private var m_fxReinitializeMap : CScriptedFlashFunction;
	private var m_fxEnableDebugMode : CScriptedFlashFunction;
	private var m_fxEnableUnlimitedZoom : CScriptedFlashFunction;
	private var m_fxEnableManualLod : CScriptedFlashFunction;
	private var m_fxShowBorders : CScriptedFlashFunction;
	private var m_fxSetDefaultPosition : CScriptedFlashFunction;
	private var m_fxShowToussaint : CScriptedFlashFunction;

	var currentTag			: name;

	event  OnConfigUI()
	{
		var initData : W3MapInitData;
		
		m_menuState = 'GlobalMap';
		
		
		
		initData = (W3MapInitData)GetMenuInitData();
		if ( initData )
		{			
			if(ShouldProcessTutorial('TutorialFastTravelHighlight'))
			{
				
				if(initData.GetTriggeredExitEntity() || initData.GetUsedFastTravelEntity() || thePlayer.IsOnBoat())
				{
					GameplayFactsAdd("tutorial_fast_travel_open", 1, 1);
				}
			}
		}
		
		super.OnConfigUI();
		
		m_flashModule = GetMenuFlash();
		m_fxSetUserMapPinPosition      = m_flashModule.GetMemberFlashFunction( "SetUserMapPinPosition" );
		m_fxSetMapZooms                = m_flashModule.GetMemberFlashFunction( "SetMapZooms" );
		m_fxSetMapVisibilityBoundaries = m_flashModule.GetMemberFlashFunction( "SetMapVisibilityBoundaries" );
		m_fxSetMapScrollingBoundaries  = m_flashModule.GetMemberFlashFunction( "SetMapScrollingBoundaries" );
		m_fxSetMapSettings             = m_flashModule.GetMemberFlashFunction( "SetMapSettings" );
		m_fxReinitializeMap            = m_flashModule.GetMemberFlashFunction( "ReinitializeMap" );
		m_fxEnableDebugMode            = m_flashModule.GetMemberFlashFunction( "EnableDebugMode" );
		m_fxEnableUnlimitedZoom        = m_flashModule.GetMemberFlashFunction( "EnableUnlimitedZoom" );
		m_fxEnableManualLod            = m_flashModule.GetMemberFlashFunction( "EnableManualLod" );
		m_fxShowBorders                = m_flashModule.GetMemberFlashFunction( "ShowBorders" );
		m_fxSetDefaultPosition         = m_flashModule.GetMemberFlashFunction( "setDefaultMapPostion" );
		m_fxShowToussaint              = m_flashModule.GetMemberFlashFunction( "ShowToussaint" );
		
		Initialize();
		
		UpdateActiveAreas();
		SelectCurrentModule();
		
		UpdateCurrentQuestData();
		
		
		if (!((W3MenuInitData)GetMenuInitData()))
		{
			SetMenuState('GlobalMap');
		}
		
		
		
		
		
		
		
		
		
		
		m_fxShowToussaint.InvokeSelfOneArg( FlashArgBool( theGame.GetDLCManager().IsEP2Available() ) );
	}
	
	protected function GetSavedDataMenuName() : name
	{
		return m_menuState;
	}
	
	function Initialize()
	{
		var manager: CCommonMapManager;
	    var worldPath : String;
	    var currentJournalArea : int;
	    var currentJournalAreaName : string;
	    
		manager = theGame.GetCommonMapManager();
		worldPath = theGame.GetWorld().GetDepotPath();
		m_currentArea = manager.GetAreaFromWorldPath( worldPath );
		currentJournalArea = manager.GetCurrentJournalArea();
		currentJournalAreaName = AreaTypeToName( currentJournalArea );
		
		GetMenuFlashValueStorage().SetFlashString( "worldmap.global.universe.area", currentJournalAreaName );
		
		UpdateQuestAreas();

		SwitchToHubMap( currentJournalArea );
	}
	
	private function UpdateQuestAreas()
	{
		var manager: CWitcherJournalManager = theGame.GetJournalManager();
	    var areasWithQuests : array< int >;
	    
	    var i : int;
		var flashObject	: CScriptedFlashObject;
		var flashArray 	: CScriptedFlashArray;

		areasWithQuests = manager.GetJournalAreasWithQuests();
		
		flashArray = m_flashValueStorage.CreateTempFlashArray();
		for ( i = 0; i < areasWithQuests.Size(); i += 1 )
		{
			
			flashObject = m_flashValueStorage.CreateTempFlashObject();
			flashObject.SetMemberFlashString( "area", AreaTypeToName( areasWithQuests[ i ] ) );
			flashArray.PushBackFlashObject( flashObject );
		}
		m_flashValueStorage.SetFlashArray( "worldmap.global.universe.questareas", flashArray );
	}
	
	public  function SetMenuState(newState : name) : void
	{
		SaveStateData();
		super.SetMenuState(newState);
		LogChannel('MAP_STATE',"state "+newState);
		GetSavedData();
		currentTag = UISavedData.selectedTag;
		SelectCurrentModule();
		UpdateInputFeedback();
	}
	
	
	private function UpdateInputFeedback():void
	{
		m_defaultInputBindings.Clear();
		super.SetButtons();
	}
	
	protected function SetMapTitle(mapTitle:string):void
	{
		GetMenuFlashValueStorage().SetFlashString( "map.name.set", mapTitle );
	}
	
	protected function SetCurrentAreaId(areaId:EAreaName):void
	{
		GetMenuFlashValueStorage().SetFlashInt( "map.current.area.id", areaId );
	}

	event  OnDebugEvent( id : int )
	{
		LogChannel( 'MapTimer', "Flash " + id );
	}
	
	function UpdateData( optional ignoreSelectionChange : bool )
	{
		var l_flashArray		: CScriptedFlashArray;
		var fastTravelEntiry	: CR4FastTravelEntity;
		var playerPos			: Vector = thePlayer.GetWorldPosition();
		var commonMapManager	: CCommonMapManager = theGame.GetCommonMapManager();
		
		LogChannel( 'MapTimer', "UpdateData START" );
		
		fastTravelEntiry = (CR4FastTravelEntity)GetMenuInitData();
		l_flashArray = GetMenuFlashValueStorage().CreateTempFlashArray();
		
		UpdateEntityPins(l_flashArray );
		UpdateUserMapPin( l_flashArray );
		if ( IsCurrentAreaShown() )
		{
			UpdatePlayerPin( l_flashArray );
		}
		
		LogChannel( 'MapTimer', "UpdateData MIDDLE1" );
		
		if (!ignoreSelectionChange)
		{
			GetMenuFlashValueStorage().SetFlashArray(  "worldmap.global.pins.static", l_flashArray );
		}
		else
		{
			GetMenuFlashValueStorage().SetFlashArray(  "worldmap.global.pins.static.update", l_flashArray );
		}
		
		LogChannel( 'MapTimer', "UpdateData MIDDLE2" );
		
		OnGetFiltersData();
		
		LogChannel( 'MapTimer', "UpdateData END" );
	}
	
	private function UpdateCurrentQuestData() : void
	{
		var curQuestData     : CScriptedFlashObject;
		var currentQuest	 : CJournalQuest;
		var titleStringId    : int;
		
		currentQuest =  theGame.GetJournalManager().GetTrackedQuest();
		if ( currentQuest )
		{
			titleStringId = currentQuest.GetTitleStringId();
			curQuestData = m_flashValueStorage.CreateTempFlashObject();
			curQuestData.SetMemberFlashString("questName", GetLocStringById(titleStringId));
			m_flashValueStorage.SetFlashObject("map.quest.name", curQuestData);
		}
	}
	
	private function UpdatePlayerPin( out flashArray : CScriptedFlashArray ) : void
	{
		var l_flashObject		: CScriptedFlashObject;		
		var position			: Vector;
		var playerRotation      : EulerAngles;
		var playerAngle         : float;
		var cameraAngle         : float;
		var commonMapManager	: CCommonMapManager = theGame.GetCommonMapManager();
		
		position = thePlayer.GetWorldPosition();
		cameraAngle = theCamera.GetCameraHeading();
		playerRotation = thePlayer.GetWorldRotation();
		playerAngle = -playerRotation.Yaw;
		
		if ( playerAngle < 0 )
		{
			playerAngle += 360.0;
		}
		
		l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject("red.game.witcher3.data.StaticMapPinData");
		
		l_flashObject.SetMemberFlashUInt(   "id",       NameToFlashUInt( 'Player' ) );
		l_flashObject.SetMemberFlashInt(    "areaId",	m_shownArea );
		l_flashObject.SetMemberFlashInt(    "journalAreaId", commonMapManager.GetJournalAreaByPosition( m_shownArea, position ) );
		l_flashObject.SetMemberFlashNumber( "posX",     position.X );
		l_flashObject.SetMemberFlashNumber( "posY",     position.Y );
		if ( (W3ReplacerCiri)thePlayer )
		{
			l_flashObject.SetMemberFlashString( "description", GetLocStringByKeyExt( "map_description_player_ciri"));
			l_flashObject.SetMemberFlashString( "label", 	   GetLocStringByKeyExt( "map_location_player_ciri"));
		}
		else
		{
			l_flashObject.SetMemberFlashString( "description", GetLocStringByKeyExt( "map_description_player"));
			l_flashObject.SetMemberFlashString( "label", 	   GetLocStringByKeyExt( "map_location_player"));
		}
		l_flashObject.SetMemberFlashString( "type",     NameToString( 'Player' ) );
		l_flashObject.SetMemberFlashNumber( "radius",	0 );
		l_flashObject.SetMemberFlashBool(   "isQuest",	false );
		l_flashObject.SetMemberFlashBool(   "isPlayer",	true );
		l_flashObject.SetMemberFlashNumber( "rotation",	playerAngle );
		
		
		flashArray.PushBackFlashObject(l_flashObject);
	}
	
	private function UpdateUserMapPin( out flashArray : CScriptedFlashArray ) : void
	{
		var manager : CCommonMapManager = theGame.GetCommonMapManager();
		var l_flashObject		: CScriptedFlashObject;		
		var area				: int;
		var position			: Vector;

		manager.GetUserMapPin( area, position.X, position.Y );
		if ( area == AN_Prologue_Village_Winter )
		{
			area = AN_Prologue_Village;
		}
		
		l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject("red.game.witcher3.data.StaticMapPinData");
		
		if ( area != (int)m_shownArea )
		{
			position.X = -10000;
			position.Y = -10000;
			l_flashObject.SetMemberFlashBool( "hidden", true );
		}
		position.Z = 0;
		
		l_flashObject.SetMemberFlashUInt(   "id",       NameToFlashUInt( 'User' ) );
		l_flashObject.SetMemberFlashNumber( "posX",     position.X );
		l_flashObject.SetMemberFlashNumber( "posY",     position.Y );
		l_flashObject.SetMemberFlashString( "description", GetLocStringByKeyExt( "map_description_user"));
		l_flashObject.SetMemberFlashString( "label", 	GetLocStringByKeyExt( "map_location_user"));
		l_flashObject.SetMemberFlashString( "type",     NameToString( 'User' ) );
		l_flashObject.SetMemberFlashNumber( "radius",	0 );
		l_flashObject.SetMemberFlashBool(   "isQuest",	false );
		l_flashObject.SetMemberFlashBool(   "isPlayer",	false );
		l_flashObject.SetMemberFlashNumber( "rotation",	0 );
		
		
		flashArray.PushBackFlashObject(l_flashObject);
	}

	function ReinitializeMap()
	{
		m_fxReinitializeMap.InvokeSelf();
	}
	
	function UpdateActiveAreas() : void
	{
		var pinsList 	    : array< SAvailableFastTravelMapPin >;
		var curPin			: SAvailableFastTravelMapPin;
		var availableAreas  : array< bool >;
		var i 				: int;
		
		for ( i = 0; i < EnumGetMax( 'EAreaName' ) + 1; i += 1 )
		{
			availableAreas.PushBack(false);
		}
		
		pinsList = theGame.GetCommonMapManager().GetFastTravelPoints(true, true);
		
		for ( i = 0; i < pinsList.Size(); i += 1 )
		{
			curPin = pinsList[i];
			
			availableAreas[curPin.area] = true;
		}
		
		m_flashValueStorage.SetFlashBool("universearea.kaermorhen.active", availableAreas[AN_Kaer_Morhen]);
		m_flashValueStorage.SetFlashBool("universearea.novigrad.active", availableAreas[AN_NMLandNovigrad]);
		m_flashValueStorage.SetFlashBool("universearea.nomansland.active", availableAreas[AN_NMLandNovigrad]);
		m_flashValueStorage.SetFlashBool("universearea.wyzima.active", availableAreas[AN_Wyzima]);
		m_flashValueStorage.SetFlashBool("universearea.prologvillage.active", availableAreas[AN_Prologue_Village]);
		m_flashValueStorage.SetFlashBool("universearea.skellige.active", availableAreas[AN_Skellige_ArdSkellig]);
		m_flashValueStorage.SetFlashBool("universearea.toussaint.active", availableAreas[AN_Dlc_Bob]);
	}

	function UpdateEntityPins( out flashArray : CScriptedFlashArray ) : void
	{
		var worldPath				: string;
		var mapPinInstances 		: array< SCommonMapPinInstance >;
		var mapPinInstancesCount	: int;
		var pin						: SCommonMapPinInstance;
		var i						: int;
		var l_flashObject			: CScriptedFlashObject;		
		var filterCheck				: bool;
		var filterType				: name;
		var canShowKnownEntities	: bool;
		var commonMapManager		: CCommonMapManager = theGame.GetCommonMapManager();
		
		worldPath = commonMapManager.GetWorldPathFromAreaType( m_shownArea );
		
		mapPinInstances			= commonMapManager.GetMapPinInstances( worldPath );
		mapPinInstancesCount	= mapPinInstances.Size();
		
		canShowKnownEntities = commonMapManager.CanShowKnownEntities();
		
		m_currentPinTypes.Clear();
		for ( i = 0; i < mapPinInstancesCount; i += 1 )
		{
			pin = mapPinInstances[ i ];
		
			if ( !pin.isDiscovered && !pin.isKnown )
			{
				continue;
			}
			
			if ( pin.type == 'NPC' ||
				 pin.type == 'Enemy' ||
				 pin.type == 'EnemyDead' ||
				 pin.type == 'GenericFocus' ||
				 pin.type == 'Rift'	||
				 pin.type == 'PointOfInterestMappin' ||
				 pin.type == 'Teleport')
			{
				continue;
			}
			if ( pin.type == 'User' )
			{
				
				continue;
			}
			
			if ( thePlayer.IsSailing() )
			{
				if ( pin.type == 'RoadSign' )
				{
					continue;
				}
			}
			else
			{
				if ( pin.type == 'Harbor' )
				{
					continue;
				}
			}

			if ( pin.visibleType == 'NotDiscoveredPOI' && !canShowKnownEntities )
			{
				continue;
			}
			
			if ( pin.isDisabled )
			{
				filterType = pin.type;
			}
			else
			{
				filterType = pin.visibleType;
			}
			
			AddUniquePinTypeFilter( filterType );
			
			filterCheck = CheckFilter( filterType );
			if ( filterCheck )
			{
				l_flashObject = GetMenuFlashValueStorage().CreateTempFlashObject( "red.game.witcher3.data.StaticMapPinData" );
				l_flashObject.SetMemberFlashUInt(   "id",       NameToFlashUInt( pin.tag ) );
				l_flashObject.SetMemberFlashUInt(	"areaId",   m_shownArea);
				l_flashObject.SetMemberFlashInt(    "journalAreaId", commonMapManager.GetJournalAreaByPosition( m_shownArea, pin.position ) );
				l_flashObject.SetMemberFlashNumber( "posX",     pin.position.X );
				l_flashObject.SetMemberFlashNumber( "posY",     pin.position.Y );
				
				l_flashObject.SetMemberFlashString( "type",     NameToString( pin.visibleType ) );
				l_flashObject.SetMemberFlashNumber( "radius",	pin.visibleRadius );
				l_flashObject.SetMemberFlashBool(   "isQuest",	commonMapManager.IsQuestType( pin.type ) );
				l_flashObject.SetMemberFlashBool(   "isPlayer",	false );
				
				AddPinTypeData(l_flashObject, pin);
				flashArray.PushBackFlashObject(l_flashObject);
			}
		}
	}
	
	private function AddPinTypeData(out dataObject : CScriptedFlashObject, targetPin: SCommonMapPinInstance) : void
	{
		var definitionManager : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var journalManager:CWitcherJournalManager;
		var questMappins:array<CJournalBase>;
		var questObjectives:array<CJournalBase>;
		var curQuestMappin:CJournalQuestMapPin;
		var curObjective:CJournalQuestObjective;
		var curQuest:CJournalQuest;
		
		var isTracked:bool;
		var label:string;
		var description:string;
		
		label = "";
		description = "";
		switch (targetPin.visibleType)
		{


			
			
			case 'StoryQuest':
			case 'ChapterQuest':
			case 'SideQuest':
			case 'MonsterQuest':
			case 'TreasureQuest':
			
			case 'QuestReturn':
			case 'HorseRace':
			case 'BoatRace':
				journalManager = theGame.GetJournalManager();
				curObjective = (CJournalQuestObjective)journalManager.GetEntryByGuid( targetPin.guid );
				if ( curObjective )
				{
					curQuest = curObjective.GetParentQuest();
					
					label = GetLocStringById( curQuest.GetTitleStringId() );
					description = GetLocStringById( curObjective.GetTitleStringId() );
					isTracked = journalManager.GetTrackedQuest().guid == curQuest.guid;
					
					dataObject.SetMemberFlashBool( "tracked",      isTracked );
					dataObject.SetMemberFlashBool( "highlighted",  targetPin.isHighlighted );
					
				}
				break;
			
			case 'Horse':
			case 'Rift':
			case 'Teleport':
			case 'QuestAvailable':
			case 'QuestAvailableHoS':
			case 'QuestAvailableBaW':
			case 'MagicLamp':
			case 'Whetstone':
			case 'Entrance':
			
			case 'NotDiscoveredPOI':
				label = GetLocStringByKeyExt( StrLower("map_location_" + targetPin.visibleType) );
				description = GetLocStringByKeyExt( StrLower("map_description_" + targetPin.visibleType) );
				break;


			case 'MonsterNest':
			case 'MonsterNestDisabled':
			case 'PlaceOfPower':
			case 'PlaceOfPowerDisabled':
			case 'TreasureHuntMappin':
			case 'TreasureHuntMappinDisabled':
			case 'SpoilsOfWar':
			case 'SpoilsOfWarDisabled':
			case 'BanditCamp':
			case 'BanditCampDisabled':
			case 'BanditCampfire':
			case 'BanditCampfireDisabled':
			case 'BossAndTreasure':
			case 'BossAndTreasureDisabled':
			case 'Contraband':
			case 'ContrabandDisabled':
			case 'ContrabandShip':
			case 'ContrabandShipDisabled':
			case 'RescuingTown':
			case 'RescuingTownDisabled':
			case 'DungeonCrawl':
			case 'DungeonCrawlDisabled':


			case 'PlayerStash':
				label = GetLocStringByKeyExt( StrLower("map_location_" + targetPin.type) );
				description = GetLocStringByKeyExt( StrLower("map_description_" + targetPin.type) );
				break;
				


			case 'Shopkeeper':
			case 'Blacksmith':
			case 'Armorer':
			
			case 'Hairdresser':
				label = GetLocStringByKeyExt( StrLower("map_location_" + targetPin.type) );
				description = GetLocStringByKeyExt( StrLower("map_description_" + targetPin.type) );
				break;
			case 'Alchemic':
				label = GetLocStringByKeyExt( StrLower("map_location_alchemic") );
				description = GetLocStringByKeyExt( StrLower("map_description_alchemic") );
				break;
			case 'Herbalist':
				label = GetLocStringByKeyExt( StrLower("herbalist") );
				description = GetLocStringByKeyExt( StrLower("map_description_alchemic") );
				break;
			case 'Innkeeper':
				label = GetLocStringById( 175619 );
				description = GetLocStringByKeyExt( StrLower("map_description_shopkeeper") );
				break;
			case 'Enchanter':
				label = GetLocStringByKeyExt( "panel_map_enchanter_pin_name" );
				description = GetLocStringByKeyExt( "panel_map_enchanter_pin_description" );
				break;



			case 'Prostitute':
				label       = GetLocStringByKeyExt( "novigrad_courtisan" );
				description = GetLocStringByKeyExt( "map_description_prostitute" );
				break;



			case 'ArmorRepairTable':
				label       = GetLocStringByKeyExt( "map_location_armor_repair_table" );
				description = GetLocStringByKeyExt( "map_description_armor_repair_table" );
				break;



			case 'Herb': 
				label       = GetLocStringByKeyExt( definitionManager.GetItemLocalisationKeyName( targetPin.tag ) );
				description = GetLocStringByKeyExt( definitionManager.GetItemLocalisationKeyDesc( targetPin.tag ) );
				break;



			case 'RoadSign':
				label = GetLocStringByKeyExt( StrLower("map_location_" + targetPin.tag ) );
				description = GetLocStringByKeyExt( StrLower("map_description_" + targetPin.tag ) );
				break;



			case 'NoticeBoard':
			case 'NoticeBoardFull':
				label = GetLocStringByKeyExt( StrLower("map_location_noticeboard" ) );
				description = GetLocStringByKeyExt( StrLower("map_description_noticeboard" ) );
				break;



			case 'Boat':
				label = GetLocStringByKeyExt( StrLower("panel_hud_boat" ) );
				description = GetLocStringByKeyExt("map_description_player_boat");
				break;



			default:
				if ( targetPin.customNameId != 0 )
				{
					label = GetLocStringById( targetPin.customNameId );
					description = ""; 
				}
				else
				{
					label = GetLocStringByKeyExt( StrLower("map_location_" + targetPin.visibleType) );
					description = GetLocStringByKeyExt( StrLower("map_description_" + targetPin.visibleType) );
				}
				break;
		}
		
		dataObject.SetMemberFlashString( "label", label );
		dataObject.SetMemberFlashString( "description", description );
	}
	
	event  OnPinch( value : float )
	{
		
		LogChannel( 'Gui', "CR4MapMenu::OnPinch " + value );
	}

	event  OnClosingMenu()
	{
		var initData : W3MapInitData;
		SaveStateData();
		theGame.GetGuiManager().SetLastOpenedCommonMenuName( GetMenuName() );
		
		initData = (W3MapInitData)GetMenuInitData();
		if ( initData )
		{
			if ( initData && initData.GetTriggeredExitEntity() )
			{
				thePlayer.OnTeleportPlayerToPlayableArea( true );
			}
		}
		
		super.OnClosingMenu();
	}

	event  OnCloseMenu()
	{
		if( m_parentMenu )
		{
			m_parentMenu.ChildRequestCloseMenu();
		}
		
		CloseMenu();
	}
		
	function SaveStateData()
	{
		switch(m_menuState)
		{	
			case 'Objectives':
			case 'FastTravel':
				m_guiManager.UpdateUISavedData( m_menuState, UISavedData.openedCategories, currentTag, UISavedData.selectedModule );
				break;
			case 'GlobalMap':
				return;
		}
	}	
	
	event  OnSwitchToWorldMap()
	{
		LogChannel('WORLDMAP',"OnSwitchToWorldMap" );
		SetMapTitle(GetLocStringByKeyExt("panel_map_title_worldmap"));
		UpdateInputFeedback();
	}

	event   OnSwitchToHubMap( areaName : string )
	{
		var areaType : EAreaName;
		areaType = AreaNameToType( areaName );
		SwitchToHubMap(areaType);
	}
	
	
	
	private function AddUniquePinTypeFilter(pinType:name):void
	{
		var len, i 	   : int;
		var isPinExist : bool;
		var curPinData : MappinTypeInfo;
		
		
		if (pinType == 'Waypoint' ||
			pinType == 'StoryQuest' ||
			pinType == 'ChapterQuest' ||
			pinType == 'SideQuest' ||
			pinType == 'MonsterQuest' ||
			pinType == 'TreasureQuest')
		{
			return;
		}
		
		if (pinType == 'NoticeBoardFull')
		{
			pinType = 'NoticeBoard';
		}
		
		if (!m_discoveredPinsTypes.Contains(pinType))
		{
			m_discoveredPinsTypes.PushBack(pinType);
		}
		
		len = m_currentPinTypes.Size();
		for (i = 0; i < len; i+=1)
		{
			if (m_currentPinTypes[i].type == pinType)
			{
				m_currentPinTypes[i].amount = m_currentPinTypes[i].amount + 1;
				m_currentPinTypes[i].visible = !IsPinFilterDisabled(pinType);
				isPinExist = true;
				break;
			}
		}
		if (!isPinExist)
		{
			curPinData.type = pinType;
			curPinData.amount = 1;
			curPinData.visible = !IsPinFilterDisabled(pinType);
			m_currentPinTypes.PushBack(curPinData);
		}
	}
	
	private function EnablePinFilter(pinType:name):void
	{
		theGame.GetCommonMapManager().SetPinFilterVisible(pinType, true);
	}
	
	private function DisablePinFilter(pinType:name):void
	{
		theGame.GetCommonMapManager().SetPinFilterVisible(pinType, false);
	}
	
	private function DisableAllPinFilters(exceptions:array<name>):void
	{
		var len, i : int;
		var curPinType : name;
		var manager	: CCommonMapManager = theGame.GetCommonMapManager();
		
		len = m_currentPinTypes.Size();
		for (i = 0; i < len; i+=1)
		{
			curPinType = m_currentPinTypes[i].type;
			if (!exceptions.Contains(curPinType))
			{
				manager.SetPinFilterVisible(curPinType, false);
			}
		}
	}
	
	private function IsPinFilterDisabled(pinType:name):bool
	{
		return !theGame.GetCommonMapManager().GetPinFilterVisible(pinType);
	}
	
	private function CheckFilter(targetType:name):bool
	{
		if (targetType == 'NoticeBoardFull')
		{
			targetType = 'NoticeBoard';
		}
		
		return !IsPinFilterDisabled(targetType);
	}
	
	event OnGetFiltersData():void
	{
		var currentPinType     : MappinTypeInfo;
		var filterListGFx 	   : CScriptedFlashArray;
		var filterItemGFx	   : CScriptedFlashObject;
		var i, len 		       : int;
		var label, description : string;
		
		len = m_currentPinTypes.Size();
		filterListGFx = m_flashValueStorage.CreateTempFlashArray();
		for ( i = 0; i < len; i += 1 )
		{
		    currentPinType = m_currentPinTypes[i];
		    GetPinTypeDescription(currentPinType.type, label, description);
		    
			filterItemGFx = m_flashValueStorage.CreateTempFlashObject();
			filterItemGFx.SetMemberFlashString("label", label);
			filterItemGFx.SetMemberFlashString("description", description);
			filterItemGFx.SetMemberFlashString("type", currentPinType.type);
			filterItemGFx.SetMemberFlashUInt("typeId", NameToFlashUInt(currentPinType.type));
			filterItemGFx.SetMemberFlashBool("enabled", currentPinType.visible);
			filterItemGFx.SetMemberFlashUInt("amount", currentPinType.amount);
			filterListGFx.PushBackFlashObject(filterItemGFx);
		}
		m_flashValueStorage.SetFlashArray( "map.pins.summary", filterListGFx );
	}
	
	private function GetPinTypeDescription(pinType:name, out label : string, out description : string):void
	{
		switch (pinType)
		{
			case 'Prostitute':
				label       = GetLocStringByKeyExt( "novigrad_courtisan" );
				description = GetLocStringByKeyExt( "map_description_prostitute" );
				break;
			case 'ArmorRepairTable':
				label       = GetLocStringByKeyExt( "map_location_armor_repair_table" );
				description = GetLocStringByKeyExt( "map_description_armor_repair_table" );
				break;
			case 'Entrance':
				label = GetLocStringByKeyExt( "map_location_cave_entrance" );
				description = GetLocStringByKeyExt( "map_description_cave_entrance" );
				break;
			case 'Innkeeper':
				label = GetLocStringById( 175619 );
				description = GetLocStringByKeyExt( "map_description_shopkeeper" );
				break;
			case 'Herbalist':
				label = GetLocStringByKeyExt( StrLower("herbalist") );
				description = GetLocStringByKeyExt( StrLower("map_description_alchemic") );
				break;
			case 'Enchanter':
				label = GetLocStringByKeyExt( "panel_map_enchanter_pin_name" );
				description = GetLocStringByKeyExt( "panel_map_enchanter_pin_description" );
				break;
			case 'Boat':
				label = GetLocStringByKeyExt( StrLower("panel_hud_boat") );
				description = GetLocStringByKeyExt("map_description_player_boat");
				break;
			default:
				label = GetLocStringByKeyExt( StrLower("map_location_" + pinType ));
				description = GetLocStringByKeyExt( StrLower("map_description_" + pinType));
				break;
		}
	}
	
	event OnUpdateFilter(pinType:name, enabled:bool):void
	{
		if (enabled)
		{
			EnablePinFilter(pinType);
		}
		else
		{
			DisablePinFilter(pinType);
		}
		UpdateData(true);
	}
	
	function GetAreaDefaultPosition( areaId : int, out x : float, out y : float ) : void
	{
		switch ( areaId )
		{
			case AN_NMLandNovigrad:
				x = -150;
				y = 450;
				break;
			case AN_Velen:
				x = -300;
				y = -100;
				break;
			default:
				x = -1;
				y = -1;
		}
	}
	
	
	event OnHighlightObjective( tag : name )
	{
		var l_objective						: CJournalQuestObjective;
		var journalManager     				: CWitcherJournalManager;	
		
		journalManager = theGame.GetJournalManager();
		l_objective = (CJournalQuestObjective)journalManager.GetEntryByTag( tag );
		if ( l_objective && journalManager.GetEntryStatus( l_objective ) == JS_Active )
		{
			journalManager.SetHighlightedObjective( l_objective );
		}
	}
	
	
	event OnTrackQuest( tag : name )
	{
		var journalManager : CWitcherJournalManager;
		var l_quest	: CJournalBase;
		
		journalManager = theGame.GetJournalManager();
		l_quest = journalManager.GetEntryByTag(tag);
		journalManager.SetTrackedQuest( l_quest );
	}
	
	

	function SwitchToHubMap( area : EAreaName )
	{
		var manager : CCommonMapManager = theGame.GetCommonMapManager();
		var journalArea : EAreaName;
		var originArea : EAreaName;

		originArea = area;
		
		if ( area == AN_Undefined )
		{
			
			return;
		}
		
		
		
		
		
		
		if ( area == AN_Velen || area == AN_NMLandNovigrad )
		{
			
			if ( m_currentArea == AN_NMLandNovigrad )
			{
				
				journalArea = manager.GetCurrentJournalArea();
			}
			else
			{
				
				journalArea = area;
			}
			
			
			area = AN_NMLandNovigrad;
		}
		else
		{
			
			journalArea = area;
		}
		
		SetMapTitle( GetLocStringByKeyExt( manager.GetLocalisationNameFromAreaType( journalArea ) ) );
		SetCurrentAreaId( originArea );
		UpdateDefaultPosition(originArea);
		UpdateInputFeedback();

		if ( area == m_shownArea )
		{
			ReinitializeMap();
		}
		else
		{
			m_shownArea = area;
			UpdateTitle();
			UpdateMapSettings();
			UpdateData();
		}
	}
	
	event OnEntrySelected( tag : name ) 
	{
		LogChannel('WORLDMAP', "OnEntrySelected tag: "+tag+"  area: ");
		currentTag = tag;
	}

	event   OnSwitchToInterior( )
	{
		LogChannel('WORLDMAP', "OnSwitchToInterior" );
	}

	event  OnUserMapPinSet( posX : float, posY : float )
	{
		var manager	: CCommonMapManager = theGame.GetCommonMapManager();
		var worldPath : string;
		var realShownArea : EAreaName;
		var position : Vector;
		
		if ( m_currentArea == m_shownArea )
		{
			worldPath = theGame.GetWorld().GetDepotPath();
			realShownArea = manager.GetAreaFromWorldPath( worldPath, true );
		}
		else
		{
			realShownArea = m_shownArea;
		}
		
		position.X = posX;
		position.Y = posY;
		position.Z = 0;
		if ( manager.ToggleUserMapPin( (int)realShownArea, position ) )
		{
			m_fxSetUserMapPinPosition.InvokeSelfThreeArgs( FlashArgBool( true ), FlashArgNumber( posX ), FlashArgNumber( posY ) );
			theSound.SoundEvent("gui_hubmap_mark_pin");
		}
		else
		{
			m_fxSetUserMapPinPosition.InvokeSelfThreeArgs( FlashArgBool( false ), FlashArgNumber( 0 ), FlashArgNumber( 0 ) );
		}
	}
	
	event  OnStaticMapPinUsed( pinTag : name, areaId : int)
	{
		var initData : W3MapInitData;
		var manager	: CCommonMapManager = theGame.GetCommonMapManager();
		var fastTravelEntity : W3FastTravelEntity;
		var loadingInitData : W3MenuInitData;
		var contentTag : name;
		var progress : float;
		var rootMenu : CR4Menu;
		
		manager	= theGame.GetCommonMapManager();
		if ( !manager )
		{
			return false;
		}
		
		if ( !manager.IsWorldAvailable( areaId ) )
		{
			contentTag = manager.GetWorldContentTag( areaId );
			progress = theGame.ProgressToContentAvailable(contentTag);
			theSound.SoundEvent("gui_global_denied");
			theGame.GetGuiManager().ShowProgressDialog(0, "", "panel_map_cannot_travel_downloading_content", true, UDB_Ok, progress, UMPT_Content, contentTag);
			return false;
		}

		if( !thePlayer.IsActionAllowed( EIAB_FastTravel ) )
		{
			showNotification( GetLocStringByKeyExt("panel_hud_message_actionnotallowed") );
			OnPlaySoundEvent("gui_global_denied");
			return false;
		}

		if ( !manager.DBG_IsAllowedFT() )
		{
			if ( thePlayer.IsSailing() )
			{
				
				initData = (W3MapInitData)GetMenuInitData();
				if ( initData && initData.GetTriggeredExitEntity() )
				{
					
					initData.SetTriggeredExitEntity( false );
				}
			}
			else
			{
				initData = (W3MapInitData)GetMenuInitData();
				if ( !initData )
				{
					showNotification( GetLocStringByKeyExt("panel_map_cannot_travel") );
					OnPlaySoundEvent("gui_global_denied");
					return false;
				}
				fastTravelEntity = (W3FastTravelEntity)initData.GetUsedFastTravelEntity();
				if (fastTravelEntity && fastTravelEntity.entityName == pinTag)
				{
					showNotification( GetLocStringByKeyExt("panel_map_cannot_travel_already_here") );
					OnPlaySoundEvent("gui_global_denied");
					return false;
				}
				if ( initData.GetTriggeredExitEntity() )
				{
					
					initData.SetTriggeredExitEntity( false );
				}
			}
		}
		
		manager.UseMapPin( pinTag, true );
		
		
		if (areaId == -1)
		{
			areaId == m_shownArea;
		}
		
		if ( m_currentArea == areaId )
		{
			manager.PerformLocalFastTravelTeleport( pinTag );
			theGame.SetGameTime( theGame.GetGameTime() + GameTimeCreate(0, RoundF( RandF() * 4 ), RoundF( RandF() * 60 ), RoundF( RandF() * 60 ) ), true);
		}
		else
		{
			manager.PerformGlobalFastTravelTeleport( m_shownArea, pinTag );
			theGame.SetGameTime( theGame.GetGameTime() + GameTimeCreate(0, RoundF( RandF() * 10 ), RoundF( RandF() * 60 ), RoundF( RandF() * 60 ) ), true);
		}
		theGame.Unpause("menus");
		
		rootMenu = theGame.GetGuiManager().GetRootMenu();
		if ( rootMenu )
		{
			rootMenu.CloseMenu();
		}
		return true;
	}
	
	function UpdateTitle()
	{
		GetMenuFlashValueStorage().SetFlashString("worldmap.title.set", GetMapTitle(), -1 );
	}
	
	private function UpdateDefaultPosition( areaId : int )
	{
		var defX, defY : float;
		
		GetAreaDefaultPosition(areaId, defX, defY);
		m_fxSetDefaultPosition.InvokeSelfTwoArgs( FlashArgNumber(defX), FlashArgNumber(defY) );
	}

	private function UpdateMapSettings()
	{
		var mapSize : float;
		var tileCount : int;
		var textureSize : int;
		var imagePath : string;
		var minLod	: int;
		var maxLod	: int;
		var vminX, vmaxX, vminY, vmaxY : int;
		var sminX, smaxX, sminY, smaxY : int;
		var minZoom, maxZoom : float;
		var zoom12, zoom23, zoom34 : float;
		
		mapSize		= theGame.GetMiniMapSize( m_shownArea );
		tileCount	= theGame.GetMiniMapTileCount( m_shownArea );
		textureSize	= theGame.GetMiniMapTextureSize( m_shownArea );
		minLod		= theGame.GetMiniMapMinLod( m_shownArea );
		maxLod		= theGame.GetMiniMapMaxLod( m_shownArea );

		vminX		= theGame.GetMiniMapVminX( m_shownArea );
		vmaxX		= theGame.GetMiniMapVmaxX( m_shownArea );
		vminY		= theGame.GetMiniMapVminY( m_shownArea );
		vmaxY		= theGame.GetMiniMapVmaxY( m_shownArea );

		sminX		= theGame.GetMiniMapSminX( m_shownArea );
		smaxX		= theGame.GetMiniMapSmaxX( m_shownArea );
		sminY		= theGame.GetMiniMapSminY( m_shownArea );
		smaxY		= theGame.GetMiniMapSmaxY( m_shownArea );
		
		minZoom		= theGame.GetMiniMapMinZoom( m_shownArea );
		maxZoom		= theGame.GetMiniMapMaxZoom( m_shownArea );
		zoom12		= theGame.GetMiniMapZoom12( m_shownArea );
		zoom23		= theGame.GetMiniMapZoom23( m_shownArea );
		zoom34		= theGame.GetMiniMapZoom34( m_shownArea );
		imagePath	= GetShownMapName();
		
		m_fxSetMapZooms.InvokeSelfFiveArgs( FlashArgNumber( minZoom ), FlashArgNumber( maxZoom ), FlashArgNumber( zoom12 ), FlashArgNumber( zoom23 ), FlashArgNumber( zoom34 ) );
		m_fxSetMapVisibilityBoundaries.InvokeSelfFourArgs( FlashArgInt( vminX ), FlashArgInt( vmaxX ), FlashArgInt( vminY ), FlashArgInt( vmaxY ) );
		m_fxSetMapScrollingBoundaries.InvokeSelfFourArgs( FlashArgInt( sminX ), FlashArgInt( smaxX ), FlashArgInt( sminY ), FlashArgInt( smaxY ) );
		m_fxSetMapSettings.InvokeSelfSixArgs( FlashArgNumber( mapSize ), FlashArgInt( tileCount ), FlashArgInt( textureSize ), FlashArgInt( minLod ), FlashArgInt( maxLod ), FlashArgString( imagePath ) );
	}
	
	function GetShownMapName() : string
	{
	    var manager : CCommonMapManager = theGame.GetCommonMapManager();
	    
		return manager.GetMapName( m_shownArea );
	}
	
	function GetMapTitle() : string
	{
	    var manager : CCommonMapManager = theGame.GetCommonMapManager();
	    
		return manager.GetLocalisationNameFromAreaType( m_shownArea );
	}

	function IsCurrentAreaShown() : bool
	{
		return m_currentArea == m_shownArea;
	}

	private function FilterPinsByDuplicateName( pinsArray : array< SCommonMapPinInstance > ) : array< SCommonMapPinInstance > 
	{
		var i : int;
		var j : int;
		
		for( i = 0; i < pinsArray.Size(); i += 1 ) 
		{
			for( j = pinsArray.Size() - 1; j > i; j -= 1 )
			{
				if( pinsArray[j].tag == pinsArray[i].tag )
				{
					pinsArray.Erase(j);
				}
			}
		}
		
		return pinsArray;
	}	
		
	event  OnSkipPressed()
	{
		OnCloseMenu();
	}
	
	event OnCategoryOpened( categoryName : name, opened : bool )
	{
		var i : int;
		if( categoryName == 'None' )
		{
			return false;
		}
		if( opened )
		{
			if( UISavedData.openedCategories.FindFirst(categoryName) == -1 )
			{
				UISavedData.openedCategories.PushBack(categoryName);
			}
		}
		else
		{
			i = UISavedData.openedCategories.FindFirst(categoryName);
			if( i > -1 )
			{
				UISavedData.openedCategories.Erase(i);
			}
		}
	}
	
	public function EnableDebugMode( enable : bool )
	{
		m_fxEnableDebugMode.InvokeSelfOneArg( FlashArgBool( enable ) );
	}
	
	public function EnableUnlimitedZoom( enable : bool )
	{
		m_fxEnableUnlimitedZoom.InvokeSelfOneArg( FlashArgBool( enable ) );
	}
	
	public function EnableManualLod( enable : bool )
	{
		m_fxEnableManualLod.InvokeSelfOneArg( FlashArgBool( enable ) );
	}
	
	public function ShowBorders( show : bool )
	{
		m_fxShowBorders.InvokeSelfOneArg( FlashArgBool( show ) );
	}
	
	function PlayOpenSoundEvent()
	{
		
		
	}
}

exec function map_debug( enable : bool )
{
	var manager : CR4GuiManager;
	var rootMenu : CR4Menu;
	var mapMenu : CR4MapMenu;
	
	manager = (CR4GuiManager)theGame.GetGuiManager();
	if ( manager )
	{
		rootMenu = manager.GetRootMenu();
		if ( rootMenu )
		{
			mapMenu = (CR4MapMenu)rootMenu.GetSubMenu();
			if ( mapMenu )
			{
				mapMenu.EnableDebugMode( enable );
			}
		}
	}
}

exec function map_unlimitedzoom( enable : bool )
{
	var manager : CR4GuiManager;
	var rootMenu : CR4Menu;
	var mapMenu : CR4MapMenu;
	
	manager = (CR4GuiManager)theGame.GetGuiManager();
	if ( manager )
	{
		rootMenu = manager.GetRootMenu();
		if ( rootMenu )
		{
			mapMenu = (CR4MapMenu)rootMenu.GetSubMenu();
			if ( mapMenu )
			{
				mapMenu.EnableUnlimitedZoom( enable );
			}
		}
	}
}

exec function map_manuallod( enable : bool )
{
	var manager : CR4GuiManager;
	var rootMenu : CR4Menu;
	var mapMenu : CR4MapMenu;
	
	manager = (CR4GuiManager)theGame.GetGuiManager();
	if ( manager )
	{
		rootMenu = manager.GetRootMenu();
		if ( rootMenu )
		{
			mapMenu = (CR4MapMenu)rootMenu.GetSubMenu();
			if ( mapMenu )
			{
				mapMenu.EnableManualLod( enable );
			}
		}
	}
}

exec function map_borders( show : bool )
{
	var manager : CR4GuiManager;
	var rootMenu : CR4Menu;
	var mapMenu : CR4MapMenu;
	
	manager = (CR4GuiManager)theGame.GetGuiManager();
	if ( manager )
	{
		rootMenu = manager.GetRootMenu();
		if ( rootMenu )
		{
			mapMenu = (CR4MapMenu)rootMenu.GetSubMenu();
			if ( mapMenu )
			{
				mapMenu.ShowBorders( show );
			}
		}
	}
}

exec function innkeep()
{
	var numbers : array< int >;
	var i : int;

	numbers.PushBack(175619);
	numbers.PushBack(475415);
	numbers.PushBack(538568);
	numbers.PushBack(1084890); 

	for ( i = 0; i < numbers.Size(); i += 1 )
	{
		LogChannel('asdf', numbers[ i ] + " [" + GetLocStringById( numbers[ i ] ) + "]");
	}
}
