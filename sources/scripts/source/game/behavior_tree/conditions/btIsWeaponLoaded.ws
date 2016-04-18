/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CBTCondIsWeaponLoaded extends IBehTreeTask
{	
	private var storageHandler : CAIStorageHandler;
	protected var combatDataStorage : CHumanAICombatStorage;
	
	function IsAvailable() : bool
	{
		if( combatDataStorage.GetProjectile() || combatDataStorage.ReturnWeaponSubTypeForActiveCombatStyle() == 0 ) 
		{
			return true;
		}
		return false;
	}
	
	function Initialize()
	{
		storageHandler = InitializeCombatStorage();
		combatDataStorage = (CHumanAICombatStorage)storageHandler.Get();
	}
};

class CBTCondIsWeaponLoadedDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsWeaponLoaded';
};