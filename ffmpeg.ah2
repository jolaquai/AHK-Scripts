; Import the codebase library to allow calls to some often-needed functions and more
#Include ".\#Includes\ahk-codebase.ah2"

mt := MsgBox("Multi-thread mode?`nThis uses ``Run()`` instead of ``RunWait()``.", , 0x3)
switch (mt)
{
    case "Yes":
        mt := true
    case "No":
        mt := false
    case "Cancel":
        ExitApp()
}

/**
 * Initial directory when picking the input file.
 */
initdir := "E:\YOUTUBE\Captures"

/**
 * The variable `SplitPath()` will store the file name of the input file in.
 */
f := ""

/**
 * The variable `SplitPath()` will store the file extension of the input file in.
 */
ext := ""

/**
 * The variable `SplitPath()` will store the path to the directory of the input file in.
 */
dir := ""

g := Gui()

g.Add("Text", , "Input file (click for a file picker)")
input := g.Add("Edit", "r1 w300", codebase.directoryOperations.getNewest(initdir, false, "*.mp4"))
inputchoose := g.Add("Button", , "Choose input")
inputchoose.OnEvent("Click", input_rc)
input_rc(*)
{
    if (input.Value := FileSelect( , initdir))
    output_reset()
}

g.Add("Text", , "Output file name and extension (click for a file picker)`nOutput will be in the same directory as input.")
output := g.Add("Edit", "r1 w300")
outputchoose := g.Add("Button", , "Choose output")
outputchoose.OnEvent("Click", output_rc)
output_rc(*)
{
    global dir, ext, fn
    sel := FileSelect("S", initdir . "\" . fn . "-c." . ext)
    SplitPath(sel, , &d, &e, &f)
    if (sel)
        output.Value := f . ext
    else
        output_reset()

}
outputreset := g.Add("Button", , "Reset output")
outputreset.OnEvent("Click", output_reset)
output_reset(*)
{
    global dir, ext, fn
    if (input.Value == "")
        return

    try
    {
        SplitPath(input.Value, , &dir, &ext, &fn)
        output.Value := fn . "-c." . ext
    }
}
output_reset()

g.Add("Text", , "-ss")
ss := g.Add("Edit", "r1 w150")

g.Add("Text", , "-to / -t")
to := g.Add("Edit", "r1 w150")
t := g.Add("Checkbox", "-Wrap", "Use -t")

g.Add("Text", , "Force Bitrate (custom comp., overrides preset)")
br := g.Add("Edit", "r1 w150")

shareMode := g.Add("Checkbox", , "Sharing Mode (undersample, lower res)")

/**
 * The string of encoding options to use when ticking the `reencode` checkbox.
 */
encodeop := "-c:a copy -c:v libx264 -crf 00"

reenctext := g.Add("Text", "x10", "Re-encode (veeeery slow | " . encodeop . ")`nDo not check if input and output formats differ.")
reencode := g.Add("Checkbox", "-Wrap", "Re-encode (compress)")
crf28 := g.Add("Radio", "w50 Checked", "28")
crf28.OnEvent("Click", crfchange)
crf32 := g.Add("Radio", "w50 xp+55", "32")
crf32.OnEvent("Click", crfchange)
crf36 := g.Add("Radio", "w50 xp+55", "36")
crf36.OnEvent("Click", crfchange)
crfchange(caller, *)
{
    global
    encodeop := SubStr(encodeop, 1, StrLen(encodeop) - 2) . caller.Text
    reenctext.Value := "Re-encode (veeeery slow | " . encodeop . ")`nDo not check if input and output formats differ."
}
crfchange(crf28)

exec := g.Add("Button", "x10 Default w300", "Execute")
exec.OnEvent("Click", exec_c)
exec_c(*)
{
    if (br.Value)
    {
        c := 'ffmpeg '
        . (ss.Value !== "" ? "-ss " . ss.Value . " " : "")
        . (to.Value !== "" ? (t.Value ? "-t " : "-to ") . to.Value . " " : "")
        . '-i "' . input.Value . '"' . " "
        . "-b " . br.Value . " "
        . (shareMode.Value ? '-filter:v "fps=fps=30, scale=1600:900" -r 30 ': "")
        . '"' . dir . "\" . output.Value . '"'
    }
    else
    {
        c := 'ffmpeg '
        . (ss.Value !== "" ? "-ss " . ss.Value . " " : "")
        . (to.Value !== "" ? (t.Value ? "-t " : "-to ") . to.Value . " " : "")
        . '-i "' . input.Value . '"' . " "
        . (shareMode.Value ? '-filter:v "fps=fps=30, scale=1600:900" -r 30 ': "") . " "
        . (reencode.Value ? encodeop : (shareMode.Value ? "" : "-c copy")) . " "
        . '"' . dir . "\" . output.Value . '"'
    }

    A_Clipboard := c
    if (MsgBox(c, , 0x4) == "Yes")
    {
        if (mt)
        {
            Run(A_ComSpec . ' /k ' . c)
        }
        else
        {
            r := RunWait(c)

            if (r !== 0)
            {
                MsgBox("ffmpeg finished with error code " . r)
                Run(A_ComSpec . ' /c err ' . r)
            }
        }
    }
}

switchmode := g.Add("Button", "w300 r3")
switchmode.OnEvent("Click", switchmode_c)
switchmode_c()
switchmode_c(*)
{
    static runonce := true
    global mt
    if (runonce)
    {
        runonce := false
        mt := !mt
    }
    mt := !mt
    switchmode.Text := "Currently in " . (!mt ? "single-thread" : "multi-thread") . " mode`n" .
        (!mt ? "Only one ffmpeg process can currently run" : "") . "`n" .
        "Click to switch to " . (mt ? "single-thread" : "multi-thread") . " mode"
}

g.Show()