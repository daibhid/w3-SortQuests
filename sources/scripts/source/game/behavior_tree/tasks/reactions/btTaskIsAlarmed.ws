/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CBTTaskIsAlarmed extends IBehTreeTask
{
	protected var storageHandler 	: CAIStorageHandler;
	protected var reactionDataStorage : CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		return reactionDataStorage.IsAlarmed(GetLocalTime());
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	function Initialize()
	{
		storageHandler = new CAIStorageHandler in this;
		storageHandler.Initialize( 'ReactionData', '*CAIStorageReactionData', this );
		reactionDataStorage = (CAIStorageReactionData)storageHandler.Get();
	}
	
}

class CBTTaskIsAlarmedDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskIsAlarmed';
}

class CBTTaskIsAngry extends IBehTreeTask
{
	protected var storageHandler 	: CAIStorageHandler;
	protected var reactionDataStorage : CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		return reactionDataStorage.IsAngry(GetLocalTime());
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	function Initialize()
	{
		storageHandler = new CAIStorageHandler in this;
		storageHandler.Initialize( 'ReactionData', '*CAIStorageReactionData', this );
		reactionDataStorage = (CAIStorageReactionData)storageHandler.Get();
	}
	
}

class CBTTaskIsAngryDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskIsAngry';
}

