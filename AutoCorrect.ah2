; Import the codebase library to allow calls to some often-needed functions and more
#Include #Includes\ahk-codebase.ah2
#Include #Includes\siege.ah2
; #Include #Includes\Dictionary.ah2
codebase.Tool("Reloaded AutoCorrect.ah2", codebase.Tool.center, , , 15)

; Function / Variable / Object / Class Declarations
if (!A_IsDebuggerAttached)
{
    codebase.directoryOperations.DirectoryMonitor("E:\YOUTUBE\Captures\Tom Clancy's Rainbow Six  Siege", 1000)
    codebase.directoryOperations.DirectoryMonitor("E:\YOUTUBE\Captures\Counter-strike  Global Offensive", 1000)
    codebase.directoryOperations.DirectoryMonitor("E:\YOUTUBE\Captures\Overwatch", 1000)
}

/**
 * A `Rapidvar` is basically just a glorified Integer "type" with a custom maximum value instead of it being dictated by the amount of bits used to store a number. Its _current_ value's intended use is to influence the behavior of a game's hotkeys.
 *
 * The name `Rapidvar` is a reference to "rapid firing" semi-automatic guns by making a game hotkey spam the left mouse button only if that game's `Rapidvar` is equal to some value, which is the entire reason I created `Rapidvar`s. Despite this, I've since found other use cases, such as creating a "single fire" mode for any weapon. Its uses beyond as a toggle switch for specific hotkey behaviors are rather limited.
 * @note While every `Rapidvar` has a maximum value defined at instantiation, it is not guaranteed that its current value is within the range `[0, Rapidvar.max]` as the `set` method does not enforce the limit to allow for temporary values. This also avoids having to cycle between all _possible_ values of a `Rapidvar` to achieve a specific state. To ensure the current value stays within that range, either call the `inc` or `dec` methods, or use `safeset`.
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
            MonitorGet(MonitorGetPrimary(), &l, &t)
            this.x := l + 10
            this.y := t + 5
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
     * @param value The potential value to set the `Rapidvar` to. Negative values are ignored and the absolute value is used instead.
     * @returns The new value of the `Rapidvar`. May not be equal to `value`.
     */
    safeset(value) => this.set(Abs(Mod(Abs(value), this.max + 1)))

    /**
     * Check whether the `Rapidvar`'s current value is equal to a specific value or at least one of a series of values.
     * @param anyof Any number of numerical values to check against.
     * @note If no arguments are passed, the current value of the `Rapidvar` is returned. Equivalent to calling this method and passing all values in the range `[1, Rapidvar.max]`.
     * @returns `true` if the `Rapidvar`'s value is equal to any of the passed values, `false` otherwise.
     */
    check(anyof*)
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
    inc() => this.set(Abs(Mod(Abs(this.value + 1), this.max + 1)))

    /**
     * Decrease the current value of the `Rapidvar`.
     * @returns The new value of the `Rapidvar`.
     */
    dec() => this.value - 1 < 0 ? this.set(this.getMax()) : this.set(this.value - 1)

    /**
     * Get the maximum value of the `Rapidvar`.
     * @returns The maximum value of the `Rapidvar`.
     */
    getMax() => this.max

    /**
     * Set the new maximum value of the `Rapidvar`.
     * @param value The new maximum.
     * @returns The new maximum value of the `Rapidvar`.
     */
    setMax(value) => this.max := value
}

dbdrapid := Rapidvar("dbd")
siegerapid := Rapidvar("siege")
xtrctnrapid := Rapidvar("xtrctn", , true)
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
f13rapid := Rapidvar("f13")
mwrapid := Rapidvar("mw")
huntrapid := Rapidvar("hunt", 2)
swrapid := Rapidvar("sw")

robloxSwitchKeys := [
    "~*XButton2",
    "~*e",
    "~*q"
]
for k in robloxSwitchKeys
{
    Hotkey(k, hkfunc)
}

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

Hotstring(":*?:>`:§", ">:3")
Hotstring(":*?:<`:§", ">:3")
Hotstring(":*?:<`:3", ">:3")
Hotstring(":*?:>;§", ">;3")
Hotstring(":*?:<;§", ">;3")
Hotstring(":*?:<;3", ">;3")

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
:*?:=/=::≠
:*?:math_corr::≙
:*?:math_est::≙
:*?:math_caret::^

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

