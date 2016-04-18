/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




import abstract class W3AbilityManager extends IScriptable
{
	
	
	

	import var owner : CActor;												
	import var charStats : CCharacterStats;									
	import saved var usedDifficultyMode : EDifficultyMode;					
	import var difficultyAbilities : array< array< name > >;				
	import var ignoresDifficultySettings : bool;							
	private var overhealBonus : float;

	import final function CacheStaticScriptData();
	import final function SetInitialStats( diff : EDifficultyMode ) : bool;
	import final function FixInitialStats( diff : EDifficultyMode ) : bool;
	
	import final function HasStat( stat : EBaseCharacterStats ) : bool;
	import final function StatAddNew( stat : EBaseCharacterStats, optional max : float );
	import final function RestoreStat( stat : EBaseCharacterStats );
	import final function RestoreStats();
	import  	 function GetStat( stat : EBaseCharacterStats, optional skipLock : bool ) : float;
	public final function GetStatMax( stat : EBaseCharacterStats ) : float;
	public final function GetStatPercents( stat : EBaseCharacterStats ) : float;
	import final function GetStats( stat : EBaseCharacterStats, out current : float, out max : float ) : bool;
	import final function SetStatPointCurrent( stat : EBaseCharacterStats, val : float );
	import final function SetStatPointMax( stat : EBaseCharacterStats, val : float );
	import final function UpdateStatMax( stat : EBaseCharacterStats );
	
	import final function HasResistStat( stat : ECharacterDefenseStats ) : bool;
	import final function GetResistStat( stat : ECharacterDefenseStats, out resistStat: SResistanceValue ) : bool;
	import final function SetResistStat( stat : ECharacterDefenseStats, out resistStat: SResistanceValue );
	import final function ResistStatAddNew( stat : ECharacterDefenseStats );
	import  	 function RecalcResistStat( stat : ECharacterDefenseStats );
	
	import  	 function GetAttributeValueInternal( attributeName : name, optional tags : array< name > ) : SAbilityAttributeValue;
	
	import final function CacheDifficultyAbilities();
	import final function UpdateStatsForDifficultyLevel( diff : EDifficultyMode );
	import final function UpdateDifficultyAbilities( diff : EDifficultyMode );
	
	
	import final function GetAllStats_Debug( out stats : array< SBaseStat > ) : bool;
	import final function GetAllResistStats_Debug( out stats : array< SResistanceValue > ) : bool;

	protected var isInitialized : bool;										
	protected saved var blockedAbilities : array<SBlockedAbility>;			
		default isInitialized = false;										
	
	
	public function PostInit();
		
	
	public function Init(ownr : CActor, cStats : CCharacterStats, isFromLoad : bool, diff : EDifficultyMode) : bool
	{
		var abs : array<name>;
		var i : int;
		var dm : CDefinitionsManagerAccessor;

		isInitialized = false;		
		difficultyAbilities.Clear();
		ignoresDifficultySettings = false;
		
		CacheStaticScriptData();
		
		owner = ownr;
		charStats = cStats;
		dm = theGame.GetDefinitionsManager();
				
		
		charStats.GetAbilities(abs);
		for(i=0; i<abs.Size(); i+=1)
		{
			if(dm.AbilityHasTag(abs[i], theGame.params.DIFFICULTY_TAG_IGNORE))
			{
				ignoresDifficultySettings = true;
				break;
			}
		}
		
		
		if(!ignoresDifficultySettings)
			difficultyAbilities.Resize(EnumGetMax('EDifficultyMode')+1);
		
		
		if(!isFromLoad)
		{
			usedDifficultyMode = EDM_NotSet;
			
			if(!SetInitialStats(diff))
				return false;
		}
		else
		{
			if ( !FixInitialStats(diff) )
			{
				if(!ignoresDifficultySettings)
				{
					CacheDifficultyAbilities();
				}
			}
		}
		
		
		
		
		if(!ignoresDifficultySettings && usedDifficultyMode != diff)
		{
			UpdateStatsForDifficultyLevel(diff);
		}
		
		return true;
	}
	
	public final function IsInitialized() : bool 		{return isInitialized;}
	
	
	
	public function OnOwnerRevived()
	{
		var i : int;
		
		RestoreStats();
		
		for(i=blockedAbilities.Size()-1; i>=0; i-=1)
		{
			if(blockedAbilities[i].timeWhenEnabledd > 0)
				blockedAbilities.EraseFast(i);
		}
	}
	
	
	
	
	
	
	protected function CheckForbiddenAttribute(attName : name) : bool
	{
		if( theGame.params.IsForbiddenAttribute(attName) )
		{
			LogAssert(false, "W3AbilityManager.CheckForbiddenAttribute: you are trying to get attribute <<" + attName + ">> in a wrong way - use propper custom function instead!");
			return true;
		}
		
		return false;
	}
	
	
	public function GetAttributeValue(attributeName : name, optional tags : array<name>) : SAbilityAttributeValue
	{
		var val : SAbilityAttributeValue;
	
		if(CheckForbiddenAttribute(attributeName))
		{
			val.valueBase = -9999;
			val.valueAdditive = -9999;
			val.valueMultiplicative = 100;
			return val;
		}
		
		return GetAttributeValueInternal(attributeName, tags);
	}
	
	public function GetAbilityAttributeValue(abilityName : name, attributeName : name) : SAbilityAttributeValue
	{
		var val : SAbilityAttributeValue;
	
		if(CheckForbiddenAttribute(attributeName))
		{
			val.valueBase = -9999;
			val.valueAdditive = -9999;
			val.valueMultiplicative = 100;
			return val;
		}
		
		return charStats.GetAbilityAttributeValue(attributeName, abilityName);
	}
	
	
	
		
	
	
	
	
	protected function GetNonBlockedSkillAbilitiesList(tags : array<name>) : array<name>
	{
		var null : array<name>;
		return null;
	}
	
	
	
	public function CheckBlockedAbilities(dt : float) : float
	{
		var i : int;
		var min : float;
		
		min = 1000000;
		for(i = blockedAbilities.Size()-1; i>=0; i-=1)
		{
			if(blockedAbilities[i].timeWhenEnabledd != -1)
			{
				blockedAbilities[i].timeWhenEnabledd = MaxF(blockedAbilities[i].timeWhenEnabledd - dt, 0);
				
				if(blockedAbilities[i].timeWhenEnabledd == 0)		
				{
					BlockAbility(blockedAbilities[i].abilityName, false);	
				}
				else
				{
					min = MinF(min, blockedAbilities[i].timeWhenEnabledd);
				}
			}
		}
		
		if(min == 1000000)
			min = -1;
			
		return min;
	}
	
	
	protected final function FindBlockedAbility(abName : name) : int
	{
		var i : int;
		
		for(i=0; i<blockedAbilities.Size(); i+=1)
			if(blockedAbilities[i].abilityName == abName)
				return i;
				
		return -1;
	}
	
	
	public function BlockAbility(abilityName : name, block : bool, optional cooldown : float) : bool
	{		
		var i : int;
		var ab : SBlockedAbility;
		var min, cnt : float;
		var ret : bool;
				
		if(!IsNameValid(abilityName))
			return false;
				
		for(i=0; i<blockedAbilities.Size(); i+=1)
		{
			if(blockedAbilities[i].abilityName == abilityName)
			{
				if(!block)
				{	
					cnt = blockedAbilities[i].count;
					blockedAbilities.Erase(i);					
					if(cnt > 0)									
						charStats.AddAbility(abilityName, cnt);					
					
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		
		if(block)
		{
			ab.abilityName = abilityName;
			
			if(cooldown > 0)				
			{
				ab.timeWhenEnabledd = cooldown;
				
				
				min = cooldown;
				for(i=0; i<blockedAbilities.Size(); i+=1)
				{
					if(blockedAbilities[i].timeWhenEnabledd > 0)
					{
						min = MinF(min, blockedAbilities[i].timeWhenEnabledd);
					}
				}
				
				
				owner.AddTimer('CheckBlockedAbilities', min, , , , true);
			}
			else
			{
				ab.timeWhenEnabledd = -1;
			}
			
			
			ab.count = owner.GetAbilityCount(abilityName);
	
			
			ret = charStats.RemoveAbility(abilityName);
			blockedAbilities.PushBack(ab);
			return ret;
		}
		else
		{
			return false;
		}
	}
	
	public final function IsAbilityBlocked(abilityName : name) : bool
	{
		return FindBlockedAbility(abilityName) >= 0;
	}
		
	
	
	
	
	
	
	
	public function GetPowerStatValue(stat : ECharacterPowerStats, optional abilityTag : name) : SAbilityAttributeValue
	{
		var tags : array<name>;
		
		if(IsNameValid(abilityTag))
			tags.PushBack(abilityTag);
		return GetAttributeValueInternal(PowerStatEnumToName(stat), tags);
	}
	
	
	protected function MutliplyStatBy(stat : EBaseCharacterStats, val : float)
	{
		if(val > 0)
			SetStatPointCurrent(stat, MinF(val * GetStat(stat, true), GetStatMax(stat) ) );
	}
	
	
	public function GetResistValue(stat : ECharacterDefenseStats, out points : float, out percents : float)
	{
		var pts, prc, charPts, charPerc : SAbilityAttributeValue;
		var buff : W3Mutagen20_Effect;
		var resistStat : SResistanceValue; 
		
		if ( GetResistStat( stat, resistStat ) )
		{
			charPts = resistStat.points;
			charPerc = resistStat.percents;		
		}
		
		
		if(stat == CDS_DoTBurningDamageRes || stat == CDS_DoTPoisonDamageRes || stat == CDS_DoTBleedingDamageRes)
		{
			if(owner.HasBuff(EET_Mutagen20))
			{
				buff = (W3Mutagen20_Effect)owner.GetBuff(EET_Mutagen20);
				buff.GetResistBonus(stat, pts, prc);
				
				charPts = charPts + pts;
				charPerc = charPerc + prc;
			}
		}
		
		points = CalculateAttributeValue(charPts);
		percents = MinF(1, CalculateAttributeValue(charPerc));		
		return;
	}
	
	
	
	
	
	
	
	
	
	
	public function UsedHPType() : EBaseCharacterStats
	{
		var j : int;
		var hasEss, hasVit : bool;
		
		hasEss = HasStat( BCS_Essence ) && GetStatMax( BCS_Essence ) > 0.0f;
		hasVit = HasStat( BCS_Vitality ) && GetStatMax( BCS_Vitality ) > 0.0f;

		if(hasVit && !hasEss)
			return BCS_Vitality;
		else if(!hasVit && hasEss)
			return BCS_Essence;
		else
			return BCS_Undefined;
	}
	
	
	
	
	
	
	
	
	
		
	
	
	
	
	
	
		
	public function ForceSetStat( stat : EBaseCharacterStats, val : float )
	{
		var prev : float;
			
		prev = GetStat(stat);
		SetStatPointCurrent(stat, MinF(GetStatMax(stat), MaxF(0, val)) );
		
		if(prev != GetStat(stat))
		{
			if( stat == BCS_Vitality )
			{
				OnVitalityChanged();				
			}
			else if( stat == BCS_Toxicity )
			{
				OnToxicityChanged();
			}
			else if( stat == BCS_Focus )
			{
				OnFocusChanged();
			}
			else if( stat == BCS_Air )
			{
				OnAirChanged();
			}
		}
	}
	
	
	
	
	
	
	

	
	
	
	
	
	
	
	
	
	protected function InternalReduceStat(stat : EBaseCharacterStats, amount : float)
	{
		SetStatPointCurrent(stat, MaxF( 0, GetStat(stat, true) - MaxF( 0, amount ) ) );
	}
	
	public function DrainAir(cost : float, optional delay : float )
	{
		
		if(cost > 0)
		{			
			InternalReduceStat(BCS_Air, cost);
			owner.StartAirRegen();
		}
		
		
		if(delay > 0)
			owner.PauseEffects(EET_AutoAirRegen, 'AirCostDelay', false, delay);		
	}
	
	public function DrainSwimmingStamina(cost : float, optional delay : float )
	{
		if(cost > 0)
		{			
			InternalReduceStat(BCS_SwimmingStamina, cost);
			owner.StartSwimmingStaminaRegen();
		}
		
		
		if(delay > 0)
			owner.PauseEffects(EET_AutoSwimmingStaminaRegen, 'SwimmingStaminaCostDelay', false, delay);		
	}
	
	
	
	
	
	
	
	
	public function DrainStamina(action : EStaminaActionType, optional fixedCost : float, optional fixedDelay : float, optional abilityName : name, optional dt : float, optional costMult : float) : float
	{
		var cost, delay : float;

		GetStaminaActionCost(action, cost, delay, fixedCost, fixedDelay, abilityName, dt, costMult);
		
		
		if(cost > 0)
		{
			InternalReduceStat(BCS_Stamina, cost);
			owner.StartStaminaRegen();
		}
		
		
		if(delay > 0)
		{
			if(IsNameValid(abilityName))
				owner.PauseEffects(EET_AutoStaminaRegen, abilityName, true, delay, true);
			else
				owner.PauseEffects(EET_AutoStaminaRegen, StaminaActionTypeToName(action), true, delay, true);
		}
		
		return cost;
	}
	
	
	public function GetStaminaActionCost(action : EStaminaActionType, out cost : float, out delay : float, optional fixedCost : float, optional fixedDelay : float, optional abilityName : name, optional dt : float, optional costMult : float)
	{
		var costAtt, delayAtt : SAbilityAttributeValue;
		
		if(action == ESAT_FixedValue)
		{
			cost = fixedCost;
			delay = MaxF(0, fixedDelay);
		}
		else
		{
			GetStaminaActionCostInternal(action, dt > 0.0f, costAtt, delayAtt, abilityName);
	
			cost = CalculateAttributeValue(costAtt);
			delay = CalculateAttributeValue(delayAtt);
		}
		
		if(costMult != 0)
		{
			cost *= costMult;
		}
		
		if(dt > 0)
		{			
			cost *= dt;
		}
	}
	
	protected function GetStaminaActionCostInternal(action : EStaminaActionType, isPerSec : bool, out cost : SAbilityAttributeValue, out delay : SAbilityAttributeValue, optional abilityName : name)
	{
		var costAttributeName, delayAttributeName, attribute : name;
		var tags : array<name>;
		var val : SAbilityAttributeValue;
	
		
		cost = val;
		delay = val;
	
		theGame.params.GetStaminaActionAttributes(action, isPerSec, costAttributeName, delayAttributeName);
		
		
		if(action == ESAT_Ability)
		{
			if(isPerSec)
				attribute = theGame.params.STAMINA_COST_PER_SEC_DEFAULT;
			else 
				attribute = theGame.params.STAMINA_COST_DEFAULT;
				
			cost = GetSkillAttributeValue(abilityName, attribute, false, true);
			delay = GetSkillAttributeValue(abilityName, theGame.params.STAMINA_DELAY_DEFAULT, false, true);
		}
		
		else
		{
			cost = GetAttributeValueInternal(costAttributeName);
			delay = GetAttributeValueInternal(delayAttributeName);
		}
		
		cost += GetAttributeValueInternal('stamina_cost_modifier');
		delay += GetAttributeValueInternal('stamina_delay_modifier');
	}
	
	
	public function GetSkillAttributeValue(abilityName: name, attributeName : name, addBaseCharAttribute : bool, addSkillModsAttribute : bool) : SAbilityAttributeValue
	{
		var min, max :SAbilityAttributeValue;
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, attributeName, min, max);
		return GetAttributeRandomizedValue(min, max);
	}
	
	public function DrainFocus(amount : float )
	{
		InternalReduceStat(BCS_Focus, amount);
		OnFocusChanged();
	}
	
	public function DrainMorale(amount : float )
	{
		InternalReduceStat(BCS_Morale, amount);
		owner.StartMoraleRegen();
	}
	
	public function DrainToxicity(amount : float )
	{
		InternalReduceStat(BCS_Toxicity, amount);
		OnToxicityChanged();
	}
	
	
	public function DrainVitality(amount : float)
	{	
		SetStatPointCurrent(BCS_Vitality, MaxF( 0, GetStat(BCS_Vitality) - MaxF(0, amount) ));
		owner.StartVitalityRegen();
		
		if(GetStat(BCS_Vitality) <= 0 && owner.UsesVitality())
		{
			owner.SignalGameplayEvent( 'Death' );
			owner.SetAlive(false);
		}
		
		OnVitalityChanged();
	}
	
	
	public function DrainEssence(amount : float)
	{
		SetStatPointCurrent(BCS_Essence, MaxF( 0, GetStat(BCS_Essence) - MaxF(0, amount) ) );
		owner.StartEssenceRegen();
		
		if(GetStat(BCS_Essence) <= 0 && owner.UsesEssence())
		{
			owner.SignalGameplayEvent( 'Death' );
			owner.SetAlive(false);
		}
	}
	
	public function AddPanic( amount : float )
	{
		SetStatPointCurrent( BCS_Panic, RoundF(MaxF( 0, GetStat( BCS_Panic ) - amount )) );
		owner.StartPanicRegen();
	}
	
	
	
	
	public function GainStat( stat : EBaseCharacterStats, amount : float )
	{
		var statWithoutLock, statWithLock, lock, max : float;
		var hadOverheal : bool;
		var mi, ma : SAbilityAttributeValue;
		
		statWithoutLock = GetStat(stat, true);
		statWithLock = GetStat(stat, false);
		lock = statWithLock - statWithoutLock;
		max = GetStatMax(stat);
		
		SetStatPointCurrent(stat, MinF( max - lock, statWithoutLock + MaxF(0, amount) ) );
		
		if( stat == BCS_Vitality )
		{
			OnVitalityChanged();
			if ( (W3PlayerAbilityManager)this && owner == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 4 _Stats') && GetWitcherPlayer().IsInCombat() && (statWithoutLock + amount) > max )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 4 _Stats', 'max_bonus', mi, ma);				
				hadOverheal = (overhealBonus > (0.005 * GetStatMax(BCS_Vitality)));
				overhealBonus += (statWithoutLock + amount) - GetStatMax(stat);
				overhealBonus = MinF(overhealBonus, max * ma.valueMultiplicative);
				thePlayer.PlayRuneword4FX();				
			}
		}
		else if( stat == BCS_Toxicity )
			OnToxicityChanged();
		else if( stat == BCS_Focus )
			OnFocusChanged();
	}
	
	
	
	
	
	
	
	public function GetApplicatorParamsFor(applicator : W3ApplicatorEffect, out pwrStatValue : SAbilityAttributeValue)
	{
	}
	
	
	
	
	
	
	
	public function IgnoresDifficultySettings() : bool
	{
		return ignoresDifficultySettings;
	}
	
	
	
	
	
	protected function OnVitalityChanged();	
	protected function OnToxicityChanged();
	protected function OnFocusChanged();
	protected function OnAirChanged();
	
	
	public function OnAbilityAdded(abilityName : name)
	{
		var idx : int;
	
		if(!owner)
			return;		
	
		if(IsAbilityBlocked(abilityName))
		{
			idx = FindBlockedAbility(abilityName);
			blockedAbilities[idx].count += 1;			
			charStats.RemoveAbility(abilityName);		
			blockedAbilities[idx].count += 1;			
		}
		else
		{
			OnAbilityChanged(abilityName);
		}
	}
	
	
	public function OnAbilityRemoved(abilityName : name)
	{
		var idx : int;
		
		if(!owner)
			return;		
			
		if(IsAbilityBlocked(abilityName))
		{
			idx = FindBlockedAbility(abilityName);
			blockedAbilities[idx].count -= 1;
			
		}
		else
		{
			OnAbilityChanged(abilityName);
			
			if(abilityName == 'Runeword 4 _Stats')
				ResetOverhealBonus();
		}
	}
	
	
	protected function OnAbilityChanged(abilityName : name)
	{
		var atts, tags : array<name>;
		var i,size,stat, j : int;
		var oldMax, maxVit, maxEss : float;
		var resistStatChanged, tmpBool : bool;
		var dm : CDefinitionsManagerAccessor;
		var val : SAbilityAttributeValue;
		var buffs : array<CBaseGameplayEffect>;
		var regenBuff : W3RegenEffect;
		var cannotAddAttributes : array< name >;
				
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes(abilityName, atts);		
		resistStatChanged = false;
		size = atts.Size();
		
		
		if(dm.AbilityHasTag(abilityName, theGame.params.DIFFICULTY_TAG_IGNORE))
		{
			ignoresDifficultySettings = true;
			difficultyAbilities.Clear();
			usedDifficultyMode = EDM_NotSet;
		}
		
		
		
		owner.GetListOfCannotAddAttributes( cannotAddAttributes );
		
		for(i=0; i<size; i+=1)
		{					
			if ( cannotAddAttributes.Contains( atts[i] ) )
			{
				continue;
			}
		
			
			
			stat = StatNameToEnum(atts[i]);
			if(stat != BCS_Undefined)
			{
				if(!HasStat(stat))
				{
					
					StatAddNew(stat);
				}
				else
				{
					
					if(abilityName == theGame.params.GLOBAL_ENEMY_ABILITY || abilityName == theGame.params.GLOBAL_PLAYER_ABILITY || abilityName == theGame.params.ENEMY_BONUS_PER_LEVEL)
					{
						
						UpdateStatMax(stat);
						RestoreStat(stat);
					}
					else
					{
						
						oldMax = GetStatMax(stat);
						UpdateStatMax(stat);
						MutliplyStatBy(stat, GetStatMax(stat) / oldMax);
					}
				}
				continue;
			}
			
			
			stat = ResistStatNameToEnum(atts[i], tmpBool);
			if(stat != CDS_None)
			{
				if ( HasResistStat( stat ) )
				{
					RecalcResistStat(stat);
					resistStatChanged = true;
				}								
				else
				{
					
					ResistStatAddNew(stat);
				}
				
				continue;
			}
			
			
			stat = PowerStatNameToEnum(atts[i]);
			if(stat != CPS_Undefined)
			{
				owner.UpdateApplicatorBuffs();
				continue;
			}
			
			
			stat = RegenStatNameToEnum(atts[i]);
			if(stat != CRS_Undefined && stat != CRS_UNUSED)
			{
				buffs = owner.GetBuffs();
				
				for(j=0; j<buffs.Size(); j+=1)
				{
					regenBuff = (W3RegenEffect)buffs[j];
					if(regenBuff)
					{
						if(regenBuff.GetRegenStat() == stat && IsBuffAutoBuff(regenBuff.GetEffectType()))
						{
							regenBuff.UpdateEffectValue();
							break;
						}
					}
				}
				if( stat == CRS_Essence )
				{
					owner.StartEssenceRegen();
				}
			}
			
			
			if(!ignoresDifficultySettings && atts[i] == theGame.params.DIFFICULTY_HP_MULTIPLIER)
			{		
				

				maxVit = GetStatMax( BCS_Vitality );
				maxEss = GetStatMax( BCS_Essence );
				if(maxVit > 0)
				{
					oldMax = maxVit;
					UpdateStatMax(BCS_Vitality);					
					MutliplyStatBy(BCS_Vitality, GetStatMax(BCS_Vitality) / oldMax);
				}
				
				if(maxEss > 0)
				{
					oldMax = maxEss;
					UpdateStatMax(BCS_Essence);					
					MutliplyStatBy(BCS_Essence, GetStatMax(BCS_Essence) / oldMax);
				}
				
				continue;
			}		
		}
		
		if(resistStatChanged)
			owner.RecalcEffectDurations();
	}
	
	
	
	
	public function GetOverhealBonus() : float
	{
		return overhealBonus;
	}
	
	public function ResetOverhealBonus()
	{
		overhealBonus = 0;
		thePlayer.StopEffect('runeword_4');
	}
	
	
	
	
	
	public function Debug_GetUsedDifficultyMode() : EDifficultyMode
	{
		return usedDifficultyMode;
	}
}
