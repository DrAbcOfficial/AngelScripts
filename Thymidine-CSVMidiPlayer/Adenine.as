CClientCommand xbd("xbd", "xbd", @gesusewtfisdat);

void gesusewtfisdat(const CCommand@ pArgs) 
{
    g_Game.AlertMessage( at_console, CCScreen::g_aryFileinfo.length() );
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
	CCScreen::AddTask (pPlayer);
}

void Playbuffer( CBasePlayer@ pPlayer , array<string>&in szAryin )
{
    for (uint i = 0;i< szAryin.length(); i++)
    {
        g_Game.AlertMessage( at_console, "\n" + szAryin[i] );
    }
}

namespace CCScreen
{
array<array<string>> g_aryFileinfo;
void ScreenFileBuffer()
{
    File@ file = g_FileSystem.OpenFile("scripts/plugins/store/NewIsland.txt", OpenFile::READ);
    if (file !is null && file.IsOpen()) 
	{
         //所有节以数组保存，保持文件的顺序
        array<string> szLine;
		while(!file.EOFReached()) 
		{
			string sLine;
			file.ReadLine(sLine);

			if (sLine == "{Head}")
			{
                g_Game.AlertMessage( at_console, szLine.length() );
                g_aryFileinfo.insertLast(szLine);
                szLine = {};
            }
            else
            {
                szLine.insertLast(sLine);
            }
		}
		file.Close();
	}
}

void AddTask(CBasePlayer@ pPlayer)
{
    for (uint i = 0;i< g_aryFileinfo.length(); i++)
    {
        g_Scheduler.SetTimeout("Playbuffer", int(i)*0.1 + 5,@pPlayer, g_aryFileinfo[i]);
    }
}
}