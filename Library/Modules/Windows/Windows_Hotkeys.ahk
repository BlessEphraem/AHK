/** 
##############################################
#                  @README                   #
##############################################
**/

/*
Some windows default hotkey are awfull and useless.
Like if you do in this right order :

{LWin} + {LAlt} + {LShift} + {LCtrl}
    will open "https://m365.cloud.microsoft/?from=OfficeKey"

Microsoft want to reminds you that your computer is not yours.
I tried everything, and you can still have this page showing up,
so if you want to remove it completly, use Regedit

You should have a msgbox when you launch my script. 
If not, open a CMD as admin and write down :

REG ADD HKCU\Software\Classes\ms-officeapp\Shell\Open\Command /t REG_SZ /d rundll32
    Not harmfull at all, will only remove
    THIS microsoft shortcut DEFINITELY.
    Be sure before doing so.
*/

    Hold := [(Actions) => Sleep(10)]
    PressedHotkey := [(Actions) => SendInput("{" ThisHotkey := CleanHotkey() "}")]

    ClipSlotCopy_1 := [(Actions) => ClipSlot.Write(1)]
    ClipSlotCopy_2 := [(Actions) => ClipSlot.Write(2)]
    ClipSlotCopy_3 := [(Actions) => ClipSlot.Write(3)]
    ClipSlotCopy_4 := [(Actions) => ClipSlot.Write(4)]

    ClipSlotPaste_1 := [(Actions) => ClipSlot.Paste(1)]
    ClipSlotPaste_2 := [(Actions) => ClipSlot.Paste(2)]
    ClipSlotPaste_3 := [(Actions) => ClipSlot.Paste(3)]
    ClipSlotPaste_4 := [(Actions) => ClipSlot.Paste(4)]


;Numpad1::HandleKeyGestures(ClipSlotPaste_1, , ClipSlotCopy_1)

/** 
##############################################
#               @MODIFIER_KEY                #
##############################################
**/

; Disable Alt Acceleration Menu
~LAlt::SendInput("{Blind}{vkE8}")

;~LWin::LWin

; Replace Windows StartMenu with Flow Launcher. Can be any command.
;LWin up::StartMenu.Replace("Z:\Scripts\Tools\_externals\FlowLauncher\Flow.Launcher.exe")

/** 
##############################################
#                 @KEYBOARD                  #
##############################################
**/

#&::Application.Window(
        Application_Class.Arc.winTitle,
        Application_Class.Arc.path
    )

#é::Application.Window(
        Application_Class.Explorer.winClass,
        Application_Class.Explorer.path
    )

#"::Application.Window(
        Application_Class.Discord.winTitle,
        Application_Class.Discord.path
    )

#'::Application.Window(
        Application_Class.Codium.winTitle,
        Application_Class.Codium.path
    )

#(::Application.Window(
        Application_Class.Obsidian.winTitle,
        Application_Class.Obsidian.path
    )

#Numpad0::CMD("komorebic focus-workspace 0")
#Numpad1::CMD("komorebic focus-workspace 1")
#Numpad2::CMD("komorebic focus-workspace 2")
#Numpad3::CMD("komorebic focus-workspace 3")
#Numpad4::CMD("komorebic focus-workspace 4")

#space::{
    Language.Switch("fr", "en")
    GUI_Debug.ReturnDebug A_ThisHotkey, "SwitchLanguage() => Switch between 'fr' and 'en'", true
}

#²::{
    Terminal("Deepr Terminal", "wt.exe", 3, 1200, 850, "onToggle", 300)
    GUI_Debug.ReturnDebug A_ThisHotkey, "Terminal() => Run/Focus Deepr Terminal", true
}

#z::{
    AlwaysOnTop(Sound := true)
    GUI_Debug.ReturnDebug A_ThisHotkey, "AlwaysOnTop()", true
}

#f::{
    CMD("komorebic toggle-monocle")
    GUI_Debug.ReturnDebug A_ThisHotkey, "Komorebic() => 'toggle-monocle'", true
}

#v::{
    CMD("komorebic toggle-float")
    GUI_Debug.ReturnDebug A_ThisHotkey, "Komorebic() => 'toggle-float'", true
}

