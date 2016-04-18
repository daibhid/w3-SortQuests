/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CBTTaskSpawnFXEntity extends IBehTreeTask
{
	var attachToActor					: bool;
	var useNodeWithTag					: bool;
	var referenceNodeTag				: name;
	var useOnlyOneFXEntity				: bool;
	var useTargetInsteadOfOwner			: bool;
	var useCombatTarget					: bool;
	var baseOffsetOnCasterRotation		: bool;
	var attachToSlotName				: name;
	var resourceName					: name;
	var spawnAfter						: float;
	var spawnOnAnimEvent				: name;
	var spawnOnGameplayEvent			: name;
	var fxNameOnSpawn					: name;
	var fxEntityTag						: name;
	var destroyEntityAfter				: float;
	var destroyEntityOnAnimEvent		: name;
	var destroyEntityOnDeact			: bool;
	var stopAllEffectsAfter				: float;
	var offsetVector	 				: Vector;
	var additionalRotation				: EulerAngles;
	
	protected var attachedTo 			: CEntity;
	protected var entity 				: CEntity;
	protected var entityTemplate		: CEntityTemplate;
	private   var spawned				: bool;
	
	function OnActivate() : EBTNodeStatus
	{
		spawned = false;
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
		
		if( entityTemplate && !IsNameValid( spawnOnGameplayEvent ) && !IsNameValid( spawnOnAnimEvent ) && spawnAfter <= 0 )
		{
			SpawnEntity();
		}
		
		if( spawnAfter > 0 )
		{
			Sleep( spawnAfter );
			if( entityTemplate && !spawned )
				SpawnEntity();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( destroyEntityOnDeact && destroyEntityAfter <= 0.0 && entity )
		{
			entity.StopAllEffects();
			entity.DestroyAfter( 1.0 );
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( IsNameValid( spawnOnAnimEvent ) && animEventName == spawnOnAnimEvent )
		{
			if( entityTemplate && !spawned )
			{
				SpawnEntity();
			}
			return true;
		}
		
		if( IsNameValid( destroyEntityOnAnimEvent ) && animEventName == destroyEntityOnAnimEvent && destroyEntityAfter <= 0.0 && entity )
		{
			entity.StopAllEffects();
			entity.DestroyAfter( 1.0 );
			return true;
		}
		
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid( spawnOnGameplayEvent ) && eventName == spawnOnGameplayEvent )
		{
			if( entityTemplate && !spawned )
			{
				SpawnEntity();
			}
			return true;
		}
		
		return false;
	}
	
	function SpawnEntity()
	{
		var spawnPos : Vector;
		var spawnRot : EulerAngles;
		
		if ( useOnlyOneFXEntity && entity )
			return;
		
		EvaluatePos( spawnPos, spawnRot );
		entity = theGame.CreateEntity( entityTemplate, spawnPos, spawnRot );
		
		if ( entity )
		{
			if ( IsNameValid( fxEntityTag ))
			{
				((CGameplayEntity)entity).AddTag( fxEntityTag );
			}
			
			if ( destroyEntityAfter > 0 )
			{
				entity.DestroyAfter( destroyEntityAfter );
			}
			
			if ( stopAllEffectsAfter > 0 && destroyEntityAfter > stopAllEffectsAfter )
			{
				entity.StopAllEffectsAfter( stopAllEffectsAfter );
			}
			
			if( IsNameValid( fxNameOnSpawn ) )
			{
				entity.PlayEffect( fxNameOnSpawn );
			}
			
			if ( attachToActor || IsNameValid( attachToSlotName ) )
			{
				Attach( attachToSlotName );
			}
			
			spawned = true;
		}
	}
	
	function EvaluatePos( out pos : Vector, out rot : EulerAngles )
	{
		var spawnPos	: Vector;
		var spawnRot	: EulerAngles;
		var actor		: CActor = GetActor();
		var target		: CActor = GetCombatTarget();
		var node 		: CNode; 
		var entMat		: Matrix;
		
		var damageAreaEntity : CDamageAreaEntity;
		
		if( useNodeWithTag && referenceNodeTag != 'None' )
		{
			node = theGame.GetNodeByTag( referenceNodeTag );
			
			if( node )
			{
				spawnPos = node.GetWorldPosition();
				spawnRot = node.GetWorldRotation();
			}
		}
		else if( useTargetInsteadOfOwner )
		{
			if( useCombatTarget )
			{
				spawnPos = target.GetWorldPosition();
				spawnRot = target.GetWorldRotation();
			}
			else
			{
				spawnPos = GetActionTarget().GetWorldPosition();
				spawnRot = GetActionTarget().GetWorldRotation();
			}
		}
		else
		{
			spawnPos = actor.GetWorldPosition();
			spawnRot = actor.GetWorldRotation();
		}
		
		if ( baseOffsetOnCasterRotation )
		{
			spawnRot = actor.GetWorldRotation();
		}
		
		if ( !( offsetVector.X == 0 && offsetVector.Y == 0 && offsetVector.Z == 0 ) )
		{
			entMat = MatrixBuiltTRS( spawnPos, spawnRot );
			spawnPos = VecTransform( entMat, offsetVector );
		}
		
		spawnRot.Pitch += additionalRotation.Pitch;
		spawnRot.Yaw += additionalRotation.Yaw;
		spawnRot.Roll += additionalRotation.Roll;
		
		pos = spawnPos;
		rot = spawnRot;
	}
	
	function Attach( slot : name )
	{
		var loc 	: Vector;
		var rot		: EulerAngles;	
		var owner 	: CActor = GetActor();
		
		if ( IsNameValid( slot ) )
		{
			if ( owner.HasSlot( slot, true ) )
			{
				entity.CreateAttachment( owner, slot );
			}
			else
			{
				entity.CreateAttachment( owner, slot );
			}
			attachedTo = NULL;
		}
		else
		{
			attachedTo = owner;	
		}
		
		if ( attachedTo )
		{
			loc = attachedTo.GetWorldPosition();
			rot = attachedTo.GetWorldRotation();
			
			entity.TeleportWithRotation( loc, rot );
		}
	}
};

class CBTTaskSpawnFXEntityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSpawnFXEntity';

	editable var resourceName				: name;
	editable var attachToActor				: bool;
	editable var useNodeWithTag				: bool;
	editable var useOnlyOneFXEntity			: bool;
	editable var referenceNodeTag			: name;
	editable var useTargetInsteadOfOwner	: bool;
	editable var useCombatTarget			: bool;
	editable var attachToSlotName			: name;
	editable var spawnAfter					: float;
	editable var spawnOnAnimEvent			: name;
	editable var spawnOnGameplayEvent		: name;
	editable var fxNameOnSpawn				: name;
	editable var fxEntityTag				: name;
	editable var destroyEntityAfter			: float;
	editable var destroyEntityOnAnimEvent	: name;
	editable var destroyEntityOnDeact		: bool;
	editable var stopAllEffectsAfter		: float;
	editable var offsetVector	 			: Vector;
	editable var additionalRotation			: EulerAngles;
	editable var baseOffsetOnCasterRotation	: bool;
	
	default useCombatTarget = true;
	
	hint fxEntityTag = "fx entity has to be of CGameplayEntity class to add tag";
	hint useTargetInsteadOfOwner = "use target position for fx entity spawn";
	hint useOnlyOneFXEntity = "prevent duplicating fx entity, use in cojunction with TaskManageSpawnFXEntity";
};





