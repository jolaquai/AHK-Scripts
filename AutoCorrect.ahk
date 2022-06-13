; Import the codebase library to allow calls to some often-needed functions and more
#Include #Includes\ahk-codebase.ahk
#Include #Includes\siege.ahk
codebase.Tool("Reloaded AutoCorrect.ahk", codebase.Tool.center, , , 15)

; Function / Variable / Object / Class Declarations

; ~This was first intended to be a class, but AHKv2 doesn't support using methods as SetTimer() callback functions (they are of course still function objects in the usual sense, but passing them as inputs to other functions doesn't work), which makes implementation as I intended impossible. This is likely due to AHKv2 not having any "guarantee" that the method's function object is still valid when the callback is attempted to be executed.~
; Turns out, though, I'm just fucking retarded and didn't know about ObjBindMethod(), so it _does_ work exactly as I wanted.
codebase.directoryOperations.DirectoryMonitor("E:\YOUTUBE\Captures\Tom Clancy's Rainbow Six  Siege", 1000)
codebase.directoryOperations.DirectoryMonitor("E:\YOUTUBE\Captures\Counter-strike  Global Offensive", 1000)
codebase.directoryOperations.DirectoryMonitor("E:\YOUTUBE\Captures\Overwatch", 1000)

/**
 * A `Rapidvar` is basically a counter with a specific maximum value. Its _current_ value's intended use is to influence the behavior of a game's hotkeys.
 *
 * The name `Rapidvar` is a reference to "rapid firing" semi-automatic guns by making a game hotkey spam the left mouse button only if that game's `Rapidvar` is equal to some value, which is the entire reason I created `Rapidvar`s. Despite this, I've since found other use cases, such as creating a "single fire" mode for any weapon. Its uses beyond as a toggle switch for specific hotkey behaviors are rather limited.
 * @note While every `Rapidvar` has a maximum value defined at instantiation, it is not guaranteed that its current value is within the range `[0, Rapidvar.max]` as the `set()` method does not enforce the limit to allow for temporary values. This also avoids having to cycle between all _possible_ values of a `Rapidvar` to achieve a specific state. To ensure the current value stays within that range, either call the `inc()` or `dec()` methods, or use `safeset()`.
 */
class Rapidvar
{
    /**
     * Instantiate a `Rapidvar`.
     * @param shorthand A short identifier to identify this `Rapidvar` with.
     * @param max The maximum value to allow the `Rapidvar` to assume. Defaults to `1` if omitted.
     * @param po Whether to place the tooltip at prespecified coordinates (which would preferably be outside of the target window to prevent issues such as _Borderless Windowed_ mode windows covering the tooltip).
     * @returns `Rapidvar`
     */
    __New(shorthand, max := 1, po := false)
    {
        this.value := 0
        this.max := max
        this.name := shorthand . "rapid"
        this.ttp := (po ? codebase.Tool.coords : codebase.Tool.center)
        if (this.ttp == codebase.Tool.coords)
        {
            this.x := 3840
            this.y := 0
        }
    }

    x := 10
    y := 20

    /**
     * Set the current value of the `Rapidvar` regardless of the configured maximum value.
     * @param value The value to set the `Rapidvar` to.
     * @returns The new value of the `Rapidvar`.
     */
    set(value)
    {
        this.value := value

        codebase.Tool(this.name . " switched to " . this.value, this.ttp, , this.x, this.y)
        return this.value
    }

    /**
     * Safely set the current value of the `Rapidvar`, ensuring that it stays within the range `[0, Rapidvar.max]`.
     * @param value The potential value to set the `Rapidvar` to.
     * @returns The new value of the `Rapidvar`. May not be equal to `value`.
     */
    safeset(value) => this.set(Abs(Mod(value, this.max + 1)))

    /**
     * Check whether the `Rapidvar`'s current value is equal to a specific value or at least one of a series of values.
     * @param anyof Any number of numerical values to check against.
     * @note If no arguments are passed, the return value is the current value of the `Rapidvar`.
     * @returns `true` if the `Rapidvar`'s value is equal to any of the passed values, `false` otherwise.
     */
    is(anyof*)
    {
        if (!(anyof.Length))
        {
            return this.value
        }

        for v in anyof
        {
            if (this.value == v)
            {
                return true
            }
        }
        return false
    }

    /**
     * Get the current value of the `Rapidvar`.
     * @returns The current value of the `Rapidvar`.
     */
    get() => this.value

    /**
     * Increase the current value of the `Rapidvar`.
     * @returns The new value of the `Rapidvar`.
     */
    inc() => this.safeset(this.value + 1)

    /**
     * Decrease the current value of the `Rapidvar`.
     * @returns The new value of the `Rapidvar`.
     */
    dec() => this.safeset(this.value - 1)

    /**
     * Get the maximum value of the `Rapidvar`.
     * @returns The maximum value of the `Rapidvar`.
     */
    getMax() => this.max

    /**
     * Set the new maximum value of the `Rapidvar`.
     * @param max The new maximum.
     * @returns The new maximum value of the `Rapidvar`.
     */
    setMax(max) => this.max := max
}

dbdrapid := Rapidvar("dbd")
siegerapid := Rapidvar("siege")
extractionrapid := Rapidvar("extraction", , true)
acorapid := Rapidvar("aco")
csrapid := Rapidvar("cs")
hlrapid := Rapidvar("hl")
wsrapid := Rapidvar("ws")
strapid := Rapidvar("st")
rbrapid := Rapidvar("rb", 3)
mcrapid := Rapidvar("mc")
krrapid := Rapidvar("kr")
sfrapid := Rapidvar("sf")
fnrapid := Rapidvar("fn")
owrapid := Rapidvar("ow")
apexrapid := Rapidvar("apex")

robloxSwitchKeys := [
    "~*XButton2",
    "~*e",
    "~*q"
]
for k in robloxSwitchKeys
    Hotkey(k, hkfunc)

; "Actual" AutoCorrect

:*?:paly::play
:*?:cuase::cause
:?:amke::make
:?:maek::make
:*?:quiten::quinten
:*?:fukc::fuck
:*?:fuckign::fucking
:*?:schalf::schlaf
:*?:chrous::chorus
:*?:imapct::impact
:*?:mathc::match
:*?:macth::match
:*?:besesr::besser
:*?:nciht::nicht

:*?:in frage stellen::infrage stellen
:*?:infragestellen::infrage stellen
:*?:infragezustellen::infrage zu stellen
:*?:in frage zu stellen::infrage zu stellen
:?:in frage::infrage
:?*:immernoch::immer noch

:*?:you#::you'
:*?:it#::it'
:*?:they#::they'
:*?:e#::e'

:*?:~c~::ç
:*?:/l/::ł
:*?:a__e::æ

