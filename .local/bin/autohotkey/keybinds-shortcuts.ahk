﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Enter::Run, wt.exe
!Enter::Run, "C:\Program Files\Emacs\emacs-28.1\bin\runemacs.exe"
#Space::Run, everything.exe