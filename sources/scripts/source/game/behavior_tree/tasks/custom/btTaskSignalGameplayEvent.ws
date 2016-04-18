/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class CBTTaskSignalGameplayEvent extends IBehTreeTask
{
	var onActivate : bool;
	var onDeactivate : bool;
	var onSuccess : bool;
	
	var eventName : name;
	
	function IsAvailable() : bool
	{
		if (eventName)
			return true;
			
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
			GetNPC().SignalGameplayEvent(eventName);
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
			GetNPC().SignalGameplayEvent(eventName);
	}
	
	function OnCompletion( success : bool )
	{
		if ( onSuccess && success )
			GetNPC().SignalGameplayEvent(eventName);
	}
	
}

class CBTTaskSignalGameplayEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSignalGameplayEvent';

	editable var eventName : name;
	editable var onActivate : bool;
	editable var onDeactivate : bool;
	editable var onSuccess : bool;
}

