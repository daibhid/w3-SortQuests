/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


class W3ArrowProjectile extends W3AdvancedProjectile
{
	editable 	var defaultTrail 				: name;		default defaultTrail = 'arrow_trail';
	
	public	 	var underwaterTrail 			: name;		default underwaterTrail = 'arrow_trail_underwater';
	private 	var boneName 					: name;
	private 	var activeTrail					: name;
	private		var shouldBeAttachedToVictim 	: bool;		default shouldBeAttachedToVictim = true;
	
	protected 	var isOnFire 					: bool;
	protected 	var isUnderwater 				: bool;
	protected   var isBouncedArrow				: bool;
	protected   var isScheduledForDestruction	: bool; 	default isScheduledForDestruction = false;
	
	event OnProjectileShot( targetCurrentPosition : Vector, optional target : CNode )
	{
		super.OnProjectileShot(targetCurrentPosition,target);
		if ( !IsNameValid(activeTrail) )
		{
			ActivateTrail( defaultTrail );
			
			this.SoundEvent( "cmb_arrow_swoosh" );
		}
	}
	
	event OnRangeReached()
	{
		StopAllEffects();
		
		if( !isScheduledForDestruction )
		{
			AddTimer( 'TimeDestroy', 2, false );
			isScheduledForDestruction = true;
		}
	}
	
	
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		
		var actorVictim	: CActor;
		var casterPos 	: Vector;
		var parryInfo 	: SParryInfo;
		var arrowHitPos : Vector;
		var bounce		: bool;
		var abs 		: array<name>;
		var isRolling	: bool;
		var template 	: CEntityTemplate;
		
		if ( yrdenAlternate )
		{
			return true;
		}
		
		SetShouldBeAttachedToVictim( true );
		
		if ( !isActive )
		{
			return true;
		}
		
		if(collidingComponent)
			victim = (CGameplayEntity)collidingComponent.GetEntity();
		
