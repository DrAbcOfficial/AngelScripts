namespace CustomTank
{
enum TANKSF
{
    SF_TANK_ACTIVE = 0x0001,
    SF_TANK_PLAYER = 0x0002,
    SF_TANK_HUMANS = 0x0004,
    SF_TANK_ALIENS = 0x0008,
    SF_TANK_LINEOFSIGHT = 0x0010,
    SF_TANK_CANCONTROL = 0x0020,
    SF_TANK_SOUNDON = 0x8000
}

enum HIDEHUD
{
	HIDEHUD_WEAPONS = ( 1<<0 ),
	HIDEHUD_FLASHLIGHT = ( 1<<1 ),
	HIDEHUD_ALL = ( 1<<2 ),
	HIDEHUD_HEALTH = ( 1<<3 ),
}

const float MAX_LOST_CONTROL_RANGE = 128;

/**
enum TANKBULLET
{
	TANK_BULLET_NONE = 0,
	TANK_BULLET_9MM = 1,
	TANK_BULLET_MP5 = 2,
	TANK_BULLET_12MM = 3,
};
**/

const array<Vector> gTankSpread =
{
	Vector( 0, 0, 0 ), // perfect
	Vector( 0.025, 0.025, 0.025 ),	// small cone
	Vector( 0.05, 0.05, 0.05 ),  // medium cone
	Vector( 0.1, 0.1, 0.1 ),	// large cone
	Vector( 0.25, 0.25, 0.25 ),	// extra-large cone
};

abstract class CFuncTank : ScriptBaseEntity
{
	CBasePlayer@ m_pController;
	float m_flNextAttack;
	Vector m_vecControllerUsePos;
	
	float m_yawCenter;	// "Center" yaw
	float m_yawRate; // Max turn rate to track targets
	float m_yawRange; // Range of turning motion (one-sided: 30 is +/- 30 degress from center)
    // Zero is full rotation
	float m_yawTolerance;	// Tolerance angle

	float m_pitchCenter;	// "Center" pitch
	float m_pitchRate;	// Max turn rate on pitch
	float m_pitchRange;	// Range of pitch motion as above
	float m_pitchTolerance;	// Tolerance angle

	float m_fireLast; // Last time I fired
	float m_fireRate; // How many rounds/second
	float m_lastSightTime;// Last time I saw target
	float m_persist; // Persistence of firing (how long do I shoot when I can't see)
	float m_minRange; // Minimum range to aim/track
	float m_maxRange; // Max range to aim/track

	Vector m_barrelPos;	// Length of the freakin barrel
	float m_spriteScale;	// Scale of any sprites we shoot
	string m_iszSpriteSmoke;
	string m_iszSpriteFlash;
	string m_iszRotateSound;
	int	m_bulletType;	// Bullet type
	int m_iBulletDamage; // 0 means use Bullet type's default damage
	
	Vector m_sightOrigin;	// Last sight of target
	int m_spread; // firing spread
	string m_iszMaster;	// Master entity (game_team_master or multisource)

	Vector UpdateTargetPosition( CBaseEntity@ pTarget )
	{
        return pTarget.BodyTarget( pev.origin );
	}
	int	ObjectCaps()
    {
        return BaseClass.ObjectCaps() & ~FCAP_ACROSS_TRANSITION;
    }

	bool IsActive()
    {
        return (pev.spawnflags & SF_TANK_ACTIVE) != 0 ? true : false;
    }
	void TankActivate()
    {
        pev.spawnflags |= SF_TANK_ACTIVE;
        pev.nextthink = pev.ltime + 0.1;
        m_fireLast = 0;
    }
	void TankDeactivate()
    {
        pev.spawnflags &= ~SF_TANK_ACTIVE;
        m_fireLast = 0;
        StopRotSound();
    }
	bool CanFire()
    {
        return (g_Engine.time - m_lastSightTime) < m_persist;
    }

	Vector BarrelPosition()
	{
        return pev.origin + g_Engine.v_forward * m_barrelPos.x + g_Engine.v_right * m_barrelPos.y + g_Engine.v_up * m_barrelPos.z;
	}

    void Precache()
    {
        if ( m_iszSpriteSmoke != "" )
            g_Game.PrecacheModel( string(m_iszSpriteSmoke) );
        if ( m_iszSpriteFlash != "" )
            g_Game.PrecacheModel( string(m_iszSpriteFlash) );

        if ( m_iszRotateSound != "" )
            g_SoundSystem.PrecacheSound( string(m_iszRotateSound) );
    }

    void Spawn()
    {
        Precache();
        pev.movetype = MOVETYPE_PUSH;  // so it doesn't get pushed by anything
        pev.solid = SOLID_BSP;
        g_EntityFuncs.SetModel( self, string(pev.model) );

        m_yawCenter = pev.angles.y;
        m_pitchCenter = pev.angles.x;

        if (IsActive())
            pev.nextthink = pev.ltime + 1.0;

        m_sightOrigin = BarrelPosition(); // Point at the end of the barrel

        if (m_fireRate <= 0)
            m_fireRate = 1;
        if ( m_spread > int(gTankSpread.length()) )
            m_spread = 0;
        pev.oldorigin = pev.origin;
    }

    bool KeyValue( const string& in szKey, const string& in szValue )
    {
        if ( szKey == "yawrate")
            m_yawRate = atof(szValue);
        else if ( szKey == "yawrange")
            m_yawRange = atof(szValue);
        else if ( szKey == "yawtolerance")
            m_yawTolerance = atof(szValue);
        else if ( szKey == "pitchrange")
            m_pitchRange = atof(szValue);
        else if ( szKey == "pitchrate")
            m_pitchRate = atof(szValue);
        else if ( szKey == "pitchtolerance")
            m_pitchTolerance = atof(szValue);
        else if ( szKey == "firerate")
            m_fireRate = atof(szValue);
        else if ( szKey == "barrel")
            m_barrelPos.x = atof(szValue);
        else if ( szKey == "barrely")
            m_barrelPos.y = atof(szValue);
        else if ( szKey == "barrelz")
            m_barrelPos.z = atof(szValue);
        else if ( szKey == "spritescale")
            m_spriteScale = atof(szValue);
        else if ( szKey == "spritesmoke")
            m_iszSpriteSmoke = szValue;
        else if ( szKey == "spriteflash")
            m_iszSpriteFlash = szValue;
        else if ( szKey == "rotatesound")
            m_iszRotateSound = szValue;
        else if ( szKey == "persistence")
            m_persist = atof(szValue);
        else if ( szKey == "bullet")
            m_bulletType = atoi(szValue);
        else if (  szKey == "bullet_damage" )
            m_iBulletDamage = atoi(szValue);
        else if ( szKey == "firespread")
            m_spread = atoi(szValue);
        else if ( szKey == "minRange")
            m_minRange = atof(szValue);
        else if ( szKey == "maxRange")
            m_maxRange = atof(szValue);
        else if ( szKey == "master")
            m_iszMaster = szValue;
        else
            return BaseClass.KeyValue( szKey, szValue );
        return true;
    }

    bool OnControls( entvars_t@ pevTest )
    {
        if ( pev.spawnflags & SF_TANK_CANCONTROL == 0 )
            return false;

        Vector offset = pevTest.origin - pev.origin;
        if ( (m_vecControllerUsePos - pevTest.origin).Length() < 30 )
            return true;
        return false;
    }

    bool StartControl( CBasePlayer@ pController )
    {
        if ( m_pController !is null )
            return false;

        // Team only or disabled?
        if ( m_iszMaster != "" )
        {
    		if ( !g_EntityFuncs.IsMasterTriggered( m_iszMaster, pController ) )
        		return false;
        }

        //ALERT( at_console, "using TANK!\n");

        @m_pController = @pController;
        if ( m_pController.m_hActiveItem )
        {
			cast<CBasePlayerWeapon@>(m_pController.m_hActiveItem.GetEntity()).Holster();
			m_pController.pev.weaponmodel = 0;
			m_pController.pev.viewmodel = 0; 

        }

        m_pController.m_iHideHUD |= HIDEHUD_WEAPONS;
        m_vecControllerUsePos = m_pController.pev.origin;
        
        pev.nextthink = pev.ltime + 0.1;
        
        return true;
    }

	void StopControl()
	{
		// TODO: bring back the controllers current weapon
		if ( m_pController is null )
			return;

		if ( m_pController.m_hActiveItem )
			cast<CBasePlayerWeapon@>(m_pController.m_hActiveItem.GetEntity()).Deploy();

		//ALERT( at_console, "stopped using TANK\n");

		m_pController.m_iHideHUD &= ~HIDEHUD_WEAPONS;

		pev.nextthink = 0;
		@m_pController = null;

		if ( IsActive() )
		pev.nextthink = pev.ltime + 1.0;
	}

	// Called each frame by the player's ItemPostFrame
	void ControllerPostFrame()
	{
		if(m_pController is null)
			return;

		if ( g_Engine.time < m_flNextAttack )
			return;

		if ( m_pController.pev.button & IN_ATTACK != 0 ) 
		{

			m_fireLast = g_Engine.time - (1/m_fireRate) - 0.01;  // to make sure the gun doesn't fire too many bullets
			Fire( BarrelPosition(), g_Engine.v_forward, m_pController.pev );
	
			// HACKHACK -- make some noise (that the AI can hear)
			if ( m_pController !is null && m_pController.IsPlayer() )
				cast<CBasePlayer@>(m_pController).m_iWeaponVolume = LOUD_GUN_VOLUME;
			m_flNextAttack = g_Engine.time + (1/m_fireRate);
		}
		//距离太远将停止操控
		//g_Log.PrintF("%1\n", (m_pController.pev.origin - self.Center()).Length());
		if( (m_pController.pev.origin - self.Center()).Length() > MAX_LOST_CONTROL_RANGE)
			StopControl();
	}
////////////// END NEW STUFF //////////////
	void Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
	{
		if ( pev.spawnflags & SF_TANK_CANCONTROL != 0 )
		{ 
			// player controlled turret
			if ( pActivator.Classify() != CLASS_PLAYER )
				return;
			else if ( m_pController is null && useType != USE_OFF )
			{
				(cast<CBasePlayer@>(pActivator)).m_hTargetTank = self;
				StartControl(cast<CBasePlayer@>(pActivator));
			}
			else
				StopControl();
		}
		else
		{
			if ( !self.ShouldToggle( useType, IsActive() ) )
				return;

			if ( IsActive() )
				TankDeactivate();
			else
				TankActivate();
		}
	}

	edict_t@ FindTarget( edict_t@ pPlayer )
	{
		return pPlayer;
	}

	bool InRange( float range )
	{
		if ( range < m_minRange )
			return false;
		if ( m_maxRange > 0 && range > m_maxRange )
			return false;
		return true;
	}

	void Think()
	{
		pev.avelocity = g_vecZero;
		TrackTarget();

		if ( fabs(pev.avelocity.x) > 1 || fabs(pev.avelocity.y) > 1 )
			StartRotSound();
		else
			StopRotSound();
	}

	float fabs(float inNum)
	{
		return inNum < 0 ? -inNum : inNum;
	}

	void TrackTarget()
	{
		TraceResult tr;
		edict_t@ pPlayer = g_EngineFuncs.EntitiesInPVS( self.edict() );
		bool updateTime = false, lineOfSight;
		Vector angles, direction, targetPosition, barrelEnd;
		edict_t@ pTarget;

		// Get a position to aim for
		if (m_pController !is null)
		{
			// Tanks attempt to mirror the player's angles
			angles = m_pController.pev.v_angle;
			angles[0] = 0 - angles[0];
			//测试
			ControllerPostFrame();

			pev.nextthink = pev.ltime + 0.05;
		}
		else
		{
			if ( IsActive() )
				pev.nextthink = pev.ltime + 0.1;
			else
				return;

			if ( pPlayer is null )
			{
				if ( IsActive() )
					pev.nextthink = pev.ltime + 2;	// Wait 2 secs
				return;
			}

			@pTarget = FindTarget( pPlayer );
			if ( pTarget is null )
				return;

			// Calculate angle needed to aim at target
			barrelEnd = BarrelPosition();
			targetPosition = pTarget.vars.origin + pTarget.vars.view_ofs;
			float range = (targetPosition - barrelEnd).Length();
 
			if ( !InRange( range ) )
				return;

			g_Utility.TraceLine( barrelEnd, targetPosition, dont_ignore_monsters, self.edict(), tr );
			lineOfSight = false;
			// No line of sight, don't track
			if ( tr.flFraction == 1.0 || @tr.pHit is @pTarget )
			{
				lineOfSight = true;

				CBaseEntity@ pInstance = g_EntityFuncs.Instance(pTarget);
				if ( InRange( range ) && pInstance !is null && pInstance.IsAlive() )
				{
					updateTime = true;
					m_sightOrigin = UpdateTargetPosition( pInstance );
				}
			}
			// Track sight origin
			// !!! I'm not sure what i changed
			direction = m_sightOrigin - pev.origin;
			// direction = m_sightOrigin - barrelEnd;
			angles = Math.VecToAngles( direction );
			// Calculate the additional rotation to point the end of the barrel at the target (not the gun's center) 
			AdjustAnglesForBarrel( angles, direction.Length() );
		}
		angles.x = -angles.x;
		// Force the angles to be relative to the center position
		angles.y = m_yawCenter + Math.AngleDistance( angles.y, m_yawCenter );
		angles.x = m_pitchCenter + Math.AngleDistance( angles.x, m_pitchCenter );

		// Limit against range in y
		if ( angles.y > m_yawCenter + m_yawRange )
		{
			angles.y = m_yawCenter + m_yawRange;
			updateTime = false;	// Don't update if you saw the player, but out of range
		}
		else if ( angles.y < (m_yawCenter - m_yawRange) )
		{
 			angles.y = (m_yawCenter - m_yawRange);
 			updateTime = false; // Don't update if you saw the player, but out of range
		}

		if ( updateTime )
 			m_lastSightTime = g_Engine.time;

		// Move toward target at rate or less
		float distY = Math.AngleDistance( angles.y, pev.angles.y );
			pev.avelocity.y = distY * 10;
		if ( pev.avelocity.y > m_yawRate )
			pev.avelocity.y = m_yawRate;
		else if ( pev.avelocity.y < -m_yawRate )
			pev.avelocity.y = -m_yawRate;

		// Limit against range in x
		if ( angles.x > m_pitchCenter + m_pitchRange )
 			angles.x = m_pitchCenter + m_pitchRange;
		else if ( angles.x < m_pitchCenter - m_pitchRange )
 			angles.x = m_pitchCenter - m_pitchRange;

		// Move toward target at rate or less
		float distX = Math.AngleDistance( angles.x, pev.angles.x );
		pev.avelocity.x = distX  * 10;

		if ( pev.avelocity.x > m_pitchRate )
 			pev.avelocity.x = m_pitchRate;
		else if ( pev.avelocity.x < -m_pitchRate )
 			pev.avelocity.x = -m_pitchRate;

		if ( m_pController !is null )
 			return;

		if ( CanFire() && ( (fabs(distX) < m_pitchTolerance && fabs(distY) < m_yawTolerance) || (pev.spawnflags & SF_TANK_LINEOFSIGHT) != 0 ) )
		{
 			bool fire = false;
 			if ( pev.spawnflags & SF_TANK_LINEOFSIGHT != 0 )
 			{
				float length = direction.Length();
				g_Utility.TraceLine( barrelEnd, barrelEnd + g_Engine.v_forward * length, dont_ignore_monsters, self.edict(), tr );
				if ( tr.pHit is pTarget )
  					fire = true;
 			}
 			else
				fire = true;

			if ( fire )
				Fire( BarrelPosition(), g_Engine.v_forward, pev );
 			else
 				m_fireLast = 0;
		}
		else
 			m_fireLast = 0;
	}
	// If barrel is offset, add in additional rotation
	void AdjustAnglesForBarrel( Vector angles, float distance )
	{
		float r2, d2;
		if ( m_barrelPos.y != 0 || m_barrelPos.z != 0 )
		{
			distance -= m_barrelPos.z;
			d2 = distance * distance;
			if ( m_barrelPos.y != 0 )
			{
				r2 = m_barrelPos.y * m_barrelPos.y;
				angles.y += (180.0 / Math.PI) * atan2( m_barrelPos.y, sqrt( d2 - r2 ) );
			}
			if ( m_barrelPos.z != 0 )
			{
				r2 = m_barrelPos.z * m_barrelPos.z;
				angles.x += (180.0 / Math.PI) * atan2( -m_barrelPos.z, sqrt( d2 - r2 ) );
			}
		}
	}

	void Fire( const Vector barrelEnd, const Vector forward, entvars_t@ pevAttacker )
	{
		//Dummy
	}

	// Fire targets and spawn sprites
	void FireEffect( const Vector barrelEnd, const Vector forward, entvars_t@ pevAttacker )
	{
		if ( m_fireLast != 0 )
		{
			if ( m_iszSpriteSmoke != "" )
			{
				CSprite@ pSprite = g_EntityFuncs.CreateSprite( string(m_iszSpriteSmoke), barrelEnd, true );
				pSprite.AnimateAndDie( Math.RandomFloat( 15.0, 20.0 ) );
				pSprite.SetTransparency( kRenderTransAlpha, int(pev.rendercolor.x), int(pev.rendercolor.y), int(pev.rendercolor.z), 255, kRenderFxNone );
				pSprite.pev.velocity.z = Math.RandomFloat(40, 80);
				pSprite.SetScale( m_spriteScale );
			}
			if ( m_iszSpriteFlash != "" )
			{
				CSprite@ pSprite = g_EntityFuncs.CreateSprite( string(m_iszSpriteFlash), barrelEnd, true );
				pSprite.AnimateAndDie( 60 );
				pSprite.SetTransparency( kRenderTransAdd, 255, 255, 255, 255, kRenderFxNoDissipation );
				pSprite.SetScale( m_spriteScale );
				// Hack Hack, make it stick around for at least 100 ms.
				pSprite.pev.nextthink += 0.1;
			}
			self.SUB_UseTargets( self, USE_TOGGLE, 0 );
		}
		m_fireLast = g_Engine.time;
	}

	void TankTrace( const Vector vecStart, const Vector vecForward, const Vector vecSpread, TraceResult&out tr )
	{
		// get circular gaussian spread
		float x, y, z;
		do 
		{
			x = Math.RandomFloat(-0.5,0.5) + Math.RandomFloat(-0.5,0.5);
			y = Math.RandomFloat(-0.5,0.5) + Math.RandomFloat(-0.5,0.5);
			z = x*x+y*y;
		} 
		while (z > 1);

		Vector vecDir = vecForward +
			x * vecSpread.x * g_Engine.v_right +
			y * vecSpread.y * g_Engine.v_up;
		Vector vecEnd;
		vecEnd = vecStart + vecDir * 4096;
		g_Utility.TraceLine( vecStart, vecEnd, dont_ignore_monsters, self.edict(), tr );
	}

	void StartRotSound()
	{
		if ( m_iszRotateSound == "" || (pev.spawnflags & SF_TANK_SOUNDON) != 0 )
			return;

		pev.spawnflags |= SF_TANK_SOUNDON;
		g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, string(m_iszRotateSound), 0.85, ATTN_NORM);
	}


	void StopRotSound()
	{
		if ( pev.spawnflags & SF_TANK_SOUNDON != 0 && m_iszRotateSound != "" )
			g_SoundSystem.StopSound( self.edict(), CHAN_STATIC, string(m_iszRotateSound) );
		pev.spawnflags &= ~SF_TANK_SOUNDON;
	}
}

