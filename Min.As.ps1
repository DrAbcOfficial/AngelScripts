#Remove unnecessary characters from anglescripts
#To disgust others
Write-Output "Drop *.as files here."
$filePath = Read-Host
$filePath = $filePath.Trim("`"");
if($filePath.ToLower().EndsWith(".as")){
    $replaceMap = @{
        " ," = ","; ", " = ",";
        "+ " = "+"; " +" = "+";
        "- " = "-"; " -" = "-";
        " *" = "*"; "* " = "*";
        "/ " = "/"; " /" = "/";
        "; " = ";"; " ;" = ";";
        " &" = "&"; "& " = "&";
        " |" = "|"; "| " = "|";
        " %" = "%"; "% " = "%";
        " ^" = "^"; "^ " = "^";
        " !" = "!";
        "`t" = " ";
        " ?" = "?"; "? " = "?";
        " {" = "{"; "{ " = "{"; " }" = "}"; "} " = "}";
        " (" = "("; "( " = "("; " )" = ")"; ") " = ")";
        " <" = "<"; "< " = "<"; " >" = ">"; "> " = ">";
        " [" = "["; "[ " = "["; " ]" = "]"; "] " = "]";
        " =" = "="; "= " = "="
    }
    $aryScripts = @();
    #此处换成按字符读取，处理/**/
    Get-Content $filePath | ForEach-Object {
        $szLine = $_.ToString().Trim()
        if(!([string]::IsNullOrWhiteSpace($szLine)) -and !($szLine.StartsWith("//"))){
            $oldc = ''
            $newLine = ""
            foreach($c in $szLine){
                if(($c -eq '/') -and ($oldc -eq '/')){
                    $newLine = $newLine.Substring(0, $newLine.Length - 1)
                }
                $oldc = $c
                $newLine += $c
            }
            $aryScripts += @($newLine)
        }
    }
    $out
    foreach($szLine in $aryScripts){
        foreach($k in $replaceMap.Keys){
            if($szLine.Contains($k)){
                $szLine = $szLine.Replace($k, $replaceMap[$k])
            }
        }
        $szLine -replace " {2,}", " " | Out-File ($filePath.SubString(0, $filePath.Length - 3) + ".min.as") -NoNewline -Append utf8
    }
}
else{
    Write-Output "Invalid file..."
}
Write-Output "Any key exit"
Read-Host | Out-Null