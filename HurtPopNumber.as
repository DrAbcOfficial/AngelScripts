/**
    num.spr 11 frames
    0-10
    0 1 2 3 4 5 6 7 8 9 0 +
    64x96 | Black background | Addictive
**/
/**
    healthbar.spr 11 frame
    0-10
    full health -> 0 health
    128x16 | Black background | Addictive
**/
//Pop number path
const string szModel = "sprites/misc/num.spr";
//Pop number scale
const float flScale = 0.1;
//Pop number offset
const float flOffset = 8.0;
//Pop number noise
const float flPopUpNoise = 8;

const bool bEnableHealthBar = true;
const float flHealthBarScale = 0.2;
const float flHealthBarOffset = 8.0;
const Vector vecStandardSize = VEC_HUMAN_HULL_MAX - VEC_HUMAN_HULL_MIN;
//Class bar style
const array<CMonsterHeathBarItem@> aryHealthBar = {
    //None
    CMonsterHeathBarItem(RGBA(80, 80 ,80, 255), "sprites/misc/healthbar.spr"),
    //Machine
    CMonsterHeathBarItem(RGBA(80, 80 ,80, 255), "sprites/misc/healthbar.spr"),
    //Player
    CMonsterHeathBarItem(RGBA(0, 255 ,0, 255), "sprites/misc/healthbar.spr"),
    //Human passive
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
    //Human military
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
     //Alien military
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
    //Alien passive
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
    //Alien monster
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
    //Alien prey
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
    //Alien predator
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
    //Insect
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
    //Player ally
    CMonsterHeathBarItem(RGBA(76, 255 ,0, 255), "sprites/misc/healthbar.spr"),
    //Player bio weapon
    CMonsterHeathBarItem(RGBA(0, 125 ,0, 255), "sprites/misc/healthbar.spr"),
    //Alien bio weapon
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
    //Race X (pit drone)
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
    //Race X (shock)
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
    //Team 1
    CMonsterHeathBarItem(RGBA(255, 0 ,0, 255), "sprites/misc/healthbar.spr"),
    //Team 2
    CMonsterHeathBarItem(RGBA(0, 0 ,255, 255), "sprites/misc/healthbar.spr"),
    //Team 3
    CMonsterHeathBarItem(RGBA(0, 255 ,0, 255), "sprites/misc/healthbar.spr"),
    //Team 4
    CMonsterHeathBarItem(RGBA(255, 255 ,0, 255), "sprites/misc/healthbar.spr")
};

const array<string> aryIgnoreMonster = {
    "monster_generic",
    "monster_rat",
    "monster_satchel",
    "monster_shockroach",
    "monster_snark",
    "monster_sqknest",
    "monster_tripmine",
    "monster_scientist_dead",
    "monster_otis_dead",
    "monster_leech",
    "monster_human_grunt_ally_dead",
    "monster_grunt_ally_medic_dead",
    "monster_grunt_ally_torch_dead",
    "monster_tentacle",
    "monster_tentaclemaw",
    "monster_flyer_flock",
    "monster_flyer"
    "monster_hgrunt_dead",
    "monster_hevsuit_dead",
    "monster_handgrenade",
    "monster_gman",
    "monster_furniture",
    "monster_flyer_flock",
    "monster_cockroach",
    "monster_bloater",
    "monster_osparey",
    "monster_apache",
    "monster_barney_dead",
    "monster_babycrab",
    "monster_barnacle"
};

const array<string> aryIgnoreMap = {
    "sc5x_bonus"
};
class CMonsterHeathBarItem{
    RGBA Color;
    string Spr;
    CMonsterHeathBarItem(RGBA&in c, string&in s){
        this.Color = c;
        this.Spr = s;
    }
}
array<CHandleMonster@> aryHandle;
CScheduledFunction@ pHeathbarthink;
void PluginInit(){
    g_Module.ScriptInfo.SetAuthor("蒂洛阿伯斯");
    g_Module.ScriptInfo.SetContactInfo("弱小的阿伯斯不懂");
}