class CFuncTankAthena : CFuncTank
{
	CBeam@ m_pLaser;
	float m_laserTime;

	CBaseEntity@ pRocket;

	void Fire( const Vector barrelEnd, const Vector forward, entvars_t@ pevAttacker )
	{
		if ( m_fireLast != 0 )
		{
			// FireBullets needs g_Engine.v_up, etc.
			Math.MakeAimVectors(pev.angles);
			int bulletCount = int((g_Engine.time - m_fireLast) * m_fireRate);

			if ( bulletCount > 0 )
			{
				if(@m_pLaser !is null)
					g_EntityFuncs.Remove(m_pLaser);

				TraceResult tr;
				TankTrace( barrelEnd, forward, gTankSpread[m_spread], tr );
				g_Utility.TraceLine( tr.vecEndPos, g_Engine.v_up * 8102, dont_ignore_monsters, self.edict(), tr );

				@pRocket = g_EntityFuncs.ShootMortar(pevAttacker, tr.vecEndPos, Vector(0, 0, 0) );

				/**
				@m_pLaser = g_EntityFuncs.CreateBeam("sprites/laserbeam.spr", 255);
				m_pLaser.SetColor(255, 255, 0);
				m_pLaser.SetBrightness(255);

				TraceResult tr;
				TankTrace( barrelEnd, forward, gTankSpread[m_spread], tr );
				m_pLaser.SetStartPos( tr.vecEndPos );	
				g_EntityFuncs.CreateExplosion(tr.vecEndPos, g_vecZero, pevAttacker.get_pContainingEntity(), 5, true);

				g_Utility.TraceLine( tr.vecEndPos, g_Engine.v_up * 8102, dont_ignore_monsters, self.edict(), tr );
				m_pLaser.SetEndPos( tr.vecEndPos );

					m_laserTime = g_Engine.time;
					m_pLaser.pev.dmgtime = g_Engine.time - 1.0;
					m_pLaser.pev.nextthink = 0;
				**/
				FireEffect( barrelEnd, forward, pevAttacker );
			}
		}
		else
			FireEffect( barrelEnd, forward, pevAttacker );
	}
}

