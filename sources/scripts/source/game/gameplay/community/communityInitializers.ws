/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CSpawnTreeInitializerSetImmortality extends ISpawnTreeScriptedInitializer
{
	editable var immortalityMode : EActorImmortalityMode;

	function GetEditorFriendlyName() : string
	{
		return "SetImmortality";
	}
	
	function Init( actor : CActor ) : bool
	{
		var npc : CNewNPC;
		actor.SetImmortalityMode( immortalityMode, AIC_Default );
		npc = (CNewNPC)actor;
		if ( npc )
			npc.SetImmortalityInitialized();
			
		return true;
	}
};