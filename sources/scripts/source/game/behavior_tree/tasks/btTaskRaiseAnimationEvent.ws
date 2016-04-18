/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CBTTaskRaiseAnimationEvent extends IBehTreeTask
{	
	var eventName : CName;
	var forceEvent : Bool;
	function OnActivate() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		if ( forceEvent == false )
		{
			owner.RaiseEvent( eventName );
		}
		else
		{
			owner.RaiseForceEvent( eventName );
		}
		return BTNS_Active;
	}
};


class CBTTaskRaiseAnimationEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskRaiseAnimationEvent';

	editable var eventName : CName;
	editable var forceEvent : Bool;
};