namespace nHeavyArmor
{
//模型和音效
const string ARMOR_MODEL = "models/fullarmor.mdl";
const string ARMOR_SOUND = "tr_kevlar.wav";
//拾取图标
const string PICKED_ICON = "suit_full";
//护甲值
const int HEAVY_VALUE = 300;
const int MIDDLE_VALUE = 200;
const int LIGHT_VALUE = 150;
//速度
const double HEAVY_SPEED = 0.5f;
const double MIDDLE_SPEED = 0.75f;
const double LIGHT_SPEED = 0.85f;
//重力
const double HEAVY_GRAVITY = 1.4f;
const double MIDDLE_GRAVITY = 1.05f;
const double LIGHT_GRAVITY = 1.0f;

const array<uint> MODEL_INDEX = { 6, 2, 0 };
const string ARMOR_KEYVAL = "$i_hasHeavyArmor";

abstract class CBaseArmor : ScriptBaseEntity
{
	private CBasePlayer@ m_pPlayer;
	private EHandle eView = null;

	protected int iArmorValue;
	protected uint8 uiArmorType;
	protected float flArmorHeavy;
	protected float flArmorGravity;
	protected string szArmorModel = ARMOR_MODEL;
	protected string szArmorSound = ARMOR_SOUND;

	void Think()
	{
		if(m_pPlayer !is null)
		{
			if(!m_pPlayer.IsAlive())
			{
				g_EntityFuncs.DispatchKeyValue(m_pPlayer.edict(), ARMOR_KEYVAL, "0");
				if(eView.IsValid())
					eView.GetEntity().SUB_Remove();
				self.SUB_Remove();
			}
			self.pev.nextthink = g_Engine.time + 0.1;
		}
		BaseClass.Think();
	}

	void AddToPlayer(CBasePlayer@ pPlayer)
	{
		@m_pPlayer = pPlayer;
		pPlayer.pev.armortype = pPlayer.pev.armorvalue = iArmorValue;
		pPlayer.pev.maxspeed = pPlayer.pev.maxspeed * flArmorHeavy;
		pPlayer.pev.gravity = flArmorGravity;



		CBaseEntity@ pView = g_EntityFuncs.Create("info_target", pPlayer.pev.origin, pPlayer.pev.angles, false);
		pView.pev.movetype = MOVETYPE_FOLLOW;
		@pView.pev.aiment = pPlayer.edict();
		pView.pev.rendermode = kRenderNormal;
		g_EntityFuncs.SetModel(pView, szArmorModel);
		pView.pev.body = MODEL_INDEX[uiArmorType];
		eView = EHandle(pView);
		
		@self.pev.owner = pPlayer.edict();
		self.pev.solid	= SOLID_NOT;
		self.pev.rendermode = 1;
		
		g_EntityFuncs.DispatchKeyValue(pPlayer.edict(), ARMOR_KEYVAL, "1");

		NetworkMessage message( MSG_ONE, NetworkMessages::ItemPickup, pPlayer.edict() );
			message.WriteString(PICKED_ICON);
		message.End();
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_AUTO, ARMOR_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM );

		Think();
	}

	void Touch(CBaseEntity@ pEntity)
	{
		if(pEntity.IsPlayer() && pEntity.IsNetClient() && pEntity.IsAlive())
		{
			CBasePlayer@ pPlayer = cast<CBasePlayer@>(pEntity);
			CustomKeyvalue pCustom = pPlayer.GetCustomKeyvalues().GetKeyvalue(ARMOR_KEYVAL);
			if(!pCustom.Exists())
				AddToPlayer(pPlayer);
			else if(pCustom.GetInteger() != 1)
				AddToPlayer(pPlayer);
		}
		BaseClass.Touch(pEntity);
	}

	void Precache()
	{
		BaseClass.Precache();

		g_Game.PrecacheModel( szArmorModel );
		g_Game.PrecacheGeneric( szArmorModel );

		g_SoundSystem.PrecacheSound( szArmorSound );
		g_Game.PrecacheGeneric( "sound/" + szArmorSound );
	}

	void Spawn()
	{
		g_EntityFuncs.SetModel( self, szArmorModel );

		BaseClass.Spawn();

		self.pev.solid	= SOLID_TRIGGER;
		self.pev.body = MODEL_INDEX[uiArmorType];
		g_EntityFuncs.SetSize(self.pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX);
	}
}

class CLightArmor : CBaseArmor
{
	CLightArmor()
	{
		uiArmorType = 0;
		iArmorValue = LIGHT_VALUE;
		flArmorHeavy = LIGHT_SPEED;
		flArmorGravity = LIGHT_GRAVITY;
	}
}

class CMiddleArmor : CBaseArmor
{
	CMiddleArmor()
	{
		uiArmorType = 1;
		iArmorValue = MIDDLE_VALUE;
		flArmorHeavy = MIDDLE_SPEED;
		flArmorGravity = MIDDLE_GRAVITY;
	}
}

class CHeavyArmor : CBaseArmor
{
	CHeavyArmor()
	{
		uiArmorType = 2;
		iArmorValue = HEAVY_VALUE;
		flArmorHeavy = HEAVY_SPEED;
		flArmorGravity = HEAVY_GRAVITY;
	}
}

void RegisterArmor()
{
	g_Game.PrecacheModel( ARMOR_MODEL );
	g_SoundSystem.PrecacheSound( ARMOR_SOUND );
	g_CustomEntityFuncs.RegisterCustomEntity( "nHeavyArmor::CLightArmor", "item_lightarmor" );
	g_CustomEntityFuncs.RegisterCustomEntity( "nHeavyArmor::CMiddleArmor", "item_middlearmor" );
	g_CustomEntityFuncs.RegisterCustomEntity( "nHeavyArmor::CHeavyArmor", "item_heavyarmor" );
	g_ItemRegistry.RegisterItem("item_lightarmor","");	
}
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "DrAbc" );
	g_Module.ScriptInfo.SetContactInfo( "Dr.Abc@foxmail.com" );
}
void MapInit()
{
	nHeavyArmor::RegisterArmor();
}