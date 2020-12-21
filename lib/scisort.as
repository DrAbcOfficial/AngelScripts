//科学家排序
array<int> aryTest = {5, 1, 19, 54, 231, 91, 56, 25, 77, 3, 23, 44, 68, 125};
array<CBaseEntity@> aryScientists = {};
array<int> aryOut = {};
CScheduledFunction@ pSchedule = null;
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "DrAbc" );
	g_Module.ScriptInfo.SetContactInfo( "Dr.Abc@foxmail.com" );
}

void MapInit()
{
    g_Game.PrecacheOther("monster_scientist");
}

CClientCommand g_HelloWorld("hello", "Hello", @helloword);
void helloword(const CCommand@ pArgs) 
{
    InitScientist(aryTest);
}

void StartHarm()
{
    g_Log.PrintF("排序开始\n");
	@pSchedule = g_Scheduler.SetInterval("DoHarm", 0.001, g_Scheduler.REPEAT_INFINITE_TIMES);
}

void DoHarm()
{
    for(uint i = 0; i < aryScientists.length(); i++)
    {
        if(!aryScientists[i].IsAlive())
        {
            aryOut.insertLast(aryScientists[i].pev.gamestate);
            g_EntityFuncs.Remove(aryScientists[i]);
            aryScientists.removeAt(i);
        }
        else
        {
            aryScientists[i].TakeDamage(aryScientists[i].pev, aryScientists[i].pev, 0.1, 0);
            g_PlayerFuncs.ClientPrintAll(HUD_PRINTCONSOLE, string(aryScientists[i].pev.health));
        }
    }
    if(aryScientists.length() <= 1)
    {
        g_Scheduler.RemoveTimer(pSchedule);
        if(aryScientists.length() == 1)
            aryOut.insertLast(aryScientists[0].pev.gamestate);
        string szTemp = "\n排序结果:\n";
        for(uint i = 0; i < aryOut.length(); i++)
        {
            szTemp += string(aryOut[i]) + ",";
        }
        g_Log.PrintF(szTemp + "\n");
    }
}

void InitScientist(array<int>&in aryBeSort)
{
    g_Log.PrintF("排序初始化开始\n");
    string szTemp = ""; 
    for(uint i = 0; i < aryBeSort.length(); i++)
    {
        CBaseEntity@ pEntity = g_EntityFuncs.Create("monster_scientist", Vector(-522, 732, -1616), g_vecZero, false);
        pEntity.pev.gamestate = aryBeSort[i];
        pEntity.pev.max_health = pEntity.pev.health = float(aryBeSort[i]);
        aryScientists.insertLast(pEntity);
        szTemp += string(aryBeSort[i]) + ",";
    }
    g_Log.PrintF("待排序数组" + szTemp + "\n");
    g_Scheduler.SetTimeout("StartHarm", 1);
}
