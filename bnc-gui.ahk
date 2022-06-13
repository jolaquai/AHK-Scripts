; Import the codebase library to allow calls to some often-needed functions and more
#Include F:\PROGRAMMING\AHK Scripts\#Includes\ahk-codebase.ahk
OnError((*) => 0)

g := Gui(, "Binomialverteilungsrechner lol")
g.OnEvent("Close", (*) => ExitApp(0))
g.OnEvent("Escape", (*) => ExitApp(0))

; n-p-k Texts
g.Add("Text", "x5   y5 w65 r1", "n")
g.Add("Text", "x75  y5 w65 r1", "p")
g.Add("Text", "x145 y5 w65 r1", "k")
g.Add("Text", "x215 y5 w65 r1", "Ergebnis")
; n-p-k Edits
s_n := g.Add("Edit", "x5   y25 w65 r1")
s_p := g.Add("Edit", "x75  y25 w65 r1")
s_k := g.Add("Edit", "x145 y25 w65 r1")
; n-p-k Result
s_r := g.Add("Edit", "x215 y25 w65 r1 ReadOnly")
; n-p-k Execute
s_e := g.Add("Button", "x5 y50 w276", "n-p-k einzeln berechnen")
s_e.OnEvent("Click", s_exec)
s_exec(*)
{
    s_r.Value := Round(codebase.math.probability.binomialDistribution(s_n.Value, s_p.Value, s_k.Value), 5)
}

; von-bis Texts
g.Add("Text", "x5   y120 w65 r1", "n")
g.Add("Text", "x75  y120 w65 r1", "p")
g.Add("Text", "x145 y120 w65 r1", "von")
g.Add("Text", "x215 y120 w65 r1", "bis")
g.Add("Text", "x5   y165 w276 r2 Center", "Ergebnis der kumulativen Berechnung in Extrafenster`nFür Standard-Kumulativberechnung: ``von`` = 0")
; von-bis Edits
km_n := g.Add("Edit", "x5   y140 w65 r1")
km_p := g.Add("Edit", "x75  y140 w65 r1")
km_v := g.Add("Edit", "x145 y140 w65 r1", 0)
km_b := g.Add("Edit", "x215 y140 w65 r1")
; von-bis Execute
km_e := g.Add("Button", "x5 y195 w276", "Kumulativ berechnen")
km_e.OnEvent("Click", km_exec)
km_exec(*)
{
    if (codebase.collectionOperations.or(
        km_n.Value == "",
        !IsInteger(km_n.Value),
        km_p.Value == "",
        !IsNumber(km_p.Value),
        (km_v.Value !== "" && !IsInteger(km_v.Value)),
        (km_b.Value !== "" && !IsInteger(km_b.Value))
    ))
    {
        MsgBox("Ungültige/s Argument/e für kumulative Berechnung.")
        return
    }
     
    km_n.Value := Integer(km_n.Value)
    km_p.Value := Float(km_p.Value)
    km_v.Value := ((km_v.Value !== "" && !IsInteger(km_v.Value)) ? Integer(km_v.Value) : 0)
    km_b.Value := ((km_b.Value !== "" && !IsInteger(km_b.Value)) ? Integer(km_b.Value) : Integer(km_n.Value))

    if (km_p.Value >= 1.0 || km_p.Value <= 0)
    {
        MsgBox("Ungültiger Wert für p. Darf weder ≤ 0, noch ≥ 1 sein.", , codebase.msgboxopt.icons.error)
        return
    }
    if (km_b.Value > km_n.Value || km_b.Value < km_v.Value)
    {
        MsgBox("Ungültiger Wert für ``bis``. Darf weder > n, noch < ``von`` sein.", , codebase.msgboxopt.icons.error)
        return
    }
    if (km_v.Value > km_n.Value)
    {
        MsgBox("Ungültiger Wert für ``von``. Darf > n sein.", , codebase.msgboxopt.icons.error)
        return
    }

    r := Gui()
    r.OnEvent("Close", (*) => Exit(0))
    r.OnEvent("Escape", (*) => Exit(0))

    lv := r.Add("ListView", "x5 y5 r" . Integer(km_n.Value) + 1 . " Report -Redraw Count" . Integer(km_n.Value), ["k", "P(X=k)", "P(X≤k)"])
    lv.OnEvent("DoubleClick", lv_dc)
    lv_dc(obj, row)
    {
        A_Clipboard := ""
        Loop lv.GetCount("Column")
        {
            A_Clipboard .= " " . lv.GetText(row, A_Index) . "`;"
        }
        A_Clipboard := Trim(A_Clipboard, "`t `;")
        if (A_Clipboard)
        {
            codebase.tool("Kopiert!")
        }
    }
    for k in codebase.range(start := Integer(km_v.Value), Integer(km_b.Value))
    {
        lv.Add(,
            k,
            Round(codebase.math.probability.binomialDistribution(km_n.Value, km_p.Value, k), 5),
            Round(codebase.math.probability.binomialDistributionRange(km_n.Value, km_p.Value, start, k), 5)
        )
    }
    Loop lv.GetCount("Column")
    {
        lv.ModifyCol(A_Index, "AutoHdr")
    }
    lv.Opt("+Redraw")

    r.Show()
}

g.Show("")