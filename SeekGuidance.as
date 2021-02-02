void PluginInit()
{
    g_Module.ScriptInfo.SetAuthor("Dr.Abc");
    g_Module.ScriptInfo.SetContactInfo( "\n" + 
        """
        迷惘者们的奇迹。                      ------------------------
                                           |      \| T |/          /
        能看见更多来自其他世界的建议，       /   %$^&3$#%^^%**&^     |
        而身无余火者也能看见召唤记号。       |    **7><)?/&&@44#61   /
                                         /     /\    / \    //   |
        圣职的标准长存在信仰中，           |    /  }  /   ----     /
        因此他们不需要不知名的建议。        /  /    \/      \  \\  |
                                        | -                    /
        虽然如此，这个奇迹还是被传颂下来， /    Seek  Guidance    |
        让迷惘者能继续看见些许希望。      -------------------------
        """);
}

void MapInit()
{
    g_CustomEntityFuncs.RegisterCustomEntity("CDSGuidance", "guidance");
    g_Game.PrecacheOther("guidance");

    WriteGuidanceFromBlob();
    ReadGuidanceFromBlob();
    szLastMapname = g_Engine.mapname;
}

const string szModel = "models/misc/guidance.mdl";
const string szRootPath = "scripts/plugins/store/seekguidance/";
const int iMaxKeepDay = 30;
const uint uiMaxKeepPerMap = 96;
const string szCommand = "drawguidance";
dictionary dicPlayerCount = {};
string szLastMapname;
array<CDSGuidanceBlobItem@> aryGuidance = {};
CClientCommand hDrawGuidanceCommand(szCommand, "Attraction a supervision aimed at those who in the hunt for the footpath", @DrawGuidance);

array<string> aryTemplet = { 
    "前有{0}", "前无{0}", "前面需要{0}", "前面要小心{0}", "接下来,{0}很有用", "你以为是{0}吧?", "如果有{0}的话....", 
    "有{0}的预感....", "是{0}的时候了", "{0}", "{0}?", "{0}!", "{0}....", "居然是{0}....", "{0}万岁!", "赐予{0}吧!", "啊,好{0}啊...."
};
array<string> aryConjunctions = {
    "另外", "但是", "所以", "反正", "或者", "不过", "对了", "也就是说", "正因为如此"
};
dictionary dicWord = {
    {"生物", array<string> = {
        "猎头蟹", "僵尸", "外星部队", "士兵", "特工", "重装战士"
        "双人组", "三人行", "你", "您", "伙伴", "你这家伙", "好人", "坏人", "强大的敌人",
        "可爱的家伙", "可怜的家伙", "奇怪的家伙", "敏捷的家伙", "迟钝的家伙", "卑鄙的家伙", 
        "有钱人", "穷人", "骗子", "胖子", "瘦子", "年轻人", "老年人", "老爷爷", "老婆婆", "老师", "英雄", "王者"
    }},
    {"物品", array<string> = {
        "强力物品", "垃圾残渣", "火箭筒", "霰弹枪", "步枪", "手枪", "狙击枪", "能量武器", "近战武器", "爆炸物", "箱子", "按钮", "门", 
        "电池", "血包", "障碍物", "弹药", "陷阱", "管道", "状态物", "重要物品", "工具箱"
    }},
    {"战术", array<string> = {
        "近身战", "远距离战", "逐个击破", "诱出", "包围击破", "伏击", "夹击", 
        "一网打尽", "二刀流", "隐藏", "跳过去", "冲过去", "包抄", "围住", "赌运气", "谨慎", "暂歇", "装死"
    }},
    {"动作", array<string> = {
        "人梯", "小跑", "冲刺", "翻越", "攀爬", "跳跃", "攻击", "跳跃攻击", "冲刺攻击", "落下攻击", 
        "反击", "背刺", "防御", "破坏", "等待", "吃掉", "左顾右盼", "寻求掩护"
    }},
    {"环境", array<string> = {
        "岩浆", "毒气", "辐射", "蒸汽", "大群敌人", "泥沼", "洞窟", "近路", "远路", "隐藏道路", "小路", "死胡同", "迷宫", "洞穴", 
        "光亮的场所", "昏暗的场所", "宽阔的场所", "狭小的场所", "安全区域", "危险区域", "狙击点", "梯子", "升降机", "通风管", "绝景"
    }},
    {"方位", array<string> = {
        "前", "后", "左", "右", "上", "下", "脚下", "头上", "背后"
    }},
    {"部位", array<string> = {
        "头", "颈", "腹部", "背部", "臀部", "手臂", "指头", "腿", "尾巴", "翅膀", 
        "全身上下", "舌", "右臂", "左臂", "拇指", "食指", "中指", "无名指", "小指", "右脚", "左脚", "外壳", "车轮", "核心", "坐骑"
    }},
    {"概念", array<string> = {
        "机会", "危机", "提示", "秘密", "梦话", "幸运", "不幸", "生", "死", "毁灭", "高兴", "愤怒", "痛苦", "悲伤", "泪", "信念", 
        "背叛", "希望", "绝望", "恐怖", "发狂", "胜利", "失败", "牺牲", "光", "暗", "勇气", "轻松", "活泼", "报复", "放弃", "极限", 
        "后悔", "无畏", "男", "女", "友情", "爱情", "鲁莽", "冷静", "意志", "治愈", "静谧", "幽邃", "沉淀物"
    }},
    {"独语", array<string> = {
        "加油", "做的好", "我成功了!", "看我干的好事....", "在这里!", "不是这里!", "我想放弃了....", "好孤单....", "你不是对手!", 
        "干掉他!", "仔细看", "仔细听", "想清楚", "又是这里....", "好戏就要登场", "你没资格", "别停下来", "快回头", "放弃吧", "别放弃", 
        "救救我....", "怎么可能....", "太高了....", "好想离开....", "别慌张", "好像在做梦", "做好心里准备了吗?", "你迟早会有同样的下场", "太阳万岁!", "愿火焰将您引导"
    }}
};


