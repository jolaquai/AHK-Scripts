; Import the codebase library to allow calls to some often-needed functions and more
#Include #Includes\ahk-codebase.ahk

clipProcess(type)
{
    if (WinActive("ahk_exe devenv.exe"))
    {
        return
    }

    static changed := false

    if (type !== 1 || changed)
    {
        changed := false
        return
    }

    if (InStr(A_Clipboard, "cdn.discordapp.com/avatars") && RegExMatch(A_Clipboard, "webp(\?size=).*"))
    {
        changed := true
        A_Clipboard := RegExReplace(A_Clipboard, "webp(\?size=).*", "png$1" . 4096)
    }
    else if (InStr(A_Clipboard, "www.youtube.com/watch?v="))
    {
        changed := true
        A_Clipboard := StrReplace(A_Clipboard, "www.youtube.com/watch?v=", "youtu.be/")
        A_Clipboard := RegExReplace(A_Clipboard, "&[^t][^&]+", "")
    }
    else if (InStr(A_Clipboard, "steamcommunity.com") || InStr(A_Clipboard, "store.steampowered.com"))
    {
        if (SubStr(A_Clipboard, 1, StrLen("steam://openurl/")) == "steam://openurl/")
        {
            return
        }
        else
        {
            changed := true
            A_Clipboard := "steam://openurl/" . A_Clipboard
        }
    }
}
OnClipboardChange(clipProcess)

afkCondition()
{
    global

    if (codebase.collectionOperations.orFunc(WinActive, triggers*))
    {
        if (A_TimeIdlePhysical >= requiredIdleTime
            && !GetKeyState("RButton", "P")
            && !GetKeyState("LButton", "P")
            && !GetKeyState("LAlt", "P")
            && !GetKeyState("Space", "P")
        )
        {
            Loop
            {
                try
                {
                    return WinGetProcessName("A")
                }
            }
        }
        else
        {
            return true
        }
    }
    else
    {
        return false
    }
}

sendAfk(exe := "")
{
    global

    defaultDelay := 250
    static kscount := 0

    if (exe == "GTA5.exe")
    {
        Send("{LCtrl down}")
        Send("{d down}")
    }
    else if (exe == "Mordhau-Win64-Shipping.exe")
    {
        Send("v{w down}")
        Sleep(250)
        Send("{w up}")
    }
    else if (exe == "KnockoutCity.exe")
    {
        if (Mod(kscount, 2) == 0)
        {
            ks := "{LAlt}{a up}{d down}"
        }
        else
        {
            ks := "{LAlt}{d up}{a down}"
        }
        Send(ks)
        Sleep(400 + ((kscount - 1) * 61))
        Send("ad{LAlt}")
        if (!WinActive("ahk_exe " . exe) || !afkCondition())
        {
            Send("{s up}{d up}{LAlt}")
        }
    }
    else if (exe == "Rocksmith2014.exe")
    {
        Send("{F13}")
    }
    else if (exe == "RobloxPlayerBeta.exe")
    {
        Send("{Space}")
        return

        Send("{e down}")
        Sleep(15000)
        Send("{e up}")
        return

        Send("{w down}")
        Sleep(250)
        Send("{w up}")
    }
    else if (exe == "RainbowSix.exe")
    {
        Send("{g down}")
        Sleep(1000)
        Send("{g up}{w down}")
        Sleep(defaultDelay)
        Send("{w up}{F6 down}")
        Sleep(defaultDelay)
        Send("{F6 up}")
    }
    else if (exe == "DeadByDaylight-Win64-Shipping.exe")
    {
        return
        codebase.Tool("Starting DBD's AFK...")

        Loop
        {
            breakoutDBD()

            Send("{w down}{d up}")
            Sleep(250)
            breakoutDBD()

            Send("{a down}{w up}")
            Sleep(250)
            breakoutDBD()

            Send("{s down}{a up}")
            Sleep(250)
            breakoutDBD()

            Send("{d down}{s up}")
            Sleep(250)
            breakoutDBD()
        }

        breakoutDBD()
        {
            if !WinActive("ahk_exe DeadByDaylight-Win64-Shipping.exe")
            {
                Send("{w up}{a up}{s up}{d up}{Alt up}{Tab up}")
                Exit()
            }
        }
    }
    else
    {
        Send("{w down}")
        Sleep(defaultDelay)
        Send("{w up}")
    }
}

