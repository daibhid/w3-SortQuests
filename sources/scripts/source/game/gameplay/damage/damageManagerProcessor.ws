/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/





class W3DamageManagerProcessor extends CObject 
{
	
	private var playerAttacker				: CR4Player;				
	private var playerVictim				: CR4Player;				
	private var action						: W3DamageAction;
	private var attackAction				: W3Action_Attack;			
	private var weaponId					: SItemUniqueId;			
	private var actorVictim 				: CActor;					
	private var actorAttacker				: CActor;					
	private var dm 							: CDefinitionsManagerAccessor;
	private var attackerMonsterCategory		: EMonsterCategory;
	private var victimMonsterCategory		: EMonsterCategory;
	private var victimCanBeHitByFists		: bool;
	
	
	public function ProcessAction(act : W3DamageAction)
	{
		var wasAlive, validDamage, isFrozen, autoFinishersEnabled : bool;
		var focusDrain : float;
		var npc : CNewNPC;
		var buffs : array<EEffectType>;
		var arrStr : array<string>;
			
		wasAlive = act.victim.IsAlive();		
		npc = (CNewNPC)act.victim;
		
		
 		InitializeActionVars(act);
 		
 		
		
 		if(playerVictim && attackAction && attackAction.IsActionMelee() && !attackAction.CanBeParried() && attackAction.IsParried())
 		{
			action.GetEffectTypes(buffs);
			
			if(!buffs.Contains(EET_Knockdown) && !buffs.Contains(EET_HeavyKnockdown))
			{
				
				action.SetParryStagger();
				
				
				action.SetProcessBuffsIfNoDamage(true);
				
				
				action.AddEffectInfo(EET_LongStagger);
				
				
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				action.SetCanPlayHitParticle(false);
				
				
				action.RemoveBuffsByType(EET_Bleeding);
			}
 		}
 		
 		
 		if(actorAttacker && playerVictim && ((W3PlayerWitcher)playerVictim) && GetWitcherPlayer().IsAnyQuenActive())
			FactsAdd("player_had_quen");
		
		
		ProcessPreHitModifications();

		
		ProcessActionQuest(act);
		
		
		isFrozen = (actorVictim && actorVictim.HasBuff(EET_Frozen));
		
		
		validDamage = ProcessActionDamage();
		
		
		if(wasAlive && !action.victim.IsAlive())
		{
			arrStr.PushBack(action.victim.GetDisplayName());
			if(npc && npc.WillBeUnconscious())
			{
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_unconscious", , , arrStr), NULL, action.victim);
			}
			else if(action.attacker && action.attacker.GetDisplayName() != "")
			{
				arrStr.PushBack(action.attacker.GetDisplayName());
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_killed", , , arrStr), action.attacker, action.victim);
			}
			else
			{
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_dies", , , arrStr), NULL, action.victim);
			}
		}
		
		if( wasAlive && action.DealsAnyDamage() )
		{
			((CActor) action.attacker).SignalGameplayEventParamFloat(  'CausesDamage', MaxF( action.processedDmg.vitalityDamage, action.processedDmg.essenceDamage ) );
		}
		
		
		ProcessActionReaction(isFrozen, wasAlive);
		
		
		if(action.DealsAnyDamage() || action.ProcessBuffsIfNoDamage())
			ProcessActionBuffs();
		
		
		if(theGame.CanLog() && !validDamage && action.GetEffectsCount() == 0)
		{
			LogAssert(false, "W3DamageManagerProcessor.ProcessAction: action deals no damage and gives no buffs - investigate!");
			if ( theGame.CanLog() )
			{
				LogDMHits("*** Action has no valid damage and no valid buffs - investigate!", action);
			}
		}
		
		
		if(actorAttacker)
			actorAttacker.OnPocessActionPost(action);

		
		if(actorVictim == GetWitcherPlayer() && action.DealsAnyDamage() && !action.IsDoTDamage())
		{
			if(actorAttacker && attackAction)
			{
				if(actorAttacker.IsHeavyAttack( attackAction.GetAttackName() ))
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('heavy_attack_focus_drain'));
				else if(actorAttacker.IsSuperHeavyAttack( attackAction.GetAttackName() ))
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('super_heavy_attack_focus_drain'));
				else 
					focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')); 
			}
			else
			{
				
				focusDrain = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')); 
			}
			
			
			if ( GetWitcherPlayer().CanUseSkill(S_Sword_s16) )
				focusDrain *= 1 - (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, true) ) * thePlayer.GetSkillLevel(S_Sword_s16));
				
			thePlayer.DrainFocus(focusDrain);
		}
		
		
		if(actorAttacker == GetWitcherPlayer() && actorVictim && !actorVictim.IsAlive() && (action.IsActionMelee() || action.GetBuffSourceName() == "Kill"))
		{
			autoFinishersEnabled = theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled');
			
			
			
			
			if(!autoFinishersEnabled || !thePlayer.GetFinisherVictim())
			{
				if(thePlayer.HasAbility('Runeword 10 _Stats', true))
					GetWitcherPlayer().Runeword10Triggerred();
				if(thePlayer.HasAbility('Runeword 12 _Stats', true))
					GetWitcherPlayer().Runeword12Triggerred();
			}
		}
		
		
		if(action.EndsQuen() && actorVictim)
		{
			actorVictim.FinishQuen(false);			
		}

		
		if(actorVictim == thePlayer && attackAction && attackAction.IsActionMelee() && (ShouldProcessTutorial('TutorialDodge') || ShouldProcessTutorial('TutorialCounter') || ShouldProcessTutorial('TutorialParry')) )
		{
			if(attackAction.IsCountered())
			{
				theGame.GetTutorialSystem().IncreaseCounters();
			}
			else if(attackAction.IsParried())
			{
				theGame.GetTutorialSystem().IncreaseParries();
			}
			
			if(attackAction.CanBeDodged() && !attackAction.WasDodged())
			{
				GameplayFactsAdd("tut_failed_dodge", 1, 1);
				GameplayFactsAdd("tut_failed_roll", 1, 1);
			}
		}	
	}
	
	
	private final function InitializeActionVars(act : W3DamageAction)
	{
		var tmpName : name;
		var tmpBool	: bool;
	
		action 				= act;
		playerAttacker 		= (CR4Player)action.attacker;
		playerVictim		= (CR4Player)action.victim;
		attackAction 		= (W3Action_Attack)action;		
		actorVictim 		= (CActor)action.victim;
		actorAttacker		= (CActor)action.attacker;
		dm 					= theGame.GetDefinitionsManager();
		
		if(attackAction)
			weaponId 		= attackAction.GetWeaponId();
			
		theGame.GetMonsterParamsForActor(actorVictim, victimMonsterCategory, tmpName, tmpBool, tmpBool, victimCanBeHitByFists);
		
		if(actorAttacker)
			theGame.GetMonsterParamsForActor(actorAttacker, attackerMonsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
	}
	
	
	
	
	
	
	private function ProcessActionQuest(act : W3DamageAction)
	{
		var victimTags, attackerTags : array<name>;
		
		victimTags = action.victim.GetTags();
		
		if(action.attacker)
			attackerTags = action.attacker.GetTags();
		
		AddHitFacts( victimTags, attackerTags, "_weapon_hit" );
		
		
		if ((CGameplayEntity) action.victim) action.victim.OnWeaponHit(act);
	}
	
	
	
	
	
	private function ProcessActionDamage() : bool
	{
		var directDmgIndex, size, i : int;
		var dmgInfos : array< SRawDamage >;
		var immortalityMode : EActorImmortalityMode;
		var dmgValue : float;
		var anyDamageProcessed, fallingRaffard : bool;
		var victimHealthPercBeforeHit, frozenAdditionalDamage : float;		
		var powerMod : SAbilityAttributeValue;
		var witcher : W3PlayerWitcher;
		var canLog : bool;
		var immortalityChannels : array<EActorImmortalityChanel>;
		
		canLog = theGame.CanLog();
		
		
		action.SetAllProcessedDamageAs(0);
		size = action.GetDTs(dmgInfos);
		action.SetDealtFireDamage(false);		
		
		
		if(!actorVictim || (!actorVictim.UsesVitality() && !actorVictim.UsesEssence()) )
		{
			
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_FIRE && dmgInfos[i].dmgVal > 0)
				{
					action.victim.OnFireHit( (CGameplayEntity)action.causer );
					break;
				}
			}
			
			if ( !actorVictim.abilityManager )
				actorVictim.OnDeath(action);
			
			return false;
		}
		
		
		if(actorVictim.UsesVitality())
			victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Vitality);
		else
			victimHealthPercBeforeHit = actorVictim.GetStatPercents(BCS_Essence);
				
		
		ProcessDamageIncrease(dmgInfos);
					
		
		if ( canLog )
		{
			LogBeginning();
		}
			
		
		ProcessCriticalHitCheck();
		
		
		ProcessOnBeforeHitChecks();
		
		
		powerMod = GetAttackersPowerMod();

		
		anyDamageProcessed = false;
		directDmgIndex = -1;
		witcher = GetWitcherPlayer();
		for( i = 0; i < size; i += 1 )
		{
			
			if(dmgInfos[i].dmgVal == 0)
				continue;
			
			if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_DIRECT)
			{
				directDmgIndex = i;
				continue;
			}
			
			
			if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_POISON && witcher == actorVictim && witcher.HasBuff(EET_GoldenOriole) && witcher.GetPotionBuffLevel(EET_GoldenOriole) == 3)
			{
				
				witcher.GainStat(BCS_Vitality, dmgInfos[i].dmgVal);
				
				
				if ( canLog )
				{
					LogDMHits("", action);
					LogDMHits("*** Player absorbs poison damage from level 3 Golden Oriole potion: " + dmgInfos[i].dmgVal, action);
				}
				
				
				dmgInfos[i].dmgVal = 0;
				
				continue;
			}
			
			
			if ( canLog )
			{
				LogDMHits("", action);
				LogDMHits("*** Incoming " + NoTrailZeros(dmgInfos[i].dmgVal) + " " + dmgInfos[i].dmgType + " damage", action);
				if(action.IsDoTDamage())
					LogDMHits("DoT's current dt = " + NoTrailZeros(action.GetDoTdt()) + ", estimated dps = " + NoTrailZeros(dmgInfos[i].dmgVal / action.GetDoTdt()), action);
			}
			
			
			anyDamageProcessed = true;
				
			
			dmgValue = MaxF(0, CalculateDamage(dmgInfos[i], powerMod));
		
			
			if( DamageHitsEssence(  dmgInfos[i].dmgType ) )		action.processedDmg.essenceDamage  += dmgValue;
			if( DamageHitsVitality( dmgInfos[i].dmgType ) )		action.processedDmg.vitalityDamage += dmgValue;
			if( DamageHitsMorale(   dmgInfos[i].dmgType ) )		action.processedDmg.moraleDamage   += dmgValue;
			if( DamageHitsStamina(  dmgInfos[i].dmgType ) )		action.processedDmg.staminaDamage  += dmgValue;
		}
		
		if(size == 0 && canLog)
		{
			LogDMHits("*** There is no incoming damage set (probably only buffs).", action);
		}
		
		if ( canLog )
		{
			LogDMHits("", action);
			LogDMHits("Processing block, parry, immortality, signs and other GLOBAL damage reductions...", action);		
		}
		
		
		if(actorVictim)
			actorVictim.ReduceDamage(action);
				
		
		if(directDmgIndex != -1)
		{
			anyDamageProcessed = true;
			
			
			immortalityChannels = actorVictim.GetImmortalityModeChannels(AIM_Invulnerable);
			fallingRaffard = immortalityChannels.Size() == 1 && immortalityChannels.Contains(AIC_WhiteRaffardsPotion) && action.GetBuffSourceName() == "FallingDamage";
			
			if(action.GetIgnoreImmortalityMode() || (!actorVictim.IsImmortal() && !actorVictim.IsInvulnerable() && !actorVictim.IsKnockedUnconscious()) || fallingRaffard)
			{
				action.processedDmg.vitalityDamage += dmgInfos[directDmgIndex].dmgVal;
				action.processedDmg.essenceDamage  += dmgInfos[directDmgIndex].dmgVal;
			}
			else if( actorVictim.IsInvulnerable() )
			{
				
			}
			else if( actorVictim.IsImmortal() )
			{
				
				action.processedDmg.vitalityDamage += MinF(dmgInfos[directDmgIndex].dmgVal, actorVictim.GetStat(BCS_Vitality)-1 );
				action.processedDmg.essenceDamage  += MinF(dmgInfos[directDmgIndex].dmgVal, actorVictim.GetStat(BCS_Essence)-1 );
			}
		}
		
		
		if( actorVictim.HasAbility( 'OneShotImmune' ) )
		{
			if( action.processedDmg.vitalityDamage >= actorVictim.GetStatMax( BCS_Vitality ) )
			{
				action.processedDmg.vitalityDamage = actorVictim.GetStatMax( BCS_Vitality ) - 1;
			}
			else if( action.processedDmg.essenceDamage >= actorVictim.GetStatMax( BCS_Essence ) )
			{
				action.processedDmg.essenceDamage = actorVictim.GetStatMax( BCS_Essence ) - 1;
			}
		}
		
		
		if(action.HasDealtFireDamage())
			action.victim.OnFireHit( (CGameplayEntity)action.causer );
			
		
		ProcessInstantKill();
			
		
		ProcessActionDamage_DealDamage();
		
		
		if(playerAttacker && witcher)
			witcher.SetRecentlyCountered(false);
		
		
		if( attackAction && !attackAction.IsCountered() && playerVictim && attackAction.IsActionMelee())
			theGame.GetGamerProfile().ResetStat(ES_CounterattackChain);
		
		
		ProcessActionDamage_ReduceDurability();
		
		
		if(playerAttacker && actorVictim)
		{
			
			if(playerAttacker.inv.ItemHasOilApplied(weaponId) && (!playerAttacker.CanUseSkill(S_Alchemy_s06) || (playerAttacker.GetSkillLevel(S_Alchemy_s06) < 3)) )
			{			
				playerAttacker.ReduceOilAmmo(weaponId);
				
				if(ShouldProcessTutorial('TutorialOilAmmo'))
				{
					FactsAdd("tut_used_oil_in_combat");
				}
			}
			
			
			playerAttacker.inv.ReduceItemRepairObjectBonusCharge(weaponId);
		}
		
		
		if(actorVictim && actorAttacker && !action.GetCannotReturnDamage() )
			ProcessActionReturnedDamage();	
		
		return anyDamageProcessed;
	}
	
	
	private function ProcessInstantKill()
	{
		var instantKill, focus : float;

		if(!actorVictim || !attackAction || !actorAttacker || actorVictim.HasAbility('InstantKillImmune') || actorVictim.IsImmortal() || actorVictim.IsInvulnerable())
			return;
		
		
		if(actorAttacker == thePlayer)
		{
			if( ConvertGameSecondsToRealTimeSeconds(GameTimeToSeconds(theGame.GetGameTime()-thePlayer.lastInstantKillTime)) < theGame.params.INSTANT_KILL_INTERNAL_PLAYER_COOLDOWN)
				return;
		}
	
			
		
		instantKill = CalculateAttributeValue(actorAttacker.GetInventory().GetItemAttributeValue(weaponId, 'instant_kill_chance'));
		
		
		if ((attackAction.IsActionMelee() || attackAction.IsActionRanged()) && playerAttacker && thePlayer.CanUseSkill(S_Sword_s03) && !playerAttacker.inv.IsItemFists(weaponId))
		{
			focus = thePlayer.GetStat(BCS_Focus);
			
			if(focus >= 1)
				instantKill += focus * CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s03, 'instant_kill_chance', false, true) ) * thePlayer.GetSkillLevel(S_Sword_s03);
		}

		
		if ( RandF() < instantKill )
		{
			if(theGame.CanLog())
			{
				LogDMHits("Instant kill!! (" + NoTrailZeros(instantKill * 100) + "% chance", action);
			}
		
			action.processedDmg.vitalityDamage += actorVictim.GetStat(BCS_Vitality);
			action.processedDmg.essenceDamage += actorVictim.GetStat(BCS_Essence);
			attackAction.SetCriticalHit();	
			attackAction.SetInstantKill();			
			
			
			if(playerAttacker)
			{
				thePlayer.SetLastInstantKillTime(theGame.GetGameTime());
				theSound.SoundEvent('cmb_play_deadly_hit');
				theGame.SetTimeScale(0.2, theGame.GetTimescaleSource(ETS_InstantKill), theGame.GetTimescalePriority(ETS_InstantKill), true, true);
				thePlayer.AddTimer('RemoveInstantKillSloMo', 0.2);
			}			
		}
	}
	
	
	private function ProcessOnBeforeHitChecks()
	{
		var isSilverSword, isSteelSword : bool;
		var oilItemName, effectAbilityName, monsterBonusType : name;
		var effectType : EEffectType;
		var null, monsterBonusVal : SAbilityAttributeValue;
		var oilLevel, skillLevel, i : int;
		var baseChance, perOilLevelChance, chance : float;
		var buffs : array<name>;
	
		
		if(playerAttacker && actorVictim && attackAction && attackAction.IsActionMelee() && playerAttacker.CanUseSkill(S_Alchemy_s12))
		{
			
			isSilverSword = playerAttacker.inv.IsItemSilverSwordUsableByPlayer(weaponId);
			
			if(!isSilverSword)
				isSteelSword = playerAttacker.inv.IsItemSteelSwordUsableByPlayer(weaponId);
			else
				isSteelSword = false;
			
			if(isSilverSword || isSteelSword)
			{
				
				oilItemName = playerAttacker.inv.GetOilNameOnSword(isSteelSword);				
				if(dm.IsItemAlchemyItem(oilItemName))
				{
					
					monsterBonusType = MonsterCategoryToAttackPowerBonus(victimMonsterCategory);
					monsterBonusVal = playerAttacker.inv.GetItemAttributeValue(weaponId, monsterBonusType);
				
					if(monsterBonusVal != null)
					{
						
						oilLevel = (int)CalculateAttributeValue(playerAttacker.inv.GetItemAttributeValue(weaponId, 'level')) - 1;				
						skillLevel = playerAttacker.GetSkillLevel(S_Alchemy_s12);
						baseChance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Alchemy_s12, 'skill_chance', false, true));
						perOilLevelChance = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Alchemy_s12, 'oil_level_chance', false, true));						
						chance = baseChance * skillLevel + perOilLevelChance * oilLevel;
						
						
						if(RandF() < chance)
						{
							
							dm.GetContainedAbilities(playerAttacker.GetSkillAbilityName(S_Alchemy_s12), buffs);
							for(i=0; i<buffs.Size(); i+=1)
							{
								EffectNameToType(buffs[i], effectType, effectAbilityName);
								action.AddEffectInfo(effectType, , , effectAbilityName);
							}
						}
					}
				}
			}
		}
	}
	
	
	private function ProcessCriticalHitCheck()
	{
		var critChance, critDamageBonus : float;
		var	canLog : bool;
		var arrStr : array<string>;
		var samum : CBaseGameplayEffect;
		
		canLog = theGame.CanLog();
		
		if(playerAttacker && attackAction && (attackAction.IsActionMelee() || attackAction.IsActionRanged()))
		{		
			
			if( SkillEnumToName(S_Sword_s02) == attackAction.GetAttackTypeName() )
			{				
				critChance += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s02, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * playerAttacker.GetSkillLevel(S_Sword_s02);
			}
			
			
			if(GetWitcherPlayer() && GetWitcherPlayer().HasRecentlyCountered() && playerAttacker.CanUseSkill(S_Sword_s11) && playerAttacker.GetSkillLevel(S_Sword_s11) > 2)
			{
				critChance += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s11, theGame.params.CRITICAL_HIT_CHANCE, false, true));
			}
			
			
			critChance += playerAttacker.GetCriticalHitChance(playerAttacker.IsHeavyAttack(attackAction.GetAttackName()),actorVictim, victimMonsterCategory);
			
			
			if (attackAction.IsActionRanged() && playerAttacker.CanUseSkill(S_Sword_s07))
			{
				critChance += CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s07, theGame.params.CRITICAL_HIT_CHANCE, false, true)) * playerAttacker.GetSkillLevel(S_Sword_s07);
			}
			
			
			if(action.GetIsHeadShot())
				critChance += theGame.params.HEAD_SHOT_CRIT_CHANCE_BONUS;
				
			
			if ( actorVictim && actorVictim.IsAttackerAtBack(playerAttacker) )
				critChance += theGame.params.BACK_ATTACK_CRIT_CHANCE_BONUS;
				
			
			samum = actorVictim.GetBuff(EET_Blindness, 'petard');
			if(samum && samum.GetBuffLevel() == 3)
			{
				critChance += 1.0f;
			}
			
			
			if ( canLog )
			{
				
				critDamageBonus = 1 + CalculateAttributeValue(actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker)));
				
				critDamageBonus += CalculateAttributeValue(actorAttacker.GetAttributeValue('critical_hit_chance_fast_style'));
				critDamageBonus = 100 * critDamageBonus;
				
				
				LogDMHits("", action);				
				LogDMHits("Trying critical hit (" + NoTrailZeros(critChance*100) + "% chance, dealing " + NoTrailZeros(critDamageBonus) + "% damage)...", action);
			}
			
			
			if(RandF() < critChance)
			{
				
				attackAction.SetCriticalHit();
								
				if ( canLog )
				{
					LogDMHits("********************", action);
					LogDMHits("*** CRITICAL HIT ***", action);
					LogDMHits("********************", action);				
				}
				
				arrStr.PushBack(action.attacker.GetDisplayName());
				theGame.witcherLog.AddCombatMessage(theGame.witcherLog.COLOR_GOLD_BEGIN + GetLocStringByKeyExtWithParams("hud_combat_log_critical_hit",,,arrStr) + theGame.witcherLog.COLOR_GOLD_END, action.attacker, NULL);
			}
			else if ( canLog )
			{
				LogDMHits("... nope", action);
			}
		}	
	}
	
	
	private function LogBeginning()
	{
		var logStr : string;
		
		if ( !theGame.CanLog() )
		{
			return;
		}
		
		LogDMHits("-----------------------------------------------------------------------------------", action);		
		logStr = "Beginning hit processing from <<" + action.attacker + ">> to <<" + action.victim + ">> via <<" + action.causer + ">>";
		if(attackAction)
		{
			logStr += " using AttackType <<" + attackAction.GetAttackTypeName() + ">>";		
		}
		logStr += ":";
		LogDMHits(logStr, action);
		LogDMHits("", action);
		LogDMHits("Target stats before damage dealt are:", action);
		if(actorVictim)
		{
			if( actorVictim.UsesVitality() )
				LogDMHits("Vitality = " + NoTrailZeros(actorVictim.GetStat(BCS_Vitality)), action);
			if( actorVictim.UsesEssence() )
				LogDMHits("Essence = " + NoTrailZeros(actorVictim.GetStat(BCS_Essence)), action);
			if( actorVictim.GetStatMax(BCS_Stamina) > 0)
				LogDMHits("Stamina = " + NoTrailZeros(actorVictim.GetStat(BCS_Stamina, true)), action);
			if( actorVictim.GetStatMax(BCS_Morale) > 0)
				LogDMHits("Morale = " + NoTrailZeros(actorVictim.GetStat(BCS_Morale)), action);
		}
		else
		{
			LogDMHits("Undefined - victim is not a CActor and therefore has no stats", action);
		}
	}
	
	
	private function ProcessDamageIncrease(out dmgInfos : array< SRawDamage >)
	{
		var difficultyDamageMultiplier, rendLoad, rendBonus, overheal, rendRatio : float;
		var i : int;
		var frozenBuff : W3Effect_Frozen;
		var frozenDmgInfo : SRawDamage;
		var hadFrostDamage : bool;
		var mpac : CMovingPhysicalAgentComponent;
		var rendBonusPerPoint, staminaRendBonus : SAbilityAttributeValue;
		var witcherAttacker : W3PlayerWitcher;
		var damageVal 			: SAbilityAttributeValue;
		var fxEnt : CEntity;
		var template : CEntityTemplate;
		var boneRotation : EulerAngles;
		var bonePosition : Vector;
		var boneIndex : int;
		
		
		
		if(actorAttacker && !actorAttacker.IgnoresDifficultySettings() && !action.IsDoTDamage())
		{
			difficultyDamageMultiplier = CalculateAttributeValue(actorAttacker.GetAttributeValue(theGame.params.DIFFICULTY_DMG_MULTIPLIER));
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal * difficultyDamageMultiplier;
			}
		}
			
		
		
		
		if(actorVictim && !action.IsDoTDamage() && actorVictim.HasBuff(EET_Frozen) && ( (W3AardProjectile)action.causer || (W3AardEntity)action.causer || action.DealsPhysicalOrSilverDamage()) )
		{
			frozenBuff = (W3Effect_Frozen)actorVictim.GetBuff(EET_Frozen);
			
			frozenDmgInfo.dmgVal = frozenBuff.GetAdditionalDamagePercents() * actorVictim.GetMaxHealth();
			
			
			hadFrostDamage = false;
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				if(dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_FROST)
				{
					dmgInfos[i].dmgVal += frozenDmgInfo.dmgVal;
					hadFrostDamage = true;
					break;
				}
			}
			
			
			if(!hadFrostDamage)
			{						
				frozenDmgInfo.dmgType = theGame.params.DAMAGE_NAME_FROST;
				dmgInfos.PushBack(frozenDmgInfo);
			}
			
			
			actorVictim.RemoveAllBuffsOfType(EET_Frozen);
			action.AddEffectInfo(EET_KnockdownTypeApplicator);
		}
		
		
		if(actorVictim)
		{
			mpac = (CMovingPhysicalAgentComponent)actorVictim.GetMovingAgentComponent();
						
			if(mpac && mpac.IsDiving())
			{
				mpac = (CMovingPhysicalAgentComponent)actorAttacker.GetMovingAgentComponent();	
				
				if(mpac && mpac.IsDiving())
				{
					action.SetUnderwaterDisplayDamageHack();
				
					if(playerAttacker && attackAction && attackAction.IsActionRanged())
					{
						for(i=0; i<dmgInfos.Size(); i+=1)
						{
							if(FactsQuerySum("NewGamePlus"))
							{
								dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS_NGP);
							}
							else
							{
								dmgInfos[i].dmgVal *= (1 + theGame.params.UNDERWATER_CROSSBOW_DAMAGE_BONUS);
							}
						}
					}
				}
			}
		}
		
		
		if(playerAttacker && attackAction && SkillNameToEnum(attackAction.GetAttackTypeName()) == S_Sword_s02)
		{
			witcherAttacker = (W3PlayerWitcher)playerAttacker;
			
			
			rendRatio = witcherAttacker.GetSpecialAttackTimeRatio();
			
			
			rendLoad = MinF(rendRatio * playerAttacker.GetStatMax(BCS_Focus), playerAttacker.GetStat(BCS_Focus));
			
			
			if(rendLoad >= 1)
			{
				rendBonusPerPoint = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'adrenaline_final_damage_bonus', false, true);
				rendBonus = FloorF(rendLoad) * rendBonusPerPoint.valueMultiplicative;
				
				for(i=0; i<dmgInfos.Size(); i+=1)
				{
					dmgInfos[i].dmgVal *= (1 + rendBonus);
				}
			}
			
			
			staminaRendBonus = witcherAttacker.GetSkillAttributeValue(S_Sword_s02, 'stamina_max_dmg_bonus', false, true);
			
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal *= (1 + rendRatio * staminaRendBonus.valueMultiplicative);
			}
		}	
 
		
		if ( actorAttacker != thePlayer && action.IsActionRanged() && (int)CalculateAttributeValue(actorAttacker.GetAttributeValue('level',,true)) > 31)
		{
			damageVal = actorAttacker.GetAttributeValue('light_attack_damage_vitality',,true);
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				dmgInfos[i].dmgVal = dmgInfos[i].dmgVal + CalculateAttributeValue(damageVal) / 2;
			}
		}
		
		
		if ( actorVictim && playerAttacker && attackAction && action.IsActionMelee() && thePlayer.HasAbility('Runeword 4 _Stats', true) && !attackAction.WasDodged() )
		{
			overheal = thePlayer.abilityManager.GetOverhealBonus() / thePlayer.GetStatMax(BCS_Vitality);
		
			if(overheal > 0.005f)
			{
				for(i=0; i<dmgInfos.Size(); i+=1)
				{
					dmgInfos[i].dmgVal *= 1.0f + overheal;
				}
			
				thePlayer.abilityManager.ResetOverhealBonus();
				
				
				template = (CEntityTemplate)LoadResource('runeword_4');
				
				boneIndex = actorVictim.GetBoneIndex( 'pelvis' );
				if( boneIndex == -1 )
				{
					boneIndex = actorVictim.GetBoneIndex( 'k_pelvis_g' );
				}
				
				if( boneIndex != -1 )
				{
					actorVictim.GetBoneWorldPositionAndRotationByIndex( boneIndex, bonePosition, boneRotation );
					fxEnt = theGame.CreateEntity( template, bonePosition, boneRotation );
					fxEnt.CreateAttachmentAtBoneWS( actorVictim, 'k_pelvis_g', bonePosition, boneRotation );
				}
			}
		}
	}
	
	
	private function ProcessActionReturnedDamage()
	{
		var witcher 			: W3PlayerWitcher;
		var quen 				: W3QuenEntity;
		var params 				: SCustomEffectParams;
		var processFireShield, canBeParried, canBeDodged, wasParried, wasDodged : bool;
		var g5Chance			: SAbilityAttributeValue;
		
		
		if((attackerMonsterCategory == MC_Necrophage || attackerMonsterCategory == MC_Vampire) && actorVictim.HasBuff(EET_BlackBlood))
			ProcessActionBlackBloodReturnedDamage();		
		
		
		if(action.IsActionMelee() && actorVictim.HasAbility( 'Thorns' ) )
			ProcessActionThornDamage();
		
		if(actorVictim.HasAbility( 'Glyphword 5 _Stats', true))
		{			
			if( GetAttitudeBetween(actorAttacker, actorVictim) == AIA_Hostile)
			{
				if( !action.IsDoTDamage() )
				{
					g5Chance = actorVictim.GetAttributeValue('glyphword5_chance');
					
					if(RandF() < g5Chance.valueAdditive)
					{
						canBeParried = attackAction.CanBeParried();
						canBeDodged = attackAction.CanBeDodged();
						wasParried = attackAction.IsParried() || attackAction.IsCountered();
						wasDodged = attackAction.WasDodged();
				
						if(!action.IsActionMelee() || (!canBeParried && canBeDodged && !wasDodged) || (canBeParried && !wasParried && !canBeDodged) || (canBeParried && canBeDodged && !wasDodged && !wasParried))
							ProcessActionReflectDamage();
					}	
				}
			}			
			
		}
		
		
		if(playerVictim && !playerAttacker && actorAttacker && attackAction && attackAction.IsActionMelee() && thePlayer.HasBuff(EET_Mutagen26))
		{
			ProcessActionLeshenMutagenDamage();
		}
		
		
		if(action.IsActionMelee() && actorVictim.HasAbility( 'FireShield' ) )
		{
			witcher = GetWitcherPlayer();			
			processFireShield = true;			
			if(playerAttacker == witcher)
			{
				quen = (W3QuenEntity)witcher.GetSignEntity(ST_Quen);
				if(quen && quen.IsAnyQuenActive())
				{
					processFireShield = false;
				}
			}
			
			if(processFireShield)
			{
				params.effectType = EET_Burning;
				params.creator = actorVictim;
				params.sourceName = actorVictim.GetName();
				
				params.effectValue.valueMultiplicative = 0.01;
				actorAttacker.AddEffectCustom(params);
			}
		}
		
		
		if(actorAttacker.UsesEssence())
			ProcessSilverStudsReturnedDamage();
	}
	
	
	private function ProcessActionLeshenMutagenDamage()
	{
		var damageAction : W3DamageAction;
		var returnedDamage, pts, perc : float;
		var mutagen : W3Mutagen26_Effect;
		
		mutagen = (W3Mutagen26_Effect)playerVictim.GetBuff(EET_Mutagen26);
		mutagen.GetReturnedDamage(pts, perc);
		
		if(pts <= 0 && perc <= 0)
			return;
			
		returnedDamage = pts + perc * action.GetDamageValueTotal();
		
		
		damageAction = new W3DamageAction in this;		
		damageAction.Initialize( action.victim, action.attacker, NULL, "Mutagen26", EHRT_None, CPS_AttackPower, true, false, false, false );		
		damageAction.SetCannotReturnDamage( true );		
		damageAction.SetHitAnimationPlayType( EAHA_ForceNo );				
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, returnedDamage);
		
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
	}
	
	
	private function ProcessSilverStudsReturnedDamage()
	{
		var damageAction : W3DamageAction;
		var returnedDamage : float;
		
		returnedDamage = CalculateAttributeValue(actorVictim.GetAttributeValue('returned_silver_damage'));
		
		if(returnedDamage <= 0)
			return;
		
		damageAction = new W3DamageAction in this;		
		damageAction.Initialize( action.victim, action.attacker, NULL, "SilverStuds", EHRT_None, CPS_AttackPower, true, false, false, false );		
		damageAction.SetCannotReturnDamage( true );		
		damageAction.SetHitAnimationPlayType( EAHA_ForceNo );		
		
		damageAction.AddDamage(theGame.params.DAMAGE_NAME_SILVER, returnedDamage);
		
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
	}
	
	
	private function ProcessActionBlackBloodReturnedDamage()
	{
		var returnedAction : W3DamageAction;
		var returnVal : SAbilityAttributeValue;
		var bb : W3Potion_BlackBlood;
		var potionLevel : int;
		var returnedDamage : float;
	
		if(action.processedDmg.vitalityDamage <= 0)
			return;
		
		bb = (W3Potion_BlackBlood)actorVictim.GetBuff(EET_BlackBlood);
		potionLevel = bb.GetBuffLevel();
		
		
		returnedAction = new W3DamageAction in this;		
		returnedAction.Initialize( action.victim, action.attacker, bb, "BlackBlood", EHRT_None, CPS_AttackPower, true, false, false, false );		
		returnedAction.SetCannotReturnDamage( true );		
		
		returnVal = bb.GetReturnDamageValue();
		
		if(potionLevel == 1)
		{
			returnedAction.SetHitAnimationPlayType(EAHA_ForceNo);
		}
		else
		{
			returnedAction.SetHitAnimationPlayType(EAHA_ForceYes);
			returnedAction.SetHitReactionType(EHRT_Reflect);
		}
		
		returnedDamage = (returnVal.valueBase + action.processedDmg.vitalityDamage) * returnVal.valueMultiplicative + returnVal.valueAdditive;
		returnedAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage);
		
		theGame.damageMgr.ProcessAction(returnedAction);
		delete returnedAction;
	}
	
	
	private function ProcessActionReflectDamage()
	{
		var returnedAction : W3DamageAction;
		var returnVal, min, max : SAbilityAttributeValue;
		var potionLevel : int;
		var returnedDamage : float;
		var template : CEntityTemplate;
		var fxEnt : CEntity;
		var boneIndex: int;
		var b : bool;
		var component : CComponent;
		
		
		if(action.processedDmg.vitalityDamage <= 0)
			return;
		
		returnedDamage = CalculateAttributeValue(actorVictim.GetTotalArmor());
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Glyphword 5 _Stats', 'damage_mult', min, max);
		
		
		
		
		returnedAction = new W3DamageAction in this;		
		returnedAction.Initialize( action.victim, action.attacker, NULL, "Glyphword5", EHRT_None, CPS_AttackPower, true, false, false, false );		
		returnedAction.SetCannotReturnDamage( true );		
		returnedAction.SetHitAnimationPlayType(EAHA_ForceYes);
		returnedAction.SetHitReactionType(EHRT_Heavy);
		
		returnedAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, returnedDamage * min.valueMultiplicative);
		
		
		
		
		theGame.damageMgr.ProcessAction(returnedAction);
		delete returnedAction;
		
		template = (CEntityTemplate)LoadResource('glyphword_5');
		
		
		
		
		
		
		component = action.attacker.GetComponent('torso3effect');
		if(component)
			thePlayer.PlayEffect('reflection_damge', component);
		else
			thePlayer.PlayEffect('reflection_damge', action.attacker);
		action.attacker.PlayEffect('yrden_shock');
	}
	
	
	private function ProcessActionThornDamage()
	{
		var damageAction 		: W3DamageAction;
		var damageVal 			: SAbilityAttributeValue;
		var damage				: float;
		var inv					: CInventoryComponent;
		var damageNames			: array < CName >;
		
		damageAction	= new W3DamageAction in this;
		
		damageAction.Initialize( action.victim, action.attacker, NULL, "Thorns", EHRT_Light, CPS_AttackPower, true, false, false, false );
		
		damageAction.SetCannotReturnDamage( true );		
		
		damageVal 				=  actorVictim.GetAttributeValue( 'light_attack_damage_vitality' );
		
		
		
		
		
		inv = actorAttacker.GetInventory();		
		inv.GetWeaponDTNames(weaponId, damageNames );
		damageVal.valueBase  = actorAttacker.GetTotalWeaponDamage(weaponId, damageNames[0], GetInvalidUniqueId() );
		
		damageVal.valueBase *= 0.10f;
		
		if( damageVal.valueBase == 0 )
		{
			damageVal.valueBase = 10;
		}
				
		damage = (damageVal.valueBase + action.processedDmg.vitalityDamage) * damageVal.valueMultiplicative + damageVal.valueAdditive;
		damageAction.AddDamage(  theGame.params.DAMAGE_NAME_PIERCING, damage );
		
		damageAction.SetHitAnimationPlayType( EAHA_ForceYes );
		theGame.damageMgr.ProcessAction(damageAction);
		delete damageAction;
	}
	
	
	private function GetAttackersPowerMod() : SAbilityAttributeValue
	{		
		var powerMod, criticalDamageBonus, min, max, critReduction : SAbilityAttributeValue;
		var mutagen : CBaseGameplayEffect;
		var totalBonus : float;
			
		
		powerMod = action.GetPowerStatValue();
		if ( powerMod.valueAdditive == 0 && powerMod.valueBase == 0 && powerMod.valueMultiplicative == 0 && theGame.CanLog() )
			LogDMHits("Attacker has power stat of 0!", action);
		
		
		if(playerAttacker && attackAction && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()))
			powerMod.valueMultiplicative -= 0.833;
		
		
		if ( playerAttacker && (W3IgniProjectile)action.causer )
			powerMod.valueMultiplicative = 1 + (powerMod.valueMultiplicative - 1) * theGame.params.IGNI_SPELL_POWER_MILT;
		
		
		if ( playerAttacker && (W3AardProjectile)action.causer )
			powerMod.valueMultiplicative = 1;
		
		
		if(attackAction && attackAction.IsCriticalHit())
		{
			criticalDamageBonus = actorAttacker.GetCriticalHitDamageBonus(weaponId, victimMonsterCategory, actorVictim.IsAttackerAtBack(playerAttacker));
			
			criticalDamageBonus += actorAttacker.GetAttributeValue('critical_hit_chance_fast_style');
			
			if(playerAttacker)
			{
				if(playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s08))
					criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s08, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s08);
				else if (!playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s17))
					criticalDamageBonus += playerAttacker.GetSkillAttributeValue(S_Sword_s17, theGame.params.CRITICAL_HIT_DAMAGE_BONUS, false, true) * playerAttacker.GetSkillLevel(S_Sword_s17);
			}
			
			
			totalBonus = CalculateAttributeValue(criticalDamageBonus);
			critReduction = actorVictim.GetAttributeValue(theGame.params.CRITICAL_HIT_REDUCTION);
			totalBonus = totalBonus * ClampF(1 - critReduction.valueMultiplicative, 0.f, 1.f);
			
			
			powerMod.valueMultiplicative += totalBonus;
		}
		
		
		if (actorVictim && playerAttacker)
		{
			if ( playerAttacker.HasBuff(EET_Mutagen05) && (playerAttacker.GetStat(BCS_Vitality) == playerAttacker.GetStatMax(BCS_Vitality)) )
			{
				mutagen = playerAttacker.GetBuff(EET_Mutagen05);
				dm.GetAbilityAttributeValue(mutagen.GetAbilityName(), 'damageIncrease', min, max);
				powerMod += GetAttributeRandomizedValue(min, max);
			}
		}
			
		return powerMod;
	}
	
	
	private function GetDamageResists(dmgType : name, out resistPts : float, out resistPerc : float)
	{
		var armorReduction, armorReductionPerc, skillArmorReduction : SAbilityAttributeValue;
		var bonusReduct, bonusResist, maxOilCharges : float;
		var oilCharges : int;
		var mutagenBuff : W3Mutagen28_Effect;
		var appliedOilName, vsMonsterResistReduction : name;
		
		
		if(attackAction && attackAction.IsActionMelee() && actorAttacker.GetInventory().IsItemFists(weaponId) && !actorVictim.UsesEssence())
			return;
			
		
		if(actorVictim)
		{
			
			actorVictim.GetResistValue( GetResistForDamage(dmgType, action.IsDoTDamage()), resistPts, resistPerc );
			
			
			if(playerVictim && actorAttacker && playerVictim.CanUseSkill(S_Alchemy_s05))
			{
				GetOilProtectionAgainstMonster(dmgType, bonusResist, bonusReduct);
				
				resistPerc += bonusResist * playerVictim.GetSkillLevel(S_Alchemy_s05);
			}
			
			
			if(playerVictim && actorAttacker && playerVictim.HasBuff(EET_Mutagen28))
			{
				mutagenBuff = (W3Mutagen28_Effect)playerVictim.GetBuff(EET_Mutagen28);
				mutagenBuff.GetProtection(attackerMonsterCategory, dmgType, action.IsDoTDamage(), bonusResist, bonusReduct);
				resistPts += bonusReduct;
				resistPerc += bonusResist;
			}
			
			
			if(actorAttacker)
			{
				
				armorReduction = actorAttacker.GetAttributeValue('armor_reduction');
				armorReductionPerc = actorAttacker.GetAttributeValue('armor_reduction_perc');
				
				
				if(playerAttacker)
				{
					vsMonsterResistReduction = MonsterCategoryToResistReduction(victimMonsterCategory);
					appliedOilName = playerAttacker.inv.GetSwordOil(weaponId);
					
					
					if(dm.ItemHasAttribute(appliedOilName, true, vsMonsterResistReduction))
					{
						oilCharges = playerAttacker.GetCurrentOilAmmo(weaponId);
						maxOilCharges = playerAttacker.GetMaxOilAmmo(weaponId);
						
						armorReductionPerc.valueMultiplicative += ((float)oilCharges) / maxOilCharges;
					}
				}
				
				
				if(playerAttacker && action.IsActionMelee() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_2))
					armorReduction += playerAttacker.GetSkillAttributeValue(S_Sword_2, 'armor_reduction', false, true);
				
				
				if ( playerAttacker && 
					 action.IsActionMelee() && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && 
					 ( dmgType == theGame.params.DAMAGE_NAME_PHYSICAL || 
					   dmgType == theGame.params.DAMAGE_NAME_SLASHING || 
				       dmgType == theGame.params.DAMAGE_NAME_PIERCING || 
					   dmgType == theGame.params.DAMAGE_NAME_BLUDGEONING || 
					   dmgType == theGame.params.DAMAGE_NAME_RENDING || 
					   dmgType == theGame.params.DAMAGE_NAME_SILVER
					 ) && 
					 playerAttacker.CanUseSkill(S_Sword_s06)
				   ) 
				{
					
					skillArmorReduction = playerAttacker.GetSkillAttributeValue(S_Sword_s06, 'armor_reduction_perc', false, true);
					armorReductionPerc += skillArmorReduction * playerAttacker.GetSkillLevel(S_Sword_s06);				
				}
			}
		}
		
		
		if(!action.GetIgnoreArmor())
			resistPts += CalculateAttributeValue( actorVictim.GetTotalArmor() );
		
		
		resistPts = MaxF(0, resistPts - CalculateAttributeValue(armorReduction) );		
		resistPerc -= CalculateAttributeValue(armorReductionPerc);		
		
		
		
		resistPerc = MaxF(0, resistPerc);
	}
		
	
	private function CalculateDamage(dmgInfo : SRawDamage, powerMod : SAbilityAttributeValue) : float
	{
		var finalDamage, finalIncomingDamage : float;
		var resistPoints, resistPercents : float;
		var ptsString, percString : string;
		var mutagen : CBaseGameplayEffect;
		var min, max : SAbilityAttributeValue;
		var encumbranceBonus : float;
		var temp : bool;
		var fistfightDamageMult : float;
		var burning : W3Effect_Burning;
	
		
		GetDamageResists(dmgInfo.dmgType, resistPoints, resistPercents);
	
		
		if( thePlayer.IsFistFightMinigameEnabled() && actorAttacker == thePlayer )
		{
			finalDamage = MaxF(0, (dmgInfo.dmgVal));
		}
		else
		{
			finalDamage = MaxF(0, (dmgInfo.dmgVal + powerMod.valueBase) * powerMod.valueMultiplicative + powerMod.valueAdditive);
		}
			
		finalIncomingDamage = finalDamage;
			
		if(finalDamage > 0.f)
		{
			
			if(!action.IsPointResistIgnored() && !(dmgInfo.dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE || dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FROST ))
			{
				finalDamage = MaxF(0, finalDamage - resistPoints);
				
				if(finalDamage == 0.f)
					action.SetArmorReducedDamageToZero();
			}
		}
		
		if(finalDamage > 0.f)
		{
			
			if (playerVictim == GetWitcherPlayer() && playerVictim.HasBuff(EET_Mutagen02))
			{
				encumbranceBonus = 1 - (GetWitcherPlayer().GetEncumbrance() / GetWitcherPlayer().GetMaxRunEncumbrance(temp));
				if (encumbranceBonus < 0)
					encumbranceBonus = 0;
				mutagen = playerVictim.GetBuff(EET_Mutagen02);
				dm.GetAbilityAttributeValue(mutagen.GetAbilityName(), 'resistGainRate', min, max);
				encumbranceBonus *= CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				resistPercents += encumbranceBonus;
			}
			finalDamage *= 1 - resistPercents;
		}		
		
		if(dmgInfo.dmgType == theGame.params.DAMAGE_NAME_FIRE && finalDamage > 0)
			action.SetDealtFireDamage(true);
			
		if( playerAttacker && thePlayer.IsWeaponHeld('fist') && !thePlayer.IsInFistFightMiniGame() && action.IsActionMelee() )
		{
			if(FactsQuerySum("NewGamePlus") > 0)
			{fistfightDamageMult = thePlayer.GetLevel()* 0.1;}
			else
			{fistfightDamageMult = thePlayer.GetLevel()* 0.05;}
			
			finalDamage *= ( 1+fistfightDamageMult );
		}
		
		if(playerAttacker && attackAction && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()))
			finalDamage *= 1.833;
			
		
		burning = (W3Effect_Burning)action.causer;
		if(actorVictim && (((W3IgniEntity)action.causer) || ((W3IgniProjectile)action.causer) || ( burning && burning.IsSignEffect())) )
		{
			min = actorVictim.GetAttributeValue('igni_damage_amplifier');
			finalDamage = finalDamage * (1 + min.valueMultiplicative) + min.valueAdditive;
		}
		
		
		if ( theGame.CanLog() )
		{
			LogDMHits("Single hit damage: initial damage = " + NoTrailZeros(dmgInfo.dmgVal), action);
			LogDMHits("Single hit damage: attack_power = base: " + NoTrailZeros(powerMod.valueBase) + ", mult: " + NoTrailZeros(powerMod.valueMultiplicative) + ", add: " + NoTrailZeros(powerMod.valueAdditive), action );
			if(action.IsPointResistIgnored())
				LogDMHits("Single hit damage: resistance pts and armor = IGNORED", action);
			else
				LogDMHits("Single hit damage: resistance pts and armor = " + NoTrailZeros(resistPoints), action);			
			LogDMHits("Single hit damage: resistance perc = " + NoTrailZeros(resistPercents * 100), action);
			LogDMHits("Single hit damage: final damage to sustain = " + NoTrailZeros(finalDamage), action);
		}
			
		return finalDamage;
	}
	
	
	private function ProcessActionDamage_DealDamage()
	{
		var logStr : string;
		var hpPerc : float;
		var npcVictim : CNewNPC;
	
		
		if ( theGame.CanLog() )
		{
			logStr = "";
			if(action.processedDmg.vitalityDamage > 0)			logStr += NoTrailZeros(action.processedDmg.vitalityDamage) + " vitality, ";
			if(action.processedDmg.essenceDamage > 0)			logStr += NoTrailZeros(action.processedDmg.essenceDamage) + " essence, ";
			if(action.processedDmg.staminaDamage > 0)			logStr += NoTrailZeros(action.processedDmg.staminaDamage) + " stamina, ";
			if(action.processedDmg.moraleDamage > 0)			logStr += NoTrailZeros(action.processedDmg.moraleDamage) + " morale";
				
			if(logStr == "")
				logStr = "NONE";
			LogDMHits("Final damage to sustain is: " + logStr, action);
		}
				
		
		if(actorVictim)
		{
			hpPerc = actorVictim.GetHealthPercents();
			
			
			if(actorVictim.IsAlive())
			{
				npcVictim = (CNewNPC)actorVictim;
				if(npcVictim && npcVictim.IsHorse())
				{
					npcVictim.GetHorseComponent().OnTakeDamage(action);
				}
				else
				{
					actorVictim.OnTakeDamage(action);
				}
			}
			
			if(!actorVictim.IsAlive() && hpPerc == 1)
				action.SetWasKilledBySingleHit();
		}
			
		if ( theGame.CanLog() )
		{
			LogDMHits("", action);
			LogDMHits("Target stats after damage dealt are:", action);
			if(actorVictim)
			{
				if( actorVictim.UsesVitality())						LogDMHits("Vitality = " + NoTrailZeros( actorVictim.GetStat(BCS_Vitality)), action);
				if( actorVictim.UsesEssence())						LogDMHits("Essence = "  + NoTrailZeros( actorVictim.GetStat(BCS_Essence)), action);
				if( actorVictim.GetStatMax(BCS_Stamina) > 0)		LogDMHits("Stamina = "  + NoTrailZeros( actorVictim.GetStat(BCS_Stamina, true)), action);
				if( actorVictim.GetStatMax(BCS_Morale) > 0)			LogDMHits("Morale = "   + NoTrailZeros( actorVictim.GetStat(BCS_Morale)), action);
			}
			else
			{
				LogDMHits("Undefined - victim is not a CActor and therefore has no stats", action);
			}
		}
	}
	
	
	private function ProcessActionDamage_ReduceDurability()
	{		
		var witcherPlayer : W3PlayerWitcher;
		var dbg_currDur, dbg_prevDur1, dbg_prevDur2, dbg_prevDur3, dbg_prevDur4, dbg_prevDur : float;
		var dbg_armor, dbg_pants, dbg_boots, dbg_gloves, reducedItemId, weapon : SItemUniqueId;
		var slot : EEquipmentSlots;
		var weapons : array<SItemUniqueId>;
		var armorStringName : string;
		var canLog, playerHasSword : bool;
		var i : int;
		
		canLog = theGame.CanLog();

		witcherPlayer = GetWitcherPlayer();
	
		
		if ( playerAttacker && playerAttacker.inv.IsIdValid( weaponId ) && playerAttacker.inv.HasItemDurability( weaponId ) )
		{		
			dbg_prevDur = playerAttacker.inv.GetItemDurability(weaponId);
						
			if ( playerAttacker.inv.ReduceItemDurability(weaponId) && canLog )
			{
				LogDMHits("", action);
				LogDMHits("Player's weapon durability changes from " + NoTrailZeros(dbg_prevDur) + " to " + NoTrailZeros(action.attacker.GetInventory().GetItemDurability(weaponId)), action );
			}
		}
		
		else if(playerVictim && attackAction && attackAction.IsActionMelee() && (attackAction.IsParried() || attackAction.IsCountered()) )
		{
			weapons = playerVictim.inv.GetHeldWeapons();
			playerHasSword = false;
			for(i=0; i<weapons.Size(); i+=1)
			{
				weapon = weapons[i];
				if(playerVictim.inv.IsIdValid(weapon) && (playerVictim.inv.IsItemSteelSwordUsableByPlayer(weapon) || playerVictim.inv.IsItemSilverSwordUsableByPlayer(weapon)) )
				{
					playerHasSword = true;
					break;
				}
			}
			
			if(playerHasSword)
			{
				playerVictim.inv.ReduceItemDurability(weapon);
			}
		}
		
		else if(action.victim == witcherPlayer && (action.IsActionMelee() || action.IsActionRanged()) && action.DealsAnyDamage())
		{
			
			if ( canLog )
			{
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Armor, dbg_armor) )
					dbg_prevDur1 = action.victim.GetInventory().GetItemDurability(dbg_armor);
				else
					dbg_prevDur1 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Pants, dbg_pants) )
					dbg_prevDur2 = action.victim.GetInventory().GetItemDurability(dbg_pants);
				else
					dbg_prevDur2 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Boots, dbg_boots) )
					dbg_prevDur3 = action.victim.GetInventory().GetItemDurability(dbg_boots);
				else
					dbg_prevDur3 = 0;
					
				if ( witcherPlayer.GetItemEquippedOnSlot(EES_Gloves, dbg_gloves) )
					dbg_prevDur4 = action.victim.GetInventory().GetItemDurability(dbg_gloves);
				else
					dbg_prevDur4 = 0;
			}
			
			slot = GetWitcherPlayer().ReduceArmorDurability();
			
			
			if( canLog )
			{
				LogDMHits("", action);
				if(slot != EES_InvalidSlot)
				{		
					switch(slot)
					{
						case EES_Armor : 
							armorStringName = "chest armor";
							reducedItemId = dbg_armor;
							dbg_prevDur = dbg_prevDur1;
							break;
						case EES_Pants : 
							armorStringName = "pants";
							reducedItemId = dbg_pants;
							dbg_prevDur = dbg_prevDur2;
							break;
						case EES_Boots :
							armorStringName = "boots";
							reducedItemId = dbg_boots;
							dbg_prevDur = dbg_prevDur3;
							break;
						case EES_Gloves :
							armorStringName = "gloves";
							reducedItemId = dbg_gloves;
							dbg_prevDur = dbg_prevDur4;
							break;
					}
					
					dbg_currDur = action.victim.GetInventory().GetItemDurability(reducedItemId);
					LogDMHits("", action);
					LogDMHits("Player's <<" + armorStringName + ">> durability changes from " + NoTrailZeros(dbg_prevDur) + " to " + NoTrailZeros(dbg_currDur), action );
				}
				else
				{
					LogDMHits("Tried to reduce player's armor durability but failed", action);
				}
			}
				
			
			if(slot != EES_InvalidSlot)
				thePlayer.inv.ReduceItemRepairObjectBonusCharge(reducedItemId);
		}
	}	
	
	
	
	
	
	
	private function ProcessActionReaction(wasFrozen : bool, wasAlive : bool)
	{
		var dismemberExplosion 			: bool;
		var damageName 					: name;
		var damage 						: array<SRawDamage>;
		var points, percents, hp, dmg 	: float;
		var counterAction 				: W3DamageAction;		
		var moveTargets					: array<CActor>;
		var i 							: int;
		var canPerformFinisher			: bool;
		var weaponName					: name;
		var npcVictim					: CNewNPC;
		var toxicCloud					: W3ToxicCloud;
		var playsNonAdditiveAnim		: bool;
		var bleedCustomEffect 			: SCustomEffectParams;
		
		if(!actorVictim)
			return;
		
		npcVictim = (CNewNPC)actorVictim;
		
		canPerformFinisher = CanPerformFinisher(actorVictim);
		
		if( actorVictim.IsAlive() && !canPerformFinisher )
		{
			
			if(!action.IsDoTDamage() && action.DealtDamage())
			{
				if ( actorAttacker && npcVictim)
				{
					npcVictim.NoticeActorInGuardArea( actorAttacker );
				}

				
				if ( !playerVictim )
					actorVictim.RemoveAllBuffsOfType(EET_Confusion);
				
				
				if(playerAttacker && action.IsActionMelee() && !playerAttacker.GetInventory().IsItemFists(weaponId) && playerAttacker.IsLightAttack(attackAction.GetAttackName()) && playerAttacker.CanUseSkill(S_Sword_s05))
				{
					bleedCustomEffect.effectType = EET_Bleeding;
					bleedCustomEffect.creator = playerAttacker;
					bleedCustomEffect.sourceName = SkillEnumToName(S_Sword_s05);
					bleedCustomEffect.duration = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'duration', false, true));
					bleedCustomEffect.effectValue.valueAdditive = CalculateAttributeValue(playerAttacker.GetSkillAttributeValue(S_Sword_s05, 'dmg_per_sec', false, true)) * playerAttacker.GetSkillLevel(S_Sword_s05);
					actorVictim.AddEffectCustom(bleedCustomEffect);
				}
			}
			
			
			if(actorVictim && wasAlive)
			{
				playsNonAdditiveAnim = actorVictim.ReactToBeingHit( action );
			}				
		}
		else
		{
			
			if( !canPerformFinisher && CanDismember( wasFrozen, dismemberExplosion, weaponName ) )
			{
				ProcessDismemberment(wasFrozen, dismemberExplosion);
				toxicCloud = (W3ToxicCloud)action.causer;
				
				if(toxicCloud && toxicCloud.HasExplodingTargetDamages())
					ProcessToxicCloudDismemberExplosion(toxicCloud.GetExplodingTargetDamages());
					
				
				if(IsRequiredAttitudeBetween(thePlayer, action.victim, true))
				{
					moveTargets = thePlayer.GetMoveTargets();
					for ( i = 0; i < moveTargets.Size(); i += 1 )
					{
						if ( moveTargets[i].IsHuman() )
							moveTargets[i].DrainMorale(20.f);
					}
				}
			}
			
			else if ( canPerformFinisher )
			{
				if ( actorVictim.IsAlive() )
					actorVictim.Kill(false,thePlayer);
					
				thePlayer.AddTimer( 'DelayedFinisherInputTimer', 0.1f );
				thePlayer.SetFinisherVictim( actorVictim );
				thePlayer.CleanCombatActionBuffer();
				thePlayer.OnBlockAllCombatTickets( true );
				
				moveTargets = thePlayer.GetMoveTargets();
				
				for ( i = 0; i < moveTargets.Size(); i += 1 )
				{
					if ( actorVictim != moveTargets[i] )
						moveTargets[i].SignalGameplayEvent( 'InterruptChargeAttack' );
				}	
				
				if ( theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled' ) == "true" )
					actorVictim.AddAbility( 'ForceFinisher', false );
				
				if ( actorVictim.HasTag( 'ForceFinisher' ) )
					actorVictim.AddAbility( 'ForceFinisher', false );
				
				actorVictim.SignalGameplayEvent( 'ForceFinisher' );
				
			} 
			else if ( weaponName == 'fists' && npcVictim )
			{
				npcVictim.DisableAgony();	
			}
			
			thePlayer.FindMoveTarget();
		}
		
		
		actorVictim.ProcessHitSound(action, playsNonAdditiveAnim || !actorVictim.IsAlive());
		
		
		
		if(attackAction && attackAction.IsCriticalHit() && action.DealtDamage() && !actorVictim.IsAlive())
			GCameraShake(0.5);
		
		
		if( attackAction && npcVictim && npcVictim.IsShielded( actorAttacker ) && attackAction.IsParried() && attackAction.GetAttackName() == 'attack_heavy' &&  npcVictim.GetStaminaPercents() <= 0.1 )
		{
			npcVictim.ProcessShieldDestruction();
		}
		
		
		if( actorVictim && action.CanPlayHitParticle() && ( action.DealsAnyDamage() || (attackAction && attackAction.IsParried()) ) )
			actorVictim.PlayHitEffect(action);
			

		if( action.victim.HasAbility('mon_nekker_base') && !actorVictim.CanPlayHitAnim() && !((CBaseGameplayEffect) action.causer) ) 
		{
			
			actorVictim.PlayEffect(theGame.params.LIGHT_HIT_FX);
			actorVictim.SoundEvent("cmb_play_hit_light");
		}
			
		
		if(actorVictim && playerAttacker && action.IsActionMelee() && thePlayer.inv.IsItemFists(weaponId) )
		{
			actorVictim.SignalGameplayEvent( 'wasHitByFists' );	
				
			if(MonsterCategoryIsMonster(victimMonsterCategory))
			{
				if(!victimCanBeHitByFists)
				{
					playerAttacker.ReactToReflectedAttack(actorVictim);
				}
				else
				{			
					actorVictim.GetResistValue(CDS_PhysicalRes, points, percents);
				
					if(percents >= theGame.params.MONSTER_RESIST_THRESHOLD_TO_REFLECT_FISTS)
						playerAttacker.ReactToReflectedAttack(actorVictim);
				}
			}			
		}
		
		
		ProcessSparksFromNoDamage();
		
		
		if(attackAction && attackAction.IsActionMelee() && actorAttacker && playerVictim && attackAction.IsCountered() && playerVictim == GetWitcherPlayer())
		{
			GetWitcherPlayer().SetRecentlyCountered(true);
		}
		
		
		
		
		if(attackAction && !action.IsDoTDamage() && (playerAttacker || playerVictim) && (attackAction.IsParried() || attackAction.IsCountered()) )
		{
			theGame.VibrateControllerLight();
		}
	}
	
	private function CanDismember( wasFrozen : bool, out dismemberExplosion : bool, out weaponName : name ) : bool
	{
		var dismember			: bool;
		var dismemberChance 	: int;
		var petard 				: W3Petard;
		var bolt 				: W3BoltProjectile;
		var arrow 				: W3ArrowProjectile;
		var inv					: CInventoryComponent;
		var toxicCloud			: W3ToxicCloud;
		var witcher				: W3PlayerWitcher;
		var i					: int;
		var secondaryWeapon		: bool;

		petard = (W3Petard)action.causer;
		bolt = (W3BoltProjectile)action.causer;
		arrow = (W3ArrowProjectile)action.causer;
		toxicCloud = (W3ToxicCloud)action.causer;
		
		dismemberExplosion = false;
		
		if(playerAttacker)
		{
			secondaryWeapon = playerAttacker.inv.ItemHasTag( weaponId, 'SecondaryWeapon' ) || playerAttacker.inv.ItemHasTag( weaponId, 'Wooden' );
		}
		
		if( actorVictim.HasAbility( 'DisableDismemberment' ) )
		{
			dismember = false;
		}
		else if( actorVictim.HasTag( 'DisableDismemberment' ) )
		{
			dismember = false;
		}
		else if (actorVictim.WillBeUnconscious())
		{
			dismember = false;		
		}
		else if (playerAttacker && secondaryWeapon )
		{
			dismember = false;
		}
		else if( arrow )
		{
			dismember = false;
		}		
		else if( actorAttacker.HasAbility( 'ForceDismemberment' ) )
		{
			dismember = true;
		}
		else if(wasFrozen)
		{
			dismember = true;
		}						
		else if( (petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill()) )
		{
			dismember = true;
		}
		else if( (W3Effect_YrdenHealthDrain)action.causer )
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else if(toxicCloud && toxicCloud.HasExplodingTargetDamages())
		{
			dismember = true;
			dismemberExplosion = true;
		}
		else
		{
			inv = actorAttacker.GetInventory();
			weaponName = inv.GetItemName( weaponId );
			
			if( attackAction 
				&& !inv.IsItemSteelSwordUsableByPlayer(weaponId) 
				&& !inv.IsItemSilverSwordUsableByPlayer(weaponId) 
				&& weaponName != 'polearm'
				&& weaponName != 'fists_lightning' 
				&& weaponName != 'fists_fire' )
			{
				dismember = false;
			}			
			else if ( attackAction && attackAction.IsCriticalHit() )
			{
				dismember = true;
				dismemberExplosion = attackAction.HasForceExplosionDismemberment();
			}
			else if ( action.HasForceExplosionDismemberment() )
			{
				dismember = true;
				dismemberExplosion = true;
			}
			else
			{
				
				dismemberChance = theGame.params.DISMEMBERMENT_ON_DEATH_CHANCE;
				
				
				if(playerAttacker && playerAttacker.forceDismember)
				{
					dismemberChance = thePlayer.forceDismemberChance;
					dismemberExplosion = thePlayer.forceDismemberExplosion;
				}
				
				
				if(attackAction)
				{
					dismemberChance += RoundMath(100 * CalculateAttributeValue(inv.GetItemAttributeValue(weaponId, 'dismember_chance')));
					dismemberExplosion = attackAction.HasForceExplosionDismemberment();
				}
					
				
				witcher = (W3PlayerWitcher)actorAttacker;
				if(witcher && witcher.CanUseSkill(S_Perk_03))
					dismemberChance += RoundMath(100 * CalculateAttributeValue(witcher.GetSkillAttributeValue(S_Perk_03, 'dismember_chance', false, true)));
				
				dismemberChance = Clamp(dismemberChance, 0, 100);
				
				if (RandRange(100) < dismemberChance)
					dismember = true;
				else
					dismember = false;
			}
		}		

		return dismember;
	}	
	
	private function CanPerformFinisher( actorVictim : CActor ) : bool
	{
		var finisherChance 			: int;
		var areEnemiesAttacking		: bool;
		var i						: int;
		var victimToPlayerVector, playerPos	: Vector;
		var item 					: SItemUniqueId;
		var moveTargets				: array<CActor>;
		var b						: bool;
		var size					: int;
		var npc						: CNewNPC;
		
		if ( (W3ReplacerCiri)thePlayer || playerVictim || thePlayer.isInFinisher )
			return false;
		
		if ( actorVictim.IsAlive() && !CanPerformFinisherOnAliveTarget(actorVictim) )
			return false;
		
		moveTargets = thePlayer.GetMoveTargets();	
		size = moveTargets.Size();
		playerPos = thePlayer.GetWorldPosition();
	
		if ( size > 0 )
		{
			areEnemiesAttacking = false;			
			for(i=0; i<size; i+=1)
			{
				npc = (CNewNPC)moveTargets[i];
				if(npc && VecDistanceSquared(playerPos, moveTargets[i].GetWorldPosition()) < 7 && npc.IsAttacking() && npc != actorVictim )
				{
					areEnemiesAttacking = true;
					break;
				}
			}
		}
		
		victimToPlayerVector = actorVictim.GetWorldPosition() - playerPos;
		
		if ( actorVictim.IsHuman() )
		{
			npc = (CNewNPC)actorVictim;
			if ( ( actorVictim.HasBuff(EET_Confusion) || actorVictim.HasBuff(EET_AxiiGuardMe) ) )
			{
				finisherChance = 75 + ( - ( npc.currentLevel - thePlayer.GetLevel() ) );
			}
			else if ( ( size <= 1 && theGame.params.FINISHER_ON_DEATH_CHANCE > 0 ) || ( actorVictim.HasAbility('ForceFinisher') ) )
			{
				finisherChance = 100;
			}
			else if ( npc.currentLevel - thePlayer.GetLevel() < -5 )
			{
				finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE + ( - ( npc.currentLevel - thePlayer.GetLevel() ) );
			}
			else
				finisherChance = theGame.params.FINISHER_ON_DEATH_CHANCE;
				
			finisherChance = Clamp(finisherChance, 0, 100);
		}
		else 
			finisherChance = 0;	
			
		if ( actorVictim.HasTag('ForceFinisher') )
		{
			finisherChance = 100;
			areEnemiesAttacking = false;
		}
			
		item = thePlayer.inv.GetItemFromSlot( 'l_weapon' );	
		
		if ( thePlayer.forceFinisher )
		{
			b = playerAttacker && attackAction && attackAction.IsActionMelee();
			b = b && ( actorVictim.IsHuman() && !actorVictim.IsWoman() );
			b =	b && !thePlayer.IsInAir();
			b =	b && ( thePlayer.IsWeaponHeld( 'steelsword') || thePlayer.IsWeaponHeld( 'silversword') );
			b = b && !thePlayer.IsSecondaryWeaponHeld();
			b =	b && !thePlayer.inv.IsIdValid( item );
			b =	b && !actorVictim.IsKnockedUnconscious();
			b =	b && !actorVictim.HasBuff( EET_Knockdown );
			b =	b && !actorVictim.HasBuff( EET_Ragdoll );
			b =	b && !actorVictim.HasBuff( EET_Frozen );
			b =	b && !thePlayer.IsUsingVehicle();
			b =	b && thePlayer.IsAlive();
			b =	b && !thePlayer.IsCurrentSignChanneled();
		}
		else
		{
			b = playerAttacker && attackAction && attackAction.IsActionMelee();
			b = b && ( actorVictim.IsHuman() && !actorVictim.IsWoman() );
			b =	b && RandRange(100) < finisherChance;
			b =	b && !areEnemiesAttacking;
			b =	b && AbsF( victimToPlayerVector.Z ) < 0.4f;
			b =	b && !thePlayer.IsInAir();
			b =	b && ( thePlayer.IsWeaponHeld( 'steelsword') || thePlayer.IsWeaponHeld( 'silversword') );
			b = b && !thePlayer.IsSecondaryWeaponHeld();
			b =	b && !thePlayer.inv.IsIdValid( item );
			b =	b && !actorVictim.IsKnockedUnconscious();
			b =	b && !actorVictim.HasBuff( EET_Knockdown );
			b =	b && !actorVictim.HasBuff( EET_Ragdoll );
			b =	b && !actorVictim.HasBuff( EET_Frozen );
			b =	b && !actorVictim.HasAbility( 'DisableFinishers' );
			b =	b && actorVictim.GetAttitude( thePlayer ) == AIA_Hostile;
			b =	b && !thePlayer.IsUsingVehicle();
			b =	b && thePlayer.IsAlive();
			b =	b && !thePlayer.IsCurrentSignChanneled();
			b =	b && ( theGame.GetWorld().NavigationCircleTest( actorVictim.GetWorldPosition(), 2.f ) || actorVictim.HasTag('ForceFinisher') ) ;
			
		}
		
		if ( b  )
		{
			if ( !actorVictim.IsAlive() )
				actorVictim.AddAbility( 'DisableFinishers', false );
				
			return true;
		}
		
		return false;
	}
	
	private function CanPerformFinisherOnAliveTarget( actorVictim : CActor ) : bool
	{
		return actorVictim.IsHuman() 
		&& ( actorVictim.HasBuff(EET_Confusion) || actorVictim.HasBuff(EET_AxiiGuardMe) )
		&& actorVictim.IsVulnerable()
		&& !actorVictim.HasAbility('DisableFinisher')
		&& !actorVictim.HasAbility('InstantKillImmune');
	}
	
	
	
	
	
	
	private function ProcessActionBuffs() : bool
	{
		var inv : CInventoryComponent;
		var ret : bool;
	
		
		if(!action.victim.IsAlive() || action.WasDodged() || (attackAction && attackAction.IsActionMelee() && !attackAction.ApplyBuffsIfParried() && attackAction.CanBeParried() && attackAction.IsParried()) )
			return true;
			
		
		ApplyQuenBuffChanges();
	
		
		if(actorVictim && action.GetEffectsCount() > 0)
			ret = actorVictim.ApplyActionEffects(action);
		else
			ret = false;
			
		
		if(actorAttacker && actorVictim)
		{
			inv = actorAttacker.GetInventory();
			actorAttacker.ProcessOnHitEffects(actorVictim, inv.IsItemSilverSwordUsableByPlayer(weaponId), inv.IsItemSteelSwordUsableByPlayer(weaponId), action.IsActionWitcherSign() );
		}
		
		return ret;
	}
	
	
	private function ApplyQuenBuffChanges()
	{
		var npc : CNewNPC;
		var protection : bool;
		var witcher : W3PlayerWitcher;
		var quenEntity : W3QuenEntity;
		var i : int;
		var buffs : array<EEffectType>;
	
		if(!actorVictim || !actorVictim.HasAlternateQuen())
			return;
		
		npc = (CNewNPC)actorVictim;
		if(npc)
		{
			if(!action.DealsAnyDamage())
				protection = true;
		}
		else
		{
			witcher = (W3PlayerWitcher)actorVictim;
			if(witcher)
			{
				quenEntity = (W3QuenEntity)witcher.GetCurrentSignEntity();
				if(quenEntity.GetBlockedAllDamage())
				{
					protection = true;
				}
			}
		}
		
		if(!protection)
			return;
			
		action.GetEffectTypes(buffs);
		for(i=buffs.Size()-1; i>=0; i -=1)
		{
			if(buffs[i] == EET_KnockdownTypeApplicator || IsKnockdownEffectType(buffs[i]))
				continue;
				
			action.RemoveBuff(i);
		}
	}
	
	
	
	
	private function ProcessDismemberment(wasFrozen : bool, dismemberExplosion : bool )
	{
		var hitDirection		: Vector;
		var usedWound			: name;
		var npcVictim			: CNewNPC;
		var wounds				: array< name >;
		var i					: int;
		var petard 				: W3Petard;
		var bolt 				: W3BoltProjectile;		
		var forcedRagdoll		: bool;
		var isExplosion			: bool;
		var dismembermentComp 	: CDismembermentComponent;
		var specialWounds		: array< name >;
		var useHitDirection		: bool;
		
		if(!actorVictim)
			return;
			
		dismembermentComp = (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' ));
		if(!dismembermentComp)
			return;
			
		if(wasFrozen)
		{
			ProcessFrostDismemberment();
			return;
		}
		
		forcedRagdoll = false;
		
		
		petard = (W3Petard)action.causer;
		bolt = (W3BoltProjectile)action.causer;
		
		if( dismemberExplosion || (attackAction && ( attackAction.GetAttackName() == 'attack_explosion' || attackAction.HasForceExplosionDismemberment() ))
			|| (petard && petard.DismembersOnKill()) || (bolt && bolt.DismembersOnKill()) )
		{
			isExplosion = true;
		}
		else
		{
			isExplosion = false;
		}
		
		
		if(playerAttacker && thePlayer.forceDismember && IsNameValid(thePlayer.forceDismemberName))
		{
			usedWound = thePlayer.forceDismemberName;
		}
		else
		{	
			
			if(isExplosion)
			{
				dismembermentComp.GetWoundsNames( wounds, WTF_Explosion );								
				if ( wounds.Size() > 0 )
					usedWound = wounds[ RandRange( wounds.Size() ) ];
					
				if ( usedWound )
					StopVO( actorVictim ); 
			}
			else if(attackAction || action.GetBuffSourceName() == "riderHit")
			{
				if  ( attackAction.GetAttackTypeName() == 'sword_s2' || thePlayer.isInFinisher )
					useHitDirection = true;
				
				if ( useHitDirection ) 
				{
					hitDirection = actorAttacker.GetSwordTipMovementFromAnimation( attackAction.GetAttackAnimName(), attackAction.GetHitTime(), 0.1, attackAction.GetWeaponEntity() );
					usedWound = actorVictim.GetNearestWoundForBone( attackAction.GetHitBoneIndex(), hitDirection, WTF_Cut );
				}
				else
				{			
					
					dismembermentComp.GetWoundsNames( wounds );
					
					
					if(wounds.Size() > 0)
					{
						dismembermentComp.GetWoundsNames( specialWounds, WTF_Explosion );
						for ( i = 0; i < specialWounds.Size(); i += 1 )
						{
							wounds.Remove( specialWounds[i] );
						}
						
						if(wounds.Size() > 0)
						{
							
							dismembermentComp.GetWoundsNames( specialWounds, WTF_Frost );
							for ( i = 0; i < specialWounds.Size(); i += 1 )
							{
								wounds.Remove( specialWounds[i] );
							}
							
							
							if ( wounds.Size() > 0 )
								usedWound = wounds[ RandRange( wounds.Size() ) ];
						}
					}
				}
			}
		}
		
		if ( usedWound )
		{
			npcVictim = (CNewNPC)action.victim;
			if(npcVictim)
				npcVictim.DisableAgony();			
			
			actorVictim.SetDismembermentInfo( usedWound, actorVictim.GetWorldPosition() - actorAttacker.GetWorldPosition(), forcedRagdoll );
			actorVictim.AddTimer( 'DelayedDismemberTimer', 0.05f );
			
			
			if ( usedWound == 'explode_02' || usedWound == 'explode2' )
			{
				ProcessDismembermentDeathAnim( usedWound, true, EFDT_LegLeft );
				actorVictim.SetKinematic( false );
				
			}
			else
				ProcessDismembermentDeathAnim( usedWound, false );
			
			DropEquipmentFromDismember( usedWound, true, true );
			
			if( attackAction )			
				GCameraShake( 0.5, false, actorAttacker.GetWorldPosition(), 10);
				
			if(playerAttacker)
				theGame.VibrateControllerHard();	
		}
		else
		{
			LogChannel( 'Dismemberment', "ERROR: No wound found to dismember on entity but entity supports dismemberment!!!" );
		}
	}
	
	function ApplyForce()
	{
		var size, i : int;
		var victim : CNewNPC;
		var fromPos, toPos : Vector;
		var comps : array<CComponent>;
		var impulse : Vector;
		
		victim = (CNewNPC)action.victim;
		toPos = victim.GetWorldPosition();
		toPos.Z += 1.0f;
		fromPos = toPos;
		fromPos.Z -= 2.0f;
		impulse = VecNormalize( toPos - fromPos.Z ) * 10;
		
		comps = victim.GetComponentsByClassName('CComponent');
		victim.GetVisualDebug().AddArrow( 'applyForce', fromPos, toPos, 1, 0.2f, 0.2f, true, Color( 0,0,255 ), true, 5.0f );
		size = comps.Size();
		for( i = 0; i < size; i += 1 )
		{
			comps[i].ApplyLocalImpulseToPhysicalObject( impulse );
		}
	}
	
	private function ProcessFrostDismemberment()
	{
		var dismembermentComp 	: CDismembermentComponent;
		var wounds				: array< name >;
		var wound				: name;
		var i					: int;
		var npcVictim			: CNewNPC;
		
		dismembermentComp = (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' ));
		if(!dismembermentComp)
			return;
		
		dismembermentComp.GetWoundsNames( wounds, WTF_Frost );		
		if ( wounds.Size() > 0 )
		{
			wound = wounds[ RandRange( wounds.Size() ) ];
		}
		else
		{
			return;
		}
		
		npcVictim = (CNewNPC)action.victim;
		if(npcVictim)
		{
			npcVictim.DisableAgony();
			StopVO( npcVictim );
		}
	
		actorVictim.SetDismembermentInfo( wound, actorVictim.GetWorldPosition() - actorAttacker.GetWorldPosition(), true );
		actorVictim.AddTimer( 'DelayedDismemberTimer', 0.05f );
		ProcessDismembermentDeathAnim( wound, false );
		DropEquipmentFromDismember( wound, true, true );
		
		if( attackAction )			
			GCameraShake( 0.5, false, actorAttacker.GetWorldPosition(), 10);
			
		if(playerAttacker)
			theGame.VibrateControllerHard();	
	}
	
	
	private function ProcessDismembermentDeathAnim( nearestWound : name, forceDeathType : bool, optional deathType : EFinisherDeathType )
	{
		var dropCurveName : name;
		
		if ( forceDeathType )
		{
			if ( deathType == EFDT_Head )
				StopVO( actorVictim );
				
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)deathType );
			
			return;
		}
		
		dropCurveName = ( (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' )) ).GetMainCurveName( nearestWound );
		
		if ( dropCurveName == 'head' )
		{
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_Head );
			StopVO( actorVictim );
		}
		else if ( dropCurveName == 'torso_left' || dropCurveName == 'torso_right' || dropCurveName == 'torso' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_Torso );
		else if ( dropCurveName == 'arm_right' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_ArmRight );
		else if ( dropCurveName == 'arm_left' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_ArmLeft );
		else if ( dropCurveName == 'leg_left' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_LegLeft );
		else if ( dropCurveName == 'leg_right' )
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_LegRight );
		else 
			actorVictim.SetBehaviorVariable( 'FinisherDeathType', (int)EFDT_None );
	}
	
	private function StopVO( actor : CActor )
	{
		actor.SoundEvent( "grunt_vo_death_stop", 'head' );
	}

	private function DropEquipmentFromDismember( nearestWound : name, optional dropLeft, dropRight : bool )
	{
		var dropCurveName : name;
		
		dropCurveName = ( (CDismembermentComponent)(actorVictim.GetComponentByClassName( 'CDismembermentComponent' )) ).GetMainCurveName( nearestWound );
		
		if ( ChangeHeldItemAppearance() )
		{
			actorVictim.SignalGameplayEvent('DropWeaponsInDeathTask');
			return;
		}
		
		if ( dropLeft || dropRight )
		{
			
			if ( dropLeft )
				actorVictim.DropItemFromSlot( 'l_weapon', true );
			
			if ( dropRight )
				actorVictim.DropItemFromSlot( 'r_weapon', true );			
			
			return;
		}
		
		if ( dropCurveName == 'arm_right' )
			actorVictim.DropItemFromSlot( 'r_weapon', true );
		else if ( dropCurveName == 'arm_left' )
			actorVictim.DropItemFromSlot( 'l_weapon', true );
		else if ( dropCurveName == 'torso_left' || dropCurveName == 'torso_right' || dropCurveName == 'torso' )
		{
			actorVictim.DropItemFromSlot( 'l_weapon', true );
			actorVictim.DropItemFromSlot( 'r_weapon', true );
		}			
		else if ( dropCurveName == 'head' || dropCurveName == 'leg_left' || dropCurveName == 'leg_right' )
		{
			if(  RandRange(100) < 50 )
				actorVictim.DropItemFromSlot( 'l_weapon', true );
			
			if(  RandRange(100) < 50 )
				actorVictim.DropItemFromSlot( 'r_weapon', true );
		} 
	}
	
	function ChangeHeldItemAppearance() : bool
	{
		var inv : CInventoryComponent;
		var weapon : SItemUniqueId;
		
		inv = actorVictim.GetInventory();
		
		weapon = inv.GetItemFromSlot('l_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return true;
		}
		
		weapon = inv.GetItemFromSlot('r_weapon');
		
		if ( inv.IsIdValid( weapon ) )
		{
			if ( inv.ItemHasTag(weapon,'bow') || inv.ItemHasTag(weapon,'crossbow') )
				inv.GetItemEntityUnsafe(weapon).ApplyAppearance("rigid");
			return true;
		}
	
		return false;
	}
	
	
	private function GetOilProtectionAgainstMonster(dmgType : name, out resist : float, out reduct : float)
	{
		var vsMonsterAttributeName : name;
		var oilTypeMatches, isPointResist : bool;
		var i, j : int;
		var abs, atts : array<name>;
		var requiredResist : ECharacterDefenseStats;
		var val : float;
		var valMin, valMax : SAbilityAttributeValue;
		var heldWeapons : array<SItemUniqueId>;
		var weapon : SItemUniqueId;
		
		resist = 0;
		reduct = 0;
		vsMonsterAttributeName = MonsterCategoryToAttackPowerBonus(attackerMonsterCategory);
		
		
		heldWeapons = thePlayer.inv.GetHeldWeapons();
		
		
		for(i=0; i<heldWeapons.Size(); i+=1)
		{
			if(!thePlayer.inv.IsItemFists(heldWeapons[i]))
			{
				weapon = heldWeapons[i];
				break;
			}
		}
		
		
		if(!thePlayer.inv.IsIdValid(weapon))
			return;
		
		thePlayer.inv.GetItemAbilities(weapon, abs);
		for(i=0; i<abs.Size(); i+=1)
		{
			
			if(dm.AbilityHasTag(abs[i], theGame.params.OIL_ABILITY_TAG))
			{
				dm.GetAbilityAttributes(abs[i], atts);
				oilTypeMatches = false;
				
				
				for(j=0; j<atts.Size(); j+=1)
				{
					if(vsMonsterAttributeName == atts[j])
					{
						oilTypeMatches = true;
						break;
					}
				}
				
				if(!oilTypeMatches)
					break;
					
				
				resist = CalculateAttributeValue(thePlayer.GetSkillAttributeValue(S_Alchemy_s05, 'defence_bonus', false, true));
				
				
				
				return;
			}
		}
	}
	
	
	private function ProcessToxicCloudDismemberExplosion(damages : array<SRawDamage>)
	{
		var act : W3DamageAction;
		var i, j : int;
		var ents : array<CGameplayEntity>;
		
		
		if(damages.Size() == 0)
		{
			LogAssert(false, "W3DamageManagerProcessor.ProcessToxicCloudDismemberExplosion: trying to process but no damages are passed! Aborting!");
			return;
		}		
		
		
		FindGameplayEntitiesInSphere(ents, action.victim.GetWorldPosition(), 3, 1000, , FLAG_OnlyAliveActors);
		
		
		for(i=0; i<ents.Size(); i+=1)
		{
			act = new W3DamageAction in this;
			act.Initialize(action.attacker, ents[i], action.causer, 'Dragons_Dream_3', EHRT_Heavy, CPS_Undefined, false, false, false, true);
			
			for(j=0; j<damages.Size(); j+=1)
			{
				act.AddDamage(damages[j].dmgType, damages[j].dmgVal);
			}
			
			theGame.damageMgr.ProcessAction(act);
			delete act;
		}
	}
	
	
	private final function ProcessSparksFromNoDamage()
	{
		var sparksEntity, weaponEntity : CEntity;
		var weaponTipPosition : Vector;
		var weaponSlotMatrix : Matrix;
		
		
		if(!playerAttacker || !attackAction || !attackAction.IsActionMelee() || attackAction.DealsAnyDamage())
			return;
			
		
		if(!attackAction.DidArmorReduceDamageToZero() || attackAction.IsParried() || attackAction.IsCountered() )
			return;
			
		
		if(actorVictim.HasTag('NoSparksOnArmorDmgReduced'))
			return;
			
		
		weaponEntity = playerAttacker.inv.GetItemEntityUnsafe(weaponId);
		weaponEntity.CalcEntitySlotMatrix( 'blood_fx_point', weaponSlotMatrix );
		weaponTipPosition = MatrixGetTranslation( weaponSlotMatrix );
		
		
		sparksEntity = theGame.CreateEntity( (CEntityTemplate)LoadResource( 'sword_colision_fx' ), weaponTipPosition );
		sparksEntity.PlayEffect('sparks');
	}
	
	private function ProcessPreHitModifications()
	{
		var fireDamage, totalDmg : float;
		var attribute : SAbilityAttributeValue;
		var infusion : ESignType;
		var hack : array< SIgniEffects >;
		var dmgValTemp : float;
		var igni : W3IgniEntity;
		var template : CEntityTemplate;
		var quen : W3QuenEntity;

		if( actorVictim.HasAbility( 'HitWindowOpened' ) && !action.IsDoTDamage() )
		{
			quen = (W3QuenEntity)action.causer; 
			
			if( !quen )
			{
				action.ClearDamage();
				if( action.IsActionMelee() )
				{
					actorVictim.PlayEffect( 'special_attack_break' );
				}
				actorVictim.SetBehaviorVariable( 'repelType', 0 );
				
				actorVictim.AddEffectDefault( EET_CounterStrikeHit, thePlayer ); 
				action.RemoveBuffsByType( EET_KnockdownTypeApplicator );
			
				((CNewNPC)actorVictim).SetHitWindowOpened( false );
			}
		}
		
		
		
		if(action.attacker == thePlayer && attackAction && attackAction.IsActionMelee() && (W3PlayerWitcher)thePlayer && thePlayer.HasAbility('Runeword 1 _Stats', true))
		{
			infusion = GetWitcherPlayer().GetRunewordInfusionType();
			
			switch(infusion)
			{
				case ST_Aard:
					action.AddEffectInfo(EET_KnockdownTypeApplicator);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					template = (CEntityTemplate)LoadResource('runeword_1_aard');
					if(action.victim.GetBoneIndex('pelvis') != -1)
						theGame.CreateEntity(template, action.victim.GetBoneWorldPosition('pelvis'), action.victim.GetWorldRotation(), , , true);
					else
						theGame.CreateEntity(template, action.victim.GetBoneWorldPosition('k_pelvis_g'), action.victim.GetWorldRotation(), , , true);
						
					break;
				case ST_Axii:
					action.AddEffectInfo(EET_Confusion);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					break;
				case ST_Igni:
					
					totalDmg = action.GetDamageValueTotal();
					attribute = thePlayer.GetAttributeValue('runeword1_fire_dmg');
					fireDamage = totalDmg * attribute.valueMultiplicative;
					action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, fireDamage);
					
					
					action.SetCanPlayHitParticle(false);					
					action.victim.AddTimer('Runeword1DisableFireFX', 1.f);
					action.SetHitReactionType(EHRT_Heavy);	
					action.victim.PlayEffect('critical_burning');
					break;
				case ST_Yrden:
					attribute = thePlayer.GetAttributeValue('runeword1_yrden_duration');
					action.AddEffectInfo(EET_Slowdown, attribute.valueAdditive);
					action.SetProcessBuffsIfNoDamage(true);
					attackAction.SetApplyBuffsIfParried(true);
					break;
				default:		
					break;
			}
		}
	}
}

exec function ForceDismember( b: bool, optional chance : int, optional n : name, optional e : bool )
{
	var temp : CR4Player;
	
	temp = thePlayer;
	temp.forceDismember = b;
	temp.forceDismemberName = n;
	temp.forceDismemberChance = chance;
	temp.forceDismemberExplosion = e;
} 

exec function ForceFinisher( b: bool, optional n : name, optional rightStance : bool )
{
	var temp : CR4Player;
	
	temp = thePlayer;
	temp.forcedStance = rightStance;
	temp.forceFinisher = b;
	temp.forceFinisherAnimName = n;
} 
