option Explicit    
dim wmi,proc,procs,proname,flag,WshShell    
Do  
    proname="TxTGeoIP.exe"
set wmi=getobject("winmgmts:{impersonationlevel=impersonate}!\\.\root\cimv2")    
set procs=wmi.execquery("select * from win32_process")    
  flag=true    
for each proc in procs    
    if strcomp(proc.name,proname)=0 then    
      flag=false    
      exit for    
    end if    
next    
  set wmi=nothing    
  if flag then    
    Set WshShell = Wscript.CreateObject("Wscript.Shell")    
    WshShell.Run ("TxTGeoIP.exe")
end if    
  wscript.sleep 10000  
loop