/**
    Happy Chinese New Year!
**/
//爆炸spr
const string szExplosion = "sprites/zerogxplode.spr";
//粒子spr
const array<string> aryGlow = { "sprites/glow_bg.spr", "sprites/glow_blu.spr", "sprites/glow_grn.spr", "sprites/glow_org.spr", "sprites/glow_prp.spr", "sprites/glow_red.spr", "sprites/glow_ylo.spr"};
//烟花模型
const string szModel = "models/rpgrocket.mdl";
//发射音效
const string szFireSound = "weapons/rocketfire1.wav";
//部署音效
const string szPlaceSound = "weapons/mine_deploy.wav";
//爆炸音效
const string szExplosionSound = "weapons/explode5.wav";
//尾迹音效
const string szFollowTrace = "sprites/smoke.spr";
//烟花速度
const float flSpeed = 500.0f;
//飞行时间
const float flExplodeTime = 6.0f;
//发射间隔
const float flMaxWait = 3;
//发射默认等待时间
const float flDelay = 3;
//最大等待时间
const float flMaxDelay = 15.0f;

void PluginInit(){
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo("ahhh");
}

void MapInit(){
	g_Game.PrecacheModel( szFollowTrace );
    g_Game.PrecacheModel( szExplosion );
    g_Game.PrecacheModel( szModel );
	g_SoundSystem.PrecacheSound( szFireSound );	
    g_SoundSystem.PrecacheSound( szExplosionSound );	
    g_SoundSystem.PrecacheSound( szPlaceSound );	
	
    g_Game.PrecacheGeneric( szFollowTrace );
	g_Game.PrecacheGeneric( szExplosion );
    g_Game.PrecacheGeneric( szModel );
	g_Game.PrecacheGeneric( "sound/" + szFireSound );
    g_Game.PrecacheGeneric( "sound/" + szExplosionSound );
    g_Game.PrecacheGeneric( "sound/" + szPlaceSound );

    for(uint i = 0; i < aryGlow.length(); i++){
        g_Game.PrecacheModel( aryGlow[i] );
        g_Game.PrecacheGeneric( aryGlow[i] );

    }
    for(uint i = 0; i < aryPlayerTime.length(); i++){
        aryPlayerTime[i] = 0;
    }
}

void FireWorkExplosion(CBaseEntity@ pEntity){
    Vector vecOrigin = pEntity.pev.origin;
    g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_MUSIC, szExplosionSound, 1.0, ATTN_NORM, 0, PITCH_NORM );
    pEntity.pev.flags |= FL_KILLME;
    g_EntityFuncs.Remove(@pEntity);
    NetworkMessage g(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
        g.WriteByte(TE_GLOWSPRITE);
        g.WriteCoord(vecOrigin.x);
        g.WriteCoord(vecOrigin.y);
        g.WriteCoord(vecOrigin.z);
        g.WriteShort(g_EngineFuncs.ModelIndex(szExplosion));
        g.WriteByte(20);
        g.WriteByte(200);
        g.WriteByte(255);
	g.End();

    NetworkMessage l(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
        l.WriteByte(TE_DLIGHT);
        l.WriteCoord(vecOrigin.x);
        l.WriteCoord(vecOrigin.y);
        l.WriteCoord(vecOrigin.z);
        l.WriteByte(255);
        l.WriteByte(255);
        l.WriteByte(255);
        l.WriteByte(255);
        l.WriteByte(255);
        l.WriteByte(255);
	l.End();
    
    for(uint i = 0; i < aryGlow.length(); i++){
        NetworkMessage t(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
            t.WriteByte(TE_SPRITETRAIL);
            t.WriteCoord(vecOrigin.x);
            t.WriteCoord(vecOrigin.y);
            t.WriteCoord(vecOrigin.z);
            t.WriteCoord(vecOrigin.x);
            t.WriteCoord(vecOrigin.y);
            t.WriteCoord(vecOrigin.z);
            t.WriteShort(g_EngineFuncs.ModelIndex(aryGlow[i]));
            t.WriteByte(Math.RandomLong(8, 16));
            t.WriteByte(50);
            t.WriteByte(Math.RandomLong(8, 16));
            t.WriteByte(255);
            t.WriteByte(Math.RandomLong(64, 96));
        t.End();
    }
}

void FireWorkLanch(CBaseEntity@ pEntity){
    g_SoundSystem.EmitSoundDyn( pEntity.edict(), CHAN_AUTO, szFireSound, 1.0, ATTN_NORM, 0, PITCH_NORM );
    pEntity.pev.velocity = Vector(Math.RandomFloat(-10, 10), 0, flSpeed);
    NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
        m.WriteByte(TE_BEAMFOLLOW);
        m.WriteShort(pEntity.entindex());
        m.WriteShort(g_EngineFuncs.ModelIndex(szFollowTrace));
        m.WriteByte(uint8(flExplodeTime * 10));
        m.WriteByte(2);
        m.WriteByte(255);
        m.WriteByte(255);
        m.WriteByte(255);
        m.WriteByte(200);
	m.End();
    g_Scheduler.SetTimeout("FireWorkExplosion", flExplodeTime, @pEntity);
}

array<float> aryPlayerTime(33);
CClientCommand g_HelloWorld("firework", "firework", @Firework);
void Firework(const CCommand@ pArgs) {
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    float flTime = g_Engine.time - aryPlayerTime[pPlayer.entindex()];
    if(flTime <= flMaxWait){
        g_PlayerFuncs.ClientPrint(@pPlayer, HUD_PRINTCENTER, "Wait for " + formatFloat(flMaxWait - flTime, width: 2, precision: 2) + "s");
        return;
    }
    float flTempDelay = flDelay;
    if(pArgs.ArgC() > 1)
        flTempDelay = Math.clamp(0.2, flMaxDelay, atof(pArgs[1]));
    Vector vecOrigin = pPlayer.Center();
    vecOrigin.z = pPlayer.pev.absmin.z + 16;
    CBaseEntity@ pEntity = g_EntityFuncs.Create("info_target",  vecOrigin, Vector(90, 0, 0), true, pPlayer.edict());
    g_EntityFuncs.SetModel(@pEntity, szModel);
    g_EntityFuncs.DispatchSpawn(pEntity.edict());
    pEntity.pev.solid = SOLID_NOT;
    pEntity.pev.movetype = MOVETYPE_BOUNCEMISSILE;
	g_Scheduler.SetTimeout("FireWorkLanch", flTempDelay, @pEntity);
    g_SoundSystem.EmitSoundDyn( pPlayer.edict(), CHAN_AUTO, szPlaceSound, 1.0, ATTN_NORM, 0, PITCH_NORM );
    aryPlayerTime[pPlayer.entindex()] = g_Engine.time;
}