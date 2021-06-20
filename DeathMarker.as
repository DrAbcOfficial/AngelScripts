//get this file here
//https://github.com/wootguy/sc_rust/blob/master/ByteBuffer.as
//using commit: 07b0f760f780ad39084357f05fdead83e23e9c9d
#include "ByteBuffer"

//记录x秒
const float flRecord = 5;
//记录间隔
const float flRecordInteve = 0.2;
//fade time
const float flRecordFadeTime = 2;
//fade think time
const float flRecordFadeThinkTime = 0.01;
//血迹模型
const string szModel = "models/gib_skull.mdl";
//人物模型
const string szPlayerModel = "models/player.mdl";
//连接线模型
const string szSprModel = "sprites/laserbeam.spr";
//记录格式
//记录总数,路径点总数,秒,间隔,Eox,Eoy,Eoz,Ea,ox,oy,oz,ax,ay,az,ia,ig,bg
//保存路径，需要自己新建文件夹
const string szSavePath = "scripts/plugins/store/deathmarker/";
//一张图最多有多少血迹
const uint iMaxKeepPerMap = 96;
//lateinit
int iRecordCount;

array<array<CBloodStainInfo@>> aryPlayerInfo(33);
array<float> aryPlayerRecordTimerInterve(33);
array<int> aryPlayerRecordOldSequence(33);
array<CBloodStainSaveInfo@> arySzBlds();
string szMapName = "";

void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("Dr.Abc");
    g_Module.ScriptInfo.SetContactInfo("死亡指引着前进💀");
    iRecordCount = int(flRecord / flRecordInteve);
}

void MapInit()
{
    g_CustomEntityFuncs.RegisterCustomEntity("CDSBloodstain", "bloodstain");
    g_Game.PrecacheOther("bloodstain");
    g_CustomEntityFuncs.RegisterCustomEntity("CDSBloodstainDancer", "bloodstaindancer");
    g_Game.PrecacheOther("bloodstaindancer");

    g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @Killed);
    g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerSpawn);
    g_Hooks.RegisterHook(Hooks::Weapon::WeaponPrimaryAttack, @WeaponPrimaryAttack);
    g_Hooks.RegisterHook(Hooks::Weapon::WeaponSecondaryAttack, @WeaponSecondaryAttack);
    g_Hooks.RegisterHook(Hooks::Weapon::WeaponTertiaryAttack, @WeaponTertiaryAttack);
    g_Hooks.RegisterHook(Hooks::Player::PlayerPostThink, @PlayerPostThink);

    if(szMapName != "")
        SaveFile(szMapName);
    szMapName = g_Engine.mapname;
}

void MapActivate()
{
    arySzBlds = {};
    ReadFile(szMapName);
}

class CBloodStainSaveInfo
{
    Vector vecOrigin;
    float flAngle;
    array<CBloodStainInfo@> aryInfos = {};
}

class CBloodStainInfo
{
    Vector vecOrigin;
    Vector vecAngles;

    int iAnimation;
    int iGaitAnimation;
    bool bOnGround;

    CBloodStainInfo(Vector _o, Vector _a, int _i, int _gi, bool _g = true)
    {
        vecOrigin = _o;
        vecAngles = _a;
        iAnimation = _i;
        iGaitAnimation = _gi;
        bOnGround = _g;
    }
}

class CDSBloodstainDancer: ScriptBaseAnimating
{
    void Spawn()
    { 
        g_EntityFuncs.SetModel(self, szPlayerModel);
        self.pev.movetype = MOVETYPE_NOCLIP;
        self.pev.solid = SOLID_NOT;
        
        self.pev.rendermode = kRenderTransAdd;
        self.pev.renderamt = 1;
        self.pev.rendercolor = Vector(255, 0, 0);
        self.pev.renderfx = kRenderFxGlowShell;

        self.ResetSequenceInfo();
        self.ResetGaitSequenceInfo();
        self.StudioFrameAdvance();
    }
}

class CDSBloodstain: ScriptBaseAnimating
{
    float flRecordTime = flRecord;
    float flRecordInterveTime = flRecordInteve;

    private Vector vecFadeInterve;
    //不能保存引用，否则会因玩家变化
    private array<CBloodStainInfo@> aryInfo;
    private EHandle pDancer;
    private uint iIndex = 0;
    private Vector vecOriginIntev;
    private Vector vecAnglesIntev;

    int ObjectCaps()
    {
        return BaseClass.ObjectCaps() | FCAP_IMPULSE_USE;
    }

