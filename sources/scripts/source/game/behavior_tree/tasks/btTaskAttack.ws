/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class CBTTaskAttack extends CBTTaskPlayAnimationEventDecorator
{
	var attackType									: EAttackType;
	var stopTaskAfterDealingDmg 					: bool;
	var setAttackEndVarOnStopTask					: bool;
	var useDirectionalAttacks 						: bool;
	var fxOnDamageInstigated 						: name;
	var fxOnDamageVictim							: name;
	var applyFXCooldown								: float;
	var behVarNameOnDeactivation 					: name;
	var behVarValueOnDeactivation 					: float;
	var stopAllEfectsOnDeactivation 				: bool;
	
	
	var slideToTargetOnAnimEvent 					: bool;
	var useCombatTarget 							: bool;
	var applyEffectType								: EEffectType;
	var customEffectDuration						: float;
	var fxTimeCooldown								: float;
	
	var useActionBlend : bool;
	
	var stopTask : bool;
	
	default stopTask = false;
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor;
		var targetToAttackerAngle : float;
		
		InitializeCombatDataStorage();	
		
		if( useCombatTarget )
			target = GetCombatTarget();
		else
			target = (CActor)GetActionTarget();
		
		npc.SetBehaviorVariable( 'AttackType', (int)attackType, true );
		
		if ( setAttackEndVarOnStopTask )
			npc.SetBehaviorVariable( 'AttackEnd', 0 );
		
		
		target.SetUnpushableTarget( npc );
		npc.SetUnpushableTarget( target );
		
		if ( useDirectionalAttacks )
		{
			targetToAttackerAngle = NodeToNodeAngleDistance(target,npc);
			
			npc.SetBehaviorVariable( 'targetAngleDiff', targetToAttackerAngle/180, true);
			
			if( targetToAttackerAngle >= -180.0 && targetToAttackerAngle < -157.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_m180, true );
			}
			if( targetToAttackerAngle >= -157.5 && targetToAttackerAngle < -112.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_m135, true );
			}
			if( targetToAttackerAngle >= -112.5 && targetToAttackerAngle < -67.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_m90, true );
			}
			else if( targetToAttackerAngle >= -67.5 && targetToAttackerAngle < -22.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_m45, true );
			}
			else if( targetToAttackerAngle >= -22.5 && targetToAttackerAngle < 22.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_0, true );
			}
			else if( targetToAttackerAngle >= 22.5 && targetToAttackerAngle < 67.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_45, true );
			}
			else if( targetToAttackerAngle >= 67.5 && targetToAttackerAngle < 112.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_90, true );
			}
			else if( targetToAttackerAngle >= 112.5 && targetToAttackerAngle < 157.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_135, true );
			}
			else if( targetToAttackerAngle >= 157.5 && targetToAttackerAngle < 180.0 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_180, true );
			}
			
		}
		return super.OnActivate();
	}
	
	latent function Main() : EBTNodeStatus
	{
		var startTime : float = GetLocalTime();
		var npc : CNewNPC = GetNPC();
		
		while ( startTime + 0.15 > GetLocalTime() ) 
		{	
			SleepOneFrame();
		}
		combatDataStorage.SetIsAttacking( true, GetLocalTime() );
		
		return BTNS_Active;
	}
	
	function OnDeactivate() 
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		
		combatDataStorage.SetIsAttacking( false );
		
		
		target.SetUnpushableTarget( NULL );
		npc.SetUnpushableTarget( NULL );
		
		
		if ( thePlayer.GetDodgeFeedbackTarget() == npc )
			npc.SetDodgeFeedback( false );		
		
		
		
		if ( behVarNameOnDeactivation )
		{
			npc.SetBehaviorVariable( behVarNameOnDeactivation, behVarValueOnDeactivation, true );
		}
		
		if ( stopAllEfectsOnDeactivation )
		{
			npc.StopAllEffects();
		}
		
		stopTask = false;
		
		super.OnDeactivate();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var owner				: CActor = GetActor();
		var target 				: CActor = GetCombatTarget();
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		var minDistance			: float;
		
		if ( slideToTargetOnAnimEvent && animEventName == 'SlideToTarget' && ( animEventType == AET_DurationStart || animEventType == AET_DurationStartInTheMiddle ))
		{
			movementAdjustor = owner.GetMovingAgentComponent().GetMovementAdjustor();
			
			if ( movementAdjustor )
			{
				movementAdjustor.CancelByName( 'SlideToTarget' );
				ticket = movementAdjustor.CreateNewRequest( 'SlideToTarget' );
				movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
				
				movementAdjustor.MaxLocationAdjustmentSpeed( ticket, 1000000 );
				movementAdjustor.ScaleAnimation( ticket );
				minDistance = ((CMovingPhysicalAgentComponent)owner.GetMovingAgentComponent()).GetCapsuleRadius()+((CMovingPhysicalAgentComponent)target.GetMovingAgentComponent()).GetCapsuleRadius();
				minDistance += 0.1;
				movementAdjustor.SlideTowards( ticket, target, minDistance, 10000 );
			}
			return true;
		}
		else if ( stopTask && ( animEventName == 'AllowBlend'  || (useActionBlend && animEventName == 'ActionBlend') ) )
		{
			GetNPC().RaiseEvent('AnimEndAUX');
			Complete(true);
			return true;
		}
		
		return super.OnAnimEvent(animEventName, animEventType, animInfo);
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc 			: CNewNPC = GetNPC();
		var attributeValue 	: SAbilityAttributeValue;
		
		if ( eventName == 'DamageInstigated' )
		{
			ApplyCriticalEffectOnTarget();
			
			if ( IsNameValid( fxOnDamageInstigated ) && ( GetLocalTime() > fxTimeCooldown ))
			{
				fxTimeCooldown = GetLocalTime() + applyFXCooldown;
				npc.PlayEffect(fxOnDamageInstigated);
			}
			if ( IsNameValid( fxOnDamageVictim ) && ( GetLocalTime() > fxTimeCooldown ))
			{
				fxTimeCooldown = GetLocalTime() + applyFXCooldown;
				GetCombatTarget().PlayEffect( fxOnDamageVictim );
			}
			if ( stopTaskAfterDealingDmg )
			{
				if ( setAttackEndVarOnStopTask )
					npc.SetBehaviorVariable( 'AttackEnd', 1.0 );
				stopTask = true;
			}
			return true;
		}
		else if ( eventName == 'AxiiGuardMeAdded' )
		{
			GetNPC().RaiseEvent('AnimEndAUX');
			Complete(true);
			return true;
		}
		
		return super.OnGameplayEvent(eventName);
	}
	
	function ApplyCriticalEffectOnTarget()
	{
		var npc 	: CNewNPC = GetNPC();
		var target 	: CActor = GetCombatTarget();
		var params 	: SCustomEffectParams;		
		
		if ( applyEffectType != EET_Undefined )
		{
			if ( customEffectDuration > 0 )
			{
				params.effectType = applyEffectType;
				params.creator = npc;
				params.sourceName = npc.GetName();
				params.duration = customEffectDuration;
				
				target.AddEffectCustom( params );
			}
			else
			{
				target.AddEffectDefault( applyEffectType, npc, npc.GetName() );
			}
		}
	}
};

class CBTTaskAttackDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskAttack';
	
	editable var attackType									: EAttackType;
	editable var stopTaskAfterDealingDmg					: bool;
	editable var setAttackEndVarOnStopTask					: bool;
	editable var useDirectionalAttacks 						: bool;
	editable var fxOnDamageInstigated 						: name;
	editable var fxOnDamageVictim							: name;
	editable var applyFXCooldown							: float;
	editable var behVarNameOnDeactivation 					: name;
	editable var behVarValueOnDeactivation 					: float;	
	editable var stopAllEfectsOnDeactivation 				: bool;
	
	editable var slideToTargetOnAnimEvent 					: bool;
	editable var useCombatTarget 							: bool;
	editable var useActionBlend 							: bool;
	editable var attackParameter							: CBehTreeValInt;
	editable var applyEffectType							: EEffectType;
	editable var customEffectDuration						: float;
	
	default attackType 										= EAT_Attack1;
	default stopTaskAfterDealingDmg 						= false;
	default useDirectionalAttacks 							= false;
	default stopAllEfectsOnDeactivation 					= false;
	default slideToTargetOnAnimEvent 						= true;
	default useCombatTarget 								= true;
	default useActionBlend 									= false;
	default customEffectDuration							= -1;
	
	function OnSpawn( task : IBehTreeTask )
	{
		var thisTask : CBTTaskAttack; 
		
		thisTask = (CBTTaskAttack)task;
		
		if( attackType ==  EAT_None && GetValInt( attackParameter ) >= 0 )
		{
			thisTask.attackType	= GetValInt( attackParameter );
		}
	}
};

