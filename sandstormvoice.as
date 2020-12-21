//the sound file directory path
//e.g: sandstorm -> "sound/sandstorm/xxxxx"
const string szPathHeader = "sandstorm";
//the word appeared when you taunt
const string szAlertMessage = "*警告*";
//the client command to taunt
const string szTauntKeyword = "taunt";
//the taunt sound radius
//default value is 512
const float flSoundRadius = 1024; //512
//taunt recharge time
//prevent for flooding
const float flFreezeTime = 2;
//delay before monster respond
const float flRespondDelay = 2.0f;
//how long you keeping suppress status when gotting shot
const float flPanicTime = 3;
//blacklist or whitelist monster
const array<string> aryAvaliable = {
    "monster_*"
};
//enable blacklist/whitelist?
const bool bIsEnable = false;
//above list is blacklist or whitelist
const bool bIsBlackList = true;
//monster UID obtain method
//default using headnode
/**
    0   serialNumber
    1   modelIndex
    2   entIndex
    3   spawnflags
    4   headnode
**/
const int iMonsterUID = 0;
//player taunting status
// 0    0
//SUP  INT
enum VOICE_TYPE
{
    VOICE_RESNORMAL = 0,
    VOICE_INTNORMAL,
    VOICE_RESSUP,
    VOICE_INTSUP
}
//monster spawn flags
//it's not containg in vanillia game, sitt
enum MONSTERSPAWNFLAG
{
	// Monster Spawnflags
	SF_MONSTER_WAIT_TILL_SEEN		= 1,// spawnflag that makes monsters wait until player can see them before attacking.
	SF_MONSTER_GAG					= 2, // no idle noises from this monster
	SF_MONSTER_HITMONSTERCLIP		= 4,
	//								= 8,
	SF_MONSTER_PRISONER				= 16, // monster won't attack anyone, no one will attacke him.
	//								= 32,
	//								= 64,
	SF_MONSTER_WAIT_FOR_SCRIPT		= 128, //spawnflag that makes monsters wait to check for attacking until the script is done or they've been attacked
	SF_MONSTER_PREDISASTER			= 256,	//this is a predisaster scientist or barney. Influences how they speak.
	SF_MONSTER_FADECORPSE			= 512, // Fade out corpse after death
	SF_MONSTER_FALL_TO_GROUND		= -2147483648,
	//								= 
	// specialty spawnflags         = 
	SF_MONSTER_TURRET_AUTOACTIVATE	= 32,
	SF_MONSTER_TURRET_STARTINACTIVE	= 64,
	SF_MONSTER_WAIT_UNTIL_PROVOKED	= 64 // don't attack the player unless provoked
}
//Voice data storage
array<CVoiceData@> aryVoiceBank;
//Player data storage
dictionary dicPlayerBank;
//Voice data item class
class CVoiceData
{
    //taunt
    array<string> aryIntNormal;
    array<string> aryIntSuppress;
    //retaunt
    array<string> aryReintNormal;
    array<string> aryReintSuppress;
    //Unique name, using for define different item
    string Name;
    
