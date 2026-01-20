#Requires AutoHotkey v2.0

/**
 * @Simple_Press -> Right Click
 * @Double_Press -> Open the right click windows menu and press "{l}" to navigate on "Label".
 *                 be carefull using it, don't work on subtitles tracks.
 * @Hold         -> Move playhead to mouse
 * @On_release   -> If it was "Hold", Focus the panel under mouse
 */
RButton::{
    ActionsExecuted := HandleKeyGestures(PressedHotkey, Open_Label, Playhead_ToMouse, Panel_UnderMouse)
    GUI_Debug.ReturnDebug "{RButton}", "HandleKeyGestures() -> " ActionsExecuted, true
}

/***********************************************************************************
                                                  @FUNCTIONS
***********************************************************************************/

    PressedHotkey := [(Actions) => SendInput("{" ThisHotkey := CleanHotkey() "}")]

    Panel_UnderMouse := [(Actions) => (Mouse.FocusActive())]

    Playhead_ToMouse := [(Actions) => SendInput(Premiere.PlayheadToMouse)]

    Open_Label := [ 
          (Actions) => (
              BlockInput("On") 
              SendInput(Resolve.SearchMenu)
              Sleep(65)
              SendText("Set Clip Color ")
              BlockInput("Off")
          )
    ]
