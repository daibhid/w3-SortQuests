/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/





class CBTTaskCharge extends CBTTaskAttack
{
	var checkLineOfSight				: bool;
	var dealDamage						: bool;
	var bCollisionWithActor 			: bool;
	var activated						: bool;
	var endTaskWhenOwnerGoesPastTarget 	: bool;
	var xmlDamageName					: name;
	var collidedActor 					: CActor;
	var chargeType						: EChargeAttackType;
	
	
	
	default bCollisionWithActor 		= false;
	
	
	function IsAvailable() : bool
	{
		if( !checkLineOfSight )
		{ 
			return super.IsAvailable() ;
		}		
		if ( theGame.GetWorld().NavigationLineTest(GetActor().GetWorldPosition(), GetCombatTarget().GetWorldPosition(), GetActor().GetRadius()) )
		{
			return super.IsAvailable();
		}
		return false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var dotProduct 					: float;
		var npc 						: CNewNPC;
		var target						: CActor;
		var targetPos					: Vector;
		var npcPos						: Vector;
		var startPos					: Vector;
		
		npc.SetBehaviorVariable( 'AttackEnd', 0 );
		
		if ( endTaskWhenOwnerGoesPastTarget )
		{
			npc = GetNPC();
			target = GetCombatTarget();
			startPos = npc.GetWorldPosition();
			dotProduct = 0;
			
			while ( dotProduct >= 0.0f )
			{
				Sleep( 0.25 );
				npcPos		= npc.GetWorldPosition();
				targetPos 	= target.GetWorldPosition();
				dotProduct 	= VecDot( targetPos - startPos, targetPos - npcPos );
			}
			
			npc.SetBehaviorVariable( 'AttackEnd', 1.0 );
			return BTNS_Completed;
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		super.OnDeactivate();
		
		bCollisionWithActor = false;
		collidedActor = NULL;
		activated = false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc 			: CNewNPC = GetNPC();
		var damageAction 	: W3DamageAction;
		var action			: W3Action_Attack;
		var damage 			: float;
		var attackName		: name;
		var skillName		: name;
		var params			: SCustomEffectParams;
		
		if ( activated && !bCollisionWithActor && eventName == 'CollisionWithActor' )
		{
			collidedActor = (CActor)GetEventParamObject();
			if ( IsRequiredAttitudeBetween(npc,collidedActor,true) )
			{				
				bCollisionWithActor = true;
				if ( !dealDamage )
				{
					if(chargeType == ECAT_Knockdown)
						params.effectType = EET_KnockdownTypeApplicator;
					else if(chargeType == ECAT_Stagger)
						params.effectType = EET_Stagger;
					
					if(params.effectType != EET_Undefined)
					{
						params.creator = npc;
						params.duration = 0.5;
						
						collidedActor.AddEffectCustom(params);
					}				
				}
				else
				{
					
					action = new W3Action_Attack in theGame.damageMgr;
					
					switch (chargeType)
					{
						case ECAT_Knockdown:
							skillName = 'attack_super_heavy';
							attackName = 'attack_super_heavy';
							break;
						case ECAT_Stagger:
							skillName = 'attack_stagger';
							attackName = 'attack_stagger';
							break;
					}
					
					action.Init( npc, collidedActor, NULL, npc.GetInventory().GetItemFromSlot( 'r_weapon' ), attackName, npc.GetName(), EHRT_None, false, true, skillName, AST_Jab, ASD_UpDown, true, false, false, false );
					theGame.damageMgr.ProcessAction( action );
					
					delete action;
				}
			}
			return true;
		}
		
		return super.OnGameplayEvent( eventName );
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		res = super.OnAnimEvent(animEventName,animEventType,animInfo);
		
		if ( animEventName == 'attackStart')
		{
			activated = true;
			return true;
		}
		else if ( animEventName == 'Knockdown' && animEventType == AET_DurationStart )
		{
			activated = true;
			return true;
		}
		else if ( animEventName == 'Knockdown' && animEventType == AET_DurationEnd )
		{
			activated = false;
			return true;
		}
		else if ( animEventName == 'Stagger' && animEventType == AET_DurationStart )
		{
			activated = true;
			return true;
		}
		else if ( animEventName == 'Stagger' && animEventType == AET_DurationEnd )
		{
			activated = false;
			return true;
		}
		
		return res;
	}
}

class CBTTaskChargeDef extends CBTTaskAttackDef
{
	default instanceClass 						= 'CBTTaskCharge';

	editable var checkLineOfSight				: bool;
	editable var dealDamage 					: bool;
	editable var endTaskWhenOwnerGoesPastTarget	: bool;
	editable var chargeType 					: EChargeAttackType;
	
	default checkLineOfSight 					= true;
	default dealDamage 							= true;
	default chargeType 							= ECAT_Knockdown;
}
