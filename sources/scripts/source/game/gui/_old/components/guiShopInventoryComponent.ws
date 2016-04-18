/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3GuiShopInventoryComponent extends W3GuiBaseInventoryComponent
{
	protected function InvalidateItems( items : array<SItemUniqueId> )
	{
		
	}

	function SetInventoryFlashObjectForItem( item : SItemUniqueId, out flashObject : CScriptedFlashObject) : void
	{
		var isQuest	 : bool;
		
		super.SetInventoryFlashObjectForItem(item, flashObject);
		
		isQuest = _inv.ItemHasTag(item, 'Quest');
		
		flashObject.SetMemberFlashBool( "isQuest", isQuest );
		flashObject.SetMemberFlashBool( "isNew", false ); 
	}
	
	protected function GridPositionEnabled() : bool
	{
		return false;
	}
	
	
	protected function ShopHasInfiniteFunds() : bool
	{
		return _inv.GetFundsType() == EInventoryFunds_Unlimited;
	}

	
	public function GiveItem( itemId : SItemUniqueId, customer : W3GuiBaseInventoryComponent, optional quantity : int, optional out newItemID : SItemUniqueId ) : bool
	{
		var customerMoney : int;
		var itemPrice : int;
		var success : bool;
		var invItem : SInventoryItem;

		success = false;
		
		if( quantity < 1 )
		{
			quantity = 1;
		}

		customerMoney = customer._inv.GetMoney();

		invItem = _inv.GetItem( itemId );
		
		itemPrice = _inv.GetInventoryItemPriceModified( invItem, false ) * quantity;
		
		if ( customerMoney >= itemPrice )
		{
			success = super.GiveItem( itemId, customer, quantity, newItemID );
			if ( success )
			{
				customer._inv.RemoveMoney( itemPrice );
				
				if ( !ShopHasInfiniteFunds() )
				{
					_inv.AddMoney( itemPrice );
				}
			}
		}
		return success;
	}
	
	
	public function ReceiveItem( itemId : SItemUniqueId, giver : W3GuiBaseInventoryComponent, optional quantity : int, optional out newItemID : SItemUniqueId ) : bool
	{
		var shopMoney : int;
		var itemCost : int;
		var success : bool;
		var invItem : SInventoryItem;

		shopMoney = _inv.GetMoney();

		invItem = giver._inv.GetItem( itemId );
		
		itemCost = _inv.GetInventoryItemPriceModified( invItem, true ) * quantity;

		success = false;

		if ( itemCost >= 0 && ( shopMoney >= itemCost || ShopHasInfiniteFunds() ) )
		{
			success = super.ReceiveItem( itemId, giver, quantity, newItemID );
			if ( success )
			{
				if ( !ShopHasInfiniteFunds() )
				{
					_inv.RemoveMoney( itemCost );
				}
				giver._inv.AddMoney( itemCost );
			}
		}
		return success;
	}
	
	public function GetItemActionType( item : SItemUniqueId, optional bGetDefault : bool ) : EInventoryActionType
	{
		return IAT_Buy;
	}
	public function GetItemName(item : SItemUniqueId):name
	{
		return _inv.GetItemName(item);
	}
}


