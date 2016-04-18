/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




enum ETeleportType
{
	TT_ToPlayer,
	TT_ToTarget,
	TT_AwayFromTarget,
	TT_FromLastPosition,
	TT_Random,
	TT_ToSelf,
	TT_ToNode,
}

class TaskSetIsTeleporting extends IBehTreeTask
{
	var SetToFalseOnDeactivate : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		GetNPC().SetIsTeleporting( true );
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( SetToFalseOnDeactivate )
			GetNPC().SetIsTeleporting( false );
	}
};

class TaskSetIsTeleportingDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'TaskSetIsTeleporting';

	editable var SetToFalseOnDeactivate : bool;
	
	default SetToFalseOnDeactivate = true;
};




class TaskTeleportInWaterAction extends TaskTeleportAction
{
	
	
	
	public var waterDepthNeeded : float;
	
	private function IsPointSuitableForTeleport( out whereTo : Vector ) : bool
	{
		var npc 			: CNewNPC = GetNPC();
		var newPos 			: Vector;
		var radius 			: float;
		var waterDepth 		: float;
		var z 				: float;
		var l_temp			: Vector;

		radius = npc.GetRadius();
		
		waterDepth = theGame.GetWorld().GetWaterDepth( whereTo );
		
		if ( waterDepth == 10000 ) { waterDepth = 0; }
		
		if( waterDepth < waterDepthNeeded )
		{
			return false;
		}
		
		
		if( theGame.GetWorld().SweepTest( whereTo , whereTo + Vector( 0, 0, 3 ), radius, l_temp, l_temp ) )
		{
			return false;
		}		
		
		return true;
	}
}
class TaskTeleportInWaterActionDef extends TaskTeleportActionDef
{
	default instanceClass = 'TaskTeleportInWaterAction';
	
	
	
	editable var waterDepthNeeded	: float;
	
	default waterDepthNeeded =  3.0f;
}




class TaskTeleportAction extends IBehTreeTask
{
	
	public var teleportType 									: ETeleportType;
	public var teleportToRequestedFacingDirection 				: bool;
	public var teleportAwayFromRequestedFacingDirection			: bool;
	public var teleportOutsidePlayerFOV							: bool;
	public var teleportBehindTarget								: bool;
	public var requestedFacingDirectionNoiseAngle				: float;
	public var minDistance 										: float;
	public var maxDistance 										: float;
	public var setIsTeleportingFlag								: bool;
	public var minWaterDepthToAppear							: float;
	public var maxWaterDepthToAppear							: float;
	public var zTolerance										: float;
	public var testLOSforNewPosition							: bool;
	public var testNavigationBetweenCombatTargetAndNewPosition	: bool;
	public var overrideActorRadiusForNavigationTests			: bool;
	public var actorRadiusForNavigationTests					: float;
	public var checkWaterLevel									: bool;
	public var searchingTimeout									: float;
	public var nodeTag											: name;
	public var shouldSpawnMarkers								: bool;
	public var useCombatTarget									: bool;
	public var paramsOverriden									: bool;
	public var cashedBool										: bool;
	public var setInvulnerable									: bool;
	
	
	protected var alreadyTeleported 							: bool;
	protected var isTeleporting 								: bool;
	protected var distFromLastTelePos 							: float;
	protected var dangerZone, angle 							: float;
	protected var lastTelePos 									: Vector;
	
	default isTeleporting = false;
	default alreadyTeleported = false;
	
	
	function IsAvailable() : bool
	{
		var currTime : float = GetLocalTime();
		
		if ( useCombatTarget && !GetCombatTarget() )
		{
			return false;
		}
		return true;
	}
	
	
	
	
	
		
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if ( setIsTeleportingFlag )
		{
			
			npc.SetIsTeleporting( true );
			if ( setInvulnerable )
				npc.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
		}
		
