paths := [
    "C:\Users\User\Pictures\Roblox",
    "C:\Users\User\Documents\ShareX\Screenshots"
]

for p in paths
{
    try
    {
        DirDelete(p, true)
    }
    catch (Error as e)
    {
        MsgBox(e.Message . "`n`nfrom: < " . e.What " >`n`n" . e.Stack)
    }
}

Loop Files "E:\YOUTUBE\Captures\*", "D"
{
    try DirDelete(A_LoopFileFullPath, false)
}
