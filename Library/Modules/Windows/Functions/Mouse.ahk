/**
 * @class Mouse
 * Provides static methods for interacting with the mouse position and the
 * corresponding window and control under the cursor.
 */

class Mouse {
    /**
     * Retrieves the coordinates of the mouse cursor, and the ID and control name
     * of the window under the cursor.
     *
     * **AHK 2.0 Usage:**
     * `pos := Mouse.Get()`
     * `MsgBox "Window ID: " pos.Id ", Control: " pos.Control`
     *
     * @returns {{Id: Integer, Control: String}} An object containing:
     * - `Id`: The unique ID of the window under the cursor.
     * - `Control`: The class name of the control under the cursor.
     */
    static Get() {
        MouseGetPos ,, &Id, &Control
        return { Id: Id, Control: Control }
    }

    /**
     * Attempts to set the keyboard focus to the control currently under the mouse cursor.
     * If the control cannot be found or focused (e.g., if it's not a focusable control),
     * a transient tooltip message is displayed.
     *
     * **AHK 2.0 Usage:**
     * `Mouse.FocusActive()` ; Call this to focus the control under the mouse.
     *
     * @returns {void}
     */
    static FocusActive() {
        try ControlFocus(this.Get().Control, this.Get().Id)
        catch {
            ; TimedTooltip is a placeholder for a user-defined function that displays a temporary message.
            ; A SetTimer with a negative period (-100ms) executes once after 100ms.
            Tooltip("Can't find control.", 2000)
        }
        return
    }

    class Move {

        static Pixel(Xdirection := 0, YDirection := 0 ) {
            MouseGetPos &firstX, &firstY
            MouseMove firstX + (Xdirection), firstY + (YDirection)
            return
        }

        static Monitor(maxScreens := 0) {
            MonitorCount := MonitorGetCount()

            ; Validation du paramètre
            if (maxScreens > 0 && maxScreens > MonitorCount) {
                Tooltip "ERROR : Invalid screen value set. The code will execute for each monitor instead."
                Sleep 2000
                Tooltip ""
                maxScreens := 0  ; Revenir au comportement par défaut
            }
        
            ; Si un nombre de moniteurs spécifique est demandé
            max := (maxScreens > 0) ? maxScreens : MonitorCount
        
            CoordMode("Mouse", "Screen")
            MouseGetPos(&MouseX, &MouseY)
        
            ; Trouver sur quel écran on est
            current := 0
            Loop MonitorCount {
                MonitorGet(A_Index, &MonitorLeft, &MonitorTop, &MonitorRight, &MonitorBottom)
                if ((MouseX >= MonitorLeft) && (MouseX < MonitorRight) && (MouseY >= MonitorTop) && (MouseY < MonitorBottom)) {
                    current := A_Index
                    currentRX := (MouseX - MonitorLeft) / (MonitorRight - MonitorLeft)
                    currentRY := (MouseY - MonitorTop) / (MonitorBottom - MonitorTop)
                    break
                }
            }
        
            ; Calcul de l'écran suivant
            next := current + 1
            if (next > max)
                next := 1
        
            ; Aller au centre du moniteur suivant
            MonitorGet(next, &MonitorLeft, &MonitorTop, &MonitorRight, &MonitorBottom)
            newX := (MonitorLeft + MonitorRight) / 2
            newY := (MonitorTop + MonitorBottom) / 2

            ; Déplacement souris
            DllCall("SetCursorPos", "int", newX, "int", newY)
            Sleep 10
        }
    }

    /**
    * Restricts or frees the mouse cursor's movement.
    * If 'rect' is provided, the cursor is confined to that screen rectangle.
    * If 'rect' is omitted, all cursor restrictions are removed.
    *
    * @param {Map | unset} [rect] An optional object (Map) with screen coordinates:
    * { x1: number, y1: number, x2: number, y2: number }.
    * 'x1' and 'y1' define the top-left corner.
    * 'x2' and 'y2' define the bottom-right corner.
    * If this parameter is not set, the cursor will be unclipped.
    * @returns {number} A non-zero value if successful, or zero if it fails.
    */
    static ClipCursor(rect := unset) {
        ; Check if the optional 'rect' parameter was provided
        if IsSet(rect) {
            ; A Windows RECT structure has 4 32-bit integers (left, top, right, bottom)
            ; 4 * 4 bytes = 16 bytes
            buf := Buffer(16)

            ; Populate the buffer with the rectangle's coordinates
            NumPut("int", rect.x1, buf, 0)  ; RECT.left
            NumPut("int", rect.y1, buf, 4)  ; RECT.top
            NumPut("int", rect.x2, buf, 8)  ; RECT.right
            NumPut("int", rect.y2, buf, 12) ; RECT.bottom

            ; Call the API to clip the cursor, passing a pointer to our RECT buffer
            return DllCall("ClipCursor", "ptr", buf)
        } else {
            ; The 'rect' parameter was not provided
            ; Passing a NULL pointer (0) to ClipCursor unclips the cursor.
            return DllCall("ClipCursor", "ptr", 0)
        }
    }
}