/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


class CBTTaskShouldBecomeAFollower extends IBehTreeTask
{
	protected var storageHandler : CAIStorageHandler;
	protected var combatDataStorage : CHumanAICombatStorage;
	
	
	function Initialize()
	{
		storageHandler = InitializeCombatStorage();
		combatDataStorage = (CHumanAICombatStorage)storageHandler.Get();
	}
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		if ( GetActor().HasTag(theGame.params.TAG_NPC_IN_PARTY) )
			combatDataStorage.BecomeAFollower();
		else
			combatDataStorage.NoLongerFollowing();
		
		return BTNS_Active;			
	}
}

class CBTTaskShouldBecomeAFollowerDef extends IBehTreeFollowerTaskDefinition
{
	default instanceClass = 'CBTTaskShouldBecomeAFollower';
}