; :*?:>`:§::>:3
; :*?:<`:§::>:3
; :*?:<`:3::>:3
; :*?:>;§::>;3
; :*?:<;§::>;3
; :*?:<;3::>;3

; "On-Purpose" AutoCorrect aka. Symbols

; Greek letters
; The uppercase character is inserted instead if just the 'g' in gr_alpha, for example, is capitalized. Or just capitalize the entire thing.
;   lowercase     ; uppercase
  :*?:gr_alpha::α ; Α
   :*?:gr_beta::β ; Β
  :*?:gr_gamma::γ ; Γ
  :*?:gr_delta::δ ; Δ
:*?:gr_epsilon::ε ; Ε
   :*?:gr_zeta::ζ ; Ζ
    :*?:gr_eta::η ; Η
  :*?:gr_theta::θ ; Θ
   :*?:gr_iota::ι ; Ι
  :*?:gr_kappa::κ ; Κ
 :*?:gr_lambda::λ ; Λ
     :*?:gr_mu::μ ; Μ
     :*?:gr_nu::ν ; Ν
     :*?:gr_xi::ξ ; Ξ
:*?:gr_omicron::ο ; Ο
     :*?:gr_pi::π ; Π
    :*?:gr_rho::ρ ; Ρ
  :*?:gr_sigma::σ ; Σ
    :*?:gr_tau::τ ; Τ
:*?:gr_upsilon::υ ; Υ
    :*?:gr_phi::φ ; Φ
    :*?:gr_chi::χ ; Χ
    :*?:gr_psi::ψ ; Ψ
  :*?:gr_omega::ω ; Ω

; Music
:*?:mus_b:: {Left}♭+{Right}
:*?:mus_flat:: {Left}♭+{Right}
:*?:mus_#:: {Left}♯+{Right}
:*?:mus_sharp:: {Left}♯+{Right}
:*?:mus_cent::¢

; Arrows
:*?:arr_r::→
:*?:arr_fat_r::⇒

:*?:arr_l::←
:*?:arr_fat_l::⇐

:*?:arr_d::↓
:*?:arr_fat_d::⇓

:*?:arr_u::↑
:*?:arr_fat_u::⇑

:*?:arr_ul::↖
:*?:arr_ur::↗
:*?:arr_dr::↘
:*?:arr_dl::↙

:*?:arr_double_l::↔
:*?:arr_double_r::↔
:*?:arr_double_d::↕
:*?:arr_double_u::↕

; Math
:*?:math_approx::≈
:*?:math_neq::≠
:*?:math_corr::≙
:*?:math_est::≙

:*?:math_diameter::Ø
:*?:math_average::Ø

:*?:math_elementof::∈
:*?:math_notelementof::∉

:*?:math_inf::∞

:*?:math_xor::⊕

:*?:math_plusminus::±
:*?:math_times_dot::∙
:*?:math_times_cross::×
:*?:math_div::÷
:*?:math_sqrt::√

:*?:math_lt::<
:*?:math_le::≤
:*?:math_gt::>
:*?:math_ge::≥

; Insert character from Unicode code
:*?:\u+::
{
    ih := InputHook("V L4", "{NumpadEnter}{Escape}")
    codebase.Tool("Waiting for Unicode char code...", codebase.Tool.center)
    ih.Start()
    ih.Wait()
    ih.Stop()
    if (ih.EndReason == "EndKey" && ih.EndKey == "Escape")
    {
        codebase.Tool("Input terminated through Escape, exiting...", codebase.Tool.center)
        return
    }
    n := codebase.convert.HexToDec(StrUpper(ih.Input))
    Send("{Backspace " . StrLen(ih.Input) + (ih.EndReason == "EndKey" ? 1 : 0) . "}" . (A_Clipboard := Chr(n)))
}

:*?:symb_identify::
{
    ih := InputHook("V", "{NumpadEnter}{Escape}")
    codebase.Tool("Waiting for Unicode char code...", codebase.Tool.center)
    ih.Start()
    ih.Wait()
    ih.Stop()
    if (ih.EndReason == "EndKey" && ih.EndKey == "Escape")
    {
        codebase.Tool("Input terminated through Escape, exiting...", codebase.Tool.center)
        return
    }
    Send("{Backspace " . StrLen(ih.Input) + 1 . "}")
    A_Clipboard := ""
    for x in StrSplit(ih.Input)
    {
        ; -> U+HEX/DEC
        n := StrReplace(codebase.convert.DecToHex(Ord(x), 4), "0x", "") . "/" . Ord(x)
        A_Clipboard := codebase.stringOperations.strJoin("`n", true, A_Clipboard, n)
        Send("U{+}" . n . " ")
    }
}
:*?:U+::
{
    input := InputBox().Value
    str := ""
    for x in StrSplit(input)
    {
        ; -> U+HEX/DEC
        n := "U+" . StrReplace(codebase.convert.DecToHex(Ord(x), 4), "0x", "") . "/" . Ord(x)
        str := codebase.stringOperations.strJoin(" ", true, str, n)
    }
    InputBox(, , , str)
}

; Misc. symbols
:*?:symb_checkmark::✓
:*?:symb_lightning::↯
:*?:symb_heart::♥
:*?:symb_bul_empty::◦
:*?:symb_bul_fill::•
:*?:symb_tm::™
:*?:symb_fullblock::█
:*?:symb_square::■
:*?:symb_death::♰

:*?:symb_em::—
:*?:symb_en::–

; Rarely needed
:*?:symb_tab::`t
:*?:symb_newline::`n
:*?:symb_nl::`n
:*?:symb_linefeed::`n
:*?:symb_lf::`n
:*?:symb_carriagereturn::`r
:*?:symb_cr::`r

; Accented letters
:*?:/o/::ø
:*?:~a~::ã
:*?:~n~::ñ
:*?:,c,::ç
; :*?:°a°::å
:*?:_o_::ō

; Abbreviations / AutoComplete
:*?:tottfiy`:::The Only Thing They Fear Is You
:*?:kod`:::Knightrider of Doom
:*?:bspw`:::beispielsweise
:*?:mglw`:::möglicherweise
:*?:wahrver`:::wahrscheinlichkeitsverteilung
:*?:binver`:::binomialverteilung
:*?:dnd`:::do-not-disturb

:?:@Paul::@₱₳ɄⱠ

; Emojis
#HotIf !WinActive("ahk_exe discord.exe")
:*?:`:sparkle`:::✨
:*?:`:wink`:::😉
:*?:`:moon`:::🌚
:*?:`:sunglasses`:::😎
:*?:`:ok_hand`:::👌
:*?:`:sweat_smile`:::😅
:*?:`:shruggie`:::¯\_(ツ)_/¯
:*?:`:smirk`:::😏
:*?:`:joy`:::😂
:*?:`:pleading`:::🥺
:*?:`:puppy_eyes`:::🥺
:*?:`:upside_down`:::🙃
:*?:`:thumbs_up`:::👍
:*?:`:sad`:::😔
:*?:`:drooling`:::🤤
:*?:`:innocent`:::😇
:*?:`:heart_eyes`:::😍
~X & WheelUp::Send("{LAlt down}{PgDn}{LAlt Up}")