#^r::{
    CMD("komorebic retile")
    GUI_Debug.ReturnDebug A_ThisHotkey, "Komorebic() => 'retile'", true
}

#left::{
    CMD("komorebic cycle-move previous")
    GUI_Debug.ReturnDebug A_ThisHotkey, "Komorebic() => 'Move window PREV'", true
}

    #^left::{
        CMD("komorebic cycle-move-to-monitor previous")
        GUI_Debug.ReturnDebug A_ThisHotkey, "Komorebic() => 'Move to PREV Monitor'", true
    }

        #!left::{
            CMD("komorebic cycle-move-to-workspace previous")
            GUI_Debug.ReturnDebug A_ThisHotkey, "Komorebic() => 'Move to PREV Workspace'", true
        }

#right::{
    CMD("komorebic cycle-move next")
    GUI_Debug.ReturnDebug A_ThisHotkey, "Komorebic() => 'Move window NEXT'", true
}

    #^right::{
        CMD("komorebic cycle-move-to-monitor next")
        GUI_Debug.ReturnDebug A_ThisHotkey, "Komorebic() => 'Move to NEXT Monitor'", true
    }

        #!right::{
            CMD("komorebic cycle-move-to-workspace next")
            GUI_Debug.ReturnDebug A_ThisHotkey, "Komorebic() => 'Move to NEXT Workspace'", true
        }

#b:: {
    resolutions := [[810, 1440], [1920, 1080], [1400, 1400]]

    hwnd := WinActive("A")
    if !hwnd
    return

    ; Récupère les dimensions actuelles
    WinGetPos(&x, &y, &w, &h, hwnd)

    ; Trouve l'index de la résolution actuelle ou la plus proche
    idx := 0, minDiff := 1e9
    loop resolutions.Length {
        rw := resolutions[A_Index][1], rh := resolutions[A_Index][2]
        diff := Abs(w - rw) + Abs(h - rh)
        if diff < minDiff
        idx := A_Index, minDiff := diff
    }

    ; Résolution suivante (boucle circulaire)
    next := Mod(idx, resolutions.Length) + 1
    targetW := resolutions[next][1], targetH := resolutions[next][2]

    ; Centre la fenêtre
    posX := (A_ScreenWidth - targetW) // 2
    posY := (A_ScreenHeight - targetH) // 2

    WinMove(posX, posY, targetW, targetH, hwnd)
}



/**
#c:: {
hwnd := WinActive("A")
if !hwnd
return

; Récupérer la taille actuelle de la fenêtre
WinGetPos(&winX, &winY, &winW, &winH, hwnd)

; Taille de l'écran principal
screenW := A_ScreenWidth
screenH := A_ScreenHeight

; Calcul des nouvelles positions (centrées)
posX := (screenW - winW) // 2
posY := (screenH - winH) // 2

; Appliquer le déplacement sans redimensionnement
WinMove(posX, posY, , , hwnd)
}
*/



/** 
##############################################
#                   @MOUSE                   #
##############################################
**/

#Mbutton::{
    Window.Move "MButton"
    GUI_Debug.ReturnDebug "{MButton}", "WindowMover()", true
}

#!Mbutton::{
    Window.Resize "MButton"
    GUI_Debug.ReturnDebug "{Alt} + {MButton}", "WindowResizer()", true
}



;@_WheelLeft
F13::{
    CMD("komorebic cycle-move next")
    GUI_Debug.ReturnDebug "{WheelLeft} := {F13}", true
}

    !F13::{
        CMD("komorebic resize-axis horizontal decrease")
        GUI_Debug.ReturnDebug "{WheelLeft} := {F13}", true
    }

;@_WheelRight
F14::{
    CMD("komorebic cycle-move previous")
    GUI_Debug.ReturnDebug "{WheelRight} := {F14}", true
}

    !F14::{
        CMD("komorebic resize-axis horizontal increase")
        GUI_Debug.ReturnDebug "{WheelRight} := {F14}", true
    }



