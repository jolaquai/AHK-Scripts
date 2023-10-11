; Import the codebase library to allow calls to some often-needed functions and more
#Include #Includes\ahk-codebase.ahk

MainWindow := Gui(, "Mortuary Assistant Gameplay Helper")
MainWindow.Add("Text", "w600 r2 x5 y5 Center", "Choose the sigils the game reveals to you to automatically find the correct demon.`nDepending on which demon it is, 2 or 4 sigils may be required.")

ImagePathBase := EnvGet("userprofile") . "\Documents\MAHelper\"
Sigils := [
    codebase.Path(ImagePathBase . "lowercase_q.png"),      ; 1
    codebase.Path(ImagePathBase . "h_backtick.png"),       ; 2
    codebase.Path(ImagePathBase . "h_tick.png"),           ; 3
    codebase.Path(ImagePathBase . "t_twostroke.png"),      ; 4
    codebase.Path(ImagePathBase . "h_apostrophe.png"),     ; 5
    codebase.Path(ImagePathBase . "h_wavyarrow.png"),      ; 6
    codebase.Path(ImagePathBase . "l_thicc.png"),          ; 7
    codebase.Path(ImagePathBase . "j_tick.png"),           ; 8
    codebase.Path(ImagePathBase . "magnifying_glass.png"), ; 9
    codebase.Path(ImagePathBase . "fancy_three.png"),      ; 10
    codebase.Path(ImagePathBase . "ship_mast.png"),        ; 11
    codebase.Path(ImagePathBase . "tempest.png")           ; 12
]
Sigil_Empty := codebase.Path(ImagePathBase . "_EMPTY.png")

CB_Sigils := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
IM_Sigils := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
Sigils_Display := [1, 2, 3, 4]

; Possible TODO: find unique n-length combinations in Arrays
Demons := Map(
    "Variketh", [ 3,  4,  9,  2],
    "Fermok",   [ 4,  6,  9, 10],
    "Teshak",   [ 6,  5, 11, 12],
    "Uzkaret",  [ 8, 10,  1,  3],
    "Balmet",   [ 2,  6,  4,  1],
    "Anek",     [ 9,  4,  5,  6],
    "Telduk",   [ 4, 11,  8,  1],
    "Sebbos",   [ 9,  2,  8,  1],
    "Shadat",   [ 3,  8,  7,  9],
    "Azel",     [11,  1,  8,  7],
    "Kovos",    [ 5,  6, 11,  9],
    "Maset",    [ 2,  9,  3,  8]
)

