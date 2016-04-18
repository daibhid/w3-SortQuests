/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CBTTaskStopYrden extends IBehTreeTask
{
	var npc 					: CNewNPC;
	var yrden					: W3YrdenEntity;
	var yrdenIsActionTarget		: bool;
	var range					: float;
	var maxResults				: int;
	var onActivate				: bool;
	var onDeactivate			: bool;

	function OnActivate() : EBTNodeStatus
	{
		npc = GetNPC();
		
		if( yrdenIsActionTarget && onActivate )
		{
			yrden = (W3YrdenEntity) GetActionTarget();
			yrden.TimedCanceled( 0, 0 );
			yrden.OnSignAborted( true );
		}
		else if ( onActivate )
		{
			StopYrden();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate() 
	{
		if( yrdenIsActionTarget && onDeactivate )
		{
			yrden = (W3YrdenEntity) GetActionTarget();
			yrden.TimedCanceled( 0, 0 );
			yrden.OnSignAborted( true );
			
		}
		else if ( onDeactivate )
		{
			StopYrden();
		}
		
	}
	function StopYrden()
	{	
		var i			: int;
		var l_entities 	: array<CGameplayEntity>;
		var l_actor		: CActor;
		var l_yrden		: W3YrdenEntity;
		
		
		npc.RemoveAllBuffsOfType( EET_Burning );
		npc.RemoveAllBuffsOfType( EET_Frozen );
		npc.RemoveAllBuffsOfType( EET_Bleeding );
		npc.RemoveAllBuffsOfType( EET_SlowdownFrost );
		npc.RemoveAllBuffsOfType( EET_Slowdown );
		
		
		
		FindGameplayEntitiesInSphere( l_entities, npc.GetWorldPosition(), range, maxResults );
		
		for( i = 0; i < l_entities.Size(); i += 1 )
		{
			l_actor = (CActor) l_entities[i];
			if( l_actor )
			{
				
			}
			l_yrden = (W3YrdenEntity) l_entities[i];
			if( l_yrden )
			{
				l_yrden.TimedCanceled( 0, 0 );
				l_yrden.OnSignAborted( true );
			}
		}
		
		
	}
	
}
class CBTTaskStopYrdenDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskStopYrden';
		
	var npc 							: CNewNPC;
	var yrden							: CGameplayEntity;
	editable var yrdenIsActionTarget	: bool;
	editable var range					: float;
	editable var maxResults				: int;
	editable var onActivate				: bool;
	editable var onDeactivate			: bool;
}