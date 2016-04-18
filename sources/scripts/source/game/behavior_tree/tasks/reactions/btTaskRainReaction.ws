/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CBTTaskRainReaction extends IBehTreeTask
{
	protected var storageHandler 	: CAIStorageHandler;
	protected var reactionDataStorage : CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		return BTNS_Completed;
	}
	
	
	function Initialize()
	{
		storageHandler = new CAIStorageHandler in this;
		storageHandler.Initialize( 'ReactionData', '*CAIStorageReactionData', this );
		reactionDataStorage = (CAIStorageReactionData)storageHandler.Get();
	}
}

class CBTTaskRainReactionDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskRainReaction';
}
