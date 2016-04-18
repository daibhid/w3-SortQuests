/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CBTTaskPlayAnimationEventDecorator extends IBehTreeTask
{
	var finishTaskOnAllowBlend				: bool;
	var rotateOnRotateEvent 				: bool;
	var disableHitOnActivation 				: bool;
	var disableLookatOnActivation 			: bool;
	var interruptOverlayAnim				: bool;
	var checkStats							: bool;
	var xmlMoraleCheckName					: name;
	var xmlStaminaCostName					: name;
	var drainStaminaOnUse					: bool;
	var completeTaskOnRotateEnd				: bool;
			
	private var staminaCost					: float;
	private var moraleThreshold				: float;
	private var lookAt 						: bool;
	private var hitAnim 					: bool;
	private var additiveHits 				: bool;
	private var slowMo 						: bool;
	private var guardOpen					: bool;
	private var unstoppable					: bool;
	
	private var waitingForEndOfDisableHit 	: bool;
	
	protected var storageHandler 			: CAIStorageHandler;
	protected var combatDataStorage 		: CBaseAICombatStorage;	
	
	function IsAvailable() : bool
	{
		if ( checkStats )
		{
			GetStats();
			if ( IsNameValid(xmlStaminaCostName) && GetActor().GetStat( BCS_Stamina ) < staminaCost )
			{
				return false;
			}
			if ( IsNameValid(xmlMoraleCheckName) && GetActor().GetStat( BCS_Morale ) < moraleThreshold )
			{
				return false;
			}
		}
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		GetStats();
		
		if ( drainStaminaOnUse && staminaCost )
			npc.DrainStamina(ESAT_FixedValue, staminaCost, 1);
		if ( disableHitOnActivation )
			npc.SetCanPlayHitAnim( false );
		if ( disableLookatOnActivation )
		{
			npc.SignalGameplayEvent('LookatOff');
			lookAt = true;
		}
		if ( interruptOverlayAnim )
		{
			npc.RaiseEvent('InterruptOverlay');
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		if ( hitAnim || disableHitOnActivation )
		{
			npc.SetCanPlayHitAnim( true );
			hitAnim = false;
		}
		if ( unstoppable )
		{
			npc.SetUnstoppable( false );
			unstoppable = false;
		}
		if ( lookAt )
		{
			lookAt = false;
			npc.SignalGameplayEvent('LookatOn');
		}
		if ( additiveHits )
		{
			npc.SetUseAdditiveHit( false );
		}
		if ( slowMo )
		{
			theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_SlowMoTask) );
			slowMo = false;
		}
		if ( guardOpen )
		{
			npc.SetGuarded(true);
		}
		if( waitingForEndOfDisableHit )
		{
			npc.SetCanPlayHitAnim( true );
			waitingForEndOfDisableHit = false;
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
	
	function GetStats()
	{
		if ( xmlStaminaCostName )
		{
			staminaCost = CalculateAttributeValue(GetNPC().GetAttributeValue( xmlStaminaCostName ));
		}
		if ( xmlMoraleCheckName )
		{
			moraleThreshold = CalculateAttributeValue(GetNPC().GetAttributeValue( xmlMoraleCheckName ));
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( finishTaskOnAllowBlend && animEventName == 'AllowBlend' && animEventType == AET_DurationStart )
		{
			Complete(true);
		}
		else if ( animEventName == 'LTrail' )
		{
			if( animEventType == AET_DurationStart )
			{
				npc.PlayEffect('l_trail');
			}
			else if( animEventType == AET_DurationEnd )
			{
				npc.StopEffect('l_trail');
			}
		}
		else if ( animEventName == 'RTrail' )
		{
			if( animEventType == AET_DurationStart )
			{
				npc.PlayEffect('r_trail');
			}
			else if( animEventType == AET_DurationEnd )
			{
				npc.StopEffect('r_trail');
			}
		}
		else if ( animEventName == 'DisableHitAnim' && !disableHitOnActivation )
		{
			if( animEventType == AET_DurationEnd )
			{
				npc.SetCanPlayHitAnim( true );
				hitAnim = false;
				waitingForEndOfDisableHit = false;
			}
			else
			{
				npc.SetCanPlayHitAnim( false );
				waitingForEndOfDisableHit = true;
				hitAnim = true;
			}
		}
		else if ( animEventName == 'SetUnstoppable' && !disableHitOnActivation )
		{
			if( animEventType == AET_DurationEnd )
			{
				npc.SetUnstoppable( false );
				unstoppable = false;
			}
			else
			{
				npc.SetUnstoppable( true );
				unstoppable = true;
			}
		}
		else if ( animEventName == 'LookatOff' )
		{
			if( animEventType == AET_DurationStart )
			{
				npc.SignalGameplayEvent('LookatOff');
				lookAt = true;
			}
			else if ( animEventType == AET_DurationEnd )
			{
				npc.SignalGameplayEvent('LookatOn');
				lookAt = false;
			}
		}
		else if ( animEventName == 'LookatOn' )
		{
			if( animEventType == AET_DurationStart )
			{
				npc.SignalGameplayEvent('LookatOn');
				lookAt = false;
			}
		}
		else if ( animEventName == 'AdditiveHitsOnly' )
		{
			if( animEventType == AET_DurationStart )
			{
				npc.SetCanPlayHitAnim( false );
				hitAnim = true;
			}
			else if( animEventType == AET_DurationEnd )
			{
				npc.SetCanPlayHitAnim( true );
				hitAnim = false;
			}
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
		}
		else if ( animEventName == 'Invulnerable' )
		{
			if( animEventType == AET_DurationStart )
			{
				npc.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
			}
			else if( animEventType == AET_DurationEnd )
			{
				npc.SetImmortalityMode( AIM_None, AIC_Combat );
			}
		}
		else if ( animEventName == 'DisableGameplayVisibility' )
		{
			if( animEventType == AET_DurationStart )
			{
				npc.SetGameplayVisibility( false );
			}
			else if( animEventType == AET_DurationEnd )
			{
				npc.SetGameplayVisibility( true );
			}
		}
		else if ( animEventName == 'DisableProxyCollisions' )
		{
			if( animEventType == AET_DurationStart )
			{
				npc.EnableCharacterCollisions( false );
			}
			else if( animEventType == AET_DurationEnd )
			{
				npc.EnableCharacterCollisions( true );
			}
		}
		else if ( animEventName == 'CompleteTask' && animEventType == AET_DurationEnd )
		{
			Complete( true );
		}
		else if ( animEventName == 'RotateEnd' && completeTaskOnRotateEnd )
		{
			Complete( true );
		}
		
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( rotateOnRotateEvent )
		{
			if ( eventName == 'RotateEventStart')
			{
				GetNPC().SetRotationAdjustmentRotateTo( GetCombatTarget() );
				return true;
			}
			if ( eventName == 'RotateAwayEventStart')
			{
				GetNPC().SetRotationAdjustmentRotateTo( GetCombatTarget(), 180.0 );
				return true;
			}
		}
		
		return false;
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			storageHandler = InitializeCombatStorage();
			combatDataStorage = (CBaseAICombatStorage)storageHandler.Get();
		}
	}
};

class CBTTaskPlayAnimationEventDecoratorDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPlayAnimationEventDecorator';

	editable var finishTaskOnAllowBlend		: bool;
	editable var rotateOnRotateEvent		: bool;
	editable var disableHitOnActivation 	: bool;
	editable var disableLookatOnActivation 	: bool;
	editable var interruptOverlayAnim		: bool;
	editable var checkStats					: bool;
	editable var xmlMoraleCheckName			: name;
	editable var xmlStaminaCostName			: name;
	editable var drainStaminaOnUse			: bool;
	editable var completeTaskOnRotateEnd	: bool;
	
	default rotateOnRotateEvent = true;
	default finishTaskOnAllowBlend = true;
	default disableHitOnActivation = false;
	default disableLookatOnActivation = false;
	default interruptOverlayAnim = true;
	default checkStats = true;
};
