#Include #Includes\ahk-codebase.ahk
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
:*?:gr_alpha::Î± ; Î‘
:*?:gr_beta::Î² ; Î’
:*?:gr_gamma::Î³ ; Î“
:*?:gr_delta::Î´ ; Î”
:*?:gr_epsilon::Îµ ; Î•
:*?:gr_zeta::Î¶ ; Î–
:*?:gr_eta::Î· ; Î—
:*?:gr_theta::Î¸ ; Î˜
:*?:gr_iota::Î¹ ; Î™
:*?:gr_kappa::Îº ; Îš
:*?:gr_lambda::Î» ; Î›
:*?:gr_mu::Î¼ ; Îœ
:*?:gr_nu::Î½ ; Î
:*?:gr_xi::Î¾ ; Îž
:*?:gr_omicron::Î¿ ; ÎŸ
:*?:gr_pi::Ï€ ; Î 
:*?:gr_rho::Ï ; Î¡
:*?:gr_sigma::Ïƒ ; Î£
:*?:gr_tau::Ï„ ; Î¤
:*?:gr_upsilon::Ï… ; Î¥
:*?:gr_phi::Ï† ; Î¦
:*?:gr_chi::Ï‡ ; Î§
:*?:gr_psi::Ïˆ ; Î¨
:*?:gr_omega::Ï‰ ; Î©

; Arrows
:*?:arr_r::â†’
:*?:arr_fat_r::â‡’

:*?:arr_l::â†
:*?:arr_fat_l::â‡

:?:arr_d::â†“
:*?:arr_fat_d::â‡“

:?:arr_u::â†‘
:*?:arr_fat_u::â‡‘

:*?:arr_ul::â†–
:*?:arr_ur::â†—
:*?:arr_dr::â†˜
:*?:arr_dl::â†™

:*?:arr_double_l::â†”
:*?:arr_double_r::â†”
:*?:arr_double_d::â†•
:*?:arr_double_u::â†•

; Math :*?:math_approx::â‰ˆ :*?:math_neq::â‰  :*?:=/=::â‰ 
:*?:math_corr::â‰™
:*?:math_est::â‰™

:*?:math_diameter::Ã˜
:*?:math_average::Ã˜

:*?:math_elementof::âˆˆ
:*?:math_notelementof::âˆ‰

:*?:math_inf::âˆž

:*?:math_xor::âŠ•

:*?:math_plusminus::Â±
:*?:math_times_dot::âˆ™
:*?:math_times_cross::Ã—
:*?:math_div::Ã·
:*?:math_sqrt::âˆš

:*?:math_lt::<
:*?:math_le::â‰¤
:*?:math_gt::>
:*?:math_ge::â‰¥

; Misc. symbols
:*?:symb_checkmark::âœ“
:*?:symb_lightning::â†¯
:*?:symb_heart::â™¥r
:*?:symb_bul_empty::â—¦
:*?:symb_bul_fill::â€¢
:*?:symb_tm::â„¢
:*?:symb_fullblock::â–ˆ
:*?:symb_square::â– 
:*?:symb_death::â™°

:*?:symb_em::â€”
:*?:symb_en::â€“

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

>^>+Ã¼::
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

#HotIf WinActive("ahk_exe teams.exe")
; FÃ¼lÃ¼b Casing
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
