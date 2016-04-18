/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_Bleeding extends W3DamageOverTimeEffect
{	
	default effectType = EET_Bleeding;
	default resistStat = CDS_BleedingRes;
	
	public function OnDamageDealt(dealtDamage : bool)
	{
		
		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;
			
			if(target.IsEffectActive(targetEffectName))
				StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;
			
			if(!target.IsEffectActive(targetEffectName))
				PlayTargetFX();
		}		
	}
}