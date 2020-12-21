//test
string test = "";
string strMatrix = "  ";
float flObj = 0;
CClientCommand g_HelloWorld("hello", "Hello", @helloword);
void helloword(const CCommand@ pArgs) 
{
    g_Game.AlertMessage( at_console, "Your Substr is: [" + test + "].\n");
    g_Game.AlertMessage( at_console, "Your Result is: [" + flObj + "].\n");
    g_Game.AlertMessage( at_console, "Your Matrix is: \n" + strMatrix );
}
//test//


const double m_iLcsMarch = 0.65;
string LastMap = "";
bool LCS( string&in str1, string&in str2)
{
    if( str1 == "" || str2 == "")
        return false;

    array<array<int8>> m_Matrix (str1.Length(), array<int8>( str2.Length(), 0));
    int8 index = 0;
    int8 length = 0;

    for(uint i = 0; i < str1.Length(); i++)
    {
        for(uint j = 0; j < str2.Length(); j++)
        {
            int8 n = int(i)-1 >= 0 && int(j)-1 >= 0 ? m_Matrix[i-1][j-1] : 0;

            m_Matrix[i][j] = str1[i] == str2[j] ? n+1 : 0;
            if( m_Matrix[i][j] > length )
            {
                length = m_Matrix[i][j];
                index = i;
            }
        }
    }

    //Test
    test = str1.SubString(index - length + 1, length);
    strMatrix = "  ";
    for (uint i = 0; i < str2.Length(); i++)
    {
        strMatrix += string(str2.opIndex(i)) + " ";
    }
    strMatrix += "\n";
    //test//

    for (uint i = 0; i < str1.Length(); i++)
    {
        strMatrix += string(str1.opIndex(i))  + " ";
        for(uint j = 0; j < str2.Length(); j++)
        {
            strMatrix += string(m_Matrix[i][j]) + " ";
        }
        strMatrix += "\n";
    }
    

    float Result = float(length)/float( str2.Length() > str1.Length() ? str2.Length() : str1.Length() );

    //test
    flObj = Result;
    //test//
    
    if( Result >= m_iLcsMarch)
        return true;
    return false;
}
