; For the love of all things holy, DON'T import this anywhere just for teh lulz
; Having this loaded in a `Persistent(true)` script causes a permanent 19 MB memory usage increase

; Import the codebase library to allow calls to some often-needed functions and more
#Include ahk-codebase.ah2

class Dictionary
{
    static GuiAccess := {
        gui: Gui(),
        input: "",
        rs: []
    }

    static buildMappings()
    {
        words := []
        
        Loop Read, "F:\PROGRAMMING\AHK Scripts\#Includes\dict.csv"
        {
            if (A_Index == 1)
            {
                continue
            }
            Loop Parse, A_LoopReadLine, "CSV"
            {
                if (
                    A_Index !== 1
                ;|| SubStr(A_LoopField, -1) == "-"
                 || InStr(A_LoopField, "-")
                 || InStr(A_LoopField, "'")
                 || InStr(A_LoopField, " ")
                 || (words.Length ? words[-1] == A_LoopField : false)
                )
                {
                    break
                }
                
                words.Push(A_LoopField)
            }
        }

        Dictionary.GuiAccess.input := Dictionary.GuiAccess.gui.Add("Edit",   "x5   y5  r1  w800")
        inChng(ctrl, *)
        {
            words := Dictionary.contains(ctrl.Value)

            Dictionary.GuiAccess.rs[1].Opt("-Redraw")
            Dictionary.GuiAccess.rs[2].Opt("-Redraw")
            Dictionary.GuiAccess.rs[3].Opt("-Redraw")
            Dictionary.GuiAccess.rs[4].Opt("-Redraw")

            Dictionary.GuiAccess.rs[1].Delete()
            Dictionary.GuiAccess.rs[2].Delete()
            Dictionary.GuiAccess.rs[3].Delete()
            Dictionary.GuiAccess.rs[4].Delete()

            Dictionary.GuiAccess.rs[1].Add(codebase.collectionOperations.arrayOperations.subarray(words, 1,                            Floor(words.Length * (1 / 4))))
            Dictionary.GuiAccess.rs[2].Add(codebase.collectionOperations.arrayOperations.subarray(words, Ceil(words.Length * (1 / 4)), Floor(words.Length * (2 / 4))))
            Dictionary.GuiAccess.rs[3].Add(codebase.collectionOperations.arrayOperations.subarray(words, Ceil(words.Length * (2 / 4)), Floor(words.Length * (3 / 4))))
            Dictionary.GuiAccess.rs[4].Add(codebase.collectionOperations.arrayOperations.subarray(words, Ceil(words.Length * (3 / 4)), words.Length))

            Dictionary.GuiAccess.rs[1].Opt("+Redraw")
            Dictionary.GuiAccess.rs[2].Opt("+Redraw")
            Dictionary.GuiAccess.rs[3].Opt("+Redraw")
            Dictionary.GuiAccess.rs[4].Opt("+Redraw")
        }
        Dictionary.GuiAccess.input.OnEvent("Change", inChng)
        Dictionary.GuiAccess.rs.Push(Dictionary.GuiAccess.gui.Add("ListBox", "x5   y30 r40 w200"))
        Dictionary.GuiAccess.rs.Push(Dictionary.GuiAccess.gui.Add("ListBox", "x205 y30 r40 w200"))
        Dictionary.GuiAccess.rs.Push(Dictionary.GuiAccess.gui.Add("ListBox", "x405 y30 r40 w200"))
        Dictionary.GuiAccess.rs.Push(Dictionary.GuiAccess.gui.Add("ListBox", "x605 y30 r40 w200"))
        ;Dictionary.GuiAccess.gui.Show()

        return words
    }
    static _data := Dictionary.buildMappings()

    static contains(str, shuffle := false, maxLength?)
    {
        _is := codebase.collectionOperations.arrayOperations.arrayContainsPartial(Dictionary._data, str)
        w := []
        if (IsSet(maxLength))
        {
            for i in _is
            {
                if (StrLen(Dictionary._data[i]) <= maxLength)
                {
                    w.Push(Dictionary._data[i])
                }
            }
        }
        else
        {
            w := codebase.collectionOperations.arrayOperations.evaluate((i) => Dictionary._data[i], _is)
        }
        return (shuffle ? codebase.collectionOperations.arrayOperations.arrShuffle(w) : w)
    }
}