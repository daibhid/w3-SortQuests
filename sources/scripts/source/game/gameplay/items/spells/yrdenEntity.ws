/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




struct SYrdenEffects
{
	editable var castEffect		: name;
	editable var placeEffect	: name;
	editable var shootEffect	: name;
	editable var activateEffect : name;
}

statemachine class W3YrdenEntity extends W3SignEntity
{
	editable var effects		: array< SYrdenEffects >;
	editable var projTemplate	: CEntityTemplate;
	editable var projDestroyFxEntTemplate : CEntityTemplate;

	protected var ActorsInArea 	: array< CActor >;
	protected var flyersInArea	: array< CNewNPC >;
	
	protected var trapDuration	: float;
	protected var charges		: int;
	
	public var notFromPlayerCast : bool;
	
	default skillEnum = S_Magic_3;

	public function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool ) : bool
	{
		notFromPlayerCast = notPlayerCast;
		
		return super.Init(inOwner, prevInstance, skipCastingAnimation, notPlayerCast);
	}
		
	public function GetSignType() : ESignType
	{
		return ST_Yrden;
	}
		
	public function SkillUnequipped(skill : ESkill)
	{
		var i : int;
	
		super.SkillUnequipped(skill);
		
		if(skill == S_Magic_s11)
		{
			for(i=0; i<ActorsInArea.Size(); i+=1)
				ActorsInArea[i].RemoveBuff( EET_YrdenHealthDrain );
		}
	}
	
	public function SkillEquipped(skill : ESkill)
	{
		var i : int;
		var params : SCustomEffectParams;
	
		super.SkillEquipped(skill);
	
		if(skill == S_Magic_s11)
		{
			params.effectType = EET_YrdenHealthDrain;
			params.creator = owner.GetActor();
			params.sourceName = "yrden_mode0";
			params.isSignEffect = true;
			
			for(i=0; i<ActorsInArea.Size(); i+=1)
				ActorsInArea[i].AddEffectCustom(params);
		}
	}

	event OnProcessSignEvent( eventName : name )
	{
		if ( eventName == 'yrden_draw_ready' )
		{
			PlayEffect( 'yrden_cast' );
		}
		else
		{
			return super.OnProcessSignEvent(eventName);
		}
		
		return true;
	}
	
	public final function ClearActorsInArea()
	{
		var i : int;
		
		for(i=0; i<ActorsInArea.Size(); i+=1)
			ActorsInArea[i].SignalGameplayEventParamObject('LeavesYrden', this );
		
		ActorsInArea.Clear();
		flyersInArea.Clear();
	}
	
	protected function GetSignStats()
	{
		var chargesAtt, trapDurationAtt : SAbilityAttributeValue;
	
		super.GetSignStats();
		
		chargesAtt = owner.GetSkillAttributeValue(skillEnum, 'charge_count', false, true);
		trapDurationAtt = owner.GetSkillAttributeValue(skillEnum, 'trap_duration', false, true);
		
		trapDurationAtt += owner.GetActor().GetTotalSignSpellPower(skillEnum);
		trapDurationAtt.valueMultiplicative -= 1;	
		
		charges = (int)CalculateAttributeValue(chargesAtt);
		trapDuration = CalculateAttributeValue(trapDurationAtt);
	}
	
	event OnStarted()
	{
		var player : CR4Player;
		
		Attach(true, true);
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
		
		PlayEffect( 'cast_yrden' );
		
		if ( owner.ChangeAspect( this, S_Magic_s03 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'YrdenChanneled' );
		}
		else
		{
			GotoState( 'YrdenCast' );
		}
	}
	
	
	protected latent function Place(trapPos : Vector)
	{
		var trapPosTest, trapPosResult, collisionNormal : Vector;
		var rot : EulerAngles;
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		witcher.yrdenEntities.PushBack(this);
		
		DisablePreviousYrdens();		
		
		
		Detach();
		
		
		SleepOneFrame();
		
		
		trapPosTest = trapPos;
		trapPosTest.Z -= 0.5;		
		rot = GetWorldRotation();
		rot.Pitch = 0;
		rot.Roll = 0;
		
		if(theGame.GetWorld().StaticTrace(trapPos, trapPosTest, trapPosResult, collisionNormal))
		{
			trapPosResult.Z += 0.1;	
			TeleportWithRotation ( trapPosResult, rot );
		}
		else
		{
			TeleportWithRotation ( trapPos, rot );
		}
		
		
		SleepOneFrame();
		
		AddTimer('TimedCanceled', trapDuration, , , , true);
		
		if(!notFromPlayerCast)
			owner.GetActor().OnSignCastPerformed(ST_Yrden, fireMode);
	}
	
	private final function DisablePreviousYrdens()
	{
		var maxCount, i, size, currCount : int;
		var isAlternate : bool;
		var witcher : W3PlayerWitcher;
		
		
		isAlternate = IsAlternateCast();
		witcher = GetWitcherPlayer();
		size = witcher.yrdenEntities.Size();
		
		
		maxCount = 1;
		currCount = 0;
		
		if(!isAlternate && owner.CanUseSkill(S_Magic_s10) && owner.GetSkillLevel(S_Magic_s10) >= 2)
		{
			maxCount += 1;
		}
		
		for(i=size-1; i>=0; i-=1)
		{
			
			if(!witcher.yrdenEntities[i])
			{
				witcher.yrdenEntities.Erase(i);		
				continue;
			}
			
			if(witcher.yrdenEntities[i].IsAlternateCast() == isAlternate)
			{
				currCount += 1;
				
				
				if(currCount > maxCount)
				{
					witcher.yrdenEntities[i].OnSignAborted(true);
				}
			}
		}
	}
	
	timer function TimedCanceled( delta : float , id : int)
	{
		var i : int;
		var areas : array<CComponent>;
		
		super.CleanUp();
		StopAllEffects();
		
		
		areas = GetComponentsByClassName('CTriggerAreaComponent');
		for(i=0; i<areas.Size(); i+=1)
			areas[i].SetEnabled(false);
		
		for(i=0; i<ActorsInArea.Size(); i+=1)
		{
			ActorsInArea[i].BlockAbility('Flying', false);
		}
		ClearActorsInArea();
		DestroyAfter(3);
	}
	
	
	protected function NotifyGameplayEntitiesInArea( componentName : CName )
	{
		var entities : array<CGameplayEntity>;
		var triggerAreaComp : CTriggerAreaComponent;
		var i : int;
		var ownerActor : CActor;
		
		ownerActor = owner.GetActor();
		triggerAreaComp = (CTriggerAreaComponent)this.GetComponent( componentName );
		triggerAreaComp.GetGameplayEntitiesInArea( entities, 6.0 );
		
		for ( i=0 ; i < entities.Size() ; i+=1 )
		{
			if( !((CActor)entities[i]) )
				entities[i].OnYrdenHit( ownerActor );
		}
	}
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, selected : bool )
	{
	}
}

