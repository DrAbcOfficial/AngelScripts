namespace ExpCrab
{
	const array<string> pIdleSounds = 
	{
		"headcrab/hc_idle1.wav",
		"headcrab/hc_idle2.wav",
		"headcrab/hc_idle3.wav",
	};

	const array<string> pAlertSounds = 
	{
		"headcrab/hc_alert1.wav",
	};

	const array<string> pPainSounds = 
	{
		"headcrab/hc_pain1.wav",
		"headcrab/hc_pain2.wav",
		"headcrab/hc_pain3.wav",
	};
	const array<string> pAttackSounds = 
	{
		"headcrab/hc_attack1.wav",
		"headcrab/hc_attack2.wav",
		"headcrab/hc_attack3.wav",
	};

	const array<string> pDeathSounds = 
	{
		"headcrab/hc_die1.wav",
		"headcrab/hc_die2.wav",
	};

	const array<string> pBiteSounds = 
	{
		"headcrab/hc_headbite.wav",
	};
	
	const int HC_AE_JUMPATTACK = 2;
    const int HC_AE_ROTATEYAW = 60;
	const string EXPLOSION_SPR = "sprites/zerogxplode.spr";
	const string HEADCRAB_MODEL = "models/explocrab.mdl";
	const string HEADCRAB_NAME = "Creeper Crab";
    const float flExploDamage = 40;
    const float flExploRange = 48;
    const int iBitDamage = 10;
    const int iHealth = 20;

	class CExpCrab : ScriptBaseMonsterEntity
	{
		
		private int m_iSoundVolue = 1;
		private	int m_iVoicePitch = PITCH_NORM;	

		CExpCrab()
		{
			@this.m_Schedules = @monster_expcrab_schedules;
		}

		int	Classify ()
		{
			return	CLASS_ALIEN_PREY;
		}

		Vector Center ()
		{
			return Vector( pev.origin.x, pev.origin.y, pev.origin.z + 6 );
		}

		Vector BodyTarget(const Vector& in posSrc) 
		{ 
			return Center();
		}

		void SetYawSpeed ()
		{
			int ys;
			ys = HC_AE_ROTATEYAW;
			self.pev.yaw_speed = ys;
		}

		void HandleAnimEvent( MonsterEvent@ pEvent )
		{
			switch( pEvent.event )
			{
				case HC_AE_JUMPATTACK:
				{
					pev.flags &= FL_ONGROUND;

					g_EntityFuncs.SetOrigin (self, pev.origin + Vector ( 0 , 0 , 1) );
					Math.MakeVectors ( pev.angles );

					Vector vecJumpDir;
					if (self.m_hEnemy.IsValid())
					{
						float gravity = g_EngineFuncs.CVarGetFloat( "sv_gravity" );
						if (gravity <= 1)
							gravity = 1;

						float height = (self.m_hEnemy.GetEntity().pev.origin.z + self.m_hEnemy.GetEntity().pev.view_ofs.z - pev.origin.z);
						if (height < 16)
							height = 16;
						float speed = sqrt( 2 * gravity * height );
						float time = speed / gravity;

						vecJumpDir = (self.m_hEnemy.GetEntity().pev.origin + self.m_hEnemy.GetEntity().pev.view_ofs - pev.origin);
						vecJumpDir = vecJumpDir * ( 1.0 / time );

						vecJumpDir.z = speed;

						float distance = vecJumpDir.Length();
						
						if (distance > 650)
						{
							vecJumpDir = vecJumpDir * ( 650.0 / distance );
						}
					}
					else
						vecJumpDir = Vector( g_Engine.v_forward.x, g_Engine.v_forward.y, g_Engine.v_up.z ) * 350;

					int iSound = Math.RandomLong(0,2);
					if ( iSound != 0 )
						g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pAttackSounds[iSound], m_iSoundVolue, ATTN_IDLE, 0, m_iVoicePitch);
					pev.velocity = vecJumpDir;
					self.m_flNextAttack = g_Engine.time + 2;
				}
				break;

				default:
					BaseClass.HandleAnimEvent( pEvent );
					break;
			}
		}

		void RunTask ( Task@ pTask )
		{
			switch ( pTask.iTask )
			{
				case TASK_RANGE_ATTACK1:
				{
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, pAttackSounds[0], m_iSoundVolue, ATTN_IDLE, 0, m_iVoicePitch );
					self.m_IdealActivity = ACT_RANGE_ATTACK1;
					SetTouch ( TouchFunction(LeapTouch) );
					self.TaskComplete();
					break;
				}
				case TASK_RANGE_ATTACK2:
				{
					if ( self.m_fSequenceFinished )
					{
						self.TaskComplete();
						SetTouch( null );
						self.m_IdealActivity = ACT_IDLE;
					}
					break;
				}
				default:
				{
					BaseClass.RunTask( pTask );
				}
			}
		}


		void Spawn()
		{
			Precache();
			g_EntityFuncs.SetModel(self, HEADCRAB_MODEL);
			g_EntityFuncs.SetSize(pev, Vector(-12, -12, 0), Vector(12, 12, 24));
			pev.solid			        = SOLID_SLIDEBOX;
			pev.movetype		        = MOVETYPE_STEP;
			self.m_bloodColor	        = BLOOD_COLOR_GREEN;
			pev.effects		            = 0;
			pev.dmg                     = iBitDamage;
			pev.health			        = iHealth;
			pev.view_ofs		        = Vector ( 0, 0, 20 );
			pev.yaw_speed		        = HC_AE_ROTATEYAW;
			self.m_flFieldOfView        = 0.5;
			self.m_MonsterState		    = MONSTERSTATE_NONE;
			self.m_FormattedName        = HEADCRAB_NAME;
			self.MonsterInit();
			BaseClass.Spawn();
		}
		
		void Precache()
		{
			BaseClass.Precache();
			for(uint i = 0; i < pIdleSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pIdleSounds[i]);
			}

			for(uint i = 0; i < pAlertSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pAlertSounds[i]);
			}

			for(uint i = 0; i < pPainSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pPainSounds[i]);
			}

			for(uint i = 0; i < pAttackSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pAttackSounds[i]);
			}

			for(uint i = 0; i < pDeathSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pDeathSounds[i]);
			}

			for(uint i = 0; i < pBiteSounds.length();i++)
			{
				g_SoundSystem.PrecacheSound(pBiteSounds[i]);
			}

			g_Game.PrecacheModel(HEADCRAB_MODEL);
			g_Game.PrecacheModel(EXPLOSION_SPR);
		}

		float GetDamageAmount()
		{
			return pev.dmg;
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

		void Killed(entvars_t@ pevAttacker, int iGib)
		{
			iGib = GIB_ALWAYS;
			BaseClass.Killed(pevAttacker, iGib);
			Detonate();
			g_Utility.BloodDrips( self.GetOrigin(), g_vecZero, self.BloodColor(), 80 );
		}

		void ExploThink()
		{
			Killed(self.pev, GIB_ALWAYS);
		}

		void LeapTouch ( CBaseEntity @pOther )
		{
			if ( pOther.pev.takedamage == DAMAGE_NO )
			{
				return;
			}
			if ( pOther.Classify() == Classify() )
			{
				return;
			}
			if (  pev.flags & FL_ONGROUND == 0 )
			{
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, RANDOM_SOUND_ARRAY(pBiteSounds), m_iSoundVolue, ATTN_IDLE, 0, m_iVoicePitch );
				pOther.TakeDamage( self.pev, self.pev, GetDamageAmount(), DMG_SLASH );
				SetThink(ThinkFunction(ExploThink));
				pev.nextthink = g_Engine.time +  0.1;
			}
			SetTouch( null );
		}

		void PrescheduleThink ()
		{
			if ( self.m_MonsterState == MONSTERSTATE_COMBAT && Math.RandomFloat( 0, 5 ) < 0.1 )
			{
				IdleSound();
			}
		}

		bool CheckRangeAttack1 ( float flDot, float flDist )
		{
			if ( (pev.flags & FL_ONGROUND != 0) && flDist <= 256 && flDot >= 0.65 )
			{
				return true;
			}
			return false;
		}

		bool CheckRangeAttack2 ( float flDot, float flDist )
		{
			return false;
		}

		int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
		{	
			if ( bitsDamageType & DMG_ACID != 0)
				flDamage = 0;

			return BaseClass.TakeDamage( pevInflictor, pevAttacker, flDamage, bitsDamageType );
		}

		void IdleSound ()
		{
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, RANDOM_SOUND_ARRAY(pIdleSounds), m_iSoundVolue, ATTN_IDLE, 0, m_iVoicePitch );
		}

		void AlertSound ()
		{
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, RANDOM_SOUND_ARRAY(pAlertSounds), m_iSoundVolue, ATTN_IDLE, 0, m_iVoicePitch );
		}

		void PainSound ()
		{
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, RANDOM_SOUND_ARRAY(pPainSounds), m_iSoundVolue, ATTN_IDLE, 0, m_iVoicePitch );
		}

		void DeathSound ()
		{
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, RANDOM_SOUND_ARRAY(pDeathSounds), m_iSoundVolue, ATTN_IDLE, 0, m_iVoicePitch );
		}

		string RANDOM_SOUND_ARRAY(array<string> ary)
		{
			int i = Math.RandomLong(0,ary.length() - 1);
			return ary[i];
		}

		Schedule@ GetScheduleOfType ( int Type )
		{	
			switch	( Type )
			{
				case SCHED_RANGE_ATTACK1:
					return slHCRangeAttack1;
			}
			return BaseClass.GetScheduleOfType( Type );
		}
	}

	array<ScriptSchedule@>@ monster_expcrab_schedules;

	ScriptSchedule slHCRangeAttack1 (
		bits_COND_ENEMY_OCCLUDED	|
		bits_COND_NO_AMMO_LOADED,
		0,
		"HCRangeAttack1"
	);

	ScriptSchedule slHCRangeAttack1Fast (
		bits_COND_ENEMY_OCCLUDED	|
		bits_COND_NO_AMMO_LOADED,
		0,
		"HCRAFast"
	);

	void InitSchedules()
	{
		slHCRangeAttack1.AddTask( ScriptTask(TASK_STOP_MOVING) );
		slHCRangeAttack1.AddTask( ScriptTask(TASK_FACE_IDEAL) );
		slHCRangeAttack1.AddTask( ScriptTask(TASK_RANGE_ATTACK1) );
		slHCRangeAttack1.AddTask( ScriptTask(TASK_SET_ACTIVITY, float(ACT_IDLE)) );
		slHCRangeAttack1.AddTask( ScriptTask(TASK_FACE_IDEAL) );
		slHCRangeAttack1.AddTask( ScriptTask(TASK_WAIT_RANDOM) );

		slHCRangeAttack1Fast.AddTask( ScriptTask(TASK_STOP_MOVING) );
		slHCRangeAttack1Fast.AddTask( ScriptTask(TASK_FACE_IDEAL) );
		slHCRangeAttack1Fast.AddTask( ScriptTask(TASK_RANGE_ATTACK1) );
		slHCRangeAttack1Fast.AddTask( ScriptTask(TASK_SET_ACTIVITY, float(ACT_IDLE)) );
		array<ScriptSchedule@> scheds = {slHCRangeAttack1, slHCRangeAttack1Fast};
		@monster_expcrab_schedules = @scheds;
	}

	void Register()
	{
		InitSchedules();
		g_CustomEntityFuncs.RegisterCustomEntity( "ExpCrab::CExpCrab", "monster_expcrab" );
	}
}