; Surround symbols
#HotIf !WinActive("ahk_exe Code.exe")
    && !WinActive("ahk_exe discord.exe")
    >+SC00D::
    {
        window := WinActive("A")

        string := InputBox("Input between one and three options to surround the selection with or insert, separated by a space.`nZero or more than three options causes the thread to exit here.")
        symbols := StrSplit(string.Value, A_Space)

        if (symbols.Length == 1)
        {
            WinActivate(window)
            WinWaitActive(window)
            surroundSymbols(symbols[1])
        }
        else if (symbols.Length == 2)
        {
            WinActivate(window)
            WinWaitActive(window)
            surroundSymbols(symbols[1], symbols[2])
        }
        else if (symbols.Length == 3)
        {
            WinActivate(window)
            WinWaitActive(window)
            surroundSymbols(symbols[1], symbols[2], symbols[3])
        }
        else
        {
            Exit(1)
        }

        /*
         * Send the actual inputs.
         * @param leftSymbol The left symbol to insert.
         * @param rightSymbol The right symbol to insert. Defaults to `leftSymbol` if omitted.
         * @param moveLeft The amount of left movements to make. Defaults to `StrLen(rightSymbol)` if omitted.
         */
        surroundSymbols(leftSymbol, rightSymbol := unset, moveLeft := unset)
        {
            if (!IsSet(rightSymbol))
            {
                rightSymbol := leftSymbol
            }
            
            if (!IsSet(moveLeft))
            {
                moveLeft := StrLen(rightSymbol)
            }

            old := A_Clipboard
            A_Clipboard := ""

            Send("^c")
            if (ClipWait(0.25) == 0)
            {
                Send(leftSymbol . rightSymbol)
                Send("{Left " . moveLeft . "}")
            }
            else
            {
                Send(leftSymbol . A_Clipboard . rightSymbol)
            }

            A_Clipboard := old
        }
    }

; Post-autorun return call
return

; Alt-F4 Intercept and Behavior Alteration
#Include #Includes\alt-f4.ahk

; Shortcut Keys (for keyboards that do not have media buttons)
; Might have to change 'AppsKey' if it is unavailable

AppsKey & F2::Run("ribbons.scr /s")
AppsKey & F6::Send("{Media_Prev}")
AppsKey & F7::Send("{Media_Play_Pause}")
AppsKey & F8::Send("{Media_Next}")
AppsKey & F10::Send("{Volume_Down}")
AppsKey & F11::Send("{Volume_Up}")
AppsKey & F12::DllCall("powrprof\SetSuspendState", "Int", 0, "Int", 1, "Int", 0)

; Reload with Ctrl+S

#HotIf !WinActive("ahk_exe HITMAN3.exe")
    && !WinActive("ahk_exe DeadByDaylight-Win64-Shipping.exe")
    && !WinActive("ahk_exe Shipping-ThiefGame.exe")
    && !WinActive("ahk_exe javaw.exe")
    && !WinActive("ahk_exe Mafia3DefinitiveEdition.exe")
    && !WinActive("ahk_exe FarCry5.exe")
    && !WinActive("ahk_exe OLGame.exe")
    && !WinActive("ahk_exe csgo.exe")
    && !WinActive("ahk_exe re8.exe")
    && !WinActive("ahk_exe RustClient.exe")
    && !WinActive("ahk_exe LittleNightmares.exe")
    && !WinActive("ahk_exe hl2.exe")
    && !WinActive("ahk_exe NewColossus_x64vk.exe")
    && !WinActive("ahk_exe left4dead2.exe")
    && !WinActive("Roblox")
    && !WinActive("ahk_exe r5apex.exe")
    && !WinActive("ahk_exe EvilDead-Win64-Shipping.exe")
    && !WinActive("ahk_exe Aragami.exe")
~^s::
{
    ; Script duplication due to rapid reloading should be prevented by this
    Send("{Ctrl up}{s up}")
    Sleep(100)
    DetectHiddenWindows(true)
    for hwnd in WinGetList("ahk_class AutoHotkey")
    {
        if (hwnd == A_ScriptHwnd)
        {
            continue
        }
        PostMessage(0x0111, 65303, , , hwnd)
    }
    Reload()
}

; Hotkeys

