/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
statemachine abstract class W3SignEntity extends CGameplayEntity
{
	
	protected 	var owner 				: W3SignOwner;
	protected 	var attachedTo 			: CEntity;
	protected 	var boneIndex 			: int;
	protected 	var fireMode 			: int;
	protected 	var skillEnum 			: ESkill;
	public    	var signType 			: ESignType;
	public    	var actionBuffs   		: array<SEffectInfo>;	
	editable  	var friendlyCastEffect	: name;
	protected		var cachedCost			: float;
	
	public function GetSignType() : ESignType
	{
		return ST_None;
	}
	
	event OnProcessSignEvent( eventName : name )
	{
		LogChannel( 'Sign', "Process anim event " + eventName );
		
		if( eventName == 'cast_begin' )
		{
			
			if(owner.GetActor() == thePlayer)
			{
				thePlayer.SetPadBacklightColorFromSign(GetSignType());				
			}
	
			OnStarted();
		}
		else if( eventName == 'cast_throw' )
		{
			OnThrowing();
		}
		else if( eventName == 'cast_end' )
		{
			OnEnded();
		}
		else if( eventName == 'cast_friendly_begin' )
		{
			Attach( true );
		}		
		else if( eventName == 'cast_friendly_throw' )
		{
			OnCastFriendly();
		}
		else
		{
			return false;
		}
		
		return true;
	}
	
	public function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
	{
		var player : CR4Player;
		var focus : SAbilityAttributeValue;
		
		owner = inOwner;
		fireMode = 0;
		GetSignStats();
		
		if ( skipCastingAnimation || owner.InitCastSign( this ) )
		{
			if(!notPlayerCast)
			{
				owner.SetCurrentlyCastSign( GetSignType(), this );				
				CacheActionBuffsFromSkill();
			}
			
			
			if ( !skipCastingAnimation )
			{
				AddTimer( 'BroadcastSignCast', 0.8, false, , , true );
			}
			
			
			player = (CR4Player)owner.GetPlayer();
			if(player && !notPlayerCast && player.CanUseSkill(S_Perk_10))
			{
				focus = player.GetAttributeValue('focus_gain');
				
				if ( player.CanUseSkill(S_Sword_s20) )
				{
					focus += player.GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * player.GetSkillLevel(S_Sword_s20);
				}
				player.GainStat(BCS_Focus, 0.1f * (1 + CalculateAttributeValue(focus)) );	
			}
			
 			return true;
		}
		else
		{
			owner.GetActor().SoundEvent( "gui_ingame_low_stamina_warning" );
			CleanUp();
			Destroy();
			return false;
		}
	}
	
	
	event OnStarted()
	{
		var player : CR4Player;
		
		Attach();
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();			
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
	}
		
	
	event OnThrowing()
	{
	}
	
	
	event OnEnded(optional isEnd : bool)
	{
		var witcher : W3PlayerWitcher;
		var abilityName : name;
		var abilityCount, maxStack : float;
		var min, max : SAbilityAttributeValue;
		var addAbility : bool;
		var mutagen17 : W3Mutagen17_Effect;

		var camHeading : float;
		
		witcher = (W3PlayerWitcher)owner.GetActor();
		if(witcher && witcher.IsCurrentSignChanneled() && witcher.GetCurrentlyCastSign() != ST_Quen && witcher.bRAxisReleased )
		{
			if ( !witcher.lastAxisInputIsMovement )
			{
				camHeading = VecHeading( theCamera.GetCameraDirection() );
				if ( AngleDistance( GetHeading(), camHeading ) < 0 )
					witcher.SetCustomRotation( 'ChanneledSignCastEnd', camHeading + witcher.GetOTCameraOffset(), 0.0, 0.2, false );
				else
					witcher.SetCustomRotation( 'ChanneledSignCastEnd', camHeading - witcher.GetOTCameraOffset(), 0.0, 0.2, false );
			}
			witcher.ResetLastAxisInputIsMovement();
		}
		
		
		witcher = (W3PlayerWitcher)owner.GetActor();
		if(witcher && witcher.HasBuff(EET_Mutagen17))
		{
			 mutagen17 = (W3Mutagen17_Effect)witcher.GetBuff(EET_Mutagen17);
			 if(mutagen17.HasBoost())
			 {
				mutagen17.ClearBoost();
			 }
		}		
		
		
		if(witcher && witcher.HasBuff(EET_Mutagen22) && witcher.IsInCombat() && witcher.IsThreatened())
		{
			abilityName = witcher.GetBuff(EET_Mutagen22).GetAbilityName();
			abilityCount = witcher.GetAbilityCount(abilityName);
			
			if(abilityCount == 0)
			{
				addAbility = true;
			}
			else
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen22_max_stack', min, max);
				maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				
				if(maxStack >= 0)
				{
					addAbility = (abilityCount < maxStack);
				}
				else
				{
					addAbility = true;
				}
			}
			
			if(addAbility)
			{
				witcher.AddAbility(abilityName, true);
			}
		}
		
		CleanUp();
	}

	
	
	
	event OnSignAborted( optional force : bool )
	{
		CleanUp();
		
		Destroy();
	}	

	event OnCheckChanneling()
	{
		return false;
	}

	public function GetOwner() : CActor
	{
		return owner.GetActor();
	}

	
	public function SkillUnequipped( skill : ESkill ){}
	
	
	public function SkillEquipped( skill : ESkill ){}

	
	public function OnNormalCast()
	{
		if(owner.GetActor() == thePlayer && GetWitcherPlayer().IsInitialized())
			theGame.VibrateControllerLight();	
	}

	public function SetAlternateCast( newSkill : ESkill )
	{
		fireMode = 1;
		skillEnum = newSkill;
		GetSignStats(); 
	}
	
	public function IsAlternateCast() : bool
	{
		return fireMode == 1;
	}

	protected function GetSignStats(){}
		
	protected function CleanUp()
	{	
		owner.RemoveTemporarySkills();
	}
			
	
	function Attach( optional toSlot : bool, optional toWeaponSlot : bool )
	{		
		var loc : Vector;
		var rot : EulerAngles;	
		var ownerActor : CActor;
		
		ownerActor = owner.GetActor();
		if ( toSlot )
		{
			if (!toWeaponSlot && ownerActor.HasSlot( 'sign_slot', true ) )
			{
				CreateAttachment( ownerActor, 'sign_slot' );			
			}
			else
			{
				CreateAttachment( ownerActor, 'l_weapon' );						
			}
			boneIndex = ownerActor.GetBoneIndex( 'l_weapon' );
			attachedTo = NULL;
		}
		else
		{
			
			
			attachedTo = ownerActor;
			boneIndex = ownerActor.GetBoneIndex( 'l_weapon' );
			
		}
		
		if ( attachedTo )
		{
			if ( boneIndex != -1 )
			{
				loc = MatrixGetTranslation( attachedTo.GetBoneWorldMatrixByIndex( boneIndex ) );
				
				
				if ( ownerActor == thePlayer && (W3AardEntity)this )
				{
					rot = VecToRotation( thePlayer.GetLookAtPosition() - MatrixGetTranslation( thePlayer.GetBoneWorldMatrixByIndex( thePlayer.GetHeadBoneIndex() ) ) );
					rot.Pitch = -rot.Pitch;
					if ( rot.Pitch < 0.f && ( thePlayer.GetPlayerCombatStance() == PCS_Normal || thePlayer.GetPlayerCombatStance() == PCS_AlertFar ) )
						rot.Pitch = 0.f;
					
					thePlayer.GetVisualDebug().AddSphere( 'signEntity', 0.3f, thePlayer.GetLookAtPosition(), true, Color( 255, 0, 0 ), 30.f ); 
					thePlayer.GetVisualDebug().AddArrow( 'signHeading', thePlayer.GetWorldPosition(), thePlayer.GetWorldPosition() + RotForward( rot )*4, 1.f, 0.2f, 0.2f, true, Color(0,128,128), true,10.f );
				}
				else
					rot = attachedTo.GetWorldRotation();
				
				
			}
			else
			{
				loc = attachedTo.GetWorldPosition();
				rot = attachedTo.GetWorldRotation();
			}
			
			
			TeleportWithRotation( loc, rot );
		}
		
		
		if ( owner.IsPlayer() )
		{
			
			
			
			
		}
	}
	
	function Detach()
	{
		BreakAttachment();
		attachedTo = NULL;
		boneIndex = -1;
	}
	
	
	public function InitSignDataForDamageAction( act : W3DamageAction)
	{
		act.SetSignSkill( skillEnum );
		FillActionDamageFromSkill( act );
		FillActionBuffsFromSkill( act );
	}	
	
	private function FillActionDamageFromSkill( act : W3DamageAction )
	{
		var attrs : array< name >;
		var i, size : int;
		var val : float;
		var dm : CDefinitionsManagerAccessor;
		
		if ( !act )
		{
			LogSigns( "W3SignEntity.FillActionDamageFromSkill: action does not exist!" );
			return;
		}
				
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes( owner.GetSkillAbilityName( skillEnum ), attrs );
		size = attrs.Size();
		
		for ( i = 0; i < size; i += 1 )
		{
			if ( IsDamageTypeNameValid( attrs[i] ) )
			{
				val = CalculateAttributeValue( owner.GetSkillAttributeValue( skillEnum, attrs[i], false, true ) );
				act.AddDamage( attrs[i], val );
			}
		}
	}
	
	protected function FillActionBuffsFromSkill(act : W3DamageAction)
	{
		var i : int;
		
		for(i=0; i<actionBuffs.Size(); i+=1)
			act.AddEffectInfo(actionBuffs[i].effectType, , , actionBuffs[i].effectAbilityName);
	}
	
	protected function CacheActionBuffsFromSkill()
	{
		var attrs : array< name >;
		var i, size : int;
		var signAbilityName : name;
		var dm : CDefinitionsManagerAccessor;
		var buff : SEffectInfo;
		
		actionBuffs.Clear();
		dm = theGame.GetDefinitionsManager();
		signAbilityName = owner.GetSkillAbilityName( skillEnum );
		dm.GetContainedAbilities( signAbilityName, attrs );
		size = attrs.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			if( IsEffectNameValid(attrs[i]) )
			{
				EffectNameToType(attrs[i], buff.effectType, buff.effectAbilityName);
				actionBuffs.PushBack(buff);
			}		
		}
	}
	
	public function GetSkill() : ESkill
	{
		return skillEnum;
	}
	
	timer function BroadcastSignCast( deltaTime : float , id : int)
	{		
		
		if ( owner.IsPlayer() )
		{			
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'CastSignAction', -1, 8.0f, -1.f, -1, true ); 
			LogReactionSystem( "'CastSignAction' was sent by Player - single broadcast - distance: 10.0" ); 
		}
		
		BroadcastSignCast_Override();
	}	
	
	function BroadcastSignCast_Override()
	{
	}

	event OnCastFriendly()
	{
		PlayEffect( friendlyCastEffect );
		AddTimer('DestroyCastFriendlyTimer', 0.1, true, , , true);
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'CastSignAction', -1, 8.0f, -1.f, -1, true ); 
		thePlayer.GetVisualDebug().AddSphere( 'dsljkfadsa', 0.5f, this.GetWorldPosition(), true, Color( 0, 255, 255 ), 10.f );
	}
	
	timer function DestroyCastFriendlyTimer(dt : float, id : int)
	{
		var active : bool;

		active = IsEffectActive( friendlyCastEffect );
			
		if(!active)
		{
			Destroy();
		}
	}	
}

