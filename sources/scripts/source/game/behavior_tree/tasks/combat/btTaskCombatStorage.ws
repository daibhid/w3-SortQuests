/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CBTTaskCombatStorage extends IBehTreeTask
{
	protected var storageHandler 	: CAIStorageHandler;
	protected var combatDataStorage : CBaseAICombatStorage;
	
	public var setIsShooting 	: bool;
	public var setIsAiming 		: bool;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		InitializeCombatDataStorage();
		if ( setIsShooting )
			combatDataStorage.SetIsShooting( true );
		if ( setIsAiming )
			combatDataStorage.SetIsAiming( true );
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( setIsShooting )
			combatDataStorage.SetIsShooting( false );
		if ( setIsAiming )
			combatDataStorage.SetIsAiming( false );
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

class CBTTaskCombatStorageDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskCombatStorage';

	editable var setIsShooting 	: bool;
	editable var setIsAiming 	: bool;
}



class CBehTreeTaskCombatStorageCleanup extends IBehTreeTask
{
	private var storageHandler : CAIStorageHandler;
	protected var combatDataStorage : CHumanAICombatStorage;
	
	function OnActivate() : EBTNodeStatus
	{
		
		GetNPC().DisableLookAt();
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		InitializeCombatDataStorage();
		
		combatDataStorage.SetActiveCombatStyle( EBG_Combat_Undefined );
		combatDataStorage.SetPreCombatWarning(true);
		
		npc.SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)GMM_Default );
		
		npc.OnAllowBehGraphChange();
		
		npc.LowerGuard();
		
		combatDataStorage.DetachAndDestroyProjectile();
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

class CBehTreeTaskCombatStorageCleanupDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskCombatStorageCleanup';
}



class CBTTaskPreCombatWarning extends IBehTreeTask
{
	protected var storageHandler 	: CAIStorageHandler;
	protected var combatDataStorage : CBaseAICombatStorage;
	
		
	public var setFlagOnActivate 	: bool;
	public var setFlagOnDectivate 	: bool;
	
	public var flag : bool;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		InitializeCombatDataStorage();
		if ( setFlagOnActivate )
		{
			combatDataStorage.SetPreCombatWarning( flag );
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( setFlagOnDectivate )
		{
			combatDataStorage.SetPreCombatWarning( flag );
		}
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

class CBTTaskPreCombatWarningDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPreCombatWarning';

	editable var setFlagOnActivate : bool;
	editable var setFlagOnDectivate : bool;
	
	editable var flag : bool;
}






class CBTTaskGetPreCombatWarning extends IBehTreeTask
{
	protected var storageHandler 	: CAIStorageHandler;
	protected var combatDataStorage : CBaseAICombatStorage;
	
	public var setFlagOnActivate 	: bool;
	public var setFlagOnDectivate 	: bool;
	
	public var flag : bool;
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		return combatDataStorage.GetPreCombatWarning();
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

class CBTTaskGetPreCombatWarningDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskGetPreCombatWarning';
}