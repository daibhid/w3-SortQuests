/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3LevelManager
{
	private var owner : W3PlayerWitcher;
	private saved var levelDefinitions : array< SLevelDefinition >;		
	private saved var level : int;									
	private saved var points : array< SSpendablePoints >;			
	
	public function Initialize()
	{
		var tmp : SSpendablePoints;
		var i : int;
		
		tmp.free = 0;
		tmp.used = 0;
			
		for(i=0; i<=EnumGetMax('ESpendablePointType'); i+=1)
			points.PushBack(tmp);
	}
	
	public function PostInit(own : W3PlayerWitcher, bFromLoad : bool)
	{
		owner = own;
				
		if(!bFromLoad)
		{	
			LoadLevelingDataFromXML();
			level = levelDefinitions[0].number;		
		}
	}
	
	public final function ResetCharacterDev()
	{
		var i : int;
		
		for(i=0; i<points.Size(); i+=1)
		{
			points[i].free += points[i].used;
			points[i].used = 0;
		}
	}
	
	
	private function LoadLevelingDataFromXML()
	{	
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var i, temp : int;
		var levelDef : SLevelDefinition;
		var tmpLevels : array<int>;
							
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('leveling');
		
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'number', temp);	
			tmpLevels.PushBack(temp);
		}
		
		ArraySortInts(tmpLevels);
		for(i=1; i<tmpLevels.Size()-1; i+=1)
		{
			if(tmpLevels[i-1]+1 != tmpLevels[i])
			{
				LogAssert(false,"W3LevelManager.LoadLevelingDataFromXML: There is a gap in levels definitions - between levels " + tmpLevels[i-1] + " and " + tmpLevels[i]);
				return;
			}
		}
		
		
		LogChannel('Leveling',"W3LevelManager.LoadLevelingDataFromXML: min level is " + tmpLevels[0] + ", max level is " + tmpLevels[tmpLevels.Size()-1]);
		
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'number', temp);				
			levelDef.number = temp;
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'requiredTotalExp', temp);
			levelDef.requiredTotalExp = temp;
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'addedSkillPoints', temp);			
			levelDef.addedSkillPoints = temp;
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'addedMutationPoints', temp);
			levelDef.addedMutationPoints = temp;
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'addedKnowledgePoints', temp);
			levelDef.addedKnowledgePoints = temp;
			
			levelDefinitions.PushBack(levelDef);
		}
	}
	
	public function SetFreeSkillPoints(amount : int)
	{
		points[ESkillPoint].free = amount;
	}
	
	public function FixMaxLevel()
	{
		var i : int;
		
		
		if(points[EExperiencePoint].used >= levelDefinitions[GetMaxLevel()].requiredTotalExp)
		{
			level = GetMaxLevel();
			points[EExperiencePoint].free = 0;
			
			i = 0;
			while( levelDefinitions[i].number != level )
			{
				i+=1;
			}
			points[EExperiencePoint].used = levelDefinitions[i].requiredTotalExp;
		}
		else if(level == GetMaxLevel())
		{
			points[EExperiencePoint].free = 0;
		}
	}
	
	
	public function AddPoints(type : ESpendablePointType, amount : int, show : bool )
	{
		var total : int;
		var arrInt : array<int>;
		var hudWolfHeadModule : CR4HudModuleWolfHead;		
		var hud : CR4ScriptedHud;
		hud = (CR4ScriptedHud)theGame.GetHud();
	
		if(amount <= 0)
		{
			LogAssert(false, "W3LevelManager.AddPoints: amount of <<" + type + ">> is <= 0 !!!");
			return;
		}
		
		
		if(type == EExperiencePoint && level >= GetMaxLevel())
			return;
			 
		points[type].free += amount;

		if(type == EExperiencePoint)
		{
			
			if(FactsQuerySum("NewGamePlus") > 0 && GetLevel() < 50)
			{
				points[type].free += amount;
				amount *= 2;
			}
			
			
			while(true)
			{
				total = GetTotalExpForNextLevel();
				if(total > 0 && GetPointsTotal(EExperiencePoint) >= total)
				{
					GainLevel( true );
					GetWitcherPlayer().AddAbility( GetWitcherPlayer().GetLevelupAbility( GetWitcherPlayer().GetLevel() ) );
				}
				else
					break;
			}
			
			if(level == GetMaxLevel())
			{
				points[type].free = 0;
			}
		
			theTelemetry.LogWithValue(TE_HERO_EXP_EARNED, amount);
			
			arrInt.PushBack(amount);
			
			
			hud.OnExperienceUpdate(amount, show);
		}
		else if(type == ESkillPoint)
		{
			theTelemetry.LogWithValue(TE_HERO_SKILL_POINT_EARNED, amount);
			
			
			hudWolfHeadModule = (CR4HudModuleWolfHead)hud.GetHudModule( "WolfHeadModule" );
			if ( hudWolfHeadModule )
			{
				hudWolfHeadModule.ShowLevelUpIndicator(show);
			}
		}
	}
	
	
	public function SpendPoints(type : ESpendablePointType, amount : int)
	{
		if(amount <= 0)
		{
			LogAssert(false, "W3LevelManager.SpendPoints: amount to spend is <=0");
			return;
		}
		if( points[type].free >= amount )
		{
			points[type].free -= amount;
			points[type].used += amount;
		}
		else
		{
			LogAssert(false, "W3LevelManager.SpendPoints: trying to spend more than you have!");
		}
	}
	
	
	public final function UnspendPoints(type : ESpendablePointType, amount : int)
	{
		if(amount <= 0)
		{
			LogAssert(false, "W3LevelManager.UnspendPoints: amount to restore is <=0");
			return;
		}
		if( points[type].used >= amount )
		{
			points[type].free += amount;
			points[type].used -= amount;
		}
		else
		{
			LogAssert(false, "W3LevelManager.UnspendPoints: trying to restore more than you have spent!");
		}
	}
	
	public function GetPointsFree(type : ESpendablePointType) : int			{return points[type].free;}	
	public function GetPointsUsed(type : ESpendablePointType) : int			{return points[type].used;}
	public function GetPointsTotal(type : ESpendablePointType) : int		{return points[type].free + points[type].used;}
	public function GetLevel() : int										{return level;}
	public function GetMaxLevel() : int										{return 70;}

	
	public function GetTotalExpForCurrLevel() : int
	{
		if ( level > 0 )
			return levelDefinitions[ level - 1 ].requiredTotalExp;
		else
			return 0;
	}
	
	
	public function GetTotalExpForNextLevel() : int							
	{
		if(level < levelDefinitions[levelDefinitions.Size()-1].number)
			return levelDefinitions[level].requiredTotalExp;
		else
			return -1;
	}
		
	public function GainLevel( show : bool )
	{
		var totalExp : int;
	
		if(level == GetMaxLevel())
		{
			LogAssert(false, "W3LevelManager.GainLevel: already at max level, so why trying to gain a level?");
			return;
		}
		
		level += 1;
		
		totalExp = points[EExperiencePoint].used + points[EExperiencePoint].free;
		points[EExperiencePoint].used = levelDefinitions[level].requiredTotalExp;
		points[EExperiencePoint].free = totalExp - points[EExperiencePoint].used;
		
		theTelemetry.LogWithValue(TE_HERO_LEVEL_UP, level);
		
		if(levelDefinitions[level].addedSkillPoints > 0)
			AddPoints(ESkillPoint, levelDefinitions[level].addedSkillPoints, show);
			
		owner.OnLevelGained(level, show);
	}
	
	public function AutoLevel()
	{
		var dm 									: CDefinitionsManagerAccessor;
		var main 								: SCustomNode;
		var skills 								: array<SSkill>;
		var skillType							: ESkill;
		var i, priority, freePoints, tmpInt		: int;
		var tmpName								: name;
		var type								: ESpendablePointType;
		
		skills = thePlayer.GetPlayerSkills();
		dm = theGame.GetDefinitionsManager();
		type = ESkillPoint;
		
		freePoints = GetPointsFree( type );
		tmpInt = 1;
		
		for( i=0; i<skills.Size(); i+=1 )
		{
			dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'priority', priority);
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'skill_name', tmpName);
			skillType = SkillNameToEnum(tmpName);
			
			if( freePoints > 0 && GetWitcherPlayer().CanLearnSkill( skills[i].skillType ) && priority == tmpInt )
			{
				tmpInt += 1;
				GetWitcherPlayer().AddSkill(skills[i].skillType, true);
				skills.Erase(i);
			}			
		}
	}
}