state YrdenCast in W3YrdenEntity extends NormalCast
{
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			parent.CleanUp();	
			parent.StopEffect( 'yrden_cast' );			
			parent.GotoState( 'YrdenSlowdown' );
		}
	}
}

state YrdenChanneled in W3YrdenEntity extends Channeling
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		caster.OnDelayOrientationChange();
		caster.GetActor().PauseEffects( EET_AutoStaminaRegen, 'SignCast' );
		ChannelYrden();
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			parent.CleanUp();	
		}
		
		parent.StopEffect( 'yrden_cast' );
		
		caster.GetActor().ResumeEffects( EET_AutoStaminaRegen, 'SignCast' );
		
		parent.GotoState( 'YrdenShock' );
	}
	
	event OnEnded(optional isEnd : bool)
	{
	}
	
	event OnSignAborted( optional force : bool )
	{
		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
		}
		
		parent.AddTimer('TimedCanceled', 0, , , , true);
		
		super.OnSignAborted( force );
	}		
	
	entry function ChannelYrden()
	{
		while( Update() )
		{
			Sleep( 0.0001f );
		}
		
		OnSignAborted();
	}
}


state YrdenShock in W3YrdenEntity extends Active
{
	private var usedShockAreaName : name;
	
	event OnEnterState( prevStateName : name )
	{
		var skillLevel : int;
		
		super.OnEnterState( prevStateName );
		
		skillLevel = caster.GetSkillLevel(parent.skillEnum);
		
		if(skillLevel == 1)
			usedShockAreaName = 'Shock_lvl_1';
		else if(skillLevel == 2)
			usedShockAreaName = 'Shock_lvl_2';
		else if(skillLevel == 3)
			usedShockAreaName = 'Shock_lvl_3';
			
		parent.GetComponent(usedShockAreaName).SetEnabled( true );
		
		ActivateShock();
		parent.NotifyGameplayEntitiesInArea( usedShockAreaName );
	}
	
	event OnLeaveState( nextStateName : name )
	{
		parent.GetComponent(usedShockAreaName).SetEnabled( false );
		parent.ClearActorsInArea();
	}
	
	entry function ActivateShock()
	{
		var i, size : int;
		var target : CActor;
		var hitEntity : CEntity;
		var shot : bool;
			
		parent.Place(parent.GetWorldPosition());
		
		parent.PlayEffect( parent.effects[parent.fireMode].placeEffect );
		parent.PlayEffect( parent.effects[parent.fireMode].castEffect );
		
		
		Sleep(1.f);
		
		while( parent.ActorsInArea.Size() == 0 )
		{
			
			Sleep( 0.2f );
		}
		
		while( parent.charges > 0 )
		{
			hitEntity = NULL;
			shot = false;
			size = parent.ActorsInArea.Size();
			if ( size > 0 )
			{
				do
				{
					target = parent.ActorsInArea[RandRange(size)];
					if(target.GetHealth() <= 0.f || target.IsInAgony() )
					{
						parent.ActorsInArea.Remove(target);
						size -= 1;
						target = NULL;
					}
				}while(size > 0 && !target)
				
				if(target && target.GetGameplayVisibility())
				{
					shot = true;
					hitEntity = ShootTarget(target, true, 0.2f, false);
				}
			}
			
			if(hitEntity)
				Sleep(2.f);		
			else if(shot)
				Sleep(0.1f);	
			else
				Sleep(1.f);		
		}
		
		parent.GotoState( 'Discharged' );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var target : CNewNPC;		
		var projectile : CProjectileTrajectory;		
		
		target = (CNewNPC)(activator.GetEntity());
		if ( parent.charges && target && target.GetHealth() > 0.f && target.GetAttitude( caster.GetActor() ) == AIA_Hostile && !parent.ActorsInArea.Contains(target) )
		{
			if( parent.ActorsInArea.Size() == 0 )
			{
				parent.PlayEffect( parent.effects[parent.fireMode].activateEffect );
			}
			
			parent.ActorsInArea.PushBack( target );
			
			target.OnYrdenHit( caster.GetActor() );
			
			target.SignalGameplayEventParamObject('EntersYrden', parent );
		}		
		else if(parent.projDestroyFxEntTemplate)
		{
			projectile = (CProjectileTrajectory)activator.GetEntity();
			
			if(projectile && !((W3SignProjectile)projectile) && IsRequiredAttitudeBetween(caster.GetActor(), projectile.caster, true, true, false))
			{
				if(projectile.IsStopped())
				{
					
					projectile.SetIsInYrdenAlternateRange(parent);
				}
				else
				{			
					ShootDownProjectile(projectile);
				}
			}
		}
	}
	
	public final function ShootDownProjectile(projectile : CProjectileTrajectory)
	{
		var hitEntity, fxEntity : CEntity;
		
		hitEntity = ShootTarget(projectile, false, 0.1f, true);
					
		
		if(hitEntity == projectile || !hitEntity)
		{
			
			fxEntity = theGame.CreateEntity( parent.projDestroyFxEntTemplate, projectile.GetWorldPosition() );
			
			
			
			if(!hitEntity)
			{
				parent.PlayEffect( parent.effects[1].shootEffect );		
				parent.PlayEffect( parent.effects[1].shootEffect, fxEntity );
			}
			
			projectile.StopProjectile();
			projectile.Destroy();			
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var target : CNewNPC;
		var projectile : CProjectileTrajectory;
		
		target = (CNewNPC)(activator.GetEntity());
		
		if ( target && parent.charges && target.GetAttitude( thePlayer ) == AIA_Hostile )
		{
			parent.ActorsInArea.Erase( parent.ActorsInArea.FindFirst( target ) );
			target.SignalGameplayEventParamObject('LeavesYrden', parent );
		}
		
		if ( parent.ActorsInArea.Size() <= 0 )
		{
			parent.StopEffect( parent.effects[parent.fireMode].activateEffect );
		}
	}
	
	var traceFrom, traceTo : Vector;
	private function ShootTarget( targetNode : CNode, useTargetsPositionCorrection : bool, extraRayCastLengthPerc : float, useProjectileGroups : bool ) : CEntity
	{
		var results : array<SRaycastHitResult>;
		var i, ind : int;
		var min : float;
		var collisionGroupsNames : array<name>;
		var entity : CEntity;
		var targetActor : CActor;
		var targetPos : Vector;
		var physTest : bool;
		
		traceFrom = virtual_parent.GetWorldPosition();
		traceFrom.Z += 1.f;
		
		targetPos = targetNode.GetWorldPosition();
		traceTo = targetPos;
		if(useTargetsPositionCorrection)
			traceTo.Z += 1.f;
		
		traceTo = traceFrom + (traceTo - traceFrom) * (1.f + extraRayCastLengthPerc);
		
		collisionGroupsNames.PushBack( 'RigidBody' );
		collisionGroupsNames.PushBack( 'Static' );
		collisionGroupsNames.PushBack( 'Debris' );	
		collisionGroupsNames.PushBack( 'Destructible' );	
		collisionGroupsNames.PushBack( 'Terrain' );
		collisionGroupsNames.PushBack( 'Phantom' );
		collisionGroupsNames.PushBack( 'Water' );
		collisionGroupsNames.PushBack( 'Boat' );		
		collisionGroupsNames.PushBack( 'Door' );
		collisionGroupsNames.PushBack( 'Platforms' );
		
		if(useProjectileGroups)
		{
			collisionGroupsNames.PushBack( 'Projectile' );
		}
		else
		{			
			collisionGroupsNames.PushBack( 'Character' );			
		}
		
		physTest = theGame.GetWorld().GetTraceManager().RayCastSync(traceFrom, traceTo, results, collisionGroupsNames);

		if ( !physTest || results.Size() == 0 )
			FindActorsAtLine( traceFrom, traceTo, 0.05f, results, collisionGroupsNames );
		
		if ( results.Size() > 0 )
		{
			
			while(results.Size() > 0)
			{
				
				min = results[0].distance;
				ind = 0;
				
				for(i=1; i<results.Size(); i+=1)
				{
					if(results[i].distance < min)
					{
						min = results[i].distance;
						ind = i;
					}
				}
				
				
				if(results[ind].component)
				{
					entity = results[ind].component.GetEntity();
					targetActor = (CActor)entity;
					
					
					if(targetActor && IsRequiredAttitudeBetween(targetActor, caster.GetActor(), false, false, true))
						return NULL;
					
					
					if( (targetActor && targetActor.GetHealth() > 0.f && targetActor.IsAlive()) || (!targetActor && entity) )
					{
						
						YrdenTrapHitEnemy(targetActor, results[ind].position);						
						return entity;
					}
					else if(targetActor)
					{
						
						results.EraseFast(ind);
					}
				}
				else
				{
					break;
				}
			}
		}
		
		return NULL;
	}
	
	private final function YrdenTrapHitEnemy(entity : CEntity, hitPosition : Vector)
	{
		var component : CComponent;
		var targetActor, casterActor : CActor;
		var action : W3DamageAction;
		var player : W3PlayerWitcher;
		var skillType : ESkill;
		var skillLevel, i : int;
		var damageBonusFlat : float;		
		var damages : array<SRawDamage>;
		var glyphwordY : W3YrdenEntity;
		
		
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
		parent.PlayEffect( parent.effects[parent.fireMode].shootEffect );
		parent.PlayEffect( parent.effects[parent.fireMode].castEffect );
			
		targetActor = (CActor)entity;
		if(targetActor)
		{
			component = targetActor.GetComponent('torso3effect');		
			if ( component )
			{
				parent.PlayEffect( parent.effects[parent.fireMode].shootEffect, component );
			}
		}
		
		if(!targetActor || !component)
		{
			parent.PlayEffect( parent.effects[parent.fireMode].shootEffect, entity );
		}

		
		
			parent.charges -= 1;
		
		
		casterActor = caster.GetActor();
		if ( casterActor && (CGameplayEntity)entity)
		{
			
			action =  new W3DamageAction in theGame.damageMgr;
			player = caster.GetPlayer();
			skillType = virtual_parent.GetSkill();
			skillLevel = player.GetSkillLevel(skillType);
			
			
			action.Initialize( casterActor, (CGameplayEntity)entity, this, casterActor.GetName()+"_sign", EHRT_Light, CPS_SpellPower, false, false, true, false, 'yrden_shock', 'yrden_shock', 'yrden_shock', 'yrden_shock');
			virtual_parent.InitSignDataForDamageAction(action);
			action.hitLocation = hitPosition;
			action.SetCanPlayHitParticle(true);
			
			
			if(player && skillLevel > 1)
			{
				action.GetDTs(damages);
				damageBonusFlat = CalculateAttributeValue(player.GetSkillAttributeValue(skillType, 'damage_bonus_flat_after_1', false, true));
				action.ClearDamage();
				
				for(i=0; i<damages.Size(); i+=1)
				{
					damages[i].dmgVal += damageBonusFlat * (skillLevel - 1);
					action.AddDamage(damages[i].dmgType, damages[i].dmgVal);
				}
			}
			
			
			theGame.damageMgr.ProcessAction( action );
		}
		else
		{
			entity.PlayEffect( 'yrden_shock' );
		}
		
		if(casterActor.HasAbility('Glyphword 15 _Stats', true))
		{
			glyphwordY = (W3YrdenEntity)theGame.CreateEntity(GetWitcherPlayer().GetSignTemplate(ST_Yrden), entity.GetWorldPosition(), entity.GetWorldRotation() );
			glyphwordY.Init(caster, parent, true, true);
			glyphwordY.CacheActionBuffsFromSkill();
			glyphwordY.GotoState( 'YrdenSlowdown' );
		}
	}
	
	event OnThrowing()
	{
		parent.CleanUp();	
	}
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags, selected : bool )
	{
		frame.DrawLine(traceFrom, traceTo, Color(255, 255, 0));
	}
}

