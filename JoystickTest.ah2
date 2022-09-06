; Auto-detect which joysticks there are
joysticks := []
Loop 16
{
    if (GetKeyState(A_Index . "JoyName"))
        joysticks.Push(A_Index)
}

if (joysticks.Length == 0)
{
    MsgBox("No joysticks connected.")
    ExitApp(0)
}

+Escape::Reload()

#SingleInstance

w := 300

editMap := Map()
joyGui := Gui()
joyGui.OnEvent("Close", (*) => ExitApp())
joyGui.Add("Text", "w" . w, "(Dis)Connecting controllers while this window is open will produce Errors!`n")

for js in joysticks
{
    joyGui.Add("Text", , "Joystick Info #" . js)
    editMap[js] := joyGui.Add("Edit", "ReadOnly r3 w" . w, "")
}
joyGui.Show()

Loop
{
    for js in joysticks
    {
        joy_buttons := GetKeyState(js . "JoyButtons")
        joy_name := GetKeyState(js . "JoyName")
        joy_info := GetKeyState(js . "JoyInfo")

        buttons_down := ""
        Loop joy_buttons
        {
            if GetKeyState(js . "Joy" A_Index)
                buttons_down .= " " A_Index
        }

        axis_info := "X" Round(GetKeyState(js . "JoyX"))
        axis_info .= "  Y" Round(GetKeyState(js . "JoyY"))

        if InStr(joy_info, "Z")
            axis_info .= "  Z" Round(GetKeyState(js . "JoyZ"))
        if InStr(joy_info, "R")
            axis_info .= "  R" Round(GetKeyState(js . "JoyR"))
        if InStr(joy_info, "U")
            axis_info .= "  U" Round(GetKeyState(js . "JoyU"))
        if InStr(joy_info, "V")
            axis_info .= "  V" Round(GetKeyState(js . "JoyV"))
        if InStr(joy_info, "P")
            axis_info .= "  POV" Round(GetKeyState(js . "JoyPOV"))

        val := 
        (
            axis_info
            "`nButtons:`n"
            buttons_down
        )

        if (!(editMap[js].Value == val))
            editMap[js].Value := val
    }
}