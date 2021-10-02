enum GRUNT_WEAPONS{
    HGRUNT_9MMAR = 1 << 0,
    HGRUNT_HANDGRENADE = 1 << 1,
    HGRUNT_GRENADELAUNCHER = 1 << 2,
    HGRUNT_SHOTGUN = 1 << 3
}
enum GRUNT_TASK
{
	TASK_GRUNT_FACE_TOSS_DIR = LAST_COMMON_TASK + 1,
	TASK_GRUNT_SPEAK_SENTENCE,
	TASK_GRUNT_CHECK_FIRE,
    TASK_SAY_RELOAD
};
enum HGRUNT_SENTENCE_TYPES
{
	HGRUNT_SENT_NONE = -1,
	HGRUNT_SENT_GREN = 0,
	HGRUNT_SENT_ALERT,
	HGRUNT_SENT_MONSTER,
	HGRUNT_SENT_COVER,
	HGRUNT_SENT_THROW,
	HGRUNT_SENT_CHARGE,
	HGRUNT_SENT_TAUNT,
};

enum GRUNT_SCHED
{
	SCHED_GRUNT_SUPPRESS = LAST_COMMON_SCHEDULE + 1,
	SCHED_GRUNT_ESTABLISH_LINE_OF_FIRE,// move to a location to set up an attack against the enemy. (usually when a friendly is in the way).
	SCHED_GRUNT_COVER_AND_RELOAD,
	SCHED_GRUNT_SWEEP,
	SCHED_GRUNT_FOUND_ENEMY,
	SCHED_GRUNT_REPEL,
	SCHED_GRUNT_REPEL_ATTACK,
	SCHED_GRUNT_REPEL_LAND,
	SCHED_GRUNT_WAIT_FACE_ENEMY,
	SCHED_GRUNT_TAKECOVER_FAILED,// special schedule type that forces analysis of conditions and picks the best possible schedule to recover from this type of failure.
	SCHED_GRUNT_ELOF_FAIL,
};

const int HEAD_GROUP = 1;

const int GUN_GROUP = 2;
const int GUN_MP5 = 0;
const int GUN_SHOTGUN = 1;
const int GUN_NONE = 2;

const int GRUNT_CLIP_SIZE = 36; // how many bullets in a clip? - NOTE: 3 round burst sound, so keep as 3 * x!

const float GRUNT_ATTN = ATTN_NORM;	// attenutation of grunt sentences
const int HGRUNT_LIMP_HEALTH = 20;
const int HGRUNT_DMG_HEADSHOT = ( DMG_BULLET | DMG_CLUB );	// damage types that can kill a grunt with a single headshot.
const int HGRUNT_NUM_HEADS = 2; // how many grunt heads are there? 
const int HGRUNT_MINIMUM_HEADSHOT_DAMAGE = 15; // must do at least this much damage in one shot to head to score a headshot kill
const float HGRUNT_SENTENCE_VOLUME = 0.35; // volume of grunt sentences
const int bits_COND_GRUNT_NOFIRE = bits_COND_SPECIAL1;
const int TASKSTATUS_RUNNING = 1;
const int TASKSTATUS_COMPLETE = 4;
const int SF_MONSTER_GAG = 2;
const int ACTIVITY_NOT_AVAILABLE = -1;

enum INSBOT_HANIMATION{
    HGRUNT_AE_RELOAD = 2,
    HGRUNT_AE_KICK, 
    HGRUNT_AE_BURST1,
    HGRUNT_AE_BURST2,
    HGRUNT_AE_BURST3,
    HGRUNT_AE_GREN_TOSS,
    HGRUNT_AE_GREN_LAUNCH,
    HGRUNT_AE_GREN_DROP,
    HGRUNT_AE_CAUGHT_ENEMY,
    HGRUNT_AE_DROP_GUN
}

class CInsurgencyBotVoiceItem
{
    string szName = "";
    array<CInsurgencyBotVoicePair@>@ aryItems = null;

    CInsurgencyBotVoiceItem(string s , array<CInsurgencyBotVoicePair@>@ d){
        szName = s;
        @aryItems = d;
    }

    string Get(string Key){
        for(uint i = 0; i < aryItems.length(); i++){
            if(aryItems[i].szName == Key)
                return szInsBotVoicePath + szName + "/" + Key + " (" + Math.RandomLong(1, aryItems[i].iCount) + ").mp3";
        }
        return "";
    }

    void Precache(){
        for(uint i = 0; i < aryItems.length(); i++){
            string szPath = szInsBotVoicePath + szName + "/" + aryItems[i].szName + " (";
            for(int j = 1; j <= aryItems[i].iCount;j++){
                //g_Game.PrecacheGeneric("sound/" + szPath + j + ").mp3");
                g_SoundSystem.PrecacheSound(szPath + j + ").mp3");
            }
        }
    }
}

class CInsurgencyBotVoicePair{
    string szName;
    int iCount;
    CInsurgencyBotVoicePair(string s, int i){
        szName = s;
        iCount = i;
    }
}
class CInsurgencyBotVoice{
    CInsurgencyBotVoiceItem pArab1("Arab1", 
                {
                    CInsurgencyBotVoicePair("BotSpot/", 8),
                    CInsurgencyBotVoicePair("EnemyDown/Su", 8),
                    CInsurgencyBotVoicePair("EnemyDown/Un", 8),
                    CInsurgencyBotVoicePair("FlameDeath/", 6),
                    CInsurgencyBotVoicePair("FlashOut/Su", 7),
                    CInsurgencyBotVoicePair("FlashOut/Un", 8),
                    CInsurgencyBotVoicePair("FragOut/Su", 8),
                    CInsurgencyBotVoicePair("FragOut/Un", 8),
                    CInsurgencyBotVoicePair("FriendlyDown/", 8),
                    CInsurgencyBotVoicePair("FriendlyFire/", 5),
                    CInsurgencyBotVoicePair("HearEnemy/", 10),
                    CInsurgencyBotVoicePair("IncendiaryOut/Su", 5),
                    CInsurgencyBotVoicePair("IncendiaryOut/Un", 5),
                    CInsurgencyBotVoicePair("Inti/Su", 8),
                    CInsurgencyBotVoicePair("Inti/Un", 8),
                    CInsurgencyBotVoicePair("IntiRes/Su", 8),
                    CInsurgencyBotVoicePair("IntiRes/Un", 8),
                    CInsurgencyBotVoicePair("LastOneStanding/", 8),
                    CInsurgencyBotVoicePair("MolotovOut/Su", 5),
                    CInsurgencyBotVoicePair("MolotovOut/Un", 5),
                    CInsurgencyBotVoicePair("ReceiveDamage/", 15),
                    CInsurgencyBotVoicePair("Reloading/Su", 12),
                    CInsurgencyBotVoicePair("Reloading/Un", 8),
                    CInsurgencyBotVoicePair("SmokeOut/Su", 8),
                    CInsurgencyBotVoicePair("SmokeOut/Un", 8),
                    CInsurgencyBotVoicePair("SpotFrag/", 5),
                    CInsurgencyBotVoicePair("SpotRocket/", 5),
                    CInsurgencyBotVoicePair("SuppressedByExplosive/", 5),
                    CInsurgencyBotVoicePair("SupressedBySniper/", 5)
                });
}
CInsurgencyBotVoice g_InsVoice;

const string szInsBotVoicePath = "insbot/";

class CInsurgencyBotMonster : ScriptBaseMonsterEntity
{
	CInsurgencyBotVoiceItem@ pVoice = g_InsVoice.pArab1;
    int iCommanderIndex = -1;
    int iMyIndex = -1;
    uint iSquardNumber = 1;

    // checking the feasibility of a grenade toss is kind of costly, so we do it every couple of seconds,
	// not every server frame.
	float m_flNextGrenadeCheck;
	float m_flNextPainTime;
	float m_flLastEnemySightTime;

	Vector	m_vecTossVelocity;

	bool m_fThrowGrenade;
	bool m_fStanding;
	bool m_fFirstEncounter;// only put on the handsign show in the squad's first encounter.
	int m_cClipSize;

	int m_voicePitch;

	int m_iBrassShell;
	int m_iShotgunShell;

    float m_iHurtTime;

    private string szModel = "models/hlclassic/hgrunt.mdl";
    private string szShellModel = "models/shell.mdl";
    private string szShotShellModel = "models/shell.mdl";
    private int iShotPellet = 12;
    private int iKickDamage = 10;
    private float iGrenadeSpeed = 800;

