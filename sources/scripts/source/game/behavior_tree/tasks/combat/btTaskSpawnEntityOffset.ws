/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CBTTaskSpawnEntityOffset extends CBTTaskPlayAnimationEventDecorator
{
	var positionOffset		: Vector;	
	var resourceName		: name;
	var entityTemplate		: CEntityTemplate;
	var spawnAnimEventName	: name;
	var completeAfterSpawn	: bool;
	
	protected var m_summonerComponent		: W3SummonerComponent;
	
	private var couldntLoadResource : bool;
	
	function Initialize()
	{
		m_summonerComponent = (W3SummonerComponent) GetNPC().GetComponentByClassName('W3SummonerComponent');
	}
	
	function IsAvailable() : bool
	{
		if ( couldntLoadResource )
		{
			return false;
		}
		return super.IsAvailable();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return super.OnActivate();
	}
	
	latent function Main() : EBTNodeStatus
	{
		if ( !entityTemplate )
		{
			entityTemplate = ( CEntityTemplate ) LoadResourceAsync( resourceName );
		}
		
		if ( !entityTemplate )
		{
			couldntLoadResource = true;
			return BTNS_Failed;
		}
		
		if ( !IsNameValid( spawnAnimEventName ))
		{
			SpawnEntity();
		}
		
		return BTNS_Active;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		if ( IsNameValid( spawnAnimEventName ) && animEventName == spawnAnimEventName )
		{
			SpawnEntity();
			return true;
		}
		
		return res;
	}
	
	function SpawnEntity()
	{
		var npc 		: CNewNPC = GetNPC();
		var matrix		: Matrix;
		var spawnPos 	: Vector;
		var entity 		: CEntity;
		
		matrix = npc.GetLocalToWorld();
		spawnPos = VecTransform( matrix, positionOffset);
		
		entity = theGame.CreateEntity( entityTemplate, spawnPos );
		
		if( m_summonerComponent )
		{
			m_summonerComponent.AddEntity( entity );
		}
		
		
		if( completeAfterSpawn )
		{
			Complete( true );
		}
	}
}

class CBTTaskSpawnEntityOffsetDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskSpawnEntityOffset';
	
	editable var resourceName		: CBehTreeValCName;
	editable var spawnAnimEventName	: name;
	editable var entityTemplate		: CEntityTemplate;
	editable var positionOffset		: Vector;	
	editable var completeAfterSpawn	: bool;
	
	
	default spawnAnimEventName = 'SpawnEntity';
}
