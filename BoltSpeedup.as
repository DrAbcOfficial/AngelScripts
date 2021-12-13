//新速度
const float flNewSpeed = 4000;
//搜索时间间隔
const float flSearchInterv = 0.02;
//启用尾迹
const bool bEnableTrace = true;
//尾迹SPR
const string szTracePath = "sprites/bdsc_custom/safelaserbeam.spr";
//尾迹颜色
const RGBA colorTraceColor = RGBA(255, 255, 255, 80);

CScheduledFunction@ pScheduler = null;
void PluginInit(){
    g_Module.ScriptInfo.SetAuthor("Dr.Abc");
    g_Module.ScriptInfo.SetContactInfo("是你?是我?");
}
void MapInit(){
	g_Scheduler.RemoveTimer(@pScheduler);
	g_Scheduler.SetInterval("BoltSpeedUp", flSearchInterv, g_Scheduler.REPEAT_INFINITE_TIMES);
	g_Game.PrecacheModel(szTracePath);
}
void BoltSpeedUp(){
	CBaseEntity@ pBolt = null;
	while((@pBolt = g_EntityFuncs.FindEntityByClassname(pBolt, "bolt")) !is null){
		if(pBolt.pev.bInDuck == 0){
			pBolt.pev.velocity = pBolt.pev.velocity.Normalize() * flNewSpeed;
			if(bEnableTrace){
				NetworkMessage m(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
					m.WriteByte(TE_BEAMFOLLOW);
					m.WriteShort(pBolt.entindex());
					m.WriteShort(g_EngineFuncs.ModelIndex(szTracePath));
					m.WriteByte(16);
					m.WriteByte(1);
					m.WriteByte(colorTraceColor.r);
					m.WriteByte(colorTraceColor.g);
					m.WriteByte(colorTraceColor.b);
					m.WriteByte(colorTraceColor.a);
				m.End();
			}
			pBolt.pev.bInDuck = 1;
		}
	}
}