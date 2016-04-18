/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class BTCondIsChangingWeapon extends IBehTreeTask
{
	private var storageHandler : CAIStorageHandler;
	protected var combatDataStorage : CHumanAICombatStorage;
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		return combatDataStorage.IsProcessingItems();
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			storageHandler = InitializeCombatStorage();
			combatDataStorage = (CHumanAICombatStorage)storageHandler.Get();
		}
	}
}

class BTCondIsChangingWeaponDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsChangingWeapon';
}




class BTCondDoesChangingWeaponRequiresIdle extends IBehTreeTask
{
	private var storageHandler : CAIStorageHandler;
	protected var combatDataStorage : CHumanAICombatStorage;
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		return combatDataStorage.DoesProcessingRequiresIdle();
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			storageHandler = InitializeCombatStorage();
			combatDataStorage = (CHumanAICombatStorage)storageHandler.Get();
		}
	}
}

class BTCondDoesChangingWeaponRequiresIdleDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondDoesChangingWeaponRequiresIdle';
}