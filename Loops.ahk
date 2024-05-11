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

    if (InStr(A_Clipboard, "open.spotify.com") && RegExMatch(A_Clipboard, "\?.*=") && !InStr(A_Clipboard, "spotify:"))
    {
        changed := true
        str := RegExReplace(A_Clipboard, "\?.*", "")
        A_Clipboard := str . "`n" . StrReplace(StrReplace(StrReplace(StrReplace(str,
            "https://", "spotify:"),
            "/", ":"),
            "open.spotify.com", ""),
            "::", ":")
    }
    else if (InStr(A_Clipboard, "cdn.discordapp.com/avatars") && RegExMatch(A_Clipboard, "webp(\?size=).*"))
    {
        changed := true
        A_Clipboard := RegExReplace(A_Clipboard, "webp(\?size=).*", "png$1" . 4096)
    }
    else if (InStr(A_Clipboard, "www.youtube.com/watch?v="))
    {
        changed := true
        A_Clipboard := StrReplace(A_Clipboard, "www.youtube.com/watch?v=", "youtu.be/")
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

    ; Monitors
    /* DISABLED UNTIL IT WORKS CORRECTLY
    static dontmove, winlist
    old := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    MouseGetPos(&x, &y)
    dontmove := false
    winlist := WinGetList()
    if (winlist.Length !== (new := WinGetList()).Length)
    {
        winlist := new
    
        for win in winlist
        {
            ; If a window's client width and height are the monitor's resolution, it's a game running in Fullscreen or Windowed Borderless
            try
            {
                WinGetClientPos(, , &w, &h, win)
                if (WinActive(win) && w == 3840 && h == 2160)
                {
                    dontmove := true
                }
            }
        }
    }
    if (y >= 1080 && y !== 2159 && (x == 0 || x == 3839))
    {
        if (!dontmove)
        {
            MouseMove(x, y / 2, 0)
        }
    }
    CoordMode("Mouse", old)
    */

    ; Dead By Daylight progress bar monitor
    static DBD_WIDTH := 0
    static DBD_HEIGHT := 0
    if (DBD_WIDTH == 0 || DBD_HEIGHT == 0)
    {
        MonitorGet(MonitorGetPrimary(), , , &DBD_WIDTH, &DBD_HEIGHT)
    }

    DBD_X1 := Floor(1671 * (DBD_WIDTH / 3840))
    DBD_Y1 := Floor(1735 * (DBD_HEIGHT / 2160))
    DBD_X2 := Floor(2262 * (DBD_WIDTH / 3840))
    PB_DBD_WIDTH := DBD_X2 - DBD_X1

    static dbdLastUpdate := A_TickCount
    static dbdRate := 0.0
    static dbdRates := []
    static dbdPrev := "0.00"
    try
    {
        if (
            (WinActive("ahk_exe DeadByDaylight-Win64-Shipping.exe"))
            && (GetKeyState("LButton", "P") || GetKeyState("E", "P") || GetKeyState("RButton", "P"))
            && PixelSearch(&cx, &cy, DBD_X1, DBD_Y1, DBD_X2, DBD_Y1, "0x3C4347", 50)    ; very high tolerance, but may improve detection rates when there actually is a progress bar being filled
        )
        {
            ; (cx, cy) is the left-most pixel of the progress bar that is _not_ filled
            percent := Round((100 * (cx - DBD_X1)) / PB_DBD_WIDTH, 2)
            c := [
                Round((90 * (cx - DBD_X1)) / PB_DBD_WIDTH, 2) . "/90`t[Gen]",
                Round((32 * (cx - DBD_X1)) / PB_DBD_WIDTH, 2) . "/32`t[Recover]",
                Round((20 * (cx - DBD_X1)) / PB_DBD_WIDTH, 2) . "/20`t[Gate]",
                Round((16 * (cx - DBD_X1)) / PB_DBD_WIDTH, 2) . "/16`t[Heal]",
                Round((14 * (cx - DBD_X1)) / PB_DBD_WIDTH, 2) . "/14`t[Totem]",
                Round((12 * (cx - DBD_X1)) / PB_DBD_WIDTH, 2) . "/12`t[S. Mend]",
                Round((8 * (cx - DBD_X1)) / PB_DBD_WIDTH, 2) . "/8`t[Mend]"
            ]

            if (percent !== dbdPrev)
            {
                ; Average only the last 10 rates, discard the older ones
                if ((n := Round((Abs(dbdPrev - percent) / ((A_TickCount - dbdLastUpdate) / 1000)), 2)) < 50)
                {
                    dbdRates.Push(n)
                }
                if (dbdRates.Length > 10)
                {
                    dbdRates.RemoveAt(1)
                }
                try dbdRate := Round(codebase.math.sum(1, dbdRates.Length, (p) => dbdRates[p]) / dbdRates.Length, 2)

                codebase.Tool(
                    codebase.stringOperations.strJoin("`n", , c*)
                    . "`n" . percent . "%"
                    . "`t@ ~" . dbdRate . "%/s",
                    codebase.Tool.coords, 400, cx, DBD_Y1 + 20
                )

                dbdPrev := percent
                dbdLastUpdate := A_TickCount
            }
        }
    }

    ; Approach 1 (WIP): Uses PixelSearch to find white pixels in the bomb timer
    static approach := 0
    if (approach == 1)
    {
        static R6BOMB_WIDTH := 0
        static R6BOMB_HEIGHT := 0
        if (R6BOMB_WIDTH == 0 || R6BOMB_HEIGHT == 0)
        {
            MonitorGet(MonitorGetPrimary(), , , &R6BOMB_WIDTH, &R6BOMB_HEIGHT)
        }

        static R6BOMB_RIGHT_X1 := Floor(1921 * (R6BOMB_WIDTH / 3840))
        static R6BOMB_RIGHT_Y1 := Floor(30 * (R6BOMB_HEIGHT / 2160))
        static R6BOMB_RIGHT_X2 := Floor(1959 * (R6BOMB_WIDTH / 3840))
        static R6BOMB_RIGHT_Y2 := Floor(114 * (R6BOMB_HEIGHT / 2160))
        static R6BOMB_LEFT_X1 := Floor(1921 * (R6BOMB_WIDTH / 3840))
        static R6BOMB_LEFT_Y1 := Floor(114 * (R6BOMB_HEIGHT / 2160))
        static R6BOMB_LEFT_X2 := Floor(1881 * (R6BOMB_WIDTH / 3840))
        static R6BOMB_LEFT_Y2 := Floor(30 * (R6BOMB_HEIGHT / 2160))
        static R6BOMB_HEIGHT_DELTA := R6BOMB_RIGHT_Y2 - R6BOMB_RIGHT_Y1
        static R6BOMB_YELLOW_X := Floor(1934 * (R6BOMB_WIDTH / 3840))
        static R6BOMB_YELLOW_Y := Floor(52 * (R6BOMB_HEIGHT / 2160))

        static R6BOMBPrev := "0.00"

        try
        {
            if (WinActive("ahk_exe RainbowSix.exe") || WinActive("ahk_exe vlc.exe"))
            {
                resultFromRight := true
                PixelSearch(&cx, &cy, R6BOMB_RIGHT_X1, R6BOMB_RIGHT_Y1, R6BOMB_RIGHT_X2, R6BOMB_RIGHT_Y2, "0xFFFFFF", 1)
                if (!cx || !cy)
                {
                    resultFromRight := false
                    PixelSearch(&cx, &cy, R6BOMB_LEFT_X1, R6BOMB_LEFT_Y1, R6BOMB_LEFT_X2, R6BOMB_LEFT_Y2, "0xFFFFFF", 1)
                }
                if ((cx >= 1912 && cx <= 1921) || (cy >= 51 && cy <= 81))
                {

                }
                OutputDebug(Format("Found ({1}, {2})`n", cx, cy))

                ; (cx, cy) is the furthest counterclockwise _filled_ pixel of the bomb timer
                percent := 100 - ((num := Abs(Floor(((cy - R6BOMB_RIGHT_Y1) / R6BOMB_HEIGHT_DELTA) * 50))) > 50 ? -num : num)
                OutputDebug(percent . "`n")

                if (percent !== R6BOMBPrev)
                {
                    codebase.Tool(
                        Round(45 * (percent / 100), 2) . "sec"
                        . "`n" . percent . "%",
                        codebase.Tool.coords, 1000, cx, cy
                    )

                    R6BOMBPrev := percent
                }

                return Sleep(0)
            }
        }
    }
    else if (approach == 2)
    {
        ; Approach 2 (broken): Checks for singular white pixels in the bomb timer area
        static r6prev := "0.00"
        static r6_radiussubconst := 3
        static indices := codebase.range(-22, 68)
        if (WinActive("ahk_exe RainbowSix.exe") || WinActive("ahk_exe vlc.exe"))
        {
            if (true)
            {
                for j in indices
                {
                    searchx := 1920 + ((41 - r6_radiussubconst) * Cos((j / 90) * 2 * codebase.math.constants.pi))
                    searchy := 72 + ((43 - r6_radiussubconst) * Sin((j / 90) * 2 * codebase.math.constants.pi))
                    codebase.Tool(c := PixelGetColor(searchx, searchy), codebase.Tool.coords, 1000, searchx, searchy)
                    if (c == "0x767676")
                    {
                        continue
                    }

                    if (codebase.convert.colors.between(c, "0xF0F0F0", "0xFFFFFF"))
                    {
                        timeleft := Round(45 * ((89 - (j + 22)) / 89), 2)
                        OutputDebug(timeleft . "sec`n")
                        if (timeleft !== r6prev)
                        {
                            r6prev := timeleft
                        }
                        break
                    }
                }
            }
        }
    }

    ; Siege progress bar monitor
    ; Always make this the last thing to do and return if there is a bomb timer, as that is more important than a progress bar
    static R6PROG_WIDTH := 0
    static R6PROG_HEIGHT := 0
    if (R6PROG_WIDTH == 0 || R6PROG_HEIGHT == 0)
    {
        MonitorGet(MonitorGetPrimary(), , , &R6PROG_WIDTH, &R6PROG_HEIGHT)
    }

    R6PROG_X1 := Floor(857 * (R6PROG_WIDTH / 1920))
    R6PROG_Y1 := Floor(628 * (R6PROG_HEIGHT / 1080))
    R6PROG_X2 := Floor(1064 * (R6PROG_WIDTH / 1920))
    PB_R6PROG_WIDTH := R6PROG_X2 - R6PROG_X1

    static R6PROGLastUpdate := A_TickCount
    static R6PROGRate := 0.0
    static R6PROGRates := []
    static R6PROGPrev := "0.00"
    try
    {
        if (
            (WinActive("ahk_exe RainbowSix.exe") || WinActive("ahk_exe vlc.exe"))
            && (GetKeyState("F", "P") || GetKeyState("MButton", "P") || GetKeyState("CapsLock", "P") || GetKeyState("LButton", "P"))
            && PixelSearch(&cx, &cy, R6PROG_X2, R6PROG_Y1, R6PROG_X1, R6PROG_Y1, "0xFFFFFF", 15)    ; very high tolerance, but may improve detection rates when there actually is a progress bar being filled
        )
        {
            ; (cx, cy) is the right-most pixel of the progress bar that _is_ filled
            percent := Round((100 * (cx - R6PROG_X1)) / PB_R6PROG_WIDTH, 2)
            c := [
                Round((7 * (cx - R6PROG_X1)) / PB_R6PROG_WIDTH, 2) . "/7`t[Defuser]",
                Round((5 * (cx - R6PROG_X1)) / PB_R6PROG_WIDTH, 2) . "/5`t[Reinforce]",
            ]

            if (percent !== R6PROGPrev)
            {
                ; Average only the last 10 rates, discard the older ones
                if ((n := Round((Abs(R6PROGPrev - percent) / ((A_TickCount - R6PROGLastUpdate) / 1000)), 2)) < 50)
                {
                    R6PROGRates.Push(n)
                }
                if (R6PROGRates.Length > 10)
                {
                    R6PROGRates.RemoveAt(1)
                }
                try R6PROGRate := Round(codebase.math.sum(1, R6PROGRates.Length, (p) => R6PROGRates[p]) / R6PROGRates.Length, 2)

                codebase.Tool(
                    codebase.stringOperations.strJoin("`n", , c*)
                    . "`n" . percent . "%"
                    . "`t@ ~" . R6PROGRate . "%/s",
                    codebase.Tool.coords, 1000, cx, R6PROG_Y1 + 15
                )

                R6PROGPrev := percent
                R6PROGLastUpdate := A_TickCount
            }
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
        "ahk_exe msedge.exe",
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
        if (!InStr(FileGetAttrib(f), "R"))
        {
            FileSetAttrib("+R", f)
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

    if (WinExist("LonelyScreen AirPlay Receiver"))
    {
        for win in WinGetList("LonelyScreen AirPlay Receiver")
        {
            WinGetPos(, , &w, &h, "LonelyScreen AirPlay Receiver")
            if (w == 422 && h == 236)
            {
                WinKill("LonelyScreen AirPlay Receiver")
            }
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

    if (WinActive("Trial Expired VideoPad Professional"))
    {
        Click("888 544")
        WinWaitActive("Register VideoPad")
        typeRegistration()
    }
    if (WinActive("Register VideoPad"))
    {
        typeRegistration()
    }

    static typeRegistration()
    {
        Send("{RAW}210870705-mnrdenzi")
        Send("{Enter}")
    }

    Sleep(0)
}

/**
 * Executes loop actions that run every 10 seconds with the highest priority (all other loop functions are interrupted by this).
 */
slowMonitor()
{
    Loop Parse FileRead("C:\Users\User\Desktop\Share\remote.txt"), "`n", "`r"
    {
        switch (StrLower(A_LoopField))
        {
            case "overwatch":
                Run("C:\Users\User\Documents\Gayms\Overwatch.lnk")
            case "dbd":
                Run("steam://rungameid/381210")
        }
    }
    FileOpen("C:\Users\User\Desktop\Share\remote.txt", "w")
}

#HotIf    ; #HotIf WinActive("ahk_group lock")
~*F8::
{
    global
    lock := !lock
}

; Autorun

GroupAdd("lock", "Sea of Thieves ahk_exe ApplicationFrameHost.exe")
GroupAdd("lock", "ahk_exe RainbowSix.exe")
GroupAdd("lock", "ahk_exe TslGame.exe")

GroupAdd("noCaps", "ahk_exe RainbowSix.exe")
GroupAdd("noCaps", "ahk_exe r5apex.exe")
GroupAdd("noCaps", "ahk_exe VALORANT-Win64-Shipping.exe")

GroupAdd("crossOverGroup", "ahk_exe RainbowSix.exe")
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
