//自定义模型路径
const array<CCustomModel@> aryModels = {
	CCustomModel("monster_zombie",  //怪物classname
		"models/zombie.mdl",		//原模型路径
		array<string> = {			//替换目标路径
			"models/bdsc_npc/zombie.mdl",
			"models/bdsc_npc/zombie2.mdl",
			"models/bdsc_npc/zombie_worker.mdl"
		}),
	CCustomModel("monster_zombie_barney", 
		"models/zombiebarney.mdl",
		array<string> = {
			"models/bdsc_npc/zombie_barney.mdl",
			"models/bdsc_npc/zombie_hev.mdl"
		}),
	CCustomModel("monster_zombie_soldier", 
		"models/zombiesoldier.mdl",
		array<string> = {
			"models/bdsc_npc/zombie_barney.mdl"
		})
};

class CCustomModel{
	string szClassName;
	string szOriginPath;
	array<string> aryPaths = {};

	CCustomModel(string c, string o, array<string>@ a){
		szClassName = c;
		szOriginPath = o;
		aryPaths = a;
	}

	void Precache(){
		for(uint i = 0; i < aryPaths.length(); i++){
			g_Game.PrecacheModel(aryPaths[i]);
		}
	}

	string GetModel(){
		return aryPaths[Math.RandomLong(0, aryPaths.length()-1)];
	}
}

CCustomModel@ GetPath(string szClassName){
	for(uint i = 0; i < aryModels.length(); i++){
		if(szClassName == aryModels[i].szClassName)
			return aryModels[i];
	}
	return null;
}

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo("Run gunmp Run");
	g_Hooks.RegisterHook(Hooks::Game::EntityCreated, @EntityCreated);
}

void MapInit(){
	for(uint i = 0; i < aryModels.length(); i++){
		aryModels[i].Precache();
	}
}

void MapStart(){
    CBaseEntity@ pMonster = null;
    while((@pMonster = g_EntityFuncs.FindEntityByClassname(pMonster, "monster_*")) !is null){
        ChangeName(@pMonster);
    }
}

void ChangeName(CBaseEntity@ pEntity){
    if(string(pEntity.pev.classname).StartsWith("monster_zombie") && pEntity.pev.spawnflags & 128 == 0 && pEntity.pev.targetname == ""){
        CBaseMonster@ pMonster = cast<CBaseMonster@>(@pEntity);
        if(@pMonster !is null && !pMonster.m_fCustomModel){
            CCustomModel@ pPath = GetPath(pMonster.pev.classname);
            if(pPath !is null && pPath.szOriginPath != pMonster.pev.model)
            	g_Scheduler.SetTimeout("SetUpModel", 0.01, EHandle(@pMonster), pPath.GetModel());
        }
    }
}

void SetUpModel(EHandle eEntity, string p){
	if(eEntity.IsValid()){
		g_EntityFuncs.SetModel(eEntity.GetEntity(), p);
		g_EntityFuncs.SetSize(eEntity.GetEntity().pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX);
	}
}

HookReturnCode EntityCreated( CBaseEntity@ pEntity ){
    ChangeName(@pEntity);
    return HOOK_CONTINUE;
}