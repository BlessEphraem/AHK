;AutoGUI creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;EasyAutoGUI-AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2

if A_LineFile = A_ScriptFullPath && !A_IsCompiled
{
    myGui := Constructor()
    myGui.Show("w1609 h417")
}

Constructor()
{
    myGui := Gui()

    ; --- Rangée de fonctions (F-Keys) ---
    ButtonEsc := myGui.Add("Button", "x8 y8 w58 h59", "&Esc")
    ButtonF1 := myGui.Add("Button", "x136 y8 w58 h59", "&F1")
    ButtonF2 := myGui.Add("Button", "x200 y8 w58 h59", "&F2")
    ButtonF3 := myGui.Add("Button", "x264 y8 w58 h59", "&F3")
    ButtonF4 := myGui.Add("Button", "x328 y8 w58 h59", "&F4")
    ButtonF5 := myGui.Add("Button", "x456 y8 w58 h59", "&F5")
    ButtonF6 := myGui.Add("Button", "x520 y8 w58 h59", "&F6")
    ButtonF7 := myGui.Add("Button", "x584 y8 w58 h59", "&F7")
    ButtonF8 := myGui.Add("Button", "x648 y8 w58 h59", "&F8")
    ButtonF9 := myGui.Add("Button", "x776 y8 w58 h59", "&F9")
    ButtonF10 := myGui.Add("Button", "x840 y8 w58 h59", "&F10")
    ButtonF11 := myGui.Add("Button", "x904 y8 w58 h59", "&F11")
    ButtonF12 := myGui.Add("Button", "x968 y8 w58 h59", "&F12")

    ; --- Touches Spéciales (Haut Droit) ---
    ButtonPrintScreen := myGui.Add("Button", "x1096 y8 w58 h59", "&PrintScreen")
    ButtonScrollLock := myGui.Add("Button", "x1160 y8 w58 h59", "&ScrollLock")
    ButtonPause := myGui.Add("Button", "x1224 y8 w58 h59", "&Pause")

    ; --- Rangée des Chiffres (Haut) ---
    ButtonGrave := myGui.Add("Button", "x8 y96 w58 h59", "&²") ; Anciennement 'Button'
    Button1 := myGui.Add("Button", "x72 y96 w58 h59", "&1")
    Button2 := myGui.Add("Button", "x136 y96 w58 h59", "&2")
    Button3 := myGui.Add("Button", "x200 y96 w58 h59", "&3")
    Button4 := myGui.Add("Button", "x264 y96 w58 h59", "&4")
    Button5 := myGui.Add("Button", "x328 y96 w58 h59", "&5")
    Button6 := myGui.Add("Button", "x392 y96 w58 h59", "&6")
    Button7 := myGui.Add("Button", "x456 y96 w58 h59", "&7")
    Button8 := myGui.Add("Button", "x520 y96 w58 h59", "&8")
    Button9 := myGui.Add("Button", "x584 y96 w58 h59", "&9")
    Button0 := myGui.Add("Button", "x648 y96 w58 h59", "0")
    ButtonMinus := myGui.Add("Button", "x712 y96 w58 h59", "&-") ; Anciennement 'Button'
    ButtonEquals := myGui.Add("Button", "x776 y96 w58 h59", "&=") ; Anciennement 'Button'
    ButtonBackspace := myGui.Add("Button", "x840 y96 w185 h59", "&Backspace")

    ; --- Rangée QWERTY ---
    ButtonTab := myGui.Add("Button", "x8 y160 w81 h59", "&Tab")
    ButtonQ := myGui.Add("Button", "x96 y160 w58 h59", "&Q")
    ButtonW := myGui.Add("Button", "x160 y160 w58 h59", "&W")
    ButtonE := myGui.Add("Button", "x224 y160 w58 h59", "&E")
    ButtonR := myGui.Add("Button", "x288 y160 w58 h59", "&R")
    ButtonT := myGui.Add("Button", "x352 y160 w58 h59", "&T")
    ButtonY := myGui.Add("Button", "x416 y160 w58 h59", "Y")
    ButtonU := myGui.Add("Button", "x480 y160 w58 h59", "&U")
    ButtonI := myGui.Add("Button", "x544 y160 w58 h59", "&I")
    ButtonO := myGui.Add("Button", "x608 y160 w58 h59", "&O")
    ButtonP := myGui.Add("Button", "x672 y160 w58 h59", "&P")
    ButtonBracketL := myGui.Add("Button", "x736 y160 w58 h59", "&[") ; Anciennement 'Button'
    ButtonBracketR := myGui.Add("Button", "x800 y160 w58 h59", "&]") ; Anciennement 'Button'
    ButtonBackslash := myGui.Add("Button", "x864 y160 w161 h59", "&\") ; Anciennement 'Button'

    ; --- Rangée ASDF ---
    ButtonCapsLock := myGui.Add("Button", "x8 y224 w105 h59", "&CapsLock")
    ButtonA := myGui.Add("Button", "x120 y224 w58 h59", "&A")
    ButtonS := myGui.Add("Button", "x184 y224 w58 h59", "&S")
    ButtonD := myGui.Add("Button", "x248 y224 w58 h59", "&D")
    ButtonF := myGui.Add("Button", "x312 y224 w58 h59", "&F")
    ButtonG := myGui.Add("Button", "x376 y224 w58 h59", "&G")
    ButtonH := myGui.Add("Button", "x440 y224 w58 h59", "&H")
    ButtonJ := myGui.Add("Button", "x504 y224 w58 h59", "&J")
    ButtonK := myGui.Add("Button", "x568 y224 w58 h59", "&K")
    ButtonL := myGui.Add("Button", "x632 y224 w58 h59", "&L")
    ButtonSemicolon := myGui.Add("Button", "x696 y224 w58 h59", "&;") ; Anciennement 'Button'
    ButtonQuote := myGui.Add("Button", "x760 y224 w58 h59", "&,") ; Anciennement 'Button' (Note: text is comma, but position is quote on US layout)
    ButtonEnter := myGui.Add("Button", "x824 y224 w201 h59", "&Enter")

    ; --- Rangée ZXCV ---
    ButtonLShift := myGui.Add("Button", "x8 y288 w129 h59", "&LShift")
    ButtonZ := myGui.Add("Button", "x144 y288 w58 h59", "&Z")
    ButtonX := myGui.Add("Button", "x208 y288 w58 h59", "&X")
    ButtonC := myGui.Add("Button", "x272 y288 w58 h59", "&C")
    ButtonV := myGui.Add("Button", "x336 y288 w58 h59", "&V")
    ButtonB := myGui.Add("Button", "x400 y288 w58 h59", "&B")
    ButtonN := myGui.Add("Button", "x464 y288 w58 h59", "&N")
    ButtonM := myGui.Add("Button", "x528 y288 w58 h59", "&M")
    ButtonComma := myGui.Add("Button", "x592 y288 w58 h59", "&<") ; Anciennement 'Button' (Note: text is <)
    ButtonPeriod := myGui.Add("Button", "x656 y288 w58 h59", "&>") ; Anciennement 'Button' (Note: text is >)
    ButtonSlash := myGui.Add("Button", "x720 y288 w58 h59", "&/") ; Anciennement 'Button'
    ButtonRShift := myGui.Add("Button", "x784 y288 w241 h59", "&RShift")

    ; --- Rangée du Bas (Modifiers) ---
    ButtonLCtrl := myGui.Add("Button", "x8 y352 w73 h59", "&LCtrl")
    ButtonLWin := myGui.Add("Button", "x88 y352 w73 h59", "&LWin")
    ButtonLAlt := myGui.Add("Button", "x168 y352 w73 h59", "&LAlt")
    ButtonSpace := myGui.Add("Button", "x248 y352 w457 h59", "&F1") ; Renommé (Anciennement 'ButtonF1')
    ButtonRAlt := myGui.Add("Button", "x712 y352 w73 h59", "&RAlt")
    ButtonFN := myGui.Add("Button", "x792 y352 w73 h59", "&FN")
    ButtonAppsKey := myGui.Add("Button", "x872 y352 w73 h59", "&AppsKey")
    ButtonRCtrl := myGui.Add("Button", "x952 y352 w73 h59", "&RCtrl")

    ; --- Bloc de Navigation ---
    ButtonInsert := myGui.Add("Button", "x1096 y96 w58 h59", "&Insert")
    ButtonHome := myGui.Add("Button", "x1160 y96 w58 h59", "&Home")
    ButtonPgUp := myGui.Add("Button", "x1224 y96 w58 h59", "&PgUp")
    ButtonDelte := myGui.Add("Button", "x1096 y160 w58 h59", "&Delte")
    ButtonEnd := myGui.Add("Button", "x1160 y160 w58 h59", "&End")
    ButtonPgDn := myGui.Add("Button", "x1224 y160 w58 h59", "&PgDn")
    ButtonUp := myGui.Add("Button", "x1160 y288 w58 h59", "&Up")
    ButtonLeft := myGui.Add("Button", "x1096 y352 w58 h59", "&Left")
    ButtonDown := myGui.Add("Button", "x1160 y352 w58 h59", "&Down")
    ButtonRight := myGui.Add("Button", "x1224 y352 w58 h59", "&Right")

    ; --- Pavé Numérique (Numpad) ---
    ButtonNumLock := myGui.Add("Button", "x1352 y96 w58 h59", "&NumLock")
    ButtonNumpadDiv := myGui.Add("Button", "x1416 y96 w58 h59", "&/") ; Anciennement 'Button'
    ButtonNumpadMult := myGui.Add("Button", "x1480 y96 w58 h59", "&*") ; Anciennement 'Button'
    ButtonNumpadSub := myGui.Add("Button", "x1544 y96 w58 h59", "&-") ; Anciennement 'Button'
    ButtonNumpad7 := myGui.Add("Button", "x1352 y160 w58 h59", "&7") ; Renommé (Anciennement 'Button7')
    ButtonNumpad8 := myGui.Add("Button", "x1416 y160 w58 h59", "&8") ; Renommé (Anciennement 'Button8')
    ButtonNumpad9 := myGui.Add("Button", "x1480 y160 w58 h59", "&9") ; Renommé (Anciennement 'Button9')
    ButtonNumpadAdd := myGui.Add("Button", "x1544 y160 w58 h123", "&+") ; Anciennement 'Button'
    ButtonNumpad4 := myGui.Add("Button", "x1352 y224 w58 h59", "&4") ; Renommé (Anciennement 'Button4')
    ButtonNumpad5 := myGui.Add("Button", "x1416 y224 w58 h59", "&5") ; Renommé (Anciennement 'Button5')
    ButtonNumpad6 := myGui.Add("Button", "x1480 y224 w58 h59", "&6") ; Renommé (Anciennement 'Button6')
    ButtonNumpad1 := myGui.Add("Button", "x1352 y288 w58 h59", "&1") ; Renommé (Anciennement 'Button1')
    ButtonNumpad2 := myGui.Add("Button", "x1416 y288 w58 h59", "&2") ; Renommé (Anciennement 'Button2')
    ButtonNumpad3 := myGui.Add("Button", "x1480 y288 w58 h59", "&3") ; Renommé (Anciennement 'Button3')
    ButtonNumpadEnter := myGui.Add("Button", "x1544 y288 w58 h123", "&NumpadEnter")
    ButtonNumpad0 := myGui.Add("Button", "x1352 y352 w121 h59", "&0") ; Renommé (Anciennement 'Button0')
    ButtonNumpadDot := myGui.Add("Button", "x1480 y352 w58 h59", "&.") ; Anciennement 'Button'


    ; --- Assignation des Événements (MAINTENANT CORRECT) ---
    ; Chaque bouton a maintenant son propre .OnEvent
    ButtonEsc.OnEvent("Click", OnEventHandler)
    ButtonF1.OnEvent("Click", OnEventHandler)
    ButtonF2.OnEvent("Click", OnEventHandler)
    ButtonF3.OnEvent("Click", OnEventHandler)
    ButtonF4.OnEvent("Click", OnEventHandler)
    ButtonF5.OnEvent("Click", OnEventHandler)
    ButtonF6.OnEvent("Click", OnEventHandler)
    ButtonF7.OnEvent("Click", OnEventHandler)
    ButtonF8.OnEvent("Click", OnEventHandler)
    ButtonF9.OnEvent("Click", OnEventHandler)
    ButtonF10.OnEvent("Click", OnEventHandler)
    ButtonF11.OnEvent("Click", OnEventHandler)
    ButtonF12.OnEvent("Click", OnEventHandler)
    ButtonPrintScreen.OnEvent("Click", OnEventHandler)
    ButtonScrollLock.OnEvent("Click", OnEventHandler)
    ButtonPause.OnEvent("Click", OnEventHandler)
    ButtonGrave.OnEvent("Click", OnEventHandler)
    Button1.OnEvent("Click", OnEventHandler)
    Button2.OnEvent("Click", OnEventHandler)
    Button3.OnEvent("Click", OnEventHandler)
    Button4.OnEvent("Click", OnEventHandler)
    Button5.OnEvent("Click", OnEventHandler)
    Button6.OnEvent("Click", OnEventHandler)
    Button7.OnEvent("Click", OnEventHandler)
    Button8.OnEvent("Click", OnEventHandler)
    Button9.OnEvent("Click", OnEventHandler)
    Button0.OnEvent("Click", OnEventHandler)
    ButtonMinus.OnEvent("Click", OnEventHandler)
    ButtonEquals.OnEvent("Click", OnEventHandler)
    ButtonBackspace.OnEvent("Click", OnEventHandler)
    ButtonTab.OnEvent("Click", OnEventHandler)
    ButtonQ.OnEvent("Click", OnEventHandler)
    ButtonW.OnEvent("Click", OnEventHandler)
    ButtonE.OnEvent("Click", OnEventHandler)
    ButtonR.OnEvent("Click", OnEventHandler)
    ButtonT.OnEvent("Click", OnEventHandler)
    ButtonY.OnEvent("Click", OnEventHandler)
    ButtonU.OnEvent("Click", OnEventHandler)
    ButtonI.OnEvent("Click", OnEventHandler)
    ButtonO.OnEvent("Click", OnEventHandler)
    ButtonP.OnEvent("Click", OnEventHandler)
    ButtonBracketL.OnEvent("Click", OnEventHandler)
    ButtonBracketR.OnEvent("Click", OnEventHandler)
    ButtonBackslash.OnEvent("Click", OnEventHandler)
    ButtonCapsLock.OnEvent("Click", OnEventHandler)
    ButtonA.OnEvent("Click", OnEventHandler)
    ButtonS.OnEvent("Click", OnEventHandler)
    ButtonD.OnEvent("Click", OnEventHandler)
    ButtonF.OnEvent("Click", OnEventHandler)
    ButtonG.OnEvent("Click", OnEventHandler)
    ButtonH.OnEvent("Click", OnEventHandler)
    ButtonJ.OnEvent("Click", OnEventHandler)
    ButtonK.OnEvent("Click", OnEventHandler)
    ButtonL.OnEvent("Click", OnEventHandler)
    ButtonSemicolon.OnEvent("Click", OnEventHandler)
    ButtonQuote.OnEvent("Click", OnEventHandler)
    ButtonEnter.OnEvent("Click", OnEventHandler)
    ButtonLShift.OnEvent("Click", OnEventHandler)
    ButtonZ.OnEvent("Click", OnEventHandler)
    ButtonX.OnEvent("Click", OnEventHandler)
    ButtonC.OnEvent("Click", OnEventHandler)
    ButtonV.OnEvent("Click", OnEventHandler)
    ButtonB.OnEvent("Click", OnEventHandler)
    ButtonN.OnEvent("Click", OnEventHandler)
    ButtonM.OnEvent("Click", OnEventHandler)
    ButtonComma.OnEvent("Click", OnEventHandler)
    ButtonPeriod.OnEvent("Click", OnEventHandler)
    ButtonSlash.OnEvent("Click", OnEventHandler)
    ButtonRShift.OnEvent("Click", OnEventHandler)
    ButtonLCtrl.OnEvent("Click", OnEventHandler)
    ButtonLWin.OnEvent("Click", OnEventHandler)
    ButtonLAlt.OnEvent("Click", OnEventHandler)
    ButtonSpace.OnEvent("Click", OnEventHandler)
    ButtonRAlt.OnEvent("Click", OnEventHandler)
    ButtonFN.OnEvent("Click", OnEventHandler)
    ButtonAppsKey.OnEvent("Click", OnEventHandler)
    ButtonRCtrl.OnEvent("Click", OnEventHandler)
    ButtonInsert.OnEvent("Click", OnEventHandler)
    ButtonHome.OnEvent("Click", OnEventHandler)
    ButtonPgUp.OnEvent("Click", OnEventHandler)
    ButtonDelte.OnEvent("Click", OnEventHandler)
    ButtonEnd.OnEvent("Click", OnEventHandler)
    ButtonPgDn.OnEvent("Click", OnEventHandler)
    ButtonUp.OnEvent("Click", OnEventHandler)
    ButtonLeft.OnEvent("Click", OnEventHandler)
    ButtonDown.OnEvent("Click", OnEventHandler)
    ButtonRight.OnEvent("Click", OnEventHandler)
    ButtonNumLock.OnEvent("Click", OnEventHandler)
    ButtonNumpadDiv.OnEvent("Click", OnEventHandler)
    ButtonNumpadMult.OnEvent("Click", OnEventHandler)
    ButtonNumpadSub.OnEvent("Click", OnEventHandler)
    ButtonNumpad7.OnEvent("Click", OnEventHandler)
    ButtonNumpad8.OnEvent("Click", OnEventHandler)
    ButtonNumpad9.OnEvent("Click", OnEventHandler)
    ButtonNumpadAdd.OnEvent("Click", OnEventHandler)
    ButtonNumpad4.OnEvent("Click", OnEventHandler)
    ButtonNumpad5.OnEvent("Click", OnEventHandler)
    ButtonNumpad6.OnEvent("Click", OnEventHandler)
    ButtonNumpad1.OnEvent("Click", OnEventHandler)
    ButtonNumpad2.OnEvent("Click", OnEventHandler)
    ButtonNumpad3.OnEvent("Click", OnEventHandler)
    ButtonNumpadEnter.OnEvent("Click", OnEventHandler)
    ButtonNumpad0.OnEvent("Click", OnEventHandler)
    ButtonNumpadDot.OnEvent("Click", OnEventHandler)

    ; --- Configuration de la GUI ---
    myGui.OnEvent('Close', (*) => ExitApp())
    myGui.Title := "Window"

    OnEventHandler(Control, Info)
    {
        ; Étape 1: Récupérer le texte du bouton qui a été cliqué
        buttonText := Control.Text

        ; Étape 2: (Optionnel) Nettoyer le texte en enlevant le symbole "&"
        ; Le "&" est utilisé pour les raccourcis clavier (ex: "&F1")
        buttonText := StrReplace(buttonText, "&")

        ; Étape 3: Afficher l'info-bulle UNIQUEMENT avec ce texte
        ToolTip(buttonText)

        ; Étape 4: Garder votre timer pour que l'info-bulle disparaisse
        SetTimer(() => ToolTip(), -3000)
    }

    return myGui
}