state YrdenSlowdown in W3YrdenEntity extends Active
{
	event OnEnterState( prevStateName : name )
	{
		var player : CR4Player;
		var cost, stamina : float;
		
		super.OnEnterState( prevStateName );
		
		parent.GetComponent( 'Slowdown' ).SetEnabled( true );
		parent.PlayEffect( 'yrden_slowdown_sound' );
		
		ActivateSlowdown();
		
		if(!parent.notFromPlayerCast)
		{
			player = caster.GetPlayer();
			if(player == caster.GetActor() && player && player.CanUseSkill(S_Perk_09))
			{
				cost = player.GetStaminaActionCost(ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0);
				stamina = player.GetStat(BCS_Stamina, true);
				
				if(cost > stamina)
					player.DrainFocus(1);
				else
					caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			}
			else
				caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
	}
	
	event OnLeaveState( nextStateName : name )
	{
		CleanUp();
		parent.GetComponent('Slowdown').SetEnabled( false );
		parent.ClearActorsInArea();
	}
	
	private function CleanUp()
	{
		var i, size : int;
		
		size = parent.ActorsInArea.Size();
		for( i = 0; i < size; i += 1 )
		{
			parent.ActorsInArea[i].RemoveBuff( EET_YrdenHealthDrain );
		}
	}
	
	event OnThrowing()
	{
		parent.CleanUp();	
	}
	
	event OnSignAborted( force : bool )
	{
		if( force )
			CleanUp();
		
		parent.AddTimer('TimedCanceled', 0, , , , true);
		
		super.OnSignAborted( force );
	}
	
	entry function ActivateSlowdown()
	{
		var obj : CEntity;
		var pos : Vector;
		
		obj = (CEntity)parent;
		pos = obj.GetWorldPosition();
		parent.Place(pos);
		
		CreateTrap();
		
		theGame.GetBehTreeReactionManager().CreateReactionEvent( parent, 'YrdenCreated', parent.trapDuration, 30, 0.1f, 999, true );
		parent.NotifyGameplayEntitiesInArea( 'Slowdown' );
		YrdenSlowdown_Loop();
	}
	
	private function CreateTrap()
	{
		var components : array<CComponent>;
		var i, size : int;
		var outZDiff : float;
		var currPosition : Vector;
		
		components = parent.GetComponentsByClassName( 'CEffectDummyComponent' );
		size = components.Size();
		
		for ( i = 0 ; i < size ; i+=1 )
		{		
			currPosition = components[i].GetLocalPosition();
			if ( Trace( components[i], outZDiff ) )
			{
				currPosition.Z += outZDiff;
			}
			currPosition.Z += 0.1f;
			components[i].SetPosition( currPosition );
			
			switch ( components[i].GetName() )
			{
				case "CEffectDummyComponent0": parent.PlayEffect( 'rune_00' , components[i] ); break;
				case "CEffectDummyComponent1": parent.PlayEffect( 'rune_01' , components[i] ); break;
				case "CEffectDummyComponent2": parent.PlayEffect( 'rune_02' , components[i] ); break;
				case "CEffectDummyComponent3": parent.PlayEffect( 'rune_03' , components[i] ); break;
				case "CEffectDummyComponent4": parent.PlayEffect( 'rune_04' , components[i] ); break;
				case "CEffectDummyComponent5": parent.PlayEffect( 'rune_05' , components[i] ); break;
				case "CEffectDummyComponent6": parent.PlayEffect( 'rune_06' , components[i] ); break;
				default: break;
			}
		}
	}
	
	private function Trace( comp: CComponent, out outZDiff : float ) : bool
	{
		var currPosition, outPosition, outNormal, tempPosition1, tempPosition2 : Vector;
		
		currPosition = comp.GetWorldPosition();
		
		tempPosition1 = currPosition;
		tempPosition1.Z -= 5;
		
		tempPosition2 = currPosition;
		tempPosition2.Z += 2;
		
		if ( theGame.GetWorld().StaticTrace( tempPosition2, tempPosition1, outPosition, outNormal ) )
		{
			outZDiff = outPosition.Z - currPosition.Z;
			return true;
		}
		
		return false;
	}
	
	entry function YrdenSlowdown_Loop()
	{
		var params, paramsDrain : SCustomEffectParams;
		var casterActor : CActor;
		var i : int;
		var min, max, scale, pts, prc : float;
		var casterPlayer : CR4Player;
		var npc : CNewNPC;
		
		casterActor = caster.GetActor();
		casterPlayer = caster.GetPlayer();
		
		
		min = CalculateAttributeValue(casterPlayer.GetSkillAttributeValue(S_Magic_3, 'min_slowdown', false, true));
		max = CalculateAttributeValue(casterPlayer.GetSkillAttributeValue(S_Magic_3, 'max_slowdown', false, true));

		params.effectType = parent.actionBuffs[0].effectType;
		params.creator = casterActor;
		params.sourceName = "yrden_mode0";
		params.isSignEffect = true;
		params.customPowerStatValue = casterActor.GetTotalSignSpellPower(virtual_parent.GetSkill());
		params.customAbilityName = parent.actionBuffs[0].effectAbilityName;
		params.duration = 0.1;	
		scale = params.customPowerStatValue.valueMultiplicative / 4;
		params.effectValue.valueAdditive = min + (max - min) * scale;
		params.effectValue.valueAdditive = ClampF( params.effectValue.valueAdditive, min, max );
		
		
		if(thePlayer.CanUseSkill(S_Magic_s11))
		{
			
			paramsDrain = params;
			paramsDrain.customAbilityName = '';
			paramsDrain.effectType = EET_YrdenHealthDrain;
		}
						
		while(true)
		{
			
			for(i=parent.flyersInArea.Size()-1; i>=0; i-=1)
			{
				npc = parent.flyersInArea[i];
				if(!npc.IsFlying())
				{
					parent.ActorsInArea.PushBack(npc);
					npc.BlockAbility('Flying', true);
					parent.flyersInArea.EraseFast(i);
				}
			}
			
			for(i=0; i<parent.ActorsInArea.Size(); i+=1)
			{			
				
				parent.ActorsInArea[i].GetResistValue(CDS_ShockRes, pts, prc);
				if(prc < 1)
					parent.ActorsInArea[i].AddEffectCustom(params);			
				
				
				if(thePlayer.CanUseSkill(S_Magic_s11))
				{
					parent.ActorsInArea[i].AddEffectCustom(paramsDrain);
				}
				
				
				parent.ActorsInArea[i].OnYrdenHit( casterActor );
			}
			
			SleepOneFrame();
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var target : CNewNPC;
		var casterActor : CActor;
		
		target = (CNewNPC)(activator.GetEntity());
		casterActor = caster.GetActor();
		if ( target && target.IsAlive() && target.GetAttitude( casterActor ) == AIA_Hostile && !parent.ActorsInArea.Contains(target))
		{
			if (!target.IsFlying())
			{
				
				if( parent.ActorsInArea.Size() == 0 )
				{
					parent.PlayEffect( parent.effects[parent.fireMode].activateEffect );
				}
				
				parent.ActorsInArea.PushBack( target );		
				target.SignalGameplayEventParamObject('EntersYrden', parent );
				target.BlockAbility('Flying', true);
			}
			else
			{
				parent.flyersInArea.PushBack(target);
			}
		}		
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var target : CNewNPC;
		var i : int;
		
		target = (CNewNPC)(activator.GetEntity());
		if( target )
		{
			i = parent.ActorsInArea.FindFirst( target );
			if( i >= 0 )
			{
				target.RemoveBuff( EET_YrdenHealthDrain );
				
				parent.ActorsInArea.Erase( i );
			}
			target.SignalGameplayEventParamObject('LeavesYrden', parent );
			target.BlockAbility('Flying', false);
			parent.flyersInArea.Remove(target);
		}
		
		if ( parent.ActorsInArea.Size() == 0 )
		{
			parent.StopEffect( parent.effects[parent.fireMode].activateEffect );
		}
	}
}

state Discharged in W3YrdenEntity extends Active
{
	event OnEnterState( prevStateName : name )
	{
		YrdenExpire();
	}
	
	entry function YrdenExpire()
	{
		Sleep( 1.f );
		OnSignAborted( true );
	}
}