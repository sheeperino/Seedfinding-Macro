; SSG Custom Macro 1.16+ Seedfinding Edit
; Author: Sheep
; Credits: logwet, xheb_, Peej, Specnr

; Guide:
; - Change the settings however you like, adjust your reset hotkeys (bottom of the script)
; - Double click the file to run
; - Enjoy 


#NoEnv
#SingleInstance Force
#MaxThreadsPerHotkey 100
Process, Priority, , A
SetWorkingDir %A_ScriptDir%
SetDefaultMouseSpeed, 0
SetTitleMatchMode, 2
CoordMode, Mouse, Window

global oldWorldsFolder := "C:\Users\Sophie\Desktop\MultiMC\instances\1.12.2\.minecraft\oldWorlds\"
global SavesDirectories := ["C:\Users\Sophie\Desktop\MultiMC\instances\1.16.11\.minecraft\saves\","C:\Users\Sophie\Desktop\MultiMC\instances\1.16.12\.minecraft\saves\"]

global delayType := "Accurate" ; Accurate or Standard
global delay := 60 ; Delay between keypresses
global switchDelay := 0
global seedDelay := 0 ; Delay before typing the seed
global seed := 123 ; Put a seed here if needed
global worldMoving := True

global currInst := -1
global PIDs := GetAllPIDs()
global instances := SavesDirectories.MaxIndex()

IfNotExist, %oldWorldsFolder%
  FileCreateDir %oldWorldsFolder%

#Include, seedfinding settings.ahk

CreateWorld(idx)
{
  if (idx := GetActiveInstanceNum()) > 0
  {
    pid := PIDs[idx]  
    WaitMenuScreen(idx)
  	
  	Reset(pid)
      sleep, 50

    if (worldMoving)
  	  MoveWorlds(idx)
  }
}

Reset(pid)
{
    SetKeyDelay, -1
	Sleep(delay)
    	ControlSend, ahk_parent, {Blind}{Tab}{Enter}, ahk_pid %pid% ; Singleplayer
  	Sleep(delay)
  	ControlSend, ahk_parent, {Blind}{Tab 3}{Enter}, ahk_pid %pid% ; World list
  	Sleep(delay)
  	ControlSend, ahk_parent, {Blind}{Tab}{Enter 2}, ahk_pid %pid% ; Change gamemode
    Sleep(delay)
    ControlSend, ahk_parent, {Blind}{Tab 5}{Enter}, ahk_pid %pid% ; More World Options
  	Sleep(delay)
  	ControlSend, ahk_parent, {Blind}{Tab 3}, ahk_pid %pid%
  	Sleep(seedDelay)
    seed := GetSeed()
    ControlSend, ahk_parent, {Blind}{Text}%seed%, ahk_pid %pid% ; Seed
    Sleep(delay)
  	ControlSend, ahk_parent, {Blind}{Enter}, ahk_pid %pid% ; Create New World
}

ExitWorld()
{
  CheckSection()
  SetKeyDelay, -1
    WinGetTitle, title, ahk_pid %pid%
    if (GetActiveInstanceNum() == idx)
      return

    if (instances > 1) {
      idx := GetActiveInstanceNum()
      nextIdx := Mod(idx, instances) + 1
      SwitchInstance(nextIdx)
    }

  Send {Blind}{Shift Down}{Tab}{Shift Up}
  Send {Blind}{Enter}
  Send {Blind}{Esc}
  sleep, 10
  Send {Blind}{Shift Down}{Tab}{Shift Up}
  Send {Blind}{Enter}
	CreateWorld(idx)
return
}

Sleep(time) {
  if (delayType == "Accurate")
    DllCall("Sleep",UInt,time)
  else
    Sleep, time
}

MoveWorlds(idx)
{
  dir := savesDirectories[idx]
  OutputDebug, moving worlds of %dir%
  Loop, Files, %dir%*, D
  {
    If (InStr(A_LoopFileName, "New World"))
      FileMoveDir, %dir%%A_LoopFileName%, %oldWorldsFolder%%A_LoopFileName%%A_NowUTC%, R
  }
}

GetActiveInstanceNum() {
  WinGet, pid, PID, A
  WinGetTitle, title, ahk_pid %pid%
  for i, tmppid in PIDs {
    if (tmppid == pid)
      return i
  }
}

GetInstanceNum(pid)
{
  command := Format("powershell.exe $x = Get-WmiObject Win32_Process -Filter \""ProcessId = {1}\""; $x.CommandLine", pid)
  rawOut := RunHide(command)
  for i, savesDir in SavesDirectories {
    StringTrimRight, tmp, savesDir, 18
    subStr := StrReplace(tmp, "\", "/")
    if (InStr(rawOut, subStr))
      return i
  }
return -1
}

SwitchInstance(idx)
{
  currInst := idx
  pid := PIDs[idx]
  Sleep(switchDelay)
  WinSet, AlwaysOnTop, On, ahk_pid %pid%
  WinSet, AlwaysOnTop, Off, ahk_pid %pid%
  Send {Numpad%idx% down}
  sleep, 50
  Send {Numpad%idx% up}
  Send {Blind}{RButton}
}

RunHide(Command)
{
	OutputDebug, runhide
  dhw := A_DetectHiddenWindows
  DetectHiddenWindows, On
  Run, %ComSpec%,, Hide, cPid
  WinWait, ahk_pid %cPid%
  DetectHiddenWindows, %dhw%
  DllCall("AttachConsole", "uint", cPid)

  Shell := ComObjCreate("WScript.Shell")
  Exec := Shell.Exec(Command)
  Result := Exec.StdOut.ReadAll()

  DllCall("FreeConsole")
  Process, Close, %cPid%
Return Result
}

GetAllPIDs()
{
  OutputDebug, getting all pids 
  orderedPIDs := []
  loop, %instances%
    orderedPIDs.Push(-1)
  WinGet, all, list, ahk_exe javaw.exe
  Loop, %all%
  {
    WinGet, pid, PID, % "ahk_id " all%A_Index%
      Output .= pid "`n"
  }
  tmpPids := StrSplit(Output, "`n")
  for i, pid in tmpPids {
    if (pid) {
      inst := GetInstanceNum(pid)
      OutputDebug, instance num: %inst%
      orderedPIDs[inst] := pid
	  OutputDebug, pid %pid%
    }
  }
return orderedPIDs
}

WaitMenuScreen(idx)
{
  rawLogFile := StrReplace(savesDirectories[idx], "saves", "logs\latest.log")
  StringTrimRight, logFile, rawLogFile, 1
  numLines := 0
  Loop, Read, %logFile%
  {
    numLines += 1
  }
  mainMenu := False
  While (!mainMenu)
  {
    startTime := A_TickCount
    Loop, Read, %logFile%
    { 
      if ((numLines - A_Index) < 1)
      {
        if (InStr(A_LoopReadLine, "Stopping worker threads")) {
          mainMenu := True
        }
      }
    }
  }
}

SetTitles() {
  for i, pid in PIDs {
    WinSetTitle, ahk_pid %pid%, , Minecraft - Instance %i%
  }
}

#IfWinActive, ahk_exe javaw.exe
{
*CapsLock::
   ExitWorld()
return

*F12::
  SetTitles()
return

*!End::
  MsgBox, Script terminated by user
  ExitApp
}