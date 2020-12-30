#include "CTJA"

namespace CTJALoader
{
    CTJA@ Builder(string szFilename)
    {
        File@ file = g_FileSystem.OpenFile(szFilename, OpenFile::READ);
        if (file !is null && file.IsOpen()) 
		{
            bool bIsStart = false;
            CTJA pTJA;
            uint uiLine = 0;
			while(!file.EOFReached()) 
			{
                uiLine++;
                string sLine;
                file.ReadLine(sLine);
                sLine.Trim();

                if(sLine.IsEmpty())
                    continue;
                if(sLine == "#START")
                    bIsStart = true;
                
                if(!bIsStart)
                {
                    array<string> aryTemp = sLine.Split(":");
                    if(aryTemp.length() != 2)
                    {
                        Logger::Log("TJA File phrase fail in Line {0} Position {1}. Incorrect Command Format.", string(uiLine), string(file.Tell()));
                        continue;
                    }
                    pTJA.Meta.insertLast(CTJAMetaItem(aryTemp[0], aryTemp[1]));
                }
                else
                    pTJA.Note.insertLast(CTJANoteItem(sLine));
                if(sLine == "#END")
                    bIsStart = false;
			}
			file.Close();
            return pTJA;
		}
        Logger::Log("TJA File does not exist.");
        return null;
    }
}