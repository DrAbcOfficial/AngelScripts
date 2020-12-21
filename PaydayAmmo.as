//模型路径
const string szAmmoMdl = "models/fun/payday_ammo.mdl";
//拾取音效
const string szPickSnd = "items/9mmclip1.wav";
//默认占位符
const string szDefaultName = "DEFAULT_REPLACER";
//物品注册名称
const string szItemClassname = "item_paydayammoclip";
//物品自毁时间
const int iSelfDestory = 45;
//物品最小碰撞盒
const Vector vecHullMin = Vector( -12, -12, -8 );
//物品最大碰撞盒
const Vector vecHullMax = Vector( 12, 12, 8 );
//物品最小飞行方向
const Vector vecFlyPosMin = Vector(-200,-200,-200);
//物品最大飞行方向
const Vector vecFlyPosMax = Vector(200,200,200);
//无弹匣武器子弹补充倍率
const Vector2D vecNoClip = Vector2D(0.2, 0.3);
//每多少秒进行一次检查
const float flReapet = 1.0f;
//依据子弹种类补充量表
dictionary dicAmmoMap = {{"357", Vector2D(2, 4)},
    {"556", Vector2D(10, 15)},
    {"9mm", Vector2D(12, 25)},
    {"ARgrenades", Vector2D(0, 2)},
    {"bolts", Vector2D(1, 3)},
    {"rockets", Vector2D(0, 2)},
    {"buckshot", Vector2D(1, 5)},
    {szDefaultName, Vector2D(12, 23)}
};
//不可补充子弹武器列表
const array<string> aryBanWeapons = {
    "weapon_handgrenade",
    "weapon_sporelauncher",
    "weapon_hornetgun",
    "weapon_satchel",
    "weapon_tripmine",
	"weapon_shockrifle",
	"weapon_snark",
	"weapon_as_jetpack",
	"weapon_observer"
};
//不可掉落子弹怪物列表
const array<string> aryBanMonsters = {
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
    "monster_headcrab",
    "monster_barnacle"
};
//关系表
array<array<int8>> aryRelationMap = {
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,0,1,1,1,0,1,1,1,1,1,0,1,1,1,1},
	{0,1,0,0,0,1,1,1,1,1,1,0,1,1,1,1},
	{0,4,-2,-2,-2,2,1,1,2,1,1,0,0,0,4,4},
	{0,0,1,1,1,-2,1,2,1,1,1,0,0,0,2,2},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,1,1,1,1,2,0,-2,0,0,0,0,0,0,1,2},
	{0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0},
	{0,0,1,1,1,1,0,0,0,0,4,0,0,0,4,0},
	{0,0,1,1,1,1,0,0,0,2,0,0,0,0,1,1},
	{0,4,4,4,4,4,4,0,4,4,4,0,0,0,0,0},
    {0,1,-2,0,-2,1,1,1,1,1,1,0,0,0,1,1},
	{0,0,0,0,0,1,1,1,1,1,1,0,0,1,1,1},
	{0,0,1,1,1,1,0,-2,1,1,0,0,1,0,1,1},
	{0,1,1,1,1,1,1,1,0,1,1,0,0,0,-2,-2},
	{0,1,2,1,1,2,1,2,0,0,1,0,0,0,-2,-2}};

class CPDAmmoClip: ScriptBasePlayerAmmoEntity
{
	private float flLifeTime;
	void Spawn()
	{ 
        BaseClass.Spawn();

		g_EntityFuncs.SetModel(self, szAmmoMdl);
		g_EntityFuncs.SetSize(self.pev,vecHullMin, vecHullMax );

        self.pev.velocity = g_Engine.v_forward * Math.RandomFloat (vecFlyPosMin.x,vecFlyPosMax.x) + 
                            g_Engine.v_right * Math.RandomFloat (vecFlyPosMin.y,vecFlyPosMax.y) + 
                            g_Engine.v_up * Math.RandomFloat (vecFlyPosMin.z,vecFlyPosMax.z);
		self.pev.angles = Math.VecToAngles( self.pev.velocity );

        flLifeTime = g_Engine.time + iSelfDestory;
	}

    int SupplyAmount(CBasePlayerWeapon@ pWeapon, bool isSubType = false)
	{
        string tempStr = isSubType ? pWeapon.pszAmmo2() : pWeapon.pszAmmo1();
        Vector2D vecTemp = Vector2D(dicAmmoMap.exists(tempStr) ? dicAmmoMap[tempStr] : dicAmmoMap[szDefaultName]);
		return int(Math.max(0, Math.RandomFloat(vecTemp.x , vecTemp.y)));
	}

	bool AddAmmo( CBaseEntity@ pOther ) 
	{ 
		if(pOther.IsPlayer())
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(pOther);
			CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());

