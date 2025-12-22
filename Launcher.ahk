#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir A_ScriptDir
; Ensures the working directory is that of the AHK script

/**

    autoeditor := "C:\Users\Ephraem\Desktop\Test_2\.supportFiles\Pythons\auto-editor\bin\auto-editor.exe"
    commandeAutoEditor := "-m --help"
    RunWait A_ComSpec " /k " '"' autoeditor '"' " " commandeAutoEditor

*/

class Files {
    static mainPy := "main.py"
    static outputPath := "paths.ahk" 
    static outputIncludes := ".includes.ahk" 
}

; If one of thoses return false = Fatal Error
Launcher.Log.Toggle := false
Launcher.Check.Python(&pythonCmd)
Launcher.Check.mainPy(A_ScriptDir, Files.mainPy)
Launcher.Build(pythonCmd, Files.mainPy, Files.outputPath, Files.outputIncludes, Launcher.Log.Toggle)
ExitApp

class Launcher {

    /**
     * Handles logging to a file and provides message box configuration.
     * The LogFile path is stored statically.
     */
    class Log {
        ; Define the path for the log file
        static LogFile := "launcher.log"
        static Toggle := ""

        ; Message box parameters: [Prefix, Title, Icon]
        static Err := ["Error : ", "Error", "16"]      ; Icon 16: Stop
        static FatErr := ["Fatal Error : ", "Fatal Error", "16"] ; Icon 16: Stop
        static Warn := ["Warning : ", "Read Warning", "48"]    ; Icon 48: Warning
        static Done := ["Done : ", "Done", "64"]      ; Icon 64: Information

        /**
        * Writes a formatted message to the log file.
        * @param {string} type - The message type (e.g., "ERROR", "WARNING", "INFO").
        * @param {string} msg - The content of the message.
        * @returns {void}
        */
        static Write(type, msg) {
            if !Launcher.Log.Toggle
                return
            
            ; Format: [YYYY-MM-DD HH:MM:SS] [TYPE] Message content
            Timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
            LogEntry := "[" Timestamp "] [" type "] " msg "`n"
            try {
                FileAppend(LogEntry, Launcher.Log.LogFile)
            } catch {
                ; Cannot write to log file, maybe permission error. Fail silently.
            }
        }
    }

    class Check {

        /**
        * Checks if Python is installed and accessible via the PATH by trying common launchers.
        * Displays a message box whether Python is found or not.
        * @returns {void}
        */
        static Python(&foundCommand) {

            pythonCommands := ["python", "py", "python3"]
            foundCommand := ""
            pythonVersion := ""
            
            Launcher.Log.Write("INFO", "Starting Python check...")

            for cmd in pythonCommands { ; Try launching each check command
                Launcher.Log.Write("INFO", "Attempting to launch: " cmd " --version")
                try {
                    ; Note: RunWait does not capture stdout easily in AHK v2 without explicit redirection.
                    ; We'll assume successful execution signals Python is found.
                    cmdCompose := A_ComSpec " /c " cmd " --version"
                    Output := RunWait(cmdCompose, ,)
                    if (Output != "") { ; Output might contain the version string if redirection was used, or is just a success signal
                        foundCommand := cmd
                        Launcher.Log.Write("SUCCESS", "Python found via command: " foundCommand)
                        break ; Found, stop the loop
                    }
                } catch { ; Run failed (command not found, not in PATH) - Continue with the next command
                    Launcher.Log.Write("DEBUG", "Command '" cmd "' failed to launch or is not in PATH.")
                }
            }

            if (foundCommand != "") {
                ; The original script used the assumption that RunWait returned the version. We log success.
                resultTrue := " 🐍 Python Check OK" . "`nPython is installed and accessible via the command: " . foundCommand
                Launcher.Log.Write("DONE", resultTrue)
                return foundCommand
            } else {
                resultFalse := "Python not found" . "`nPython could not be launched with the common commands ('python', 'py', 'python3')."
                . "`nIf you are using modules that depend on Python, please ensure it is installed and its access path (PATH) is correctly configured."
                ; Added instruction to check log file
                . "`nFor more details, please check the log file: " . Launcher.Log.LogFile
                Launcher.Log.Write("FATAL_ERROR", resultFalse)
                MsgBox Launcher.Log.FatErr[1] resultFalse, Launcher.Log.FatErr[2], Launcher.Log.FatErr[3]
                return foundCommand := false
            }
        }

