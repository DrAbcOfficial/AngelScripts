const string szMdl = "misc/v_spary.mdl";
const string szSound = "fvox/hiss.wav";
const string szSmoke = "wep_smoke_02.spr";
const float flDelay = 0.7;

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "drabc" );
	g_Module.ScriptInfo.SetContactInfo( "bruh" );
	g_Hooks.RegisterHook(Hooks::Player::PlayerDecal, @PlayerDecal);
}

void MapInit()
{
	g_Game.PrecacheModel( "models/" + szMdl );
    g_Game.PrecacheGeneric("models/" + szMdl );

    g_Game.PrecacheModel( "sprites/" + szSmoke );
    g_Game.PrecacheGeneric("sprites/" + szSmoke );

    g_Game.PrecacheGeneric( "sound/" + szSound );
    g_SoundSystem.PrecacheSound( szSound );
}

void StopAnimation(CBasePlayer@ pPlayer)
{
	pPlayer.m_flNextAttack = g_Engine.time;
	pPlayer.DeployWeapon();
}

HookReturnCode PlayerDecal( CBasePlayer@ pPlayer, const TraceResult& in trace )
{
	if(pPlayer is null || !pPlayer.IsNetClient())
        return HOOK_CONTINUE;
    CBasePlayerWeapon@ pWeapon = cast<CBasePlayerWeapon@>(pPlayer.m_hActiveItem.GetEntity());
    if(pWeapon is null)
    	return HOOK_CONTINUE;

    pPlayer.HolsterWeapon();
    pPlayer.pev.viewmodel = "models/" + szMdl;
    pPlayer.m_szAnimExtension = "crowbar";
    pWeapon.SendWeaponAnim(0, 0, 0);
    pPlayer.SetAnimation( PLAYER_ATTACK1 );
    g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_ITEM, szSound, 0.9, ATTN_NORM, 0, PITCH_NORM );

	NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
		m.WriteByte(TE_GLOWSPRITE);
		m.WriteCoord(trace.vecEndPos.x);
		m.WriteCoord(trace.vecEndPos.y);
		m.WriteCoord(trace.vecEndPos.z);
		m.WriteShort(g_EngineFuncs.ModelIndex("sprites/" + szSmoke));
		m.WriteByte(1);
		m.WriteByte(10);
		m.WriteByte(80);
	m.End();
    
    pPlayer.m_flNextAttack = g_Engine.time + flDelay;
    g_Scheduler.SetTimeout("StopAnimation", flDelay, @pPlayer);
	return HOOK_CONTINUE;
}