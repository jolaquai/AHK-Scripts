out := ""
even := 0
odd := 0
eh := 0
nona := 0

input := InputBox()
if (input.Result = "Cancel")
    ExitApp(0)

for x in StrSplit(input.Value)
{
    if (!RegExMatch(x, "[a-zA-Z]"))
    {
        nona++
        out .= x
        continue
    }

    n := Random(0, 4096)

    if (Mod(n, 2) = 0)
    {
        xnew := StrLower(x)
        out .= xnew
        even++
    }
    else
    {
        xnew := StrUpper(x)
        out .= xnew
        odd++
    }

    if (x == xnew)
        eh++
}

InputBox("Total = " . even + odd . "`nEven (upper) = " . even . "`nOdd (lower) = " . odd . "`nNo change = " . eh . "`nNo effect = " . nona, , , out)