class CFuncTankGun : CFuncTank
{
	void Fire( const Vector barrelEnd, const Vector forward, entvars_t@ pevAttacker )
	{
		int i;
		if ( m_fireLast != 0 )
		{
			// FireBullets needs g_Engine.v_up, etc.
			Math.MakeAimVectors(pev.angles);

			int bulletCount = int((g_Engine.time - m_fireLast) * m_fireRate);
			if ( bulletCount > 0 )
			{
				for ( i = 0; i < bulletCount; i++ )
				{
					switch( m_bulletType )
					{
						case TANK_BULLET_9MM:
							self.FireBullets( 1, barrelEnd, forward, gTankSpread[m_spread], 4096, BULLET_MONSTER_9MM, 1, m_iBulletDamage, pevAttacker );
							break;

						case TANK_BULLET_MP5:
							self.FireBullets( 1, barrelEnd, forward, gTankSpread[m_spread], 4096, BULLET_MONSTER_MP5, 1, m_iBulletDamage, pevAttacker );
							break;

						case TANK_BULLET_12MM:
							self.FireBullets( 1, barrelEnd, forward, gTankSpread[m_spread], 4096, BULLET_MONSTER_12MM, 1, m_iBulletDamage, pevAttacker );
							break;
						case TANK_BULLET_NONE: break;
						default: break;
					}
				}
				FireEffect( barrelEnd, forward, pevAttacker );
			}
		}
		else
			FireEffect( barrelEnd, forward, pevAttacker );
	}
}