#HotIf ; Context-insensitive hotkeys
    ScrollLock::
    ^ScrollLock::
    {
        SetScrollLockState(false)

        simple := true

        n := ""
        math := codebase.math
        vec := codebase.math.vectorGeometry
        prob := codebase.math.probability
        mat := codebase.math.matrixComputation

        arr := [ 
            
        ]

        if (!simple)
        {
            l := 0
            for op in siege.atkdef
            {
                if ((name := StrLen(op.nickname)) > l)
                {
                    l := name
                }
            }
            for class in [siege.attackers(), siege.defenders()]
            {
                if (A_Index == 1)
                {
                    arr.Push("[ATK]")
                }
                else
                {
                    arr.Push("`n[DEF]")
                }

                for op in class
                {
                    for w in op.primaries
                    {
                        if (w.type & siege.Weapon.types.marksmanrifle)
                        {
                            arr.Push(op.nickname . codebase.stringOperations.strSeparator(op.nickname, 4, l) . w.name)
                        }
                    }
                }
            }
        }

        if (!(arr.Length))
        {
            codebase.Tool("returned", codebase.Tool.center)
            return
        }

        n := Trim(codebase.elemsOut(arr), '`n `t`r')

        A_Clipboard := n
        MsgBox(n)
    }

    CtrlBreak::
    Pause::
    ^CtrlBreak::
    ^Pause::
    {
        SNIP := "E:\YOUTUBE\ETC DATA\Snip"

        replacepairs := Map(
            "$", "s"
        )

        artist := FileRead(SNIP . "\Snip_Artist.txt")
        track := FileRead(SNIP . "\Snip_Track.txt")

        for find, rep in replacepairs
        {
            artist := StrReplace(artist, find, rep)
            track := StrReplace(track, find, rep)
        }

        artist := StrSplit(artist, ",", " `t")[1]
        track := StrSplit(track, [" - "], " `t")[1]

        artist := StrLower(RegExReplace(artist, "[^a-zA-Z]*"))
        track := StrLower(RegExReplace(track, "[^a-zA-Z]*"))

        Run("https://www.azlyrics.com/lyrics/" . artist . "/" . track . ".html")
    }

    ^+ö::
    ranscp(a)
    {
        static n := 0
        if (IsNumber(a))
        {
            Run("https://scp-wiki.wikidot.com/scp-" . (n + a))
        }
        else
        {
            n := Random(1, 7000)
            Run("https://scp-wiki.wikidot.com/scp-" . n)
        }
    }
    ^!+ö::ranscp(0)

    ^+ä::
    {
        SNIP := "E:\YOUTUBE\ETC DATA\Snip"
        path := FileSelect("S 16", "C:\Users\User\Documents\cdlc\album.jpg", , "JPG Image (*.jpg)")
        if (path == "")
        {
            return
        }
        FileCopy(SNIP . "\Snip_Artwork.jpg", path, true)
    }

    ^+ü::
    {
        MsgBox(A_Clipboard := codebase.elemsOut(
            
        ))
    }

    ^+#::
    {
        MsgBox(A_Clipboard := codebase.elemsOut(
            
        ))
    }

    SC00D::Send("``{Space}")
    +SC00D::Send("``{Space}")
 
    ; Pixel-perfect mouse movement which literally just breaks on any but the primary monitor IF Windows's DPI scaling is set to anything but 100%
    #HotIf !WinActive("ahk_exe Code - Insiders.exe")
    NumpadDot & Numpad2::MouseMove(0, 1, 50, "R")
    NumpadDot & Numpad4::MouseMove(-1, 0, 50, "R")
    NumpadDot & Numpad6::MouseMove(1, 0, 50, "R")
    NumpadDot & Numpad8::MouseMove(0, -1, 50, "R")
    NumpadDot & Numpad7::Click()
    NumpadDot & Numpad9::Click("Right")
    #HotIf

    #!Left::WinMove(-1920, 0, 1920 / 3, 1080, "A")
    #!Right::WinMove(-1920 + (1920 / 3), 0, (1920 * (2 / 3)), 1080, "A")
    
    ^+!c::
    ^+!x::
    {
        local sep := "`n"

        old := A_Clipboard
        A_Clipboard := ""
        Send("^" . SubStr(A_ThisHotkey, -1, 1))
        ClipWait(0.25)
        if (A_Clipboard)
        {
            A_Clipboard := Trim(old, '`t ') . sep . Trim(A_Clipboard, '`t ')
            codebase.Tool("Appended!")
        }
        else
        {
            A_Clipboard := old
            codebase.Tool("Error...")
        }
    }

    ; AltGr
    <^>!ü::
    {
        elemW := 300
        chosenTime := A_Now
        MouseGetPos(&x, &y)

        /**
         * Functions returning values from open windows should operate on this handle as the WinTitle parameter `"A"` will target the GUI window instead of the previously intended target window.
         */
        window := WinActive("A")
        /**
         * Sometimes, the window to be operated on is immediately destroyed upon focus loss. Therefore, attempt to construct a winInfo object before this happens.
         */
        try
        {
            info := codebase.WinInfo(window)
        }
        catch (Error as e)
        {
            throw e
            ; return MsgBox("Failed to construct winInfo object on window handle ``" . window . "``. It was most likely closed before any info could be obtained.")
        }
        col := PixelGetColor(x, y)

        try
        {
            ;altgrgui_Exit()
        }
        Sleep(100)

        /**
         * Destroys the altgrgui's GUI window and reactivates the previously active window.
         *
         * @param * Any. These callback functions are always called with the arguments `GuiCtrlObj` and `Info`, sometimes more than this. Not allowing this function to receive arguments will cause an Error to be thrown.
         */
        altgrgui_Exit(*)
        {
            altgrgui.Hide()
            altgrgui.Destroy()
            
            /**
             * Whether to allow the reactivation of the previous window to fail.
             *
             * Specify `true` to re-throw caught Errors during reactivation of the previous window.
             *
             * Specify `false` to ignore any caught Errors.
             * This is generally preferred because there is no downside, and actually helps when dealing with windows that are immediately destroyed upon focus loss.
             */
            throwReactivationErrors := false

            try
            {
                WinActivate(window)
                WinWaitActive(window)
            }
            catch (Error as e)
            {
                if (throwReactivationErrors)
                {
                    throw e
                }
            }
        }

        altgrgui := Gui(, "altgrgui [" . info.ahk_hwnd . "]")
        altgrgui.OnEvent("Close", altgrgui_Exit)
        altgrgui.OnEvent("Escape", altgrgui_Exit)

        /**
         * Retrieves the command line of the previously active window by getting the `commandline` property of the `info` object that was constructed earlier, then sets the clipboard equal to the retrieved value. Finally calls `altgrgui_Exit()` to close the GUI window and return to the previously active window.
         *
         * @param * Any. These callback functions are always called with the arguments `GuiCtrlObj` and `Info`, sometimes more than this. Not allowing this function to receive arguments will cause an Error to be thrown.
         */
        cmdl_Click(*)
        {
            A_Clipboard := ""
            A_Clipboard := info.commandline
            if (A_Clipboard)
            {
                codebase.Tool("Copied!")
            }

            altgrgui_Exit()
        }
        cmdl := altgrgui.Add("Button", "w" . elemW, "Copy command line of active window")
        cmdl.OnEvent("Click", cmdl_Click)

        /**
         * Retrieves the executable name of the previously active window by getting the `ahk_exe` property of the `info` object that was constructed earlier, then sets the clipboard equal to the retrieved value. Finally calls `altgrgui_Exit()` to close the GUI window and return to the previously active window.
         *
         * @param * Any. These callback functions are always called with the arguments `GuiCtrlObj` and `Info`, sometimes more than this. Not allowing this function to receive arguments will cause an Error to be thrown.
         */
        exec_Click(*)
        {
            A_Clipboard := ""
            A_Clipboard := info.ahk_exe
            if (A_Clipboard)
                codebase.Tool("Copied!")

            altgrgui_Exit()
        }
        cmdl := altgrgui.Add("Button", "w" . elemW, "Copy executable name of active window")
        cmdl.OnEvent("Click", exec_Click)

        /**
         * Sets the clipboard equal to the position of and color under the cursor before the GUI window was opened. Finally calls `altgrgui_Exit()` to close the GUI window and return to the previously active window.
         *
         * @param * Any. These callback functions are always called with the arguments `GuiCtrlObj` and `Info`, sometimes more than this. Not allowing this function to receive arguments will cause an Error to be thrown.
         */
        mpos_Click(*)
        {
            A_Clipboard := ""
            A_Clipboard := codebase.stringOperations.strJoin(", ", true, x, y, col)
            if (A_Clipboard)
            {
                codebase.Tool("Copied!")
            }

            altgrgui_Exit()
        }
        mpos := altgrgui.Add("Button", "Default r2 w" . elemW, "Copy mouse position and color under`ncursor when this window was opened (Enter)")
        mpos.OnEvent("Click", mpos_Click)

        /**
         * Retrieves the chosen time from the DateTime GUI element and sets `chosenTime` equal to it.
         *
         * @param obj The GUI element object that called this function. Always passed by the calling element.
         * @param * Any. These callback functions are always called with the arguments `GuiCtrlObj` and `Info`, sometimes more than this. Not allowing this function to receive arguments will cause an Error to be thrown.
         */
        cal_Change(obj, *)
        {
            global chosenTime := obj.Value
            codebase.Tool("Changed")
        }
        cal := altgrgui.Add("DateTime", "Choose" . chosenTime . " w" . elemW, "MM/dd/yyyy    HH:mm:ss")
        cal.OnEvent("Change", cal_Change)

        /**
         * Sets the clipboard equal to the chosen date and time as a Unix timestamp. Finally calls `altgrgui_Exit()` to close the GUI window and return to the previously active window.
         *
         * @param * Any. These callback functions are always called with the arguments `GuiCtrlObj` and `Info`, sometimes more than this. Not allowing this function to receive arguments will cause an Error to be thrown.
         */
        calts_Click(*)
        {
            global chosenTime
            A_Clipboard := ""
            A_Clipboard := DateDiff(chosenTime, codebase.ahkTimeZero, "s") + (codebase.getUnixTimeUTC() - codebase.getUnixTimeLocal())
            if (A_Clipboard)
            {
                codebase.Tool("Copied!")
            }

            altgrgui_Exit()
        }
        calts := altgrgui.Add("Button", "w" . elemW, "Copy Unix time of chosen timestamp (UTC, Discord timestamp-compatible)")
        calts.OnEvent("Click", calts_Click)

        /**
         * Sets the clipboard equal to the current date and time (relative to UTC) as a Unix timestamp. Finally calls `altgrgui_Exit()` to close the GUI window and return to the previously active window.
         *
         * @param * Any. These callback functions are always called with the arguments `GuiCtrlObj` and `Info`, sometimes more than this. Not allowing this function to receive arguments will cause an Error to be thrown.
         */
        unix0ts_Click(*)
        {
            A_Clipboard := ""
            A_Clipboard := codebase.getUnixTimeUTC()
            if (A_Clipboard)
            {
                codebase.Tool("Copied!")
            }

            altgrgui_Exit()
        }
        unix0ts := altgrgui.Add("Button", "w" . elemW, "Copy current Unix time (UTC, Discord timestamp-compatible)")
        unix0ts.OnEvent("Click", unix0ts_Click)

        /**
         * Sets the clipboard equal to the chosen date and time (in the current time zone) as a Unix timestamp. Finally calls `altgrgui_Exit()` to close the GUI window and return to the previously active window.
         *
         * @param * Any. These callback functions are always called with the arguments `GuiCtrlObj` and `Info`, sometimes more than this. Not allowing this function to receive arguments will cause an Error to be thrown.
         */
        unixlts_Click(*)
        {
            A_Clipboard := ""
            A_Clipboard := codebase.getUnixTimeLocal()
            if (A_Clipboard)
            {
                codebase.Tool("Copied!")
            }
            
            altgrgui_Exit()
        }
        unixlts := altgrgui.Add("Button", "w" . elemW, "Copy current Unix time (local time)")
        unixlts.OnEvent("Click", unixlts_Click)

        /**
         * Sets the clipboard equal to the absolute value (always positive) of the difference between the chosen date and time in seconds. Finally calls `altgrgui_Exit()` to close the GUI window and return to the previously active window.
         *
         * @param * Any. These callback functions are always called with the arguments `GuiCtrlObj` and `Info`, sometimes more than this. Not allowing this function to receive arguments will cause an Error to be thrown.
         */
        tdiff_Click(*)
        {
            global chosenTime
            A_Clipboard := ""
            A_Clipboard := DateDiff(A_Now, chosenTime, "s") < 0 ? -DateDiff(A_Now, chosenTime, "s") : DateDiff(A_Now, chosenTime, "s")
            if (A_Clipboard)
            {
                codebase.Tool("Copied!")
            }
            
            altgrgui_Exit()
        }
        tdiff := altgrgui.Add("Button", "w" . elemW, "Copy difference between A_Now and chosen timestamp")
        tdiff.OnEvent("Click", tdiff_Click)

        /**
         * If ShutdownBlocker is running on the system, calls it with the `-allow` parameter per command line to allow a shutdown to be scheduled. Then calls `shutdown` per command line to schedule a shutdown of the system at the chosen timestamp. Finally calls `altgrgui_Exit()` to close the GUI window and return to the previously active window.
         *
         * @param * Any. These callback functions are always called with the arguments `GuiCtrlObj` and `Info`, sometimes more than this. Not allowing this function to receive arguments will cause an Error to be thrown.
         */
        tdiffsd_Click(*)
        {
            global chosenTime
            try
            {
                WinActivate("Shutdown Blocker")
                sdb := WinExist("Shutdown Blocker")
                Run(A_ComSpec . ' /c ' . codebase.WinInfo(sdb).processQueryResult.ExecutablePath . ' -allow')
            }

            Sleep(1000)
            
            sdtime := DateDiff(A_Now, chosenTime, "s") < 0 ? -DateDiff(A_Now, chosenTime, "s") : DateDiff(A_Now, chosenTime, "s")
            ex := RunWait('shutdown -s -t ' . sdtime)
            
            if (!ex)
            {
                MsgBox("Shutting down in`n" . codebase.formatMilliseconds(sdtime * 1000, false, 0))
            }
            else if (ex == 1190)
            {
                MsgBox("Failed to schedule a shutdown as one is already scheduled.`nCall ``shutdown -a`` to abort that one and retry.")
            }
            else ; literal last resort
            {
                RunWait(A_ComSpec . ' /k err ' . ex)
                throw Error("Failed to schedule a shutdown.")
            }
            
            altgrgui_Exit()
        }
        tdiffsd := altgrgui.Add("Button", "w" . elemW, "Shutdown at chosen timestamp")
        tdiffsd.OnEvent("Click", tdiffsd_Click)

        altgrgui.Show()
    }

    ; RShift + ß
    >+SC00C::
    {
        global

        input := ""
        patterns := []

        window := WinActive("A")

        inputgui := Gui()
        inputgui.OnEvent("Close", inputgui_Escape)
        inputgui.OnEvent("Escape", inputgui_Escape)

        inputgui_Escape(obj)
        {
            inputgui.Destroy()
            
            WinActivate(window)
            WinWaitActive(window)
            
            Exit(0)
        }
        
        inputgui.Add("Text", , "Paste text to insert.`nThis may not preserve line breaks if ill-formatted.")
        inputEdit := inputgui.Add("Edit", "r35 w500 Wantreturn")

        inputgui.Add("Text", , "Split text to new line at each occurance of this string:")
        inputSplit := inputgui.Add("Edit", "w500")

        replaceLineBreaks := inputgui.Add("CheckBox", "Checked", "Replace line breaks with the following string (e.g. text has been extracted from an image)")
        replaceString := inputgui.Add("Edit", "w500", A_Space)

        numberFormat := inputgui.Add("CheckBox", , "This is an INTEGER and should be formatted according to the following standard:")
        radEng := inputgui.Add("Radio", "Group", "English")
        radGer := inputgui.Add("Radio", "Checked", "German")

        inputgui.Add("Text", , "Replace patterns:")
        fnrlist := inputgui.Add("ListView", "w500 ReadOnly +Redraw -Multi Grid", ["Find", "Replace", "RegEx"])
        for x in codebase.range(1, fnrlist.GetCount("Col"))
        {
            fnrlist.ModifyCol(x, "150 Text")
        }
        f := inputgui.Add("Edit", "w500")
        r := inputgui.Add("Edit", "w500")
        reg := inputgui.Add("Edit", "w500")

        fnrbtn := inputgui.Add("Button", , "Add FnR pattern")
        fnrbtn.OnEvent("Click", fnrbtn_Click)
        fnrbtn_Click(*)
        {
            err := ""

            if (f.Value && !r.Value)
            {
                err := "A value for the Find text / regex pattern was given, but not for the Replace text / regex pattern."
            }
            if (!f.Value && r.Value)
            {
                err := "A value for the Replace text / regex pattern was given, but not for the Find text / regex pattern."
            }
            if (f.Value == r.Value)
            {
                err := "Find and Replace text / regex patterns inputs cannot be the same."
            }

            if (err !== "")
            {
                MsgBox("Failed to add Find-and-replace pattern.`n" . err)
                return
            }

            patterns.Push(Map(
                "find", f.Value,
                "rep", r.Value,
                "reg", (reg.Value ? true : false)
            ))

            x := patterns[patterns.Length]
            fnrlist.Add( , x["find"], x["rep"], (x["reg"] ? "true" : "false"))
            
            for x in codebase.range(1, fnrlist.GetCount("Col"))
            {
                fnrlist.ModifyCol(x, "AutoHdr Text")
            }
                
            f.Value := ""
            r.Value := ""
            reg.Value := ""
        }

        inputBtn := inputgui.Add("Button", "w100 Default", "OK")
        inputBtn.OnEvent("Click", inputBtn_Click)

        inputgui.Show()

        inputBtn_Click(*)
        {
            ; Get the values we need, then destroy the GUI object
            input := inputEdit.Value
            split := inputSplit.Value
            repLB := replaceLineBreaks.Value
            repStr := replaceString.Value

            numFormat := numberFormat.Value
            engMode := radEng.Value

            inputgui.Destroy()

            ; We've retrieved the input text, now clean it up a little
            ; Remove weird bullet point symbols
            input := StrReplace(input, "•", "")
            ; Change weird arrow to "normal" ones (broken, "" may be more than just broken *arrows*)
            ; Word usually interprets "weird" arrows as ""
            input := StrReplace(input, "", "→")
            ; Replace corrupted Office newlines by their "normal" counterparts
            input := StrReplace(input, "", "`n`n")
            ; Make all formatted quotation marks into normal ones
            ; Word will still create the appropriate ones should this tool be used to paste text in there
            input := StrReplace(input, "„", "`"")
            input := StrReplace(input, "“", "`"")
            ; Remove all indentation
            input := RegExReplace(input, "( {2,})", " ")
            input := RegExReplace(input, "(\t+)", "\t")
            ; Clean up weird "space-dash-space" constructs

            if (numFormat)
            {
                if (StrLen(input) < 25)
                {
                    ; The number is acceptably small to format without an E expression

                    ; Get some data ready
                    arr := StrSplit(input)
                    len := arr.Length
                    spt := (engMode ? "," : ".")
                    input := ""

                    ; Reverse inputted and insert the spt separator after every third digit
                    while (len - (A_Index - 1) > 0)
                    {
                        input .= arr[len - (A_Index - 1)]
                        if (Mod(A_Index, 3) == 0 && A_Index !== len)
                        {
                            input .= spt
                        }
                    }

                    ; Reverse the string again
                    input := codebase.stringOperations.strReverse(input)
                }
                else
                {
                    input := Format("{:E}", input)
                    if (engMode)
                    {
                        input := StrReplace(input, ".", ",")
                    }
                }

                ; Skip the other procedures, these don't apply to a pure integer
            }
            else
            {
                ; If the text was extracted from an image (where there are newlines (= new paragraphs) in MS Word where there shouldn't be any), replace all newlines by the specified repStr, a single space by default
                if (repLB)
                {
                    input := StrReplace(input, "`r`n", repStr)
                    input := StrReplace(input, "`r", repStr)
                    input := StrReplace(input, "`n", repStr)
                }

                if (split)
                {
                    inputtedSplit := StrSplit(input, split)
                    input := ""
                    for txt in inputtedSplit
                    {
                        input .= txt
                        if (!(A_Index == inputtedSplit.Length))
                        {
                            input .= "`n"
                        }
                    }
                }
            }

            if (input == "")
            {
                Exit(0)
            }

            WinActivate(window)
            WinWaitActive(window)

            Send("{Raw}" . input)
        }
    }

; Context-sensitive hotkeys

#HotIf WinActive("ahk_exe Code - Insiders.exe")
    NumpadDot::Send(".")

#HotIf !ProcessExist("ShareX.exe")
    PrintScreen::Send("#+s")

; Explorer
#HotIf WinActive("ahk_exe explorer.exe")
    || WinActive("ahk_exe AutoHotkey.exe")
    || WinActive("Save")
    ^Backspace::
    {
        Send("^+{Left}")
        ; Send("+{Left}")
        Send("{Backspace}")
    }

; Siege
#HotIf WinActive("ahk_exe RainbowSix.exe")
    :*?b0: ki::`:`:
    :*?b0: cu::`:`:
    :*?b0:whor::`:`:
    :*?b0:retar::`:`:

    NumpadSub::
    {
        sendstr := A_Clipboard

        sendstr := StrReplace(sendstr, '`r`n', ' ')
        sendstr := StrReplace(sendstr, '`r', ' ')
        sendstr := StrReplace(sendstr, '`n', ' ')
        sendstr := StrReplace(sendstr, '`t', ' ')
        sendstr := StrReplace(sendstr, '<', ' ')
        sendstr := StrReplace(sendstr, '>', ' ')

        Send(sendstr)
    }

    +b::siegerapid.inc()
    +m::siegerapid.set(-1)
    +v::siegerapid.set(2)

    ~LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("LButton", "P") && siegerapid.is(-1)))
            {
                break
            }

            Send("{LAlt up}{Click}")
            Sleep(10)
        }
    }

    ~RButton & LButton::
    {
        global
        Loop
        {
            if (GetKeyState("LButton", "P") && GetKeyState("RButton", "P") && siegerapid.is(1))
            {
                Send("{LAlt up}{Click}")
                Sleep(10)
            }
            else if (GetKeyState("LButton", "P") && GetKeyState("RButton", "P") && siegerapid.is(2))
            {
                Send("{Click}{LButton up}")
                break
            }
            else
            {
                break
            }
        }
    }
    
    2::
    {
        Send("{Numpad9 down}")
        Sleep(200)
        while (true)
        {
            if (GetKeyState("1", "P") || GetKeyState("XButton1", "P")) ; cancel
            {
                Sleep(200)
                Send("{Numpad9 up}")
                break
            }
            else if (GetKeyState("2", "P") || GetKeyState("LButton", "P")) ; Throw!
            {
                Send("{Numpad9 up}")
                break
            }
            Sleep(10)
        }
    }

    ~f::
    f_hold(ThisHotkey)
    {
        static fpresses := 0
        fpresses++
        
        SetTimer(exec, -200)
        exec()
        {
            if (fpresses == 2)
            {
                codebase.Tool("Double-F!", codebase.Tool.center)
                KeyWait("f")
                Sleep(50)
                Send("{f down}")
            }
            fpresses := 0
        }
    }

    ~CapsLock::
    caps_hold(ThisHotkey)
    {
        static capspresses := 0
        capspresses++
        
        SetTimer(exec, -200)
        exec()
        {
            if (capspresses == 2)
            {
                codebase.Tool("Double-Caps!", codebase.Tool.center)
                KeyWait("CapsLock")
                Sleep(50)
                Send("{CapsLock down}")
            }
            capspresses := 0
        }
    }

    F2::
    {
        pause()
        {
            if (!WinActive("ahk_exe RainbowSix.exe"))
            {
                Sleep(10000)
                return 1
            }
            return 0
        }
        enter()
        {
            if (pause())
            {
                return
            }

            Send("{Enter}")
            Sleep(1000)
        }
        ctrlClick()
        {
            if (pause())
            {
                return
            }

            ; Prone / Aufstehen -> weniger Hits?
            Send("{LControl down}")
            ; 1600x1200 !!!
            CoordMode("Mouse", "Client")
            ; "Retry"-Button
            Click("986 953")
            Click("284 783")
            CoordMode("Mouse", "Screen")
            Send("{LControl up}")
            Sleep(500)
        }
        tab()
        {
            if (pause())
            {
                return
            }

            ; Tab drücken, um schneller zum "Bonus"-Tab zu kommen, im Scoreboard ist der Retry-Button nicht sichtbar
            Send("{Tab}")
            Sleep(500)
        }

        loopStart := A_TickCount
        Loop
        {
            OutputDebug(codebase.formatMilliseconds(A_TickCount - loopStart) . " (~" . Round(((A_TickCount - loopStart) / (1000 * 60)) * 25, 2) . ")`n")
            ctrlClick()
            tab()
            Loop 5
            {
                enter()
            }
        }
    }

