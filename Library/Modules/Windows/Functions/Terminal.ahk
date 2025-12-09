/**
 * @param {string} Title - The custom title for the Terminal instance (Must match the window title).
 * @param {string} Exe - The path to the terminal executable (e.g., 'wt.exe', 'wezterm-gui.exe').
 * @param {Integer} [Position=3] - Screen position (1: Top-Left, 2: Top-Right, 3: Bottom-Left, 4: Bottom-Right).
 * @param {Integer} [Width=500] - The desired width of the window.
 * @param {Integer} [Height=300] - The desired height of the window.
 * @param {Integer} [CheckInterval=300] - Timer interval in ms to check focus.
 * @param {string} [ProfilePath=""] - Optional: Path to a .ps1 profile (Only used if Exe is wt.exe).
 */
class Terminal {

    __new(title, exe, position := 3, width := 500, height := 300, checkInterval := 300, profilePath := "") {
        ; Call the initialization function
        this.Init(title, exe, position, width, height, checkInterval, profilePath)
    }

    /**
     * Initializes and positions the Terminal window.
     * @private
     * @param {string} title - The custom title for the window.
     * @param {string} exe - The path to the executable.
     * @param {Integer} position - Screen position.
     * @param {Integer} width - The desired width.
     * @param {Integer} height - The desired height.
     * @param {Integer} checkInterval - Timer interval in ms.
     * @param {string} profilePath - Load from a .ps1 file (wt.exe only).
     */
    Init(title, exe, position, width, height, checkInterval, profilePath) {
        ; 1. Enable detection of hidden windows (essential for managing the window when hidden)
        DetectHiddenWindows(true)

        ; Check if the window already exists based on the Title
        this.hwnd := WinExist(title)
        
        if (!this.hwnd) {
            ; Prepare the launch command
            runStr := ""

            ; CHECK: Is this Windows Terminal?
            if (InStr(exe, "wt.exe")) {
                ; Specific logic for Windows Terminal (Quake mode arguments)
                if (profilePath != "") {
                     ; Launch with specific profile/script
                     runStr := Format('{} -w _quake nt --title "{}" pwsh.exe -NoExit -Command "{}"', exe, title, profilePath)
                } else {
                     ; Standard PowerShell tab
                     runStr := Format('{} -w _quake nt -p "PowerShell" --title "{}"', exe, title)
                }
            } else {
                ; GENERIC LOGIC: Just run the executable for other terminals (WezTerm, Alacritty, etc.)
                ; Note: Ensure your terminal configuration sets the Window Title to match the 'title' parameter.
                runStr := exe
            }

            ; Execute the command
            try {
                Run(runStr)
            } catch as err {
                MsgBox("Failed to run executable: " . exe . "`nError: " . err.Message)
                return
            }
            
            ; Wait for the window to actually appear (timeout after 5 seconds)
            this.hwnd := WinWait(title, , 5)
            
            if (!this.hwnd) {
                MsgBox("Failed to detect the window with title: '" . title . "'.`nMake sure the terminal configuration sets this title correctly.")
                return
            }
        }

        ; 2. Retrieve the current screen resolution
        monitorWidth := A_ScreenWidth
        monitorHeight := A_ScreenHeight
        
        ; Initialize X and Y coordinates
        x := 0
        y := 0
        
        ; Calculate X and Y based on the requested Position ID
        if (position = 1) { ; Top-Left
            x := 0
            y := 0
        } else if (position = 2) { ; Top-Right
            x := monitorWidth - width
            y := 0
        } else if (position = 3) { ; Bottom-Left
            x := 0
            y := monitorHeight - height
        } else if (position = 4) { ; Bottom-Right
            x := monitorWidth - width
            y := monitorHeight - height
        } else {
            ; Default fallback: Bottom-Left (3)
            x := 0
            y := monitorHeight - height
        }

        ; 3. Ensure the window is actually visible
        WinShow("ahk_id " . this.hwnd)
        
        ; Restore if minimized (Quake behavior)
        if (WinGetMinMax("ahk_id " . this.hwnd) = -1) {
            WinRestore("ahk_id " . this.hwnd)
        }

        ; Move and resize the window using the calculated X/Y coordinates
        WinMove(x, y, width, height, "ahk_id " . this.hwnd)
        
        ; Force the window to stay on top of others and give it focus
        WinSetAlwaysOnTop(true, "ahk_id " . this.hwnd)
        WinActivate("ahk_id " . this.hwnd)

        ; Start the timer to monitor window focus (calls the 'Watch' method)
        SetTimer(this.Watch.Bind(this), checkInterval)
    }

    /**
     * Minimizes the window if it loses focus.
     * Used as a SetTimer function.
     * @private
     */
    Watch() {
        ; Ensure the window still exists
        if (!WinExist("ahk_id " . this.hwnd)) {
            ; Stop the timer if the window is gone
            SetTimer(, 0)
            return
        }

        ; Check if the window is no longer active (lost focus)
        if (WinActive("A") != this.hwnd) {
            WinMinimize("ahk_id " . this.hwnd)
            ; Stop the timer as the window is minimized
            SetTimer(, 0)
        }
    }
}