class CFuncTankLaser : CFuncTank
{
	CLaser@ m_pLaser;
	float	m_laserTime;

	void Activate()
	{
		if ( GetLaser() is null )
		{
 			g_EntityFuncs.Remove(self);
 			//ALERT( at_error, "Laser tank with no env_laser!\n" );
		}
		else
 			m_pLaser.TurnOff();
	}

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if ( szKey == "laserentity")
		{
			pev.message = szValue;
			return true;
		}
		else
			return BaseClass.KeyValue(szKey, szValue);
	}

	CLaser@ GetLaser()
	{
		if ( m_pLaser !is null )
			return m_pLaser;

		CBaseEntity@ pentLaser;
		@pentLaser = g_EntityFuncs.FindEntityByTargetname( null, string(pev.message) );
		while ( pentLaser is null )
		{
			// Found the landmark
			if ( g_EntityFuncs.FindEntityByClassname( pentLaser, "env_laser" ) !is null )
			{
				@m_pLaser = cast<CLaser@>(pentLaser);
				break;
			}
			else
				@pentLaser = g_EntityFuncs.FindEntityByTargetname( pentLaser, string(pev.message) );
		}
		return m_pLaser;
	}

	void Think()
	{
		if ( m_pLaser !is null && (g_Engine.time > m_laserTime) )
			m_pLaser.TurnOff();
		Think();
	}

	void Fire( const Vector barrelEnd, const Vector forward, entvars_t@ pevAttacker )
	{
		int i;
		TraceResult tr;
		if ( m_fireLast != 0 && GetLaser() !is null )
		{
			// TankTrace needs g_Engine.v_up, etc.
			Math.MakeAimVectors(pev.angles);
			int bulletCount = int((g_Engine.time - m_fireLast) * m_fireRate);
			if ( bulletCount > 0 )
			{
				for ( i = 0; i < bulletCount; i++ )
				{
					m_pLaser.pev.origin = barrelEnd;
					TankTrace( barrelEnd, forward, gTankSpread[m_spread], tr );
					
					m_laserTime = g_Engine.time;
					m_pLaser.TurnOn();
					m_pLaser.pev.dmgtime = g_Engine.time - 1.0;
					m_pLaser.FireAtPoint( tr );
					m_pLaser.pev.nextthink = 0;
				}
			Fire( barrelEnd, forward, pev );
			}
		}
		else
			Fire( barrelEnd, forward, pev );
	}
}