; Extraction
#HotIf WinActive("ahk_exe R6-Extraction.exe")
    +b::extractionrapid.inc()

    ~RButton & LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("LButton", "P") && GetKeyState("RButton", "P") && extractionrapid.is()))
            {
                break
            }

            Send("{LAlt up}{Click}")
            Sleep(10)
        }
    }

; Plague Inc. Evolved
#HotIf WinActive("Plague Inc: Evolved")
    ^LButton::Send("{LButton 2}")

; Moonscraper
#HotIf WinActive("ahk_exe Moonscraper Chart Editor.exe")
    ^d::
    {
        MouseGetPos(&x, &y)

        MouseMove(191, 900)
        Sleep(30)
        Loop 10
        {
            Click("WheelDown")
        }
        Sleep(50)
        Click("109 922")
        Sleep(50)

        MouseMove(x, y)
    }

    ~p::
    {
        KeyWait("P", "U")
        KeyWait("LButton", "D")
        KeyWait("LButton", "U")

        MouseMove(194, 820)
        Sleep(50)
        Click("194 820")

        KeyWait("Enter", "D")
        KeyWait("Enter", "U")

        Send("gy")
        MouseMove(964, 848)
    }

; Dead By Daylight
#HotIf WinActive("ahk_exe DeadByDaylight-Win64-Shipping.exe")
    NumpadSub::Send(A_Clipboard)

    NumpadAdd::
    {
        codebase.Tool("Starting hit loop...")

        Loop
        {
            breakout()

            Click("1524 1006")
            Sleep(Random(70, 130))
        }

        breakout()
        {
            if (!WinActive("ahk_exe DeadByDaylight-Win64-Shipping.exe"))
            {
                ; Send("")
                Exit()
            }
        }
    }
    
    +b::dbdrapid.inc()
    
    ~Space::
    {
        global

        Loop
        {
            if (!(GetKeyState("Space", "P") && dbdrapid.is()))
            {
                break
            }

            Send("{Space}")
            Sleep(10)
        }
    }

    !a::
    {
        codebase.Tool("Starting DBD's AFK...")

        Loop
        {
            breakout()

            Send("{w down}{d up}")
            Sleep(250)
            breakout()

            Send("{a down}{w up}")
            Sleep(250)
            breakout()

            Send("{s down}{a up}")
            Sleep(250)
            breakout()

            Send("{d down}{s up}")
            Sleep(250)
            breakout()
        }

        breakout()
        {
            if (!WinActive("ahk_exe DeadByDaylight-Win64-Shipping.exe"))
            {
                Send("{w up}{a up}{s up}{d up}{Alt up}{Tab up}")
                Exit()
            }
        }
    }

    NumpadDot::
    Numpad0::
    Numpad1::
    Numpad2::
    Numpad3::
    dbdTimer(hk)
    {
        static dbdTimerActive := false
        static dbdTimerEnd := 0
        static countup := false
        static extraTime := 0

        if (InStr(hk, "Dot"))
        {
            dbdTimerActive := false
            dbdTimerEnd := 0
            countup := false
            extraTime := 0
            return
        }
        else
        {
            if (InStr(hk, "0"))
            {
                countup := true
            }
            extraTime := SubStr(hk, -1, 1) * 10000
        }

        Loop
        {
            if (dbdTimerActive)
            {
                ToolTip((A_TickCount > dbdTimerEnd ? 1 : -1) * Abs(dbdTimerEnd - A_TickCount), -5, 5)
                if (!countup && A_TickCount > dbdTimerEnd)
                {
                    ToolTip()
                    dbdTimerActive := false
                    dbdTimerEnd := 0
                    countup := false
                    extraTime := 0
                    break
                }
            }
            else
            {
                dbdTimerActive := true
                dbdTimerEnd := A_TickCount + 59000 + extraTime
            }
        }
    }

