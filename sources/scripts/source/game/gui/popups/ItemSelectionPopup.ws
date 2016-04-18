/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3ItemSelectionPopupData extends CObject
{
	var targetInventory : CInventoryComponent;
	var filterTagsList : array<name>;
	var collectorTag : name;
	var targetItems : array<name>;
}

class CR4ItemSelectionPopup extends CR4PopupBase
{
	var m_DataObject     : W3ItemSelectionPopupData;
	var m_playerInv      : W3GuiSelectItemComponent;
	var m_containerInv   : W3GuiContainerInventoryComponent;
	var m_containerOwner : CGameplayEntity;
	
	event  OnConfigUI()
	{
		super.OnConfigUI();
		
		theInput.StoreContext( 'EMPTY_CONTEXT' );
		m_DataObject = (W3ItemSelectionPopupData)GetPopupInitData();		
		
		if (!m_DataObject)
		{
			ClosePopup();
		}
		
		if (theInput.LastUsedPCInput())
		{
			theGame.MoveMouseTo(0.5, 0.5);
		}
		
		m_playerInv = new W3GuiSelectItemComponent in this;
		m_playerInv.Initialize( thePlayer.GetInventory() );
		m_playerInv.filterTagList = m_DataObject.filterTagsList;
		m_playerInv.SetFilterType(IFT_QuestItems);
		
		m_containerOwner = (CGameplayEntity)theGame.GetEntityByTag( m_DataObject.collectorTag );
		
		
		
		UpdateData();
		
		
		m_guiManager.RequestMouseCursor(true);
		theGame.ForceUIAnalog(true);
		
		theGame.Pause("ItemSelectionPopup");
	}
	
	event  OnCloseSelectionPopup()
	{
		ClosePopup();
	}
	
	event  OnCallSelectItem(itemId : SItemUniqueId)
	{
		var len, i : int;
		
		if (thePlayer.GetInventory().IsIdValid(itemId))
		{
			len = m_DataObject.targetItems.Size();
			for (i = 0; i < len; i=i+1 )
			{
				if (m_DataObject.targetItems[i] == m_playerInv.GetItemName(itemId))
				{
					thePlayer.GetInventory().GiveItemTo( m_containerOwner.GetInventory(), itemId, 1 );
					break;
				}
			}
			ClosePopup();
		}
	}
	
	event  OnInventoryItemSelected(itemId : SItemUniqueId)
	{
		
	}
	
	event  OnClosingPopup()
	{
		theGame.Unpause("ItemSelectionPopup");
		
		if (m_containerInv)
		{
			delete m_containerInv;
		}
		
		if (m_playerInv)
		{
			delete m_playerInv;
		}
		
		theInput.RestoreContext( 'EMPTY_CONTEXT', true );
		theGame.ForceUIAnalog(false);
		m_guiManager.RequestMouseCursor(false);
		
		super.OnClosingPopup();
	}
	
	private function UpdateData():void
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		
		l_flashObject = m_flashValueStorage.CreateTempFlashObject();
		l_flashArray = m_flashValueStorage.CreateTempFlashArray();		
		m_playerInv.GetInventoryFlashArray(l_flashArray, l_flashObject);		
		m_flashValueStorage.SetFlashArray( "repair.grid.player", l_flashArray );
	}
	
}