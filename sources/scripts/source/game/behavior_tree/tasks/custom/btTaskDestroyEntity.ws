/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CBTTaskDestroyEntity extends IBehTreeTask
{
	var entityTag : name;
	var effectName	: name;
	var playEffect	: bool;
	
	default playEffect = false;
	
	function OnActivate() : EBTNodeStatus
	{
		if( entityTag != '' )
		{
			FindAndDestoryEntity();
		}
		
		return BTNS_Active;
	}
	
	private function FindAndDestoryEntity()
	{
		var entity : CEntity; 

		entity = theGame.GetEntityByTag( entityTag );
			
		if( entity )
		{
			if( playEffect )
			{
				entity.PlayEffect('effectName');
			}
			entity.Destroy();
		}
	}
};

class CBTTaskDestroyEntityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDestroyEntity';
	editable var entityTag : name;
	editable var effectName	: name;
	editable var playEffect	: bool;
};