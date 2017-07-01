#SingleInstance force
#NoEnv
;~ OutputDebug DBGVIEWCLEAR
#Include ..\AppFactory\Source\AppFactory.ahk
#include CLR.ahk

Version := "4.0.2"

; Load MicroTimer Lib
dllname := "MicroTimer.dll"
if (!FileExist(dllname)){
    MsgBox % dllname " Not found"
    ExitApp
}
asm := CLR_LoadLibrary(dllname)
; Use CLR to instantiate a class from within the DLL
MicroTimer := asm.CreateInstance("MicroTimer")

Factory := new AppFactory()
w1 := 90, w2 := 200
Gui, Add, Text, % "xm y+10 w" w1, Fire Button
Factory.AddInputButton("HK1", "x+5 yp-3 w" w2, Func("InputEvent"))
Gui, Add, Text, % "xm y+10 w" w1, Fire Sequence
Factory.AddControl("FireSequence", "Edit", "x+5 yp-3 w" w2, "1,2,3,4", Func("SeqChanged"))
Gui, Add, Text, % "xm y+10 w" w1, Fire Rate
Factory.AddControl("FireRate", "Edit", "x+5 yp-3 w200", "500", Func("RateChanged"))
Gui, Add, Text, % "xm y+10 w" w1, Key Press Duration
Factory.AddControl("KeyDelay", "Edit", "x+5 yp-3 w200", "50", Func("KeyDelayChanged"))

SequencePos := 1

Gui, Show, , % "Fire Control v" Version
return

GuiClose:
    ExitApp

InputEvent(state){
    Global Factory, MicroTimer, FireRate
    static FireTimer := 0
    if (state){
        if (FireTimer != 0)
            return
        FireTimer := MicroTimer.Create(Func("DoFire"), FireRate)
        res := FireTimer.SetState(1)
        ;~ OutputDebug % "AHK| Timer Started, result: " res
    } else {
        res := FireTimer.SetState(0)
        FireTimer := 0
        ;~ OutputDebug % "AHK| Timer Stopped, result: " res
    }
}

SeqChanged(state){
    global Factory, FireSequence
    FireSequence := StrSplit(state, ",", A_Space)
}

KeyDelayChanged(state){
    SetKeyDelay, 0, % state
}

RateChanged(state){
    global FireRate
    FireRate := state
}

DoFire(){
    global FireSequence, SequencePos
    Send % "{Blind}{" FireSequence[SequencePos] "}"
    ;~ OutputDebug % "AHK| Fired - Sent key : " FireSequence[SequencePos] " (seq = " SequencePos " / " FireSequence.Length() ")"
    SequencePos++
    if (SequencePos > FireSequence.Length())
        SequencePos := 1
}