    /**
        Build function
        Name: string
        Normal sound length: uint
        Suppres sound length: uint
        Respond normal sound length: uint
        Suppress respond sound length: uint
    **/
    CVoiceData(string _Name, uint _intNormal, uint _intSuppress, uint _intReNormal, uint _intReSuppress)
    {
        Name = _Name;

        string szTemp = "";

        for(uint i = 1; i <= _intNormal; i++)
			{ aryIntNormal.insertLast(SoundPathBuilder(_Name, "int", "unsupp", i)); }

        for(uint i = 1; i <= _intSuppress; i++)
			{ aryIntSuppress.insertLast(SoundPathBuilder(_Name, "int", "supp", i)); }

        for(uint i = 1; i <= _intReNormal; i++)
			{ aryReintNormal.insertLast(SoundPathBuilder(_Name, "res", "unsupp", i)); }

        for(uint i = 1; i <= _intReSuppress; i++)
			{ aryReintSuppress.insertLast(SoundPathBuilder(_Name, "res", "supp", i)); }
    }
    /**
        Precache Sound file
    **/
    void Precache()
    {
        for(uint i = 0; i < aryIntNormal.length(); i++)
        {
            g_SoundSystem.PrecacheSound(aryIntNormal[i]);
            g_Game.PrecacheGeneric("sound/" + aryIntNormal[i] );
        }
        for(uint i = 0; i < aryIntSuppress.length(); i++)
        {
            g_SoundSystem.PrecacheSound(aryIntSuppress[i]);
            g_Game.PrecacheGeneric("sound/" + aryIntSuppress[i] );
        }
        for(uint i = 0; i < aryReintNormal.length(); i++)
        {
            g_SoundSystem.PrecacheSound(aryReintNormal[i]);
            g_Game.PrecacheGeneric("sound/" + aryReintNormal[i] );
        }
        for(uint i = 0; i < aryReintSuppress.length(); i++)
        {
            g_SoundSystem.PrecacheSound(aryReintSuppress[i]);
            g_Game.PrecacheGeneric("sound/" + aryReintSuppress[i] );
        }
    }
    /**
        Get random sound sample
        voice statue: int
    **/
    string GetRndSound(int type = VOICE_INTNORMAL)
    {
        switch(type)
        {
            case VOICE_INTNORMAL:return aryIntNormal[Math.RandomLong(0, aryIntNormal.length() - 1)];
            case VOICE_INTSUP:return aryIntSuppress[Math.RandomLong(0, aryIntSuppress.length() - 1)];
            case VOICE_RESNORMAL:return aryReintNormal[Math.RandomLong(0, aryReintNormal.length() - 1)];
            case VOICE_RESSUP:
            default:return aryReintSuppress[Math.RandomLong(0, aryReintSuppress.length() - 1)];
        }
        return aryIntNormal[Math.RandomLong(0, aryIntNormal.length() - 1)];
    }
}
//Player data item class
class CPlayerData
{
    int iVoiceType = 0;
    float flLastInti = 0;
	float flDamageTime = 0;
}
/**
    Sound sample path builder
    voice type name: string
    int or reint: string
    suppress or normal: string
    file index: uint
**/
string SoundPathBuilder(string name, string subDir, string dubDir, uint index)
{
    return szPathHeader + "/" + name + "/" + subDir + "/" + dubDir + " (" + index + ").mp3";
}
/**
    New voice register
    voice type name: string
    int normal length: uint
    int supress length: uint
    reint normal length: uint
    reint supress length: uint
**/
void AddNewVoice(string name, uint a, uint b, uint c, uint d)
{
    aryVoiceBank.insertLast(CVoiceData(name, a, b, c, d));
}
/**
    Precache all voice sample file
**/
void PrecacheAll()
{
    for(uint i = 0; i < aryVoiceBank.length(); i++)
		{aryVoiceBank[i].Precache();}
}
/**
    Get CPlayerData by player
    player: ref
**/
CPlayerData@ GetPlayerData(CBasePlayer@ pPlayer)
{
    CPlayerData@ pTemp = null;
    dicPlayerBank.get(g_EngineFuncs.GetPlayerAuthId(pPlayer.edict()), @pTemp);
    return pTemp;
}
/**
    Registe new player data
    player: ref
**/
CPlayerData@ AddPlayerData(CBasePlayer@ pPlayer)
{
    CPlayerData pTemp;
    pTemp.iVoiceType = pPlayer.entindex() % aryVoiceBank.length();
    dicPlayerBank.set(g_EngineFuncs.GetPlayerAuthId(pPlayer.edict()), @pTemp);
    return @pTemp;
}
/**
    Get player voice type
    playerdata: ref
**/
int GetPlayerVoiceType(CPlayerData@ pData)
{
	if(g_Engine.time < flPanicTime)
		return VOICE_INTNORMAL;
	else
		return g_Engine.time - pData.flDamageTime <= flPanicTime ? VOICE_INTSUP : VOICE_INTNORMAL;
}

