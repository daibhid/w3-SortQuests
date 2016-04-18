/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CBTTaskChangeAppearance extends IBehTreeTask
{
	public var appearanceName		: name;
	public var onActivate 			: bool;
	public var onDectivate 		: bool;
	
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			GetActor().SetAppearance(appearanceName);
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDectivate )
		{
			GetActor().SetAppearance(appearanceName);
		}
	}
}

class CBTTaskChangeAppearanceDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskChangeAppearance';

	editable var appearanceName		: name;
	editable var onActivate 		: bool;
	editable var onDectivate 		: bool;
}