    void SetInfo(array<CBloodStainInfo@> _a)
    {
        aryInfo = _a;
        //从最老到最新
        aryInfo.reverse();
    }

    void Spawn()
    { 
        g_EntityFuncs.SetModel(self, szModel);
        //8x8x8大小
        g_EntityFuncs.SetSize(self.pev, Vector(-4, -4, -4), Vector(4, 4, 4));
        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_TRIGGER;
        self.pev.rendermode = kRenderTransTexture;
        self.pev.renderamt = 160;
        self.pev.rendercolor = Vector(255, 0, 0);
        self.pev.renderfx = kRenderFxDistort;

        g_EngineFuncs.DropToFloor(self.edict());
    }

    void Precache()
    {
        g_Game.PrecacheModel(szModel);
        g_Game.PrecacheGeneric(szModel);
        g_Game.PrecacheModel(szPlayerModel);
        g_Game.PrecacheGeneric(szPlayerModel);
        g_Game.PrecacheModel(szSprModel);
        g_Game.PrecacheGeneric(szSprModel);
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue = 0.0f)
    {
        if(pDancer.IsValid())
            return;
        if(pActivator.IsPlayer() && pActivator.IsAlive())
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>(@pActivator);
            if(pPlayer.IsNetClient())
            {
                CBaseAnimating@ pEntity = cast<CBaseAnimating@>(
                    g_EntityFuncs.Create("bloodstaindancer", self.pev.origin, self.pev.angles, false, null));
                iIndex = 0;
                SetDancerInfo();
                SetIntev();
                SetThink(ThinkFunction(PlayThink));
                self.pev.nextthink = g_Engine.time;
                pDancer = EHandle(@pEntity);

                NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
                    m.WriteByte(TE_BEAMENTS);
                    m.WriteShort(self.entindex());
                    m.WriteShort(pEntity.entindex());
                    m.WriteShort(g_EngineFuncs.ModelIndex(szSprModel));
                    m.WriteByte(0);
                    m.WriteByte(1);
                    m.WriteByte(255);
                    m.WriteByte(8);
                    m.WriteByte(0);
                    m.WriteByte(255);
                    m.WriteByte(0);
                    m.WriteByte(0);
                    m.WriteByte(120);
                    m.WriteByte(0);
                m.End();
            }
        }
    }

    void SetDancerInfo()
    {
        if(pDancer.IsValid())
        {
            CBaseEntity@ pEntity = pDancer.GetEntity();
            CBloodStainInfo@ pInfo = aryInfo[iIndex];
            pEntity.pev.origin = pInfo.vecOrigin;
            pEntity.pev.angles = pInfo.vecAngles;
            pEntity.pev.sequence = pInfo.iAnimation;
            pEntity.pev.gaitsequence = pInfo.iGaitAnimation;
            pEntity.pev.frame = 0;
        }
    }

    bool SetIntev()
    {
        if(iIndex + 1 < aryInfo.length() - 1)
        {
            CBloodStainInfo@ pInfo = aryInfo[iIndex];
            CBloodStainInfo@ pNext = aryInfo[iIndex+1];
            vecOriginIntev = (pNext.vecOrigin - pInfo.vecOrigin)/flRecordInterveTime;
            Vector vecAngleDiff = pNext.vecAngles - pInfo.vecAngles;
            //不准有大于180的值
            if(abs(vecAngleDiff.y) > 180)
                vecAngleDiff.y = 360 - abs(vecAngleDiff.y % 360);
            vecAnglesIntev = vecAngleDiff/flRecordInterveTime;
            return true;
        }
        return false;
    }

    void PlayThink()
    {
        if(pDancer.IsValid())
        {
            CBaseAnimating@ pEntity = cast<CBaseAnimating@>(pDancer.GetEntity());
            if(iIndex < aryInfo.length())
            {
                SetDancerInfo();
                SetIntev();

                pEntity.pev.velocity = vecOriginIntev;
                pEntity.pev.avelocity = vecAnglesIntev;
                pEntity.InitBoneControllers();
                pEntity.SetBlending(0, 0);
                iIndex++;
                self.pev.nextthink = g_Engine.time + flRecordInterveTime;
            }
            else
            {
                pEntity.pev.velocity = g_vecZero;
                pEntity.pev.avelocity = g_vecZero;
                pEntity.pev.origin = aryInfo[iIndex-1].vecOrigin;
                vecFadeInterve = pEntity.pev.rendercolor * flRecordFadeThinkTime / flRecordFadeTime;
                SetThink(ThinkFunction(FadeThink));
                self.pev.nextthink = g_Engine.time;
            }
        }
    }

    void FadeThink()
    {
        if(pDancer.IsValid())
        {
            CBaseAnimating@ pEntity = cast<CBaseAnimating@>(pDancer.GetEntity());
            if(pEntity.pev.rendercolor.Length() >= 1)
            {
                pEntity.pev.rendercolor = pEntity.pev.rendercolor - vecFadeInterve;
                self.pev.nextthink = g_Engine.time + flRecordFadeThinkTime;
            }
            else
            {
                NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
                    m.WriteByte(TE_KILLBEAM);
                    m.WriteShort(pEntity.entindex());
                m.End();
                SetThink(null);
                g_EntityFuncs.Remove(@pEntity);
            }
        }
    }
}