    void Precache()
    {
        g_Game.PrecacheModel(szModel);
        g_Game.PrecacheGeneric(szModel);

        m_iBrassShell = g_Game.PrecacheModel(szShellModel);
        g_Game.PrecacheGeneric(szShellModel);

        m_iShotgunShell = g_Game.PrecacheModel(szShotShellModel);
        g_Game.PrecacheGeneric(szShotShellModel);

		m_voicePitch = Math.RandomLong(0,1) == 1 ? 109 + Math.RandomLong(0,7) : 0;
    }

    void Spawn()
    {
        InitSchedule();
        Precache();
        g_EntityFuncs.SetModel(self, szModel);
        g_EntityFuncs.SetSize(pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX);
        pev.solid            = SOLID_SLIDEBOX;
        pev.movetype        = MOVETYPE_STEP;
        self.m_bloodColor        = BLOOD_COLOR_RED;
        pev.effects        = 0;
        pev.health            = 300;
        self.m_flFieldOfView        = VIEW_FIELD_WIDE;
        self.m_MonsterState        = MONSTERSTATE_NONE;
        self.m_afCapability        = bits_CAP_RANGE_ATTACK1 | bits_CAP_RANGE_ATTACK2 | bits_CAP_HEAR | 
                                        bits_CAP_MELEE_ATTACK1 | bits_CAP_DOORS_GROUP | 
                                        bits_CAP_SQUAD | bits_CAP_FALL_DAMAGE | bits_CAP_TURN_HEAD;

        m_flNextGrenadeCheck = g_Engine.time + 1;
	    m_flNextPainTime	= g_Engine.time;
        self.m_HackedGunPos        = Vector( 0, 0, 55 );
        self.m_FormattedName = "BOT";
        pev.skin = Math.RandomFloat(0, 1) < 0.8 ?  0 : 1;	// light skin
        
	    m_fFirstEncounter	= true;// this is true when the grunt spawns, because he hasn't encountered an enemy yet.

        if (pev.weapons == 0)
            pev.weapons = HGRUNT_9MMAR | HGRUNT_HANDGRENADE;

        if (pev.weapons & HGRUNT_SHOTGUN != 0)
        {
            self.SetBodygroup( GUN_GROUP, GUN_SHOTGUN );
            m_cClipSize = 8;
        }
        else
            m_cClipSize		= GRUNT_CLIP_SIZE;
        self.m_cAmmoLoaded		= m_cClipSize;

        if (pev.weapons & HGRUNT_SHOTGUN != 0)
            self.SetBodygroup( HEAD_GROUP, 2);
        else if (pev.weapons & HGRUNT_GRENADELAUNCHER != 0)
            self.SetBodygroup( HEAD_GROUP, 3 );
            pev.skin = 1; // alway dark skin
        self.MonsterInit();
    }

