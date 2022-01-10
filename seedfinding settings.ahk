#NoEnv
#SingleInstance, force
SetKeyDelay, -1

global filteredLines := {}
global line := 399 ; line to read "#" column
; global sectionStart := 399 ; starting section
global sectionEnd := 400 ; ending section


RetrieveInfo() {
    line++
    lines := []
    FileReadLine, rawLines, seedlist.csv, % line
    for k, v in StrSplit(rawLines, ",") {
        lines.Push(v)
    }
    filteredLines := { "seed": lines[3]
                    , "structure seed": lines[2]
                    ; , "spawn x": lines[3]
                    ; , "spawn z": lines[4]
                    , "portal x": lines[8]
                    , "portal z": lines[10]
                    , "village x": lines[4]
                    , "village z": lines[5]
                    , "ruined x": lines[6]
                    , "ruined z": lines[7]  }
}

GetSeed() {
    RetrieveInfo()
    seed := filteredLines["seed"]
    OutputDebug, current seed: %seed%
    return seed
}

CheckSection() {
    if (line > sectionEnd) {
        MsgBox, You reached the end of your section `nMark your section as done on discord! `nExiting app...
        ExitApp
    }
    else if (line == sectionEnd)
        MsgBox, This is the last seed of your section! %line%-%sectionEnd%
}

InputCoordinates(dimension, structure) {
    Switch structure
    {
    Case "spawn":
        X := filteredLines["spawn x"]
        Z := filteredLines["spawn z"]
    Case "portal":
        X := filteredLines["portal x"]
        Z := filteredLines["portal z"]
    Case "village":
        X := filteredLines["village x"]
        Z := filteredLines["village z"]
    Case "ruined":
        X := filteredLines["ruined x"]
        Z := filteredLines["ruined z"]
    }
    if (dimension == "the_nether") {
        X /= 8
        Z /= 8
    }
    Send, {Blind}{t}
    sleep, 50
    Send, {Blind}/execute in minecraft:%dimension% run tp @s %X% ~ %Z%
    Send, {Blind}{Enter}
}

; hotkeys
; some key combinations don't work in that case user other combinations

#IfWinActive, ahk_exe javaw.exe
{
Numpad1::
    line++
    seed := GetSeed()
    SendInput, %seed%
return

!Numpad1::
    line--
    seed := GetSeed()
    SendInput, %seed%
return

Numpad2::
    InputCoordinates("overworld", "portal")
Return

*!Numpad2::
    line--
    InputCoordinates("overworld", "portal")
Return

*^Numpad2::
    InputCoordinates("the_nether", "portal")
Return

*^!Numpad2::
    line--
    InputCoordinates("the_nether", "portal")
Return

Numpad3::
    InputCoordinates("overworld", "village")
Return

*!Numpad3::
    line--
    InputCoordinates("overworld", "village")
Return

Numpad4::
    InputCoordinates("overworld", "ruined")
Return

*!Numpad4::
    line--
    InputCoordinates("overworld", "ruined")
Return

Numpad5:: ; Spawn a nether portal
    Send, {Blind}{t}
    sleep, 50
    Send, {Blind}/setblock ~ ~ ~ minecraft:nether_portal
    Send, {Blind}{Enter}
return

Numpad6::
    MsgBox, current line %line%
return
}