/**
 * Executes loop actions that run as fast as the internal timer engine allows at ~1ms (interrupted by all other loop functions).
 */
fastMonitor()
{
    global
    str := ""
    static robloxWasActive := 0

    if (!doTick)
    {
        return
    }

    t := A_TimeIdlePhysical
    idletime.Value := codebase.formatMilliseconds(t, true, 1)

    if (compticks.Value !== ticks)
    {
        compticks.Value := ticks
    }
    if (ticktimer.Value !== "0")
    {
        ticktimer.Value := "0"
    }

    afk := afkCondition()
    proc := ""
    while (proc == "")
    {
        try
        {
            win := WinGetID("A")
            proc := codebase.stringOperations.strEllipsize(WinGetTitle("ahk_id " . win), 40) . "`n" . WinGetProcessName("ahk_id " . win)
        }
    }

    if (afk == false)
    {
        str := "Current process CANNOT satisfy:`n" . proc
        if (afkCond.Value !== str)
        {
            afkCond.Value := str
        }

        str := "Inactive in current process"
        if (state.Value !== str)
        {
            state.Value := str
        }

        ticks := 0
        oldAfkTick := A_TickCount
    }
    else if (afk == true)
    {
        str := "Current process CAN satisfy:`n" . proc
        if (afkCond.Value !== str)
        {
            afkCond.Value := str
        }

        str := "Ready"
        if (state.Value !== str)
        {
            state.Value := str
        }

        ticks := 0
        oldAfkTick := A_TickCount
    }
    else
    {
        str := "SATISFIED by current process:`n" . proc
        if (afkCond.Value !== str)
        {
            afkCond.Value := str
        }
        if (ticktimer.Value !== A_TickCount - oldAfkTick)
        {
            ticktimer.Value := A_TickCount - oldAfkTick
        }

        if (A_TickCount - oldAfkTick > 10000)
        {
            str := "Sending inputs..."
            if (state.Value !== str)
            {
                state.Value := str
            }

            ticks++
            sendAfk(afk)
            oldAfkTick := A_TickCount
        }
        else
        {
            str := "Ready"
            if (state.Value !== str)
            {
                state.Value := str
            }
        }
    }

    if (WinExist("ahk_exe RobloxPlayerBeta.exe"))
    {
        if (WinActive("ahk_exe RobloxPlayerBeta.exe"))
        {
            if (PixelGetColor(3266, 1712) == "D82533")
            {
                Click("3266 1712")
            }

            robloxWasActive := 0
            str := codebase.formatMilliseconds(0, true, 1)
            if (robloxAfk.Value !== str)
            {
                robloxAfk.Value := str
            }
        }
        else
        {
            if (robloxWasActive == 0)
            {
                robloxWasActive := A_TickCount
            }
            robloxAfk.Value := codebase.formatMilliseconds(A_TickCount - robloxWasActive, true, 1)

            if (A_TickCount - robloxWasActive >= 1000 * 60 * 18)
            {
                try
                {
                    oldactive := WinActive("A")
                    WinActivate(roblox)
                    WinWaitActive(roblox)
                    sendAfk("RobloxPlayerBeta.exe")
                    robloxWasActive := 0
                    str := codebase.formatMilliseconds(0, true, 1)
                    if (robloxAfk.Value !== str)
                    {
                        robloxAfk.Value := str
                    }
                    WinActivate(oldactive)
                }
            }
        }
    }
    else
    {
        robloxWasActive := 0
        str := codebase.formatMilliseconds(0, true, 1)
        if (robloxAfk.Value !== str)
        {
            robloxAfk.Value := str
        }
    }
}

disClick(obj, *)
{
    global

    ticks := 0
    oldAfkTick := A_TickCount

    if (!(doTick := !(obj.Value)))
    {
        str := "Script functionality disabled`nUncheck the box to re-enable"
        if (afkCond.Value !== str)
        {
            afkCond.Value := str
        }
    }
}

