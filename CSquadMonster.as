const int SF_SQUADMONSTER_LEADER = 32

enum SQUAD_SLOT{
    bits_NO_SLOT = 0,
    bits_SLOT_HGRUNT_ENGAGE1 = 1 << 0,
    bits_SLOT_HGRUNT_ENGAGE2 = 1 << 1,
    bits_SLOTS_HGRUNT_ENGAGE = bits_SLOT_HGRUNT_ENGAGE1 | bits_SLOT_HGRUNT_ENGAGE2,
    bits_SLOT_HGRUNT_GRENADE1 = 1 << 2,
    bits_SLOT_HGRUNT_GRENADE2 = 1 << 3,
    bits_SLOTS_HGRUNT_GRENADE = bits_SLOT_HGRUNT_GRENADE1 | bits_SLOT_HGRUNT_GRENADE2,
    bits_SLOT_AGRUNT_HORNET1 = 1 << 4,
    bits_SLOT_AGRUNT_HORNET2 = 1 << 5,
    bits_SLOT_AGRUNT_CHASE = 1 << 6,
    bits_SLOTS_AGRUNT_HORNET = bits_SLOT_AGRUNT_HORNET1 | bits_SLOT_AGRUNT_HORNET2,
    bits_SLOT_HOUND_ATTACK1 = 1 << 7,
    bits_SLOT_HOUND_ATTACK2 = 1 << 8,
    bits_SLOT_HOUND_ATTACK3 = 1 << 9,
    bits_SLOTS_HOUND_ATTACK = bits_SLOT_HOUND_ATTACK1 | bits_SLOT_HOUND_ATTACK2 | bits_SLOT_HOUND_ATTACK3,
    bits_SLOT_SQUAD_SPLIT = 1 << 10
};

const int NUM_SLOTS = 11// update this every time you add/remove a slot.

const int MAX_SQUAD_MEMBERS = 5


class CSquadMonster : ScriptBaseMonsterEntity
{
	// squad leader info
	EHandle	m_hSquadLeader;		// who is my leader
	array<EHandle> m_hSquadMember(MAX_SQUAD_MEMBERS-1);	// valid only for leader
	int m_afSquadSlots;
	float m_flLastEnemySightTime; // last time anyone in the squad saw the enemy
	bool	m_fEnemyEluded;
	// squad member info
	int		m_iMySlot;// this is the behaviour slot that the monster currently holds in the squad. 

	//=========================================================
    // CheckEnemy
    //=========================================================
    int CheckEnemy ( CBaseEntit@ pEnemy )
    {
        int iUpdatedLKP;
        iUpdatedLKP = BaseClass.CheckEnemy ( self.m_hEnemy );
        // communicate with squad members about the enemy IF this individual has the same enemy as the squad leader.
        if ( InSquad() && self.m_hEnemy == MySquadLeader().m_hEnemy )
        {
            if ( iUpdatedLKP != 0 )
                // have new enemy information, so paste to the squad.
                SquadPasteEnemyInfo();
            else
                // enemy unseen, copy from the squad knowledge.
                SquadCopyEnemyInfo();
        }
        return iUpdatedLKP;
    }

	//=========================================================
    // StartMonster
    //=========================================================
    void StartMonster()
    {
        BaseClass.StartMonster();
        if ( self.m_afCapability & bits_CAP_SQUAD != 0  && !InSquad() )
        {
            if ( !pev.netname != "" )
            {
                // if I have a groupname, I can only recruit if I'm flagged as leader
                if ( pev.spawnflags & SF_SQUADMONSTER_LEADER == 0 )
                    return;
            }

            // try to form squads now.
            int iSquadSize = SquadRecruit( 1024, 4 );


            if ( IsLeader() && pev.classname == "monster_human_grunt")
            {
                SetBodygroup( 1, 1 ); // UNDONE: truly ugly hack
                pev.skin = 0;
            }
        }
    }

	void VacateSlot()
    {
        if ( m_iMySlot != bits_NO_SLOT && InSquad() )
        {
    //		ALERT ( at_aiconsole, "Vacated Slot %d - %d\n", m_iMySlot, m_hSquadLeader->m_afSquadSlots );
            MySquadLeader().m_afSquadSlots &= ~m_iMySlot;
            m_iMySlot = bits_NO_SLOT;
        }
    }
    
	void ScheduleChange ()
    {
        VacateSlot();
    }

	void Killed( entvars_t@ pevAttacker, int iGib )
    {
        VacateSlot();
        if ( InSquad() )
            MySquadLeader().SquadRemove( this );

        BaseClass.Killed ( @pevAttacker, iGib );
    }