void MapInit(){
    //清空缓存
    g_Scheduler.RemoveTimer(@pHeathbarthink);
    aryHandle = {};

    if(aryIgnoreMap.find(g_Engine.mapname) > -1)
        return;
    g_Game.PrecacheModel( szModel );
    g_Game.PrecacheGeneric( szModel );
    if(bEnableHealthBar)
    {
        for(uint i = 0; i < aryHealthBar.length(); i++){
            g_Game.PrecacheModel( aryHealthBar[i].Spr );
            g_Game.PrecacheGeneric( aryHealthBar[i].Spr );
        }
    }
    //怪物的思考大概是0.07s
    @pHeathbarthink = g_Scheduler.SetInterval("CheckMonster", 0.07, g_Scheduler.REPEAT_INFINITE_TIMES);
}
/**
    0 1 2 3 4
    q b s g +
**/
array<EHandle> IntToModels(int t, Vector vecOrigin, RGBA rgbColor = RGBA(255, 255, 255, 255)){
    t = Math.clamp(0, 9999, t);
    array<EHandle> aryTemp(5);
    array<int> aryNum = {
        int(t/1000),
        int(t/100) % 10,
        int(t/10) % 100 % 10,
        t % 1000 % 100 % 10,
        10
    };
    array<Vector> aryVector(5);
    for(uint i = 0; i < 5;i++){
        aryVector[i] = vecOrigin + g_Engine.v_right * (flOffset * int(i));
    }
    bool bNonZero = false;
    for(uint i = 0; i < 5;i++){
        if(aryNum[i] > 0 && !bNonZero)
            bNonZero = true;
        if(bNonZero){
            if(i == 4 && t < 9999)
                continue;
            CSprite@ pSpr = g_EntityFuncs.CreateSprite(szModel, aryVector[i], false);
            pSpr.pev.framerate = 0;
            pSpr.pev.frame = aryNum[i];
            pSpr.pev.scale = flScale;
            pSpr.SetTransparency(kRenderTransAdd, rgbColor.r, rgbColor.g, rgbColor.b, rgbColor.a, kRenderFxNone);
            pSpr.pev.movetype = MOVETYPE_NOCLIP;
            pSpr.pev.solid = SOLID_NOT;
            pSpr.pev.velocity = Vector(0, 0, 25);
            pSpr.Expand(-0.08f, 300.0f);
            aryTemp[i] = pSpr;
        }
    }
    return aryTemp;
}
class CHandleMonster{
    private Vector vecPos;
    EHandle Monster;
    private float oldHealth;

    private EHandle Spr;
    private float flSprScale;
    Vector Pos{
        get { return Monster.IsValid() ? Monster.GetEntity().Center() + g_Engine.v_up * 16 : vecPos;}
        set{ vecPos = value + g_Engine.v_up * 16;}
    }
    Vector HealthBarPos(){
        Vector vecPos = Monster.GetEntity().Center();
        vecPos.z = (Monster.GetEntity().pev.absmax + g_Engine.v_up * flHealthBarOffset * flSprScale).z;
        return vecPos;
    }

    MONSTERSTATE GetMonsterState(){
        if(!Monster.IsValid())
            return MONSTERSTATE_NONE;
        CBaseMonster@ pMonster = cast<CBaseMonster@>(Monster.GetEntity());
        if(pMonster is null)
            return MONSTERSTATE_NONE;
        return pMonster.m_MonsterState;
    }
    bool IsValid{
        get { return Monster.IsValid() ? Monster.GetEntity().IsAlive() : false;}
    }
    bool IsHealthBarValid(){
        return Spr.IsValid();
    }

