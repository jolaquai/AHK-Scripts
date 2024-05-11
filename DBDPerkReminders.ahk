; Import the codebase library to allow calls to some often-needed functions and more
#Include #Includes\ahk-codebase.ahk

perkMappings := Map()
perks := []

for cat in ["Boon_Perks", "Exhaustion_Perks", "Hex_Perks", "Killer_Perks", "Obsession_Perks", "Scourge_Hook_Perks", "Survivor_Perks", "Teachable_Killer_Perks", "Teachable_Survivor_Perks"]
{
    catpage := codebase.requests.makeRequest("https://deadbydaylight.fandom.com/wiki/Category:" . cat, "GET").Get("ResponseText")
    startIndex := InStr(catpage, 'Pages in category')
    while (RegExMatch(catpage, "<li><a.*?>(.*?)<\/a><\/li>", &m, startIndex))
    {
        perkname := StrReplace(StrReplace(m[1], "&amp;", "&"), "&#039;", "'")
        perks.Push(Trim(perkname))
        startIndex += m.Len[1]
    }
}
perks := codebase.collectionOperations.arrayOperations.removeDuplicates(perks)
codebase.collectionOperations.arrayOperations.arrSort(&perks, , true)

preFetchPerkMappings()
{
    global
    static omitcount := 0
    local replace := Map(
        "&#60;",    "<",
        "&#lt;",    "<",
        "&#62;",    ">",
        "&#gt;",    ">",
        "&#47;",    "/",
        "<br>",     "`n",
        "<br />",   "`n",
        "&#10;",    "`n",
        "&#13;",    "`n",
        "#32;",     A_Space,
        "&#32;",    A_Space,
        "&#160;",   A_Space,
        "&#42;",    "-",
        "#37;",     "%",
        "&#37;",    "%",
        "&#39;",    "'",
        "&#34;",    '"',
        "&#38;",    "&",
        "&amp;",    "&",
        "&%",       "%",
    )

    getPerkDesc(perk)
    {
        static start := A_TickCount, count := 0
        count++
        rate := 0.000000000000001
        try rate := count / ((A_TickCount - start) / 1000)
        ; Optimal rate at around 6 MByte/s download speed is around ~12.5 per second, but it'll take a lot longer if your computer or connection is slow
        OutputDebug("Fetching perk description for '" . perk . "' (" . rate . ")`n")
        perk := StrReplace(perk, " ", "_")
        
        ; Request the perk's Wiki page
        desc := codebase.requests.makeRequest("https://deadbydaylight.fandom.com/wiki/" . perk, "GET").Get("ResponseText")
        ; Extract the perkDesc div
        RegExMatch(desc, 's)<div class="perkDesc divTableCell">(.*?)<\/div>', &desc)
        desc := desc[1]
        ; Retired perk? Leave it out
        if (InStr(desc, "THIS PERK HAS BEEN RETIRED."))
        {
            return { d: "omit", r: rate }
        }
    
        ; Translate some HTML escapes to their actual characters (and &#42; to "-" instead of "*")
        desc := codebase.stringOperations.strReplace(desc, replace)
        desc := RegExReplace(desc, "'{2,}")
        desc := RegExReplace(desc, "`n{2,}", "`n")
        desc := RegExReplace(desc, " +%", "%")
        ; Remove remaining HTML escapes and tags
        desc := RegExReplace(desc, "(&#..;)+")
        desc := RegExReplace(desc, "(<.*?>)")
    
        ; Satisfy my hate of British spelling
        desc := StrReplace(desc, "metre", "meter")
        desc := StrReplace(desc, "centre", "center")
    
        ; Trim the string and return it
        return {
            d: Trim(desc, " `t`n`r"),
            r: rate
        }
    }

    for perk in perks
    {
        ; Attempt to get the perk's description
        desc := getPerkDesc(perk)
        ; If the description is "omit", the perk has been retired
        if (desc.d == "omit")
        {
            ; Increment the omitcount to display the correct number of perks
            omitcount++
            ; Put the perk into the Map so a loop later can find and remove it, otherwise we'll get errors
            perkMappings.Set(perk . "OMIT", desc)
            ; Set the download progress bar's new maximum
            fetchProgress.Opt("Range0-" . (perks.Length - omitcount))
            continue
        }
        perkMappings.Set(perk, desc.d)
        status.Text := '"' . perk . '" (' . (A_Index - omitcount) . '/' . (perks.Length - omitcount) . ')`n'
            . 'Downloading at a rate of ' . Round(desc.r, 2) . ' perk(s)/sec.`n'
            . 'Estimated time remaining: ' . Round((perks.Length - A_Index) / desc.r, 2) . ' sec'
        fetchProgress.Value := A_Index - omitcount
    }

    ; Find all perks with the "OMIT" suffix...
    for k, v in perkMappings.Clone()
    {
        if (InStr(k, "OMIT", true))
        {
            ; ...and remove them from the Map...
            perkMappings.Delete(k)
            ; ...AND from the perks Array, otherwise it'll be selectable in the ComboBoxes and we'll get errors
            perks.RemoveAt(codebase.collectionOperations.arrayOperations.arrayContains(perks, SubStr(k, 1, StrLen(k) - 4))[1])
        }
    }

    Loop 4
    {
        status.Text := "Done! (" . 5 - A_Index . "...)"
        Sleep(1000)
    }
}

pre := Gui("AlwaysOnTop", "Loading perks...")
pre.OnEvent("Escape", ExitApp)
pre.OnEvent("Close", ExitApp)

fetchProgress := pre.Add("Progress", "x5 y5 w300 h20 Border Smooth C06B025 Range0-" . perks.Length)
status := pre.Add("Text", "x5 y35 w300 r4 Center")
pre.Add("Text", "x5 y105 w300 Center Wrap",
    "Please wait while downloading perks and their descriptions. This may take a while, depending on your connection and PC speed.`n"
    . "This window will close automatically when the download is complete."
)
pre.Show()
preFetchPerkMappings()

pre.GetPos(&x, &y)
pre.Hide()
pre.Destroy()

mainguititle := "Perk Descriptions"
main := Gui("AlwaysOnTop", mainguititle)
main.OnEvent("Escape", ExitApp)
main.OnEvent("Close", ExitApp)

elemwidth := 400

(cb1 := main.Add("ComboBox", "x" . 5 + ((elemwidth + 5) * 0) . " y5   w" . elemwidth . " r10 ", perks)).OnEvent("Change", perkChanged)
(cb2 := main.Add("ComboBox", "x" . 5 + ((elemwidth + 5) * 0) . " y255 w" . elemwidth . " r10 ", perks)).OnEvent("Change", perkChanged)
(cb3 := main.Add("ComboBox", "x" . 5 + ((elemwidth + 5) * 1) . " y5   w" . elemwidth . " r10 ", perks)).OnEvent("Change", perkChanged)
(cb4 := main.Add("ComboBox", "x" . 5 + ((elemwidth + 5) * 1) . " y255 w" . elemwidth . " r10 ", perks)).OnEvent("Change", perkChanged)

pd1 := main.Add("Edit",      "x" . 5 + ((elemwidth + 5) * 0) . " y30  w" . elemwidth . " r15 -HScroll -VScroll ReadOnly Multi -Tabstop WantCtrlA", "")
pd2 := main.Add("Edit",      "x" . 5 + ((elemwidth + 5) * 0) . " y280 w" . elemwidth . " r15 -HScroll -VScroll ReadOnly Multi -Tabstop WantCtrlA", "")
pd3 := main.Add("Edit",      "x" . 5 + ((elemwidth + 5) * 1) . " y30  w" . elemwidth . " r15 -HScroll -VScroll ReadOnly Multi -Tabstop WantCtrlA", "")
pd4 := main.Add("Edit",      "x" . 5 + ((elemwidth + 5) * 1) . " y280 w" . elemwidth . " r15 -HScroll -VScroll ReadOnly Multi -Tabstop WantCtrlA", "")

perkChanged(sender, *)
{
    global
    switch (sender)
    {
        case cb1:
            change := pd1
        case cb2:
            change := pd2
        case cb3:
            change := pd3
        case cb4:
            change := pd4
    }

    if ((newtxt := perkMappings.Get(sender.Text, "")) == "")
    {
        OutputDebug("Attempted retrieval for " . sender.Text . " failed.`n")
        newtxt := ""
    }
    else
    {
        ; A value was found for the "search term", so there must be a match in the perks Array, so attempt to correct the capitalization
        sender.Text := perks[codebase.collectionOperations.arrayOperations.arrayContains(perks, sender.Text, false)[1]]
        change.Value := newtxt
    }
}

main.Show("x" . x . " y" . y)
