class CMutatorPilot : CMutator
{
    CMutatorPilot()
    {
        Name = "Mutator-Pilot";
        DisplayName = "铁驭";
        HelpInfo = "喷气背包允许二段跳, 二段跳后贴墙将进入滑行模式";
        Type = Mutator::MUTATOR_TYPE::MUTATOR_PRETHINK;
        Pre = true;
    }

    private string szSpr = "sprites/laserbeam.spr";
    private string szSound = "tfc/weapons/airgun_1.wav";

    bool Precache() override
    {
        g_Game.PrecacheModel( szSpr );
		g_Game.PrecacheGeneric( szSpr );

        g_SoundSystem.PrecacheSound( szSound );
		g_Game.PrecacheGeneric( "sound/" + szSound );
        return true;
    }

    bool IsInWall(TraceResult&in tr)
    {
        return tr.flFraction <= 0.5;
    }

    void StartGlide(CBasePlayer@ pPlayer, bool bIsRight)
    {
        PlayerData::Set(pPlayer, "_WALL_GLIDE_", "1"); 
        Vector vecForward = g_Engine.v_forward;
        vecForward.z = 0;
        pPlayer.pev.velocity = pPlayer.pev.velocity + g_Engine.v_right * (bIsRight ? 1 : -1 ) * 200;
        pPlayer.pev.velocity = pPlayer.pev.velocity + vecForward * 128;
        pPlayer.pev.gravity = 0.05;

        NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
            m.WriteByte(TE_BEAMFOLLOW);
            m.WriteShort(pPlayer.entindex());
            m.WriteShort(g_EngineFuncs.ModelIndex(szSpr));
            m.WriteByte(2);
            m.WriteByte(8);
            m.WriteByte(125);
            m.WriteByte(125);
            m.WriteByte(255);
            m.WriteByte(125);
        m.End();
    }

    void StopGlide(CBasePlayer@ pPlayer)
    {
        PlayerData::Set(pPlayer, "_WALL_GLIDE_", "0");
        pPlayer.pev.gravity = 1;
    }

