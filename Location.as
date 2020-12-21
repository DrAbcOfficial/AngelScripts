void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "drabc" );
	g_Module.ScriptInfo.SetContactInfo( "bruh" );
}

array<string> aryVec;
uint id = 0;
string Vec2Sz(Vector&in ori, Vector&in ang)
{
    return "[Origin] " + ori.x + "," + ori.y + "," + ori.z + "\n[Angle]" + ang.x + "," + ang.y + "," + ang.z;
}

CClientCommand g_HelloWorld("hello", "Hello", @helloword);
void helloword(const CCommand@ pArgs) 
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	string a = Vec2Sz(pPlayer.pev.origin, pPlayer.pev.angles);
	id++;
    aryVec.insertLast(a);
    g_Game.AlertMessage( at_console, "\n["+ id + "]>\n" + a);
}

const string FilePath = "scripts/plugins/store/StoredLocation.txt";
CClientCommand g_HiWorld("hi", "Hi", @hi);
void hi(const CCommand@ pArgs) 
{
	File @pFile = g_FileSystem.OpenFile( FilePath , OpenFile::WRITE );
	if ( pFile !is null && pFile.IsOpen())
	{
        for(uint i = 0; i < aryVec.length();++i)
        {
            pFile.Write("[" + i + "]>\n");
            pFile.Write(aryVec[i] + "\n");
        }
        pFile.Close();
		g_Game.AlertMessage( at_console, "\nExported as A txt in :[" + FilePath + "]");
	}
}
