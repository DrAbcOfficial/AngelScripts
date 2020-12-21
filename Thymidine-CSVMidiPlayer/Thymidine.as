/* Mid2Csv http://www.fourmilab.ch/webtools/midicsv */
#include "Adenine"

const string szPluginTitle = "Thymidine";
//插件标题
const float g_GloabalPitch = 1.0f;
//全局音调
const dictionary g_SoundPath = {
                                    {'default','Thymidine/piano' },
                                    {'Note_on_c','Thymidine/piano'}
};
//音效对应列表
dictionary g_dicMusicList;
float g_PlayTick = 750;        //默认速率
float g_DefaultMulti = 25;      //速率转换倍率

//调试代码
array<string> @tstary;
CClientCommand test("tst", "tst", @tst);
void tst(const CCommand@ pArgs) 
{
	CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();
    string args = pArgs.GetCommandString();
    array<string>aryargs = args.Split(' ');
	string sMessage = "";
	for (uint i = 1; i < tstary.length()+1; ++i) 
	{
		sMessage += tstary[i-1] + " | ";
		if (i % 5 == 0) 
		{
			sMessage.Resize(sMessage.Length() -2);
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, sMessage);
			g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n");
			sMessage = "";
		}
	}
	if (sMessage.Length() > 2) 
	{
		sMessage.Resize(sMessage.Length() -2);
		g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, sMessage + "\n");
	}
	g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, "\n");

	g_MidPlay.PlayMidi(aryargs[1],pPlayer);
}
//结束

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo("12345");
    g_Scheduler.ClearTimerList();
	g_FileBuffer.FileBuffer('scripts/plugins/store/NewIsland.csv');
	g_FileBuffer.FileBuffer('scripts/plugins/store/Lemon.csv');
	g_FileBuffer.FileBuffer('scripts/plugins/store/mlh.csv');
	g_FileBuffer.FileBuffer('scripts/plugins/store/zgb.csv');
    //CCScreen::ScreenFileBuffer();
}

void MapInit()
{
    g_Scheduler.ClearTimerList();
    g_MidUtility.Precache('Thymidine/piano');
}

void AddScheduler(CCMidiFile @data, CBasePlayer @pPlayer)
{
    //检查是否为空
    if(data !is null && pPlayer !is null)
    {
        //为零的话就是说停止之前的音轨占用了
        string filePath = g_MidUtility.SoundPath(data.Type) + '(' + data.Note + ').mp3';
        SOUND_CHANNEL Track = g_MidUtility.Track(data.Track);
        if(data.Velocity != 0)
        {
            g_MidUtility.Broadcast('[Play] [' + data.Time + '] ' + g_MidUtility.SoundPath(data.Type) + ' | T ' + Track + ' | V ' + g_MidUtility.Volume(data.Velocity) + ' | N ' + data.Note );
            g_SoundSystem.EmitSoundDyn(pPlayer.edict(), Track, filePath, g_MidUtility.Volume(data.Velocity), ATTN_NORM, 0, g_MidUtility.Pitch(g_GloabalPitch));
        }
        else
        {
            g_MidUtility.Broadcast('[Stop] [' + data.Time + '] ' + g_MidUtility.SoundPath(data.Type) + ' | T ' + Track);
            g_SoundSystem.StopSound(pPlayer.edict(), Track, filePath);
        }
    }
    else
        g_MidUtility.Error('Null data or player!');
}

class CCMidiPlay
{
    //播放
    void PlayMidi(string&in szName, CBasePlayer @pPlayer)
    {
        if(g_dicMusicList.exists(szName))
        {
            array<CCMidiFile>g_aryFileinfo = array<CCMidiFile>(g_dicMusicList[szName]);
            CCMidiFile @data = g_aryFileinfo[0];
           // g_PlayTick = data.Time/g_DefaultMulti;
            for(uint i = 1;i < g_aryFileinfo.length();i++)
            {
                @data = g_aryFileinfo[i];
                g_Scheduler.SetTimeout("AddScheduler", g_MidUtility.Time(data.Time),@data,@pPlayer);
            }
        }
        else
            g_MidUtility.Alert("There's no any file named "+ szName +" in server's database!");
    }
}
CCMidiPlay g_MidPlay;

