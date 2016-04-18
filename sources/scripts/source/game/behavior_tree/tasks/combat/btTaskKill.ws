/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/











class CBTTaskKill extends IBehTreeTask
{
	var actor, owner	: CActor;
	
	var self 			: bool;
	var target			: bool;
	var player			: bool;
	var onDamageTaken	: bool;
	var onAardHit		: bool;
	var onIgniHit		: bool;
	var onAxiiHit		: bool;
	var onActivate 		: bool;
	var onDeactivate 	: bool;
	

	function OnActivate() : EBTNodeStatus
	{	
		if ( onActivate )
		{
			Execute();
		}
		
		return BTNS_Active;
	}	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			Execute();
		}
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( onAardHit && eventName == 'AardHitReceived' )
		{
			Execute();
			return true;
		}
		
		if ( onIgniHit && eventName == 'IgniHitReceived' )
		{
			Execute();
			return true;
		}
		
		if ( onIgniHit && eventName == 'AxiiHitReceived' )
		{
			Execute();
			return true;
		}
		
		if ( onDamageTaken && eventName == 'DamageTaken' )
		{
			Execute();
			return true;
		}
		
		return false;
	}
	
	function Execute()
	{
		actor = GetCombatTarget();
		owner = GetActor();
		
		if ( target && actor.IsAlive() )
		{
			actor.Kill();
		}
		if ( player && thePlayer.IsAlive() )
		{
			thePlayer.Kill();
		}
		if ( self && owner.IsAlive() )
		{
			owner.Kill();
		}
	}
}

class CBTTaskKillDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskKill';

	editable var onActivate 				: bool;
	editable var onDeactivate 				: bool;
	editable var target						: bool;
	editable var player						: bool;
	editable var self						: bool;
	editable var onAardHit					: bool;
	editable var onIgniHit					: bool;
	editable var onAxiiHit					: bool;
	editable var onDamageTaken				: bool;

	hint target = "Kills the current target.";
	hint player = "Kills the current player character.";
	hint self = "Kills the owner of the AI Tree.";
}