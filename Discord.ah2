#Include ".\#Includes\ahk-codebase.ah2"

cmd := "C:\Users\User\AppData\Local\Discord\app-1.0.9005\Discord.exe"

sub(obj, inf)
{
    if (ck.Value = 1)
    {
        if (WinExist("ahk_exe Discord.exe"))
        {
            try
            {
                id := WinGetPID("ahk_exe Discord.exe")
                ProcessClose(id)
            }
        }
    }

    if (radio[1].Value)
        Run(cmd)
    else if (radio[2].Value)
        Run(cmd . " --vanilla")
    else
    {
        ; This should never happen. Contact the authorities.
    }

    g.Destroy()
}

g := Gui()

radio := [
    g.Add("Radio", "Group Checked", "BetterDiscord"),
    g.Add("Radio", "", "Vanilla")
]

ck := g.Add("CheckBox", "Checked", "Kill Discord?")

bt := g.Add("Button", "Default w120", "OK")
bt.OnEvent("Click", sub)

g.Show()