:*?:copyVKSC::
{
    local ih := InputHook("V", "{Escape}")
    ih.KeyOpt("{All}", "+NS")
    ih.OnKeyDown := fn
    ih.OnEnd := end
    ih.Start()
    
    end(*)
    {
        if (ih.EndKey == "Escape")
        {
            codebase.Tool("Input terminated through Escape, exiting...", codebase.Tool.center)
            return
        }
    }
    fn(hook, vk, sc)
    {
        A_Clipboard := ""
        A_Clipboard := Format("VK{:02X}SC{:03X}", vk, sc)
        codebase.Tool("Success", codebase.Tool.center)
        return ih.Stop()
    }
}

; Insert character from Unicode code
:b0*?:\u+::
:b0*?:\x+::
insertCharacterFromUnicodeCode(ThisHotkey)
{
    ih := InputHook("V L4", "{Escape}")
    codebase.Tool("Waiting for Unicode char code...", codebase.Tool.center)
    ih.Start()
    ih.Wait()
    ih.Stop()
    if (ih.EndReason == "EndKey" && ih.EndKey == "Escape")
    {
        codebase.Tool("Input terminated through Escape, exiting...", codebase.Tool.center)
        return
    }
    Send("{Backspace 7}" . (A_Clipboard := Chr(InStr(ThisHotkey, "\x") ? Integer("0x" . ih.Input) : Integer(ih.Input))))
}