class CDSGuidanceBlobItem
{
    string SteamID;
    Vector vecOrigin;
    float flAngle;
    uint32 t1;
    uint32 d1;
    uint32 w1;
    int32 c;
    uint32 t2;
    uint32 d2;
    uint32 w2;
    time_t t;
}

string SnipMessage(uint t1, uint d1, uint w1, int c, uint t2, uint d2, uint w2)
{
    array<string>@ szKeys = dicWord.getKeys();
    string szTemp = aryTemplet[t1];
    szTemp = szTemp.Replace("{0}", cast<array<string>@>(dicWord[szKeys[d1]])[w1]);
    if(c >= 0){
        szTemp += ", " + aryConjunctions[c] + aryTemplet[t2];
        szTemp = szTemp.Replace("{0}", cast<array<string>@>(dicWord[szKeys[d2]])[w2]);
    }
    return szTemp + ".";
}

class CDSGuidance: ScriptBaseAnimating
{   
    //模板 词典名 词典序号 连接词 模板 词典名 词典序号
    private array<int> aryMessage = {0,0,0,-1,0,0,0};
    private time_t Timestap = 0;
    private float flTime = 0;
    private string szMessage;


    void SetMessage(uint t1, uint d1, uint w1, int c = -1, uint t2 = 0, uint d2 = 0, uint w2 = 0, time_t t = 0)
    {
        aryMessage = {t1, d1, w1, c, t2, d2, w2};
        szMessage = SnipMessage(t1, d1, w1, c, t2, d2, w2);
        if(t == 0)
            Timestap = UnixTimestamp();
        //g_Log.PrintF("" + t1 + " " + d1 + " " + w1 + " " + c + " " + t2 + " " + d2 + " " + w2 + "" + t + "\n");
    }

    int ObjectCaps()
    {
        return BaseClass.ObjectCaps() | FCAP_IMPULSE_USE;
    }

    void Spawn()
    { 
        g_EntityFuncs.SetModel(self, szModel);
        g_EntityFuncs.SetSize(self.pev, Vector(-24, -8, 0), Vector(24, 8, 1));
        self.pev.movetype = MOVETYPE_NONE;
        self.pev.solid = SOLID_TRIGGER;
        self.ResetSequenceInfo();
    }

    void Precache()
    {
        g_Game.PrecacheModel(szModel);
        g_Game.PrecacheGeneric(szModel);
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue = 0.0f)
    {
        if(g_Engine.time - flTime < 5.0f)
            return;
        if(pActivator.IsPlayer() && pActivator.IsAlive())
        {
            CBasePlayer@ pPlayer = cast<CBasePlayer@>(@pActivator);
            if(pPlayer.IsNetClient()){
                g_PlayerFuncs.SayText(pPlayer, "[寻求建言]" + szMessage + "\n");
                flTime = g_Engine.time;
            }
        }
    }
}

CDSGuidance@ CreateGuidance(Vector vecOrigin, float flAngle, string szId, uint t1, uint d1, uint w1, int c = -1, uint t2 = 0, uint d2 = 0, uint w2 = 0, time_t t = 0)
{
    CDSGuidance@ pEntity = cast<CDSGuidance@>(CastToScriptClass(g_EntityFuncs.Create("guidance", vecOrigin, Vector(0, flAngle, 0), false, null)));
    pEntity.SetMessage(t1, d1, w1, c, t2, d2, w2, t);
    pEntity.pev.targetname = szId;
    return pEntity;
}