XButton1::{
    SendInput("{Delete}")
    GUI_Debug.ReturnDebug "{XButton1}", "SendInput() => {Delete}", true
}

    ^XButton1::{
        SendInput("^{Delete}")
        GUI_Debug.ReturnDebug "{Ctrl} + {XButton1}", "SendInput() => ^{Delete}", true
    }

        +XButton1::{
            SendInput("+{Delete}")
            GUI_Debug.ReturnDebug "{Shift} + {XButton1}", "SendInput() => +{Delete}", true
        }



XButton2::{
    SendInput("{Enter}")
    GUI_Debug.ReturnDebug "{XButton2}", "SendInput() => {Enter}", true
}

    ^XButton2::{
        SendInput("^{Enter}")
        GUI_Debug.ReturnDebug "{Ctrl} + {XButton2}", "SendInput() => ^{Enter}", true
    }

        +XButton2::{
            SendInput("+{Enter}")
            GUI_Debug.ReturnDebug "{Shift} + {XButton2}", "SendInput() => +{Enter}", true
        }



/** 
##############################################
#                @MXGESTURES                 #
##############################################
**/



/**
@NOTES
FOR MX MASTER USER :
Dunno why, but WheelRight/WheelLeft on MX Master is pretty bad recognized by AHK.,
Tried to assign "Launch_App1" and "Launch_App2", doesn't recognize it,
But "Launch_Mail" and "Launch_Media" work ?? Wtf logitech ??
I don't like it, so I decided to use F13 and F14.
If you have some problem with using these, because it open a f*cking office page,
go see @README at the top page.
**/



; Move windows across workspaces
;@_MXGestureLeft
+!#Down::{
    CMD("komorebic cycle-move-to-workspace previous")
    GUI_Debug.ReturnDebug "{Shift} + {MXGestureLeft} := #+!^{Down}", true
}

;@_MXGestureRight
+!#Up::{
    CMD("komorebic cycle-move-to-workspace next")
    GUI_Debug.ReturnDebug "{Shift} + {MXGestureRight} := #+!^{Up}", true
}

;Move windows across monitor
;@_MXGestureLeft
^!#Down::{
    CMD("komorebic cycle-move-to-monitor previous")
    GUI_Debug.ReturnDebug "{Ctrl} + {MXGestureLeft} := #+!^{Down}", true
}

;@_MXGestureRight
^!#Up::{
    CMD("komorebic cycle-move-to-monitor next")
    GUI_Debug.ReturnDebug "{Ctrl} + {MXGestureRight} := #+!^{Up}", true
}

;Change Workspace
;@_MXGestureLeft
#Down::{
    CMD("komorebic focus-monitor 0")
    Sleep(33)
    CMD("komorebic cycle-workspace previous")
    GUI_Debug.ReturnDebug "{MXGestureLeft} := #!{Down}", true
}

;@_MXGestureRight
#Up::{
    CMD("komorebic focus-monitor 0")
    Sleep(5)
    CMD("komorebic cycle-workspace next")
    GUI_Debug.ReturnDebug "{MXGestureRight} := #!{Up}", true
}

;@_MXGesturePress
Appskey::{
    CMD("komorebic toggle-workspace-layer")
    GUI_Debug.ReturnDebug "{MXGesturePress} := {AppsKey}", true
}



/** 
##############################################
#                  @KEYPAD                   #
##############################################
**/

/*
[ ][ ][ ][ ]
[ ][ ][ ][ ]
[ ][ ][ ][ ]
[■][■][■][■]
*/

;@_PadKey1
Browser_Home::{
    Application.Window(Application_Class.Explorer.winClass, "Z:\Workspace", false)
    GUI_Debug.ReturnDebug "{PadKey1} => {Browser_Home}", "Application.Window() => 'Z:\Workspace'", true
}

;@_PadKey2
Browser_Favorites::{
    Application.Window(Application_Class.Explorer.winClass, "Z:\Workspace\Renders\Watchfolder", false)
    GUI_Debug.ReturnDebug "{PadKey2} => {Browser_Favorites}", "Application.Window() => 'Z:\Workspace\Productions\Premiere Pro\.Watchfolder'", true
}

