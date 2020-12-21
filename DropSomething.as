//掉落发言
const array<string> aryDropShit = {
    "你被%monster%狠很击中了肚子，这使得你掉落了一坨不可名状的物体",
    "%monster%的攻势实在是太激烈了，你不得不抛弃一些负担",
    "你的HEV里的内循环系统并不能从%monster%手上保护你",
    "从%monster%而来的激烈攻击使得你遗弃了自己的午饭",
    "%monster%一掌就将你的分泌物打了出来"
};
//捡起发言
const array<string> aryEatShit = {
    "你捡起了%player%的遗志，还有点甜",
    "这是%player%亲手制作的巧克力，你迫不及待地尝了尝",
    "这一大坨巧克力里还留有%player%的味道",
    "%player%丢在这里的东西，你决定不还给他",
    "%player%为你留下了一些慰问品",
    "你从可怜的%player%身上搜刮到了好大一坨巧克力",
    "%player%为你准备了新鲜的巧克力，快尝尝吧"
};

//最低需求伤害
const int iDamageGap = 20;
//最大缩放尺寸
const float iMaxSize = 5.0f;
//模型
const string szShitMdl = "models/misc/shit.mdl";
//类名
const string szShitClassName = "item_shit";
//恢复量
const int iShitGive = 20;
//碰撞体积最小点
const Vector vecShitBaseSizeMin = Vector(-4, -4, -4);
//碰撞体积最大点
const Vector vecShitBaseSizeMax = Vector(4, 4, 4);

/**
    获得随机句子
    数组
**/
string GetRandomSentence(array<string>&in inAry)
{
    if(inAry.length() <= 0)
        return "";
    else
        return inAry[Math.RandomLong(0, inAry.length() - 1)];
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo( "Bruh" );

    g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage);
}

void MapInit()
{
    g_CustomEntityFuncs.RegisterCustomEntity("CShit", szShitClassName);
    g_Game.PrecacheOther( szShitClassName );
}

HookReturnCode PlayerTakeDamage(DamageInfo@ info)
{
    if(info.flDamage < iDamageGap || info.pAttacker is null || !info.pAttacker.IsMonster())
        return HOOK_CONTINUE;

    CBasePlayer@ pPlayer = cast<CBasePlayer@>(info.pVictim);
    CBaseMonster@ pMonster = cast<CBaseMonster@>(info.pAttacker);
    if(pPlayer !is null && pPlayer.IsNetClient())
    {
        g_PlayerFuncs.SayText(pPlayer, GetRandomSentence(aryDropShit).Replace("%monster%", string(pMonster.m_FormattedName)));

        CBaseEntity@ pShit = g_EntityFuncs.Create(szShitClassName, pPlayer.pev.origin, g_vecZero, true);
            @pShit.pev.owner = @pPlayer.edict();
            float flTemp = Math.min(iMaxSize, info.flDamage/iDamageGap);
            pShit.pev.scale = flTemp;
            g_EntityFuncs.SetSize(pShit.pev, vecShitBaseSizeMin.opMul(flTemp), vecShitBaseSizeMax.opMul(flTemp));
        g_EntityFuncs.DispatchSpawn(pShit.edict());
    }
    return HOOK_HANDLED;
}

class CShit: ScriptBasePlayerAmmoEntity
{
	void Spawn()
	{ 
		Precache();
		if( !self.SetupModel() )
			g_EntityFuncs.SetModel( self, szShitMdl );
		else
			g_EntityFuncs.SetModel( self, self.pev.model );
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		BaseClass.Precache();
		if( string(self.pev.model).IsEmpty() )
			g_Game.PrecacheModel(szShitMdl);
		else
			g_Game.PrecacheModel( self.pev.model );
	}
	
	bool AddAmmo(CBaseEntity@ pOther)
	{
		CBasePlayer@ pPlayer = cast<CBasePlayer@>(pOther);
        if(pPlayer.edict() is self.pev.owner)
            return false;

		if(pPlayer.pev.health < 100)
		{
			NetworkMessage message( MSG_ONE, NetworkMessages::ItemPickup, pPlayer.edict() );
				message.WriteString("item_healthkit");
			message.End();

            NetworkMessage m( MSG_ONE, NetworkMessages::ToxicCloud, pPlayer.edict() );
                m.WriteCoord(pPlayer.pev.origin.x);
                m.WriteCoord(pPlayer.pev.origin.y);
                m.WriteCoord(pPlayer.pev.origin.z);
	        m.End();

			if((pPlayer.pev.health + iShitGive) > pPlayer.pev.max_health)
				pPlayer.pev.health = pPlayer.pev.max_health;
			else
				pPlayer.pev.health += iShitGive;
			
            g_PlayerFuncs.SayText(pPlayer, GetRandomSentence(aryEatShit).Replace("%player%", string(self.pev.owner.vars.netname)));
			return true;
		}
		return false;
	}
}
