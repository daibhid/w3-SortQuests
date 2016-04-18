/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CBTTaskSetBehVarOnAnimEvent extends IBehTreeTask
{
	var eventName 		: name;
	var behVarName 		: name;
	var behVarValue		: float;
	var eventReceived 	: bool;
	
	latent function Main()
	{
		var npc : CNewNPC = GetNPC();
		
		while ( true )
		{
			if ( eventReceived && IsNameValid(eventName) && eventName != 'AllowBlend' )
			{
				npc.SetBehaviorVariable( behVarName, behVarValue );
				eventReceived = false;
			}
		}
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
	
	
		if ( eventReceived && IsNameValid(eventName) && eventName == 'AllowBlend' )
		{
			npc.SetBehaviorVariable( behVarName, behVarValue );
			eventReceived = false;
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == eventName )
		{
			eventReceived = true;
			return true;
		}
		
		return false;
	}
};

class CBTTaskSetBehVarOnAnimEventDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetBehVarOnAnimEvent';

	editable var eventName 		: name;
	editable var behVarName 	: name;
	editable var behVarValue	: float;
	
	default eventName = 'AllowBlend';
};
