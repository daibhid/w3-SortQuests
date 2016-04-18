/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CBTTaskPlayEffect extends IBehTreeTask
{
	var effectName 				: CName;
	var owner 					: CNewNPC;
	var onWeaponItem 	 		: bool;
	var turnOff 				: bool;
	var connectEffectWithTarget : bool;
	var onAnimEvent				: name;
	var onGameplayEvent			: name;
	var onActivate 				: bool;
	var onDeactivate 			: bool;
	var onSuccess 				: bool;
	var onFailure 				: bool;

	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			ProcessEffect();
		}
		return BTNS_Active;
	}
	
	function OnCompletion( success : bool )
	{
		if( success && onSuccess )
		{
			ProcessEffect();
		}
		if ( !success && onFailure )
		{
			ProcessEffect();
		}
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			ProcessEffect();
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( onAnimEvent ) && animEventName == onAnimEvent )
		{
			ProcessEffect();
			return true;
		}
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid( onGameplayEvent ) && eventName == onGameplayEvent )
		{
			ProcessEffect();
			return true;
		}
		return false;
	}
	
	function ProcessEffect()
	{
		var itemIds : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var i : int;
		
		owner = GetNPC();
		
		if ( onWeaponItem )
		{
			inv = owner.GetInventory();
			itemIds = inv.GetAllWeapons();
			
			for(i=0; i<itemIds.Size(); i+=1)
			{
				if ( turnOff )
				{
					if(inv.IsItemHeld(itemIds[i]))
						inv.StopItemEffect( itemIds[i], effectName );
				}
				else
				{
					if(inv.IsItemHeld(itemIds[i]))
						inv.PlayItemEffect( itemIds[i], effectName );
				}
			}
		}
		else
		{
			if ( turnOff )
			{
				owner.StopEffect ( effectName ) ;
			}
			else if ( connectEffectWithTarget )
			{
				owner.PlayEffect ( effectName, GetCombatTarget() );
			}
			else
			{
				owner.PlayEffect ( effectName ) ;
			}
		}
	}
}
class CBTTaskPlayEffectDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPlayEffect';

	editable var effectName 				: CBehTreeValCName;
	editable var onWeaponItem 				: bool;
	editable var turnOff 					: bool;
	editable var connectEffectWithTarget 	: bool;
	editable var onAnimEvent				: name;
	editable var onGameplayEvent			: name;
	editable var onActivate 				: bool;
	editable var onDeactivate 				: bool;
	editable var onSuccess 					: bool;
	editable var onFailure 					: bool;
	
	hint effectName = "Type valid name of the effect here.";
	hint turnOff = "Disables the effect instead of defaulting to turning the effect on.";
}