/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3NotificationData extends CObject
{
	public var messageText : string;
	public var duration    : float;
	default duration = 0;
}

class CR4OverlayPopup extends CR4PopupBase
{
	private var m_InitDataObject         : W3NotificationData;
	
	private var m_fxShowNotification     : CScriptedFlashFunction;
	private var m_fxHideNotification     : CScriptedFlashFunction;
	
	private var m_fxShowLoadingIndicator : CScriptedFlashFunction;
	private var m_fxHideLoadingIndicator : CScriptedFlashFunction;
	private var m_fxShowSavingIndicator  : CScriptedFlashFunction;
	private var m_fxHideSavingIndicator  : CScriptedFlashFunction;
	
	private var m_fxAppendButton  		  : CScriptedFlashFunction;
	private var m_fxRemoveButton  		  : CScriptedFlashFunction;
	private var m_fxRemoveContextButtons  : CScriptedFlashFunction;
	private var m_fxUpdateButtons 		  : CScriptedFlashFunction;
	
	private var m_fxShowMouseCursor  	   : CScriptedFlashFunction;
	private var m_fxShowSafeRect 		   : CScriptedFlashFunction;
	
	
	private var m_cursorRequested		   : int;
	private var m_cursorHidden			   : bool;
	
	event  OnConfigUI()
	{
		super.OnConfigUI();
		
		m_fxShowNotification = m_flashModule.GetMemberFlashFunction( "showNotification" );
		m_fxHideNotification = m_flashModule.GetMemberFlashFunction( "hideNotification" );
		
		m_fxShowLoadingIndicator = m_flashModule.GetMemberFlashFunction( "showLoadIdicator" );
		m_fxHideLoadingIndicator = m_flashModule.GetMemberFlashFunction( "hideLoadIdicator" );
		m_fxShowSavingIndicator = m_flashModule.GetMemberFlashFunction( "showSaveIdicator" );
		m_fxHideSavingIndicator = m_flashModule.GetMemberFlashFunction( "hideSaveIdicator" );
		
		m_fxAppendButton = m_flashModule.GetMemberFlashFunction( "appendBinding" );
		m_fxRemoveButton = m_flashModule.GetMemberFlashFunction( "removeBinding" );
		m_fxRemoveContextButtons = m_flashModule.GetMemberFlashFunction( "removeAllContextBinding" );
		m_fxUpdateButtons = m_flashModule.GetMemberFlashFunction( "updateInputFeedback" );
		
		m_fxShowMouseCursor = m_flashModule.GetMemberFlashFunction( "showMouseCursor" );		
		
		m_fxShowSafeRect = m_flashModule.GetMemberFlashFunction( "showSafeRect" );
		
		m_InitDataObject = (W3NotificationData)GetPopupInitData();
		if (m_InitDataObject)
		{
			ShowNotification(m_InitDataObject.messageText, m_InitDataObject.duration);
		}
		
		m_cursorRequested = theGame.GetGuiManager().mouseCursorRequestStack;
		if (m_cursorRequested > 0)
		{
			UpdateCursorVisibility();
		}
		
		UpdateInputDevice();
	}
	
	event OnInputHandled(NavCode:string, KeyCode:int, ActionId:int)
	{
		
	}
	
	public function RequestMouseCursor(value:bool):void
	{
		if (value)
		{
			m_cursorRequested+=1;
		}
		else
		if (m_cursorRequested > 0)
		{
			m_cursorRequested-=1;
		}
		
		UpdateCursorVisibility();
	}
	
	public function ForceHideMouseCursor(value:bool):void
	{
		m_cursorHidden = value;
		UpdateCursorVisibility();
	}
	
	public function UpdateGamepadType():void
	{
		UpdateInputDeviceType();
		UpdateInputDevice();
	}
	
	public function UpdateInputDevice():void
	{
		var isGamepad:bool = theInput.LastUsedGamepad();
		
		UpdateCursorVisibility();
		SetControllerType(isGamepad);
	}
	
	private function ShowSoftwareCursor()
	{
		m_fxShowMouseCursor.InvokeSelfOneArg( FlashArgBool( true ) );
	}
	
	private function HideSoftwareCursor()
	{
		m_fxShowMouseCursor.InvokeSelfOneArg( FlashArgBool( false ) );
	}
	
	private function ShowCursor()
	{
		if ( theGame.IsSoftwareCursor() )
		{
			ShowSoftwareCursor();
			theGame.HideHardwareCursor();
		}
		else
		{
			HideSoftwareCursor();
			theGame.ShowHardwareCursor();
		}
	}
	
	private function HideCursor()
	{
		HideSoftwareCursor();
		theGame.HideHardwareCursor();
	}
	
	private function UpdateCursorVisibility():void
	{
		var isGamepad:bool = theInput.LastUsedGamepad();
		
		if (!isGamepad && !m_cursorHidden && m_cursorRequested > 0)
		{
			ShowCursor();
		}
		else
		{
			HideCursor();
		}
	}
	
	public function ShowSafeRect(value:bool):void
	{
		m_fxShowSafeRect.InvokeSelfOneArg( FlashArgBool(value) );
	}
	
	public function AppendButton(actionId:int, gpadCode:string, kbCode:int, label:string, optional contextId:name):void
	{
		m_fxAppendButton.InvokeSelfFiveArgs(FlashArgInt(actionId), FlashArgString(gpadCode), FlashArgInt(kbCode), FlashArgString(label), FlashArgUInt(NameToFlashUInt(contextId)));
	}
	
	public function RemoveButton(actionId:int, optional contextId:name):void
	{
		m_fxRemoveButton.InvokeSelfTwoArgs(FlashArgInt(actionId), FlashArgUInt(NameToFlashUInt(contextId)));
	}
	
	public function RemoveContextButtons(contextId:name):void
	{
		m_fxRemoveContextButtons.InvokeSelfOneArg(FlashArgUInt(NameToFlashUInt(contextId)));
	}
	
	public function UpdateButtons():void
	{
		m_fxUpdateButtons.InvokeSelf();		
	}
	
	public function ShowNotification(messageText : string, optional duration : float) : void
	{
		m_fxShowNotification.InvokeSelfTwoArgs( FlashArgString(messageText), FlashArgNumber(duration) );
	}
	
	public function HideNotification() : void
	{
		m_fxHideNotification.InvokeSelf();
	}
	
	public function ShowLoadingIndicator():void
	{
		m_fxShowLoadingIndicator.InvokeSelf();
	}
	
	
	public function HideLoadingIndicator(optional immediateHide : bool):void
	{
		m_fxHideLoadingIndicator.InvokeSelfOneArg(FlashArgBool(immediateHide));
	}
	
	public function ShowSavingIndicator():void
	{
		m_fxShowSavingIndicator.InvokeSelf();
	}
	
	
	public function HideSavingIndicator(optional immediateHide : bool):void
	{
		m_fxHideSavingIndicator.InvokeSelfOneArg(FlashArgBool(immediateHide));
	}
	
}

exec function closeoverlay()
{
	theGame.ClosePopup( 'OverlayPopup' );
}