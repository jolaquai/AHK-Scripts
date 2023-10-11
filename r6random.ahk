#Include #Includes\ahk-codebase.ah2
#Include #Includes\siege.ah2

eh := ""
OnError(handle, -1)
handle(err, ret)
{
    if (InStr(err.Message, "function recursion limit exceeded"))
    {
        if (MsgBox("Too many Operators were excluded to perform a random pick and the script must reload.`nWould you like to copy the list of Operators you tried to omit?", "Error", codebase.msgboxopt.buttons.yesno) == "Yes")
        {
            A_Clipboard := opts.opsToOmit.Value
        }
        Reload()
    }
    return 0
}

mainguittitle := "Operator Random Pick"
optguititle := "Options"

/**
 * The chance of generating a challenge for a generated Operator in %.
 *
 * The largest error to expect from the actual generation is about 5% as the random number generation algorithm of AHKv2 is _sufficiently_ random to somewhat stick to defined chances when the calculations are done correctly.
 */
challengechance := 30
/**
 * If an Operator `nickname` matches one of the strings in this Array, it will never be picked. Any Operators not checked in the options panel will be combined with this. Operators ending here will not be included in "Excluding..." lists above picks.
 */
hardcodedOmit := [
    
]

; Operator Random Pick GUI
initThisManyOperatorSlots := (A_Args.Length == 1 ? A_Args[1] : 2)
oprpgui := Gui(, mainguittitle)
oprpgui.OnEvent("Close", (*) => ExitApp(0))

oprpgui.Add("Text", "x10 y10 w350 r1 Center", "Defender" . (initThisManyOperatorSlots > 1 ? "s" : ""))
oprpgui.Add("Text", "x420 y10 w350 r1 Center", "Attacker" . (initThisManyOperatorSlots > 1 ? "s" : ""))

opt := Gui(, optguititle)
opt.OnEvent("Escape", Hide)
opt.OnEvent("Close", Hide)
opts := {
    ; Whether to omit the Operators that were picked during the LAST pick
    excludePreviousPicks: opt.Add("Checkbox", "x10 y10 Checked y10", "Exclude previous " . (initThisManyOperatorSlots * 2) . " Operators from next first pick"),
    ; Whether only Operators checked in the checkboxes below will be chosen
    includeOnlyTheseOps: opt.Add("Checkbox", "x10 y25 Checked", "Only include the following Operators when picking"),
    ; Operators checked here will not be included in "Excluding..." lists above picks
    whichOps: populateOperatorCheckboxes()
}
populateOperatorCheckboxes()
{
    global checkboxOmit, combinedOmit
    clicked(ctrl, info)
    {
        if (ctrl.Value == 1)
        {
            checkboxOmit := codebase.collectionOperations.arrayOperations.remove(checkboxOmit, [ctrl.Text])
        }
        else
        {
            checkboxOmit.Push(ctrl.Text)
        }
    }

    arr := []
    for op in siege.defenders()
    {
        check := opt.Add("Checkbox", "x30 y" . (45 + (15 * (A_Index - 1))) . " Checked Left", op.nickname)
        check.OnEvent("Click", clicked)
        arr.Push(check)
    }
    for op in siege.attackers()
    {
        check := opt.Add("Checkbox", "x140 y" . (45 + (15 * (A_Index - 1))) . " Checked Left", op.nickname)
        check.OnEvent("Click", clicked)
        arr.Push(check)
    }
}

optpnlshow := false
optpnl := oprpgui.Add("Button", "x10 y30 w810 r1 Center", "Show Options Panel")
optpnl.OnEvent("Click", optpnl_Click)
/**
 * When the user clicks the "Show/Hide Options Panel" button, this function is called.
 * - Toggle and remember the state of the Options Panel by settings `optpnlshown` to the opposite of its current value
 * - If the Options Panel is visible, hide it
 * - If the Options Panel is hidden, show it; specifically, make it visible and position it next to the main GUI
 */
optpnl_Click(*)
{
    global optpnlshow := !optpnlshow
    if (optpnlshow)
    {
        WinGetPos(&x, &y, &w, , mainguittitle)
        optpnl.Text := "Hide Options Panel"
        opt.Show("x" . x + w + 10 . " y" . y)
    }
    else
    {
        Hide()
    }
}
/**
 * Hides the Options Panel.
 */
Hide(*)
{
    global optpnlshow
    optpnlshow := false
    optpnl.Text := "Show Options Panel"
    opt.Hide()
}

/**
 * The initial offset to apply when placing elements in the GUI.
 *
 * It should be set to a value that allows header elements to appear before the Operator pick slots.
 */
initoffset := 55
/**
 * How many pixels to leave as spacing between Operator pick slots.
 */
slotoffset := 20

