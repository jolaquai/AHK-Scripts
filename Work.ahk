﻿#Include #Includes\ahk-codebase.ahk
codebase.Tool('Reloaded ' . A_ScriptName)

; Reload with Ctrl+S
; #HotIf !WinActive('ahk_exe HITMAN3.exe')
/* NEVER EVER USE THIS WHEN RUNNING IN A VM
~^s::
{
    ; Script process duplication due to rapid reloading should be prevented by this
    Send('{Ctrl up}{s up}')
    Sleep(100)
    DetectHiddenWindows(true)
    for hwnd in WinGetList('ahk_class AutoHotkey')
    {
        if (hwnd == A_ScriptHwnd)
        {
            continue
        }
        PostMessage(0x0111, 65303, , , hwnd)
    }
    Reload()
}
*/

#HotIf
; Greek letters
; The uppercase character is inserted instead if just the 'g' in gr_alpha, for example, is capitalized. Or just capitalize the entire thing.
;   lowercase     ; uppercase
:*?:gr_alpha::α   ; Α
:*?:gr_beta::β    ; Β
:*?:gr_gamma::γ   ; Γ
:*?:gr_delta::δ   ; Δ
:*?:gr_epsilon::ε ; Ε
:*?:gr_zeta::ζ    ; Ζ
:*?:gr_eta::η     ; Η
:*?:gr_theta::θ   ; Θ
:*?:gr_iota::ι    ; Ι
:*?:gr_kappa::κ   ; Κ
:*?:gr_lambda::λ  ; Λ
:*?:gr_mu::μ      ; Μ
:*?:gr_nu::ν      ; Ν
:*?:gr_xi::ξ      ; Ξ
:*?:gr_omicron::ο ; Ο
:*?:gr_pi::π      ; Π
:*?:gr_rho::ρ     ; Ρ
:*?:gr_sigma::σ   ; Σ
:*?:gr_tau::τ     ; Τ
:*?:gr_upsilon::υ ; Υ
:*?:gr_phi::φ     ; Φ
:*?:gr_chi::χ     ; Χ
:*?:gr_psi::ψ     ; Ψ
:*?:gr_omega::ω   ; Ω

; Arrows
:*?:arr_r::→
:*?:arr_fat_r::⇒

:*?:arr_l::←
:*?:arr_fat_l::⇐

:?:arr_d::↓
:*?:arr_fat_d::⇓

:?:arr_u::↑
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

; Misc. symbols
:*?:symb_checkmark::✓
:*?:symb_lightning::↯
:*?:symb_heart::♥r
:*?:symb_bul_empty::◦
:*?:symb_bul_fill::•
:*?:symb_tm::™
:*?:symb_fullblock::█
:*?:symb_square::■
:*?:symb_death::♰

:*?:symb_em::—
:*?:symb_en::–

