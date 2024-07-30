; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.

#Enter::Run("wt.exe")
<!Space::Run("everything.exe")

F11::
{
    global
    Run("mmsys.cpl")
    WinWait("Sound")
    ControlSend("{Down 2}", "SysListView321")
    ControlClick("&Set Default")
    ControlClick("OK")
    return
}

F12::
{
    global
    Run("mmsys.cpl")
    WinWait("Sound")
    ControlSend("{Down}", "SysListView321")
    ControlClick("&Set Default")
    ControlClick("OK")
    return
}
