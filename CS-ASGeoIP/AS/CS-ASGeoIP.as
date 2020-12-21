/***
	CS-AS联用 IP返回
*****/

namespace CIPAdderss
{
	const string JoinTitle = "Geo-IP";
	const string FileDir	= "scripts/plugins/store/IPOutput.txt";
	const string FileOut	= "scripts/plugins/store/IPInput.txt";
	const string DoneFilePath	= "scripts/plugins/store/IPDoneput";
	const string sNotWelcome = "Your country is not welcome on this server.";
	const array<string> banNation = 
								{
									"BG"
								};

	string ThatDay;
	dictionary GeoIPDataBase;

	string LeaveCast(CBasePlayer@ pPlayer)
	{
		int8 LeaveIndex = 0;
		if(pPlayer.pev.frags - pPlayer.m_iDeaths < 0 || pPlayer.pev.frags < 0)
			LeaveIndex = Math.RandomLong(1,3);
		else if ( g_PlayerFuncs.FindPlayerByIndex(1) is  pPlayer)
			LeaveIndex = Math.RandomLong(4,5);
		else
			LeaveIndex = Math.RandomLong(6,8);
		string LeaveReason;
		switch(LeaveIndex)
		{
			case 0:LeaveReason = "离开了服务器";break;
			case 1:LeaveReason = "RageQuit了";break;
			case 2:LeaveReason = "生气的走了";break;
			case 3:LeaveReason = "怒摔键盘走了";break;
			case 4:LeaveReason = "心满意足的离开了这里";break;
			case 5:LeaveReason = "终于成为了MVP,离开这里留下了传说";break;
			case 6:LeaveReason = "觉得一阵迷茫，离开这里去寻找自己的人参";break;
			case 7:LeaveReason = "突然想起来有事离开了这里";break;
			case 8:LeaveReason = "不小心点了Quit Game";break;
			default:LeaveReason = "离开了服务器";break;
		}
		return LeaveReason;
	}

	string JoinCast()
	{
		string JoinReason;
		switch(Math.RandomLong(0,8))
		{
			case 0:JoinReason = "正在加入服务器";break;
			case 1:JoinReason = "降临到了这里";break;
			case 2:JoinReason = "正在加入搅基";break;
			case 3:JoinReason = "不小心进入了这个服务器";break;
			case 4:JoinReason = "来叻来叻来叻";break;
			case 5:JoinReason = "终于下载完了资源进来了";break;
			case 6:JoinReason = "想进来康康";break;
			case 7:JoinReason = "不小心点了Join Game";break;
			case 8:JoinReason = "出现了";break;
			default:JoinReason = "正在加入服务器";break;
		}
		return JoinReason;
	}

	void Kick (string&in sId, string&in sReason)
	{
		g_EngineFuncs.ServerCommand("kick #"+ sId + sNotWelcome + " \"[" + sReason + "\"]\n");
	}

	void ReadIP()
	{
		File @pFile = g_FileSystem.OpenFile( FileDir , OpenFile::READ );
		if ( pFile !is null && pFile.IsOpen() )
		{
			string line;
			while ( !pFile.EOFReached() )
			{
				pFile.ReadLine( line );
				if ( line.IsEmpty() )
					continue;
				array<string>@ buff = line.Split( "," );				//分割
				CCIPData data; //实例化
				if(buff.length() > 0)
				{	
					data.Code = buff[1];
					data.Country = buff[2];
					data.Region = buff[3];
					data.City = buff[4];
					GeoIPDataBase[buff[0]] = data;
				}
			}
			pFile.Close();
		}
		else
			FormatLog("IP data No Read!");							//畜生，你中了甚么
	}
	
	void WriteMetaIP( string MetaIP ,string FilePath = FileOut )
	{
		File @pFile = g_FileSystem.OpenFile( FilePath , OpenFile::WRITE );
		if ( pFile !is null && pFile.IsOpen())
		{
			pFile.Write(MetaIP);	//写出元数据
			pFile.Close();	
			@pFile = g_FileSystem.OpenFile( DoneFilePath , OpenFile::WRITE );
			if ( pFile !is null && pFile.IsOpen())
			{
				pFile.Write("#wedone#");	//写出结束数据
				pFile.Close();	
			}
		}
		else
			FormatLog("IP data No Write!");				//畜生，你中了甚么
	}