/**
 * Executes loop actions that run every 70 milliseconds (interrupts fastMonitor).
 * This should be the function to react to WinActive checks etc. as `fastMonitor` is too sensitive to accurately detect window changes after interacting with them.
 */
functions()
{
    global

    autoReahk := false
    if (autoReahk)
    {
        ahkproc := []
        for p in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
        {
            ; https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-process?redirectedfrom=MSDN
            if (InStr(p.Name, "AutoHotkey"))
            {
                ahkproc.Push(p.CommandLine)
            }
        }
        for cl, c in codebase.collectionOperations.arrayOperations.arrayIndex(ahkproc)
        {
            ; More than one identical process exists! -> reahk!
            try
            {
                if (c >= 3)
                {
                    SplitPath(A_ScriptFullPath, , &dir, , , &drv)
                    f := FileOpen('reAhk.bat', "w")
                    f.Write(drv . "`ncd " . dir . "`ntaskkill /f /im autohotkey64.exe`n`nstart AutoCorrect.ahk`nstart Loops.ahk")
                    f.Close()
                    Run('reAhk.bat')
                }
            }
        }
    }

    if (!ProcessExist("explorer.exe"))
    {
        Run("explorer.exe")
    }

    if (WinExist("ahk_exe csgo.exe"))
    {
        c := PixelGetColor(1987, 828)
        if (c == "0x5ACB5E" || c == "0x4CAF50" || c == "0x439246")
        {
            Click("1987 828")
        }
    }

    killList := [
        "Feedback Hub",
        "Steam - News",
        "Special Offers",
        "Quick Assist",
        "ahk_exe Narrator.exe"
    ]
    for win in killList
    {
        ;MsgBox("Trying to kill " . win)
        if (id := WinExist(win))
        {
            ;MsgBox("Found " . win . " with id`n" . id)
            WinKill(win)
        }
    }

    showList := [
        "R6 Analyst - Multi Monitor page",
    ]
    for win in showList
    {
        if (WinExist(win))
        {
            WinShow(win)
        }
    }

    if (
        p := WinExist("Video Call - WhatsApp")
        || p := WinExist("Voice Call - WhatsApp")
    )
    {
        WinMove(3840, 0, 1920, 1080, p)
        WinSetAlwaysOnTop(1, p)
    }

    if (WinExist("Friends") && WinExist("Add friends"))
    {
        WinGetPos(&x, &y, , , "Friends")
        WinGetPos(, , &w, , "Add friends")
        WinMove(x - w - 5, y, , , "Add friends")
    }

    if (WinActive("Shut Down Windows") && false)
    {
        if (MsgBox("Hibernate?", , 0x4) == "Yes")
        {
            DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)
        }
    }

    if (WinExist("ahk_group crossOverGroup"))
    {
        if (!ProcessExist("CrossOver.exe"))
        {
            Run("C:\Users\User\AppData\Local\Programs\crossover\CrossOver.exe")
            Sleep(10000)
            return
        }
    }

    if (WinExist("PhasmoMenu") && WinExist("Teleport"))
    {
        old := A_TitleMatchMode
        SetTitleMatchMode(3)

        wins := ["PhasmoMenu v0.3.9.3", "Player", "Ghost", "GhostInfo", "PlayerInfo", "ItemInfo", "Spawn", "Evidence", "Cash/Items/Exp", "CursedObjects", "KeyBinds ", "Teleport"]

        for n in codebase.range(2, wins.Length)
        {
            WinGetPos(&x, &y, &w, &h, wins[n - 1])
            WinMove(x + w, y, , , wins[n])
        }

        SetTitleMatchMode(old)
    }

    readOnlyFiles := [
        "C:\Users\User\Documents\My Games\Rainbow Six - Siege\51e0474f-7c98-4afc-902b-8c1367f823d0\GameSettings.ini"
    ]
    for f in readOnlyFiles
    {
        try {
            if (!InStr(FileGetAttrib(f), "R"))
            {
                FileSetAttrib("+R", f)
            }
        }
    }

    if (WinExist("ahk_exe Rocksmith2014.exe"))
    {
        if (!WinExist("Cheat Engine"))
        {
            if (!dodgedCE)
            {
                doDodge := false
                for w in rsDodgeCEtriggers
                {
                    if (WinExist(w))
                    {
                        doDodge := true
                        break
                    }
                }

                if (doDodge)
                {
                    MsgBox("One or more processes that don't want Cheat Engine running are currently open. CE will not be launched.")
                    dodgedCE := true
                }
                else
                {
                    dodgedCE := false

celoop:
                    Run("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Cheat Engine.lnk", "C:\Program Files\Cheat Engine 7.4")
                    Sleep(2500)

                    if (!WinExist("Cheat Engine") || MsgBox("Did Cheat Engine start correctly?", "Correct CE startup", "0x4 T5") == "No")
                    {
                        goto celoop
                    }
                    else
                    {
                        PostMessage(0x0112, 0xF020, , , "Cheat Engine")
                    }
                }
            }
            else
            {
                if (codebase.collectionOperations.andFunc(WinExist, rsDodgeCEtriggers*))
                {
                    dodgedCE := false
                    doDodge := false
                }
            }
        }

        if (!WinExist("ahk_exe RockSniffer.exe"))
        {
rsnloop:
            Run("E:\Programs\RockSniffer 0.4.1\RockSniffer.exe", "E:\Programs\RockSniffer 0.4.1")
            Sleep(2500)

            if (!WinExist("ahk_exe RockSniffer.exe") || MsgBox("Did RockSniffer start correctly?", "Correct RockSniffer startup", "0x4 T5") == "No")
            {
                goto rsnloop
            }
            else
            {
                PostMessage(0x0112, 0xF020, , , "ahk_exe RockSniffer.exe")
            }

            try
            {
                WinActivate("Rocksmith")
            }
        }

        rsExists := true
    }
    else if (rsExists)
    {
        if (MsgBox("Lost track of Rocksmith's process. Kill CE?", "RS closed", 4) == "Yes")
        {
            try
            {
                ProcessClose(WinGetPID("Cheat Engine"))
            }
            try
            {
                ProcessClose(WinGetPID("ahk_exe RockSniffer.exe"))
            }
        }

        rsExists := false
        doDodge := false
        dodgedCE := false
    }

    if (olExists && !WinExist("ahk_exe outlook.exe"))
    {
        olExists := false

        Run(A_ComSpec . ' /c taskkill /f /im outlook.exe')
    }
    else
    {
        if (WinExist("ahk_exe outlook.exe"))
        {
            olExists := true
        }
    }

    if (WinExist("ahk_exe sndvol.exe"))
    {
        try
        {
            WinGetPos(&searchx, &searchy, &w, &h, "ahk_exe sndvol.exe")
            if (w < 3000)
            {
                WinMove(searchx, searchy, 3000, h, "ahk_exe sndvol.exe")
            }
        }
    }

    if (WinActive("ahk_group lock"))
    {
        if (lock)
        {
            MouseMove(A_ScreenWidth / 2, A_ScreenHeight / 2, 0)
        }
    }

    if (WinActive("ahk_group noCaps") || true)
    {
        while (GetKeyState("CapsLock", "T") && !GetKeyState("CapsLock", "P"))
        {
            SetCapsLockState(false)
        }
    }

    if (DirExist("C:\Users\user\Downloads\*valorant*"))
    {
        try
        {
            DirDelete("C:\Users\user\Downloads\*valorant*")
        }
    }

    if (FileExist("C:\Users\user\Downloads\*valorant*"))
    {
        try
        {
            FileDelete("C:\Users\user\Downloads\*valorant*")
        }
    }

    Sleep(0)
}

