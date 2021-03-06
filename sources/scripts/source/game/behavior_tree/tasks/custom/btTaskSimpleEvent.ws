/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class CBTTaskSimpleEvent extends IBehTreeTask
{
	var available : bool;
	default available = false;

	var Delay : float;
	var Event : name;
	
	function IsAvailable() : bool
	{
		if ( isActive )
		{
			return true;
		}
		
		if (available)
		{
			return true;
		}
		
		return false;
	}
	
	function OnDeactivate()
	{
		available = false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == Event )
		{
			GetNPC().RaiseForceEvent(Event);
			available = true;
			return true;
		}
		return false;
	}
}

class CBTTaskSimpleEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSimpleEvent';

	editable var Delay : float;
	editable var Event : name;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		if ( IsNameValid( Event ) )
		{
			listenToGameplayEvents.PushBack( Event );
		}
	}
}

