/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class CR4HudModuleBuffs extends CR4HudModuleBase
{
	private var _currentEffects : array <CBaseGameplayEffect>;
	private var _previousEffects : array <CBaseGameplayEffect>;
	
	private var m_fxSetPercentSFF : CScriptedFlashFunction;
	private var m_fxShowBuffUpdateFx : CScriptedFlashFunction;
	
	private var m_flashValueStorage : CScriptedFlashValueStorage;	
	private var iCurrentEffectsSize : int;	default iCurrentEffectsSize = 0;
	private var bDisplayBuffs : bool; default bDisplayBuffs = true;
	
	private var m_runword5Applied : bool; default m_runword5Applied = false;
	
	
	

	event  OnConfigUI()
	{
		var flashModule : CScriptedFlashSprite;
		var hud : CR4ScriptedHud;
		
		m_anchorName = "mcAnchorBuffs";
		m_flashValueStorage = GetModuleFlashValueStorage();
		super.OnConfigUI();
		
		flashModule = GetModuleFlash();	
		m_fxSetPercentSFF				= flashModule.GetMemberFlashFunction( "setPercent" );
		m_fxShowBuffUpdateFx			= flashModule.GetMemberFlashFunction( "showBuffUpdateFx" );
		
		hud = (CR4ScriptedHud)theGame.GetHud();
		if (hud)
		{
			hud.UpdateHudConfig('BuffsModule', true);
		}
	}

	event OnTick( timeDelta : float )
	{
		var effectsSize : int;
		var effectArray : array< CBaseGameplayEffect >;
		var i : int;
		var offset : int;
		var duration : float;
		var initialDuration : float;
		var hasRunword5 : bool;
		var oilEffect : W3Effect_Oil;

		if ( !CanTick( timeDelta ) )
			return true;

		_previousEffects = _currentEffects;
		_currentEffects.Clear();
		
		if( bDisplayBuffs && GetEnabled() )
		{		
			offset = 0;
			
			effectArray = thePlayer.GetCurrentEffects();
			effectsSize = effectArray.Size();
			hasRunword5 = false;
			
			for ( i = 0; i < effectsSize; i += 1 )
			{
				if(effectArray[i].ShowOnHUD() && effectArray[i].GetEffectNameLocalisationKey() != "MISSING_LOCALISATION_KEY_NAME" )
				{	
					
					initialDuration = effectArray[i].GetInitialDuration();
					
					if ( (W3RepairObjectEnhancement)effectArray[i] && GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats') )
					{
						hasRunword5 = true;
						
						if (!m_runword5Applied)
						{
							m_runword5Applied = true;
							UpdateBuffs();
							break;
						}
					}
					
					if( initialDuration < 1.0)
					{
						initialDuration = 1;
						duration = 1;
					}
					else
					{
						duration = effectArray[i].GetDurationLeft();
						if(duration < 0.f)
							duration = 0.f;		
					}
					
					if ( effectArray[i].GetEffectType() == EET_Oil )
					{
						oilEffect = (W3Effect_Oil)effectArray[ i ];
						if ( oilEffect )
						{
							initialDuration = oilEffect.GetAmmoInitialCount();
							duration		= oilEffect.GetAmmoCurrentCount();
						}
					}
					
					if(_currentEffects.Size() < i+1-offset)
					{
						_currentEffects.PushBack(effectArray[i]);
						m_fxSetPercentSFF.InvokeSelfThreeArgs( FlashArgNumber(i-offset),FlashArgNumber( duration ), FlashArgNumber( initialDuration ) );
					}
					else if( effectArray[i].GetEffectType() == _currentEffects[i-offset].GetEffectType() )
					{
						m_fxSetPercentSFF.InvokeSelfThreeArgs( FlashArgNumber(i-offset),FlashArgNumber( duration ), FlashArgNumber( initialDuration ) );
					}
					else
					{
						LogChannel('HUDBuffs',i+" something wrong");
					}
				}
				else
				{
					offset += 1;
					
				}
			}
			
			if (!hasRunword5 && m_runword5Applied)
			{
				m_runword5Applied = false;
				UpdateBuffs();
			}
		}

		
		if ( _currentEffects.Size() == 0 && _previousEffects.Size() == 0 )
			return true;

		
		if ( buffListHasChanged(_currentEffects, _previousEffects) )
			UpdateBuffs();

	}

	
	private function buffListHasChanged( currentEffects : array<CBaseGameplayEffect>, previousEffects : array<CBaseGameplayEffect> ) : bool
	{
		var i : int;
		var currentSize : int = currentEffects.Size();
		var previousSize : int = previousEffects.Size();

		
		if( currentSize != previousSize )
			return true;
		else 
		{
			
			for( i = 0; i < currentSize; i+=1 )
			{
				if ( currentEffects[i] != previousEffects[i] )
					return true;
			}

			
			return false;
		}
	}

	function UpdateBuffs()
	{
		var l_flashObject			: CScriptedFlashObject;
		var l_flashArray			: CScriptedFlashArray;
		var i 						: int;
		var oilEffect				: W3Effect_Oil;

		l_flashArray = GetModuleFlashValueStorage()().CreateTempFlashArray();
		for(i = 0; i < Min(12,_currentEffects.Size()); i += 1) 
		{
			if(_currentEffects[i].ShowOnHUD() && _currentEffects[i].GetEffectNameLocalisationKey() != "MISSING_LOCALISATION_KEY_NAME" )
			{
				l_flashObject = m_flashValueStorage.CreateTempFlashObject();
				l_flashObject.SetMemberFlashBool("isVisible",_currentEffects[i].ShowOnHUD());
				l_flashObject.SetMemberFlashString("iconName",_currentEffects[i].GetIcon());
				l_flashObject.SetMemberFlashString("title",GetLocStringByKeyExt(_currentEffects[i].GetEffectNameLocalisationKey()));
				l_flashObject.SetMemberFlashBool("IsPotion",_currentEffects[i].IsPotionEffect());
				l_flashObject.SetMemberFlashBool("isPositive", !_currentEffects[i].IsNegative());
				l_flashObject.SetMemberFlashBool("usesCustomCounter", _currentEffects[i].UsesCustomCounter());
				
				if ( _currentEffects[i].GetEffectType() == EET_Oil )
				{	
					oilEffect = (W3Effect_Oil)_currentEffects[i];
					if ( oilEffect )
					{
						l_flashObject.SetMemberFlashNumber("duration",        oilEffect.GetAmmoCurrentCount() * 1.0 );
						l_flashObject.SetMemberFlashNumber("initialDuration", oilEffect.GetAmmoInitialCount() * 1.0 );
					}
				}
				else if ( (W3RepairObjectEnhancement)_currentEffects[i] && GetWitcherPlayer().HasRunewordActive('Runeword 5 _Stats') )
				{
					l_flashObject.SetMemberFlashNumber("duration", -1 );
					l_flashObject.SetMemberFlashNumber("initialDuration", -1 );
				}
				else
				{
					l_flashObject.SetMemberFlashNumber("duration",_currentEffects[i].GetDurationLeft() );
					l_flashObject.SetMemberFlashNumber("initialDuration", _currentEffects[i].GetInitialDuration());
				}
				l_flashArray.PushBackFlashObject(l_flashObject);	
			}
		}
		
		m_flashValueStorage.SetFlashArray( "hud.buffs", l_flashArray );
	}
	
	protected function UpdateScale( scale : float, flashModule : CScriptedFlashSprite ) : bool
	{
		return true;
	}
	
	protected function UpdatePosition(anchorX:float, anchorY:float) : void
	{
		var l_flashModule 		: CScriptedFlashSprite;
		var tempX				: float;
		var tempY				: float;
		
		l_flashModule 	= GetModuleFlash();
		
		
		
		
		tempX = anchorX + (660.0 * (1.0 - theGame.GetUIHorizontalFrameScale()));
		tempY = anchorY + (645.0 * (1.0 - theGame.GetUIVerticalFrameScale())); 
		
		l_flashModule.SetX( tempX );
		l_flashModule.SetY( tempY );	
	}
	
	event  OnBuffsDisplay( value : bool )
	{
		bDisplayBuffs = value;
	}
	
	public function ShowBuffUpdate() :void
	{
		m_fxShowBuffUpdateFx.InvokeSelf();
	}
}

exec function testBf()
{
	var hud : CR4ScriptedHud;
	hud = (CR4ScriptedHud)theGame.GetHud();
	if (hud)
	{
		hud.ShowBuffUpdate();
	}
}
