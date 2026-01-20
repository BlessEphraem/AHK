/***********************************************************************************
 * 
 * @description A fully modulable ahk script with per application hotkeys layering.
 * @author Ephraem
 * @date 2021/05/10
 * @version 7
 * 
/**********************************************************************************/

/***********************************************************************************
                                    @Notes

-- FOR THE CORE
Need to finish "CustomDevice.ini", inside "Z:\Files\parsertest"
Need to do a layout for Premiere MacroPad
Need search about "Hotkeys" dynamic functions
Need "Keyboard Display GUI" to show a keyboard with assigned key with color, text.. Adapt for macro pad (VERY BIG WORK HERE) 

-- FOR "Premiere_Hotkeys"
Need to do a "Double Value Copy/Paste" func for pasting double values (ex: Motion/Position -> "960", "540")

***********************************************************************************/

/***********************************************************************************
                                    @Init
***********************************************************************************/

#include "C:\Users\%A_UserName%\.config\AHK\.includes.ahk"

    TraySetIcon(A_Path.SupportFiles.Icons "\deepr_Icon.png")

    if (PID := !ProcessExist("komorebi.exe"))
        CMD("komorebic start")

    if (PID := !ProcessExist("VolumeSync.exe"))
        Run "Z:\Scripts\Tools\System\VolumeSync.exe"

    #SuspendExempt

    #ESC::Run A_ScriptDir "\Launcher.ahk"

    #^!Space::
    {
        Suspend(-1)
        if (A_IsSuspended)
            SoundPlay(A_Path.SupportFiles.Sounds . "\Button1.wav")
        else
            SoundPlay(A_Path.SupportFiles.Sounds . "\Button3.wav")
    }

    #SuspendExempt False 

/***********************************************************************************
                                    @SetTimers
***********************************************************************************/

    global MsgboxTitle := "Deepr"
    global Err := MsgboxTitle " Error"

    g_AppsToPin := [
        "ahk_class ApplicationFrameWindow",
        "ahk_exe Flow.Launcher.exe",
        "ahk_class CabinetWClass",
        "ahk_class PLUGPLUG_UI_NATIVE_WINDOW_CLASS_NAME",
        Application_Class.MediaEncoder.winTitle
    ]

    g_childAppsToPin := [
        "Keyboard Shortcuts",
        "Track Fx Editor - ",
        "Clip Fx Editor - "
    ]

    SetTimer(WatchTooltip, 300)
    SetTimer(WatchError, 300)
    SetTimer((*) => WatchApp(g_AppsToPin, ), 300)
    SetTimer((*) => WatchChildApp(Application_Class.PremierePro.winTitle, g_childAppsToPin), 300)

;SetTimer((*)o => RandomFunctions() , 1000)
/***********************************************************************************
                                    @GUI
***********************************************************************************/

    GUI_Debug.Init()
    SetTimer((*) => GUI_Debug.Update() , 100) ; Check every 100 ms
    GUI_SideNote.Init()
