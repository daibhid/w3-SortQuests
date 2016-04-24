
enum GroupOrder {
	GROUP_Main = 0,
	GROUP_Secondary = 1,
	GROUP_Witcher = 2,
	GROUP_Treasure = 3,
	GROUP_Failed = 4,
}

function SortedAdd( 
	targetQuest : CJournalQuest, 
	out sortedQuests  : array<CJournalQuest>, 
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
	

	if(sortedQuests.Size() == 0)
	{
		Setup2DArray(sortedQuestsMap, sortedQuestLevels);
	}
	
	if(sortedQuestsMap[group].Size() == 0)
	{
		f2DMapAdd(targetQuest, group, sortedQuests, sortedQuestsMap, 0);
		sortedQuestsMap[group].PushBack(targetQuest);
		sortedQuestLevels[group].PushBack(questLevel);
	}
	else if(targetQuest == currentQuest)
	{
		f2DMapAdd(targetQuest, group, sortedQuests, sortedQuestsMap, 0);
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
				f2DMapAdd(targetQuest, group, sortedQuests, sortedQuestsMap, j);
				sortedQuestsMap[group].Insert(j, targetQuest);
				sortedQuestLevels[group].Insert(j, questLevel);
				return;
			}
		}
		f2DMapAdd(targetQuest, group, sortedQuests, sortedQuestsMap, 0);
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
	return GROUP_Failed;
}

function Setup2DArray(out sortedQuestsMap  : array<array<CJournalQuest>>, out sortedQuestLevels : array<array<int>>)
{
	var i : int;
	//for(i = 0; i < GroupOrder.Size(); i += 1 )
	//{
		//sortedQuestsMap[i] = new array<CJournalQuest>();
		//sortedQuestLevels[i] = new array<int>();
	//}
}

function f2DMapAdd(
	targetQuest : CJournalQuest,
	group : int,
	out sortedQuests  : array<CJournalQuest>, 
	out sortedQuestsMap  : array<array<CJournalQuest>>, 
	targetPosition : int)
{
	var index : int;
	var i : int;
	index = 0;
	for(i = 0; i < group; i+= 1)
	{
		index += sortedQuestsMap[i].Size();
	}
	index += targetPosition;
	
	sortedQuests.Insert(index, targetQuest);
}