void SaveFile(string szPath)
{
    if(arySzBlds.length() <= 0)
        return;
    ByteBuffer fb;

    fb.Write(arySzBlds.length());
    for(uint i = 0; i < arySzBlds.length(); i++)
    {
        if(arySzBlds[i] is null)
            continue;

        fb.Write(arySzBlds[i].aryInfos.length());
        fb.Write(flRecord);
        fb.Write(flRecordInteve);

        fb.Write(arySzBlds[i].vecOrigin.x);
        fb.Write(arySzBlds[i].vecOrigin.y);
        fb.Write(arySzBlds[i].vecOrigin.z);
        fb.Write(arySzBlds[i].flAngle);

        for(uint j = 0; j < arySzBlds[i].aryInfos.length(); j++)
        {
            fb.Write(arySzBlds[i].aryInfos[j].vecOrigin.x);
            fb.Write(arySzBlds[i].aryInfos[j].vecOrigin.y);
            fb.Write(arySzBlds[i].aryInfos[j].vecOrigin.z);

            fb.Write(arySzBlds[i].aryInfos[j].vecAngles.x);
            fb.Write(arySzBlds[i].aryInfos[j].vecAngles.y);
            fb.Write(arySzBlds[i].aryInfos[j].vecAngles.z);

            fb.Write(arySzBlds[i].aryInfos[j].iAnimation);
            fb.Write(arySzBlds[i].aryInfos[j].iGaitAnimation);
        }
    }

    File @pFile = g_FileSystem.OpenFile( szSavePath + szPath , OpenFile::WRITE );
    if ( pFile !is null)
    {
        string dataString = fb.base128encode();
        pFile.Write(dataString);
        pFile.Close();  
    }
}

void ReadFile(string szPath)
{
    File @pFile = g_FileSystem.OpenFile( szSavePath + szPath , OpenFile::READ );
    ByteBuffer@ fb;
    if (pFile !is null)
    {
        @fb = ByteBuffer(pFile);
        pFile.Close();  
    }
    if(fb is null)
        return;
    uint iAllCount = fb.ReadUInt32();
    for(uint a = 0; a < iAllCount; a++)
    {
        uint iCount = fb.ReadUInt32();
        float flRecordTime = fb.ReadFloat();
        float flInterve = fb.ReadFloat();
        float ox = fb.ReadFloat();
        float oy = fb.ReadFloat();
        float oz = fb.ReadFloat();
        Vector vecOrigin = Vector(ox, oy, oz);
        float flAngle = fb.ReadFloat();
        array<CBloodStainInfo@> aryInfos = {};
        for(uint i = 0; i < iCount; i++)
        {
            float oex = fb.ReadFloat();
            float oey = fb.ReadFloat();
            float oez = fb.ReadFloat();

            float aex = fb.ReadFloat();
            float aey = fb.ReadFloat();
            float aez = fb.ReadFloat();

            int ia = fb.ReadInt32();
            int iga = fb.ReadInt32();
            aryInfos.insertLast(CBloodStainInfo(
                Vector(oex, oey, oez),
                Vector(aex, aey, aez),
                ia,
                iga
                ));
        }
        if(fb.err != 0)
            return;
        CDSBloodstain@ pEntity = CreateBloodStain(vecOrigin, Vector(0, flAngle, 0), aryInfos);
        pEntity.flRecordTime = flRecordTime;
        pEntity.flRecordInterveTime = flInterve;

        CBloodStainSaveInfo pSave;
        pSave.vecOrigin = vecOrigin;
        pSave.flAngle = flAngle;
        pSave.aryInfos = aryInfos;

        if(arySzBlds.length() < iMaxKeepPerMap)
            arySzBlds.insertLast(pSave);
    }
}

