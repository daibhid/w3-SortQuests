/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CBehTreeTaskCSEffect extends IBehTreeTask
{
	protected var CSType		  : ECriticalStateType;
	protected var requestedCSType : ECriticalStateType;
	
	var buffType			: EEffectType;
	var buff 				: CBaseGameplayEffect;
	public var finisherAnimName 	: name;
	
	private var hasBuff 					: bool;
	private var allowBlend 					: bool;
	private var hitReactionDisabled 		: bool;
	private var waitForDropItem 			: bool;
	private var isInAir						: bool;
	private var heightDiff					: float;
	private var isInPotentialRagdoll 		: bool;
	private var guardOpen					: bool;
	
	private var criticalStatesToResist 		: int;
	private var resistCriticalStateChance 	: int;
	
	private var storageHandler 				: CAIStorageHandler;
	protected var combatDataStorage 		: CBaseAICombatStorage;
	protected var reactionDataStorage 		: CAIStorageReactionData;
	
	protected var finisherEnabled 			: bool;
	protected var forceFinisherActivation	: bool;
	protected var finisherDisabled			: bool;
	
	default hasBuff = false;
	default allowBlend = false;
	default finisherEnabled = false;
	
	private var pullToNavRadiusMult : float;
	
	default pullToNavRadiusMult = 3.f;
	
	default waitForDropItem = true;
	
	private	var	m_storedInteractionPri 		: EInteractionPriority; default	m_storedInteractionPri 		= IP_NotSet;
	
	function IsAvailable () : bool
	{
		var owner 			: CNewNPC = GetNPC();
		
		buff = owner.ChooseCurrentCriticalBuffForAnim();
		
		if ( buff )
			return true;

		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var owner		: CNewNPC = GetNPC();
		var currentPri : EInteractionPriority;
		var actor 		: CActor;
		var morphedMM	: CMorphedMeshManagerComponent;
		
		InitializeDataStorages();
		
		buffType = buff.GetEffectType();
		CSType = GetBuffCriticalType(buff);
		
		
		owner.CSAnimStarted(buff);
		
		owner.IncCriticalStateCounter();
		
		owner.SetBehaviorVariable( 'bCriticalStopped', 0 );
		owner.SetBehaviorVariable( 'CriticalStateType', (int)CSType );		
		owner.SignalGameplayEvent('CSActivated');
		
		combatDataStorage.SetCriticalState( CSType, true, 0 );
		
		
		
		reactionDataStorage.ChangeAttitudeIfNeeded(owner, (CActor)(buff.GetCreator()) );
		
		SetHitReactionDirection();
		
		hasBuff = true;
		
		finisherDisabled = false;
		
		
		actor = (CActor)owner;
		currentPri = actor.GetInteractionPriority();
		if ( actor.IsAlive() && currentPri != IP_Max_Unpushable )
		{
			m_storedInteractionPri = currentPri;
			actor.SetInteractionPriority( IP_Max_Unpushable );
		}
		
		if( CSType == ECST_Hypnotized || CSType == ECST_Confusion )
		{
			if( owner.HasAbility('RageActive') )
			{
				owner.StopEffect('morph_fx');
				morphedMM = owner.GetMorphedMeshManagerComponent();
				morphedMM.SetMorphBlend( 0, 0.5f );
				owner.RemoveAbility( 'RageActive' );
				owner.RemoveAbility( 'Thorns' );
			}
			owner.SignalGameplayEvent('StopRage');
		}
		
		if ( ShouldDisableHitReaction() )
		{
			owner.SetCanPlayHitAnim(false);
			hitReactionDisabled = true;
		}
		else
			hitReactionDisabled = false;
		
		if ( owner.HasShieldedAbility() && ShouldNotLowerGuard() )
		{
		}
		else
			owner.LowerGuard();
		
		if ( !owner.IsInAir() && owner.IsOnGround() )
		{
			EnableFinisher();
		}	
		
		if ( CSType != ECST_CounterStrikeHit && ShouldTryToDisarm() )
		{
			Disarm();
		}
		
		if ( CSType == ECST_HeavyKnockdown || CSType == ECST_Knockdown || CSType == ECST_Ragdoll || CSType == ECST_LongStagger || CSType == ECST_Stagger )
		{
			OnRagdollStart();
		}
		else
			isInPotentialRagdoll = false;
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var criticalStateCounter : int;
		var tmpF : float;
		var timeStamp : float;
		var mac : CMovingPhysicalAgentComponent;
		
		
		criticalStateCounter = 0;
		
		
		
		if (( CSType == ECST_HeavyKnockdown || CSType == ECST_Knockdown || CSType == ECST_LongStagger || CSType == ECST_Stagger ) && npc.HasAbility( 'MistCharge' ))
		{
			npc.PlayEffect( 'appear_fog' );
		}
		
		if ( CSType == ECST_BurnCritical && npc.HasAbility( 'BurnIgnore' ))
		{
			timeStamp = GetLocalTime();
			while ( isActive )
			{
				if ( timeStamp + 1.0 <= GetLocalTime() )
				{
					npc.SignalGameplayEvent('BurnCriticalCompleted');
					npc.RequestCriticalAnimStop();
					Complete(true);
				}
				SleepOneFrame();
			}
		}
		else if ( CSType == ECST_CounterStrikeHit )
		{
			if ( npc.HasAbility( 'mon_gravehag' ) )
			{
				tmpF = npc.GetBehaviorVariable( 'AttackType' );
				if ( tmpF == 6 || tmpF == 19 )
				{
					npc.SetBehaviorVariable( 'countered', 1 );
					npc.RemoveAbility('TongueAttack');
				}
			}
			
			while ( waitForDropItem )
			{
				SleepOneFrame();
			}
			npc.SetRequiredItems( 'None', 'blunt1h');
			npc.ProcessRequiredItems(true);
		}
		else if ( isInPotentialRagdoll )
		{
			mac = (CMovingPhysicalAgentComponent)GetActor().GetMovingAgentComponent();
			while ( true )
			{
				OnRagdollUpdate( npc, mac);
				SleepOneFrame();
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var actor : CActor;
		var owner : CNewNPC = GetNPC();
		var buffs : array<CBaseGameplayEffect>;
		var deactivate : bool;
		var i : int;
		
		actor = (CActor)owner;
		
		actor.EnablePhysicalMovement(false);
		
		if ( actor.IsAlive() && m_storedInteractionPri != IP_NotSet )
		{
			actor.SetInteractionPriority( m_storedInteractionPri );
			m_storedInteractionPri = IP_NotSet;
		}
		
		if ( guardOpen )
		{
			owner.SetGuarded(true);
			guardOpen = false;
		}
		
		if ( hitReactionDisabled )
			owner.SetCanPlayHitAnim(true);
		
		if ( finisherEnabled )
		{
			DisableFinisher();		
		}
			
		combatDataStorage.SetCriticalState( CSType, false, GetLocalTime() );		
		
		if ( isInPotentialRagdoll )
			OnRagdollStop();
		
		
		
		if ( owner.IsAlive() && owner.IsRagdolled() && ! owner.IsStatic() 
			&& ( requestedCSType != ECST_HeavyKnockdown && requestedCSType != ECST_Knockdown ) )
			owner.SetKinematic(true);
		
		forceFinisherActivation = false;
	}	
	



	function ShouldEnableFinisher() : bool
	{
		var actor : CActor;
		actor = GetActor();
		
		if( CSType != ECST_HeavyKnockdown && CSType != ECST_Knockdown && CSType != ECST_Ragdoll && forceFinisherActivation == false )
		{			
			return false;
		}
		
		if ( GetWitcherPlayer() && GetAttitudeBetween( actor, thePlayer ) == AIA_Hostile && actor.IsVulnerable() && actor.GetComponent( "Finish" ) )
		{
			if( actor.HasAbility('ResistFinisher') &&  actor.GetHealthPercents() > 0.2f )
			{
				return false;
			};
			
			return true;
		}
		return false;
	}
	
	function EnableFinisher()
	{
		if( IsNameValid(finisherAnimName) && ShouldEnableFinisher() && !finisherEnabled && !finisherDisabled )
		{
			
			if( buffType == EET_Stagger )
			{
				buffType = buffType;
			}
		
			GetNPC().EnableFinishComponent( true );
			thePlayer.AddToFinishableEnemyList( GetNPC(), true );
			finisherEnabled = true;
		}
	}
	
	function DisableFinisher()
	{
		GetNPC().EnableFinishComponent( false );
		thePlayer.AddToFinishableEnemyList( GetNPC(), false );
		finisherEnabled = false;
	}
	
	function ShouldCompleteOnParryStart() : bool
	{
		switch ( CSType )
		{
			case ECST_Stagger 				: return true;
			case ECST_CounterStrikeHit		: return true;
			default							: return false;
		}
		return false;
	}
	
	function ShouldNotLowerGuard() : bool
	{
		switch ( CSType )
		{
			case ECST_Stagger 				: return true;
			case ECST_CounterStrikeHit		: return true;
			default							: return false;
		}
		return false;
	}
	
	function ShouldTryToDisarm() : bool
	{
		var res : bool;
		
		if ( !GetNPC().HasShieldedAbility() )
			return false;
		
		switch ( CSType )
		{
			case ECST_HeavyKnockdown 	: res = true; break;
			case ECST_Knockdown			: res = true; break;
			default						: res = false;
		}
		if ( !res )
			return false;
			
		return GetNPC().HasShieldedAbility();
	}
	
	function ShouldDisableHitReaction() : bool
	{
		switch ( CSType )
		{
			case ECST_Frozen			: return true;
			case ECST_Ragdoll			: return true;
			default						: return false;
		}
		return false;
	}
	
	function Disarm()
	{
		GetNPC().DropItemFromSlot( 'l_weapon', true );
	}
	
	
	function FinisherSyncAnim()
	{
		theGame.GetSyncAnimManager().SetupSimpleSyncAnim( finisherAnimName, thePlayer, GetActor() );
	}
	
	function CombatCheck() : bool
	{
		var stateName : name;
		stateName = thePlayer.GetCurrentStateName();
		if ( stateName == 'CombatSteel' || stateName == 'CombatSilver' )
		{
			return true;
		}
		return false;
	}
	
	
	function GetStats()
	{
		var resistCriticalStateMultiplier : int;
		
		criticalStatesToResist = (int)CalculateAttributeValue(GetActor().GetAttributeValue('critical_states_to_raise_guard'));
		resistCriticalStateChance = (int)MaxF(0, 100*CalculateAttributeValue(GetActor().GetAttributeValue('resist_critical_state_chance')));
		resistCriticalStateMultiplier = (int)MaxF(0, 100*CalculateAttributeValue(GetActor().GetAttributeValue('resist_critical_state_chance_mult_per_hit')));
		
		resistCriticalStateChance += Max( 0, GetNPC().GetCriticalStateCounter() - 1 ) * resistCriticalStateMultiplier;
		
		if ( criticalStatesToResist < 0 )
		{
			criticalStatesToResist = 65536;
		}
	}
	
	function Roll( chance : float ) : bool
	{
		if ( chance >= 100 )
			return true;
		else if ( RandRange(100) < chance )
		{
			return true;
		}
		
		return false;
	}
	
	private function SetHitReactionDirection()
	{
		
		var victimToAttackerAngle 	: float;
		var npc 					: CNewNPC = GetNPC();
		var target					: CActor = GetCombatTarget();
		
		if ( !buff.GetCreator() )
			return;
		
		victimToAttackerAngle = NodeToNodeAngleDistance( buff.GetCreator(), npc );
		
		if( AbsF(victimToAttackerAngle) <= 90 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionDirection',(int)EHRD_Forward);
		}
		else if( AbsF(victimToAttackerAngle) > 90 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionDirection',(int)EHRD_Back);
		}
		
		if( victimToAttackerAngle > 45 && victimToAttackerAngle < 135 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionSide',(int)EHRS_Right);
		}
		else if( victimToAttackerAngle < -45 && victimToAttackerAngle > -135 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionSide',(int)EHRS_Left);
		}
		else
		{
			npc.SetBehaviorVariable( 'HitReactionSide',(int)EHRS_None);
		}
	}
	


	
	private var startAirPos : Vector;
	private var endAirPos : Vector;
	private var cachedInAir : bool;
	private var airStartTime : float;
	private var screamPlayed : bool;
	private var fallingDamage : float;
	private var maxFallingHeightDiff : float;
	
	function OnRagdollStart()
	{
		var mac : CMovingPhysicalAgentComponent;
		var radius : float;
		var owner	: CNewNPC = GetNPC();
		mac = (CMovingPhysicalAgentComponent)GetActor().GetMovingAgentComponent();
		
		screamPlayed = false;
		airStartTime = 0.f;
		fallingDamage = 0.f;
		maxFallingHeightDiff = 0.f;
		
		if ( !GetNPC().IsInFistFightMiniGame() && GetActor().IsVulnerable() && ( !IsThisStagger() || IsCliffBehindMe() ) && !GetNPC().IsInInterior() && GetActor().EnablePhysicalMovement(true) )
		{
			mac.SnapToNavigableSpace( false );
			isInPotentialRagdoll = true;
			if ( GetActor().IsInAir() )
			{
				startAirPos = mac.GetAgentPosition();
				cachedInAir = true;
				airStartTime = GetLocalTime();
			}
			else
				cachedInAir = false;
		}
		else
		{
			GetActor().EnablePhysicalMovement(false);
			mac.SnapToNavigableSpace( true );
			isInPotentialRagdoll = false;
		}
		
	}
	
	
	function OnRagdollUpdate( owner : CNewNPC, mac : CMovingPhysicalAgentComponent )
	{
		var velocity : float;
		var submergeDepth : float;
		var currentFaliingHeightDiff : float;
		
		velocity = VecLengthSquared(mac.GetVelocity());
		submergeDepth = mac.GetSubmergeDepth();
		
		if ( !owner.IsInAir() && !cachedInAir && !mac.IsOnGround() && velocity >= 0.01 )
		{
			owner.SetIsInAir(true);
			startAirPos = mac.GetAgentPosition();
			cachedInAir = true;
			DisableFinisher();
			airStartTime = GetLocalTime();
		}
		else if ( ( !owner.IsInAir() && cachedInAir ) || ( owner.IsInAir() && mac.IsOnGround() ) || ( !mac.IsOnGround() && velocity < 0.01 ) || ( owner.IsInAir() && submergeDepth <= -0.5 ) )
		{
			EnableFinisher();
			owner.SetIsInAir(false);
			cachedInAir = false;
			endAirPos = mac.GetAgentPosition();
			currentFaliingHeightDiff = startAirPos.Z - endAirPos.Z;
			maxFallingHeightDiff = MaxF(currentFaliingHeightDiff,maxFallingHeightDiff);
			fallingDamage = MaxF(fallingDamage,owner.ApplyFallingDamage(currentFaliingHeightDiff, false));
			airStartTime = 0.f;
		}
		
			
			
		if ( owner.IsHuman() )
		{
			if ( IsThisStagger() && airStartTime > 0.f && ( (GetLocalTime() - airStartTime) > 0 ) )
			{
				ApplyRagdoll();
			}
			
			if ( !screamPlayed && airStartTime > 0.f && ( (GetLocalTime() - airStartTime) > 0.5f ) )
			{
				PlayScream();
				screamPlayed = true;
			}
		}
		else
		{	
			if ( !mac.IsOnNavigableSpace() && IsCliffBehindMe() )
			{
				ApplyRagdoll();
			}		
		}
		
		if ( !owner.IsInAir() && owner.IsHuman() && IsThisStagger() )
		{
			if ( !mac.IsOnNavigableSpace() )
			{
				ApplyRagdoll();
			}
		}
		else if ( !owner.IsInAir() && owner.IsAlive() && ( submergeDepth <= -0.5 || owner.GetBehaviorVariable('bCriticalStopped') > 0.5 ) )
		{
			if ( mac.IsOnNavigableSpace() )
			{
				return;
			}
			else if ( KillNPCIfNeeded(owner, mac) )
			{
				Complete(true);
			}
		}
	}
	
	function OnRagdollStop()
	{
		var mac 	: CMovingPhysicalAgentComponent;
		var owner 	: CNewNPC;
		
		owner = GetNPC();
		mac = (CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent();
		
		if ( owner.IsHuman() && IsThisStagger() )
		{
			if ( owner.IsInAir() || !mac.IsOnNavigableSpace() )
			{
				ApplyRagdoll();
			}
			
			if ( !owner.HasBuff(EET_Ragdoll) )
			{
				mac.SnapToNavigableSpace( true );
				owner.EnablePhysicalMovement(false);
			}
		}
		else if ( owner.IsAlive() )
		{
			if ( !mac.IsOnNavigableSpace() && KillNPCIfNeeded(owner, mac) )
			{
				mac.SnapToNavigableSpace( false );
			}
			else
			{
				mac.SnapToNavigableSpace( true );
				owner.EnablePhysicalMovement(false);
			}
		}
		else		
		{
			mac.SnapToNavigableSpace( false );
			 if( CSType == ECST_Ragdoll || owner.IsRagdolled() )
				owner.DisableDeathAndAgony();
		}
	}
	
	function IsThisStagger() : bool
	{
		return CSType == ECST_Stagger || CSType == ECST_LongStagger || CSType == ECST_CounterStrikeHit;
	}
	
	function IsCliffBehindMe() : bool
	{
		var ownerPosition, pointA, pointB : Vector;
		var heading : Vector;
		var position, normal : Vector;
		var target : CNode;
		var collisionGroups : array<name>;
		
		ownerPosition = GetNPC().GetWorldPosition();
		if ( buff.GetCreator() )
		{
			target = buff.GetCreator();
		}
		else if ( GetCombatTarget() )
		{
			target = GetCombatTarget();
		}
		
		if ( !target )
			return false;
			
		heading = VecNormalize( target.GetWorldPosition() - ownerPosition )*-1.5;
		
		pointA = ownerPosition + heading;
		
		if ( theGame.GetWorld().NavigationLineTest( ownerPosition, pointA, GetActor().GetRadius(), false, true ) )
			return false;
	
		position = ownerPosition;
		position.Z += 1.5;
		
		if ( theGame.GetWorld().StaticTrace( position, position + heading , position, normal, collisionGroups ) )
			return false;
		
		pointA.Z += 1.5;
		
		heading = VecNormalize( target.GetWorldPosition() - ownerPosition )*-2;
		pointB = ownerPosition + heading;
		pointB.Z -= 1.5;
		
		collisionGroups.PushBack('Static');
		collisionGroups.PushBack('Terrain');
		
		if ( theGame.GetWorld().SweepTest( pointA, pointB , 0.4, position, normal, collisionGroups ) )
			return false;
		
		return true;
	}
	
	function KillNPCIfNeeded( owner : CNewNPC, mac : CMovingPhysicalAgentComponent ) : bool
	{
		var newPosition : Vector;
		
		if ( !theGame.GetWorld().NavigationFindSafeSpot(mac.GetAgentPosition(), owner.GetRadius(), ClampF(owner.GetRadius()*pullToNavRadiusMult, 0, 2.5f), newPosition) 
						&& !CanSwimOrFly( owner, mac ))
		{
			if ( fallingDamage > 0 || maxFallingHeightDiff >= 1.3f )
				owner.Kill(false,NULL,'FallingDamage');
			else
				owner.Kill();
			owner.SetKinematic(false);
			return true;
		}
		
		return false;
	}
	
	function CanSwimOrFly( owner : CNewNPC, mac : CMovingPhysicalAgentComponent ) : bool
	{
		if( (owner.HasAbility('mon_drowner_base') ||  owner.HasAbility('mon_siren_base')) && mac.GetSubmergeDepth() < 0  )
			return true;
		
		if(( owner.HasAbility('mon_wyvern_base') ||  owner.HasAbility('mon_siren_base') || owner.HasAbility('mon_gryphon_base')  || owner.HasAbility('mon_harpy_base') ) &&  mac.GetSubmergeDepth() > 0 )
			return true;
			
		return false;
	}
	
	function ApplyRagdoll()
	{
		var owner 	: CNewNPC = GetNPC();
		var params 	: SCustomEffectParams;
		
		if ( GetActor().HasBuff(EET_Ragdoll) )
			return;
		
		params.effectType = EET_Ragdoll;
		params.creator = GetActor();
		params.sourceName = "inAir";
		params.duration = 1.0;
		GetActor().AddEffectCustom(params);
		
		
		
		
		
		if( !owner.IsHuman()  )
		{
			owner.Kill();
		}
	}
	
	function PlayScream()
	{
		if ( GetActor().IsWoman() )
			return GetActor().SoundEvent("grunt_vo_test_falling_scream_AdultFemale", 'head');
		else
			return GetActor().SoundEvent("grunt_vo_test_falling_scream_AdultMale", 'head');
	}


	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		var target 				: CActor = npc.GetTarget();
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		
		if ( animEventName == 'AllowBlend' && animEventType == AET_DurationStart )
		{
			Complete( true );
			return true;
		}
		else if( animEventName == 'StaggerCounter' )
		{
			npc.SignalGameplayEvent( 'StaggerCounter' );
			Complete( true );
			return true;
		}
		else if( animEventName == 'DisarmMoment' )
		{
			if ( ShouldTryToDisarm() )
				Disarm();
			
			return true;
		}
		else if ( animEventName == 'OpenGuard' && npc.HasShieldedAbility() )
		{
			if( animEventType == AET_DurationStart )
			{
				npc.SetGuarded(false);
				guardOpen = true;
			}
			else if( animEventType == AET_DurationEnd )
			{
				npc.SetGuarded(true);
				guardOpen = false;
			}
			return true;
		}
		else if ( animEventName == 'SetRagdoll' )
		{			
			if ( ( ( CMovingPhysicalAgentComponent ) npc.GetMovingAgentComponent() ).HasRagdoll() )
			{
				npc.TurnOnRagdoll();
			}
		}
		else if ( animEventName == 'SlideToTarget' )
		{
			movementAdjustor = npc.GetMovingAgentComponent().GetMovementAdjustor();
			movementAdjustor.CancelByName( 'SlideToTarget' );
			ticket = movementAdjustor.CreateNewRequest( 'SlideToTarget' );
			movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
			movementAdjustor.MaxLocationAdjustmentSpeed( ticket, 20.0 );
			movementAdjustor.ScaleAnimation( ticket );
			movementAdjustor.AdjustLocationVertically( ticket, true );
			movementAdjustor.SlideTowards( ticket, target, 1.0, 1.5 );
			return true;
		}
		
		return false;
	}
	
	function OnListenedGameplayEvent( gameEventName : name ) : bool
	{		
		if ( gameEventName == 'CriticalState' )
		{
			requestedCSType		= (int) GetNPC().GetBehaviorVariable('CriticalStateType');			
			
		}
		return IsAvailable();
	}
	
	protected function getBuffType( CSType : ECriticalStateType ) : EEffectType
	{
		switch( CSType )
		{
			case ECST_Immobilize 				: return EET_Immobilized;
			case ECST_BurnCritical 				: return EET_Burning;
			case ECST_Knockdown 				: return EET_Knockdown;
			case ECST_HeavyKnockdown 			: return EET_HeavyKnockdown;
			case ECST_Blindness					: return EET_Blindness;
			case ECST_Confusion					: return EET_Confusion;
			case ECST_Paralyzed					: return EET_Paralyzed;
			case ECST_Hypnotized				: return EET_Hypnotized;
			case ECST_Stagger					: return EET_Stagger;
			case ECST_CounterStrikeHit			: return EET_CounterStrikeHit;
			case ECST_LongStagger				: return EET_LongStagger;
			case ECST_Pull						: return EET_Pull;
			case ECST_Ragdoll					: return EET_Ragdoll;
			case ECST_PoisonCritical			: return EET_PoisonCritical;
			case ECST_Frozen					: return EET_Frozen;
			case ECST_Swarm						: return EET_Swarm;
			case ECST_Snowstorm					: return EET_Snowstorm;
			case ECST_Tornado					: return EET_Tornado;
			default 							: return EET_Undefined;
		}
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc : CNewNPC;
		var syncAnimName : name;
		var effect : CBaseGameplayEffect;
		
		npc = GetNPC();
		if ( eventName == 'RotateEventStart' )
		{
			effect = npc.GetBuff(getBuffType( CSType ));
			npc.SetRotationAdjustmentRotateTo( (CNode)(effect.GetCreator()) );
			return true;
		}
		else if ( eventName == 'StoppingEffect' && finisherEnabled && GetEventParamInt(-1) == CSType )
		{
			GetNPC().EnableFinishComponent( false );
			thePlayer.AddToFinishableEnemyList( GetNPC(), false );
			finisherEnabled = false;
			return true;
		}
		else if ( eventName == 'Finisher' )
		{
			if ( CombatCheck() && finisherEnabled )
			{
				GetNPC().EnableFinishComponent( false );
				thePlayer.AddToFinishableEnemyList( GetNPC(), false );
				GetNPC().FinisherAnimStart();
				FinisherSyncAnim();
			}
			return true;
		}
		else if ( eventName == 'ParryStart' && ShouldCompleteOnParryStart() && npc.IsShielded(GetCombatTarget()) )
		{
			Complete(true);
			return true;
		}
		else if ( eventName == 'DisableFinisher' )
		{
			
			if( !npc.HasAbility('mon_siren_base') )
			{
				finisherDisabled = true;
				DisableFinisher();
			}
			return true;
		}
		else if ( eventName == 'EnableFinisher' )
		{
			finisherDisabled = false;
			EnableFinisher();
			return true;
		}
		else if ( eventName == 'ForceStopCriticalEffect' && GetEventParamInt(-1) == CSType )
		{
			Complete(true);
			return true;
		}
		else if	( eventName == 'SpearDestruction')
		{
			npc.ProcessSpearDestruction();
			waitForDropItem = false;
			return true;
		}
		
		return false;
	}
	
	function InitializeDataStorages()
	{
		if ( !combatDataStorage || !reactionDataStorage )
		{
			storageHandler = InitializeCombatStorage();
			combatDataStorage = (CHumanAICombatStorage)storageHandler.Get();
			
			storageHandler = new CAIStorageHandler in this;
			storageHandler.Initialize( 'ReactionData', '*CAIStorageReactionData', this );
			reactionDataStorage = (CAIStorageReactionData)storageHandler.Get();
		}
	}
};

class CBehTreeTaskCSEffectDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskCSEffect';
	editable var finisherAnimName		: CBehTreeValCName;	
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CriticalState' );
	}
}
