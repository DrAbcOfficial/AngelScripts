namespace TJAPlayer
{
    funcdef bool FuncCommandCall(string, TJAPlayer::TJAPlayer@);
    funcdef bool FuncNoteCall(uint, CBaseEntity@, TJAPlayer::TJAPlayer@);

    class TJAPlayer
    {
        int iNowBPM = 120;
        int iNowBeat = 4;
        int iNowNote = 4;
        string szNowTitle;
        string szAuthor;
        string szArtist;
        string szBGM;
        float flOffset = 0.0;
        CTJA@ nowTJA;
        float flTime = 0.0;
        float flBGMPlayDelay = 0.0;
        float flScrollMulti = 1.0;
        float flScrollSpeed = 600;
        float flScrollDistance = 0.0;

        string szOutFunction = "OutCall";
        string szCommandFunction = "CommandCall";
        string szPlayFunction = "PlayBGM";

        int iNowLine = 0;
        bool bIsEnd = false;
        bool bIsDrumRoll = false;
        bool bIsGOGO = false;
        bool bIsPlay = false;
        array<CScheduledFunction@> aryPlay = {};

        private array<FuncCommandCall@> aryCommandCall = {};
        private array<FuncNoteCall@> aryNoteCall = {};

        void AddCommandHook(FuncCommandCall@ pHook)
        {
            aryCommandCall.insertLast(pHook);
        }

        void RemoveCommandHook(FuncCommandCall@ pHook)
        {
            for(uint i = 0; i < aryCommandCall.length(); i++)
            {
                if(aryCommandCall[i] is pHook)
                {
                    aryCommandCall.removeAt(i);
                    break;
                }
            }
        }

        void ExcuteCommandHook(string szCommand, TJAPlayer::TJAPlayer@ pTJAPlayer)
        {
            for(uint i = 0; i < aryCommandCall.length(); i++)
            {
                aryCommandCall[i](szCommand, pTJAPlayer);
            }
        }

        void AddNoteHook(FuncNoteCall@ pHook)
        {
            aryNoteCall.insertLast(pHook);
        }

        void RemoveNoteHook(FuncNoteCall@ pHook)
        {
            for(uint i = 0; i < aryNoteCall.length(); i++)
            {
                if(aryNoteCall[i] is pHook)
                {
                    aryNoteCall.removeAt(i);
                    break;
                }
            }
        }

        void ExcuteNoteHook(uint uiNote, CBaseEntity@ pEntity, TJAPlayer::TJAPlayer@ pTJAPlayer)
        {
            for(uint i = 0; i < aryNoteCall.length(); i++)
            {
                aryNoteCall[i](uiNote, pEntity, pTJAPlayer);
            }
        }

        void Setup(CTJA@ pTJA)
        {
            for(uint i = 0; i < pTJA.Meta.length(); i++)
            {
                if(pTJA.Meta[i].Name == "BPM")
                    iNowBPM = atoi(pTJA.Meta[i].Value);
                else if(pTJA.Meta[i].Name == "TITLE")
                    szNowTitle = pTJA.Meta[i].Value;
                else if(pTJA.Meta[i].Name == "AUTHOR")
                    szAuthor = pTJA.Meta[i].Value;
                else if(pTJA.Meta[i].Name == "ARTIST")
                    szArtist = pTJA.Meta[i].Value;
                else if(pTJA.Meta[i].Name == "WAVE")
                    szBGM = pTJA.Meta[i].Value;
                else if(pTJA.Meta[i].Name == "OFFSET")
                    flOffset = atof(pTJA.Meta[i].Value);
            }
            flTime = -flOffset;
            flBGMPlayDelay = flScrollDistance / flScrollSpeed * flScrollMulti;
            @nowTJA = @pTJA;
        }

        void Stop()
        {
            if(@nowTJA is null)
                return;

            g_SoundSystem.StopSound( g_EntityFuncs.IndexEnt(0), CHAN_MUSIC, "taikocoop/" + szBGM );
            if(!bIsEnd)
            {
                for(uint i = 0; i < aryPlay.length(); i++)
                {
                    if(!aryPlay[i].HasBeenRemoved())
                        g_Scheduler.RemoveTimer(aryPlay[i]);
                }
            } 
            aryPlay = {};
            iNowLine = 0;
            flTime = -flOffset;
            flScrollMulti = 1.0;
            flScrollSpeed = 600;
            bIsDrumRoll = false;
            bIsPlay = false;
            bIsGOGO = false;
        }

        void Play()
        {
            if(!bIsPlay)
                Stop();
            if(@nowTJA is null)
                return;

            bIsPlay = true;
            bIsEnd = false;
            for(uint i = 0; i < nowTJA.Note.length(); i++)
            {
                uint iPreNowLine = 0;
                float flTimeGap = 0.0f;
                if(nowTJA.Note[i].bIsCommand)
                {
                    PreCommand(nowTJA.Note[i].szCommand);
                    aryPlay.insertLast(g_Scheduler.SetTimeout(szCommandFunction, flTime + flTimeGap, nowTJA.Note[i].szCommand, @this));
                }
                else
                {
                    iPreNowLine++;
                    //BPM与以X个X分音符为一节
                    flTimeGap = (60.0f / float(iNowBPM) / float(iNowBeat)) / (float(nowTJA.Note[i].aryNote.length()) / float(iNowBeat * iNowNote));
                    //加上Scroll改变的音符速度与标准差
                    flTimeGap += (flScrollDistance / (flScrollSpeed * flScrollMulti)) - (flScrollDistance / flScrollSpeed);
                    for(uint j = 0; j < nowTJA.Note[i].aryNote.length(); j++)
                    {
                        aryPlay.insertLast(g_Scheduler.SetTimeout(szOutFunction, flTime + (flTimeGap * float(j + 1)), nowTJA.Note[i].aryNote[j], iPreNowLine, @this));
                    }
                    flTime += flTimeGap * float(nowTJA.Note[i].aryNote.length());
                }
            }
            aryPlay.insertLast(g_Scheduler.SetTimeout(szPlayFunction, flBGMPlayDelay, szBGM));
            //Logger::Log(szNowTitle + "-" + szArtist);
            //Logger::Log("LEVLE: " + nowTJA.GetMeta("LEVEL"));
            //Logger::Log("" + Math.Floor(flTime / 60) + ":" + Math.Floor(flTime % 60));
        }

        void PreCommand(string szCommand)
        {
            if(szCommand.StartsWith("#BPMCHANGE"))
                iNowBPM = atoi(szCommand.Replace("#BPMCHANGE ", ""));
            else if(szCommand.StartsWith("#MEASURE"))
            {
                array<string> aryTemp = szCommand.Replace("#MEASURE ", "").Split("/");
                iNowBeat = atoi(aryTemp[0]);
                iNowNote = atoi(aryTemp[1]);
            }
            else if(szCommand.StartsWith("#SCROLL"))
                flScrollMulti = atof(szCommand.Replace("#SCROLL ", ""));
        }

        void ShowInfo()
        {
            g_PlayerFuncs.ShowMessageAll(szNowTitle + " - " + szArtist + " : " + szAuthor + "\nLEVEL: " + nowTJA.GetMeta("LEVEL"));
        }
    }
}

