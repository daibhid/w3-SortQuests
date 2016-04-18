/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class CBTTaskManageFact extends IBehTreeTask
{
	var fact		: string;
	var value		: int;
	var validFor	: int;
	var add			: bool;
	var doNotCompleteAfter : bool;
	
	hint add = "false - remove fact";
	
	function OnActivate() : EBTNodeStatus
	{
		if( add )
		{
			FactsAdd( fact, value, validFor );
		}
		else
		{
			FactsRemove( fact );
		}
		
		if ( doNotCompleteAfter )
			return BTNS_Active;
			
		return BTNS_Completed;
	}
}

class CBTTaskManageFactDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskManageFact';

	editable var fact		: string;
	editable var value		: int;
	editable var add		: bool;
	editable var validFor	: int;
	editable var doNotCompleteAfter : bool;

	default add = true;
	default doNotCompleteAfter = false;
}