CClientCommand g_VoiceAlert(szTauntKeyword, "Taunting to monsters", @Voice);
/**
    the client command
    command arguments: ref
**/
void Voice(const CCommand@ pArgs) 
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    //dead people can't speak
    if(pPlayer is null || !pPlayer.IsAlive())
        return;
    //registe new data if no data
    CPlayerData@ pData = GetPlayerData(pPlayer);
    if(pData is null)
        @pData = AddPlayerData(pPlayer);
    //freezing to prevent flooding
    if(Math.max(g_Engine.time - pData.flLastInti, 0) <= flFreezeTime)
        return; 
    pData.flLastInti = g_Engine.time;
    //if has arguments
    if(pArgs.ArgC() > 1)
	{
		string szTemp = pArgs.Arg(1);
		szTemp.Trim();
		//numeric arguments, set sound index directly
		if(!isalpha(pArgs.Arg(1)))
			pData.iVoiceType = Math.clamp(0, aryVoiceBank.length() - 1, atoi(pArgs.Arg(1)));
		else
        //non-numeric arguments, found sound index to set
			for(uint i = 0; i < aryVoiceBank.length(); i++)
			{
				if(tolower(aryVoiceBank[i].Name) == tolower(szTemp))
				{
					pData.iVoiceType = i;
					break;
				}
			}
	}
    //print message to all players
    g_PlayerFuncs.SayTextAll(pPlayer, string(pPlayer.pev.netname) + ": " + szAlertMessage + "\n");
    //play sound sample
    g_SoundSystem.PlaySound(
        pPlayer.edict(), 
        CHAN_AUTO, 
        aryVoiceBank[pData.iVoiceType].GetRndSound(GetPlayerVoiceType(pData)), 
        1.0f, 1.0f);
    //delay set monster responding
    g_Scheduler.SetTimeout("MonsertRespond", flRespondDelay, @pPlayer, pPlayer.pev.origin);
}
/**
    can monster respond taunting?
    taunting player: ref
    be taunting monster: ref
**/
bool CanMonsterRespond(CBasePlayer@ pPlayer, CBaseEntity@ pEntity)
{
    return pEntity.IRelationship(pPlayer) > R_NO && pEntity.IsAlive() && 
            pEntity.IsMonster() && !pPlayer.FVisible(pEntity, true);
}
/**
    is monster playing map scripts?
    be taunting monster: ref
**/
bool IsMonsterInScripts(CBaseMonster@ pMonster)
{
	return pMonster.m_MonsterState < MONSTERSTATE_SCRIPT && 
			pMonster.pev.spawnflags & SF_MONSTER_PRISONER == 0 && 
			pMonster.pev.spawnflags & SF_MONSTER_WAIT_FOR_SCRIPT == 0 &&
			pMonster.pev.spawnflags & SF_MONSTER_PREDISASTER  == 0 &&
			pMonster.pev.spawnflags & SF_MONSTER_FADECORPSE	 == 0;
}
/**
    Get monster uuid by multi method
    be taunting monster: ref
**/
int GetMonsterUID(CBaseMonster@ pMonster)
{
    switch(iMonsterUID)
    {
        case 0:return pMonster.edict().serialnumber;
        case 1:return pMonster.entindex();
        case 2:return pMonster.pev.modelindex;
        case 3:return pMonster.pev.spawnflags;
        case 4:return pMonster.edict().headnode;
    }
    return -1;
}
/**
    Is monster suppress
    be taunting monster: ref
**/
int IsMonsterSuppress(CBaseMonster@ pMonster)
{
	if(pMonster.m_MonsterState & MONSTERSTATE_COMBAT != 0 || pMonster.m_MonsterState & MONSTERSTATE_ALERT != 0)
		return VOICE_RESSUP;
	return VOICE_RESNORMAL;
}
/**
    Monster respond player taunting
    player: ref
    player old origin: Vector
**/
void MonsertRespond(CBasePlayer@ pPlayer, Vector vecOrigin)
{
    CBaseEntity@ pEntity = null;
    CBaseMonster@ pMonster = null;
    while((@pEntity = g_EntityFuncs.FindEntityInSphere(
        pEntity, 
        vecOrigin, 
        flSoundRadius,
        "monster_*",
        "classname")) !is null)
    {
        //is in whitelist/black list?
        if(bIsEnable)
        {
            if(aryAvaliable.find(string(pEntity.pev.classname)) < 0 && !bIsBlackList)
                return;
            else if (aryAvaliable.find(string(pEntity.pev.classname)) >= 0 && bIsBlackList)
                return;
        }

        if(CanMonsterRespond(pPlayer, pEntity))
        {		
            @pMonster = cast<CBaseMonster@>(pEntity);
			if(!IsMonsterInScripts(pMonster))
				return;
				
            pMonster.PushEnemy(pPlayer, vecOrigin);
			pMonster.m_hTargetEnt = pMonster.m_hEnemy = pPlayer;
			pMonster.m_vecEnemyLKP = vecOrigin;
			pMonster.SetConditions(bits_COND_HEAR_SOUND | bits_COND_SEE_ENEMY);
			pMonster.m_afSoundTypes &= bits_SOUND_PLAYER;
        }
    }

    if(@pMonster !is null)
    {
        if(pMonster.pev.spawnflags & SF_MONSTER_WAIT_TILL_SEEN != 0)
            pMonster.pev.spawnflags &= ~SF_MONSTER_WAIT_TILL_SEEN;
		pMonster.SetConditions(bits_COND_SEE_CLIENT);

        g_SoundSystem.PlaySound(
            pMonster.edict(), 
            CHAN_AUTO, 
            aryVoiceBank[GetMonsterUID(pMonster) % aryVoiceBank.length()].GetRndSound( IsMonsterSuppress(pMonster) ), 
			1.0f, 1.0f);
    }
}
/**
    playertakedamage
    damage info: ref
**/
HookReturnCode PlayerTakeDamage( DamageInfo@ pDamageInfo )
{
    CBasePlayer@ pVictim = cast<CBasePlayer@>(pDamageInfo.pVictim);
	if(pVictim is null)
		return HOOK_CONTINUE;
    if(pVictim.IsConnected() && pVictim.IsAlive())
    {
		GetPlayerData(pVictim).flDamageTime = g_Engine.time;
    }
    return HOOK_CONTINUE;
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo( "Bruh" );
	
	g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage);
    //registe voice da
    //normal
    //normal supress
    //respond
    //respond supress
	AddNewVoice("female", 8, 8, 8, 8);
    AddNewVoice("agent", 9, 8, 9, 8);
    AddNewVoice("american", 8, 8, 10, 11);
    AddNewVoice("insurgent", 8, 8, 8, 8);
    AddNewVoice("male", 8, 8, 8, 8);
	AddNewVoice("russian", 10, 8, 13, 11);
}

void MapInit()
{
    PrecacheAll();
}