//文件读取
class CCFileBuffer
{
    void FileBuffer( string filename )
    {
        File@ file = g_FileSystem.OpenFile(filename, OpenFile::READ);
        if (file !is null && file.IsOpen()) 
		{
            array< CCMidiFile > g_aryFileinfo;//所有节以数组保存，保持文件的顺序
			while(!file.EOFReached()) 
			{
				string sLine;
				file.ReadLine(sLine);
                array<string> parseds = sLine.Split(",");
				
				if(parseds.length() < 2)
					continue;
				
				if (parseds[1] == '0' || g_MidUtility.IsNumeric(parseds[1]) || sLine.IsEmpty() || parseds.length() < 6 )
					continue;
                //时间为0的行和时间不为数字的行是无效的

                if(g_MidUtility.IsFileHeader(parseds[2]))
                    continue;
                //文件头是不要的

                CCMidiFile data;
                data.Track = atoi(parseds[0]);//音轨
                data.Time = atoi(parseds[1]);//时间
                data.Type = parseds[2];//乐器
                data.Note = atoi(parseds[4]);//音调
                data.Velocity = atoi(parseds[5]);//音量
                //每一节的数据

                if( data.Type == " Tempo" ) //播放速度信息
                {
                    data.Time = atoi(parseds[3]);
                    g_aryFileinfo.insertAt(0,data);
                }
                else
                    g_aryFileinfo.insertLast(data);
			}
            array<string> substr = filename.Split('/');
            substr = substr[substr.length()-1].Split('.');
            g_dicMusicList.set(substr[0], g_aryFileinfo);//去掉.csv后缀保存文件
            @tstary = g_dicMusicList.getKeys();
			file.Close();
		}
        else
        {
            g_MidUtility.Alert("Can not reach this file! skipping it...");
        }
    }
}
CCFileBuffer g_FileBuffer;

//封装
class CCUtility
{
    //简单的判断是否为数字
    bool IsNumeric( string character )
    {
        if((character>='0')&&(character<='9'))
            return true;
        else
            return false;
    }

    //文件头的标志
    array<string> g_FileHeader = {  " Header",
                                    " Start_track",
                                    " Time_signature",
                                    " Key_signature",
                                    " Control_c",
                                    " Program_c",
                                    " MIDI_port",
                                    " End_track",
                                    " End_of_file"};
    //简单的判断是否为文件头
    bool IsFileHeader( string character )
    {
        for(uint i = 0; i < g_FileHeader.length(); i++)
        {
            if( character == g_FileHeader[i])
                return true;
        }
        return false;
    }

    //由Tick转换为秒
    float Time(float&in i)
    {
        return i/g_PlayTick;
    }

    //规范化音量
    float Volume(int&in i)
    {
        float cache = float(i)/100;
        if(cache > 1.0)
        {
            cache = 1.0;
            g_MidUtility.Alert('Input volume is too high! clamped it.');
        }
        return cache;
    }

    //快慢可调整
    int Pitch(float&in f)
    {
        return int( PITCH_NORM * f );
    }
    
    //规范化音轨
    SOUND_CHANNEL Track(int8&in i)
    {
        switch (i)
        {
            case 0:return CHAN_AUTO;
            case 1:return CHAN_WEAPON;
            case 2:return CHAN_VOICE;
            case 3:return CHAN_ITEM;
            case 4:return CHAN_BODY;
            case 5:return CHAN_STREAM;
            case 6:return CHAN_STATIC;
            case 7:return CHAN_MUSIC;
            default:return CHAN_AUTO;
        }
        return CHAN_AUTO;
    }

    //返回声音路径
    string SoundPath( string&in szName)
    {
        if(g_SoundPath.exists(szName))
            return string(g_SoundPath[szName])+ '/';
        else
        {
            g_MidUtility.Alert('There is no this sound type in database!');
            return string(g_SoundPath['default'] )+ '/';
        }
    }

    //批量加载资源
    void Precache( string&in fileroot )
    {
        for(uint8 i = 1; i < 254; i++)
        {
            g_SoundSystem.PrecacheSound( fileroot + '/(' + i + ').mp3' );
        }
    }

    //提示信息
    void Broadcast(string&in szName)
    {
        g_Game.AlertMessage( at_console, "["+szPluginTitle+"] [Thread]: " + szName+"\n" );
    }

    //警告信息
    void Alert(string&in szName)
    {
        g_Game.AlertMessage( at_console, "["+szPluginTitle+"] [Warning]: " + szName+"\n" );
    }

    //错误信息
    void Error(string&in szName)
    {
        g_Game.AlertMessage( at_console, "["+szPluginTitle+"] [Error]: " + szName+"\n" );
    }
}
CCUtility g_MidUtility;

//每一节的数据类
class CCMidiFile
{
    private int8 g_int8Track;
    private float g_intTime;
    private string g_strType;
    private int g_intNote;
    private int g_Velocity;

    //音轨
    uint8 Track
	{
	    get const{ return g_int8Track;}
		set{ g_int8Track = value;}
	}

    //时间
    float Time
	{
	    get const{ return g_intTime;}
		set{ g_intTime = value;}
	}

    //类型
    string Type
    {
        get const{ return g_strType;}
		set{ g_strType = value;}
    }

    //音调
    uint Note
	{
	    get const{ return g_intNote;}
		set{ g_intNote = value;}
	}

    //音量
    uint Velocity
	{
	    get const{ return g_Velocity;}
		set{ g_Velocity = value;}
	}
}