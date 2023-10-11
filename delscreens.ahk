; Import the codebase library to allow calls to some often-needed functions and more
#Include #Includes\ahk-codebase.ahk

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
        MsgBox(codebase.ErrorHandler.output(e))
    }
}

folders := codebase.directoryOperations.getFolders("E:\YOUTUBE\Captures", false)
for folder in folders.Clone()
{
    if (b := codebase.directoryOperations.isEmpty(folder))
    {
        try
        {
            DirDelete(folder, true)
        }
        catch
        {
            MsgBox(codebase.ErrorHandler.output(e))
        }
    }
}