state Finished in W3SignEntity
{
	event OnEnterState( prevStateName : name )
	{
		
		parent.DestroyAfter( 8.f );
		if ( parent.owner.IsPlayer() )
		{
			
			parent.owner.GetPlayer().GetMovingAgentComponent().EnableVirtualController( 'Signs', false );	
		}
		parent.CleanUp();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		if ( parent.owner.IsPlayer() )
		{
			parent.owner.GetPlayer().RemoveCustomOrientationTarget( 'Signs' );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		
	}
}

state Active in W3SignEntity
{
	var caster : W3SignOwner;
	
	event OnEnterState( prevStateName : name )
	{
		caster = parent.owner;
	}
	
	event OnSignAborted( optional force : bool )
	{
		
		if( force )
		{
			parent.StopAllEffects();
			parent.GotoState( 'Finished' );
		}
	}
}

state BaseCast in W3SignEntity
{
	var caster : W3SignOwner;
	
	event OnEnterState( prevStateName : name )
	{
		caster = parent.owner;
		if ( caster.IsPlayer() && !( (W3QuenEntity)parent || (W3YrdenEntity)parent ) )
			caster.GetPlayer().GetMovingAgentComponent().EnableVirtualController( 'Signs', true );
	}
	
	event OnLeaveState( nextStateName : name )
	{
		caster.GetActor().SetBehaviorVariable( 'IsCastingSign', 0 );
		caster.SetCurrentlyCastSign( ST_None, NULL );
		LogChannel( 'ST_None', "ST_None" );
	}
	
	event OnThrowing()
	{		
		if(caster.IsPlayer())
		{
			FactsAdd("ach_sign", 1, 4 );		
			theGame.GetGamerProfile().CheckLearningTheRopes();
		}
		return true;
	}
	
	event OnEnded(optional isEnd : bool)
	{
		parent.OnEnded(isEnd);
		parent.GotoState( 'Finished' );
	}
	
	event OnSignAborted( optional force : bool )
	{
		parent.CleanUp();
		parent.StopAllEffects();
		parent.GotoState( 'Finished' );
	}
}

state NormalCast in W3SignEntity extends BaseCast
{
	event OnEnterState( prevStateName : name )
	{
		var player : CR4Player;
		var cost, stamina : float;
		
		super.OnEnterState(prevStateName);
		
		
		
		return true;
	}
	
	event OnEnded(optional isEnd : bool)
	{
		var player : CR4Player;
		var cost, stamina : float;
		
		
		
		super.OnEnded(isEnd);
	}
}

state Channeling in W3SignEntity extends BaseCast
{
	event OnEnterState( prevStateName : name )
	{
		
		super.OnEnterState( prevStateName );
		parent.cachedCost = -1.0f;
		
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent.owner.GetActor(), 'CastSignAction', -1, 8.0f, 0.2f, -1, true );
	}

	event OnLeaveState( nextStateName : name )
	{
		caster.GetActor().ResumeEffects( EET_AutoStaminaRegen, 'SignCast' );
	
		theGame.GetBehTreeReactionManager().RemoveReactionEvent( parent.owner.GetActor(), 'CastSignAction' );
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent.owner.GetActor(), 'CastSignAction', -1, 8.0f, -1.f, -1, true );
		
		
		super.OnLeaveState( nextStateName );
	}
	
	event OnThrowing()
	{
		var actor : CActor;
		var player : CR4Player;
		var stamina : float;
		
		if( super.OnThrowing() )
		{
			actor = caster.GetActor();
			player = (CR4Player)actor;
			
			if(player)
			{
				if( parent.cachedCost <= 0.0f )
				{
					parent.cachedCost = player.GetStaminaActionCost( ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0 );
				}
			
				stamina = player.GetStat(BCS_Stamina);
			}
			
			actor.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			actor.StartStaminaRegen();
			actor.PauseEffects( EET_AutoStaminaRegen, 'SignCast', true );
			
			if(player && ( parent.cachedCost > stamina ) && ( player.CanUseSkill( S_Perk_10 ) ) )
				player.DrainFocus( 1 );
				
			return true;
		}
		
		return false;
	}
	
	event OnCheckChanneling()
	{
		return true;
	}
	
	
	function Update() : bool
	{
		var multiplier, stamina, leftStaminaCostPerc, leftStaminaCost : float;
		var player : CR4Player;
		var reductionCounter : int;
		var stop : bool;
		var costReduction : SAbilityAttributeValue;
		
		player = caster.GetPlayer();
		
		if(player)
		{
			stop = false;
			if( ShouldStopChanneling() )
			{
				stop = true;
			}
			else
			{
				if(player.CanUseSkill(S_Perk_09))
				{
					if(player.GetStat( BCS_Stamina ) <= 0 && player.GetStat(BCS_Focus) <= 0)
						stop = true;
					else
						stop = false;
				}
				else
				{
					stop = (player.GetStat( BCS_Stamina ) <= 0);
				}
			}
		}		
		
		if(stop)
		{
			OnEnded();
			return false;
		}
		else
		{
			if(player && !((W3QuenEntity)parent) )	
			{
				theGame.VibrateControllerLight();	
			}
			
			
			reductionCounter = caster.GetSkillLevel(virtual_parent.skillEnum) - 1;
			multiplier = 1;
			if(reductionCounter > 0)
			{
				costReduction = caster.GetSkillAttributeValue(virtual_parent.skillEnum, 'stamina_cost_reduction_after_1', false, false) * reductionCounter;
				multiplier = 1 - costReduction.valueMultiplicative;
			}
			
			
			if (!(virtual_parent.GetSignType() == ST_Quen && caster.CanUseSkill(S_Magic_s04) && multiplier == 0))
			{
				if(player)
				{
					if( parent.cachedCost <= 0.0f )
					{	
						parent.cachedCost = multiplier * player.GetStaminaActionCost( ESAT_Ability, SkillEnumToName( parent.skillEnum ), theTimer.timeDelta );
					}
				
					stamina = player.GetStat(BCS_Stamina);
				}
				
				if(multiplier > 0.f)
					caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ), theTimer.timeDelta, multiplier );
				
				if(player && parent.cachedCost > stamina)
				{
					leftStaminaCost = parent.cachedCost - stamina;
					leftStaminaCostPerc = leftStaminaCost / player.GetStatMax(BCS_Stamina);
										
					
					player.DrainFocus(leftStaminaCostPerc);
				}
			}
			caster.OnProcessCastingOrientation( true );
		}
		return true;
	}
	
	protected function ShouldStopChanneling() : bool
	{
		var currentInputContext : name;
		
		if ( theInput.GetActionValue( 'CastSignHold' ) > 0.f )
		{
			return false;
		}
		else
		{
			return true;
		}
		
	}
}