;@_PadKey3
Browser_Search::{
    Application.Window(Application_Class.Explorer.winClass, "Z:\Workspace\Renders", false)
    GUI_Debug.ReturnDebug "{PadKey3} => {Browser_Search}", "Application.Window() => 'Z:\Workspace\Productions\Premiere Pro\.Renders'", true
}

;@_PadKey4
Browser_Refresh::{
    Application.Window(Application_Class.Explorer.winClass, "Z:\Workspace\Productions\Premiere Pro\Sessions", false)
    GUI_Debug.ReturnDebug "{PadKey4} => {Browser_Refresh}", "Application.Window() => 'Z:\Workspace\Productions\Premiere Pro\Sessions'", true
}



/*
[ ][ ][ ][ ]
[ ][ ][ ][ ]
[■][■][■][■]
[ ][ ][ ][ ]
*/

;@_PadKey5
Launch_App1::{
    Application.Window(
        Application_Class.Explorer.winClass,
        "Z:\Files", false
    )
    GUI_Debug.ReturnDebug "{PadKey5} => {Launch_App1}", "Application.Window() => 'Z:\Files'", true
}

;@_PadKey6
Launch_App2::{
    Application.Window(
        Application_Class.Explorer.winClass,
        "Z:\Videos", false
    )
    GUI_Debug.ReturnDebug "{PadKey6} => {Launch_App2}", "Application.Window() => 'Z:\Videos'", true
}

;@_PadKey7
F15::{
    Application.Window(
        Application_Class.Explorer.winClass,
        "Z:\Pictures", false
    )
    GUI_Debug.ReturnDebug "{PadKey7} => {F15}", "Application.Window() => 'Z:\Pictures'", true
}

;@_PadKey8
F16::{
    Application.Window(
        Application_Class.Explorer.winClass,
        "Z:\Sounds", false
    )
    GUI_Debug.ReturnDebug "{PadKey8} => {F16}", "Application.Window() => 'Z:\Sounds'", true
}

/*
[ ][ ][ ][ ]
[■][■][■][■]
[ ][ ][ ][ ]
[ ][ ][ ][ ]
*/

;@_PadKey9
F17::{
    GUI_Debug.ReturnDebug "{PadKey9} => {F17}", "NONE", true
}

;@_PadKey10
F18::{
    GUI_Debug.ReturnDebug "{PadKey10} => {F18}", "NONE", true
}

;@_PadKey11
F19::{
    GUI_Debug.ReturnDebug "{PadKey11} => {F19}", "NONE", true
}

;@_PadKey12
F20::{
    GUI_Debug.ReturnDebug "{PadKey12} => {F20}", "NONE", true
}


/*
[■][■][■][■]
[ ][ ][ ][ ]
[ ][ ][ ][ ]
[ ][ ][ ][ ]
*/

;@_PadKey13
F21::{
    Application.Window(
        Application_Class.Explorer.winClass,
        "Z:\Scripts", false
    )
    GUI_Debug.ReturnDebug "{PadKey13} => {F21}", "Application.Window() => 'Z:\Scripts'", true
}

;@_PadKey14
F22::{
    GUI_Debug.ReturnDebug "{PadKey14} => {F22}", "NONE", true
}

;@_PadKey15
F23::{
    GUI_Debug.ReturnDebug "{PadKey15} => {F23}", "NONE", true
}

;@_PadKey16
F24::{
    IsShow := GUI_Debug.Toggle()
    ; Mise à jour facultative de la GUI de débogage (Debug_Gui)
    if (IsShow) {
    ; Le Toggle a fermé la fenêtre.
        GUI_Debug.ReturnDebug "{PadKey16} => {F24}", "GUI_Debug.Toggle() => Show Debug GUI", true
    } else {
    ; Le Toggle a lancé la fenêtre.
        GUI_Debug.ReturnDebug "{PadKey16} => {F24}", "GUI_Debug.Toggle() => Hide Debug GUI", true
    }
}

/**
##############################################
#            @KEYPAD_SMALLWHEEL1             #
##############################################
**/

Media_Prev::{
    Volume.Change("ChangeAppVolume", "Arc.exe", -0.02, "Z:\Scripts\Tools\_externals\nircmd.exe")
    GUI_Debug.ReturnDebug "{PadSmallWheel1 Left} => {Media_Prev}", "Volume.Change() => Arc -2%", true
}