:*?:symb_identify::
{
    ih := InputHook("V", "{Enter}{Escape}")
    ih.KeyOpt("{Enter}", "S")
    codebase.Tool("Waiting for any text...", codebase.Tool.center)
    ih.Start()
    ih.Wait()
    if (ih.EndReason == "EndKey" && ih.EndKey == "Escape")
    {
        codebase.Tool("Input terminated through Escape, exiting...", codebase.Tool.center)
        return
    }
    Send("{Backspace " . StrLen(ih.Input) . "}")
    A_Clipboard := ""
    for x in StrSplit(ih.Input)
    {
        ; -> U+HEX/DEC
        n := Format("{:04X}", Ord(x)) . "/" . Ord(x)
        A_Clipboard .= (A_Index > 1 ? " " : "") . "U+" . n
    }
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

; Rarely needed and usually useless because this sends inputs, not the symbols (i.e. `n becomes an Enter input)
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
:*?:/l/::ł
:*?:a__e::æ
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
:*?C:Dnd`:::Do-Not-Disturb
:*?:dnd`:::do-not-disturb

:?:@Paul::@₱₳ɄⱠ
:*?:@Dezzy::@ドミニク

; Emojis
; #HotIf !WinActive("ahk_exe discord.exe")
:*?:`:drooling`:::🤤
:*?:`:heart_eyes`:::😍
:*?:`:innocent`:::😇
:*?:`:joy`:::😂
:*?:`:moon`:::🌚
:*?:`:ok_hand`:::👌
:*?:`:pleading`:::🥺
:*?:`:sad`:::😔
:*?:`:shruggie`:::¯\\\_(ツ)\_\/¯
:*?:`:smirk`:::😏
:*?:`:sparkle`:::✨
:*?:`:sunglasses`:::😎
:*?:`:sweat_smile`:::😅
:*?:`:thumbs_up`:::👍
:*?:`:upside_down`:::🙃
:*?:`:wink`:::😉
~X & WheelUp::Send("{LAlt down}{PgDn}{LAlt Up}")

; Surround symbols
/*
#HotIf !WinActive("VSCode")
    && !WinActive("ahk_exe discord.exe")
    RShift & SC00D:: ; RShift + `
    {
        window := WinActive("A")
        symbols := StrSplit(InputBox("Input between one and three options to surround the selection with or insert, separated by a space.`nZero or more than three options causes the thread to exit here.").Value, A_Space)

        WinActivate(window)
        WinWaitActive(window)

        if (symbols.Length == 1)
        {
            surroundSymbols(symbols[1])
        }
        else if (symbols.Length == 2)
        {
            surroundSymbols(symbols[1], symbols[2])
        }
        else if (symbols.Length == 3)
        {
            surroundSymbols(symbols[1], symbols[2], symbols[3])
        }

        /*
         * Send the actual inputs.
         * @param leftSymbol The left symbol to insert.
         * @param rightSymbol The right symbol to insert. Defaults to `leftSymbol` if omitted.
         * @param moveLeft The amount of left movements to make. Defaults to `StrLen(rightSymbol)` if omitted.
         /
        surroundSymbols(leftSymbol, rightSymbol?, moveLeft?)
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

    RShift & SC00C:: ; RShift + ß
    {
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
        inputEdit := inputgui.Add("Edit", "r35 w500 WantReturn")

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
            ; Replace vertical tabs by "normal" newlines
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

            if (input)
            {
                WinActivate(window)
                WinWaitActive(window)

                Send("{Raw}" . input)
            }
        }
    }
*/

; Post-autorun return call
return

; Alt-F4 Intercept and Behavior Alteration
#Include #Includes\alt-f4.ah2

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
    ; Script process duplication due to rapid reloading should be prevented by this
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

#HotIf ; Global hotkeys
    SC002::return
    SC029::SC002
    SC00D::Send("``{Space}")
    LShift & SC00D::Send("``{Space}")
    <^>!SC00C::Send("{LAlt down}{Numpad9}{Numpad2}{LAlt up}")
    <^>!SC01B::Send("{LAlt down}{Numpad1}{Numpad2}{Numpad6}{LAlt up}")

#HotIf ; Context-insensitive hotkeys
    <+>^ü::
    {
        procs := ["Launcher.exe", "RockstarErrorHandler.exe", "RockstarService.exe", "SocialClubHelper.exe", "PlayGTAV.exe"]
        for pname in procs 
        {
            while (ProcessClose(pname))
            {
                
            }
        }
    }

    ScrollLock::
    ^ScrollLock::
    {
        SetScrollLockState(false)

        simple := true

        n := ""
        math := codebase.math
        vec := math.vectorGeometry
        prob := math.probability
        mat := math.matrixComputation

        arr := [
            Random(1, 250)
        ]

        if (!simple)
        {
            for class in [siege.defenders()] ; [siege.attackers(), siege.defenders()]
            {
                for op in class
                {
                    for w in codebase.collectionOperations.arrayOperations.arrayConcat(op.primaries, op.secondaries)
                    {
                        if (
                            !(codebase.collectionOperations.arrayOperations.arrayContainsPartial(arr, w.name, false).Length)
                         && w.type & siege.Weapon.types.assaultrifle
                        )
                        {
                            arr.Push(op.nickname . " - " . w.name)
                        }
                    }
                }
            }
        }
        codebase.collectionOperations.arrayOperations.arrSort(&arr, true)

        if (!(arr.Length))
        {
            codebase.Tool("Exited.", codebase.Tool.center)
            return
        }

        MsgBox(A_Clipboard := Trim(codebase.elemsOut(arr), '`n `t`r'))
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

        artist := StrLower(RegExReplace(artist, "[^a-zA-Z]+", "-"))
        track := StrLower(RegExReplace(track, "[^a-zA-Z]+", "-"))

        Run("https://genius.com/" . artist . "-" . track . "-lyrics")
    }

    ^+ö::
    {
        MsgBox(A_Clipboard := codebase.elemsOut(
            
        ))
    }

    ^+ä::
    {
        MsgBox(A_Clipboard := codebase.elemsOut(
            
        ))
    }
    
    ^!+ä::
    {
        MsgBox(A_Clipboard := codebase.elemsOut(
            
        ))
    }

    ^+ü::
    {
        static lenu := codebase.collectionOperations.arrayOperations.arrayConcat(codebase.constants.lowercaseAsc, codebase.constants.numbersAsc)
        url := "https://prnt.sc/"
        Loop 6
        {
            url .= lenu[Random(1, lenu.Length)]
        }
        Run(url)
        return

        MsgBox(A_Clipboard := codebase.elemsOut(
            
        ))
    }

    ^+#::
    {
        MsgBox(A_Clipboard := codebase.elemsOut(
            
        ))
    }

    ; Pixel-perfect mouse movement which literally just breaks on any but the primary monitor IF Windows's DPI scaling is set to anything but 100%
    #HotIf !WinActive("VSCode")
    NumpadDot & Numpad2::MouseMove(0, 1, 50, "R")
    NumpadDot & Numpad4::MouseMove(-1, 0, 50, "R")
    NumpadDot & Numpad6::MouseMove(1, 0, 50, "R")
    NumpadDot & Numpad8::MouseMove(0, -1, 50, "R")
    NumpadDot & Numpad7::Click()
    NumpadDot & Numpad9::Click("Right")

    :*?b0:(::){Left}
    :*?b0:[::]{Left}
    :*?b0:{::{}}{Left}

    #HotIf

    #!Left::WinMove(-1920, 0, 1920 / 3, 1080, "A")
    #!Right::WinMove(-1920 + (1920 / 3), 0, (1920 * (2 / 3)), 1080, "A")
    
    ^+!c::
    ^+!x::
    {
        sep := "`n"

        old := A_Clipboard
        A_Clipboard := ""
        Send("^" . SubStr(A_ThisHotkey, -1, 1))
        if (ClipWait())
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

        altgrgui := Gui(, "altgrgui [" . info.ahk_id . "]")
        altgrgui.OnEvent("Close", altgrgui_Exit)
        altgrgui.OnEvent("Escape", altgrgui_Exit)

        /**
         * Retrieves the command line of the previously active window by getting the `commandline` property of the `info` object that was constructed earlier, then sets the clipboard equal to the retrieved value. Finally calls `altgrgui_Exit` to close the GUI window and return to the previously active window.
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
        altgrgui.Add("Button", "w" . elemW, "Copy command line of active window").OnEvent("Click", cmdl_Click)

        /**
         * Retrieves the executable name of the previously active window by getting the `ahk_exe` property of the `info` object that was constructed earlier, then sets the clipboard equal to the retrieved value. Finally calls `altgrgui_Exit` to close the GUI window and return to the previously active window.
         */
        exec_Click(*)
        {
            A_Clipboard := ""
            A_Clipboard := info.ahk_exe
            if (A_Clipboard)
                codebase.Tool("Copied!")

            altgrgui_Exit()
        }
        altgrgui.Add("Button", "w" . elemW, "Copy executable name of active window").OnEvent("Click", exec_Click)

        /**
         * Retrieves the executable name of the previously active window by getting the `ahk_exe` property of the `info` object that was constructed earlier, then sets the clipboard equal to the retrieved value. Finally calls `altgrgui_Exit` to close the GUI window and return to the previously active window.
         */
        cmdpath_Click(*)
        {
            SplitPath(info.processQueryResult.ExecutablePath, , &path)
            A_Clipboard := ""
            A_Clipboard := path

            if (A_Clipboard)
            {
                codebase.Tool("Copied!")
            }

            altgrgui_Exit()
        }
        altgrgui.Add("Button", "w" . elemW, "Copy executable path of active window").OnEvent("Click", cmdpath_Click)

        /**
         * Sets the clipboard equal to the position of and color under the cursor before the GUI window was opened. Finally calls `altgrgui_Exit` to close the GUI window and return to the previously active window.
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
         */
        cal_Change(obj, *)
        {
            global chosenTime := obj.Value
            codebase.Tool("Changed")
        }
        cal := altgrgui.Add("DateTime", "Choose" . chosenTime . " w" . elemW, "MM/dd/yyyy    HH:mm:ss")
        cal.OnEvent("Change", cal_Change)

        /**
         * Sets the clipboard equal to the chosen date and time as a Unix timestamp. Finally calls `altgrgui_Exit` to close the GUI window and return to the previously active window.
         */
        calts_Click(*)
        {
            global chosenTime
            A_Clipboard := ""
            A_Clipboard := DateDiff(chosenTime, codebase.constants.ahkTimeZero, "s") + (codebase.getUnixTimeUTC() - codebase.getUnixTimeLocal())
            if (A_Clipboard)
            {
                codebase.Tool("Copied!")
            }

            altgrgui_Exit()
        }
        calts := altgrgui.Add("Button", "w" . elemW, "Copy Unix time of chosen timestamp (UTC, Discord timestamp-compatible)")
        calts.OnEvent("Click", calts_Click)

        /**
         * Sets the clipboard equal to the current date and time (relative to UTC) as a Unix timestamp. Finally calls `altgrgui_Exit` to close the GUI window and return to the previously active window.
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
         * Sets the clipboard equal to the chosen date and time (in the current time zone) as a Unix timestamp. Finally calls `altgrgui_Exit` to close the GUI window and return to the previously active window.
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
         * Sets the clipboard equal to the absolute value (always positive) of the difference between the chosen date and time in seconds. Finally calls `altgrgui_Exit` to close the GUI window and return to the previously active window.
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
         * If ShutdownBlocker is running on the system, calls it with the `-allow` parameter per command line to allow a shutdown to be scheduled. Then calls `shutdown` per command line to schedule a shutdown of the system at the chosen timestamp. Finally calls `altgrgui_Exit` to close the GUI window and return to the previously active window.
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
            
            sdtime := Abs(DateDiff(A_Now, chosenTime, "s"))
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

; Context-sensitive hotkeys

#HotIf WinActive("VSCode")
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
    +v::siegerapid.set(2)

    ~RButton & LButton::
    {
        global
        Loop
        {
            if (GetKeyState("LButton", "P") && GetKeyState("RButton", "P") && siegerapid.check(1))
            {
                Send("{LAlt up}{Click}")
                Sleep(10)
            }
            else if (GetKeyState("LButton", "P") && GetKeyState("RButton", "P") && siegerapid.check(2))
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

    ~*1::
    ~*XButton1::
    ~*XButton2::
    ~*LButton::
    *2::
    {
        static nadeHeld := false
        static nadeBtn := "Numpad9"
        out := A_ThisHotkey

        if (nadeHeld)
        {
            if (A_ThisHotkey == "*2" || InStr(A_ThisHotkey, "LButton"))
            {
                out .= "`nThrowing"
            }
            else ; if (InStr(hotkey, "XButton1") || InStr(hotkey, "XButton2") || hotkey == "~1") ; Cancel
            {
                out .= (nadeHeld ? "`nCanceling" : "")
                Send("{XButton1}")
            }

            nadeHeld := false
            Send("{" . nadeBtn . " up}")
        }
        else
        {
            if (A_ThisHotkey == "*2")
            {
                out .= "`nHolding"
                nadeHeld := true
                Send("{" . nadeBtn . " down}")
            }
        }

        codebase.Tool(out, codebase.Tool.coords, , 10, 10)
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

; Extraction
#HotIf WinActive("ahk_exe R6-Extraction.exe")
    +b::xtrctnrapid.inc()

    ~RButton & LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("LButton", "P") && GetKeyState("RButton", "P") && xtrctnrapid.check()))
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

        MouseMove(382, 1800)
        Sleep(30)
        Loop 10
        {
            Click("WheelDown")
        }
        Sleep(50)
        Click("218 1844")
        Sleep(50)

        MouseMove(x, y)
    }

    ~p::
    {
        KeyWait("P", "U")
        KeyWait("LButton", "D")
        KeyWait("LButton", "U")

        MouseMove(388, 1640)
        Sleep(50)
        Click("388 1640")

        KeyWait("Enter", "D")
        KeyWait("Enter", "U")

        Send("gy")
        MouseMove(1928, 1696)
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

    .::
    {
        Loop
        {
            if (!GetKeyState("SC034", "P"))
            {
                break
            }

            Send("{Space}")
            Sleep(620)
        }
    }
    
    +b::dbdrapid.inc()
    
    ~Space::
    {
        global

        Loop
        {
            if (!(GetKeyState("Space", "P") && dbdrapid.check()))
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
            if (!(WinActive("ahk_exe ACOdyssey.exe") && GetKeyState("Space", "P") && acorapid.check()))
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
            if (!(GetKeyState("LButton", "P") && csrapid.check()))
            {
                break
            }

            Send("{Blind}{LButton}")
            Sleep(Random((t := 40), t + 20))
        }
    }

    ~*Space::
    {
        Loop
        {
            if (!(GetKeyState("Space", "P") && csrapid.check()))
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
            if (!(GetKeyState("LButton", "P") && hlrapid.check()))
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
            if (!(GetKeyState("LButton", "P") && wsrapid.check()))
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
            if (!(GetKeyState("Space", "P") && strapid.check()))
            {
                break
            }

            Send("{Space}")
            Sleep(10)
        }
    }
    
#HotIf WinActive("Roblox")
    F11::Send("{w down}")
    *F1::SC002
    *Numpad1::SC002
    *SC029::SC002

    NumpadAdd::WheelUp
    NumpadSub::WheelDown

    ö::Send("{LButton down}{RButton down}")

    ~*WheelUp::
    ~*WheelDown::
    {
        return
        static m := []
        if (!(m.Length))
        {
            for i in codebase.range(1, 2)
            {
                m.Push(String(i))
            }
        }

        static i := 1
        if (InStr(A_ThisHotkey, "up"))
        {
            i--
            if (i == 0)
            {
                i := m.Length
            }
        }
        else
        {
            i++
            if (i > m.Length)
            {
                i := 1
            }
        }
        OutputDebug(i)
        Send(i)
        Send("{Wheel" . (InStr(A_ThisHotkey, "up") ? "Down" : "Up") . "}")
    }

    +b::rbrapid.inc()

    CapsLock::e
    ; g::Send("{f down}")

    F10::
    {
        Loop
        {
            if (!WinActive("Roblox"))
            {
                break
            }

            Send("{Blind}{Click}")
            Sleep(10)
        }
    }

    ; ~RButton & LButton::
    ~*LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("LButton", "P") && rbrapid.check(1, 3)))
            {
                break
            }

            Send("{Blind}{Click}")
            Sleep(10)
        }
    }

    hkfunc(ThisHotkey)
    {
        if (!(WinActive("Roblox") && rbrapid.check(2, 3)))
        {
            return
        }

        physPress := SubStr(ThisHotkey, 3)
        static vars := Map()
        static resetKey := ""
        
        if (!(vars.Count))
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
        str := ""

        if (physPress == resetKey)
        {
            ; resetKey was pressed
            for key, val in vars
            {
                ; Iterate through the other keys and release them all
                vars.Set(key, false)
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
                    if (vars.Get(key) == false)
                    {
                        ; The key is _not_ down, so press it
                        ; Remember that it's supposed to be down
                        vars.Set(key, true)
                        ; Wait for it to be released before sending the "down" key event
                        KeyWait(key)
                        Send("{" . key . " down}")
                    }
                    else
                    {
                        ; The key _is_ down, so release it
                        vars.Set(key, false)
                        Send("{" . key . " up}")
                    }
                }
                else
                {
                    ; The current key is _not_ the one that's been pressed, so release it
                    vars.Set(key, false)
                    Send("{" . key . " up}")
                }

                str .= key . "`n" . vars.Get(key) . "`n`n"
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
            if (!(GetKeyState("B", "P") && rbrapid.check()))
            {
                break
            }

            Send("b")
            Sleep(75)
        }
    }

#HotIf WinExist("ahk_exe GTA5.exe")
    ^.::
    {
        WinGetPos(&x, &y, , , "ahk_exe GTA5.exe")
        WinMove(x, y, w := 3600, (w / 16) * 9, "ahk_exe GTA5.exe")
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
        switch (MsgBox("Set blocking rules on / off?", "GTA:O Port Blocking WF Rules", 3)) 
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
            if (!(GetKeyState("Space", "P") && sfrapid.check()))
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
    last(*)
    {
        global
        static last
        last := A_Clipboard

        Loop
        {
            if (!(GetKeyState("LButton", "P") && fnrapid.check()))
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
            if (!(GetKeyState("Space", "P") && owrapid.check()))
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
            if (!(GetKeyState("LButton", "P") && owrapid.check(2)))
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
            if (!(GetKeyState("LButton", "P") && GetKeyState("RButton", "P") && apexrapid.check()))
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
            if (!(GetKeyState("Y", "P") && apexrapid.check()))
            {
                break
            }
            
            Send("y")
            Sleep(10)
        }
    }

#HotIf WinActive("ahk_exe SummerCamp.exe")
    ^.::WinMove(0, 0, 3840, 2160, "ahk_exe SummerCamp.exe")

    +b::f13rapid.inc()

    ~e::
    {
        global
        Loop
        {
            if (!(GetKeyState("E", "P") && f13rapid.check()))
            {
                break
            }
            
            SendPlay("e")
            Sleep(10)
        }
    }

#HotIf WinActive("ahk_exe ModernWarfare.exe")
    +b::mwrapid.inc()

    ~LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("LButton", "P") && mwrapid.check()))
            {
                break
            }
            
            Send("{LButton}")
            Sleep(10)
        }
    }

#HotIf WinActive("ahk_exe HuntGame.exe")
    +b::huntrapid.inc()
    +n::huntrapid.dec()

#HotIf WinActive("ahk_exe starwarsbattlefrontii.exe")
    *LWin::return
    *RWin::return

    XButton2::F12
    
    +b::swrapid.inc()

    ~LButton::
    {
        global
        Loop
        {
            if (!(GetKeyState("LButton", "P") && swrapid.check()))
            {
                break
            }
            
            Send("{LButton}")
            Sleep(10)
        }
    }

    ~Space::
    {
        global
        Loop
        {
            if (!(GetKeyState("Space", "P") && swrapid.check()))
            {
                break
            }
            
            Send("{Space}")
            Sleep(10)
        }
    }

#HotIf WinActive("ahk_exe Phasmophobia.exe")