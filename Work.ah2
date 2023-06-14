#Include #Includes\ahk-codebase.ah2
codebase.Tool('Reloaded ' . A_ScriptName)

; Reload with Ctrl+S
; #HotIf !WinActive('ahk_exe HITMAN3.exe')
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

#HotIf
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

; Math :*?:math_approx::≈ :*?:math_neq::≠ :*?:=/=::≠
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

/*
presentGui := Gui('AlwaysOnTop', 'Present GUI')
presentGui.Add('Text', 'Center w150 r1', 'Clock-in')
rc := presentGui.Add('Button', 'x155 y5 Center w150 r1', 'Reset clock-in')
rc.OnEvent('Click', (*) => ci.Text := SubStr(A_Now, 1, 8))
ci := presentGui.Add('Edit', 'x5 Center w300 r1', SubStr(A_Now, 1, 8))
presentGui.Add('Text', 'Center w300 r1', 'Break')
br := presentGui.Add('Edit', 'Center w300 r1', "30")
doUpdate := presentGui.Add('Checkbox', 'Center w300 r2 Border', 'Update')
SetTimer(update, 950, -1) ; Timer should always be interruptible
update()
{
    if (!(doUpdate.Value))
    {
        return
    }
    try
    {
        v := Round((DateDiff(A_Now, ci.Text ? ci.Text : 0, 's') / 3600) - ((br.Text ? br.Text : 0) / 60), 4)
        dt.Text := v . ' = ' . codebase.formatMilliseconds(v * 3600000, false, 0)
    }
    try
    {
        pl.Text := FormatTime(DateAdd(ci.Text, 7.75 + (wp.Value / 60) + (br.Text ? br.Text : 0) / 60, "H"), "HH:mm:ss")
    }
}
presentGui.Add('Text', 'Center w300 r1', 'Delta')
dt := presentGui.Add('Edit', 'ReadOnly Center w300 r1')

presentGui.Add('Text', 'Center w300 r1', 'Wanted plus')
wp := presentGui.Add('Edit', 'Center w300 r1', "30")
presentGui.Add('Text', 'Center w300 r1', 'Until')
pl := presentGui.Add('Edit', 'ReadOnly Center w300 r1')

presentGui.Show('X1925 Y5')
ci.Focus()
*/

>^>+ü::
{
    A_Clipboard := WinGetProcessName(WinExist('A'))
}

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
    if (InStr(A_Clipboard, "C:\Users\laquai.joshua.EDV\Desktop\Alles\Alle"))
    {
        A_Clipboard := StrReplace(A_Clipboard, "C:\Users\laquai.joshua.EDV\Desktop\Alles\Alle", "\\sa13-laquaij-vm\Alle")
    }
}

#HotIf !WinActive('ahk_exe devenv.exe')
    && !WinActive('ahk_exe Code.exe')
    && !WinActive('ahk_exe firefox.exe')
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
    Run('explorer.exe "' . path . '"')
}

!NumpadAdd::
{
    prev := WinActive("A")
    input := InputBox("Type a Unicode codepoint")
    if (input.Result == "OK")
    {
        WinActivate(prev)
        Send(Chr(codebase.convert.HexToDec(input.Value)))
    }
}

#HotIf WinActive("ahk_exe devenv.exe")
^!+c::
{
    Send("^c")
    if (ClipWait(0.25))
    {
        newLines := []
        lines := StrSplit(A_Clipboard, "`r`n", ' ')

        for line in lines
        {
            newLines.Push(Trim(line))
        }

        A_Clipboard := codebase.stringOperations.strJoin("`r`n", true, newLines*)
        return codebase.Tool("Copied without indentation", codebase.Tool.center, 1000)
    }
    return codebase.Tool("Failed", codebase.Tool.center, 1000)
}