#Requires AutoHotkey v2.0

class StartMenu {
    static Replace(command) {
        SendInput "{Blind}{vkE8}"
        start_time := A_TickCount
        KeyWait "LWin" or "RWin"
        time_limit := 200
        IsHold := (A_TickCount - start_time > time_limit)

        if A_PriorKey != "LWin"
            IsConflict := true
        else
            IsConflict := false

        /*
        tooltip "Hold: " IsHold "`nConflict: " IsConflict
        */

        if (IsHold = true or IsConflict = true) {
            SendInput("{Blind}{vkE8}")
            exit
        } else {
            CMD(command)
            exit
        }
    }
}