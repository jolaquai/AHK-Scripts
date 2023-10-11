#HotIf WinActive("ahk_exe RainbowSix.exe")
!F4::
{
    return
    if (MsgBox("Really kill Siege?", , 4) == "Yes")
    {
        routine("ahk_exe RainbowSix.exe")
    }
}

#HotIf
!F4::routine()

routine(target := unset)
{
    /**
     * Determines which method is used to attempt to terminate the process.
     *
     * `1` uses `WinClose()`, politely asking the program to close.
     *
     * `2` uses `ProcessClose()`, firmly requesting the program to close. This is the default and usually enough to force a process to exit.
     *
     * `3` uses `WinKill()`, which just kills the process.
     *
     * `4` uses a `taskkill` cmd call. Comparable to method `3` but even more aggressive.
     */
    mode := 2

    /**
     * Determines which method is used to attempt to terminate the process if the method specified by `mode` fails. Must be greater than `mode` or `0` to disable the fallback on failure.
     *
     * `0` disables the fallback.
     *
     * `2` uses `ProcessClose()`, firmly requesting the program to close.
     *
     * `3` uses `WinKill()`, which just kills the process.
     *
     * `4` uses a `taskkill` cmd call. Comparable to method `3` but even more aggressive.
     */
    fallback := 4

    /**
     * Whether to notify the user when the initially selected `mode` fails.
     */
    notifyOnFallback := false

    /**
     * The process to attempt and kill (the active window at Alt-F4 press).
     */
    killThis := WinGetProcessName((IsSet(target) ? target : "A"))

    /**
     * An Array of executable names that, when matching `killThis`, will prevent the kill routine from running.
     */
    doNotKill := [
        "explorer.exe",
        "bluej.exe"
    ]

    /**
     * Attempts to kill `killThis` with the passed aggressiveness level.
     * @param mode The aggressiveness level to use.
     */
    kill(mode)
    {
        switch (mode)
        {
            case 1:
                WinClose("ahk_pid " . id)
            case 2:
                ProcessClose(id)
            case 3:
                WinKill("ahk_pid " . id)
            case 4:
                MsgBox("Mode 4 : " . id)
                Run(A_ComSpec . ' /c taskkill /f /pid ' . id)
        }
    }
    
    ; Step through the processes in the doNotKill array
    for noKill in doNotKill
    {
        ; If noKill matches killThis, skip the kill routine
        if (noKill == killThis)
        {
            switch (noKill)
            {
                ; `switch` to determine actions to perform _instead_ of killing `killThis`
                ; `case`s must match entries in `doNotKill`, otherwise no matches will occur
                case "explorer.exe":
                    WinClose("ahk_exe" . killThis)
                default:
                    ; Notify the user that the kill routine was skipped and for what process
                    MsgBox("Didn't kill window with process name < " . noKill . " >!")
            }
            return
        }
    }

    ; Get the process ID of the process to kill
    id := WinGetPID("ahk_exe " . killThis)
    try
    {
        ; Attempt to kill the process
        kill(mode)
    }
    catch
    {
        ; If the initial kill attempt failed, fallback if enabled
        if (fallback)
        {
            ; Whether to notify the user on fallback usage
            if (notifyOnFallback)
            {
                MsgBox("Initial process termination method " . mode . " failed. Attempting to use fallback mode " . fallback . " now.")
            }

            ; Attempt to kill the process with the fallback method
            ; If this fails as well, all hope is lost
            kill(fallback)
        }
    }
}