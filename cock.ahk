; Import the codebase library to allow calls to some often-needed functions and more
#Include .\#Includes\ahk-codebase.ahk

f := "C:\Users\leon\AppData\Roaming\BetterDiscord\themes\Black Minimalistica.theme.css"
snip := "C:\Users\leon\OneDrive\Desktop\Snip\Snip_Metadata.json"

discordThemeUpdate()
{
    theme := FileRead(f)
    s := InStr(theme, '`t--background-image: /* AHK */')

    theme := FileOpen(f, "rw")
    line := '`t--background-image: /* AHK */ url("{url}");`r`n}'
    codebase.stringOperations.strComposite(&line, { url: codebase.requests.parseJson(FileRead(snip))["album"]["images"][1]["url"] })
    theme.Seek(s - 1, 0)
    theme.Write(line)
    theme.Close()
}

SetTimer(discordThemeUpdate, 2500)