    bool PlayerPreThink(CBasePlayer@ pPlayer, uint& out uiFlags) override
    {
        if(pPlayer is null || !pPlayer.IsAlive() || !pPlayer.m_fLongJump)
            return true;
        if(pPlayer.pev.flags & FL_ONGROUND == 0 && (pPlayer.m_afPhysicsFlags == 0 || pPlayer.m_afPhysicsFlags == PFLAG_USING) )
        {
            if(pPlayer.pev.oldbuttons & IN_JUMP == 0 && pPlayer.pev.button & IN_JUMP != 0 && !PlayerData::GetBool(pPlayer, "_DOUBLE_JUMP_"))
            {
                PlayerData::Set(pPlayer, "_DOUBLE_JUMP_", "1");
                Math.MakeVectors(pPlayer.pev.angles);
                Vector vecAgles = Math.VecToAngles(pPlayer.pev.velocity);
                pPlayer.pev.velocity = pPlayer.pev.velocity + g_Engine.v_up * 255;
                g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, szSound, 1.0, ATTN_NORM, 0, 100 + Math.RandomLong( -10, 10 ));
                NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
                m.WriteByte(TE_BEAMFOLLOW);
                    m.WriteShort(pPlayer.entindex());
                    m.WriteShort(g_EngineFuncs.ModelIndex(szSpr));
                    m.WriteByte(1);
                    m.WriteByte(8);
                    m.WriteByte(125);
                    m.WriteByte(125);
                    m.WriteByte(255);
                    m.WriteByte(255);
                m.End();
            }

            if(PlayerData::GetBool(pPlayer, "_DOUBLE_JUMP_"))
            {
                TraceResult tr;
                //不知道有什么作用但是不这样做g_Engine.v_xxx会乱
                Vector vecSrc = pPlayer.pev.origin;
                Math.MakeVectors(pPlayer.pev.angles);
                Math.VecToAngles(pPlayer.pev.velocity);
                //玩家左右16距离寻找墙壁
                float flCheckDist = (pPlayer.pev.size.x + pPlayer.pev.size.y) / 2 + 16;
                //先寻找右边墙壁
                g_Utility.TraceLine(vecSrc, vecSrc + g_Engine.v_right * flCheckDist, dont_ignore_monsters, dont_ignore_glass, pPlayer.edict(), tr);
                bool bIsRight = IsInWall(tr);
                bool bFlag;
                //未找到则寻找左边
                if(!bIsRight)
                {
                    g_Utility.TraceLine(vecSrc, vecSrc + g_Engine.v_right * -flCheckDist, dont_ignore_monsters, dont_ignore_glass, pPlayer.edict(), tr);
                    bFlag = IsInWall(tr);
                }
                else //找到了
                    bFlag = true;

                //找到了墙壁
                if(bFlag && !PlayerData::GetBool(pPlayer, "_WALL_FORBIDDEN_GLIDE_"))
                {
                    //移动玩家视角营造滑行效果
                    pPlayer.pev.punchangle.y += bIsRight ? -2 : 2; 
                    pPlayer.pev.punchangle.y = Math.clamp(-20.0f, 20.0f, pPlayer.pev.punchangle.y);
                    //第一次贴墙
                    if(!PlayerData::GetBool(pPlayer, "_WALL_GLIDE_"))
                        StartGlide(pPlayer, bIsRight);
                    else
                    {
                        //帅气的第三人称
                        pPlayer.pev.sequence = 11;
                        pPlayer.pev.gaitsequence = 6;
                        //不准下滑
                        //if(pPlayer.pev.velocity.z > 0)
                        pPlayer.pev.velocity.z = 0;       
                        //再次拍空格则从墙上弹开
                        //Logger::Log(CrossProduct(tr.vecPlaneNormal, pPlayer.pev.angles).z);
                        if(pPlayer.pev.oldbuttons & IN_JUMP == 0 && pPlayer.pev.button & IN_JUMP != 0)
                        {
                            //0.5s允许弹开一次
                            if(g_Engine.time - PlayerData::GetFloat(pPlayer, "_WALL_GLIDE_JUMPTIME_") >= 0.5f)
                            {
                                float flSpeed = Math.max(256, pPlayer.pev.velocity.Length());
                                pPlayer.pev.velocity = pPlayer.pev.velocity + tr.vecPlaneNormal * flSpeed + g_Engine.v_up * flSpeed;
                                PlayerData::Set(pPlayer, "_WALL_GLIDE_JUMPTIME_", g_Engine.time);
                                g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, szSound, 1.0, ATTN_NORM, 0, 100 + Math.RandomLong( -10, 10 ));
                                StopGlide(pPlayer);
                            }
                        }
                        //速度太慢，直接掉落
                        Vector vecTemp = pPlayer.pev.velocity;
                        vecTemp.z = 0;
                        if(vecTemp.Length() < 96)
                        {
                            //禁止再次贴墙
                            StopGlide(pPlayer);
                            PlayerData::Set(pPlayer, "_WALL_FORBIDDEN_GLIDE_", "1");
                        }
                    }
                }
                else if(PlayerData::GetBool(pPlayer, "_WALL_GLIDE_"))
                    StopGlide(pPlayer);
            }
        }
        else
            Clean(@pPlayer);
        return true;
    }
    
    void Clean(CBasePlayer@ pPlayer)
    {
        if(PlayerData::GetBool(pPlayer, "_DOUBLE_JUMP_"))
                PlayerData::Set(pPlayer, "_DOUBLE_JUMP_", "0");
        if(PlayerData::GetBool(pPlayer, "_WALL_GLIDE_"))
        {
            NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
                m.WriteByte(TE_KILLBEAM);
                m.WriteShort(pPlayer.entindex());
            m.End();
            StopGlide(pPlayer);
        }
        if(PlayerData::GetBool(pPlayer, "_WALL_FORBIDDEN_GLIDE_"))
            PlayerData::Set(pPlayer, "_WALL_FORBIDDEN_GLIDE_", "0");
        if(PlayerData::GetFloat(pPlayer, "_WALL_GLIDE_JUMPTIME_") != 0)
            PlayerData::Set(pPlayer, "_WALL_GLIDE_JUMPTIME_", 0);
    }
}
CMutatorPilot g_MutatorPilot;