:*?:lang_abstract::
:*?:lang_add::
:*?:lang_alias::
:*?:lang_and::
:*?:lang_args::
:*?:lang_as::
:*?:lang_ascending::
:*?:lang_async::
:*?:lang_await::
:*?:lang_base::
:*?:lang_bool::
:*?:lang_break::
:*?:lang_by::
:*?:lang_byte::
:*?:lang_case::
:*?:lang_catch::
:*?:lang_char::
:*?:lang_checked::
:*?:lang_class::
:*?:lang_const::
:*?:lang_continue::
:*?:lang_decimal::
:*?:lang_default::
:*?:lang_delegate::
:*?:lang_descending::
:*?:lang_do::
:*?:lang_double::
:*?:lang_dynamic::
:*?:lang_else::
:*?:lang_enum::
:*?:lang_equals::
:*?:lang_event::
:*?:lang_explicit::
:*?:lang_extern::
:*?:lang_false::
:*?:lang_file::
:*?:lang_finally::
:*?:lang_fixed::
:*?:lang_float::
:*?:lang_for::
:*?:lang_foreach::
:*?:lang_from::
:*?:lang_get::
:*?:lang_global::
:*?:lang_goto::
:*?:lang_group::
:*?:lang_if::
:*?:lang_implicit::
:*?:lang_in::
:*?:lang_init::
:*?:lang_int::
:*?:lang_interface::
:*?:lang_internal::
:*?:lang_into::
:*?:lang_is::
:*?:lang_join::
:*?:lang_let::
:*?:lang_lock::
:*?:lang_long::
:*?:lang_managed::
:*?:lang_nameof::
:*?:lang_namespace::
:*?:lang_new::
:*?:lang_nint::
:*?:lang_not::
:*?:lang_notnull::
:*?:lang_nuint::
:*?:lang_null::
:*?:lang_object::
:*?:lang_on::
:*?:lang_operator::
:*?:lang_or::
:*?:lang_orderby::
:*?:lang_out::
:*?:lang_override::
:*?:lang_params::
:*?:lang_partial::
:*?:lang_private::
:*?:lang_protected::
:*?:lang_public::
:*?:lang_readonly::
:*?:lang_record::
:*?:lang_ref::
:*?:lang_remove::
:*?:lang_required::
:*?:lang_return::
:*?:lang_sbyte::
:*?:lang_scoped::
:*?:lang_sealed::
:*?:lang_select::
:*?:lang_set::
:*?:lang_short::
:*?:lang_sizeof::
:*?:lang_stackalloc::
:*?:lang_static::
:*?:lang_string::
:*?:lang_struct::
:*?:lang_switch::
:*?:lang_this::
:*?:lang_throw::
:*?:lang_true::
:*?:lang_try::
:*?:lang_typeof::
:*?:lang_uint::
:*?:lang_ulong::
:*?:lang_unchecked::
:*?:lang_unmanaged::
:*?:lang_unsafe::
:*?:lang_ushort::
:*?:lang_using::
:*?:lang_value::
:*?:lang_var::
:*?:lang_virtual::
:*?:lang_void::
:*?:lang_volatile::
:*?:lang_when::
:*?:lang_where::
:*?:lang_while::
:*?:lang_with::
:*?:lang_yield::
InsertLangword(hk)
{
    hk := SubStr(hk, 10)
    old := A_Clipboard
    A_Clipboard := "<see langword=`"" . hk . "`"/>"
    Sleep(500)
    Send("^v")
    Sleep(500)
    A_Clipboard := old
}

:*?:__gagr::.GetAwaiter().GetResult()
:*?:__caf::.ConfigureAwait(false)
:*?:__fgagr::.ConfigureAwait(false).GetAwaiter().GetResult()

:*?:__guid::
{
    A_Clipboard := codebase.getGuids()[1]
    Send("^v")
}
:*?:__lguid::
{
    A_Clipboard := StrLower(codebase.getGuids()[1])
    Send("^v")
}
^!+1::
^!+2::
^!+3::
^!+4::
^!+5::
^!+6::
^!+7::
^!+8::
^!+9::
^!+0::
{
    A_Clipboard := codebase.stringOperations.strJoin("`r`n", false, codebase.getGuids(SubStr(A_ThisHotkey, 4))*)
    Send("^v")
}

^!+F10::
{
    WinSetAlwaysOnTop(-1, 'A')
}

>^>+ü::
{
    A_Clipboard := WinGetProcessName(WinExist('A'))
    MsgBox("Copied name of active process: '" . A_Clipboard . "'")
}

SC00D::Send("``{Space}")
LShift & SC00D::Send("``{Space}")

#HotIf WinActive('ahk_exe AcroRd32.exe') && WinExist('Arbortext')
^c::
{
    Send('^c')
    str := A_Clipboard
    str := Trim(str, '-')
    pattern := "(?    <!\\)([\.\+\*\?\[\^\]\$\(\)\{\}\=\!\<\>\|\:\-])"
    while (RegExMatch(str, pattern))
    {
        str := RegExReplace(str, pattern, '\$2')
    }
    str := StrReplace(str, ' ', '.')
    A_Clipboard := str
    codebase.Tool('Copied')

    if (WinExist('Suchen/Ersetzen'))
    {
        WinActivate('Suchen/Ersetzen')
        Sleep(300)
        Send('!c')
        Sleep(150)
        Send('^v')
    }
}
#HotIf

^+!c::
{
    old := A_Clipboard
    A_Clipboard := ''
    Send('^c')
    ClipWait(0.25)
    A_Clipboard := old . FileRead(EnvGet('USERPROFILE') . '\Documents\ahk_appendsep.txt', 'UTF-8') . A_Clipboard

    codebase.Tool(A_Clipboard ? 'Appended!' : 'Error')
}

^c::
{
    old := A_Clipboard
    A_Clipboard := ''
    Send('^c')
    ClipWait(0.25)
    if (InStr(A_Clipboard, "\\sa13-laquaij-vm\Alle"))
    {
        A_Clipboard := StrReplace(A_Clipboard, "\\sa13-laquaij-vm\Alle", "\\sa13-laquaij-vm\Alle")
    }
    if (InStr(A_Clipboard, "\\lm01\FREMDVERGABE\"))
    {
        A_Clipboard := StrReplace(A_Clipboard, "\\lm01\FREMDVERGABE\", "\\lm01\FREMDVERGABE\")
    }
}

#HotIf !WinActive('ahk_exe devenv.exe')
    && !WinActive('ahk_exe Code.exe')
    && !WinActive('ahk_exe Code - Insiders.exe')
    && !WinActive('ahk_exe firefox.exe')
    && !WinActive('ahk_exe teams.exe')
    && !WinActive('ahk_exe msteams.exe')
^Backspace:: Send('^+{Left}{Backspace}')
#HotIf

^!+v:: Send("{Raw}" . A_Clipboard)

#HotIf WinActive('Joshua Laquai ahk_exe firefox.exe')
:b0:}}::{Backspace}
#HotIf

^!+i::
{
    box := InputBox("chars to identify?")
    path := A_Temp . "\charident.txt"
    f := FileOpen(path, "w")
    for char in StrSplit(box.Value)
    {
        f.WriteLine("'" . char . "' == \u" . Format("{:04x}", Ord(char)))
    }
    f.Close()
    ; Run('explorer.exe "' . path . '"')
}

!NumpadAdd::
{
    prev := WinActive("A")
    input := InputBox("Type a Unicode codepoint")
    if (input.Result == "OK")
    {
        toSend := ""
        if (InStr(input.Value, " "))
        {
            split := StrSplit(input.Value, " ")
            for code in split
            {
                toSend .= Chr(codebase.convert.HexToDec(code))
            }
        }
        else
        {
            len := StrLen(input.Value)
            if (Mod(len, 4))
            {
                MsgBox("Code point(s) must have length mod 4!")
            }

            WinActivate(prev)

            ; Split into 4-char chunksStrLen(input.Value)
            i := 1
            while (i < len)
            {
                toSend .= Chr(codebase.convert.HexToDec(SubStr(input.Value, i, 4)))
                i += 4
            }
        }
        Send(toSend)
    }
}

!NumpadSub::
{
    input := InputBox("Type any characters to identify")
    if (input.Result == "OK")
    {
        template := "https://www.babelstone.co.uk/Unicode/whatisit.html?string="
        Run(template . input.Value)
    }
}

#HotIf WinActive("ahk_exe devenv.exe")
lastHotkey := ""

^!+d::
{
    global

    old := A_Clipboard
    A_Clipboard := "<div>`r`n</div>"
    Send("^v")
    A_Clipboard := old
    Sleep(250)
    Send("{Up}{Enter}")

    lastHotkey := A_ThisHotkey
}
^z::
{
    global

    Loop (InStr(lastHotkey, "^!+d") ? 3 : 1)
    {
        Send("^z")
    }

    lastHotkey := A_ThisHotkey
}

#HotIf WinActive("ahk_exe teams.exe")
; Fülüb Casing
^+p::
{
    static ClickTextField() => Click("1601, 1146")
    static ClickSizeButton() => Click("947, 1044")
    static ClickSmall() => Click("968, 1002")
    static ClickBig() => Click("968, 940")

    old := A_CoordModeMouse
    CoordMode("Mouse", "Window")

    while (!(GetKeyState("F8", "P")))
    {
        Send("{Shift Down}{Right}{Shift Up}")
        ;Sleep(20)
        if (Mod(A_Index, 3) == 0)
        {
            ClickSizeButton()
            ClickSmall()
        }
        else if (Mod(A_Index, 2) == 0)
        {
            Send("{Right}")
            continue
        }
        else
        {
            ClickSizeButton()
            ClickBig()
        }
        ;Sleep(20)
        Send("{Right}")
        ;Sleep(20)
    }

    A_CoordModeMouse := old
}

#HotIf WinActive("ahk_exe FoxitPDFReader.exe")
^c::
{
    ; Override copying from Foxit to allow working with the text in Regexs for <beginpage> checking
    A_Clipboard := ""
    Send("^c")
    ClipWait(0.5)

    ret := A_Clipboard
    ret := StrReplace(ret, "`r", "`n")
    ret := StrReplace(ret, "`n", " ")
    ret := Trim(ret)
    ret := Trim(ret, " -")
    ret := RegExReplace(ret, "(\d+)(ff?\.)", "$1 $2")
    ret := RegExReplace(ret, "[\^\$\.\*\+\?\(\)\[\]\{\}\|]", "\$0")

    ;ret := StrReplace(ret, " ", ".*?")
    ret := StrReplace(ret, " ", ".?")

    A_Clipboard := ret

    try
    {
        WinActivate("Find ahk_exe notepad++.exe")
    }
    catch
    {
        WinActivate("ahk_exe notepad++.exe")
        Send("^f")
    }
    WinWaitActive("Find ahk_exe notepad++.exe")
    Send("^v")
    Send("{Enter}")
}

