/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/










class BTTaskAddRemoveAbility extends IBehTreeTask
{
	
	
	
	var abilityName			: name;
	var allowMultiple		: bool;
	var removeAbility		: bool;
	var onDeactivate		: bool;
	var onAnimEventName		: name;
	
	
	function OnActivate() : EBTNodeStatus
	{
		if( !onDeactivate ) Execute();
		return BTNS_Active;
	}
	
	
	function OnDeactivate()
	{
		if( onDeactivate ) Execute();
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( onAnimEventName ) && animEventName == onAnimEventName )
		{
			Execute();
			return true;
		}
		return false;
	}
	
	
	private function Execute()
	{
		var l_npc : CNewNPC = GetNPC();
		
		if( removeAbility )
		{
			l_npc.RemoveAbility( abilityName );
		}
		else
		{
			l_npc.AddAbility( abilityName, allowMultiple );
		}
	}

}


class BTTaskAddRemoveAbilityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskAddRemoveAbility';
	
	
	
	editable var abilityName		: name;
	editable var allowMultiple		: bool;
	editable var removeAbility		: bool;
	editable var onDeactivate		: bool;
	editable var onAnimEventName	: name;
	
	default allowMultiple = true;
	
	hint onDeactivate = "Execute on deactivate instead on on Activate";
}
