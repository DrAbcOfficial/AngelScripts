void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("Dr.Abc");
    g_Module.ScriptInfo.SetContactInfo("Shinobi yo");
    g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @Killed);
}

void MapInit()
{
    g_Game.PrecacheModel( "sprites/" + m_szSprName );
    g_Game.PrecacheGeneric("sprites/" + m_szSprName );

    g_Game.PrecacheGeneric( "sound/" + m_szSndName );
    g_SoundSystem.PrecacheSound( m_szSndName );
}

const string m_szSprName = "misc/sekiro_death.spr";
const string m_szSndName = "misc/sekiro_death.mp3";

void SendDeath( CBasePlayer@ pPlayer, const string& in strName, uint framenum = 0, float hold = 0.1 )
{
	HUDSpriteParams params;
	params.channel = 14;
	params.flags = HUD_ELEM_ABSOLUTE_Y | HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_SCR_CENTER_X | HUD_SPR_PLAY_ONCE | HUD_SPR_HIDE_WHEN_STOPPED | HUD_ELEM_DYNAMIC_ALPHA; 
	params.spritename = strName;
	params.x = 0;
	params.y = -128;
    params.frame = framenum;
	params.holdTime = hold + 0.2;
	params.color1 = RGBA_RED;
	g_PlayerFuncs.HudCustomSprite( pPlayer, params );
}

HookReturnCode Killed( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
    if(pPlayer is null)
        return HOOK_HANDLED;
    if(!pPlayer.IsNetClient())
        return HOOK_HANDLED;
	
	for(uint i = 0; i < 39; i++)
	{
		g_Scheduler.SetTimeout("SendDeath", 0.1 * i, @pPlayer, m_szSprName, i, 0.2);
	}

	g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_ITEM, m_szSndName, 0.9, ATTN_NORM, 0, PITCH_NORM );
	g_PlayerFuncs.ScreenFade(pPlayer, Vector(0,0,0), 0.5f, 5.0f, 255, FFADE_IN );
    return HOOK_HANDLED;
}