	void BroadIPAddress( string&in Name, string szID )
	{			
		CCIPData@ data = null;
		if(GeoIPDataBase.exists(szID))
		{
			@data = cast<CCIPData@>(GeoIPDataBase[szID]);

			if( banNation.find(data.Code) != -1 )
				CIPAdderss::Kick(szID, data.Code);
			else
				CIPAdderss::SayToAll("["+ CIPAdderss::JoinTitle + "]玩家:" +Name+ "[" + data.Code + "]"+"来自["+ data.Country + "|" + data.Region + "|" + data.City + "]" + CIPAdderss::JoinCast() + ".\n");	//来了
		}
		else
		{
			@data = cast<CCIPData@>(GeoIPDataBase["Unkown"]);
			CIPAdderss::SayToAll("["+ CIPAdderss::JoinTitle + "]玩家:" +Name+ "[" + data.Code + "]"+"来自["+ data.Country + "|" + data.Region + "|" + data.City + "]" + CIPAdderss::JoinCast() + ".\n");	//来了
		}
		
	}
	
	void CastLeave( CBasePlayer@ pPlayer )
	{
		CIPAdderss::SayToAll("["+ CIPAdderss::JoinTitle + "]玩家:" +string(pPlayer.pev.netname)+ CIPAdderss::LeaveCast(pPlayer)+".\n");		//走了
	}

	void SayToAll( string&in InPut )
	{
		//发送信息并记录日志
		g_PlayerFuncs.ClientPrintAll( HUD_PRINTTALK, InPut + "\n" );
		g_Game.AlertMessage(at_logged, InPut + "\n");
	}

	void FormatLog(string&in InPut)
	{
		string szCurrentTime;
		DateTime time;
		time.Format(szCurrentTime, "%Y.%m.%d - %H:%M:%S" );
		g_Game.AlertMessage(at_logged, "==> [" + szCurrentTime + "] "+ InPut + ".\n");
	}
}

class CCIPData
{
	private string sz_Code;
	private string sz_Country;
	private string sz_Region;
	private string sz_City;

	string Code
	{
		get const{ return sz_Code;}
		set{ sz_Code = value;}
	}

	string Country
	{
		get const{ return sz_Country;}
		set{ sz_Country = value;}
	}

	string Region
	{
		get const{ return sz_Region;}
		set{ sz_Region = value;}
	}

	string City
	{
		get const{ return sz_City;}
		set{ sz_City = value;}
	}
}


void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("Dr.Abc");
	g_Module.ScriptInfo.SetContactInfo("Bruh.");
	
	CCIPData data;
	data.Code = "UNK";
	data.Country = "互联网";
	data.Region = "地球";
	data.City = "未知";
	CIPAdderss::GeoIPDataBase["Unkown"] = data;

	//注册Time
	g_Hooks.RegisterHook( Hooks::Player::ClientConnected, @ClientConnected );
	g_Hooks.RegisterHook( Hooks::Player::ClientDisconnect, @ClientDisconnect );
	g_Hooks.RegisterHook( Hooks::Player::ClientPutInServer, @ClientPutInServer );
}

void MapInit()
{
	string Date;
	DateTime time;
	time.Format(Date, "%d" );

	if( Date != CIPAdderss::ThatDay )
	{
		CIPAdderss::GeoIPDataBase.deleteAll();
		CIPAdderss::WriteMetaIP("",CIPAdderss::FileDir);
		CIPAdderss::ThatDay = Date;
	}
}

HookReturnCode ClientConnected( edict_t@ pEntity, const string& in szPlayerName, const string& in szIPAddress, bool& out bDisallowJoin, string& out szRejectReason )
{
	const string szSteamId = g_EngineFuncs.GetPlayerAuthId(pEntity);
	if(!CIPAdderss::GeoIPDataBase.exists(szSteamId))
		CIPAdderss::WriteMetaIP(szSteamId + "," +szIPAddress);
	return HOOK_HANDLED;
}

HookReturnCode ClientPutInServer(CBasePlayer@ pPlayer)
{
	const string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
	if(!CIPAdderss::GeoIPDataBase.exists(szSteamId))
		CIPAdderss::ReadIP();
	
	CIPAdderss::BroadIPAddress(pPlayer.pev.netname, szSteamId );
	return HOOK_HANDLED;
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer )
{
	CIPAdderss::CastLeave(pPlayer);								//Call
	return HOOK_HANDLED;
}
