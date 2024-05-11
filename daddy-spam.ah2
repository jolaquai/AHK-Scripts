; Import the codebase library to allow calls to some often-needed functions and more
#Include #Includes\ahk-codebase.ahk

/**
 * A `Rapidvar` is basically just a glorified Integer "type" with a custom maximum value instead of it being dictated by the amount of bits used to store a number. Its _current_ value's intended use is to influence the behavior of a game's hotkeys.
 *
 * The name `Rapidvar` is a reference to "rapid firing" semi-automatic guns by making a game hotkey spam the left mouse button only if that game's `Rapidvar` is equal to some value, which is the entire reason I created `Rapidvar`s. Despite this, I've since found other use cases, such as creating a "single fire" mode for any weapon. Its uses beyond as a toggle switch for specific hotkey behaviors are rather limited.
 * @note While every `Rapidvar` has a maximum value defined at instantiation, it is not guaranteed that its current value is within the range `[0, Rapidvar.max]` as the `set` method does not enforce the limit to allow for temporary values. This also avoids having to cycle between all _possible_ values of a `Rapidvar` to achieve a specific state. To ensure the current value stays within that range, either call the `inc` or `dec` methods, or use `safeset`.
 */
class Rapidvar
{
    x := 10
    y := 20

    /**
     * Instantiate a `Rapidvar`.
     * @param shorthand A short identifier to identify this `Rapidvar` with.
     * @param max The maximum value to allow the `Rapidvar` to assume. Defaults to `1` if omitted.
     * @param po Whether to place the tooltip at prespecified coordinates (which would preferably be outside of the target window to prevent issues such as _Borderless Windowed_ mode windows covering the tooltip).
     * @returns `Rapidvar`
     */
    __New(shorthand, max := 1, po := false)
    {
        this.value := 0
        this.max := max
        this.name := shorthand . "rapid"
        this.ttp := (po ? codebase.Tool.coords : codebase.Tool.center)
    }

    /**
     * Set the current value of the `Rapidvar` regardless of the configured maximum value.
     * @param value The value to set the `Rapidvar` to.
     * @returns The new value of the `Rapidvar`.
     */
    set(value)
    {
        this.value := value
        return this.value
    }

    /**
     * Safely set the current value of the `Rapidvar`, ensuring that it stays within the range `[0, Rapidvar.max]`.
     * @param value The potential value to set the `Rapidvar` to. Negative values are ignored and the absolute value is used instead.
     * @returns The new value of the `Rapidvar`. May not be equal to `value`.
     */
    safeset(value) => this.set(Abs(Mod(Abs(value), this.max + 1)))

    /**
     * Check whether the `Rapidvar`'s current value is equal to a specific value or at least one of a series of values.
     * @param anyof Any number of numerical values to check against.
     * @note If no arguments are passed, the current value of the `Rapidvar` is returned. Equivalent to calling this method and passing all values in the range `[1, Rapidvar.max]`.
     * @returns `true` if the `Rapidvar`'s value is equal to any of the passed values, `false` otherwise.
     */
    check(anyof*)
    {
        if (!(anyof.Length))
        {
            return this.value
        }

        for v in anyof
        {
            if (this.value == v)
            {
                return true
            }
        }
        return false
    }

    /**
     * Get the current value of the `Rapidvar`.
     * @returns The current value of the `Rapidvar`.
     */
    get() => this.value

    /**
     * Increase the current value of the `Rapidvar`.
     * @returns The new value of the `Rapidvar`.
     */
    inc() => this.set(Abs(Mod(Abs(this.value + 1), this.max + 1)))

    /**
     * Decrease the current value of the `Rapidvar`.
     * @returns The new value of the `Rapidvar`.
     */
    dec() => this.value - 1 < 0 ? this.set(this.getMax()) : this.set(this.value - 1)

    /**
     * Get the maximum value of the `Rapidvar`.
     * @returns The maximum value of the `Rapidvar`.
     */
    getMax() => this.max

    /**
     * Set the new maximum value of the `Rapidvar`.
     * @param value The new maximum.
     * @returns The new maximum value of the `Rapidvar`.
     */
    setMax(value) => this.max := value
}

siegerapid := Rapidvar("siege", , true)

; Siege
#HotIf WinActive("ahk_exe RainbowSix.exe")

    +b::siegerapid.inc()

    ~*RButton::
    mouse_override(*)
    {
        Loop
        {
            if (GetKeyState("RButton", "P"))
            {
                if (GetKeyState("LButton", "P"))
                {
                    if (siegerapid.check(1))
                    {
                        Send("{Blind}{Click}")
                        Sleep(10)
                    }
                    else if (siegerapid.check(2))
                    {
                        Send("{Blind}{LButton down}")
                        Sleep(100)
                        Send("{Blind}{LButton up}")
                        Sleep(200)
                    }
                }
            }
            else
            {
                break
            }
        }
    }