		return BTNS_Active;
	}
	
	
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var newPosition : Vector;
		var res : bool;
		var node : CNode;
		
		if( teleportType == TT_ToNode )
		{
			if( nodeTag == 'None' )
				return BTNS_Failed;
				
			node = theGame.GetNodeByTag( nodeTag );
			
			if( node )
			{
				newPosition = node.GetWorldPosition();
				res  = true;
			}
		}
		else
		{
			res = FindSuitablePoint( newPosition, searchingTimeout );
		}
		
		if ( !res )
			return BTNS_Failed;
		
		if( shouldSpawnMarkers )
			SpawnBlinkMarkers( GetNPC().GetWorldPosition(), newPosition );
	
		PerformTeleport( newPosition );
		
		alreadyTeleported = true;
		
		return BTNS_Completed;
	}
	
	
	
	
	
	protected function PerformTeleport( newPosition : Vector )
	{
		var rotation : EulerAngles;
		
		
		if( teleportType == TT_ToNode )
		{
			rotation = theGame.GetNodeByTag( nodeTag ).GetWorldRotation();
			GetNPC().TeleportWithRotation( newPosition, rotation );
		}
		else if ( GetCombatTarget() )
		{
			rotation = VecToRotation( GetCombatTarget().GetWorldPosition() - newPosition );
			rotation.Pitch = 0.f;
			rotation.Roll = 0.f;
			GetNPC().TeleportWithRotation( newPosition, rotation );
		}
		else
			GetNPC().Teleport( newPosition );
			
		lastTelePos = newPosition;
	}
	
	protected latent function FindSuitablePoint( out newPosition : Vector, optional timeOut : float ) : bool
	{
		var whereTo 			: Vector;
		var randVec 			: Vector;
		var startTimeStamp 		: float = GetLocalTime();
		
		randVec = CalculateRandVec();
		whereTo = CalculateWhereToVec(randVec);
		
		while ( !IsPointSuitableForTeleport(whereTo) )
		{
			if ( timeOut > 0 && ( startTimeStamp + timeOut < GetLocalTime() ) )
				return false;
			
			SleepOneFrame();
			randVec = CalculateRandVec();
			whereTo = CalculateWhereToVec(randVec);
			
		}
		
		newPosition = whereTo;
		
		return true;
	}
	
	
	
	
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		if ( setIsTeleportingFlag )
		{
			
			npc.SetIsTeleporting( false );
			if ( setInvulnerable )
				npc.SetImmortalityMode( AIM_None, AIC_Combat );
		}
		if ( paramsOverriden )
		{
			testNavigationBetweenCombatTargetAndNewPosition = cashedBool;
			paramsOverriden = false;
		}
		
		
		isTeleporting = false;
	}
	
	
	
	
	
	
	protected function IsPointSuitableForTeleport( out whereTo : Vector ) : bool
	{
		var npc 			: CNewNPC = GetNPC();
		var newPos 			: Vector;
		var radius 			: float;
		var waterDepth 		: float;
		var z 				: float;

		if( overrideActorRadiusForNavigationTests )
			radius = MaxF( 0.01, actorRadiusForNavigationTests );
		else
			radius = npc.GetRadius();
		
		if ( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, radius, radius*3, newPos ) )
		{
			if ( theGame.GetWorld().NavigationComputeZ(whereTo, whereTo.Z - zTolerance, whereTo.Z + zTolerance, z) )
			{
				whereTo.Z = z;
				if ( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, radius, radius*3, newPos ) )
					return false;
			}
			
		}
		
		
		
		
		
		
		
		
		
		if ( testNavigationBetweenCombatTargetAndNewPosition && testLOSforNewPosition )
		{
			if ( !theGame.GetWorld().NavigationLineTest(newPos, GetCombatTarget().GetWorldPosition(), radius ) && !theGame.GetWorld().NavigationLineTest( npc.GetWorldPosition(), newPos, radius ) )
				return false;
		}
		else
		{
			if ( testNavigationBetweenCombatTargetAndNewPosition && !theGame.GetWorld().NavigationLineTest(newPos, GetCombatTarget().GetWorldPosition(), radius ) )
				return false;
				
			if ( testLOSforNewPosition && !theGame.GetWorld().NavigationLineTest(npc.GetWorldPosition(), newPos, radius ) )
				return false;
		}
		
		if ( checkWaterLevel || minWaterDepthToAppear > 0 )
		{
			waterDepth = theGame.GetWorld().GetWaterDepth( newPos );
			
			if ( waterDepth == 10000 ) { waterDepth = 0; }
			if( waterDepth > maxWaterDepthToAppear )
			{
				return false;
			}
			if ( minWaterDepthToAppear > 0 && waterDepth < minWaterDepthToAppear )
			{
				return false;
			}
		}
		
		whereTo = newPos;
		
		return true;
	}
	
	private function CalculateWhereToVec( randVec : Vector ) : Vector
	{
		var whereTo		: Vector;
		var npc 		: CNewNPC = GetNPC();
		var target 		: CNode; 
		
		if ( useCombatTarget )
			target = GetCombatTarget();
		else
			target = GetActionTarget();
		
		if ( teleportType == TT_ToSelf || ( teleportType != TT_ToSelf && !target ) )
		{
			whereTo = npc.GetWorldPosition() - randVec;
		}
		else if ( teleportBehindTarget )
		{
			whereTo = target.GetWorldPosition() + randVec;
		}
		else if ( teleportOutsidePlayerFOV )
		{
			whereTo = theCamera.GetCameraPosition() - randVec;
		}
		else if ( teleportType == TT_ToTarget || teleportType == TT_FromLastPosition )
		{
			if ( teleportToRequestedFacingDirection || teleportAwayFromRequestedFacingDirection )
			{
				whereTo = target.GetWorldPosition() + randVec;
			}
			else
			{
				whereTo = target.GetWorldPosition() - randVec;
			}
		}
		else if ( teleportType == TT_ToPlayer )
		{
			if ( teleportToRequestedFacingDirection || teleportAwayFromRequestedFacingDirection )
			{
				whereTo = thePlayer.GetWorldPosition() + randVec;
			}
			else
			{
				whereTo = thePlayer.GetWorldPosition() - randVec;
			}
		}
		
		else
		{
			whereTo = npc.GetWorldPosition() - randVec;
		}
		return whereTo;
	}
	
	private function CalculateRandVec() : Vector
	{
		var randVec 				: Vector = Vector(0.f,0.f,0.f);
		var npc 					: CNewNPC = GetNPC();
		var target 					: CActor = GetCombatTarget();
		var cameraToPlayerDistance 	: float;
		var averageDistance			: float;
		
		
		if ( teleportToRequestedFacingDirection )
		{
			averageDistance = RandRangeF( minDistance, maxDistance );
			requestedFacingDirectionNoiseAngle *= -1;
			randVec = VecFromHeading ( AngleNormalize180( npc.GetBehaviorVariable( 'requestedFacingDirection' ) + 180 + requestedFacingDirectionNoiseAngle ))*averageDistance;
		}
		
		else if ( teleportAwayFromRequestedFacingDirection )
		{
			averageDistance = RandRangeF( minDistance, maxDistance );
			requestedFacingDirectionNoiseAngle *= -1;
			randVec = VecFromHeading ( AngleNormalize180( npc.GetBehaviorVariable( 'requestedFacingDirection' ) + requestedFacingDirectionNoiseAngle ))*averageDistance;
		}
		
		else if ( teleportType == TT_ToSelf )
		{
			randVec = VecRingRand(minDistance,maxDistance);
		}
		else if ( teleportBehindTarget )
		{
			randVec = VecConeRand( VecHeading(target.GetHeadingVector())+180, 5, minDistance, maxDistance );
		}
		else if ( teleportOutsidePlayerFOV )
		{
			cameraToPlayerDistance = VecDistance( theCamera.GetCameraPosition(), thePlayer.GetWorldPosition() );
			if ( cameraToPlayerDistance*1.2 > minDistance )
			{
				minDistance = cameraToPlayerDistance*1.2;
				maxDistance = ( maxDistance + ( cameraToPlayerDistance - minDistance ))*1.2;
			}
			else
			{
				randVec = VecConeRand( theCamera.GetCameraHeading(), 45, minDistance, maxDistance );
			}
		}
		else if ( teleportType == TT_FromLastPosition )
		{
			angle = NodeToNodeAngleDistance( npc.GetTarget(), npc );
			
			if ( alreadyTeleported )
			{
				distFromLastTelePos = VecDistance( lastTelePos, npc.GetWorldPosition() );
				minDistance = distFromLastTelePos - 2;
				maxDistance = distFromLastTelePos + 2;
				randVec = VecConeRand( angle, 30, minDistance, maxDistance );
			}
			else
			{
				randVec = VecRingRand(minDistance,maxDistance);
			}
		}
		else if ( maxDistance != 0 )
		{
			randVec = VecRingRand(minDistance,maxDistance);
		}
		return randVec;
	}
	
	private latent function SpawnBlinkMarkers( startPos : Vector, endPos : Vector )
	{
		var startEnt, endEnt : CEntity;
		var entityTemplate : CEntityTemplate;
		
		
		
		
		
		entityTemplate = (CEntityTemplate)LoadResourceAsync( 'blink_marker' );
		
		if( entityTemplate )
		{
			startEnt = theGame.CreateEntity( entityTemplate, startPos, VecToRotation( endPos - startPos ) );
			endEnt = theGame.CreateEntity( entityTemplate, endPos, VecToRotation( startPos - endPos ) );
		}
		
		startEnt.PlayEffect( 'disappear' );
		endEnt.PlayEffect( 'appear' );
		
		startEnt.DestroyAfter( 2.0 );
		endEnt.DestroyAfter( 2.0 );
	}
}

class TaskTeleportActionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'TaskTeleportAction';

	editable var setIsTeleportingFlag 								: bool;
	editable var minDistance 										: float;
	editable var maxDistance 										: float;
	editable var teleportToRequestedFacingDirection					: bool;
	editable var teleportAwayFromRequestedFacingDirection			: bool;
	editable var requestedFacingDirectionNoiseAngle					: float;
	editable var teleportBehindTarget								: bool;
	editable var teleportOutsidePlayerFOV							: bool;
	editable var teleportType 										: ETeleportType;
	editable var minWaterDepthToAppear								: float;
	editable var maxWaterDepthToAppear								: float;
	editable var zTolerance											: float;
	editable var testLOSforNewPosition								: bool;
	editable var useCombatTarget									: bool;
	editable var testNavigationBetweenCombatTargetAndNewPosition	: bool;
	editable var overrideActorRadiusForNavigationTests				: bool;
	editable var actorRadiusForNavigationTests						: float;
	editable var checkWaterLevel									: bool;
	editable var searchingTimeout									: float;
	editable var nodeTag											: name;
	editable var shouldSpawnMarkers									: bool;
	editable var setInvulnerable									: bool;
	
	default minDistance = 3.0;
	default maxDistance = 5.0;
	default zTolerance = 5.0;
	default teleportOutsidePlayerFOV = true;
	default teleportType = TT_ToPlayer;
	default setIsTeleportingFlag = true;
	default maxWaterDepthToAppear = 1;
	default testLOSforNewPosition = true;
	default useCombatTarget = true;
	default testNavigationBetweenCombatTargetAndNewPosition = true;
	default checkWaterLevel = true;
	default searchingTimeout = 5.0;
	default shouldSpawnMarkers = false;
	default setInvulnerable = true;
	
	hint teleportToRequestedFacingDirection = "OVERRIDES teleportBehindTarget and teleportOutsidePlayerFOV";
};






class CBTTaskTeleport extends TaskTeleportAction
{
	var vanish 									: bool;
	var forceInvisible							: bool;
	var disallowInPlayerFOV 					: bool;
	var cameraToPlayerDistance 					: float;
	var cooldown 								: float;
	var nextTeleTime 							: float;
	var delayActivation							: float;
	var delayReappearance 						: float;
	var disableInvisibilityAfterReappearance 	: bool;
	var disappearfxName 						: name;
	var appearFXName 							: name;
	var additionalAppearFXName					: name;
	var performPosCheckOnTeleportEventName		: bool;
	var performLastMomentPosCheck				: bool;
	var teleportEventName 						: name;	
	var raiseEventName							: name;
	var appearRaiseEventName					: name;
	var appearRaiseEventNameOnFailure			: name;		
	var setBehVarNameOnRaiseEvent				: name;		
	var setBehVarValueOnRaiseDisappearEvent		: float;	
	var setBehVarValueOnRaiseAppearEvent		: float;	
	var heading 								: Vector;
	var randVec 								: Vector;
	var playerPos 								: Vector;
	var whereTo 								: Vector;
	var canBeStrafed							: bool;
	var appearFXPlayed							: bool;
	var appearRaiseEventLaunched				: bool;
	var disappearRaiseEventLaunched				: bool;
	var shouldPlayHitAnim						: bool; 
	
	
	
	
	default vanish = false;
	default isTeleporting = false;
	default alreadyTeleported = false;
	default teleportEventName = 'Vanish';
	default appearRaiseEventName = 'Appear';
	
	function IsAvailable() : bool
	{
		var currTime : float = GetLocalTime();
		
		super.IsAvailable();
		
		if ( isActive )
		{
			return true;
		}
		
		if (  nextTeleTime > 0 && nextTeleTime > currTime )
		{
			return false;
		}
		
		if ( disallowInPlayerFOV )
		{
			if ( !ActorInPlayerFOV() )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return true;
		}
	}
	
	
	
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		npc.SetIsTeleporting( true );
		if ( setInvulnerable )
			npc.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
		npc.AddBuffImmunity_AllNegative( 'teleport', true );
		
		npc.SetCanPlayHitAnim( shouldPlayHitAnim );
		
