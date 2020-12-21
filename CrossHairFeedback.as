/***
CrossHairFeedBack	--Dr.Abc
****/

dictionary g_pPlayerDic;

class CPlayerData
{
	float PlayerFrags;
	bool IsGrenade;
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo( "I LOVE OWL2" );
	g_Hooks.RegisterHook(Hooks::Player::PlayerPreThink, @PlayerPreThink);
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
}

void MapInit()
{
	g_Game.PrecacheModel( "sprites/misc/mlg.spr" );
	g_Game.PrecacheModel( "sprites/misc/grenade.spr" );
	g_SoundSystem.PrecacheSound( "misc/hitmarker.mp3" );	
	
	g_Game.PrecacheGeneric( "sound/misc/hitmarker.mp3" );
	g_Game.PrecacheGeneric( "sprites/misc/mlg.spr" );
	g_Game.PrecacheGeneric( "sprites/misc/grenade.spr" );
}

HookReturnCode ClientSay(SayParameters@ pParams)
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ pArguments = pParams.GetArguments();
	if (pArguments.ArgC() == 1) 
	{
		if (pArguments.Arg(0).ToLowercase() == "!grenademeter") 
		{
			pParams.ShouldHide = true;
			string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
			CPlayerData@ data = cast<CPlayerData@>(g_pPlayerDic[steamId]);
			if (data.IsGrenade)
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[GrenadeMeter] Disabled.\n");
				data.IsGrenade = false;
			}
			else 
			{
				g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTTALK, "[GrenadeMeter] Enabled.\n");
				data.IsGrenade = true;
			}
			g_pPlayerDic[steamId] = data;
			return HOOK_HANDLED;
		}
	}
	return HOOK_CONTINUE;
}

HookReturnCode PlayerPreThink( CBasePlayer@ pPlayer, uint& out uiFlags )
{
	const string steamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if(!g_pPlayerDic.exists(steamId))
	{
		CPlayerData data;
		data.PlayerFrags = pPlayer.pev.frags;
		data.IsGrenade = true;
		g_pPlayerDic[steamId] = data;
		return HOOK_HANDLED;
	}
	else 
	{
		CPlayerData@ data = cast<CPlayerData@>(g_pPlayerDic[steamId]);
		if ( int(data.PlayerFrags) != int(pPlayer.pev.frags) )
		{
			SendHUD( pPlayer );
			data.PlayerFrags = pPlayer.pev.frags;
			data.IsGrenade = data.IsGrenade;
			g_pPlayerDic[steamId] = data;
		}
		if( data.IsGrenade )
			SendGrenadeHUD( pPlayer );
		return HOOK_HANDLED;
	}
}

void SendHUD( CBasePlayer@ pPlayer, float hold = 0.2 )
{
	HUDSpriteParams params;
	
	params.channel = 5;
	params.flags =  HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_SCR_CENTER_X | HUD_SPR_MASKED | HUD_ELEM_DEFAULT_ALPHA;
	params.spritename = "misc/mlg.spr";
	params.x = 0;
	params.y = 0;
	params.fxTime = 0.03;
	params.effect = HUD_EFFECT_RAMP_UP;
	params.fadeinTime = 0.03;
	params.fadeoutTime = 0.03;
	params.holdTime = hold;
	params.color1 = RGBA_SVENCOOP;
	params.color2 = RGBA_WHITE;
	
	g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, "misc/hitmarker.mp3", 0.45 , ATTN_NORM, 0, PITCH_NORM, 1 );
	g_PlayerFuncs.HudCustomSprite( pPlayer, params );
}

void SendGrenadeHUD( CBasePlayer@ pPlayer, float hold = 0.2 )
{
	CBaseEntity@pEntity = g_EntityFuncs.FindEntityByClassname(pEntity, "grenade");
	if( pEntity !is null )
	{
		Vector vecLengh = pPlayer.pev.origin - pEntity.pev.origin;
		if( vecLengh.Length() < 256.0f )
		{
			HUDSpriteParams params;

			Vector vecAngle = vecLengh/vecLengh.Length();
			vecAngle = Vector(vecAngle.x + 1, vecAngle.y + 1, vecAngle.z + 1).opDiv(2);
			
			Vector vecAim = pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES )/pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES ).Length();
			vecAim = Vector(vecAim.x + 1, vecAim.y + 1, vecAim.z + 1 ).opDiv(2);
			
			Vector2D vecHUD = ((vecAngle + vecAim)/2).Make2D();
			
			params.channel = 6;
			params.spritename = "misc/grenade.spr";
			params.x = vecHUD.x ;
			params.y = vecHUD.y ;
			params.holdTime = hold;
			params.color1 = ( pEntity.IRelationship( pPlayer ) >= R_DL ) ? RGBA_RED : RGBA_SVENCOOP;
			g_PlayerFuncs.HudCustomSprite( pPlayer, params );
		}
		
	}
}