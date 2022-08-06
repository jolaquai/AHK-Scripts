#Include #Includes\ahk-codebase.ah2
#Include #Includes\siege.ah2

eh := ""
OnError(handle, -1)
handle(err, ret)
{
    if (InStr(err.Message, "function recursion limit exceeded"))
    {
        if (
            MsgBox(
                "
                (
                    Too many Operators were excluded to perform a random pick!
                    The script must reload.
                    Would you like to copy the list of Operators you tried to omit?
                )",
            ,
            codebase.msgboxopt.buttons.yesno
            ) == "Yes"
        )
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
 * If an Operator `nickname` matches one of the strings in this Array, it will never be picked.
 *
 * Any Operator `nickname`s specified in the options panel's `opsToOmit` Edit control will be combined with this.
 * @note Operator `nickname`s specified here will not be included in "Excluding..." lists above picks.
 */
hardcodedOmit := [
    
]

; Operator Random Pick GUI
initThisManyOperatorSlots := 3
oprpgui := Gui(, mainguittitle)
oprpgui.OnEvent("Close", (*) => ExitApp(0))

oprpgui.Add("Text", "x10 y10 w350 r1 Center", "Defender" . (initThisManyOperatorSlots > 1 ? "s" : ""))
oprpgui.Add("Text", "x420 y10 w350 r1 Center", "Attacker" . (initThisManyOperatorSlots > 1 ? "s" : ""))

opt := Gui(, optguititle)
opt.OnEvent("Escape", Hide)
opt.OnEvent("Close", Hide)
opts := {
    ; Whether to omit the Operators that were picked during the LAST pick
    excludePreviousPicks: opt.Add("Checkbox", "Checked", "Exclude previous three Operators from next first pick"),
    ; Whether Operators specified in the Edit control below will be omitted from the next pick
    excludeSpecifiedOps: opt.Add("Checkbox", "wp Checked", "Exclude the following Operators from all picks`n(Both ATK and DEF, delimited by `"comma space`")"),
    ; Operator `nickname`s specified here will not be included in "Excluding..." lists above picks
    opsToOmit: opt.Add("Edit", "wp r4 WantReturn -HScroll -VScroll")
}

opts.opsToOmit.OnEvent("LoseFocus", opsToOmit_Change)
/**
 * When the user changes the value of the Edit control `opsToOmit`, this function is called.
 * - Set `omitFuncMustBeCalled` to `true`
 * - If the user has made the `opsToOmit` Edit control blank, set `combinedOmit` to `hardcodedOmit` and return
 * - Otherwise, split the value of `opsToOmit` by "comma space"
 * - Set `combinedOmit` to the resulting Array combined with `hardcodedOmit`
 * - If `combinedOmit` now contains enough Operators so that there are potentially not enough Defenders or Attackers left to pick exactly `initThisManyOperatorSlots`, warn the user about their input
 */
opsToOmit_Change(*)
{
    global combinedOmit, hardcodedOmit, warned, omitFuncMustBeCalled := true

    if (!(opts.excludeSpecifiedOps.Value))
    {
        combinedOmit := hardcodedOmit
        return
    }

    split := StrSplit(opts.opsToOmit.Value, ', ')
    combinedOmit := codebase.collectionOperations.arrayOperations.arrayConcat(hardcodedOmit, split)
    if (combinedOmit.Length >= (Min(siege.attackers.list.Length, siege.defenders.list.Length) - initThisManyOperatorSlots + 1))
    {
        MsgBox("Warning!`nThe amount of omitted Operators may lead to errors being thrown (" . split.Length . "). If this happens, the script reloads and the list of omitted Operators is lost.`nConsider omitting less Operators!")
    }
}
opsToOmit_Change()
opts.opsToOmit.OnEvent("Focus", opsToOmit_WarnAboutMisuse)
/**
 * When the user focuses the Edit control `opsToOmit`, this function is called.
 * - If the user has not been warned about the more or less bad programming of the `opsToOmit` Edit control (i.e. `warned` has not been initialized), warn them
 * - Set `warned` to true
 */
opsToOmit_WarnAboutMisuse(*)
{
    if (!IsSet(warned))
    {
        MsgBox(
            "
            (
                Warning!
                The functions that handle excluding Operators from picks are FAR from perfect and I'm still working on them.
                That said, they DO work if used correctly. As such, here's a few tips to KEEP them working:
                - If there's anything in the edit field that is NOT an Operator name, spelled as it should be (i.e. "Capitão" needs the "ã"), it will not have any effect on the pick, AND the misspelled name MIGHT show up in the list of excluded Operators at some point. It shouldn't, but it has, for some reason.
                    - That said, it IS possible to specify just "a" as an "excluded Operator" and it will still work, however, it will match ANY Operator whose name contains "a" (i.e. "a" will match Ace, Alibi, ..., Dokkaebi, Ela, Finka, Glaz, Hibana, ..., Wamai, Warden, Zofia)
                - Check the list before trusting a random pick. Operators specified in the list are NOT displayed as excluded so that the Text control doesn't become cluttered with Operator names if many are excluded.
                - After changing the list, no matter which button is pressed, BOTH Operator classes will be randomized to apply the changes.
            )"
        )
    }
    global warned := true
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

/**
 * Which Defenders are not to be picked. This is updated with every pick for the Defenders, meaning it will contain a total of `combinedOmit.Length + initThisManyOperatorSlots` elements after a run has finished.
 */
defomit := combinedOmit
/**
 * Which Attackers are not to be pickeacd. This is updated with every pick for the Attackers, meaning it will contain a total of `combinedOmit.Length + initThisManyOperatorSlots` elements after a run has finished.
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
    global omitFuncMustBeCalled, combinedOmit, opts, challengechance
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

    ; If the user has turned off the option to omit the previous picked Operators, the class's list of omitted Operators is set to `combinedOmit`
    if (!(opts.excludePreviousPicks.Value))
    {
        %classomit% := combinedOmit.Clone()
    }

    Loop %cnames%.Length
    {
        ; "Excluding..." string shenanigans
        omitInters := codebase.collectionOperations.arrayOperations.arrayIntersect(%classomit%, combinedOmit)
        omitparts := []
        for str in %classomit%
        {
            if (!(codebase.collectionOperations.arrayOperations.arrayContains(omitInters, str).Length))
            {
                omitparts.Push(str)
            }
        }
        s := codebase.stringOperations.strJoin(', ', true, omitparts*)
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

    ; If the list of Operators to omit has changed, multiple calls to `generate` must be made to ensure the new exclusion list takes effect
    if (omitFuncMustBeCalled)
    {
        omitFuncMustBeCalled := false
        generate(defbtn)
        generate(defbtn)
        generate(atkbtn)
        generate(atkbtn)
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