		appearFXPlayed = false;
		return BTNS_Active;
	}
	
	
	
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var npc 			: CNewNPC = GetNPC();
		var target 			: CActor = GetCombatTarget();
		var newPosition		: Vector;
		var res 			: bool;
		
		
		appearRaiseEventLaunched = false;
		disappearRaiseEventLaunched = false;
		
		if ( !performPosCheckOnTeleportEventName )
		{
			
			
			res = PosChecks( newPosition );
			
			if ( !res )
			{
				return BTNS_Failed;
			}
		}
		
		
		
		if ( delayActivation == 0 )
		{
			
			
			npc.RaiseEvent( raiseEventName );
			disappearRaiseEventLaunched = true;
			if ( IsNameValid( setBehVarNameOnRaiseEvent ) )
				npc.SetBehaviorVariable( setBehVarNameOnRaiseEvent, setBehVarValueOnRaiseDisappearEvent, true );
			
			if( IsNameValid( disappearfxName ))
			{
				
				npc.PlayEffect( disappearfxName );
			}
		}
		
		
		res = false;
		isTeleporting = true;
		
		npc.SetGameplayVisibility( false );
		
		if ( delayActivation > 0 )
		{
			Sleep( delayActivation );
			
			npc.RaiseEvent( raiseEventName );
			disappearRaiseEventLaunched = true;
			if ( IsNameValid( setBehVarNameOnRaiseEvent ) )
				npc.SetBehaviorVariable( setBehVarNameOnRaiseEvent, setBehVarValueOnRaiseDisappearEvent, true );
			
			if( IsNameValid( disappearfxName ))
			{
				
				npc.PlayEffect( disappearfxName );
				
				Sleep( 0.1f );
			}
		}
		
		if ( teleportEventName )
		{
			while ( !vanish )
			{
				Sleep( 0.01f );
			}
			
			if ( performPosCheckOnTeleportEventName )
			{
				res = PosChecks( newPosition );
				
				if ( !res )
				{
					return BTNS_Failed;
				}
			}
			
			if ( forceInvisible )
			{
				npc.SetVisibility( false );
			}
		}
		
		if ( delayReappearance > 0 )
		{
			if ( forceInvisible && !IsNameValid(teleportEventName) )
			{
				npc.SetVisibility( false );
			}
			
			npc.EnableCharacterCollisions( false );
			Sleep( delayReappearance );
			
			if ( performLastMomentPosCheck )
			{
				res = PosChecks( newPosition );
				
				if ( !res )
				{
					return BTNS_Failed;
				}
			}
			SafeTeleport( newPosition );
			
			if( IsNameValid( appearRaiseEventName ) )
			{
				npc.RaiseEvent( appearRaiseEventName );
				appearRaiseEventLaunched = true;
				if ( IsNameValid( setBehVarNameOnRaiseEvent ) )
					npc.SetBehaviorVariable( setBehVarNameOnRaiseEvent, setBehVarValueOnRaiseAppearEvent, true );
			}
		}
		else
		{
			if ( performLastMomentPosCheck )
			{
				res = PosChecks( newPosition );
				
				if ( !res )
				{
					return BTNS_Failed;
				}
			}
			SafeTeleport( newPosition );
		}
		
		if( IsNameValid( appearFXName ))
		{
			appearFXPlayed = true;
			npc.PlayEffect( appearFXName );
		}
		
		if( IsNameValid( additionalAppearFXName ))
		{
			appearFXPlayed = true;
			npc.PlayEffect( additionalAppearFXName );
		}
		
		if ( disableInvisibilityAfterReappearance )
		{
			if ( forceInvisible )
			{
				npc.SetVisibility( true );
			}
			
			
		}
		
		if( IsNameValid( appearRaiseEventName ) )
		{
			npc.WaitForBehaviorNodeDeactivation( appearRaiseEventName, 2.f );
		}
		
		nextTeleTime = GetLocalTime() + cooldown;
		alreadyTeleported = true;
		SleepOneFrame();
		
		return BTNS_Completed;
	}
	
	
	
	
	
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		
		
		npc.SetCanPlayHitAnim( true );
		
		npc.SetBehaviorVariable( 'teleport_on_hit', 0, true );
		if ( isTeleporting )
		{
			isTeleporting = false;
			vanish = false;
		}
		
		if ( !appearFXPlayed )
		{
			if( IsNameValid( additionalAppearFXName ))
			{
				npc.PlayEffect( additionalAppearFXName );
			}
			else if( IsNameValid( appearFXName ))
			{
				npc.PlayEffect( appearFXName );
			}
		}
		
		if ( forceInvisible )
		{
			npc.SetVisibility( true );
		}
		
		if ( teleportEventName )
		{
			npc.SetGameplayVisibility( true );
		}
		
		if ( delayReappearance > 0 || disableInvisibilityAfterReappearance )
		{
			npc.EnableCharacterCollisions( true );
			npc.SetGameplayVisibility( true );
		}
		
		
		npc.SetIsTeleporting( false );
		if ( setInvulnerable )
			npc.SetImmortalityMode( AIM_None, AIC_Combat );
		npc.RemoveBuffImmunity_AllNegative( 'teleport' );
	}
	
	function OnCompletion( success : bool )
	{
		if ( !success && IsNameValid( appearRaiseEventNameOnFailure ) && disappearRaiseEventLaunched && !appearRaiseEventLaunched )
			GetNPC().RaiseEvent( appearRaiseEventNameOnFailure );
	}
	
	
	
	
	
	
	latent function PosChecks( out pos : Vector ) : bool
	{
		var l_res : bool;
		
		l_res = FindSuitablePoint(pos, 0.5); 
		if ( !l_res )
		{
			
			paramsOverriden = true;
			cashedBool = testNavigationBetweenCombatTargetAndNewPosition;
			testNavigationBetweenCombatTargetAndNewPosition = false;
			l_res = FindSuitablePoint(pos, 0.1) ;
			if ( !l_res )
			{		
				return false;
			}
		}
		
		return true;
	}
	
	latent function SafeTeleport( pos : Vector ) : bool
	{
		var l_rotation : EulerAngles;
		var npc : CNewNPC = GetNPC();
		
		if ( GetCombatTarget() )
		{
			l_rotation = VecToRotation( GetCombatTarget().GetWorldPosition() - pos );
			l_rotation.Pitch = 0.f;
			l_rotation.Roll = 0.f;
			
			npc.TeleportWithRotation( pos, l_rotation );
		}
		else
		{
			npc.Teleport( pos );
		}
		
		lastTelePos = pos;
		
		return true;
	}
	
	function ActorInPlayerFOV() : bool
	{
		var npc	: CNewNPC = GetNPC();
		
		if ( thePlayer.WasVisibleInScaledFrame( npc, 1.15f, 1.15f ) )
		{
			return true;
		}
		return false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == teleportEventName )
		{
			vanish = true;
			return true;
		}
		return false;
	}
};

