/**
 * My codebase library for most of my other AHK scripts.
 *
 * Notes:
 * - Dates should be interpreted as MM/DD/YYYY or MM/DD/YY.
 *
 * Coding conventions:
 * - The entire library is written to allow for easy modification and expansion, making the functions somewhat prone to changes. The idea is, however, to ensure that either all calls to functions only produce different results while leaving the function's syntax untouched (or only changed so that calls to it do not have to be changed to be valid, such as adding optional parameters), or that a syntax change is easy enough to fix using regex Find-and-Replace.
 * - Most comparisons are hard-coded case-sensitive (operator `==` instead of `=`). This does _not_ apply to functions the express use of which is string comparison, in which case an optional parameter allows for control over this. Most, if not all, default to `true`, i.e. a case-sensitive comparison. Additionally (as per AHKv2 behavior), case-sense is ignored for comparisons where one of the operands is not of type `String` (ex. objects).
 * - String concatenations are / should always be done explicitly: `"string 1" . " " . var` instead of `"string 1" " " var`.
 * - Most, if not all, cases where braces (`{ }`) _may_ be omitted, they _are_ present. I've recently (1/19/2022) noticed some extremely odd behavior relating to `if`s in any form of loop, be it introduced by `Loop` or `for`. The loop would sometimes be left prematurely, even though no `return` or `break` keywords were encountered. Adding braces prevented this from happening, which probably means the AHKv2 parser messes up somewhere and breaks out of the loop if an `if` clause executed incorrectly. It also did not _always_ do this, causing some confusion as to what this "incorrect execution" even is. I still haven't found an answer for that, but omitting braces seems to cause it, which is why I've decided to add them wherever appropriate (or possible, rather), even if this is only technically necessary when there's an `if` construct in the loop: `( {2,})((?:loop|for|if|else|try|catch|while).*\n)(.*)` and `$1$2$1{\n$3\n$1}`.
 * - The "Lower Camel Case" naming convention is followed (e.g. `mapOperations`, not `MapOperations`), except in class definitions when the intention of these is _not_ solely to hold `static` functions and constants, but to actually be instantiated into an object (e.g. `codebase.math.vectorGeometry.Vector`, not `codebase.math.vectorGeometry.vector`).
 * - On 8/19/2022, I made the switch to the `.ah2` file extension. You will very likely have to associate it with your AHKv2 executable in Windows before 
 *
 * The functions and some classes are annotated using comments, allowing IntelliSense to display parameter and other information. Basically, to get the most out of this, use the following commands (Windows):
 * - `code --install-extension zero-plusplus.vscode-autohotkey-debug`
 * - `code --install-extension thqby.vscode-autohotkey2-lsp`
 *
 * This "script" is a pure library. While it does technically contain an autorun section to set directives or similar, it will exit immediately upon finishing this.
 */
notes := ""

; Directives / pre-execution statements
; These don't usually need to be set in every new script but doing it might help in specific cases. They can be overridden at any time by calling the built-in setter functions or supplying #directives with other arguments than the ones in here.

eh := codebase.ErrorHandler([Error], codebase.ErrorHandler.reload)

#Include JSON.ah2
#Include MimeTypeMap.ah2
#Include UnicodeBlockMap.ah2
#Include HTTPStatusMap.ah2

SendMode("Event")
#SingleInstance force
Persistent(false)
SetTitleMatchMode(2)
#Warn Unreachable, Off
A_MenuMaskKey := ""

InstallKeybdHook(true, true)
InstallMouseHook(true, true)
#UseHook true

#WinActivateForce

CoordMode("ToolTip", "Screen")
CoordMode("Mouse", "Screen")
CoordMode("Pixel", "Screen")

SetKeyDelay(30, 10)
SetKeyDelay(30, 10, "Play")
SetMouseDelay(30)
SetMouseDelay(30, "Play")
SetScrollLockState(false)

scriptStartupDate := A_Now
scriptStartupTick := A_TickCount
/**
 * Whether a debugger has been attached to the script since script launch or reload (the latter of which is nearly impossible).
 *
 * Allows full control over what a script does and does not do if a debugger is attached. For example, timers may interrupt debugging sessions if their periods expire while the script is paused.
 * @note This is not 100% reliable:
 * - Does not update in real-time.
 * - Does not reflect the actual status if a debugger has attached to a running script.
 * - If the script calls `Reload` or is reloaded through `PostMessage`, a debug session, if any, is terminated. After a reload in this manner, this variable will most likely be `false`.
 *
 * Because of this, it is discouraged to attach a debugger to a script that is running.
 */
A_IsDebuggerAttached := !!InStr(codebase.WinInfo(A_ScriptHwnd, false).processQueryResult.CommandLine, "/Debug")

; Support the AHKv2-native practice of calling an object's `ToString` method if it cannot be stringified directly (which makes no sense if you think about it, cause there is no native `ToString` method)
Object.Prototype.DefineProp("ToString", { Call: codebase.collectionOperations.objectOperations.toString.Bind({ }) })

/**
 * The `codebase` class containing all the subclasses and functions.
 * To make calling them easier, create function references:
 * ```
 * arrCnt := codebase.collectionOperations.arrayOperations.arrayContains.Bind({ })
 * ```
 */
class codebase
{
    /**
     * Switches the values of two variables.
     * @param var1 A `VarRef` to the first variable.
     * @param var2 A `VarRef` to the second variable.
     */
    static switchVars(&var1, &var2)
    {
        temp := var2
        var2 := var1
        var1 := temp
    }

    /**
     * @returns The current Unix time (seconds since midnight, January 1, 1970) relative to UTC.
     */
    static getUnixTimeUTC() => DateDiff(A_NowUTC, codebase.constants.ahkTimeZero, "s")
    /**
     * @returns The current Unix time (seconds since midnight, January 1, 1970) relative to the local time zone.
     */
    static getUnixTimeLocal() => DateDiff(A_Now, codebase.constants.ahkTimeZero, "s")
    /**
     * @returns The current Unix time (seconds since midnight, January 1, 1970) relative to the local time zone.
     */
    static getLocalTimezoneOffset() => A_NowUTC

    /**
     * Changes the state of one or multiple Windows Firewall rules.
     * @param newState The new state of the rule(s) expressed as a truthy or falsey value.
     * @param sNames One or more names of Windows Firewall rules the state of which are to change.
     * @throws `ValueError` if `newState` is not a truthy or falsey value.
     * @throws `TypeError` if `rNames` is not a String or an Array.
     * @returns The exit code of the `ComSpec` process if both input parameters are valid.
     * @returns An Array of exit codes from `ComSpec` processes, the length of which being the amount of Windows Firewall rules names passed.
     */
    static setWFRuleStatus(newState, rNames*)
    {
        if (newState == true)
        {
            enable := "yes"
        }
        else if (newState == false)
        {
            enable := "no"
        }
        else
        {
            throw ValueError("Invalid value for ``newState``. Received ``" . newState . "``, expected a truthy or falsey value.")
        }

        codes := []
        for rule in rNames
        {
            codes.Push(RunWait(A_ComSpec . ' /c netsh advfirewall firewall set rule name="' . rule . '" new enable=' . enable))
        }
        return codes
    }

    /**
     * Calls upon one or multiple Windows services to start or stop.
     * @param newState The new desired state of the service(s) expressed as a truthy or falsey value.
     * @param sNames One or more names of Windows services the state of which are to change.
     * @throws `ValueError` if `newState` is not a truthy or falsey value.
     * @throws `TypeError` if `sNames` is not a String or an Array.
     * @returns An Array of exit codes from `ComSpec` processes, the length of which being the amount of Windows service names passed.
     */
    static setWServiceStatus(newState, sNames*)
    {
        if (newState == true)
        {
            enable := "start"
        }
        else if (newState == false)
        {
            enable := "stop"
        }
        else
        {
            throw ValueError("Invalid value for ``newState``. Received ``" . newState . "``, expected a truthy or falsey value.")
        }

        codes := []
        for service in sNames
        {
            codes.Push(RunWait(A_ComSpec . ' /c net ' . enable . " " . service))
        }
        return codes
    }

    /**
     * Changes the processor affinity of one or more processes.
     * @param affinity The affinity to set for the processes.
     * - If this is an integer, it is interpreted as the value of a `codebase.Bitfield` object constructed with the amount of bits equal to the environment variable `NUMBER_OF_PROCESSORS`, e.g. `0000111111111111` if the system has 16 processors (which would select all but the first 4 processors).
     * - If this is a string, it is used directly to instantiate a `codebase.Bitfield` object.
     * @param proc One or more names of processes to target. All processes with this name will be affected. Not case-sensitive.
     * @note If the amount of bits used to construct the `affinity` parameter is less than the `NUMBER_OF_PROCESSORS` environment variable, if `n` is the number of missing bits, the first `n` processors are deselected, after which the passed pattern takes effect.
     * @note For ease of use, passing `0` for `affinity` will select all processors.
     * @returns An Array of objects constructed from `SetProcessAffinityMask` calls, the length of which being the amount of process names _found_, _not_ the amount of executable names passed. The objects are constructed as follows: `{ hwnd: Integer, executableName: String, returnValue: Integer }`.
     */
    static setProcessAffinity(affinity, proc*)
    {
        processors := EnvGet("NUMBER_OF_PROCESSORS")

        if (IsNumber(affinity))
        {
            affinity := codebase.stringOperations.strReverse(codebase.convert.DecToBin(affinity, processors))
            if (affinity == codebase.stringOperations.strRepeat(processors, '0'))
            {
                affinity := codebase.Bitfield(codebase.stringOperations.strRepeat(processors, '1')).Value()
            }
        }
        else
        {
            affinity := codebase.Bitfield(affinity).Value()
        }

        returns := []
        processes := []
        for p in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
        {
            if (codebase.collectionOperations.arrayOperations.arrayContainsPartial(proc, p.Name).Length)
            {
                processes.Push(p.ProcessId)
            }
        }
        for hwnd in processes
        {
            ret := 0
            if (hwnd)
            {
                hProcess := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", 0, "UInt", hwnd)
                ret := DllCall("SetProcessAffinityMask", "UInt", hProcess, "UInt", codebase.Bitfield(affinity).Value())
                DllCall("CloseHandle", "UInt", hProcess)
            }
            returns.Push({
                hwnd: hwnd,
                executableName: WinGetProcessName("ahk_pid " . hwnd),
                returnValue: ret
            })
        }
        return returns
    }

    /**
     * Collects numbers between a start and stop bound. Also operates in reverse and with non-integer bounds and step widths, contrary to the inspiring `range` object in Python. Additionally, this does not return an `Enumerator`, but _can_ be used in its place everywhere as it returns an Array of collected numbers. This is more practical anyway since the return Array of this function is used a lot in the `codebase`.
     * @param start The inclusive start bound of the range of numbers.
     * @param stop The inclusive stop bound of the range of numbers.
     * @param step The step width to use when gathering values. Defaults to `1` if `start < stop` or `-1` if `start > stop` if omitted.
     * @note If `step` _was_ explicitly passed, but `start < stop` and `step < 0` or `start > stop` and `step > 0`, this is assumed to be a mistake, and `-step` will be used instead of `step`.
     * @note If `stop` is set so that `start + (step * x)` surpasses `stop` at some `x`, the last value of the return array will be the last number that was reached _before_ passing over `stop`. As such, by definition, `return[-1] <= stop` and `return` does not _necessarily_ contain `stop`.
     * @note As mentioned, this function operates with non-integer bounds and step widths, however, due to floating-point rounding, a workaround must be used. If a value other than but sufficiently close to `stop` is reached, `stop` is instead made the last value of the return Array. "Sanity checks" of this kind are only done for the last value, not at any other point while collecting numbers.
     * @throws `ValueError` if `0` was explicitly passed for `step`.
     * @returns The Array `[start]` if `stop == start`.
     * @returns The Array of numbers.
     */
    static range(start, stop, step := 1)
    {
        if (stop == start)
        {
            return [start]
        }

        if (step == 0)
        {
            throw ValueError("Invalid value for ``step``. Received ``" . step . "``, expected a value !== 0.")
        }
        else if ((step < 0 && start < stop) || (step > 0 && start > stop))
        {
            step := -step
        }

        arr := [start]
        curr := start

        while (step > 0 ? (curr < stop && curr + step <= stop) : (curr > stop && curr + step >= stop))
        {
            curr += step
            arr.Push((curr))
        }

        if (codebase.math.misc.equal(0.000000000001, arr[-1], stop))
        {
            arr[-1] := stop
        }

        return arr
    }

    /**
     * Traverses objects or collections and constructs an output string from its contents. Recurses into sub-objects and sub-collections and "stringifies" various types that don't directly support operations like string concatenation.
     * @param elems Any values to incorporate into the output string.
     * - No elements passed: an empty string is returned.
     * - Empty value: a newline is inserted.
     * - Array: The function is recursively called on each element.
     * - Map: The function is recursively called on each key-value pair.
     * - Function: The function's name and information about it is inserted. The amount of parameters it takes is displayed as follows, where `n` is any number: `pn` indicates a required parameter, `pn?` indicates an optional parameter, `v*` indicates a final variadic parameter.
     * - Primitive values (Strings, numbers, etc.): The value is inserted as-is.
     * - `Error`s: The information contained by the `Error` object is compiled into a string in the following format: `[Unthrown {Error Type}]\n{Output from codebase.ErrorHandler.output}`.
     * - Objects: The object's `ToString` method is called. On simple objects, this compiles the object's OwnProps and their values into a string. Objects instantiated from user-defined classes should overwrite `ToString` if warranted.
     * @returns An output string constructed while traversing the values in `elems`.
     */
    static elemsOut(elems*)
    {
        indentStr := "    "

        if (elems.Length == 0)
        {
            return ""
        }

        out := ""

        for elem in elems
        {
            if (!IsSet(elem))
            {
                ; unset / empty = newline
                out .= "`n"
                continue
            }

            if (elem is Array)
            {
                out .= "[Array ("
                arrelems := ""
                lines := StrSplit(Trim(codebase.elemsOut(elem*), '`n '), '`n')
                for line in lines
                {
                    arrelems .= indentStr . line . "`n"
                }
                out .= elem.Length . ")]`n" . arrelems
            }
            else if (elem is Map)
            {
                out .= "[Map ("
                kvpairs := ""
                for a, b in elem
                {
                    kvpairs .= indentStr . "[Key-Value pair]`n"
                    kvpairs .= indentStr . indentStr . 'Key | ' . Trim(codebase.elemsOut(a), '`n ') . '`n'
                    kvpairs .= indentStr . indentStr . 'Value | ' . Trim(codebase.elemsOut(b), '`n ') . '`n'
                }
                out .= elem.Count . ")]`n" . kvpairs
            }
            else if (elem is Func)
            {
                out .= (elem.Name !== "" ? elem.Name : "UnnamedFunc")
                param := []
                if (elem.MinArgs)
                {
                    for j in codebase.range(1, elem.MinArgs)
                    {
                        param.Push("p" . j)
                    }
                }
                if (elem.MinArgs !== elem.MaxArgs)
                {
                    for j in codebase.range(elem.MinArgs + 1, elem.MaxArgs)
                    {
                        param.Push("p" . j . "?")
                    }
                }
                s := "(" . codebase.stringOperations.strJoin(", ", , param*) . (elem.IsVariadic ? ", v*" : "") . ")"
            }
            else if (elem is String || elem is Number)
            {
                out .= elem . "`n"
            }
            else if (elem is Error)
            {
                out .= "[Unthrown " . Type(elem) . "]`n" . codebase.ErrorHandler.output(elem, false) . "`n"
            }
            else if (elem is Object)
            {
                out .= "[" . Type(elem) . Format(" ({1:})]`n", elem.OwnProps().Length)
                props := StrSplit(Trim(codebase.collectionOperations.objectOperations.toString(elem), '`n ') . "`n", '`n')
                str := ""
                for line in props
                {
                    if (StrLen(line) == 0)
                    {
                        continue
                    }
                    str .= indentStr . line . "`n"
                }
                out .= str
            }
            else
            {
                throw TypeError("Invalid type for a value passed to ``codebase.elemsOut``. Received ``" . Type(elem) . "``, expected any handled Type.")
            }
        }


        return Trim(out, '`t `n') . "`n"
    }

