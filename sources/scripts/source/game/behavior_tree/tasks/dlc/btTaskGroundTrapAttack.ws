/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CBTTaskGroundTrapAttack extends CBTTaskAttack
{
	public var camShakeStrength 			: float;
	public var activateOnAnimEvent 			: name;
	public var affectEnemiesInRange 		: float;
	public var delayDamage 					: float;
	public var debuffType 					: EEffectType;
	public var debuffDuration 				: float;
	public var trapResourceName				: name;
	public var playFxOnTrapSpawn			: name;
	public var playFxDamage 				: name;
	public var delayDamageFx 				: float;
	
	private var m_trapEntity				: CEntityTemplate;
	private var m_trap						: CGameplayEntity;
	private var m_activated 				: bool;
	
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var npc						: CNewNPC = GetNPC();
		var params 					: SCustomEffectParams;
		var action 					: W3DamageAction;
		var attributeName 			: name;
		var victims 				: array<CGameplayEntity>;
		var damage 					: float;
		var timeStamp 				: float;
		var res1, res2				: bool;
		var i 						: int;
		
		
		if ( !m_trapEntity )
		{
			m_trapEntity = (CEntityTemplate)LoadResourceAsync( trapResourceName );
		}
		
		if ( !m_trapEntity )
		{
			return BTNS_Failed;
		}
		
		attributeName = GetBasicAttackDamageAttributeName(theGame.params.ATTACK_NAME_LIGHT, theGame.params.DAMAGE_NAME_PHYSICAL);
		damage = CalculateAttributeValue(npc.GetAttributeValue(attributeName));
		
		action = new W3DamageAction in this;
		action.SetHitAnimationPlayType(EAHA_ForceNo);
		action.attacker = npc;
		
		
		
		if ( IsNameValid( activateOnAnimEvent ) )
		{
			while( !m_activated )
			{
				SleepOneFrame();
			}
		}
		else
		{
			m_activated = true;
		}
		
		while ( m_activated )
		{
			if ( timeStamp == 0 )
				timeStamp = GetLocalTime();
			
			SleepOneFrame();
			
			if ( !m_trap )
			{
				m_trap = (CGameplayEntity)theGame.CreateEntity( m_trapEntity, GetCombatTarget().GetWorldPosition(), npc.GetWorldRotation() );
				if ( IsNameValid( playFxOnTrapSpawn ) && m_trap )
					m_trap.PlayEffect( playFxOnTrapSpawn );
			}
			
			if ( ( timeStamp + delayDamageFx ) < GetLocalTime() && !res1 )
			{
				res1 = true;
				
				if ( IsNameValid( playFxDamage ) )
					m_trap.PlayEffect( playFxDamage );
			}
			
			if ( ( timeStamp + delayDamage ) < GetLocalTime() && !res2 )
			{
				res2 = true;
				
				victims.Clear();
				FindGameplayEntitiesInRange( victims, m_trap, affectEnemiesInRange, 99, , FLAG_OnlyAliveActors );
				
				if ( camShakeStrength > 0 )
					GCameraShake(camShakeStrength, true, m_trap.GetWorldPosition(), 30.0f);
				
				if ( victims.Size() > 0 )
				{
					for ( i = 0 ; i < victims.Size() ; i += 1 )
					{
						if ( victims[i] != npc && !((CActor)victims[i]).IsCurrentlyDodging() )
						{
							if ( debuffType != EET_Undefined )
							{
								params.effectType = debuffType;
								params.creator = npc;
								params.sourceName = npc.GetName();
								if ( debuffDuration > 0 )
									params.duration = debuffDuration;
								
								((CActor)victims[i]).AddEffectCustom(params);
							}
							
							action.Initialize( npc, victims[i], this, npc.GetName(), EHRT_None, CPS_AttackPower, false, true, false, false);
							action.AddDamage(theGame.params.DAMAGE_NAME_RENDING, damage );
							theGame.damageMgr.ProcessAction( action );
						}
					}
				}
			}
		}
		
		victims.Clear();
		delete action;
		return BTNS_Active;
	}
	
	
	
	function OnDeactivate()
	{
		m_trap.DestroyAfter( 5.0 );
		m_trap.StopAllEffects();
		m_activated = false;
		
		super.OnDeactivate();
	}
	
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == activateOnAnimEvent )
		{
			m_activated = true;	
			return true;
		}
		
		return false;
	}
}




class CBTTaskGroundTrapAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskGroundTrapAttack';
	
	editable var camShakeStrength 			: float;
	editable var activateOnAnimEvent 		: name;
	editable var affectEnemiesInRange 		: float;
	editable var delayDamage 				: float;
	editable var debuffType 				: EEffectType;
	editable var debuffDuration 			: float;
	editable var trapResourceName 			: name;
	editable var playFxOnTrapSpawn			: name;
	editable var playFxDamage 				: name;
	editable var delayDamageFx 				: float;
}