class CBTTaskTeleportDef extends TaskTeleportActionDef
{
	default instanceClass = 'CBTTaskTeleport';

	editable var cooldown 								: float;
	editable var delayActivation						: float;
	editable var delayReappearance 						: float;
	editable var forceInvisible 						: bool;
	editable var disableInvisibilityAfterReappearance	: bool;
	editable var disallowInPlayerFOV 					: bool;
	editable var performPosCheckOnTeleportEventName		: bool;
	editable var performLastMomentPosCheck				: bool;
	editable var teleportEventName 						: name;
	editable var appearRaiseEventName					: name;
	editable var appearRaiseEventNameOnFailure			: name;
	editable var setBehVarNameOnRaiseEvent				: name;
	editable var setBehVarValueOnRaiseDisappearEvent	: float;
	editable var setBehVarValueOnRaiseAppearEvent		: float;
	editable var disappearfxName 						: name;
	editable var appearFXName 							: name;
	editable var additionalAppearFXName					: name;
	editable var raiseEventName 						: name;
	editable var shouldPlayHitAnim						: bool; 
	
	default minDistance = 3.0;
	default maxDistance = 5.0;
	default cooldown = 5.0;
	default delayReappearance = 1.0;
	default disallowInPlayerFOV = false;
	default teleportOutsidePlayerFOV = true;
	default teleportType = TT_ToPlayer;
	default teleportEventName = 'Vanish';
	default raiseEventName = 'Teleport';
	default appearRaiseEventName = 'Appear';
	default shouldPlayHitAnim = false;
};





class CBTTaskTeleportDecorator extends CBTTaskTeleport
{
	var finished : bool;
	var completeWhenTeleported : bool;
	
	
	function IsAvailable() : bool
	{
		super.IsAvailable();
		
		return true;
	}
	
	
	
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var res 			: bool;
		var newPosition 	: Vector;
		
		if ( !performPosCheckOnTeleportEventName )
		{
			
			
			res = PosChecks( newPosition );
			
			if ( !res )
			{
				return BTNS_Failed;
			}
		}
		
	
		finished = false;
		
		if ( disallowInPlayerFOV )
		{
			if ( !ActorInPlayerFOV() )
			{
				if ( !performPosCheckOnTeleportEventName )
				{
					Teleport( newPosition );
				}
				else
				{
					Teleport();
				}
			}
		}
		else
		{
			if ( !performPosCheckOnTeleportEventName )
			{
				Teleport( newPosition );
			}
			else
			{
				Teleport();
			}
		}
		
		while( completeWhenTeleported )
		{
			if( finished )
			{
				return BTNS_Completed;
			}
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		
		npc.SetCanPlayHitAnim( true );
		npc.SetBehaviorVariable( 'teleport_on_hit', 0, true );
		
		if ( !appearFXPlayed )
		{
			if( IsNameValid( additionalAppearFXName ))
			{
				npc.PlayEffect( additionalAppearFXName );
			}
			else if( IsNameValid( appearFXName ))
			{
				npc.PlayEffect( appearFXName );
			}
		}
		
		if ( isTeleporting )
		{
			isTeleporting = false;
			vanish = false;
		}
		
		if ( forceInvisible )
		{
			npc.SetVisibility( true );
		}
		
		if ( teleportEventName )
		{
			npc.SetGameplayVisibility( true );
		}
		
		if ( delayReappearance > 0 || disableInvisibilityAfterReappearance )
		{
			npc.EnableCharacterCollisions( true );
			npc.SetGameplayVisibility( true );
		}
		
		npc.SetIsTeleporting( false );
		if ( setInvulnerable )
			npc.SetImmortalityMode( AIM_None, AIC_Combat );
		npc.RemoveBuffImmunity_AllNegative( 'teleport' );
	}
	
	latent function Teleport( optional newPos : Vector ) : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var res : bool;
		var maxTries : int;
		
		res = false;
		
		if ( delayActivation > 0 )
		{
			Sleep( delayActivation );
			
			npc.SetIsTeleporting( true );
			if ( setInvulnerable )
				npc.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
			npc.AddBuffImmunity_AllNegative( 'teleport', true );
			npc.SetCanPlayHitAnim( shouldPlayHitAnim );
			npc.RaiseEvent( raiseEventName );
			
			if( IsNameValid( disappearfxName ))
			{
				
				npc.PlayEffect( disappearfxName );
				
				Sleep( 0.1f );
			}
		}
		
		if ( teleportEventName )
		{
			while ( !vanish )
			{
				Sleep( 0.01f );
			}
			
			if ( performPosCheckOnTeleportEventName )
			{
				res = PosChecks( newPos );
				
				if ( !res )
				{
					return BTNS_Failed;
				}
			}
			
			npc.SetGameplayVisibility( false );
			if ( forceInvisible )
			{
				npc.SetVisibility( false );
			}
		}
		
		isTeleporting = true;
		
