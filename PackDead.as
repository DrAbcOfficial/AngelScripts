/**
打包玩家身上所有武器
使用名称来挨个寻找是因为MAX_ITEM_TYPES和
CBasePlayerItem@ m_rgpPlayerItems(size_t uiIndex)不能遍历到所有武器
而直接传递引用而不是用自带的weaponbox实体是
因为weaponbox会删掉原来的实体而调用Respawn()方法生成一个新实体
而sc team并不允许玩家重写Respawn()方法，对于一些带有构造函数的实体来说
将会导致丢失插件自定义的信息（比如武器配件）
这对于目前服务器上在跑的插件来说是不可接受的
**/
//模型路径
const string szPackageMdl = "models/w_weaponbox.mdl";
//拾取音效
const string szPickSnd = "items/9mmclip1.wav";
//物品自毁时间
const int iSelfDestory = 45;

const array<string> aryPackableWeapons = {
	//原版
	"weapon_357",
	"weapon_9mmAR",
	"weapon_9mmar",
	"weapon_9mmhandgun",
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_displacer",
	"weapon_eagle",
	"weapon_egon",
	"weapon_gauss",
	"weapon_glock",
	"weapon_grapple",
	"weapon_handgrenade",
	"weapon_hornetgun",
	"weapon_m16",
	"weapon_m249",
	"weapon_medkit",
	"weapon_minigun",
	"weapon_mp5",
	"weapon_pipewrench",
	"weapon_python",
	"weapon_rpg",
	"weapon_satchel",
	"weapon_saw",
	"weapon_shockrifle",
	"weapon_shotgun",
	"weapon_snark",
	"weapon_sniperrifle",
	"weapon_sporelauncher",
	"weapon_tripmine",
	"weapon_uzi",
	"weapon_uziakimbo",
	//吧服
	"weapon_m21",
	"weapon_mp7",
	"weapon_ump45",
	"weapon_sg552",
	"weapon_m202a1",
	"weapon_m4m203",
	"weapon_mp5m203",
	"weapon_g11",
	"weapon_m40a3",
	"weapon_m60",
	"weapon_usp",
	"weapon_p90",
	"weapon_mac10",
	"weapon_tmp",
	"weapon_vector",
	"weapon_shockstick",
	"weapon_knife",
	"weapon_zweihander",
	"weapon_claymore",
	"weapon_aimine",
	"weapon_penguin",
	"weapon_sentry",
	"weapon_ksg",
	"weapon_m3",
	"weapon_m32",
	"weapon_glock18",
	"weapon_rcl",
	"weapon_harpoon",
	"weapon_pipewrench",
	"weapon_hegrenade",
	"weapon_anm14grenade",
	"weapon_rcd",
	//TH
	"weapon_colt1911",
	"weapon_greasegun",
	"weapon_m14",
	"weapon_m16a1",
	"weapon_sawedoff",
	"weapon_spanner",
	"weapon_teslagun",
	"weapon_tommygun",
	//AOMDC
	"weapon_dcberetta",
	"weapon_dcp228",
	"weapon_dcglock",
	"weapon_dchammer",
	"weapon_dcknife",
	"weapon_dcmp5k",
	"weapon_dcuzi",
	"weapon_dcshotgun",
	"weapon_dcrevolver",
	"weapon_dcdeagle",
	"weapon_dcaxe",
	"weapon_dcl85a1"
	//AOM
	"weapon_clak47",
	"weapon_clberetta",
	"weapon_cldeagle",
	"weapon_clknife",
	"weapon_clshotgun",
	//HL Classic
	"weapon_hlcrowbar",
	"weapon_hlmp5",
	"weapon_hlshotgun"
};

class CLockDeadPlayerPackage: ScriptBasePlayerAmmoEntity
{
	private float flLifeTime;
	private array<EHandle> aryPackWeapon = {};
	private EHandle pOwner;

	void SetOwner(CBaseEntity@ pEntity)
	{
		pOwner = EHandle(@pEntity);
	}

	void SetList(CBasePlayer@ pPlayer)
	{
		for(uint i = 0; i < aryPackableWeapons.length(); i++)
		{
			CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>(pPlayer.HasNamedPlayerItem(aryPackableWeapons[i]));
			if(@pWeapon is null)
				continue;
			if( pWeapon.PrimaryAmmoIndex() != -1 )
			{
				pWeapon.m_iDefaultAmmo = pPlayer.m_rgAmmo(pWeapon.PrimaryAmmoIndex());
				pPlayer.m_rgAmmo(pWeapon.PrimaryAmmoIndex(), 0);
			}
			if( pWeapon.SecondaryAmmoIndex() != -1 )
			{
				pWeapon.m_iDefaultSecAmmo = pPlayer.m_rgAmmo(pWeapon.SecondaryAmmoIndex());
				pPlayer.m_rgAmmo(pWeapon.SecondaryAmmoIndex(), 0);
			}
			
			pWeapon.KeyValue("m_flCustomRespawnTime", "-1");
			aryPackWeapon.insertLast(EHandle(@pWeapon));
			//g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "" + pWeapon.pev.classname + "\n");
		}
	}