; HITMAN 3
#HotIf WinActive("ahk_exe HITMAN3.exe")
    NumpadSub::Send("{Control down}")

; Rocksmith 2014
#HotIf WinActive("ahk_exe Rocksmith2014.exe")
    RButton::Send("{Escape}")
    Del::return

#HotIf WinActive("ahk_exe ACOdyssey.exe")
    ~Space::
    {
        global

        Loop
        {
            if (!(WinActive("ahk_exe ACOdyssey.exe") && GetKeyState("Space", "P") && acorapid.is()))
            {
                break
            }

            Send("{Space}")
            Sleep(10)
        }
    }

    +b::acorapid.inc()

; PowerPoint
#HotIf WinActive("ahk_exe powerpnt.exe")
    <^>!e::
    {
        MouseGetPos(&x, &y)
        Click("150 15")
        MouseMove(x, y)
        Send("^i")
    }
    >^ö::
    {
        Send("{End}{Delete}+{Enter}")
    }

; Word
#HotIf WinActive("ahk_exe winword.exe")
    <^>!e::
    {
        MouseGetPos(&x, &y)
        Click("192 15")
        MouseMove(x, y)
    }

    >^NumpadSub::
    {
        i := InputBox("Insert base sequence to translate.")

        if (i.Result == "Cancel")
        {
            Exit(0)
        }
        
        r := i.Value
        r := StrReplace(r, "C", "x")
        r := StrReplace(r, "U", "y")
        r := StrReplace(r, "G", "C")
        r := StrReplace(r, "A", "U")
        r := StrReplace(r, "x", "G")
        r := StrReplace(r, "y", "A")

        InputBox("Translated sequence (is now mRNA):", , , r)
    }

