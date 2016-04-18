/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CBTCondHasTag extends IBehTreeTask
{
	public var tag		: name;
	
	function IsAvailable() : bool
	{
		return GetActor().HasTag( tag );
	}
};


class CBTCondHasTagDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondHasTag';

	editable var tag		: name;
};


















