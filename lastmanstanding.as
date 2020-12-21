const string szLastManMessage = "You are the last one, good luck.\n";
const string szFailedMessage = "Failed! nice try.\n";
const string szFinishMessage = "Nice Job! You did it!\n";
const string szLastManMusic = "music/insslastman.mp3";
const string szStartMusic = "grunts2/radio1.wav";
const string szFinishMusic = "boid/boid_alert1.wav";

CScheduledFunction@ sfCheck = null;
bool bIsLastMan = false;
void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "Dr.Abc" );
	g_Module.ScriptInfo.SetContactInfo( "not me ofc not me" );
}

void MapInit()
{
	g_Game.PrecacheGeneric( "sound/" + szLastManMusic );
	g_SoundSystem.PrecacheSound( szLastManMusic );

	g_Game.PrecacheGeneric( "sound/" + szStartMusic );
	g_SoundSystem.PrecacheSound( szStartMusic );

	g_Game.PrecacheGeneric( "sound/" + szFinishMusic );
	g_SoundSystem.PrecacheSound( szFinishMusic );

	g_Scheduler.RemoveTimer(sfCheck);
	@sfCheck = g_Scheduler.SetInterval("CheckForAlive", 1, g_Scheduler.REPEAT_INFINITE_TIMES);
}

void CheckForAlive()
{
	if(!g_SurvivalMode.IsEnabled() || !g_SurvivalMode.IsActive())
		return;

	CBasePlayer@ tPlayer = null;
	uint j = 0, w = 0;
	for (int i = 1;i <= g_Engine.maxClients;i++)
	{
		CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
		if (pPlayer !is null && pPlayer.IsConnected())
		{
			if(pPlayer.IsAlive())
			{
				@tPlayer = @pPlayer;
				j++;
			}
			w++;
		}
	}

	if(j <= 1 || w <= 1)
		return;

	if(!bIsLastMan)
	{
		if(j == 1)
		{
			bIsLastMan = true;
			Play(tPlayer);
			g_SoundSystem.PlaySound(g_EntityFuncs.IndexEnt(1), CHAN_MUSIC, szStartMusic, 1.0f, 0.0f, 0);
		}
	}
	else
	{
		if(j > 1)
		{
			bIsLastMan = false;
			Stop(tPlayer);
			g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, szFinishMessage);
			g_SoundSystem.PlaySound(g_EntityFuncs.IndexEnt(1), CHAN_MUSIC, szFinishMusic, 1.0f, 0.0f, 0);
		}
		else if(j == 0)
		{
			bIsLastMan = false;
			Stop(null);
			g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, szFailedMessage);
		}
	}
}

void Play(CBasePlayer@ pPlayer)
{
	g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCENTER, szLastManMessage);
	g_SoundSystem.PlaySound(g_EntityFuncs.IndexEnt(0), CHAN_MUSIC, szLastManMusic, 1.0f, 0.0f, SND_FORCE_LOOP);
}

void Stop(CBasePlayer@ pPlayer)
{
	g_SoundSystem.StopSound(g_EntityFuncs.IndexEnt(0), CHAN_MUSIC, szLastManMusic);

	if(@pPlayer is null)
		return;
}
