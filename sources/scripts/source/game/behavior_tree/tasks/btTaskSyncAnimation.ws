/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class CBTTaskPlaySyncedAnimation extends IBehTreeTask
{
	private var isRunning				: bool;
	private var shouldStartAnimation	: bool;
	
	private var syncInstance	: CAnimationManualSlotSyncInstance;
	private var sequenceIndex	: int;
	
	private	var forceEventOnEnd	: name;
	private var gameplayEventOnEnd : name;
	
	private var finisherSyncAnim : bool;
	private var completeSuccess : bool;
	
	function IsAvailable() : bool
	{
		if ( isActive || shouldStartAnimation )
		{
			return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		if( !isRunning )
		{
			isRunning = true;
			shouldStartAnimation = false;
		}
		owner.EnableCharacterCollisions( false );
		owner.SetCanPlayHitAnim( false );
		
		
		owner.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		while( true )
		{
			if( syncInstance )
			{
				if( syncInstance.HasEnded() )
				{
					completeSuccess = true;
					return BTNS_Completed;
				}
			}
			else
			{
				return BTNS_Failed;
			}
			
			SleepOneFrame();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var owner : CActor = GetActor();
		
		if ( completeSuccess && finisherSyncAnim )
		{
			GetActor().DropItemFromSlot( 'r_weapon' );
			GetActor().DropItemFromSlot( 'l_weapon' );
			GetActor().BreakAttachment();
			GetNPC().DisableDeathAndAgony();
			owner.SetImmortalityMode( AIM_None, AIC_Combat );
			owner.Kill(false, GetWitcherPlayer() );
			owner.RaiseEvent('FinisherDeath');
		}
		
		if( syncInstance && sequenceIndex > -1 )
		{
			syncInstance.StopSequence( sequenceIndex );
		}
		
		if ( !finisherSyncAnim )
			owner.EnableCharacterCollisions( true );
		
		isRunning = false;
		shouldStartAnimation = false;
		syncInstance = NULL;
		forceEventOnEnd = 'None';
		gameplayEventOnEnd = 'None';
		finisherSyncAnim = false;
		completeSuccess = false;
		
		owner.SetImmortalityMode( AIM_None, AIC_Combat );
		
		
		owner.SetCanPlayHitAnim( true );
	}
	
	function OnCompletion( success : bool )
	{
		if( forceEventOnEnd )
		{
			GetActor().RaiseForceEvent( forceEventOnEnd );
		}
		if ( gameplayEventOnEnd )
		{
			GetActor().SignalGameplayEvent( gameplayEventOnEnd );
		}
	}
	
	function OnListenedGameplayEvent( gameEventName : name ) : bool
	{
		var owner : CActor = GetActor();
		if ( gameEventName == 'PlaySyncedAnim' )
		{
			shouldStartAnimation = true;
			return true;
		}
		else if ( gameEventName == 'PlayFinisherSyncedAnim' )
		{
			shouldStartAnimation = true;
			finisherSyncAnim = true;
			return true;
		}
		else if ( gameEventName == 'SetupSyncInstance' )
		{
			syncInstance = theGame.GetSyncAnimManager().GetSyncInstance( GetEventParamInt( -1 ) );
		}
		else if ( gameEventName == 'SetupSequenceIndex' )
		{
			sequenceIndex = GetEventParamInt( -1 );
		}
		else if ( gameEventName == 'SetupEndEvent' )
		{
			forceEventOnEnd = GetEventParamCName( 'None' );
		}
		else if ( gameEventName == 'SetupEndGameplayEvent' )
		{
			gameplayEventOnEnd = GetEventParamCName( 'None' );
		}
		
		return false;
	}
	
	function OnGameplayEvent( gameEventName : name ) : bool
	{
		if ( gameEventName == 'FinisherInterrupt' && GetActor().IsAlive() )
		{
			if ( theGame.GetSyncAnimManager().BreakSyncIfPossible( GetActor() ) )
			{
				finisherSyncAnim = false;
				((CNewNPC)GetActor()).FinisherAnimInterrupted();
				Complete(false);
			}
		}
		else if ( gameEventName == 'FinisherKill' && GetActor().IsAlive() )
		{
			thePlayer.SpawnFinisherBlood();
			GetActor().SetHealth(0.1f);
		}
		
		return false;
	}
}

class CBTTaskPlaySyncedAnimationDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPlaySyncedAnimation';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'PlaySyncedAnim' );
		listenToGameplayEvents.PushBack( 'PlayFinisherSyncedAnim' );
		listenToGameplayEvents.PushBack( 'SetupSyncInstance' );
		listenToGameplayEvents.PushBack( 'SetupSequenceIndex' );
		listenToGameplayEvents.PushBack( 'SetupEndEvent' );
		listenToGameplayEvents.PushBack( 'SetupEndGameplayEvent' );
	}
}
