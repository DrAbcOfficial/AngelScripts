void PluginInit(){
	g_Module.ScriptInfo.SetAuthor("哈哈哈");
	g_Module.ScriptInfo.SetContactInfo("哈哈哈哈哈哈哈哈哈哈哈哈");
	g_Hooks.RegisterHook(Hooks::Game::EntityCreated, @EntityCreated);
    g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientPutInServer);
    g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
}

void MapActivate(){
	@aryName = {};
    CBaseEntity@ pMonster = null;
    while((@pMonster = g_EntityFuncs.FindEntityByClassname(pMonster, "monster_*")) !is null){
        ChangeName(@pMonster, true);
    }
}

array<string>@ aryRndName = {
    "英国大力士", "美国大力士", "德国大力士", "俄国大力士", "泰国大力士", "马宝国老师", "管理员", "摇摆羊", "SC Administrator",
    "智力担当", "大陀螺", "我卢本伟没开挂", "核心选手", "网络监察", "强尼手银", "强尼黑手", "CJ", "The train u followed",
    "Deep dark fantasy artist", "榴弹哥", "手雷哥", "苗苗乐", "可可爱爱", "一颗手雷十三个敌人", "ＷＩＤＥ　ＰＵＴＩＮ", "Server Owner", 
    "没有人", "苗苗秃", "miaonei", "力の金阁", "技の银阁", "动の铜阁", "守の铁阁", "大名鼎鼎的V", "流汗黄豆人", "RRTS Chun", "L40_M3N9", 
    "黄豆流汗人", "你背后有头屑", "巨型牛牛", "小型唧唧", "孙笑川258", "垃圾桶战神", 
    "铲子杀人魔", "叉子杀人魔", "勺子杀人魔", "筷子杀人魔", "锹子杀人魔", "瓶子杀人魔", "牛子杀人魔", 
    "夜光閃亮亮復仇鬼", "just monika", "苇名黑心", "赛文奥特曼", "恶 魔 人", "喷香碳烤夜雀", "乐狗", "牛牛光波", "弔之弔人", "屑王之王", "弔名小王子",
    "新墨西哥沙漠大力士", "不要谐音咪咪", "dead game"
};

array<string>@ aryName = {};
HookReturnCode ClientPutInServer( CBasePlayer@ pPlayer ){
    for(uint i = 0; i < aryName.length();i++){
    	if(aryName[i] == pPlayer.pev.netname)
    		return HOOK_CONTINUE;
    }
    aryName.insertLast(pPlayer.pev.netname);
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect( CBasePlayer@ pPlayer ){
    for(uint i = 0; i < aryName.length();i++){
    	if(aryName[i] == pPlayer.pev.netname){
    		aryName.removeAt(i);
    		return HOOK_CONTINUE;
    	}
    }
    aryName.insertLast(pPlayer.pev.netname);
	return HOOK_CONTINUE;
}

void ChangeName(CBaseEntity@ pEntity, bool bForce = false){
    if(string(pEntity.pev.classname).StartsWith("monster_")){
        CBaseMonster@ pMonster = cast<CBaseMonster@>(@pEntity);
        if(@pMonster !is null && (bForce || string(pMonster.m_FormattedName).IsEmpty())){
            if(Math.RandomLong(0,2) < 2 || aryName.length() <= 0)
                pMonster.m_FormattedName = aryRndName[Math.RandomLong(0, aryRndName.length()-1)];
            else
                pMonster.m_FormattedName = aryName[Math.RandomLong(0, aryName.length()-1)];
        }
    }
}

HookReturnCode EntityCreated( CBaseEntity@ pEntity ){
    ChangeName(@pEntity);
    return HOOK_CONTINUE;
}