/**
class CFuncTankRocket : public CFuncTank
{
public:
	void Precache();
	void Fire( const Vector &barrelEnd, const Vector &forward, entvars_t *pevAttacker );
};
LINK_ENTITY_TO_CLASS( func_tankrocket, CFuncTankRocket );

void CFuncTankRocket::Precache()
{
	UTIL_PrecacheOther( "rpg_rocket" );
	Precache();
}



void CFuncTankRocket::Fire( const Vector &barrelEnd, const Vector &forward, entvars_t *pevAttacker )
{
	int i;

	if ( m_fireLast != 0 )
	{
 int bulletCount = (g_Engine.time - m_fireLast) * m_fireRate;
 if ( bulletCount > 0 )
 {
 	for ( i = 0; i < bulletCount; i++ )
 	{
  CBaseEntity *pRocket = CBaseEntity::Create( "rpg_rocket", barrelEnd, pev.angles, self.edict() );
 	}
 	Fire( barrelEnd, forward, pev );
 }
	}
	else
 Fire( barrelEnd, forward, pev );
}


class CFuncTankMortar : public CFuncTank
{
public:
	void KeyValue( KeyValueData *pkvd );
	void Fire( const Vector &barrelEnd, const Vector &forward, entvars_t *pevAttacker );
};
LINK_ENTITY_TO_CLASS( func_tankmortar, CFuncTankMortar );


void CFuncTankMortar::KeyValue( KeyValueData *pkvd )
{
	if ( szKey == "iMagnitude"))
	{
 pev.impulse = atoi( szValue );
 pkvd.fHandled = true;
	}
	else
 KeyValue( pkvd );
}


void CFuncTankMortar::Fire( const Vector &barrelEnd, const Vector &forward, entvars_t *pevAttacker )
{
	if ( m_fireLast != 0 )
	{
 int bulletCount = (g_Engine.time - m_fireLast) * m_fireRate;
 // Only create 1 explosion
 if ( bulletCount > 0 )
 {
 	TraceResult tr;

 	// TankTrace needs g_Engine.v_up, etc.
 	Math.MakeAimVectors(pev.angles);

 	TankTrace( barrelEnd, forward, gTankSpread[m_spread], tr );

 	ExplosionCreate( tr.vecEndPos, pev.angles, self.edict(), pev.impulse, true );

 	Fire( barrelEnd, forward, pev );
 }
	}
	else
 Fire( barrelEnd, forward, pev );
}



//============================================================================
// FUNC TANK CONTROLS
//============================================================================
class CFuncTankControls : public CBaseEntity
{
public:
	virtual int	ObjectCaps();
	void Spawn();
	void Use( CBaseEntity *pActivator, CBaseEntity *pCaller, USE_TYPE useType, float value );
	void Think();

	virtual int	Save( CSave &save );
	virtual int	Restore( CRestore &restore );
	static TYPEDESCRIPTION m_SaveData[];

	CFuncTank *m_pTank;
};
LINK_ENTITY_TO_CLASS( func_tankcontrols, CFuncTankControls );

TYPEDESCRIPTION	CFuncTankControls::m_SaveData[] = 
{
	DEFINE_FIELD( CFuncTankControls, m_pTank, FIELD_CLASSPTR ),
};

IMPLEMENT_SAVERESTORE( CFuncTankControls, CBaseEntity );

int	CFuncTankControls :: ObjectCaps() 
{ 
	return (CBaseEntity::ObjectCaps() & ~FCAP_ACROSS_TRANSITION) | FCAP_IMPULSE_USE; 
}


void CFuncTankControls :: Use( CBaseEntity *pActivator, CBaseEntity *pCaller, USE_TYPE useType, float value )
{ // pass the Use command onto the controls
	if ( m_pTank )
 m_pTank.Use( pActivator, pCaller, useType, value );

	ASSERT( m_pTank != null );	// if this fails,  most likely means save/restore hasn't worked properly
}


void CFuncTankControls :: Think()
{
	edict_t *pTarget = null;

	do 
	{
 pTarget = FIND_ENTITY_BY_TARGETNAME( pTarget, string(pev.target) );
	} while ( !FnullEnt(pTarget) && strncmp( string(pTarget.v.classname), "func_tank", 9 ) );

	if ( FnullEnt( pTarget ) )
	{
 ALERT( at_console, "No tank %s\n", string(pev.target) );
 return;
	}

	m_pTank = (CFuncTank*)Instance(pTarget);
}

void CFuncTankControls::Spawn()
{
	pev.solid = SOLID_TRIGGER;
	pev.movetype = MOVETYPE_NONE;
	pev.effects |= EF_NODRAW;
	SET_MODEL( ENT(pev), string(pev.model) );

	UTIL_SetSize( pev, pev.mins, pev.maxs );
	UTIL_SetOrigin( pev, pev.origin );
	
	pev.nextthink = g_Engine.time + 0.3;	// After all the func_tank's have spawned

	CBaseEntity::Spawn();
}
**/
}