/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_Oil extends CBaseGameplayEffect
{
	private var currCount : int;			
	private var maxCount : int;				
	private var sword : SItemUniqueId;		
	
	default effectType = EET_Oil;
	default isPositive = true;
	default dontAddAbilityOnTarget = true;
	
	event OnEffectAdded(customParams : W3BuffCustomParams)
	{
		var oilParams : W3OilBuffParams;
		
		
		oilParams = (W3OilBuffParams)customParams;
		if(oilParams)
		{
			iconPath = oilParams.iconPath;
			effectNameLocalisationKey = oilParams.localizedName;
			effectDescriptionLocalisationKey = oilParams.localizedDescription;
			currCount = oilParams.currCount;
			maxCount = oilParams.maxCount;
			sword = oilParams.sword;
		}
		
		usesCustomCounter = true;
		
		super.OnEffectAdded(customParams);
	}

	public final function GetAmmoInitialCount() : int
	{
		return maxCount;
	}

	public final function GetAmmoCurrentCount() : int
	{
		return currCount;
	}

	public final function GetAmmoPercentage() : float
	{
		return currCount / maxCount;
	}
	
	public final function GetSwordItemId() : SItemUniqueId
	{
		return sword;
	}
	
	public final function UpdateCounter(c : int)
	{
		currCount = c;
	}
	
	public function CheckCustomCounter()
	{
		if ( currCount <= 0 )
		{
			isActive = false;
		}
	}
}

class W3OilBuffParams extends W3BuffCustomParams
{
	var iconPath : string;
	var localizedName : string;
	var localizedDescription : string;
	var currCount : int;
	var maxCount : int;
	var sword : SItemUniqueId;
}