void WriteGuidanceFromBlob()
{
    if(aryGuidance.length() <= 0)
        return;
    FileWriter(szLastMapname, @aryGuidance);
}

void ReadGuidanceFromBlob()
{
    aryGuidance = {};
    dicPlayerCount.deleteAll();
    array<string>@ pBlob = FileReader(g_Engine.mapname);
    if(pBlob is null)
        return;
    //3 float + 3 float + 3 uint + 1 int + 3 uint + 1 uint64 = 12 + 12 + 12 + 4 + 12 + 8 = 60 bytes
    //g_Log.PrintF(pBlob.ReadSizeValid(60));
    //只要最新的64个
    for(int i = (Math.min(uiMaxKeepPerMap, pBlob.length()) - 1); i >= 0; i--)
    {
        array<string> szLine = pBlob[i].Split("\t");
        if(dicPlayerCount.exists(szLine[0])){
            int iCount = int(dicPlayerCount[szLine[0]]);
            if(iCount < 3)
                dicPlayerCount[szLine[0]] = iCount+1;
            else
                continue;
        }
        else
           dicPlayerCount[szLine[0]] = 1;

        CDSGuidanceBlobItem pItem;
            pItem.SteamID = szLine[0];
            pItem.vecOrigin.x = atof(szLine[1]);
            pItem.vecOrigin.y = atof(szLine[2]);
            pItem.vecOrigin.z = atof(szLine[3]);
            pItem.flAngle = atof(szLine[4]);
            pItem.t1 = atoui(szLine[5]);
            pItem.d1 = atoui(szLine[6]);
            pItem.w1 = atoui(szLine[7]);
            pItem.c = atoi(szLine[8]);
            pItem.t2 = atoui(szLine[9]);
            pItem.d2 = atoui(szLine[10]);
            pItem.w2 = atoui(szLine[11]);
            pItem.t = atoui64(szLine[12]);

        if(TimeDifference(DateTime(), DateTime(pItem.t)).GetDays() <= iMaxKeepDay){
            aryGuidance.insertLast(pItem);
        }
    }
    InitGuidance();
}

void InitGuidance()
{
    for(uint i = 0; i < aryGuidance.length(); i++)
    {
        CreateGuidance(aryGuidance[i].vecOrigin, aryGuidance[i].flAngle, aryGuidance[i].SteamID,
            aryGuidance[i].t1, aryGuidance[i].d1, aryGuidance[i].w1, 
            aryGuidance[i].c, aryGuidance[i].t2, aryGuidance[i].d2, aryGuidance[i].w2, aryGuidance[i].t);
    }
}

void PrintArrayToPlayer(CBasePlayer@ pPlayer, array<string>@ aryPrint)
{
    string sMessage = "";
    for (uint i = 1; i < aryPrint.length()+1; ++i) 
    {
        string szTemp = aryPrint[i-1];
        sMessage += "[" + i + "]" + szTemp.Replace("{0}", "***") + " ";

        if (i % 5 == 0) 
        {
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, sMessage);
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n");
            sMessage = "";
        }
    }

    if (sMessage.Length() > 2) 
    {
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, sMessage + "\n");
    }
}

bool FileWriter(string szPath, array<CDSGuidanceBlobItem@>@ szContent, OpenFileFlags_t flag = OpenFile::WRITE)
{
    File @pFile = g_FileSystem.OpenFile( szRootPath + szPath , flag );
    if ( pFile !is null && pFile.IsOpen())
    {
        for(uint i = 0; i  < szContent.length();i++)
        {
            CDSGuidanceBlobItem@ pItem = szContent[i];
            pFile.Write( pItem.SteamID + "\t" + pItem.vecOrigin.ToString().Replace(", ", "\t") + "\t" + pItem.flAngle + "\t" +
                        pItem.t1 + "\t" + pItem.d1 + "\t" + pItem.w1 + "\t" + pItem.c + "\t" + pItem.t2 + "\t" + pItem.d2 + "\t" + pItem.w2 + "\t" + pItem.t + "\n");
        }
        pFile.Close();  
        return true;
    }
    else
        return false;
}
array<string>@ FileReader(string szPath)
{
    array<string> aryTemp = {};
    File @pFile = g_FileSystem.OpenFile( szRootPath + szPath , OpenFile::READ );
    if ( pFile !is null && pFile.IsOpen())
    {
        string szLine = "";
        while(!pFile.EOFReached())
        {
            pFile.ReadLine(szLine);
            if(szLine.IsEmpty())
                continue;
            aryTemp.insertLast(szLine);
        }
        pFile.Close();  
        return @aryTemp;
    }
    else
        return null;
}

