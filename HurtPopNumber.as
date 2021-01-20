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
const string szModel = "sprites/misc/num.spr";
const float flScale = 0.1;
const float flOffset = 8.0;
const float flPopUpNoise = 8;

const bool bEnableHealthBar = true;
const string szHealthBarModel = "sprites/misc/healthbar.spr";
const float flHealthBarScale = 0.2;
const float flHealthBarOffset = 8.0;
const Vector vecStandardSize = VEC_HUMAN_HULL_MAX - VEC_HUMAN_HULL_MIN;

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
array<CHandleMonster@> aryHandle;
void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("蒂洛阿伯斯");
    g_Module.ScriptInfo.SetContactInfo("弱小的阿伯斯不懂");
}

void MapInit()
{
    aryHandle = {};
    g_Game.PrecacheModel( szModel );
    g_Game.PrecacheGeneric( szModel );
    if(bEnableHealthBar)
    {
        g_Game.PrecacheModel( szHealthBarModel );
        g_Game.PrecacheGeneric( szHealthBarModel );
    }
    g_Scheduler.ClearTimerList();
    //怪物的思考大概是0.07s
    g_Scheduler.SetInterval("CheckMonster", 0.07, g_Scheduler.REPEAT_INFINITE_TIMES);
}

/**
    0 1 2 3 4
    q b s g +

**/
array<EHandle> IntToModels(int t, Vector vecOrigin, RGBA rgbColor = RGBA(255, 255, 255, 255))
{
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
    for(uint i = 0; i < 5;i++)
    {
        aryVector[i] = vecOrigin + g_Engine.v_right * (flOffset * int(i));
    }
    bool bNonZero = false;
    for(uint i = 0; i < 5;i++)
    {
        if(aryNum[i] > 0 && !bNonZero)
            bNonZero = true;
        if(bNonZero)
        {
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
            pSpr.SUB_StartFadeOut();
            aryTemp[i] = pSpr;
        }
    }
    return aryTemp;
}
class CHandleMonster
{
    private Vector vecPos;
    EHandle Monster;
    private float oldHealth;

    private EHandle Spr;
    private float flSprScale;
    Vector Pos
    {
        get { return Monster.IsValid() ? Monster.GetEntity().Center() + g_Engine.v_up * 16 : vecPos;}
        set{ vecPos = value + g_Engine.v_up * 16;}
    }
    Vector HealthBarPos()
    {
        Vector vecPos = Monster.GetEntity().Center();
        vecPos.z = (Monster.GetEntity().pev.absmax + g_Engine.v_up * flHealthBarOffset * flSprScale).z;
        return vecPos;
    }
    bool IsValid
    {
        get { return Monster.IsValid() ? Monster.GetEntity().IsAlive() : false;}
    }
    CHandleMonster (CBaseEntity@ pMonster)
    {
        Monster = pMonster;
        Pos = pMonster.Center() + g_Engine.v_up * 16;
        oldHealth = pMonster.pev.health;
        if(bEnableHealthBar)
        {
            flSprScale = (pMonster.pev.size.x / vecStandardSize.x + pMonster.pev.size.y / vecStandardSize.y + pMonster.pev.size.z / vecStandardSize.z) / 3;
            RGBA rgbColor = pMonster.IsPlayerAlly() ? RGBA(0, 255, 0, 255) : RGBA(255, 0, 0, 255);
            CSprite@ pSpr = g_EntityFuncs.CreateSprite(szHealthBarModel, HealthBarPos(), false);
            pSpr.pev.framerate = 0;
            pSpr.pev.frame = 0;
            pSpr.pev.scale = flHealthBarScale * flSprScale;
            pSpr.SetTransparency(kRenderTransAdd, rgbColor.r, rgbColor.g, rgbColor.b, rgbColor.a, kRenderFxNone);
            pSpr.pev.movetype = MOVETYPE_NOCLIP;
            pSpr.pev.solid = SOLID_NOT;
            Spr = pSpr;
        }
    }
    void CheckHealth()
    {
        float reduce = 0;
        RGBA color = RGBA(255, 255, 255, 255);
        if(!IsValid)
        {
            reduce = oldHealth;
            color = RGBA(255, 0, 0, 255);
            if(bEnableHealthBar)
                g_EntityFuncs.Remove(Spr.GetEntity());
        }
        else
        {
            reduce = oldHealth - Monster.GetEntity().pev.health;
            oldHealth = Monster.GetEntity().pev.health;
            if(reduce > Monster.GetEntity().pev.max_health * 0.33)
                color = RGBA(255, 0, 0, 255);
            if(bEnableHealthBar && Spr.IsValid())
            {
                Spr.GetEntity().pev.origin = HealthBarPos();
                Spr.GetEntity().pev.frame = int(Monster.GetEntity().pev.health / Monster.GetEntity().pev.max_health * 10);
            }
        }
        if(int(reduce) > 0)
            IntToModels(int(reduce), Pos + Vector(Math.RandomFloat(-flPopUpNoise, flPopUpNoise), Math.RandomFloat(-flPopUpNoise, flPopUpNoise), Math.RandomFloat(-flPopUpNoise, flPopUpNoise)), color);
    }
    bool opEquals(CHandleMonster@ pHandle)
    {
        return pHandle.Monster.GetEntity() is this.Monster.GetEntity();
    }
    bool opEquals(CBaseEntity@ pHandle)
    {
        return pHandle is this.Monster.GetEntity();
    }
}
int findIndex(CBaseEntity@ pMonster)
{
    for(uint i = 0; i < aryHandle.length();i++)
    {
        if(aryHandle[i] == pMonster)
            return i;
    }
    return -1;
}
void CheckMonster()
{
    CBaseEntity@ pMonster = null;
    while((@pMonster = g_EntityFuncs.FindEntityByClassname(pMonster, "monster_*")) !is null)
    {
        if(aryIgnoreMonster.find(pMonster.pev.classname) > -1)
            continue;
        if(pMonster.IsAlive() && pMonster.IsMonster() && pMonster.pev.takedamage != DAMAGE_NO && pMonster.pev.max_health > 0)
        {
            int iIndex = findIndex(pMonster);
            if( iIndex < 0)
                aryHandle.insertLast(@CHandleMonster(pMonster));
        }
    }

    for(uint i=0;i<aryHandle.length();i++)
    {
        aryHandle[i].CheckHealth();
        if(!aryHandle[i].IsValid)
            aryHandle.removeAt(i);
    }
}
