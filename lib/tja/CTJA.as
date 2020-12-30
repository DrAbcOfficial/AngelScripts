class CTJAMetaItem
{
    string Value = "";
    string Name = "";
    CTJAMetaItem(string _Name, string _szStr)
    {
        Name = _Name;
        Value = _szStr;
    }
}

class CTJANoteItem
{
    bool bIsCommand = false;
    string szCommand = "";
    array<uint> aryNote = {};
    CTJANoteItem(string rawLine)
    {
        if(rawLine.StartsWith("#"))
        {
            bIsCommand = true;
            szCommand = rawLine;
        }
        else
        {
            rawLine.Trim(",");
            for(uint i =0;i < rawLine.Length();i++)
            {
                aryNote.insertLast(isalnum(rawLine[i]) ? atoui(rawLine[i]) : 0);
            }
        }
    }
}

class CTJA
{
    array<CTJAMetaItem@> Meta;
    array<CTJANoteItem@> Note;

    string GetMeta(string name)
    {
        for(uint i = 0;i < Meta.length();i++)
        {
            if(Meta[i].Name == name)
                return Meta[i].Value;
        }
        return "";
    }

    void Precache()
    {
        string szWave = "";
        for(uint i = 0; i < Meta.length(); i++)
        {
            if(Meta[i].Name == "WAVE")
            {
                szWave = Meta[i].Value;
                break;
            }
        }
        g_Game.PrecacheGeneric( "sound/taikocoop/" + szWave );
        g_SoundSystem.PrecacheSound( "taikocoop/" + szWave );
    }
}