    /**
     * Formats a millisecond value while automatically accounting for the size of the number.
     * @param t The millisecond value to format.
     * @param includeRaw Whether to include the original value in the return value, separated by a newline from the formatted version. Defaults to `false` if omitted.
     * @param precision How many digits to include beyond seconds by rounding the excess milliseconds. Defaults to `1` if omitted.
     * - If this remaining value is less than `10`, this has no effect.
     * - If this remaining value is between `10` and `100`, this only has an effect if it is `1` or `2`.
     * - The remaining value is omitted entirely if `0` is passed and `t` is greater than `1000`.
     * @param suffix A suffix to append to the remaining milliseconds. Defaults to none if omitted.
     * @throws `ValueError` if precision is not between `0` and `3`.
     * @returns The formatted time value.
     */
    static formatMilliseconds(t, includeRaw := false, precision := 1, suffix := "")
    {
        if (precision < 0 || precision > 3)
        {
            throw ValueError("Invalid value for ``precision``. Received ``" . precision . "``, expected ``0``, ``1``, ``2`` or ``3``.")
        }

        precision := 10 ** (3 - precision)

        if (t >= 1000 * 60 * 60)
        {
            return (includeRaw ? t . "`n" : "") . t // 1000 // 60 // 60 . "h " . (Mod(t // 1000 // 60, 60)) . "m " . (Mod(t // 1000, 60)) . "s" . (precision !== 0 ? " " . SubStr(t, -3, 3) // precision . suffix : "")
        }
        else if (t >= 1000 * 60)
        {
            return (includeRaw ? t . "`n" : "") . (Mod(t // 1000 // 60, 60)) . "m " . (Mod(t // 1000, 60)) . "s" . (precision !== 0 ? " " . SubStr(t, -3, 3) // precision . suffix : "")
        }
        else if (t >= 1000)
        {
            return (includeRaw ? t . "`n" : "") . (Mod(t // 1000, 60)) . "s" . (precision !== 0 ? " " . SubStr(t, -3, 3) // precision . suffix : "")
        }
        else if (t >= 100)
        {
            return (includeRaw ? t . "`n" : "") . (precision !== 0 ? SubStr(t, -3, 3) // precision . suffix : "")
        }
        else if (t >= 10)
        {
            return (includeRaw ? t . "`n" : "") . (precision !== 0 ? SubStr(t, -3, 3) // (precision !== 10 ? precision : 1) . suffix : "")
        }
        else
        {
            return (includeRaw ? t . "`n" : "") . SubStr(t, -3, 3) . suffix
        }
    }

    static escape(str) => RegExReplace(str, "[\*_\/\\]", "\$0")

    /**
     * Converts each letter in a string to its equivalent in the NATO spelling alphabet.
     * @param str The string to convert.
     * @returns The converted string.
     */
    static convertToNATOSpelling(str)
    {
        lookup := Map(
            "a", "Alpha",
            "b", "Bravo",
            "c", "Charlie",
            "d", "Delta",
            "e", "Echo",
            "f", "Foxtrot",
            "g", "Golf",
            "h", "Hotel",
            "i", "India",
            "j", "Juliett",
            "k", "Kilo",
            "l", "Lima",
            "m", "Mike",
            "n", "November",
            "o", "Oscar",
            "p", "Papa",
            "q", "Quebec",
            "r", "Romeo",
            "s", "Sierra",
            "t", "Tango",
            "u", "Uniform",
            "v", "Victor",
            "w", "Whiskey",
            "x", "X-ray",
            "y", "Yankee",
            "z", "Zulu"
        )

        str := StrLower(str)
        words := StrSplit(str, ' ')
        for in words
        {
            words[A_Index] := StrSplit(words[A_Index])
        }

        for in words
        {
            outer := A_Index
            for in words[outer]
            {
                inner := A_Index
                words[outer][inner] := lookup.Get(words[outer][inner], words[outer][inner])
            }
        }

        for in words
        {
            words[A_Index] := codebase.stringOperations.strJoin(" ", , words[A_Index]*)
        }
        return codebase.stringOperations.strJoin(" / ", , words*)
    }

    class misc
    {
        
    }

    class constants
    {
        /**
         * The Unix time (seconds since midnight, January 1, 1970) `0` in YYYYMMDDHH24MISS format to use in date / time comparisons.
         */
        static ahkTimeZero := "19700101000000"
        
        /**
         * Contains the numbers 0-9 in ascending order.
         */
        static numbersAsc := []
        /**
         * Contains the numbers 9-0 in descending order.
         */
        static numbersDsc := []
        /**
         * Contains uppercase letters A-Z (character codes 65-90) in ascending order.
         */
        static uppercaseAsc := []
        /**
         * Contains uppercase letters Z-A (character codes 90-65) in descending order.
         */
        static uppercaseDsc := []
        /**
         * Contains lowercase letters a-z (character codes 97-122) in ascending order.
         */
        static lowercaseAsc := []
        /**
         * Contains lowercase letters z-a (character codes 122-97) in descending order.
         */
        static lowercaseDsc := []

        /**
         * Has no value. Exists to call the function `codebase.constants._init` which populates the following static fields:
         * - `codebase.constants.numbersAsc`
         * - `codebase.constants.numbersDsc`
         * - `codebase.constants.uppercaseAsc`
         * - `codebase.constants.uppercaseDsc`
         * - `codebase.constants.lowercaseAsc`
         * - `codebase.constants.lowercaseDsc`
         */
        static init := codebase.constants._init()
        static _init()
        {
            for n in codebase.range(0, 9)
            {
                codebase.constants.numbersAsc.Push(n)
                codebase.constants.numbersDsc.Push(9 - n)
            }

            for o in codebase.range(65, 90)
            {
                codebase.constants.lowercaseAsc.Push(Chr(32 + o))
                codebase.constants.lowercaseDsc.Push(Chr(32 + 65 + 90 - o))

                codebase.constants.uppercaseAsc.Push(Chr(o))
                codebase.constants.uppercaseDsc.Push(Chr(65 + 90 - o))
            }
        }
    }

    /**
     * An object to accumulate or handle run-time Errors.
     */
    class ErrorHandler
    {
        static custom := -2
        static reload := -1
        static suppress := 0
        static notify := 1
        static rethrow := 2
        static stop := 3
        static exit := 4

        /**
         * Instantiates an `ErrorHandler` object.
         * It keeps track of any errors that are thrown and takes a predefined action upon catching one.
         * @param types An Array of `Error` subclasses that this `ErrorHandler` should watch for. Specifying `[Error]` causes it to watch for all errors. Defaults to `[Error]` if omitted.
         * @param mode How this `ErrorHandler` should react to an incoming error. Refer to `ErrorHandler.setMode` for possible values and their meanings. Defaults to `codebase.ErrorHandler.notify` if omitted.
         * @param custom A custom function to pass incoming `Error` objects to, if the chosen `mode` dictates to do so. The stipulations for this function's return value are the same as for any other `OnError` callback function. If a value is passed but it is not a function, it is ignored.
         * @returns An `ErrorHandler` object.
         */
        __New(types?, mode := 1, custom?)
        {
            OnError(this.handle.Bind(this), 1)

            this.setTypes(IsSet(types) ? types : [Error])
            this.setMode(mode)
            if (IsSet(custom))
            {
                if (custom is Func)
                {
                    this.customFunc := custom
                }
            }

            this.errs := []
        }

        __Delete()
        {
            OnError(this.handle, 0)
        }

        __Item[n]
        {
            get => this.errs[n]
        }

        handle(e, ret)
        {
            for t in this.types
            {
                if (e is t)
                {
                    this.errs.Push(e)
                    break
                }
                return
            }

            switch (this.mode)
            {
                case codebase.ErrorHandler.custom:
                    return this.customFunc(e)
                case codebase.ErrorHandler.reload:
                    MsgBox(codebase.ErrorHandler.output(e))
                    Reload()
                case codebase.ErrorHandler.suppress:
                    return -1
                case codebase.ErrorHandler.notify:
                    MsgBox(codebase.ErrorHandler.output(e))
                    return -1
                case codebase.ErrorHandler.rethrow:
                    return 0
                case codebase.ErrorHandler.stop:
                    MsgBox(codebase.ErrorHandler.output(e))
                    return 1
                case codebase.ErrorHandler.exit:
                    MsgBox(codebase.ErrorHandler.output(e))
                    ExitApp(0)
            }
        }

        /**
         * Formats the information contained in an `Error` object.
         * @param e The `Error` object the information of which to format into a string.
         * @param stack Whether to include the call stack contained in the `Error` object. Defaults to `true` if omitted.
         * @returns A string with the information contained in `e`.
         */
        static output(e, stack := true) => e.Message . "`nExtra:`t" . e.Extra . "`nLine:`t" . e.Line . "`nfrom:`t" . e.What . (stack ? "`n`n" . StrReplace(e.Stack, " : ", '`n') : "")

        /**
         * Evaluates a series of passed types/class names and checks if they are `Error` or subclasses of it.
         * @param types An Array of types.
         * @throws `TypeError` if `var` is not a `expected type`.
         */
        setTypes(types)
        {
            errtypes := [Error, IndexError, MemberError, MemoryError, MethodError, OSError, PropertyError, TargetError, TimeoutError, TypeError, UnsetError, UnsetItemError, ValueError, ZeroDivisionError]

            if (codebase.collectionOperations.arrayOperations.arrayIntersect(errtypes, types).Length !== types.Length)
            {
                throw TypeError("Invalid type for ``types[" . A_Index . "]``. Received ``" . Type(types[A_Index]) . "``, expected ``Error`` or one of its subclasses.")
            }

            this.types := types
        }

        /**
         * Changes how this `ErrorHandler` should react to an incoming error.
         * @param mode One of the following values.
         * - `codebase.ErrorHandler.custom`: Collect errors and pass the `Error` objects to a passed function, the return value of which dictates whether execution may continue.
         * - `codebase.ErrorHandler.reload`: Notify the user of any errors that occur. Even if the error would allow it, stop execution and reload the script.
         * - `codebase.ErrorHandler.suppress`: Collect errors, but do not notify the user of them. Allows programmatic checking if errors occured and is of no further use than debugging. If the error allows, continue execution.
         * - `codebase.ErrorHandler.rethrow`: Collect errors and let AHKv2 handle them. Execution is continued as defined by AHKv2's default error handling, meaning execution _will_ continue if the error allows it.
         * - `codebase.ErrorHandler.notify`: Collect errors and notify the user of them. If the error allows, continue execution.
         * - `codebase.ErrorHandler.stop`: Collect errors and notify the user of then. Even if the error would allow it, stop execution and terminate the underlying (calling) thread.
         * - `codebase.ErrorHandler.exit`: Notify the user of any errors that occur. Even if the error would allow it, stop execution and terminate the script.
         */
        setMode(mode)
        {
            modes := [
                codebase.ErrorHandler.custom,
                codebase.ErrorHandler.reload,
                codebase.ErrorHandler.suppress,
                codebase.ErrorHandler.notify,
                codebase.ErrorHandler.rethrow,
                codebase.ErrorHandler.stop,
                codebase.ErrorHandler.exit
            ]

            if (!(codebase.collectionOperations.arrayOperations.arrayContains(modes, mode).Length))
            {
                throw ValueError("Invalid value for ``mode``. Received ``" . mode . "``, expected one of the following: ``codebase.ErrorHandler.suppress``, ``codebase.ErrorHandler.notify``, ``codebase.ErrorHandler.stop``.")
            }

            this.mode := mode
        }
    }

    /**
     * A class to display a tooltip, with various options being taken care of automatically.
     */
    class Tool
    {
        static usedToolTipIds := []

        /**
         * Display a tooltip while having the "heavy lifting" taken care of automatically, namely removing it after a set time, placement and rotating through the 20 ToolTip slots available to a single running script.
         * @param text The text to be displayed.
         * @param display Which display mode to use. Value must be one of the following: `codebase.Tool.cursor`, `codebase.Tool.center`, `codebase.Tool.coords`. Defaults to `codebase.Tool.cursor` if omitted.
         * @param displayTime How many milliseconds to display the tooltip for. Defaults to `1000` if omitted.
         * @param x The x-coordinate of where to place the tooltip. Defaults to `0` if omitted.
         * - If `display` is `codebase.Tool.coords`, this is used as-is.
         * - Otherwise, it is treated as an offset from the position that `display` would indicate.
         * @param y The y-coordinate of where to place the tooltip. Defaults to `0` if omitted.
         * - If `display` is `codebase.Tool.coords`, this is used as-is.
         * - Otherwise, it is treated as an offset from the position that `display` would indicate.
         */
        __New(text, display := 0, displayTime := 1000, x?, y?)
        {
            thisId := 0
            for i in codebase.range(1, 20)
            {
                if (!(codebase.collectionOperations.arrayOperations.arrayContains(codebase.Tool.usedToolTipIds, i).Length))
                {
                    codebase.Tool.usedToolTipIds.Push(thisId := i)
                    break
                }
            }

            ; Failsafe: all ToolTip slots are occupied?
            ; -> begin freeing from the beginning, reusing the oldest occupied IDs
            ; if their freeing function hasn't been called yet, free them immediately (this also deletes the timer, meaning it can be safely re-set by using the ToolTip ID)
            if (thisId == 0)
            {
                thisId := codebase.Tool.usedToolTipIds[1]
                codebase.Tool.freeId(codebase.Tool.usedToolTipIds[1])
                codebase.Tool.usedToolTipIds.RemoveAt(1)
                codebase.Tool.usedToolTipIds.Push(thisId)
            }

            switch (display)
            {
                case 0:
                    MouseGetPos(&xo, &yo)
                case 1:
                    xo := A_ScreenWidth / 2
                    yo := A_ScreenHeight / 2
            }
            
            if (display == 2)
            {
                ToolTip(text, x, y, thisId)
            }
            else
            {
                ToolTip(text, xo + (IsSet(x) ? x : 0), yo + (IsSet(y) ? y : 0), thisId)
            }

            SetTimer(codebase.Tool.freeing.%"id" . thisId%, -displayTime, codebase.datatypes.Int64.max_value)
            return thisId
        }

        static cursor := 0
        static center := 1
        static coords := 2

        /**
         * Frees an occupied slot ID from the `codebase.Tool.usedToolTipIds` Array.
         * @param id The ID of the slot to free.
         * @note This should not be called manually. It is called automatically after the time specified when creating a ToolTip using `codebase.Tool`.
         */
        static freeId(id, *)
        {
            SetTimer(codebase.Tool.freeing.%"id" . id%, 0, codebase.datatypes.Int64.max_value)
            ToolTip(, , , id)
            codebase.Tool.usedToolTipIds := codebase.collectionOperations.arrayOperations.remove(codebase.Tool.usedToolTipIds, [id])
        }

        static freeing := {
            id1: codebase.Tool.freeId.Bind(this, 1),
            id2: codebase.Tool.freeId.Bind(this, 2),
            id3: codebase.Tool.freeId.Bind(this, 3),
            id4: codebase.Tool.freeId.Bind(this, 4),
            id5: codebase.Tool.freeId.Bind(this, 5),
            id6: codebase.Tool.freeId.Bind(this, 6),
            id7: codebase.Tool.freeId.Bind(this, 7),
            id8: codebase.Tool.freeId.Bind(this, 8),
            id9: codebase.Tool.freeId.Bind(this, 9),
            id10: codebase.Tool.freeId.Bind(this, 10),
            id11: codebase.Tool.freeId.Bind(this, 11),
            id12: codebase.Tool.freeId.Bind(this, 12),
            id13: codebase.Tool.freeId.Bind(this, 13),
            id14: codebase.Tool.freeId.Bind(this, 14),
            id15: codebase.Tool.freeId.Bind(this, 15),
            id16: codebase.Tool.freeId.Bind(this, 16),
            id17: codebase.Tool.freeId.Bind(this, 17),
            id18: codebase.Tool.freeId.Bind(this, 18),
            id19: codebase.Tool.freeId.Bind(this, 19),
            id20: codebase.Tool.freeId.Bind(this, 20)
        }
    }

    /**
     * A class to allow interaction with the standard input and output streams `stdin`, `stdout` and `stderr`.
     */
    class StandardIO
    {
        /**
         * Instantiates a new `StandardIO` object.
         *
         * Use its properties `stdin`, `stdout` and `stderr` to access the standard input, output and error streams respectively.
         * - Data can be read from the input stream using the stream's read methods and typing in the console window.
         * - Data can be written to the output stream using the stream's write methods.
         * - Data can be read from _and_ written to the error stream using the stream's read and write methods.
         *
         * Output streams must be closed (`this.invalidateHandles`) or flushed (`this.flush`) before any data is actually written from the buffers. This can be done manually and occurs automatically when the `StandardIO` object is destroyed.
         *
         * By reading and tokenizing user input via `stdin`, this can be used to emulate CLI behavior.
         */
        __New()
        {
            ; Allocate and attach to a new console
            DllCall("kernel32.dll\AllocConsole")
            ; Retrieve handles to the standard input, output and error streams
            this.stdin := FileOpen("*", "r")
            this.stdout := FileOpen("*", "w")
            this.stderr := FileOpen("**", "w")
        }

        __Delete()
        {
            ; Close the handles to the standard input, output and error streams
            this.invalidateHandles()
            ; Detach from and free the console
            DllCall("kernel32.dll\FreeConsole")
        }

        /**
         * Checks if this `StandardIO` object's handles for `stdin`, `stdout` and `stderr` are valid.
         * @returns `true` if all handles are valid, `false` otherwise.
         */
        areHandlesValid() => Type(this.stdin) == "File" && Type(this.stdout) == "File" && Type(this.stderr) == "File"

        /**
         * Attempts flushing and forcibly invalidating this `StandardIO` object's handles for `stdin`, `stdout` and `stderr`.
         * @returns `true` if all handles could be invalidated, `false` otherwise.
         */
        invalidateHandles()
        {
            this.flush()
            for stream in [this.stdin, this.stdout, this.stderr]
            {
                try
                {
                    stream.Close()
                }
                stream := ""
            }
            return !this.areHandlesValid()
        }

        /**
         * Forcibly revalidates this `StandardIO` object's handles for `stdin`, `stdout` and `stderr`.
         * @note If retrieving handles to _any_ of the streams fails, _all_ handles will be invalidated.
         * @returns `true` if all handles could be validated, `false` otherwise.
         */
        validateHandles()
        {
            this.invalidateHandles()
            this.stdin := FileOpen("*", "r")
            this.stdout := FileOpen("*", "w")
            this.stderr := FileOpen("**", "w")
            return this.areHandlesValid()
        }

        /**
         * Flushes the two output streams `stdout` and `stderr`.
         * @returns `true` if the streams could be flushed, `false` otherwise. If `false`, all handles should be considered invalid.
         */
        flush()
        {
            for stream in [this.stdout, this.stderr]
            {
                try
                {
                    stream.Read(0)
                }
                catch
                {
                    this.invalidateHandles()
                    return false
                }
            }
            return true
        }

        /**
         * Reads one or more lines from the standard input stream `stdin`, blocking until this succeeds.
         * @param maxLines The maximum number of lines to read. Defaults to `1` if omitted.
         * @note If reading fails, all handles are invalidated and the function returns the lines _read up until the Error occured_.
         * @returns An Array of lines read from `stdin`, with a `Length` of `maxLines` if reading hasn't failed before then.
         */
        readLines(maxLines := 1)
        {
            out := []
            Loop maxLines
            {
                try
                {
                    out.Push(this.stdin.ReadLine() . "`n")
                }
                catch
                {
                    this.invalidateHandles()
                    break
                }
            }
            return out
        }

        /**
         * Reads one line from the standard input stream `stdin` and parses it as if it were a command-line command, splitting it into substrings appropriate for CLIs.
         * @note If reading fails, all handles are invalidated and the function returns an empty Array.
         * @returns 
         */
        readCLIParse()
        {
            read := ""
            ret := []

            try
            {
                read := this.stdin.ReadLine()
                if (InStr(read, '"'))
                {
                    sub := StrSplit(read, '"', ' ')
                    for searchx in sub
                    {
                        if (InStr(searchx, ' '))
                        {
                            ret.Push(StrSplit(searchx, ' ')*)
                        }
                        else
                        {
                            ret.Push(searchx)
                        }
                    }
                }
                else
                {
                    ret.Push(StrSplit(read, ' ')*)
                }
            }
            catch
            {
                this.invalidateHandles()
            }
            return ret
        }
    }

    /**
     * A class to make styling and setting options for message boxes easier.
     *
     * To use options from the subclasses, add them in the message box's `options` parameter.
     */
    class msgboxopt
    {
        class buttons
        {
            static ok :=                        0x000000
            static okcancel :=                  0x000001
            static abortretryignore :=          0x000002
            static yesnocancel :=               0x000003
            static yesno :=                     0x000004
            static retrycancel :=               0x000005
            static canceltryagaincontinue :=    0x000006
        }

        class icons
        {
            static error :=         0x000010
            static question :=      0x000020
            static exclamation :=   0x000030
            static info :=          0x000040
        }

        class defaultButton
        {
            static button2default := 0x000100
            static button3default := 0x000200
            static button4default := 0x000300
        }

        class modality
        {
            static system :=        0x001000
            static task :=          0x002000
            static alwaysontop :=   0x040000
        }
        
        class other
        {
            static help :=              0x004000
            static rightjustify :=      0x080000
            static rtlreadingorder :=   0x100000
        }

        class results
        {
            static ok := "OK"
            static cancel := "Cancel"
            static yes := "Yes"
            static no := "No"
            static abort := "Abort"
            static retry := "Retry"
            static ignore := "Ignore"
            static tryagain := "TryAgain"
            static continue := "Continue"
            static timeout := "Timeout"
        }
    }

    /**
     * A class for working with numbers as bitfields, for which AHKv2 has no native support.
     */
    class Bitfield
    {
        /**
         * Instantiates a new `codebase.Bitfield` object.
         * @param bits
         * - Value mode: Any number of values for the `codebase.Bitfield` to hold. All passed values are translated into simple boolean values, i.e. contents of strings or numerical values are lost.
         * - String mode: A string of any length with single digits to identify the bits the object should hold, e.g. "00010100".
         * @returns A `codebase.Bitfield` object.
         */
        __New(bits*)
        {
            this.bits := []
            for searchx in (bits.Length == 1 ? (Type(bits[1]) == "String" ? StrSplit(bits[1]) : bits) : bits)
            {
                this.bits.Push(!!searchx)
            }
            this.DefineProp("Value", { Get: this.Value })
            return this.Value()
        }

        /**
         * Returns the object's stored bits as a numerical value.
         * @throws `ValueError` if `this.bits.Length` is `≥ 64` as a signed 64-bit integer may not be able to represent all bits as a number.
         * @returns The `codebase.Bitfield` object's stored bits converted to a numerical value.
         */
        Value()
        {
            if (this.bits.Length >= 64)
            {
                throw ValueError("Cannot convert a ``codebase.Bitfield`` with 64 or more bits to a ``long``.")
            }

            return codebase.math.sum(1, this.bits.Length, (x) => this.bits[x] * (2 ** (this.bits.Length - x)))
        }
    }

    /**
     * A class for working with numbers, or more precisely with numbers as bitfields.
     * @note AHKv2 has no native support for bitfields, so this class is a workaround.
     */
    class bitwiseOperations
    {
        /**
         * Calculates the bitwise-AND of a series of bitfields (numbers).
         * @param vals The numbers to AND.
         * @note The AND of more than 2 numbers is calculated by stepping through `vals` and ANDing 2 at a time, then ANDing this intermediate value with the next, etc. until there is only one final value left. This is the AND of all numbers passed.
         * @returns The AND of the numbers in `vals`.
         */
        static and(vals*)
        {
            if (vals.Length < 2)
            {
                throw ValueError("Invalid value for ``vals.Length``. Received ``" . vals.Length . "``, expected a value >= 2.")
            }

            ret := vals[1]
            for j in codebase.range(2, vals.Length)
            {
                ret &= vals[j]
            }
            return ret
        }

        /**
         * Calculates the bitwise-OR of a series of bitfields (numbers).
         * @param vals The numbers to OR.
         * @note The OR of more than 2 numbers is calculated by stepping through `vals` and ORing 2 at a time, then ORing this intermediate value with the next, etc. until there is only one final value left. This is the OR of all numbers passed.
         * @returns The OR of the numbers in `vals`.
         */
        static or(vals*)
        {
            if (vals.Length < 2)
            {
                throw ValueError("Invalid value for ``vals.Length``. Received ``" . vals.Length . "``, expected a value >= 2.")
            }

            ret := vals[1]
            for j in codebase.range(2, vals.Length)
            {
                ret |= vals[j]
            }
            return ret
        }

        /**
         * Calculates the bitwise-XOR of a series of bitfields (numbers).
         * @param vals The numbers to XOR.
         * @returns The XOR of the numbers in `vals`.
         *
        static xor(vals*)
        {
            newvals := []
            for val in vals
            {
                newvals.Push(codebase.Bitfield(codebase.convert.DecToBin(val)))
            }

            longest := { bits: [] }
            for bf in newvals
            {
                if (bf.bits.Length > longest.bits.Length)
                {
                    longest := bf
                }
            }

            str := ""
            for i in codebase.range(1, longest.bits.Length)
            {
                count1 := 0
                for bf in newvals
                {
                    if (bf.bits.Has(i) ? bf.bits[i] : 0)
                    {
                        count1++
                    }
                }
                str .= String(count1 == 1 ? 1 : 0)
            }
            
            return codebase.Bitfield(str).Value()
        }
        */
    }

    /**
     * A class for manipulating strings.
     */
    class stringOperations
    {
        /**
         * Constructs a string consisting of spaces to separate one "column" of text from another.
         * @param str The current string to use when calculating the amount of padding spaces.
         * @param padding How many spaces to add in addition to the amount needed to separate the columns _exactly_. Defaults to `4` if omitted.
         * @param extra One of the following. Defaults to `StrLen(str)` if omitted, resulting in exactly `padding` padding spaces for each string.
         * - An Array of all possible strings in the "left column".
         * - The longest string in the "left column".
         * - An integer, which is interpreted as length of the longest string in the "left column".
         * @returns A string consisting of spaces with an appropriate length to separate the columns; it does _not_ contain the input string or any strings in `extra`.
         */
        static strSeparator(str, padding := 4, extra?)
        {
            if (!IsSet(extra))
            {
                extra := StrLen(str)
            }
            else if (IsNumber(extra))
            {

            }
            else if (Type(extra) == "Array")
            {
                extra := Max(codebase.collectionOperations.arrayOperations.evaluate(StrLen, extra)*)
            }
            else
            {
                extra := StrLen(extra)
            }

            return codebase.stringOperations.strRepeat(padding + extra - StrLen(str), ' ')
        }

        /**
         * Takes an input string and basically performs circular left-shifts on its characters until the first character _would_ again reach the beginning of the string.
         * @param str The string to shift.
         * @param utf16 Whether the string consists solely of UTF-16 characters (i.e. emojis). Defaults to `false` if omitted.
         * @note If `utf16` is incorrectly set or `str` is a mix of 8-bit and 16-bit characters, the returned string will contain garbage.
         * @returns The shifted string.
         */
        static strLineShift(str, utf16 := false)
        {
            input := String(str)
            out := input . "`n"

            while (A_Index < StrLen(str))
            {
                splt := StrSplit(input)
                input := codebase.stringOperations.strConcat(codebase.collectionOperations.arrayOperations.subarray(splt, 2, )*) . splt[1]

                if (utf16 && !Mod(A_Index + 1, 2))
                {
                    continue
                }

                out .= input . "`n"
            }

            return out
        }

        /**
         * Performs a series of `StrReplace` calls on an input string with data from a Map.
         * @param str The string to perform the replacements on.
         * @param srmap A Map of search-replace pairs.
         * @returns The string with all replacements performed.
         */
        static strReplace(str, srmap)
        {
            ret := String(str)
            for k, v in srmap
            {
                ret := StrReplace(ret, k, v)
            }
            return ret
        }

        /**
         * Performs a series of `RegExReplace` calls on an input string with data from a Map.
         * @param str The string to perform the replacements on.
         * @param srmap A Map of search-replace pairs.
         * @returns The string with all replacements performed.
         */
        static strRegExReplace(str, srmap)
        {
            ret := String(str)
            for k, v in srmap
            {
                ret := RegExReplace(ret, k, v)
            }
            return ret
        }

        /**
         * Creates a `Buffer` object from a string.
         * @param str The string to convert to store in a `Buffer`.
         * @param encoding The encoding to use for the `Buffer`. Defaults to `UTF-8` if omitted.
         * @returns A `Buffer` object.
         */
        static toBuffer(str, encoding := "UTF-8")
        {
            buf := Buffer(StrPut(str, encoding))
            StrPut(str, buf, encoding)
            return buf
        }

        /**
         * Constructs a String consisting of a source string repeated one or more times.
         * @param count How many times to repeat the string.
         * @param obj The string to repeat.
         * @note This is the string equivalent of `codebase.stringOperations.strJoin('', true, codebase.collectionOperations.objRepeat(count, obj)*)` if `obj` is a string.
         * @returns The constructed string.
         */
        static strRepeat(count, str)
        {
            ret := ""
            Loop count
            {
                ret .= str
            }
            return ret
        }

        /**
         * Concatenates any number of input arguments into a single string. If concatenation on something other than a string or number is attempted, concatenation on the result of its `ToString` method is performed. This may result in unexpected results due to the formatting of the result of `ToString`.
         * @param strs The strings to concatenate.
         * @returns The concatenated string.
         */
        static strConcat(strs*)
        {
            ret := ""
            for str in strs
            {
                try ret .= str
                catch
                {
                    ret .= str.ToString()
                }
            }
            return ret
        }

        /**
         * Joins a number of strings into a single string with a separator in between. This separator is not present at the end of the string. If concatenation on something other than a string or number is attempted, concatenation on the result of its `ToString` method is performed. This may result in unexpected results due to the formatting of the result of `ToString`.
         * @param sep The separator to use between the strings.
         * @param insertEmpty Whether to insert the separator if an empty string is encountered.
         * @param strs The strings to join with `sep`.
         * @returns All strings in `strs` connected with `sep`.
         */
        static strJoin(sep, insertEmpty := false, strs*)
        {
            out := ""
            for str in strs
            {
                if (str == "" && !insertEmpty)
                {
                    continue
                }

                try out .= str . sep
                catch
                {
                    out .= str.ToString() . sep
                }
            }
            return StrLen(sep) ? SubStr(out, 1, -StrLen(sep)) : out
        }

        /**
         * Uses C#-style syntax and emulates composite string formatting to avoid having to use concatenations.
         * @param str A `VarRef` to the initial string to search for `{name}` patterns, where `name` is any alpha-numeric string (i.e. `IsAlpha(name)` must return `true` for every `name`).
         * @param objOrMap One of the following:
         * - An object containing `name: value` pairs. The pattern `{name}` will be searched for in `str` and replaced by the corresponding `value`.
         * - A Map containing `key: value` pairs. The pattern `{key}` will be searched for in `str` and replaced by the corresponding `value`.
         * @note The amount of values in `objOrMap` must correspond to (or at least exceed) the amount of `{name}` patterns in `str` as `obj.Length` is used to determine how many `StrReplace` calls will be made. Excess objects / values are discarded as their corresponding `{name}` patterns will be missing.
         * @note Yes, this is exactly the same as using the AHKv2-native function `Format` with... admittedly less functionality, however, this one allows naming of the passed objects / values and the user is returned all excess objects / values that could not be inserted into `str`, possibly allowing for easier error handling?
         * @returns `objOrMap` with all name-value or key-value pairs removed that were successfully inserted into `str`. If `objOrMap.OwnProps` or `objOrMap.Count` after calling this function is not empty, there are still composite patterns (`{name}`) left in `str`.
         */
        static strComposite(&str, objOrMap)
        {
            startingpos := 1
            while (RegExMatch(str, "\{([A-z0-9 ]+)\}", &match, startingpos) !== 0)
            {
                replace := ""
                if (Type(objOrMap) == "Object")
                {
                    if (objOrMap.HasOwnProp(match[1]))
                    {
                        replace := objOrMap.GetOwnPropDesc(match[1]).Value
                        str := StrReplace(str, match[], replace)
                        objOrMap.DeleteProp(match[1])
                    }
                    else
                    {
                        startingpos := match.Pos + match.Len
                    }
                }
                else if (Type(objOrMap) == "Map")
                {
                    if (objOrMap.Has(match[1]))
                    {
                        replace := objOrMap.Get(match[1])
                        str := StrReplace(str, match[], replace)
                        objOrMap.Delete(match[1])
                    }
                    else
                    {
                        startingpos := match.Pos + match.Len
                    }
                }
            }
            return objOrMap
        }

        /**
         * Reverses a string.
         * @param string The string to reverse.
         * @returns The reversed string.
         */
        static strReverse(string)
        {
            if (Type(string) !== "String")
            {
                throw TypeError("Invalid type for ``string``. Received ``" . Type(string) . "``, expected ``String``.")
            }

            split := StrSplit(string)
            len := split.Length
            out := ""

            while (len - (A_Index - 1) > 0)
            {
                out .= split[len - (A_Index - 1)]
            }

            return out
        }

        /**
         * Ellipsizes a string, truncating at a given length and adding a suffix.
         * @param str The string to ellipsize.
         * @param chars The maximum length the ellipsized string may be, excluding the length of `elli`.
         * @param elli The string to ellipsize with. Defaults to "(...)". There is no space added between the remaining portion of the string and `elli`.
         * @returns `str` with no changes if its length does not exceeded `chars`.
         * @returns The ellipsized string if its length exceeded `chars`.
         */
        static strEllipsize(str, chars, elli := "(...)")
        {
            if (StrLen(str) <= chars)
            {
                return str
            }

            return SubStr(str, 1, chars) . elli
        }
    }

    /**
     * A class for working with collections or otherwise general cases of working with variable amounts of values.
     */
    class collectionOperations
    {
        /**
         * Constructs an Array consisting of one value repeated one or more times.
         * @param count How many times to repeat the object.
         * @param obj The object (any value) to repeat.
         * @note This is intended to replicate syntax such as `[6 for x in range(9)]` in Python.
         * @note This is the generally usable equivalent of `codebase.stringOperations.strRepeat(count, str)`, however, it compiles an Array instead of a string.
         * @returns The constructed Array.
         */
        static objRepeat(count, obj)
        {
            ret := []
            if (count == 0)
            {
                return ret
            }
            Loop count
            {
                ret.Push(obj)
            }
            return ret
        }

        /**
         * Takes any amount of expressions and checks if any of them evaluate to `true`. As with AHKv2's `or` operators (`or` and `||`), this is programmed to short-circuit, meaning expressions are only evaluated up to the first one that is truthy.
         * @param expr Any number of expressions to evaluate.
         * @returns `true` if any of the expressions evaluate to `true`.
         * @returns `false` if none of the expressions evaluate to `true`.
         */
        static or(expr*)
        {
            for ex in expr
            {
                if (ex)
                {
                    return true
                }
            }
            return false
        }

        /**
         * Inputs any amount of parameters into a function separately and checks if any of their return values evaluate to `true`. As with AHKv2's `or` operators (`or` and `||`), this is programmed to short-circuit, meaning function calls are only made and return values are only evaluated up to the first one that is truthy.
         * @param f The function to pass the parameters to.
         * @param args The parameters to pass to the function.
         * @throws `TypeError` if the value passed for `func` is not a `Func` object or one of its subtypes.
         * @returns `true` if any of the return values collected by calling `func` with the parameters from `args` evaluate to `true`.
         * @returns `false` if none of the return values collected by calling `func` with the parameters from `args` evaluates to `false`.
         */
        static orFunc(f, args*)
        {
            if (!(f is Func))
            {
                throw TypeError("Invalid type for ``func``. Received ``" . Type(f) . "``, expected ``Func``, ``Closure`` or ``BoundFunc``.")
            }

            for p in args
            {
                if (f(p))
                {
                    return true
                }
            }
            return false
        }

        /**
         * Takes any amount of expressions and checks if any of them evaluate to `true`. As with AHKv2's `and` operators (`and` and `&&`), this is programmed to short-circuit, meaning expressions are only evaluated up to the first one that is falsey.
         * @param expr Any number of expressions to evaluate.
         * @returns `true` if all of the expressions evaluate to `true`.
         * @returns `false` if one of the expressions evaluate to `false`.
         */
        static and(expr*)
        {
            for ex in expr
            {
                if (!ex)
                {
                    return false
                }
            }
            return true
        }

        /**
         * Inputs any amount of parameters into a function separately and checks if any of their return values evaluate to `true`. As with AHKv2's `and` operators (`and` and `&&`), this is programmed to short-circuit, meaning function calls are only made and return values are only evaluated up to the first one that is falsey.
         * @param f The function to pass the parameters to.
         * @param args The parameters to pass to the function.
         * @throws `TypeError` if the value passed for `func` is not a `Func` object or one of its subtypes.
         * @returns `true` if all of the return values collected by calling `func` with the parameters from `args` evaluate to `true`.
         * @returns `false` if one of the return values collected by calling `func` with the parameters from `args` evaluates to `false`.
         */
        static andFunc(f, args*)
        {
            if (!(f is Func))
            {
                throw TypeError("Invalid type for ``func``. Received ``" . Type(f) . "``, expected ``Func``, ``Closure`` or ``BoundFunc``.")
            }

            for p in args
            {
                if (!f(p))
                {
                    return false
                }
            }
            return true
        }

        /**
         * Returns the first truthy value in any number of input arguments or the last value if no previous value is truthy.
         * @param args The values to step through.
         * @returns The first truthy value in `args`.
         * @returns The last value in `args` if no previous value is truthy.
         */
        static true(args*)
        {
            for v in args
            {
                if (v)
                {
                    return v
                }
            }
            return args[args.Length]
        }

        /**
         * A class containing functions for manipulating Maps.
         */
        class mapOperations
        {
            /**
             * Finds all keys in a series of Map that are only present in _all_ input Maps.
             * @param maps The Maps to analyze.
             * @note This function is commutative (i.e. `mapIntersect(map_1, map_2)` is equivalent to `mapIntersect(map_2, map_1)`).
             * @note This function complements `codebase.collectionOperations.mapOperations.mapNotIntersect`. Combining the results of the function calls `mapIntersect(map_1, map_2)` and `mapNotIntersect(map_1, map_2)` yields `map_1` extended by `map_2`'s values for the keys present in both.
             * @returns A Map with all keys that are present in all passed Maps. Their corresponding values are the value of the key from all passed Maps as an Array in the order the input Maps were passed in.
             */
            static mapIntersect(maps*)
            {
                for mp in maps
                {
                    if (Type(mp) !== "Map")
                    {
                        throw TypeError("Invalid type for ``maps[" . A_Index . "]``. Received ``" . Type(maps[A_Index]) . "``, expected ``Map``.")
                    }
                }

                shortest := maps[1]
                out := Map()

                ; Find the input Map with the shortest Length, as only the key-value pairs contained in it are even candidates for the intersect Map
                for mp in maps
                {
                    if (codebase.collectionOperations.mapOperations.getKeys(mp).Length < codebase.collectionOperations.mapOperations.getKeys(shortest).Length)
                    {
                        shortest := mp
                    }
                }

                ; maps.RemoveAt(codebase.collectionOperations.arrayOperations.arrayContains(maps, shortest)[1])

                for k in shortest
                {
                    presentIn := []
                    for mp in maps
                    {
                        presentIn.Push(mp.Has(k))
                    }

                    if (codebase.collectionOperations.and(presentIn*))
                    {
                        values := []
                        for mp in maps
                        {
                            values.Push(mp.Get(k))
                        }
                        out.Set(k, values)
                    }
                }

                return out
            }

            /**
              * Finds all elements in a source Map that are _not_ present in any of the other input Maps.
              * @param src The source Map to iterate over.
              * @param arrs Any number of Maps to look for elements from `maps` in.
              * @note This function is not commutative (i.e. `mapNotIntersect(map_1, map_2)` is not equivalent to `mapNotIntersect(map_2, map_1)`) as the source Map `src` determines which items are even candidates to be returned.
              * @note This function complements `codebase.collectionOperations.mapOperations.mapIntersect`. Combining the results of the function calls `mapIntersect(map_1, map_2)` and `mapNotIntersect(map_1, map_2)` yields `map_1` extended by `map_2`'s values for the keys present in both.
              * @returns A Map with key-value pairs from `src` that are not present in any of the other Maps.
              */
            static mapNotIntersect(src, maps*)
            {
                for mp in maps
                {
                    if (Type(mp) !== "Map")
                    {
                        throw TypeError("Invalid type for ``maps[" . A_Index . "]``. Received ``" . Type(maps[A_Index]) . "``, expected ``Map``.")
                    }
                }

                out := src.Clone()

                for mp in maps
                {
                    for k in mp
                    {
                        if (out.Has(k))
                        {
                            out.Delete(k)
                        }
                    }
                }

                return out
            }

            /**
             * Compiles all keys of a Map into an Array.
             * @param k The Map to iterate over.
             * @returns An Array with the keys of `k`.
             */
            static getKeys(k)
            {
                keys := []
                for searchx in k
                {
                    keys.Push(searchx)
                }
                return keys
            }

            /**
             * Compiles all values of a Map into an Array.
             * @param k The Map to iterate over.
             * @returns An Array with the values of `k`.
             */
            static getValues(k)
            {
                values := []
                for , searchy in k
                {
                    values.Push(searchy)
                }
                return values
            }

            /**
             * Creates an "inverted" clone of a Map, using the original's values as keys and vice versa.
             * @param k The Map to invert.
             * @returns The inverted Map.
             */
            static mapInvert(k)
            {
                kNew := Map()
                for searchx, searchy in k
                {
                    kNew.Set(searchy, searchx)
                }
                return kNew
            }

            /**
             * Adds the key-value pairs of any number of maps to an initial Map.
             * @param src A `VarRef` to the Map to add the following Maps to.
             * @param overwrite Whether to overwrite existing key-value pairs in the initial Map if the key is present in any of the following Maps.
             * @param append Any number of maps to add to `src`.
             * @returns `true` if any changes were made to `src`.
             * @returns `false` if no changes were made to `src`.
             */
            static mapCombine(&src, overwrite, append*)
            {
                for m in append
                {
                    if (Type(m) !== "Map")
                    {
                        throw TypeError("Invalid type for a value in ``append``. Received ``" . Type(m) . "``, expected ``Map`` (item #" . A_Index . ").")
                    }
                }

                changed := false
                for m in append
                {
                    for k, v in m
                    {
                        if (!(src.Has(k)) || overwrite)
                        {
                            src.Set(k, v)
                            changed := true
                        }
                    }
                }

                return changed
            }

            /**
             * Expands a Map by adding its inverse's key-value pairs to itself.
             * @param src A `VarRef` to the Map to add its inverse's data to.
             * @param overwrite Whether to overwrite existing key-value pairs in the initial Map if the key is present in any of the following Maps.
             * @returns `true` if any changes were made to `src`.
             * @returns `false` if no changes were made to `src`.
             */
            static mapExpand(&src, overwrite)
            {
                changed := false
                for k, v in codebase.collectionOperations.mapOperations.mapInvert(src)
                {
                    if (!(src.Has(k)) || overwrite)
                    {
                        src.Set(k, v)
                        changed := true
                    }
                }

                return changed
            }
        }

        /**
         * A class containing functions for manipulating Arrays.
         */
        class arrayOperations
        {
            /**
             * A constant used by various functions in this class. For example, item removal functions set items to be removed equal to this constant and then delete them.
             *
             * This is deliberately... "abstract" and not something as simple as `"rem"` as it is very likely for a user to be using `"rem"` as a _wanted_ value in an Array.
             */
            static arrayRemoveItem := "###00418632R_E_M_O_V_E_I_T_E_M9456345812###"

            /**
             * Evaluates a function on each item in an Array and returns the results in an Array.
             * @param f The function to evaluate on each item in the Array.
             * @param arr The Array to iterate over.
             * @returns An Array with the results of calling `f` on each item in `arr`.
             */
            static evaluate(f, arr)
            {
                v := []
                for elem in arr
                {
                    v.Push(f(elem))
                }
                return v
            }

            /**
             * Shifts an Array's elements, removing specific elements.
             * @param arr The Array to iterate over.
             * @param elems An Array of elements to remove from `arr`.
             * @note This removes _elements_ from `arr` matching ones in `elems`, _not_ indices.
             * @returns An Array with the same elements as `arr`, but with any elements matching the ones in `elems` removed.
             */
            static remove(arr, elems)
            {
                rem := []

                for e in elems
                {
                    for j in codebase.collectionOperations.arrayOperations.arrayContains(arr, e)
                    {
                        rem.Push(j)
                    }
                }

                if (rem.Length)
                {
                    for j in rem
                    {
                        if (j <= 0)
                        {
                            continue
                        }

                        arr.RemoveAt(j)
                        for in rem
                        {
                            rem[A_Index] -= 1
                        }
                    }
                }

                return arr
            }

            /**
             * Shifts an Array's elements, removing elements at specific indices.
             * @param arr The Array to iterate over.
             * @param i An Array of indices to remove elements from `arr` at.
             * @note This removes _indices_ from `arr`, _not_ specific elements.
             * @returns An Array with the same elements as `arr`, but with elements at the indices in `i` removed.
             */
            static removeAt(arr, i)
            {
                cpy := arr.Clone()
                for _i in i
                {
                    cpy[_i] := codebase.collectionOperations.arrayOperations.arrayRemoveItem
                }
                return codebase.collectionOperations.arrayOperations.remove(cpy, [codebase.collectionOperations.arrayOperations.arrayRemoveItem])
            }

            /**
             * Shifts an Array's elements, "removing" empty / missing / unset elements.
             * @param arr The Array to iterate over.
             * @returns An Array with the same elements as `arr`, but with any empty / missing / unset elements removed.
             */
            static removeEmpty(arr)
            {
                cpy := arr.Clone()
                empty := []

                for e in arr
                {
                    if (!IsSet(e))
                    {
                        cpy[A_Index] := codebase.collectionOperations.arrayOperations.arrayRemoveItem
                    }
                }

                return codebase.collectionOperations.arrayOperations.remove(cpy, [codebase.collectionOperations.arrayOperations.arrayRemoveItem])
            }

            /**
             * Removes duplicates from a series of values.
             * @param arr An Array to remove duplicates from.
             * @returns An Array containing the original values with duplicates removed.
             */
            static removeDuplicates(arr)
            {
                out := []

                for e in arr
                {
                    if (!(codebase.collectionOperations.arrayOperations.arrayContains(out, e).Length))
                    {
                        out.Push(e)
                    }
                }

                return out
            }

            /**
             * Shifts an Array's elements, removing elements based on the return value of a function.
             * @param arr The Array to iterate over.
             * @param f The function to use when determining which elements to remove. Expected return values are:
             * - Any value evaluating to `true`: the element is removed.
             * - Any value evaluating to `false`: the element is kept.
             * @returns `arr` with all elements removed that `f` returned `true` for.
             */
            static removeFunction(arr, f)
            {
                cpy := arr.Clone()
                for val in arr
                {
                    if (f(val))
                    {
                        cpy[A_Index] := codebase.collectionOperations.arrayOperations.arrayRemoveItem
                    }
                }
                return codebase.collectionOperations.arrayOperations.remove(cpy, [codebase.collectionOperations.arrayOperations.arrayRemoveItem])
            }

            /**
             * Checks whether an Array contains the specified item. This is basically `array.IndexOf(element)`, but finds _all_ instead of only the first instance.
             * @param arr The Array to iterate over.
             * @param item The item to look for.
             * @param caseSense Whether case matters when comparing the values. Defaults to `true` if omitted.
             * @throws `TypeError` if `arr` is not an Array.
             * @note The return value is _always_ an Array, even if there is only one index for `item` in `arr` or it was not found at all. To check just _if_ `item` is present in `arr` at all, use the `Length` prop as an `if` condition.
             * @returns An Array of indices.
             */
            static arrayContains(arr, item, caseSense := true)
            {
                if (Type(arr) !== "Array")
                {
                    throw TypeError("Invalid type for ``array``. Received ``" . Type(arr) . "``, expected ``Array``.")
                }

                j := []
                for elem in arr
                {
                    if ((caseSense ? elem == item : elem = item))
                    {
                        j.Push(A_Index)
                    }
                }

                return j
            }

            /**
             * Checks whether an Array or any element of the Array contains the specified item.
             * @param arr The Array to iterate over.
             * @param item The item to look for.
             * @param caseSense Whether case matters when comparing the values. Defaults to `true` if omitted.
             * @throws `TypeError` if `arr` is not an Array.
             * @note If an element in `arr` cannot be interpreted as a string or numerical string, its `ToString` method is called. If this _also_ fails, the element is skipped and considered not to contain `item`.
             * @returns An Array of indices if `item` was found in one or more elements of `arr`. This is always an Array, even if `item` is present in an element of `arr` only once.
             * @returns An empty Array if `item` was not found.
             */
            static arrayContainsPartial(arr, item, caseSense := true)
            {
                if (Type(arr) !== "Array")
                {
                    throw TypeError("Invalid type for ``array``. Received ``" . Type(arr) . "``, expected ``Array``.")
                }

                j := []
                for elem in arr
                {
                    if ((caseSense ? elem == item : elem = item))
                    {
                        j.Push(A_Index)
                        continue
                    }

                    try
                    {
                        if (InStr(elem, item, caseSense))
                        {
                            j.Push(A_Index)
                            continue
                        }
                    }
                    catch
                    {
                        try
                        {
                            if (InStr(elem.ToString(), item, caseSense))
                            {
                                j.Push(A_Index)
                                continue
                            }
                        }
                    }
                }

                return j
            }

            /**
             * Finds all elements in a source Array that are _not_ present in any of the other Arrays.
             * @param src The source Array to iterate over.
             * @param arrs Any number of Arrays to look for elements from `src` in.
             * @note This function is not commutative (i.e. `arrayNotIntersect(arr_1, arr_2)` is not equivalent to `arrayNotIntersect(arr_2, arr_1)`) as the source Array `src` determines which items are even candidates to be returned.
             * @note This function complements `codebase.collectionOperations.arrayOperations.arrayIntersect`. Combining the results of the function calls `arrayIntersect(arr_1, arr_2)` and `arrayNotIntersect(arr_1, arr_2)` yields `arr_1`.
             * @returns An Array of elements from `src` that are not present in any of the other Arrays.
             */
            static arrayNotIntersect(src, arrs*)
            {
                for arr in arrs
                {
                    if (Type(arr) !== "Array")
                    {
                        throw TypeError("Invalid type for ``arrs[" . A_Index . "]``. Received ``" . Type(arrs[A_Index]) . "``, expected ``Array``.")
                    }
                }

                out := src.Clone()

                for arr in arrs
                {
                    for elem in arr
                    {
                        present := codebase.collectionOperations.arrayOperations.arrayContains(out, elem)
                        codebase.collectionOperations.arrayOperations.arrSort(&present, true)
                        if (present.Length)
                        {
                            for j in present
                            {
                                out.RemoveAt(j)
                            }
                        }
                    }
                }

                return out
            }

            /**
             * Finds all elements in a series of Arrays that are only present in _all_ input Arrays.
             * @param arrs The arrays to analyze.
             * @note This function is commutative (i.e. `arrayIntersect(arr_1, arr_2)` is equivalent to `arrayIntersect(arr_2, arr_1)`).
             * @note This function complements `codebase.collectionOperations.arrayOperations.arrayNotIntersect`. Combining the results of the function calls `arrayIntersect(arr_1, arr_2)` and `arrayNotIntersect(arr_1, arr_2)` yields `arr_1`.
             * @returns An Array of elements that are present in all passed Arrays.
             */
            static arrayIntersect(arrs*)
            {
                for arr in arrs
                {
                    if (Type(arr) !== "Array")
                    {
                        throw TypeError("Invalid type for ``arrs[" . A_Index . "]``. Received ``" . Type(arrs[A_Index]) . "``, expected ``Array``.")
                    }
                }

                shortest := arrs[1]
                out := []

                ; Find the input Array with the shortest Length, as only the elements contained in it are even candidates for the intersect Array
                for arr in arrs
                {
                    if (arr.Length < shortest.Length)
                    {
                        shortest := arr
                    }
                }

                arrs.RemoveAt(codebase.collectionOperations.arrayOperations.arrayContains(arrs, shortest)[1])

                for se in shortest
                {
                    presentIn := []
                    for arr in arrs
                    {
                        presentIn.Push(codebase.collectionOperations.arrayOperations.arrayContains(arr, se).Length !== 0)
                    }

                    if (codebase.collectionOperations.and(presentIn*))
                    {
                        out.Push(se)
                    }
                }

                return out
            }

            /**
             * Reverses the order of the items in an Array.
             * @param arr The Array to reverse.
             * @throws `TypeError` if `array` is not an Array.
             * @returns The reversed array.
             */
            static arrayReverse(arr)
            {
                if (Type(arr) !== "Array")
                {
                    throw TypeError("Invalid type for ``arr``. Received ``" . Type(arr) . "``, expected ``Array``.")
                }

                out := []
                for searchx in codebase.range(arr.Length, 1, -1)
                {
                    out.Push(arr[searchx])
                }

                return out
            }

            /**
             * Swaps two elements of an Array.
             * @param arr A `VarRef` to the Array to swap elements in.
             * @param i The index of the first element to swap.
             * @param j The index of the second element to swap.
             * @throws `TypeError` if `array` is not an Array.
             */
            static arrSwap(&arr, i, j)
            {
                if (Type(arr) !== "Array")
                {
                    throw TypeError("Invalid type for ``arr``. Received ``" . Type(arr) . "``, expected ``Array``.")
                }

                temp := arr[i]
                arr[i] := arr[j]
                arr[j] := temp
            }

            static arrShuffle(arr)
            {
                nArr := arr.Clone()
                if (Type(arr) !== "Array")
                {
                    throw TypeError("Invalid type for ``arr``. Received ``" . Type(arr) . "``, expected ``Array``.")
                }
                
                for i in codebase.range(1, arr.Length, 1)
                {
                    j := Random(1, arr.Length)
                    codebase.collectionOperations.arrayOperations.arrSwap(&nArr, i, j)
                }
                return nArr
            }

            /**
             * Sorts an Array.
             *
             * Current implementation: Quick sort (https://en.wikipedia.org/wiki/Quicksort#cite_ref-:2_16-2)
             * @param arr A `VarRef` to the Array to be sorted.
             * @param sortDesc Whether to sort the Array in descending order. Defaults to `false` if omitted.
             * @param stringComp Whether to use string comparison for sorting. If omitted, the sort method will be determined automatically from the Array's contents.
             * - Initially, numerical comparison is used.
             * - If any value in `arr` is not a number, string comparison is used instead.
             * @param l The lower index of the range to sort. Defaults to `1` if omitted.
             * @param r The upper index of the range to sort. Defaults to `arr.Length` if omitted.
             * @note When `stringComp` is truthy, `StrCompare` with the `"Logical"` setting is used as the sort callback function. The following problems arise when comparing strings containing both letters _and_ numbers, numerical strings and strings containing _only_ letters:
             * - `"39.21"` is numerically less than, but lexically greater than `"39.3"` (`"39.21" > "39.3"`, but `"39.2" < "39.3"`, _but_ `"39.21" < "39.30"`).
             * - The above applies to mixed strings like `"a39.21"`.
             * - Rules such as `"39.21" < "39.30"` only hold if the compared items are both strings and have the same decimal precision (see 1st bullet).
             * - Pure numbers and numerical strings are considered less than mixed and letter-only strings: `[1, "2.3", 7.33, "a", "b", "b6", "b7", "b7.3", "b7.21", "c"]` (this is "correctly" sorted). This allows sorting floats as strings to prevent floating-point precision errors. To create a string from a float so that it works with this sort function, use `String(Round())` on all floats to be sorted and round them to the _same_ precision.
             * @throws `Error` when attempting to compare strings numerically.
             * @throws `TypeError` if `arr` is not a `VarRef` to an Array.
             */
            static arrSort(&arr, sortDesc := false, stringComp?, l?, r?)
            {
                if (!IsSet(l))
                {
                    l := 1
                }
                if (!IsSet(r))
                {
                    r := arr.Length
                }
                if (!IsSet(stringComp))
                {
                    stringComp := false
                    for elem in arr
                    {
                        if (!IsNumber(elem))
                        {
                            stringComp := true
                            break
                        }
                    }
                }

                partition(&pArr, sortDesc, stringComp, l, r)
                {
                    pivot := pArr[Floor((r + l) / 2)]
                    
                    i := l - 1
                    j := r + 1

                    if (stringComp)
                    {
                        if (sortDesc)
                        {
                            iI := () => StrCompare(pArr[i], pivot, "Logical") <= 0
                            iJ := () => StrCompare(pArr[j], pivot, "Logical") >= 0
                        }
                        else
                        {
                            iI := () => StrCompare(pArr[i], pivot, "Logical") >= 0
                            iJ := () => StrCompare(pArr[j], pivot, "Logical") <= 0
                        }
                    }
                    else
                    {
                        if (sortDesc)
                        {
                            iI := () => pArr[i] <= pivot
                            iJ := () => pArr[j] >= pivot
                        }
                        else
                        {
                            iI := () => pArr[i] >= pivot
                            iJ := () => pArr[j] <= pivot
                        }
                    }
                    
                    Loop
                    {
                        Loop
                        {
                            i++
                            if (iI())
                            {
                                break
                            }
                        }
                        Loop
                        {
                            j--
                            if (iJ())
                            {
                                break
                            }
                        }

                        if (i >= j)
                        {
                            return j
                        }

                        codebase.collectionOperations.arrayOperations.arrSwap(&pArr, i, j)
                    }
                }
                
                if (Type(arr) !== "Array")
                {
                    throw TypeError("Invalid type for ``arr``. Received ``" . Type(arr) . "``, expected (a reference to) an ``Array``.")
                }

                if (l >= 0 && r >= 0 && l < r)
                {
                    p := partition(&arr, sortDesc, stringComp, l, r)
                    codebase.collectionOperations.arrayOperations.arrSort(&arr, sortDesc, stringComp, l, p)
                    codebase.collectionOperations.arrayOperations.arrSort(&arr, sortDesc, stringComp, p + 1, r)
                }
            }

            /**
             * Extracts part of an Array. Intended to replicate syntax like `arr[3:]`, `arr[:6]` or `arr[4:7]`.
             * @param arr The Array to get a subarray from.
             * @param start The index in `arr` of where to start extracting items. Defaults to `1` (the first item) if omitted.
             * @param stop The index in `arr` of where to stop extracting items. Defaults to `arr.Length` (the last item) if omitted.
             * @throws `TypeError` if `arr` is not an Array.
             * @note An empty Array is returned if a value greater than `arr.Length` is explicitly passed for `start`.
             * @note An empty Array is returned if `0` is explicitly passed for `stop`.
             * @returns The subarray extracted from `arr`. This is always an Array, even if only one item is extracted.
             */
            static subarray(arr, start := 1, stop?)
            {
                if (Type(arr) !== "Array")
                {
                    throw TypeError("Invalid type for ``arr``. Received ``" . Type(arr) . "``, expected ``Array``.")
                }
                
                if (!IsSet(stop))
                {
                    stop := arr.Length
                }

                if (stop == 0 || start > arr.Length)
                {
                    return []
                }

                sub := []
                for j in codebase.range(start, stop)
                {
                    sub.Push(arr[j])
                }
                return sub
            }

            /**
             * Concatenates (combines) a series of Arrays into one.
             * @param arrs The Arrays to concatenate.
             * @returns The items of the given `arrs` combined into one in the order they were passed.
             */
            static arrayConcat(arrs*)
            {
                comb := []
                for searchx in arrs
                {
                    for i in searchx
                    {
                        comb.Push(i)
                    }
                }
                return comb
            }

            /**
             * Splits an Array into multiple subarrays with a given length.
             * @param arr The Array to split.
             * @param n The amount of items in each subarray. If `Mod(arr.Length, n)` is not `0`, the last Array in the return Array will contain `n - Mod(arr.Length, n)` items.
             * @returns An Array of Arrays, each containing `n` of `arr`'s items in the same order.
             */
            static arraySplit(arr, n)
            {
                split := []
                for j in codebase.range(1, Ceil(arr.Length / n))
                {
                    split.Push([])
                    yoffset := (A_Index - 1) * n
                    try
                    {
                        for searchx in codebase.range(1 + yoffset, n + yoffset)
                        {
                            split[j].Push(arr[searchx])
                        }
                    }
                }
                return split
            }

            /**
            * Creates an index Map of an Array, each value of it being a key of a Map object. Its corresponding value is the amount of times it is present in the Array.
            * @param arr The Array to analyze.
            * @returns The Map object as described above.
            */
            static arrayIndex(arr)
            {
                m := Map()
                for elem in arr
                {
                    if (m.Has(elem))
                    {
                        m.Set(elem, m.Get(elem) + 1)
                    }
                    else
                    {
                        m.Set(elem, 1)
                    }
                }
                return m
            }
        }

        ; Yeah yeah, an Object isn't a collection in the usual sense but I don't know where else to put this...
        class objectOperations
        {
            /**
             * Determines the number of OwnProps an object possesses.
             * @param obj The object the OwnProps of which should be counted.
             * @returns The number of OwnProps `obj` possesses.
             */
            static getOwnPropsCount(obj)
            {
                n := 0
                for in obj.OwnProps()
                {
                    n++
                }
                return n
            }

            /**
             * Steps through an objects OwnProps and compiles their name-value pairs into a Map.
             * @param obj The object the OwnProps of which to convert to a Map.
             * @returns The OwnProps of `obj` as key-value pairs in a Map.
             */
            static toMap(obj)
            {
                out := Map()
                for n, v in obj.OwnProps()
                {
                    out.Set(n, v)
                }
                return out
            }

            /**
             * Steps through an objects OwnProps and compiles their name-value pairs into a single string.
             * @param obj The object the OwnProps of which to "stringify".
             * @param indentStr The string to use for indenting the stringified OwnProps.
             * @returns The OwnProps of `obj` in string format.
             */
            static toString(obj, indentStr := "    ", &count?)
            {
                count := 0
                out := ""
                for n, v in obj.OwnProps()
                {
                    count++
                    out .= '[Prop]`n'
                    out .= indentStr . "Name | " . Trim(codebase.elemsOut(n), '`n`t ') . '`n'
                    out .= indentStr . "Value | " . Trim(codebase.elemsOut(v), '`n`t ') . "`n"
                }
                return Trim(out, "`t`n`r")
            }
        }
    }

    /**
     * A series of functions and classes for various Math.
     */
    class math
    {
        /**
         * A collection of mathematical constants.
         */
        class constants
        {
            /**
             * Euler's constant. Exists as the definition used below, re-defined simply as `e` for convenience.
             */
            static e := Exp(1)
            /**
             * `π` ("pi"), defined as the ratio of a circle's circumference to its diameter.
             */
            static pi := 4 * ATan(1)
            /**
             * `φ` ("phi"), the golden ratio.
             *
             * Two quantities `a`, `b` with `a > b > 0` are said to be in the golden ratio `φ` if `(a + b) / a == a / b == φ`.
             */
            static phi := (1 + Sqrt(5)) / 2
            /**
             * `δ_S` ("delta S"), the silver ratio.
             *
             * Two quantities `a`, `b` with `a > b > 0` are said to be in the silver ratio `δ_S` if `(2a + b) / a == a / b == δ_S`.
             */
            static delta_S := 1 + Sqrt(2)
        }

        /**
         * A class to deal with complex numbers.
         * @note AHKv2 does not have meta-functions for simple arithmetic or similar. As such, do not attempt to perform such operations on a `codebase.math.complex.Number`, use the functions defined in this class instead.
         */
        class complex
        {
            class Number
            {
                /**
                 * The real component of the complex number.
                 */
                real := 0
                /**
                 * The imaginary / complex component of the complex number.
                 */
                imaginary := 0

                /**
                 * Instantiates a new `codebase.math.complex.Number` object.
                 * @param a The real component of the complex number.
                 * @param b The imaginary / complex component of the complex number.
                 * @note Complex numbers with complex component `b = 0` are still treated as complex by all functions in `codebase.math.complex`. This might produce unexpected results.
                 * @returns A `codebase.math.complex.Number` object.
                 */
                __New(a, b)
                {
                    this.real := a
                    this.imaginary := b
                }
            }

            /**
             * Multiplies any number of (complex) numbers.
             * @param z The numbers to multiply.
             * @note If none of the numbers in `z` are complex, the return value is not complex either.
             * @returns The numbers in `z` multiplied.
             */
            static multiply(z*)
            {
                op := z.Clone()
                a := 1
                b := 0
                for _z in z
                {
                    if (Type(_z) == "codebase.math.complex.Number")
                    {
                        a := _z.real
                        b := _z.imaginary
                        op.RemoveAt(A_Index)
                        break
                    }
                }

                for _z in op
                {
                    if (_z is Number)
                    {
                        a *= _z
                        b *= _z
                        continue
                    }
                    _a := (_z.real * a) - (_z.imaginary * b)
                    _b := (_z.imaginary * a) + (_z.real * b)
                    a := _a
                    b := _b
                }
                return (b !== 0 ? codebase.math.complex.Number(a, b) : a)
            }

            /**
             * Calculates the absolute value of a complex number, defined as the distance from the origin of the complex plane.
             * @param z The complex number.
             * @throws `TypeError` if `z` is not a `codebase.math.complex.Number`.
             * @returns The distance of `z` from the origin of the complex plane.
             */
            static abs(z)
            {
                if (Type(z) !== "codebase.math.complex.Number")
                {
                    throw TypeError("Invalid type for ``z``. Received ``" . Type(z) . "``, expected ``codebase.math.complex.Number``.")
                }

                return Sqrt((z.real ** 2) + (z.imaginary ** 2))
            }

            /**
             * Adds any number of (complex) numbers.
             * @param z The numbers to add.
             * @note If none of the numbers in `z` are complex, the return value is not complex either.
             * @returns All numbers in `z` added up.
             */
            static add(z*)
            {
                a := 0
                b := 0
                for _z in z
                {
                    if (_z is Number)
                    {
                        a += _z
                        continue
                    }
                    a += _z.real
                    b += _z.imaginary
                }
                return (b !== 0 ? codebase.math.complex.Number(a, b) : a)
            }

            /**
             * Subtracts any number of (complex) numbers from the first in the series.
             * @param z The numbers to use for the calculation. The first is used as a base from which the rest will be subtracted.
             * @note If none of the numbers in `z` are complex, the return value is not complex either.
             * @returns The numbers `z[2]` through `z[z.Length]` subtracted from `z[1]`.
             */
            static subtract(z*)
            {
                zs := [z[1]]
                for _z in z
                {
                    if (_z is Number)
                    {
                        zs.Push(-_z)
                        continue
                    }
                    zs.Push(codebase.math.complex.Number(-_z.real, -_z.imaginary))
                }
                return codebase.math.complex.add(zs*)
            }

            /**
             * Divides a (complex) number by another.
             * @param z1 The dividend to use for the calculation.
             * @param z2 The divisor to use for the calculation.
             * @note If none of the numbers in `z` are complex, the return value is not complex either.
             * @returns The result of the appropriate division method, dependent on the input types.
             */
            static divide(z1, z2)
            {
                if (z2 is Number)
                {
                    if (z1 is Number)
                    {
                        return z1 / z2
                    }
                    else
                    {
                        return codebase.math.complex.Number(
                            z1.real / z2,
                            z2.imaginary / z2
                        )
                    }
                }
                else
                {
                    return codebase.math.complex.Number(
                        ((z1.real * z2.real) + (z1.imaginary * z2.imaginary) / ((z2.real ** 2) + (z2.imaginary ** 2))),
                        ((z1.imaginary * z2.real) - (z1.real * z2.imaginary) / ((z2.real ** 2) + (z2.imaginary ** 2)))
                    )
                }
            }
        }

        /**
         * The rest of the `codebase.math` class is a lot more useful, I promise.
         */
        class misc
        {
            /**
             * An implementation of the RNG function of _Super Mario 64_.
             */
            sm64rng(inp)
            {
                input := codebase.datatypes.UInt16()
                S0 := codebase.datatypes.UInt16()
                S1 := codebase.datatypes.UInt16()
                
                input.value := inp
                if (input.value == 0x560A)
                {
                    input.value := 0
                }
                S0.value := (input.value & 0x00FF) << 8
                S0.value := S0.value ^ input.value
                input.value := ((S0.value & 0xFF) << 8) | ((S0.value & 0xFF00) >> 8)
                S0.value := ((S0.value & 0x00FF) << 1) ^ input.value

                S1.value := (S0.value >> 1) ^ 0xFF80
                if ((S0.value & 1) == 0)
                {
                    if (S1.value == 0xAA55)
                    {
                        input.value := 0
                    }
                    else
                    {
                        input.value := S1.value ^ 0x1FF4
                    }
                }
                else
                {
                    input.value := S1.value ^ 0x8180
                }
                return input.value := input.value
            }

            /**
             * Checks whether a number is _nearly_ equal to a specific wanted number while allowing a specific amount of error.
             * @param a The number to check.
             * @param b The number to check against.
             * @param error The amount of error to allow. Defaults to `0.0000000000000001` if omitted.
             * @note The default value specified for `error` is about as precise of a number as AHKv2 can still represent (15 digits).
             * @note This should be used instead of direct comparison of `a` to `b` because of floating point errors.
             * @returns `true` if `a` is "equal" to `b` within a margin of `error`, `false` otherwise.
             */
            static equal(error := 10 ** -8, vals*)
            {
                for val in vals
                {
                    if (Abs(val - vals[1]) > error)
                    {
                        return false
                    }
                }
                return true
            }

            /**
             * Calculates the slope of a function at a given input value. This is deliberately not called `derivative` as it does not return the input function's derivative.
             * @param function The function to calculate the slope of. Must be a function of one variable and return a number.
             * @param x The input value to calculate the slope at.
             * @returns The slope of `function` at `x`.
             */
            static riseOverRun(function, x) => Round((function(x + 0.00001) - function(x)) / 0.00001)

            /**
             * Calculates the difference of the squares of two numbers.
             * @param a The first number.
             * @param b The second number.
             * @note The return value is not absolute. It is negative if `b` is greater than `a`.
             * @returns The difference of the squares of `a` and `b`.
             */
            static squareDifference(a, b)
            {
                a := Abs(a)
                b := Abs(b)

                return a > b ? (2 * a * (a - b)) - ((a - b) ** 2) : - codebase.math.misc.squareDifference(b, a)
            }

            /**
             * Generates a random polynomial.
             * @param maxDegree The maximum degree the polynomial may have.
             * @param maxCoeff The maximum value any of the terms' coefficients may assume. The minimum it may assume is then defined as `-maxCoeff`. Defaults to 30 if omitted.
             * @param forceMax Whether to only generate polynomials that possess an `x^max` term. Defaults to `true` if omitted.
             * @param allTerms Whether to only generate polynomials that possess all terms ranging from `x^max` to `x^0` (constant). Defaults to `false` if omitted.
             * @param noConstant Whether to allow the `x^0` term to be `0`. Defaults to `true` if omitted.
             * @param rationalCoefficients Whether to allow coefficients to be rational instead of forcing them to be integers. Defaults to `false` if omitted.
             * @note If `rationalCoefficients` is `true`, the coefficients are very likely unmanageable due to them being truly random numbers instead of, for example, fractions with integer numerators and denominators.
             * @throws `TypeError` if the value passed for `maxDegree` is not an integer.
             * @throws `ValueError` if `maxDegree` is not greater than `0`.
             * @returns The generated polynomial as a string.
             */
            static ranpoly(maxDegree, maxCoeff := 30, forceMax := true, allTerms := false, noConstant := true, rationalCoefficients := false)
            {
                if (Type(maxDegree) !== "Integer")
                {
                    throw TypeError("Invalid type for ``maxDegree``. Received ``" . Type(maxDegree) . "``, expected an integer greater than ``0``.")
                }
                if (maxDegree <= 0)
                {
                    throw ValueError("Invalid value for ``maxDegree``. Received ``" . maxDegree . "``, expected a value greater than ``0``.")
                }

                if (forceMax)
                {
                    ran := Random(-maxCoeff / 1, maxCoeff)
                    if (Round(ran) == 0)
                    {
                        ran := 1.0
                    }
                    coeff := [(rationalCoefficients ? ran : Round(ran))]
                }
                else
                {
                    coeff := []
                }

                Loop (maxDegree - 1)
                {
                    ran := Random(-maxCoeff / 1, maxCoeff)
                    if (Round(ran) == 0)
                    {
                        if (allTerms)
                        {
                            ran := 1.0
                        }
                    }
                    coeff.Push((rationalCoefficients ? ran : Round(ran)))
                }

                ran := Random(-maxCoeff / 1, maxCoeff)
                if (Round(ran) == 0)
                {
                    if (noConstant)
                    {
                        ran := 1.0
                    }
                }
                coeff.Push((rationalCoefficients ? ran : Round(ran)))

                out := ""
                for d in codebase.range(maxDegree, 0)
                {
                    out .= (A_Index !== 1 && coeff[A_Index] >= 0 ? "+" : "") . (coeff[A_Index] ? coeff[A_Index] : "") . (A_Index !== maxDegree + 1 ? "x^" . d : "")
                }

                out := RegExReplace(out, "[0-9]+x^0", "")
                out := StrReplace(out, "x^1", "x")
                out := StrReplace(out, "+1x^", "+x^")
                out := StrReplace(out, "-1x^", "-x^")
                out := LTrim(out, "1.0+`t" . " ")
                out := RTrim(out, ".0`t" . " ")
                out := RegExReplace(out, "\++", "+")
                out := StrReplace(out, "+-", "-")

                return out
            }

            /**
             * Uses Newtons method to approximate / calculate the square root of a number. Accuracy of the result depends on the amount of iterations performed.
             * @param n The number to calculate the root of.
             * @param r Which root of `n` to calculate (2nd, 3rd etc.).
             * @param guess An initial guess to use for the calculation. Defaults to `2 * n` if `n` is between `0` and `1` or `0.5 * n` if `n` is greater than `1` if omitted.
             * @param iter The amount of iterations to perform. As the N-R method delivers a precise-enough answer relatively quickly (and AutoHotkey usually can't handle values more precise than are returned after this), defaults to `6` if omitted.
             * @returns An Array with all steps of the approximation. The first element is `guess` itself, the last element (index `[-1]`) is the value after `iter` approximations.
             */
            static newtonRaphson(n, r, guess?, iter := 6)
            {
                if (!IsSet(guess))
                {
                    guess := (n > 0 && n < 1 ? 2 * n : 0.5 * n)
                }
                if (guess <= 0)
                {
                    throw ValueError("Invalid value for ``guess``. Received ``" . guess . "``, expected a value greater than ``0``.")
                }
                if (n < 0)
                {
                    throw ValueError("Invalid value for ``n``. Received ``" . n . "``, expected a value greater than or equal to ``0``.")
                }
                if (r == 0)
                {
                    throw ValueError("Invalid value for ``r``. Received ``" . r . "``, expected a value not equal to ``0``.")
                }
                if (iter <= 0)
                {
                    throw ValueError("Invalid value for ``iter``. Received ``" . iter . "``, expected a value greater than or equal to ``0``.")
                }
                if (r == 1)
                {
                    return n
                }

                steps := [guess]
                for j in codebase.range(1, iter)
                {
                    steps.Push(guess -= ((guess ** r - 3) / (r * (guess ** (r - 1)))))
                }

                return steps
            }

            /**
             * Returns the fractional part of a number.
             * @param n The number to return the fractional part of.
             * @returns The fractional part of `n`. Between `0` inclusive and `1` exclusive.
             */
            static frac(n) => Mod(n, 1)

            /**
             * Returns the integer part of a number.
             * @param n The number to return the integer part of.
             * @returns The integer part of `n`.
             */
            static int(n) => Integer(Round(n - codebase.math.misc.frac(n)))

            /**
             * Calculates all coprimes of a number less than that number.
             */
            static coprimes(n)
            {
                pf := codebase.math.primeFactors(n)

                out := codebase.range(1, n - 1)
                for pk in pf
                {
                    for searchx in codebase.range(1, n - 1)
                    {
                        if (pk * searchx > n)
                        {
                            break
                        }

                        for j in codebase.collectionOperations.arrayOperations.arrayContains(out, pk * searchx)
                        {
                            out[j] := codebase.collectionOperations.arrayOperations.arrayRemoveItem
                        }
                    }
                }

                return codebase.collectionOperations.arrayOperations.remove(out, [codebase.collectionOperations.arrayOperations.arrayRemoveItem])
            }
        }

        class trig
        {
            /**
             * The rest of the `codebase.math.trig` class is a lot more useful, I promise.
             */
            class misc
            {
                /**
                 * Creates a sine and cosine function that, when provided with arguments in a specific range, return coordinates that define an ellipse around given input coordinates.
                 * @param x The `x`-coordinate of the point the two functions should define an ellipse around.
                 * @param y The `y`-coordinate of the point the two functions should define an ellipse around.
                 * @param rSin The factor to use for the sine function, corresponding to the horizontal radius of the ellipse.
                 * @param rCos The factor to use for the cosine function, corresponding to the vertical radius of the ellipse. Defaults to `rSin` if omitted, making the ellipse a circle.
                 * @param resolution How many "degrees" constitute a full rotation around the point `x, y`. Defaults to `360` if omitted.
                 * @note May also be used for linear instead of elliptical or circular movement by using only one of the output functions.
                 * @returns An object in the pattern `{ sin: Func(1), cos: Func(1) }`.
                 */
                static ellipseAround(x, y, rSin, rCos?, resolution := 360)
                {
                    if (!IsSet(rCos))
                    {
                        rCos := rSin
                    }

                    return {
                        sin: (this, d) => rSin * Sin((d / resolution) * (2 * codebase.math.constants.pi)) + x,
                        cos: (this, d) => rCos * (-Cos((d / resolution) * (2 * codebase.math.constants.pi))) + y
                    }
                }
            }

            /**
             * Returns the inverse function (`f^-1` / `arcf`) to one of the trig functions.
             * @param trigFunc A trig function. Value must be one of the following:
             * - `Sin`
             * - `Cos`
             * - `Tan`
             * - `codebase.math.trig.Cot`
             * - `codebase.math.trig.Sec`
             * - `codebase.math.trig.Csc`
             * - `codebase.math.trig.Sinh`
             * - `codebase.math.trig.Cosh`
             * - `codebase.math.trig.Tanh`
             * - `codebase.math.trig.Coth`
             * - `codebase.math.trig.Sech`
             * - `codebase.math.trig.Csch`
             * - One of the above functions' inverse functions.
             * @returns The input function's corresponding inverse function (e.g. `trigInverse(Cos) -> ACos`).
             */
            static trigInverse(trigFunc)
            {
                retMap := Map(
                    Sin, ASin,
                    Cos, ACos,
                    Tan, ATan,
                    codebase.math.trig.Cot, codebase.math.trig.ACot,
                    codebase.math.trig.Sec, codebase.math.trig.ASec,
                    codebase.math.trig.Csc, codebase.math.trig.ACsc,
                    codebase.math.trig.Sinh, codebase.math.trig.ASinh,
                    codebase.math.trig.Cosh, codebase.math.trig.ACosh,
                    codebase.math.trig.Tanh, codebase.math.trig.ATanh,
                    codebase.math.trig.Coth, codebase.math.trig.ACoth,
                    codebase.math.trig.Sech, codebase.math.trig.ASech,
                    codebase.math.trig.Csch, codebase.math.trig.ACsch
                )
                codebase.collectionOperations.mapOperations.mapCombine(&retMap, true, codebase.collectionOperations.mapOperations.mapInvert(retMap))
                
                try
                {
                    return retMap.Get(trigFunc)
                }
                catch
                {
                    throw ValueError("Invalid value for ``trigFunc``. Received ``" . trigFunc . "``, expected one of the trig functions.")
                }
            }

            /**
             * Returns the trigonometric cotangent of a number.
             * @param n The number to calculate the cotangent of.
             * @returns `n`'s cotangent.
             */
            static Cot(n) => 1 / Tan(n)

            /**
             * Returns the arccotangent (the number whose cotangent is the input) in radians.
             * @param n The number to calculate the arccotangent of.
             * @returns `n`'s arccotangent.
             */
            static ACot(n) => ATan(1 / n)

            /**
             * Returns the trigonometric secant of a number.
             * @param n The number to calculate the secant of.
             * @returns `n`'s secant.
             */
            static Sec(n) => 1 / Cos(n)

            /**
             * Returns the arcsecant (the number whose secant is the input) in radians.
             * @param n The number to calculate the arcsecant of.
             * @returns `n`'s arcsecant.
             */
            static ASec(n) => ACos(1 / n)

            /**
             * Returns the trigonometric cosecant of a number.
             * @param n The number to calculate the cosecant of.
             * @returns `n`'s cosecant.
             */
            static Csc(n) => 1 / Sin(n)

            /**
             * Returns the arccosecant (the number whose cosecant is the input) in radians.
             * @param n The number to calculate the arccosecant of.
             * @returns `n`'s arccosecant.
             */
            static ACsc(n) => ASin(1 / n)

            /**
             * Returns the trigonometric hyperbolic sine of a number.
             * @param n The number to calculate the hyperbolic sine of.
             * @returns `n`'s hyperbolic sine.
             */
            static Sinh(n) => ((codebase.math.constants.e ** n) - (codebase.math.constants.e ** (-n))) / 2

            /**
             * Returns the hyperbolic arcsine (the number whose hyperbolic sine is the input) in radians.
             * @param n The number to calculate the hyperbolic arcsine of.
             * @returns `n`'s hyperbolic arcsine.
             */
            static ASinh(n) => Ln(n + Sqrt(n ** 2 + 1))

            /**
             * Returns the trigonometric hyperbolic cosine of a number.
             * @param n The number to calculate the hyperbolic cosine of.
             * @returns `n`'s hyperbolic cosine.
             */
            static Cosh(n) => ((codebase.math.constants.e ** n) + (codebase.math.constants.e ** (-n))) / 2

            /**
             * Returns the hyperbolic arccosine (the number whose hyperbolic cosine is the input) in radians.
             * @param n The number to calculate the hyperbolic arccosine of.
             * @returns `n`'s hyperbolic arccosine.
             */
            static ACosh(n) => Ln(n + Sqrt(n ** 2 - 1))

            /**
             * Returns the trigonometric hyperbolic tangent of a number.
             * @param n The number to calculate the hyperbolic tangent of.
             * @returns `n`'s hyperbolic tangent.
             */
            static Tanh(n) => codebase.math.trig.Sinh(n) / codebase.math.trig.Cosh(n)

            /**
             * Returns the hyperbolic arctangent (the number whose hyperbolic tangent is the input) in radians.
             * @param n The number to calculate the hyperbolic arctangent of.
             * @returns `n`'s hyperbolic arctangent.
             */
            static ATanh(n) => 0.5 * Ln((1 + n) / (1 - n))

            /**
             * Returns the trigonometric hyperbolic cotangent of a number.
             * @param n The number to calculate the hyperbolic cotangent of.
             * @returns `n`'s hyperbolic cotangent.
             */
            static Coth(n) => 1 / codebase.math.trig.Tanh(n)

            /**
             * Returns the hyperbolic arccotangent (the number whose hyperbolic cotangent is the input) in radians.
             * @param n The number to calculate the hyperbolic arccotangent of.
             * @returns `n`'s hyperbolic arccotangent.
             */
            static ACoth(n) => codebase.math.trig.ATanh(1 / n)

            /**
             * Returns the trigonometric hyperbolic secant of a number.
             * @param n The number to calculate the hyperbolic secant of.
             * @returns `n`'s hyperbolic secant.
             */
            static Sech(n) => 1 / codebase.math.trig.Cosh(n)

            /**
             * Returns the hyperbolic arcsecant (the number whose hyperbolic secant is the input) in radians.
             * @param n The number to calculate the hyperbolic arcsecant of.
             * @returns `n`'s hyperbolic arcsecant.
             */
            static ASech(n) => codebase.math.trig.ACosh(1 / n)

            /**
             * Returns the trigonometric hyperbolic cosecant of a number.
             * @param n The number to calculate the hyperbolic cosecant of.
             * @returns `n`'s hyperbolic cosecant.
             */
            static Csch(n) => 1 / codebase.math.trig.Sinh(n)

            /**
             * Returns the hyperbolic arccosecant (the number whose hyperbolic cosecant is the input) in radians.
             * @param n The number to calculate the hyperbolic arccosecant of.
             * @returns `n`'s hyperbolic arccosecant.
             */
            static ACsch(n) => codebase.math.trig.ASinh(1 / n)

            static sinc(n)
            {
                if (n == 0)
                {
                    return 1
                }
                return Sin(n) / n
            }

            static sincNormalized(n)
            {
                if (n == 0)
                {
                    return 1
                }
                return Sin(codebase.math.constants.pi * n) / (codebase.math.constants.pi * n)
            }
        }

        class vectorGeometry
        {
            class Vector
            {
                /**
                 * Instantiates a new `codebase.math.vectorGeometry.Vector` from a series of passed coordinates.
                 * It defines a Vector as described below.
                 * @param args The new Vector's coordinates. They can later be get or set using property accessor syntax. The properties' names follow the pattern `vn`, where `n` is an integer between `1` and the number of coordinates passed (`args.Length`). The order they are passed in is preserved when it comes to naming the properties.
                 * @note Vectors of dimensions `0` and `1` are not supported, meaning at least `2` coordinates must be passed to successfully instantiate an object of the class.
                 * @returns A `codebase.math.vectorGeometry.Vector` object.
                 */
                __New(args*)
                {
                    if (args.Length < 2)
                    {
                        throw ValueError("Cannot construct Vector object from ``" . args.Length . "`` arguments, expected at least ``2``.")
                    }

                    this.dim := args.Length
                    for v in args
                    {
                        this.DefineProp("v" . A_Index, { Value: v })
                    }
                }

                __Enum(p*) => this.asArray().__Enum(p*)

                /**
                 * Compiles the coordinates of the `codebase.math.vectorGeometry.Vector` object into an Array.
                 * @returns array
                 */
                asArray()
                {
                    o := []
                    for , coord in this.OwnProps()
                    {
                        o.Push(coord)
                    }
                    return o
                }

                /**
                 * Calculates the scalar product ("dot product") of a series of vectors.
                 * @param vs The vectors to use for the calculation. `vs.Length` must evaluate to ≥ `1` and ≤ `3`.
                 * @throws `ValueError` if < `1` or > `3` vectors were passed.
                 * @throws `TypeError` if any of the values in `vs` is not a `codebase.math.vectorGeometry.Vector`.
                 * @note If any of the vectors' dimension is not equal to the `Max` of all the dimension values encountered in `vs`, `0` is assumed for the missing coordinate(s).
                 * @returns The scalar product of the vectors in `vs`.
                 */
                scalarProduct(vs*) => codebase.math.vectorGeometry.scalarProduct(this, vs*)
                /**
                 * Calculates the Vector product ("cross product") of a series of vectors.
                 * @param vs The vectors to use for the calculation. `vs.Length` must evaluate to ≥ `1` and ≤ `3`.
                 * @throws `ValueError` if < `1` or > `3` vectors were passed.
                 * @throws `TypeError` if any of the values in `vs` is not a `codebase.math.vectorGeometry.Vector`.
                 * @throws `ValueError` if the `dim` property (dimension of the Vector) of `this` is not `3` as Vector products are only defined in three-dimensional space.
                 * @throws `ValueError` if the `dim` property (dimension of the Vector) of any of the vectors in `vs` is greater than `3` as Vector products are only defined in three-dimensional space.
                 * @note As mentioned, a `ValueError` is thrown if the dimension of `this` is not `3`. If any of the _other_ vectors' dimension is only `2`, it is overwritten with a new `codebase.math.vectorGeometry.Vector` object. The first two coordinates will be preserved and the third be set to `0` to ensure calculations are always possible.
                 * @returns The Vector product of the vectors in `vs`, which is itself a Vector.
                 */
                vectorProduct(vs*) => codebase.math.vectorGeometry.vectorProduct(this, vs*)
                /**
                 * Adds a series of vectors to `this`.
                 * @param vs Any number of vectors.
                 * @throws `TypeError` if any of the values in `vs` is not a `codebase.math.vectorGeometry.Vector`.
                 * @returns A sum of `this` and the vectors in `vs`, which is itself a Vector.
                 */
                add(vs*) => codebase.math.vectorGeometry.vectorAdd(this, vs*)
                /**
                 * Subtracts a series of vectors from `this`.
                 * @param vs Any number of vectors.
                 * @throws `TypeError` if any of the values in `vs` is not a `codebase.math.vectorGeometry.Vector`.
                 * @returns The vectors in `vs` subtracted from `this`, which is itself a Vector.
                 */
                subtract(vs*) => codebase.math.vectorGeometry.vectorSubtract(this, vs*)
                /**
                 * Calculates the "absolute value" of the Vector, defined as its the distance from the origin of the Vector space.
                 * @returns The distance from the origin of the target point of `this`.
                 */
                abs() => codebase.math.vectorGeometry.vectorAbs(this)
            }

            /**
             * Calculates the relationship two lines have.
             * @param pv1 The position Vector of a point on the first line.
             * @param dv1 The direction Vector of the first line.
             * @param pv2 The position Vector of a point on the second line.
             * @param dv2 The direction Vector of the second line.
             * @throws `TypeError` if any of the input arguments is not a `codebase.math.vectorGeometry.Vector`.
             * @throws `ValueError` if `dv1` or `dv2` are null vectors, as `pv_n` and `dv_n` would not define a line in this case.
             * @returns `1` if the lines are equal.
             * @returns `-1` if the lines are parallel but not equal.
             * @returns A Vector with the coordinates of the intersection point if the lines intersect exactly once.
             * @returns `0` if the lines are not parallel and do not intersect.
             */
            static lineToLineRelation(pv1, dv1, pv2, dv2)
            {
                if (Type(pv1) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``pv1``. Received ``" . Type(pv1) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }
                if (Type(dv1) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``dv1``. Received ``" . Type(dv1) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }
                if (Type(pv2) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``pv2``. Received ``" . Type(pv2) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }
                if (Type(dv2) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``dv2``. Received ``" . Type(dv2) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }
                if (codebase.math.vectorGeometry.vectorCompare(dv1, codebase.math.vectorGeometry.nullVector(3)))
                {
                    throw ValueError("``dv1`` is a null vector.")
                }
                if (codebase.math.vectorGeometry.vectorCompare(dv2, codebase.math.vectorGeometry.nullVector(3)))
                {
                    throw ValueError("``dv2`` is a null vector.")
                }
                if (pv1.dim !== 3)
                {
                    throw ValueError("Invalid value for ``pv1.dim``. Received ``" . pv1.dim . "``, expected ``3``.")
                }
                if (dv1.dim !== 3)
                {
                    throw ValueError("Invalid value for ``dv1.dim``. Received ``" . dv1.dim . "``, expected ``3``.")
                }
                if (pv2.dim !== 3)
                {
                    throw ValueError("Invalid value for ``pv2.dim``. Received ``" . pv2.dim . "``, expected ``3``.")
                }
                if (dv2.dim !== 3)
                {
                    throw ValueError("Invalid value for ``dv2.dim``. Received ``" . dv2.dim . "``, expected ``3``.")
                }

                l1(lambda) => codebase.math.vectorGeometry.vectorAdd(pv1, codebase.math.vectorGeometry.scalarMultiply(lambda, dv1))
                l2(mu) => codebase.math.vectorGeometry.vectorAdd(pv2, codebase.math.vectorGeometry.scalarMultiply(mu, dv2))

                if (codebase.math.vectorGeometry.linearDependence(dv1, dv2))
                {
                    ; The lines are at least parallel, now check whether they are actually the same line
                    ; This is not exactly easy as it's basically solving a system of equations, however, since this is not as analytical and strict as school math, let's just solve one line for a value of `μ` and check if that value checks out overall
                    ; Since the first line of the system has the following format, the below formula works no matter what the values are: `x_n = B_n + μ*v_n`
                    m := (dv2.v1 !== 0 ? (pv1.v1 - pv2.v1) / dv2.v1 : (dv2.v2 !== 0 ? (pv1.v2 - pv2.v2) / dv2.v2 : (pv1.v3 - pv2.v3) / dv2.v3))
                    if (codebase.math.vectorGeometry.vectorCompare(codebase.math.vectorGeometry.scalarMultiply(1, pv1), l2(m)))
                    {
                        ; The lines are equal as they share position vectors
                        return 1
                    }
                    else
                    {
                        ; The lines are parallel but not equal
                        return -1
                    }
                }
                else
                {
                    ; The lines are not parallel, meaning they either intersect once or not at all
                    ; Since the first line of the system has the following format, the below formula works no matter what the values are: `x_n = B_n + μ*v_n`
                    try
                    {
                        m := (dv2.v1 !== 0 ? (pv1.v1 - pv2.v1) / dv2.v1 : (dv2.v2 !== 0 ? (pv1.v2 - pv2.v2) / dv2.v2 : (pv1.v3 - pv2.v3) / dv2.v3))
                        return l2(m)
                    }
                    catch
                    {
                        ; The lines are not parallel and do not intersect
                        return 0
                    }
                }
            }

            /**
             * Calculates the intersect angle of two lines.
             * @param dv1 The direction Vector of the first line.
             * @param dv2 The direction Vector of the second line.
             * @throws `TypeError` if any of the input arguments is not a `codebase.math.vectorGeometry.Vector`.
             * @throws `ValueError` if `dv1` or `dv2` are null vectors.
             * @note The returned number is the angle in radians. To convert to degrees, multiply by `codebase.math.convert.radToDeg`.
             * @returns The angle between the two lines.
             */
            static intersectAngle(dv1, dv2)
            {
                if (Type(dv1) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``dv1``. Received ``" . Type(dv1) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }
                if (Type(dv2) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``dv2``. Received ``" . Type(dv2) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }
                if (dv1.dim !== 3)
                {
                    throw ValueError("Invalid value for ``dv1.dim``. Received ``" . dv1.dim . "``, expected ``3``.")
                }
                if (dv2.dim !== 3)
                {
                    throw ValueError("Invalid value for ``dv2.dim``. Received ``" . dv2.dim . "``, expected ``3``.")
                }
                if (codebase.math.vectorGeometry.vectorCompare(dv1, codebase.math.vectorGeometry.nullVector(3)))
                {
                    throw ValueError("``dv1`` is a null vector.")
                }
                if (codebase.math.vectorGeometry.vectorCompare(dv2, codebase.math.vectorGeometry.nullVector(3)))
                {
                    throw ValueError("``dv2`` is a null vector.")
                }

                dv1 := codebase.math.vectorGeometry.vectorSimplify(dv1)
                dv2 := codebase.math.vectorGeometry.vectorSimplify(dv2)

                return ACos(Abs(codebase.math.vectorGeometry.scalarProduct(dv1, dv2)) / (codebase.math.vectorGeometry.vectorAbs(dv1) * codebase.math.vectorGeometry.vectorAbs(dv2)))
            }

            /**
             * Calculates the intersect angle of a line with a plane.
             * @param dv The direction Vector of a line.
             * @param nv The normal Vector of _or_ two parameter Vectors to define a plane.
             * @throws `TypeError` if any of the input arguments is not a `codebase.math.vectorGeometry.Vector`.
             * @throws `ValueError` if `dv1` or `dv2` are null vectors.d
             * @note The returned number is the angle in radians. To convert to degrees, multiply by `codebase.math.convert.radToDeg`.
             * @returns The angle between the line and the plane.
             */
            static intersectAngleLinePlane(dv, nv*)
            {
                if (Type(dv) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``dv``. Received ``" . Type(dv) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }
                if (dv.dim !== 3)
                {
                    throw ValueError("Invalid value for ``dv.dim``. Received ``" . dv.dim . "``, expected ``3``.")
                }
                if (codebase.math.vectorGeometry.vectorCompare(dv, codebase.math.vectorGeometry.nullVector(3)))
                {
                    throw ValueError("``dv`` is a null vector.")
                }

                dv := codebase.math.vectorGeometry.vectorSimplify(dv)
                if (nv.Length == 1)
                {
                    nv := codebase.math.vectorGeometry.vectorSimplify(nv[1])
                }
                else
                {
                    nv := codebase.math.vectorGeometry.vectorProduct(nv[1], nv[2])
                }

                return (codebase.math.constants.pi / 2) - ASin(Abs(codebase.math.vectorGeometry.scalarProduct(dv, nv)) / (codebase.math.vectorGeometry.vectorAbs(dv) * codebase.math.vectorGeometry.vectorAbs(nv)))
            }

            /**
             * Checks if a series of vectors are equal, i.e. have the same coordinates. As this is obvious when created, this function is intended for programmatic checks within other functions.
             * @param vs Any number of vectors.
             * @throws `TypeError` if any of the values in `vs` is not a `codebase.math.vectorGeometry.Vector`.
             * @returns `true` if all the vectors in `vs` are equal.
             */
            static vectorCompare(vs*)
            {
                if (vs.Length < 2)
                {
                    throw ValueError("Invalid value for ``vs.Length``. Received ``" . vs.Length . "``, expected a value ``≥ 2``.")
                }

                hdim := 0
                for v in vs
                {
                    if (v.dim > hdim)
                    {
                        hdim := v.dim
                    }
                }

                for v in vs
                {
                    fi := A_Index
                    if (Type(v) !== "codebase.math.vectorGeometry.Vector")
                    {
                        throw TypeError("Invalid type for ``vs[" . A_Index . "]``. Received ``" . Type(v) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                    }

                    if (v.dim < hdim)
                    {
                        param := []
                        Loop hdim
                        {
                            li := A_Index
                            param.Push((vs[fi].HasOwnProp("v" . li) ? vs[fi].GetOwnPropDesc("v" . li).Value : 0))
                        }
                        vs[fi] := codebase.math.vectorGeometry.Vector(param*)
                    }
                }

                equal := true
                for j in codebase.range(2, vs.Length)
                {
                    Loop hdim
                    {
                        if (!(codebase.math.misc.equal(0.0000001, vs[1].GetOwnPropDesc("v" . A_Index).Value, vs[j].GetOwnPropDesc("v" . A_Index).Value)))
                        {
                            return false
                        }
                    }
                }
                return true
            }

            /**
             * Creates a null Vector (all coordinates are `0`).
             * @param dim The dimension of the null Vector. This will be equal to the Vector.dim property defined at `codebase.math.vectorGeometry.Vector` object instatiation. Must be `≥ 2`. Defaults to `3` if omitted.
             * @returns A null Vector with `dim` coordinates, all `0`.
             */
            static nullVector(dim := 3)
            {
                if (dim < 2)
                {
                    throw ValueError("Invalid value for ``dim``. Received ``" . dim . "``, expected a value > ``2``.")
                }
                
                d := []
                Loop dim
                {
                    d.Push(0)
                }
                return codebase.math.vectorGeometry.Vector(d*)
            }

            /**
             * Finds the coordinates of the points where a line in three-dimensional space intersects the `x2x3`, `x1x3` and `x1x2` planes.
             * @param pv The position Vector of a point on the line.
             * @param dv The direction Vector to indicate where the line runs.
             * @throws `ValueError` if `dv` is a null Vector, as `pv` and `dv` would not define a line in this case.
             * @note The return object should not be _expected_ to have a specific number of props as the direction Vector `dv` might have one or more coordinates equal to `0`. As such, it should only be iterated over using an object's `OwnProps` method, _unless_ the passed direction Vector is _ensured_ to possess a specific expected number of intersections with the coordinate planes.
             * @returns An object, with at least one of the props `x2x3`, `x1x3` and `x1x2`, each with the props `x1`, `x2` and `x3` for the coordinates of the points.
             */
            static planeIntersections(pv, dv)
            {
                if (Type(pv) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``pv``. Received ``" . Type(pv) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }
                if (Type(dv) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``dv``. Received ``" . Type(dv) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }
                if (pv.dim !== 3)
                {
                    throw ValueError("Invalid value for ``pv.dim``. Received ``" . pv.dim . "``, expected ``3``.")
                }
                if (dv.dim !== 3)
                {
                    throw ValueError("Invalid value for ``dv.dim``. Received ``" . dv.dim . "``, expected ``3``.")
                }
                if (dv.v1 == 0 && dv.v2 == 0 && dv.v3 == 0)
                {
                    throw ValueError("Invalid value for ``dv``. Expected a Vector that is not a null Vector.")
                }

                ; If a coordinate in the direction Vector is `0`, the line defined by the vectors cannot intersect with the plane that is missing that coordinate as the two run parallel to each other, i.e.
                ; - `dv.v1 = 0` -> `line ∉ x2x3`
                ; - `dv.v2 = 0` -> `line ∉ x1x3`
                ; - `dv.v3 = 0` -> `line ∉ x1x2`
                possibleIntersections := [1, 2, 3]
                for e in [dv.v1, dv.v2, dv.v3]
                {
                    if (e == 0)
                    {
                        possibleIntersections.RemoveAt(codebase.collectionOperations.arrayOperations.arrayContains(possibleIntersections, A_Index)[1])
                    }
                }

                out := { }

                ; The entire idea of using a loop like this was absolutely disgusting to come up with, understand and then actually write
                ; The actual solution, as in, the code, is     B  E  A  U  T  I  F  U  L, but that's about it
                ; AAAAND it works so I reeeeaaaally don't care :3
                for searchx in possibleIntersections
                {
                    base := [1, 2, 3]
                    base.RemoveAt(searchx)

                    lambda := 0
                    if ((v := pv.GetOwnPropDesc("v" . searchx).Value) !== 0)
                    {
                        lambda += (v > 0 ? -v : v)
                    }

                    try
                    {
                        lambda /= dv.GetOwnPropDesc("v" . searchx).Value
                    }

                    xs := { }
                    xs.DefineProp("x" . searchx, { Value: 0.0 })
                    xs.DefineProp("x" . base[1], { Value: pv.GetOwnPropDesc("v" . base[1]).Value + (dv.GetOwnPropDesc("v" . base[1]).Value * lambda) })
                    xs.DefineProp("x" . base[2], { Value: pv.GetOwnPropDesc("v" . base[2]).Value + (dv.GetOwnPropDesc("v" . base[2]).Value * lambda) })

                    out.DefineProp("x" . base[1] . "x" . base[2], { Value: xs })
                }

                return out
            }

            /**
             * Calculates the slope and y-intercept of a line in two-dimensional space defined by two vectors,
             * @param pv The position Vector of a point on the line.
             * @param dv The direction Vector to indicate the direction of the line.
             * @returns An object with the props `a`, `b` and `fn`. `a` and `b` form the linear function `y = ax + b`, and `fn` is this linear function, which takes an `x` value and outputs the corresponding `y` value.
             */
            static linearFunctionData(pv, dv)
            {
                if (Type(pv) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``pv``. Received ``" . Type(pv) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }
                if (Type(dv) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``dv``. Received ``" . Type(dv) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }
                if (pv.dim !== 2)
                {
                    throw ValueError("Invalid value for ``pv.dim``. Received ``" . pv.dim . "``, expected ``2``.")
                }
                if (dv.dim !== 2)
                {
                    throw ValueError("Invalid value for ``dv.dim``. Received ``" . dv.dim . "``, expected ``2``.")
                }
                if (dv.v1 == 0 && dv.v2 == 0)
                {
                    throw ValueError("Invalid value for ``dv``. Expected a Vector that is not a null Vector.")
                }

                a := ((pv.v2 + dv.v2) - pv.v2) / ((pv.v1 + dv.v1) - pv.v1)
                b := pv.v2 - (a * pv.v1)

                return { a: a, b: b, fn: (this, x) => (a * x) + b }
            }

            /**
             * Checks whether a series of vectors is linearly dependent.
             * @param vs The vectors to use for the calculation. `vs.Length` must evaluate to ≥ `2` and ≤ `4`.
             * @throws `ValueError` if < `2` or > `4` vectors were passed.
             * @throws `TypeError` if any of the values in `vs` is not a `codebase.math.vectorGeometry.Vector`.
             * @note If any of the vectors' dimension is not equal to the `Max` of all the dimension values encountered in `vs`, `0` is assumed for the missing coordinate(s).
             * @returns A truthy value if the vectors in `vs` are linearly dependent.
             * @returns A falsey value if the vectors in `vs` are linearly independent.
             */
            static linearDependence(vs*)
            {
                hdim := 0
                for v in vs
                {
                    if (v.dim > hdim)
                    {
                        hdim := v.dim
                    }
                }

                for v in vs
                {
                    fi := A_Index
                    if (Type(v) !== "codebase.math.vectorGeometry.Vector")
                    {
                        throw TypeError("Invalid type for ``vs[" . A_Index . "]``. Received ``" . Type(v) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                    }

                    if (v.dim < hdim)
                    {
                        param := []
                        Loop hdim
                        {
                            li := A_Index
                            param.Push((vs[fi].HasOwnProp("v" . li) ? vs[fi].GetOwnPropDesc("v" . li).Value : 0))
                        }
                        vs[fi] := codebase.math.vectorGeometry.Vector(param*)
                    }
                }

                for v in vs
                {
                    if (codebase.math.vectorGeometry.vectorCompare(v, codebase.math.vectorGeometry.nullVector(3)))
                    {
                        ; Any Vector is always linearly dependent with a null Vector.
                        return true
                    }
                }

                for in vs
                {
                    vs[A_Index] := codebase.math.vectorGeometry.vectorSimplify(vs[A_Index])
                }

                switch (vs.Length)
                {
                    case 2:
                        ; If the simplified vectors are equal, they are linearly dependent and the full calculation is unnecessary
                        if ((r := codebase.math.vectorGeometry.vectorCompare(vs[1], vs[2])))
                        {
                            return r
                        }
                        else
                        {
                            ; Divide the first Vector's coordinate with the respective second Vector's coordinate
                            val1 := vs[1].v1 / vs[2].v1
                            val2 := vs[1].v2 / vs[2].v2
                            val3 := vs[1].v3 / vs[2].v3
                            ; Are the values equal?
                            return codebase.math.misc.equal(, val1, val2, val3)
                        }
                    case 3:
                        ; codebase.math.vectorGeometry.scalarProduct returns an Integer. If it is `0`, the three vectors are linearly dependent, otherwise they are not.
                        ; This entire calculation is called the triple product. This behavior is defined as the scalar product of three vectors.
                        return !(codebase.math.vectorGeometry.scalarProduct(vs[1], vs[2], vs[3]))
                        ; codebase.math.matrixComputation.matrixDeterminantLaplaceExpansion returns an Integer. If it is `0`, the three vectors are linearly dependent, otherwise they are not.
                        ; This is called the Determinant criterion.
                        ; This is commented out because it is computationally less efficient than the triple product.
                        ; return !(codebase.math.matrixComputation.matrixDeterminantLaplaceExpansion(codebase.math.matrixComputation.Matrix(vs[1], vs[2], vs[3])))
                    case 4:
                        ; In three-dimensional space, 4 vectors are always linearly dependent.
                        return true
                    default:
                        throw ValueError("Invalid value for ``vs.Length``. Received ``" . vs.Length . "``, expected a value ≥ ``2`` and ≤ ``4``.")
                }
            }

            /**
             * Attemps to simplify a Vector by reducing its coordinates as much as possible. This is only really helpful for normal vectors of surfaces or the Vector product of two vectors if used for the sole purpose of finding a perpendicular Vector, for example.
             * @param v The Vector to simplify.
             * @returns The simplified Vector, which may be equal to `v` if it could not be simplified. This may have the effect that all dimensions will be converted to floating-point numbers if they weren't already in this format.
             */
            static vectorSimplify(v)
            {
                gcd := []
                Loop v.dim
                {
                    gcd.Push(v.GetOwnPropDesc("v" . A_Index).Value)
                }
                return codebase.math.vectorGeometry.scalarMultiply(1 / codebase.math.gcd(gcd*), v)
            }

            /**
             * Multiplies each coordinate of a Vector with a scalar.
             * @param s The scalar to multiply the Vector's coordinates by.
             * @param v The Vector to multply by the scalar.
             * @returns `v` scaled by a factor of `s`, which is itself a Vector.
             */
            static scalarMultiply(s, v)
            {
                new := []
                Loop v.dim
                {
                    new.Push(v.GetOwnPropDesc("v" . A_Index).Value * s)
                }

                return codebase.math.vectorGeometry.Vector(new*)
            }

            /**
             * Calculates the scalar product ("dot product") of a series of vectors.
             * @param vs The vectors to use for the calculation. `vs.Length` must evaluate to ≥ `2` and ≤ `4`.
             * @throws `ValueError` if < `2` or > `4` vectors were passed.
             * @throws `TypeError` if any of the values in `vs` is not a `codebase.math.vectorGeometry.Vector`.
             * @note If any of the vectors' dimension is not equal to the `Max` of all the dimension values encountered in `vs`, `0` is assumed for the missing coordinate(s).
             * @returns The scalar product of the vectors in `vs`.
             */
            static scalarProduct(vs*)
            {
                hdim := 0
                for v in vs
                {
                    if (v.dim > hdim)
                    {
                        hdim := v.dim
                    }
                }

                for v in vs
                {
                    if (Type(v) !== "codebase.math.vectorGeometry.Vector")
                    {
                        throw TypeError("Invalid type for ``vs[" . A_Index . "]``. Received ``" . Type(v) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                    }
                }

                switch (vs.Length)
                {
                    ; This taught me how my own range calculation functions, fat-arrow function definitions and argument binding works
                    ; I despise these three things in conjunction :)
                    case 2:
                        return codebase.math.sum(
                            1,
                            hdim,
                            (i) => codebase.math.product(
                                1,
                                vs.Length,
                                ((a, n) => vs[n].HasOwnProp("v" . a) ? vs[n].GetOwnPropDesc("v" . a).Value : 0).Bind(i)
                            )
                        )
                    case 3:
                        return codebase.math.vectorGeometry.scalarProduct(vs[1], codebase.math.vectorGeometry.vectorProduct(vs[2], vs[3]))
                    case 4:
                        return codebase.math.vectorGeometry.scalarProduct(codebase.math.vectorGeometry.vectorProduct(vs[1], vs[2]), codebase.math.vectorGeometry.vectorProduct(vs[3], vs[4]))
                    default:
                        throw ValueError("Invalid value for ``vs.Length``. Received ``" . vs.Length . "``, expected a value ≥ ``2`` and ≤ ``4``.")
                }
            }

            static dotProduct := codebase.math.vectorGeometry.scalarProduct

            /**
             * Calculates the Vector product ("cross product") of a series of vectors.
             * @param vs The vectors to use for the calculation. `vs.Length` must evaluate to ≥ `2` and ≤ `4`.
             * @throws `ValueError` if < `2` or > `4` vectors were passed.
             * @throws `TypeError` if any of the values in `vs` is not a `codebase.math.vectorGeometry.Vector`.
             * @throws `ValueError` if the `dim` property (dimension of the Vector) of the first Vector in `vs` is not `3` as Vector products are only defined in three-dimensional space.
             * @throws `ValueError` if the `dim` property (dimension of the Vector) of any of the vectors in `vs` is greater than `3` as Vector products are only defined in three-dimensional space.
             * @note As mentioned, a `ValueError` is thrown if the _first_ Vector's dimension is not `3`. If any of the _other_ vectors' dimension is only `2`, it is overwritten with a new `codebase.math.vectorGeometry.Vector` object. The first two coordinates will be preserved and the third be set to `0` to ensure calculations are always possible.
             * @returns The Vector product of the vectors in `vs`, which is itself a Vector.
             */
            static vectorProduct(vs*)
            {
                for v in vs
                {
                    if (Type(v) !== "codebase.math.vectorGeometry.Vector")
                    {
                        throw TypeError("Invalid type for ``vs[" . A_Index . "]``. Received ``" . Type(v) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                    }
                    
                    if (v.dim > 3)
                    {
                        throw ValueError("Invalid value for ``vs[" . A_Index . "].dim``. Received ``" . vs[A_Index].dim . "``, expected a value ≥ ``2`` and ≤ ``3``.")
                    }

                    if (v.dim < 3)
                    {
                        if (A_Index == 1)
                        {
                            throw ValueError("Invalid value for initial Vector's ``vs[1].dim``. Received ``" . vs[1].dim . "``, expected ``3``.")
                        }
                        else
                        {
                            vs[A_Index] := codebase.math.vectorGeometry.Vector(vs[A_Index].v1, vs[A_Index].v2, 0)
                        }
                    }
                }

                switch (vs.Length)
                {
                    case 2:
                        return codebase.math.vectorGeometry.Vector(
                            (vs[1].v2 * vs[2].v3) - (vs[1].v3 * vs[2].v2),
                            (vs[1].v3 * vs[2].v1) - (vs[1].v1 * vs[2].v3),
                            (vs[1].v1 * vs[2].v2) - (vs[1].v2 * vs[2].v1)
                        )
                    case 3:
                        ; If you're searching for the triple product, the function `codebase.math.vectorGeometry.scalarProduct` computes that when three vectors are passed as arguments
                        return codebase.math.vectorGeometry.vectorProduct(vs[1], codebase.math.vectorGeometry.vectorProduct(vs[2], vs[3]))
                    case 4:
                        return codebase.math.vectorGeometry.vectorProduct(codebase.math.vectorGeometry.vectorProduct(vs[1], vs[2]), codebase.math.vectorGeometry.vectorProduct(vs[3], vs[4]))
                    default:
                        throw ValueError("Invalid value for ``vs.Length``. Received ``" . vs.Length . "``, expected a value ≥ ``2`` and ≤ ``4``.")
                }
            }

            static crossProduct := codebase.math.vectorGeometry.vectorProduct

            /**
             * Adds a series of vectors.
             * @param vs Any number of vectors.
             * @throws `TypeError` if any of the values in `vs` is not a `codebase.math.vectorGeometry.Vector`.
             * @returns A sum of the vectors `vs`, which is itself a Vector.
             */
            static vectorAdd(vs*)
            {
                for v in vs
                {
                    if (Type(v) !== "codebase.math.vectorGeometry.Vector")
                    {
                        throw TypeError("Invalid type for ``v[" . A_Index . "]``. Received ``" . Type(v) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                    }
                }

                dims := []
                for v in vs
                {
                    dims.Push(v.dim)
                }

                newV := []
                for j in codebase.range(1, Max(dims*))
                {
                    newV.Push(
                        codebase.math.sum(
                            1,
                            vs.Length,
                            ((a, n) => vs[n].HasOwnProp("v" . a) ? vs[n].GetOwnPropDesc("v" . a).Value : 0).Bind(j)
                        )
                    )
                }

                return codebase.math.vectorGeometry.Vector(newV*)
            }

            /**
             * Subtracts a series of vectors from the first in the series.
             * @param vs Any number of vectors.
             * @throws `TypeError` if any of the values in `vs` is not a `codebase.math.vectorGeometry.Vector`.
             * @returns The vectors from index `2` up to `vs.Length` subtracted from the first in `vs`, which is itself a Vector.
             */
            static vectorSubtract(vs*)
            {
                for v in vs
                {
                    if (Type(v) !== "codebase.math.vectorGeometry.Vector")
                    {
                        throw TypeError("Invalid type for ``vs[" . A_Index . "]``. Received ``" . Type(v) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                    }
                }

                dims := []
                for v in vs
                {
                    dims.Push(v.dim)
                }

                newV := []
                for j in codebase.range(1, Max(dims*))
                {
                    newV.Push(
                        codebase.math.sum(
                            1,
                            vs.Length,
                            ((a, n) => vs[n].HasOwnProp("v" . a) ? (n !== 1 ? -(vs[n].GetOwnPropDesc("v" . a).Value) : vs[n].GetOwnPropDesc("v" . a).Value) : 0).Bind(j)
                        )
                    )
                }

                return codebase.math.vectorGeometry.Vector(newV*)
            }

            /**
             * Calculates the "absolute value" of a Vector, defined as its the distance from the origin of the Vector space.
             * @param v The Vector.
             * @throws `TypeError` if `v` is not a `codebase.math.vectorGeometry.Vector`.
             * @returns The distance from the origin of `v`'s target point.
             */
            static vectorAbs(v)
            {
                if (Type(v) !== "codebase.math.vectorGeometry.Vector")
                {
                    throw TypeError("Invalid type for ``v``. Received ``" . Type(v) . "``, expected ``codebase.math.vectorGeometry.Vector``.")
                }

                return Sqrt(codebase.math.sum(1, v.dim, (n) => (v.GetOwnPropDesc("v" . n).Value) ** 2))
            }
        }

        class matrixComputation
        {
            class Matrix
            {
                /**
                 * Instantiates a new `codebase.math.matrixComputation.Matrix` from a series of passed values.
                 * It defines a Matrix as described below.
                 * @param arrsOrVectors Any number of Arrays or Vectors which comprise the matrix.
                 * - Row mode (all passed elements must be Arrays): The amount of Arrays and the amount of elements in the largest dictate the dimension of the matrix. The resulting elements may later be get or set using property accessor syntax. The properties' names follow the pattern `xy`, where `x` is an integer between `1` and the number of elements in the largest Array passed, and `y` is an integer between `1` and the number of Arrays passed (`arrsOrVectors.Length`). The order they are passed in is preserved when it comes to naming the properties.
                 * - Column mode (all passed elements must be `codebase.math.vectorGeometry.Vector` objects): The amount of objects and the dimensions of the largest dictate the dimensions of the matrix. The resulting elements may later be get or set using property accessor syntax. The properties' names follow the pattern `xy`, where `x` is an integer between `1` and the number of `codebase.math.vectorGeometry.Vector` objects passed, and `y` is an integer between `1` and the largest of the dimensions of the `codebase.math.vectorGeometry.Vector` objects passed. The order they are passed in is preserved when it comes to naming the properties.
                 * @note If cells would be empty because of unequal Array lengths or `codebase.math.vectorGeometry.Vector` dimensions, empty values will be set to `0`.
                 * @returns A `codebase.math.matrixComputation.Matrix` object.
                 */
                __New(arrsOrVectors*)
                {
                    if (!(codebase.collectionOperations.andFunc((p) => Type(p) == "Array", arrsOrVectors*) || codebase.collectionOperations.andFunc((p) => Type(p) == "codebase.math.vectorGeometry.Vector", arrsOrVectors*)))
                    {
                        throw TypeError("Invalid type for elements in ``arrsOrVectors``. Expected only ``Array`` or ``codebase.math.vectorGeometry.Vector``.")
                    }

                    xdim := 0
                    if (Type(arrsOrVectors[1]) == "Array")
                    {
                        for arr in arrsOrVectors
                        {
                            if (arr.Length > xdim)
                            {
                                xdim := arr.Length
                            }
                        }
                        this.dim := { x: xdim, y: arrsOrVectors.Length }
                    }
                    else
                    {
                        for vec in arrsOrVectors
                        {
                            if (vec.dim > xdim)
                            {
                                xdim := vec.dim
                            }
                        }
                        this.dim := { y: xdim, x: arrsOrVectors.Length }
                    }
                    
                    this.dim.DefineProp("ToString", { Call: (*) => this.dim.x . "x" . this.dim.y . "`n" })

                    if (Type(arrsOrVectors[1]) == "Array")
                    {
                        for row in arrsOrVectors
                        {
                            rowIndex := A_Index
                            Loop this.dim.x
                            {
                                elemIndex := A_Index
                                v := ""
                                try
                                {
                                    v := arrsOrVectors[rowIndex][elemIndex]
                                }
                                this.DefineProp(elemIndex . rowIndex, { Value: (IsSet(v) && v !== "" ? v : 0) })
                            }
                        }
                    }
                    else
                    {
                        for column in arrsOrVectors
                        {
                            colIndex := A_Index
                            Loop this.dim.y
                            {
                                elemIndex := A_Index
                                v := ""
                                try
                                {
                                    v := arrsOrVectors[colIndex].GetOwnPropDesc("v" . elemIndex).Value
                                }
                                this.DefineProp(colIndex . elemIndex, { Value: (IsSet(v) && v !== "" ? v : 0) })
                            }
                        }
                    }
                }

                /**
                 * Computes the determinant of the matrix.
                 * @throws `ValueError` if `this` is not a square matrix (`x` and `y` dimensions are equal).
                 * @throws `ValueError` if `n` is not `2` or `3` for the matrix dimensions `n x n`.
                 * @returns The determinant of `this`.
                 */
                determinant() => codebase.math.matrixComputation.matrixDeterminantLaplaceExpansion(this)
                /**
                 * Multiplies the matrix by a scalar.
                 * @param s The scalar to multiply `this` by.
                 * @returns `this`, with each cell multiplied by `s`.
                 */
                scalarMultiply(s) => codebase.math.matrixComputation.scalarMultiply(s, this)
                /**
                 * Mutiplies the matrix by another, the result of which is itself a matrix.
                 * @param m The matrix to mutiply `this` by.
                 * @throws `TypeError` if `m` is not a `codebase.math.matrixComputation.Matrix`.
                 * @throws `ValueError` if the number of columns of `this` is not equal to `m`'s number of rows.
                 * @returns The matrix product of `this` and `m`.
                 */
                multiply(m) => codebase.math.matrixComputation.matrixMultiply(this, m)

                /**
                 * Outputs the matrix by formatting it.
                 * @note The output could become unexpectedly wide if the matrix has a large amount of columns. Be aware of an incorrectly displayed output when, for example, using a MsgBox(), as it isn't wide enough beyond 7 columns or when attempting to display a matrix with floating-point value entries with a large amount of decimal places.
                 * @returns A formatted string displaying the contents of the matrix.
                 */
                ToString()
                {
                    out := "`t"

                    ; Column headers
                    Loop this.dim.x
                    {
                        out .= "[" . A_Index . "]`t"
                    }
                    out .= "`n"

                    for j in codebase.range(1, this.dim.y)
                    {
                        out .= "[" . j . "]`t"
                        for elem in this.getRow(j)
                        {
                            out .= elem . "`t"
                        }
                        out .= "`n"
                    }

                    return Trim(out, "`n`r") . "`nProp`tdim | " . this.dim.ToString()
                }

                /**
                 * Exports the Matrix to a CSV file.
                 * @param f The name of the file to write to.
                 * @returns `true` if the file was written successfully, `false` otherwise.
                 */
                toCSV(f)
                {
                    try
                    {
                        w := FileOpen(f, "w")

                        ; Column headers
                        out := [""]
                        Loop this.dim.x
                        {
                            out.Push("[" . A_Index . "]")
                        }
                        w.WriteLine(codebase.stringOperations.strJoin(',', true, out*))

                        for j in codebase.range(1, this.dim.y)
                        {
                            out := []
                            w.Write("[" . j . "],")
                            for elem in this.getRow(j)
                            {
                                out.Push(elem)
                            }
                            w.WriteLine(codebase.stringOperations.strJoin(',', true, out*))
                        }
                        w.WriteLine()
                        w.WriteLine("dim," . this.dim.ToString())
                        w.Close()
                        return true
                    }
                    catch
                    {
                        return false
                    }
                }

                /**
                 * Compiles a column of the matrix into a Vector.
                 * @param cn Which column to extract.
                 * @returns The elements in column `cn` as a Vector.
                 */
                getVector(i) => codebase.math.vectorGeometry.Vector(this.getColumn(i)*)

                /**
                 * Compiles columns of the matrix into Vectors, left-to-right.
                 * @param start The row to start extracting at.
                 * @param stop The row to stop extracting at.
                 * @returns An Array of Vectors, each containing the elements of a column.
                 */
                getVectors(start := 1, stop?)
                {
                    v := []
                    for j in codebase.range(start, IsSet(stop) ? stop : this.dim.y)
                    {
                        v.Push(this.getVector(j))
                    }
                    return v
                }

                /**
                 * Performs Gaussian Elimination on the matrix to bring it into row echelon form.
                 * @note The value returned by this function is only meaningful for square matrices.
                 * @returns The matrix's determinant.
                 */
                gaussianElimination()
                {
                    h := 1
                    k := 1
                    d := 1

                    while (h <= this.dim.y && k <= this.dim.x)
                    {
                        i_max := 0
                        args := codebase.range(h, this.dim.y)
                        for j in args
                        {
                            n := Abs(this.GetOwnPropDesc(k . j).Value)
                            if (n > i_max)
                            {
                                i_max := args[A_Index]
                            }
                        }

                        if (!(this.GetOwnPropDesc(k . i_max).Value))
                        {
                            k++
                        }
                        else
                        {
                            this.swapRows(h, i_max)
                            d *= -1

                            for j in codebase.range(h + 1, this.dim.y)
                            {
                                if (j > this.dim.y)
                                {
                                    continue
                                }

                                f := this.GetOwnPropDesc(k . j).Value / this.GetOwnPropDesc(k . h).Value
                                this.DefineProp(k . j, { Value: 0 })
                                for j in codebase.range(k + 1, this.dim.y)
                                {
                                    if (j > this.dim.x)
                                    {
                                        continue
                                    }
                                    this.DefineProp(j . j, { Value: this.GetOwnPropDesc(j . j).Value - (this.GetOwnPropDesc(j . h).Value * f) })
                                    d *= f
                                }
                            }

                            h++
                            k++
                        }
                    }

                    return codebase.math.product(1, this.leadingCoefficients().Length, (p) => this.leadingCoefficients()[p]) / d
                }

                /**
                 * Compiles the leading coefficients of the matrix's rows into an Array.
                 * @note This is only useful when the matrix is in row echelon form, achieved by performing Gaussian Elimination (`codebase.math.matrixComputation.gaussianElimination`).
                 * @returns An Array of the leading coefficients of the matrix's rows.
                 */
                leadingCoefficients()
                {
                    coeff := []
                    for j in codebase.range(1, this.dim.y)
                    {
                        for j in codebase.range(1, this.dim.x)
                        {
                            n := this.GetOwnPropDesc(j . j).Value
                            if (n !== 0)
                            {
                                coeff.Push(n)
                                break
                            }
                        }
                    }
                    return coeff
                }

                /**
                 * Swaps two rows of the matrix.
                 * @param i The first row.
                 * @param j The second row.
                 * @returns `this`, with rows `i` and `j` swapped.
                 */
                swapRows(i, j)
                {
                    m := this.Clone()
                    swapi := m.getRow(i)
                    swapj := m.getRow(j)

                    for searchx in codebase.range(1, m.dim.x)
                    {
                        m.DefineProp(searchx . i, { Value: swapj[searchx] })
                        m.DefineProp(searchx . j, { Value: swapi[searchx] })
                    }
                    return m
                }

                /**
                 * Swaps two columns of the matrix.
                 * @param i The first columns.
                 * @param j The second columns.
                 * @returns `this`, with columns `i` and `j` swapped.
                 */
                swapColumns(i, j)
                {
                    m := this.Clone()
                    swapi := m.getColumn(i)
                    swapj := m.getColumn(j)

                    for searchx in codebase.range(1, m.dim.y)
                    {
                        m.DefineProp(i . searchx, { Value: swapj[searchx] })
                        m.DefineProp(j . searchx, { Value: swapi[searchx] })
                    }
                    return m
                }

                /**
                 * Compiles a row of the matrix into an Array, left-to-right.
                 * @param rn Which row to extract.
                 * @returns The elements in row `rn`.
                 */
                getRow(rn)
                {
                    out := []
                    for j in codebase.range(1, this.dim.x)
                    {
                        r := j . rn
                        if (this.HasOwnProp(r))
                        {
                            out.Push(this.GetOwnPropDesc(r).Value)
                        }
                    }
                    return out
                }

                /**
                 * Compiles rows of the matrix into an Array, top-to-bottom.
                 * @param start The row to start extracting at.
                 * @param stop The row to stop extracting at.
                 * @returns An Array of Arrays, each sub-Array containing the elements of a row.
                 */
                getRows(start := 1, stop?)
                {
                    out := []
                    for j in codebase.range(start, IsSet(stop) ? stop : this.dim.y)
                    {
                        out.Push(this.getRow(j))
                    }
                    return out
                }

                /**
                 * Compiles a column of the matrix into an Array, top-to-bottom.
                 * @param cn Which column to extract.
                 * @returns The elements in column `cn`.
                 */
                getColumn(cn)
                {
                    out := []
                    for j in codebase.range(1, this.dim.y)
                    {
                        r := cn . j
                        if (this.HasOwnProp(r))
                        {
                            out.Push(this.GetOwnPropDesc(r).Value)
                        }
                    }
                    return out
                }

                /**
                 * Compiles all columns of the matrix into an Array, left-to-right.
                 * @param start The row to start extracting at.
                 * @param stop The row to stop extracting at.
                 * @returns An Array of Arrays, each sub-Array containing the elements of a column.
                 */
                getColumns(start := 1, stop?)
                {
                    out := []
                    for j in codebase.range(start, IsSet(stop) ? stop : this.dim.x)
                    {
                        out.Push(this.getColumn(j))
                    }
                    return out
                }
            }

            /**
             * Multiplies a matrix by a scalar.
             * @param s The scalar to multiply the matrix by.
             * @param m The matrix to multiply by `s`.
             * @returns `m`, with each cell multiplied by `s`.
             */
            static scalarMultiply(s, m)
            {
                new := m.Clone()
                Loop m.dim.y
                {
                    yi := A_Index
                    Loop m.dim.x
                    {
                        xi := A_Index
                        new.DefineProp(yi . xi, { Value: Number(m.GetOwnPropDesc(yi . xi).Value) * s })
                    }
                }
                return new
            }

            /**
             * Mutiplies a matrix by another, the result of which is itself a matrix.
             * @param m1 The first matrix.
             * @param m2 The second matrix.
             * @throws `TypeError` if `m1` or `m2` is not a `codebase.math.matrixComputation.Matrix`.
             * @throws `ValueError` if `m1`'s number of columns is not equal to `m2`'s number of rows.
             * @returns The matrix product of `m1` and `m2`.
             */
            static matrixMultiply(m1, m2)
            {
                if (Type(m1) !== "codebase.math.matrixComputation.Matrix")
                {
                    throw TypeError("Invalid type for ``m1``. Received ``" . Type(m1) . "``, expected ``codebase.math.matrixComputation.Matrix``.")
                }
                if (Type(m2) !== "codebase.math.matrixComputation.Matrix")
                {
                    throw TypeError("Invalid type for ``m2``. Received ``" . Type(m2) . "``, expected ``codebase.math.matrixComputation.Matrix``.")
                }
                if (m1.dim.x !== m2.dim.y)
                {
                    throw ValueError("Invalid value for ``m2.dim.y``. Received ``" . m2.dim.y . "``, expected ``m1.dim.x`` (" . m1.dim.x . ").")
                }

                rows := []
                Loop m1.dim.y
                {
                    yi := A_Index
                    yarr := []
                    Loop m2.dim.x
                    {
                        xi := A_Index
                        yarr.Push(
                            codebase.math.vectorGeometry.scalarProduct(
                                codebase.math.vectorGeometry.Vector(m1.getRow(yi)*),
                                codebase.math.vectorGeometry.Vector(m2.getColumn(xi)*)
                            )
                        )
                    }
                    rows.Push(yarr)
                }

                return codebase.math.matrixComputation.Matrix(rows*)
            }

            /**
             * Computes the determinant of a matrix using Laplace expansion.
             * @param m The matrix to calculate the determinant of.
             * @throws `ValueError` if `m` is not a square matrix (`x` and `y` dimensions are equal).
             * @note While this is a one-to-one replica of the Python implementation from https://en.wikipedia.org/wiki/Laplace_expansion#Computational_expense, as that article states, using the Laplace expansion for very large matrices ends up being computationally inefficient. This shouldn't be a problem considering what this library is intended for.
             * @returns The determinant of `m`.
             */
            static matrixDeterminantLaplaceExpansion(m)
            {
                if (m.dim.x !== m.dim.y)
                {
                    throw ValueError("Invalid value for ``m.dim.y``. Received ``" . m.dim.y . "``, expected ``m.dim.x`` (" . m.dim.x . "). Only square matrices have a determinant.")
                }

                ; Convert input matrix m to an Array of Arrays
                if (Type(m) == "codebase.math.matrixComputation.Matrix")
                {
                    m := m.getRows()
                }

                ; Base case for recursion, when the matrix has dimensions 1x1
                if (m.Length == 1)
                {
                    return m[1][1]
                }

                ; Initialize the determinant
                total := 0
                ; Step through the matrix's first row
                for column, element in m[1]
                {
                    ; Recursively calculate the determinant of the sub-matrix
                    ; Initialize Array for the sub-matrix
                    k := []
                    ; Step through the columns of m, skipping the first column
                    for col in codebase.collectionOperations.arrayOperations.subarray(m, 2)
                    {
                        ; Add all but the first row and current column to the sub-matrix Array
                        k.Push(codebase.collectionOperations.arrayOperations.arrayConcat(
                                codebase.collectionOperations.arrayOperations.subarray(col, , column - 1),
                                codebase.collectionOperations.arrayOperations.subarray(col, column + 1)
                            )
                        )
                    }
                    ; Determine the sign of the determinant determinant
                    s := Mod(A_Index, 2) ? 1 : -1
                    ; Multiply the current determinant's sign by the current element and the determinant of the sub-matrix and add to the total
                    total += s * element * codebase.math.matrixComputation.matrixDeterminantLaplaceExpansion(codebase.math.matrixComputation.Matrix(k*))
                }
                return total
            }
        }

        /**
         * Calculates the slope and `y`-intercept of a best fit line for a set of given points.
         * @param knownX The `x`-coordinates of the known points.
         * @param knownY The `y`-coordinates of the known points.
         * @returns A Map containing the slope `m`, `y`-intercept `b` and function `func` of the best fit line for the given points, to be used in the following function: `m * x + b`, where `x` is any number.
         */
        static fitLinear(knownX, knownY)
        {
            if (knownX.Length !== knownY.Length)
            {
                throw ValueError("Invalid value for ``knownY.Length``. Received ``" . knownY.Length . "``, expected ``knownX.Length`` (``" . knownX.Length . "``).")
            }

            sumX := 0
            sumXY := 0
            sumX2 := 0
            sumY := 0

            for j in codebase.range(1, knownX.Length)
            {
                sumXY += knownX[j] * knownY[j]
                sumX += knownX[j]
                sumY += knownY[j]
                sumX2 += knownX[j] ** 2
            }

            sumXY /= knownX.Length
            sumX /= knownX.Length
            sumY /= knownX.Length
            sumX2 /= knownX.Length

            m := (sumXY - (sumX * sumY)) / (sumX2 - (sumX * sumX))
            b := ((sumX2 * sumY) - (sumXY * sumX)) / (sumX2 - (sumX * sumX))

            return Map(
                "m", m,
                "b", b,
                "func", (x) => m * x + b
            )
        }

        /**
         * Calculates the exponent and `y`-intercept of a best fit exponential function for a set of given points.
         * @param knownX The `x`-coordinates of the known points.
         * @param knownY The `y`-coordinates of the known points.
         * @returns A Map containing the starting value `A`, exponent `B` and function `func` of the best fit exponential function for the given points, to be used in the following function: `A * (e ** (B * x))`, where `x` is any number.
         */
        static fitExponential(knownX, knownY)
        {
            if (knownX.Length !== knownY.Length)
            {
                throw ValueError("Invalid value for ``knownY.Length``. Received ``" . knownY.Length . "``, expected ``knownX.Length`` (``" . knownX.Length . "``).")
            }

            linear := codebase.math.fitLinear(knownX, knownY)

            return Map(
                "A", codebase.math.constants.e ** linear.Get("b"),
                "B", linear.Get("m"),
                "func", (x) => (codebase.math.constants.e ** linear.Get("b")) * (codebase.math.constants.e ** (linear.Get("m") * x))
            )
        }

        /**
         * Finds the greatest common divisor of a series of integers.
         * @param nums The numbers to find the GCD of.
         * @returns The GCD of all the numbers in `nums`.
         * @returns `1` if no other options for the GCD were found.
         */
        static gcd(nums*)
        {
            ; If there's only one number, that number is the GCD... of itself
            if (nums.Length == 1)
            {
                return nums[1]
            }

            ; Sort the numbers in ascending order
            codebase.collectionOperations.arrayOperations.arrSort(&nums, true, false)

            ; Step through the numbers
            ; Make them all positive, as any being negative a) wouldn't change the result (as, for example, both `9mod3` and `-9mod3` are `0`) and b) messes up this more than simple procedure
            ; If any of the numbers are 1, that is the only option for the GDC
            for n in nums
            {
                n := Abs(n)
                if (n == 1)
                {
                    return 1
                }
            }

            ; Go through all numbers between the maximum input and `2` and test if they are the GCD
            ; Start from the maximum input as we're searching for the _greatest_ common divisor
            for g in codebase.range(Max(nums*), 2)
            {
                b := []
                for n in nums
                {
                    b.Push(Mod(n, g) == 0)
                }
                if (codebase.collectionOperations.and(b*))
                {
                    return g
                }
            }

            ; If all else fails, return `1`
            ; This is the case, for example, if one of the inputs is `1` or one of the numbers is a prime and all others are not multiples of it
            return 1
        }

        /**
         * Finds the least common multiple of a series of integers.
         * @param nums The numbers to find the LCM of.
         * @returns The LCM of all the numbers in `nums`.
         * @returns All numbers in `nums` multiplied if no other options for the LCM were found.
         */
        static lcm(nums*)
        {
            ; If there's only one number, that number is the LCM... of itself
            if (nums.Length == 1)
            {
                return nums[1]
            }

            ; Sort the numbers in descending order
            codebase.collectionOperations.arrayOperations.arrSort(&nums, false, false)

            ; Step through the numbers
            ; Make them all positive, as any being negative a) wouldn't change the result (as, for example, both `9mod3` and `-9mod3` are `0`) and b) messes up this more than simple procedure
            f := 1
            for n in nums
            {
                n := Abs(n)
                f *= n
            }

            ; If it _wasn't_ in the input array, get the prime factors of all the numbers and index the Arrays
            m := []
            for n in nums
            {
                m.Push(codebase.collectionOperations.arrayOperations.arrayIndex(codebase.math.primeFactors(n)))
            }

            fm := Map()

            ; Step through the Maps
            for mp in m
            {
                ; Step through the key-value pairs
                for number, freq in mp
                {
                    ; If the current number is already present in the final map
                    if (fm.Has(number))
                    {
                        ; If the current number is present more often in the current map than the final map, update the frequency
                        if (freq > fm.Get(number))
                        {
                            fm.Set(number, freq)
                        }
                    }
                    else
                    {
                        fm.Set(number, freq)
                    }
                }
            }

            f := 1
            for k, v in fm
            {
                f *= k ** v
            }

            ; If all else fails, multiply all numbers in `nums` and return that
            return f
        }

        /**
         * Computes the numerical average of the numbers passed in.
         * @param nums The numbers to calculate the average of.
         * @returns The average of all the numbers in `nums`.
         */
        static avg(nums*) => codebase.math.sum(1, nums.Length, (a) => nums[a]) / nums.Length

        /**
         * Finds the prime factors of a number through brute-force.
         * @param n The number to find the prime factors of.
         * @returns An Array of numbers containing all prime factors of `n`.
         */
        static primeFactors(n)
        {
            p := []

            while (Mod(n, 2) == 0)
            {
                p.Push(2)
                n /= 2
            }

            for j in codebase.range(3, Sqrt(n), 2)
            {
                while (Mod(n, j) == 0)
                {
                    p.Push(Round(j))
                    n /= j
                }
            }

            if (n > 2)
            {
                p.Push(Round(n))
            }

            return p
        }

        /**
         * In essence, calculates the slope of the linear function that is described by an x-y-coordinate pair and calculates the sought-after value by inputting another value for `x`.
         * @param x The `x` "distance" over which the change of `y` takes place.
         * @param y The `y` "height change" that takes place over the "distance" of `x`.
         * @param targetX The desired `x` input to calculate the estimate for.
         * @returns The result of the calculation.
         */
        static ruleOfThree(x, y, targetX) => (y / x) * targetX

        /**
         * Calculates the factorial of a number.
         * @param n The number of which to calculate the factorial.
         * @throws `ValueError` of `n` is negative.
         * @returns The factorial of `n`.
         */
        static factorial(n)
        {
            if (n == 0)
            {
                return 1
            }
            if (n < 0)
            {
                throw ValueError("Invalid value for ``n``. Received ``" . n . "``, expected a positive value or ``0``.")
            }

            return codebase.math.product(1, n, (x) => x)
        }

        /**
         * Calculates the logarithm of a number with a given base.
         * @param num The number to get the logarithm of.
         * @param base The base to use.
         * @returns The logarithm of the number.
         */
        static log(num, base) => Log(num) / Log(base)

        /**
         * Steps through a range of values, passes them to a custom function and returns the sum of the results.
         * @param x The inclusive start value (lower bound) of the numbers to step through.
         * @param n The inclusive stop value (upper bound) of the numbers to step through.
         * @param fn The function to pass the current number to. Must support being passed exactly one parameter and return a numeric value.
         * @throws `TypeError` if `fn` is not a `Func` object or one of its subtypes.
         * @returns The sum of the numbers returned by `fn`.
         */
        static sum(x, n, fn)
        {
            if (!(fn is Func))
            {
                throw TypeError("Invalid type for ``fn``. Received ``" . Type(fn) . "``, expected ``Func``, ``Closure`` or ``BoundFunc``.")
            }

            result := 0
            for num in codebase.range(x, n)
            {
                result += fn(num)
            }
            return result
        }

        /**
         * Steps through a range of values, passes them to a custom function and returns the product of the results.
         * @param x The inclusive start value (lower bound) of the numbers to step through.
         * @param n The inclusive stop value (upper bound) of the numbers to step through.
         * @param fn The function to pass the current number to. Must support being passed exactly one parameter and return a numeric value.
         * @throws `TypeError` if `fn` is not a `Func` object or one of its subtypes.
         * @returns The product of the numbers returned by `fn`.
         */
        static product(x, n, fn)
        {
            if (!(fn is Func))
            {
                throw TypeError("Invalid type for ``fn``. Received ``" . Type(fn) . "``, expected ``Func``, ``Closure`` or ``BoundFunc``.")
            }

            result := 1
            for num in codebase.range(x, n)
            {
                result *= fn(num)
            }
            return result
        }

        /**
         * Calculates the solution(s) of the quadratic formula. The parameters should be taken from a quadratic function as follows: `ax^2 + bx + c = 0`.
         * @param a The coefficient of `x^2`.
         * @param b The coefficient of `x`.
         * @param c The y-intercept / constant `c`.
         * @returns An Array of length `1` or `2` depending on how many were found.
         * @returns An empty Array if no solutions exist or they are complex.
         */
        static quadraticFormula(a, b, c)
        {
            try
            {
                d := Sqrt((b ** 2) - 4 * a * c)
            }
            catch
            {
                return 0
            }

            if (d == 0)
            {
                return [-b / 2]
            }

            return [(-b + d) / 2, (-b - d) / 2]
        }

        /**
         * Rounds a number to the nearest multiple of a number.
         * @param n The number to round.
         * @param m TODO
         */
        static roundMultiple(n, m) => Round(n / m) * m

        class sequences
        {
            /**
             * Calculates a number in the Fibonacci sequence.
             * @param n The number in the sequence to calculate.
             * @returns The `n`th Fibonacci number.
             */
            static fibonacci(n)
            {
                if (n < 2)
                {
                    return n
                }
                return codebase.math.sequences.fibonacci(n - 1) + codebase.math.sequences.fibonacci(n - 2)
            }

            /**
             * Calculates a number in the Pell sequence.
             * @param n The number in the sequence to calculate.
             * @returns The `n`th Pell number.
             */
            static pell(n)
            {
                if (n < 2)
                {
                    return n
                }
                return (2 * codebase.math.sequences.pell(n - 1)) + codebase.math.sequences.pell(n - 2)
            }

            /**
             * Calculates a number in the Lucas sequence.
             * @param n The number in the sequence to calculate.
             * @returns The `n`th Lucas number.
             */
            static lucas(n)
            {
                if (n == 0)
                {
                    return 2
                }
                if (n == 1)
                {
                    return 1
                }
                return codebase.math.sequences.lucas(n - 1) + codebase.math.sequences.lucas(n - 2)
            }

            /**
             * Calculates a number in the Pell-Lucas sequence.
             * @param n The number in the sequence to calculate.
             * @returns The `n`th Pell-Lucas number.
             */
            static pellLucas(n)
            {
                if (n < 2)
                {
                    return 2
                }
                return (2 * codebase.math.sequences.pellLucas(n - 1)) + codebase.math.sequences.pellLucas(n - 2)
            }

            /**
             * Calculates a number in the Calkin-Wilf sequence.
             * @param n The number in the sequence to calculate.
             * @returns The `n`th Calkin-Wilf number.
             */
            static calkinWilf(n)
            {
                if (n < 2)
                {
                    return n
                }
                return 1 / ((2 * Floor(codebase.math.sequences.calkinWilf(n - 1))) - codebase.math.sequences.calkinWilf(n - 1) + 1)
            }
        }

        class geometry
        {
            class square
            {
                static getArea(a) => a ** 2
                static getPerimeter(a) => 4 * a
                static getDiagonal(a) => Sqrt(2) * a
            }

            class cube
            {
                static getVolume(a) => a ** 3
                static getSurface(a) => 6 * (a ** 2)
                static getDiagonal(a) => Sqrt(3) * a
            }

            class rectangle
            {
                static getArea(a, b) => a * b
                static getPerimeter(a, b) => 2 * (a + b)
                static getDiagonal(a, b) => Sqrt(a ** 2 + b ** 2)
            }

            class cuboid
            {
                static getVolume(a, b, c) => a * b * c
                static getSurface(a, b, c) => 2 * (a * (b + c) + b * c)
                static getDiagonal(a, b, c) => Sqrt((a ** 2) + (b ** 2) + (c ** 2))
            }

            class circle
            {
                static getArea(r) => codebase.math.constants.pi * (r ** 2)
                static getCircumference(r) => 2 * codebase.math.constants.pi * r
                static getRadiusArea(A) => Sqrt(A / codebase.math.constants.pi)
                static getRadiusCircumference(u) => u / 2 * codebase.math.constants.pi
                static getSectorArea(r, ang) => (codebase.math.constants.pi * (r ** 2) * ang) / 360
                static getSectorArc(r, ang) => (codebase.math.constants.pi * r * ang) / 180
            }

            class cylinder
            {
                static getVolume(r, h) => codebase.math.constants.pi * (r ** 2) * h
                static getSurface(r, h) => 2 * codebase.math.constants.pi * r * (r + h)
                static getMantle(r, h) => codebase.math.geometry.circle.getCircumference(r) * h
            }

            class cone
            {
                static getVolume(r, h) => (codebase.math.constants.pi * (r ** 2) * h) / 3
                static getSurface(r, h) => codebase.math.constants.pi * r * (r + (codebase.math.geometry.cone.getSlant(r, h)))
                static getSlant(r, h) => Sqrt((r ** 2) + (h ** 2))
            }

            class sphere
            {
                static getVolume(r) => (4 * codebase.math.constants.pi * (r ** 3)) / 3
                static getSurface(r) => 4 * codebase.math.constants.pi * (r ** 2)
            }
        }

        class probability
        {
            /**
             * Picks one from a set of elements with set chances.
             * @param elems A Map object with a label for the items and their associated chances.
             * @note The probabilities of the items need not add up to exactly `1`.
             * @returns A Map object with the chosen item and what random number caused it to be picked. This number is between `0` and the sum of all probabilities in `elems`.
             */
            static pickRandom(elems)
            {
                celems := Map()
                o := 0
                for e, p in elems
                {
                    o += p
                    celems.Set(e, o)
                }

                ran := Random(0.0, o)
                for e, p in celems
                {
                    if (p >= ran)
                    {
                        return Map(
                            "e", e,
                            "p", p,
                            "ran", ran
                        )
                    }
                }
            }

            /**
             * Calculates the probability of correctly randomly picking a series of elements from a given subset size from a set.
             * @param n The size of the set.
             * @param k The size of the subsets.
             * @param h The number of correctly picked elements from `k`.
             * @returns The probability of randomly picking `h` correct elements from a specific subset of size `k` of `n`.
             */
            static specificChance(n, k, h) => (codebase.math.probability.choose(k, h) * codebase.math.probability.choose(n - k, k - h)) / codebase.math.probability.choose(n, k)
            
            /**
             * Calculates the probability of correctly randomly picking a specific range of series of elements from a given subset size from a set. Used for scenarios where the desired number of correct random picks is described as "at least `lower`" or "at most `upper`".
             * @param n The size of the set.
             * @param k The size of the subsets.
             * @param lower The inclusive lower bound for calculating the cumulative probability. Defaults to `0` if omitted.
             * @param upper The inclusive upper bound for calculating the cumulative probability. Defaults to `k` if omitted.
             * @returns The probability of getting between `lower` and `upper` hits in `n` trials.
             */
            static specificChanceCumulative(n, k, lower := 0, upper?)
            {
                if (!IsSet(upper))
                {
                    upper := k
                }

                if (upper < lower)
                {
                    return codebase.math.sum(upper, lower, (s) => codebase.math.probability.choose(k, s) * codebase.math.probability.choose(n - k, k - s) / codebase.math.probability.choose(n, k))
                }
                return codebase.math.sum(lower, upper, (s) => codebase.math.probability.choose(k, s) * codebase.math.probability.choose(n - k, k - s) / codebase.math.probability.choose(n, k))
            }
            
            /**
             * Calculates the number of possible subsets in a set, with the following conditions (binomial coefficient):
             * - `abc = acb = bac = bca = cab = cba` and these are all counted as `1` total
             * - repetitions like picking `aaa` are not allowed
             * @param n The size of the set.
             * @param k The size of the subsets.
             * @throws `ValueError` if `k` is greater than `n`.
             * @throws `ValueError` if `k` is less than `0`.
             * @returns The number of possible subsets in `n` according to the above conditions.
             */
            static choose(n, k)
            {
                if (k > n || k < 0)
                {
                    throw ValueError("Invalid value for ``k``. Received ``" . k . "``, expected a number less than or equal to ``n`` (" . n . ").")
                }
                if (k == 0 || n == k)
                {
                    return 1
                }

                k := Min(k, n - k)
                c := 1
                for searchx in codebase.range(0, k - 1)
                {
                    c *= (n - searchx) / (searchx + 1)
                }
                return c
            }

            /**
             * Calculates the number of possible subsets in a set, with the following conditions (permutations):
             * - `ab ≠ ba` and permutations that contain the same elements but in a different order are counted individually
             * - repetitions like picking `aa` are allowed
             * @param n The size of the set.
             * @param k The size of the subsets.
             * @throws `ValueError` if `k` is greater than `n`.
             * @throws `ValueError` if `k` is less than `0`.
             * @returns The number of possible subsets in `n` according to the above conditions.
             */
            static permute(n, k)
            {
                if (k > n || k < 0)
                {
                    throw ValueError("Invalid value for ``k``. Received ``" . k . "``, expected a number less than or equal to ``n`` (" . n . ").")
                }
                if (k == 0)
                {
                    return 1
                }
                if (n == k)
                {
                    return n ** n
                }
            }

            /**
             * Calculates the number of possible subsets in a set, with the following conditions (partial permutations):
             * - `ab ≠ ba` and permutations that contain the same elements but in a different order are counted individually
             * - repetitions like picking `aa` are not allowed
             * @param n The size of the set.
             * @param k The size of the subsets.
             * @throws `ValueError` if `k` is greater than `n`.
             * @throws `ValueError` if `k` is less than `0`.
             * @returns The number of possible subsets in `n` according to the above conditions.
             */
            static partialPermute(n, k)
            {
                if (k > n || k < 0)
                {
                    throw ValueError("Invalid value for ``k``. Received ``" . k . "``, expected a number less than or equal to ``n`` (" . n . ").")
                }
                if (k == 0)
                {
                    return 1
                }
                if (n == k)
                {
                    return codebase.math.factorial(n)
                }

                p := 1
                for searchx in codebase.range(n - k + 1, n)
                {
                    p *= searchx
                }

                return p
            }

            /**
             * Calculates the expected value (`E(X)`, `mu`, `μ`) for a set of values and associated probabilities.
             * @param x_i The values to use.
             * @param Px An associated probability for each element in `x_i`.
             * @throws `TypeError` if `x_i` is not an `Array`.
             * @throws `TypeError` if `Px` is not an `Array`.
             * @throws `ValueError` if `x_i.Length` is not `Px.Length`.
             * @returns The expected value of `X`.
             */
            static expectedValue(x_i, Px)
            {
                if (Type(x_i) !== "Array")
                {
                    throw TypeError("Invalid type for ``x_i``. Received ``" . Type(x_i) . "``, expected ``Array``.")
                }
                if (Type(Px) !== "Array")
                {
                    throw TypeError("Invalid type for ``Px``. Received ``" . Type(Px) . "``, expected ``Array``.")
                }
                if (Px.Length !== x_i.Length)
                {
                    throw ValueError("Invalid value for ``Px.Length``. Received ``" . Px.Length . "``, expected ``x_i.Length`` (``" . x_i.Length . "``).")
                }

                mu := 0
                for j in codebase.range(1, x_i.Length)
                {
                    mu += x_i[j] * Px[j]
                }
                return mu
            }

            /**
             * Calculates the variance for a set of values and associated probabilities.
             * @param x_i The values to use.
             * @param Px An associated probability for each element in `x_i`.
             * @throws `TypeError` if `x_i` is not an `Array`.
             * @throws `TypeError` if `Px` is not an `Array`.
             * @throws `ValueError` if `x_i.Length` is not `Px.Length`.
             * @returns The variance of `X`.
             */
            static variance(x_i, Px)
            {
                if (Type(x_i) !== "Array")
                {
                    throw TypeError("Invalid type for ``x_i``. Received ``" . Type(x_i) . "``, expected ``Array``.")
                }
                if (Type(Px) !== "Array")
                {
                    throw TypeError("Invalid type for ``Px``. Received ``" . Type(Px) . "``, expected ``Array``.")
                }
                if (Px.Length !== x_i.Length)
                {
                    throw ValueError("Invalid value for ``Px.Length``. Received ``" . Px.Length . "``, expected ``x_i.Length`` (``" . x_i.Length . "``).")
                }

                mu := codebase.math.probability.expectedValue(x_i, Px)

                var := 0
                for j in codebase.range(1, x_i.Length)
                {
                    var += ((x_i[j]) ** 2) * Px[j]
                }
                return var
            }

            /**
             * Calculates the standard deviation for a set of values and associated probabilities.
             * @param x_i The values to use.
             * @param Px An associated probability for each element in `x_i`.
             * @throws `TypeError` if `x_i` is not an `Array`.
             * @throws `TypeError` if `Px` is not an `Array`.
             * @throws `ValueError` if `x_i.Length` is not `Px.Length`.
             * @returns The standard deviation of of `X`.
             */
            static standardDeviation(x_i, Px)
            {
                if (Type(x_i) !== "Array")
                {
                    throw TypeError("Invalid type for ``x_i``. Received ``" . Type(x_i) . "``, expected ``Array``.")
                }
                if (Type(Px) !== "Array")
                {
                    throw TypeError("Invalid type for ``Px``. Received ``" . Type(Px) . "``, expected ``Array``.")
                }
                if (Px.Length !== x_i.Length)
                {
                    throw ValueError("Invalid value for ``Px.Length``. Received ``" . Px.Length . "``, expected ``x_i.Length`` (``" . x_i.Length . "``).")
                }

                return Sqrt(codebase.math.probability.variance(x_i, Px))
            }

            /**
             * Calculates the probability of getting a specific total number of hits in a number of trials where there are only two possible outcomes.
             * @param n The number of trials that are conducted.
             * @param p The probability of getting a hit.
             * @param k The desired total number of hits in the trials.
             * @throws `ValueError` if `p` is negative or `0`.
             * @throws `ValueError` if `k` is greater than `n`.
             * @throws `ValueError` if `k` is less than `0`.
             * @returns The probability of getting `k` hits in `n` trials.
             */
            static binomialDistribution(n, p, k)
            {
                if (p <= 0)
                {
                    throw ValueError("Invalid value for ``p``. Received ``" . p . "``, expected a number greater than ``0``.")
                }
                if (k > n || k < 0)
                {
                    throw ValueError("Invalid value for ``k``. Received ``" . k . "``, expected a number less than or equal to ``n`` (" . n . ").")
                }

                return codebase.math.probability.choose(n, k) * (p ** k) * ((1 - p) ** (n - k))
            }

            /**
             * Calculates the probability of getting a specific range of numbers of hits in a number of trials, where there are only two possible outcomes. Used for scenarios where the desired number of hits is described as "at least `lower`" or "at most `upper`".
             * @param n The number of trials that are conducted.
             * @param p The probability of getting a hit.
             * @param lower The inclusive lower bound for calculating the cumulative distribution function.
             * @param upper The inclusive upper bound for calculating the cumulative distribution function.
             * @returns The probability of getting between `lower` and `upper` hits in `n` trials.
             */
            static binomialDistributionRange(n, p, lower, upper)
            {
                if (upper < lower)
                {
                    return codebase.math.sum(upper, lower, (s) => codebase.math.probability.choose(n, s) * (p ** s) * ((1 - p) ** (n - s)))
                }
                return codebase.math.sum(lower, upper, (s) => codebase.math.probability.choose(n, s) * (p ** s) * ((1 - p) ** (n - s)))
            }

            /**
             * Contructs an Array of Map objects, the first containing the probability of getting a specific total number of hits according to the binomial distribution and the second containing the probability of getting a specific range of numbers of hits according to the cumulative binomial distribution.
             * @param n The number of trials that are conducted and the inclusive upper bound for the calculations. Each number between `0` and this inclusive will be used to calculate the probability for that specific number of hits and the `0`-based cumulative distribution function (let `x` be that number, then the cumulative probability will be calculated with a lower bound of `0` and an upper bound of `x`).
             * @param p The probability of getting a hit.
             * @param rnd The number of decimal places to round the results to. Defaults to `6` if omitted.
             * @returns The Array as described.
             */
            static binomialDistributionTables(n, p, rnd := 6)
            {
                distr := Map()
                cumul := Map()

                for searchx in codebase.range(0, n)
                {
                    distr.Set(searchx, Round(codebase.math.probability.binomialDistribution(n, p, searchx), rnd))
                    distr.Set(searchx, Round(codebase.math.probability.binomialDistributionRange(n, p, 0, searchx), rnd))
                }

                return [distr, cumul]
            }
        }
    }

    class directoryOperations
    {
        /**
         * Installs a monitor on a directory, allowing the user to register functions to be called when files are added or removed.
         */
        class DirectoryMonitor
        {
            /**
             * Instatiates a new `codebase.directoryOperations.DirectoryMonitor` object.
             * @param path The path of the directory to monitor.
             * @param interval The interval at which to check for changes. Defaults to `10000` (10 seconds) if omitted.
             * @param callbacks An object with one or more of the following props containing functions to be called when the corresponding event occurs. If omitted, the `add` and `remove` callbacks will be registered automatically. The default implementation of these display a Tooltip detailing the changes in the top-left corner of the right-most monitor.
             * - `add`: A file is added to the directory.
             * - `remove`: A file is removed from the directory.
             * @returns A `codebase.directoryOperations.DirectoryMonitor` object.
             */
            __New(path, interval := 10000, callbacks?)
            {
                this.firstRun := true

                this.timer := ObjBindMethod(this, "monitor")

                this.path := path
                this.interval := interval
                this.tooltipTime := 4000
                this.files := []

                this.callbacks := { }

                ; Find the right-most monitor
                l := 0
                t := 0
                for j in codebase.range(1, MonitorGetCount())
                {
                    MonitorGet(j, &ln, &tn)
                    if (ln > l)
                    {
                        l := ln
                        t := tn
                    }
                }
                this.x := l + 5
                this.y := t + 5

                if (!IsSet(callbacks))
                {
                    add(caller, files)
                    {
                        str := codebase.stringOperations.strJoin('`n+ ', true, '', files*)
                        codebase.Tool(files.Length . " file" . (files.Length != 1 ? "s" : "") . " added to `"" . this.path . "`":" . str, codebase.Tool.coords, this.tooltipTime, this.x, this.y)
                    }
                    remove(caller, files)
                    {
                        str := codebase.stringOperations.strJoin('`n+ ', true, '', files*)
                        codebase.Tool(files.Length . " file" . (files.Length != 1 ? "s" : "") . " removed from `"" . this.path . "`":" . str, codebase.Tool.coords, this.tooltipTime, this.x, this.y)
                    }

                    this.callbacks.add := add
                    this.callbacks.remove := remove
                }

                this.enable()
            }

            __Delete()
            {
                this.disable()
            }

            enable(interval?)
            {
                if (IsSet(interval))
                {
                    this.interval := interval
                }

                SetTimer(this.timer, this.interval)
            }

            disable(runOnce := false)
            {
                SetTimer(this.timer, (runonce ? -1 : 0))
            }
            
            monitor()
            {
                now := []
                Loop Files this.path . "\*"
                {
                    now.Push(A_LoopFileFullPath)
                }
                if (this.firstRun)
                {
                    this.firstRun := false
                    this.files := now
                    return
                }

                ; Has a `Length` > `0` if the directory has had files added
                add := codebase.collectionOperations.arrayOperations.arrayNotIntersect(now, this.files)
                ; Has a `Length` > `0` if the directory has had files removed
                rem := codebase.collectionOperations.arrayOperations.arrayNotIntersect(this.files, now)
                ; 
                
                ; Show data in the debug console
                ; OutputDebug(this.files.Length . "`n" . now.Length . "`n" . add.Length . "`n" . rem.Length . "`n`n")

                if (add.Length)
                {
                    this.callbacks.add(add)
                }
                else if (rem.Length)
                {
                    this.callbacks.remove(rem)
                }

                this.files := now
            }
        }

        /**
         * Scans the contents of a given directory and returns an Array of paths to all folders in the starting directory.
         * @param dir The directory to search through.
         * @param recurse Whether to recurse into subdirectories while conducting the search.
         * @param filter An inclusion filter to apply during the search. If passed, only folders the names of which match with the filter expression will be considered. Defaults to none (all folders) if omitted.
         * @returns An Array of paths to the folders in `dir`.
         * @returns An Array of paths to the folders and subfolders in `dir`, if `recurse` is `true`.
         * @returns An empty Array if there are no folders in `dir`.
         */
        static getFolders(dir, recurse, filter := "")
        {
            paths := []

            Loop Files dir . (filter ? "\" . filter : "\*"), (recurse ? "RD" : "D")
            {
                paths.Push(A_LoopFileFullPath)
            }

            return paths
        }

        /**
         * Scans the contents of a given directory and returns an Array of paths to all files in the starting directory.
         * @param dir The directory to search through.
         * @param recurse Whether to recurse into subdirectories while conducting the search.
         * @param filter An inclusion filter to apply during the search. If passed, only files the names of which match with the filter expression will be considered. Defaults to none (all folders) if omitted.
         * @returns An Array of paths to the files in `dir`.
         * @returns An Array of paths to the files in `dir` and all subfolders of `dir`, if `recurse` is `true`.
         * @returns An empty Array if there are no files in `dir`.
         */
        static getFiles(dir, recurse, filter := "")
        {
            paths := []

            Loop Files dir . (filter ? "\" . filter : "\*"), (recurse ? "RF" : "F")
            {
                paths.Push(A_LoopFileFullPath)
            }

            return paths
        }

        /**
         * Determines if a directory is empty.
         * @param dir The directory to search through.
         * @returns `true` if the directory contains no other directories or files.
         */
        static isEmpty(dir) => !(codebase.directoryOperations.getFiles(dir, false).Length || codebase.directoryOperations.getFolders(dir, false).Length)

        /**
         * Scans the files of a given directory and returns the path to the oldest file, with 'oldest' referring to creation date.
         * @param dir The directory to search through.
         * @param recurse Whether to recurse into subdirectories while conducting the search.
         * @param filter An inclusion filter to apply during the search. If passed, only files the names of which match with the filter expression will be considered. Defaults to none (all files) if omitted.
         * @note If multiple files have the same creation date, the first one found will be returned.
         * @returns The absolute path to the oldest file in the directory.
         * @returns The absolute path to the oldest file in the directory or one of its subdirectories, if `recurse` is `true`.
         * @returns An empty string if no file was found.
         */
        static getOldest(dir, recurse, filter := "")
        {
            path := ""
            date := A_Now

            Loop Files dir . (filter ? "\" . filter : "\*"), (recurse ? "RF" : "F")
            {
                if (DateDiff(A_LoopFileTimeCreated, date, "S") < 0)
                {
                    path := A_LoopFileFullPath
                    date := A_LoopFileTimeCreated
                }
            }

            return path
        }

        /**
         * Scans the files of a given directory and returns the path to the newest file, with 'newest' referring to creation date.
         * @param dir The directory to search through.
         * @param recurse Whether to recurse into subdirectories while conducting the search.
         * @param filter An inclusion filter to apply during the search. If passed, only files the names of which match with the filter expression will be considered. Defaults to none (all files) if omitted.
         * @note If multiple files have the same creation date, the first one found will be returned.
         * @returns The absolute path to the newest file in the directory.
         * @returns The absolute path to the newest file in the directory or one of its subdirectories, if `recurse` is `true`.
         * @returns An empty string if no file was found.
         */
        static getNewest(dir, recurse, filter := "")
        {
            path := ""
            date := codebase.constants.ahkTimeZero

            Loop Files dir . (filter ? "\" . filter : "\*"), (recurse ? "RF" : "F")
            {
                if (DateDiff(A_LoopFileTimeCreated, date, "S") > 0)
                {
                    path := A_LoopFileFullPath
                    date := A_LoopFileTimeCreated
                }
            }

            return path
        }

        /**
         * Scans the files of a given directory and returns the path to the largest one (file size).
         * @param dir The directory to search through.
         * @param recurse Whether to recurse into subdirectories while conducting the search.
         * @param filter An inclusion filter to apply during the search. If passed, only files the names of which match with the filter expression will be considered. Defaults to none (all files) if omitted.
         * @note If multiple files have the same size, the first one found will be returned.
         * @returns The absolute path to the oldest file in the directory.
         * @returns The absolute path to the oldest file in the directory or one of its subdirectories, if `recurse` is `true`.
         * @returns An empty string if no file was found.
         */
        static getLargest(dir, recurse, filter := "")
        {
            path := ""
            size := 0

            Loop Files dir . (filter ? "\" . filter : "\*"), (recurse ? "RF" : "F")
            {
                if (A_LoopFileSize > size)
                {
                    path := A_LoopFileFullPath
                    size := A_LoopFileSizeMB
                }
            }

            return path
        }

        /**
         * Scans the files of a given directory and returns the path to the smallest one (file size).
         * @param dir The directory to search through.
         * @param recurse Whether to recurse into subdirectories while conducting the search.
         * @param filter An inclusion filter to apply during the search. If passed, only files the names of which match with the filter expression will be considered. Defaults to none (all files) if omitted.
         * @note If multiple files have the same size, the first one found will be returned.
         * @returns The absolute path to the oldest file in the directory.
         * @returns The absolute path to the oldest file in the directory or one of its subdirectories, if `recurse` is `true`.
         * @returns An empty string if no file was found.
         */
        static getSmallest(dir, recurse, filter := "")
        {
            path := ""
            size := codebase.datatypes.Int64.max_value

            Loop Files dir . (filter ? "\" . filter : "\*"), (recurse ? "RF" : "F")
            {
                if (A_LoopFileSize < size)
                {
                    path := A_LoopFileFullPath
                    size := A_LoopFileSizeMB
                }
            }

            return path
        }
    }

    class windowOperations
    {
        /**
         * Checks whether a window is currently being displayed on the primary monitor.
         * @param target The window to check. Defaults to the currently active window if omitted.
         * @returns `true` if `target`'s top-left corner is on the primary monitor, `false` otherwise.
         */
        static isOnPrimaryMonitor(target?)
        {
            MonitorGet(MonitorGetPrimary(), &l, &t, &r, &b)
            WinGetPos(&x, &y, &w, &h, IsSet(target) ? target : "A")
            if ((x < r && x > l) && (y < b && y > t))
            {
                return true
            }
            else
            {
                return false
            }
        }
    }

    class convert
    {
        /**
         * The factor used to convert radians to degrees.
         */
        static radToDeg := 180 / codebase.math.constants.pi
         /**
          * The factor used to convert degrees to radians.
          */
        static degToRad := codebase.math.constants.pi / 180

        class misc
        {
            static CtoF(celsius) => (celsius * (9 / 5)) + 32
            static FtoC(fahrenheit) => (fahrenheit - 32) * (5 / 9)

            static MPGtoLP100(mpg) => 235.214583 / mpg
            static LP100toMPG(lp100) => 235.214583 / lp100
        }

        static DecToBase64()
        {
            if (dec < 0)
            {
                prefix := "-" . prefix
                dec := Abs(dec)
            }

            out := ""

            while (dec !== 0)
            {
                rm := Mod(dec, 64)
                if (rm < 26)
                {
                    out .= []
                }
                else if (rm < 36)
                {
                    out .= Chr(65 + (rm - 10))
                }
                dec := Integer(dec / 64)
            }

            out := StrReplace(out, "-", "")

            if (pad < 0)
            {
                Loop
                {
                    if (StrLen(out) <= 2 ** (A_Index - 1))
                    {
                        pad := 2 ** (A_Index - 1)
                        break
                    }
                }
            }

            p := pad - StrLen(out)
            Loop (p < 0 ? 0 : p)
            {
                out .= "0"
            }

            return codebase.stringOperations.strReverse(out)
        }

        /**
         * Convert a given decimal number into hexadecimal. The output will automatically be prepended with a "0x" to identify the number as hex.
         * @param dec The decimal number to convert.
         * @param pad The desired minimal width to pad the output value with `0`'s to. Defaults to the next-higher power of 2 if omitted.
         * @returns `dec` converted into hexadecimal.
         */
        static DecToHex(dec, pad := -1)
        {
            prefix := "0x"

            if (dec < 0)
            {
                prefix := "-" . prefix
                dec := Abs(dec)
            }

            out := ""

            while (dec !== 0)
            {
                rm := Mod(dec, 16)
                if (rm < 10)
                {
                    out .= rm
                }
                else if (rm < 36)
                {
                    out .= Chr(65 + (rm - 10))
                }
                dec := Integer(dec / 2)
            }

            out := StrReplace(out, "-", "")

            if (pad < 0)
            {
                Loop
                {
                    if (StrLen(out) <= 2 ** (A_Index - 1))
                    {
                        pad := 2 ** (A_Index - 1)
                        break
                    }
                }
            }

            p := pad - StrLen(out)
            Loop (p < 0 ? 0 : p)
            {
                out .= "0"
            }

            return codebase.stringOperations.strReverse(out . codebase.stringOperations.strReverse(prefix))
        }

        /**
         * Convert a given decimal number into binary.
         * @param dec The decimal number to convert.
         * @param pad The desired minimal width to pad the output value with `0`'s to. Defaults to the next-higher power of 2.
         * @returns `dec` converted into binary.
         */
        static DecToBin(dec, pad := -1)
        {
            prefix := ""

            if (dec < 0)
            {
                prefix := "-" . prefix
                dec := Abs(dec)
            }

            out := ""

            while (dec !== 0)
            {
                rm := Mod(dec, 2)
                if (rm < 10)
                {
                    out .= rm
                }
                else if (rm < 36)
                {
                    out .= Chr(65 + (rm - 10))
                }
                dec := Integer(dec / 2)
            }

            out := StrReplace(out, "-", "")

            if (pad < 0)
            {
                Loop
                {
                    if (StrLen(out) <= 2 ** (A_Index - 1))
                    {
                        pad := 2 ** (A_Index - 1)
                        break
                    }
                }
            }

            p := pad - StrLen(out)
            Loop (p < 0 ? 0 : p)
            {
                out .= "0"
            }

            return codebase.stringOperations.strReverse(out . codebase.stringOperations.strReverse(prefix))
        }

        /**
         * Convert a given binary number into decimal.
         * @param bin The bin number to convert.
         * @returns The input number converted into decimal.
         */
        static BinToDec(bin)
        {
            res := 0

            bin := StrReplace(bin, "-", "", false, &neg)
            bin := codebase.stringOperations.strReverse(bin)
            bin := StrSplit(bin)

            for j in bin
            {
                res += j * (2 ** (A_Index - 1))
            }

            if (neg)
            {
                res := -res
            }

            return res
        }

        /**
         * Convert a given hexadecimal number into decimal.
         * @param hex The hex number to convert.
         * @returns The input number converted into decimal.
         */
        static HexToDec(hex)
        {
            res := 0
            hex := StrReplace(hex, "0x", "")
            hex := StrReplace(hex, "-", "", false, &neg)

            hex := codebase.stringOperations.strReverse(hex)
            hex := StrSplit(hex)

            for j in hex
            {
                res += (IsNumber(j) ? j : Ord(j) - 55) * (16 ** (A_Index - 1))
            }

            if (neg)
            {
                res := -res
            }

            return res
        }

        class colors
        {
            /**
             * Calculates the average of a series of colors.
             * @param colors The colors to average.
             * @note The output always contains an Alpha component, even if the input colors do not. If an input color does not contain an Alpha component, it will be assumed to be `0xFF` or `255`. This will cause unexpected results if not all of the input colors have an Alpha component, so `SubStr` the output to remove the Alpha component if it is unwanted.
             * @returns The average color.
             */
            static average(colors*)
            {
                rvs := []
                gvs := []
                bvs := []
                avs := []

                for c in colors
                {
                    rvs.Push(codebase.convert.HexToDec(SubStr(c, 3, 2)))
                    gvs.Push(codebase.convert.HexToDec(SubStr(c, 5, 2)))
                    bvs.Push(codebase.convert.HexToDec(SubStr(c, 7, 2)))
                    if ((alpha := SubStr(c, 9, 2)) !== "")
                    {
                        avs.Push(codebase.convert.HexToDec(alpha))
                    }
                    else
                    {
                        avs.Push(255)
                    }
                }

                r := Round(codebase.math.avg(rvs*))
                g := Round(codebase.math.avg(gvs*))
                b := Round(codebase.math.avg(bvs*))
                a := Round(codebase.math.avg(avs*))
                return codebase.convert.DecToHex(r, 2)
                    . SubStr(codebase.convert.DecToHex(g, 2), 3)
                    . SubStr(codebase.convert.DecToHex(b, 2), 3)
                    . SubStr(codebase.convert.DecToHex(a, 2), 3)
            }

            static variation(color, shades)
            {
                r := codebase.convert.HexToDec(SubStr(color, 3, 2))
                g := codebase.convert.HexToDec(SubStr(color, 5, 2))
                b := codebase.convert.HexToDec(SubStr(color, 7, 2))
                if ((a := SubStr(color, 9, 2)) !== "")
                {
                    a := codebase.convert.HexToDec(a)
                }
                else
                {
                    a := 255
                }

                return [
                    "0x" . codebase.convert.DecToHex(((v := r - shades) < 0 ? 0 : v), 2)
                        . SubStr(codebase.convert.DecToHex(((v := g - shades) < 0 ? 0 : v), 2), 3)
                        . SubStr(codebase.convert.DecToHex(((v := b - shades) < 0 ? 0 : v), 2), 3)
                        . SubStr(codebase.convert.DecToHex(((v := a - shades) < 0 ? 0 : v), 2), 3),
                    color
                    "0x" . codebase.convert.DecToHex(((v := r + shades) > 255 ? 255 : v), 2)
                        . SubStr(codebase.convert.DecToHex(((v := g + shades) > 255 ? 255 : v), 2), 3)
                        . SubStr(codebase.convert.DecToHex(((v := b + shades) > 255 ? 255 : v), 2), 3)
                        . SubStr(codebase.convert.DecToHex(((v := a + shades) > 255 ? 255 : v), 2), 3)
                ]
            }

            /**
             * Checks if a given color is between two other colors by numerically comparing the RGB(A) components.
             * @param color The color to check.
             * @param min The lower bound color.
             * @param max The upper bound color.
             * @returns `true` if the color is between the two other colors, `false` otherwise.
             */
            static between(color, min, max) => codebase.convert.colors.compare(min, color) && codebase.convert.colors.compare(color, max)

            /**
             * Compares two color values (numerically).
             * @param refColor The color to compare to.
             * @param compColor The color to compare with.
             * @param fullExclusive If truthy, to be considered greater than `refColor`, all of `compColor`'s rgb(a) components must actually be greater than its corresponding value in `refColor`.
             * @returns `0` if `compColor` is numerically equal to `refColor`
             * @returns `1` if `compColor` is numerically greater than `refColor`, `-1` otherwise.
             */
            static compare(refColor, compColor, fullExclusive := false)
            {
                ref := []
                comp := []

                for val in codebase.convert.colors.HexToRGB(refColor)
                {
                    ref.Push(val)
                }

                for val in codebase.convert.colors.HexToRGB(compColor)
                {
                    comp.Push(val)
                }

                gt := []
                lt := []
                Loop ref.Length
                {
                    gt.Push(comp[A_Index] > ref[A_Index])
                    lt.Push(comp[A_Index] < ref[A_Index])
                }

                gt := (fullExclusive ? codebase.collectionOperations.and(gt*)  : codebase.collectionOperations.or(gt*))  ; Evaluates to `1` if `compColor > refColor`
                lt := (fullExclusive ? -codebase.collectionOperations.and(lt*) : -codebase.collectionOperations.or(lt*)) ; Evaluates to `-1` if `compColor < refColor`
                return codebase.collectionOperations.true(gt, lt, 0)
            }

            /**
             * Converts a color string in hex format into its `rgb` or `rgba` representation. The output only includes an alpha value if it is included in the input string.
             * @param color The hex color string to convert. Expected to be a hex string in one of the following formats:
             * - `0xA82`
             * - `0xA82F`
             * - `0xAE8623`
             * - `0xAE8623FF`
             * @param paste Whether to return a pastable string instead of an Array of values. Defaults to `false` if omitted.
             * @returns The individual components of the `rgb` or `rgba` representation of the input color in an Array if `paste` is `false`.
             * @returns The input hex color represented as `rgb` or `rgba` if `paste` is `true`.
             */
            static HexToRGB(color, paste := false)
            {
                cols := []

                switch (StrLen(StrReplace(color, "0x", "")))
                {
                    case 3:
                        cols := [
                            codebase.convert.HexToDec(SubStr(color, 3, 1)) * 17,
                            codebase.convert.HexToDec(SubStr(color, 4, 1)) * 17,
                            codebase.convert.HexToDec(SubStr(color, 5, 1)) * 17
                        ]
                    case 4:
                        cols := [
                            codebase.convert.HexToDec(SubStr(color, 3, 1)) * 17,
                            codebase.convert.HexToDec(SubStr(color, 4, 1)) * 17,
                            codebase.convert.HexToDec(SubStr(color, 5, 1)) * 17,
                            codebase.convert.HexToDec(SubStr(color, 6, 1)) * 17
                        ]
                    case 6:
                        cols := [
                            codebase.convert.HexToDec(SubStr(color, 3, 2)),
                            codebase.convert.HexToDec(SubStr(color, 5, 2)),
                            codebase.convert.HexToDec(SubStr(color, 7, 2))
                        ]
                    case 8:
                        cols := [
                            codebase.convert.HexToDec(SubStr(color, 3, 2)),
                            codebase.convert.HexToDec(SubStr(color, 5, 2)),
                            codebase.convert.HexToDec(SubStr(color, 7, 2)),
                            codebase.convert.HexToDec(SubStr(color, 9, 2))
                        ]
                    default:
                        throw ValueError("Invalid length of input hex color ``" . color . "``. Received ``" . StrLen(color) . "``, expected ``3``, ``4``, ``6`` or ``8``.")
                }
                
                if (paste)
                {
                    return codebase.stringOperations.strJoin(", ", true, cols*)
                }
                return cols
            }

            /**
             * Converts individual rgba color components (such as `174, 134, 35, 255`) into its hex color string representation. The output only includes an alpha value if one is passed.
             * @param r The red component of the color to convert.
             * @param g The green component of the color to convert.
             * @param b The blue component of the color to convert.
             * @param a The alpha component of the color to convert. Defaults to `unset` if omitted.
             * @returns The input `rgb` or `rgba` color represented as a hex string string.
             */
            static RGBToHex(r, g, b, a?)
            {
                if (r < 0 || r > 255)
                {
                    throw ValueError("Invalid value for ``r``. Received ``" . r . "``, expected a value between ``0`` and ``255``.")
                }
                if (g < 0 || g > 255)
                {
                    throw ValueError("Invalid value for ``g``. Received ``" . g . "``, expected a value between ``0`` and ``255``.")
                }
                if (b < 0 || b > 255)
                {
                    throw ValueError("Invalid value for ``b``. Received ``" . b . "``, expected a value between ``0`` and ``255``.")
                }
                if (IsSet(a))
                {
                    if (a < 0 || a > 255)
                    {
                        throw ValueError("Invalid value for ``a``. Received ``" . a . "``, expected a value between ``0`` and ``255``.")
                    }
                }

                return codebase.convert.DecToHex(r, 2)
                    . SubStr(codebase.convert.DecToHex(g, 2), 3)
                    . SubStr(codebase.convert.DecToHex(b, 2), 3)
                    . (IsSet(a) ? SubStr(codebase.convert.DecToHex(a, 2), 3) : "")
            }
        }
    }

    /**
     * A class to contain a few functions to help send HTTP requests using a COM object by automating the process of constructing it, setting options and finally gathering response data.
     */
    class requests
    {
        /**
         * Send a HTTP request and return its response data as well as a parsed version of the JSON response.
         * @param url The URL to send the request to.
         * @param method The HTTP method to use when sending the request ("GET", "POST", "PATCH", etc.)
         * @param headers A Map object with the headers to set before sending the request.
         * @param data The body data to send with the request. Must be a string, anything interpretable as a string or a `Buffer` object.
         * @throws `TypeError` if a value for `header` is passed but not a Map object.
         * @note When passing body `data` _read from a file_, read the file using `FileRead` with the `RAW` option.
         * @returns A Map object constructed from the contents of the reponse produced by the request.
         */
        static makeRequest(url, method, headers?, data?)
        {
            if (IsSet(headers))
            {
                if (Type(headers) !== "Map")
                {
                    throw TypeError("Invalid type for ``headers``. Received ``" . Type(headers) . "``, expected ``Map``.")
                }
            }

            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open(method, url)
            if (IsSet(headers))
            {
                for header, header_cnt in headers
                {
                    whr.SetRequestHeader(header, header_cnt)
                }
            }
            else
            {
                headers := Map()
            }

            if (IsSet(data))
            {
                if (Type(data) == "Buffer")
                {
                    if (!(headers.Has("Content-Length")))
                    {
                        whr.SetRequestHeader("Content-Length", data.Size)
                    }
                    if (!(headers.Has("Content-Type")))
                    {
                        throw ValueError("Invalid value for ``headers``. Received body ``data`` but no ``Content-Type`` header was set.")
                    }
                }
                else
                {
                    if (!(headers.Has("Content-Length")))
                    {
                        whr.SetRequestHeader("Content-Length", StrLen(data))
                    }
                    if (!(headers.Has("Content-Type")))
                    {
                        throw ValueError("Invalid value for ``headers``. Received body ``data`` but no ``Content-Type`` header was set.")
                    }
                }

                whr.Send(Type(data) == "Buffer" ? StrGet(data) : data)
            }
            else
            {
                whr.Send()
            }

            try
            {
                outMap := Map(
                    "JSON", codebase.requests.parseJson(whr.ResponseText),
                    "ResponseBody", whr.ResponseBody,
                    "ResponseHeaders", StrSplit(whr.GetAllResponseHeaders(), Chr(13) . Chr(10)),
                    "ResponseText", whr.ResponseText,
                    "ResponseTextFormatted", codebase.requests.dumpJson(codebase.requests.parseJson(whr.ResponseText)),
                    "Status", whr.Status,
                    "StatusText", whr.StatusText
                )
            }
            catch
            {
                outMap := Map(
                    "ResponseBody", whr.ResponseBody,
                    "ResponseHeaders", StrSplit(whr.GetAllResponseHeaders(), Chr(13) . Chr(10)),
                    "ResponseText", whr.ResponseText,
                    "Status", whr.Status,
                    "StatusText", whr.StatusText
                )
            }
            whr := ""
            return outMap
        }
        
        /**
         * Call the `load` function of _TheArkive_'s AHKv2 rewrite of the JSON parser for AHK.
         * @param json The JSON string to parse to an object.
         * @returns A Map object with the parsed JSON content.
         */
        static parseJson(json) => jxon_load(&json)
        /**
         * Call the `dump` function of _TheArkive_'s AHKv2 rewrite of the JSON parser for AHK.
         * @param json The JSON object to dump into a string.
         * @returns A formatted string dump of the JSON object.
         */
        static dumpJson(json) => jxon_dump(json, 4)
    }

    class WinInfo
    {
        ahk_id := 0

        /**
         * Instantiates a new `codebase.WinInfo` object.
         * @param identifier An AHK _WinTitle_ parameter to identify the window the data is to be retrieved about / from.
         * @throws `TargetError` if the HWND of the target window could not be retrieved.
         * @returns An instance of the `WinInfo` class with data about the window specified by `identifier`.
         */
        __New(identifier := "A", msg := true)
        {
            ; Use Windows's HWND instead of the title etc. because that may change after execution of this line.
            this.ahk_id := WinGetID(identifier)

            SetTimer(() => ToolTip(), -500)

            if (!(this.ahk_id))
            {
                throw TargetError("Active window HWND could not be retrieved. The window might be 'not responding' or have been closed.")
            }

            WinGetPos(&xAbsolute, &yAbsolute, &wAbsolute, &hAbsolute, this.ahk_id)
            WinGetClientPos(&xClient, &yClient, &wClient, &hClient, this.ahk_id)

            this.wAbsolute := wAbsolute
            this.hAbsolute := hAbsolute
            this.xAbsolute := xAbsolute
            this.yAbsolute := yAbsolute
            this.wClient := wClient
            this.hClient := hClient
            this.xClient := xClient
            this.yClient := yClient

            this.title := WinGetTitle(this.ahk_id)
            this.ahk_class := WinGetClass(this.ahk_id)
            this.ahk_exe := WinGetProcessName(this.ahk_id)
            this.ahk_pid := WinGetPID(this.ahk_id)

            if (!WinExist(this.ahk_id))
            {
                throw TargetError("Active window could not be accessed. The window might be 'not responding' or have been closed.")
            }

            DetectHiddenText(false)
            this.textVisible := SendMessage(0x000D, , , , this.ahk_id)
            try
            {
                this.textStatusVisible := StatusBarGetText(this.ahk_id)
            }
            catch Error
            {
                this.textStatusVisible := ""
            }

            DetectHiddenText(true)
            this.textAll := SendMessage(0x000D, , , , this.ahk_id)
            try
            {
                this.textStatusAll := StatusBarGetText(this.ahk_id)
            }
            catch Error
            {
                this.textStatusAll := ""
            }

            this.processQueryResult := { }
            for p in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
            {
                ; https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-process
                if (p.ProcessId == this.ahk_pid)
                {
                    for v in ["CreationClassName", "Caption", "CommandLine", "CreationDate", "CSCreationClassName", "CSName", "Description", "ExecutablePath", "ExecutionState", "Handle", "HandleCount", "InstallDate", "KernelModeTime", "MaximumWorkingSetSize", "MinimumWorkingSetSize", "Name", "OSCreationClassName", "OSName", "OtherOperationCount", "OtherTransferCount", "PageFaults", "PageFileUsage", "ParentProcessId", "PeakPageFileUsage", "PeakVirtualSize", "PeakWorkingSetSize", "Priority", "PrivatePageCount", "ProcessId", "QuotaNonPagedPoolUsage", "QuotaPagedPoolUsage", "QuotaPeakNonPagedPoolUsage", "QuotaPeakPagedPoolUsage", "ReadOperationCount", "ReadTransferCount", "SessionId", "Status", "TerminationDate", "ThreadCount", "UserModeTime", "VirtualSize", "WindowsVersion", "WorkingSetSize", "WriteOperationCount", "WriteTransferCount"]
                    {
                        if (p.%v%)
                        {
                            this.processQueryResult.DefineProp(v, { Value: p.%v% })
                        }
                    }
                    if (msg)
                    {
                        MsgBox(codebase.elemsOut(this.processQueryResult))
                    }
                    break
                }
            }
            try
            {
                this.commandline := this.processQueryResult.CommandLine
            }
            catch
            {
                this.commandline := this.getCommandLineLegacy()
            }
        }

        /**
         * Attempts to retrieve the full command-line of the target process using the legacy method (a `wmic` call).
         * @note This overwrites `this.commandline`. To restore the original value if this method fails, access `this.processQueryResult.CommandLine`.
         * @returns The full command-line of the target process.
         */
        getCommandLineLegacy()
        {
            ; Run wmic to retrieve the active window's full command-line with arguments
            Run(A_ComSpec . " /c wmic path Win32_Process where handle='" . this.ahk_pid . "' get Commandline /format:list >`"" . A_ScriptDir . "\cmdln.txt`"")

            ; Wait for the file to be created
            Sleep(500)

            ; Read the file
            read := FileRead("cmdln.txt")

            ; Clean up the return string a little; it's full of line breaks
            read := StrReplace(read, "`r", "")
            read := StrReplace(read, "`n", "")
            read := SubStr(read, 13)
            read := Trim(read)

            ; Also put that back into the text file in case it's needed for some other purpose
            try
            {
                FileDelete("cmdln.txt")
            }
            FileAppend(read, "cmdln.txt")

            return read
        }
    }

    /**
     * A class for parsing CSV files.
     */
    class csvOperations
    {
        /**
         * Parses a CSV file into a 2D array.
         * @param file The path to the CSV file to parse.
         * @param delimiter The delimiter to use. Defaults to ',' if omitted.
         * @param quote The quote character to use. Defaults to '"' if omitted.
         * @param trm Whether to trim whitespace from the beginning and end of each value. Defaults to `true` if omitted.
         * @param skipEmpty Whether to skip empty lines. Defaults to `true` if omitted.
         * @returns A 2D array of the parsed CSV file.
         */
        static parse(file, delimiter := ',', quote := '"', trm := true, skipEmpty := true)
        {
            out := []

            Loop Read, file
            {
                ; Skip empty lines
                if (skipEmpty && !(A_LoopReadLine))
                {
                    continue
                }

                sub := []
                ; Split the line into tokens
                Loop Parse A_LoopReadLine, "CSV"
                {
                    f := A_LoopField
                    if (trm)
                    {
                        ; Trim whitespace from the beginning and end of each value
                        f := Trim(f)
                    }
                    ; Add the values to the output array
                    sub.Push(f)
                }
                ; Add the sub-array to the output array
                out.Push(sub)
            }

            ; return the array
            return out
        }

        /**
         * Parses a CSV file into a matrix.
         * @param file The path to the CSV file to parse.
         * @param delimiter The delimiter to use. Defaults to ',' if omitted.
         * @param quote The quote character to use. Defaults to '"' if omitted.
         * @param trm Whether to trim whitespace from the beginning and end of each value. Defaults to `true` if omitted.
         * @param skipEmpty Whether to skip empty lines. Defaults to `true` if omitted.
         * @note As per `codebase.math.matrixComputation.Matrix` standards, empty values extracted from the CSV file are replaced with `0`.
         * @note Attempting to perform operations on the return `codebase.math.matrixComputation.Matrix` object such as calculating its determinant causes an error if any of the cells contain text.
         * @returns A `codebase.math.matrixComputation.Matrix` object with the data of the parsed CSV file.
         */
        static parseToMatrix(file, delimiter := ',', quote := '"', trm := true, skipEmpty := true)
        {
            out := []

            Loop Read, file
            {
                ; Skip empty lines
                if (skipEmpty && !(A_LoopReadLine))
                {
                    continue
                }

                sub := []
                ; Split the line into tokens
                Loop Parse A_LoopReadLine, "CSV"
                {
                    f := A_LoopField
                    if (trm)
                    {
                        ; Trim whitespace from the beginning and end of each value
                        f := Trim(f)
                    }

                    ; Add the values to the output array
                    sub.Push(f)
                }
                ; Add the sub-array to the output array
                out.Push(sub)
            }

            ; return the array
            return codebase.math.matrixComputation.Matrix(out*)
        }
    }

    /**
     * A class outlining data about common number types and containing wrappers for primitive types such as `Byte`, `Int16`, `UInt16`, etc.
     */
    class datatypes
    {
        /**
         * Calculates the minimum value a variable of a data type with the given width can have.
         * @param width The width of the storage in bits.
         * @param signed Whether the storage may be signed.
         * @returns The minimum value of the data type. This is always `0` if `signed` is `false`.
         */
        static getMin(width, signed) => (signed == 1 ? - (2 ** width) : 0)
        
        /**
         * Calculates the minimum value a variable of a data type with the given width can have.
         * @param width The width of the storage in bits.
         * @param signed Whether the storage may be signed.
         * @returns The maximum value of the data type.
         */
        static getMax(width, signed) => (signed == 1 ? 2 ** (width - 1) - 1 : 2 ** this.width - 1)
        
        class base
        {
            static signed := false
            static width := 1

            static min_value := 0
            static max_value := 1

            value
            {
                get
                {
                    return this.v
                }
                set
                {
                    this.v := value & this.max_value
                }
            }
        }

        class UInt8 extends codebase.datatypes.base
        {
            __New(n := 0)
            {
                this.v := n & this.max_value
            }

            signed := false
            width := 8

            min_value := (this.signed ? - (2 ** this.width) : 0)
            max_value := (this.signed ? 2 ** (this.width - 1) - 1 : 2 ** this.width - 1)
        }

        class Int8 extends codebase.datatypes.base
        {
            __New(n := 0)
            {
                this.v := n & this.max_value
            }

            signed := true
            width := 8

            min_value := (this.signed ? - (2 ** this.width) : 0)
            max_value := (this.signed ? 2 ** (this.width - 1) - 1 : 2 ** this.width - 1)
        }

        class UInt16 extends codebase.datatypes.base
        {
            __New(n := 0)
            {
                this.v := n & this.max_value
            }

            signed := false
            width := 16

            max_value := (this.signed ? 2 ** (this.width - 1) - 1 : 2 ** this.width - 1)
            min_value := (this.signed ? -(this.max_value) - 1 : 0)
        }

        class Int16 extends codebase.datatypes.base
        {
            __New(n := 0)
            {
                this.v := n & this.max_value
            }

            signed := true
            width := 16

            max_value := (this.signed ? 2 ** (this.width - 1) - 1 : 2 ** this.width - 1)
            min_value := (this.signed ? -(this.max_value) - 1 : 0)
        }

        class UInt32 extends codebase.datatypes.base
        {
            __New(n := 0)
            {
                this.v := n & this.max_value
            }

            signed := false
            width := 32

            max_value := (this.signed ? 2 ** (this.width - 1) - 1 : 2 ** this.width - 1)
            min_value := (this.signed ? -(this.max_value) - 1 : 0)
        }

        class Int32 extends codebase.datatypes.base
        {
            __New(n := 0)
            {
                this.v := n & this.max_value
            }

            signed := true
            width := 32

            max_value := (this.signed ? 2 ** (this.width - 1) - 1 : 2 ** this.width - 1)
            min_value := (this.signed ? -(this.max_value) - 1 : 0)
        }

        class UInt64
        {
            __New(n := 0)
            {
                this.v := n & this.max_value
            }

            signed := false
            width := 64

            ; AHKv2 cannot represent this and returns -1
            max_value := (this.signed ? 2 ** (this.width - 1) - 1 : 2 ** this.width - 1)
            min_value := (this.signed ? -(this.max_value) - 1 : 0)
        }

        class Int64 extends codebase.datatypes.base
        {
            __New(n := 0)
            {
                this.v := n & this.max_value
            }

            signed := true
            width := 64

            max_value := (this.signed ? 2 ** (this.width - 1) - 1 : 2 ** this.width - 1)
            min_value := (this.signed ? -(this.max_value) - 1 : 0)
        }
    }
}