void DrawGuidance(const CCommand@ pArgs) 
{
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    if(pPlayer !is null || !pPlayer.IsNetClient()){
        return;
    }
    if(!pPlayer.IsAlive()){
        g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "未死的诅咒尚未降临, 你还不需要用这种方式留下信息\n");
        return;
    }
    uint index1 = 0;
    uint dicIndex1 = 0;
    uint wordIndex1 = 0;
    int c = -1;
    uint index2 = 0;
    uint dicIndex2 = 0;
    uint wordIndex2 = 0;

    uint iSwitch = pArgs.ArgC();
    uint iHelp = 0;
    for(int i = 1; i < pArgs.ArgC(); i++)
    {
        if(pArgs[i] == "?"){
            iSwitch--;
            iHelp++;
        }
        switch(i)
        {
            case 1:index1=Math.clamp(0, aryTemplet.length()-1, atoui(pArgs[i])-1);break;
            case 2:dicIndex1=Math.clamp(0, dicWord.getKeys().length()-1, atoui(pArgs[i])-1);break;
            case 3:wordIndex1=Math.clamp(0, cast<array<string>@>(dicWord[dicWord.getKeys()[dicIndex1]]).length()-1, atoui(pArgs[i])-1);break;
            case 4:c=Math.clamp(-1, aryConjunctions.length()-1, atoi(pArgs[i])-1);break;
            case 5:index2=Math.clamp(0, aryTemplet.length()-1, atoui(pArgs[i])-1);break;
            case 6:dicIndex2=Math.clamp(0, dicWord.getKeys().length()-1, atoui(pArgs[i])-1);break;
            case 7:wordIndex2=Math.clamp(0, cast<array<string>@>(dicWord[dicWord.getKeys()[dicIndex2]]).length()-1, atoui(pArgs[i])-1);break;
        }
    }
    
    switch(iSwitch){
        case 2:
        case 6:{
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "可用词语库:\n");
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
            PrintArrayToPlayer(pPlayer, dicWord.getKeys());
            break;
        }
        case 3:{
            string szKey = dicWord.getKeys()[dicIndex1];
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[" + szKey + "]可用词语:\n");
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
            PrintArrayToPlayer(pPlayer, cast<array<string>@>(dicWord[szKey]));
            break;
        }
        case 7:{
            string szKey = dicWord.getKeys()[dicIndex2];
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[" + szKey + "]可用词语:\n");
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
            PrintArrayToPlayer(pPlayer, cast<array<string>@>(dicWord[szKey]));
            break;
        }
        case 4:
        case 8:{
            if(iHelp > 0){
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "建言预览:\n");
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, SnipMessage(index1, dicIndex1, wordIndex1, c, index2, dicIndex2, wordIndex2) + "\n");
                break;
            }
            string szId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
            Vector vecOrigin = pPlayer.pev.origin;
            vecOrigin.z = pPlayer.pev.absmin.z + 2;
            float flAngle = pPlayer.pev.angles.y;
            time_t t = UnixTimestamp();
            CDSGuidanceBlobItem pItem;
                pItem.SteamID = szId;
                pItem.vecOrigin = vecOrigin;
                pItem.flAngle = flAngle;
                pItem.t1 = index1;
                pItem.d1 = dicIndex1;
                pItem.w1 = wordIndex1;
                pItem.c = c;
                pItem.t2 = index2;
                pItem.d2 = dicIndex2;
                pItem.w2 = wordIndex2;
                pItem.t = t;
            aryGuidance.insertLast(@pItem);
            CDSGuidance@ pNew = CreateGuidance(vecOrigin, flAngle, szId, index1, dicIndex1, wordIndex1, c, index2, dicIndex2, wordIndex2, t);
            if(dicPlayerCount.exists(szId)){
                int iCount = int(dicPlayerCount[szId]);
                if(iCount < 3)
                    dicPlayerCount[szId] = iCount+1;
                else{
                    CBaseEntity@ pEntity = null;
                    while((@pEntity = g_EntityFuncs.FindEntityByTargetname(@pEntity, szId)) !is null){
                        if(@pEntity !is @pNew.self)
                            break;
                        else
                            continue;
                    }
                    pEntity.SUB_StartFadeOut();
                }
            }
            else
                dicPlayerCount[szId] = 1;

            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "已写成建言\n");
            break;
        }
        case 5:{
            if(c < 0 || iHelp > 0){
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "可用连接词:\n");
                g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
                PrintArrayToPlayer(pPlayer, @aryConjunctions);
                break;
            }
        }
        default: {
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "可用模板:\n");
            g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
            PrintArrayToPlayer(pPlayer, @aryTemplet);
            break;
        }
    }
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "帮助: ." + szCommand + " [模板编号] [词库编号] [词语编号] <连接词> <模板编号> <词库编号> <词语编号>\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "[]指必填 | <>指选填 | 用?查询(例:." + szCommand + " 1 2 3 ?)\n");
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "------------------------\n");
}
