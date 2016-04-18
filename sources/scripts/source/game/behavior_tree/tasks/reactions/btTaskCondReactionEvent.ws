/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/







class CBTTaskCondReactionEvent extends IBehTreeTask
{
	var reactionEventName	: name;
	var eventReceived		: bool;
	
	
	function IsAvailable() : bool
	{
		if ( eventReceived )
		{
			return true;
		}
		return false;
	}
	
	function OnDeactivate()
	{
		eventReceived = false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == reactionEventName )
		{
			eventReceived = true;
			return true;
		}
		return false;
	}
};

class CBTTaskCondReactionEventDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskCondReactionEvent';

	editable var reactionEventName	: name;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		
		if ( IsNameValid( reactionEventName ) )
		{
			listenToGameplayEvents.PushBack( reactionEventName );
		}
	}
};