    int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType )
    {
        self.Forget( bits_MEMORY_INCOVER );
        m_iHurtTime = g_Engine.time;
        return BaseClass.TakeDamage ( pevInflictor, pevAttacker, flDamage, bitsDamageType );
    }

    bool IsSupress(){
        return g_Engine.time - m_iHurtTime <= 5;
    }

    int Classify()
    {
        return CLASS_HUMAN_MILITARY;
    }

    void SetYawSpeed ()
    {
        int ys;
        switch ( self.m_Activity )
        {
            case ACT_IDLE: ys = 150; break;
            case ACT_RUN: ys = 150; break;
            case ACT_WALK: ys = 180; break;
            case ACT_RANGE_ATTACK1: ys = 120; break;
            case ACT_RANGE_ATTACK2: ys = 120; break;
            case ACT_MELEE_ATTACK1:	ys = 120; break;
            case ACT_MELEE_ATTACK2: ys = 120; break;
            case ACT_TURN_LEFT:
            case ACT_TURN_RIGHT: ys = 180; break;
            case ACT_GLIDE:
            case ACT_FLY: ys = 30; break;
            default: ys = 90; break;
        }
        pev.yaw_speed = ys;
    }

    void CheckAmmo ()
    {
        if ( self.m_cAmmoLoaded <= 0 )
            self.SetConditions(bits_COND_NO_AMMO_LOADED);
    }

    CBaseEntity@ Kick()
    {
        TraceResult tr;
        Math.MakeVectors( pev.angles );
        Vector vecStart = pev.origin;
        vecStart.z += pev.size.z * 0.5;
        Vector vecEnd = vecStart + g_Engine.v_forward * 70;
        g_Utility.TraceHull( vecStart, vecEnd, dont_ignore_monsters, head_hull, self.edict(), tr );

        if ( tr.pHit !is null )
        {
            CBaseEntity@ pEntity = g_EntityFuncs.Instance(tr.pHit);
            return pEntity;
        }
        return null;
    }

    Vector GetGunPosition()
    {
        if (m_fStanding)
            return pev.origin + Vector( 0, 0, 60 );
        else
            return pev.origin + Vector( 0, 0, 48 );
    }

    void Shoot()
    {
        if (!self.m_hEnemy.IsValid())
            return;
        Vector vecShootOrigin = GetGunPosition();
        Vector vecShootDir = self.ShootAtEnemy( vecShootOrigin );

        Math.MakeVectors ( pev.angles );

        Vector	vecShellVelocity = g_Engine.v_right * Math.RandomFloat(40,90) + g_Engine.v_up * Math.RandomFloat(75,200) + g_Engine.v_forward * Math.RandomFloat(-40, 40);
        g_EntityFuncs.EjectBrass ( vecShootOrigin - vecShootDir * 24, vecShellVelocity, pev.angles.y, m_iBrassShell, TE_BOUNCE_SHELL); 
        self.FireBullets(1, vecShootOrigin, vecShootDir, VECTOR_CONE_10DEGREES, 2048, BULLET_MONSTER_MP5 ); // shoot +-5 degrees
        pev.effects |= EF_MUZZLEFLASH;
        self.m_cAmmoLoaded--;// take away a bullet!
        Vector angDir = Math.VecToAngles( vecShootDir );
        self.SetBlending( 0, angDir.x );
    }

    void Shotgun ()
    {
        if (!self.m_hEnemy.IsValid())
            return;
        Vector vecShootOrigin = GetGunPosition();
        Vector vecShootDir = self.ShootAtEnemy( vecShootOrigin );

        Math.MakeVectors ( pev.angles );

        Vector	vecShellVelocity = g_Engine.v_right * Math.RandomFloat(40,90) + g_Engine.v_up * Math.RandomFloat(75,200) + g_Engine.v_forward * Math.RandomFloat(-40, 40);
        g_EntityFuncs.EjectBrass ( vecShootOrigin - vecShootDir * 24, vecShellVelocity, pev.angles.y, m_iShotgunShell, TE_BOUNCE_SHOTSHELL); 
        self.FireBullets(iShotPellet, vecShootOrigin, vecShootDir, VECTOR_CONE_15DEGREES, 2048, BULLET_PLAYER_BUCKSHOT, 0 ); // shoot +-7.5 degrees

        pev.effects |= EF_MUZZLEFLASH;
        
        self.m_cAmmoLoaded--;// take away a bullet!

        Vector angDir = Math.VecToAngles( vecShootDir );
        self.SetBlending( 0, angDir.x );
    }

    void HandleAnimEvent( MonsterEvent@ pEvent )
    {
        Vector	vecShootDir;
        Vector	vecShootOrigin;
        switch( pEvent.event )
        {
            case HGRUNT_AE_DROP_GUN:
            {
                Vector	vecGunPos;
                Vector	vecGunAngles;
                self.GetAttachment( 0, vecGunPos, vecGunAngles );

                // switch to body group with no gun.
                self.SetBodygroup( GUN_GROUP, GUN_NONE );

                // now spawn a gun.
                if (pev.weapons & HGRUNT_SHOTGUN != 0)
                    self.DropItem( "weapon_shotgun", vecGunPos, vecGunAngles );
                else
                    self.DropItem( "weapon_9mmAR", vecGunPos, vecGunAngles );
                if (pev.weapons & HGRUNT_GRENADELAUNCHER != 0)
                    self.DropItem( "ammo_ARgrenades", self.BodyTarget( pev.origin ), vecGunAngles );
                break;
            }

            case HGRUNT_AE_RELOAD:
                //g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "hgrunt/gr_reload1.wav", 1, ATTN_NORM );
                self.m_cAmmoLoaded = m_cClipSize;
                self.ClearConditions(bits_COND_NO_AMMO_LOADED);
                break;

            case HGRUNT_AE_GREN_TOSS:
            {
                Math.MakeVectors( pev.angles );
                // CGrenade::ShootTimed( pev, pev.origin + g_Engine.v_forward * 34 + Vector (0, 0, 32), m_vecTossVelocity, 3.5 );
                g_EntityFuncs.ShootTimed( pev, GetGunPosition(), m_vecTossVelocity, 3.5 );
                m_fThrowGrenade = false;
                m_flNextGrenadeCheck = g_Engine.time + 6;// wait six seconds before even looking again to see if a grenade can be thrown.
                // !!!LATER - when in a group, only try to throw grenade if ordered.
            }
            break;
            case HGRUNT_AE_GREN_LAUNCH:
            {
                //g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_WEAPON, "weapons/glauncher.wav", 0.8, ATTN_NORM);
                g_EntityFuncs.ShootContact( pev, GetGunPosition(), m_vecTossVelocity );
                m_fThrowGrenade = false;
                m_flNextGrenadeCheck = g_Engine.time + Math.RandomFloat( 2, 5 );
            }
            break;

            case HGRUNT_AE_GREN_DROP:
            {
                Math.MakeVectors( pev.angles );
                g_EntityFuncs.ShootTimed( pev, pev.origin + g_Engine.v_forward * 17 - g_Engine.v_right * 27 + g_Engine.v_up * 6, g_vecZero, 3 );
            }
            break;

            case HGRUNT_AE_BURST1:
            {
                if ( pev.weapons & HGRUNT_9MMAR != 0)
                {
                    Shoot();

                    // the first round of the three round burst plays the sound and puts a sound in the world sound list.
                   // if (Math.RandomLong(0,1) == 1)
                        //g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "hgrunt/gr_mgun1.wav", 1, ATTN_NORM );
                    //else
                        //g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "hgrunt/gr_mgun2.wav", 1, ATTN_NORM );
                }
                else
                {
                    Shotgun();
                    //g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_WEAPON, "weapons/sbarrel1.wav", 1, ATTN_NORM );
                }
                //CSoundEnt::InsertSound ( bits_SOUND_COMBAT, pev.origin, 384, 0.3 );
            }
            break;
            case HGRUNT_AE_BURST2:
            case HGRUNT_AE_BURST3:
                Shoot();
                break;
            case HGRUNT_AE_KICK:
            {
                CBaseEntity@ pHurt = Kick();

                if ( pHurt !is null)
                {
                    // SOUND HERE!
                    Math.MakeVectors( pev.angles );
                    pHurt.pev.punchangle.x = 15;
                    pHurt.pev.velocity = pHurt.pev.velocity + g_Engine.v_forward * 100 + g_Engine.v_up * 50;
                    pHurt.TakeDamage( pev, pev, iKickDamage, DMG_CLUB );
                }
            }
            break;
            case HGRUNT_AE_CAUGHT_ENEMY:
            {
                if (FOkToSpeak())
                {
                   // SENTENCEG_PlayRndSz(self.edict(), "HG_ALERT", HGRUNT_SENTENCE_VOLUME, GRUNT_ATTN, 0, m_voicePitch);
                    //JustSpoke();
                }
            }
            default:
                BaseClass.HandleAnimEvent( @pEvent );
                break;
        }
    }

    bool FOkToSpeak()
    {
        // if someone else is talking, don't speak
        //if (g_Engine.time <= CTalkMonster::g_talkWaitTime)
        //    return FALSE;

        if ( pev.spawnflags & SF_MONSTER_GAG != 0)
        {
            if ( self.m_MonsterState != MONSTERSTATE_COMBAT )
                return false;
        }
        return true;
    }

    void StartTask ( Task@ pTask )
    {
        self.m_iTaskStatus = TASKSTATUS_RUNNING;
        switch ( pTask.iTask )
        {
            case TASK_GRUNT_CHECK_FIRE:
            if ( !self.NoFriendlyFire() )
                self.SetConditions( bits_COND_GRUNT_NOFIRE );
            self.TaskComplete();
            break;
            case TASK_GRUNT_SPEAK_SENTENCE:
                //SpeakSentence();
                self.TaskComplete();
            break;
            case TASK_WALK_PATH:
            case TASK_RUN_PATH:
                // grunt no longer assumes he is covered if he moves
                self.Forget( bits_MEMORY_INCOVER );
                BaseClass.StartTask( pTask );
                break;

            case TASK_RELOAD:
                self.m_IdealActivity = ACT_RELOAD;
                break;

            case TASK_GRUNT_FACE_TOSS_DIR:
                break;

            case TASK_FACE_IDEAL:
            case TASK_FACE_ENEMY:
                BaseClass.StartTask( pTask );
                if (pev.movetype == MOVETYPE_FLY)
                    self.m_IdealActivity = ACT_GLIDE;
                break;
            case TASK_SAY_RELOAD:
                g_SoundSystem.EmitSoundDyn(self.edict(), CHAN_VOICE, pVoice.Get(IsSupress() ? "Reloading/Su" : "Reloading/Un"), 1, ATTN_NORM );
                self.TaskComplete();
            default: 
                BaseClass.StartTask( pTask );
                break;
        }
    }

    bool FacingIdeal()
    {
        return abs(self.FlYawDiff()) <= 0.006;
    }

    void RunTask ( Task@ pTask )
    {
        //Logger::Log(pTask.iTask);
        switch ( pTask.iTask )
        {
            case TASK_GRUNT_FACE_TOSS_DIR:
            {
                // project a point along the toss vector and turn to face that point.
                self.MakeIdealYaw( pev.origin + m_vecTossVelocity * 64 );
                self.ChangeYaw( int(pev.yaw_speed) );
                if ( FacingIdeal() )
                    self.m_iTaskStatus = TASKSTATUS_COMPLETE;
                break;
            }
            default: BaseClass.RunTask( @pTask );break;
        }
    }

    void GibMonster ()
    {
        Vector	vecGunPos;
        Vector	vecGunAngles;
        if ( self.GetBodygroup(2) != 2 )
        {
            self.GetAttachment( 0, vecGunPos, vecGunAngles );
            
            CBaseEntity@ pGun = self.DropItem( pev.weapons &  HGRUNT_SHOTGUN != 0 ? "weapon_shotgun" : "weapon_9mmAR", vecGunPos, vecGunAngles );
            if (@pGun !is null)
            {
                pGun.pev.velocity = Vector (Math.RandomFloat(-100,100), Math.RandomFloat(-100,100), Math.RandomFloat(200,300));
                pGun.pev.avelocity = Vector (0, Math.RandomFloat( 200, 400 ), 0 );
            }
        
            if (pev.weapons & HGRUNT_GRENADELAUNCHER  != 0)
            {
                @pGun = self.DropItem( "ammo_ARgrenades", vecGunPos, vecGunAngles );
                if (@pGun !is null)
                {
                    pGun.pev.velocity = Vector (Math.RandomFloat(-100,100), Math.RandomFloat(-100,100), Math.RandomFloat(200,300));
                    pGun.pev.avelocity = Vector ( 0, Math.RandomFloat( 200, 400 ), 0 );
                }
            }
        }
        BaseClass.GibMonster();
    }

    int ISoundMask ()
    {
        return	bits_SOUND_WORLD	|
                bits_SOUND_COMBAT	|
                bits_SOUND_PLAYER	|
                bits_SOUND_DANGER;
    }

    bool FCanCheckAttacks ()
    {
        return !self.HasConditions( bits_COND_ENEMY_TOOFAR );
    }

    bool CheckMeleeAttack1 ( float flDot, float flDist )
    {
        CBaseMonster@ pEnemy = cast<CBaseMonster@>(self.m_hEnemy.GetEntity());
        if ( self.m_hEnemy.IsValid() )
        {
            if ( @pEnemy is null)
                return false;
        }
        return flDist <= 64 && flDot >= 0.7	&& 
            pEnemy.Classify() != CLASS_ALIEN_BIOWEAPON &&
            pEnemy.Classify() != CLASS_PLAYER_BIOWEAPON;
    }

    bool CheckRangeAttack1 ( float flDot, float flDist )
    {
        if ( self.m_hEnemy.IsValid() && !self.HasConditions( bits_COND_ENEMY_OCCLUDED ) && flDist <= 2048 && flDot >= 0.5 && self.NoFriendlyFire() )
        {
            TraceResult	tr;
            if ( !self.m_hEnemy.GetEntity().IsPlayer() && flDist <= 64 )
                return false;

            Vector vecSrc = self.GetGunPosition();
            g_Utility.TraceLine( vecSrc, self.m_hEnemy.GetEntity().BodyTarget(vecSrc), ignore_monsters, ignore_glass, self.edict(), tr);
            if ( tr.flFraction >= 0.9 )
                return true;
        }
        return false;
    }

    bool CheckRangeAttack2 ( float flDot, float flDist )
    {
        if (pev.weapons & (HGRUNT_HANDGRENADE | HGRUNT_GRENADELAUNCHER) == 0)
            return false;
        
        // if the grunt isn't moving, it's ok to check.
        if ( self.m_flGroundSpeed != 0 )
        {
            m_fThrowGrenade = false;
            return m_fThrowGrenade;
        }

        // assume things haven't changed too much since last time
        if (g_Engine.time < m_flNextGrenadeCheck )
            return m_fThrowGrenade;
        
        CBaseEntity@ pEnemy = self.m_hEnemy.GetEntity();
        if(@pEnemy is null)
            return false;

        if ( pEnemy.pev.flags & FL_ONGROUND == 0 && pEnemy.pev.waterlevel == 0 && self.m_vecEnemyLKP.z > pev.absmax.z  )
        {
            m_fThrowGrenade = false;
            return m_fThrowGrenade;
        }
        Vector vecTarget;
        if (pev.weapons & HGRUNT_HANDGRENADE != 0)
            vecTarget = Math.RandomLong(0,1) == 1 ? Vector( pEnemy.pev.origin.x, pEnemy.pev.origin.y, pEnemy.pev.absmin.z ) : self.m_vecEnemyLKP;
        else
        {
            vecTarget = self.m_vecEnemyLKP + (pEnemy.BodyTarget( pev.origin ) - pEnemy.pev.origin);
            if (self.HasConditions( bits_COND_SEE_ENEMY))
                vecTarget = vecTarget + ((vecTarget - pev.origin).Length() / iGrenadeSpeed) * pEnemy.pev.velocity;
        }
        
        if ((vecTarget - pev.origin ).Length2D() <= 256 )
        {
            m_flNextGrenadeCheck = g_Engine.time + 1; 
            m_fThrowGrenade = false;
            return m_fThrowGrenade;
        }

            
        if (pev.weapons & HGRUNT_HANDGRENADE != 0)
        {
            Vector vecToss = VecCheckToss( pev, self.GetGunPosition(), vecTarget, 0.5 );
            if ( vecToss != g_vecZero )
            {
                m_vecTossVelocity = vecToss;
                m_fThrowGrenade = true;
                m_flNextGrenadeCheck = g_Engine.time;
            }
            else
            {
                m_fThrowGrenade = false;
                m_flNextGrenadeCheck = g_Engine.time + 1;
            }
        }
        else
        {
            Vector vecToss = VecCheckThrow( pev, self.GetGunPosition(), vecTarget, iGrenadeSpeed, 0.5 );

            if ( vecToss != g_vecZero )
            {
                m_vecTossVelocity = vecToss;
                m_fThrowGrenade = true;
                m_flNextGrenadeCheck = g_Engine.time + 0.3; // 1/3 second.
            }
            else
            {
                m_fThrowGrenade = false;
                m_flNextGrenadeCheck = g_Engine.time + 1; // one full second.
            }
        }
        return m_fThrowGrenade;
    }

    Vector VecCheckToss ( entvars_t@pev, Vector vecSpot1, Vector vecSpot2 , float flGravMulti)
    {
        TraceResult        tr;
        Vector            vecMidPoint;
        Vector            vecApex;
        Vector            vecScale;
        Vector            vecGrenadeVel;
        Vector            vecTemp;
        float            flGravity = g_EngineFuncs.CVarGetFloat("sv_gravity");

        if (vecSpot2.z - vecSpot1.z > 500)
            return g_vecZero;

        Math.MakeVectors (pev.angles);

        vecSpot2 = vecSpot2 + g_Engine.v_right * ( Math.RandomFloat(-8,8) + Math.RandomFloat(-16,16) );
        vecSpot2 = vecSpot2 + g_Engine.v_forward * ( Math.RandomFloat(-8,8) + Math.RandomFloat(-16,16) );
        vecMidPoint = vecSpot1 + (vecSpot2 - vecSpot1) * 0.5;
        g_Utility.TraceLine(vecMidPoint, vecMidPoint + Vector(0,0,500), ignore_monsters, self.edict(), tr);
        vecMidPoint = tr.vecEndPos;
        vecMidPoint.z -= 15;
        if (vecMidPoint.z < vecSpot1.z || vecMidPoint.z < vecSpot2.z)
            return g_vecZero;

        float distance1 = (vecMidPoint.z - vecSpot1.z);
        float distance2 = (vecMidPoint.z - vecSpot2.z);

        float time1 = sqrt( distance1 / (flGravMulti * flGravity));
        float time2 = sqrt( distance2 / (flGravMulti * flGravity));

        if (time1 < 0.1)
            return g_vecZero;

        vecGrenadeVel = (vecSpot2 - vecSpot1) / (time1 + time2);
        vecGrenadeVel.z = flGravity * time1;

        vecApex  = vecSpot1 + vecGrenadeVel * time1;
        vecApex.z = vecMidPoint.z;

        g_Utility.TraceLine(vecSpot1, vecApex, dont_ignore_monsters, self.edict(), tr);
        if (tr.flFraction != 1.0)
            return g_vecZero;

        if (tr.flFraction != 1.0)
            return g_vecZero;
        return vecGrenadeVel;
    }

    Vector VecCheckThrow ( entvars_t@ pev, const Vector vecSpot1, Vector vecSpot2, float flSpeed, float flGravityAdj )
    {
        float flGravity = g_EngineFuncs.CVarGetFloat("sv_gravity") * flGravityAdj;

        Vector vecGrenadeVel = (vecSpot2 - vecSpot1);

        // throw at a constant time
        float time = vecGrenadeVel.Length( ) / flSpeed;
        vecGrenadeVel = vecGrenadeVel * (1.0 / time);

        // adjust upward toss to compensate for gravity loss
        vecGrenadeVel.z += flGravity * time * 0.5;

        Vector vecApex = vecSpot1 + (vecSpot2 - vecSpot1) * 0.5;
        vecApex.z += 0.5 * flGravity * (time * 0.5) * (time * 0.5);
        
        TraceResult tr;
        g_Utility.TraceLine(vecSpot1, vecApex, dont_ignore_monsters, self.edict(), tr);
        if (tr.flFraction != 1.0)
            return g_vecZero;

        g_Utility.TraceLine(vecSpot2, vecApex, ignore_monsters, self.edict(), tr);
        if (tr.flFraction != 1.0)
        {
            // fail!
            return g_vecZero;
        }

        return vecGrenadeVel;
    }

    void TraceAttack( entvars_t@ pevAttacker, float flDamage, Vector vecDir, TraceResult ptr, int bitsDamageType)
    {
        // check for helmet shot
        if (ptr.iHitgroup == 11)
        {
            // it's head shot anyways
            ptr.iHitgroup = HITGROUP_HEAD;
        }
        BaseClass.TraceAttack( pevAttacker, flDamage, vecDir, ptr, bitsDamageType );
    }

    void SetActivity ( Activity NewActivity )
    {
        int	iSequence = ACTIVITY_NOT_AVAILABLE;
        switch (NewActivity)
        {
            case ACT_RANGE_ATTACK1:
                iSequence = pev.weapons & HGRUNT_9MMAR != 0 ? 
                    self.LookupSequence( m_fStanding ? "standing_mp5" : "crouching_mp5" ) : 
                    self.LookupSequence( m_fStanding ? "standing_shotgun" : "crouching_shotgun" );
                break;
            case ACT_RANGE_ATTACK2:
                iSequence = self.LookupSequence( pev.weapons & HGRUNT_HANDGRENADE != 0 ? "throwgrenade" : "launchgrenade" );
                break;
            case ACT_RUN:
                iSequence = self.LookupActivity ( pev.health <= HGRUNT_LIMP_HEALTH ? ACT_RUN_HURT : NewActivity );
                break;
            case ACT_WALK:
                iSequence = self.LookupActivity ( pev.health <= HGRUNT_LIMP_HEALTH ? ACT_WALK_HURT : NewActivity );
                break;
            case ACT_IDLE:
                if ( self.m_MonsterState == MONSTERSTATE_COMBAT )
                    NewActivity = ACT_IDLE_ANGRY;
            default:
                iSequence = self.LookupActivity ( NewActivity );
                break;
        }
        
        self.m_Activity = NewActivity;
        if ( iSequence > ACTIVITY_NOT_AVAILABLE )
        {
            if ( pev.sequence != iSequence || !self.m_fSequenceLoops )
                pev.frame = 0;

            pev.sequence = iSequence;
            self.ResetSequenceInfo( );
            self.SetYawSpeed();
        }
        else
            pev.sequence		= 0;
    }

    Schedule@ GetSchedule()
    {
        if ( pev.movetype == MOVETYPE_FLY && self.m_MonsterState != MONSTERSTATE_PRONE )
        {
            if (pev.flags & FL_ONGROUND != 0)
            {
                pev.movetype = MOVETYPE_STEP;
                return GetScheduleOfType ( SCHED_GRUNT_REPEL_LAND );
            }
            else
                return GetScheduleOfType ( self.m_MonsterState == MONSTERSTATE_COMBAT ? SCHED_GRUNT_REPEL_ATTACK : SCHED_GRUNT_REPEL );
        }

        if ( self.HasConditions(bits_COND_HEAR_SOUND) )
        {
            CSound@ pSound = self.PBestSound();
            if (@pSound !is null)
            {
                if (pSound.m_iType & bits_SOUND_DANGER != 0)
                {
                    /**添加嘲讽音效 */
                    return GetScheduleOfType( SCHED_TAKE_COVER_FROM_BEST_SOUND );
                }
            }
        }
        switch	( self.m_MonsterState )
        {
            case MONSTERSTATE_COMBAT:
            {
                if ( self.HasConditions( bits_COND_ENEMY_DEAD ) )
                {
                    /**添加enemy down音效 */
                    // call base class, all code to handle dead enemies is centralized there.
                    return BaseClass.GetSchedule();
                }
                if ( self.HasConditions(bits_COND_NEW_ENEMY) )
                {
                    if (FOkToSpeak())// && Math.RandomLong(0,1))
                    {
                        if (self.m_hEnemy.IsValid() && self.m_hEnemy.GetEntity().IsPlayer())
                        {
                            /**
                            * 添加发现玩家惊讶音效
                            */
                        }
                    }
                    if ( self.HasConditions ( bits_COND_CAN_RANGE_ATTACK1 ) )
                        return GetScheduleOfType ( SCHED_GRUNT_SUPPRESS );
                    else
                        return GetScheduleOfType ( SCHED_GRUNT_ESTABLISH_LINE_OF_FIRE );
                }
                else if ( self.HasConditions ( bits_COND_NO_AMMO_LOADED ) )
                    return GetScheduleOfType ( SCHED_GRUNT_COVER_AND_RELOAD );
                
                else if ( self.HasConditions( bits_COND_LIGHT_DAMAGE ) )
                {
                    int iPercent = Math.RandomLong(0,99);

                    if ( iPercent <= 90 && self.m_hEnemy.IsValid() )
                    {
                        if (FOkToSpeak())
                        {
                            /**
                             * 播放 Im hit im hit
                             */
                        }
                        return GetScheduleOfType( SCHED_TAKE_COVER_FROM_ENEMY );
                    }
                    else
                        return GetScheduleOfType( SCHED_SMALL_FLINCH );
                }
                else if ( self.HasConditions ( bits_COND_CAN_MELEE_ATTACK1 ) )
                    return GetScheduleOfType ( SCHED_MELEE_ATTACK1 );
                else if (pev.weapons & HGRUNT_GRENADELAUNCHER != 0 && self.HasConditions ( bits_COND_CAN_RANGE_ATTACK2 ))
                    return GetScheduleOfType( SCHED_RANGE_ATTACK2 );
                else if ( self.HasConditions ( bits_COND_CAN_RANGE_ATTACK1 ) )
                    return GetScheduleOfType( SCHED_RANGE_ATTACK1 );
                else if ( self.HasConditions( bits_COND_ENEMY_OCCLUDED ) )
                {
                    if ( self.HasConditions( bits_COND_CAN_RANGE_ATTACK2 ))
                    {
                        if (FOkToSpeak())
                        {
                           /**
                            * 播放 hey hey grenade out out
                            */
                        }
                        return GetScheduleOfType( SCHED_RANGE_ATTACK2 );
                    }
                    /*
                    else if ( OccupySlot( bits_SLOTS_HGRUNT_ENGAGE ) )
                    {
                        //!!!KELLY - grunt cannot see the enemy and has just decided to 
                        // charge the enemy's position. 
                        if (FOkToSpeak())// && Math.RandomLong(0,1))
                        {
                            //SENTENCEG_PlayRndSz( ENT(pev), "HG_CHARGE", HGRUNT_SENTENCE_VOLUME, GRUNT_ATTN, 0, m_voicePitch);
                            //JustSpoke();
                        }

                        return GetScheduleOfType( SCHED_GRUNT_ESTABLISH_LINE_OF_FIRE );
                    }
                    */
                    else
                    {
                        if (FOkToSpeak() && Math.RandomLong(0,1) == 1)
                        {
                            /**
                             * 播放 You r in jungle now babe
                             */
                            //SENTENCEG_PlayRndSz( ENT(pev), "HG_TAUNT", HGRUNT_SENTENCE_VOLUME, GRUNT_ATTN, 0, m_voicePitch);
                            //JustSpoke();
                        }
                        return GetScheduleOfType( SCHED_STANDOFF );
                    }
                }
                
                if ( self.HasConditions( bits_COND_SEE_ENEMY ) && !self.HasConditions ( bits_COND_CAN_RANGE_ATTACK1 ) )
                    return GetScheduleOfType ( SCHED_GRUNT_ESTABLISH_LINE_OF_FIRE );
            }
        }
        return BaseClass.GetSchedule();
    }
