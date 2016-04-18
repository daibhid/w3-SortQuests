/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/






import struct SCardDefinition
{
	import var index			: int;
	import var title			: string;
	import var description		: string;
	import var power			: int;
	import var picture			: string;
	import var faction			: eGwintFaction;
	import var typeFlags		: int;
	import var effectFlags		: array< eGwintEffect >;
	import var summonFlags		: array< int >;
	
	
	import var dlcPictureFlag	: name; 	
	import var dlcPicture		: string;
}


import struct SDeckDefinition
{
	import var cardIndices				: array< int >;
	import var leaderIndex 				: int;
	import var unlocked  				: bool;
	import var specialCard				: int;
	import var dynamicCardRequirements	: array< int >;
	import var dynamicCards 			: array< int >;
};

import struct CollectionCard
{
	import var cardID 		: int;
	import var numCopies 	: int;
}

import class CR4GwintManager extends IGameSystem
{
	public var testMatch:bool; default testMatch = false;
	
	import final function GetCardDefs() : array<SCardDefinition>;
	import final function GetLeaderDefs() : array<SCardDefinition>;
	
	import final function GetFactionDeck(faction:eGwintFaction, out deck:SDeckDefinition) : bool;
	import final function SetFactionDeck(faction:eGwintFaction, deck:SDeckDefinition) : void;
	
	import final function GetPlayerCollection() : array<CollectionCard>;
	import final function GetPlayerLeaderCollection() : array<CollectionCard>;
	
	import final function GetSelectedPlayerDeck() : eGwintFaction;
	import final function SetSelectedPlayerDeck(index : eGwintFaction) : void;
	
	import final function UnlockDeck(index : eGwintFaction) : void;
	import final function IsDeckUnlocked(index : eGwintFaction) : bool;
	
	import final function AddCardToCollection(cardIndex : int) : void;
	import final function RemoveCardFromCollection(cardIndex : int) : void;
	import final function HasCardInCollection(cardIndex : int) : bool;
	
	import final function AddCardToDeck(faction:eGwintFaction, cardIndex : int) : void;
	import final function RemoveCardFromDeck(faction:eGwintFaction, cardIndex : int) : void;
	
	import final function GetHasDoneTutorial() : bool;
	import final function SetHasDoneTutorial(value : bool) : void;
	
	import final function GetHasDoneDeckTutorial() : bool;
	import final function SetHasDoneDeckTutorial(value : bool) : void;
	
	public function HasLootedCard() : bool
	{
		return FactsDoesExist("Gwint_Card_Looted");
	}
	
	event  OnGwintSetupNewgame()
	{
		var northernPlayerDeck : SDeckDefinition;
		var nilfgardPlayerDeck : SDeckDefinition;
		var scotialPlayerDeck : SDeckDefinition;
		var nmlPlayerDeck : SDeckDefinition;
	
		
		northernPlayerDeck.cardIndices.PushBack( 3 ); 
		northernPlayerDeck.cardIndices.PushBack( 3 ); 
		northernPlayerDeck.cardIndices.PushBack( 4 ); 
		northernPlayerDeck.cardIndices.PushBack( 4 ); 
		northernPlayerDeck.cardIndices.PushBack( 5 ); 
		northernPlayerDeck.cardIndices.PushBack( 6 ); 
		northernPlayerDeck.cardIndices.PushBack( 106 ); 
		northernPlayerDeck.cardIndices.PushBack( 111 ); 
		northernPlayerDeck.cardIndices.PushBack( 112 ); 
		northernPlayerDeck.cardIndices.PushBack( 113 ); 
		northernPlayerDeck.cardIndices.PushBack( 114 ); 
		northernPlayerDeck.cardIndices.PushBack( 115 ); 
		northernPlayerDeck.cardIndices.PushBack( 116 ); 
		northernPlayerDeck.cardIndices.PushBack( 120 ); 
		northernPlayerDeck.cardIndices.PushBack( 121 ); 
		northernPlayerDeck.cardIndices.PushBack( 125 ); 
		northernPlayerDeck.cardIndices.PushBack( 125 ); 
		northernPlayerDeck.cardIndices.PushBack( 135 ); 
		northernPlayerDeck.cardIndices.PushBack( 145 ); 
		northernPlayerDeck.cardIndices.PushBack( 150 ); 
		northernPlayerDeck.cardIndices.PushBack( 150 ); 
		northernPlayerDeck.cardIndices.PushBack( 150 ); 
		northernPlayerDeck.cardIndices.PushBack( 107 ); 
		northernPlayerDeck.cardIndices.PushBack( 160 ); 
		northernPlayerDeck.cardIndices.PushBack( 160 ); 
		northernPlayerDeck.cardIndices.PushBack( 175 ); 
		AddCardToCollection(108); 
		AddCardToCollection(136); 
		
		
		northernPlayerDeck.leaderIndex = 1001;
		northernPlayerDeck.specialCard = -1; 
		northernPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_NothernKingdom, northernPlayerDeck);
		
		
		nilfgardPlayerDeck.leaderIndex = 2001;
		nilfgardPlayerDeck.specialCard = -1; 
		nilfgardPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_Nilfgaard, nilfgardPlayerDeck);
		
		
		
		scotialPlayerDeck.leaderIndex = 3001;
		scotialPlayerDeck.specialCard = -1; 
		scotialPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_Scoiatael, scotialPlayerDeck);
		
		
		
		nmlPlayerDeck.leaderIndex = 4001;
		nmlPlayerDeck.specialCard = -1; 
		nmlPlayerDeck.unlocked = false;
		SetFactionDeck(GwintFaction_NoMansLand, nmlPlayerDeck);
		
		UnlockDeck(GwintFaction_NothernKingdom);
		UnlockDeck(GwintFaction_Nilfgaard);
		UnlockDeck(GwintFaction_Scoiatael);
		UnlockDeck(GwintFaction_NoMansLand);
		
		SetSelectedPlayerDeck(GwintFaction_NothernKingdom);
	}
	
	public function GetTutorialPlayerDeck() : SDeckDefinition
	{
		var tutorialDeck : SDeckDefinition;
		
		
		tutorialDeck.cardIndices.PushBack( 3 ); 
		tutorialDeck.cardIndices.PushBack( 3 ); 
		tutorialDeck.cardIndices.PushBack( 4 ); 
		tutorialDeck.cardIndices.PushBack( 4 ); 
		tutorialDeck.cardIndices.PushBack( 5 ); 
		tutorialDeck.cardIndices.PushBack( 6 ); 
		
		tutorialDeck.cardIndices.PushBack( 106 ); 
		tutorialDeck.cardIndices.PushBack( 111 ); 
		tutorialDeck.cardIndices.PushBack( 112 ); 
		tutorialDeck.cardIndices.PushBack( 113 ); 
		tutorialDeck.cardIndices.PushBack( 114 ); 
		tutorialDeck.cardIndices.PushBack( 115 ); 
		tutorialDeck.cardIndices.PushBack( 116 ); 
		tutorialDeck.cardIndices.PushBack( 120 ); 
		tutorialDeck.cardIndices.PushBack( 121 ); 
		tutorialDeck.cardIndices.PushBack( 126 ); 
		tutorialDeck.cardIndices.PushBack( 127 ); 
		tutorialDeck.cardIndices.PushBack( 135 ); 
		tutorialDeck.cardIndices.PushBack( 145 ); 
		tutorialDeck.cardIndices.PushBack( 150 ); 
		tutorialDeck.cardIndices.PushBack( 151 ); 
		tutorialDeck.cardIndices.PushBack( 152 ); 
		tutorialDeck.cardIndices.PushBack( 107 ); 
		tutorialDeck.cardIndices.PushBack( 160 ); 
		tutorialDeck.cardIndices.PushBack( 161 ); 
		tutorialDeck.cardIndices.PushBack( 175 ); 
		tutorialDeck.leaderIndex = 1001;
		tutorialDeck.specialCard = -1; 
		
		return tutorialDeck;
	}
	
	protected function setupEnemyDecks() : void
	{
		if (!enemyDecksSet)
		{
			enemyDecksSet = true;
			
			
			SetupAIDeckDefinitions();			
			SetupAIDeckDefinitions1();
			SetupAIDeckDefinitions2();
			SetupAIDeckDefinitions3();
			SetupAIDeckDefinitions4();
			SetupAIDeckDefinitions5();
			SetupAIDeckDefinitions6();
			SetupAIDeckDefinitions7();
			SetupAIDeckDefinitionsNK();
			SetupAIDeckDefinitionsNilf();
			SetupAIDeckDefinitionsScoia();
			SetupAIDeckDefinitionsNML();
			SetupAIDeckDefinitionsPrologue();
			SetupAIDeckDefinitionsTournament1();
			SetupAIDeckDefinitionsTournament2();
			
			SetupAIDeckDefinitions8();
			SetupAIDeckDefinitions9();
			SetupAIDeckDefinitions10();
		}
	}
	
	
	
	
	
	private var enemyDecksSet : bool; default enemyDecksSet = false;
	private var enemyDecks : array< SDeckDefinition >;
	private var selectedEnemyDeck : int;
	
	private var difficulty : int;

	private var diff1 : int;
	private var diff2 : int;
	private var diff3 : int;
	private var diff4 : int;
	private var diff5 : int;
	private var diff6 : int;
	private var diff7 : int;
	private var diff8 : int;
	private var diff9 : int;
	private var diff10 : int;
	private var diff11 : int;
	private var diff12 : int;
	private var diff13 : int;
	private var diff14 : int;
	private var diff15 : int;
	
	private var doubleAIEnabled : bool;
	
	public var gameRequested : bool; default gameRequested = false;
	
	public function setDoubleAIEnabled(value:bool):void
	{
		doubleAIEnabled = value;
	}
	
	public function getDoubleAIEnabled():bool
	{
		return doubleAIEnabled;
	}
	
	public function GetCurrentPlayerDeck() : SDeckDefinition
	{
		var selectedDeck : SDeckDefinition;
		GetFactionDeck(GetSelectedPlayerDeck(), selectedDeck);
		
		return selectedDeck;
	}
	
	public function HasUnlockedDeck():bool
	{
		if (!IsDeckUnlocked(GwintFaction_NoMansLand) && !IsDeckUnlocked(GwintFaction_Nilfgaard) &&
			!IsDeckUnlocked(GwintFaction_NothernKingdom) && !IsDeckUnlocked(GwintFaction_Scoiatael))
		{
			return false;
		}
		
		return true;
	}
	
	public function SetEnemyDeckIndex(deckIndex:int):void
	{
		selectedEnemyDeck = deckIndex;
	}
	
	public function SetEnemyDeckByName(deckname:name):void
	{
		switch(deckname)
		{
		case 'CardProdigy':
			selectedEnemyDeck = 0;
			break;
		case 'Dijkstra':
			selectedEnemyDeck = 1;
			break;
		case 'Baron':
			selectedEnemyDeck = 2;
			break;
		case 'Roche':
			selectedEnemyDeck = 3;
			break;
		case 'Sjusta':
			selectedEnemyDeck = 4;
			break;
		case 'Stjepan':
			selectedEnemyDeck = 5;
			break;
		case 'CrossroadsInnkeeper':
			selectedEnemyDeck = 6;
			break;
		case 'BoatBuilder':
			selectedEnemyDeck = 7;
			break;
		case 'MarkizaSerenity':
			selectedEnemyDeck = 8;
			break;
		case 'Gremista':
			selectedEnemyDeck = 9;
			break;
		case 'Zoltan':
			selectedEnemyDeck = 10;
			break;
		case 'Lambert':
			selectedEnemyDeck = 11;
			break;
		case 'Thaler':
			selectedEnemyDeck = 12;
			break;
		case 'VimmeVivaldi':
			selectedEnemyDeck = 13;
			break;
		case 'ScoiaTrader':
			selectedEnemyDeck = 14;
			break;
		case 'Crach':
			selectedEnemyDeck = 15;
			break;
		case 'LugosTheMad':
			selectedEnemyDeck = 16;
			break;
		case 'Hermit':
			selectedEnemyDeck = 17;
			break;
		case 'Olivier':
			selectedEnemyDeck = 18;
			break;
		case 'Mousesack':
			selectedEnemyDeck = 19;
			break;
		case 'NKEasy':
			selectedEnemyDeck = 20;
			break;
		case 'NKNormal':
			selectedEnemyDeck = 21;
			break;
		case 'NKHard':
			selectedEnemyDeck = 22;
			break;
		case 'NilfEasy':
			selectedEnemyDeck = 23;
			break;
		case 'NilfNormal':
			selectedEnemyDeck = 24;
			break;
		case 'NilfHard':
			selectedEnemyDeck = 25;
			break;
		case 'ScoiaEasy':
			selectedEnemyDeck = 26;
			break;
		case 'ScoiaNormal':
			selectedEnemyDeck = 27;
			break;
		case 'ScoiaHard':
			selectedEnemyDeck = 28;
			break;
		case 'NMLEasy':
			selectedEnemyDeck = 29;
			break;
		case 'NMLNormal':
			selectedEnemyDeck = 30;
			break;
		case 'NMLHard':
			selectedEnemyDeck = 31;
			break;
		case 'NilfPrologue':
			selectedEnemyDeck = 32;
			break;
		case 'NKTournament':
			selectedEnemyDeck = 33;
			break;
		case 'NilfTournament':
			selectedEnemyDeck = 34;
			break;
		case 'ScoiaTournament':
			selectedEnemyDeck = 35;
			break;
		case 'NMLTournament':
			selectedEnemyDeck = 36;
			break;
		case 'Shani':
			selectedEnemyDeck = 37;
			break;
		case 'Olgierd':
			selectedEnemyDeck = 38;
			break;
		case 'Gambler':
			selectedEnemyDeck = 39;
			break;
		case 'Halflings':
			selectedEnemyDeck = 40;
			break;
		case 'CircusGwentAddict':
			selectedEnemyDeck = 41;
			break;
		default:
			selectedEnemyDeck = 23;
			break;
		}
	}
	
	public function GetCardDefinition(cardIndex:int) : SCardDefinition
	{
		var cardDefinitions : array<SCardDefinition>;
		var errorDefinition : SCardDefinition;
		var currentDefinition : SCardDefinition;
		var i:int;
		
		if (cardIndex >= 1000)
		{
			cardDefinitions = GetLeaderDefs();
		}
		else
		{
			cardDefinitions = GetCardDefs();
		}
		
		for (i = 0; i < cardDefinitions.Size(); i += 1)
		{
			currentDefinition = cardDefinitions[i];
			if (currentDefinition.index == cardIndex)
			{
				return currentDefinition;
			}
		}
		
		errorDefinition.index = -1;
		
		return errorDefinition;
	}
	
	public function GetCurrentAIDeck() : SDeckDefinition
	{
		GenerateDifficultyData();

		setupEnemyDecks(); 
		
		return enemyDecks[selectedEnemyDeck];
	}
		
	private function GenerateDifficultyData()
	{
		var difficultyBalanceValue : int;
		difficultyBalanceValue = 0;

		difficulty = FactsQueryLatestValue("gwent_difficulty");

		if (difficulty)
		{
			
			if (difficulty == 1) 
			{ 
				difficultyBalanceValue += 80;
			}
			
			if (difficulty == 2) 
			{ 
				difficultyBalanceValue += 0;
			}
			
			if (difficulty == 3) 
			{ 
				difficultyBalanceValue -= 80;
			}
		}

		diff1 = 145 + difficultyBalanceValue;
		diff2 = 150 + difficultyBalanceValue;
		diff3 = 155 + difficultyBalanceValue;
		diff4 = 160 + difficultyBalanceValue;
		diff5 = 165 + difficultyBalanceValue;
		diff6 = 170 + difficultyBalanceValue;
		diff7 = 175 + difficultyBalanceValue;
		diff8 = 180 + difficultyBalanceValue;
		diff9 = 185 + difficultyBalanceValue;
		diff10 = 190 + difficultyBalanceValue;
		diff11 = 205 + difficultyBalanceValue;
		diff12 = 215 + difficultyBalanceValue;
		diff13 = 220 + difficultyBalanceValue;
		diff14 = 225 + difficultyBalanceValue;
		diff15 = 230 + difficultyBalanceValue;		
	}
		
	private function SetupAIDeckDefinitions()
	{
		var CardProdigyDeck		:SDeckDefinition;
		var DijkstraDeck		:SDeckDefinition;
		var BaronDeck			:SDeckDefinition;

		
		
			
			

			
			
			
			if (difficulty == 1)
			{
				CardProdigyDeck.cardIndices.PushBack(1); 
				CardProdigyDeck.cardIndices.PushBack(4); 
				CardProdigyDeck.cardIndices.PushBack(4); 
				CardProdigyDeck.cardIndices.PushBack(6); 
				CardProdigyDeck.cardIndices.PushBack(6); 
				CardProdigyDeck.cardIndices.PushBack(135); 
				CardProdigyDeck.cardIndices.PushBack(136); 
				CardProdigyDeck.cardIndices.PushBack(107); 
			}
			if (difficulty == 2)
			{
				CardProdigyDeck.cardIndices.PushBack(1); 
				CardProdigyDeck.cardIndices.PushBack(1); 
				CardProdigyDeck.cardIndices.PushBack(2); 
				CardProdigyDeck.cardIndices.PushBack(4); 
				CardProdigyDeck.cardIndices.PushBack(4); 
				CardProdigyDeck.cardIndices.PushBack(6); 
				CardProdigyDeck.cardIndices.PushBack(6); 
				CardProdigyDeck.cardIndices.PushBack(107); 
			}
			if (difficulty == 3)
			{
				CardProdigyDeck.cardIndices.PushBack(1); 
				CardProdigyDeck.cardIndices.PushBack(0); 
				CardProdigyDeck.cardIndices.PushBack(2); 
				CardProdigyDeck.cardIndices.PushBack(4); 
				CardProdigyDeck.cardIndices.PushBack(6); 
				CardProdigyDeck.cardIndices.PushBack(140); 
				CardProdigyDeck.cardIndices.PushBack(141); 
				CardProdigyDeck.cardIndices.PushBack(9); 
			}

			CardProdigyDeck.cardIndices.PushBack(125); 
			CardProdigyDeck.cardIndices.PushBack(126); 
			CardProdigyDeck.cardIndices.PushBack(127); 
			CardProdigyDeck.cardIndices.PushBack(130); 
			CardProdigyDeck.cardIndices.PushBack(131); 
			CardProdigyDeck.cardIndices.PushBack(132); 
			CardProdigyDeck.cardIndices.PushBack(140); 
			CardProdigyDeck.cardIndices.PushBack(141); 
			CardProdigyDeck.cardIndices.PushBack(145); 
			CardProdigyDeck.cardIndices.PushBack(146); 
			CardProdigyDeck.cardIndices.PushBack(160); 
			CardProdigyDeck.cardIndices.PushBack(161); 
			CardProdigyDeck.cardIndices.PushBack(162); 

			

			CardProdigyDeck.dynamicCardRequirements.PushBack(diff5);
			CardProdigyDeck.dynamicCards.PushBack(2); 
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff7);
			CardProdigyDeck.dynamicCards.PushBack(2); 
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff9);
			CardProdigyDeck.dynamicCards.PushBack(103); 
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff11);
			CardProdigyDeck.dynamicCards.PushBack(102); 
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff11);
			CardProdigyDeck.dynamicCards.PushBack(109); 
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff14);
			CardProdigyDeck.dynamicCards.PushBack(101); 
			CardProdigyDeck.dynamicCardRequirements.PushBack(diff14);
			CardProdigyDeck.dynamicCards.PushBack(12); 

			CardProdigyDeck.specialCard = 100; 
			CardProdigyDeck.leaderIndex = 1001;
			enemyDecks.PushBack(CardProdigyDeck);
			
			
			
			

			

			
			DijkstraDeck.cardIndices.PushBack(0); 
			DijkstraDeck.cardIndices.PushBack(1); 
			DijkstraDeck.cardIndices.PushBack(3); 
			DijkstraDeck.cardIndices.PushBack(4); 
			DijkstraDeck.cardIndices.PushBack(6); 
			
			if (difficulty == 1)
			{	
				DijkstraDeck.cardIndices.PushBack(3); 
				DijkstraDeck.cardIndices.PushBack(4); 
				DijkstraDeck.cardIndices.PushBack(108); 
				DijkstraDeck.cardIndices.PushBack(136); 
			}
			if (difficulty == 2)
			{
				DijkstraDeck.cardIndices.PushBack(2); 
				DijkstraDeck.cardIndices.PushBack(0); 
				DijkstraDeck.cardIndices.PushBack(3); 
				DijkstraDeck.cardIndices.PushBack(4); 
				DijkstraDeck.cardIndices.PushBack(6); 
			}
			if (difficulty == 3)
			{
				DijkstraDeck.cardIndices.PushBack(0); 
				DijkstraDeck.cardIndices.PushBack(101); 
				DijkstraDeck.cardIndices.PushBack(9); 
			}

			DijkstraDeck.cardIndices.PushBack(14); 
			DijkstraDeck.cardIndices.PushBack(105); 
			DijkstraDeck.cardIndices.PushBack(111); 
			DijkstraDeck.cardIndices.PushBack(120); 
			DijkstraDeck.cardIndices.PushBack(121); 
			DijkstraDeck.cardIndices.PushBack(140); 
			DijkstraDeck.cardIndices.PushBack(141); 
			DijkstraDeck.cardIndices.PushBack(145); 
			DijkstraDeck.cardIndices.PushBack(146); 
			DijkstraDeck.cardIndices.PushBack(150); 
			DijkstraDeck.cardIndices.PushBack(160); 
			DijkstraDeck.cardIndices.PushBack(161); 
			DijkstraDeck.cardIndices.PushBack(170); 
			DijkstraDeck.cardIndices.PushBack(175); 

			

			DijkstraDeck.dynamicCardRequirements.PushBack(diff5);
			DijkstraDeck.dynamicCards.PushBack(2); 
			DijkstraDeck.dynamicCardRequirements.PushBack(diff7);
			DijkstraDeck.dynamicCards.PushBack(2); 
			DijkstraDeck.dynamicCardRequirements.PushBack(diff9);
			DijkstraDeck.dynamicCards.PushBack(16); 
			DijkstraDeck.dynamicCardRequirements.PushBack(diff11);
			DijkstraDeck.dynamicCards.PushBack(101); 
			DijkstraDeck.dynamicCardRequirements.PushBack(diff11);
			DijkstraDeck.dynamicCards.PushBack(109); 
			DijkstraDeck.dynamicCardRequirements.PushBack(diff14);
			DijkstraDeck.dynamicCards.PushBack(116); 
			DijkstraDeck.dynamicCardRequirements.PushBack(diff14);
			DijkstraDeck.dynamicCards.PushBack(12); 
			
			
			DijkstraDeck.specialCard = 102; 
			DijkstraDeck.leaderIndex = 1002; 
			enemyDecks.PushBack(DijkstraDeck);
			
			
			
			BaronDeck.cardIndices.PushBack(2); 
			BaronDeck.cardIndices.PushBack(3); 
			BaronDeck.cardIndices.PushBack(5); 
			BaronDeck.cardIndices.PushBack(5); 

			if (difficulty == 1)
			{	
				BaronDeck.cardIndices.PushBack(108); 
				BaronDeck.cardIndices.PushBack(13); 
				BaronDeck.cardIndices.PushBack(5); 
			}
			if (difficulty == 2)
			{
				BaronDeck.cardIndices.PushBack(2); 
			}
			if (difficulty == 3)
			{
				BaronDeck.cardIndices.PushBack(0); 
				BaronDeck.cardIndices.PushBack(0); 
				BaronDeck.cardIndices.PushBack(101); 
			}
			
			BaronDeck.cardIndices.PushBack(105); 
			BaronDeck.cardIndices.PushBack(111); 
			BaronDeck.cardIndices.PushBack(112); 
			BaronDeck.cardIndices.PushBack(116); 
			BaronDeck.cardIndices.PushBack(121); 
			BaronDeck.cardIndices.PushBack(125); 
			BaronDeck.cardIndices.PushBack(125); 
			BaronDeck.cardIndices.PushBack(125); 
			BaronDeck.cardIndices.PushBack(130); 
			BaronDeck.cardIndices.PushBack(131); 
			BaronDeck.cardIndices.PushBack(132); 
			BaronDeck.cardIndices.PushBack(140); 
			BaronDeck.cardIndices.PushBack(145); 
			BaronDeck.cardIndices.PushBack(160); 
			BaronDeck.cardIndices.PushBack(161); 
			BaronDeck.cardIndices.PushBack(162); 
			BaronDeck.cardIndices.PushBack(170); 

			

			BaronDeck.dynamicCardRequirements.PushBack(diff5);
			BaronDeck.dynamicCards.PushBack(1); 
			BaronDeck.dynamicCardRequirements.PushBack(diff7);
			BaronDeck.dynamicCards.PushBack(8); 
			BaronDeck.dynamicCardRequirements.PushBack(diff9);
			BaronDeck.dynamicCards.PushBack(120); 
			BaronDeck.dynamicCardRequirements.PushBack(diff11);
			BaronDeck.dynamicCards.PushBack(11); 
			BaronDeck.dynamicCardRequirements.PushBack(diff11);
			BaronDeck.dynamicCards.PushBack(12); 
			BaronDeck.dynamicCardRequirements.PushBack(diff14);
			BaronDeck.dynamicCards.PushBack(15); 
			BaronDeck.dynamicCardRequirements.PushBack(diff14);
			BaronDeck.dynamicCards.PushBack(7); 

			BaronDeck.specialCard = 109; 
			BaronDeck.leaderIndex = 1001;
			enemyDecks.PushBack(BaronDeck);
			
	}
	
	private function SetupAIDeckDefinitions1()
	{
		var RocheDeck			:SDeckDefinition;
		var SjustaDeck			:SDeckDefinition;


			
			RocheDeck.cardIndices.PushBack(0); 
			RocheDeck.cardIndices.PushBack(1); 
			RocheDeck.cardIndices.PushBack(4); 
			RocheDeck.cardIndices.PushBack(6); 
			
			if (difficulty == 1)
			{	
				RocheDeck.cardIndices.PushBack(6); 
				RocheDeck.cardIndices.PushBack(108); 
				RocheDeck.cardIndices.PushBack(136); 
			}
			if (difficulty == 2)
			{
				RocheDeck.cardIndices.PushBack(0); 
				RocheDeck.cardIndices.PushBack(1); 
				RocheDeck.cardIndices.PushBack(136); 
			}
			if (difficulty == 3)
			{
				RocheDeck.cardIndices.PushBack(0); 
				RocheDeck.cardIndices.PushBack(1); 
				RocheDeck.cardIndices.PushBack(9); 
			}
			
			RocheDeck.cardIndices.PushBack(101); 
			RocheDeck.cardIndices.PushBack(120); 
			RocheDeck.cardIndices.PushBack(121); 
			RocheDeck.cardIndices.PushBack(125); 
			RocheDeck.cardIndices.PushBack(126); 
			RocheDeck.cardIndices.PushBack(127); 
			RocheDeck.cardIndices.PushBack(135); 
			RocheDeck.cardIndices.PushBack(140); 
			RocheDeck.cardIndices.PushBack(141); 
			RocheDeck.cardIndices.PushBack(145); 
			RocheDeck.cardIndices.PushBack(146); 
			RocheDeck.cardIndices.PushBack(150); 
			RocheDeck.cardIndices.PushBack(151); 
			RocheDeck.cardIndices.PushBack(170); 
			RocheDeck.cardIndices.PushBack(175); 


			RocheDeck.dynamicCardRequirements.PushBack(diff5);
			RocheDeck.dynamicCards.PushBack(15); 
			RocheDeck.dynamicCardRequirements.PushBack(diff7);
			RocheDeck.dynamicCards.PushBack(2); 
			RocheDeck.dynamicCardRequirements.PushBack(diff9);
			RocheDeck.dynamicCards.PushBack(10); 
			RocheDeck.dynamicCardRequirements.PushBack(diff11);
			RocheDeck.dynamicCards.PushBack(11); 
			RocheDeck.dynamicCardRequirements.PushBack(diff11);
			RocheDeck.dynamicCards.PushBack(8); 
			RocheDeck.dynamicCardRequirements.PushBack(diff14);
			RocheDeck.dynamicCards.PushBack(12); 
			RocheDeck.dynamicCardRequirements.PushBack(diff14);
			RocheDeck.dynamicCards.PushBack(7); 


			RocheDeck.specialCard = -1;
			RocheDeck.leaderIndex = 1003; 
			enemyDecks.PushBack(RocheDeck);
			
			
			
			SjustaDeck.cardIndices.PushBack(0); 
			SjustaDeck.cardIndices.PushBack(2); 

			if (difficulty == 1)
			{	
				SjustaDeck.cardIndices.PushBack(135); 
				SjustaDeck.cardIndices.PushBack(136); 
				SjustaDeck.cardIndices.PushBack(108); 
			}
			if (difficulty == 2)
			{
				SjustaDeck.cardIndices.PushBack(0); 
				SjustaDeck.cardIndices.PushBack(1); 
				SjustaDeck.cardIndices.PushBack(135); 
				SjustaDeck.cardIndices.PushBack(136); 
				SjustaDeck.cardIndices.PushBack(108); 
			}
			if (difficulty == 3)
			{
				SjustaDeck.cardIndices.PushBack(0); 
				SjustaDeck.cardIndices.PushBack(1); 
			}

			SjustaDeck.cardIndices.PushBack(12); 
			SjustaDeck.cardIndices.PushBack(13); 
			SjustaDeck.cardIndices.PushBack(106); 
			SjustaDeck.cardIndices.PushBack(109); 
			SjustaDeck.cardIndices.PushBack(111); 
			SjustaDeck.cardIndices.PushBack(112); 
			SjustaDeck.cardIndices.PushBack(113); 
			SjustaDeck.cardIndices.PushBack(116); 
			SjustaDeck.cardIndices.PushBack(125); 
			SjustaDeck.cardIndices.PushBack(126); 
			SjustaDeck.cardIndices.PushBack(130); 
			SjustaDeck.cardIndices.PushBack(131); 
			SjustaDeck.cardIndices.PushBack(132); 
			SjustaDeck.cardIndices.PushBack(160); 
			SjustaDeck.cardIndices.PushBack(161); 

			SjustaDeck.dynamicCardRequirements.PushBack(diff5);
			SjustaDeck.dynamicCards.PushBack(15);
			SjustaDeck.dynamicCardRequirements.PushBack(diff7);
			SjustaDeck.dynamicCards.PushBack(2); 
			SjustaDeck.dynamicCardRequirements.PushBack(diff9);
			SjustaDeck.dynamicCards.PushBack(9);
			SjustaDeck.dynamicCardRequirements.PushBack(diff11);
			SjustaDeck.dynamicCards.PushBack(11);
			SjustaDeck.dynamicCardRequirements.PushBack(diff11);
			SjustaDeck.dynamicCards.PushBack(8);
			SjustaDeck.dynamicCardRequirements.PushBack(diff14);
			SjustaDeck.dynamicCards.PushBack(10);
			SjustaDeck.dynamicCardRequirements.PushBack(diff14);
			SjustaDeck.dynamicCards.PushBack(7); 

			SjustaDeck.specialCard = -1;
			SjustaDeck.leaderIndex = 1004; 
			enemyDecks.PushBack(SjustaDeck);


	}
	private function SetupAIDeckDefinitions2()
	{
		var StjepanDeck			:SDeckDefinition;
		var CrossroadsDeck		:SDeckDefinition;
		var BoatBuilderDeck		:SDeckDefinition;

		
		
			
			
			StjepanDeck.cardIndices.PushBack(0); 
			StjepanDeck.cardIndices.PushBack(3); 
			StjepanDeck.cardIndices.PushBack(4); 

			if (difficulty == 1)
			{	
				StjepanDeck.cardIndices.PushBack(3); 
				StjepanDeck.cardIndices.PushBack(5); 
				StjepanDeck.cardIndices.PushBack(215); 
			}
			if (difficulty == 2)
			{
				StjepanDeck.cardIndices.PushBack(0); 
				StjepanDeck.cardIndices.PushBack(3); 
				StjepanDeck.cardIndices.PushBack(5); 
				StjepanDeck.cardIndices.PushBack(215); 
			}
			if (difficulty == 3)
			{
				StjepanDeck.cardIndices.PushBack(0); 
			}

			StjepanDeck.cardIndices.PushBack(206); 
			StjepanDeck.cardIndices.PushBack(207); 
			StjepanDeck.cardIndices.PushBack(208); 
			StjepanDeck.cardIndices.PushBack(210); 
			StjepanDeck.cardIndices.PushBack(213); 
			StjepanDeck.cardIndices.PushBack(214); 
	
			StjepanDeck.cardIndices.PushBack(218); 
			StjepanDeck.cardIndices.PushBack(235); 
			StjepanDeck.cardIndices.PushBack(236); 
			StjepanDeck.cardIndices.PushBack(240); 
			StjepanDeck.cardIndices.PushBack(241); 
			StjepanDeck.cardIndices.PushBack(245); 
			StjepanDeck.cardIndices.PushBack(246); 
			StjepanDeck.cardIndices.PushBack(247); 
			StjepanDeck.cardIndices.PushBack(230); 
			StjepanDeck.cardIndices.PushBack(231); 


			StjepanDeck.dynamicCardRequirements.PushBack(diff5);
			StjepanDeck.dynamicCards.PushBack(15);
			StjepanDeck.dynamicCardRequirements.PushBack(diff7);
			StjepanDeck.dynamicCards.PushBack(230);
			StjepanDeck.dynamicCardRequirements.PushBack(diff9);
			StjepanDeck.dynamicCards.PushBack(2); 
			StjepanDeck.dynamicCardRequirements.PushBack(diff11);
			StjepanDeck.dynamicCards.PushBack(231);
			StjepanDeck.dynamicCardRequirements.PushBack(diff11);
			StjepanDeck.dynamicCards.PushBack(8);
			StjepanDeck.dynamicCardRequirements.PushBack(diff14);
			StjepanDeck.dynamicCards.PushBack(12);
			StjepanDeck.dynamicCardRequirements.PushBack(diff14);
			StjepanDeck.dynamicCards.PushBack(7); 


			StjepanDeck.specialCard = 9; 
			StjepanDeck.leaderIndex = 2003; 
			enemyDecks.PushBack(StjepanDeck);
			
			
			CrossroadsDeck.cardIndices.PushBack(1); 
			CrossroadsDeck.cardIndices.PushBack(2); 
			CrossroadsDeck.cardIndices.PushBack(6); 

			if (difficulty == 1)
			{	
				CrossroadsDeck.cardIndices.PushBack(4); 
				CrossroadsDeck.cardIndices.PushBack(4); 
				CrossroadsDeck.cardIndices.PushBack(6); 
				CrossroadsDeck.cardIndices.PushBack(209); 
				CrossroadsDeck.cardIndices.PushBack(212); 
			}
			if (difficulty == 2)
			{
				CrossroadsDeck.cardIndices.PushBack(2); 
				CrossroadsDeck.cardIndices.PushBack(4); 
				CrossroadsDeck.cardIndices.PushBack(4); 
				CrossroadsDeck.cardIndices.PushBack(6); 
				CrossroadsDeck.cardIndices.PushBack(209); 
				CrossroadsDeck.cardIndices.PushBack(212); 
			}
			if (difficulty == 3)
			{
				CrossroadsDeck.cardIndices.PushBack(2); 
				CrossroadsDeck.cardIndices.PushBack(4); 
			}

			CrossroadsDeck.cardIndices.PushBack(211); 
			CrossroadsDeck.cardIndices.PushBack(213); 
			CrossroadsDeck.cardIndices.PushBack(230); 
			CrossroadsDeck.cardIndices.PushBack(231); 
			CrossroadsDeck.cardIndices.PushBack(235); 
			CrossroadsDeck.cardIndices.PushBack(236); 
			CrossroadsDeck.cardIndices.PushBack(240); 
			CrossroadsDeck.cardIndices.PushBack(241); 
			CrossroadsDeck.cardIndices.PushBack(245); 
			CrossroadsDeck.cardIndices.PushBack(246); 
			CrossroadsDeck.cardIndices.PushBack(247); 
			CrossroadsDeck.cardIndices.PushBack(248); 
			CrossroadsDeck.cardIndices.PushBack(250); 
			CrossroadsDeck.cardIndices.PushBack(251); 
			CrossroadsDeck.cardIndices.PushBack(252); 
			CrossroadsDeck.cardIndices.PushBack(265); 


			CrossroadsDeck.dynamicCardRequirements.PushBack(diff5);
			CrossroadsDeck.dynamicCards.PushBack(15);
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff7);
			CrossroadsDeck.dynamicCards.PushBack(0);
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff9);
			CrossroadsDeck.dynamicCards.PushBack(1);
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff11);
			CrossroadsDeck.dynamicCards.PushBack(11);
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff11);
			CrossroadsDeck.dynamicCards.PushBack(13);
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff14);
			CrossroadsDeck.dynamicCards.PushBack(7); 
			CrossroadsDeck.dynamicCardRequirements.PushBack(diff14);
			CrossroadsDeck.dynamicCards.PushBack(10);

			CrossroadsDeck.specialCard = 201; 
			CrossroadsDeck.leaderIndex = 2002; 
			enemyDecks.PushBack(CrossroadsDeck);
			
			
			BoatBuilderDeck.cardIndices.PushBack(0); 
			BoatBuilderDeck.cardIndices.PushBack(2); 
			BoatBuilderDeck.cardIndices.PushBack(3); 
			BoatBuilderDeck.cardIndices.PushBack(4); 
			BoatBuilderDeck.cardIndices.PushBack(6); 

			if (difficulty == 1)
			{	
				BoatBuilderDeck.cardIndices.PushBack(5); 
				BoatBuilderDeck.cardIndices.PushBack(209); 
			}
			if (difficulty == 2)
			{
				BoatBuilderDeck.cardIndices.PushBack(0); 
				BoatBuilderDeck.cardIndices.PushBack(1); 
				BoatBuilderDeck.cardIndices.PushBack(5); 
				BoatBuilderDeck.cardIndices.PushBack(209); 
			}
			if (difficulty == 3)
			{
				BoatBuilderDeck.cardIndices.PushBack(0); 
				BoatBuilderDeck.cardIndices.PushBack(1); 
			}

			BoatBuilderDeck.cardIndices.PushBack(202); 
			BoatBuilderDeck.cardIndices.PushBack(206); 
			BoatBuilderDeck.cardIndices.PushBack(214); 
			BoatBuilderDeck.cardIndices.PushBack(218); 
			BoatBuilderDeck.cardIndices.PushBack(220); 
			BoatBuilderDeck.cardIndices.PushBack(235); 
			BoatBuilderDeck.cardIndices.PushBack(236); 
			BoatBuilderDeck.cardIndices.PushBack(240); 
			BoatBuilderDeck.cardIndices.PushBack(241); 
			BoatBuilderDeck.cardIndices.PushBack(245); 
			BoatBuilderDeck.cardIndices.PushBack(246); 
			BoatBuilderDeck.cardIndices.PushBack(250); 
			BoatBuilderDeck.cardIndices.PushBack(255); 
			BoatBuilderDeck.cardIndices.PushBack(265); 

			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff5);
			BoatBuilderDeck.dynamicCards.PushBack(247);
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff7);
			BoatBuilderDeck.dynamicCards.PushBack(248);
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff9);
			BoatBuilderDeck.dynamicCards.PushBack(251);
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff11);
			BoatBuilderDeck.dynamicCards.PushBack(252);
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff11);
			BoatBuilderDeck.dynamicCards.PushBack(260);
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff14);
			BoatBuilderDeck.dynamicCards.PushBack(7); 
			BoatBuilderDeck.dynamicCardRequirements.PushBack(diff14);
			BoatBuilderDeck.dynamicCards.PushBack(12);

			BoatBuilderDeck.specialCard = 200; 
			BoatBuilderDeck.leaderIndex = 2004; 
			enemyDecks.PushBack(BoatBuilderDeck);
			

	}
	
	
	private function SetupAIDeckDefinitions3()
	{

		var MarkizaDeck			:SDeckDefinition;
		var GremistaDeck		:SDeckDefinition;


			
			MarkizaDeck.cardIndices.PushBack(1); 
			MarkizaDeck.cardIndices.PushBack(2); 
			MarkizaDeck.cardIndices.PushBack(4); 
			MarkizaDeck.cardIndices.PushBack(6); 

			if (difficulty == 1)
			{	
				MarkizaDeck.cardIndices.PushBack(3); 
				MarkizaDeck.cardIndices.PushBack(3); 
				MarkizaDeck.cardIndices.PushBack(5); 
				MarkizaDeck.cardIndices.PushBack(210); 
			}
			if (difficulty == 2)
			{
				MarkizaDeck.cardIndices.PushBack(3); 
				MarkizaDeck.cardIndices.PushBack(3); 
				MarkizaDeck.cardIndices.PushBack(5); 
				MarkizaDeck.cardIndices.PushBack(0); 
				MarkizaDeck.cardIndices.PushBack(1); 
				MarkizaDeck.cardIndices.PushBack(2); 
				MarkizaDeck.cardIndices.PushBack(210); 
			}
			if (difficulty == 3)
			{
				MarkizaDeck.cardIndices.PushBack(3); 
				MarkizaDeck.cardIndices.PushBack(0); 
				MarkizaDeck.cardIndices.PushBack(1); 
				MarkizaDeck.cardIndices.PushBack(2); 
			}

			MarkizaDeck.cardIndices.PushBack(200); 
			MarkizaDeck.cardIndices.PushBack(206); 
			MarkizaDeck.cardIndices.PushBack(208); 
			MarkizaDeck.cardIndices.PushBack(211); 
			MarkizaDeck.cardIndices.PushBack(213); 
			MarkizaDeck.cardIndices.PushBack(214); 
			MarkizaDeck.cardIndices.PushBack(220);	
			MarkizaDeck.cardIndices.PushBack(221);	
			MarkizaDeck.cardIndices.PushBack(230);	
			MarkizaDeck.cardIndices.PushBack(231);	
			MarkizaDeck.cardIndices.PushBack(245);	
			MarkizaDeck.cardIndices.PushBack(246);	
			MarkizaDeck.cardIndices.PushBack(250);	
			MarkizaDeck.cardIndices.PushBack(251);
			MarkizaDeck.cardIndices.PushBack(252);

			MarkizaDeck.dynamicCardRequirements.PushBack(diff5);
			MarkizaDeck.dynamicCards.PushBack(235);
			MarkizaDeck.dynamicCardRequirements.PushBack(diff7);
			MarkizaDeck.dynamicCards.PushBack(0);
			MarkizaDeck.dynamicCardRequirements.PushBack(diff9);
			MarkizaDeck.dynamicCards.PushBack(13);
			MarkizaDeck.dynamicCardRequirements.PushBack(diff11);
			MarkizaDeck.dynamicCards.PushBack(12);
			MarkizaDeck.dynamicCardRequirements.PushBack(diff11);
			MarkizaDeck.dynamicCards.PushBack(14);
			MarkizaDeck.dynamicCardRequirements.PushBack(diff14);
			MarkizaDeck.dynamicCards.PushBack(7); 
			MarkizaDeck.dynamicCardRequirements.PushBack(diff14);
			MarkizaDeck.dynamicCards.PushBack(10);

			MarkizaDeck.specialCard = 202; 
			MarkizaDeck.leaderIndex = 2001; 
			enemyDecks.PushBack(MarkizaDeck);
			
			
			
			GremistaDeck.cardIndices.PushBack(3); 

			if (difficulty == 1)
			{			
				GremistaDeck.cardIndices.PushBack(4); 
				GremistaDeck.cardIndices.PushBack(5); 
				GremistaDeck.cardIndices.PushBack(6); 
				GremistaDeck.cardIndices.PushBack(215); 
			}
			if (difficulty == 2)
			{
				GremistaDeck.cardIndices.PushBack(0); 
				GremistaDeck.cardIndices.PushBack(0); 
				GremistaDeck.cardIndices.PushBack(0); 
				GremistaDeck.cardIndices.PushBack(4); 
				GremistaDeck.cardIndices.PushBack(5); 
				GremistaDeck.cardIndices.PushBack(6); 
				GremistaDeck.cardIndices.PushBack(215); 
			}
			if (difficulty == 3)
			{
				GremistaDeck.cardIndices.PushBack(0); 
				GremistaDeck.cardIndices.PushBack(0); 
				GremistaDeck.cardIndices.PushBack(6); 
				GremistaDeck.cardIndices.PushBack(255); 
				GremistaDeck.cardIndices.PushBack(203); 
			}

			GremistaDeck.cardIndices.PushBack(14); 
			GremistaDeck.cardIndices.PushBack(203); 
			GremistaDeck.cardIndices.PushBack(205); 
			GremistaDeck.cardIndices.PushBack(210); 
			GremistaDeck.cardIndices.PushBack(217); 
			GremistaDeck.cardIndices.PushBack(230);	
			GremistaDeck.cardIndices.PushBack(231);	
			GremistaDeck.cardIndices.PushBack(236);	
			GremistaDeck.cardIndices.PushBack(260);	
			GremistaDeck.cardIndices.PushBack(261);	
			GremistaDeck.cardIndices.PushBack(265); 


			GremistaDeck.dynamicCardRequirements.PushBack(diff5);
			GremistaDeck.dynamicCards.PushBack(15);
			GremistaDeck.dynamicCardRequirements.PushBack(diff7);
			GremistaDeck.dynamicCards.PushBack(12);
			GremistaDeck.dynamicCardRequirements.PushBack(diff9);
			GremistaDeck.dynamicCards.PushBack(10);
			GremistaDeck.dynamicCardRequirements.PushBack(diff11);
			GremistaDeck.dynamicCards.PushBack(8);
			GremistaDeck.dynamicCardRequirements.PushBack(diff11);
			GremistaDeck.dynamicCards.PushBack(9);
			GremistaDeck.dynamicCardRequirements.PushBack(diff14);
			GremistaDeck.dynamicCards.PushBack(7); 
			GremistaDeck.dynamicCardRequirements.PushBack(diff14);
			GremistaDeck.dynamicCards.PushBack(16);


			GremistaDeck.specialCard = 11; 
			GremistaDeck.leaderIndex = 2001; 
			enemyDecks.PushBack(GremistaDeck);

	}


	private function SetupAIDeckDefinitions4()
	{
	
		var ZoltanDeck			:SDeckDefinition;
		var LambertDeck			:SDeckDefinition;
		var ThalerDeck			:SDeckDefinition;

		
		
			
			
			ZoltanDeck.cardIndices.PushBack(2); 

			if (difficulty == 1)
			{
				ZoltanDeck.cardIndices.PushBack(3); 
				ZoltanDeck.cardIndices.PushBack(4); 
				ZoltanDeck.cardIndices.PushBack(5); 
				ZoltanDeck.cardIndices.PushBack(342);	
				ZoltanDeck.cardIndices.PushBack(355);	
			}
			if (difficulty == 2)
			{
				ZoltanDeck.cardIndices.PushBack(1); 
				ZoltanDeck.cardIndices.PushBack(1); 
				ZoltanDeck.cardIndices.PushBack(2); 
				ZoltanDeck.cardIndices.PushBack(3); 
				ZoltanDeck.cardIndices.PushBack(4); 
				ZoltanDeck.cardIndices.PushBack(5); 
				ZoltanDeck.cardIndices.PushBack(342);	
				ZoltanDeck.cardIndices.PushBack(355);	
			}
			if (difficulty == 3)
			{
				ZoltanDeck.cardIndices.PushBack(1); 
				ZoltanDeck.cardIndices.PushBack(1); 
				ZoltanDeck.cardIndices.PushBack(2); 
				ZoltanDeck.cardIndices.PushBack(302);	
			}

			ZoltanDeck.cardIndices.PushBack(302);	
			ZoltanDeck.cardIndices.PushBack(307);	
			ZoltanDeck.cardIndices.PushBack(320);	
			ZoltanDeck.cardIndices.PushBack(321);	
			ZoltanDeck.cardIndices.PushBack(325);	
			ZoltanDeck.cardIndices.PushBack(326);	
			ZoltanDeck.cardIndices.PushBack(335);	
			ZoltanDeck.cardIndices.PushBack(336);	
			ZoltanDeck.cardIndices.PushBack(337);	
			ZoltanDeck.cardIndices.PushBack(340);	
			ZoltanDeck.cardIndices.PushBack(341);	
			ZoltanDeck.cardIndices.PushBack(365);	
			ZoltanDeck.cardIndices.PushBack(366);	


			ZoltanDeck.dynamicCardRequirements.PushBack(diff5);
			ZoltanDeck.dynamicCards.PushBack(15);
			ZoltanDeck.dynamicCardRequirements.PushBack(diff7);
			ZoltanDeck.dynamicCards.PushBack(8);
			ZoltanDeck.dynamicCardRequirements.PushBack(diff9);
			ZoltanDeck.dynamicCards.PushBack(9);
			ZoltanDeck.dynamicCardRequirements.PushBack(diff11);
			ZoltanDeck.dynamicCards.PushBack(11);
			ZoltanDeck.dynamicCardRequirements.PushBack(diff11);
			ZoltanDeck.dynamicCards.PushBack(14);
			ZoltanDeck.dynamicCardRequirements.PushBack(diff14);
			ZoltanDeck.dynamicCards.PushBack(7); 
			ZoltanDeck.dynamicCardRequirements.PushBack(diff14);
			ZoltanDeck.dynamicCards.PushBack(16);


			ZoltanDeck.specialCard = 300; 
			ZoltanDeck.leaderIndex = 3002; 
			enemyDecks.PushBack(ZoltanDeck);
			
			
			LambertDeck.cardIndices.PushBack(0); 
			LambertDeck.cardIndices.PushBack(2); 
			LambertDeck.cardIndices.PushBack(3); 
			LambertDeck.cardIndices.PushBack(6); 
			
			if (difficulty == 1)
			{
				LambertDeck.cardIndices.PushBack(310);	
				LambertDeck.cardIndices.PushBack(311);	
			}
			if (difficulty == 2)
			{
				LambertDeck.cardIndices.PushBack(0); 
				LambertDeck.cardIndices.PushBack(1); 
				LambertDeck.cardIndices.PushBack(2); 
				LambertDeck.cardIndices.PushBack(2); 

			}
			if (difficulty == 3)
			{
				LambertDeck.cardIndices.PushBack(0); 
				LambertDeck.cardIndices.PushBack(1); 
				LambertDeck.cardIndices.PushBack(2); 
				LambertDeck.cardIndices.PushBack(301);	
			}

			LambertDeck.cardIndices.PushBack(9);	
			LambertDeck.cardIndices.PushBack(302);	
			LambertDeck.cardIndices.PushBack(308);	
			LambertDeck.cardIndices.PushBack(309);	
			LambertDeck.cardIndices.PushBack(320);	
			LambertDeck.cardIndices.PushBack(340);	
			LambertDeck.cardIndices.PushBack(341);	
			LambertDeck.cardIndices.PushBack(342);	
			LambertDeck.cardIndices.PushBack(343);	
			LambertDeck.cardIndices.PushBack(350);	
			LambertDeck.cardIndices.PushBack(351);	
			LambertDeck.cardIndices.PushBack(360);	
			LambertDeck.cardIndices.PushBack(365);	
			LambertDeck.cardIndices.PushBack(366);
			
			LambertDeck.dynamicCardRequirements.PushBack(diff5);
			LambertDeck.dynamicCards.PushBack(8);
			LambertDeck.dynamicCardRequirements.PushBack(diff7);
			LambertDeck.dynamicCards.PushBack(12);
			LambertDeck.dynamicCardRequirements.PushBack(diff9);
			LambertDeck.dynamicCards.PushBack(322); 
			LambertDeck.dynamicCardRequirements.PushBack(diff11);
			LambertDeck.dynamicCards.PushBack(2); 
			LambertDeck.dynamicCardRequirements.PushBack(diff11);
			LambertDeck.dynamicCards.PushBack(13);
			LambertDeck.dynamicCardRequirements.PushBack(diff14);
			LambertDeck.dynamicCards.PushBack(15);
			LambertDeck.dynamicCardRequirements.PushBack(diff14);
			LambertDeck.dynamicCards.PushBack(10);


			
			LambertDeck.specialCard = 11; 
			LambertDeck.leaderIndex = 3001; 
			enemyDecks.PushBack(LambertDeck);
			
			
			ThalerDeck.cardIndices.PushBack(6); 
			
			if (difficulty == 1)
			{
				ThalerDeck.cardIndices.PushBack(3); 
				ThalerDeck.cardIndices.PushBack(3); 
				ThalerDeck.cardIndices.PushBack(4); 
				ThalerDeck.cardIndices.PushBack(5); 
				ThalerDeck.cardIndices.PushBack(6); 
				ThalerDeck.cardIndices.PushBack(310); 
			}
			if (difficulty == 2)
			{
				ThalerDeck.cardIndices.PushBack(3); 
				ThalerDeck.cardIndices.PushBack(3); 
				ThalerDeck.cardIndices.PushBack(4); 
				ThalerDeck.cardIndices.PushBack(5); 
				ThalerDeck.cardIndices.PushBack(6); 
			}
			if (difficulty == 3)
			{
				ThalerDeck.cardIndices.PushBack(3); 
				ThalerDeck.cardIndices.PushBack(5); 
				ThalerDeck.cardIndices.PushBack(0); 
				ThalerDeck.cardIndices.PushBack(0); 
				ThalerDeck.cardIndices.PushBack(1); 
				ThalerDeck.cardIndices.PushBack(300); 
			}
			
			ThalerDeck.cardIndices.PushBack(307);	
			ThalerDeck.cardIndices.PushBack(308);	
			ThalerDeck.cardIndices.PushBack(309);	
			ThalerDeck.cardIndices.PushBack(312);	
			ThalerDeck.cardIndices.PushBack(313);	
			ThalerDeck.cardIndices.PushBack(320);	
			ThalerDeck.cardIndices.PushBack(321);	
			ThalerDeck.cardIndices.PushBack(325);	
			ThalerDeck.cardIndices.PushBack(326);	
			ThalerDeck.cardIndices.PushBack(330);	
			ThalerDeck.cardIndices.PushBack(331);	
			ThalerDeck.cardIndices.PushBack(332);	
			ThalerDeck.cardIndices.PushBack(335);	
			ThalerDeck.cardIndices.PushBack(336);	
			ThalerDeck.cardIndices.PushBack(355);	
			ThalerDeck.cardIndices.PushBack(360);	
			ThalerDeck.cardIndices.PushBack(365);


			ThalerDeck.dynamicCardRequirements.PushBack(diff5);
			ThalerDeck.dynamicCards.PushBack(337);
			ThalerDeck.dynamicCardRequirements.PushBack(diff7);
			ThalerDeck.dynamicCards.PushBack(15);
			ThalerDeck.dynamicCardRequirements.PushBack(diff9);
			ThalerDeck.dynamicCards.PushBack(322);
			ThalerDeck.dynamicCardRequirements.PushBack(diff11);
			ThalerDeck.dynamicCards.PushBack(11);
			ThalerDeck.dynamicCardRequirements.PushBack(diff11);
			ThalerDeck.dynamicCards.PushBack(14);
			ThalerDeck.dynamicCardRequirements.PushBack(diff14);
			ThalerDeck.dynamicCards.PushBack(306);
			ThalerDeck.dynamicCardRequirements.PushBack(diff14);
			ThalerDeck.dynamicCards.PushBack(13);

			ThalerDeck.specialCard = 7; 
			ThalerDeck.leaderIndex = 3003; 
			enemyDecks.PushBack(ThalerDeck);

	}
	


	private function SetupAIDeckDefinitions5()
	{

		var VimmeDeck			:SDeckDefinition;
		var ScoiaTraderDeck		:SDeckDefinition;

			
			VimmeDeck.cardIndices.PushBack(6); 
			VimmeDeck.cardIndices.PushBack(4); 
			VimmeDeck.cardIndices.PushBack(5); 
			VimmeDeck.cardIndices.PushBack(1); 

			if (difficulty == 1)
			{
				VimmeDeck.cardIndices.PushBack(4); 
				VimmeDeck.cardIndices.PushBack(310); 
			}
			if (difficulty == 2)
			{
				VimmeDeck.cardIndices.PushBack(1); 
				VimmeDeck.cardIndices.PushBack(4); 
				
			}
			if (difficulty == 3)
			{
				VimmeDeck.cardIndices.PushBack(1); 
				VimmeDeck.cardIndices.PushBack(302); 
			}

			VimmeDeck.cardIndices.PushBack(301);	
			VimmeDeck.cardIndices.PushBack(305);	
			VimmeDeck.cardIndices.PushBack(325);	
			VimmeDeck.cardIndices.PushBack(326);	
			VimmeDeck.cardIndices.PushBack(335);	
			VimmeDeck.cardIndices.PushBack(336);	
			VimmeDeck.cardIndices.PushBack(337);	
			VimmeDeck.cardIndices.PushBack(340);	
			VimmeDeck.cardIndices.PushBack(341);	
			VimmeDeck.cardIndices.PushBack(342);	
			VimmeDeck.cardIndices.PushBack(343);	
			VimmeDeck.cardIndices.PushBack(344);	
			VimmeDeck.cardIndices.PushBack(365);	
			VimmeDeck.cardIndices.PushBack(366);	
			VimmeDeck.cardIndices.PushBack(367);


			VimmeDeck.dynamicCardRequirements.PushBack(diff5);
			VimmeDeck.dynamicCards.PushBack(0);
			VimmeDeck.dynamicCardRequirements.PushBack(diff7);
			VimmeDeck.dynamicCards.PushBack(12);
			VimmeDeck.dynamicCardRequirements.PushBack(diff9);
			VimmeDeck.dynamicCards.PushBack(0);
			VimmeDeck.dynamicCardRequirements.PushBack(diff11);
			VimmeDeck.dynamicCards.PushBack(16);
			VimmeDeck.dynamicCardRequirements.PushBack(diff11);
			VimmeDeck.dynamicCards.PushBack(11);
			VimmeDeck.dynamicCardRequirements.PushBack(diff14);
			VimmeDeck.dynamicCards.PushBack(7); 
			VimmeDeck.dynamicCardRequirements.PushBack(diff14);
			VimmeDeck.dynamicCards.PushBack(14);

			VimmeDeck.specialCard = 8; 
			VimmeDeck.leaderIndex = 3002; 
			enemyDecks.PushBack(VimmeDeck);
			
			
			
			ScoiaTraderDeck.cardIndices.PushBack(6); 
			ScoiaTraderDeck.cardIndices.PushBack(1); 
			
			if (difficulty == 1)
			{
				ScoiaTraderDeck.cardIndices.PushBack(3); 
				ScoiaTraderDeck.cardIndices.PushBack(4); 
				ScoiaTraderDeck.cardIndices.PushBack(5); 
				VimmeDeck.cardIndices.PushBack(310); 
			}
			if (difficulty == 2)
			{
				ScoiaTraderDeck.cardIndices.PushBack(0); 
				ScoiaTraderDeck.cardIndices.PushBack(1); 
				ScoiaTraderDeck.cardIndices.PushBack(2); 
				ScoiaTraderDeck.cardIndices.PushBack(3); 
				ScoiaTraderDeck.cardIndices.PushBack(4); 
				ScoiaTraderDeck.cardIndices.PushBack(5); 
				
			}
			if (difficulty == 3)
			{
				ScoiaTraderDeck.cardIndices.PushBack(0); 
				ScoiaTraderDeck.cardIndices.PushBack(1); 
				ScoiaTraderDeck.cardIndices.PushBack(5); 
				ScoiaTraderDeck.cardIndices.PushBack(302); 
				ScoiaTraderDeck.cardIndices.PushBack(301); 
			}

			ScoiaTraderDeck.cardIndices.PushBack(303);	
			ScoiaTraderDeck.cardIndices.PushBack(305);	
			ScoiaTraderDeck.cardIndices.PushBack(306);	
			ScoiaTraderDeck.cardIndices.PushBack(307);	
			ScoiaTraderDeck.cardIndices.PushBack(308);	
			ScoiaTraderDeck.cardIndices.PushBack(309);	
			ScoiaTraderDeck.cardIndices.PushBack(310);	
			ScoiaTraderDeck.cardIndices.PushBack(311);	
			ScoiaTraderDeck.cardIndices.PushBack(312);	
			ScoiaTraderDeck.cardIndices.PushBack(313);	
			ScoiaTraderDeck.cardIndices.PushBack(320);	
			ScoiaTraderDeck.cardIndices.PushBack(321);	
			ScoiaTraderDeck.cardIndices.PushBack(350);	
			ScoiaTraderDeck.cardIndices.PushBack(351);	
			ScoiaTraderDeck.cardIndices.PushBack(352);


			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff5);
			ScoiaTraderDeck.dynamicCards.PushBack(2);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff7);
			ScoiaTraderDeck.dynamicCards.PushBack(2);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff9);
			ScoiaTraderDeck.dynamicCards.PushBack(8);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff11);
			ScoiaTraderDeck.dynamicCards.PushBack(11);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff11);
			ScoiaTraderDeck.dynamicCards.PushBack(14);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff14);
			ScoiaTraderDeck.dynamicCards.PushBack(15);
			ScoiaTraderDeck.dynamicCardRequirements.PushBack(diff14);
			ScoiaTraderDeck.dynamicCards.PushBack(16);


			ScoiaTraderDeck.specialCard = 10; 
			ScoiaTraderDeck.leaderIndex = 3001; 
			enemyDecks.PushBack(ScoiaTraderDeck);
	}
	
	private function SetupAIDeckDefinitions6()
	{
		var CrachDeck			:SDeckDefinition;
		var LugosDeck			:SDeckDefinition;
		var HermitDeck			:SDeckDefinition;

		
		
			
			
			
			CrachDeck.cardIndices.PushBack(1); 
			CrachDeck.cardIndices.PushBack(4); 

			if (difficulty == 1)
			{
				CrachDeck.cardIndices.PushBack(3); 
				CrachDeck.cardIndices.PushBack(4); 
				CrachDeck.cardIndices.PushBack(5); 
				CrachDeck.cardIndices.PushBack(420); 
				CrachDeck.cardIndices.PushBack(427); 
			}
			if (difficulty == 2)
			{
				CrachDeck.cardIndices.PushBack(1); 
				CrachDeck.cardIndices.PushBack(2); 
				CrachDeck.cardIndices.PushBack(2); 
				CrachDeck.cardIndices.PushBack(3); 
				CrachDeck.cardIndices.PushBack(4); 
				CrachDeck.cardIndices.PushBack(5); 
				CrachDeck.cardIndices.PushBack(420); 
				CrachDeck.cardIndices.PushBack(427); 
			}
			if (difficulty == 3)
			{
				CrachDeck.cardIndices.PushBack(1); 
				CrachDeck.cardIndices.PushBack(0); 
				CrachDeck.cardIndices.PushBack(5); 
				CrachDeck.cardIndices.PushBack(6); 
				CrachDeck.cardIndices.PushBack(403); 
				CrachDeck.cardIndices.PushBack(443); 
			}

			CrachDeck.cardIndices.PushBack(407);	
			CrachDeck.cardIndices.PushBack(410);	
			CrachDeck.cardIndices.PushBack(415);	
			CrachDeck.cardIndices.PushBack(417);	
			CrachDeck.cardIndices.PushBack(423);	
			CrachDeck.cardIndices.PushBack(425);	
			CrachDeck.cardIndices.PushBack(435);	
			CrachDeck.cardIndices.PushBack(440);	
			CrachDeck.cardIndices.PushBack(443);	
			CrachDeck.cardIndices.PushBack(447);	
			CrachDeck.cardIndices.PushBack(450);	
			CrachDeck.cardIndices.PushBack(451);


			CrachDeck.dynamicCardRequirements.PushBack(diff5);
			CrachDeck.dynamicCards.PushBack(452);
			CrachDeck.dynamicCardRequirements.PushBack(diff7);
			CrachDeck.dynamicCards.PushBack(453);
			CrachDeck.dynamicCardRequirements.PushBack(diff9);
			CrachDeck.dynamicCards.PushBack(8);
			CrachDeck.dynamicCardRequirements.PushBack(diff11);
			CrachDeck.dynamicCards.PushBack(11);
			CrachDeck.dynamicCardRequirements.PushBack(diff11);
			CrachDeck.dynamicCards.PushBack(14);
			CrachDeck.dynamicCardRequirements.PushBack(diff14);
			CrachDeck.dynamicCards.PushBack(7); 
			CrachDeck.dynamicCardRequirements.PushBack(diff14);
			CrachDeck.dynamicCards.PushBack(10);


			CrachDeck.specialCard = 400; 
			CrachDeck.leaderIndex = 4001; 
			enemyDecks.PushBack(CrachDeck);

			
			
			LugosDeck.cardIndices.PushBack(0); 
	
			if (difficulty == 1)
			{
				LugosDeck.cardIndices.PushBack(3); 
				LugosDeck.cardIndices.PushBack(4); 
				LugosDeck.cardIndices.PushBack(4); 
				LugosDeck.cardIndices.PushBack(5); 
				LugosDeck.cardIndices.PushBack(5); 
				LugosDeck.cardIndices.PushBack(420); 
				LugosDeck.cardIndices.PushBack(427); 
			}
			if (difficulty == 2)
			{
				LugosDeck.cardIndices.PushBack(0); 
				LugosDeck.cardIndices.PushBack(3); 
				LugosDeck.cardIndices.PushBack(4); 
				LugosDeck.cardIndices.PushBack(4); 
				LugosDeck.cardIndices.PushBack(5); 
				LugosDeck.cardIndices.PushBack(5); 
				LugosDeck.cardIndices.PushBack(420); 
			}
			if (difficulty == 3)
			{
				LugosDeck.cardIndices.PushBack(4); 
				LugosDeck.cardIndices.PushBack(5); 
				LugosDeck.cardIndices.PushBack(0); 
				LugosDeck.cardIndices.PushBack(6); 
				LugosDeck.cardIndices.PushBack(403); 
				LugosDeck.cardIndices.PushBack(443); 
			}

			LugosDeck.cardIndices.PushBack(401);	
			LugosDeck.cardIndices.PushBack(413);	
			LugosDeck.cardIndices.PushBack(417);	
			LugosDeck.cardIndices.PushBack(407);	
			LugosDeck.cardIndices.PushBack(415);	
			LugosDeck.cardIndices.PushBack(417);	
			LugosDeck.cardIndices.PushBack(423);	
			LugosDeck.cardIndices.PushBack(423);	
			LugosDeck.cardIndices.PushBack(433);	
			LugosDeck.cardIndices.PushBack(440);	
			LugosDeck.cardIndices.PushBack(445);	
			LugosDeck.cardIndices.PushBack(455);	
			LugosDeck.cardIndices.PushBack(455);	
			LugosDeck.cardIndices.PushBack(456);	
			LugosDeck.cardIndices.PushBack(457);	
			LugosDeck.cardIndices.PushBack(460);	
			LugosDeck.cardIndices.PushBack(461);	
			LugosDeck.cardIndices.PushBack(463);


			LugosDeck.dynamicCardRequirements.PushBack(diff5);
			LugosDeck.dynamicCards.PushBack(462);
			LugosDeck.dynamicCardRequirements.PushBack(diff7);
			LugosDeck.dynamicCards.PushBack(2); 
			LugosDeck.dynamicCardRequirements.PushBack(diff9);
			LugosDeck.dynamicCards.PushBack(1); 
			LugosDeck.dynamicCardRequirements.PushBack(diff11);
			LugosDeck.dynamicCards.PushBack(11);
			LugosDeck.dynamicCardRequirements.PushBack(diff11);
			LugosDeck.dynamicCards.PushBack(8);
			LugosDeck.dynamicCardRequirements.PushBack(diff14);
			LugosDeck.dynamicCards.PushBack(2); 
			LugosDeck.dynamicCardRequirements.PushBack(diff14);
			LugosDeck.dynamicCards.PushBack(10);


			LugosDeck.specialCard = 464; 
			LugosDeck.leaderIndex = 4002; 
			enemyDecks.PushBack(LugosDeck);


			

			if (difficulty == 1)
			{
				HermitDeck.cardIndices.PushBack(3); 
				HermitDeck.cardIndices.PushBack(4); 
				HermitDeck.cardIndices.PushBack(5); 
				HermitDeck.cardIndices.PushBack(6); 
				HermitDeck.cardIndices.PushBack(6); 
				HermitDeck.cardIndices.PushBack(420); 
				HermitDeck.cardIndices.PushBack(427); 
			}
			if (difficulty == 2)
			{
				HermitDeck.cardIndices.PushBack(2); 
				HermitDeck.cardIndices.PushBack(2); 
				HermitDeck.cardIndices.PushBack(4); 
				HermitDeck.cardIndices.PushBack(5); 
				HermitDeck.cardIndices.PushBack(6); 
				HermitDeck.cardIndices.PushBack(6); 
				HermitDeck.cardIndices.PushBack(0); 
			}
			if (difficulty == 3)
			{
				HermitDeck.cardIndices.PushBack(0); 
				HermitDeck.cardIndices.PushBack(1); 
				HermitDeck.cardIndices.PushBack(4); 
				HermitDeck.cardIndices.PushBack(6); 
				HermitDeck.cardIndices.PushBack(6); 
				HermitDeck.cardIndices.PushBack(403); 
				HermitDeck.cardIndices.PushBack(443); 
			}

			HermitDeck.cardIndices.PushBack(400);	
			HermitDeck.cardIndices.PushBack(450);	
			HermitDeck.cardIndices.PushBack(451);	
			HermitDeck.cardIndices.PushBack(452);	
			HermitDeck.cardIndices.PushBack(453);	
			HermitDeck.cardIndices.PushBack(455);	
			HermitDeck.cardIndices.PushBack(456);	
			HermitDeck.cardIndices.PushBack(457);	
			HermitDeck.cardIndices.PushBack(460);	
			HermitDeck.cardIndices.PushBack(461);	
			HermitDeck.cardIndices.PushBack(462);
			HermitDeck.cardIndices.PushBack(463);		
			HermitDeck.cardIndices.PushBack(470);	
			HermitDeck.cardIndices.PushBack(471);	
			HermitDeck.cardIndices.PushBack(472);	
			HermitDeck.cardIndices.PushBack(475);		
			HermitDeck.cardIndices.PushBack(477);


			HermitDeck.dynamicCardRequirements.PushBack(diff5);
			HermitDeck.dynamicCards.PushBack(464);
			HermitDeck.dynamicCardRequirements.PushBack(diff7);
			HermitDeck.dynamicCards.PushBack(443);
			HermitDeck.dynamicCardRequirements.PushBack(diff9);
			HermitDeck.dynamicCards.PushBack(2); 
			HermitDeck.dynamicCardRequirements.PushBack(diff11);
			HermitDeck.dynamicCards.PushBack(11);
			HermitDeck.dynamicCardRequirements.PushBack(diff11);
			HermitDeck.dynamicCards.PushBack(14);
			HermitDeck.dynamicCardRequirements.PushBack(diff14);
			HermitDeck.dynamicCards.PushBack(7); 
			HermitDeck.dynamicCardRequirements.PushBack(diff14);
			HermitDeck.dynamicCards.PushBack(12);

			HermitDeck.specialCard = 476; 
			HermitDeck.leaderIndex = 4002; 
			enemyDecks.PushBack(HermitDeck);
		
			
	}

	private function SetupAIDeckDefinitions7()
	{

		var OlivierDeck			:SDeckDefinition;
		var MousesackDeck		:SDeckDefinition;

			
			OlivierDeck.cardIndices.PushBack(4); 
			OlivierDeck.cardIndices.PushBack(5); 

			if (difficulty == 1)
			{
				OlivierDeck.cardIndices.PushBack(3); 
				OlivierDeck.cardIndices.PushBack(4); 
				OlivierDeck.cardIndices.PushBack(5); 
				OlivierDeck.cardIndices.PushBack(420); 
				OlivierDeck.cardIndices.PushBack(427); 
				OlivierDeck.cardIndices.PushBack(447);
			}
			if (difficulty == 2)
			{
				OlivierDeck.cardIndices.PushBack(3); 
				OlivierDeck.cardIndices.PushBack(4); 
				OlivierDeck.cardIndices.PushBack(5); 
				OlivierDeck.cardIndices.PushBack(420); 
				OlivierDeck.cardIndices.PushBack(427); 
				OlivierDeck.cardIndices.PushBack(447);
			}
			if (difficulty == 3)
			{	
				OlivierDeck.cardIndices.PushBack(1); 
				OlivierDeck.cardIndices.PushBack(1); 
				OlivierDeck.cardIndices.PushBack(6); 
				OlivierDeck.cardIndices.PushBack(401); 
				OlivierDeck.cardIndices.PushBack(400); 
			}

			OlivierDeck.cardIndices.PushBack(403);	
			OlivierDeck.cardIndices.PushBack(407);	
			OlivierDeck.cardIndices.PushBack(410);
			OlivierDeck.cardIndices.PushBack(413);
			OlivierDeck.cardIndices.PushBack(415);	
			OlivierDeck.cardIndices.PushBack(425);	
			OlivierDeck.cardIndices.PushBack(440);	
			OlivierDeck.cardIndices.PushBack(443);
			OlivierDeck.cardIndices.PushBack(450);	
			OlivierDeck.cardIndices.PushBack(451);	
			OlivierDeck.cardIndices.PushBack(452);	
			OlivierDeck.cardIndices.PushBack(453);	
			OlivierDeck.cardIndices.PushBack(470);	
			OlivierDeck.cardIndices.PushBack(471);	
			OlivierDeck.cardIndices.PushBack(472);


			OlivierDeck.dynamicCardRequirements.PushBack(diff5);
			OlivierDeck.dynamicCards.PushBack(15);
			OlivierDeck.dynamicCardRequirements.PushBack(diff7);
			OlivierDeck.dynamicCards.PushBack(0);
			OlivierDeck.dynamicCardRequirements.PushBack(diff9);
			OlivierDeck.dynamicCards.PushBack(0);
			OlivierDeck.dynamicCardRequirements.PushBack(diff11);
			OlivierDeck.dynamicCards.PushBack(11);
			OlivierDeck.dynamicCardRequirements.PushBack(diff11);
			OlivierDeck.dynamicCards.PushBack(8);
			OlivierDeck.dynamicCardRequirements.PushBack(diff14);
			OlivierDeck.dynamicCards.PushBack(7); 
			OlivierDeck.dynamicCardRequirements.PushBack(diff14);
			OlivierDeck.dynamicCards.PushBack(12);

			OlivierDeck.specialCard = -1;
			OlivierDeck.leaderIndex = 4002; 
			enemyDecks.PushBack(OlivierDeck);


			
			if (difficulty == 1)
			{
				MousesackDeck.cardIndices.PushBack(0); 
				MousesackDeck.cardIndices.PushBack(0); 
				MousesackDeck.cardIndices.PushBack(1); 
				MousesackDeck.cardIndices.PushBack(1); 
				MousesackDeck.cardIndices.PushBack(2); 
				MousesackDeck.cardIndices.PushBack(3); 
				MousesackDeck.cardIndices.PushBack(4); 
				MousesackDeck.cardIndices.PushBack(5); 
				MousesackDeck.cardIndices.PushBack(6); 
				MousesackDeck.cardIndices.PushBack(420); 
				MousesackDeck.cardIndices.PushBack(427); 
			}
			if (difficulty == 2)
			{
				MousesackDeck.cardIndices.PushBack(0); 
				MousesackDeck.cardIndices.PushBack(0); 
				MousesackDeck.cardIndices.PushBack(1); 
				MousesackDeck.cardIndices.PushBack(1); 
				MousesackDeck.cardIndices.PushBack(2); 
				MousesackDeck.cardIndices.PushBack(3); 
				MousesackDeck.cardIndices.PushBack(4); 
				MousesackDeck.cardIndices.PushBack(5); 
				MousesackDeck.cardIndices.PushBack(6); 
			}
			if (difficulty == 3)
			{	
				MousesackDeck.cardIndices.PushBack(0); 
				MousesackDeck.cardIndices.PushBack(0); 
				MousesackDeck.cardIndices.PushBack(1); 
				MousesackDeck.cardIndices.PushBack(1); 
				MousesackDeck.cardIndices.PushBack(4); 
				MousesackDeck.cardIndices.PushBack(6); 
				MousesackDeck.cardIndices.PushBack(401); 
				MousesackDeck.cardIndices.PushBack(443); 
			}

			MousesackDeck.cardIndices.PushBack(401);	
			MousesackDeck.cardIndices.PushBack(407);	
			MousesackDeck.cardIndices.PushBack(415);	
			MousesackDeck.cardIndices.PushBack(417);
			MousesackDeck.cardIndices.PushBack(423);
			MousesackDeck.cardIndices.PushBack(450);	
			MousesackDeck.cardIndices.PushBack(451);	
			MousesackDeck.cardIndices.PushBack(452);	
			MousesackDeck.cardIndices.PushBack(455);	
			MousesackDeck.cardIndices.PushBack(456);	
			MousesackDeck.cardIndices.PushBack(457);	
			MousesackDeck.cardIndices.PushBack(460);	
			MousesackDeck.cardIndices.PushBack(461);	
			MousesackDeck.cardIndices.PushBack(462);	
			MousesackDeck.cardIndices.PushBack(463);	
			MousesackDeck.cardIndices.PushBack(470);	
			MousesackDeck.cardIndices.PushBack(471);	
			MousesackDeck.cardIndices.PushBack(472);	
			MousesackDeck.cardIndices.PushBack(476);	
			MousesackDeck.cardIndices.PushBack(477);


			MousesackDeck.dynamicCardRequirements.PushBack(diff5);
			MousesackDeck.dynamicCards.PushBack(15);
			MousesackDeck.dynamicCardRequirements.PushBack(diff7);
			MousesackDeck.dynamicCards.PushBack(12);
			MousesackDeck.dynamicCardRequirements.PushBack(diff9);
			MousesackDeck.dynamicCards.PushBack(13);
			MousesackDeck.dynamicCardRequirements.PushBack(diff11);
			MousesackDeck.dynamicCards.PushBack(11);
			MousesackDeck.dynamicCardRequirements.PushBack(diff11);
			MousesackDeck.dynamicCards.PushBack(14);
			MousesackDeck.dynamicCardRequirements.PushBack(diff14);
			MousesackDeck.dynamicCards.PushBack(2); 
			MousesackDeck.dynamicCardRequirements.PushBack(diff14);
			MousesackDeck.dynamicCards.PushBack(7);


			MousesackDeck.specialCard = 403; 
			MousesackDeck.leaderIndex = 4004; 
			enemyDecks.PushBack(MousesackDeck);

	}
	
	
		private function SetupAIDeckDefinitions8()
	{

		var ShaniDeck			:SDeckDefinition;
		var OlgierdDeck		    :SDeckDefinition;

			
			
			
			ShaniDeck.cardIndices.PushBack(2); 
			ShaniDeck.cardIndices.PushBack(0); 
			ShaniDeck.cardIndices.PushBack(0); 
			
			
			if (difficulty == 1)
			{
				ShaniDeck.cardIndices.PushBack(310);	
				ShaniDeck.cardIndices.PushBack(312);	
				ShaniDeck.cardIndices.PushBack(336);	
				ShaniDeck.cardIndices.PushBack(337);	
			}
			if (difficulty >= 2)
			{
				ShaniDeck.cardIndices.PushBack(0); 
				ShaniDeck.cardIndices.PushBack(1); 
				ShaniDeck.cardIndices.PushBack(302);	
				ShaniDeck.cardIndices.PushBack(303);	
				ShaniDeck.cardIndices.PushBack(9); 		
				ShaniDeck.cardIndices.PushBack(16); 	
			}
			if (difficulty == 3)
			{
				ShaniDeck.cardIndices.PushBack(2); 
				ShaniDeck.cardIndices.PushBack(10); 	
				ShaniDeck.cardIndices.PushBack(300);	
				ShaniDeck.cardIndices.PushBack(301);	
			}

			ShaniDeck.cardIndices.PushBack(305);	
			ShaniDeck.cardIndices.PushBack(306);	
			ShaniDeck.cardIndices.PushBack(308);	
			ShaniDeck.cardIndices.PushBack(309);	
			ShaniDeck.cardIndices.PushBack(313);	
			ShaniDeck.cardIndices.PushBack(320);	
			ShaniDeck.cardIndices.PushBack(321);	
			ShaniDeck.cardIndices.PushBack(322);	
			ShaniDeck.cardIndices.PushBack(325);	
			ShaniDeck.cardIndices.PushBack(326);	
			ShaniDeck.cardIndices.PushBack(365);	
			ShaniDeck.cardIndices.PushBack(366);	
			ShaniDeck.cardIndices.PushBack(367);	
			
			
			ShaniDeck.dynamicCardRequirements.PushBack(diff5);
			ShaniDeck.dynamicCards.PushBack(1); 
			ShaniDeck.dynamicCardRequirements.PushBack(diff7);
			ShaniDeck.dynamicCards.PushBack(8); 
			ShaniDeck.dynamicCardRequirements.PushBack(diff11);
			ShaniDeck.dynamicCards.PushBack(11); 
			ShaniDeck.dynamicCardRequirements.PushBack(diff11);
			ShaniDeck.dynamicCards.PushBack(12); 
			ShaniDeck.dynamicCardRequirements.PushBack(diff14);
			ShaniDeck.dynamicCards.PushBack(15); 
			ShaniDeck.dynamicCardRequirements.PushBack(diff14);
			ShaniDeck.dynamicCards.PushBack(7); 

			ShaniDeck.specialCard = 17; 
			ShaniDeck.leaderIndex = 3005; 
			enemyDecks.PushBack(ShaniDeck);
			

			
			
			
			OlgierdDeck.cardIndices.PushBack(2); 

			
			if (difficulty == 1)
			{
				OlgierdDeck.cardIndices.PushBack(4); 
				OlgierdDeck.cardIndices.PushBack(415);	
				OlgierdDeck.cardIndices.PushBack(423);	
				OlgierdDeck.cardIndices.PushBack(455);	
				OlgierdDeck.cardIndices.PushBack(456);	
				OlgierdDeck.cardIndices.PushBack(457);	
			}
			if (difficulty >= 2)
			{
				OlgierdDeck.cardIndices.PushBack(0); 
				OlgierdDeck.cardIndices.PushBack(5); 
				OlgierdDeck.cardIndices.PushBack(6); 
				OlgierdDeck.cardIndices.PushBack(453);	 
				OlgierdDeck.cardIndices.PushBack(475); 	 
				OlgierdDeck.cardIndices.PushBack(16); 	 
				OlgierdDeck.cardIndices.PushBack(400);   
				OlgierdDeck.cardIndices.PushBack(403);   
			}
			if (difficulty == 3)
			{
				OlgierdDeck.cardIndices.PushBack(0); 
				OlgierdDeck.cardIndices.PushBack(1); 
				OlgierdDeck.cardIndices.PushBack(10);   
			}

			OlgierdDeck.cardIndices.PushBack(401);	
			OlgierdDeck.cardIndices.PushBack(407);	
			OlgierdDeck.cardIndices.PushBack(450);	
			OlgierdDeck.cardIndices.PushBack(451);	
			OlgierdDeck.cardIndices.PushBack(452);	
			OlgierdDeck.cardIndices.PushBack(460);	
			OlgierdDeck.cardIndices.PushBack(461);	
			OlgierdDeck.cardIndices.PushBack(462);	
			OlgierdDeck.cardIndices.PushBack(463);	
			OlgierdDeck.cardIndices.PushBack(476);	
			OlgierdDeck.cardIndices.PushBack(477);  

			OlgierdDeck.dynamicCardRequirements.PushBack(diff5);
			OlgierdDeck.dynamicCards.PushBack(15); 
			OlgierdDeck.dynamicCardRequirements.PushBack(diff7);
			OlgierdDeck.dynamicCards.PushBack(12); 
			OlgierdDeck.dynamicCardRequirements.PushBack(diff9);
			OlgierdDeck.dynamicCards.PushBack(13); 
			OlgierdDeck.dynamicCardRequirements.PushBack(diff11);
			OlgierdDeck.dynamicCards.PushBack(9); 
			OlgierdDeck.dynamicCardRequirements.PushBack(diff11);
			OlgierdDeck.dynamicCards.PushBack(14); 
			OlgierdDeck.dynamicCardRequirements.PushBack(diff14);
			OlgierdDeck.dynamicCards.PushBack(2); 
			OlgierdDeck.dynamicCardRequirements.PushBack(diff14);
			OlgierdDeck.dynamicCards.PushBack(7); 

			OlgierdDeck.specialCard = 478; 
			OlgierdDeck.leaderIndex = 4005;
			enemyDecks.PushBack(OlgierdDeck);

	}
	
	
	private function SetupAIDeckDefinitions9()
	{
		var GamblerDeck			:SDeckDefinition;
		var HalflingsDeck		:SDeckDefinition;

			
			
			
			GamblerDeck.cardIndices.PushBack(2); 

			
			if (difficulty == 1)
			{
				GamblerDeck.cardIndices.PushBack(245); 
				GamblerDeck.cardIndices.PushBack(250); 
				GamblerDeck.cardIndices.PushBack(221); 
			}
			if (difficulty >= 2)
			{
				GamblerDeck.cardIndices.PushBack(6); 
				GamblerDeck.cardIndices.PushBack(0); 
				GamblerDeck.cardIndices.PushBack(0); 
				GamblerDeck.cardIndices.PushBack(200); 
				GamblerDeck.cardIndices.PushBack(214); 
				GamblerDeck.cardIndices.PushBack(19);  
				GamblerDeck.cardIndices.PushBack(260); 
				GamblerDeck.cardIndices.PushBack(240); 
				GamblerDeck.cardIndices.PushBack(202); 
			}
			if (difficulty == 3)
			{
				GamblerDeck.cardIndices.PushBack(0); 
				GamblerDeck.cardIndices.PushBack(1); 
				GamblerDeck.cardIndices.PushBack(1); 
				GamblerDeck.cardIndices.PushBack(2); 
				GamblerDeck.cardIndices.PushBack(201); 
				GamblerDeck.cardIndices.PushBack(218); 
				GamblerDeck.cardIndices.PushBack(19); 
				GamblerDeck.cardIndices.PushBack(9); 
				GamblerDeck.cardIndices.PushBack(265); 
			}

			GamblerDeck.cardIndices.PushBack(236); 
			GamblerDeck.cardIndices.PushBack(203); 
			GamblerDeck.cardIndices.PushBack(208); 
			GamblerDeck.cardIndices.PushBack(213); 
			GamblerDeck.cardIndices.PushBack(230); 
			GamblerDeck.cardIndices.PushBack(231); 
			GamblerDeck.cardIndices.PushBack(235); 
			GamblerDeck.cardIndices.PushBack(241); 
			GamblerDeck.cardIndices.PushBack(261); 
			GamblerDeck.cardIndices.PushBack(19); 

			
			GamblerDeck.dynamicCardRequirements.PushBack(diff1);
			GamblerDeck.dynamicCards.PushBack(15); 
			GamblerDeck.dynamicCardRequirements.PushBack(diff4);
			GamblerDeck.dynamicCards.PushBack(16); 
			GamblerDeck.dynamicCardRequirements.PushBack(diff4);
			GamblerDeck.dynamicCards.PushBack(12); 
			GamblerDeck.dynamicCardRequirements.PushBack(diff6);
			GamblerDeck.dynamicCards.PushBack(248); 
			GamblerDeck.dynamicCardRequirements.PushBack(diff6);
			GamblerDeck.dynamicCards.PushBack(11); 
			GamblerDeck.dynamicCardRequirements.PushBack(diff8);
			GamblerDeck.dynamicCards.PushBack(7); 

			GamblerDeck.specialCard = 18; 
			GamblerDeck.leaderIndex = 2005;
			enemyDecks.PushBack(GamblerDeck);


			
			
			
			HalflingsDeck.cardIndices.PushBack(2); 
			HalflingsDeck.cardIndices.PushBack(1); 
			HalflingsDeck.cardIndices.PushBack(3); 
			HalflingsDeck.cardIndices.PushBack(4); 

			
			if (difficulty == 1)
			{
				HalflingsDeck.cardIndices.PushBack(3); 
				HalflingsDeck.cardIndices.PushBack(152);	
			}
			if (difficulty >= 2)
			{
				HalflingsDeck.cardIndices.PushBack(152);	
				HalflingsDeck.cardIndices.PushBack(2); 
				HalflingsDeck.cardIndices.PushBack(0); 
				HalflingsDeck.cardIndices.PushBack(100);	
				HalflingsDeck.cardIndices.PushBack(103);	
				HalflingsDeck.cardIndices.PushBack(105); 	
				HalflingsDeck.cardIndices.PushBack(109);	
				HalflingsDeck.cardIndices.PushBack(160);	
				HalflingsDeck.cardIndices.PushBack(162); 	
			}
			if (difficulty == 3)
			{
				HalflingsDeck.cardIndices.PushBack(1); 
				HalflingsDeck.cardIndices.PushBack(102);	
				HalflingsDeck.cardIndices.PushBack(101);	
				HalflingsDeck.cardIndices.PushBack(10);		
			}

			HalflingsDeck.cardIndices.PushBack(116); 	
			HalflingsDeck.cardIndices.PushBack(120); 	
			HalflingsDeck.cardIndices.PushBack(140); 	
			HalflingsDeck.cardIndices.PushBack(141); 	
			HalflingsDeck.cardIndices.PushBack(145); 	
			HalflingsDeck.cardIndices.PushBack(161); 	
			HalflingsDeck.cardIndices.PushBack(170); 	
			HalflingsDeck.cardIndices.PushBack(175);	
			
			HalflingsDeck.dynamicCardRequirements.PushBack(diff2);	
			HalflingsDeck.dynamicCards.PushBack(13);				
			HalflingsDeck.dynamicCardRequirements.PushBack(diff5);	
			HalflingsDeck.dynamicCards.PushBack(151); 				
			HalflingsDeck.dynamicCardRequirements.PushBack(diff6);	
			HalflingsDeck.dynamicCards.PushBack(12); 				
			HalflingsDeck.dynamicCardRequirements.PushBack(diff8);	
			HalflingsDeck.dynamicCards.PushBack(11); 				
			HalflingsDeck.dynamicCardRequirements.PushBack(diff8);	
			HalflingsDeck.dynamicCards.PushBack(7); 				
			HalflingsDeck.dynamicCardRequirements.PushBack(diff8);	
			HalflingsDeck.dynamicCards.PushBack(15); 				
			HalflingsDeck.dynamicCardRequirements.PushBack(diff10);	
			HalflingsDeck.dynamicCards.PushBack(9); 				
			
			HalflingsDeck.specialCard = 16;	
			HalflingsDeck.leaderIndex = 1004; 
			enemyDecks.PushBack(HalflingsDeck);
	}

	private function SetupAIDeckDefinitions10()
	{
		var CircusGwentAddictDeck   :SDeckDefinition;

			
			
			
			CircusGwentAddictDeck.cardIndices.PushBack(3); 
			CircusGwentAddictDeck.cardIndices.PushBack(1); 
			CircusGwentAddictDeck.cardIndices.PushBack(2); 

			
			if (difficulty == 1)
			{
				CircusGwentAddictDeck.cardIndices.PushBack(6); 
				CircusGwentAddictDeck.cardIndices.PushBack(4); 
				CircusGwentAddictDeck.cardIndices.PushBack(310); 
				CircusGwentAddictDeck.cardIndices.PushBack(311); 
			}
			if (difficulty >= 2)
			{
				CircusGwentAddictDeck.cardIndices.PushBack(0); 
				CircusGwentAddictDeck.cardIndices.PushBack(2); 
				CircusGwentAddictDeck.cardIndices.PushBack(367);	
				CircusGwentAddictDeck.cardIndices.PushBack(300);	
				CircusGwentAddictDeck.cardIndices.PushBack(10); 	
			}
			if (difficulty == 3)
			{
				CircusGwentAddictDeck.cardIndices.PushBack(0); 
				CircusGwentAddictDeck.cardIndices.PushBack(301);	
				CircusGwentAddictDeck.cardIndices.PushBack(302);	
			}

			CircusGwentAddictDeck.cardIndices.PushBack(16); 	
			CircusGwentAddictDeck.cardIndices.PushBack(303);	
			CircusGwentAddictDeck.cardIndices.PushBack(305);	
			CircusGwentAddictDeck.cardIndices.PushBack(306);	
			CircusGwentAddictDeck.cardIndices.PushBack(308);	
			CircusGwentAddictDeck.cardIndices.PushBack(309);	
			CircusGwentAddictDeck.cardIndices.PushBack(313);	
			CircusGwentAddictDeck.cardIndices.PushBack(320);	
			CircusGwentAddictDeck.cardIndices.PushBack(321);	
			CircusGwentAddictDeck.cardIndices.PushBack(322);	
			CircusGwentAddictDeck.cardIndices.PushBack(325);	
			CircusGwentAddictDeck.cardIndices.PushBack(326);	
			CircusGwentAddictDeck.cardIndices.PushBack(365);	
			CircusGwentAddictDeck.cardIndices.PushBack(366);	

			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff5);
			CircusGwentAddictDeck.dynamicCards.PushBack(15); 
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff7);
			CircusGwentAddictDeck.dynamicCards.PushBack(12); 
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff9);
			CircusGwentAddictDeck.dynamicCards.PushBack(13); 
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff11);
			CircusGwentAddictDeck.dynamicCards.PushBack(9); 
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff11);
			CircusGwentAddictDeck.dynamicCards.PushBack(14); 
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff14);
			CircusGwentAddictDeck.dynamicCards.PushBack(2); 
			CircusGwentAddictDeck.dynamicCardRequirements.PushBack(diff14);
			CircusGwentAddictDeck.dynamicCards.PushBack(7); 

			CircusGwentAddictDeck.specialCard = 368; 
			CircusGwentAddictDeck.leaderIndex = 3005;
			enemyDecks.PushBack(CircusGwentAddictDeck);
	}
	
	private function SetupAIDeckDefinitionsNK()
	{
		var NKEasy				:SDeckDefinition;
		var NKNormal			:SDeckDefinition;
		var NKHard				:SDeckDefinition;
		
			
			NKEasy.cardIndices.PushBack(3); 
			NKEasy.cardIndices.PushBack(4); 
			NKEasy.cardIndices.PushBack(5); 
			NKEasy.cardIndices.PushBack(6); 

			if (difficulty == 3)
			{
				NKEasy.cardIndices.PushBack(100); 
				NKEasy.cardIndices.PushBack(9); 
			}

			NKEasy.cardIndices.PushBack(13); 
			NKEasy.cardIndices.PushBack(105); 
			NKEasy.cardIndices.PushBack(106); 
			NKEasy.cardIndices.PushBack(107); 
			NKEasy.cardIndices.PushBack(108); 
			NKEasy.cardIndices.PushBack(109);
			NKEasy.cardIndices.PushBack(111); 
			NKEasy.cardIndices.PushBack(112); 
			NKEasy.cardIndices.PushBack(113); 
			NKEasy.cardIndices.PushBack(114); 
			NKEasy.cardIndices.PushBack(120); 
			NKEasy.cardIndices.PushBack(125); 
			NKEasy.cardIndices.PushBack(126); 
			NKEasy.cardIndices.PushBack(130); 
			NKEasy.cardIndices.PushBack(135); 
			NKEasy.cardIndices.PushBack(136); 
			NKEasy.cardIndices.PushBack(141); 
			NKEasy.cardIndices.PushBack(145); 
			NKEasy.cardIndices.PushBack(150); 
			NKEasy.cardIndices.PushBack(150); 
			NKEasy.cardIndices.PushBack(175);
			NKEasy.specialCard = -1; 
			NKEasy.leaderIndex = 1001;
			enemyDecks.PushBack(NKEasy);

			
			
			NKNormal.cardIndices.PushBack(4); 
			NKNormal.cardIndices.PushBack(1); 
			NKNormal.cardIndices.PushBack(0); 
			NKNormal.cardIndices.PushBack(2); 
			NKNormal.cardIndices.PushBack(6); 

			if (difficulty == 1)
			{
				NKNormal.cardIndices.PushBack(4); 
				NKNormal.cardIndices.PushBack(3); 
			}
			if (difficulty == 2)
			{
				NKNormal.cardIndices.PushBack(4); 
				NKNormal.cardIndices.PushBack(1); 
				NKNormal.cardIndices.PushBack(100); 
			}
			if (difficulty == 3)
			{
				NKNormal.cardIndices.PushBack(100); 
				NKNormal.cardIndices.PushBack(9); 
			}

			NKNormal.cardIndices.PushBack(101); 
			NKNormal.cardIndices.PushBack(105); 
			NKNormal.cardIndices.PushBack(106); 
			NKNormal.cardIndices.PushBack(107); 
			NKNormal.cardIndices.PushBack(109); 
			NKNormal.cardIndices.PushBack(113); 
			NKNormal.cardIndices.PushBack(114); 
			NKNormal.cardIndices.PushBack(121); 
			NKNormal.cardIndices.PushBack(120); 
			NKNormal.cardIndices.PushBack(130); 
			NKNormal.cardIndices.PushBack(131); 
			NKNormal.cardIndices.PushBack(140); 
			NKNormal.cardIndices.PushBack(141); 
			NKNormal.cardIndices.PushBack(145); 
			NKNormal.cardIndices.PushBack(146); 
			NKNormal.cardIndices.PushBack(150); 
			NKNormal.cardIndices.PushBack(151); 
			NKNormal.cardIndices.PushBack(175); 

			NKNormal.dynamicCardRequirements.PushBack(diff12);
			NKNormal.dynamicCards.PushBack(12); 
			NKNormal.dynamicCardRequirements.PushBack(diff13);
			NKNormal.dynamicCards.PushBack(11); 
			NKNormal.dynamicCardRequirements.PushBack(diff15);
			NKNormal.dynamicCards.PushBack(10); 

			NKNormal.specialCard = -1; 
			NKNormal.leaderIndex = 1002;
			enemyDecks.PushBack(NKNormal);
			
			
			NKHard.cardIndices.PushBack(0); 
			NKHard.cardIndices.PushBack(1); 
			NKHard.cardIndices.PushBack(2); 
			NKHard.cardIndices.PushBack(3); 
			NKHard.cardIndices.PushBack(4); 
			NKHard.cardIndices.PushBack(6); 

			if (difficulty == 1)
			{
				NKHard.cardIndices.PushBack(4); 
				NKHard.cardIndices.PushBack(3); 
			}
			if (difficulty == 2)
			{
				NKHard.cardIndices.PushBack(1); 
				NKHard.cardIndices.PushBack(2); 
				NKHard.cardIndices.PushBack(7); 
				NKHard.cardIndices.PushBack(9); 
				NKHard.cardIndices.PushBack(10); 
			}
			if (difficulty == 3)
			{
				NKHard.cardIndices.PushBack(1); 
				NKHard.cardIndices.PushBack(2); 
				NKHard.cardIndices.PushBack(7);  
				NKHard.cardIndices.PushBack(15); 
				NKHard.cardIndices.PushBack(9); 
				NKHard.cardIndices.PushBack(10); 
			}

			NKHard.cardIndices.PushBack(11); 
			NKHard.cardIndices.PushBack(12); 
			NKHard.cardIndices.PushBack(100); 
			NKHard.cardIndices.PushBack(101); 
			NKHard.cardIndices.PushBack(102); 
			NKHard.cardIndices.PushBack(103); 
			NKHard.cardIndices.PushBack(105); 
			NKHard.cardIndices.PushBack(109); 
			NKHard.cardIndices.PushBack(116); 
			NKHard.cardIndices.PushBack(111); 
			NKHard.cardIndices.PushBack(121); 
			NKHard.cardIndices.PushBack(120); 
			NKHard.cardIndices.PushBack(140); 
			NKHard.cardIndices.PushBack(141); 
			NKHard.cardIndices.PushBack(145); 
			NKHard.cardIndices.PushBack(146); 
			NKHard.cardIndices.PushBack(150); 
			NKHard.cardIndices.PushBack(175);
			NKHard.specialCard = -1; 
			NKHard.leaderIndex = 1003;
			enemyDecks.PushBack(NKHard);
	}
	private function SetupAIDeckDefinitionsNilf()
	{
		var NilfEasy				:SDeckDefinition;
		var NilfNormal				:SDeckDefinition;
		var NilfHard				:SDeckDefinition;
			
			
			NilfEasy.cardIndices.PushBack(3); 
			NilfEasy.cardIndices.PushBack(4); 
			NilfEasy.cardIndices.PushBack(5); 
			NilfEasy.cardIndices.PushBack(6); 

			if (difficulty == 3)
			{
				NilfEasy.cardIndices.PushBack(1); 
				NilfEasy.cardIndices.PushBack(0); 
				NilfEasy.cardIndices.PushBack(15); 
				NilfEasy.cardIndices.PushBack(9); 
			}

			NilfEasy.cardIndices.PushBack(205); 
			NilfEasy.cardIndices.PushBack(207); 
			NilfEasy.cardIndices.PushBack(209); 
			NilfEasy.cardIndices.PushBack(210); 
			NilfEasy.cardIndices.PushBack(211); 
			NilfEasy.cardIndices.PushBack(212); 
			NilfEasy.cardIndices.PushBack(213); 
			NilfEasy.cardIndices.PushBack(215); 
			NilfEasy.cardIndices.PushBack(217); 
			NilfEasy.cardIndices.PushBack(218); 
			NilfEasy.cardIndices.PushBack(219);
			NilfEasy.cardIndices.PushBack(221);
			NilfEasy.cardIndices.PushBack(241);
			NilfEasy.cardIndices.PushBack(245);
			NilfEasy.cardIndices.PushBack(250);
			NilfEasy.cardIndices.PushBack(251);
			NilfEasy.specialCard = 260; 
			NilfEasy.leaderIndex = 2001;
			enemyDecks.PushBack(NilfEasy);
			
			
			
			if (difficulty == 1)
			{
				NilfNormal.cardIndices.PushBack(4); 
				NilfNormal.cardIndices.PushBack(3); 
			}
			if (difficulty == 2)
			{
				NilfNormal.cardIndices.PushBack(0); 
				NilfNormal.cardIndices.PushBack(1); 
				NilfNormal.cardIndices.PushBack(1); 
				NilfNormal.cardIndices.PushBack(2); 
				NilfNormal.cardIndices.PushBack(2); 
				NilfNormal.cardIndices.PushBack(3); 
				NilfNormal.cardIndices.PushBack(3); 
				NilfNormal.cardIndices.PushBack(6); 
				NilfNormal.cardIndices.PushBack(200); 
				NilfNormal.cardIndices.PushBack(230);
				NilfNormal.cardIndices.PushBack(218); 
			}
			if (difficulty == 3)
			{
				NilfNormal.cardIndices.PushBack(0); 
				NilfNormal.cardIndices.PushBack(1); 
				NilfNormal.cardIndices.PushBack(1); 
				NilfNormal.cardIndices.PushBack(2); 
				NilfNormal.cardIndices.PushBack(3); 
				NilfNormal.cardIndices.PushBack(6); 
				NilfNormal.cardIndices.PushBack(9); 
				NilfNormal.cardIndices.PushBack(200); 
				NilfNormal.cardIndices.PushBack(230);
				NilfNormal.cardIndices.PushBack(218); 
			}

			NilfNormal.cardIndices.PushBack(201); 
			NilfNormal.cardIndices.PushBack(203); 
			NilfNormal.cardIndices.PushBack(207); 
			NilfNormal.cardIndices.PushBack(209); 
			NilfNormal.cardIndices.PushBack(210); 
			NilfNormal.cardIndices.PushBack(208); 
			NilfNormal.cardIndices.PushBack(213); 
			NilfNormal.cardIndices.PushBack(235);
			NilfNormal.cardIndices.PushBack(236);
			NilfNormal.cardIndices.PushBack(240);
			NilfNormal.cardIndices.PushBack(245);
			NilfNormal.cardIndices.PushBack(246);
			NilfNormal.cardIndices.PushBack(247);
			NilfNormal.cardIndices.PushBack(250);
			NilfNormal.cardIndices.PushBack(251);
			NilfNormal.cardIndices.PushBack(252);
			NilfNormal.cardIndices.PushBack(260);
			NilfNormal.cardIndices.PushBack(261);


			NilfNormal.dynamicCardRequirements.PushBack(diff12);
			NilfNormal.dynamicCards.PushBack(15);
			NilfNormal.dynamicCardRequirements.PushBack(diff13);
			NilfNormal.dynamicCards.PushBack(202);
			NilfNormal.dynamicCardRequirements.PushBack(diff15);
			NilfNormal.dynamicCards.PushBack(7); 

			NilfNormal.specialCard = -1; 
			NilfNormal.leaderIndex = 2002;
			enemyDecks.PushBack(NilfNormal);


			
			if (difficulty == 1)
			{
				NilfHard.cardIndices.PushBack(4); 
				NilfHard.cardIndices.PushBack(3); 
			}
			if (difficulty == 2)
			{
				NilfHard.cardIndices.PushBack(0); 
				NilfHard.cardIndices.PushBack(1); 
				NilfHard.cardIndices.PushBack(1); 
				NilfHard.cardIndices.PushBack(2); 
				NilfHard.cardIndices.PushBack(2); 
				NilfHard.cardIndices.PushBack(218); 
				NilfHard.cardIndices.PushBack(200); 
				NilfHard.cardIndices.PushBack(231); 
				NilfHard.cardIndices.PushBack(235); 
			}
			if (difficulty == 3)
			{
				NilfHard.cardIndices.PushBack(0); 
				NilfHard.cardIndices.PushBack(0); 
				NilfHard.cardIndices.PushBack(1); 
				NilfHard.cardIndices.PushBack(1); 
				NilfHard.cardIndices.PushBack(2); 
				NilfHard.cardIndices.PushBack(2); 
				NilfHard.cardIndices.PushBack(218); 
				NilfHard.cardIndices.PushBack(200); 
				NilfHard.cardIndices.PushBack(231); 
				NilfHard.cardIndices.PushBack(235); 
				NilfHard.cardIndices.PushBack(9);   
			}

			NilfHard.cardIndices.PushBack(15); 
			NilfHard.cardIndices.PushBack(16); 
			NilfHard.cardIndices.PushBack(201); 
			NilfHard.cardIndices.PushBack(202); 
			NilfHard.cardIndices.PushBack(203); 
			NilfHard.cardIndices.PushBack(208); 
			NilfHard.cardIndices.PushBack(213); 
			NilfHard.cardIndices.PushBack(214); 
			NilfHard.cardIndices.PushBack(230); 
			NilfHard.cardIndices.PushBack(236); 
			NilfHard.cardIndices.PushBack(240); 
			NilfHard.cardIndices.PushBack(241); 
			NilfHard.cardIndices.PushBack(245); 
			NilfHard.cardIndices.PushBack(246); 
			NilfHard.cardIndices.PushBack(247); 
			NilfHard.cardIndices.PushBack(250); 
			NilfHard.cardIndices.PushBack(251); 
			NilfHard.cardIndices.PushBack(252); 

			NilfHard.specialCard = 261; 
			NilfHard.leaderIndex = 2003;
			enemyDecks.PushBack(NilfHard);
		
	}
	
	private function SetupAIDeckDefinitionsScoia()
	{
		var ScoiaEasy				:SDeckDefinition;
		var ScoiaNormal				:SDeckDefinition;
		var ScoiaHard				:SDeckDefinition;
		
			
			ScoiaEasy.cardIndices.PushBack(3); 
			ScoiaEasy.cardIndices.PushBack(4); 
			ScoiaEasy.cardIndices.PushBack(5); 
			ScoiaEasy.cardIndices.PushBack(6); 

			if (difficulty == 3)
			{
				ScoiaEasy.cardIndices.PushBack(0); 
				ScoiaEasy.cardIndices.PushBack(1); 
				ScoiaEasy.cardIndices.PushBack(300); 
				ScoiaEasy.cardIndices.PushBack(9); 
			}

			ScoiaEasy.cardIndices.PushBack(306);
			ScoiaEasy.cardIndices.PushBack(307);
			ScoiaEasy.cardIndices.PushBack(308);
			ScoiaEasy.cardIndices.PushBack(309);
			ScoiaEasy.cardIndices.PushBack(310);
			ScoiaEasy.cardIndices.PushBack(311);
			ScoiaEasy.cardIndices.PushBack(312);
			ScoiaEasy.cardIndices.PushBack(320);
			ScoiaEasy.cardIndices.PushBack(325);
			ScoiaEasy.cardIndices.PushBack(330);
			ScoiaEasy.cardIndices.PushBack(331);
			ScoiaEasy.cardIndices.PushBack(335);
			ScoiaEasy.cardIndices.PushBack(336);
			ScoiaEasy.cardIndices.PushBack(337);
			ScoiaEasy.cardIndices.PushBack(340);
			ScoiaEasy.cardIndices.PushBack(350);
			ScoiaEasy.cardIndices.PushBack(351);
			ScoiaEasy.cardIndices.PushBack(355);
			ScoiaEasy.cardIndices.PushBack(360);
			ScoiaEasy.specialCard = -1; 
			ScoiaEasy.leaderIndex = 3001;
			enemyDecks.PushBack(ScoiaEasy);

			
			
 			if (difficulty == 1)
			{
				ScoiaNormal.cardIndices.PushBack(0); 
				ScoiaNormal.cardIndices.PushBack(1); 
				ScoiaNormal.cardIndices.PushBack(3); 
				ScoiaNormal.cardIndices.PushBack(4); 
				ScoiaNormal.cardIndices.PushBack(5); 
				ScoiaNormal.cardIndices.PushBack(6); 
			}
			if (difficulty == 2)
			{
				ScoiaNormal.cardIndices.PushBack(0); 
				ScoiaNormal.cardIndices.PushBack(1); 
				ScoiaNormal.cardIndices.PushBack(2); 
				ScoiaNormal.cardIndices.PushBack(2); 
				ScoiaNormal.cardIndices.PushBack(3); 
				ScoiaNormal.cardIndices.PushBack(6); 
				ScoiaNormal.cardIndices.PushBack(5); 
				ScoiaNormal.cardIndices.PushBack(301);	
				ScoiaNormal.cardIndices.PushBack(302);	
			}
			if (difficulty == 3)
			{
				ScoiaNormal.cardIndices.PushBack(0); 
				ScoiaNormal.cardIndices.PushBack(0); 
				ScoiaNormal.cardIndices.PushBack(1); 
				ScoiaNormal.cardIndices.PushBack(2); 
				ScoiaNormal.cardIndices.PushBack(6); 
				ScoiaNormal.cardIndices.PushBack(5); 
				ScoiaNormal.cardIndices.PushBack(301);	
				ScoiaNormal.cardIndices.PushBack(302);	
			}
 
			ScoiaNormal.cardIndices.PushBack(16);   
			ScoiaNormal.cardIndices.PushBack(303);	
			ScoiaNormal.cardIndices.PushBack(305);	
			ScoiaNormal.cardIndices.PushBack(306);	
			ScoiaNormal.cardIndices.PushBack(307);  
			ScoiaNormal.cardIndices.PushBack(308);	
			ScoiaNormal.cardIndices.PushBack(309);	
			ScoiaNormal.cardIndices.PushBack(313);	
			ScoiaNormal.cardIndices.PushBack(320);	
			ScoiaNormal.cardIndices.PushBack(321);	
			ScoiaNormal.cardIndices.PushBack(322);	
			ScoiaNormal.cardIndices.PushBack(325);	
			ScoiaNormal.cardIndices.PushBack(326);	
			ScoiaNormal.cardIndices.PushBack(330);  
			ScoiaNormal.cardIndices.PushBack(331);  
			ScoiaNormal.cardIndices.PushBack(335);	
			ScoiaNormal.cardIndices.PushBack(336);	
			ScoiaNormal.cardIndices.PushBack(337);	
			ScoiaNormal.cardIndices.PushBack(365);	
			ScoiaNormal.cardIndices.PushBack(366);	
			ScoiaNormal.cardIndices.PushBack(367);	


			ScoiaNormal.dynamicCardRequirements.PushBack(diff12);
			ScoiaNormal.dynamicCards.PushBack(12); 
			ScoiaNormal.dynamicCardRequirements.PushBack(diff13);
			ScoiaNormal.dynamicCards.PushBack(15); 
			ScoiaNormal.dynamicCardRequirements.PushBack(diff15);
			ScoiaNormal.dynamicCards.PushBack(10); 

			ScoiaNormal.specialCard = -1; 
			ScoiaNormal.leaderIndex = 3002;
			enemyDecks.PushBack(ScoiaNormal);


			
			ScoiaHard.cardIndices.PushBack(3); 
			ScoiaHard.cardIndices.PushBack(1); 
			ScoiaHard.cardIndices.PushBack(1); 
			ScoiaHard.cardIndices.PushBack(2); 
			ScoiaHard.cardIndices.PushBack(2); 
			ScoiaHard.cardIndices.PushBack(0); 

 			if (difficulty == 1)
			{
				ScoiaHard.cardIndices.PushBack(4); 
			}
			if (difficulty == 2)
			{
				ScoiaHard.cardIndices.PushBack(7);  
				ScoiaHard.cardIndices.PushBack(10); 
				ScoiaHard.cardIndices.PushBack(301);	
				ScoiaHard.cardIndices.PushBack(302);	
			}
			if (difficulty == 3)
			{
				ScoiaHard.cardIndices.PushBack(7);  
				ScoiaHard.cardIndices.PushBack(10); 
				ScoiaHard.cardIndices.PushBack(301);	
				ScoiaHard.cardIndices.PushBack(302);	
				ScoiaHard.cardIndices.PushBack(9); 
			}

			ScoiaHard.cardIndices.PushBack(15); 
			ScoiaHard.cardIndices.PushBack(16); 
			ScoiaHard.cardIndices.PushBack(12); 
			ScoiaHard.cardIndices.PushBack(300);	
			ScoiaHard.cardIndices.PushBack(303);	
			ScoiaHard.cardIndices.PushBack(305);	
			ScoiaHard.cardIndices.PushBack(306);	
			ScoiaHard.cardIndices.PushBack(308);	
			ScoiaHard.cardIndices.PushBack(309);	
			ScoiaHard.cardIndices.PushBack(313);	
			ScoiaHard.cardIndices.PushBack(320);	
			ScoiaHard.cardIndices.PushBack(321);	
			ScoiaHard.cardIndices.PushBack(322);	
			ScoiaHard.cardIndices.PushBack(325);	
			ScoiaHard.cardIndices.PushBack(326);	
			ScoiaHard.cardIndices.PushBack(365);	
			ScoiaHard.cardIndices.PushBack(366);	
			ScoiaHard.cardIndices.PushBack(367);	

			ScoiaHard.specialCard = -1; 
			ScoiaHard.leaderIndex = 3003;
			enemyDecks.PushBack(ScoiaHard);
			
	}
	
	private function SetupAIDeckDefinitionsNML()
	{
		var NMLEasy				:SDeckDefinition;
		var NMLNormal			:SDeckDefinition;
		var NMLHard				:SDeckDefinition;
		
			
			NMLEasy.cardIndices.PushBack(3); 
			NMLEasy.cardIndices.PushBack(4); 
			NMLEasy.cardIndices.PushBack(5); 
			NMLEasy.cardIndices.PushBack(6); 

			if (difficulty == 3)
			{
				NMLEasy.cardIndices.PushBack(476); 
				NMLEasy.cardIndices.PushBack(9); 
			}

			NMLEasy.cardIndices.PushBack(405); 
			NMLEasy.cardIndices.PushBack(407); 
			NMLEasy.cardIndices.PushBack(410); 
			NMLEasy.cardIndices.PushBack(413); 
			NMLEasy.cardIndices.PushBack(415); 
			NMLEasy.cardIndices.PushBack(417); 
			NMLEasy.cardIndices.PushBack(420); 
			NMLEasy.cardIndices.PushBack(423); 
			NMLEasy.cardIndices.PushBack(425); 
			NMLEasy.cardIndices.PushBack(427); 
			NMLEasy.cardIndices.PushBack(430); 
			NMLEasy.cardIndices.PushBack(433); 
			NMLEasy.cardIndices.PushBack(435); 
			NMLEasy.cardIndices.PushBack(437); 
			NMLEasy.cardIndices.PushBack(450); 
			NMLEasy.cardIndices.PushBack(455); 
			NMLEasy.cardIndices.PushBack(456); 
			NMLEasy.cardIndices.PushBack(460); 
			NMLEasy.cardIndices.PushBack(470); 
			NMLEasy.cardIndices.PushBack(475); 
			NMLEasy.specialCard = -1; 
			NMLEasy.leaderIndex = 4001;
			enemyDecks.PushBack(NMLEasy);

			
			
			NMLNormal.cardIndices.PushBack(4); 
			NMLNormal.cardIndices.PushBack(5); 
			NMLNormal.cardIndices.PushBack(6); 	
			NMLNormal.cardIndices.PushBack(0); 	

 			if (difficulty == 1)
			{
				NMLNormal.cardIndices.PushBack(4); 
				NMLNormal.cardIndices.PushBack(1); 	
				NMLNormal.cardIndices.PushBack(2); 	
			}
			if (difficulty == 2)
			{
				NMLNormal.cardIndices.PushBack(1); 	
				NMLNormal.cardIndices.PushBack(1); 	
				NMLNormal.cardIndices.PushBack(2); 	
				NMLNormal.cardIndices.PushBack(2); 	
				NMLNormal.cardIndices.PushBack(400); 
			}
			if (difficulty == 3)
			{
				NMLNormal.cardIndices.PushBack(1); 	
				NMLNormal.cardIndices.PushBack(1); 	
				NMLNormal.cardIndices.PushBack(2); 	
				NMLNormal.cardIndices.PushBack(0); 	
				NMLNormal.cardIndices.PushBack(0); 	
				NMLNormal.cardIndices.PushBack(7);  
				NMLNormal.cardIndices.PushBack(9);  
				NMLNormal.cardIndices.PushBack(400); 
			}

			NMLNormal.cardIndices.PushBack(402); 
			NMLNormal.cardIndices.PushBack(403); 
			NMLNormal.cardIndices.PushBack(407); 
			NMLNormal.cardIndices.PushBack(410); 
			NMLNormal.cardIndices.PushBack(415); 
			NMLNormal.cardIndices.PushBack(417); 
			NMLNormal.cardIndices.PushBack(423); 
			NMLNormal.cardIndices.PushBack(425); 
			NMLNormal.cardIndices.PushBack(450); 
			NMLNormal.cardIndices.PushBack(451); 
			NMLNormal.cardIndices.PushBack(452); 
			NMLNormal.cardIndices.PushBack(453); 
			NMLNormal.cardIndices.PushBack(460); 
			NMLNormal.cardIndices.PushBack(463); 
			NMLNormal.cardIndices.PushBack(461); 
			NMLNormal.cardIndices.PushBack(462); 
			NMLNormal.cardIndices.PushBack(464); 
			NMLNormal.cardIndices.PushBack(475); 
			NMLNormal.cardIndices.PushBack(476); 
			NMLNormal.cardIndices.PushBack(477); 


			NMLNormal.dynamicCardRequirements.PushBack(diff12);
			NMLNormal.dynamicCards.PushBack(401); 
			NMLNormal.dynamicCardRequirements.PushBack(diff13);
			NMLNormal.dynamicCards.PushBack(16); 
			NMLNormal.dynamicCardRequirements.PushBack(diff15);
			NMLNormal.dynamicCards.PushBack(15); 

			NMLNormal.specialCard = -1; 
			NMLNormal.leaderIndex = 4002;
			enemyDecks.PushBack(NMLNormal);

			
			
			NMLHard.cardIndices.PushBack(1); 		
			NMLHard.cardIndices.PushBack(2); 		
			NMLHard.cardIndices.PushBack(0); 		

 			if (difficulty == 1)
			{
				NMLHard.cardIndices.PushBack(4); 	
				NMLHard.cardIndices.PushBack(3); 	
				NMLHard.cardIndices.PushBack(2); 	
			}
			if (difficulty == 2)
			{
				NMLHard.cardIndices.PushBack(1); 	
				NMLHard.cardIndices.PushBack(2); 	
				NMLHard.cardIndices.PushBack(15);	
				NMLHard.cardIndices.PushBack(402);	
				NMLHard.cardIndices.PushBack(476);	
				NMLHard.cardIndices.PushBack(451);	
			}
			if (difficulty == 3)
			{
				NMLHard.cardIndices.PushBack(1); 	
				NMLHard.cardIndices.PushBack(2); 	
				NMLHard.cardIndices.PushBack(0); 	
				NMLHard.cardIndices.PushBack(15);	
				NMLHard.cardIndices.PushBack(402);	
				NMLHard.cardIndices.PushBack(476);	
				NMLHard.cardIndices.PushBack(451);	
				NMLHard.cardIndices.PushBack(9);  
			}

		
			NMLHard.cardIndices.PushBack(16);	
			NMLHard.cardIndices.PushBack(401);	
			NMLHard.cardIndices.PushBack(403);	
			NMLHard.cardIndices.PushBack(407);	
			NMLHard.cardIndices.PushBack(450);	
			NMLHard.cardIndices.PushBack(452);	
			NMLHard.cardIndices.PushBack(455);	
			NMLHard.cardIndices.PushBack(456);	
			NMLHard.cardIndices.PushBack(457);	
			NMLHard.cardIndices.PushBack(460);	
			NMLHard.cardIndices.PushBack(463);	
			NMLHard.cardIndices.PushBack(461);	
			NMLHard.cardIndices.PushBack(462);	
			NMLHard.cardIndices.PushBack(464);	
			NMLHard.cardIndices.PushBack(470);	
			NMLHard.cardIndices.PushBack(471);	
			NMLHard.cardIndices.PushBack(472);	
			NMLHard.cardIndices.PushBack(475);	
			NMLHard.cardIndices.PushBack(477);	

			NMLHard.specialCard = -1; 
			NMLHard.leaderIndex = 4003;
			enemyDecks.PushBack(NMLHard);
	}
	private function SetupAIDeckDefinitionsPrologue()
	{
		var NilfPrologue		: SDeckDefinition;
			
			
			NilfPrologue.cardIndices.PushBack(3); 
			NilfPrologue.cardIndices.PushBack(4); 
			NilfPrologue.cardIndices.PushBack(5); 
			NilfPrologue.cardIndices.PushBack(6); 

			NilfPrologue.cardIndices.PushBack(205); 
			NilfPrologue.cardIndices.PushBack(207);
			NilfPrologue.cardIndices.PushBack(209); 
			NilfPrologue.cardIndices.PushBack(210); 
			NilfPrologue.cardIndices.PushBack(211); 
			NilfPrologue.cardIndices.PushBack(212); 
			NilfPrologue.cardIndices.PushBack(215); 
			NilfPrologue.cardIndices.PushBack(215); 
			NilfPrologue.cardIndices.PushBack(217); 
			NilfPrologue.cardIndices.PushBack(221);
			NilfPrologue.cardIndices.PushBack(221);
			NilfPrologue.cardIndices.PushBack(241);
			NilfPrologue.cardIndices.PushBack(245);
			NilfPrologue.cardIndices.PushBack(250);
			NilfPrologue.cardIndices.PushBack(251);
			NilfPrologue.specialCard = 219; 
			NilfPrologue.leaderIndex = 2001;
			enemyDecks.PushBack(NilfPrologue);
	}
	private function SetupAIDeckDefinitionsTournament1()
	{
		var NKTournament		: SDeckDefinition;
		var NilfTournament		: SDeckDefinition;

			
			NKTournament.cardIndices.PushBack(2); 
			NKTournament.cardIndices.PushBack(0); 
			NKTournament.cardIndices.PushBack(1); 
			NKTournament.cardIndices.PushBack(3); 
			NKTournament.cardIndices.PushBack(3); 
			NKTournament.cardIndices.PushBack(4); 

 			if (difficulty == 1)
			{	
				NKTournament.cardIndices.PushBack(6); 
				NKTournament.cardIndices.PushBack(108); 
				NKTournament.cardIndices.PushBack(113); 
				NKTournament.cardIndices.PushBack(114); 
			}
			else
			{
				NKTournament.cardIndices.PushBack(2); 
				NKTournament.cardIndices.PushBack(1); 
				NKTournament.cardIndices.PushBack(105); 
			}

			NKTournament.cardIndices.PushBack(102);	
			NKTournament.cardIndices.PushBack(103);	
			NKTournament.cardIndices.PushBack(109);	
			NKTournament.cardIndices.PushBack(116); 
			NKTournament.cardIndices.PushBack(120); 
			NKTournament.cardIndices.PushBack(140); 
			NKTournament.cardIndices.PushBack(141); 
			NKTournament.cardIndices.PushBack(145); 
			NKTournament.cardIndices.PushBack(160);	
			NKTournament.cardIndices.PushBack(161); 
			NKTournament.cardIndices.PushBack(170); 
			NKTournament.cardIndices.PushBack(175);	
			
			NKTournament.dynamicCardRequirements.PushBack(diff2);	
			NKTournament.dynamicCards.PushBack(13);				
			NKTournament.dynamicCardRequirements.PushBack(diff5);	
			NKTournament.dynamicCards.PushBack(151); 				
			NKTournament.dynamicCardRequirements.PushBack(diff6);	
			NKTournament.dynamicCards.PushBack(12); 				
			NKTournament.dynamicCardRequirements.PushBack(diff8);	
			NKTournament.dynamicCards.PushBack(11); 				
			NKTournament.dynamicCardRequirements.PushBack(diff8);	
			NKTournament.dynamicCards.PushBack(7); 				
			NKTournament.dynamicCardRequirements.PushBack(diff8);	
			NKTournament.dynamicCards.PushBack(15); 				
			NKTournament.dynamicCardRequirements.PushBack(diff10);	
			NKTournament.dynamicCards.PushBack(10);
			NKTournament.dynamicCardRequirements.PushBack(diff10);	
			NKTournament.dynamicCards.PushBack(9); 				
			
			NKTournament.specialCard = 16;	
			NKTournament.leaderIndex = 1004; 
			enemyDecks.PushBack(NKTournament);

			
			
			NilfTournament.cardIndices.PushBack(0); 
			NilfTournament.cardIndices.PushBack(1); 
			NilfTournament.cardIndices.PushBack(2); 
			NilfTournament.cardIndices.PushBack(2); 
			NilfTournament.cardIndices.PushBack(6); 

 			if (difficulty == 1)
			{	
				NilfTournament.cardIndices.PushBack(6); 
				NilfTournament.cardIndices.PushBack(205); 
				NilfTournament.cardIndices.PushBack(209); 
				NilfTournament.cardIndices.PushBack(212); 
			}
			else
			{
				NilfTournament.cardIndices.PushBack(0); 
				NilfTournament.cardIndices.PushBack(0); 
				NilfTournament.cardIndices.PushBack(1); 
				NilfTournament.cardIndices.PushBack(218); 
				NilfTournament.cardIndices.PushBack(200); 
				NilfTournament.cardIndices.PushBack(230);
			}

			NilfTournament.cardIndices.PushBack(201);
			NilfTournament.cardIndices.PushBack(202);
			NilfTournament.cardIndices.PushBack(203); 
			NilfTournament.cardIndices.PushBack(208); 
			NilfTournament.cardIndices.PushBack(213); 
			NilfTournament.cardIndices.PushBack(214); 
			NilfTournament.cardIndices.PushBack(231);
			NilfTournament.cardIndices.PushBack(235);
			NilfTournament.cardIndices.PushBack(236);
			NilfTournament.cardIndices.PushBack(240);
			NilfTournament.cardIndices.PushBack(241);
			NilfTournament.cardIndices.PushBack(260);
			NilfTournament.cardIndices.PushBack(261);

			
			NilfTournament.dynamicCardRequirements.PushBack(diff1);
			NilfTournament.dynamicCards.PushBack(15);
			NilfTournament.dynamicCardRequirements.PushBack(diff4);
			NilfTournament.dynamicCards.PushBack(16);
			NilfTournament.dynamicCardRequirements.PushBack(diff4);
			NilfTournament.dynamicCards.PushBack(12);
			NilfTournament.dynamicCardRequirements.PushBack(diff6);
			NilfTournament.dynamicCards.PushBack(248);
			NilfTournament.dynamicCardRequirements.PushBack(diff6);
			NilfTournament.dynamicCards.PushBack(11);
			NilfTournament.dynamicCardRequirements.PushBack(diff8);
			NilfTournament.dynamicCards.PushBack(7); 
			NilfTournament.dynamicCardRequirements.PushBack(diff10);
			NilfTournament.dynamicCards.PushBack(9);


			NilfTournament.specialCard = -1; 
			NilfTournament.leaderIndex = 2004;
			enemyDecks.PushBack(NilfTournament);
		

	}

	private function SetupAIDeckDefinitionsTournament2()
	{
		var NMLTournament		: SDeckDefinition;
		var ScoiaTournament		: SDeckDefinition;

			
			ScoiaTournament.cardIndices.PushBack(0); 
			ScoiaTournament.cardIndices.PushBack(1); 
			ScoiaTournament.cardIndices.PushBack(2); 
			ScoiaTournament.cardIndices.PushBack(3); 
			ScoiaTournament.cardIndices.PushBack(4); 
			ScoiaTournament.cardIndices.PushBack(5); 

 			if (difficulty == 1)
			{	
				ScoiaTournament.cardIndices.PushBack(310); 
				ScoiaTournament.cardIndices.PushBack(312); 
				ScoiaTournament.cardIndices.PushBack(335); 
			}
			else
			{
				ScoiaTournament.cardIndices.PushBack(2); 
				ScoiaTournament.cardIndices.PushBack(301);	
				ScoiaTournament.cardIndices.PushBack(302);	
				ScoiaTournament.cardIndices.PushBack(366);	
			}
 
			ScoiaTournament.cardIndices.PushBack(303);	
			ScoiaTournament.cardIndices.PushBack(305);	
			ScoiaTournament.cardIndices.PushBack(306);	
			ScoiaTournament.cardIndices.PushBack(307);	
			ScoiaTournament.cardIndices.PushBack(308);	
			ScoiaTournament.cardIndices.PushBack(309);	
			ScoiaTournament.cardIndices.PushBack(313);	
			ScoiaTournament.cardIndices.PushBack(320);	
			ScoiaTournament.cardIndices.PushBack(321);	
			ScoiaTournament.cardIndices.PushBack(322);	
			ScoiaTournament.cardIndices.PushBack(365);	
			ScoiaTournament.cardIndices.PushBack(367);	
			
			ScoiaTournament.dynamicCardRequirements.PushBack(diff1);
			ScoiaTournament.dynamicCards.PushBack(15);
			ScoiaTournament.dynamicCardRequirements.PushBack(diff2);
			ScoiaTournament.dynamicCards.PushBack(12);
			ScoiaTournament.dynamicCardRequirements.PushBack(diff6);
			ScoiaTournament.dynamicCards.PushBack(300);
			ScoiaTournament.dynamicCardRequirements.PushBack(diff8);
			ScoiaTournament.dynamicCards.PushBack(11);
			ScoiaTournament.dynamicCardRequirements.PushBack(diff8);
			ScoiaTournament.dynamicCards.PushBack(14);
			ScoiaTournament.dynamicCardRequirements.PushBack(diff10);
			ScoiaTournament.dynamicCards.PushBack(7); 
			ScoiaTournament.dynamicCardRequirements.PushBack(diff10);
			ScoiaTournament.dynamicCards.PushBack(10);


			ScoiaTournament.specialCard = -1; 
			ScoiaTournament.leaderIndex = 3004; 
			enemyDecks.PushBack(ScoiaTournament);

			
			NMLTournament.cardIndices.PushBack(0); 		
			NMLTournament.cardIndices.PushBack(1); 		
			NMLTournament.cardIndices.PushBack(5);		
			NMLTournament.cardIndices.PushBack(5);		
			NMLTournament.cardIndices.PushBack(6);		
			NMLTournament.cardIndices.PushBack(6);		

 			if (difficulty == 1)
			{	
				NMLTournament.cardIndices.PushBack(420);	
				NMLTournament.cardIndices.PushBack(420);	
			}
			else
			{
				NMLTournament.cardIndices.PushBack(0); 		
				NMLTournament.cardIndices.PushBack(1); 		
				NMLTournament.cardIndices.PushBack(403);	
				NMLTournament.cardIndices.PushBack(477);	
			}

			NMLTournament.cardIndices.PushBack(401);	
			NMLTournament.cardIndices.PushBack(402);	
			NMLTournament.cardIndices.PushBack(407);	
			NMLTournament.cardIndices.PushBack(450);	
			NMLTournament.cardIndices.PushBack(451);	
			NMLTournament.cardIndices.PushBack(452);	
			NMLTournament.cardIndices.PushBack(460);	
			NMLTournament.cardIndices.PushBack(463);	
			NMLTournament.cardIndices.PushBack(461);	
			NMLTournament.cardIndices.PushBack(462);	
			NMLTournament.cardIndices.PushBack(464);	
			NMLTournament.cardIndices.PushBack(475);	
			NMLTournament.cardIndices.PushBack(476);	
			
			
			NMLTournament.dynamicCardRequirements.PushBack(diff1);	
			NMLTournament.dynamicCards.PushBack(1);				
			NMLTournament.dynamicCardRequirements.PushBack(diff3);	
			NMLTournament.dynamicCards.PushBack(11); 				
			NMLTournament.dynamicCardRequirements.PushBack(diff4);	
			NMLTournament.dynamicCards.PushBack(12); 				
			NMLTournament.dynamicCardRequirements.PushBack(diff4);	
			NMLTournament.dynamicCards.PushBack(2); 				
			NMLTournament.dynamicCardRequirements.PushBack(diff6);	
			NMLTournament.dynamicCards.PushBack(15); 				
			NMLTournament.dynamicCardRequirements.PushBack(diff7);	
			NMLTournament.dynamicCards.PushBack(14); 				
			NMLTournament.dynamicCardRequirements.PushBack(diff8);	
			NMLTournament.dynamicCards.PushBack(13); 				
			NMLTournament.dynamicCardRequirements.PushBack(diff10);	
			NMLTournament.dynamicCards.PushBack(7); 				
			NMLTournament.dynamicCardRequirements.PushBack(diff10);	
			NMLTournament.dynamicCards.PushBack(16); 				
			
			NMLTournament.specialCard = 401; 	
			NMLTournament.leaderIndex = 4004; 
			enemyDecks.PushBack(NMLTournament);
	}

	public function GwentLeadersNametoInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_foltest_bronze':		return 1002; 
			case 'gwint_card_foltest_silver':		return 1003; 
			case 'gwint_card_foltest_gold':			return 1004; 
			case 'gwint_card_foltest_platinium':	return 1005;
 
			case 'gwint_card_emhyr_bronze':			return 2002; 
			case 'gwint_card_emhyr_silver':			return 2003; 
			case 'gwint_card_emhyr_gold':			return 2004; 
			case 'gwint_card_emhyr_platinium':		return 2005;
 
			case 'gwint_card_francesca_bronze':		return 3002; 
			case 'gwint_card_francesca_silver':		return 3003; 
			case 'gwint_card_francesca_gold':		return 3004;
			case 'gwint_card_francesca_platinium':	return 3005;
				
			case 'gwint_card_eredin_bronze':		return 4002; 
			case 'gwint_card_eredin_silver':		return 4003; 
			case 'gwint_card_eredin_gold':			return 4004; 
			case 'gwint_card_eredin_platinium':		return 4005; 
			default: return	0;
		}
	}
	
	public function GwentNrkdNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_vernon':			return 100; 
			case 'gwint_card_natalis':			return 101; 
			case 'gwint_card_esterad':			return 102; 
			case 'gwint_card_philippa':			return 103; 
			case 'gwint_card_thaler':			return 105; 
			case 'gwint_card_dijkstra':			return 109; 
			case 'gwint_card_trebuchet':		return 121; 
			case 'gwint_card_siege_tower':		return 170; 
			case 'gwint_card_ballista':			return 146; 
			case 'gwint_card_siegfried':		return 107; 
			case 'gwint_card_blue_stripes':		return 160; 
			case 'gwint_card_blue_stripes2':	return 160; 
			case 'gwint_card_blue_stripes3':	return 160; 
			case 'gwint_card_crinfrid':			return 130; 
			case 'gwint_card_crinfrid2':		return 130; 
			case 'gwint_card_crinfrid3':		return 130; 
			case 'gwint_card_catapult':			return 140; 
			case 'gwint_card_catapult2':		return 140; 
			case 'gwint_card_stennis':			return 116; 
			case 'gwint_card_poor_infantry':	return 125;
			case 'gwint_card_poor_infantry2':	return 126;
			case 'gwint_card_poor_infantry3':	return 127;
 			case 'gwint_card_kaedwen':			return 150; 
			case 'gwint_card_kaedwen2':			return 151; 
			case 'gwint_card_dun_banner_medic':	return 175; 
			default: return 0;
		}
	}
	
	public function GwentNlfgNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_letho':				return 200; 
			case 'gwint_card_black_archer':			return 235;
			case 'gwint_card_black_archer2':		return 236;
			case 'gwint_card_menno':				return 201; 
			case 'gwint_card_moorvran':				return 202; 
			case 'gwint_card_tibor':				return 203; 
			case 'gwint_card_albrich':				return 205; 
			case 'gwint_card_combat_engineer':		return 255;	
			case 'gwint_card_assire':				return 206; 
			case 'gwint_card_fringilla':			return 208;	
			case 'gwint_card_cynthia':				return 207; 
			case 'gwint_card_morteisen':			return 209; 
			case 'gwint_card_rainfarn':				return 210; 
			case 'gwint_card_renuald':				return 211; 
			case 'gwint_card_rotten':				return 212; 
			case 'gwint_card_shilard':				return 213; 
			case 'gwint_card_sweers':				return 215; 
			case 'gwint_card_vanhemar':				return 217; 
			case 'gwint_card_vattier':				return 218; 
			case 'gwint_card_vreemde':				return 219; 
			case 'gwint_card_cahir':				return 220; 
			case 'gwint_card_puttkammer':			return 221; 
			case 'gwint_card_heavy_zerri':			return 240; 
			case 'gwint_card_zerri':				return 241; 
			case 'gwint_card_impera_brigade':		return 245;	
			case 'gwint_card_impera_brigade2':		return 245;	
			case 'gwint_card_impera_brigade3':		return 245;	
			case 'gwint_card_impera_brigade4':		return 245;	
			case 'gwint_card_archer_support':		return 230;	
			case 'gwint_card_archer_support2':		return 231;	
			case 'gwint_card_siege_support':		return 265;	
			case 'gwint_card_nausicaa':             return 250;	
			case 'gwint_card_nausicaa2':            return 250;	
			case 'gwint_card_nausicaa3':            return 250;	
			case 'gwint_card_stefan':				return 214; 
			case 'gwint_card_young_emissary':		return 260; 
			case 'gwint_card_young_emissary2':		return 261; 
			default: return 0;
			
		}
	}
	
	public function GwentSctlNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_eithne':				return 300;	
			case 'gwint_card_saskia':				return 301;	
			case 'gwint_card_isengrim':				return 302; 
			case 'gwint_card_iorveth':				return 303;	
			case 'gwint_card_milva':				return 306;	
			case 'gwint_card_dennis':				return 305;	
			case 'gwint_card_ida':					return 307;	
			case 'gwint_card_filavandrel':			return 308;	
			case 'gwint_card_yaevinn':				return 309;	
			case 'gwint_card_toruviel':				return 310;	
			case 'gwint_card_riordain':				return 311;	
			case 'gwint_card_ciaran':				return 312;	
			case 'gwint_card_barclay':				return 313;	
			case 'gwint_card_havekar_support':		return 320;	
			case 'gwint_card_havekar_support2':		return 321;	
			case 'gwint_card_havekar_support3':		return 322;	
			case 'gwint_card_vrihedd_brigade':		return 325;	
			case 'gwint_card_vrihedd_brigade2':		return 326;
			case 'gwint_card_dol_infantry':			return 330;	
			case 'gwint_card_dol_infantry2':		return 331;	
			case 'gwint_card_dol_infantry3':		return 332;	
			case 'gwint_card_dol_dwarf':			return 335;	
			case 'gwint_card_dol_dwarf2':			return 336;	
			case 'gwint_card_dol_dwarf3':			return 337;	
			case 'gwint_card_mahakam':				return 340;	
			case 'gwint_card_mahakam2':				return 341;	
			case 'gwint_card_mahakam3':				return 342;	
			case 'gwint_card_mahakam4':				return 343;	
			case 'gwint_card_mahakam5':				return 344;	
			case 'gwint_card_elf_skirmisher':		return 350;	
			case 'gwint_card_elf_skirmisher2':		return 351;	
			case 'gwint_card_elf_skirmisher3':		return 352;	
			case 'gwint_card_vrihedd_cadet':		return 355;	
			case 'gwint_card_dol_archer':			return 360;	
			case 'gwint_card_havekar_nurse':		return 365;	
			case 'gwint_card_havekar_nurse2':		return 366;	
			case 'gwint_card_havekar_nurse3':		return 367;
			case 'gwint_card_schirru':				return 368;	
			default: return 0;
		}
	}
	
	public function GwentMstrNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_draug':				return 400; 
			case 'gwint_card_kayran':				return 401; 
			case 'gwint_card_imlerith':				return 402; 
			case 'gwint_card_leshen':				return 403; 
			case 'gwint_card_forktail':				return 405; 
			case 'gwint_card_earth_elemental':		return 407; 
			case 'gwint_card_fiend':				return 410; 
			case 'gwint_card_plague_maiden':		return 413; 
			case 'gwint_card_griffin':				return 415; 
			case 'gwint_card_werewolf':				return 417; 
			case 'gwint_card_botchling':			return 420; 
			case 'gwint_card_frightener':			return 423; 
			case 'gwint_card_ice_giant':			return 425; 
			case 'gwint_card_endrega':				return 427; 
			case 'gwint_card_harpy':				return 430; 
			case 'gwint_card_cockatrice':			return 433; 
			case 'gwint_card_gargoyle':				return 435; 
			case 'gwint_card_celaeno_harpy':		return 437; 
			case 'gwint_card_grave_hag':			return 440;	
			case 'gwint_card_fire_elemental':		return 443;	
			case 'gwint_card_fogling':				return 445; 
			case 'gwint_card_wyvern':				return 447; 
			case 'gwint_card_arachas_behemoth':		return 450; 
			case 'gwint_card_arachas':				return 451; 
			case 'gwint_card_arachas2':				return 452; 
			case 'gwint_card_arachas3':				return 453; 
			case 'gwint_card_nekker':				return 455; 
			case 'gwint_card_nekker2':				return 456; 
			case 'gwint_card_nekker3':				return 457; 
			case 'gwint_card_ekkima':				return 460; 
			case 'gwint_card_fleder':				return 461; 
			case 'gwint_card_garkain':				return 462; 
			case 'gwint_card_bruxa':				return 463; 
			case 'gwint_card_katakan':				return 464; 
			case 'gwint_card_ghoul':				return 470; 
			case 'gwint_card_ghoul2':				return 471; 
			case 'gwint_card_ghoul3':				return 472; 
			case 'gwint_card_crone_brewess':		return 475;	
			case 'gwint_card_crone_weavess':		return 476;	
			case 'gwint_card_crone_whispess':		return 477;	
			case 'gwint_card_toad':					return 478;	
			default: return 0;
		}
	}
	
	public function GwentNeutralNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_geralt':				return 7 ; 	
			case 'gwint_card_vesemir':				return 8 ; 	
			case 'gwint_card_yennefer':				return 9 ; 	
			case 'gwint_card_ciri':					return 10; 	
			case 'gwint_card_triss':				return 11; 	
			case 'gwint_card_dandelion':			return 12;	
			case 'gwint_card_zoltan':				return 13; 	
			case 'gwint_card_emiel':				return 14; 	
			case 'gwint_card_villen':				return 15; 	
			case 'gwint_card_avallach':				return 16;
			case 'gwint_card_olgierd':				return 17;
			case 'gwint_card_mrmirror':				return 18;
			case 'gwint_card_mrmirror_foglet':		return 19;
			case 'gwint_card_cow':					return 20;
			default: return 0;
		}
	}
	
	public function GwentSpecialNameToInt( val : name ) :int
	{
		switch ( val )
		{
			case 'gwint_card_dummy':				return 0 ; 
			case 'gwint_card_horn':					return 1 ; 
			case 'gwint_card_scorch':				return 2 ; 
			case 'gwint_card_frost':				return 3 ; 
			case 'gwint_card_fog':					return 4 ; 
			case 'gwint_card_rain':					return 5 ; 
			case 'gwint_card_clear_sky':			return 6 ; 
			default: return 0;
		}
	}
}
