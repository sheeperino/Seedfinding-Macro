#SingleInstance, force
SetKeyDelay, -1

global filteredLines := {}
global line := 1

RetrieveInfo() {
    lines := []
    FileReadLine, rawLines, test1.csv, %line%
    for k, v in StrSplit(rawLines, ",") {
        lines.Push(v)
    }
    filteredLines := { "seed": lines[1]
                    , "structure seed": lines[2]
                    , "spawn x": lines[3]
                    , "spawn z": lines[4]
                    , "portal x": lines[5]
                    , "portal z": lines[6]
                    , "village x": lines[8]
                    , "village z": lines[9]
                    , "ruined x": lines[12]
                    , "ruined z": lines[13]  }
}

InputSeed() {
    RetrieveInfo()
    seed := filteredLines["seed"]
    SendInput, %seed%
}

InputCoordinates(dimension, structure) {
    RetrieveInfo()
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
    SendInput, {t}
    sleep, 50
    SendInput, /execute in minecraft:%dimension% run tp @s %X% ~ %Z%
    SendInput, {Enter}
}

; hotkeys
; some key combinations don't work in that case user other combinations

Numpad1::
    line++
    InputSeed()
return

!Numpad1::
    line--
    InputSeed()
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

Numpad5::
    SendInput, /setblock ~ ~ ~ minecraft:nether_portal {Enter}
return