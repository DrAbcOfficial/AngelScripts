//使选择的玩家进入游戏结束后的看计分榜状态
//无需任何参数
//指定玩家由MSG_ONE传递
void intermission() 
{
	//MESSAGE_BEGIN( MSG_ONE, NetworkMessages::SVC_INTERMISSION, null, player.edcit() );
	NetworkMessage message( MSG_ALL, NetworkMessages::SVC_INTERMISSION );
	message.End();
}

//向特定对象执行控制台命令
void helloword() 
{
	NetworkMessage message( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
		message.WriteString("spk ass");
	message.End();
}

//改变目前的计分榜模式
//0 FFA
//1 TeamPlay
void gamemode()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::GameMode );
		message.WriteByte(0);
	message.End();
}

//队伍名称
void teamname()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::TeamNames );
		message.WriteByte(2); //有几个队伍
		//以下有几个队伍就写几个String
		message.WriteString("Gordon");
		message.WriteString("Zombie");
	message.End();
}

//队伍信息
//用于指定玩家属于哪个队伍
void teaminfo()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::TeamInfo );
		message.WriteByte(g_EntityFuncs.EntIndex(pPlayer.edict()));//玩家实体序号
		message.WriteString("Spectators");//从属队伍
	message.End();
}

//分数信息
//待补全
void scoreinfo()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::ScoreInfo );
		message.WriteByte(g_EntityFuncs.EntIndex(pPlayer.edict()));	//0 玩家序号
		message.WriteFloat(114); //分数
		message.WriteLong(514);	//5 死亡数
		message.WriteFloat(19); //血量
		message.WriteFloat(19); //护甲
		message.WriteByte(8);  //队伍
		message.WriteByte(1);	//17 捐助者图标
		//0 无
		//1 电撬棍
		//2 金伍兹
		//3 金美元
		//4 测试者(猎头屑)
		//5 艺术家(蟾蜍)
		//6 开发者(SC图标)
		message.WriteByte(0);	//19 管理员图标
		//0 无
		//1 管理员
		//2 服主
	message.End();
}
//显示已经选中的武器信息
//后两项为-1时隐藏弹药等
void curweapon()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::CurWeapon );
		message.WriteByte(0);
		message.WriteByte(0xFF);
		message.WriteByte(0xFF);
	message.End();
}

//设置fov
//只影响一帧，无用
//0为重置fov为玩家默认
void setfov()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::SetFOV );
		message.WriteByte(128);
	message.End();
}

//hud上将某个玩家标记为observer
//0 取消标记
//1 标记
void spectate()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::Spectator );
		message.WriteByte(g_EntityFuncs.EntIndex(pPlayer.edict()));
		message.WriteByte(1);
	message.End();
}

//修改某个玩家的血量显示值
//玩家以MSG_ONE指定
void health()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::Health );
		message.WriteShort(120);//血量
		message.WriteShort(0);//超过一ushort时使用，加上a × 65536
	message.End();
}

//盖格计数器
//sc无用
void geiger()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::Geiger );
		message.WriteByte(255);//盖格计数器范围
	message.End();
}

//右上角手电筒图标
void flashlight()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::Flashlight );
		message.WriteByte(0); //0 关闭 1 开启
		message.WriteByte(255); //剩余电量
	message.End();
}

//显示捡起子弹数
void ammopickup()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::AmmoPickup );
		message.WriteByte(2); //子弹id
		message.WriteLong(114514); //子弹数
	message.End();
}

//显示剩余多少备弹
void ammox()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::AmmoX );
		message.WriteByte(2); //子弹id
		message.WriteLong(114514); //子弹数
	message.End();
}

//重置hud
void resethud()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::ResetHUD );
		message.WriteByte(0);
	message.End();
}

//重新初始化hud
void inithud()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::InitHUD );
	message.End();
}

//展示hλlf-life
void gametitle()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::GameTitle );
		message.WriteByte(5);
	message.End();
}

//显示的护甲数
void battery()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::Battery );
		message.WriteShort(0xFF);//护甲数
	message.End();
}
//显示左下角伤害类型
void damage()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::Damage );
		message.WriteByte(128);	//抵消的伤害
		message.WriteByte(128); //受到的伤害
		message.WriteLong(144670); //伤害类型
		message.WriteCoord(25); //攻击者方向x
		message.WriteCoord(78); //攻击者方向y
		message.WriteCoord(11); //攻击者方向z
	message.End();
}
//手电筒电量
void flashbattery()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::FlashBat );
		message.WriteByte(0);//电量 0-100
	message.End();
}

//显示火车hud
//0 消失
//1 停止
//2 前进一档
//3 前进二档
//4 前进三档
//5 倒车
void train()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::Train );
		message.WriteByte(0);
	message.End();
}