Loop 6
{
    CB_Sigils[A_Index] := MainWindow.Add("Checkbox", "Disabled w90 -Wrap r1 x" . (5 + ((A_Index - 1) * 100) + (5 * (A_Index - 1))) . " y35 Center", Sigils[A_Index].nameNoExt)
    (IM_Sigils[A_Index] := MainWindow.Add("Picture", "Border w90 h90 x" . (5 + ((A_Index - 1) * 100) + (5 * (A_Index - 1))) . " y50", Sigils[A_Index].ToString())).OnEvent("Click", imgclick)

    CB_Sigils[A_Index + 6] := MainWindow.Add("Checkbox", "Disabled w90 -Wrap r1 x" . (5 + ((A_Index - 1) * 100) + (5 * (A_Index - 1))) . " y150 Center", Sigils[A_Index + 6].nameNoExt)
    (IM_Sigils[A_Index + 6] := MainWindow.Add("Picture", "Border w90 h90 x" . (5 + ((A_Index - 1) * 100) + (5 * (A_Index - 1))) . " y165", Sigils[A_Index + 6].ToString())).OnEvent("Click", imgclick)
}
imgclick(ctrl, info)
{
    clear()
    {
        for cb in CB_Sigils
        {
            cb.Value := false
        }
        FoundDemon.Text := ""
        for sd in Sigils_Display
        {
            sd.Value := Sigil_Empty.ToString()
        }
    }

    global

    LB_Demons.Choose(0)

    imgI := codebase.collectionOperations.arrayOperations.arrayContains(IM_Sigils, ctrl)[1]
    CB_Sigils[imgI].Value := !(CB_Sigils[imgI].Value)
    checked := []
    for cb in CB_Sigils
    {
        if (cb.Value)
        {
            checked.Push(A_Index)
        }
    }
    if (checked.Length > 4)
    {
        clear()
        return
    }
    else
    {
        for i in codebase.range(4, checked.Length !== 0 ? checked.Length : 1)
        {
            Sigils_Display[i].Value := Sigil_Empty.ToString()
        }
    }
    
    for index, image in checked
    {
        Sigils_Display[index].Value := Sigils[image].ToString()
    }

    possibledemons := []
    for name, sigils in Demons
    {
        intersect := codebase.collectionOperations.arrayOperations.arrayIntersect(checked, sigils)
        if (intersect.Length == 4)
        {
            possibledemons := [{ Name: name, Sigils: sigils }]
            break
        }
        else if (intersect.Length == checked.Length)
        {
            possibledemons.Push({ Name: name, Sigils: sigils })
        }
        FoundDemon.Text := ""
    }
    if (intersect.Length < 4 && checked.Length == 4 && possibledemons.Length == 0)
    {
        possibledemons := []
        clear()
        FoundDemon.Text := "Invalid sigil combination!"
    }
    if (possibledemons.Length == 1)
    {
        FoundDemon.Text := possibledemons[1].Name
        Sigils_Display[1].Value := Sigils[possibledemons[1].Sigils[1]].ToString()
        Sigils_Display[2].Value := Sigils[possibledemons[1].Sigils[2]].ToString()
        Sigils_Display[3].Value := Sigils[possibledemons[1].Sigils[3]].ToString()
        Sigils_Display[4].Value := Sigils[possibledemons[1].Sigils[4]].ToString()
        Exit()
    }
}

MainWindow.Add("Text", "x5 y265 w50", "Demon:")
FoundDemon := MainWindow.Add("Edit", "ReadOnly x55 yp-3 Center w250", "")

Sigils_Display[1] := MainWindow.Add("Picture", "w90 h90 y265 x415 Border", Sigil_Empty.ToString())
Sigils_Display[2] := MainWindow.Add("Picture", "w90 h90 y360 x515 Border", Sigil_Empty.ToString())
Sigils_Display[3] := MainWindow.Add("Picture", "w90 h90 y455 x415 Border", Sigil_Empty.ToString())
Sigils_Display[4] := MainWindow.Add("Picture", "w90 h90 y360 x315 Border", Sigil_Empty.ToString())

MainWindow.Add("Text", "w300 r1 y285 x5 Center", "Or select a Demon here to view its sigils.")
LB_Demons := MainWindow.Add("ListBox", "w300 r" . codebase.collectionOperations.mapOperations.getKeys(Demons).Length . " yp+15 x5 -Multi", codebase.collectionOperations.mapOperations.getKeys(Demons))
LB_Demons.OnEvent("Change", demonselected)
demonselected(ctrl, info)
{
    static previous := ""
    for cb in CB_Sigils
    {
        cb.Value := false
    }

    if (LB_Demons.Text !== previous)
    {
        previous := LB_Demons.Text

        FoundDemon.Text := LB_Demons.Text
        for sd in Sigils_Display
        {
            sd.Value := Sigil_Empty.ToString()
        }

        demon := Demons.Get(LB_Demons.Text)
        Sigils_Display[1].Value := Sigils[demon[1]].ToString()
        Sigils_Display[2].Value := Sigils[demon[2]].ToString()
        Sigils_Display[3].Value := Sigils[demon[3]].ToString()
        Sigils_Display[4].Value := Sigils[demon[4]].ToString()
    }
}

MainWindow.Show()
