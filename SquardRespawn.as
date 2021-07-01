const int iMenuStayTime = 10;
array<CTextMenuPair> aryPlayerMenu(33);
array<CSpawnPos@> aryPlayerSpawnPos(33);
CScheduledFunction@ pSchedule;
class CTextMenuPair{
    CTextMenu@ mMenu;
    CTextMenu@ subMenu;
    void Unregister(){
        if(mMenu !is null)
            mMenu.Unregister();
        if(subMenu !is null)
            subMenu.Unregister();
    }
}
class CSpawnPos{
    float x;
    float y;
    float z;
    float a;
    Vector origin;
    CSpawnPos(Vector vecPos, Vector vecAng){
        x = vecPos.x;
        y = vecPos.y;
        z = vecPos.z;
        a = vecAng.y;
        origin = vecPos;
    }
}
void PluginInit(){
    g_Module.ScriptInfo.SetAuthor("Dr.Abc");
    g_Module.ScriptInfo.SetContactInfo("12345677654321");
    g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @Killed);
}
void MapInit(){
    g_Scheduler.RemoveTimer(@pSchedule);
    for(uint i = 0; i < 33; i++){
        if(aryPlayerMenu[i] !is null)
                aryPlayerMenu[i].Unregister();
    }
    aryPlayerSpawnPos = array<CSpawnPos@>(33);
    @pSchedule = g_Scheduler.SetInterval( "RefreshPos", 2, g_Scheduler.REPEAT_INFINITE_TIMES );
    g_SoundSystem.PrecacheSound("items/r_item1.wav");
}
void RefreshPos(){
    for (int i = 0; i <= g_Engine.maxClients; i++){
        CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if(pPlayer !is null && pPlayer.IsConnected() && pPlayer.IsAlive() )
            @aryPlayerSpawnPos[pPlayer.entindex()] = CSpawnPos(pPlayer.pev.origin, pPlayer.pev.angles);
    }
}
void MainMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
    if(mItem !is null && pPlayer !is null && !pPlayer.IsAlive()){
        CBasePlayer@ tPlayer = g_PlayerFuncs.FindPlayerByName(mItem.m_szName);
        if (tPlayer !is null && tPlayer.IsAlive()){
            CTextMenu@ pMenu = aryPlayerMenu[pPlayer.entindex()].subMenu;
            if(pMenu !is null)
                pMenu.Unregister();
            @pMenu = CTextMenu(SubMenuRespond);
            pMenu.AddItem("Yes", null);
            pMenu.AddItem("No", null);
            pMenu.SetTitle("Confirm respawn to the player?\n"+tPlayer.entindex());
            pMenu.Register();
            @aryPlayerMenu[pPlayer.entindex()].subMenu = pMenu;
            pMenu.Open(iMenuStayTime, 0, pPlayer);
        }
    }
}
void SubMenuRespond(CTextMenu@ mMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ mItem){
    if(mItem !is null && pPlayer !is null && !pPlayer.IsAlive()){
        if(mItem.m_szName == "Yes"){
            CSpawnPos@ pPos = aryPlayerSpawnPos[atoi(mMenu.GetTitle().SubString(32))];
            if(pPos !is null)
                g_Scheduler.SetTimeout("ForceSpawn", pPlayer.m_flRespawnDelayTime + 5 - (g_Engine.time - pPlayer.m_fDeadTime), EHandle(pPlayer), @pPos);
                
        }
        else
            aryPlayerMenu[pPlayer.entindex()].mMenu.Open(iMenuStayTime, 0, pPlayer);
    }
}
void ForceSpawn(EHandle hPlayer, CSpawnPos@ pPos){
    if(hPlayer.IsValid() && pPos !is null){
        CBasePlayer@ pPlayer = cast<CBasePlayer@>(hPlayer.GetEntity());
        g_PlayerFuncs.RespawnPlayer(@pPlayer, true, true);
        pPlayer.pev.origin = pPos.origin;
        pPlayer.pev.angles.y = pPos.a;
        pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;
        NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
        m.WriteByte(TE_IMPLOSION);
            m.WriteCoord(pPlayer.pev.origin.x);
            m.WriteCoord(pPlayer.pev.origin.y);
            m.WriteCoord(pPlayer.pev.origin.z);
            m.WriteByte(64);
            m.WriteByte(24);
            m.WriteByte(5);
        m.End();
        NetworkMessage t(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
            t.WriteByte(TE_TELEPORT);
            t.WriteCoord(pPlayer.pev.origin.x);
            t.WriteCoord(pPlayer.pev.origin.y);
            t.WriteCoord(pPlayer.pev.origin.z);
        t.End();
        g_SoundSystem.PlaySound(pPlayer.edict(), CHAN_STATIC, "items/r_item1.wav", 1.0f, 1.0f, 0, 100);
    }
}
HookReturnCode Killed( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib ){
    if(g_SurvivalMode.IsActive() || pPlayer is null || !pPlayer.IsNetClient())
        return HOOK_CONTINUE;
    @aryPlayerSpawnPos[pPlayer.entindex()] = null;
    CTextMenu@ pMenu = aryPlayerMenu[pPlayer.entindex()].mMenu;
    if(pMenu !is null)
        pMenu.Unregister();
    @pMenu = CTextMenu(MainMenuRespond);
    for (int i = 0; i <= g_Engine.maxClients; i++){
        CBasePlayer@ tPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
        if(tPlayer !is null && tPlayer.IsConnected() && 
            tPlayer.IsAlive() && @pPlayer !is @tPlayer &&
            aryPlayerSpawnPos[tPlayer.entindex()] !is null)
            pMenu.AddItem(tPlayer.pev.netname, null);
    }
    pMenu.SetTitle("[Set Spawn Leader]");
    pMenu.AddItem("\rDefault Spawn", null);
    pMenu.Register();
    @aryPlayerMenu[pPlayer.entindex()].mMenu = pMenu;
    pMenu.Open(iMenuStayTime, 0, pPlayer);
    return HOOK_CONTINUE;
}