//武器列表
//由于该消息随时会被更新，所以并无实际作用
void weaponlist()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::WeaponList );
		message.WriteString("xixi");//武器名称
		message.WriteByte(6);//主子弹类型
		message.WriteByte(6);//最大子弹数
		message.WriteByte(6);//副子弹类型
		message.WriteByte(6);//最大子弹数
		message.WriteByte(6);//slot
		message.WriteByte(6);//position
		message.WriteByte(6);//id
		message.WriteByte(6);//flag
	message.End();
}

//屏幕抖动
void screenshake()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::ScreenShake );
		message.WriteShort(255);//数目
		message.WriteShort(15);//持续时间
		message.WriteShort(126`);//频率
	message.End();
}
//屏幕渐变
void screenfade()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::ScreenFade );
		message.WriteShort(255); //渐入时间
		message.WriteShort(15);	 //持续时间
		message.WriteShort(126);//效果标签
		message.WriteByte(126);//r
		message.WriteByte(126);//g
		message.WriteByte(126);//b
		message.WriteByte(126);//a
	message.End();
}
//文字信息
//最多允许有4个参数
void textmsg()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::TextMsg );
		message.WriteByte(1);//文字位置
		message.WriteString("hello");
		message.WriteString("h");//1
		message.WriteString("e");//2
		message.WriteString("l");//3
		message.WriteString("o");//4
	message.End();
}

//聊天栏发送消息
void saytext()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::SayText );
		message.WriteByte(g_EntityFuncs.EntIndex(pPlayer.edict()));//发送者
		message.WriteString("hello");//内容
	message.End();
}

//屏幕中下方hud发送消息
void hudtext()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::HudText );·
		message.WriteString("hello");
	message.End();
}

//右下发送捡起物品
void itempickup()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::ItemPickup );
		message.WriteString("item_battery");
	message.End();
}

//服务器名称
void servername()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::ServerName );
		message.WriteString("hello");
	message.End()
}
//打开motd并发送消息
void motd()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::MOTD );
		message.WriteByte(2);//后面有多少条String填多少
		message.WriteString("hello");
		message.WriteString("world");
	message.End();
}
//发起一个投票
void votemenu()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::VoteMenu );
		message.WriteByte(10);//持续时间
		message.WriteString("hello");//投票内容
		message.WriteString("ok");//yes按钮内容
		message.WriteString("negative");//no按钮内容
	message.End();
}

//修改下一张图hud上显示
void nextmap()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::NextMap );
		message.WriteString("\n\n\nhello");
	message.End();
}

//改变视角
//0 第一
//1 第三
void viewmode()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::ViewMode );
		message.WriteByte(1);
	message.End();
}

//将武器音效改为经典模式
//0 禁用
//1 启用
void classicmode()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::ClassicMode );
		message.WriteByte(1);
	message.End();
}

//创建一滩蟾蜍的毒云
void toxiccloud()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::ToxicCloud );
		message.WriteCoord(-518);//x
		message.WriteCoord(691);//y
		message.WriteCoord(-1659);//z
	message.End();
}

//创建一个Garg喷射火焰时候的火花
void gargsplash()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::GargSplash );
		message.WriteCoord(-518);//x
		message.WriteCoord(691);//y
		message.WriteCoord(-1659);//z
	message.End();
}
//电蚂蚁射击落点音效和光效
void shkflash()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::ShkFlash );
		message.WriteCoord(-814);//x
		message.WriteCoord(751);//y
		message.WriteCoord(-1659);//z
		message.WriteByte(128);//范围
	message.End();
}
//血液渣渣，可自定义颜色
void createblood()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::CreateBlood );
		message.WriteCoord(-814);//x
		message.WriteCoord(751);//y
		message.WriteCoord(-1659);//z
		message.WriteByte(2);//颜色
		message.WriteByte(2);//渣渣大小
	message.End();
}
//电蚂蚁自爆效果
void srdetonate()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::SRDetonate );
		message.WriteCoord(-814);//x
		message.WriteCoord(751);//y
		message.WriteCoord(-1659);//z
		message.WriteByte(255);//范围
	message.End();
}
//能听见声音，不知道有啥用
void flamethrow()
{
	NetworkMessage message( MSG_ALL, NetworkMessages::Flamethwr );
		message.WriteCoord(-814);//x
		message.WriteCoord(751);//y
		message.WriteCoord(-1659);//z
	message.End();
}
//发送玩家当前武器信息
//第一位状态为1时，代表获得武器
//第一位状态为0时，代表失去武器
//第一位状态为0且第二三位为255时，第一次获得为玩家死亡，第二次获得为玩家从出生点重生，以此来判断是否为被队友复活
void flamethrow()
{
	BEGIN_READ(pbuf, iSize);
	int iState = READ_BYTE();
	if (iState > 0)
	{
		int iId = READ_SHORT();
		int iClip = READ_LONG();
		int iClip2 = READ_LONG();
	}
	else
	{
		int iId = READ_BYTE();
		int iFlag2 = READ_BYTE();
	}
}
