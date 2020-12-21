const array<string> m_aryPiHua = 
{
    "没吃饭吗？",
    "你怎么回事小老弟",
    "呵呵",
    "嘻嘻",
    "？？",
    "¿",
    "哇哦",
    "打的不错",
    "谢谢",
    "Go to Play COD",
    "低难度可能更适合你一点",
    "笨逼",
    "蔡",
    "你玩SC像蔡徐坤",
    "你没事了"
};

const dictionary m_dicPiHua = 
{
    { "monster_barnacle", array<string> = {"你吃起来很美味 :P"} }
};

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("Dr.Abc");
    g_Module.ScriptInfo.SetContactInfo("?");
    g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @Killed);
}

HookReturnCode Killed( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
    if(pPlayer is null)
        return HOOK_HANDLED;
    if(!pPlayer.IsNetClient())
        return HOOK_HANDLED;
    if(pAttacker is null)
        return HOOK_HANDLED;
    if(pAttacker.IsPlayer())
        return HOOK_HANDLED;
    if(pAttacker.IsNetClient())
        return HOOK_HANDLED;
    if(!pAttacker.IsMonster())
        return HOOK_HANDLED;
    
    CBaseMonster@ pMonster = cast<CBaseMonster@>(pAttacker);
    string szAttname = string(pMonster.m_FormattedName);
    
    array<string>aryCache;
    if(m_dicPiHua.exists(pMonster.GetClassname()))
        aryCache = aryAdd(m_aryPiHua, cast<array<string>>(m_dicPiHua[pMonster.GetClassname()]));
    else  
        aryCache = m_aryPiHua;

    uint rnd = Math.RandomLong(0, aryCache.length() - 1 );
    g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, szAttname + ": " + aryCache[rnd]);
    return HOOK_HANDLED;
}

array<string> aryAdd(array<string>&in ary1, array<string>&in ary2)
{
    array<string> cache = ary1;
    for(uint i = 0; i < ary2.length(); i++)
    {
        cache.insertLast(ary2[i]);
    }
    return cache;
}