void PlayBGM(string szBGM)
{
    g_SoundSystem.EmitSoundDyn( g_EntityFuncs.IndexEnt(0), CHAN_MUSIC, "taikocoop/" + szBGM, 1.0, ATTN_NORM, 0, PITCH_NORM );
}

void CommandCall(string szCommand, TJAPlayer::TJAPlayer@ pTJAPlayer)
{
    if(szCommand.StartsWith("#START"))
        pTJAPlayer.iNowBPM = atoi(pTJAPlayer.nowTJA.GetMeta("BPM"));
    else if(szCommand.StartsWith("#BPMCHANGE"))
        pTJAPlayer.iNowBPM = atoi(szCommand.Replace("#BPMCHANGE ", ""));
    else if(szCommand.StartsWith("#END"))
    {
        pTJAPlayer.bIsEnd = true;
        pTJAPlayer.Stop();
    }
    else if(szCommand.StartsWith("#MEASURE"))
    {
        array<string> aryTemp = szCommand.Replace("#MEASURE ", "").Split("/");
        pTJAPlayer.iNowBeat = atoi(aryTemp[0]);
        pTJAPlayer.iNowNote = atoi(aryTemp[1]);
    }
    else if(szCommand.StartsWith("#GOGOSTART"))
        pTJAPlayer.bIsGOGO = true;
    else if(szCommand.StartsWith("#GOGOEND"))
        pTJAPlayer.bIsGOGO = false;
    else if(szCommand.StartsWith("#SCROLL"))
        pTJAPlayer.flScrollMulti = atof(szCommand.Replace("#SCROLL ", ""));
    pTJAPlayer.ExcuteCommandHook(szCommand, @pTJAPlayer);
}

void OutCall(uint uiNote, int iNowLine, TJAPlayer::TJAPlayer@ pTJAPlayer)
{
    if(pTJAPlayer.iNowLine != iNowLine)
        pTJAPlayer.iNowLine = iNowLine;

    if(!pTJAPlayer.bIsDrumRoll && uiNote == 0)
            return;
    else if(uiNote != 0)
        pTJAPlayer.bIsDrumRoll = false;

    if(uiNote == 5 || uiNote == 6 || uiNote == 7 )
        pTJAPlayer.bIsDrumRoll = true;
        
    CBaseEntity@ pNode = g_EntityFuncs.CreateEntity("func_hitnode", null, false);
    CBaseEntity@ pSpawner = g_EntityFuncs.FindEntityByTargetname(pSpawner, "spawner3");
    if(pSpawner !is null)
    {
        pNode.pev.origin = pSpawner.pev.origin;
        if(uiNote == 1 || uiNote == 3)
            pNode.pev.skin = 1;
        else if(uiNote == 2 || uiNote == 4)
            pNode.pev.skin = 0;
        else if(uiNote == 5 || uiNote == 6 || uiNote == 7 || uiNote == 0)
            pNode.pev.skin = 2;
        g_EntityFuncs.DispatchSpawn(pNode.edict());
        pNode.pev.velocity = Vector(0, pTJAPlayer.flScrollSpeed * pTJAPlayer.flScrollMulti, 0);
        if(uiNote == 3 || uiNote == 4 || uiNote == 6 )
            pNode.pev.scale *= 1.3;
        else if(uiNote == 0)
            pNode.pev.scale *= 0.7;
    }
    pTJAPlayer.ExcuteNoteHook(uiNote, pNode, @pTJAPlayer);
}