Media_Play_Pause::{
    
    IsClosed := Volume.SndVol.Toggle(2, 1000, 200, 80, 5)
    Button := "{Media_Play_Pause}"

    ; Mise à jour facultative de la GUI de débogage (Debug_Gui)
    if (IsClosed) {
    ; Le Toggle a fermé la fenêtre.
        GUI_Debug.ReturnDebug "{PadSmallWheel1 Pressed} => " Button, "Volume.SndVol.Init() => SndVol Ended", true
    } else {
    ; Le Toggle a lancé la fenêtre.
        GUI_Debug.ReturnDebug "{PadSmallWheel1 Pressed} => " Button, "Volume.SndVol.Init() => SndVol Started", true
    }
}

Media_Next::{

    Volume.Change("ChangeAppVolume", "Arc.exe", +0.02, "Z:\Scripts\Tools\_externals\nircmd.exe")

    GUI_Debug.ReturnDebug "{PadSmallWheel1 Right} => {Media_Next}", "Volume.Change() => Arc +2%", true
}

/** 
##############################################
#            @KEYPAD_SMALLWHEEL2             #
##############################################
**/

Browser_Back::{
    Volume.Change("ChangeAppVolume", "discord.exe", -0.02, "Z:\Scripts\Tools\_externals\nircmd.exe")
    GUI_Debug.ReturnDebug "{PadSmallWheel2 Left} => {Browser_Back}", "changeappvolume discord.exe -0.1", true
}

Browser_Stop::{
    SendInput("{Browser_Stop}")
    GUI_Debug.ReturnDebug "{PadSmallWheel2 Pressed} => {Browser_Stop}", "changeappvolume discord.exe -0.1", true
}

Browser_Forward::{
    Volume.Change("ChangeAppVolume", "discord.exe", +0.02, "Z:\Scripts\Tools\_externals\nircmd.exe")
    GUI_Debug.ReturnDebug "{PadSmallWheel2 Right} => {Browser_Forward}", "changeappvolume discord.exe +0.1", true
}

/** 
##############################################
#              @KEYPAD_BIGWHEEL              #
##############################################
**/

Volume_Down::{
    Send("{Volume_Down}")
    GUI_Debug.ReturnDebug "{PadBigWheel Left} => {Volume_Down}", "Volume => Mix Down", true
}

Volume_Mute::{
    Send("{Media_Play_Pause}")
    GUI_Debug.ReturnDebug "{PadBigWheel Pressed} => {Volume_Mute}", "SendInput() => {Media_Play_Pause}", true
}

Volume_Up::{
    Send("{Volume_Up}")
    GUI_Debug.ReturnDebug "{PadBigWheel Right} => {Volume_Up}", "Volume => Mix Up", true
}


;   List of most useless key
;   1 = used by mouse
;   2 = used by macropad
;   0 = not used

;   NAME                         | USED? | Logitech Detected ? 
;   Browser_Back                 |   2   |  X
;   Browser_Forward              |   2   |  X
;   Browser_Refresh              |   2   |  X
;   Browser_Stop                 |   2   |  X
;   Browser_Search               |   2   |  X
;   Browser_Favorites            |   2   |  X
;   Browser_Home                 |   2   |  X

;   Volume_Mute                  |   2   |  X
;   Volume_Down                  |   2   |  X
;   Volume_Up                    |   2   |  X

;   Media_Next                   |   2   |  X
;   Media_Prev                   |   2   |  X
;   Media_Play_Pause             |   2   |  X
;   Media_Stop                   |   0   |  X

;   Launch_Mail                  |   0   |  X
;   Launch_Media                 |   0   |  X
;   Launch_App1                  |   0   |  N
;   Launch_App2                  |   0   |  N

;   Help                         |   0   |  N
;   AppsKey                      |   0   |  X
;   PrintScreen                  |   0   |  X
;   CtrlBreak                    |   0   |  N
;   Pause                        |   0   |  N

; Very hard to use key (bc it probably doesn't exist on most keyboards.)
;   Sleep