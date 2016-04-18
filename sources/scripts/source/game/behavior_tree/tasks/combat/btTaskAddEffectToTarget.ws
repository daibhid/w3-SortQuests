/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CBTTaskAddEffectToTarget extends IBehTreeTask
{
	var onActivate		: bool;
	var onEvent			: bool;
	var onDeactivate	: bool;
	var eventName		: name;
	var effectType		: EEffectType;
	var effectDuration	: float;
	var effectValue		: float;
	var effectValuePerc	: float;
	var applyOnOwner	: bool;

	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			ApplyEffect();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			ApplyEffect();
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'eventName')
		{
			ApplyEffect();
			return true;
		}
		return false;
	}
	
	function ApplyEffect()
	{
		var npc		: CNewNPC = GetNPC();
		var target	: CActor = GetCombatTarget();
		var params 	: SCustomEffectParams;
		
		params.effectType = effectType;
		params.creator = npc;
		params.sourceName = npc.GetName();
		params.duration = effectDuration;
		
		if ( effectValue > 0 )
			params.effectValue.valueAdditive = effectValue;
		
		if ( effectValuePerc > 0 )
			params.effectValue.valueMultiplicative = effectValuePerc;
		
		if( target && !applyOnOwner )
		{
			target.AddEffectCustom(params);
		}
		else if( applyOnOwner )
		{
			GetNPC().AddEffectCustom(params);
		}
	}
};

class CBTTaskAddEffectToTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskAddEffectToTarget';

	editable var onActivate			: bool;
	editable var onEvent			: bool;
	editable var onDeactivate		: bool;
	editable var eventName			: name;
	editable var effectType			: EEffectType;
	editable var effectDuration		: float;
	editable var effectValue		: float;
	editable var effectValuePerc	: float;
	editable var applyOnOwner		: bool;
	
	default onActivate = true;
	default effectDuration = 1.0f;
	default applyOnOwner = false;
};