	entvars_t@ pev
	{
		get { return self.pev;}
	}

	edict_t@ edict()
	{
		return self.edict();
	}

	void Spawn()
	{ 
		if(!pOwner.IsValid() || aryPackWeapon.length() <= 0)
		{
			g_EntityFuncs.Remove(self);
			return;
		}

        BaseClass.Spawn();
		g_EntityFuncs.SetModel(self, szPackageMdl);

        this.flLifeTime = g_Engine.time + iSelfDestory;
	}

	void Precache()
	{
		g_Game.PrecacheModel(szPackageMdl);
		g_Game.PrecacheGeneric(szPackageMdl);
		g_SoundSystem.PrecacheSound(szPickSnd);
		g_Game.PrecacheGeneric("sound/" + szPickSnd);
	}

	void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue = 0.0f)
	{
		if(pActivator.IsPlayer() && pActivator.IsNetClient())
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(@pActivator);
			if(@pPlayer is @this.pOwner.GetEntity())
				AddAmmo(@pPlayer);
			else
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "这个包裹属于: " + pOwner.GetEntity().pev.netname + "\n");
		}
	}

	bool AddAmmo( CBaseEntity@ pOther ) 
	{ 
		if(pOther.IsPlayer() && pOther.IsNetClient())
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(@pOther);
			if(!pOwner.IsValid() || @pPlayer is @this.pOwner.GetEntity())
			{
				for(uint i = 0; i < aryPackWeapon.length(); i++)
				{
					if(!aryPackWeapon[i].IsValid())
						continue;
					CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>(@aryPackWeapon[i].GetEntity());
					pPlayer.AddPlayerItem(@pWeapon);
					g_SoundSystem.EmitSound(self.edict(), CHAN_ITEM, szPickSnd, 1, ATTN_NORM);
					g_EntityFuncs.Remove(self);
				}
				return true;
			}
		}
		return false;
	}

	void Think() 
	{
        if ((this.flLifeTime > 0) && (g_Engine.time  >= this.flLifeTime))
            g_EntityFuncs.Remove(self);
        else
        	self.pev.nextthink = g_Engine.time + flLifeTime + 1;
    }
}

CLockDeadPlayerPackage@ CreateDeadPackage(CBasePlayer@ pPlayer)
{
	CLockDeadPlayerPackage@ pEntity = cast<CLockDeadPlayerPackage@>(CastToScriptClass(g_EntityFuncs.Create("item_deadplayerpackage", pPlayer.Center(), g_vecZero, true)));
	pEntity.SetOwner(pPlayer);
	pEntity.SetList(pPlayer);
    g_EntityFuncs.DispatchSpawn(pEntity.edict());
    return @pEntity;
}

HookReturnCode Killed(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib)
{
	if(!bEnable)
		return HOOK_CONTINUE;
    if(pPlayer is null)
        return HOOK_CONTINUE;
    if(!pPlayer.IsNetClient())
        return HOOK_CONTINUE;
    CLockDeadPlayerPackage@ pEntity = CreateDeadPackage(pPlayer);
    Math.MakeVectors(pPlayer.pev.angles);
    pEntity.pev.velocity = pPlayer.pev.velocity + g_Engine.v_forward * 128 + g_Engine.v_up * 128;
	for(uint i = 0; i < aryPackableWeapons.length(); i++)
		{
			CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>(pPlayer.HasNamedPlayerItem(aryPackableWeapons[i]));
			if(@pWeapon is null)
				continue;
			pPlayer.RemovePlayerItem(@pWeapon);
		}
    return HOOK_CONTINUE;
}

bool bEnable = true;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo("Not Me");
}

void MapInit()
{
	if(g_EngineFuncs.CVarGetFloat("mp_dropweapons") == 0)
	{
		bEnable = false;
		return;
	}
	//g_EngineFuncs.CVarSetFloat("mp_dropweapons", 0);
	g_CustomEntityFuncs.RegisterCustomEntity("CLockDeadPlayerPackage", "item_deadplayerpackage");
	g_Game.PrecacheOther("item_deadplayerpackage");

	g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @Killed);
}