		if ( delayReappearance > 0 )
		{
			npc.SetGameplayVisibility( false );
			if ( forceInvisible && !IsNameValid(teleportEventName) )
			{
				npc.SetVisibility( false );
			}
			
			npc.EnableCharacterCollisions( false );
			Sleep( delayReappearance );
			if ( performLastMomentPosCheck )
			{
				res = PosChecks( newPos );
				
				if ( !res )
				{
					return BTNS_Failed;
				}
			}
			SafeTeleport( newPos );
			
			if( IsNameValid( appearRaiseEventName ) )
			{
				npc.RaiseEvent( appearRaiseEventName );
			}
		}
		else
		{
			if ( performLastMomentPosCheck )
			{
				res = PosChecks( newPos );
				
				if ( !res )
				{
					return BTNS_Failed;
				}
			}
			SafeTeleport( newPos );
		}
		
		if( IsNameValid( appearFXName ))
		{
			appearFXPlayed = true;
			npc.PlayEffect( appearFXName );
		}
		
		if( IsNameValid( additionalAppearFXName ))
		{
			appearFXPlayed = true;
			npc.PlayEffect( additionalAppearFXName );
		}
		
		if ( disableInvisibilityAfterReappearance )
		{
			if ( forceInvisible )
			{
				npc.SetVisibility( true );
			}
			
			
		}
		
		if( IsNameValid( appearRaiseEventName ) )
		{
			npc.WaitForBehaviorNodeDeactivation( appearRaiseEventName, 2.f );
		}
		
		nextTeleTime = GetLocalTime() + cooldown;
		alreadyTeleported = true;
		finished = true;
		
		return BTNS_Active;
	}
};

class CBTTaskTeleportDecoratorDef extends CBTTaskTeleportDef
{
	default instanceClass = 'CBTTaskTeleportDecorator';

	editable var completeWhenTeleported : bool;
};






class CBTTaskFlyingSwarmTeleport extends CBTTaskTeleport
{
	var lair 						: CFlyingSwarmMasterLair;
	var useAnimations				: bool;
	var attackTeleport				: bool;
	var res, fail					: bool;
	var despawnCalled				: bool;
	var disableBoidPOIComponents 	: bool;
	var delayVanish					: float;
	var fxTime						: float;
	var spawnedBirdCount			: int;
	var boidPOIComponents			: array< CComponent >;
	var appearFXLoopInterval		: float;
	var forcedDespawnTime			: float;
	
	function IsAvailable() : bool
	{
		var lairEntities : array<CGameplayEntity>;
		
		super.IsAvailable();
		
		if ( !lair )
		{
			FindGameplayEntitiesInRange( lairEntities, GetActor(), 150, 1, 'SwarmMasterLair' );
			if ( lairEntities.Size() > 0 )
				lair = (CFlyingSwarmMasterLair)lairEntities[0];
		}
		if ( !lair )
		{
			return false;
		}		
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		npc.SetCanPlayHitAnim( shouldPlayHitAnim );
		npc.SetUnstoppable( true );
		npc.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
		npc.AddBuffImmunity_AllNegative( 'teleport', true );
		
		return BTNS_Active;
	}
	
	
	
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var npc 				: CNewNPC = GetNPC();
		var lairEntities 		: array<CGameplayEntity>;
		var target 				: CNode;
		var initialSwarmPos 	: Vector;
		var swarmGroupId 		: CFlyingGroupId;
		var currTime, lastTime 	: float;
		var newPosition 		: Vector;
		var i 					: int;
		
		
		if ( boidPOIComponents.Size() == 0 )
		{
			boidPOIComponents = npc.GetComponentsByClassName( 'CBoidPointOfInterestComponent' );
		}
		
		if ( boidPOIComponents.Size() == 0 )
		{
			LogChannel( 'swarmDebug', npc.GetName()+" has no CBoidPointOfInterestComponent!!" );
			return BTNS_Failed;
		}
		
		if ( disableBoidPOIComponents )
		{
			for ( i=0 ; i < boidPOIComponents.Size() ; i+=1 )
			{
				((CBoidPointOfInterestComponent)(boidPOIComponents[i])).Disable( false );
			}
		}
		
		if ( useCombatTarget )
		{
			target = GetCombatTarget();
		}
		else
		{
			target = GetActionTarget();
		}
		
		if ( !performPosCheckOnTeleportEventName )
		{
			
			
			res = PosChecks( newPosition );
			
			if ( !res )
			{
				return BTNS_Failed;
			}
		}
		
		despawnCalled = false;
		
		
		npc.SetIsTeleporting( true );
		
		if ( useAnimations )
		{
			npc.RaiseEvent( raiseEventName );
		}
		
		
		res = false;
		fail = false;
		
		lastTime = GetLocalTime();
		lastTime += 10;
		
		if ( delayActivation > 0 )
		{
			Sleep( delayActivation );
		}
		
		
		
		
		
		if ( delayVanish == 0 )
		{
			
			npc.EnableCharacterCollisions( false );
		}
		
		if( IsNameValid( disappearfxName ))
		{
			npc.PlayEffect( disappearfxName );
			
			Sleep( 0.1f );
		}
		
		
		if ( !lair )
		{
			FindGameplayEntitiesInRange( lairEntities, GetActor(), 150, 1, 'SwarmMasterLair' );
			if ( lairEntities.Size() > 0 )
				lair = (CFlyingSwarmMasterLair)lairEntities[0];
		}
		
		if ( lair )
		{
			SleepOneFrame();
			lair.SetBirdMaster( npc );
			lair.SpawnFromBirdMaster( spawnedBirdCount );
			initialSwarmPos = lair.GetTeleportGroupPosition();
			swarmGroupId = lair.GetGroupId( 'teleport' );
			lair.SignalArrivalAtNode( 'teleport', npc, 'fastShield', swarmGroupId, delayVanish + 0.5 );
		}
		else
		{
			LogChannel( 'swarmDebug', "No lair to spawn from ! " );
			return BTNS_Failed;
		}
		
		if ( delayVanish > 0 )
		{
			Sleep( delayVanish );
		}
		else if ( teleportEventName )
		{
			while ( !vanish )
			{
				SleepOneFrame();
			}
			
			if ( performPosCheckOnTeleportEventName )
			{
				res = PosChecks( newPosition );
				
				if ( !res )
				{
					return BTNS_Failed;
				}
			}
		}
		
		
		
		
		
		
		isTeleporting = true;
		