/**
 * Executes loop actions that run every 10 seconds with the highest priority (all other loop functions are interrupted by this).
 */
slowMonitor()
{
}

#HotIf    ; #HotIf WinActive("ahk_group lock")
~*^+F8::
{
    global
    lock := !lock
}

; Autorun

GroupAdd("lock", "Sea of Thieves ahk_exe ApplicationFrameHost.exe")
GroupAdd("lock", "ahk_exe RainbowSix.exe")
GroupAdd("lock", "ahk_exe TslGame.exe")
GroupAdd("lock", "ahk_exe VALORANT-Win64-Shipping.exe")

GroupAdd("noCaps", "ahk_exe RainbowSix.exe")
GroupAdd("noCaps", "ahk_exe r5apex.exe")
GroupAdd("noCaps", "ahk_exe VALORANT-Win64-Shipping.exe")

; GroupAdd("crossOverGroup", "ahk_exe RainbowSix.exe")
GroupAdd("crossOverGroup", "ahk_exe Discovery.exe")

ProcessSetPriority("BelowNormal")

oldAfkTick := A_TickCount
ticks := 0
requiredIdleTime := 15000
doTick := true

roblox := "Roblox ahk_exe RobloxPlayerBeta.exe"

triggers := [
    "ahk_exe Mordhau-Win64-Shipping.exe",
    "ahk_exe RainbowSix.exe",
    "ahk_exe KnockoutCity.exe",
    ; "ahk_exe GTA5.exe",
    "ahk_exe csgo.exe",
    "ahk_exe bf1.exe",
    "ahk_exe DeadByDaylight-Win64-Shipping.exe",
    roblox,
    "ahk_exe Rocksmith2014.exe",
    "Sea of Thieves",
    "ahk_exe VALORANT-Win64-Shipping.exe",
    "ahk_exe starwarsbattlefrontii.exe",
    ;"Notepad",
    "ahk_exe Pandemic.exe"
]