/**
    array<string> SCHEDULNAME = {"SCHED_NONE", "SCHED_IDLE_STAND", "SCHED_IDLE_WALK", "SCHED_WAKE_ANGRY", "SCHED_WAKE_CALLED", "SCHED_ALERT_FACE", "SCHED_ALERT_SMALL_FLINCH", "SCHED_ALERT_BIG_FLINCH", "SCHED_ALERT_STAND", "SCHED_INVESTIGATE_SOUND", "SCHED_INVESTIGATE_COMBAT", "SCHED_COMBAT_FACE", "SCHED_COMBAT_STAND", "SCHED_CHASE_ENEMY", "SCHED_CHASE_ENEMY_FAILED", "SCHED_VICTORY_DANCE", "SCHED_TARGET_FACE", "SCHED_TARGET_CHASE", "SCHED_SMALL_FLINCH", "SCHED_TAKE_COVER_FROM_ENEMY", "SCHED_TAKE_COVER_FROM_BEST_SOUND", "SCHED_TAKE_COVER_FROM_ORIGIN", "SCHED_COWER", "SCHED_MELEE_ATTACK1", "SCHED_MELEE_ATTACK2", "SCHED_RANGE_ATTACK1", "SCHED_RANGE_ATTACK2", "SCHED_SPECIAL_ATTACK1", "SCHED_SPECIAL_ATTACK2", "SCHED_STANDOFF", "SCHED_ARM_WEAPON", "SCHED_RELOAD", "SCHED_GUARD", "SCHED_AMBUSH", "SCHED_DIE", "SCHED_WAIT_TRIGGER", "SCHED_WAIT_TILL_SEEN", "SCHED_FOLLOW", "SCHED_SLEEP", "SCHED_WAKE", "SCHED_BARNACLE_VICTIM_GRAB", "SCHED_BARNACLE_VICTIM_CHOMP", "SCHED_AISCRIPT", "SCHED_FAIL", "SCHED_TARGET_PLAYERFACE", "SCHED_TARGET_PLAYERCHASE", "SCHED_TARGET_PLAYERCHASE_FORCE", "SCHED_MOVE_AWAY_PLAYERFOLLOW", "SCHED_MOVE_TO_TANK", "SCHED_WAIT_AT_TANK", "SCHED_FIND_ATTACK_POINT", "SCHED_LOSE_ENEMY", "SCHED_RANGE_ATTACK1_DEFAULT", "SCHED_SMALL_FLINCH_SPECIAL", "SCHED_TELEPORT_FALL", "SCHED_GUARD_POINT", "SCHED_PATH_WAYPOINT", 
        "LAST_COMMON_SCHEDULE", 
        "SCHED_GRUNT_SUPPRESS",
	"SCHED_GRUNT_ESTABLISH_LINE_OF_FIRE",
	"SCHED_GRUNT_COVER_AND_RELOAD",
	"SCHED_GRUNT_SWEEP",
	"SCHED_GRUNT_FOUND_ENEMY",
	"SCHED_GRUNT_REPEL",
	"SCHED_GRUNT_REPEL_ATTACK",
	"SCHED_GRUNT_REPEL_LAND",
	"SCHED_GRUNT_WAIT_FACE_ENEMY",
	"SCHED_GRUNT_TAKECOVER_FAILED",
	"SCHED_GRUNT_ELOF_FAIL"}; 
*/

    Schedule@ GetScheduleOfType ( int Type ) 
    {
        //Logger::Log(SCHEDULNAME[Type]);
        switch	( Type )
        {
            case SCHED_TAKE_COVER_FROM_ENEMY: return Math.RandomLong(0,1) == 1 ? slGruntTakeCover : slGruntGrenadeCover;
            case SCHED_TAKE_COVER_FROM_BEST_SOUND: return slGruntTakeCoverFromBestSound;
            case SCHED_GRUNT_TAKECOVER_FAILED: return GetScheduleOfType( self.HasConditions( bits_COND_CAN_RANGE_ATTACK1 ) ? SCHED_RANGE_ATTACK1 : SCHED_FAIL );
            case SCHED_GRUNT_ELOF_FAIL: return GetScheduleOfType ( SCHED_TAKE_COVER_FROM_ENEMY );
            case SCHED_GRUNT_ESTABLISH_LINE_OF_FIRE: return slGruntEstablishLineOfFire;
            case SCHED_RANGE_ATTACK1:
                {
                    // randomly stand or crouch
                    if (Math.RandomLong(0,9) == 0)
                        m_fStanding = Math.RandomLong(0,1) == 1 ? true : false;
                    return m_fStanding ? slGruntRangeAttack1B : slGruntRangeAttack1A;
                }
            case SCHED_RANGE_ATTACK2: return slGruntRangeAttack2;
            case SCHED_COMBAT_FACE: return slGruntCombatFace;
            case SCHED_GRUNT_WAIT_FACE_ENEMY: return slGruntWaitInCover;
            case SCHED_GRUNT_SWEEP: return slGruntSweep;
            case SCHED_GRUNT_COVER_AND_RELOAD: return slGruntHideReload;
            case SCHED_GRUNT_FOUND_ENEMY: return slGruntFoundEnemy;
            case SCHED_VICTORY_DANCE: return slGruntVictoryDance;
            case SCHED_GRUNT_SUPPRESS:
                {
                    if ( self.m_hEnemy.GetEntity().IsPlayer() && m_fFirstEncounter )
                    {
                        m_fFirstEncounter = false;// after first encounter, leader won't issue handsigns anymore when he has a new enemy
                        return slGruntSignalSuppress;
                    }
                    else
                        return slGruntSuppress;
                }
            case SCHED_FAIL: return self.m_hEnemy.IsValid() ? slGruntCombatFail : slGruntFail;
            case SCHED_GRUNT_REPEL:
                {
                    if (pev.velocity.z > -128)
                        pev.velocity.z -= 32;
                    return slGruntRepel;
                }
            case SCHED_GRUNT_REPEL_ATTACK:
                {
                    if (pev.velocity.z > -128)
                        pev.velocity.z -= 32;
                    return slGruntRepelAttack;
                }
            case SCHED_GRUNT_REPEL_LAND: return slGruntRepelLand;  
            }
        return BaseClass.GetScheduleOfType (Type);
    }

    void QuickTasklize(ScriptSchedule@&in slSchedule, array<array<float>>@&in tlTask)
    {
        for(uint i = 0; i < tlTask.length(); i++){
            slSchedule.AddTask(ScriptTask(int(tlTask[i][0]), tlTask[i][1]));
        }                                                                                                                                                           
    }

    void InitSchedule()
    {
        ;;;;;    ;;;;    ;;;;   ;;;;;    ;;;;    ;;;; 
        ;;  ;;  ;;  ;;  ;;  ;;  ;;  ;;  ;;  ;;  ;;  ;;
        ;;;;;   ;;  ;;  ;;  ;;  ;;;;;   ;;  ;;  ;;  ;;
        ;;      ;;  ;;  ;;  ;;  ;;      ;;  ;;  ;;  ;;
        ;;       ;;;;    ;;;;   ;;       ;;;;    ;;;;

         ;;;;    ;;;;   ;;  ;;  ;;;;;;  ;;;;;   ;;  ;;  ;;      ;;;;;; 
        ;;      ;;  ;;  ;;  ;;  ;;      ;;  ;;  ;;  ;;  ;;      ;;     
        ;;;;   ;;      ;;;;;;  ;;;;    ;;  ;;  ;;  ;;  ;;      ;;;;   
            ;;  ;;  ;;  ;;  ;;  ;;      ;;  ;;  ;;  ;;  ;;      ;;     
        ;;;;    ;;;;   ;;  ;;  ;;;;;;  ;;;;;    ;;;;   ;;;;;;  ;;;;;;   

        QuickTasklize(slGruntFail,tlGruntFail);
        QuickTasklize(slGruntCombatFail, tlGruntCombatFail);
        QuickTasklize(slGruntVictoryDance, tlGruntVictoryDance);
        QuickTasklize(slGruntEstablishLineOfFire, tlGruntEstablishLineOfFire);
        QuickTasklize(slGruntFoundEnemy, tlGruntFoundEnemy);
        QuickTasklize(slGruntCombatFace, tlGruntCombatFace1);
        QuickTasklize(slGruntSignalSuppress, tlGruntSignalSuppress);
        QuickTasklize(slGruntSuppress, tlGruntSuppress);
        QuickTasklize(slGruntWaitInCover,tlGruntWaitInCover);
        QuickTasklize(slGruntTakeCover,tlGruntTakeCover1);
        QuickTasklize(slGruntGrenadeCover, tlGruntGrenadeCover1);
        QuickTasklize(slGruntTossGrenadeCover, tlGruntTossGrenadeCover1);
        QuickTasklize(slGruntTakeCoverFromBestSound, tlGruntTakeCoverFromBestSound);
        QuickTasklize(slGruntHideReload, tlGruntHideReload);
        QuickTasklize(slGruntSweep, tlGruntSweep);
        QuickTasklize(slGruntRangeAttack1A, tlGruntRangeAttack1A);
        QuickTasklize(slGruntRangeAttack1B, tlGruntRangeAttack1B);
        QuickTasklize(slGruntRangeAttack2,tlGruntRangeAttack2);
        QuickTasklize(slGruntRepel, tlGruntRepel);
        QuickTasklize(slGruntRepelAttack, tlGruntRepelAttack);
        QuickTasklize(slGruntRepelLand, tlGruntRepelLand);

        @this.m_Schedules = {
            @slGruntFail,
            @slGruntCombatFail,
            @slGruntVictoryDance,
            @slGruntEstablishLineOfFire,
            @slGruntFoundEnemy,
            @slGruntCombatFace,
            @slGruntSignalSuppress,
            @slGruntSuppress,
            @slGruntWaitInCover,
            @slGruntTakeCover,
            @slGruntGrenadeCover,
            @slGruntTossGrenadeCover,
            @slGruntTakeCoverFromBestSound,
            @slGruntHideReload,
            @slGruntSweep,
            @slGruntRangeAttack1A,
            @slGruntRangeAttack1B,
            @slGruntRangeAttack2,
            @slGruntRepel,
            @slGruntRepelAttack,
            @slGruntRepelLand,
        };
    }

    private ScriptSchedule	slGruntFail
    (
            bits_COND_CAN_RANGE_ATTACK1 |
            bits_COND_CAN_RANGE_ATTACK2 |
            bits_COND_CAN_MELEE_ATTACK1 |
            bits_COND_CAN_MELEE_ATTACK2,
            0,
            "Grunt Fail"
    );

    private ScriptSchedule	slGruntCombatFail
    (
            bits_COND_CAN_RANGE_ATTACK1	|
            bits_COND_CAN_RANGE_ATTACK2,
            0,
            "Grunt Combat Fail"
    );

    private ScriptSchedule	slGruntVictoryDance
    ( 
            bits_COND_NEW_ENEMY		|
            bits_COND_LIGHT_DAMAGE	|
            bits_COND_HEAVY_DAMAGE,
            0,
            "GruntVictoryDance"
    );

    private ScriptSchedule slGruntEstablishLineOfFire
    ( 
            bits_COND_NEW_ENEMY			|
            bits_COND_ENEMY_DEAD		|
            bits_COND_CAN_RANGE_ATTACK1	|
            bits_COND_CAN_MELEE_ATTACK1	|
            bits_COND_CAN_RANGE_ATTACK2	|
            bits_COND_CAN_MELEE_ATTACK2	|
            bits_COND_HEAR_SOUND,
            
            bits_SOUND_DANGER,
            "GruntEstablishLineOfFire"
    );

    private ScriptSchedule	slGruntFoundEnemy
    ( 
            bits_COND_HEAR_SOUND,
            bits_SOUND_DANGER,
            "GruntFoundEnemy"
    );

    private ScriptSchedule	slGruntCombatFace
    ( 
            bits_COND_NEW_ENEMY				|
            bits_COND_ENEMY_DEAD			|
            bits_COND_CAN_RANGE_ATTACK1		|
            bits_COND_CAN_RANGE_ATTACK2,
            0,
            "Combat Face"
    );

    private ScriptSchedule	slGruntSignalSuppress
    ( 
            bits_COND_ENEMY_DEAD		|
            bits_COND_LIGHT_DAMAGE		|
            bits_COND_HEAVY_DAMAGE		|
            bits_COND_HEAR_SOUND		|
            bits_COND_GRUNT_NOFIRE		|
            bits_COND_NO_AMMO_LOADED,

            bits_SOUND_DANGER,
            "SignalSuppress"
    );

    private ScriptSchedule	slGruntSuppress
    ( 
            bits_COND_ENEMY_DEAD		|
            bits_COND_LIGHT_DAMAGE		|
            bits_COND_HEAVY_DAMAGE		|
            bits_COND_HEAR_SOUND		|
            bits_COND_GRUNT_NOFIRE		|
            bits_COND_NO_AMMO_LOADED,

            bits_SOUND_DANGER,
            "Suppress"
    );

    private ScriptSchedule	slGruntWaitInCover
    ( 
            bits_COND_NEW_ENEMY			|
            bits_COND_HEAR_SOUND		|
            bits_COND_CAN_RANGE_ATTACK1	|
            bits_COND_CAN_RANGE_ATTACK2	|
            bits_COND_CAN_MELEE_ATTACK1	|
            bits_COND_CAN_MELEE_ATTACK2,

            bits_SOUND_DANGER,
            "GruntWaitInCover"
    );

    private ScriptSchedule	slGruntTakeCover
    ( 
            0,
            0,
            "TakeCover"
    );

    private ScriptSchedule	slGruntGrenadeCover
    ( 
            0,
            0,
            "GrenadeCover"
    );

    private ScriptSchedule	slGruntTossGrenadeCover
    ( 
            0,
            0,
            "TossGrenadeCover"
    );

    private ScriptSchedule	slGruntTakeCoverFromBestSound
    ( 
            0,
            0,
            "GruntTakeCoverFromBestSound"
    );

    private ScriptSchedule slGruntHideReload 
    (
            bits_COND_HEAVY_DAMAGE	|
            bits_COND_HEAR_SOUND,
            bits_SOUND_DANGER,
            "GruntHideReload"
    );

    private ScriptSchedule	slGruntSweep
    ( 
            bits_COND_NEW_ENEMY		|
            bits_COND_LIGHT_DAMAGE	|
            bits_COND_HEAVY_DAMAGE	|
            bits_COND_CAN_RANGE_ATTACK1	|
            bits_COND_CAN_RANGE_ATTACK2	|
            bits_COND_HEAR_SOUND,
            bits_SOUND_WORLD		|
            bits_SOUND_DANGER		|
            bits_SOUND_PLAYER,
            "Grunt Sweep"
    );

    private ScriptSchedule	slGruntRangeAttack1A
    ( 
            bits_COND_NEW_ENEMY			|
            bits_COND_ENEMY_DEAD		|
            bits_COND_HEAVY_DAMAGE		|
            bits_COND_ENEMY_OCCLUDED	|
            bits_COND_HEAR_SOUND		|
            bits_COND_GRUNT_NOFIRE		|
            bits_COND_NO_AMMO_LOADED,
            
            bits_SOUND_DANGER,
            "Range Attack1A"
    );

    private ScriptSchedule	slGruntRangeAttack1B
    ( 
            bits_COND_NEW_ENEMY			|
            bits_COND_ENEMY_DEAD		|
            bits_COND_HEAVY_DAMAGE		|
            bits_COND_ENEMY_OCCLUDED	|
            bits_COND_NO_AMMO_LOADED	|
            bits_COND_GRUNT_NOFIRE		|
            bits_COND_HEAR_SOUND,
            bits_SOUND_DANGER,
            "Range Attack1B"
    );

    private ScriptSchedule	slGruntRangeAttack2
    ( 
            0,
            0,
            "RangeAttack2"
    );

    private ScriptSchedule	slGruntRepel
    ( 
            bits_COND_SEE_ENEMY			|
            bits_COND_NEW_ENEMY			|
            bits_COND_LIGHT_DAMAGE		|
            bits_COND_HEAVY_DAMAGE		|
            bits_COND_HEAR_SOUND,
            bits_SOUND_DANGER			|
            bits_SOUND_COMBAT			|
            bits_SOUND_PLAYER, 
            "Repel"
    );

    private ScriptSchedule	slGruntRepelAttack
    ( 
            bits_COND_ENEMY_OCCLUDED,
            0,
            "Repel Attack"
    );

    private ScriptSchedule slGruntRepelLand
    ( 
            bits_COND_SEE_ENEMY			|
            bits_COND_NEW_ENEMY			|
            bits_COND_LIGHT_DAMAGE		|
            bits_COND_HEAVY_DAMAGE		|
            bits_COND_HEAR_SOUND,
            bits_SOUND_DANGER			|
            bits_SOUND_COMBAT			|
            bits_SOUND_PLAYER, 
            "Repel Land"
    );

    array<array<float>>	tlGruntFail =
    {
        { TASK_STOP_MOVING,			0				},
        { TASK_SET_ACTIVITY,		ACT_IDLE },
        { TASK_WAIT,				2		},
        { TASK_WAIT_PVS,			0		}
    };
    array<array<float>>	tlGruntCombatFail =
    {
        { TASK_STOP_MOVING,			0				},
        { TASK_SET_ACTIVITY,		ACT_IDLE },
        { TASK_WAIT_FACE_ENEMY,		2		},
        { TASK_WAIT_PVS,			0		}
    };
    array<array<float>>	tlGruntVictoryDance =
    {
        { TASK_STOP_MOVING,						0					},
        { TASK_FACE_ENEMY,						0					},
        { TASK_WAIT,							1.5					},
        { TASK_GET_PATH_TO_ENEMY_CORPSE,		0					},
        { TASK_WALK_PATH,						0					},
        { TASK_WAIT_FOR_MOVEMENT,				0					},
        { TASK_FACE_ENEMY,						0					},
        { TASK_PLAY_SEQUENCE,					ACT_VICTORY_DANCE	}
    };
    array<array<float>> tlGruntEstablishLineOfFire = 
    {
        { TASK_SET_FAIL_SCHEDULE,	SCHED_GRUNT_ELOF_FAIL	},
        { TASK_GET_PATH_TO_ENEMY,	0						},
        { TASK_GRUNT_SPEAK_SENTENCE,0						},
        { TASK_RUN_PATH,			0						},
        { TASK_WAIT_FOR_MOVEMENT,	0						}
    };
    array<array<float>>	tlGruntFoundEnemy =
    {
        { TASK_STOP_MOVING,				0							},
        { TASK_FACE_ENEMY,				0					},
        { TASK_PLAY_SEQUENCE_FACE_ENEMY,ACT_SIGNAL1			}
    };
    array<array<float>>	tlGruntCombatFace1 =
    {
        { TASK_STOP_MOVING,				0							},
        { TASK_SET_ACTIVITY,			ACT_IDLE				},
        { TASK_FACE_ENEMY,				0					},
        { TASK_WAIT,					1.5					},
        { TASK_SET_SCHEDULE,			SCHED_GRUNT_SWEEP	}
    };
    array<array<float>>	tlGruntSignalSuppress =
    {
        { TASK_STOP_MOVING,					0						},
        { TASK_FACE_IDEAL,					0				},
        { TASK_PLAY_SEQUENCE_FACE_ENEMY,	ACT_SIGNAL2		},
        { TASK_FACE_ENEMY,					0				},
        { TASK_GRUNT_CHECK_FIRE,			0				},
        { TASK_RANGE_ATTACK1,				0				},
        { TASK_FACE_ENEMY,					0				},
        { TASK_GRUNT_CHECK_FIRE,			0				},
        { TASK_RANGE_ATTACK1,				0				},
        { TASK_FACE_ENEMY,					0				},
        { TASK_GRUNT_CHECK_FIRE,			0				},
        { TASK_RANGE_ATTACK1,				0				},
        { TASK_FACE_ENEMY,					0				},
        { TASK_GRUNT_CHECK_FIRE,			0				},
        { TASK_RANGE_ATTACK1,				0				},
        { TASK_FACE_ENEMY,					0				},
        { TASK_GRUNT_CHECK_FIRE,			0				},
        { TASK_RANGE_ATTACK1,				0				}
    };
    array<array<float>>	tlGruntSuppress =
    {
        { TASK_STOP_MOVING,			0							},
        { TASK_FACE_ENEMY,			0					},
        { TASK_GRUNT_CHECK_FIRE,	0					},
        { TASK_RANGE_ATTACK1,		0					},
        { TASK_FACE_ENEMY,			0					},
        { TASK_GRUNT_CHECK_FIRE,	0					},
        { TASK_RANGE_ATTACK1,		0					},
        { TASK_FACE_ENEMY,			0					},
        { TASK_GRUNT_CHECK_FIRE,	0					},
        { TASK_RANGE_ATTACK1,		0					},
        { TASK_FACE_ENEMY,			0					},
        { TASK_GRUNT_CHECK_FIRE,	0					},
        { TASK_RANGE_ATTACK1,		0					},
        { TASK_FACE_ENEMY,			0					},
        { TASK_GRUNT_CHECK_FIRE,	0					},
        { TASK_RANGE_ATTACK1,		0					}
    };
    array<array<float>>	tlGruntWaitInCover =
    {
        { TASK_STOP_MOVING,				0					},
        { TASK_SET_ACTIVITY,			ACT_IDLE				},
        { TASK_WAIT_FACE_ENEMY,			1					}
    };
    array<array<float>>	tlGruntTakeCover1 =
    {
        { TASK_STOP_MOVING,				0							},
        { TASK_SET_FAIL_SCHEDULE,		SCHED_GRUNT_TAKECOVER_FAILED	},
        { TASK_WAIT,					0.2							},
        { TASK_FIND_COVER_FROM_ENEMY,	0							},
        { TASK_GRUNT_SPEAK_SENTENCE,	0							},
        { TASK_RUN_PATH,				0							},
        { TASK_WAIT_FOR_MOVEMENT,		0							},
        { TASK_REMEMBER,				bits_MEMORY_INCOVER			},
        { TASK_SET_SCHEDULE,			SCHED_GRUNT_WAIT_FACE_ENEMY	}
    };
    array<array<float>>	tlGruntGrenadeCover1 =
    {
        { TASK_STOP_MOVING,						0							},
        { TASK_FIND_COVER_FROM_ENEMY,			99							},
        { TASK_FIND_FAR_NODE_COVER_FROM_ENEMY,	384							},
        { TASK_PLAY_SEQUENCE,					ACT_SPECIAL_ATTACK1			},
        { TASK_CLEAR_MOVE_WAIT,					0							},
        { TASK_RUN_PATH,						0							},
        { TASK_WAIT_FOR_MOVEMENT,				0							},
        { TASK_SET_SCHEDULE,					SCHED_GRUNT_WAIT_FACE_ENEMY	}
    };
    array<array<float>>	tlGruntTossGrenadeCover1 =
    {
        { TASK_FACE_ENEMY,						0							},
        { TASK_RANGE_ATTACK2, 					0							},
        { TASK_SET_SCHEDULE,					SCHED_TAKE_COVER_FROM_ENEMY	}
    };
    array<array<float>>	tlGruntTakeCoverFromBestSound =
    {
        { TASK_SET_FAIL_SCHEDULE,			SCHED_COWER			},// duck and cover if cannot move from explosion
        { TASK_STOP_MOVING,					0					},
        { TASK_FIND_COVER_FROM_BEST_SOUND,	0					},
        { TASK_RUN_PATH,					0					},
        { TASK_WAIT_FOR_MOVEMENT,			0					},
        { TASK_REMEMBER,					bits_MEMORY_INCOVER	},
        { TASK_TURN_LEFT,					179					}
    };
    array<array<float>>	tlGruntHideReload =
    {
        { TASK_STOP_MOVING,				0					},
        { TASK_SET_FAIL_SCHEDULE,		SCHED_RELOAD			},
        { TASK_FIND_COVER_FROM_ENEMY,	0					},
        { TASK_RUN_PATH,				0					},
        { TASK_WAIT_FOR_MOVEMENT,		0					},
        { TASK_REMEMBER,				bits_MEMORY_INCOVER	},
        { TASK_FACE_ENEMY,				0					},
        { TASK_SAY_RELOAD,              0                   },
        { TASK_PLAY_SEQUENCE,			ACT_RELOAD			}
    };
    array<array<float>>	tlGruntSweep =
    {
        { TASK_TURN_LEFT,			179	},
        { TASK_WAIT,				1	},
        { TASK_TURN_LEFT,			179	},
        { TASK_WAIT,				1	}
    };
    array<array<float>>	tlGruntRangeAttack1A =
    {
        { TASK_STOP_MOVING,			0		},
        { TASK_PLAY_SEQUENCE_FACE_ENEMY,		ACT_CROUCH },
        { TASK_GRUNT_CHECK_FIRE,	0		},
        { TASK_RANGE_ATTACK1,		0		},
        { TASK_FACE_ENEMY,			0		},
        { TASK_GRUNT_CHECK_FIRE,	0		},
        { TASK_RANGE_ATTACK1,		0		},
        { TASK_FACE_ENEMY,			0		},
        { TASK_GRUNT_CHECK_FIRE,	0		},
        { TASK_RANGE_ATTACK1,		0		},
        { TASK_FACE_ENEMY,			0		},
        { TASK_GRUNT_CHECK_FIRE,	0		},
        { TASK_RANGE_ATTACK1,		0		}
    };
    array<array<float>>	tlGruntRangeAttack1B =
    {
        { TASK_STOP_MOVING,				0		},
        { TASK_PLAY_SEQUENCE_FACE_ENEMY,ACT_IDLE_ANGRY  },
        { TASK_GRUNT_CHECK_FIRE,	0		},
        { TASK_RANGE_ATTACK1,		0		},
        { TASK_FACE_ENEMY,			0		},
        { TASK_GRUNT_CHECK_FIRE,	0		},
        { TASK_RANGE_ATTACK1,		0		},
        { TASK_FACE_ENEMY,			0		},
        { TASK_GRUNT_CHECK_FIRE,	0		},
        { TASK_RANGE_ATTACK1,		0		},
        { TASK_FACE_ENEMY,			0		},
        { TASK_GRUNT_CHECK_FIRE,	0		},
        { TASK_RANGE_ATTACK1,		0		}
    };
    array<array<float>>	tlGruntRangeAttack2 =
    {
        { TASK_STOP_MOVING,				0					},
        { TASK_GRUNT_FACE_TOSS_DIR,		0					},
        { TASK_PLAY_SEQUENCE,			ACT_RANGE_ATTACK2	},
        { TASK_SET_SCHEDULE,			SCHED_GRUNT_WAIT_FACE_ENEMY	}
    };
    array<array<float>>	tlGruntRepel =
    {
        { TASK_STOP_MOVING,			0		},
        { TASK_FACE_IDEAL,			0		},
        { TASK_PLAY_SEQUENCE,		ACT_GLIDE 	}
    };
    array<array<float>>	tlGruntRepelAttack =
    {
        { TASK_STOP_MOVING,			0		},
        { TASK_FACE_ENEMY,			0		},
        { TASK_PLAY_SEQUENCE,		ACT_FLY 	}
    };
    array<array<float>>	tlGruntRepelLand =
    {
        { TASK_STOP_MOVING,			0		},
        { TASK_PLAY_SEQUENCE,		ACT_LAND	},
        { TASK_GET_PATH_TO_LASTPOSITION,0				},
        { TASK_RUN_PATH,				0				},
        { TASK_WAIT_FOR_MOVEMENT,		0				},
        { TASK_CLEAR_LASTPOSITION,		0				}
    };
}

