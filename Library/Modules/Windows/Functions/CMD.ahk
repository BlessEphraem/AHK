#Requires AutoHotkey v2.0



class CMD {
    __new(Args, Hide := "Hide") {
        this.__run(Args, Hide)
    }

    __run(Args, Hide := "Hide") {
        try {
            Run(Args, ,Hide)
        } catch as e {
            MsgBox("Error : " e.Message)
        }
    }
}