; Cheat Engine
#HotIf WinActive("Cheat Engine")
    ^Backspace::
    {
        Send("^+{Left}")
        Send("{Backspace}")
    }

    +Enter::
    {
        Send("+{F10}")
        Send("{Down 6}{Enter}")
    }

#HotIf WinActive("ahk_exe OLGame.exe")
    Space::
    {
        Loop
        {
            if (!(GetKeyState("Space", "P")))
            {
                break
            }

            Send("{WheelDown}")
            Sleep(10)
        }
    }

#HotIf WinActive("ahk_exe DeepL.exe")
    End::
    Escape::return

#HotIf WinActive("ahk_exe firefox.exe")
    ^r::return

#HotIf WinActive("ahk_exe csgo.exe")
    #::
    {
        static csBombTimerEnd
        csBombTimerEnd := A_TickCount + 39000

        Loop
        {
            if (A_TickCount > csBombTimerEnd)
            {
                ToolTip()
                return
            }
            else
            {
                ToolTip(csBombTimerEnd - A_TickCount, 5, 5)
            }
        }
    }

    ~*LButton::
    {
        Loop
        {
            if (!(GetKeyState("LButton", "P") && csrapid.is()))
            {
                break
            }

            Send("{Blind}{LButton}")
            Sleep(50)
        }
    }

    ~*Space::
    {
        Loop
        {
            if (!(GetKeyState("Space", "P") && csrapid.is()))
            {
                break
            }

            Send("{Space}")
            ; Sleep(10)
        }
    }

    +b::csrapid.inc()

#HotIf WinActive("ahk_exe eof.exe")
    >^f::
    {
        Click("307 313")
        Sleep(50)
        Click("338 526")
    }

