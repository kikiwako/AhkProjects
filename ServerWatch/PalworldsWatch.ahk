#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance, force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir "C:\Program Files (x86)\Steam\steamapps\common\PalServer"  ; Ensures a consistent starting directory.
SetFormat, float, 3.1

; Set these variables to use with other servers

; Name of the server that will be used for logs
serverName = Palworlds

; Path to the server's folder
serverPath = C:\Program Files (x86)\Steam\steamapps\common\PalServer

; Path to the file that launches the server
serverExe = C:\Program Files (x86)\Steam\steamapps\common\PalServer\PalServer.exe

; Path to the server's running executable (same as serverExe most of the time)
exeName = PalServer-Win64-Test-Cmd.exe

; RAM usage limit (GB) which will trigger a restart of the server.
; Set to 0 to remove any limit
memoryLimit = 10

; Don't touch those
processPID := 0
memoryUsage := 0

WriteLog("Starting Server Watcher", serverName)

if (memoryLimit > 0) {
    WriteLog("Memory Limit is " . memoryLimit . " GB", serverName)
}

Loop {
    processPID := GetRunningProcessId(exeName)

    if (processPID = 0) {
        WriteLog("Server is not running", serverName)
        Run, %serverExe%, %serverPath%
		WriteLog("Restarting Server", serverName)
    }

    if (processPID != 0) {
        memoryUsage := GetProcessMemoryInfo(processPID)

		if (memoryLimit > 0) {
			WriteLog("Server is using " . memoryUsage . " / " . memoryLimit . " GB of RAM", serverName)   
		} else {
			WriteLog("Server is using " . memoryUsage . " GB of RAM", serverName)
		}
    }

    if (memoryLimit > 0 and memoryUsage > memoryLimit) {
        WriteLog("Server memory is over the limit (" . memoryUsage . " / " . memoryLimit . ")", serverName)
        Process, Close, %processPID%
        WriteLog("Shutting down server", serverName)

		sleep, 1000 * 5
    } else {
        sleep, 1000 * 60	
    }
}

WriteLog(text, svrName) {
	FileAppend, %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min% :  %text% `n, %svrName%.txt ; can provide a full path to write to another directory
}

GetRunningProcessId(name)
{
    Process, Exist, %name%
    return ErrorLevel
}

;Get memory in KB
GetProcessMemoryInfo(PID)
{
    size := 440
    VarSetCapacity(pmcex,size,0)
    ret := ""
    
    hProcess := DllCall( "OpenProcess", UInt,0x400|0x0010,Int,0,Ptr,PID, Ptr )
    if (hProcess)
    {
        if (DllCall("psapi.dll\GetProcessMemoryInfo", Ptr, hProcess, Ptr, &pmcex, UInt,size))
            ret := NumGet(pmcex, (A_PtrSize=8 ? "16" : "12"), "UInt")/1024
        DllCall("CloseHandle", Ptr, hProcess)
    }

    return % ret / 1024 / 1024
}