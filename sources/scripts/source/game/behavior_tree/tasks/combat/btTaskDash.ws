/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class CBTTaskDash extends CBTTaskPlayAnimationEventDecorator
{
	var dashChance		: int;
	var nextDashTime 	: float;
	var dashDelay		: float;
	var getStats		: bool;
	var dashBack		: bool;
	
	default dashBack = false;
	default getStats = true;
	default nextDashTime = 0.0;
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( getStats )
		{
			GetDashStats();
			getStats = false;
		}
		if ( nextDashTime > GetLocalTime() )
		{
			return false;
		}
		if (!checkDistance())
		{
			return false;
		}
		
		return Dash();
	}
	
	function checkDistance() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var dist : float;
		
		if( target )
		{	
			dist = VecDistance2D( npc.GetWorldPosition(), target.GetWorldPosition() );
			
			if( dist >= 0  && dist < 8 )
			{
				return true;
			}
		}
		return false;
	}
	
	function Dash() : bool
	{
		if( !chooseAndCheckDash() )
		{
			return false;
		}
		return true;
	}
	
	function GetDashStats()
	{
		var npc : CNewNPC = GetNPC();
		
		
		dashChance	= (int)(100*CalculateAttributeValue(npc.GetAttributeValue('dash_movement_chance')));
	}
	
	function chooseAndCheckDash() : bool
	{
		var npc : CNewNPC = GetNPC();
		var actorToTargetAngle : float;
		var target : CActor = GetCombatTarget();
		
		if (RandRange(100) < dashChance)
		{
			actorToTargetAngle = AbsF( AngleDistance( VecHeading( target.GetWorldPosition() - npc.GetWorldPosition() ), VecHeading( npc.GetHeadingVector() ) ) );
			
			if( dashBack )
			{
				npc.SetBehaviorVariable( 'DodgeDirection', (int)EDD_Back );
			}
			else if( actorToTargetAngle > -45  &&  actorToTargetAngle < 45 )
			{
				npc.SetBehaviorVariable( 'DodgeDirection', (int)EDD_Forward );
			}
			else if( actorToTargetAngle > 45  &&  actorToTargetAngle < 135 )
			{
				npc.SetBehaviorVariable( 'DodgeDirection', (int)EDD_Right );
			}
			else if( actorToTargetAngle > -135  &&  actorToTargetAngle < -45 )
			{
				npc.SetBehaviorVariable( 'DodgeDirection', (int)EDD_Left );
			}
			else
			{
				npc.SetBehaviorVariable( 'DodgeDirection', (int)EDD_Back );
			}
			return true;
		}
		return false;
	}
	
	function OnDeactivate()
	{
		nextDashTime = GetLocalTime() + dashDelay;
		return super.OnDeactivate();
	}
}

class CBTTaskDashDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskDash';

	editable var dashDelay : float;
	editable var dashBack : bool;
	
	default dashDelay = 4;
	default dashBack = false;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'Time2Dash' );
		listenToGameplayEvents.PushBack( 'LeftIdleTrigger' );
	}

}