checkboxOmit := []
combinedOmit := []
/**
 * Which Defenders are not to be picked. This is updated with every pick for the Defenders, meaning it will contain a total of `combinedOmit.Length + initThisManyOperatorSlots` elements after a run has finished.
 */
defomit := combinedOmit
/**
 * Which Attackers are not to be picked. This is updated with every pick for the Attackers, meaning it will contain a total of `combinedOmit.Length + initThisManyOperatorSlots` elements after a run has finished.
 */
atkomit := combinedOmit

/**
 * The Text controls that display which Defenders are excluded from the _current_ pick.
 */
defexclude := []
/**
 * The read-only Edit controls that display the nickname of the current pick's Defender.
 */
defnames := []
/**
 * The read-only Edit controls that display the primary weapon and attachments of the current pick's Defender.
 */
defprims := []
/**
 * The read-only Edit controls that display the secondary weapon and attachments of the current pick's Defender.
 */
defsecs := []
/**
 * The read-only Edit controls that display the gadget of the current pick's Defender.
 */
defgdgs := []
/**
 * The read-only Edit controls that display the challenge for the current pick's Defender.
 */
defchln := []

/**
 * The Text controls that display which Attackers are excluded from the _current_ pick.
 */
atkexclude := []
/**
 * The read-only Edit controls that display the nickname of the current pick's Attacker.
 */
atknames := []
/**
 * The read-only Edit controls that display the primary weapon and attachments of the current pick's Attacker.
 */
atkprims := []
/**
 * The read-only Edit controls that display the secondary weapon and attachments of the current pick's Attacker.
 */
atksecs := []
/**
 * The read-only Edit controls that display the gadget of the current pick's Attacker.
 */
atkgdgs := []
/**
 * The read-only Edit controls that display the challenge for the current pick's Attacker.
 */
atkchln := []

for in codebase.range(1, initThisManyOperatorSlots)
{
    ; Element offset
    yoffset := initoffset + 5 + ((146 + slotoffset) * (A_Index - 1))

    ; Defender elements
    defexclude.Push(oprpgui.Add("Text", "x10 y" . yoffset . " r1 w400", "Excluding "))

    defnames.Push(oprpgui.Add("Edit", "x10 y" . 20 + yoffset . " ReadOnly -VScroll -HScroll r1 w400", "Operator"))
    oprpgui.Add("Text", "x10 y" . 45 + yoffset . " r1 w200 Center", "Primary")
    oprpgui.Add("Text", "x210 y" . 45 + yoffset . " r1 w200 Center", "Secondary")
    defprims.Push(oprpgui.Add("Edit", "x10 y" . 65 + yoffset . " ReadOnly -VScroll -HScroll r4 w200", "Primary"))
    defsecs.Push(oprpgui.Add("Edit", "x210 y" . 65 + yoffset . " ReadOnly -VScroll -HScroll r4 w200", "Secondary"))
    defgdgs.Push(oprpgui.Add("Edit", "x10 y" . 130 + yoffset . " ReadOnly -VScroll -HScroll r1 w400", "Gadget"))

    ; Attacker elements
    atkexclude.Push(oprpgui.Add("Text", "x420 y" . yoffset . " r1 w400", "Excluding "))

    atknames.Push(oprpgui.Add("Edit", "x420 y" . 20 + yoffset . " ReadOnly -VScroll -HScroll r1 w400", "Operator"))
    oprpgui.Add("Text", "x420 y" . 45 + yoffset . " r1 w200 Center", "Primary")
    oprpgui.Add("Text", "x620 y" . 45 + yoffset . " r1 w200 Center", "Secondary")
    atkprims.Push(oprpgui.Add("Edit", "x420 y" . 65 + yoffset . " ReadOnly -VScroll -HScroll r4 w200", "Primary"))
    atksecs.Push(oprpgui.Add("Edit", "x620 y" . 65 + yoffset . " ReadOnly -VScroll -HScroll r4 w200", "Secondary"))
    atkgdgs.Push(oprpgui.Add("Edit", "x420 y" . 130 + yoffset . " ReadOnly -VScroll -HScroll r1 w400", "Gadget"))
}

genclassoffset := initoffset + ((146 + slotoffset) * initThisManyOperatorSlots)
defbtn := oprpgui.Add("Button", "x10 y" . genclassoffset . " r1 w400", "Generate Defender" . (initThisManyOperatorSlots > 1 ? "s" : ""))
defbtn.OnEvent("Click", generate)

atkbtn := oprpgui.Add("Button", "x420 y" . genclassoffset . " r1 w400", "Generate Attacker" . (initThisManyOperatorSlots > 1 ? "s" : ""))
atkbtn.OnEvent("Click", generate)

bthoffset := genclassoffset + 25
bthbtn := oprpgui.Add("Button", "x10 y" . bthoffset . " r1 w810 Default", "Generate " . (initThisManyOperatorSlots > 1 ? "all" : "both"))
bthbtn.OnEvent("Click", generate)

