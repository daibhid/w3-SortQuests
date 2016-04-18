
function SortedAdd( targetQuest : CJournalQuest, out sortedQuests  : array<CJournalQuest>, out sortedQuestLevels : array<int>)
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
	questLevel = GetQuestLevel(targetQuest);
		
	if(sortedQuests.Size() == 0)
	{
		sortedQuests.PushBack(targetQuest);
		sortedQuestLevels.PushBack(questLevel);
	}
	else
	{
		// Iterate through array and add
		for( j = 0; j < sortedQuests.Size(); j += 1)
		{
			if(sortedQuestLevels[j] > questLevel )
			{
				sortedQuests.Insert(j, targetQuest);
				sortedQuestLevels.Insert(j, questLevel);
				return;
			}
		}
		sortedQuests.PushBack(targetQuest);
		sortedQuestLevels.PushBack(questLevel);
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