//Enter the scoreboard at the end of the game
void SVC_INTERMISSION() {
	NetworkMessage message( MSG_ALL, NetworkMessages::SVC_INTERMISSION );
	message.End();
}
//Execute console commands
void SVC_STUFFTEXT() {
	NetworkMessage message( MSG_ALL, NetworkMessages::SVC_STUFFTEXT );
		message.WriteString("spk ass");
	message.End();
}
//Dont do that, you will ruin client
void ResetHUD(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ResetHUD );
	message.End();
}
// >0 Thirdperson
// 0 Firstperson
void ViewMode(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ViewMode );
        message.WriteByte(0);
    message.End();
}
//Dont do that, you will ruin client
void InitHUD(){
    NetworkMessage message( MSG_ALL, NetworkMessages::InitHUD );
	message.End();
}
//0 stop music
//1 ~ 33 play media/Half-Life%d
//>33 nothing
void CdAudio(){
    NetworkMessage message( MSG_ALL, NetworkMessages::CdAudio );
        message.WriteByte(0);
    message.End();
}
//0 dont allow
//>0 allow
void AllowSpec(){
    //NetworkMessage message( MSG_ALL, NetworkMessages::AllowSpec );
    //    message.WriteByte(0);
    //message.End();
}
void AmmoPickup(){
    NetworkMessage message( MSG_ALL, NetworkMessages::AmmoPickup );
        //ammo index  |  Grab it by CBasePlayerWeapon::PrimaryAmmoIndex()
        message.WriteByte(0);
        //how many  |  Negative numbers take absolute values
        message.WriteLong(0);
    message.End();
}
void AmmoX(){
    NetworkMessage message( MSG_ALL, NetworkMessages::AmmoX );
        //ammo index  |  Grab it by CBasePlayerWeapon::PrimaryAmmoIndex()
        message.WriteByte(0);
        //how many  |  Negative numbers take absolute values
        message.WriteLong(0);
    message.End();
}
void Battery(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Battery );
        message.WriteShort(0);
    message.End();
}
//Enable Mouse
//0 close
//1 open
//2 open spr file as cursor
void CameraMouse(){
    NetworkMessage message( MSG_ALL, NetworkMessages::CameraMouse );
        message.WriteByte(2);
        //when byte 2
        message.WriteString("sprites/billow_01.spr");
    message.End();
}
//TODO: Unkown yet, wait for hook test
void CbElec(){
    NetworkMessage message( MSG_ALL, NetworkMessages::CbElec );
        message.WriteByte(255);
    message.End();
}
void ChangeSky(){
    //NetworkMessage message( MSG_ALL, NetworkMessages::ChangeSky );
        //Sky name
    //    message.WriteString("desert");
        //r
    //    message.WriteCoord(0);
        //g
    //    message.WriteCoord(0);
        //b
    //    message.WriteCoord(0);
    //message.End();
}
void ClassicMode(){
    NetworkMessage message( MSG_ALL, NetworkMessages::CbElec );
        //0 Disable
        //1~255 Enable
        message.WriteByte(255);
    message.End();
}
//SSSSHHHHAAAAAKKKKEEEE camera
void Concuss(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Concuss );
        message.WriteFloat(15);//yall
        message.WriteFloat(-15);//pitch
        message.WriteFloat(15);//roll
    message.End();
}
void CreateBlood(){
    NetworkMessage message( MSG_ALL, NetworkMessages::CreateBlood );
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
        //https://github.com/baso88/SC_AngelScript/wiki/Temporary-Entities#palette-1
        message.WriteByte(251);//color
        message.WriteByte(255);//sacle
    message.End();
}
//Switched weapon info
void CurWeapon(){
    NetworkMessage message( MSG_ALL, NetworkMessages::CurWeapon );
        uint8 state = 0;
        message.WriteByte(state);
        //State > 0 new weapon
        if(state > 0){
            //weapon id
            //id < 0 drop all weapon
            message.WriteShort(0);
            //clip1
            message.WriteLong(0);
            //clip2
            message.WriteLong(0);
        }
        else{
            //Flag
            //0X1FE Player dead
            //0 drop all weapon
            message.WriteShort(0);
        }
    message.End();
}
//Draw custom spr
//Why u need this? just use HUDSpriteParams!
void CustSpr(){
    NetworkMessage message( MSG_ALL, NetworkMessages::CustSpr );
        //Channle
        //0 off
        message.WriteByte(0);
        //if channle not 0....
        //flag
        message.WriteLong(0);
        //spr path
        message.WriteString("sprite/null.spr");
        //rect
        //left
        message.WriteByte(0);
        //right
        message.WriteByte(0);
        //width
        message.WriteShort(0);
        //height
        message.WriteShort(0);
        //x
        message.WriteFloat(0);
        //y
        message.WriteFloat(0);
        //color 1
        //rgba
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        //color 2
        //rgba
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        //frame
        message.WriteByte(0);
        //numframe
        message.WriteByte(0);
        //framerate
        message.WriteFloat(0);
        //fadeinTime
        message.WriteFloat(0);
        //fadeoutTime
        message.WriteFloat(0);
        //holdTime
        message.WriteFloat(0);
        //fxTime
        message.WriteFloat(0);
        //effect
        message.WriteByte(0);
    message.End();
}
//For custom weapon load sprite
//dont use this
void CustWeapon(){
    NetworkMessage message( MSG_ALL, NetworkMessages::CustWeapon );
        //id
        message.WriteShort(0);
        //classname
        message.WriteString("weapon_bfg9000");
    message.End();
}
void Damage(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Damage );
        //armor reduce
        //useless, because only armor got damage will not send this message, LOL
        message.WriteByte(0);
        //damage taken
        message.WriteByte(0);
        //damage type
        message.WriteLong(0);
        //Attacker pos
        //For damage indicator
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
    message.End();
}
//Remove annoying vote VGUI pannel, yeah ,thats it
void EndVote(){
    NetworkMessage message( MSG_ALL, NetworkMessages::EndVote );
    message.End();
}
//wow! weapon_flamethrower!
//oh no, just play tfc/weapons/flmfire2.wav and sprites/flamethrower/fthrow.spr :(
void Flamethwr(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Flamethwr );
        message.WriteByte(1);
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
        message.WriteCoord(-143);//yaw maybe?
        message.WriteCoord(601);//ptich?
        message.WriteCoord(-1559);//roll?
    message.End();
}
//how much flash battery left?
void FlashBat(){
    NetworkMessage message( MSG_ALL, NetworkMessages::FlashBat );
        //0~100
        message.WriteByte(1);
    message.End();
}
//which guy using flash?
void Flashlight(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Flashlight );
        //id
        message.WriteByte(1);
        //battery
        message.WriteByte(1);
    message.End();
}
//Fog
void Fog(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Fog );
        //useless
        message.WriteShort(0);
        //state, 0 for off
        message.WriteByte(1);
        //if state not 0
        //useless
        message.WriteCoord(0);
        //useless
        message.WriteCoord(0);
        //useless
        message.WriteCoord(0);
        //useless
        message.WriteShort(0);
        //color rgb
        message.WriteByte(1);
        message.WriteByte(1);
        message.WriteByte(1);
        //startdist
        message.WriteShort(0);
        //enddist
        message.WriteShort(0);
    message.End();
}
//Change scoreboard mode
//0 Normal
//1 Team play
void GameMode(){
    NetworkMessage message( MSG_ALL, NetworkMessages::GameMode );
        message.WriteByte(1);
    message.End();
}
//HλLF-LIFE  WOWOWOW
void GameTitle(){
    NetworkMessage message( MSG_ALL, NetworkMessages::GameTitle );
    message.End();
}
void GargSplash(){
    NetworkMessage message( MSG_ALL, NetworkMessages::GargSplash );
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
    message.End();
}
void Geiger(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Geiger );
        //Geiger range
        //will be Lsh 2
        // iGergerrange << 2
        message.WriteByte(1);
    message.End();
}
void Gib(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Gib );
        //0 Random small gib
        //1 Random big gib
        //2 Alien gib
        message.WriteByte(4);
        //origin
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
        //shoot velocity
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
    message.End();
}
//HUD Health
void Health(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Health );
        //health value
        message.WriteLong(1);
    message.End();
}
void HideHUD(){
    NetworkMessage message( MSG_ALL, NetworkMessages::HideHUD );
        //Hide flag
        /*
            HUD_HIDEWEAPONS = (1 << 0),
            HUD_HIDEFLASHLIGHT = (1 << 1),
            HUD_HIDEALL = (1 << 2),
            HUD_HIDEHEALTH = (1 << 3),
            HUD_HIDESELECTION = (1 << 4),
            HUD_HIDEBATTERY = (1 << 5),
            HUD_HIDECUSTOM1 = (1 << 6),
            HUD_HIDECUSTOM2 = (1 << 7)
        */
        message.WriteByte(1);
    message.End();
}
void HudText(){
    NetworkMessage message( MSG_ALL, NetworkMessages::HudText );
        //health value
        message.WriteString("Hello World!");
    message.End();
}
//Dont use this, client can not delete item that they don't have!
void InvAdd(){
    NetworkMessage message( MSG_ALL, NetworkMessages::InvAdd );
        //id?
        message.WriteLong(4);
        //Count?
        message.WriteByte(255);
        message.WriteByte(1);
        message.WriteByte(1);
        message.WriteFloat(114514);
        message.WriteString("0");
        //Item Name
        message.WriteString("Big Fucking Gun 9000");
        //Item description
        message.WriteString("DESTORY");
        //Dont konw yet
        message.WriteString("0");
        //HUD Spr
        message.WriteString("stopwatch");
    message.End();
}
//Dont use this, client won't real drop item!
void InvRemove(){
    NetworkMessage message( MSG_ALL, NetworkMessages::InvAdd );
        //id?
        message.WriteLong(4);
        //Count?
        message.WriteByte(255);
    message.End();
}
void ItemPickup(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ItemPickup );
        message.WriteString("item_balabala");
    message.End();
}
//What?
void MapList(){
    NetworkMessage message( MSG_ALL, NetworkMessages::MapList );
        message.WriteString("item_balabala");
    message.End();
}
void MOTD(){
	NetworkMessage message( MSG_ALL, NetworkMessages::MOTD );
        //0 Close MOTD
		message.WriteByte(1);
		message.WriteString("Hello World!");
	message.End();
}
//Scoreboard Nextmap: xxxx
void NextMap(){
	NetworkMessage message( MSG_ALL, NetworkMessages::NextMap );
		message.WriteString("Hello World!");
	message.End();
}
void NotifyText(){
    //NetworkMessage message( MSG_ALL, NetworkMessages::NotifyText );
    //    message.WriteByte(1);
	//	message.WriteString("Hello World!");
	//message.End();
}
//WHY U use this? use HUDNumDisplayParams!
void NumDisplay(){
    NetworkMessage message( MSG_ALL, NetworkMessages::NumDisplay );
        //Channle
        //0 off
        message.WriteByte(0);
        //if channle not 0....
        //flag
        message.WriteLong(0);
        //defdigits
        message.WriteByte(0);
        //maxdigits
        message.WriteByte(0);
        //x
        message.WriteFloat(0);
        //y
        message.WriteFloat(0);
        //color 1
        //rgba
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        //color 2
        //rgba
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        //spr
        message.WriteString("watchstop");
        //rect
        //left
        message.WriteByte(0);
        //right
        message.WriteByte(0);
        //width
        message.WriteShort(0);
        //height
        message.WriteShort(0);
        //fadeinTime
        message.WriteFloat(0);
        //fadeoutTime
        message.WriteFloat(0);
        //holdTime
        message.WriteFloat(0);
        //fxTime
        message.WriteFloat(0);
        //effect
        message.WriteByte(0);
    message.End();
}
void OnTank(){
    //NetworkMessage message( MSG_ALL, NetworkMessages::OnTank );
        //0 for off
        //1~255 for on
	//	message.WriteByte(0);
	//message.End();
}
void Playlist(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Playlist );
		message.WriteString("Never fade away");
	message.End();
}
void PrintKB(){
    NetworkMessage message( MSG_ALL, NetworkMessages::PrintKB );
		message.WriteString("114");
	message.End();
}
//Portal Update
void PrtlUpdt(){
    NetworkMessage message( MSG_ALL, NetworkMessages::PrtlUpdt );
        //flag?
		message.WriteLong(0);
        //state
        //0 off
        message.WriteByte(1);
        //if state not 0...
        //state2
        message.WriteByte(1);
        //string flag
        message.WriteByte(1);
        message.WriteFloat(0);
        message.WriteLong(0);
        message.WriteLong(0);
        message.WriteByte(1);
        //if state2 not 0...
        //state3
        message.WriteByte(1);
        //if state3 not 0...
        message.WriteLong(0);
        message.WriteCoord(0);//x
        message.WriteCoord(0);//y
        message.WriteCoord(0);//z
        message.WriteAngle(9);//y
        message.WriteAngle(9);//p
        message.WriteAngle(9);//r
        //state4
        message.WriteByte(1);
        //if state4 not 0...
        message.WriteLong(0);
        message.WriteLong(0);
        //if state2 is 2...
        message.WriteByte(1);
        message.WriteByte(1);
        //if string flag not 0...
        message.WriteString("");
	message.End();
}
void RampSprite(){
    NetworkMessage message( MSG_ALL, NetworkMessages::RampSprite );
        message.WriteShort(0);
        message.WriteByte(0);
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
        //bitflag
        message.WriteShort(32767);
        //bitflag & 1
        message.WriteByte(1);
        //bitflag & 2
        message.WriteByte(1);
        //bitflag & 4
        message.WriteByte(1);
        //bitflag & 8
        message.WriteByte(1);
        //bitflag & 16
        message.WriteByte(1);
        //bitflag & 32
        message.WriteByte(1);
        //bitflag & 64
        message.WriteByte(1);
        //bitflag & 128
        message.WriteByte(1);
        //bitflag & 256
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
        //bitflag & 512
        message.WriteByte(1);
        //bitflag & 1024
        message.WriteByte(1);
        //bitflag & 2048
        message.WriteByte(1);
        //bitflag & 4096
        message.WriteByte(1);
        //bitflag & 8192
        message.WriteByte(1);
        //bitflag & 16348
        message.WriteByte(1);
        //bitflag & 32768
        message.WriteByte(1);
    message.End();
}
//For server get client voice setting
void ReqState(){
    //NetworkMessage message( MSG_ALL, NetworkMessages::ReqState );
    //message.End();
}
void SayText(){
    NetworkMessage message( MSG_ALL, NetworkMessages::SayText );
        //said player index
        message.WriteByte(1);
        //flag
        message.WriteByte(2);
        message.WriteString("Hello world");
    message.End();
}
void ScoreInfo(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ScoreInfo );
        message.WriteByte(1);   //Update player index
        message.WriteFloat(0);  //frags
        message.WriteLong(0);   //death
        message.WriteFloat(0);  //health
        message.WriteFloat(0);  //armor
        message.WriteByte(0);   //team
        //0 none
		//1 electro crowbar
		//2 golden uzi
		//3 dollar
		//4 tester
		//5 artist
		//6 developer
        message.WriteShort(6);  //doner icon
        //0 none
        //1 admin
        //2 serverowner
        message.WriteShort(0);  //admin icon
     message.End();
}
void ServerBuild(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ServerBuild );
        message.WriteString("Hello world");
    message.End();
}
//Scoreboard Title
void ServerName(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ServerName );
        message.WriteString("Hello world");
    message.End();
}
//This thing will kick everyone
void ServerVer(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ServerVer );
        message.WriteString("Hello world");
    message.End();
}
//Set Player FOV
void SetFOV(){
    NetworkMessage message( MSG_ALL, NetworkMessages::SetFOV );
        message.WriteByte(90);
    message.End();
}
void ShieldRic(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ShieldRic );
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
    message.End();
}
//weapon_shockrifle
//shock effect
//0 secconaryAttack
//1 PrimaryAttack
void ShkFlash(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ShkFlash );
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
        message.WriteByte(0);
    message.End();
}
void ShowMenu(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ShowMenu );
        message.WriteShort(1);
        message.WriteChar("@");
        //1 mean has continue content....
        message.WriteByte(1);
        message.WriteString("Hello world");
        message.WriteString("Goodbye world");
    message.End();
}
//Excute "speak xxxx" command in client..
void Speaksent(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Speaksent );
        message.WriteString("ass");
    message.End();
}
//this just tag player as observer in scoreboard
void Spectator(){
    NetworkMessage message( MSG_ALL, NetworkMessages::Spectator );
        //Spectator
        message.WriteByte(1);
        //Be spectator
        message.WriteByte(1);
    message.End();
}
void SporeTrail(){
    NetworkMessage message( MSG_ALL, NetworkMessages::SporeTrail );
        //index
        message.WriteShort(1);
        //0 PrimaryAttack
        //1 SecconaryAttack
        message.WriteByte(0);
    message.End();
}
void SRDetonate(){
    NetworkMessage message( MSG_ALL, NetworkMessages::SRDetonate );
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
        //Sclae
        message.WriteByte(255);
    message.End();
}
//shock rifle secconaryAttack
void SRPrimed(){
    NetworkMessage message( MSG_ALL, NetworkMessages::SRPrimed );
        //index
        message.WriteByte(1);
        message.WriteFloat(40);
    message.End();
}
//shock rifle secconaryAttack stop
void SRPrimedOff(){
    NetworkMessage message( MSG_ALL, NetworkMessages::SRPrimedOff );
        //index
        message.WriteByte(1);
    message.End();
}
//Useless, because you have no way to get sample index, LOL
void StartSound(){
    NetworkMessage message( MSG_ALL, NetworkMessages::SRDetonate );
        //bitFlag
        message.WriteShort(128);
        //bitFlag & 16
        //Sample index
        message.WriteShort(0);
        //bitFlag & 1
        //Volume
        message.WriteByte(255);
        //bitFlag & 2
        message.WriteByte(255);
        //bitFlag & 4
        message.WriteByte(255);
        //bitFlag & 8
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
        //bitFlag & 32768
        message.WriteFloat(255);
        message.WriteByte(255);
        message.WriteShort(128);
        
    message.End();
}
//To put player into A team
void TeamInfo(){
    NetworkMessage message( MSG_ALL, NetworkMessages::TeamInfo );
        //player index
        message.WriteByte(1);
        //TeamName
        message.WriteString("Gordon");
    message.End();
}
//To tell client how maney team we have
void TeamNames(){
    NetworkMessage message( MSG_ALL, NetworkMessages::TeamNames );
        //teams count
        message.WriteByte(2);
        //TeamName
        message.WriteString("Gordon");
        //TeamColor
        message.WriteCoord(1);//r
        message.WriteCoord(0);//g
        message.WriteCoord(0);//b
        //TeamName
        message.WriteString("Barney");
        //TeamColor
        message.WriteCoord(0);//r
        message.WriteCoord(1);//g
        message.WriteCoord(0);//b
    message.End();
}
//Useless, because Sven coop TeamPannel will caculate this in client, LOL
void TeamScore(){
    NetworkMessage message( MSG_ALL, NetworkMessages::TeamScore );
        //TeamName
        message.WriteString("Gordon");
        //TeamScore
        message.WriteShort(1);
        //TeamDeath
        message.WriteShort(1);
    message.End();
}
void TextMsg(){
    NetworkMessage message( MSG_ALL, NetworkMessages::TextMsg );
        //Flag
        message.WriteByte(1);
        message.WriteString("W");
        message.WriteString("O");
        message.WriteString("R");
        message.WriteString("L");
        message.WriteString("D");
    message.End();
}
//WHY U use this? USE HUDNumDisplayParams!
void TimeDisplay(){
    NetworkMessage message( MSG_ALL, NetworkMessages::TimeDisplay );
        //Channle
        //0 off
        message.WriteByte(0);
        //if channle not 0....
        //flag
        message.WriteLong(0);
        //min
        message.WriteFloat(0);
        //sec
        message.WriteFloat(0);
        //x
        message.WriteFloat(0);
        //y
        message.WriteFloat(0);
        //color 1
        //rgba
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        //color 2
        //rgba
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        message.WriteByte(0);
        //spr
        message.WriteString("watchstop");
        //rect
        //left
        message.WriteByte(0);
        //right
        message.WriteByte(0);
        //width
        message.WriteShort(0);
        //height
        message.WriteShort(0);
        //fadeinTime
        message.WriteFloat(0);
        //fadeoutTime
        message.WriteFloat(0);
        //holdTime
        message.WriteFloat(0);
        //fxTime
        message.WriteFloat(0);
        //effect
        message.WriteByte(0);
    message.End();
}
//change ScoarBorad timeleft
void TimeEnd(){
    NetworkMessage message( MSG_ALL, NetworkMessages::TimeEnd );
        //time left(in sec)
        message.WriteLong(999);
    message.End();
}
//Toggle HUD Element
void ToggleElem(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ToggleElem );
        //useless
        message.WriteByte(0);
        //channel
        message.WriteByte(0);
    message.End();
}
//Spawn a tomad toxic cloud
void ToxicCloud(){
    NetworkMessage message( MSG_ALL, NetworkMessages::ToxicCloud );
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
    message.End();
}
//WHY U use this? USE CUtility::TracerDecal!
void TracerDecal(){
    NetworkMessage message( MSG_ALL, NetworkMessages::TracerDecal );
        //Start POS
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
        //End Pos
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
        //useless
        message.WriteByte(0);
        //iDecalNumber
        message.WriteByte(0);
    message.End();
}
//Show Train speedo meter HUD
//0 off
//1 stop
//2 forward 1
//3 forward 2
//4 forward 3
//5 backward
void TrainHUD(){
	NetworkMessage message( MSG_ALL, NetworkMessages::Train );
		message.WriteByte(0);
	message.End();
}
//WHY U use this? Use CPlayerFuncs::HudUpdateNum!
void UpdateNum(){
    NetworkMessage message( MSG_ALL, NetworkMessages::UpdateNum );
        //Channel
		message.WriteByte(0);
        //Value
        message.WriteFloat(0);
	message.End();
}
//WHY U use this? Use CPlayerFuncs::HudUpdateTime!
void UpdateTime(){
    NetworkMessage message( MSG_ALL, NetworkMessages::UpdateTime );
        //Channel
		message.WriteByte(0);
        //min
        message.WriteFloat(0);
        //sec
        message.WriteFloat(0);
	message.End();
}
void ValClass(){
    //NetworkMessage message( MSG_ALL, NetworkMessages::ValClass );
        //length
		//message.WriteByte(3);
        //do "length" loop
        //Value
        //message.WriteShort(1);
        //message.WriteShort(2);
        //message.WriteShort(3);
	//message.End();
}
void VGUIMenu(){
    NetworkMessage message( MSG_ALL, NetworkMessages::VGUIMenu );
        //flag
		message.WriteByte(0);
        //if flag 4
        //message.WriteString("Hello World");
	message.End();
}
void VModelPos(){
    NetworkMessage message( MSG_ALL, NetworkMessages::VModelPos );
        //flag
        //1 set pos
        //0/2~255 reset
		message.WriteByte(1);
        //if flag 1
        message.WriteCoord(3);//r
        message.WriteCoord(4);//g
        message.WriteCoord(5);//b
	message.End();
}
void VoiceMask(){
    //ban index i player
    //Bitsum is 1 << (i-1)
    //NetworkMessage message( MSG_ALL, NetworkMessages::VoiceMask );
        //AudiblePlayersIndexBitSum
    //    message.WriteLong(0);
        //ServerBannedPlayersIndexBitSum
    //    message.WriteLong(0);
    //message.End();
}
//Create a votemenu pannel
void VoteMenu(){
    NetworkMessage message( MSG_ALL, NetworkMessages::VoteMenu );
        //hold time
        message.WriteByte(10);
        //vote content
		message.WriteString("hello");
        //yes button content
		message.WriteString("ok");
        //no button content
		message.WriteString("negative");
	message.End();
}
//For build WeaponResouce
//for replace weapon slot
void WeaponList(){
    NetworkMessage message( MSG_ALL, NetworkMessages::WeaponList );
        //weaponanme
        message.WriteString("weapon_crowbar");
        //ammotype1
		message.WriteByte(1);
        //max ammo
        message.WriteLong(1);
        //ammotype2
        message.WriteByte(1);
        //max ammo
        message.WriteLong(1);
        //slot
        message.WriteByte(1);
        //pos
        message.WriteByte(1);
        //id
        message.WriteShort(1);
        //flag
        message.WriteByte(1);
	message.End();
}
void WeapPickup(){
    NetworkMessage message( MSG_ALL, NetworkMessages::WeapPickup );
        //id
        message.WriteShort(1);
	message.End();
}
//call an entity named "weather_effect" to create weather effect
//BUUUT, according to the dump of server.dll, we don't have an entity named "weather_effect". so, useless
void WeatherFX(){
    NetworkMessage message( MSG_ALL, NetworkMessages::WeatherFX );
        //flag
        message.WriteShort(1);
        //start
        message.WriteCoord(-143);//x
        message.WriteCoord(601);//y
        message.WriteCoord(-1559);//z
        //end
        message.WriteCoord(0);//x
        message.WriteCoord(0);//y
        message.WriteCoord(0);//z
        //angle
        message.WriteAngle(-143);//y
        message.WriteAngle(-210);//p
        message.WriteAngle(-245);//r

        message.WriteShort(1);
        message.WriteFloat(1);
        message.WriteByte(1);

        message.WriteShort(1);
        message.WriteFloat(1);
        message.WriteByte(1);

        message.WriteByte(1);
        message.WriteFloat(1);

        //rgba
        message.WriteByte(255);
        message.WriteByte(1);
        message.WriteByte(1);
        message.WriteByte(255);

        message.WriteFloat(1);
        message.WriteFloat(1);
        message.WriteFloat(1);
        message.WriteFloat(1);
	message.End();
}
