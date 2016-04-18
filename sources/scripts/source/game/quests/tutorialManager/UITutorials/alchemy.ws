/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



state Alchemy in W3TutorialManagerUIHandler extends TutHandlerBaseState
{
	private const var INGREDIENTS, COOKED_ITEM_DESC, CATEGORIES, SELECT_SOMETHING, SELECT_THUNDERBOLT, COOK, POTIONS, PREPARATION_GO_TO : name;	
	private const var RECIPE_THUNDERBOLT : name;
	private const var POTIONS_JOURNAL : name;	
	private var isClosing : bool;
	private var isForcedTunderbolt : bool;		
	private var currentlySelectedRecipe, requiredRecipeName, selectRecipe : name;
	
		default INGREDIENTS 		= 'TutorialAlchemyIngredients';
		default COOKED_ITEM_DESC 	= 'TutorialAlchemyCookedItem';
		default CATEGORIES 			= 'TutorialAlchemyCathegories';
		default SELECT_SOMETHING 	= 'TutorialAlchemySelectRecipe';
		default SELECT_THUNDERBOLT  = 'TutorialAlchemySelectRecipeThunderbolt';
		default COOK 				= 'TutorialAlchemyCook';
		default POTIONS				= 'TutorialPotionCooked';
		default POTIONS_JOURNAL		= 'TutorialJournalPotions';
		default PREPARATION_GO_TO	= 'TutorialInventoryGoTo'; 
		default RECIPE_THUNDERBOLT  = 'Recipe for Thunderbolt 1';
		
	event OnEnterState( prevStateName : name )
	{
		var highlights : array<STutorialHighlight>;
		
		super.OnEnterState(prevStateName);
		
		isClosing = false;
		isForcedTunderbolt = (FactsQuerySum("tut_forced_preparation") > 0);
		currentlySelectedRecipe = '';
		
		if(isForcedTunderbolt)
		{
			requiredRecipeName = RECIPE_THUNDERBOLT;
			selectRecipe = SELECT_THUNDERBOLT;
			
			
			theGame.GetTutorialSystem().uiHandler.LockLeaveMenu(true);
			
			
			AddThunderBoltIngredients();
			
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(INGREDIENTS);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(COOKED_ITEM_DESC);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(CATEGORIES);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(SELECT_THUNDERBOLT);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(COOK);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(POTIONS);
			theGame.GetTutorialSystem().UnmarkMessageAsSeen(PREPARATION_GO_TO);
		}
		else
		{
			selectRecipe = SELECT_SOMETHING;
		}
		
		highlights.Resize(1);
		highlights[0].x = 0.41;
		highlights[0].y = 0.51;
		highlights[0].width = 0.27;
		highlights[0].height = 0.13;
		
		ShowHint(INGREDIENTS, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, , highlights);
	}
			
	event OnLeaveState( nextStateName : name )
	{
		isClosing = true;
		
		CloseHint(INGREDIENTS);
		CloseHint(COOKED_ITEM_DESC);
		CloseHint(CATEGORIES);
		CloseHint(selectRecipe);
		CloseHint(COOK);
		CloseHint(POTIONS);
		CloseHint(PREPARATION_GO_TO);
		
		theGame.GetTutorialSystem().MarkMessageAsSeen(INGREDIENTS);
		
		if(isForcedTunderbolt)
		{			
			
			theGame.GetTutorialSystem().uiHandler.UnregisterUIHint('Alchemy');
			theGame.GetTutorialSystem().uiHandler.UnregisterUIHint('Alchemy');
		}
		else
		{
			FactsRemove("tutorial_alch_has_ings");
		}
		
		super.OnLeaveState(nextStateName);
	}
	
	event OnTutorialClosed(hintName : name, closedByParentMenu : bool)
	{
		var highlights : array<STutorialHighlight>;
		
		if(closedByParentMenu || isClosing)
			return true;
			
		if(hintName == INGREDIENTS)
		{
			highlights.Resize(1);
			highlights[0].x = 0.68;
			highlights[0].y = 0.13;
			highlights[0].width = 0.25;
			highlights[0].height = 0.5;
			
			ShowHint(COOKED_ITEM_DESC, theGame.params.TUT_POS_ALCHEMY_X, 0.65, , highlights);
		}
		else if(hintName == COOKED_ITEM_DESC)
		{
			highlights.Resize(1);
			highlights[0].x = 0.065;
			highlights[0].y = 0.15;
			highlights[0].width = 0.35;
			highlights[0].height = 0.65;
			
			ShowHint(CATEGORIES, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, , highlights);
		}
		else if(hintName == CATEGORIES)
		{
			if(currentlySelectedRecipe == requiredRecipeName)
				ShowHint(COOK, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, ETHDT_Infinite);
			else
				ShowHint(selectRecipe, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, ETHDT_Infinite);
		}
		else if(hintName == POTIONS)
		{
			CloseHint(POTIONS);
			ShowHint(PREPARATION_GO_TO, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, ETHDT_Infinite);
			
			if(isForcedTunderbolt)
			{				
				
				thePlayer.UnblockAction(EIAB_OpenInventory, 'tut_forced_preparation');
			}
		}
	}
	
	public final function SelectedRecipe(recipeName : name, canCook : bool)
	{
		currentlySelectedRecipe = recipeName;
		
		if(IsCurrentHint(selectRecipe) && IsRecipeOk(recipeName, canCook))
		{
			CloseHint(selectRecipe);
			ShowHint(COOK, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, ETHDT_Infinite);
		}		
		else if(IsCurrentHint(COOK) && !IsRecipeOk(recipeName, canCook))
		{
			
			CloseHint(COOK);
			ShowHint(selectRecipe, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y, ETHDT_Infinite);
		}
	}
	
	private final function IsRecipeOk(recipeName : name, canCook : bool) : bool
	{
		if(isForcedTunderbolt)
		{
			return recipeName == requiredRecipeName;
		}
		else
		{
			return canCook;
		}
	}
	
	public final function CookedItem(recipeName : name)
	{
		if(isForcedTunderbolt && recipeName != requiredRecipeName)
		{
			
			AddThunderBoltIngredients();
		}
		else 
		{
			isClosing = true;	
			CloseHint(INGREDIENTS);
			CloseHint(COOKED_ITEM_DESC);
			CloseHint(CATEGORIES);
			CloseHint(selectRecipe);
			CloseHint(COOK);
			isClosing = false;
		
			ShowHint(POTIONS, theGame.params.TUT_POS_ALCHEMY_X, theGame.params.TUT_POS_ALCHEMY_Y);
			theGame.GetTutorialSystem().ActivateJournalEntry(POTIONS_JOURNAL);
		}

	}
	
	
	private final function AddThunderBoltIngredients()
	{
		var i, k, currQuantity, addQuantity, tmpInt : int;
		var tmpName : name;
		var witcher : W3PlayerWitcher;
		var dm : CDefinitionsManagerAccessor;
		var main, ingredients : SCustomNode;
		var memoryWaste : array<name>;
		
		witcher = GetWitcherPlayer();
		memoryWaste = witcher.GetAlchemyRecipes();
		
		if(!memoryWaste.Contains(RECIPE_THUNDERBOLT))
			witcher.AddAlchemyRecipe(RECIPE_THUNDERBOLT);
			
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('alchemy_recipes');		
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
			if(tmpName == RECIPE_THUNDERBOLT)
			{
				ingredients = dm.GetCustomDefinitionSubNode(main.subNodes[i],'ingredients');					
				for(k=0; k<ingredients.subNodes.Size(); k+=1)
				{		
					dm.GetCustomNodeAttributeValueName(ingredients.subNodes[k], 'item_name', tmpName);
					dm.GetCustomNodeAttributeValueInt(ingredients.subNodes[k], 'quantity', tmpInt);
					
					currQuantity = witcher.inv.GetItemQuantityByName(tmpName);
					addQuantity = tmpInt - currQuantity;
					if(addQuantity > 0)
					{
						witcher.inv.AddAnItem(tmpName, addQuantity);
					}
				}
				
				break;
			}
		}
	}
}

exec function tut_alch()
{
	TutorialMessagesEnable(true);
	theGame.GetTutorialSystem().TutorialStart(false);
	TutorialScript('alchemy', '');
}