class CBTTaskManageSpawnFXEntity extends CBTTaskSpawnFXEntity
{
	public var activateOnAnimEvent					: name;
	public var activateOnGameplayEvent				: name;
	public var activeDuration						: float;
	public var activationCooldown					: float;
	public var teleportFXEntityOnAnimEvent 			: name;
	public var teleportFXEntityOnGameplayEvent 		: name;
	public var teleportInRandomDirection			: bool;
	public var randomPositionPattern				: ESpawnPositionPattern;
	public var randomTeleportMinRange				: float;
	public var randomTeleportMaxRange				: float;
	public var randomTeleportInterval				: float;
	public var teleportZAxisOffsetMin				: float;
	public var teleportZAxisOffsetMax				: float;
	public var fxNameOnRandomTeleportOnNPC			: name;
	public var fxNameOnRandomTeleportOnFXEntity		: name;
	public var fxNameOnTeleportToTargetOnNPC		: name;
	public var fxNameOnTeleportToTargetOnFXEntity 	: name;
	public var connectFXWithTarget					: bool;
	public var destroyEntityOnCombatEnd				: bool;
	
	private var activated							: bool;
	private var lastActivation						: float;
	private var lastDeactivation					: float;
	

	latent function Main() : EBTNodeStatus
	{
		var A,B	: bool;
		
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
		
		if( entityTemplate && !IsNameValid( spawnOnGameplayEvent ) && !IsNameValid( spawnOnAnimEvent ) && spawnAfter <= 0 )
		{
			SpawnEntity();
		}
		
		B = IsNameValid( activateOnAnimEvent );
		B = B && IsNameValid( activateOnGameplayEvent );
		
		if ( !B )
			activated = true;
		
		
		while ( true )
		{
			if ( activated && teleportInRandomDirection )
			{
				TeleportFXEntity( true );
				if ( IsNameValid( fxNameOnRandomTeleportOnNPC ) )
				{
					if ( connectFXWithTarget )
						GetNPC().PlayEffect( fxNameOnRandomTeleportOnNPC, entity );
					else
						GetNPC().PlayEffect( fxNameOnRandomTeleportOnNPC );
				}
				if ( IsNameValid( fxNameOnRandomTeleportOnFXEntity ) )
					entity.PlayEffect( fxNameOnRandomTeleportOnFXEntity );
				
				if ( randomTeleportInterval > 0 )
					Sleep( randomTeleportInterval );
			}
			
			if ( activated && ( lastActivation == 0 || !A ) )
			{
				lastActivation = GetLocalTime();
				A = true;
			}
			
			if ( activated && lastActivation + activeDuration < GetLocalTime() )
			{
				lastDeactivation = GetLocalTime();
				activated = false;
			}
			
			if ( lastActivation > 0 && !activated && lastDeactivation + activationCooldown < GetLocalTime() )
			{
				lastActivation = 0;
				activated = false;
			}
			
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( teleportFXEntityOnAnimEvent ) && animEventName == teleportFXEntityOnAnimEvent )
		{
			TeleportFXEntity();
			if ( entity )
			{
				if ( IsNameValid( fxNameOnTeleportToTargetOnNPC ) )
				{
					if ( connectFXWithTarget )
						GetNPC().PlayEffect( fxNameOnTeleportToTargetOnNPC, entity );
					else
						GetNPC().PlayEffect( fxNameOnTeleportToTargetOnNPC );
				}
				if ( IsNameValid( fxNameOnTeleportToTargetOnFXEntity ) )
					entity.PlayEffect( fxNameOnTeleportToTargetOnFXEntity );
			}
			
			return true;
		}
		
		if ( IsNameValid( activateOnAnimEvent ) && animEventName == activateOnAnimEvent )
		{
			activated = true;
			return true;
		}
		
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid( teleportFXEntityOnGameplayEvent ) && eventName == teleportFXEntityOnGameplayEvent )
		{
			TeleportFXEntity();
			if ( entity )
			{
				if ( IsNameValid( fxNameOnTeleportToTargetOnNPC ) )
				{
					if ( connectFXWithTarget )
						GetNPC().PlayEffect( fxNameOnTeleportToTargetOnNPC, entity );
					else
						GetNPC().PlayEffect( fxNameOnTeleportToTargetOnNPC );
				}
				if ( IsNameValid( fxNameOnTeleportToTargetOnFXEntity ) )
					entity.PlayEffect( fxNameOnTeleportToTargetOnFXEntity );
			}
			return true;
		}
		