		npc.SetGameplayVisibility( false );
		if ( forceInvisible )
		{
			npc.SetVisibility( false );
		}
		
		if ( performLastMomentPosCheck )
		{
			res = PosChecks( newPosition );
			
			if ( !res )
			{
				return BTNS_Failed;
			}
		}
		
		SafeTeleport( newPosition );
		
		if ( delayVanish > 0 )
		{
			
			Sleep( 0.2f );
			npc.EnableCharacterCollisions( false );
		}
		
		res = false;
		
		while ( !res && !fail )
		{
			
			if ( forcedDespawnTime > 0 && !despawnCalled )
			{
				Sleep( forcedDespawnTime );
				DespawnSwarm();
			}
			
			
			if( vanish && !despawnCalled )
			{
				if ( delayReappearance > 0 )
				{
					Sleep( delayReappearance );
				}
				DespawnSwarm();
			}
			
			if ( disableInvisibilityAfterReappearance )
			{
				if ( forceInvisible )
				{
					npc.SetVisibility( true );
				}
				
				
			}
			
			currTime = GetLocalTime();
			
			if ( lair.GetTeleportBirdCount() > 0 )
			{
				if ( appearFXLoopInterval > 0 && despawnCalled )
				{
					if ( currTime > fxTime )
					{
						fxTime = GetLocalTime();
						fxTime += appearFXLoopInterval;
						
						if( IsNameValid( appearFXName ))
						{
							appearFXPlayed = true;
							npc.PlayEffect( appearFXName );
						}
					}
				}
				SleepOneFrame();
			}
			else
			{
				res = true;
			}
			
			if ( currTime > lastTime )
			{
				fail = true;
			}
		}
		
		if( IsNameValid( additionalAppearFXName ))
		{
			appearFXPlayed = true;
			npc.PlayEffect( additionalAppearFXName );
		}
		
		nextTeleTime = GetLocalTime() + cooldown;
		alreadyTeleported = true;
		
		return BTNS_Completed;
	}
	
	
	
	
	
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		var birdCount : int;
		var i : int;
		
		if ( disableBoidPOIComponents )
		{
			for ( i=0 ; i < boidPOIComponents.Size() ; i+=1 )
			{
				((CBoidPointOfInterestComponent)(boidPOIComponents[i])).Disable( true );
			}
		}
		
		if ( !appearFXPlayed )
		{
			if( IsNameValid( additionalAppearFXName ))
			{
				npc.PlayEffect( additionalAppearFXName );
			}
			else if( IsNameValid( appearFXName ))
			{
				npc.PlayEffect( appearFXName );
			}
		}
		
		npc.SetCanPlayHitAnim( true );
		npc.SetUnstoppable( false );
		npc.SetImmortalityMode( AIM_None, AIC_Combat );
		
		npc.SetBehaviorVariable( 'teleport_on_hit', 0, true );
		if ( isTeleporting )
		{
			isTeleporting = false;
			vanish = false;
		}
		
		birdCount = lair.GetTeleportBirdCount();
		if ( !despawnCalled )
		{
			lair.DespawnFromBirdMaster( spawnedBirdCount );
		}
		
		if ( forceInvisible )
		{
			npc.SetVisibility( true );
		}
		
		npc.SetGameplayVisibility( true );		
		npc.EnableCharacterCollisions( true );
		
		
		npc.SetIsTeleporting( false );
		npc.RemoveBuffImmunity_AllNegative( 'teleport' );
	}
	
	
	
	
	
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var groupState : name;
		if ( !IsNameValid(teleportEventName) && eventName == 'BoidGoToRequestCompleted' )
		{
			groupState = GetEventParamCName( 'None' );
			if ( groupState == 'teleport' )
			{
				vanish = true;
			}
			return true;
		}
		return false;
	}
	
	function DespawnSwarm()
	{
		lair.DespawnFromBirdMaster( spawnedBirdCount );
		
		if( IsNameValid( appearFXName ))
		{
			GetNPC().PlayEffect( appearFXName );
		}
		
		if ( appearFXLoopInterval > 0 )
		{
			fxTime = GetLocalTime();
			fxTime += appearFXLoopInterval;
		}
		
		despawnCalled = true;
	}	
};

class CBTTaskFlyingSwarmTeleportDef extends CBTTaskTeleportDef
{
	default instanceClass = 'CBTTaskFlyingSwarmTeleport';

	editable var useAnimations 				: bool;
	editable var spawnedBirdCount 			: int;
	editable var delayVanish 				: float;
	editable var forcedDespawnTime			: float;
	editable var appearFXLoopInterval 		: float;
	editable var disableBoidPOIComponents 	: bool;
	
	default useAnimations 					= false;
	default spawnedBirdCount 				= 50;
	default delayVanish 					= 0.2;
};






class CBTTaskFlyingSwarmTeleportAttack extends CBTTaskFlyingSwarmTeleport
{
	var boidRequestCompletedEvents 	: int;
	var despawnAfterAttackTime		: float;
	var attackCompleted, res2		: bool;
	
	private var attackTimeStamp		: float;
	
	
	
	
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var npc 				: CNewNPC = GetNPC();
		var lairEntities 		: array<CGameplayEntity>;
		var target 				: CNode;
		var initialSwarmPos 	: Vector;
		var swarmGroupId 		: CFlyingGroupId;
		var currTime, lastTime 	: float;
		var newPosition 		: Vector;
		var i 					: int;
		
		if ( boidPOIComponents.Size() == 0 )
		{
			boidPOIComponents = npc.GetComponentsByClassName( 'CBoidPointOfInterestComponent' );
		}
		
		if ( boidPOIComponents.Size() == 0 )
		{
			LogChannel( 'swarmDebug', npc.GetName()+" has no CBoidPointOfInterestComponent!!" );
			return BTNS_Failed;
		}
		
