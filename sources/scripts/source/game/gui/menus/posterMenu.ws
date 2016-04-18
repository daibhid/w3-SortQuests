/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CR4PosterMenu extends CR4MenuBase
{
	private var	m_posterEntity : W3Poster;

	private var m_fxSetDescriptionSFF			: CScriptedFlashFunction;

	event  OnConfigUI()
	{	
		var flashModule : CScriptedFlashSprite;
		var description : string;

		super.OnConfigUI();
		
		flashModule = GetMenuFlash();

		m_fxSetDescriptionSFF = flashModule.GetMemberFlashFunction( "SetDescription" );

		m_posterEntity = ( W3Poster )GetMenuInitData();
		if ( m_posterEntity )
		{
			description = m_posterEntity.GetDescription();
			if ( StrLen( description ) > 0 )
			{
				description = GetLocStringByKeyExt( description );
			}
			m_fxSetDescriptionSFF.InvokeSelfOneArg( FlashArgString( description ) );
		}

		theInput.StoreContext( 'EMPTY_CONTEXT' );
	}
	
	event  OnClosingMenu()
	{
		super.OnClosingMenu();
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		
		m_posterEntity.LeavePosterPreview();
		
		OnPlaySoundEvent( "gui_noticeboard_close" );
	}

	event  OnCloseMenu()
	{
		CloseMenu();
	}
	
	function PlayOpenSoundEvent()
	{
		OnPlaySoundEvent( "gui_noticeboard_enter" );
	}
	
	function CanPostAudioSystemEvents() : bool
	{
		return false;
	}
}

exec function postermenu()
{
	theGame.RequestMenu('PosterMenu');
}