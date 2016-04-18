/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CR4HudModuleControlsFeedback extends CR4HudModuleBase
{		
	private var	m_fxSetSwordTextSFF 	: CScriptedFlashFunction;
	private var	m_fxMakeVisible			: CScriptedFlashFunction;
	private var m_flashValueStorage 	: CScriptedFlashValueStorage;
	private var m_currentInputContext	: name;
	private var m_previousInputContext 	: name;
	private var m_currentPlayerWeapon	: EPlayerWeapon;
	private var m_displaySprint 		: bool;
	private var m_displayJump 			: bool;
	private var m_displayCallHorse		: bool;
	private var m_displayDiveDown		: bool;
	private var m_displayGallop			: bool;
	private var m_displayCanter			: bool;
	private	var m_movementLockType 		: EPlayerMovementLockType;
	private var m_lastUsedPCInput		: bool;
	private var m_CurrentHorseComp		: W3HorseComponent;
	
	private const var KEY_CONTROLS_FEEDBACK_LIST : string; 		default KEY_CONTROLS_FEEDBACK_LIST 		= "hud.module.controlsfeedback";

	event  OnConfigUI()
	{		
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorControlsFeedback"; 
		m_displaySprint = thePlayer.IsActionAllowed(EIAB_RunAndSprint);
		super.OnConfigUI();
		flashModule = GetModuleFlash();	
		m_flashValueStorage = GetModuleFlashValueStorage();
		m_fxSetSwordTextSFF = flashModule.GetMemberFlashFunction( "setSwordText" );
		m_fxMakeVisible     = flashModule.GetMemberFlashFunction( "MakeVisible" );
		
		SetTickInterval( 0.5 );
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		
		UpdateInputContext(hud.currentInputContext);
		
		if (hud)
		{
			hud.UpdateHudConfig('ControlsFeedbackModule', true);
		}
	}

	public function UpdateInputContext( inputContextName :name )
	{		
		m_currentInputContext = inputContextName;
		if( m_currentInputContext == 'JumpClimb' )
		{
			SendInputContextActions('Exploration');
			return;
		}
		SendInputContextActions(inputContextName);
	}
	
	event OnTick( timeDelta : float )
	{
		if ( !CanTick( timeDelta ) || !GetEnabled() )
		{
			return true;
		}
		
		if( m_currentPlayerWeapon != thePlayer.GetCurrentMeleeWeaponType() )
		{
			m_currentPlayerWeapon = thePlayer.GetCurrentMeleeWeaponType();
			UpdateSwordDisplay();
		}
		
		if( m_lastUsedPCInput != theInput.LastUsedPCInput() )
		{
			UpdateInputContextActions();
		}
		else if( m_currentInputContext == thePlayer.GetExplorationInputContext() || m_currentInputContext == 'JumpClimb' )
		{
			if( m_displaySprint != thePlayer.IsActionAllowed(EIAB_RunAndSprint) || thePlayer.movementLockType != m_movementLockType || m_displayCallHorse != thePlayer.IsActionAllowed(EIAB_CallHorse) || m_displayJump	!= thePlayer.IsActionAllowed(EIAB_Jump) )
			{
				UpdateInputContextActions();
			}
		}
		else if( m_currentInputContext == 'Diving' || m_currentInputContext == 'Swimming' )
		{
			if ( m_displaySprint != thePlayer.IsActionAllowed(EIAB_RunAndSprint) || m_displayDiveDown != thePlayer.OnAllowedDiveDown() )
			{
				UpdateInputContextActions();
			}
		}
		else if( m_currentInputContext == 'Horse' )
		{
			m_CurrentHorseComp = thePlayer.GetUsedHorseComponent();
			if ( m_displayGallop != m_CurrentHorseComp.OnCanGallop() || m_displayCanter != m_CurrentHorseComp.OnCanCanter() )
			{
				UpdateInputContextActions();
			}
		}
	}
	
	function UpdateInputContextActions()
	{
		if( m_currentInputContext != thePlayer.GetCombatInputContext() )
		{
			if ( m_currentInputContext == 'JumpClimb' )
				SendInputContextActions('Exploration',true);
			else
				SendInputContextActions(m_currentInputContext,true);
		}
	}
	
	function ForceModuleUpdate()
	{
		SendInputContextActions(m_currentInputContext, true);
	}
	
	function SetEnabled( value : bool )
	{
		super.SetEnabled(value);
		SendInputContextActions(m_currentInputContext, true);
	}	
	
	private function UpdateSwordDisplay()
	{
		switch( m_currentPlayerWeapon )
		{
			case PW_Silver :
				m_fxSetSwordTextSFF.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_silver")));
				break;		
			case PW_Steel :
				m_fxSetSwordTextSFF.InvokeSelfOneArg(FlashArgString(GetLocStringByKeyExt("panel_inventory_paperdoll_slotname_steel")));
				break;
			default :
				m_fxSetSwordTextSFF.InvokeSelfOneArg(FlashArgString(""));
				break;
		}
	}
	
	private function SendInputContextActions( inputContextName :name, optional isForced : bool )
	{
		var l_FlashArray			: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		var bindingGFxData	 		: CScriptedFlashObject;
		var bindingGFxData2	 		: CScriptedFlashObject;
		var l_ActionsArray	 		: array <name>;
		var l_swimingSprint	 		: bool;
		var i	 					: int;
		var outKeys 				: array< EInputKey >;
		var outKeysPC 				: array< EInputKey >;
		var labelPrefix				: string;
		var curAction				: name;
		var bracketOpeningSymbol 	: string;
		var bracketClosingSymbol  	: string;
		var actionLabel			  	: string;
		
		var attackKeysPC 			: array< EInputKey >;
		var attackModKeysPC 	    : array< EInputKey >;
		var alterAttackKeysPC 	    : array< EInputKey >;
		var modifier				: EInputKey;
		
		GetBracketSymbols(bracketOpeningSymbol, bracketClosingSymbol);
		
		l_FlashArray = m_flashValueStorage.CreateTempFlashArray();
		l_ActionsArray.Clear();
		l_swimingSprint = false;
		
		if( GetEnabled() )
		{
			if( !isForced && ( m_previousInputContext == m_currentInputContext || ( m_previousInputContext == 'JumpClimb' && m_currentInputContext == 'Exploration' ) || ( m_previousInputContext == 'Exploration' && m_currentInputContext == 'JumpClimb' ) ) )
			{
				return;
			}
			
			m_movementLockType 	= thePlayer.movementLockType;
			m_displaySprint 	= thePlayer.IsActionAllowed(EIAB_RunAndSprint);
			m_displayCallHorse 	= thePlayer.IsActionAllowed(EIAB_CallHorse);
			m_lastUsedPCInput 	= theInput.LastUsedPCInput();
			m_displayDiveDown 	= thePlayer.OnAllowedDiveDown();
			m_displayJump		= thePlayer.IsActionAllowed(EIAB_Jump);
			
			m_CurrentHorseComp = thePlayer.GetUsedHorseComponent();
			m_displayGallop 	= m_CurrentHorseComp.OnCanGallop();
			m_displayCanter 	= m_CurrentHorseComp.OnCanCanter();
			
			switch(inputContextName)
			{
				case 'JumpClimb' :
					return;
				case 'Exploration' :  					
					if( m_displaySprint )
					{
						l_ActionsArray.PushBack('Sprint');
					}
					if( m_displayJump )
					{
						l_ActionsArray.PushBack('Jump');
					}
					if( !thePlayer.IsCiri() )
					{
						l_ActionsArray.PushBack('Focus');
						if( m_displayCallHorse )
						{
							l_ActionsArray.PushBack('SpawnHorse');
						}
					}
					break;
				case 'Exploration_Replacer_Ciri' :
					if( m_displaySprint )
					{
						l_ActionsArray.PushBack('Sprint');
					}
					if( m_displayJump )
					{
						l_ActionsArray.PushBack('Jump');
					}
					break;
				case 'Horse' : 
					if ( m_displayGallop )
					{
						l_ActionsArray.PushBack('Gallop');
					}
					if ( m_displayCanter )
					{
						l_ActionsArray.PushBack('Canter');
					}
					l_ActionsArray.PushBack('HorseDismount');
					break;			
				case 'Boat' : 
					l_ActionsArray.PushBack('GI_Accelerate');
					l_ActionsArray.PushBack('GI_Decelerate');
					l_ActionsArray.PushBack('BoatDismount');
					break;
				case 'BoatPassenger' :
					l_ActionsArray.PushBack('BoatDismount');
					break;
				case 'Swimming' : 
					l_ActionsArray.PushBack('DiveDown');
					if( m_displaySprint )
					{
						l_ActionsArray.PushBack('Sprint');
					}
					l_swimingSprint = true;
					break;		
				case 'Diving' :
					if ( m_displayDiveDown )
					{
						l_ActionsArray.PushBack('DiveDown');
					}
					l_ActionsArray.PushBack('DiveUp');
					if( m_displaySprint )
					{
						l_ActionsArray.PushBack('Sprint');
					}
					l_swimingSprint = true;
					break;
				case 'FistFight' : 
				case 'CombatFists' : 
				case 'Combat' : 
				if( thePlayer.IsInCombatFist() )
					{
						l_ActionsArray.PushBack('AttackLight');
						l_ActionsArray.PushBack('AttackHeavy');
						l_ActionsArray.PushBack('LockAndGuard'); 
						l_ActionsArray.PushBack('Dodge');
					}
					else
					{
						l_ActionsArray.PushBack('AttackLight');
						l_ActionsArray.PushBack('AttackHeavy');
						l_ActionsArray.PushBack('Dodge');
						l_ActionsArray.PushBack('CastSign');
					}
					break;
				case 'Combat_Replacer_Ciri' :
					l_ActionsArray.PushBack('AttackLight');
					l_ActionsArray.PushBack('CiriDodge');
					if ( thePlayer.HasAbility('CiriCharge') )
						l_ActionsArray.PushBack('CiriSpecialAttackHeavy'); 
					if ( thePlayer.HasAbility('CiriBlink') )
						l_ActionsArray.PushBack('CiriSpecialAttack'); 
					break;
				default:
					break;
			}
			
			for( i = 0; i < l_ActionsArray.Size(); i += 1 )
			{
				curAction = l_ActionsArray[i];
				outKeys.Clear();
				outKeysPC.Clear();
				theInput.GetPadKeysForAction(curAction, outKeys );
				
				
				
				if (m_lastUsedPCInput)
				{
					modifier = IK_None;
					
					attackModKeysPC.Clear();
					theInput.GetPCKeysForAction('PCAlternate', attackModKeysPC );
					
					switch (curAction)
					{
						
						
						
						
						
						case 'AttackLight' :
								
								attackKeysPC.Clear();
								theInput.GetPCKeysForAction('AttackWithAlternateLight', attackKeysPC );
								
								if (attackKeysPC.Size() > 0 && attackKeysPC[0] != IK_None)
								{
									outKeysPC.PushBack(attackKeysPC[0]);
								}
								else								
								{
									alterAttackKeysPC.Clear();
									theInput.GetPCKeysForAction('AttackWithAlternateHeavy', alterAttackKeysPC );
									
									if (attackModKeysPC.Size() > 0 && alterAttackKeysPC.Size() > 0 && attackModKeysPC[0] != IK_None && alterAttackKeysPC[0] != IK_None)
									{
										outKeysPC.PushBack(alterAttackKeysPC[0]);
										modifier = attackModKeysPC[0];
									}
								}
								
							break;
							
						case 'AttackHeavy' :
						case 'CiriSpecialAttackHeavy' :
								
								
								
								attackKeysPC.Clear();
								theInput.GetPCKeysForAction('AttackWithAlternateHeavy', attackKeysPC );
								
								if (attackKeysPC.Size() > 0 && attackKeysPC[0] != IK_None)
								{
									outKeysPC.PushBack(attackKeysPC[0]);
								}
								else								
								{
									alterAttackKeysPC.Clear();
									theInput.GetPCKeysForAction('AttackWithAlternateLight', alterAttackKeysPC );
									
									if (attackModKeysPC.Size() > 0 && alterAttackKeysPC.Size() > 0 && attackModKeysPC[0] != IK_None && alterAttackKeysPC[0] != IK_None)
									{
										outKeysPC.PushBack(alterAttackKeysPC[0]);
										modifier = attackModKeysPC[0];
									}
								}
								
							break;
						default:
							theInput.GetPCKeysForAction(curAction, outKeysPC );
							break;
					}
				}
				
				
				
				switch (curAction) 
				{
					case 'Sprint' :
						
						
						
						
						
						break;
					case 'HorseDismount':
						outKeys.PushBack(IK_Pad_B_CIRCLE);
						break;
						
					default:
						break;
				}
				
				l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
				bindingGFxData = l_DataFlashObject.CreateFlashObject("red.game.witcher3.data.KeyBindingData");
				bindingGFxData.SetMemberFlashInt("gamepad_keyCode", outKeys[0] );
				
				if (outKeysPC.Size() > 0)
				{
					bindingGFxData.SetMemberFlashInt("keyboard_keyCode", outKeysPC[0] );
				}
				else
				{
					bindingGFxData.SetMemberFlashInt("keyboard_keyCode", 0 );
				}
				if (modifier != IK_None)
				{
					bindingGFxData.SetMemberFlashInt("altKeyCode", modifier );
				}
				
				if( curAction == 'Sprint' && ( m_currentInputContext != 'Swimming' && m_currentInputContext != 'Diving') )
				{
					if( m_movementLockType != PMLT_Free )
					{
						curAction = 'Run';
					}
				}
				
				switch (curAction)
				{
					case 'Gallop':
						labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_doubleTap") + bracketClosingSymbol + "</font>";
						break;
					case 'SpawnHorse':
						if ( !m_lastUsedPCInput )
							labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_doubleTap") + bracketClosingSymbol + "</font>";
						else
							labelPrefix = "";
						break;
					case 'Sprint':
						if ( !theInput.IsToggleSprintBound() )
							labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_hold") + bracketClosingSymbol + "</font>";						
						break;
					case 'HorseDismount':
						if ( m_lastUsedPCInput )
						{
							labelPrefix = "";
						}
						else
						{
							labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_hold") + bracketClosingSymbol + "</font>";
						}
						break;
					case 'Run':
					case 'GI_Accelerate':
					case 'GI_Decelerate':
					case 'Canter':
					case 'Focus':
					case 'Roll':
					case 'DiveUp':
					case 'DiveDown':
					case 'CiriSpecialAttackHeavy':
					case 'CiriSpecialAttack':
						labelPrefix = "<font color=\"#FCAD36\">" + bracketOpeningSymbol + GetLocStringByKeyExt("ControlLayout_hold") + bracketClosingSymbol + "</font>";
						break;
					default:
						labelPrefix = "";
						break;
				}
				
				if( curAction == 'Jump' )
				{
					actionLabel = GetLocStringByKeyExt("panel_button_common_jump");
				}
				else if( curAction == 'Sprint' && ( m_currentInputContext == 'Swimming' || m_currentInputContext == 'Diving') )
				{
					actionLabel = GetLocStringByKeyExt("panel_input_action_fast_swiming");
				}
				else if( curAction == 'SpawnHorse' )
				{
					actionLabel = GetLocStringByKeyExt("ControlLayout_SummonHorse");					
				}
				else if (curAction == 'BoatDismount' && inputContextName == 'Boat')
				{
					actionLabel = GetLocStringByKeyExt("panel_button_common_disembark");
				}
				else if ( curAction == 'CiriDodge' )
				{
					actionLabel = GetLocStringByKeyExt("ControlLayout_Dodge");
				}
				else if ( curAction == 'CiriSpecialAttackHeavy' )
				{
					actionLabel = GetLocStringByKeyExt("ControlLayout_CiriCharge");
				}
				else if ( curAction == 'CiriSpecialAttack' )
				{
					actionLabel = GetLocStringByKeyExt("ControlLayout_CiriBlink");
				}
				else
				{					
					actionLabel = GetLocStringByKeyExt("panel_input_action_"+StrLower(curAction));
				}
				
				bindingGFxData.SetMemberFlashString("label", " <font color=\"#FFFFFF\">" + actionLabel + "</font> " + labelPrefix );
				
				l_FlashArray.PushBackFlashObject(bindingGFxData);
			}
		}
		
		
		
		if( l_ActionsArray.Size() > 0 )
		{
			m_flashValueStorage.SetFlashArray( KEY_CONTROLS_FEEDBACK_LIST, l_FlashArray );
			
			
		}
		else
		{
			m_fxMakeVisible.InvokeSelfOneArg( FlashArgBool( false ) );
		}
		m_previousInputContext = m_currentInputContext;
	}
	
	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool
	{
		return super.UpdateScale(scale * 0.75,flashModule );
	}
	
	protected function UpdatePosition(anchorX:float, anchorY:float) : void
	{
		var l_flashModule 		: CScriptedFlashSprite;
		var tempX				: float;
		var tempY				: float;
		
		l_flashModule 	= GetModuleFlash();
		
		
		
		
		tempX = anchorX - (300.0 * (1.0 - theGame.GetUIHorizontalFrameScale()));
		tempY = anchorY - (200.0 * (1.0 - theGame.GetUIVerticalFrameScale())); 
		
		l_flashModule.SetX( tempX );
		l_flashModule.SetY( tempY );	
	}
	
	event OnControllerChanged()
	{
		
	}	

	event OnInputHandled(NavCode:string, KeyCode:int, ActionId:int)
	{
	}
}