    void InitHealthBar(){
        if(!Monster.IsValid())
            return;
        flSprScale = (Monster.GetEntity().pev.size.x / vecStandardSize.x + Monster.GetEntity().pev.size.y / 
            vecStandardSize.y + Monster.GetEntity().pev.size.z / vecStandardSize.z) / 3;

        int iClassify = Math.clamp(0, aryHealthBar.length(), Monster.GetEntity().Classify());
        RGBA rgbColor = aryHealthBar[iClassify].Color;
        string szHealthBarModel = aryHealthBar[iClassify].Spr;
        CSprite@ pSpr = g_EntityFuncs.CreateSprite(szHealthBarModel, HealthBarPos(), false);
        pSpr.pev.framerate = 0;
        pSpr.pev.frame = 0;
        pSpr.pev.scale = flHealthBarScale * flSprScale;
        pSpr.SetTransparency(kRenderTransAdd, rgbColor.r, rgbColor.g, rgbColor.b, rgbColor.a, kRenderFxNone);
        pSpr.pev.movetype = MOVETYPE_NOCLIP;
        pSpr.pev.solid = SOLID_NOT;
        Spr = pSpr;
    }
    CHandleMonster (CBaseEntity@ pMonster){
        Monster = pMonster;
        Pos = pMonster.Center() + g_Engine.v_up * 16;
        oldHealth = pMonster.pev.health;
    }
    void CheckHealth(){
        float reduce = 0;
        RGBA color = RGBA(255, 255, 255, 255);
        if(!IsValid){
            reduce = oldHealth;
            color = RGBA(255, 0, 0, 255);
            if(bEnableHealthBar)
                g_EntityFuncs.Remove(Spr.GetEntity());
        }
        else{
            reduce = oldHealth - Monster.GetEntity().pev.health;
            oldHealth = Monster.GetEntity().pev.health;
            if(reduce > Monster.GetEntity().pev.max_health * 0.33)
                color = RGBA(255, 0, 0, 255);
            if(bEnableHealthBar && Spr.IsValid()){
                Spr.GetEntity().pev.origin = HealthBarPos();
                Spr.GetEntity().pev.frame = int(Monster.GetEntity().pev.health / Monster.GetEntity().pev.max_health * 10);
            }
        }
        if(int(reduce) > 0)
            IntToModels(int(reduce), Pos + Vector(Math.RandomFloat(-flPopUpNoise, flPopUpNoise), 
                Math.RandomFloat(-flPopUpNoise, flPopUpNoise), Math.RandomFloat(-flPopUpNoise, flPopUpNoise)), color);
    }
    bool opEquals(CHandleMonster@ pHandle){
        return pHandle.Monster.GetEntity() is this.Monster.GetEntity();
    }
    bool opEquals(CBaseEntity@ pHandle){
        return pHandle is this.Monster.GetEntity();
    }
}
int findIndex(CBaseEntity@ pMonster){
    for(uint i = 0; i < aryHandle.length();i++){
        if(aryHandle[i] == pMonster)
            return i;
    }
    return -1;
}
void CheckMonster(){
    CBaseEntity@ pMonster = null;
    while((@pMonster = g_EntityFuncs.FindEntityByClassname(pMonster, "monster_*")) !is null){
        if(aryIgnoreMonster.find(pMonster.pev.classname) > -1)
            continue;
        if(pMonster.IsAlive() && pMonster.IsMonster() && pMonster.pev.takedamage != DAMAGE_NO && pMonster.pev.max_health > 0){
            int iIndex = findIndex(pMonster);
            if(iIndex < 0)
                aryHandle.insertLast(@CHandleMonster(pMonster));
            else if(bEnableHealthBar && !aryHandle[iIndex].IsHealthBarValid() && aryHandle[iIndex].GetMonsterState() > 1 && aryHandle[iIndex].GetMonsterState() < 5)
                aryHandle[iIndex].InitHealthBar();
        }
    }

    for(uint i=0;i<aryHandle.length();i++){
        aryHandle[i].CheckHealth();
        if(!aryHandle[i].IsValid)
            aryHandle.removeAt(i);
    }
}
