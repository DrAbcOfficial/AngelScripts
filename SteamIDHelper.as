//https://developer.valvesoftware.com/wiki/SteamID
enum STEAMID_FLAG{
        SteamID_Invalid = -1,
        SteamID_32,
        SteamID_64,
        SteamID_Community
    }
class CSteamIDHelper{
    STEAMID_FLAG checkSteamID(string sz32){
        //金源格式
        if(sz32.StartsWith("STEAM_0:"))
            return SteamID_32;
        //社区格式
        if(sz32.StartsWith("[U:1:") && sz32.EndsWith("]"))
            return SteamID_Community;
        //64位格式
        if(isalnum(sz32) && sz32.StartsWith("76561") && sz32.Length() == 17)
            return SteamID_64;
        return SteamID_Invalid;
    }
    STEAMID_FLAG checkSteamID(int64 i64){
        //64位格式
        if(i64 > 76561202255233023 || i64 < 76561197960265728)
            return SteamID_Invalid;
        return SteamID_64; 
    }
    int64 to64(string sz32){
        switch(checkSteamID(sz32)){
            case SteamID_Community: return atoi64(sz32.SubString(5, sz32.Length() - 6)) + 0x0110000100000000;
            case SteamID_32: return atoi64(sz32.SubString(10)) * 2 + atoi64(sz32.SubString(8,1) + 0x0110000100000000);
            case SteamID_64: return atoi64(sz32);
            case SteamID_Invalid:
            default: return -1;
        }
        return -1;
    }
    string to32(int64 i64){
        if(checkSteamID(i64) == SteamID_64)
            //我们是金源游戏，所以X永远为0
            return "STEAM_0:" + 
                i64 % 2 + ":" + 
                //0000 0001 0001 0000 0000 0000 0000 0001
                //0000 0000 0000 0000 0000 0000 0000 0000
                ((i64 - 76561197960265728) >> 1);
        return String::EMPTY_STRING;
    }
    string to32(string szCommunity){
        switch(checkSteamID(szCommunity)){
            case SteamID_Community: {
                int iTemp = atoi(szCommunity.SubString(5, szCommunity.Length() - 6));
                return "STEAM_0:" + (iTemp % 2) + ":" + ((iTemp - iTemp % 2) / 2);
            }
            case SteamID_32: return szCommunity;
            case SteamID_64: return this.to32(atoi64(szCommunity));
            case SteamID_Invalid:
            default: return String::EMPTY_STRING;
        }
        return String::EMPTY_STRING;
    }
    string toCommunity(int64 i64){
        if(checkSteamID(i64) != SteamID_64)
            return String::EMPTY_STRING;
        return "[U:1:" + (i64 - 0x0110000100000000) + "]";
    }
    string toCommunity(string sz32){
        switch(checkSteamID(sz32)){
            case SteamID_Community: return sz32;
            case SteamID_32: return "[U:1:" + string(atoi(sz32.SubString(10)) * 2 + atoi(sz32.SubString(8,1))) + "]";
            case SteamID_64: return this.toCommunity(atoi64(sz32));
            case SteamID_Invalid:
            default: return String::EMPTY_STRING;
        }
        return String::EMPTY_STRING;
    }
}

//tester
void println(string sz){g_Log.PrintF(sz + "\n");};
void PluginInit(){
    g_Module.ScriptInfo.SetAuthor("DDRR.AABBCC");
    g_Module.ScriptInfo.SetContactInfo("DDD");
    //76561198092541763
    CSteamIDHelper pHelper;
    //76561198092429588
    println("64:");
    println(pHelper.to64("STEAM_0:0:66081930"));
    println(pHelper.to64("[U:1:132163860]"));
    println(pHelper.to64("76561198092429588"));
    //STEAM_0:0:66081930
    println("32:");
    println(pHelper.to32("76561198092429588"));
    println(pHelper.to32("[U:1:132163860]"));
    println(pHelper.to32("STEAM_0:0:66081930"));
    //[U:1:132163860]
    println("Community:");
    println(pHelper.toCommunity("STEAM_0:0:66081930"));
    println(pHelper.toCommunity("76561198092429588"));
    println(pHelper.toCommunity("[U:1:132163860]"));
    //numeric
    println("Numeric:");
    println(pHelper.to64(76561198092429588));
    println(pHelper.to32(76561198092429588));
    println(pHelper.toCommunity(76561198092429588));
}