            if(aryBanWeapons.find(pWeapon.GetClassname()) < 0)
			{
                bool bFlag = false;
                if(pWeapon.PrimaryAmmoIndex() != -1)
                {
                    int iPrimAmmo = pPlayer.m_rgAmmo(pWeapon.PrimaryAmmoIndex());
                    int iPrimMax = pWeapon.iMaxAmmo1();
                    if(iPrimAmmo != iPrimMax)
                    {
                        bFlag = true;
                        int iPrimSupply = SupplyAmount(pWeapon);
                        if( iPrimAmmo + iPrimSupply >= iPrimMax)
                            pPlayer.m_rgAmmo(pWeapon.PrimaryAmmoIndex(), iPrimMax);
                        else
                            pPlayer.m_rgAmmo(pWeapon.PrimaryAmmoIndex(), iPrimAmmo + iPrimSupply);
                    }
                }

                if(!bFlag && pWeapon.SecondaryAmmoIndex() != -1)
                {
                    int iSubAmmo = pPlayer.m_rgAmmo(pWeapon.SecondaryAmmoIndex());
                    int iSubMax = pWeapon.iMaxAmmo2();
                    if(iSubAmmo != iSubMax)
                    {
                        bFlag = true;
                        int iSubSupply = SupplyAmount(pWeapon, true);
                        if( iSubAmmo + iSubSupply >= iSubMax)
                            pPlayer.m_rgAmmo(pWeapon.SecondaryAmmoIndex() , iSubMax);
                        else
                            pPlayer.m_rgAmmo(pWeapon.SecondaryAmmoIndex() , iSubAmmo + iSubSupply);
                    }
                }

                if(bFlag)
                {
                    g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, szPickSnd, 1, ATTN_NORM);
                    g_EntityFuncs.Remove( self );
                    return true;
                }
            }
		}
		return false;
	}

	void Think() 
	{
        BaseClass.Think();
        if ((this.flLifeTime > 0) && (g_Engine.time  >= this.flLifeTime))
            g_EntityFuncs.Remove( self );
        self.pev.nextthink = g_Engine.time + flLifeTime + 1;
    }
}

class CHandleMonster
{
    private Vector vecPos;

    EHandle Monster;
    Vector Pos
    {
        get { return Monster.IsValid() ? Monster.GetEntity().GetOrigin() + g_Engine.v_up * 16 : vecPos;}
	    set{ vecPos = value + g_Engine.v_up * 16;}
    }

    bool IsValid
    {
        get { return Monster.IsValid() ? Monster.GetEntity().IsAlive() : false;}
    }

    int Classify
    {
        get { return Monster.GetEntity().Classify();}
    }

    CHandleMonster (CBaseEntity@ pMonster)
    {
        Monster = pMonster;
        Pos = pMonster.GetOrigin() + g_Engine.v_up * 16;
    }

    bool opEquals(CHandleMonster@ pHandle)
    {
        return pHandle.Monster.GetEntity() is this.Monster.GetEntity();
    }

    bool opEquals(CBaseEntity@ pMonster)
    {
        return pMonster is this.Monster.GetEntity();
    }
}

array<CHandleMonster@> aryHandle;
CScheduledFunction@ entityCheck;
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo("Not Me");
}

void MapInit()
{
	g_Scheduler.ClearTimerList();
    @entityCheck = g_Scheduler.SetInterval("CheackEntityTimer", flReapet, g_Scheduler.REPEAT_INFINITE_TIMES);
	
	g_Game.PrecacheModel(szAmmoMdl);
	g_SoundSystem.PrecacheSound(szPickSnd);
	g_Game.PrecacheGeneric("sound/" + szPickSnd);
	
	g_CustomEntityFuncs.RegisterCustomEntity("CPDAmmoClip", szItemClassname);
}

int GetRelationshipByClass(CLASS&in inClass1, CLASS&in inClass2)
{
	int a = Math.clamp(0,15,inClass1);
	int b = Math.clamp(0,15,inClass2);
	return aryRelationMap[a][b];
}

void Create(Vector vecPos, uint uiAmount = 3)
{
    for(uint i = 0;i < uiAmount;i++)
    {
        CBaseEntity@ pEntity = g_EntityFuncs.Create(szItemClassname, vecPos, Vector(0,0,0), true);
        g_EntityFuncs.DispatchSpawn(pEntity.edict());
    }
}

void CheackEntityTimer()
{
	CBaseEntity@ pMonster = null;
	while((@pMonster = g_EntityFuncs.FindEntityByClassname(pMonster, "monster_*")) !is null)
	{
		int iRelation = GetRelationshipByClass(CLASS(pMonster.Classify()), CLASS_PLAYER);
		if(pMonster.IsAlive() && iRelation > R_NO && aryBanMonsters.find(pMonster.GetClassname()) < 0)
		{
            int iIndex = aryHandle.find(pMonster);
			if( iIndex < 0)
                aryHandle.insertLast(@CHandleMonster(pMonster));
			else
				@aryHandle[iIndex] = @CHandleMonster(pMonster);
		}
	}

	for(uint i=0;i<aryHandle.length();i++)
	{
		if(!aryHandle[i].IsValid)
		{
            Create(aryHandle[i].Pos, Math.RandomLong(1,3));
            aryHandle.removeAt(i);
		}
	}
}
