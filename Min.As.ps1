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
    $bInString = $false
    $bInComment = $false
    $bInMultiCommnet = $false
    #now old older
    $charBuffer = @("", "", "")
    $buffer = ""
    $content = Get-Content $filePath -Raw 
    for($i = 0; $i -le $content.Length;$i++){
        $charBuffer[2] = $charBuffer[1]
        $charBuffer[1] = $charBuffer[0]
        $charBuffer[0] = ([char]$content[$i]).ToString()
        if($bInComment){
            if($charBuffer[0] -eq "`n"){
                $bInComment = $false
                $charBuffer[0] = $charBuffer[1] = $charBuffer[2] = ""
            }
            continue
        }
        if($bInMultiCommnet){
            if(($charBuffer[0] -eq "/") -and ($charBuffer[1] -eq "*")){
                $bInMultiCommnet = $false
                $charBuffer[0] = $charBuffer[1] = $charBuffer[2] = ""
            }
            continue
        }
        
        if(($charBuffer[0] -eq "`"") -and ($charBuffer[1] -ne "\")){
            if($bInString){
                $bInString = $false
            }
            else{
                $bInString = $true
            }
        }
        if($bInString -eq $false){
            if(($charBuffer[0] -eq "/") -and ($charBuffer[1] -eq "/")){
               $buffer += $charBuffer[2]
               $bInComment = $true
               continue
            }
            if(($charBuffer[0] -eq "*") -and ($charBuffer[1] -eq "/")){
                $bInMultiCommnet = $true
            }
        }
        if(($charBuffer[2] -ne "`n") -and ($charBuffer[2] -ne "`r")){
            $buffer += $charBuffer[2]
        }
    }
    if(($charBuffer[1] -ne "`n") -and ($charBuffer[1] -ne "`r")){
        $buffer += $charBuffer[1]
    }
    if(($charBuffer[0] -ne "`n") -and ($charBuffer[0] -ne "`r")){
        $buffer += $charBuffer[0]
    }
    foreach($k in $replaceMap.Keys){
        if($buffer.Contains($k)){
            $buffer = $buffer.Replace($k, $replaceMap[$k])
        }
    }
    $buffer -replace " {2,}", " " | Out-File ($filePath.SubString(0, $filePath.Length - 3) + ".min.as") -Encoding utf8 -NoNewline
}
else{
    Write-Output "Invalid file..."
}
Write-Output "Any key exit"
Read-Host | Out-Null