		if ( disableBoidPOIComponents )
		{
			for ( i=0 ; i < boidPOIComponents.Size() ; i+=1 )
			{
				((CBoidPointOfInterestComponent)(boidPOIComponents[i])).Disable( false );
			}
		}
		
		if ( useCombatTarget )
		{
			target = GetCombatTarget();
		}
		else
		{
			target = GetActionTarget();
		}
		
		boidRequestCompletedEvents = 0;
		
		if ( !performPosCheckOnTeleportEventName )
		{
			
			
			res = PosChecks( newPosition );
			
			if ( !res )
			{
				return BTNS_Failed;
			}
		}
		
		despawnCalled = false;
		attackCompleted = false;
		
		
		npc.SetIsTeleporting( true );
		
		if ( useAnimations )
		{
			npc.RaiseEvent( raiseEventName );
		}
		
		
		res = false;
		res2 = false;
		fail = false;
		
		lastTime = GetLocalTime();
		lastTime += 10;
		
		if ( delayActivation > 0 )
		{
			Sleep( delayActivation );
		}
		
		
		
		
		
		if ( delayVanish == 0 )
		{
			
			npc.EnableCharacterCollisions( false );
		}
		
		if( IsNameValid( disappearfxName ))
		{
			npc.PlayEffect( disappearfxName );
			
			Sleep( 0.1f );
		}
		
		
		if ( !lair )
		{
			FindGameplayEntitiesInRange( lairEntities, GetActor(), 150, 1, 'SwarmMasterLair' );
			if ( lairEntities.Size() > 0 )
				lair = (CFlyingSwarmMasterLair)lairEntities[0];
		}
		
		if ( lair )
		{
			SleepOneFrame();
			lair.SetBirdMaster( npc );
			lair.SpawnFromBirdMaster( spawnedBirdCount );
			initialSwarmPos = lair.GetTeleportGroupPosition();
			swarmGroupId = lair.GetGroupId( 'teleport' );
			lair.SignalArrivalAtNode( 'shieldToAttackPlayer', target, 'teleport', swarmGroupId, delayVanish + 0.5 );
		}
		else
		{
			LogChannel( 'swarmDebug', "No lair to spawn from ! " );
			return BTNS_Failed;
		}
		
		if ( delayVanish > 0 )
		{
			Sleep( delayVanish );
		}
		else if ( teleportEventName )
		{
			while ( !vanish )
			{
				SleepOneFrame();
			}
			
			if ( performPosCheckOnTeleportEventName )
			{
				res = PosChecks( newPosition );
				
				if ( !res )
				{
					return BTNS_Failed;
				}
			}
		}
		
		
		
		
		
		
		isTeleporting = true;
		
		npc.SetGameplayVisibility( false );
		if ( forceInvisible )
		{
			npc.SetVisibility( false );
		}
		
		if ( performLastMomentPosCheck )
		{
			res = PosChecks( newPosition );
			
			if ( !res )
			{
				return BTNS_Failed;
			}
		}
		
		res = false;
		
		SafeTeleport( newPosition );
		
		if ( delayVanish > 0 )
		{
			
			Sleep( 0.2f );
			npc.EnableCharacterCollisions( false );
		}
		
		while ( !res && !fail )
		{
			
			if ( attackCompleted && !res2 )
			{
				SleepOneFrame();
				lair.SignalArrivalAtNode( 'teleport', npc, 'fastShield', swarmGroupId );
				res2 = true;
			}
			
			if ( forcedDespawnTime > 0 && !despawnCalled )
			{
				Sleep( forcedDespawnTime );
				DespawnSwarm();
			}
			
			
			if( vanish && !despawnCalled )
			{
				if ( delayReappearance > 0 )
				{
					Sleep( delayReappearance );
				}
				DespawnSwarm();
			}
			
			if ( despawnAfterAttackTime > 0 && attackCompleted && attackTimeStamp + despawnAfterAttackTime >= GetLocalTime() )
			{
				DespawnSwarm();
			}
			
			if ( disableInvisibilityAfterReappearance )
			{
				if ( forceInvisible )
				{
					npc.SetVisibility( true );
				}
				
				
			}
			
			currTime = GetLocalTime();
			
			if ( lair.GetTeleportBirdCount() > 0 )
			{
				if ( appearFXLoopInterval > 0 && despawnCalled )
				{
					if ( currTime > fxTime )
					{
						fxTime = GetLocalTime();
						fxTime += appearFXLoopInterval;
						
						if( IsNameValid( appearFXName ))
						{
							appearFXPlayed = true;
							npc.PlayEffect( appearFXName );
						}
					}
				}
				SleepOneFrame();
			}
			else
			{
				res = true;
			}
			
			if ( currTime > lastTime )
			{
				fail = true;
			}
		}
		
		if( IsNameValid( additionalAppearFXName ))
		{
			appearFXPlayed = true;
			npc.PlayEffect( additionalAppearFXName );
		}
		
		nextTeleTime = GetLocalTime() + cooldown;
		alreadyTeleported = true;
		
		return BTNS_Completed;
	}
	
	
	
	
	
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var groupState : name;
		if ( !IsNameValid(teleportEventName) && eventName == 'BoidGoToRequestCompleted' )
		{
			boidRequestCompletedEvents += 1;
			
			if ( boidRequestCompletedEvents == 1 )
			{
				attackCompleted = true;
				attackTimeStamp = GetLocalTime();
			}
			if ( boidRequestCompletedEvents >= 2 )
			{
				groupState = GetEventParamCName( 'None' );
				if ( groupState == 'teleport' )
				{
					vanish = true;
				}
			}
			return true;
		}
		return false;
	}	
};

class CBTTaskFlyingSwarmTeleportAttackDef extends CBTTaskFlyingSwarmTeleportDef
{
	editable var despawnAfterAttackTime : float;
	
	default despawnAfterAttackTime = 3;
	
	default instanceClass = 'CBTTaskFlyingSwarmTeleportAttack';
};