+WheelDown::
{
    Send("{PgDn 5}")
}
+WheelUp::
{
    Send("{PgUp 5}")
}

#HotIf WinActive("ahk_exe notepad++.exe")
~^c::
~^v::
{
    Send("+!s")
}

+!1::
InsertBp(hk)
{
    static lastSuppldesc := ["Lfg.", "93", "Oktober", "2020"]
    static lastWasEven := 2
    static lastPagenum := 0

    pagenum := InputBox("pagenum", , , lastPagenum + 1)
    if (pagenum.Result !== "OK" || !IsInteger(pagenum.Value))
    {
        return
    }

    evenBp := Mod(pagenum.Value, 2)
    entries := (evenBp != Mod(lastPagenum, 2)) ? [
        lastSuppldesc[1],
        lastSuppldesc[2],
        lastSuppldesc[3],
        lastSuppldesc[4]
    ] : [
        lastSuppldesc[3],
        lastSuppldesc[4],
        lastSuppldesc[1],
        lastSuppldesc[2]
    ]
    lastPagenum := Integer(pagenum.Value)

    suppldescInput := InputBox("Suppldesc", , , codebase.stringOperations.strJoin(" ", false, entries*))
    if (suppldescInput.Result !== "OK")
    {
        return
    }
    lastSuppldesc := StrSplit(suppldescInput.Value, ' ')
    lastWasEven := evenBp

    A_Clipboard := ""
    A_Clipboard := '<beginpage leavebreak="' . (evenBp ? 'no' : 'yes') . '" pagenum="' . lastPagenum . '" suppldesc="' . codebase.stringOperations.strJoin(" ", false, lastSuppldesc*) . '" />'

    WinActivate("ahk_exe notepad++.exe")
    WinWaitActive("ahk_exe notepad++.exe")
    Send("^v")
    Send("+!s")
}