CDSBloodstain@ CreateBloodStain(Vector vecOrigin, Vector vecAngle, array<CBloodStainInfo@> aryInfos)
{
    CDSBloodstain@ pEntity = cast<CDSBloodstain@>(CastToScriptClass(g_EntityFuncs.Create("bloodstain", vecOrigin, vecAngle, false, null)));
    pEntity.SetInfo(aryInfos);
    return pEntity;
}

void RecordPlayerInfo(CBasePlayer@ pPlayer, bool bDontIgnore = true)
{
    if((bDontIgnore && pPlayer.pev.sequence != aryPlayerRecordOldSequence[pPlayer.entindex()]) || 
        g_Engine.time - aryPlayerRecordTimerInterve[pPlayer.entindex()] >= flRecordInteve)
    {
        aryPlayerInfo[pPlayer.entindex()].removeLast();
        CBloodStainInfo pInfo(
            pPlayer.pev.origin, pPlayer.pev.angles, 
            pPlayer.pev.sequence, pPlayer.pev.gaitsequence, 
            pPlayer.pev.flags & FL_ONGROUND != 0);
        aryPlayerInfo[pPlayer.entindex()].insertAt(0, pInfo);
        aryPlayerRecordTimerInterve[pPlayer.entindex()] = g_Engine.time;
        aryPlayerRecordOldSequence[pPlayer.entindex()] = pPlayer.pev.sequence;
    }
}

HookReturnCode Killed( CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib )
{
    if(pPlayer is null || !pPlayer.IsNetClient())
        return HOOK_CONTINUE;

    array<CBloodStainInfo@>@ aryInfo = aryPlayerInfo[pPlayer.entindex()];
    for(uint i = 0; i < aryInfo.length(); i++)
    {
        //不完整，直接放弃
        if(aryInfo[i] is null)
            return HOOK_CONTINUE;
    }
    //更新记录最后一刻信息
    RecordPlayerInfo(@pPlayer);
    aryPlayerInfo[pPlayer.entindex()][0].iAnimation = Math.RandomLong(12,18);

    //创建实体
    Vector vecOrigin = pPlayer.pev.origin;
    Vector vecAngles = pPlayer.pev.angles;
    if(!aryInfo[1].bOnGround)
    {
        bool bGroundFlag = false;
        for(uint i = 1; i < aryInfo.length(); i++)
        {
            if(aryInfo[i].bOnGround)
            {
                vecOrigin = aryInfo[i].vecOrigin;
                vecAngles = aryInfo[i].vecAngles;
                bGroundFlag = true;
                break;
            }
        }
        if(!bGroundFlag)
            return HOOK_CONTINUE;
    }
    else
        vecOrigin.z = pPlayer.pev.absmin.z + 2;

    CreateBloodStain(vecOrigin, vecAngles, aryInfo);
    CBloodStainSaveInfo pSave;
    pSave.vecOrigin = vecOrigin;
    pSave.flAngle = vecAngles.y;
    pSave.aryInfos = aryInfo;
    arySzBlds.insertLast(pSave);

    return HOOK_CONTINUE;
}

HookReturnCode PlayerSpawn(CBasePlayer@ pPlayer)
{
    if(pPlayer is null || !pPlayer.IsNetClient())
        return HOOK_CONTINUE;
    aryPlayerInfo[pPlayer.entindex()] = array<CBloodStainInfo@>(iRecordCount);
    aryPlayerRecordTimerInterve[pPlayer.entindex()] = g_Engine.time;
    aryPlayerRecordOldSequence[pPlayer.entindex()] = -1;
    return HOOK_CONTINUE;
}

HookReturnCode WeaponPrimaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
{
    if(pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive())
        return HOOK_CONTINUE;  
    RecordPlayerInfo(@pPlayer);
    return HOOK_CONTINUE;
}

HookReturnCode WeaponSecondaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
{
    if(pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive())
        return HOOK_CONTINUE; 
    RecordPlayerInfo(@pPlayer);
    return HOOK_CONTINUE;
}

HookReturnCode WeaponTertiaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
{
    if(pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive())
        return HOOK_CONTINUE; 
    RecordPlayerInfo(@pPlayer);
    return HOOK_CONTINUE;
}

HookReturnCode PlayerPostThink(CBasePlayer@ pPlayer)
{
    if(pPlayer is null || !pPlayer.IsConnected() || !pPlayer.IsAlive())
        return HOOK_CONTINUE;
    RecordPlayerInfo(@pPlayer, false);
    return HOOK_CONTINUE;
}