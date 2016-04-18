/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


class CBTTasFollowerShouldAttack extends IBehTreeTask
{
	protected var storageHandler : CAIStorageHandler;
	protected var combatDataStorage : CHumanAICombatStorage;
	
	
	function Initialize()
	{
		storageHandler = InitializeCombatStorage();
		combatDataStorage = (CHumanAICombatStorage)storageHandler.Get();
	}
	
	
	
	function IsAvailable() : bool
	{
		if ( combatDataStorage.IsAFollower() && GetCombatTarget() != thePlayer.GetTarget() )
			return true;
		
		return combatDataStorage.ShouldAttack( GetLocalTime() );
	}
	
	function OnActivate() : EBTNodeStatus
	{		
		return BTNS_Active;			
	}
}

class CBTTasFollowerShouldAttackDef extends IBehTreeFollowerTaskDefinition
{
	default instanceClass = 'CBTTasFollowerShouldAttack';
}