		if ( IsNameValid( activateOnGameplayEvent ) && eventName == activateOnGameplayEvent )
		{
			activated = true;
			return true;
		}
		
		return false;
	}
	
	function OnListenedGameplayEvent( eventName: CName ) : bool
	{
		if ( destroyEntityOnCombatEnd && entity )
			entity.Destroy();
		return true;
	}
	
	function TeleportFXEntity( optional random : bool )
	{
		var spawnPos : Vector;
		var spawnRot : EulerAngles;
		
		if ( random )
			RandomPos( spawnPos, spawnRot );
		else
			EvaluatePos( spawnPos, spawnRot );
		
		if ( entity )
			entity.TeleportWithRotation( spawnPos, spawnRot );
	}
	
	function RandomPos( out pos : Vector, out rot : EulerAngles )
	{
		var randVec 	: Vector;
		var spawnPos 	: Vector;
		var zOffset		: float;
		
		randVec = VecRingRand( randomTeleportMinRange, randomTeleportMaxRange );
		
		if ( randomPositionPattern == ESPP_AroundTarget )
		{
			spawnPos = GetCombatTarget().GetWorldPosition() - randVec;
		}
		else if ( randomPositionPattern == ESPP_AroundSpawner )
		{
			spawnPos = GetActor().GetWorldPosition() - randVec;
		}
		else if ( randomPositionPattern == ESPP_AroundBoth )
		{
			if ( RandRange( 2 ) == 1 )
				spawnPos = GetCombatTarget().GetWorldPosition() - randVec;
			else
				spawnPos = GetActor().GetWorldPosition() - randVec;
		}
		
		zOffset = RandRangeF( teleportZAxisOffsetMax, teleportZAxisOffsetMin );
		spawnPos.Z += zOffset;
		pos = spawnPos;
	}
};

class CBTTaskManageSpawnFXEntityDef extends CBTTaskSpawnFXEntityDef
{
	editable var activateOnAnimEvent				: name;
	editable var activateOnGameplayEvent			: name;
	editable var activeDuration						: float;
	editable var activationCooldown					: float;
	editable var teleportFXEntityOnAnimEvent 		: name;
	editable var teleportFXEntityOnGameplayEvent 	: name;
	editable var teleportInRandomDirection			: bool;
	editable var randomPositionPattern				: ESpawnPositionPattern;
	editable var randomTeleportMinRange				: float;
	editable var randomTeleportMaxRange				: float;
	editable var randomTeleportInterval				: float;
	editable var teleportZAxisOffsetMin				: float;
	editable var teleportZAxisOffsetMax				: float;
	editable var fxNameOnRandomTeleportOnNPC		: name;
	editable var fxNameOnRandomTeleportOnFXEntity	: name;
	editable var fxNameOnTeleportToTargetOnNPC		: name;
	editable var fxNameOnTeleportToTargetOnFXEntity	: name;
	editable var connectFXWithTarget				: bool;
	editable var destroyEntityOnCombatEnd			: bool;
	
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'LeavingCombat' );
	}
	
	default instanceClass = 'CBTTaskManageSpawnFXEntity';
};
