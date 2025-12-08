    /**
     * @param {string} Title - The custom title for the Windows Terminal instance.
     * @param {string} Exe - The path to the Windows Terminal executable (e.g., 'wt.exe').
     * @param {Integer} [Position=3] - Screen position (1: Top-Left, 2: Top-Right, 3: Bottom-Left, 4: Bottom-Right).
     * @param {Integer} [Width=500] - The desired width of the window.
     * @param {Integer} [Height=300] - The desired height of the window.
     * @param {Integer} [CheckInterval=300] - Timer interval in ms to check focus.
     */
class Terminal {

    __new(title, exe, position := 3, width := 500, height := 300, checkInterval := 300, profilePath := "") {
        ; Call the initialization function
        this.Init(title, exe, position, width, height, checkInterval, profilePath)
    }

    /**
     * Initializes and positions the Windows Terminal window.
     * @private
     * @param {string} Title - The custom title for the Windows Terminal instance.
     * @param {string} Exe - The path to the Windows Terminal executable (e.g., 'wt.exe').
     * @param {Integer} Position - Screen position.
     * @param {Integer} Width - The desired width of the window.
     * @param {Integer} Height - The desired height of the window.
     * @param {Integer} CheckInterval - Timer interval in ms.
     * @param {Integer} profilePath - Load from a .ps1 file.
    **/
    init(Title, Exe, Position, Width, Height, CheckInterval, profilePath) {
        ; 1. Enable detection of hidden windows (essential for Quake mode logic)
        DetectHiddenWindows True 

        ; Check if the window already exists based on the Title
        this.hwnd := WinExist(Title)
        
        if (!this.hwnd) {
            ; Prepare the launch command
            if (ProfilePath != "") {
                 ; If a profile path is provided, launch PowerShell with that specific script/profile
                 RunStr := Format('{} -w _quake nt --title "{}" powershell.exe -NoExit -Command "{}"', Exe, Title, ProfilePath)
            } else {
                 ; Otherwise, launch a standard PowerShell tab
                 RunStr := Format('{} -w _quake nt -p "PowerShell" --title "{}"', Exe, Title)
            }
            Run(RunStr)
            
            ; Wait for the window to actually appear (timeout after 5 seconds)
            this.hwnd := WinWait(Title, , 5)
            
            if (!this.hwnd) {
                MsgBox("Failed to detect the Windows Terminal window.")
                return
            }
        }

        ; Retrieve the current screen resolution
        MonitorWidth := A_ScreenWidth
        MonitorHeight := A_ScreenHeight
        
        ; Initialize X and Y coordinates
        X := 0
        Y := 0
        
        ; Calculate X and Y based on the requested Position ID
        if (Position = 1) { ; Top-Left
            X := 0
            Y := 0
        } else if (Position = 2) { ; Top-Right
            X := MonitorWidth - Width
            Y := 0
        } else if (Position = 3) { ; Bottom-Left
            X := 0
            Y := MonitorHeight - Height
        } else if (Position = 4) { ; Bottom-Right
            X := MonitorWidth - Width
            Y := MonitorHeight - Height
        } else {
            ; Default fallback: Bottom-Left (3)
            X := 0
            Y := MonitorHeight - Height
        }

        ; 2. Ensure the window is actually visible
        WinShow "ahk_id " this.hwnd
        
        ; If using Quake mode, WinRestore helps if the window was previously minimized
        if (WinGetMinMax("ahk_id " this.hwnd) = -1) {
            WinRestore "ahk_id " this.hwnd
        }

        ; Move and resize the window using the calculated X/Y coordinates
        WinMove X, Y, Width, Height, "ahk_id " this.hwnd
        
        ; Force the window to stay on top of others and give it focus
        WinSetAlwaysOnTop True, "ahk_id " this.hwnd
        WinActivate "ahk_id " this.hwnd

        ; Start the timer to monitor window focus (calls the 'Watch' method)
        SetTimer this.Watch.Bind(this), CheckInterval
    }

    /**
     * Minimizes the window if it loses focus. Used as a SetTimer function.
     * @private
     */
    watch() {
        ; Ensure the window still exists
        if (!WinExist("ahk_id " this.hwnd)) {
            ; Stop the timer if the window is gone
            SetTimer , 0
            return
        }

        ; Check if the window is no longer active
        if (WinActive("A") != this.hwnd) {
            WinMinimize "ahk_id " this.hwnd
            ; Stop the timer as the window is minimized
            SetTimer , 0
        }
    }
}

/**  Example Usage (Optional, for context)
@example 
Term := Terminal("MyCustomTerminalTitle", "wt.exe", 3, 500, 300, 300)
        ; OR
Terminal("MyCustomTerminalTitle", "wt.exe", 3, 500, 300, 300)
*/
