/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class BTCondIsGuarded extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetActor().IsGuarded();
	}
}

class BTCondIsGuardedDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsGuarded';
}

class BTCondIsTargetGuarded extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetCombatTarget().IsGuarded();
	}
}

class BTCondIsTargetGuardedDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsTargetGuarded';
}