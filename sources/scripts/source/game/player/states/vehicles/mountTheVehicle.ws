/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


state MountTheVehicle in CR4Player extends Base
{
	protected var vehicle 		: CVehicleComponent;
	protected var mountType 		: EMountType;
	protected var vehicleSlot		: EVehicleSlot;
	
	private var camera : CCustomCamera;
	
	default mountType 	= MT_normal;


	
	
	

	event OnEnterState( prevStateName : name )
	{
		var exceptions : array< EInputActionBlock >;
		
		exceptions.PushBack( EIAB_Movement );
		exceptions.PushBack( EIAB_DismountVehicle );
		parent.BlockAllActions( 'MountVehicle', true, exceptions, true );
		
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		
		super.OnEnterState( prevStateName );
	}
	
	event OnLeaveState( nextStateName : name )
	{ 
		super.OnLeaveState( nextStateName );
		
		vehicle = NULL;
		parent.RemoveTimer( 'UpdateTraverser' );
		parent.BlockAllActions( 'MountVehicle', false );
	}
	
	
	
	
	
	final function SetupState( v : CVehicleComponent, inMountType : EMountType, inVehicleSlot : EVehicleSlot )
	{
		LogAssert( !vehicle, "MountTheVehicle::SetupState, 'vehicle' is already set" );
		
		vehicle 	= v;
		mountType 	= inMountType;
		vehicleSlot	= inVehicleSlot;
	}
	
	cleanup function MountCleanup()
	{
	
	}
	
	protected function OnMountingFailed()
	{	
		vehicle.OnDismountStarted( parent );
		vehicle.OnDismountFinished( parent, thePlayer.GetRiderData().sharedParams.vehicleSlot );
		
		parent.ActionCancelAll();
		parent.EnableCharacterCollisions( true );
		parent.RegisterCollisionEventsListener();
	}
	
	function ContinuedState()
	{
		parent.PopState( true );
	}

	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		var vehicleHeading : float;
	
		vehicleHeading = vehicle.GetHeading();
		moveData.pivotRotationController.SetDesiredHeading( vehicleHeading, 0.25 );
		
		return true;
	}
}