		if ( collidingComponent || !hitCollisionsGroups.Contains( 'Water' ) )
			RemoveTimer( 'CheckIfInfWaterLoop' );
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
		if( collidingComponent && !hitCollisionsGroups.Contains( 'Static' ) )
		{	
			if ( !victim || collidedEntities.Contains(victim) || victim == caster )
				return false;
			
			actorVictim = (CActor)victim;
			
			if ( hitCollisionsGroups.Contains( 'Ragdoll' ) && actorVictim )
			{
				boneName = ((CMovingPhysicalAgentComponent)actorVictim.GetMovingAgentComponent()).GetRagdollBoneName(actorIndex);
			}
			
		}
		else if ( hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' ) )
		{
			StopProjectile();
			isActive = false;
			StopActiveTrail();
			
			
			AddTimer('TimeDestroy', 20, false);
			isScheduledForDestruction = true;
			
			
			arrowHitPos = pos + RotForward( this.GetWorldRotation() ) * 0.5f; 
			Teleport( arrowHitPos );
			
			this.SoundEvent("cmb_arrow_impact_dirt");
			return true;
		}
		else if ( hitCollisionsGroups.Contains( 'Water' ) )
		{
			if ( isUnderwater )
			{
				return false;
			}
			
			
			SoundEvent("cmb_arrow_impact_water");
			
			CheckIfInfWater();
			return true;
		}	
		else 
		{
			return false;
		}
		
		if ( !actorVictim ) 
		{
			StopProjectile();
			isActive = false;
			StopActiveTrail();
			
			AddTimer('TimeDestroy', 20, false);
			isScheduledForDestruction = true;
			
			
			ProcessDamageAction(victim, pos, boneName);
			
			this.SoundEvent("cmb_arrow_impact_wood");
			
			return true;
		}		
		else if (victim == thePlayer)
		{
			bounce = false;
			
			if ( thePlayer.IsCurrentlyDodging() && thePlayer.GetBehaviorVariable( 'isRolling' ) == 1.f )
			{
				isRolling = true;
			}
			else if(thePlayer.HasAbility( 'Glyphword 1 _Stats', true ))
			{
				
				thePlayer.PlayEffect('glyphword_reflection');
				
				
				template = (CEntityTemplate)LoadResource('glyphword_1');
				theGame.CreateEntity(template, GetWorldPosition(), thePlayer.GetWorldRotation(), , , true);
			
				if ( thePlayer.CheckCounterSpamming( (CActor)caster ) && thePlayer.GetSkillLevel(S_Sword_s10) > 1 )
				{
					casterPos = caster.GetWorldPosition();
					casterPos.Z += 1.5;
					this.Init(thePlayer);
					if ( thePlayer.GetSkillLevel(S_Sword_s10) == 3 )
					{
						this.projDMG *= 1 + CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s10, 'damage_increase', false, true) );
					}
					this.ShootProjectileAtPosition(2,projSpeed*0.7,casterPos);
					ActivateTrail('arrow_trail_red');
					return true;
				}
				else
				{
					this.SoundEvent( "cmb_arrow_bounce" );
					bounce = true;
				}
			}
			else if(thePlayer.CanParryAttack() && thePlayer.CanUseSkill(S_Sword_s10))
			{			
				
				parryInfo = thePlayer.ProcessParryInfo(((CActor)caster),((CActor)victim),AST_Jab,ASD_NotSet,'attack_light',((CActor)caster).GetInventory().GetItemFromSlot('l_weapon'), true);
				if ( thePlayer.PerformParryCheck(parryInfo) )
				{
					if ( thePlayer.CheckCounterSpamming( (CActor)caster ) && thePlayer.GetSkillLevel(S_Sword_s10) > 1 )
					{
						casterPos = caster.GetWorldPosition();
						casterPos.Z += 1.5;
						this.Init(thePlayer);
						if ( thePlayer.GetSkillLevel(S_Sword_s10) == 3 )
						{
							this.projDMG *= 1 + CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s10, 'damage_increase', false, true) );
						}
						this.ShootProjectileAtPosition(2,projSpeed*0.7,casterPos);
						ActivateTrail('arrow_trail_red');
						isBouncedArrow = true;
						return true;
					}
					else
					{
						bounce = true;
					}
				}
			}
			
			
			if(!bounce)
			{
				abs = thePlayer.GetAbilities(true);				
				bounce = abs.Contains(theGame.params.BOUNCE_ARROWS_ABILITY);
				
				if(bounce)
				{
					FactsAdd("sq108_arrow_deflected");
					thePlayer.PlayEffect( 'bolt_bump' );
				}
			}
			
			if(bounce)
			{	
				this.bounceOfVelocityPreserve = 0.7;
				this.BounceOff(normal,pos);
				this.Init(thePlayer);
				ActivateTrail('arrow_trail_orange');
				return false;
			}
			else if ( !isRolling )
			{
				if( actorVictim.IsAlive() )
					ProcessDamageAction( actorVictim, pos, boneName );
				
				this.SoundEvent( "cmb_arrow_impact_body" );
				
				if( IsNameValid( boneName ) )
					AttachArrowToRagdoll( actorVictim, pos, boneName );
				else
				{
					StopProjectile();
					StopActiveTrail();
					isActive = false;
					SmartDestroy();
				}
			}
		}
		else if ( (CNewNPC)victim && ((CNewNPC)victim).IsShielded(caster) ) 
		{
			((CNewNPC)victim).SignalGameplayEvent('PerformAdditiveParry');
			
			this.SoundEvent("cmb_arrow_impact_wood");
			
			AttachArrowToShield(actorVictim, pos);
		}
		else
		{
			if(actorVictim.IsAlive())
			{
				if ( actorVictim.HasAbility( 'BounceBoltsWildhunt' ))
				{
					this.bounceOfVelocityPreserve = 0.1;
					this.BounceOff(normal, pos);
					this.Init(actorVictim);
					this.PlayEffect('sparks');
					this.SoundEvent("cmb_arrow_impact_metal");
					ActivateTrail('arrow_trail_orange');
					return false;
				}
				else
				{
					ProcessDamageAction(actorVictim, pos, boneName);
				}
			}
			else if ( actorVictim.IsInAgony() )
			{
				
				actorVictim.SignalGameplayEvent('AbandonAgony');
				
				actorVictim.SetKinematic(false);
			}
			
			this.SoundEvent("cmb_arrow_impact_body");
			
			if(IsNameValid(boneName))
				AttachArrowToRagdoll(actorVictim,pos,boneName);
			else
			{
				StopProjectile();
				StopActiveTrail();
				isActive = false;
				SmartDestroy();
			}
		}
		return true;
	}
	
	
	
	event OnAardHit( sign : W3AardProjectile )
	{
		var rigidMesh : CMeshComponent;
		
		super.OnAardHit(sign);
		
		StopProjectile();
		
		rigidMesh = (CMeshComponent)this.GetComponentByClassName('CRigidMeshComponent');
		
		if ( rigidMesh )
		{
			rigidMesh.SetEnabled( true );
		}
		else
		{
			this.bounceOfVelocityPreserve = 0.7;
			this.BounceOff(VecRand2D(),this.GetWorldPosition());
			this.Init(thePlayer);
		}
	}
	
	event OnFireHit(source : CGameplayEntity)
	{
		if ( !isUnderwater && isActive )
		{
			super.OnFireHit(source);
			ToggleFire(true);
		}
	}
	
	
	
	public function ToggleFire( toggle : bool )
	{
		if( !isOnFire && toggle )
		{
			isOnFire = true;
			ActivateTrail('arrow_trail_fire');
			this.PlayEffect('fire');
		}
		else if( isOnFire && !toggle )
		{
			isOnFire = false;
			ActivateTrail(defaultTrail);
			this.StopEffect('fire');
		}
	}
	
	function ToggleUnderwater( toggle : bool )
	{
		if( !isUnderwater && toggle )
		{
			isUnderwater = true;
		}
		else if( isUnderwater && !toggle )
		{
			isUnderwater = false;
			
			
			this.isActive = false;
			this.DestroyAfter(0.5);
		}
	}
	
	function SmartDestroy()
	{
		var i : int;
		var compList : array<CComponent>;
		compList = GetComponentsByClassName('CDrawableComponent');
		
		for ( i=0; i<compList.Size(); i+=1 )
		{
			((CDrawableComponent)compList[i]).SetVisible(false);
		}
		if( !isScheduledForDestruction )
		{
			AddTimer('TimeDestroy', 3, false);
			isScheduledForDestruction = true;
		}
	}
	
	
	
	function ActivateTrail( trailName : name )
	{
		if ( trailName != activeTrail )
		{
			if ( activeTrail )
				StopEffect( activeTrail );
			
			PlayEffect( trailName );
			activeTrail = trailName;
		}
	}
	
	function StopActiveTrail()
	{
		if (activeTrail)
		{
			StopEffect( activeTrail );
			activeTrail = '';
		}
	}
	
	timer function CheckIfInfWaterLoop( timeDelta : float , id : int)
	{
		if ( CheckIfInfWater() )
			RemoveTimer( 'CheckIfInfWaterLoop' );
	}

	protected function CheckIfInfWater() : bool
	{
		var entityPos	: Vector;
		var waterLevel	: float;
		
		entityPos = this.GetWorldPosition();
		waterLevel = theGame.GetWorld().GetWaterLevel( entityPos ); 
		
		if ( isUnderwater )
		{
			if ( waterLevel < entityPos.Z )
			{
				ToggleUnderwater( false );
				ActivateTrail(defaultTrail);
				projAngle = 5.f;
				return true;
			}
		}
		else
		{
			if ( waterLevel > entityPos.Z )
			{
				ToggleUnderwater( true );
				ToggleFire(false);
				ActivateTrail(underwaterTrail);
				projAngle = 2.f;
				return true;
			}		
		}
		
		return false;
	}

	public function ThrowProjectile( targetPosIn : Vector )
	{	
		CheckIfInfWater();
		AddTimer( 'CheckIfInfWaterLoop', 0.05, true );
	}
	
	
	
	function AttachArrowToShield( victim : CActor, pos : Vector )
	{
		var bones 		: array<name>;
		var res 		: bool;
		var inv 		: CInventoryComponent;
		var shield		: CEntity;
		
		StopProjectile();
		StopActiveTrail();
		isActive = false;
		
		inv = victim.GetInventory();
		
		shield = inv.GetItemEntityUnsafe(inv.GetItemFromSlot('l_weapon'));
		this.CreateAttachment( shield );
		
		this.CreateAttachmentAtBoneWS(shield, 'Root', pos, this.GetWorldRotation());
	}
	
	function AttachArrowToRagdoll(victim : CActor, pos : Vector, boneName : name)
	{
		var bones 		: array<name>;
		var res 		: bool;
		var arrowHitPos : Vector;
		var timerAmount : float;
		
		StopProjectile();
		StopActiveTrail();
		isActive = false;
		
		bones.PushBack( 'head' );
		bones.PushBack( 'hroll' );
		bones.PushBack( 'neck' );
		
		if ( ( victim == thePlayer && bones.Contains(boneName) ) || ((CNewNPC)victim).IsHorse() ) 
		{
			SmartDestroy();
		}
		else
		{
			arrowHitPos = pos + RotForward( this.GetWorldRotation() ) * 0.3f; 
			
			if ( boneName )
			{
				res = this.CreateAttachmentAtBoneWS(victim, boneName, arrowHitPos, this.GetWorldRotation());
			}
			else
			{
				res = this.CreateAttachmentAtBoneWS(victim, 'torso3', arrowHitPos, this.GetWorldRotation());
			}
			
			if ( res )
			{
				if( victim == thePlayer && !GetShouldBeAttachedToVictim() )
					timerAmount = 0.01;
				else if( victim == thePlayer )
					timerAmount = 3;
				else
					timerAmount = 20;
				
				AddTimer('TimeDestroy', timerAmount, false);
				isScheduledForDestruction = true;
				
			}
			else
				SmartDestroy();
		}
	}
	
	
	
	protected function ProcessDamageAction(victim : CGameplayEntity, pos : Vector, boneName : name)
	{
		var action : W3DamageAction;
		var victimTags, attackerTags : array<name>;
		var none 		: SAbilityAttributeValue;
		
		action = new W3DamageAction in this;
		action.Initialize((CGameplayEntity)caster,victim,this,caster.GetName(),EHRT_Light,CPS_AttackPower,false,true,false,false);				
		if( isOnFire )		
		{
			action.AddEffectInfo(EET_Burning);
			action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, projDMG );
			action.AddDamage(theGame.params.DAMAGE_NAME_SILVER, projSilverDMG );
		}
		else
		{
			action.AddDamage(theGame.params.DAMAGE_NAME_PIERCING, projDMG );
			action.AddDamage(theGame.params.DAMAGE_NAME_SILVER, projSilverDMG );
		}
			
		if( this.projEfect != EET_Undefined )
		{
			action.AddEffectInfo(this.projEfect);
		}
		
		if ( ((CNewNPC)victim) )
		{
			if ( boneName == 'head' || boneName == 'neck' || boneName == 'hroll' || ( boneName == 'pelvis' && ((CNewNPC)victim).IsHuman() ) )
				action.SetHeadShot();
		}
		
		if(isBouncedArrow)
		{
			action.SetBouncedArrow();
		}
		
		theGame.damageMgr.ProcessAction( action );
		collidedEntities.PushBack(victim);
		delete action;
		
		
		victimTags = victim.GetTags();
		
		attackerTags = caster.GetTags();
		
		AddHitFacts( victimTags, attackerTags, "_arrow_hit" );
	}
	
	public function SetShouldBeAttachedToVictim( val : bool )	{ shouldBeAttachedToVictim = val; }
	public function GetShouldBeAttachedToVictim() : bool		{ return shouldBeAttachedToVictim; }
}
