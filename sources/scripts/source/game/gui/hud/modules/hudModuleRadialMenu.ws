/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CR4HudModuleRadialMenu extends CR4HudModuleBase
{
	private var m_fxBlockRadialMenuSFF			: CScriptedFlashFunction;
	private var m_fxShowRadialMenuSFF			: CScriptedFlashFunction;
	private var m_fxUpdateItemIconSFF			: CScriptedFlashFunction;
	private var m_fxUpdateFieldEquippedStateSFF	: CScriptedFlashFunction;
	private var m_fxMcItemDescription			: CScriptedFlashSprite;
	private var m_fxSetDesaturatedSFF			: CScriptedFlashFunction;
	private var m_fxSetCiriRadialSFF			: CScriptedFlashFunction;
	private var m_fxSetCiriItemSFF				: CScriptedFlashFunction;
	private var m_fxSetMeditationButtonEnabledSFF: CScriptedFlashFunction;
	private var m_fxSetSelectedItem				: CScriptedFlashFunction;
	private var m_shown							: bool;
	private var _currentSelection				: string;
	private var m_IsPlayerCiri					: bool;
	private var m_isDesaturated					: bool;
	private	var m_HasBlink 						: bool;
	private var m_HasCharge						: bool;
	private	var m_allowAutoRotationReturnValue	: bool;
	private var m_swappedAcceptCancel			: bool;
	
	private var m_tutorialsHidden				: bool;
	
	
	default m_shown = false;
	default m_IsPlayerCiri = false;
	default m_isDesaturated = false;
	default m_allowAutoRotationReturnValue = true;

	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		
		m_tutorialsHidden = false;
		
		m_anchorName = "ScaleOnly";
		super.OnConfigUI();

		flashModule = GetModuleFlash();	
		m_fxBlockRadialMenuSFF			= flashModule.GetMemberFlashFunction( "BlockRadialMenu" );
		m_fxShowRadialMenuSFF			= flashModule.GetMemberFlashFunction( "ShowRadialMenu" );
		m_fxUpdateItemIconSFF			= flashModule.GetMemberFlashFunction( "UpdateItemIcon" );
		m_fxUpdateFieldEquippedStateSFF	= flashModule.GetMemberFlashFunction( "UpdateFieldEquippedState" );
		m_fxMcItemDescription 			= flashModule.GetChildFlashSprite( "mcItemDescription" ); 
		m_fxSetDesaturatedSFF 		= flashModule.GetMemberFlashFunction( "SetDesaturated" ); 
		m_fxSetCiriRadialSFF 		= flashModule.GetMemberFlashFunction( "setCiriRadial" ); 
		m_fxSetCiriItemSFF 			= flashModule.GetMemberFlashFunction( "setCiriItem" ); 
		m_fxSetMeditationButtonEnabledSFF 		= flashModule.GetMemberFlashFunction( "SetMeditationButtonEnabled" ); 
		m_fxSetSelectedItem 		= flashModule.GetMemberFlashFunction( "setSelectedItem" );
		m_fxMcItemDescription.SetVisible(false);
		
		theInput.RegisterListener( this, 'OnRadialMenu', 'RadialMenu' );
		theInput.RegisterListener( this, 'OnRadialMenuClose', 'CloseRadialMenu' );
		theInput.RegisterListener( this, 'OnRadialMenuConfirmSelection', 'ConfirmRadialMenuSelection' );
		theInput.RegisterListener( this, 'OnOpenMeditation', 'OpenMeditation' );
		UpdateSwapAcceptCancel();
	}
	
	public function UpdateSwapAcceptCancel():void
	{
		var inGameConfigWrapper : CInGameConfigWrapper;
		inGameConfigWrapper = (CInGameConfigWrapper)theGame.GetInGameConfigWrapper();
		m_swappedAcceptCancel = inGameConfigWrapper.GetVarValue('Controls', 'SwapAcceptCancel');
	}
	
	event OnTick( timeDelta : float )
	{
	}

	function IsRadialMenuOpened() : bool
	{
		return m_shown;
	}

	event OnRadialMenuItemSelected(choosenSymbol : string, isDesaturated : bool )
	{
		m_isDesaturated = isDesaturated;
		if( !m_isDesaturated )
		{
			_currentSelection = choosenSymbol;	
		}
		else
		{
			_currentSelection = "";
		}
		theSound.SoundEvent( "gui_ingame_wheel_highlight" );
	}

	event OnRadialMenuItemChoose( choosenSymbol : string )
	{
		
	}	

	event OnRadialMenuConfirmSelection(  action : SInputAction  )
	{
		if( IsPressed(action) )
		{
			
			if (m_swappedAcceptCancel)
			{
				UserClose();
			}
			else
			{
				UserConfirmSelection();
			}
		}
	}
	
	event OnRadialMenuClose( action : SInputAction )
	{
		if( IsPressed(action) )
		{
			
			if (m_swappedAcceptCancel)
			{
				UserConfirmSelection();
			}
			else
			{
				UserClose();
			}
		}
	}
	
	private function UserConfirmSelection():void
	{
		if( m_shown && !m_IsPlayerCiri)
		{
			if( _currentSelection != "" )
			{
				HideRadialMenu();
				thePlayer.OnRadialMenuItemChoose(_currentSelection);
			}
			else
			{	
				theSound.SoundEvent( "gui_global_denied" );	
			}
		}
	}
	
	event  OnActivateSlot(slotName:string)
	{
		var outKeys : array< EInputKey >;
		var player : W3PlayerWitcher;
		player = GetWitcherPlayer();
		
		thePlayer.OnRadialMenuItemChoose(slotName);
		
		UpdateItemsIcons();
	}
	
	event  OnRequestCloseRadial()
	{
		UserClose();
	}
	
	private function UserClose():void
	{
		if( m_shown )
		{
			HideRadialMenu();
		}
	}
	
	event OnOpenMeditation(  action : SInputAction  )
	{
		var witcher : W3PlayerWitcher;
		
		if( !m_IsPlayerCiri && IsPressed(action) )
		{
			if( m_shown )
			{
				witcher = GetWitcherPlayer();
				
				if(witcher.IsActionAllowed(EIAB_OpenMeditation))
				{
					HideRadialMenu();
					ResetMeditationSavedData();
					thePlayer.OnRadialMenuItemChoose("Meditation"); 
					
					
					
					if(thePlayer.GetCurrentStateName() != 'Meditation')
					{
						thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenMeditation, , witcher.IsThreatened(), !witcher.CanMeditateHere(), witcher.IsThreatened());
					}
					else
					{
						
						return true;
					}
				}
				else
				{
					thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenMeditation, , witcher.IsThreatened(), !witcher.CanMeditateHere(), witcher.IsThreatened());
				}
			}	
		}
	}
	
	function ResetMeditationSavedData()
	{
		var guiManager 			: CR4GuiManager;
		
		guiManager = theGame.GetGuiManager();
		guiManager.RemoveUISavedData('MeditationClockMenu');
	}
	
	event OnRadialMenu( action : SInputAction )
	{
		if( IsPressed(action) )
		{
			if( m_shown )
			{
				HideRadialMenu();
				
				return true;
			}
			if(!thePlayer.IsActionAllowed(EIAB_RadialMenu))
			{
				thePlayer.DisplayActionDisallowedHudMessage(EIAB_RadialMenu);
				return false;
			}
		
			if ( theGame.IsDialogOrCutscenePlaying() || theGame.IsBlackscreenOrFading() || (!thePlayer.GetBIsInputAllowed() && !GetWitcherPlayer().IsUITakeInput()) )
				return false;
				
			ShowRadialMenu();
			
		}
	}
	
	function ShowRadialMenu()
	{
		var camera : CCustomCamera;
		var hud : CR4ScriptedHud;
		
		if( !m_shown && !theGame.IsDialogOrCutscenePlaying())
		{
			
			thePlayer.RestoreBlockedSlots();
			
			
			theGame.CenterMouse();
			
			theGame.ForceUIAnalog(true);
			theInput.StoreContext( 'RadialMenu' );
			theSound.SoundEvent( "gui_ingame_wheel_open" );
			if( thePlayer.IsCiri() != m_IsPlayerCiri || m_HasBlink != thePlayer.HasAbility('CiriBlink') || m_HasCharge != thePlayer.HasAbility('CiriCharge') )
			{
				m_IsPlayerCiri = thePlayer.IsCiri();
				m_HasBlink = thePlayer.HasAbility('CiriBlink');
				m_HasCharge = thePlayer.HasAbility('CiriCharge');
				m_fxSetCiriRadialSFF.InvokeSelfThreeArgs( FlashArgBool(m_IsPlayerCiri), FlashArgBool(m_HasBlink), FlashArgBool(m_HasCharge) );
			}
			thePlayer.BlockAction(EIAB_Jump,'RadialMenu');
			
			UpdateItemsIcons();
			
			theGame.SetTimeScale( 0.1, theGame.GetTimescaleSource(ETS_RadialMenu), theGame.GetTimescalePriority(ETS_RadialMenu), false, true);
			GetWitcherPlayer().SetUITakeInput(true);

			
			camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
			m_allowAutoRotationReturnValue = camera.allowAutoRotation;
			camera.allowAutoRotation = false;
			
			
			m_shown = true;
			ResetItemsModule();
			theGame.GetGuiManager().SendCustomUIEvent( 'OpenedRadialMenu' );
			if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())		
			{
				theGame.GetTutorialSystem().uiHandler.OnOpenedMenu('RadialMenu');
			}
			m_fxSetMeditationButtonEnabledSFF.InvokeSelfOneArg(FlashArgBool(GetWitcherPlayer().IsActionAllowed(EIAB_OpenMeditation)));
			
			SelectCurrentSign();
			
			LogChannel( 'GWINT_AI', "SHOW RADIAL");
			if (!m_tutorialsHidden)
			{
				theGame.GetGuiManager().HideTutorial( true, false );
				m_tutorialsHidden = true;
			}
			
			hud = (CR4ScriptedHud)theGame.GetHud();
			if ( hud )
			{
				hud.OnRadialOpened();
			}
		}
	}
	
	private function SelectCurrentSign()
	{
		if (thePlayer.IsCiri() == m_IsPlayerCiri)
		{
			m_fxSetSelectedItem.InvokeSelfOneArg(FlashArgString(SignEnumToString(thePlayer.GetEquippedSign())));
		}
	}

	event OnHideRadialMenu()
	{
		LogChannel( 'GWINT_AI', "HIDE RADIAL");
		if (m_tutorialsHidden)
		{
			theGame.GetGuiManager().HideTutorial( false, false );
			m_tutorialsHidden = false;
		}
	}
	
	function HideRadialMenu()
	{
		var camera : CCustomCamera;
		var hud : CR4ScriptedHud;
		
		if( m_shown )
		{	
			
			theGame.ForceUIAnalog(false);
			theSound.SoundEvent( "gui_ingame_wheel_close" );
			
			theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_RadialMenu) );
			GetWitcherPlayer().SetUITakeInput(false);

			
			camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
			camera.allowAutoRotation = m_allowAutoRotationReturnValue;
			
			m_shown = false;
			theInput.RestoreContext( 'RadialMenu', true );
			
			theGame.GetGuiManager().SendCustomUIEvent( 'ClosedRadialMenu' );
			ResetItemsModule();
			if(theGame.GetTutorialSystem() && theGame.GetTutorialSystem().IsRunning())		
			{
				theGame.GetTutorialSystem().uiHandler.OnClosedMenu('RadialMenu');
			}
			thePlayer.UnblockAction( EIAB_Jump, 'RadialMenu' );
						
			hud = (CR4ScriptedHud)theGame.GetHud();
			if ( hud )
			{
				hud.OnRadialClosed();
			}
		}
	}
	
	private function ResetItemsModule()
	{	
		var itemInfoModule : CR4HudModuleItemInfo;
		itemInfoModule = (CR4HudModuleItemInfo)theGame.GetHud().GetHudModule("ItemInfoModule");
		itemInfoModule.ResetItems();
	}
	
	function UpdateItemsIcons()
	{
		var i : int;
		var inv : CInventoryComponent;
		var item : SItemUniqueId;
		var player : W3PlayerWitcher;
		var _CurrentSelectedItem : SItemUniqueId;
		var itemName : string;
		var itemDescription : string;
		var itemPath : string;
		var itemCategory : name;
		var outKeys : array< EInputKey >;
		
		player = GetWitcherPlayer();
		inv = player.GetInventory();
		
		_CurrentSelectedItem = GetWitcherPlayer().GetSelectedItemId();
		if( m_IsPlayerCiri )
		{
			inv = thePlayer.GetInventory();
			item = GetCiriItem();
			if( inv.IsIdValid(item) )
			{
				itemName = inv.GetItemName(item);
				itemName = GetLocStringByKeyExt(inv.GetItemLocalizedNameByUniqueID(item));
				itemDescription = GetLocStringByKeyExt(inv.GetItemLocalizedDescriptionByUniqueID(item));
				itemPath = inv.GetItemIconPathByUniqueID(item);
			}
			m_fxSetCiriItemSFF.InvokeSelfThreeArgs( FlashArgString(itemPath), FlashArgString(itemName), FlashArgString(itemDescription) );
		}
		else
		{
			for( i = EES_Petard1; i < EES_Quickslot2 + 1; i += 1 )
			{
				player.GetItemEquippedOnSlot(i, item);
							
				if( inv.IsIdValid(item) )
				{
					itemName = GetLocStringByKeyExt(inv.GetItemLocalizedNameByUniqueID(item));
					itemDescription = GetLocStringByKeyExt(inv.GetItemLocalizedDescriptionByUniqueID(item));
					itemCategory = inv.GetItemCategory (item);
					itemPath = inv.GetItemIconPathByUniqueID(item);
					m_fxUpdateItemIconSFF.InvokeSelfFiveArgs( FlashArgInt(i), FlashArgString(itemPath), FlashArgString(itemName), FlashArgString(itemCategory), FlashArgString(itemDescription) );
					itemName = "Slot"+(i-6);
					
					if( item == _CurrentSelectedItem )
					{
						if( inv.IsIdValid(_CurrentSelectedItem) )
						{
							theInput.GetCurrentKeysForAction('ThrowItem',outKeys);
							m_fxUpdateFieldEquippedStateSFF.InvokeSelfFourArgs( FlashArgString(itemName), FlashArgString(itemDescription), FlashArgBool(true) ,FlashArgInt(outKeys[0]));
							m_fxMcItemDescription.SetVisible(true);
						}
						else
						{
							m_fxMcItemDescription.SetVisible(false);
						}
					}
					else
					{
					
						m_fxUpdateFieldEquippedStateSFF.InvokeSelfFourArgs( FlashArgString(itemName), FlashArgString(itemDescription), FlashArgBool(false), FlashArgInt(0) );
					}
				}
				else
				{
					m_fxUpdateItemIconSFF.InvokeSelfFiveArgs( FlashArgInt(i),FlashArgString(""),FlashArgString("EMPTY!!!"), FlashArgString(""), FlashArgString("") );
				}
			}
			outKeys.Clear();
			theInput.GetCurrentKeysForAction('CastSign',outKeys);
			m_fxUpdateFieldEquippedStateSFF.InvokeSelfFourArgs( FlashArgString( SignEnumToString(player.GetEquippedSign())), FlashArgString(""), FlashArgString(true), FlashArgInt(outKeys[0]));
		}
	}
	
	function GetCiriItem() : SItemUniqueId
	{
		var ret : array<SItemUniqueId>;
		
		ret = thePlayer.GetInventory().GetItemsByName('q403_ciri_meteor');
		
		return ret[0];
	}
	
	public function SetDesaturated( value : bool, fieldName : string )
	{
		
		
		
		
		
		
		m_fxSetDesaturatedSFF.InvokeSelfTwoArgs(FlashArgBool(value),FlashArgString(fieldName));
	}
		
	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool 
	{
		return false;
	}
}

exec function srfdes( value : bool, fieldName : string )
{
	var hud : CR4ScriptedHud;
	var module : CR4HudModuleRadialMenu;

	hud = (CR4ScriptedHud)theGame.GetHud();
	module = (CR4HudModuleRadialMenu)hud.GetHudModule("RadialMenuModule");
	module.SetDesaturated( value, fieldName );
}
