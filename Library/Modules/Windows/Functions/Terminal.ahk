class Terminal {

    __new(title, exe, position := 3, width := 500, height := 300, hidden := "onUnfocused", checkInterval := 300, profilePath := "") {
        ; Call the initialization function
        this.Init(title, exe, position, width, height, hidden, checkInterval, profilePath)
    }

    /**
     * Initializes and positions the Terminal window.
     * @private
     * @param {string} title - The custom title for the window.
     * @param {string} exe - The path to the executable.
     * @param {Integer} position - Screen position.
     * @param {Integer} width - The desired width.
     * @param {Integer} height - The desired height.
     * @param {string} hidden - Hiding behavior: 'onUnfocused', 'onToggle', 'onUnfocusedAndToggle', 'none'.
     * @param {Integer} checkInterval - (Unused) Kept for compatibility.
     * @param {string} profilePath - Load from a .ps1 file (wt.exe only).
     */
    Init(title, exe, position, width, height, hidden, checkInterval, profilePath) {
        ; 1. Enable detection of hidden windows
        DetectHiddenWindows(true)

        ; Check if the window already exists based on the Title
        this.hwnd := WinExist(title)
        windowExisted := this.hwnd
        
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
                ; GENERIC LOGIC
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

        ; Debounce: Ignore rapid repeated presses (<200ms)
        if (windowExisted && A_PriorHotkey = A_ThisHotkey && A_TimeSincePriorHotkey < 200) {
            return
        }

        ; Toggle Logic: If window ALREADY EXISTED and is ACTIVE -> Minimize
        if (windowExisted && (hidden = "onToggle" || hidden = "onUnfocusedAndToggle")) {
            if (WinActive("ahk_id " . this.hwnd)) {
                WinMinimize("ahk_id " . this.hwnd)
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

        ; 3. Ensure the window is actually visible and restored
        WinShow("ahk_id " . this.hwnd)
        
        if (WinGetMinMax("ahk_id " . this.hwnd) = -1) {
            WinRestore("ahk_id " . this.hwnd)
        }

        ; Move and resize
        WinMove(x, y, width, height, "ahk_id " . this.hwnd)
        
        ; Force OnTop and Activate
        WinSetAlwaysOnTop(true, "ahk_id " . this.hwnd)
        WinActivate("ahk_id " . this.hwnd)
    }
}
