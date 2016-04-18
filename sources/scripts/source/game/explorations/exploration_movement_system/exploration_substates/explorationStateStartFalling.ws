/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/





enum EFallType
{
	FT_Idle		,
	FT_Walk		,
	FT_Run		,
	FT_Sprint	,
}



class CExplorationStateStartFalling extends CExplorationStateAbstract
{
	private editable	var	timeToJump		: float;		default timeToJump	= 0.2f;
	private				var fallCancelled	: bool;
	private				var fallType		: EFallType;
	private				var behFallType		: name;			default	behFallType	= 'FallType';
	

	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'StartFalling';
		}
		
		m_StateTypeE				= EST_OnAir;
		m_InputContextE				= EGCI_JumpClimb; 
		
		
		SetCanSave( false );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}

	
	function StateWantsToEnter() : bool
	{
		return false;
	}

	
	function StateCanEnter( curStateName : name ) : bool
	{	
		return curStateName != 'Jump' && curStateName != 'Swim';
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{
		fallCancelled	= false;
		
		
		thePlayer.OnRangedForceHolster( true );
		
		
		if( prevStateName == 'Idle' )
		{
			if( thePlayer.GetIsSprinting() )
			{
				fallType	= FT_Sprint;
			}
			else if( thePlayer.GetIsRunning())
			{
				fallType	= FT_Run;
			}
			else if( thePlayer.IsMoving() )
			{
				fallType	= FT_Walk;
			}
			else
			{
				fallType	= FT_Idle;
			}
		}
		else 
		{
			fallType	= FT_Idle;
		}
		
		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( behFallType, ( float ) ( int ) fallType );		
		
		
		thePlayer.AbortSign();	
	}
	
	
	function StateChangePrecheck( )	: name
	{	
		
		if( thePlayer.IsSwimming() )
		{
			return 'Swim';
		}
		
		
		if( fallCancelled )
		{
			if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) )
			{
				return 'Idle';
			}
		}
		
		
		return 'Jump';
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
	}
	
	
	
	
	
	
	function ReactToLoseGround() : bool
	{
		return true;
	}
	
	
	function ReactToHitGround() : bool
	{		
		fallCancelled	= true;
		
		return true;
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
}