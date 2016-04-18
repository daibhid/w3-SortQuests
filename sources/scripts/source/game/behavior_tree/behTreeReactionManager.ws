/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
import class CBehTreeReactionManager extends CObject
{
		
	import final function CreateReactionEvent( invoker : CEntity, eventName : CName, lifetime : float, distanceRange : float, broadcastInterval : float, recipientCount : int, optional skipInvoker : bool, optional setActionTargetOnBroadcast : bool ) : bool;
	import final function CreateReactionEventCustomCenter( invoker : CEntity, eventName : CName, lifetime : float, distanceRange : float, broadcastInterval : float, recipientCount : int, skipInvoker : bool, setActionTargetOnBroadcast : bool, customCenter : Vector ) : bool;
	import final function RemoveReactionEvent( invoker : CEntity, eventName : CName) : bool;
	import final function InitReactionScene( invoker : CEntity, eventName : CName, lifetime : float, distanceRange : float, broadcastInterval : float, recipientCount : int  ) : bool;
	import final function AddReactionSceneGroup( voiceset : string, group : name );
	
	private var suppressedAreas : array< CAreaComponent >;	
	
	public function RegisterReactionSceneGroups()
	{
		GlobalRegisterReactionSceneGroups();
	}
	
	public function SuppressReactions( toggle : bool, areaTag : name ) 
	{ 
		var areaEnt	: CEntity;
		var areaCmp	: CAreaComponent;
		
		areaEnt = theGame.GetEntityByTag( areaTag );
		if( areaEnt )
		{
			areaCmp = ( CAreaComponent ) areaEnt.GetComponentByClassName( 'CAreaComponent' );			
		}
		
		if( !areaCmp )
		{
			return;
		}
		
		if( toggle )
		{
			if( !suppressedAreas.Contains( areaCmp ) )
			{
				suppressedAreas.PushBack( areaCmp );
			}			
		}
		else
		{
			suppressedAreas.Remove( areaCmp );
		}
	}
	
	
	public function CreateReactionEventIfPossible( invoker : CEntity, eventName : CName, lifetime : float, distanceRange : float, broadcastInterval : float, recipientCount : int, skipInvoker : bool, optional setActionTargetOnBroadcast : bool, optional customCenter : Vector )
	{
		var suppressed : bool;
		
		suppressed = IsInSuppressed( invoker );
		
		if( !suppressed )
		{
			if( customCenter == Vector( 0, 0, 0 ) )
			{
				CreateReactionEvent( invoker, eventName, lifetime, distanceRange, broadcastInterval, recipientCount, skipInvoker, setActionTargetOnBroadcast );
			}
			else
			{
				CreateReactionEventCustomCenter( invoker, eventName, lifetime, distanceRange, broadcastInterval, recipientCount, skipInvoker, setActionTargetOnBroadcast, customCenter );
			}
			LogReactionSystem( eventName + " was sent by " + invoker + ". lifetime=" + lifetime + " distance=" + distanceRange + " interval=" + broadcastInterval ); 
		}
	}
	
	private function IsInSuppressed( invoker : CEntity ) : bool
	{
		var invokerPosition : Vector;
		var i, size : int;
		var npc : CNewNPC;
		
		npc = (CNewNPC)invoker;
		
		if ( npc.suppressBroadcastingReactions )
			return true;
			
		if ( ((CActor)invoker).IsInFistFightMiniGame() )
			return true;
		
		invokerPosition = invoker.GetWorldPosition();
		size = suppressedAreas.Size();
		
		for( i=0; i<size; i+=1 )
		{
			if( suppressedAreas[ i ].TestPointOverlap( invokerPosition ) )
			{
				return true;
			}
		}
		return false;
	}
};

import class CR4ReactionManager extends CBehTreeReactionManager
{
	import private var rainReactionsEnabled : bool;	
	
	public function SetRainReactionEnabled( enabled : bool )
	{
		rainReactionsEnabled = enabled;
	}
}

exec function CreateReactionEvent( tag : name, eventName : CName, lifetime : float, broadcastInterval : float )
{
	var invoker : CEntity;
	invoker = theGame.GetEntityByTag(tag);

	theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( invoker, eventName, lifetime, 20.0f, broadcastInterval, 1, false,);
}