	bool OccupySlot( int iDesiredSlots )
    {
        int i;
        int iMask;
        int iSquadSlots;
        if ( !InSquad() )
            return true;
        if ( SquadEnemySplit() )
        {
            m_iMySlot = bits_SLOT_SQUAD_SPLIT;
            return TRUE;
        }

        CSquadMonster@ pSquadLeader = MySquadLeader();

        if (iDesiredSlots ^ pSquadLeader.m_afSquadSlots == 0)
            return FALSE;
        iSquadSlots = pSquadLeader.m_afSquadSlots;
        for ( i = 0; i < NUM_SLOTS; i++ )
        {
            iMask = 1<<i;
            if (iDesiredSlots & iMask != 0) // am I looking for this bit?
            {
                if (iSquadSlots & iMask == 0)	// Is it already taken?
                {
                    // No, use this bit
                    pSquadLeader.m_afSquadSlots |= iMask;
                    m_iMySlot = iMask;
    //				ALERT ( at_aiconsole, "Took slot %d - %d\n", i, m_hSquadLeader->m_afSquadSlots );
                    return true;
                }
            }
        }
        return false;
    }
	bool NoFriendlyFire()
    {
        if (!InSquad())
            return true;

        CPlane	backPlane;
        CPlane  leftPlane;
        CPlane	rightPlane;

        Vector	vecLeftSide;
        Vector	vecRightSide;
        Vector	v_left;

        //!!!BUGBUG - to fix this, the planes must be aligned to where the monster will be firing its gun, not the direction it is facing!!!

        if ( m_hEnemy != NULL )
        {
            UTIL_MakeVectors ( UTIL_VecToAngles( m_hEnemy->Center() - pev->origin ) );
        }
        else
        {
            // if there's no enemy, pretend there's a friendly in the way, so the grunt won't shoot.
            return FALSE;
        }

        //UTIL_MakeVectors ( pev->angles );
        
        vecLeftSide = pev->origin - ( gpGlobals->v_right * ( pev->size.x * 1.5 ) );
        vecRightSide = pev->origin + ( gpGlobals->v_right * ( pev->size.x * 1.5 ) );
        v_left = gpGlobals->v_right * -1;

        leftPlane.InitializePlane ( gpGlobals->v_right, vecLeftSide );
        rightPlane.InitializePlane ( v_left, vecRightSide );
        backPlane.InitializePlane ( gpGlobals->v_forward, pev->origin );

    /*
        ALERT ( at_console, "LeftPlane: %f %f %f : %f\n", leftPlane.m_vecNormal.x, leftPlane.m_vecNormal.y, leftPlane.m_vecNormal.z, leftPlane.m_flDist );
        ALERT ( at_console, "RightPlane: %f %f %f : %f\n", rightPlane.m_vecNormal.x, rightPlane.m_vecNormal.y, rightPlane.m_vecNormal.z, rightPlane.m_flDist );
        ALERT ( at_console, "BackPlane: %f %f %f : %f\n", backPlane.m_vecNormal.x, backPlane.m_vecNormal.y, backPlane.m_vecNormal.z, backPlane.m_flDist );
    */

        CSquadMonster *pSquadLeader = MySquadLeader();
        for (int i = 0; i < MAX_SQUAD_MEMBERS; i++)
        {
            CSquadMonster *pMember = pSquadLeader->MySquadMember(i);
            if (pMember && pMember != this)
            {

                if ( backPlane.PointInFront  ( pMember->pev->origin ) &&
                    leftPlane.PointInFront  ( pMember->pev->origin ) && 
                    rightPlane.PointInFront ( pMember->pev->origin) )
                {
                    // this guy is in the check volume! Don't shoot!
                    return FALSE;
                }
            }
        }

        return TRUE;
    }

	// squad functions still left in base class
	CSquadMonster @MySquadLeader( ) 
	{ 
		CSquadMonster @pSquadLeader = (CSquadMonster @)((CBaseEntity @)m_hSquadLeader); 
		if (pSquadLeader != NULL)
			return pSquadLeader;
		return this;
	}
	CSquadMonster @MySquadMember( int i ) 
	{ 
		if (i >= MAX_SQUAD_MEMBERS-1)
			return this;
		else
			return (CSquadMonster @)((CBaseEntity @)m_hSquadMember[i]); 
	}
	int	InSquad ( void ) { return m_hSquadLeader != NULL; }
	int IsLeader ( void ) { return m_hSquadLeader == this; }
	int SquadJoin ( int searchRadius );
	int SquadRecruit ( int searchRadius, int maxMembers );
	int	SquadCount( void );
	void SquadRemove( CSquadMonster @pRemove );
	void SquadUnlink( void );
	bool SquadAdd( CSquadMonster @pAdd );
	void SquadDisband( void );
	void SquadAddConditions ( int iConditions );
	void SquadMakeEnemy ( CBaseEntity @pEnemy );
	void SquadPasteEnemyInfo ( void );
	void SquadCopyEnemyInfo ( void );
	bool SquadEnemySplit ( void );
	bool SquadMemberInRange( const Vector &vecLocation, float flDist );

	virtual CSquadMonster @MySquadMonsterPointer( void ) { return this; }

	static TYPEDESCRIPTION m_SaveData[];

	int	Save( CSave &save ); 
	int Restore( CRestore &restore );

	bool FValidateCover ( const Vector &vecCoverLocation );

	MONSTERSTATE GetIdealState ( void );
	Schedule_t	*GetScheduleOfType ( int iType );
};

