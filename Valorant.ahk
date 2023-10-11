#NoTrayIcon
#SingleInstance force

; Before doing anything, check if this script is running as admin. If not, try to restart with admin privileges.
; The script automatically exits if that isn't possible (e.g. the UAC dialog is answered with No)
if (!A_IsAdmin = 1)
{
    MsgBox("This instance of the VALORANT startup script is not running as admin.`nClick Yes to attempt to gain admin privileges, No to exit.", "VALORANT Startup Script", 16)
    try
    {
        if (A_IsCompiled)
            Run('*RunAs "' A_ScriptFullPath '" /restart')
        else
            Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
    }
}

if (!FileExist("valInstallSettings.txt"))
{
    ; Before asking the user, step through common locations where Riot Client Services might be
    drives := StrSplit(DriveGetList("FIXED"))
    locations := [":\Riot Games\Riot Client", ":\Program Files\Riot Games\Riot Client", ":\Program Files (x86)\Riot Games\Riot Client", ":\ProgramData\Riot Games\Riot Client", "\Riot Games\Riot Client", ":\Programs\Riot Games\Riot Client", ":\Games\Riot Games\Riot Client", ":\Users\" . A_UserName . "\Riot Games\Riot Client"]
    for k in drives
    {
        for l in locations
        {
            if (DirExist(k . l))
            {
                dsel := k . l
                MsgBox("Found the RiotClientServices executable in the following installation location:`n`n" . k . l)
            }
        }
    }

    if (DirExist(A_ProgramFiles . "\Riot Games\Riot Client"))
    {
        dsel := A_ProgramFiles . "\Riot Games\Riot Client"
        MsgBox("Found the RiotClientServices executable in the following installation location:`n`n" . dsel)
    }

    ; If there is no previously created config file, ask the user for the install path of the Riot Client, then write that into a file
    ; Finally, read the path from that file to ensure that it works
    ; That FileRead() call should *never* fail, we just created that file
    ; If it *does* fail, we've got a very big problem
    if (!IsSet(dsel))
    {
        m := "Please select the location of the < RiotClientServices.exe > file. It's probably on the drive you originally chose to install VALORANT on.`n"
            . "The path might look something like this:`nC:\Program Files\Riot Games\Riot Client\"

        dsel := DirSelect("::{20d04fe0-3aea-1069-a2d8-08002b30309d}", 0, m)
        if (dsel = "")
        {
            MsgBox("No directory has been selected or the OS refused to show the dialog.`nTo retry, open Valorant.ahk again and choose the folder.`nExiting...")
            ExitApp(1)
        }
    }

    try
    {
        FileDelete(A_ScriptDir . "\valInstallSettings.txt")
    }
    FileAppend(dsel, A_ScriptDir . "\valInstallSettings.txt")
    FileSetAttrib("+H", A_ScriptDir . "\valInstallSettings.txt")
}

; Otherwise, just read the path from the file
riotClientServices_path := FileRead("valInstallSettings.txt")

; This is a single-use script to start VALORANT.
; We first step through a number of windows that need to be closed, otherwise the game won't start.
targets := [
    "Cheat Engine",
    "Place more target window titles or other identifiers here"
]

bootstrap := true

for k in targets
{
    if (!WinExist(k))
        continue

    m := MsgBox("A process / window with name / title`n"
        . k
        . "`nis still running. VALORANT will not start with this process running.`n`nKill the process?", , 4)

    if (m = "Yes")
    {
        try
        {
            ProcessClose(WinGetPID(k))
        }
        catch
        {
            MsgBox("Couldn't kill process with name / window title`n" . k ".`nThe VALORANT launcher will not be opened.")
            bootstrap := false
        }
    }
    else
    {
        MsgBox("Not killing process with name / window title`n" . k ".`nThe VALORANT launcher will not be opened.")
        bootstrap := false
    }
}

; Finally, start the game launcher
if (bootstrap = true)
{
    SetWorkingDir(A_WinDir . "\System32")
    try
    {
        Run(riotClientServices_path . "\RiotClientServices.exe --launch-product=valorant --launch-patchline=live")
    }
    catch
    {
        if (A_LastError = 2)
        {
            try
            {
                FileDelete(A_ScriptDir . "\valInstallSettings.txt")
            }
            MsgBox("The path specified in the previously created file did not correctly point to the RiotClientServices executable.`nThe script will terminate. Upon next launch, please select its actual location.")
            ExitApp(0)
        }
        else
        {
            Run(A_ComSpec . ' /k err /winerror.h ' . A_LastError)
            MsgBox("Ran into an unknown exception while attempting to launch VALORANT. The last error code as per the OS (decimal) and error information is in the command prompt.")
        }
    }
}
else
    MsgBox("No was answered to one of the message boxes when the user was asked if a process should be killed that would prevent VALORANT from starting.`n"
        . "As a result, VALORANT will not start. The launcher won't be opened.")
