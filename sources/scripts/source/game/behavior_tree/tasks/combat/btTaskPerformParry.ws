/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CBTTaskPerformParry extends CBTTaskPlayAnimationEventDecorator
{
	var activationTimeLimitBonusHeavy : float;
	var activationTimeLimitBonusLight : float;
	
	var activationTimeLimit : float;
	var action : CName;
	
	var runMain : bool;
	
	var counterChance : float;
	var hitsToCounter : int;
		
	default activationTimeLimit = 0.0;
	default action = '';
	default runMain = false;
	
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		if ( ((CHumanAICombatStorage)combatDataStorage).IsProtectedByQuen() )
		{
			GetNPC().SetParryEnabled(true);
			return false;
		}
		else if ( activationTimeLimit > 0.0 && ( isActive || !combatDataStorage.GetIsAttacking() ) )
		{
			if ( GetLocalTime() < activationTimeLimit )
			{
				return true;
			}
			activationTimeLimit = 0.0;
			return false;
		}
		else if ( GetNPC().HasShieldedAbility() && activationTimeLimit > 0.0 )
		{
			GetNPC().SetParryEnabled(true);
			return false;
		}
		else
			GetNPC().SetParryEnabled(false);
			
		return false;
		
	}
	
	function OnActivate() : EBTNodeStatus
	{
		InitializeCombatDataStorage();
		GetNPC().SetParryEnabled(true);
		LogChannel( 'HitReaction', "TaskActivated. ParryEnabled" );
		
		GetStats();
		
		if ( action == 'ParryPerform' )
		{
			if ( TryToParry() )
			{
				runMain = true;
				RunMain();
			}
			action = '';
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var resStart,resEnd : bool = false;
		while ( runMain )
		{
			resStart = GetNPC().WaitForBehaviorNodeDeactivation('ParryPerformEnd',2.f);
			resEnd = GetNPC().WaitForBehaviorNodeActivation('ParryPerformStart',0.0001f);
			if ( !resEnd )
			{
				activationTimeLimit = 0;
				runMain = false;
			}
			if ( resStart && resEnd )
			{
				SleepOneFrame();
			}
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetNPC().SetParryEnabled( false );
		runMain = false;
		activationTimeLimit = 0;
		action = '';
		
		((CHumanAICombatStorage)combatDataStorage).ResetParryCount();
		
		super.OnDeactivate();
		
		LogChannel( 'HitReaction', "PerformParry Task Deactivated" );
	}
	
	private function GetStats()
	{
		counterChance = MaxF(0, 100*CalculateAttributeValue(GetActor().GetAttributeValue('counter_chance')));
		hitsToCounter = (int)MaxF(0, CalculateAttributeValue(GetActor().GetAttributeValue('hits_to_roll_counter')));
		
		if ( hitsToCounter < 0 )
		{
			hitsToCounter = 65536;
		}
		
	}
	
	private function TryToParry(optional counter : bool) : bool
	{
		var npc : CNewNPC = GetNPC();
		var mult : float;
		
		if ( isActive && npc.CanParryAttack() )
		{
			LogChannel( 'HitReaction', "Parried" );
			
			npc.SignalGameplayEvent('SendBattleCry');
			
			mult = theGame.params.HEAVY_STRIKE_COST_MULTIPLIER;
			
			if ( npc.RaiseEvent('ParryPerform') )
			{
				if( counter )
				{
					npc.DrainStamina( ESAT_Counterattack, 0, 0, '', 0 );
					npc.SignalGameplayEvent('Counter');
				}
				else
					npc.DrainStamina( ESAT_Parry, 0, 0, '', 0, mult );
				
				((CHumanAICombatStorage)combatDataStorage).IncParryCount();
				activationTimeLimit = GetLocalTime() + 0.5;
			}
			else
			{
				Complete(false);
			}
			
			return true;
			
		}
		else if ( isActive )
		{
			Complete(false);
			activationTimeLimit = 0.0;
		}
		
		
		return false;
	}
	
	function AdditiveParry( optional force : bool) : bool
	{
		var npc : CNewNPC = GetNPC();

		if ( force || (!isActive && npc.CanParryAttack() && combatDataStorage.GetIsAttacking()) )
		{
			npc.RaiseEvent('PerformAdditiveParry');
			return true;
		}
		
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var res : bool;
		var isHeavy : bool;
		
		InitializeCombatDataStorage();
		
		
		if ( eventName == 'ParryStart' )
		{
			isHeavy = GetEventParamInt(-1);
		
			if ( isHeavy )
				activationTimeLimit = GetLocalTime() + activationTimeLimitBonusHeavy;
			else
				activationTimeLimit = GetLocalTime() + activationTimeLimitBonusLight;
			
			if ( GetNPC().HasShieldedAbility() )
			{
				GetNPC().SetParryEnabled(true);
			}
			
			return true;
		}
		
		
		else if ( eventName == 'ParryPerform' )
		{
			if( AdditiveParry() )
				return true;

			if( !isActive )
				return false;
			
			isHeavy = GetEventParamInt(-1);
			if( ShouldCounter(isHeavy) )
				res = TryToParry(true);
			else
				res = TryToParry();
			
			if( res )
			{
				runMain = true;
				RunMain();
			}		
			return true;
		}
		
		else if ( eventName == 'CounterParryPerform' )
		{
			if ( TryToParry(true) )
			{
				runMain = true;
				RunMain();
			}
			return true;
		}
		
		else if( eventName == 'ParryStagger' )
		{
			if( !isActive )
				return false;
				
			if( GetNPC().HasShieldedAbility() )
			{
				GetNPC().AddEffectDefault( EET_Stagger, GetCombatTarget(), "ParryStagger" );
				runMain = false;
				activationTimeLimit = 0.0;
			}
			else if ( TryToParry() )
			{
				GetNPC().LowerGuard();
				runMain = false;
			}
			return true;
		}
		
		else if ( eventName == 'ParryEnd' )
		{
			activationTimeLimit = 0.0;
			return true;
		}
		else if ( eventName == 'PerformAdditiveParry' )
		{
			AdditiveParry(true);
			return true;
		}
		else if ( eventName == 'WantsToPerformDodgeAgainstHeavyAttack' && GetActor().HasAbility('ablPrioritizeAvoidingHeavyAttacks') )
		{
			activationTimeLimit = 0.0;
			if ( isActive )
				Complete(true);
			return true;
		}
		
		return super.OnGameplayEvent ( eventName );
	}
	
	function ShouldCounter(isHeavy : bool) : bool
	{
		var playerTarget : W3PlayerWitcher;
		
		if ( GetActor().HasAbility('DisableCounterAttack') )
			return false;
		
		playerTarget = (W3PlayerWitcher)GetCombatTarget();
		
		if ( playerTarget && playerTarget.IsInCombatAction_SpecialAttack() )
			return false;
		
		if ( isHeavy && !GetActor().HasAbility('ablCounterHeavyAttacks') )
			return false;
		
		return ((CHumanAICombatStorage)combatDataStorage).GetParryCount() >= hitsToCounter && Roll(counterChance);
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			storageHandler = InitializeCombatStorage();
			combatDataStorage = (CHumanAICombatStorage)storageHandler.Get();
		}
	}
}

class CBTTaskPerformParryDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskPerformParry';

	editable var activationTimeLimitBonusHeavy : CBehTreeValFloat;
	editable var activationTimeLimitBonusLight : CBehTreeValFloat;

	default finishTaskOnAllowBlend = false;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'ParryStart' );
		listenToGameplayEvents.PushBack( 'ParryPerform' );
		listenToGameplayEvents.PushBack( 'CounterParryPerform' );
		listenToGameplayEvents.PushBack( 'ParryStagger' );
		listenToGameplayEvents.PushBack( 'ParryEnd' );
		listenToGameplayEvents.PushBack( 'PerformAdditiveParry' );
		listenToGameplayEvents.PushBack( 'WantsToPerformDodgeAgainstHeavyAttack' );
		listenToGameplayEvents.PushBack( 'IgniShieldUp' );
		listenToGameplayEvents.PushBack( 'IgniShieldDown' );
	}
}

class CBTTaskCombatStylePerformParry extends CBTTaskPerformParry
{
	public var parentCombatStyle : EBehaviorGraph;
	
	function GetActiveCombatStyle() : EBehaviorGraph
	{
		InitializeCombatDataStorage();
		if ( combatDataStorage )
			return ((CHumanAICombatStorage)combatDataStorage).GetActiveCombatStyle();
		else
			return EBG_Combat_Undefined;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid(eventName) && parentCombatStyle != GetActiveCombatStyle() )
		{
			return false;
		}
		return super.OnListenedGameplayEvent(eventName);
	}
}

class CBTTaskCombatStylePerformParryDef extends CBTTaskPerformParryDef
{
	default instanceClass = 'CBTTaskCombatStylePerformParry';

	editable inlined var parentCombatStyle : CBTEnumBehaviorGraph;
}