/**
 * Generate random Operators for either or both roles, depending on which button called the function.
 * @param sender Which button called the function and thus must be one of `defbtn`, `atkbtn` or `bthbtn`. As no other parameters are needed, this may be passed explicitly instead of implicitly by clicking the button (i.e. for example, explicitly calling `generate(atkbtn)` is permitted).
 */
generate(sender, *)
{
    global checkboxOmit, combinedOmit, opts, challengechance
    global defomit, defexclude, defnames, defprims, defsecs, defgdgs, defchln
    global atkomit, atkexclude, atknames, atkprims, atksecs, atkgdgs, atkchln

    ; Determine which variables to access based on which button object was passed for `sender`
    switch (sender)
    {
        case defbtn:
            local classomit := &defomit
            local classexclude := &defexclude
            local pclass := siege.defenders

            local cnames := &defnames
            local cprims := &defprims
            local csecs := &defsecs
            local cgdgs := &defgdgs
        case atkbtn:
            local classomit := &atkomit
            local classexclude := &atkexclude
            local pclass := siege.attackers

            local cnames := &atknames
            local cprims := &atkprims
            local csecs := &atksecs
            local cgdgs := &atkgdgs
        case bthbtn:
            ; If `bthbtn` was clicked or explicitly passed, call this function once with `defbtn` and once with `atkbtn` passed as `sender`
            generate(defbtn)
            generate(atkbtn)
            return
    }

    if (opts.includeOnlyTheseOps.Value)
    {
        combinedOmit := codebase.collectionOperations.arrayOperations.arrayConcat(checkboxOmit, hardcodedOmit)
        combinedOmit := codebase.collectionOperations.arrayOperations.removeDuplicates(combinedOmit)
    }
    else
    {
        combinedOmit := hardcodedOmit
    }

    ; If the user has turned off the option to omit the previously picked Operators, the class's list of omitted Operators is set to `combinedOmit`
    if (!(opts.excludePreviousPicks.Value))
    {
        %classomit% := combinedOmit.Clone()
    }

    Loop %cnames%.Length
    {
        ; "Excluding..." string shenanigans
        s := codebase.stringOperations.strJoin(', ', true, codebase.collectionOperations.arrayOperations.arrayNotIntersect(%classomit%, combinedOmit)*)
        %classexclude%[A_Index].Value := "Excluding " . (s !== "" ? s : "nobody")

        ; Actual Operator / loadout generation
        ranop := siege.randomOperator(pclass, false, %classomit%)

        %cnames%[A_Index].Value := ranop.op.nickname
        %cprims%[A_Index].Value := ranop.loadout.primary.name . " (" . ranop.loadout.primary.type . ")" . "`nSight: " . ranop.loadout.primary.sight . "`nBarrel: " . ranop.loadout.primary.barrel . "`nGrip: " . ranop.loadout.primary.grip
        %csecs%[A_Index].Value := ranop.loadout.secondary.name . " (" . ranop.loadout.secondary.type . ")" . "`nBarrel: " . ranop.loadout.secondary.barrel . "`nLaser: " . ranop.loadout.secondary.laser
        %cgdgs%[A_Index].Value := ranop.loadout.gadget

        ; More exclusion shenanigans
        if (opts.excludePreviousPicks.Value && A_Index == 1)
        {
            %classomit% := codebase.collectionOperations.arrayOperations.arrayConcat(combinedOmit, [ranop.op.nickname])
        }
        else
        {
            %classomit%.Push(ranop.op.nickname)
        }
    }
}

generate(bthbtn)
oprpgui.Show()

cb(*)
{
    static mainX, mainY
    if (!optpnlshow)
    {
        return
    }

    WinGetPos(&mainX, &mainY, &mainW, , mainguittitle)
    WinGetPos(&optX, &optY, , , optguititle)
    if (optX !== mainX + mainW + 10 || optY !== mainY)
    {
        opt.Show("x" . mainX + mainW + 10 . " y" . mainY . (optpnlshow ? "" : " Hide"))
    }
}
SetTimer(cb, 100, -1)

; Set shortcut keys for the generation functions (Ctrl+Alt+D/A/B for Defender/Attacker/Both)
!^d::
{
    generate(defbtn)
    hwnd := WinActive("A")
    WinActivate(mainguittitle)
    WinActivate("ahk_id " . hwnd)
}
!^a::
{
    generate(atkbtn)
    hwnd := WinActive("A")
    WinActivate(mainguittitle)
    WinActivate("ahk_id " . hwnd)
}
!^b::
{
    generate(bthbtn)
    hwnd := WinActive("A")
    WinActivate(mainguittitle)
    WinActivate("ahk_id " . hwnd)
}