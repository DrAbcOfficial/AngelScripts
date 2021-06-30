//https://developer.valvesoftware.com/wiki/SteamID
//Dr.Abc
//https://github.com/DrAbcrealone/AngelScripts/blob/master/lib/SteamIDHelper.as
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
        if(isalnum(sz32) && sz32.Length() == 17 && sz32.StartsWith("76561"))
            return SteamID_64;
        return SteamID_Invalid;
    }
    STEAMID_FLAG checkSteamID(int64 i64){
        return i64 > 0x0110000200000000 || i64 < 0x0110000100000000 ? SteamID_Invalid : SteamID_64;
    }
    int64 to64(string sz32){
        switch(checkSteamID(sz32)){
            case SteamID_Community: return atoi64(sz32.SubString(5, sz32.Length() - 6)) + 0x0110000100000000;
            case SteamID_32: return atoi64(sz32.SubString(10)) * 2 + atoi64(sz32.SubString(8,1) + 0x0110000100000000);
            case SteamID_64: return atoi64(sz32);
        }
        return -1;
    }
    //我们是金源游戏，所以X永远为0
    string to32(int64 i64){
        return checkSteamID(i64) == SteamID_64 ? "STEAM_0:" + i64 % 2 + ":" + ((i64 - 0x0110000100000000) >> 1) : String::EMPTY_STRING;
    }
    string to32(string szIn){
        switch(checkSteamID(szIn)){
            case SteamID_Community: {
                int iTemp = atoi(szIn.SubString(5, szIn.Length() - 6));
                return "STEAM_0:" + (iTemp % 2) + ":" + int(iTemp / 2);
            }
            case SteamID_32: return szIn;
            case SteamID_64: return this.to32(atoi64(szIn));
        }
        return String::EMPTY_STRING;
    }
    string toCommunity(int64 i64){
        return checkSteamID(i64) != SteamID_64 ? String::EMPTY_STRING : "[U:1:" + (i64 - 0x0110000100000000) + "]";
    }
    string toCommunity(string sz32){
        switch(checkSteamID(sz32)){
            case SteamID_Community: return sz32;
            case SteamID_32: return "[U:1:" + string(atoi(sz32.SubString(10)) * 2 + atoi(sz32.SubString(8,1))) + "]";
            case SteamID_64: return this.toCommunity(atoi64(sz32));
        }
        return String::EMPTY_STRING;
    }
}

//tester
void println(string sz){g_Log.PrintF(sz + "\n");};
void PluginInit(){
    g_Module.ScriptInfo.SetAuthor("DDRR.AABBCC");
    g_Module.ScriptInfo.SetContactInfo("DDD");
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
    //checker
    println("Checker:");
    //1
    println(pHelper.checkSteamID(76561198092429588));
    println(pHelper.checkSteamID("76561198092429588"));
    //2
    println(pHelper.checkSteamID("[U:1:132163860]"));
    //0
    println(pHelper.checkSteamID("STEAM_0:0:66081930"));
    //-1
    println(pHelper.checkSteamID(1145141919810));
    println(pHelper.checkSteamID(1234567765432112345));
    println(pHelper.checkSteamID("1145141919810"));
    println(pHelper.checkSteamID("[U:1:132163860"));
    println(pHelper.checkSteamID("哀吾生之须臾羡长江之无穷"));
    println(pHelper.checkSteamID("STEAM_ID_LAN"));
    println(pHelper.checkSteamID("STEAM_ID_PENDING"));
    //False convert
    println("False:");
    println(pHelper.to64(1145141919810));
    println(pHelper.to32(1145141919810));
    println(pHelper.toCommunity(1145141919810));

    println(pHelper.to64("哀吾生之须臾羡长江之无穷"));
    println(pHelper.to32("哀吾生之须臾羡长江之无穷"));
    println(pHelper.toCommunity("哀吾生之须臾羡长江之无穷"));
}