#HotIf WinActive("ahk_exe hl2.exe")
    F2::Send("{LShift down}")

    ~*LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("LButton", "P") && hlrapid.is()))
            {
                break
            }

            Send("{Click}")
            Sleep(20)
        }
    }

    ~RButton & ~LButton::
    {
        Loop
        {
            if (!(GetKeyState("LButton", "P") && GetKeyState("RButton", "P")))
            {
                break
            }

            /*
            if (A_Index < 8)
            {
                MouseMove(0, 10, 50, "R")
            }
            else
            {
                MouseMove(0, 0.33, 50, "R")
            }
            */
            Sleep(20)
        }
    }

    +b::hlrapid.inc()

#HotIf WinActive("ahk_exe NewColossus_x64vk.exe")
    +b::wsrapid.inc()

    *RButton::
    ~*LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("LButton", "P") && wsrapid.is()))
            {
                break
            }

            if (Mod(A_Index, 2) == 0)
            {
                Send("{LButton}")
            }
            else
            {
                Send("{RButton}")
            }
            Sleep(10)
        }
    }

#HotIf WinActive("Civilization")
    F2::
    {
        Loop
        {
            if (!WinActive("Civilization"))
            {
                return
            }

            Send("{Space}")
            Sleep(10000)
        }
    }

#HotIf WinActive("Sea of Thieves")
    NumpadSub::Send(A_Clipboard)

    +b::strapid.inc()
    
    ~*Space::
    {
        Loop
        {
            if (!(GetKeyState("Space", "P") && strapid.is()))
            {
                break
            }

            Send("{Space}")
            Sleep(10)
        }
    }
    
#HotIf WinActive("Roblox")
    /*
    ~*RButton::
    ~*RButton up::
    {
        static x, y

        if (InStr(A_ThisHotkey, "up"))
        {
            MouseMove(x, y, 0)
        }
        else
        {
            MouseGetPos(&x, &y)
        }
    }
    */

    F11::Send("{f down}")

    +b::rbrapid.inc()

    F10::
    {
        Loop
        {
            if (!WinActive("Roblox"))
            {
                break
            }

            Send("{Click}")
            Sleep(10)
        }
    }

    ; ~RButton & LButton::
    ~*LButton::
    {
        global
        Loop
        {
            ;if (!(GetKeyState("LButton", "P") && GetKeyState("RButton", "P") && rbrapid.is()))
            if (!(GetKeyState("LButton", "P") && rbrapid.is(1, 3)))
            {
                break
            }

            Send("{Click}")
            Sleep(10)
        }
    }

    hkfunc(ThisHotkey)
    {
        if (!(WinActive("Roblox") && rbrapid.is(2, 3)))
        {
            return
        }

        physPress := SubStr(ThisHotkey, 3)
        ; Declare and initialize these as static to avoid setting them every time the function is called
        static vars := Map()
        static varsIsSet := false
        static resetKey := ""
        
        if (!varsIsSet)
        {
            for k in robloxSwitchKeys
            {
                ; Exclude the first key in the Array from the switch keys and make it the resetKey instead
                if (A_Index == 1)
                {
                    resetKey := k
                }
                else
                {
                    vars.Set(SubStr(k, 3), false)
                }
            }
        }
        
        ; Remember that the keys are set correctly
        varsIsSet := true
        str := ""

        if (physPress == resetKey)
        {
            ; resetKey was pressed
            for key, val in vars
            {
                ; Iterate through the other keys and release them all
                vars[key] := false
                Send("{" . key . " up}")

                str .= key . "`n" . vars[key] . "`n`n"
            }
        }
        else
        {
            ; One of the switchKeys was pressed
            for key, val in vars
            {
                ; Iterate through the keys it could be
                if (key == physPress)
                {
                    ; The current key _is_ the one that's been pressed
                    if (vars[key] == false)
                    {
                        ; The key is _not_ down, so press it
                        ; Remember that it's supposed to be down
                        vars[key] := true
                        ; Wait for it to be released before sending the "down" key event
                        KeyWait(key)
                        Send("{" . key . " down}")
                    }
                    else
                    {
                        ; The key _is_ down, so release it
                        vars[key] := false
                        Send("{" . key . " up}")
                    }
                }
                else
                {
                    ; The current key is _not_ the one that's been pressed, so release it
                    vars[key] := false
                    Send("{" . key . " up}")
                }

                str .= key . "`n" . vars[key] . "`n`n"
            }
        }

        ; Uncomment this to debug states upon keypresses
        ; MsgBox(str)
    }

    ~b::
    {
        global
        Loop
        {
            if (!(GetKeyState("B", "P") && rbrapid.is()))
            {
                break
            }

            Send("b")
            Sleep(75)
        }
    }

#HotIf WinExist("ahk_exe GTA5.exe")
    #.::
    {
        WinMove(0, 0, 3840, 2160, "ahk_exe GTA5.exe")
    }

    NumpadSub::
    {
        WinActivate("ahk_exe GTA5.exe")
        WinWaitActive("ahk_exe GTA5.exe")
        Send(A_Clipboard)
    }

    F11::
    {
        WinActivate("ahk_exe GTA5.exe")
        Send("{LShift down}{d down}}")
    }

    >+ä::
    {
        r := MsgBox("Set blocking rules on / off?", "GTA:O Port Blocking WF Rules", 3)
        switch (r)
        {
            case "Yes":
                codebase.setWFRuleStatus(true, "#GTAO Out", "#GTAO In")
            case "No":
                codebase.setWFRuleStatus(false, "#GTAO Out", "#GTAO In")
        }
    }

#HotIf WinActive("ahk_exe tuxguitar.exe")


#HotIf WinActive("ahk_exe FactoryGame-Win64-Shipping.exe")
    +b::sfrapid.inc()

    ~RButton & LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("Space", "P") && sfrapid.is()))
            {
                break
            }

            Send("{Space}")
            Sleep(10)
        }
    }

; Fortnite
#HotIf WinActive("ahk_exe FortniteClient-Win64-Shipping.exe")
    +b::fnrapid.inc()

    /*
    ~RButton & LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("LButton", "P") && fnrapid.is()))
            {
                break
            }

            SendPlay("{LButton}")
            Sleep(10)
        }
    }
    */

#HotIf WinActive("ahk_exe Overwatch.exe")
    +b::owrapid.inc()

    ~*Space::
    {
        global
        Loop
        {
            if (!(GetKeyState("Space", "P") && owrapid.is()))
            {
                break
            }

            Send("{Space}")
            Sleep(10)
        }
    }

    ~LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("LButton", "P") && owrapid.is(2)))
            {
                break
            }

            Send("{LButton}")
            Sleep(10)
        }
    }

#HotIf WinActive("Google Sheets")
    

#HotIf WinActive("ahk_exe r5apex.exe")
    +b::apexrapid.inc()

    ~RButton & ~LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("LButton", "P") && GetKeyState("RButton", "P") && apexrapid.is()))
            {
                break
            }
            
            Send("{LButton}")
            Sleep(10)
        }
    }

    ~y::
    {
        global
        Loop
        {
            if (!(GetKeyState("Y", "P") && apexrapid.is()))
            {
                break
            }
            
            Send("y")
            Sleep(10)
        }
    }