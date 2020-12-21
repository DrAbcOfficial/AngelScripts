namespace ExpHound
{
	enum EXPHOUND_AE
	{
		EXPHOUND_AE_WARN = 1,
		EXPHOUND_AE_STARTATTACK,
		EXPHOUND_AE_THUMP,
		EXPHOUND_AE_ANGERSOUND1,
		EXPHOUND_AE_ANGERSOUND2,
		EXPHOUND_AE_HOPBACK,
		EXPHOUND_AE_CLOSEEYE,
	};

	// Behavior modifiers
	const float EXPHOUND_MOD_ATKRADIUS = 512.0;
	const float EXPHOUND_MOD_HEALTH = 100.0;
	const float EXPHOUND_MOD_MOVESPEED = 320.0;
    const float flExploRange = 196;
	const float flExploDamage = 80;
	const string EXPLOSION_SPR = "sprites/zerogxplode.spr";
    const string EXPHOUND_MODEL = "models/houndeye.mdl";
    const string EXPHOUND_RUN = "common/npc_step1.wav";
    const string EXPHOUND_NAME = "Creeper";
    const array<string> EXPHOUND_ALERT = {
        "houndeye/he_alert1.wav",
        "houndeye/he_alert2.wav",
        "houndeye/he_alert3.wav"
    };

    const array<string> EXPHOUND_PANIC = {
        "houndeye/he_pain1.wav",
        "houndeye/he_pain2.wav",
        "houndeye/he_pain3.wav",
        "houndeye/he_pain4.wav",
        "houndeye/he_pain5.wav"
    };

	class CExpHound : ScriptBaseMonsterEntity
	{
		void Precache()
		{
			BaseClass.Precache();
			g_Game.PrecacheModel(EXPHOUND_MODEL);
			g_Game.PrecacheModel(EXPLOSION_SPR);
            for(uint i = 0; i < EXPHOUND_ALERT.length(); i++)
            {
                g_SoundSystem.PrecacheSound(EXPHOUND_ALERT[i]);
            }
            for(uint i = 0; i < EXPHOUND_PANIC.length(); i++)
            {
                g_SoundSystem.PrecacheSound(EXPHOUND_PANIC[i]);
            }
			g_SoundSystem.PrecacheSound(EXPHOUND_RUN);
		}
		
		void Spawn()
		{
			Precache();
			if( !self.SetupModel() )
				g_EntityFuncs.SetModel( self, EXPHOUND_MODEL );
				
			g_EntityFuncs.SetSize(self.pev, Vector(-16, -16, 0), Vector(16, 16, 36));
		
			self.pev.health = EXPHOUND_MOD_HEALTH;
		
			pev.solid					= SOLID_SLIDEBOX;
			pev.movetype				= MOVETYPE_STEP;
			self.m_bloodColor			= BLOOD_COLOR_GREEN;
			self.m_flFieldOfView		= 0.5;
			self.m_MonsterState			= MONSTERSTATE_NONE;
			self.m_afCapability			= bits_CAP_DOORS_GROUP;
			
			self.m_FormattedName		= EXPHOUND_NAME;
			self.MonsterInit();
		}
		
		int	Classify()
		{
			return self.GetClassification( CLASS_ALIEN_MONSTER );
		}
		
		void SetYawSpeed()
		{
			self.pev.yaw_speed = EXPHOUND_MOD_MOVESPEED;
		}
		
		void Killed(entvars_t@ pevAttacker, int iGib)
		{
			iGib = GIB_ALWAYS;
			BaseClass.Killed(pevAttacker, iGib);
			Detonate();
			g_Utility.BloodDrips( self.GetOrigin(), g_vecZero, self.BloodColor(), 80 );
		}
		
		void PainSound()
		{	
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, EXPHOUND_PANIC[Math.RandomLong(0,EXPHOUND_PANIC.length() - 1)], 1, ATTN_NORM, 0, PITCH_NORM );		
		}
		
		void AlertSound()
		{	
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, EXPHOUND_ALERT[Math.RandomLong(0,EXPHOUND_ALERT.length() - 1)], 1, ATTN_NORM, 0, PITCH_NORM );	
		}
		
		int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
		{	
			if(pevAttacker is null)
				return 0;

			CBaseEntity@ pAttacker = g_EntityFuncs.Instance( pevAttacker );

			if(self.CheckAttacker( pAttacker ))
				return 0;

			return BaseClass.TakeDamage(pevInflictor, pevAttacker, flDamage, bitsDamageType);
		}
		
		bool CheckRangeAttack1(float flDot, float flDist)
		{	
			if(flDist <= (EXPHOUND_MOD_ATKRADIUS * 0.5) && flDot >= 0.3)
				return true;
		
			return false;
		}

		void Detonate()
		{
			NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
				m.WriteByte(TE_EXPLOSION);
				m.WriteCoord(pev.origin.x);
				m.WriteCoord(pev.origin.y);
				m.WriteCoord(pev.origin.z);
				m.WriteShort(g_EngineFuncs.ModelIndex(EXPLOSION_SPR));
				m.WriteByte(uint8(flExploRange / 2));//scale
				m.WriteByte(15);//framrate
				m.WriteByte(TE_EXPLFLAG_NONE);//flag
			m.End();
            g_WeaponFuncs.RadiusDamage( self.pev.origin, self.pev, self.pev, flExploDamage, flExploRange, CLASS_NONE, DMG_BLAST );
		}

		void ExploThink()
		{
			Killed(self.pev, GIB_ALWAYS);
		}

		void HandleAnimEvent(MonsterEvent@ pEvent)
		{		
			switch(pEvent.event)
			{
				case EXPHOUND_AE_WARN:
					break;
				case EXPHOUND_AE_STARTATTACK:
					break;
				case EXPHOUND_AE_HOPBACK:
					break;
				case EXPHOUND_AE_THUMP:
				{
					SetThink(ThinkFunction(ExploThink));
					pev.nextthink = g_Engine.time +  0.1; // Emit the shockwaves
					break;
				}
				case EXPHOUND_AE_ANGERSOUND1:
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, EXPHOUND_PANIC[0], 1, ATTN_NORM, 0, PITCH_NORM );
					break;
				case EXPHOUND_AE_ANGERSOUND2:
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, EXPHOUND_PANIC[1], 1, ATTN_NORM, 0, PITCH_NORM );
					break;
				case EXPHOUND_AE_CLOSEEYE:
					break;
				default:
					BaseClass.HandleAnimEvent(pEvent);
			}
		}
	}
    void Register()
    {
        g_CustomEntityFuncs.RegisterCustomEntity( "ExpHound::CExpHound", "monster_exphound" );
    }
}