rsDodgeCEtriggers := [
    "ahk_exe VALORANT-Win64-Shipping.exe",
    "ahk_exe RobloxPlayerBeta.exe",
    "ahk_exe csgo.exe",
    "ahk_exe FortniteClient-Win64-Shipping.exe"
]

rsExists := 0
rsAsk := true

dodgedCE := 0

olExists := 0

lock := 0

csBombTimerActive := false
csBombTimerEnd := 0

; AFK GUI
elemWidth := 300
afkgui := Gui("AlwaysOnTop", "AFK GUI")
afkgui.OnEvent("Escape", (*) => WinMinimize(afkgui.Hwnd))
afkgui.OnEvent("Close", (*) => WinMinimize(afkgui.Hwnd))

afkgui.Add("Text", "", "A_TimeIdlePhysical:")
idletime := afkgui.Add("Edit", "ReadOnly r2 w" . elemWidth, "")

afkgui.Add("Text", "", "Completed ticks:")
compticks := afkgui.Add("Edit", "ReadOnly w" . elemWidth, "")

afkgui.Add("Text", "", "Tick timer:")
ticktimer := afkgui.Add("Edit", "ReadOnly w" . elemWidth, "")

afkgui.Add("Text", "", "Script state:")
state := afkgui.Add("Edit", "ReadOnly w" . elemWidth, "")

afkgui.Add("Text", "", "AFK condition:")
afkCond := afkgui.Add("Edit", "ReadOnly w" . elemWidth . " r3", "")

afkgui.Add("Text", "", "Roblox inactivity:")
robloxAfk := afkgui.Add("Edit", "ReadOnly w" . elemWidth . " r2", "")

tempdis := afkgui.Add("CheckBox", "", "Temporarily disable script functionality")
tempdis.OnEvent("Click", disClick)

windowList := afkgui.Add("ListBox", "ReadOnly w" . elemWidth . " r" . triggers.Length, triggers)

afkgui.Add("Button", "w" . elemWidth, "Edit").OnEvent("Click", (*) => Edit())
afkgui.Add("Button", "w" . elemWidth, "Reload").OnEvent("Click", (*) => Reload())

; afkgui.Show("X5 Y5")
; WinMinimize(afkgui.Hwnd)

codebase.Tool("Reloaded Loops.ahk", true, , , 50)

if ((f := codebase.directoryOperations.getNewest("E:\YOUTUBE\Captures\Tom Clancy's Rainbow Six  Siege", true, "*.vpj")) !== "")
{
    SplitPath(f, , &dir)
    FileCreateShortcut(f, "C:\Users\user\Desktop\proj.lnk", dir)
}

prio_0 := 0
prio_1 := 1
prio_2 := 2
SetTimer(slowMonitor, 10000, prio_1)
; SetTimer(discordThemeUpdate, 10000, prio_base)
SetTimer(functions, 70, prio_2)
SetTimer(fastMonitor, 1, prio_0)