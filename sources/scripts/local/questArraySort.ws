
enum GroupOrder {
	GROUP_Main = 0,
	GROUP_Secondary = 1,
	GROUP_Witcher = 2,
	GROUP_Treasure = 3,
	GROUP_Completed = 4,
	GROUP_Failed = 5,
}

function SortedAdd( 
	targetQuest : CJournalQuest, 
	out sortedQuestsMap  : array<array<CJournalQuest>>, 
	out sortedQuestLevels : array<array<int>>, 
	currentQuest : CJournalQuest)
{
	var j						: int;
	var questLevels 			: C2dArray;
	var iterQuestLevels			: int;
	var questLevelsCount		: int;
	var questCount				: int;
	var questLevel				: int;
	var questName				: string;
	var group					: int;
	
	questLevelsCount 	= theGame.questLevelsContainer.Size();		
	questLevel = 0;

	// Resolve quest level
	questName = "";
	questLevel = GetQuestLevel(targetQuest);
	group = GetQuestGroup(targetQuest);
	
	if(sortedQuestsMap.Size() == 0)
	{
		Setup2DArray(sortedQuestsMap, sortedQuestLevels);
	}
	
	if(sortedQuestsMap[group].Size() == 0)
	{
		sortedQuestsMap[group].PushBack(targetQuest);
		sortedQuestLevels[group].PushBack(questLevel);
	}
	else if(targetQuest == currentQuest)
	{
		sortedQuestsMap[group].Insert(0, targetQuest);
		sortedQuestLevels[group].Insert(0, -1);
	}
	else
	{
		// Iterate through array and add
		for( j = 0; j < sortedQuestsMap[group].Size(); j += 1)
		{
			if(sortedQuestLevels[group][j] > questLevel )
			{
				sortedQuestsMap[group].Insert(j, targetQuest);
				sortedQuestLevels[group].Insert(j, questLevel);
				return;
			}
		}
		sortedQuestsMap[group].PushBack(targetQuest);
		sortedQuestLevels[group].PushBack(questLevel);
		return;
	}
}

function GetQuestLevel(targetQuest : CJournalQuest) : int
{
	var j						: int;
	var questLevels 			: C2dArray;
	var iterQuestLevels			: int;
	var questLevelsCount		: int;
	var questCount				: int;
	var questLevel				: int;
	var questName				: string;

	questLevelsCount 	= theGame.questLevelsContainer.Size();		
	questLevel = 0;

	// Resolve quest level
	questName = "";
	for( iterQuestLevels = 0; iterQuestLevels < questLevelsCount; iterQuestLevels += 1 )
	{
		questLevels = theGame.questLevelsContainer[iterQuestLevels];			
		questCount = questLevels.GetNumRows();
		for( j = 0; j < questCount; j += 1 )
		{
			questName  = questLevels.GetValueAtAsName(0,j);
			if ( questName == targetQuest.baseName )
			{
				questLevel = NameToInt( questLevels.GetValueAtAsName(1,j) );
				
				if(FactsQuerySum("NewGamePlus") > 0)
				{
					questLevel += theGame.params.GetNewGamePlusLevel();
				}
				return questLevel;
			}
		}
	}
	return questLevel;
}
	
function GetQuestGroup(targetQuest : CJournalQuest) : int
{
	var eStatus : EJournalStatus;
	eStatus = theGame.GetJournalManager().GetEntryStatus(targetQuest);

	switch(eStatus)
	{
	case JS_Active:
	case JS_Inactive:
		switch(targetQuest.GetType())
		{
		case Story :
			return GROUP_Main;
		case Side :
			return GROUP_Secondary;
		case MonsterHunt :
			return GROUP_Witcher;
		case TreasureHunt :
			return GROUP_Treasure;
		
		}
	case JS_Success:
		return GROUP_Completed;
	case JS_Failed:
		return GROUP_Failed;
	}
	return GROUP_Failed;
}

function Setup2DArray(out sortedQuestsMap  : array<array<CJournalQuest>>, out sortedQuestLevels : array<array<int>>)
{
	var i : int;
	var newArrayOfQuests : array<CJournalQuest>;
	var newArrayOfInts : array<int>;
	for(i = 0; i <= GROUP_Failed; i += 1 )
	{
		sortedQuestsMap.PushBack(newArrayOfQuests);
		sortedQuestLevels.PushBack(newArrayOfInts);
	}
} 

function Sort2DArray(inputArray : array<array<CJournalQuest>>, out sortedArray : array<CJournalQuest>)
{
	var i: int;
	var j: int;
	for(i = 0; i < inputArray.Size(); i += 1)
	{
		for(j = 0; j < inputArray[i].Size(); j += 1)
		{
			sortedArray.PushBack(inputArray[i][j]);
		}
	}
	
}