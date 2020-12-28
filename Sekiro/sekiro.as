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

const string m_szSprName = "misc/cyberpunk2077.spr";
const string m_szSndName = "misc/cyberpunk2077.wav";
const uint m_uiFrameLength = 45;

void SendDeath( CBasePlayer@ pPlayer, const string& in strName, uint framenum = 0, float hold = 0.1 )
{
	HUDSpriteParams params;
	params.channel = 14;
	params.flags = HUD_ELEM_ABSOLUTE_Y | HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_SCR_CENTER_X; 
	params.spritename = strName;
	params.x = 0;
	params.y = -128;
	params.framerate = 0;
    params.frame = framenum;
	params.holdTime = hold + 0.2;
	params.color1 = RGBA_RED;
	params.fadeoutTime = 0.1;
	g_PlayerFuncs.HudCustomSprite( pPlayer, params );
}

HookReturnCode Killed( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
    if(pPlayer is null)
        return HOOK_HANDLED;
    if(!pPlayer.IsNetClient())
        return HOOK_HANDLED;
	
	for(uint i = 0; i < m_uiFrameLength; i++)
	{
		float flTime = i < (m_uiFrameLength - 1) ? 0.2 : 1.5;
		g_Scheduler.SetTimeout("SendDeath", 0.07 * i, @pPlayer, m_szSprName, i, flTime);
	}

	NetworkMessage message( MSG_ONE, NetworkMessages::SVC_STUFFTEXT, pPlayer.edict() );
		message.WriteString("spk " + m_szSndName);
	message.End();
	//g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_ITEM, m_szSndName, 0.9, ATTN_NORM, 0, PITCH_NORM );
	g_PlayerFuncs.ScreenFade(pPlayer, Vector(0,0,0), 0.5f, 5.0f, 255, FFADE_IN );
    return HOOK_HANDLED;
}