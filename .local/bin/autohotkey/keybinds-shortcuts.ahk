; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode("Input")  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.

#Enter::Run("wt.exe")
<!Space::Run("everything.exe")
; #Space::return ; disables winkey+space from switching kbd layout

; mute hotkey
F8::
{
    mute := SoundGetMute()
    if (mute = 0)
        SoundSetMute(true)
    else
        SoundSetMute(false)
}

; switch to audio device
; F10::
; {
;     global
;     Run("mmsys.cpl")
;     WinWait("Sound")
;     ControlSend("{Down 2}", "SysListView321")
;     ControlClick("&Set Default")
;     ControlClick("OK")
;     return
; }

; switch to audio device (2)
; F11::
; {
;     global
;     Run("mmsys.cpl")
;     WinWait("Sound")
;     ControlSend("{Down}", "SysListView321")
;     ControlClick("&Set Default")
;     ControlClick("OK")
;     return
; }
