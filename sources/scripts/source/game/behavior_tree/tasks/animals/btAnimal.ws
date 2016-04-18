/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class CBTTaskAnimalSetIsScared extends IBehTreeTask
{
	var value 				: bool;
	var setOnDeactivate 	: bool;
	var aiStorageHandler 	: CAIStorageHandler;
	function OnActivate() : EBTNodeStatus
	{
		var animalData 	: CAIStorageAnimalData;
		if ( setOnDeactivate == false )
		{
			animalData 			= (CAIStorageAnimalData)aiStorageHandler.Get();
			animalData.scared 	= value;
		}
		return BTNS_Active;
	}
	function OnDeactivate()
	{
		var animalData 	: CAIStorageAnimalData;
		if ( setOnDeactivate )
		{
			animalData 			= (CAIStorageAnimalData)aiStorageHandler.Get();
			animalData.scared 	= value;
		}
	}
	function Initialize()
	{
		aiStorageHandler = new CAIStorageHandler in this;
		aiStorageHandler.Initialize( 'AnimalData', '*CAIStorageAnimalData', this );
		aiStorageHandler.Get();
	}
}

class CBTTaskAnimalSetIsScaredDef extends IBehTreeHorseTaskDefinition
{
	default instanceClass = 'CBTTaskAnimalSetIsScared';
	editable var value 				: bool;
	editable var setOnDeactivate 	: bool;
	default value 					= false;
}




class CBTCondAnimalIsScared extends IBehTreeTask
{	
	var aiStorageHandler : CAIStorageHandler;
	function IsAvailable() : bool
	{
		var animalData 	: CAIStorageAnimalData;
		
		if( GetNPC().GetAttitudeGroup() == 'animals' || GetNPC().GetAttitudeGroup() == 'AG_small_animals' )
		{
			
		}
		
		animalData 			= (CAIStorageAnimalData)aiStorageHandler.Get();
		return animalData.scared;
	}
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var animalData 	: CAIStorageAnimalData;
		animalData 			= (CAIStorageAnimalData)aiStorageHandler.Get();
		animalData.scared 	= true;
		
		return true;
	}
	function Initialize()
	{
		aiStorageHandler = new CAIStorageHandler in this;
		aiStorageHandler.Initialize( 'AnimalData', '*CAIStorageAnimalData', this );
		aiStorageHandler.Get();
	}
};


class CBTCondAnimalIsScaredDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondAnimalIsScared';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'AardHitReceived' );
		listenToGameplayEvents.PushBack( 'BeingHit' );
	}
};



class CBTCondAnimalFlee extends IBehTreeTask
{	
	var chanceOfBeingScared 			: float;
	var chanceOfBeingScaredRerollTime 	: float;
	var scaredIfTargetRuns 				: bool;
	var maxTolerableTargetDistance		: float;
	
	var rollSaysScared					: bool;
	var rerollChanceTime 				: float;
	
	default rollSaysScared 		= false;
	default rerollChanceTime 	= 0.0f;
	function IsAvailable() : bool
	{
		var target 					: CActor 				= GetCombatTarget();
		var owner 					: CActor 				= GetActor();
		var attitude				: EAIAttitude;
		var dice					: Float 				= -1.0f;
		var distanceToTargetSquared : float;
		var localTime				: float;
		
		localTime = GetLocalTime();
		
		if ( rerollChanceTime < localTime )
		{
			rerollChanceTime = localTime + chanceOfBeingScaredRerollTime;
			rollSaysScared = RandF() <= chanceOfBeingScared;
		}
		
		if ( rollSaysScared )
		{
			return true;
		}
		
		if ( !target )
		{
			return false;
		}
		
		attitude 	= GetAttitudeBetween( owner, target );	
		
		if ( scaredIfTargetRuns && target.GetMovingAgentComponent().GetRelativeMoveSpeed() >= target.GetMovingAgentComponent().GetMoveTypeRelativeMoveSpeed( MT_Run ) )
		{
			return true;
		}
		distanceToTargetSquared = VecDistanceSquared( target.GetWorldPosition(), owner.GetWorldPosition() );
		if ( distanceToTargetSquared < maxTolerableTargetDistance * maxTolerableTargetDistance )
		{
			return true;
		}
		if ( attitude == AIA_Hostile )
		{
			return true;
		}
		
		return false;
	}
};


class CBTCondAnimalFleeDef extends IBehTreeHorseConditionalTaskDefinition
{
	default instanceClass = 'CBTCondAnimalFlee';

	editable var chanceOfBeingScared 			: CBehTreeValFloat;
	editable var chanceOfBeingScaredRerollTime 	: CBehTreeValFloat;
	editable var scaredIfTargetRuns				: CBehTreeValBool;
	editable var maxTolerableTargetDistance		: CBehTreeValFloat;
};




class CBTTaskReactToHostility extends IBehTreeTask
{	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var l_npc : CNewNPC = GetNPC();
		var horseComp 	: W3HorseComponent;
		
		if ( l_npc.IsHorse() )
		{
			horseComp = GetNPC().GetHorseComponent();
			if ( horseComp )
			{
				switch( horseComp.riderSharedParams.mountStatus )
				{
					case VMS_mountInProgress:
						return false;
					case VMS_mounted:
						return false;
					case VMS_dismountInProgress:
						return false;
					default :
						break;
				}
			}
		}
		
		l_npc.SignalGameplayEventParamFloat( 'AI_NeutralIsDanger', 10 ); 
		
		return true;
	}
};


class CBTTaskReactToHostilityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskReactToHostility';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'BeingHit' );
	}
};