        static mainPy(path_ScriptDir, StartScript) {
            ScriptLocation := path_ScriptDir "\" StartScript
            if !FileExist(ScriptLocation) {
                errorMsg := "The Python script '" StartScript "' was not found in the folder '" A_ScriptDir "'"
                Launcher.Log.Write("FATAL_ERROR", errorMsg)
                MsgBox Launcher.Log.FatErr[1] errorMsg . "`nCheck the log file: " . Launcher.Log.LogFile,
                Launcher.Log.FatErr[2], Launcher.Log.FatErr[3]
                ExitApp
            } else {
                Launcher.Log.Write("INFO", "Python script found at: " ScriptLocation)
                return ScriptLocation
            }
        }

        static REGEDIT(RegPath := "", ExpectedValue := "") {
            Launcher.Log.Write("INFO", "Checking registry path: " RegPath " for expected value: " ExpectedValue)
            try { ; Read the registry value
                ActualValue := RegRead(RegPath)
                if (ActualValue == ExpectedValue) {
                    resultTrue := "Deactivation OK" . "`nThe registry key for the Office Key is correctly configured (" . RegPath . " = " . ActualValue . ")."
                    . "`n The risk of triggering Office is low."
                    Launcher.Log.Write("DONE", resultTrue)
                    return true
                } else {
                    resultFalse := "Office Key Active" . "`nThe registry key is currently: " . ActualValue
                    . "`nIt must be modified to avoid conflict with complex shortcuts (Win+Shift+Alt). "
                    . "`nThis will open the page https://m365.cloud.microsoft/?from=OfficeKey if you are not careful.`n`n"
                    . "`nYou should run the following command:`n" . "REG ADD " . RegPath . " /t REG_SZ /d " . ExpectedValue
                    ; Added instruction to check log file
                    msgBoxText := resultFalse . "`nCheck the log file: " . Launcher.Log.LogFile
                    Launcher.Log.Write("WARNING", resultFalse)
                    msgbox Launcher.Log.Warn[1] msgBoxText, Launcher.Log.Warn[2], Launcher.Log.Warn[3]
                    return false
                }
            } catch as e {
                ; Read error, most likely because the key/value does not exist.
                errorMsg := "Registry Read Error: " e.Message . "`nCould not read key: " RegPath
                . "`nThis usually means the Office Key is active or the key structure is different."
                resultFalse := "Office Key Active" . "`nIt must be modified to avoid conflict with complex shortcuts (Win+Shift+Alt). "
                . "`nThis will open the page https://m365.cloud.microsoft/?from=OfficeKey if you are not careful.`n`n"
                . "`nYou should run the following command:`n`n" . "REG ADD " . RegPath . " /t REG_SZ /d " . ExpectedValue
                ; Added instruction to check log file
                msgBoxText := resultFalse . "`nCheck the log file: " . Launcher.Log.LogFile
                Launcher.Log.Write("WARNING", errorMsg . "`nAction Required: " resultFalse)
                msgbox Launcher.Log.Warn[1] msgBoxText, Launcher.Log.Warn[2], Launcher.Log.Warn[3]
                return false
            }
        }
    }

    static Build(pythonCmd, StartScript, OutputPaths, OutputIncludes, Log := "") {

        ToggleHide := ""

        if Launcher.Log.Toggle = True {
            Log := "--log"
        } 

        Launcher.Log.Write(
            "INFO", "Starting the build process. 'Launcher.Log.Toggle' is set to true," .
            " so '--log' will be appended as an argument for main.py to enable its internal logging functionality."
            )

        command := pythonCmd " " StartScript " build " pythonCmd " " OutputPaths " " OutputIncludes " " Log

        Launcher.Log.Write("INFO", "Command: " command)
        exitCode := RunWait(command, , )
        ; RunWait returns the exit code of the launched program
        ; Passing pythonCmd as an argument to the Python script to save it in "path.ini" for easier reuse later
        ; Use the StartScript variable if you implement Python detection (see Python() function below)
        
        Launcher.Log.Write("INFO", "Build script finished with Exit Code: " exitCode)
        if (exitCode = 0) {
            successMsg := "Configuration Successful!" . "`nThe Python script finished successfully and generated 'path.ini'."
            Launcher.Log.Write("DONE", successMsg)
            return
        } else {
            errorMsg := "Configuration Failure!" . "`nThe Python script encountered an error or was canceled by the user. Exit code: " exitCode
            . "`nThe operation is canceled."
            ; Added instruction to check log file
            msgBoxText := errorMsg . "`nCheck the log file: " . Launcher.Log.LogFile
            Launcher.Log.Write("FATAL_ERROR", errorMsg)
            MsgBox Launcher.Log.FatErr[1] msgBoxText, Launcher.Log.FatErr[2], Launcher.Log.FatErr[3]
            ExitApp
        }
        return
    }

}