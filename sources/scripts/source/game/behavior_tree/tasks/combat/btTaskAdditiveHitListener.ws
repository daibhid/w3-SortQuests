/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class BTTaskAdditiveHitListener extends IBehTreeTask
{
	var currentFightStageIs 	: ENPCFightStage;
	var playHitSound 			: bool;
	var sounEventName 			: string;
	var boneName 				: name;
	var timeStamp 				: float;
	var manageIgnoreSignsEvents : bool;
	var angleToIgnoreSigns		: float;
	var chanceToUseAdditive		: float;
	
	default timeStamp = 0;
	
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		GetActor().AddAbility( 'AdditiveHits' );
		return BTNS_Active;
	}
	
	
	
	function OnGameplayEvent( eventName : name ) : bool
	{		
		var owner 	: CNewNPC = GetNPC();
		var data 	: CDamageData;
		
		if ( eventName == 'BeingHit' && timeStamp + 0.4 <= GetLocalTime() )
		{
			data = (CDamageData) GetEventParamBaseDamage();
			if ( data.additiveHitReactionAnimRequested )
			{
				if( playHitSound && sounEventName != "None" && sounEventName != "")
				{
					if(owner.GetBoneIndex(boneName) != -1)
					{
						owner.SoundEvent(sounEventName, boneName);
					}
					else
					{
						owner.SoundEvent(sounEventName);
					}
				}
				owner.RaiseEvent('AdditiveHit');
				timeStamp = GetLocalTime();
			}
		}
		
		return false;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var npc 				: CNewNPC = GetNPC();
		var playerToOwnerAngle 	: float;
		
		
		if ( manageIgnoreSignsEvents )
		{
			if ( eventName == 'IgnoreSigns' )
			{
				playerToOwnerAngle = AbsF( NodeToNodeAngleDistance( thePlayer, npc ) );
				
				if( npc.UseAdditiveCriticalState() && !npc.IsUnstoppable() && playerToOwnerAngle <= angleToIgnoreSigns )
				{
					npc.RaiseEvent( 'IgnoreSigns' );
				}
				return true;
			}
			
			if ( eventName == 'IgnoreSignsEnd' )
			{
				npc.RaiseEvent( 'IgnoreSignsEnd' );
				return true;
			}
		}
		return false;
	}
}

class BTTaskAdditiveHitListenerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskAdditiveHitListener';

	editable var playHitSound 				: bool;
	editable var sounEventName 				: string;
	editable var boneName 					: name;
	editable var manageIgnoreSignsEvents	: bool;
	editable var angleToIgnoreSigns			: float;
	editable var chanceToUseAdditive		: float;
	
	default angleToIgnoreSigns = 45;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'IgnoreSigns' );
		listenToGameplayEvents.PushBack( 'IgnoreSignsEnd' );
	}
}

