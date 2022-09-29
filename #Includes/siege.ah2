/**
 * This script is my "rainbowedit" Google Sheets Spreadsheet (https://docs.google.com/spreadsheets/d/1BmvpCvjGQJ4FyqPY-hZDXP673PMx5YotaUIiUDLgxm4/edit?usp=sharing), improved and expanded upon. Importing it allows access to information about Rainbow Six Siege's Operators, their loadouts with all statistics and more.
 *
 * To check for an Operator's properties, use standard comparison operators and bitwise-and `&` and bitwise-or `|`. For example, if a `siege.Operator` (object) is stored in `op`...
 * - ...can a Hard Breach Charge _or_ a Breach Charge be chosen with this Operator? `op.gadgets & (siege.Weapon.gadgets.hardbreachcharge | siege.Weapon.gadgets.breachcharge)`
 *
 * To check for an Operator's weapons' properties, use bitwise-and `&` and bitwise-or `|`. For example, if a `siege.Weapon` (object) is stored in `prim`...
 * - ...can a 2.5x or Russian 2 sight be equipped? `prim.sights & (siege.Weapon.sights.x25max | siege.Weapon.sights.x2max)`
 * - ...is this weapon _not_ a slug shotgun _or_ a light machine gun? `prim.type & ~(siege.Weapon.types.shotgunSlug | siege.Weapon.types.lightmachinegun)`
 */
notes := ""

#Include ahk-codebase.ah2

class siege
{
    /**
     * The `list` Arrays from the `siege.attackers` and `siege.defenders` subclasses concatenated into one in that order to allow for easier looping.
     */
    static atkdef := codebase.collectionOperations.arrayOperations.arrayConcat(siege.attackers.list, siege.defenders.list)
    /**
     * The `list` Arrays from the `siege.defenders` and `siege.attackers` subclasses concatenated into one in that order to allow for easier looping.
     */
    static defatk := codebase.collectionOperations.arrayOperations.arrayConcat(siege.defenders.list, siege.attackers.list)

    class misc
    {
        /**
         * Extracted from a 60 fps video, these timestamps identify what happens exactly when in the process of a grenade throw in seconds.
         */
        static grenadeTimestampsSeconds := {
            keypress: 0.000,
            grenadeFullyOut: 0.467,
            leverDisconnected: 0.600,
            crosshairFlash_01: 1.100,
            crosshairFlash_02: 1.600,
            crosshairFlash_03: 2.100,
            crosshairFlash_04: 2.534,
            crosshairFlash_05: 2.834,
            crosshairFlash_06: 3.100,
            crosshairFlash_07: 3.400,
            crosshairFlash_08: 3.600,
            crosshairFlash_09: 3.700,
            crosshairFlash_10: 3.767,
            crosshairFlash_11: 3.867,
            crosshairFlash_12: 3.934,
            crosshairFlash_13: 3.967,
            crosshairFlash_14: 4.000,
            crosshairStopsFlashing: 4.034,
            explosion: 4.300,
            damageIsDealt: 4.334
        }

        /**
         * Extracted from a 60 fps video, these timestamps identify what happens exactly when in the process of a grenade throw in frames.
         */
        static grenadeTimestampsFrames := {
            keypress: Integer(siege.misc.grenadeTimestampsSeconds.keypress * 60),
            grenadeFullyOut: Integer(siege.misc.grenadeTimestampsSeconds.grenadeFullyOut * 60),
            leverDisconnected: Integer(siege.misc.grenadeTimestampsSeconds.leverDisconnected * 60),
            crosshairFlash_01: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_01 * 60),
            crosshairFlash_02: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_02 * 60),
            crosshairFlash_03: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_03 * 60),
            crosshairFlash_04: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_04 * 60),
            crosshairFlash_05: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_05 * 60),
            crosshairFlash_06: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_06 * 60),
            crosshairFlash_07: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_07 * 60),
            crosshairFlash_08: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_08 * 60),
            crosshairFlash_09: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_09 * 60),
            crosshairFlash_10: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_10 * 60),
            crosshairFlash_11: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_11 * 60),
            crosshairFlash_12: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_12 * 60),
            crosshairFlash_13: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_13 * 60),
            crosshairFlash_14: Integer(siege.misc.grenadeTimestampsSeconds.crosshairFlash_14 * 60),
            crosshairStopsFlashing: Integer(siege.misc.grenadeTimestampsSeconds.crosshairStopsFlashing * 60),
            explosion: Integer(siege.misc.grenadeTimestampsSeconds.explosion * 60),
            damageIsDealt: Integer(siege.misc.grenadeTimestampsSeconds.damageIsDealt * 60)
        }

        /**
         * The Operator with the longest nickname in-game.
         */
        static longestOperatorNick := { }

        /**
         * The longest weapon name in-game.
         */
        static longestWeaponName := ""
        
        /*
         * Has no value. Exists to call the function `siege.misc._init()` which populates the following static fields:
         * - `siege.misc.longestOperatorNick`
         * - `siege.misc.longestWeaponName`
         */
        static init := siege.misc._init()
        static _init()
        {
            lName := 0
            lWep := 0

            for op in siege.atkdef
            {
                if (StrLen(op.nickname) > lName)
                {
                    lName := StrLen(op.nickname)
                    siege.misc.longestOperatorNick := op
                }

                for w in codebase.collectionOperations.arrayOperations.arrayConcat(op.primaries, op.secondaries)
                {
                    if (StrLen(w.name) > lWep)
                    {
                        lWep := StrLen(w.name)
                        siege.misc.longestWeaponName := w.name
                    }
                }
            }
        }
        
    }

    class Operator
    {
        /**
         * The Operator's nickname in-game.
         */
        nickname := ""
        /**
         * An Array of `siege.Weapon` objects, identifying the Operator's primary weapons.
         */
        primaries := ""
        /**
         * An Array of `siege.Weapon` objects, identifying the Operator's secondary weapons.
         */
        secondaries := ""
        /**
         * The sum of a series of `siege.Weapon.gadgets` values, identifying the Operator's gadgets.
         */
        gadgets := ""
        /**
         * The name of the Operator's special ability.
         */
        special := ""
        /**
         * The Operator's organization in-game.
         */
        organization := ""
        /**
         * The Operator's birthplace in-game.
         */
        birthplace := ""
        /**
         * The Operator's height in centimeters.
         */
        height := ""
        /**
         * The Operator's weight in kilograms.
         */
        weight := ""
        /**
         * The Operator's real name in-game.
         */
        realname := ""
        /**
         * An object defined in the pattern `{ month: n, day: m, age: x }` to identify the Operator's age data.
         *
         * - This is `{ month: -1, day: -1, age: -1 }` if the Operator's age is [REDACTED], i.e. for Nøkk.
         */
        age := ""
        /**
         * The Operator's Speed value in-game. Their Health value is automatically deduced from this (`this.health := 4 - this.speed`).
         */
        speed := ""
        /**
         * The Operator's Health value in-game. It is automatically deduced from their Speed value (`this.health := 4 - this.speed`).
         */
        health := ""
        /**
         * The amount of HP the Operator has as a result of their Speed/Health values in-game.
         */
        hp := ""

        /**
        * Instantiate a new `Operator` object.
        * @param nickname The Operator's nickname in-game.
        * @param primaries An Array of `Weapon` objects, identifying the Operator's primary weapons.
        * @param secondaries An Array of `Weapon` objects, identifying the Operator's secondary weapons.
        * @param gadgets The sum of a series of `siege.Weapon.gadgets` values, identifying the Operator's gadgets.
        * @param special The name of the Operator's special ability.
        * @param organization The Operator's organization in-game.
        * @param birthplace The Operator's birthplace in-game.
        * @param height The Operator's height in centimeters.
        * @param weight The Operator's weight in kilograms.
        * @param realname The Operator's real name in-game.
        * @param age An object defined in the pattern `{ month: n, day: m, age: x }` to identify the Operator's age data.
        * @param speed The Operator's Speed value in-game. Their Health value is automatically deduced from this (`this.health := 4 - this.speed`).
        * @returns An `Operator` object.
        */
        __New(nickname, primaries, secondaries, gadgets, special, organization, birthplace, height, weight, realname, age, speed)
        {
            this.nickname := nickname
            this.primaries := primaries
            this.secondaries := secondaries
            this.gadgets := gadgets
            this.special := special
            this.organization := organization
            this.birthplace := birthplace
            this.height := height
            this.weight := weight
            this.realname := realname
            this.age := age
            this.speed := speed
            this.health := 4 - this.speed
            this.hp := 100 + (10 * (this.health - 1))
        }

        /**
         * Chooses a random combination of this Operator's primaries, secondaries and gadgets and compiles the result into an object.
         * @param stringOutput Whether to return a string identifying the generated loadout instead of an object with that same data. Defaults to `false` if omitted.
         * @returns An object identifying the generated loadout if `stringOutput` is falsey.
         * @returns A string identifying the generated loadout if `stringOutput` is truthy.
         */
        randomizeLoadout(stringOutput := false)
        {
            prim := this.primaries[Random(1, this.primaries.Length)]
            sec := ((s := this.secondaries[Random(1, this.secondaries.Length)]) !== "" ? s : "None")
            
            gdg := []
            for i in codebase.range(1, siege.Weapon.gadgets.listName.Length)
            {
                n := siege.Weapon.gadgets.listName[i]
                v := siege.Weapon.gadgets.listValue[i]

                if (this.gadgets & v)
                {
                    gdg.Push(n)
                }
            }
            gdg := ((s := gdg[Random(1, gdg.Length)]) !== "" ? s : "None")

            primbarrel := []
            for i in codebase.range(1, siege.Weapon.barrels.listName.Length)
            {
                n := siege.Weapon.barrels.listName[i]
                v := siege.Weapon.barrels.listValue[i]

                if (prim.barrels & v)
                {
                    primbarrel.Push(n)
                }
            }
            primbarrel := (primbarrel.Length ? primbarrel[Random(1, primbarrel.Length)] : "—")

            primsight := []
            sval := Integer(prim.sights)
            for i in codebase.range(1, siege.Weapon.sights.listName.Length)
            {
                n := siege.Weapon.sights.listName[i]
                v := siege.Weapon.sights.listValue[i]

                if (sval & v)
                {
                    sval := sval & ~v
                    primsight.Push(n)
                }
                if (sval == 0)
                {
                    break
                }
            }
            primsight := (primsight.Length ? primsight[Random(1, primsight.Length)] : "—")
            switch (primsight)
            {
                case "Non-magnifying":
                    primsight := siege.Weapon.sights.nonmags[Random(1, siege.Weapon.sights.nonmags.Length)]
                case "2.5x":
                    primsight := siege.Weapon.sights.x25s[Random(1, siege.Weapon.sights.x25s.Length)]
            }

            primgrip := []
            for i in codebase.range(1, siege.Weapon.grips.listName.Length)
            {
                n := siege.Weapon.grips.listName[i]
                v := siege.Weapon.grips.listValue[i]

                if (prim.grips & v)
                {
                    primgrip.Push(n)
                }
            }
            primgrip := (primgrip.Length ? primgrip[Random(1, primgrip.Length)] : "—")
            
            secbarrel := []
            for i in codebase.range(1, siege.Weapon.barrels.listName.Length)
            {
                n := siege.Weapon.barrels.listName[i]
                v := siege.Weapon.barrels.listValue[i]

                if (sec.barrels & v)
                {
                    secbarrel.Push(n)
                }
            }
            secbarrel := (secbarrel.Length ? secbarrel[Random(1, secbarrel.Length)] : "—")

            tp := ""
            ts := ""
            for i in codebase.range(1, siege.Weapon.types.listName.Length)
            {
                n := siege.Weapon.types.listName[i]
                v := siege.Weapon.types.listValue[i]
                
                if (prim.type & v)
                {
                    tp := n
                }
                if (sec.type & v)
                {
                    ts := n
                }
            }

            if (stringOutput)
            {
                return "`nPrimary: " . prim.name
                    . "`nPrimary Type: " . tp
                    . "`nPrimary Sight: " . primsight
                    . "`nPrimary Barrel: " . primbarrel
                    . "`nPrimary Grip: " . primgrip
                    . "`nPrimary Laser: " . (prim.underbarrel ? (Random(0, 1) ? "Yes" : "No") : "—")
                    . "`nSecondary: " . this.secondaries[Random(1, this.secondaries.Length)].name
                    . "`nSecondary Type: " . ts
                    . "`nSecondary Barrel: " . secbarrel
                    . "`nSecondary Laser: " . (sec.underbarrel ? (Random(0, 1) ? "Yes" : "No") : "—")
                    . "`nGadget: " . gdg
            }
            else
            {
                return {
                    primary: {
                        name: prim.name,
                        type: tp,
                        sight: primsight,
                        barrel: primbarrel,
                        grip: primgrip,
                        laser: prim.underbarrel ? (Random(0, 1) ? "Yes" : "No") : "—"
                    },
                    secondary: {
                        name: sec.name,
                        type: ts,
                        barrel: secbarrel,
                        laser: sec.underbarrel ? (Random(0, 1) ? "Yes" : "No") : "—"
                    },
                    gadget: gdg
                }
            }
        }
    }

    /**
     * A class to hold information about a single weapon in the game.
     *
     * This is never universal among all Operators using one specific weapon.
     */
    class Weapon
    {
        /**
         * This multiplier is applied to a weapon's base damage when equipping a suppressor on it. This is not defined anywhere and resulted from averaging the ratios from all weapons a suppressor can be equipped on (`suppressed_dmg / dmg`). Typically, using `0.84` yields a close enough approximate.
         *
         * ~It is also unknown whether the resulting float is rounded up or down, but as far as the evidence I have suggests, it's rounded up.~
         *
         * Further testing has shown that the calculated suppressed damage value is _not_ always rounded up, but instead rounded to the nearest integer.
         *
         * As of Y7S3, the suppressor's damage reduction has been removed. As such, the multiplier applied to damage when calculating suppressed damage is `1`. For compatibility reasons, a `Weapon` object's `suppresseddamage` OwnProp remains and its value is still calculated.
         */
        static suppressedDamageMultiplier := 1 ; 0.837697879481015

        class types
        {
            /**
             * Identifies the Assault Rifle weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static assaultrifle := codebase.Binary("0000000001").Value()
            /**
             * Identifies the Handgun weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static handgun := codebase.Binary("0000000010").Value()
            /**
             * Identifies the Light Machine Gun weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static lightmachinegun := codebase.Binary("0000000100").Value()
            /**
             * Identifies the Machine Pistol weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static machinepistol := codebase.Binary("0000001000").Value()
            /**
             * Identifies the Marksman Rifle weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static marksmanrifle := codebase.Binary("0000010000").Value()
            /**
             * Identifies the Shield weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static shield := codebase.Binary("0000100000").Value()
            /**
             * Identifies the Shotgun weapon type generally. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             *
             * @note This flag is not used to identify any shotgun in this library. It is merely supposed to be a user-friendly shortcut to allow for easier filtering of weapons, i.e. `siege.Weapon.types.shotgun` instead of `siege.Weapon.types.shotgunSlug | siege.Weapon.types.shotgunShot`, as they are handled the same in-game (e.g. the specific type of shotgun doesn't matter for shotgun kill challenges).
             */
            static shotgun := codebase.Binary("0011000000").Value()
            /**
             * Identifies the Shotgun (slug ammo) weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static shotgunSlug := codebase.Binary("0001000000").Value()
            /**
             * Identifies the Shotgun (shot / pellet) weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static shotgunShot := codebase.Binary("0010000000").Value()
            /**
             * Identifies the Submachine Gun weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static submachinegun := codebase.Binary("0100000000").Value()
            /**
             * Identifies the Hand Cannon weapon type (which currently uniquely identifies the "GONNE-6"). Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static handcannon := codebase.Binary("1000000000").Value()

            static listName := [
                "Assault Rifle",
                "Handgun",
                "Light Machine Gun",
                "Machine Pistol",
                "Marksman Rifle",
                "Shield",
                "Slug Shotgun",
                "Shotgun",
                "Submachine Gun",
                "Hand Cannon"
            ]
            static listValue := [
                siege.Weapon.types.assaultrifle,
                siege.Weapon.types.handgun,
                siege.Weapon.types.lightmachinegun,
                siege.Weapon.types.machinepistol,
                siege.Weapon.types.marksmanrifle,
                siege.Weapon.types.shield,
                siege.Weapon.types.shotgunSlug,
                siege.Weapon.types.shotgunShot,
                siege.Weapon.types.submachinegun,
                siege.Weapon.types.handcannon
            ]
        }

        class firingmodes
        {
            /**
             * Indicates that the weapon fires single-shot only. Use bitwise-and `&` to check whether a weapon's `firingmode` prop matches this flag.
             */
            static singleshot := codebase.Binary("01").Value()
            /**
             * Indicates that the weapon fires full auto only. Use bitwise-and `&` to check whether a weapon's `firingmode` prop matches this flag.
             */
            static fullauto := codebase.Binary("10").Value()

            static listName := [
                "Single Shot",
                "Full Auto"
            ]
            static listValue := [
                siege.Weapon.firingmodes.singleshot,
                siege.Weapon.firingmodes.fullauto
            ]
        }

        /**
         * As of Y7S1, _all_ weapons (excepting most secondaries and, for example, Glaz's "OTs-03" DMR, which does not have access to Reflex C) have access to _all_ non-magnifying scopes (Red Dot, Holo, Reflex), or more precisely, _all_ of their variants (no matter if standard, Russian, alternate etc.). Because of this, I've decided to combine them into the option `nonmagmax`. Checking for magnifying scopes still works as before.
         *
         * However, as mentioned above, exceptions such as Glaz's "OTs-03" DMR, which cannot be equipped with Reflex C, are not (yet?) handled differently.
         *
         * Additionally, since there are two 2.5x scope variants, the two options `x25max` and `rux25` have also been combined into the option `x25max`.
         *
         * As of Y7S3, all weapons that have access to scopes of a specific magnification level now automatically have access to all magnifications levels _up to_ that level. This does not apply to Kali's "CSRX 300". Because of this, most of the `sights` flags have been redefined to act as maximums (if bitwise-and comparison of a `Weapon` object's `sights` flag with `siege.Weapon.sights.x25` yields a truthy value, bitwise-and comparison with all lower sight flags also yields a truthy value).
         *
         * I also found a way to correct my logic with these flags. For example, the randomizer now no longer selects incorrect (as in, non-existant) sight options for any guns due to incorrect bitwise-and comparisons, which incorrectly assumed
         * - the earlier default behavior of not automatically including all lower magnification options when a `Weapon` had the `siege.Weapon.sights.x2max` flag set
         * - the first matching sight option (i.e. almost always 3x, because that flag includes _and therefore matches all others down to `siege.Weapon.sights.nonmagmax` with bitwise-and comparisons_) was the highest, even if that bit was not actually set to `1`.
         *
         * There is, however, some side effects to the new sight logic, how it's implemented and most importantly to the way comparisons must now be done:
         * - Instead of comparing `siege.Weapon.sights` props with the `max` flags (such as `siege.Weapon.sights.x15max`), _continue_ to do bitwise-and comparisons with the previous flags (such as `siege.Weapon.sights.x15`). This is simply intended to bring back the quick-and-easy check "do dis gun has 2.5x" that would not have been easily possible using the new sight system.
         * - The `list` props of the classes `siege.Weapon.types`, `siege.Weapon.firingmodes`, `siege.Weapon.sights`, `siege.Weapon.barrels`, `siege.Weapon.grips`, and `siege.Weapon.gadgets` had to be split into two Arrays instead of a Map relating a name to a value. The Arrays were created directly from the Map, meaning they are guaranteed to be the same length and they are type-safe (the `listName` Arrays only contain strings, the `listValue` Arrays only contain `codebase.Binary` values, i.e. integers). For manual checks or other interaction with a `Weapon` object, instead of a `for`-loop introduction like `for n, v in siege.Weapon.sights.list`, you'll now have to do something similar to what is done in `siege.Operator.randomizeLoadout`: use a`for`-loop like
         `for i in codebase.range(1, siege.Weapon.gadgets.listName.Length)` and access the lists within the loop body using `i`.
         */
        class sights
        {
            /**
             * Indicates that some other sight properties are going on with the weapon (e.g. Red Dot only on "P10-C", custom Reflex only on "DP27"). Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static other := codebase.Binary("0000001").Value()
            /**
             * Indicates that all non-magnifying scope variants can be or one of them is forcefully equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static nonmagmax := codebase.Binary("0000010").Value()
            static nonmags := ["Red Dot A", "Red Dot B", "Red Dot C", "Holo A", "Holo B", "Holo C", "Holo D", "Reflex B", "Reflex A", "Reflex C"]
            static nonmag := codebase.Binary("0000010").Value()
            /**
             * Indicates that the 1.5x sight can be or is forcefully equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static x15max := codebase.Binary("0000110").Value()
            static x15 := codebase.Binary("0000100").Value()
            /**
             * Indicates that the 2x sight can be or is forcefully equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static x2max := codebase.Binary("0001110").Value()
            static x2 := codebase.Binary("0001000").Value()
            /**
             * Indicates that the 2.5x sight can be or is forcefully equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static x25max := codebase.Binary("0011110").Value()
            static x25s := ["2.5x A", "2.5x B"]
            static x25 := codebase.Binary("0010000").Value()
            /**
             * Indicates that the 3x sight can be or is forcefully equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static x3max := codebase.Binary("0111110").Value()
            static x3 := codebase.Binary("0100000").Value()
            /**
             * Indicates that the 6x and 12x sights are equipped on the weapon (this currently uniquely identifies Kali's "CSRX 300"). Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static x612 := codebase.Binary("1000000").Value()

            static listName := [
                "Other",
                "Non-magnifying",
                "1.5x",
                "2x",
                "2.5x",
                "3x",
                "6x/12x"
            ]
            static listValue := [
                siege.Weapon.sights.other,
                siege.Weapon.sights.nonmagmax,
                siege.Weapon.sights.x15max,
                siege.Weapon.sights.x2max,
                siege.Weapon.sights.x25max,
                siege.Weapon.sights.x3max,
                siege.Weapon.sights.x612
            ]
        }

        class barrels
        {
            /**
             * Indicates that a Suppressor can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `barrels` prop matches this flag.
             */
            static suppressor := codebase.Binary("00001").Value()
            /**
             * Indicates that a Flash Hider can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `barrels` prop matches this flag.
             */
            static flashhider := codebase.Binary("00010").Value()
            /**
             * Indicates that a Compensator can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `barrels` prop matches this flag.
             */
            static compensator := codebase.Binary("00100").Value()
            /**
             * Indicates that a Muzzle Brake can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `barrels` prop matches this flag.
             */
            static muzzlebrake := codebase.Binary("01000").Value()
            /**
             * Indicates that an Extended Barrel can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `barrels` prop matches this flag.
             */
            static extendedbarrel := codebase.Binary("10000").Value()

            static listName := [
                "Suppressor",
                "Flash Hider",
                "Compensator",
                "Muzzle Brake",
                "Extended Barrel"
            ]
            static listValue := [
                siege.Weapon.barrels.suppressor,
                siege.Weapon.barrels.flashhider,
                siege.Weapon.barrels.compensator,
                siege.Weapon.barrels.muzzlebrake,
                siege.Weapon.barrels.extendedbarrel
            ]
        }

        class grips
        {
            /**
             * Indicates that a Vertical Grip can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `grips` prop matches this flag.
             */
            static verticalgrip := codebase.Binary("01").Value()
             /**
              * Indicates that an Extended Barrel can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `grips` prop matches this flag.
              */
            static angledgrip := codebase.Binary("10").Value()

            static listName := [
                "Vertical Grip",
                "Angled Grip"
            ]
            static listValue := [
                siege.Weapon.grips.verticalgrip,
                siege.Weapon.grips.angledgrip
            ]
        }

        class gadgets
        {
            /**
             * Indicates that a Frag Grenade can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static fraggrenade := codebase.Binary("0000000000001").Value()
            /**
             * Indicates that a Breach Charge can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static breachcharge := codebase.Binary("0000000000010").Value()
            /**
             * Indicates that a Claymore can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static claymore := codebase.Binary("0000000000100").Value()
            /**
             * Indicates that a Hard Breach Charge can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static hardbreachcharge := codebase.Binary("0000000001000").Value()
            /**
             * Indicates that a Smoke Grenade can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static smokegrenade := codebase.Binary("0000000010000").Value()
            /**
             * Indicates that a Stun Grenade can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static stungrenade := codebase.Binary("0000000100000").Value()
            
            /**
             * Indicates that Barbed Wire can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static barbedwire := codebase.Binary("0000001000000").Value()
            /**
             * Indicates that a Deployable Shield can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static deployableshield := codebase.Binary("0000010000000").Value()
            /**
             * Indicates that a Nitro Cell can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static nitrocell := codebase.Binary("0000100000000").Value()
            /**
             * Indicates that a Bulletproof Camera can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static bulletproofcamera := codebase.Binary("0001000000000").Value()
            /**
             * Indicates that a Proximity Alarm can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static proximityalarm := codebase.Binary("0010000000000").Value()
            /**
             * Indicates that an Impact Grenade can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static impactgrenade := codebase.Binary("0100000000000").Value()
            /**
             * Indicates that an EMP Impact Grenade can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static empgrenade := codebase.Binary("1000000000000").Value()

            static listName := [
                "Frag Grenade",
                "Breach Charge",
                "Claymore",
                "Hard Breach Charge",
                "Smoke Grenade",
                "Stun Grenade",
                "Barbed Wire",
                "Deployable Shield",
                "Nitro Cell",
                "Bulletproof Camera",
                "Proximity Alarm",
                "Impact Grenade",
                "EMP Impact Grenade"
            ]
            static listValue := [
                 siege.Weapon.gadgets.fraggrenade,
                 siege.Weapon.gadgets.breachcharge,
                 siege.Weapon.gadgets.claymore,
                 siege.Weapon.gadgets.hardbreachcharge,
                 siege.Weapon.gadgets.smokegrenade,
                 siege.Weapon.gadgets.stungrenade,
                 siege.Weapon.gadgets.barbedwire,
                 siege.Weapon.gadgets.deployableshield,
                 siege.Weapon.gadgets.nitrocell,
                 siege.Weapon.gadgets.bulletproofcamera,
                 siege.Weapon.gadgets.proximityalarm,
                 siege.Weapon.gadgets.impactgrenade,
                 siege.Weapon.gadgets.empgrenade
            ]
        }

        /**
         * The name of the weapon in-game.
         */
        name := ""
        /**
         * The value of a `codebase.Binary` object to indicate which type of weapon it is.
         * @note Inconsistencies like with Maverick's "AR-15.50" (which, in reality, is a so-called "Home Defense Rifle", not an "Assault Rifle" or "Marksman Rifle", despite what the game calls it) should not be and are not corrected.
         */
        type := ""
        /**
         * The value of a `codebase.Binary` object to indicate the firing mode the weapon possesses.
         *
         * - This is `0` for Shields.
         */
        firingmode := ""
        /**
         * The damage of the weapon.
         *
         * - This is `5` for Clash's "CCE Chield".
         * - This is `0` for all other Shields.
         */
        damage := ""
        /**
         * How many rounds per minute the weapon fires.
         *
         * - This is `20` for Clash's "CCE Chield".
         * - This is `0` for all other Shields.
         * - This is `0` for the "GONNE-6".
         */
        rpm := ""
        /**
         * How many rounds the weapon can fire before having to reload. This should _not_ include the extra round in the chamber after cocking the gun.
         *
         * - This is `4` for Clash's "CCE Chield".
         * - This is `0` for all other Shields.
         * - This is `1` for the "GONNE-6".
         */
        capacity := ""
        /**
         * The values of one or more `codebase.Binary` objects summed up to indicate which sights can be equipped on the weapon.
         *
         * - This is `0` for Shields.
         * - This is `0` for the "GONNE-6".
         * - This is `0` for all weapons which do not have scopes available.
         */
        sights := ""
        /**
         * The values of one or more `codebase.Binary` objects summed up to indicate which barrels / barrel extensions can be equipped on the weapon.
         *
         * - This is `0` for Shields.
         * - This is `0` for the "GONNE-6".
         */
        barrels := ""
        /**
         * The values of one or more `codebase.Binary` objects summed up to indicate which grips can be equipped on the weapon.
         *
         * - This is `0` for Shields.
         * - This is `0` for the "GONNE-6".
         */
        grips := ""
        /**
         * Whether the weapon has an underbarrel slot (i.e. a laser can be equipped).
         *
         * - This is `0` for Shields.
         * - This is `0` for the "GONNE-6".
         */
        underbarrel := ""
        /**
         * The damage of the weapon with a Suppressor equipped on it.
         *
         * - This is `0` for Shields.
         * - This is `0` if the weapon cannot be equipped with a Suppressor.
         */
        suppresseddamage := ""
        /**
         * The amount of damage per second the weapon can deal, considering magazine capacity, fire rate and reload time.
         * @note While also easily calculable using `damage * (rpm / 60)`, this desperately needed an overhaul due to that formula ranking the "BOSG.12.2" as the most powerful gun in the game dps-wise. I think we all agree that that's not true in all aspects.
         * @note This is calculated using a weapon's `capacity` and `reloadTactical` props. For example, if `capacity` is `30`, it is assumed that the last of the actual `30 + 1` rounds is left in the chamber to allow continuous tactical reloads.
         *
         * - This is `0` for Shields.
         */
        dps := ""
        /**
         * How long it takes to reload the gun when there is a round chambered, i.e. the bolt does not have to be pulled before the gun is ready to fire.
         * @note This has been timed from recorded 60-fps clips in-game. Timings are accurate to 60 milliseconds.
         * - Timing start explanation (tactical reload): Pressing the Reload button causes the background of the highlighted (equipped) weapon at the bottom-right to turn slightly transparent. Timing starts on the first frame where this is the case.
         * - Timing start explanation (forced reload on last round expended): See timing for tactical reloads. Used only when capturing footage of Clash's P-10C (for which I could've also used Warden, yes, but I honestly didn't think that far, it's 11 pm, give me a break).
         * - Timing start explanation (empty reload): Switching to the weapon also switches the highlighted (equipped) weapon at the bottom right. The new weapon's background begins turning white (and slightly transparent for the reason mentioned above) on the same frame on which the reload animation starts (except when switching from Clash's CCE Shield). Timing starts on the first frame where this is the case.
         * - Timing end explanation: In every instance, timing ends on the first frame AFTER the reload has been completed, i.e. when the ammo count has been reflecting the completed reload for one frame.
         *
         * - This is `0` for Shields.
         * - This is `0` for the "GONNE-6".
         * - For Shotguns that are not magazine-fed, this assumes one shell remaining in the breech.
         * - For Shotguns that are magazine-fed, this is usually the same as `reloadEmpty`.
         * - For Machine Guns that are belt-fed, this is _usually_ the same as `reloadEmpty`.
         */
        reloadTactical := ""
        /**
         * How long it takes to reload the gun when no round is chambered, i.e. the bolt has to be pulled before the gun is ready to fire.
         *
         * - This is `0` for Shields.
         * - This is `0` for the "GONNE-6".
         * - For Shotguns that are magazine-fed, this is usually the same as `reloadTactical`.
         * - For Machine Guns that are belt-fed, this is _usually_ the same as `reloadTactical`.
         */
        reloadEmpty := ""

        /**
         * Instantiate a new `Weapon` object.
         * @param name The name of the weapon in-game.
         * @param type The value of a `codebase.Binary` object to indicate which type of weapon it is.
         * @param firingmode The value of a `codebase.Binary` object to indicate the firing mode the weapon possesses.
         * @param damage The damage of the weapon.
         * @param rpm How many rounds per minute the weapon fires.
         * @param capacity How many rounds the weapon can fire before having to reload. This should _not_ include the extra round in the chamber after cocking the gun.
         * @param sights The values of one or more `codebase.Binary` objects summed up to indicate which sights can be equipped on the weapon.
         * @param barrels The values of one or more `codebase.Binary` objects summed up to indicate which barrels / barrel extensions can be equipped on the weapon.
         * @param grips The values of one or more `codebase.Binary` objects summed up to indicate which grips can be equipped on the weapon.
         * @param underbarrel Whether the weapon has an underbarrel slot (i.e. a laser can be equipped).
         * @param reloadTactical How long it takes to reload the gun when there is a round chambered, i.e. the bolt does not have to be pulled before the gun is ready to fire. For shotguns that are not magazine-fed, this assumes one shell remaining in the breech.
         * @param reloadEmpty How long it takes to reload the gun when no round is chambered, i.e. the bolt has to be pulled before the gun is ready to fire.
         * @returns A `Weapon` object.
         */
        __New(name, type, firingmode, damage, rpm, capacity, sights, barrels, grips, underbarrel, reloadTactical, reloadEmpty)
        {
            this.name := name
            this.type := type
            this.firingmode := firingmode
            this.damage := damage
            this.rpm := rpm
            this.capacity := capacity
            this.sights := sights
            this.barrels := barrels
            this.grips := grips
            this.underbarrel := underbarrel
            this.suppresseddamage := Round(this.barrels & siege.Weapon.barrels.suppressor ? this.damage * siege.Weapon.suppressedDamageMultiplier : 0)
            this.reloadTactical := reloadTactical
            this.reloadEmpty := reloadEmpty
            if (this.type & ~(siege.Weapon.types.shield))
            {
                try this.dps := Round((this.damage * this.capacity) / ((this.reloadTactical / 1000) + (this.capacity / (this.rpm / 60))))
                catch
                {
                    this.dps := 0
                }
            }
        }
    }

    class attackers
    {
        static name := "Attackers"

        static sledge := siege.Operator(
            "Sledge",
            [
                siege.Weapon(
                    "M590A1",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    85,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(4030, 60),
                    codebase.math.roundMultiple(4510, 60)
                ),
                siege.Weapon(
                    "L85A2",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    47,
                    670,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1500, 60),
                    codebase.math.roundMultiple(2360, 60)
                )
            ],
            [
                siege.Weapon(
                    "P226 MK 25",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1430, 60)
                )
            ],
            siege.Weapon.gadgets.fraggrenade | siege.Weapon.gadgets.stungrenade | siege.Weapon.gadgets.empgrenade,
            'Tactical Breaching Hammer "The Caber"',
            "SAS",
            "John O'Groats, Scotland",
            192,
            95,
            "Seamus Cowden",
            { month: 4, day: 2, age: 35 },
            2
        )

        static thatcher := siege.Operator(
            "Thatcher",
            [
                siege.Weapon(
                    "AR33",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    41,
                    749,
                    25,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1250, 60),
                    codebase.math.roundMultiple(2310, 60)
                ),
                siege.Weapon(
                    "L85A2",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    47,
                    670,
                    30,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1500, 60),
                    codebase.math.roundMultiple(2360, 60)
                ),
                siege.Weapon(
                    "M590A1",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    85,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(4030, 60),
                    codebase.math.roundMultiple(4510, 60)
                )
            ],
            [
                siege.Weapon(
                    "P226 MK 25",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1430, 60)
                )
            ],
            siege.Weapon.gadgets.breachcharge | siege.Weapon.gadgets.claymore,
            "EG Mk 0-EMP Grenade",
            "SAS",
            "Bideford, England",
            180,
            72,
            "Mike Baker",
            { month: 6, day: 22, age: 56 },
            2
        )

        static ash := siege.Operator(
            "Ash",
            [
                siege.Weapon(
                    "G36C",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    38,
                    780,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2340, 60)
                ),
                siege.Weapon(
                    "R4-C",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    39,
                    860,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1330, 60),
                    codebase.math.roundMultiple(2200, 60)
                )
            ],
            [
                siege.Weapon(
                    "M45 Meusoc",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    58,
                    550,
                    7,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1100, 60),
                    codebase.math.roundMultiple(1300, 60)
                ),
                siege.Weapon(
                    "5.7 USG",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    550,
                    20,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1260, 60),
                    codebase.math.roundMultiple(1490, 60)
                )
            ],
            siege.Weapon.gadgets.breachcharge | siege.Weapon.gadgets.claymore,
            "M120 CREM Breaching Rounds",
            "FBI SWAT",
            "Jerusalem, Israel",
            170,
            63,
            "Eliza Cohen",
            { month: 12, day: 24, age: 33 },
            3
        )

        static thermite := siege.Operator(
            "Thermite",
            [
                siege.Weapon(
                    "M1014",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    34,
                    200,
                    8,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(4450, 60),
                    codebase.math.roundMultiple(5330, 60)
                ),
                siege.Weapon(
                    "556XI",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    47,
                    690,
                    30,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1460, 60),
                    codebase.math.roundMultiple(2410, 60)
                )
            ],
            [
                siege.Weapon(
                    "M45 Meusoc",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    58,
                    550,
                    7,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1100, 60),
                    codebase.math.roundMultiple(1300, 60)
                ),
                siege.Weapon(
                    "5.7 USG",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    550,
                    20,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1260, 60),
                    codebase.math.roundMultiple(1490, 60)
                )
            ],
            siege.Weapon.gadgets.smokegrenade | siege.Weapon.gadgets.stungrenade,
            "Brimstone BC-3 Exothermic Charges",
            "FBI SWAT",
            "Plano, Texas",
            178,
            80,
            "Jordan Trace",
            { month: 3, day: 14, age: 35 },
            2
        )

        static twitch := siege.Operator(
            "Twitch",
            [
                siege.Weapon(
                    "F2",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    37,
                    980,
                    25,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip,
                    true,
                    codebase.math.roundMultiple(1420, 60),
                    codebase.math.roundMultiple(2320, 60)
                ),
                siege.Weapon(
                    "417",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    69,
                    450,
                    20,
                    siege.Weapon.sights.x3max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1350, 60),
                    codebase.math.roundMultiple(2190, 60)
                ),
                siege.Weapon(
                    "SG-CQB",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    53,
                    85,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    siege.Weapon.grips.verticalgrip,
                    true,
                    codebase.math.roundMultiple(4090, 60),
                    codebase.math.roundMultiple(4580, 60)
                )
            ],
            [
                siege.Weapon(
                    "P9",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    45,
                    550,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1440, 60)
                ),
                siege.Weapon(
                    "LFP586",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    78,
                    550,
                    6,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(2540, 60),
                    codebase.math.roundMultiple(2540, 60)
                )
            ],
            siege.Weapon.gadgets.claymore | siege.Weapon.gadgets.smokegrenade,
            "RSD Model 1 - Shock Drone",
            "GIGN",
            "Nancy, France",
            168,
            58,
            "Emmanuelle Pichon",
            { month: 10, day: 12, age: 28 },
            2
        )

        static montagne := siege.Operator(
            "Montagne",
            [
                siege.Weapon(
                    "Le Roc",
                    siege.Weapon.types.shield,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                )
            ],
            [
                siege.Weapon(
                    "P9",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    45,
                    550,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1440, 60)
                ),
                siege.Weapon(
                    "LFP586",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    78,
                    550,
                    6,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(2540, 60),
                    codebase.math.roundMultiple(2540, 60)
                )
            ],
            siege.Weapon.gadgets.hardbreachcharge | siege.Weapon.gadgets.smokegrenade | siege.Weapon.gadgets.empgrenade,
            'Extendable Shield "Le Roc"',
            "GIGN",
            "Bordeaux, France",
            190,
            90,
            "Gilles Touré",
            { month: 10, day: 11, age: 48 },
            1
        )

        static glaz := siege.Operator(
            "Glaz",
            [
                siege.Weapon(
                    "OTs-03",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    71,
                    360,
                    10,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true,
                    codebase.math.roundMultiple(1430, 60),
                    codebase.math.roundMultiple(2440, 60)
                )
            ],
            [
                siege.Weapon(
                    "PMM",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    61,
                    550,
                    8,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(0590, 60),
                    codebase.math.roundMultiple(1280, 60)
                ),
                siege.Weapon(
                    "GONNE-6",
                    siege.Weapon.types.handcannon,
                    siege.Weapon.firingmodes.singleshot,
                    10,
                    0,
                    1,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                ),
                siege.Weapon(
                    "Bearing 9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    1100,
                    25,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    0,
                    true,
                    codebase.math.roundMultiple(1300, 60),
                    codebase.math.roundMultiple(2210, 60)
                )
            ],
            siege.Weapon.gadgets.smokegrenade | siege.Weapon.gadgets.fraggrenade | siege.Weapon.gadgets.claymore,
            "HDS Flip Sight OTs-03 MARKSMAN Rifle",
            "SPETSNAZ",
            "Vladivostok, Russia",
            178,
            79,
            "Timur Glazkov",
            { month: 7, day: 2, age: 30 },
            3
        )

        static fuze := siege.Operator(
            "Fuze",
            [
                siege.Weapon(
                    "Ballistic Shield",
                    siege.Weapon.types.shield,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                ),
                siege.Weapon(
                    "6P41",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    46,
                    680,
                    100,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(6580, 60),
                    codebase.math.roundMultiple(7160, 60)
                ),
                siege.Weapon(
                    "AK-12",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    45,
                    850,
                    30,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1430, 60),
                    codebase.math.roundMultiple(2260, 60)
                )
            ],
            [
                siege.Weapon(
                    "PMM",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    61,
                    550,
                    8,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(0590, 60),
                    codebase.math.roundMultiple(1280, 60)
                ),
                siege.Weapon(
                    "GSH-18",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    18,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1260, 60),
                    codebase.math.roundMultiple(1470, 60)
                )
            ],
            siege.Weapon.gadgets.breachcharge | siege.Weapon.gadgets.hardbreachcharge | siege.Weapon.gadgets.smokegrenade,
            'APM-6 Cluster Charge "Matryoshka"',
            "SPETSNAZ",
            "Samarkand, Uzbekistan",
            180,
            80,
            "Shuhrat Kessikbayev",
            { month: 10, day: 12, age: 34 },
            1
        )

        static blitz := siege.Operator(
            "Blitz",
            [
                siege.Weapon(
                    "G52-Tactical Shield",
                    siege.Weapon.types.shield,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                )
            ],
            [
                siege.Weapon(
                    "P12",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1230, 60),
                    codebase.math.roundMultiple(1560, 60)
                )
            ],
            siege.Weapon.gadgets.smokegrenade | siege.Weapon.gadgets.breachcharge,
            "G52-Tactical Light Shield",
            "GSG 9",
            "Bremen, Germany",
            175,
            75,
            "Elias Kötz",
            { month: 4, day: 2, age: 37 },
            2
        )

        static iq := siege.Operator(
            "IQ",
            [
                siege.Weapon(
                    "AUG A2",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    42,
                    720,
                    30,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    0,
                    true,
                    codebase.math.roundMultiple(1470, 60),
                    codebase.math.roundMultiple(2340, 60)
                ),
                siege.Weapon(
                    "552 Commando",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    48,
                    690,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1390, 60),
                    codebase.math.roundMultiple(2170, 60)
                ),
                siege.Weapon(
                    "G8A1",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    37,
                    850,
                    50,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(2120, 60),
                    codebase.math.roundMultiple(3220, 60)
                )
            ],
            [
                siege.Weapon(
                    "P12",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1230, 60),
                    codebase.math.roundMultiple(1560, 60)
                )
            ],
            siege.Weapon.gadgets.breachcharge | siege.Weapon.gadgets.claymore,
            'Electronics Detector RED Mk III "Spectre"',
            "GSG 9",
            "Leipzig, Germany",
            175,
            70,
            "Monika Weiss",
            { month: 8, day: 1, age: 38 },
            3
        )

        static buck := siege.Operator(
            "Buck",
            [
                siege.Weapon(
                    "C8-SFW",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    40,
                    837,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1370, 60),
                    codebase.math.roundMultiple(1540, 60)
                ),
                siege.Weapon(
                    "CAMRS",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    69,
                    450,
                    20,
                    siege.Weapon.sights.x3max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1460, 60),
                    codebase.math.roundMultiple(2290, 60)
                )
            ],
            [
                siege.Weapon(
                    "MK1 9mm",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    550,
                    13,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1110, 60),
                    codebase.math.roundMultiple(1320, 60)
                ),
                siege.Weapon(
                    "GONNE-6",
                    siege.Weapon.types.handcannon,
                    siege.Weapon.firingmodes.singleshot,
                    10,
                    0,
                    1,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                )
            ],
            siege.Weapon.gadgets.stungrenade | siege.Weapon.gadgets.hardbreachcharge,
            "Skeleton Key SK 4-12",
            "JTF2",
            "Montréal, Quebec",
            178,
            78,
            "Sebastien Côté",
            { month: 8, day: 20, age: 36 },
            2
        )

        static blackbeard := siege.Operator(
            "Blackbeard",
            [
                siege.Weapon(
                    "MK17 CQB",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    49,
                    585,
                    20,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1430, 60),
                    codebase.math.roundMultiple(2230, 60)
                ),
                siege.Weapon(
                    "SR-25",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    61,
                    450,
                    20,
                    siege.Weapon.sights.x3max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1380, 60),
                    codebase.math.roundMultiple(2400, 60)
                )
            ],
            [
                siege.Weapon(
                    "D-50",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    71,
                    550,
                    7,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(1450, 60)
                )
            ],
            siege.Weapon.gadgets.claymore | siege.Weapon.gadgets.stungrenade | siege.Weapon.gadgets.empgrenade,
            "TARS Mk 0-Transparent Armored Rifle Shield",
            "NAVY SEAL",
            "Bellevue, Washington",
            180,
            84,
            "Craig Jenson",
            { month: 2, day: 12, age: 32 },
            2
        )

        static capitao := siege.Operator(
            "Capitão",
            [
                siege.Weapon(
                    "PARA-308",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    48,
                    650,
                    30,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(2000, 60),
                    codebase.math.roundMultiple(2300, 60)
                ),
                siege.Weapon(
                    "M249",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    48,
                    650,
                    100,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(6320, 60),
                    codebase.math.roundMultiple(6320, 60)
                )
            ],
            [
                siege.Weapon(
                    "PRB92",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    450,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(1590, 60)
                ),
                siege.Weapon(
                    "GONNE-6",
                    siege.Weapon.types.handcannon,
                    siege.Weapon.firingmodes.singleshot,
                    10,
                    0,
                    1,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                )
            ],
            siege.Weapon.gadgets.claymore | siege.Weapon.gadgets.hardbreachcharge,
            "Tactical Crossbow TAC Mk0",
            "BOPE",
            "Nova Iguaçu, Brazil",
            183,
            86,
            "Vicente Souza",
            { month: 11, day: 17, age: 49 },
            3
        )

        static hibana := siege.Operator(
            "Hibana",
            [
                siege.Weapon(
                    "TYPE-89",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    40,
                    850,
                    20,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1340, 60),
                    codebase.math.roundMultiple(2320, 60)
                ),
                siege.Weapon(
                    "Supernova",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    75,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor,
                    0,
                    true,
                    codebase.math.roundMultiple(4080, 60),
                    codebase.math.roundMultiple(4560, 60)
                )
            ],
            [
                siege.Weapon(
                    "P229",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    51,
                    550,
                    12,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1450, 60)
                ),
                siege.Weapon(
                    "Bearing 9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    1100,
                    25,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    0,
                    true,
                    codebase.math.roundMultiple(1300, 60),
                    codebase.math.roundMultiple(2210, 60)
                )
            ],
            siege.Weapon.gadgets.stungrenade | siege.Weapon.gadgets.breachcharge,
            "X-KAIROS Grenade Launcher",
            "SAT",
            "Tokyo, Japan (Suginami-ki)",
            173,
            57,
            "Yumiko Imagawa",
            { month: 7, day: 12, age: 34 },
            3
        )

        static jackal := siege.Operator(
            "Jackal",
            [
                siege.Weapon(
                    "C7E",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    46,
                    800,
                    30,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1140, 60),
                    codebase.math.roundMultiple(2010, 60)
                ),
                siege.Weapon(
                    "PDW9",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    34,
                    800,
                    50,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1490, 60),
                    codebase.math.roundMultiple(2440, 60)
                ),
                siege.Weapon(
                    "ITA12L",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    85,
                    8,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(5440, 60),
                    codebase.math.roundMultiple(7190, 60)
                )
            ],
            [
                siege.Weapon(
                    "USP40",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    550,
                    12,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1250, 60),
                    codebase.math.roundMultiple(1410, 60)
                ),
                siege.Weapon(
                    "ITA12S",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    70,
                    85,
                    5,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3200, 60),
                    codebase.math.roundMultiple(4580, 60)
                )
            ],
            siege.Weapon.gadgets.claymore | siege.Weapon.gadgets.smokegrenade,
            "Eyenox Model III",
            "GEO",
            "Ceuta, Spain",
            190,
            78,
            "Ryad Ramírez Al-Hassar",
            { month: 3, day: 1, age: 49 },
            2
        )

        static ying := siege.Operator(
            "Ying",
            [
                siege.Weapon(
                    "T-95 LSW",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    46,
                    650,
                    80,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1300, 60),
                    codebase.math.roundMultiple(2180, 60)
                ),
                siege.Weapon(
                    "SIX12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    6,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(1400, 60),
                    codebase.math.roundMultiple(1400, 60)
                )
            ],
            [
                siege.Weapon(
                    "Q-929",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    550,
                    10,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1140, 60),
                    codebase.math.roundMultiple(1440, 60)
                )
            ],
            siege.Weapon.gadgets.hardbreachcharge | siege.Weapon.gadgets.smokegrenade,
            "Candela Cluster Charges",
            "SDU",
            "Hong Kong, Central",
            160,
            52,
            "Siu Mei Lin",
            { month: 5, day: 12, age: 33 },
            2
        )

        static zofia := siege.Operator(
            "Zofia",
            [
                siege.Weapon(
                    "LMG-E",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    41,
                    720,
                    150,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(6180, 60),
                    codebase.math.roundMultiple(5430, 60)
                ),
                siege.Weapon(
                    "M762",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    45,
                    730,
                    30,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1590, 60),
                    codebase.math.roundMultiple(2350, 60)
                )
            ],
            [
                siege.Weapon(
                    "RG15",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    38,
                    550,
                    15,
                    siege.Weapon.sights.other,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1200, 60),
                    codebase.math.roundMultiple(1370, 60)
                )
            ],
            siege.Weapon.gadgets.breachcharge | siege.Weapon.gadgets.claymore,
            "KS79 Lifeline",
            "GROM",
            "Wrocław, Poland",
            179,
            72,
            "Zofia Bosak",
            { month: 1, day: 28, age: 36 },
            2
        )

        static dokkaebi := siege.Operator(
            "Dokkaebi",
            [
                siege.Weapon(
                    "Mk 14 EBR",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    450,
                    20,
                    siege.Weapon.sights.x3max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1490, 60),
                    codebase.math.roundMultiple(2440, 60)
                ),
                siege.Weapon(
                    "BOSG.12.2",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.singleshot,
                    125,
                    500,
                    2,
                    siege.Weapon.sights.x25max,
                    0,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1160, 60),
                    codebase.math.roundMultiple(1430, 60)
                )
            ],
            [
                siege.Weapon(
                    "SMG-12",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    28,
                    1270,
                    32,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2300, 60)
                ),
                siege.Weapon(
                    "GONNE-6",
                    siege.Weapon.types.handcannon,
                    siege.Weapon.firingmodes.singleshot,
                    10,
                    0,
                    1,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(0, 60),
                    codebase.math.roundMultiple(0, 60)
                ),
                siege.Weapon(
                    "C75 Auto",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    35,
                    1000,
                    26,
                    0,
                    siege.Weapon.barrels.suppressor,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2220, 60)
                )
            ],
            siege.Weapon.gadgets.smokegrenade | siege.Weapon.gadgets.stungrenade | siege.Weapon.gadgets.empgrenade,
            "Logic Bomb",
            "707th SMB",
            "Seoul, South Korea",
            180,
            70,
            "Grace Nam",
            { month: 2, day: 2, age: 29 },
            2
        )

        static lion := siege.Operator(
            "Lion",
            [
                siege.Weapon(
                    "V308",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    44,
                    700,
                    50,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1550, 60),
                    codebase.math.roundMultiple(2330, 60)
                ),
                siege.Weapon(
                    "417",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    69,
                    450,
                    20,
                    siege.Weapon.sights.x3max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1350, 60),
                    codebase.math.roundMultiple(2190, 60)
                ),
                siege.Weapon(
                    "SG-CQB",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    53,
                    85,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    siege.Weapon.grips.verticalgrip,
                    true,
                    codebase.math.roundMultiple(4090, 60),
                    codebase.math.roundMultiple(4580, 60)
                )
            ],
            [
                siege.Weapon(
                    "LFP586",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    78,
                    550,
                    6,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(2540, 60),
                    codebase.math.roundMultiple(2540, 60)
                ),
                siege.Weapon(
                    "GONNE-6",
                    siege.Weapon.types.handcannon,
                    siege.Weapon.firingmodes.singleshot,
                    10,
                    0,
                    1,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                ),
                siege.Weapon(
                    "P9",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    45,
                    550,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1440, 60)
                )
            ],
            siege.Weapon.gadgets.stungrenade | siege.Weapon.gadgets.claymore | siege.Weapon.gadgets.empgrenade,
            "EE-ONE-D Scanning Drone",
            "CBRN THREAT UNIT",
            "Toulouse, France",
            185,
            87,
            "Olivier Flament",
            { month: 8, day: 29, age: 31 },
            2
        )

        static finka := siege.Operator(
            "Finka",
            [
                siege.Weapon(
                    "Spear .308",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    42,
                    700,
                    30,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1510, 60),
                    codebase.math.roundMultiple(2460, 60)
                ),
                siege.Weapon(
                    "6P41",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    46,
                    680,
                    100,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(6580, 60),
                    codebase.math.roundMultiple(7160, 60)
                ),
                siege.Weapon(
                    "SASG-12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    330,
                    10,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1520, 60),
                    codebase.math.roundMultiple(2180, 60)
                )
            ],
            [
                siege.Weapon(
                    "PMM",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    61,
                    550,
                    8,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(0590, 60),
                    codebase.math.roundMultiple(1280, 60)
                ),
                siege.Weapon(
                    "GONNE-6",
                    siege.Weapon.types.handcannon,
                    siege.Weapon.firingmodes.singleshot,
                    10,
                    0,
                    1,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                ),
                siege.Weapon(
                    "GSH-18",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    18,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1260, 60),
                    codebase.math.roundMultiple(1470, 60)
                )
            ],
            siege.Weapon.gadgets.smokegrenade | siege.Weapon.gadgets.stungrenade,
            "Adrenal Surge",
            "CBRN THREAT UNIT",
            "Gomel, Belarus",
            171,
            68,
            "Lera Melnikova",
            { month: 6, day: 7, age: 27 },
            2
        )

        static maverick := siege.Operator(
            "Maverick",
            [
                siege.Weapon(
                    "AR-15.50",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    62,
                    450,
                    10,
                    siege.Weapon.sights.x3max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1280, 60),
                    codebase.math.roundMultiple(2120, 60)
                ),
                siege.Weapon(
                    "M4",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    44,
                    750,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1530, 60),
                    codebase.math.roundMultiple(2400, 60)
                )
            ],
            [
                siege.Weapon(
                    "1911 TACOPS",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    55,
                    450,
                    8,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1240, 60),
                    codebase.math.roundMultiple(1440, 60)
                )
            ],
            siege.Weapon.gadgets.stungrenade | siege.Weapon.gadgets.claymore,
            "Breaching Torch",
            "GSUTR",
            "Boston, Massachusetts",
            180,
            82,
            "Erik Thorn",
            { month: 4, day: 20, age: 36 },
            3
        )

        static nomad := siege.Operator(
            "Nomad",
            [
                siege.Weapon(
                    "AK-74M",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    44,
                    650,
                    40,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1430, 60),
                    codebase.math.roundMultiple(2440, 60)
                ),
                siege.Weapon(
                    "ARX200",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    47,
                    700,
                    20,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1420, 60),
                    codebase.math.roundMultiple(2350, 60)
                )
            ],
            [
                siege.Weapon(
                    ".44 Mag Semi-Auto",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    54,
                    450,
                    7,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(0590, 60),
                    codebase.math.roundMultiple(1280, 60)
                ),
                siege.Weapon(
                    "PRB92",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    450,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(1590, 60)
                )
            ],
            siege.Weapon.gadgets.stungrenade | siege.Weapon.gadgets.breachcharge,
            "Airjab Launcher",
            "GIGR",
            "Marrakesh, Morocco",
            171,
            63,
            "Sanaa El Maktoub",
            { month: 7, day: 27, age: 39 },
            2
        )

        static gridlock := siege.Operator(
            "Gridlock",
            [
                siege.Weapon(
                    "F90",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    38,
                    780,
                    30,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1380, 60),
                    codebase.math.roundMultiple(2290, 60)
                ),
                siege.Weapon(
                    "M249 SAW",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    48,
                    650,
                    60,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(2030, 60),
                    codebase.math.roundMultiple(3560, 60)
                )
            ],
            [
                siege.Weapon(
                    "Super Shorty",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    85,
                    3,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(1300, 60),
                    codebase.math.roundMultiple(2450, 60)
                ),
                siege.Weapon(
                    "GONNE-6",
                    siege.Weapon.types.handcannon,
                    siege.Weapon.firingmodes.singleshot,
                    10,
                    0,
                    1,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                ),
                siege.Weapon(
                    "SDP 9mm",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    47,
                    450,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1050, 60),
                    codebase.math.roundMultiple(1450, 60)
                )
            ],
            siege.Weapon.gadgets.smokegrenade | siege.Weapon.gadgets.breachcharge | siege.Weapon.gadgets.empgrenade,
            "Trax Stingers",
            "SASR",
            "Longreach, Central Queensland, Australia",
            177,
            102,
            "Tori Tallyo Fairous",
            { month: 8, day: 5, age: 36 },
            1
        )

        static nokk := siege.Operator(
            "Nøkk",
            [
                siege.Weapon(
                    "FMG-9",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    34,
                    800,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1420, 60),
                    codebase.math.roundMultiple(2210, 60)
                ),
                siege.Weapon(
                    "SIX12 SD",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    6,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(1400, 60),
                    codebase.math.roundMultiple(1400, 60)
                )
            ],
            [
                siege.Weapon(
                    "5.7 USG",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    550,
                    20,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1260, 60),
                    codebase.math.roundMultiple(1490, 60)
                ),
                siege.Weapon(
                    "D-50",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    71,
                    550,
                    7,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(1450, 60)
                )
            ],
            siege.Weapon.gadgets.fraggrenade | siege.Weapon.gadgets.hardbreachcharge | siege.Weapon.gadgets.empgrenade,
            "HEL Presence Reduction",
            "JAEGER CORPS",
            "[REDACTED]",
            0,
            0,
            "[REDACTED]",
            { month: -1, day: -1, age: -1 },
            2
        )

        static amaru := siege.Operator(
            "Amaru",
            [
                siege.Weapon(
                    "G8A1",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    37,
                    850,
                    50,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(2120, 60),
                    codebase.math.roundMultiple(3220, 60)
                ),
                siege.Weapon(
                    "Supernova",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    75,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor,
                    0,
                    true,
                    codebase.math.roundMultiple(4080, 60),
                    codebase.math.roundMultiple(4560, 60)
                )
            ],
            [
                siege.Weapon(
                    "SMG-11",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    35,
                    1270,
                    16,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1270, 60),
                    codebase.math.roundMultiple(2130, 60)
                ),
                siege.Weapon(
                    "GONNE-6",
                    siege.Weapon.types.handcannon,
                    siege.Weapon.firingmodes.singleshot,
                    10,
                    0,
                    1,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                ),
                siege.Weapon(
                    "ITA12S",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    70,
                    85,
                    5,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3200, 60),
                    codebase.math.roundMultiple(4580, 60)
                )
            ],
            siege.Weapon.gadgets.hardbreachcharge | siege.Weapon.gadgets.stungrenade,
            "Garra Hook",
            "APCA",
            "Cojata, Peru",
            189,
            84,
            "Azucena Rocío Quispe",
            { month: 5, day: 6, age: 48 },
            2
        )

        static kali := siege.Operator(
            "Kali",
            [
                siege.Weapon(
                    "CSRX 300",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    127,
                    50,
                    5,
                    siege.Weapon.sights.x612,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(1500, 60),
                    codebase.math.roundMultiple(2440, 60)
                )
            ],
            [
                siege.Weapon(
                    "SPSMG9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    980,
                    20,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    0,
                    true,
                    codebase.math.roundMultiple(1350, 60),
                    codebase.math.roundMultiple(1590, 60)
                ),
                siege.Weapon(
                    "C75 Auto",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    35,
                    1000,
                    26,
                    0,
                    siege.Weapon.barrels.suppressor,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2220, 60)
                ),
                siege.Weapon(
                    "P226 MK 25",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1430, 60)
                )
            ],
            siege.Weapon.gadgets.claymore | siege.Weapon.gadgets.breachcharge,
            "Low Velocity (LV) Explosive Lance",
            "NIGHTHAVEN",
            "Amreli, India",
            170,
            67,
            "Jaimini Kalimohan Shah",
            { month: 8, day: 21, age: 34 },
            2
        )

        static iana := siege.Operator(
            "Iana",
            [
                siege.Weapon(
                    "ARX200",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    47,
                    700,
                    20,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1420, 60),
                    codebase.math.roundMultiple(2350, 60)
                ),
                siege.Weapon(
                    "G36C",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    38,
                    780,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2340, 60)
                )
            ],
            [
                siege.Weapon(
                    "MK1 9mm",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    550,
                    13,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1110, 60),
                    codebase.math.roundMultiple(1320, 60)
                )
            ],
            siege.Weapon.gadgets.fraggrenade | siege.Weapon.gadgets.smokegrenade,
            "Gemini Replicator",
            "REU",
            "Katwijk, Netherlands",
            157,
            56,
            "Nienke Meijer",
            { month: 8, day: 27, age: 35 },
            2
        )

        static ace := siege.Operator(
            "Ace",
            [
                siege.Weapon(
                    "AK-12",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    45,
                    850,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1430, 60),
                    codebase.math.roundMultiple(2260, 60)
                ),
                siege.Weapon(
                    "M1014",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    34,
                    200,
                    8,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(4450, 60),
                    codebase.math.roundMultiple(5330, 60)
                )
            ],
            [
                siege.Weapon(
                    "P9",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    45,
                    550,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1440, 60)
                )
            ],
            siege.Weapon.gadgets.breachcharge | siege.Weapon.gadgets.claymore,
            "S.E.L.M.A. Aqua Breacher",
            "NIGHTHAVEN",
            "Lærdalsøyri, Norway",
            187,
            75,
            "Håvard Haugland",
            { month: 3, day: 15, age: 33 },
            2
        )

        static zero := siege.Operator(
            "Zero",
            [
                siege.Weapon(
                    "SC3000K",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    45,
                    850,
                    25,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1520, 60),
                    codebase.math.roundMultiple(2470, 60)
                ),
                siege.Weapon(
                    "MP7",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    32,
                    900,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2250, 60)
                )
            ],
            [
                siege.Weapon(
                    "5.7 USG",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    550,
                    20,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(1260, 60),
                    codebase.math.roundMultiple(1490, 60)
                ),
                siege.Weapon(
                    "GONNE-6",
                    siege.Weapon.types.handcannon,
                    siege.Weapon.firingmodes.singleshot,
                    10,
                    0,
                    1,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                )
            ],
            siege.Weapon.gadgets.hardbreachcharge | siege.Weapon.gadgets.claymore,
            "ARGUS Launcher",
            "ROS",
            "Baltimore, Maryland",
            178,
            77,
            "Samuel Leo Fisher",
            { month: 8, day: 8, age: 63 },
            2
        )

        static flores := siege.Operator(
            "Flores",
            [
                siege.Weapon(
                    "AR33",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    41,
                    749,
                    25,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1250, 60),
                    codebase.math.roundMultiple(2310, 60)
                ),
                siege.Weapon(
                    "SR-25",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    61,
                    450,
                    20,
                    siege.Weapon.sights.x3max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1380, 60),
                    codebase.math.roundMultiple(2400, 60)
                )
            ],
            [
                siege.Weapon(
                    "GSH-18",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    18,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1260, 60),
                    codebase.math.roundMultiple(1470, 60)
                )
            ],
            siege.Weapon.gadgets.stungrenade | siege.Weapon.gadgets.claymore,
            "RCE-Ratero Charge",
            "UNAFFILIATED",
            "Buenos Aires, Argentina",
            181,
            72,
            "Santiago Miguel Lucero",
            { month: 10, day: 2, age: 28 },
            2
        )

        static osa := siege.Operator(
            "Osa",
            [
                siege.Weapon(
                    "556XI",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    47,
                    690,
                    30,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1460, 60),
                    codebase.math.roundMultiple(2410, 60)
                ),
                siege.Weapon(
                    "PDW9",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    34,
                    800,
                    50,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1490, 60),
                    codebase.math.roundMultiple(2440, 60)
                )
            ],
            [
                siege.Weapon(
                    "PMM",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    61,
                    550,
                    8,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(0590, 60),
                    codebase.math.roundMultiple(1280, 60)
                )
            ],
            siege.Weapon.gadgets.smokegrenade | siege.Weapon.gadgets.claymore | siege.Weapon.gadgets.empgrenade,
            "Talon-8 Clear Shield",
            "NIGHTHAVEN",
            "Split, Croatia",
            180,
            71,
            "Anja Katarina Janković",
            { month: 4, day: 29, age: 27 },
            2
        )

        static sens := siege.Operator(
            "Sens",
            [
                siege.Weapon(
                    "POF-9",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    35,
                    740,
                    50,
                    siege.Weapon.sights.x25max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1470, 60),
                    codebase.math.roundMultiple(2240, 60)
                ),
                siege.Weapon(
                    "417",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    69,
                    450,
                    20,
                    siege.Weapon.sights.x3max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true,
                    codebase.math.roundMultiple(1350, 60),
                    codebase.math.roundMultiple(2190, 60)
                )
            ],
            [
                siege.Weapon(
                    "SDP 9mm",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    47,
                    450,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1050, 60),
                    codebase.math.roundMultiple(1450, 60)
                ),
                siege.Weapon(
                    "GONNE-6",
                    siege.Weapon.types.handcannon,
                    siege.Weapon.firingmodes.singleshot,
                    10,
                    0,
                    1,
                    0,
                    0,
                    0,
                    false,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                )
            ],
            siege.Weapon.gadgets.hardbreachcharge | siege.Weapon.gadgets.claymore,
            "R.O.U. Projector System",
            "SFG",
            "Brussels, Belgium",
            178,
            73,
            "Néon Ngoma Mutombo",
            { month: 3, day: 3, age: 30 },
            1
        )

        static grim := siege.Operator(
            "Grim",
            [
                siege.Weapon(
                    "552 Commando",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    48,
                    690,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1390, 60),
                    codebase.math.roundMultiple(2170, 60)
                ),
                siege.Weapon(
                    "SG-CQB",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    53,
                    85,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    siege.Weapon.grips.verticalgrip,
                    true,
                    codebase.math.roundMultiple(4090, 60),
                    codebase.math.roundMultiple(4580, 60)
                )
            ],
            [
                siege.Weapon(
                    "P229",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    51,
                    550,
                    12,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1450, 60)
                )
            ],
            siege.Weapon.gadgets.breachcharge | siege.Weapon.gadgets.claymore,
            "Kawan Hive Launcher",
            "NIGHTHAVEN",
            "Jurong, Singapore",
            179,
            89.8,
            "Charlie Tho Keng Boon",
            { month: 4, day: 5, age: 39 },
            3
        )
    
        static list := [
            siege.attackers.sledge,
            siege.attackers.thatcher,
            siege.attackers.ash,
            siege.attackers.thermite,
            siege.attackers.twitch,
            siege.attackers.montagne,
            siege.attackers.glaz,
            siege.attackers.fuze,
            siege.attackers.blitz,
            siege.attackers.iq,
            siege.attackers.buck,
            siege.attackers.blackbeard,
            siege.attackers.capitao,
            siege.attackers.hibana,
            siege.attackers.jackal,
            siege.attackers.ying,
            siege.attackers.zofia,
            siege.attackers.dokkaebi,
            siege.attackers.lion,
            siege.attackers.finka,
            siege.attackers.maverick,
            siege.attackers.nomad,
            siege.attackers.gridlock,
            siege.attackers.nokk,
            siege.attackers.amaru,
            siege.attackers.kali,
            siege.attackers.iana,
            siege.attackers.ace,
            siege.attackers.zero,
            siege.attackers.flores,
            siege.attackers.osa,
            siege.attackers.sens,
            siege.attackers.grim
        ]
        __Enum(p*) => siege.attackers.list.__Enum(p*)
        __New(*) => siege.attackers.list.__Enum(1)
        __Call(*) => siege.attackers.list.__Enum(1)
    }

    class defenders
    {
        static name := "Defenders"

        static smoke := siege.Operator(
            "Smoke",
            [
                siege.Weapon(
                    "FMG-9",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    34,
                    800,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1420, 60),
                    codebase.math.roundMultiple(2210, 60)
                ),
                siege.Weapon(
                    "M590A1",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    85,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(4030, 60),
                    codebase.math.roundMultiple(4510, 60)
                )
            ],
            [
                siege.Weapon(
                    "P226 MK 25",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1430, 60)
                ),
                siege.Weapon(
                    "SMG-11",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    35,
                    1270,
                    16,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1270, 60),
                    codebase.math.roundMultiple(2130, 60)
                )
            ],
            siege.Weapon.gadgets.barbedwire | siege.Weapon.gadgets.deployableshield,
            "Compound Z8 Grenades",
            "SAS",
            "London, England (King's Cross)",
            173,
            70,
            "James Porter",
            { month: 5, day: 14, age: 36 },
            2
        )

        static mute := siege.Operator(
            "Mute",
            [
                siege.Weapon(
                    "MP5K",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    30,
                    800,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1280, 60),
                    codebase.math.roundMultiple(2150, 60)
                ),
                siege.Weapon(
                    "M590A1",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    85,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(4030, 60),
                    codebase.math.roundMultiple(4510, 60)
                )
            ],
            [
                siege.Weapon(
                    "P226 MK 25",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1430, 60)
                ),
                siege.Weapon(
                    "SMG-11",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    35,
                    1270,
                    16,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1270, 60),
                    codebase.math.roundMultiple(2130, 60)
                )
            ],
            siege.Weapon.gadgets.nitrocell | siege.Weapon.gadgets.bulletproofcamera,
            '"Moni" GC90 Signal Disruptor',
            "SAS",
            "York, England",
            185,
            80,
            "Mark R. Chandar",
            { month: 10, day: 11, age: 25 },
            2
        )

        static castle := siege.Operator(
            "Castle",
            [
                siege.Weapon(
                    "UMP45",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    38,
                    600,
                    25,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1480, 60),
                    codebase.math.roundMultiple(2190, 60)
                ),
                siege.Weapon(
                    "M1014",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    34,
                    200,
                    8,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(4450, 60),
                    codebase.math.roundMultiple(5330, 60)
                )
            ],
            [
                siege.Weapon(
                    "5.7 USG",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    550,
                    20,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1260, 60),
                    codebase.math.roundMultiple(1490, 60)
                ),
                siege.Weapon(
                    "Super Shorty",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    85,
                    3,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(1300, 60),
                    codebase.math.roundMultiple(2450, 60)
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera | siege.Weapon.gadgets.proximityalarm,
            "UTP1-Universal Tactical Panel",
            "FBI SWAT",
            "Sherman Oaks, California",
            185,
            86,
            "Miles Campbell",
            { month: 9, day: 20, age: 36 },
            2
        )

        static pulse := siege.Operator(
            "Pulse",
            [
                siege.Weapon(
                    "M1014",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    34,
                    200,
                    8,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(4450, 60),
                    codebase.math.roundMultiple(5330, 60)
                ),
                siege.Weapon(
                    "UMP45",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    38,
                    600,
                    25,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1480, 60),
                    codebase.math.roundMultiple(2190, 60)
                )
            ],
            [
                siege.Weapon(
                    "M45 Meusoc",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    58,
                    550,
                    7,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1100, 60),
                    codebase.math.roundMultiple(1300, 60)
                ),
                siege.Weapon(
                    "5.7 USG",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    550,
                    20,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1260, 60),
                    codebase.math.roundMultiple(1490, 60)
                )
            ],
            siege.Weapon.gadgets.barbedwire | siege.Weapon.gadgets.nitrocell,
            "HB-5 Cardiac Sensor",
            "FBI SWAT",
            "Goldsboro, North Carolina",
            188,
            85,
            "Jack Estrada",
            { month: 10, day: 11, age: 32 },
            3
        )

        static doc := siege.Operator(
            "Doc",
            [
                siege.Weapon(
                    "SG-CQB",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    53,
                    85,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    siege.Weapon.grips.verticalgrip,
                    true,
                    codebase.math.roundMultiple(4090, 60),
                    codebase.math.roundMultiple(4580, 60)
                ),
                siege.Weapon(
                    "MP5",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    27,
                    800,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1280, 60),
                    codebase.math.roundMultiple(2220, 60)
                ),
                siege.Weapon(
                    "P90",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    22,
                    970,
                    50,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.compensator | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1560, 60),
                    codebase.math.roundMultiple(2190, 60)
                )
            ],
            [
                siege.Weapon(
                    "P9",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    45,
                    550,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1440, 60)
                ),
                siege.Weapon(
                    "LFP586",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    78,
                    550,
                    6,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(2540, 60),
                    codebase.math.roundMultiple(2540, 60)
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera | siege.Weapon.gadgets.barbedwire,
            "MPD-0 STIM PISTOL",
            "GIGN",
            "Paris, France",
            177,
            74,
            "Gustave Kateb",
            { month: 9, day: 16, age: 39 },
            1
        )

        static rook := siege.Operator(
            "Rook",
            [
                siege.Weapon(
                    "P90",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    22,
                    970,
                    50,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.compensator | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1560, 60),
                    codebase.math.roundMultiple(2190, 60)
                ),
                siege.Weapon(
                    "MP5",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    27,
                    800,
                    30,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1280, 60),
                    codebase.math.roundMultiple(2220, 60)
                ),
                siege.Weapon(
                    "SG-CQB",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    53,
                    85,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    siege.Weapon.grips.verticalgrip,
                    true,
                    codebase.math.roundMultiple(4090, 60),
                    codebase.math.roundMultiple(4580, 60)
                )
            ],
            [
                siege.Weapon(
                    "LFP586",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    78,
                    550,
                    6,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(2540, 60),
                    codebase.math.roundMultiple(2540, 60)
                ),
                siege.Weapon(
                    "P9",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    45,
                    550,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1440, 60)
                )
            ],
            siege.Weapon.gadgets.proximityalarm | siege.Weapon.gadgets.impactgrenade,
            'R1N "Rhino" Armor - Armor Pack',
            "GIGN",
            "Tours, France",
            175,
            72,
            "Julien Nizan",
            { month: 1, day: 6, age: 27 },
            1
        )

        static kapkan := siege.Operator(
            "Kapkan",
            [
                siege.Weapon(
                    "9x19VSN",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    34,
                    750,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1430, 60),
                    codebase.math.roundMultiple(2220, 60)
                ),
                siege.Weapon(
                    "SASG-12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    330,
                    10,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1520, 60),
                    codebase.math.roundMultiple(2180, 60)
                )
            ],
            [
                siege.Weapon(
                    "PMM",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    61,
                    550,
                    8,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(0590, 60),
                    codebase.math.roundMultiple(1280, 60)
                ),
                siege.Weapon(
                    "GSH-18",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    18,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1260, 60),
                    codebase.math.roundMultiple(1470, 60)
                )
            ],
            siege.Weapon.gadgets.impactgrenade | siege.Weapon.gadgets.nitrocell,
            "EDD Mk II Tripwires",
            "SPETSNAZ",
            "Kovrov, Russia",
            180,
            80,
            "Maxim Basuda",
            { month: 5, day: 14, age: 38 },
            2
        )

        static tachanka := siege.Operator(
            "Tachanka",
            [
                siege.Weapon(
                    "DP27",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    49,
                    550,
                    70,
                    siege.Weapon.sights.other | siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    false, 
                    codebase.math.roundMultiple(2490, 60),
                    codebase.math.roundMultiple(3340, 60)
                ),
                siege.Weapon(
                    "9x19VSN",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    34,
                    750,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1430, 60),
                    codebase.math.roundMultiple(2220, 60)
                )
            ],
            [
                siege.Weapon(
                    "GSH-18",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    18,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1260, 60),
                    codebase.math.roundMultiple(1470, 60)
                ),
                siege.Weapon(
                    "PMM",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    61,
                    550,
                    8,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(0590, 60),
                    codebase.math.roundMultiple(1280, 60)
                ),
                siege.Weapon(
                    "Bearing 9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    1100,
                    25,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1300, 60),
                    codebase.math.roundMultiple(2210, 60)
                )
            ],
            siege.Weapon.gadgets.barbedwire | siege.Weapon.gadgets.deployableshield,
            "Shumikha Grenade Launcher",
            "SPETSNAZ",
            "Saint Petersburg, Russia",
            183,
            86,
            "Alexsandr Sanaviev",
            { month: 11, day: 3, age: 48 },
            1
        )

        static jäger := siege.Operator(
            "Jäger",
            [
                siege.Weapon(
                    "M870",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    100,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3410, 60),
                    codebase.math.roundMultiple(4360, 60)
                ),
                siege.Weapon(
                    "416-C Carbine",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    38,
                    740,
                    25,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1340, 60),
                    codebase.math.roundMultiple(2180, 60)
                )
            ],
            [
                siege.Weapon(
                    "P12",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1230, 60),
                    codebase.math.roundMultiple(1560, 60)
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera | siege.Weapon.gadgets.barbedwire,
            'ADS-Mk IV "Magpie" Automated Defense System',
            "GSG 9",
            "Düsseldorf, Germany",
            180,
            64,
            "Marius Streicher",
            { month: 3, day: 9, age: 39 },
            2
        )

        static bandit := siege.Operator(
            "Bandit",
            [
                siege.Weapon(
                    "MP7",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    32,
                    900,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2250, 60)
                ),
                siege.Weapon(
                    "M870",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    100,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3410, 60),
                    codebase.math.roundMultiple(4360, 60)
                )
            ],
            [
                siege.Weapon(
                    "P12",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1230, 60),
                    codebase.math.roundMultiple(1560, 60)
                )
            ],
            siege.Weapon.gadgets.barbedwire | siege.Weapon.gadgets.nitrocell,
            'CED-1 Crude Electrical Device "Shock Wires"',
            "GSG 9",
            "Berlin, Germany",
            180,
            68,
            "Dominic Brunsmeier",
            { month: 8, day: 13, age: 42 },
            3
        )

        static frost := siege.Operator(
            "Frost",
            [
                siege.Weapon(
                    "Super 90",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    8,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(4320, 60),
                    codebase.math.roundMultiple(5180, 60)
                ),
                siege.Weapon(
                    "9mm C1",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    45,
                    575,
                    34,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1290, 60),
                    codebase.math.roundMultiple(2070, 60)
                )
            ],
            [
                siege.Weapon(
                    "MK1 9mm",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    550,
                    13,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1110, 60),
                    codebase.math.roundMultiple(1320, 60)
                ),
                siege.Weapon(
                    "ITA12S",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    70,
                    85,
                    5,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3200, 60),
                    codebase.math.roundMultiple(4580, 60)
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera | siege.Weapon.gadgets.deployableshield,
            "Sterling Mk2 LHT leg-hold trap (Welcome Mat)",
            "JTF2",
            "Vancouver, British Columbia",
            172,
            63,
            "Tina Lin Tsang",
            { month: 5, day: 4, age: 32 },
            2
        )

        static valkyrie := siege.Operator(
            "Valkyrie",
            [
                siege.Weapon(
                    "MPX",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    26,
                    830,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1310, 60),
                    codebase.math.roundMultiple(2040, 60)
                ),
                siege.Weapon(
                    "SPAS-12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3470, 60),
                    codebase.math.roundMultiple(4430, 60)
                )
            ],
            [
                siege.Weapon(
                    "D-50",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    71,
                    550,
                    7,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(1450, 60)
                )
            ],
            siege.Weapon.gadgets.impactgrenade | siege.Weapon.gadgets.nitrocell,
            'Gyro Cam Mk2 "Black Eye"',
            "NAVY SEAL",
            "Oceanside, California",
            170,
            61,
            "Meghan J. Castellano",
            { month: 7, day: 21, age: 31 },
            2
        )

        static caveira := siege.Operator(
            "Caveira",
            [
                siege.Weapon(
                    "M12",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    40,
                    550,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.compensator | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1290, 60),
                    codebase.math.roundMultiple(2170, 60)
                ),
                siege.Weapon(
                    "SPAS-15",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    30,
                    290,
                    6,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(1180, 60),
                    codebase.math.roundMultiple(2020, 60)
                )
            ],
            [
                siege.Weapon(
                    "Luison",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    65,
                    450,
                    12,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(1590, 60)
                )
            ],
            siege.Weapon.gadgets.impactgrenade | siege.Weapon.gadgets.proximityalarm,
            "Silent Step",
            "BOPE",
            "Rinópolis, Brazil",
            177,
            72,
            "Taina Pereira",
            { month: 10, day: 15, age: 27 },
            3
        )

        static echo := siege.Operator(
            "Echo",
            [
                siege.Weapon(
                    "Supernova",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    75,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor,
                    0,
                    true,
                    codebase.math.roundMultiple(4080, 60),
                    codebase.math.roundMultiple(4560, 60)
                ),
                siege.Weapon(
                    "MP5SD",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    30,
                    800,
                    30,
                    siege.Weapon.sights.x15max,
                    0,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2260, 60)
                )
            ],
            [
                siege.Weapon(
                    "P229",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    51,
                    550,
                    12,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1450, 60)
                ),
                siege.Weapon(
                    "Bearing 9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    1100,
                    25,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1300, 60),
                    codebase.math.roundMultiple(2210, 60)
                )
            ],
            siege.Weapon.gadgets.impactgrenade | siege.Weapon.gadgets.deployableshield,
            "Yokai Hovering Drone",
            "SAT",
            "Suginami, Tokyo, Japan",
            180,
            72,
            "Masaru Enatsu",
            { month: 10, day: 31, age: 36 },
            1
        )

        static mira := siege.Operator(
            "Mira",
            [
                siege.Weapon(
                    "Vector .45 ACP",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    23,
                    1200,
                    25,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1330, 60),
                    codebase.math.roundMultiple(2170, 60)
                ),
                siege.Weapon(
                    "ITA12L",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    85,
                    8,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(5440, 60),
                    codebase.math.roundMultiple(7190, 60)
                )
            ],
            [
                siege.Weapon(
                    "USP40",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    550,
                    12,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1250, 60),
                    codebase.math.roundMultiple(1410, 60)
                ),
                siege.Weapon(
                    "ITA12S",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    70,
                    85,
                    5,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3200, 60),
                    codebase.math.roundMultiple(4580, 60)
                )
            ],
            siege.Weapon.gadgets.proximityalarm | siege.Weapon.gadgets.nitrocell,
            "Black Mirror",
            "GEO",
            "Madrid, Spain",
            165,
            60,
            "Elena María Álvarez",
            { month: 11, day: 18, age: 39 },
            1
        )

        static lesion := siege.Operator(
            "Lesion",
            [
                siege.Weapon(
                    "SIX12 SD",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    6,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(1400, 60),
                    codebase.math.roundMultiple(1400, 60)
                ),
                siege.Weapon(
                    "T-5 SMG",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    28,
                    900,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1400, 60),
                    codebase.math.roundMultiple(2180, 60)
                )
            ],
            [
                siege.Weapon(
                    "Q-929",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    550,
                    10,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1140, 60),
                    codebase.math.roundMultiple(1440, 60)
                )
            ],
            siege.Weapon.gadgets.impactgrenade | siege.Weapon.gadgets.bulletproofcamera,
            "Gu Mines",
            "SDU",
            "Hong Kong, Junk Bay (Tseung Kwan O)",
            174,
            82,
            "Liu Tze Long",
            { month: 7, day: 2, age: 44 },
            2
        )

        static ela := siege.Operator(
            "Ela",
            [
                siege.Weapon(
                    "Scorpion Evo 3 A1",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    23,
                    1080,
                    40,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.weapon.grips.verticalgrip | siege.weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1250, 60),
                    codebase.math.roundMultiple(2220, 60)
                ),
                siege.Weapon(
                    "FO-12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    25,
                    400,
                    10,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1440, 60),
                    codebase.math.roundMultiple(2360, 60)
                )
            ],
            [
                siege.Weapon(
                    "RG15",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    38,
                    550,
                    15,
                    siege.Weapon.sights.other,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1200, 60),
                    codebase.math.roundMultiple(1370, 60)
                )
            ],
            siege.Weapon.gadgets.barbedwire | siege.Weapon.gadgets.deployableshield,
            "GRZMOT Mine",
            "GROM",
            "Wrocław, Poland",
            173,
            68,
            "Elżbieta Bosak",
            { month: 11, day: 8, age: 31 },
            3
        )

        static vigil := siege.Operator(
            "Vigil",
            [
                siege.Weapon(
                    "K1A",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    36,
                    720,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.weapon.grips.verticalgrip | siege.weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1470, 60),
                    codebase.math.roundMultiple(2280, 60)
                ),
                siege.Weapon(
                    "BOSG.12.2",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.singleshot,
                    125,
                    500,
                    2,
                    siege.Weapon.sights.nonmagmax + siege.Weapon.sights.x25max,
                    0,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1160, 60),
                    codebase.math.roundMultiple(1430, 60)
                )
            ],
            [
                siege.Weapon(
                    "C75 Auto",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    35,
                    1000,
                    26,
                    0,
                    siege.Weapon.barrels.suppressor,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2220, 60)
                ),
                siege.Weapon(
                    "SMG-12",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    28,
                    1270,
                    32,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2300, 60)
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera | siege.Weapon.gadgets.impactgrenade,
            "ERC-7 Electronic Rendering Cloak",
            "707TH SMB",
            "[REDACTED]",
            173,
            73,
            "Chul Kyung Hwa",
            { month: 1, day: 17, age: 34 },
            3
        )

        static maestro := siege.Operator(
            "Maestro",
            [
                siege.Weapon(
                    "ALDA 5.56",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    35,
                    900,
                    80,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true,
                    codebase.math.roundMultiple(5200, 60),
                    codebase.math.roundMultiple(4480, 60)
                ),
                siege.Weapon(
                    "ACS12",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.fullauto,
                    69,
                    300,
                    30,
                    siege.Weapon.sights.x2max,
                    0,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1590, 60),
                    codebase.math.roundMultiple(2440, 60)
                )
            ],
            [
                siege.Weapon(
                    "Bailiff 410",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    30,
                    485,
                    5,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3260, 60),
                    codebase.math.roundMultiple(3370, 60)
                ),
                siege.Weapon(
                    "Keratos .357",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    78,
                    450,
                    6,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(3020, 60),
                    codebase.math.roundMultiple(3020, 60)
                )
            ],
            siege.Weapon.gadgets.barbedwire | siege.Weapon.gadgets.impactgrenade,
            'Compact Laser Emplacement Mk V "Evil Eye"',
            "GIS",
            "Rome, Italy",
            185,
            87,
            "Adriano Martello",
            { month: 4, day: 13, age: 45 },
            1
        )

        static alibi := siege.Operator(
            "Alibi",
            [
                siege.Weapon(
                    "Mx4 Storm",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    26,
                    950,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip,
                    true,
                    codebase.math.roundMultiple(1570, 60),
                    codebase.math.roundMultiple(2200, 60)
                ),
                siege.Weapon(
                    "ACS12",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.fullauto,
                    69,
                    300,
                    30,
                    siege.Weapon.sights.x2max,
                    0,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1590, 60),
                    codebase.math.roundMultiple(2440, 60)
                )
            ],
            [
                siege.Weapon(
                    "Keratos .357",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    78,
                    450,
                    6,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(3020, 60),
                    codebase.math.roundMultiple(3020, 60)
                ),
                siege.Weapon(
                    "Bailiff 410",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    30,
                    485,
                    5,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3260, 60),
                    codebase.math.roundMultiple(3370, 60)
                )
            ],
            siege.Weapon.gadgets.impactgrenade | siege.Weapon.gadgets.deployableshield,
            "Prisma",
            "GIS",
            "Tripoli, Libya",
            171,
            63,
            "Aria de Luca",
            { month: 12, day: 15, age: 37 },
            3
        )

        static clash := siege.Operator(
            "Clash",
            [
                siege.Weapon(
                    "CCE Shield",
                    siege.Weapon.types.shield,
                    0,
                    5,
                    20,
                    4,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(00, 60),
                    codebase.math.roundMultiple(00, 60)
                )
            ],
            [
                siege.Weapon(
                    "Super Shorty",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    85,
                    3,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(1300, 60),
                    codebase.math.roundMultiple(2450, 60)
                ),
                siege.Weapon(
                    "SPSMG9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    980,
                    20,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    0,
                    true,
                    codebase.math.roundMultiple(1350, 60),
                    codebase.math.roundMultiple(1590, 60)
                ),
                siege.Weapon(
                    "P-10C",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    40,
                    450,
                    15,
                    siege.Weapon.sights.other,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1240, 60),
                    codebase.math.roundMultiple(1380, 60)
                )
            ],
            siege.Weapon.gadgets.barbedwire | siege.Weapon.gadgets.impactgrenade,
            "Crowd Control Electric Shield",
            "GSUTR",
            "London, England",
            179,
            73,
            "Morowa Evans",
            { month: 6, day: 7, age: 35 },
            1
        )

        static kaid := siege.Operator(
            "Kaid",
            [
                siege.Weapon(
                    "AUG A3",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    36,
                    700,
                    31,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.weapon.grips.verticalgrip | siege.weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1480, 60),
                    codebase.math.roundMultiple(2310, 60)
                ),
                siege.Weapon(
                    "TCSG12",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.singleshot,
                    63,
                    450,
                    10,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1410, 60),
                    codebase.math.roundMultiple(2290, 60)
                )
            ],
            [
                siege.Weapon(
                    ".44 Mag Semi-Auto",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    54,
                    450,
                    7,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(0590, 60),
                    codebase.math.roundMultiple(1280, 60)
                ),
                siege.Weapon(
                    "LFP586",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    78,
                    550,
                    6,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(2540, 60),
                    codebase.math.roundMultiple(2540, 60)
                )
            ],
            siege.Weapon.gadgets.nitrocell | siege.Weapon.gadgets.barbedwire,
            "Rtila Electroclaw",
            "GIGR",
            "Aroumd, Morocco",
            195,
            98,
            "Jalal El Fassi",
            { month: 6, day: 26, age: 58 },
            1
        )

        static mozzie := siege.Operator(
            "Mozzie",
            [
                siege.Weapon(
                    "Commando 9",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    36,
                    780,
                    25,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.weapon.grips.verticalgrip | siege.weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1200, 60),
                    codebase.math.roundMultiple(1540, 60)
                ),
                siege.Weapon(
                    "P10 RONI",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    26,
                    980,
                    15,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1120, 60),
                    codebase.math.roundMultiple(2200, 60)
                )
            ],
            [
                siege.Weapon(
                    "SDP 9mm",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    47,
                    450,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1050, 60),
                    codebase.math.roundMultiple(1450, 60)
                )
            ],
            siege.Weapon.gadgets.barbedwire | siege.Weapon.gadgets.nitrocell,
            "Pest Launcher",
            "SASR",
            "Portland, Australia",
            162,
            57,
            "Max Goose",
            { month: 2, day: 15, age: 35 },
            2
        )

        static warden := siege.Operator(
            "Warden",
            [
                siege.Weapon(
                    "M590A1",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    85,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(4030, 60),
                    codebase.math.roundMultiple(4510, 60)
                ),
                siege.Weapon(
                    "MPX",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    26,
                    830,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1310, 60),
                    codebase.math.roundMultiple(2040, 60)
                )
            ],
            [
                siege.Weapon(
                    "P-10C",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    40,
                    450,
                    15,
                    siege.Weapon.sights.other,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1240, 60),
                    codebase.math.roundMultiple(1380, 60)
                ),
                siege.Weapon(
                    "SMG-12",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    28,
                    1270,
                    32,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2300, 60)
                )
            ],
            siege.Weapon.gadgets.deployableshield | siege.Weapon.gadgets.nitrocell,
            "Glance Smart Glasses",
            "SECRET SERVICE",
            "Louisville, Kentucky",
            183,
            80,
            "Collinn McKinley",
            { month: 3, day: 18, age: 48 },
            2
        )

        static goyo := siege.Operator(
            "Goyo",
            [
                siege.Weapon(
                    "Vector .45 ACP",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    23,
                    1200,
                    25,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1330, 60),
                    codebase.math.roundMultiple(2170, 60)
                ),
                siege.Weapon(
                    "TCSG12",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.singleshot,
                    63,
                    450,
                    10,
                    siege.Weapon.sights.x2max,
                    siege.Weapon.barrels.suppressor,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1410, 60),
                    codebase.math.roundMultiple(2290, 60)
                )
            ],
            [
                siege.Weapon(
                    "P229",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    51,
                    550,
                    12,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1220, 60),
                    codebase.math.roundMultiple(1450, 60)
                )
            ],
            siege.Weapon.gadgets.proximityalarm | siege.Weapon.gadgets.nitrocell,
            "Volcán Canister",
            "FUERZAS ESPECIALES",
            "Culiacán Rosales, Mexico",
            171,
            83,
            "César Ruiz Hernández",
            { month: 6, day: 20, age: 31 },
            2
        )

        static wamai := siege.Operator(
            "Wamai",
            [
                siege.Weapon(
                    "AUG A2",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    42,
                    720,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator,
                    0,
                    true,
                    codebase.math.roundMultiple(1470, 60),
                    codebase.math.roundMultiple(2340, 60)
                ),
                siege.Weapon(
                    "MP5K",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    30,
                    800,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1280, 60),
                    codebase.math.roundMultiple(2150, 60)
                )
            ],
            [
                siege.Weapon(
                    "Keratos .357",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    78,
                    450,
                    6,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(3020, 60),
                    codebase.math.roundMultiple(3020, 60)
                ),
                siege.Weapon(
                    "P12",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1230, 60),
                    codebase.math.roundMultiple(1560, 60)
                )
            ],
            siege.Weapon.gadgets.impactgrenade | siege.Weapon.gadgets.proximityalarm,
            "Magnetic Neutralizing Electronic Targeting (Mag-NET) System",
            "NIGHTHAVEN",
            "Lamu, Kenya",
            187,
            83,
            "Ngũgĩ Muchoki Furaha",
            { month: 6, day: 1, age: 28 },
            2
        )

        static oryx := siege.Operator(
            "Oryx",
            [
                siege.Weapon(
                    "T-5 SMG",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    28,
                    900,
                    30,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1400, 60),
                    codebase.math.roundMultiple(2180, 60)
                ),
                siege.Weapon(
                    "SPAS-12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3470, 60),
                    codebase.math.roundMultiple(4430, 60)
                )
            ],
            [
                siege.Weapon(
                    "Bailiff 410",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    30,
                    485,
                    5,
                    0,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3260, 60),
                    codebase.math.roundMultiple(3370, 60)
                ),
                siege.Weapon(
                    "USP40",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    550,
                    12,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1250, 60),
                    codebase.math.roundMultiple(1410, 60)
                )
            ],
            siege.Weapon.gadgets.barbedwire | siege.Weapon.gadgets.proximityalarm,
            "Remah Dash",
            "[UNAFFILIATED]",
            "Azraq, Jordan",
            195,
            130,
            "Saif Al Hadid",
            { month: 7, day: 3, age: 45 },
            2
        )

        static melusi := siege.Operator(
            "Melusi",
            [
                siege.Weapon(
                    "MP5",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    27,
                    800,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1280, 60),
                    codebase.math.roundMultiple(2220, 60)
                ),
                siege.Weapon(
                    "Super 90",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    8,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(4320, 60),
                    codebase.math.roundMultiple(5180, 60)
                )
            ],
            [
                siege.Weapon(
                    "RG15",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    38,
                    550,
                    15,
                    siege.Weapon.sights.other,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1200, 60),
                    codebase.math.roundMultiple(1370, 60)
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera | siege.Weapon.gadgets.impactgrenade,
            "Banshee Sonic Defense",
            "INKABA TASK FORCE",
            "Louwsburg, South Africa",
            172,
            68,
            "Thandiwe Ndlovu",
            { month: 6, day: 16, age: 32 },
            3
        )

        static aruni := siege.Operator(
            "Aruni",
            [
                siege.Weapon(
                    "P10 RONI",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    26,
                    980,
                    15,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1120, 60),
                    codebase.math.roundMultiple(2200, 60)
                ),
                siege.Weapon(
                    "Mk 14 EBR",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    450,
                    20,
                    siege.Weapon.sights.x15max,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1490, 60),
                    codebase.math.roundMultiple(2440, 60)
                )
            ],
            [
                siege.Weapon(
                    "PRB92",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    450,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(1590, 60)
                )
            ],
            siege.Weapon.gadgets.barbedwire | siege.Weapon.gadgets.bulletproofcamera,
            "Surya Gate",
            "NIGHTHAVEN",
            "Ta Phraya District, Thailand",
            160,
            58,
            "Apha Tawanroong",
            { month: 8, day: 9, age: 42 },
            2
        )

        static thunderbird := siege.Operator(
            "Thunderbird",
            [
                siege.Weapon(
                    "Spear .308",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    42,
                    700,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1510, 60),
                    codebase.math.roundMultiple(2460, 60)
                ),
                siege.Weapon(
                    "SPAS-15",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    30,
                    290,
                    6,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(1180, 60),
                    codebase.math.roundMultiple(2020, 60)
                )
            ],
            [
                siege.Weapon(
                    "Bearing 9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    1100,
                    25,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.extendedbarrel,
                    0,
                    true,
                    codebase.math.roundMultiple(1300, 60),
                    codebase.math.roundMultiple(2210, 60)
                ),
                siege.Weapon(
                    "Q-929",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    550,
                    10,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1140, 60),
                    codebase.math.roundMultiple(1440, 60)
                )
            ],
            siege.Weapon.gadgets.impactgrenade | siege.Weapon.gadgets.nitrocell,
            "Kóna Healing Station",
            "STAR-NET AVIATION",
            "Nakoda Territories",
            172,
            70,
            "Mina Sky",
            { month: 4, day: 1, age: 36 },
            3
        )

        static thorn := siege.Operator(
            "Thorn",
            [
                siege.Weapon(
                    "UZK50GI",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    44,
                    700,
                    22,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1370, 60),
                    codebase.math.roundMultiple(2300, 60)
                ),
                siege.Weapon(
                    "M870",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    100,
                    7,
                    siege.Weapon.sights.nonmagmax,
                    0,
                    0,
                    true,
                    codebase.math.roundMultiple(3410, 60),
                    codebase.math.roundMultiple(4360, 60)
                )
            ],
            [
                siege.Weapon(
                    "1911 TACOPS",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    55,
                    450,
                    8,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1240, 60),
                    codebase.math.roundMultiple(1440, 60)
                ),
                siege.Weapon(
                    "C75 Auto",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    35,
                    1000,
                    26,
                    0,
                    siege.Weapon.barrels.suppressor,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(2220, 60)
                )
            ],
            siege.Weapon.gadgets.deployableshield | siege.Weapon.gadgets.barbedwire,
            "Razorbloom Shell",
            "EMERGENCY RESPONSE UNIT",
            "County Kildare, Ireland",
            188,
            78,
            "Brianna Skehan",
            { month: 6, day: 18, age: 28 },
            2
        )

        static azami := siege.Operator(
            "Azami",
            [
                siege.Weapon(
                    "9x19VSN",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    34,
                    750,
                    30,
                    siege.Weapon.sights.nonmagmax,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.flashhider | siege.Weapon.barrels.compensator | siege.Weapon.barrels.muzzlebrake | siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1430, 60),
                    codebase.math.roundMultiple(2220, 60)
                ),
                siege.Weapon(
                    "ACS12",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.fullauto,
                    69,
                    300,
                    30,
                    siege.Weapon.sights.x15max,
                    0,
                    siege.Weapon.grips.verticalgrip | siege.Weapon.grips.angledgrip,
                    true,
                    codebase.math.roundMultiple(1590, 60),
                    codebase.math.roundMultiple(2440, 60)
                )
            ],
            [
                siege.Weapon(
                    "D-50",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    71,
                    550,
                    7,
                    0,
                    siege.Weapon.barrels.suppressor | siege.Weapon.barrels.muzzlebrake,
                    0,
                    true,
                    codebase.math.roundMultiple(1320, 60),
                    codebase.math.roundMultiple(1450, 60)
                )
            ],
            siege.Weapon.gadgets.impactgrenade | siege.Weapon.gadgets.barbedwire,
            "Kiba Barrier",
            "UNAFFILIATED",
            "Kyoto, Japan",
            164,
            56.7,
            "Kana Fujiwara",
            { month: 9, day: 6, age: 28 },
            2
        )

        /**
         * A list of all the Operator objects defined above. Has to be an Array as the order technically matters when filtering Operators. As such, filtering must be done using the Operators' `nickname` prop as mapping the `Operator` objects to their nicknames for easier access is not possible (AHKv2 `Map`s are not ordered).
         */
        static list := [
            siege.defenders.smoke,
            siege.defenders.mute,
            siege.defenders.castle,
            siege.defenders.pulse,
            siege.defenders.doc,
            siege.defenders.rook,
            siege.defenders.kapkan,
            siege.defenders.tachanka,
            siege.defenders.jäger,
            siege.defenders.bandit,
            siege.defenders.frost,
            siege.defenders.valkyrie,
            siege.defenders.caveira,
            siege.defenders.echo,
            siege.defenders.mira,
            siege.defenders.lesion,
            siege.defenders.ela,
            siege.defenders.vigil,
            siege.defenders.maestro,
            siege.defenders.alibi,
            siege.defenders.clash,
            siege.defenders.kaid,
            siege.defenders.mozzie,
            siege.defenders.warden,
            siege.defenders.goyo,
            siege.defenders.wamai,
            siege.defenders.oryx,
            siege.defenders.melusi,
            siege.defenders.aruni,
            siege.defenders.thunderbird,
            siege.defenders.thorn,
            siege.defenders.azami
        ]
        __Enum(p*) => siege.defenders.list.__Enum(p*)
        __New(*) => siege.defenders.list.__Enum(1)
        __Call(*) => siege.defenders.list.__Enum(1)
    }

    class challenges
    {
        static challengeObjectiveMultiplier := 3

        static winRoundsWith()
        {
            s := "Win {n} rounds with {o1}, {o2}, {o3} or {o4}."
            obj := {
                n: Random(1, 2) * siege.challenges.challengeObjectiveMultiplier,
                o1: siege.randomOperator(siege.attackers).op.nickname,
            }
            obj.o2 := siege.randomOperator(siege.attackers, false, [obj.o1]).op.nickname,
            obj.o3 := siege.randomOperator(siege.defenders, false, [obj.o1, obj.o2]).op.nickname,
            obj.o4 := siege.randomOperator(siege.defenders, false, [obj.o1, obj.o2, obj.o3]).op.nickname
            codebase.stringOperations.strComposite(&s, obj)
            return s
        }
        static wepTypeElims()
        {
            tpe := ""
            while (tpe == "")
            {
                for i in codebase.range(1, siege.Weapon.types.listName.Length)
                {
                    n := siege.Weapon.types.listName[i]
                    v := siege.Weapon.types.listValue[i]

                    if (n == "Hand Cannon") ; || n == "Shield" !?
                    {
                        continue
                    }
                    if (!Mod(Random(0, 100), 3))
                    {
                        tpe := n . "s"
                    }
                }
            }
            s := "Eliminate " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " opponents with " . tpe . "."
            return s
        }
        static orgActiveDuty()
        {
            ; Get random organization
            orgs := []
            for op in siege.defatk
            {
                if (!(codebase.collectionOperations.arrayOperations.arrayContains(orgs, op.organization).Length))
                {
                    orgs.Push(op.organization)
                }
            }
            org := orgs[Random(1, orgs.Length)]

            ; Get all Operators from this organization
            ops := []
            for op in siege.defatk
            {
                if (op.organization == org && !(codebase.collectionOperations.arrayOperations.arrayContains(ops, op.nickname).Length))
                {
                    ops.Push(op.nickname)
                }
            }

            ; Determine how many Operators there are and construct an output string accordingly
            s := "{o} Active Duty: Win {n} rounds with {o1}"
            if (ops.Length > 1)
            {
                if (ops.Length > 2)
                {
                    if (ops.Length > 3)
                    {
                        s .= ", {o2}, {o3} or {o4}."
                    }
                    else
                    {
                        s .= ", {o2} or {o3}."
                    }
                }
                else
                {
                    s .= " or {o2}."
                }
            }
            else
            {
                s .= "."
            }
            obj := {
                o: org,
                n: Random(1, 2) * siege.challenges.challengeObjectiveMultiplier
            }
            for op in ops
            {
                obj.DefineProp("o" . A_Index, { Value: op })
            }
            codebase.stringOperations.strComposite(&s, obj)
            return s
        }
        static antiProjectile() => "Destroy " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " Attacker projectiles using Jäger's ADS-Mk IV, Wamai's Mag-NET Systems or Aruni's Surya Gates."
        static areaDenial() => "Damage or perform area denial against " . Random(2, 3) * siege.challenges.challengeObjectiveMultiplier . " opponents using Smoke's Z8 Gas Grenades, Tachanka's Shumikha Grenade Launcher, Goyo's Volcán Canisters, Capitão's Asphyxiating Bolts or Gridlock's Trax Stingers."
        static chemicalBonds() => "Eliminate, incapacitate or damage " . Random(2, 3) * siege.challenges.challengeObjectiveMultiplier . " opponents with Smoke's Z8 Gas Grenades or Lesion's Gu Mines. Eliminations and incapacitations count as 2 towards this."
        static deployCams() => "Deploy " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " Bulletproof Cameras, Valkyrie's Black Eyes, Maestro's Evil Eyes or Zero's Argus Cameras."
        static destroyObservation() => "Destroy " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " Defender cameras, Bulletproof Cameras, Valkyrie's Black Eyes, Echo's Yokai, Maestro's Evil Eyes or drones hacked by Mozzie's Pest as an Attacker."
        static disorient() => "Disorient " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " opponents with Zofia's Grzmot Grenades, Nomad's Airjabs, Echo's Yokai Sonic Burst, Ela's Grzmot Mines or Oryx's Remah Dash."
        static explosiveKills() => "Eliminate " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " opponents with Impact Grenades, Nitro Cells, Frag Grenades, Fuze's Cluster Charges, Flores's RCE-Ratero Charges, Kapkan's Entry Denial Devices or Thorn's Razorbloom Shells."
        static hardBreach() => "Breach " . Random(1, 3) * siege.challenges.challengeObjectiveMultiplier . " reinforced walls with Thermite's Exothermic Charges, Hibana's X-KAIROs, Ace's S.E.L.M.A. Aqua Breachers or Hard Breach Charges."
        static headshots() => "Headshot " . Random(2, 3) * siege.challenges.challengeObjectiveMultiplier . " opponents."
        static heal() => "Heal " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " teammates with Finka's Adrenal Surge, Doc's Stim Pistol or Thunderbird's KÓNA Stations. Revives count as 2 towards this."
        static kills() => "Kill " . Random(2, 4) * siege.challenges.challengeObjectiveMultiplier . " opponents."
        static matches() => (Mod(Random(0, 100), 3) ? "Play " : "Win ") . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . ((h := Random(1, 100)) <= 10 ? " Ranked" : (h <= 50 ? " Unranked" : " Casual")) . " matches."
        static reveal() => "Reveal " . Random(2, 4) * siege.challenges.challengeObjectiveMultiplier . " opponents by scanning them in cameras or pinging their special abilities."
        static role() => "Win " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " rounds as a" . (Random(1, 100) <= 50 ? "n Attacker" : " Defender") . "."
        static stun() => "Stun " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " opponents with Stun Grenades, Blitz's G52-Tactical Shield or Ying's Candelas."
        static suppressed() => "Eliminate " . Random(2, 3) * siege.challenges.challengeObjectiveMultiplier . " opponents with suppressed weapons."
        static techAttackAtk() => "Destroy, disable or render " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " Defender gadgets useless using Thatcher's EG Mk 0-EMP Grenades, Twitch's RSD Model 1 Shock Drones, Kali's LV Explosive Lance or Zero's Argus Cameras."
        static techAttackDef() => "Destroy, disable or render " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " Attacker gadgets useless using Mute's GC90 Signal Disruptors, Bandit's CED-1 Shock Wires or Kaid's Rtila Electroclaws or by hacking Attacker drones using Mozzie's Pest."
        static trapper() => "Eliminate or incapacitate " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " opponents with Kapkan's Entry Denial Devices, Frost's Welcome Mats, Goyo's Volcán Canisters, Thorn's Razorbloom Shells or during and after they are tracked by Alibi's Primas. Eliminations count as 2 towards this."
        static unauthorizedAccess() => "Hack into Defender cameras as Dokkaebi or hack an Attacker drone as Mozzie " . Random(1, 2) * siege.challenges.challengeObjectiveMultiplier . " times."
        static wallbangs() => ""

        static weeklyChallengeSet() => codebase.stringOperations.strJoin("`n", false,
            siege.challenges.wepTypeElims(),
            siege.challenges.orgActiveDuty(),
            siege.challenges.orgActiveDuty(),
            siege.challenges.orgActiveDuty(), ; 3rd time replaces thunt challenge because who tf plays thunt except for the actual challenges
            siege.challenges.role()
        )

        static list := [
            siege.challenges.antiProjectile,
            siege.challenges.areaDenial,
            siege.challenges.chemicalBonds,
            siege.challenges.deployCams,
            siege.challenges.destroyObservation,
            siege.challenges.disorient,
            siege.challenges.explosiveKills,
            siege.challenges.hardBreach,
            siege.challenges.headshots,
            siege.challenges.heal,
            siege.challenges.kills,
            siege.challenges.matches,
            siege.challenges.orgActiveDuty,
            siege.challenges.reveal,
            siege.challenges.role,
            siege.challenges.stun,
            siege.challenges.suppressed,
            siege.challenges.techAttackAtk,
            siege.challenges.techAttackDef,
            siege.challenges.trapper,
            siege.challenges.unauthorizedAccess,
            siege.challenges.wepTypeElims,
            siege.challenges.winRoundsWith,
        ]
    }

    static randomBPChallengeSet()
    {
        out := []
        possible := siege.challenges.list.Clone()

        Loop 3
        {
            r := Random(1, possible.Length)
            out.Push(possible[r].Call({ }))
            possible.RemoveAt(r) ; Allow one type of challenge only once
        }

        return out
    }

    static anyRandom()
    {
        opClass := (Mod(Random(0, 100), 2) ? siege.attackers : siege.defenders)
        return siege.randomOperator(opClass).op
    }

    /**
     * Gets a random Operator from one of the Operator classes and randomizes their loadout.
     * @param opClass Which class to pull an Operator from. Value must be one of the following: `siege.attackers`, `siege.defenders`.
     * @param stringOutput Whether to return a string identifying the generated loadout instead of an object with that same data. Defaults to `false` if omitted.
     * @param omit An Array of Operator names that will cause a repick, i.e. which will be guaranteed _not_ to be returned. Defaults to none if omitted.
     * @returns An object identifying the generated loadout if `stringOutput` is falsey.
     * @returns A string identifying the generated loadout if `stringOutput` is truthy.
     */
    static randomOperator(opClass, stringOutput := false, omit := unset)
    {
        local op
        pick()
        {
            op := { op: opClass.list[Random(1, opClass.list.Length)] }
            op.DefineProp("loadout", { Value: op.op.randomizeLoadout(stringOutput) })
            if (stringOutput)
            {
                op := "`nOperator: " . op.op.nickname . "`n" . op.loadout
            }
        }

        if (!IsSet(omit))
        {
            omit := []
        }

        repick := true
        while (repick)
        {
            pick()
            repick := false

            for x in omit
            {
                if (x == "")
                {
                    continue
                }

                if (InStr((stringOutput ? op : op.op.nickname), x))
                {
                    repick := true
                }
            }
        }
        return op
    }

    class BattlePass
    {
        class Tier
        {
            class Reward
            {
                class rarities
                {
                    /**
                    * Identifies a reward that has no associated rarity. Use bitwise-and `&` to check whether a reward's `rarity` prop matches this flag.
                    */
                    static none := codebase.Binary("000001").Value()
                    /**
                    * Identifies a common reward. Use bitwise-and `&` to check whether a reward's `rarity` prop matches this flag.
                    */
                    static common := codebase.Binary("000010").Value()
                    /**
                    * Identifies an uncommon reward. Use bitwise-and `&` to check whether a reward's `rarity` prop matches this flag.
                    */
                    static uncommon := codebase.Binary("000100").Value()
                    /**
                    * Identifies a rare reward. Use bitwise-and `&` to check whether a reward's `rarity` prop matches this flag.
                    */
                    static rare := codebase.Binary("001000").Value()
                    /**
                    * Identifies an epic reward. Use bitwise-and `&` to check whether a reward's `rarity` prop matches this flag.
                    */
                    static epic := codebase.Binary("010000").Value()
                    /**
                    * Identifies a legendary reward. Use bitwise-and `&` to check whether a reward's `rarity` prop matches this flag.
                    */
                    static legendary := codebase.Binary("100000").Value()

                    static list := Map(
                        "None", siege.BattlePass.Tier.Reward.rarities.none,
                        "Common", siege.BattlePass.Tier.Reward.rarities.common,
                        "Uncommon", siege.BattlePass.Tier.Reward.rarities.uncommon,
                        "Rare", siege.BattlePass.Tier.Reward.rarities.rare,
                        "Epic", siege.BattlePass.Tier.Reward.rarities.epic,
                        "Legendary", siege.BattlePass.Tier.Reward.rarities.legendary
                    )
                }

                class types
                {
                    /**
                    * Identifies the Bundle reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static bundle := codebase.Binary("0000000000001").Value()
                    /**
                    * Identifies the Headgear reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static headgear := codebase.Binary("0000000000010").Value()
                    /**
                    * Identifies the Uniform reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static uniform := codebase.Binary("0000000000100").Value()
                    /**
                    * Identifies the R6 Credits reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static credits := codebase.Binary("0000000001000").Value()
                    /**
                    * Identifies the Charm reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static charm := codebase.Binary("0000000010000").Value()
                    /**
                    * Identifies the Weapon Skin reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static weapon := codebase.Binary("0000000100000").Value()
                    /**
                    * Identifies the Attachment Skin reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static attachment := codebase.Binary("0000001000000").Value()
                    /**
                    * Identifies the Card Background reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static background := codebase.Binary("0000010000000").Value()
                    /**
                    * Identifies the Operator Portrait reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static portrait := codebase.Binary("0000100000000").Value()
                    /**
                    * Identifies the Alpha Pack reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static alpha := codebase.Binary("0001000000000").Value()
                    /**
                    * Identifies the Bravo Pack reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static bravo := codebase.Binary("0010000000000").Value()
                    /**
                    * Identifies the Renown Booster reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static boosterRenown := codebase.Binary("0100000000000").Value()
                    /**
                    * Identifies the Battle Point Booster reward type. Use bitwise-and `&` to check whether a reward's `type` prop matches this flag.
                    */
                    static boosterBP := codebase.Binary("1000000000000").Value()

                    static list := Map(
                        "Bundle", siege.BattlePass.Tier.Reward.types.bundle,
                        "Headgear", siege.BattlePass.Tier.Reward.types.headgear,
                        "Uniform", siege.BattlePass.Tier.Reward.types.uniform,
                        "R6 Credits", siege.BattlePass.Tier.Reward.types.credits,
                        "Charm", siege.BattlePass.Tier.Reward.types.charm,
                        "Weapon Skin", siege.BattlePass.Tier.Reward.types.weapon,
                        "Attachment Skin", siege.BattlePass.Tier.Reward.types.attachment,
                        "Card Background", siege.BattlePass.Tier.Reward.types.background,
                        "Operator Portrait", siege.BattlePass.Tier.Reward.types.portrait,
                        "Alpha Pack", siege.BattlePass.Tier.Reward.types.alpha,
                        "Bravo Pack", siege.BattlePass.Tier.Reward.types.bravo,
                        "Renown Booster", siege.BattlePass.Tier.Reward.types.boosterRenown,
                        "Battle Point Booster", siege.BattlePass.Tier.Reward.types.boosterBP
                    )
                }

                /**
                 * The name of the reward item.
                 */
                name := ""
                /**
                 * The value of a `codebase.Binary` object to indicate which type of reward it is.
                 */
                type := ""
                /**
                 * The value of a `codebase.Binary` object to indicate which rarity the reward has.
                 */
                rarity := ""
                /**
                 * Any value to provide extra information about the reward. The meaning of this value depends on `this.type`:
                 * - `siege.BattlePass.Tier.Reward.types.bundle`: An Array of further `siege.BattlePass.Tier.Reward` objects to identify the bundle's contents.
                 * - `siege.BattlePass.Tier.Reward.types.headgear`: None.
                 * - `siege.BattlePass.Tier.Reward.types.uniform`: None.
                 * - `siege.BattlePass.Tier.Reward.types.credits`: The amount of R6 credits.
                 * - `siege.BattlePass.Tier.Reward.types.charm`: None.
                 * - `siege.BattlePass.Tier.Reward.types.weapon`: Which weapon the skin is for. None if universal, "Seasonal" if seasonal (all weapons up to this season).
                 * - `siege.BattlePass.Tier.Reward.types.attachment`: Which weapon the attachment skin is for. None if universal.
                 * - `siege.BattlePass.Tier.Reward.types.background`: Which Operator the card background can be used with. None if universal.
                 * - `siege.BattlePass.Tier.Reward.types.portrait`: Which Operator the portrait picture is for.
                 * - `siege.BattlePass.Tier.Reward.types.alpha`: None.
                 * - `siege.BattlePass.Tier.Reward.types.bravo`: None.
                 * - `siege.BattlePass.Tier.Reward.types.boosterRenown`: The active duration of this booster in days.
                 * - `siege.BattlePass.Tier.Reward.types.boosterBP`: The active duration of this booster in days.
                 */
                extra := ""

                /**
                 * Instantiates a new `siege.BattlePass.Tier.Reward` object.
                 * @param name The name of the reward item.
                 * @param typ The value of a `codebase.Binary` object to indicate which type of reward it is.
                 * @param rarity The value of a `codebase.Binary` object to indicate which rarity the reward item has.
                 * @param extra Any value to provide extra information about the reward. The meaning of this value depends on `this.type`.
                 * @returns A `siege.BattlePass.Tier.Reward` object.
                 */
                __New(name, type, rarity, extra)
                {
                    this.name := name
                    this.type := type
                    this.rarity := rarity
                    this.extra := extra
                }
            }

            /**
             * An Array of `siege.BattlePass.Tier.Reward` objects to identify the rewards of this tier for all players.
             * @note This is always an Array to allow for programmatic checking for specific reward types etc. without having to ensure an existing value using `IsSet` or similar.
             */
            free := []
            /**
             * An Array of `siege.BattlePass.Tier.Reward` objects to identify the rewards of this tier for players who have bought the premium Battle Pass.
             * @note This is always an Array to allow for programmatic checking for specific reward types etc. without having to ensure an existing value using `IsSet` or similar.
             */
            premium := []

            /**
             * Instantiates a new `siege.BattlePass.Tier` object.
             * @param free An Array of `siege.BattlePass.Tier.Reward` objects to identify the rewards of this tier for all players.
             * @param premium An Array of `siege.BattlePass.Tier.Reward` objects to identify the rewards of this tier for players who have bought the premium Battle Pass.
             * @note Both are always Arrays to allow for programmatic checking for specific reward types etc. without having to ensure an existing value using `IsSet` or similar.
             * @returns A `siege.BattlePass.Tier` object.
             */
            __New(free, premium)
            {
                this.free := free
                this.premium := premium
            }
        }

        /**
         * An Array of `siege.BattlePass.Tier` objects to identify the tiers this Battle Pass contains.
         * @note A complete Battle Pass has 100 tiers, hence a complete `siege.BattlePass` object is expected to have exactly 100 objects.
         */
        tiers := []
        __Enum(v) => this.tiers.__Enum(v)
        __Item(v*) => this.tiers[v*]

        /**
         * Instantiates a new `siege.BattlePass` object.
         * @note AHKv2 does not support creating a complete `siege.BattlePass` object in one constructor call due to the length of the declaration. Use the method `siege.BattlePass.addTiers` instead as it is not subject to this limitation.
         */
        __New()
        {

        }

        addTiers(tiers*)
        {
            for tier in tiers
            {
                this.tiers.Push(tier)
            }
            return (this.tiers.Length == 100 ? true : !MsgBox("Incomplete Battle Pass, received " . this.tiers.Length . " instead of 100 ``siege.BattlePass.Tiers`` objects."))
        }

        static Y7S2 := siege.BattlePass()
        static Y7S3 := siege.BattlePass()

        /*
         * Has no value. Exists to call the function `siege.BattlePass._init()` which populates the following static fields:
         * - `siege.BattlePass.Y7S2`
         * - `siege.BattlePass.Y7S3`
         */
        static init := siege.BattlePass._init()
        static _init()
        {
            siege.BattlePass.Y7S2.addTiers(
                siege.BattlePass.Tier( ; 1
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Sens Daylight Bundle",
                            siege.BattlePass.Tier.Reward.types.bundle,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            [
                                siege.BattlePass.Tier.Reward(
                                    "Daylight Shift",
                                    siege.BattlePass.Tier.Reward.types.headgear,
                                    siege.BattlePass.Tier.Reward.rarities.rare,
                                    siege.attackers.sens
                                ),
                                siege.BattlePass.Tier.Reward(
                                    "Daylight Shift",
                                    siege.BattlePass.Tier.Reward.types.uniform,
                                    siege.BattlePass.Tier.Reward.rarities.rare,
                                    siege.attackers.sens
                                )
                            ]
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 2
                    [
                        siege.BattlePass.Tier.Reward(
                            "Otorongo",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.amaru
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.defenders.doc
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 3
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "R6 Credits",
                            siege.BattlePass.Tier.Reward.types.credits,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            120
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 4
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Doc",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 5
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Experimental Unit",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            "P90"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 6
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Lifeline",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.defenders.doc
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 7
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Jaguar Claw",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 8
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Experimental Unit",
                            siege.BattlePass.Tier.Reward.types.attachment,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "P90"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 9
                    [
                        siege.BattlePass.Tier.Reward(
                            "Otorongo",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.amaru
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 10
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Battle Point Booster",
                            siege.BattlePass.Tier.Reward.types.boosterBP,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            3
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 11
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "SG-CQB"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 12
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.sens
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 13
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolf Support",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 14
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Otorongo",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.amaru
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 15
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 16
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "R6 Credits",
                            siege.BattlePass.Tier.Reward.types.credits,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            120
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 17
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.defenders.doc
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 18
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "Spear .308"
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 19
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Lliqlla Strips",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "G8A1"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 20
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.defenders.doc
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 21
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Sens",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 22
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.defenders.thunderbird
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 23
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.sens
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 24
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 25
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Panthera Onca",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.amaru
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 26
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Battle Point Booster",
                            siege.BattlePass.Tier.Reward.types.boosterBP,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            3
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 27
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Tech",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 28
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.twitch
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 29
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "POF-9"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 30
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.defenders.clash
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 31
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.thunderbird
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 32
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.twitch
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 33
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 34
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Screen",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.sens
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 35
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "SPSMG9"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 36
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Thunderbird",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 37
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "F2"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 38
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.clash
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 39
                    [
                        siege.BattlePass.Tier.Reward(
                            "Tunnel Look",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.defenders.frost
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 40
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Battle Point Booster",
                            siege.BattlePass.Tier.Reward.types.boosterBP,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            3
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 41
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolf Tooth",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 42
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 43
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "R6 Credits",
                            siege.BattlePass.Tier.Reward.types.credits,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            120
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 44
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Clash",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 45
                    [
                        siege.BattlePass.Tier.Reward(
                            "Mud-Soaked",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "MP7"
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 46
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.sens
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 47
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Leather-Stitched",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.castle
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 48
                    [
                        siege.BattlePass.Tier.Reward(
                            "Gas Lamp",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 49
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            "Le Roc Shield"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 50
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Azure Ward",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "Seasonal"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 51
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 52
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Leather-Stitched",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.castle
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 53
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Azure Ward",
                            siege.BattlePass.Tier.Reward.types.attachment,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 54
                    [
                        siege.BattlePass.Tier.Reward(
                            "Powder Flask",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 55
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Tunnel Lock",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.defenders.frost
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 56
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Animal Hide",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "UMP45"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 57
                    [
                        siege.BattlePass.Tier.Reward(
                            "Tourniquet",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 58
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Sapper Unit",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.bandit
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 59
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Leather-Stitched",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.castle
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 60
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 61
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.montagne
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 62
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Dirt-Encrusted",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "9mm C1"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 63
                    [
                        siege.BattlePass.Tier.Reward(
                            "Radiant Dignity",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "MP5"
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 64
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Canis Lupus",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.castle
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 65
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Sapper Unit",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.defenders.bandit
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 66
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Montagne",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 67
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.ying
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 68
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Gemmed Talisman",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 69
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 70
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "R6 Credits",
                            siege.BattlePass.Tier.Reward.types.credits,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            120
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 71
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Gold Leaf",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.defenders.melusi
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 72
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 73
                    [
                        siege.BattlePass.Tier.Reward(
                            "Gold Leaf",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.melusi
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 74
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Anemometer",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 75
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 76
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "T-95 LSW"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 77
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.montagne
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 78
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 79
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Ying",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 80
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.attackers.lion
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 81
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 82
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Sight",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.attackers.lion
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 83
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "V308"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 84
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 85
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Digger Work",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.nomad
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 86
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Aurous Growth",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.melusi
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 87
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 88
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Lion",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 89
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Digger Work",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.nomad
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 90
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 91
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Gold Leaf",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.melusi
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 92
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.ying
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 93
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 94
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Soil-Caked",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "AK-74M"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 95
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Defensive Scheme",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 96
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 97
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "R6 Credits",
                            siege.BattlePass.Tier.Reward.types.credits,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            120
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 98
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Threat Assessment",
                            siege.BattlePass.Tier.Reward.types.attachment,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "UMP45"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 99
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.attackers.lion
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 100
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wolfguard Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.attackers.lion
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Threat Assessment",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            "UMP45"
                        )
                    ]
                )
            )

            siege.BattlePass.Y7S3.addTiers(
                siege.BattlePass.Tier( ; 1
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Grim Toxin Bundle",
                            siege.BattlePass.Tier.Reward.types.bundle,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            [
                                siege.BattlePass.Tier.Reward(
                                    "Bog Venom",
                                    siege.BattlePass.Tier.Reward.types.headgear,
                                    siege.BattlePass.Tier.Reward.rarities.rare,
                                    siege.attackers.grim
                                ),
                                siege.BattlePass.Tier.Reward(
                                    "Bog Venom",
                                    siege.BattlePass.Tier.Reward.types.uniform,
                                    siege.BattlePass.Tier.Reward.rarities.rare,
                                    siege.attackers.grim
                                )
                            ]
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 2
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.kali
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Undersea Sunburst",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.finka
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 3
                    [

                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "R6 Credits",
                            siege.BattlePass.Tier.Reward.types.credits,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            120
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 4
                    [
                        siege.BattlePass.Tier.Reward(
                            "Orange Mollusk",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 5
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Haven Troubleshooter",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            "M590A1"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 6
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Entry Rays",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.defenders.smoke
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 7
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Monkey Pin",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 8
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Haven Troubleshooter",
                            siege.BattlePass.Tier.Reward.types.attachment,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "M590A1"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 9
                    [
                        siege.BattlePass.Tier.Reward(
                            "Civilized Wilderness",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.kali
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 10
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Battle Point Booster",
                            siege.BattlePass.Tier.Reward.types.boosterBP,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            3
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 11
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Elegans Aurantiacus",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "Spear .308"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 12
                    [
                        siege.BattlePass.Tier.Reward(
                            "Carapace Casing",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.grim
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 13
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Fanned Favorite",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 14
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.kali
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 15
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 16
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "R6 Credits",
                            siege.BattlePass.Tier.Reward.types.credits,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            120
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 17
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Aerated Body Armor",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.defenders.smoke
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 18
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "P10 RONI"
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 19
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.kali
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 20
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Undersea Sunburst",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.finka
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 21
                    [
                        siege.BattlePass.Tier.Reward(
                            "Techno-Bee",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 22
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.defenders.aruni
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 23
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Carapace Casing",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.grim
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 24
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 25
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Standard",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.kali
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 26
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Battle Point Booster",
                            siege.BattlePass.Tier.Reward.types.boosterBP,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            3
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 27
                    [
                        siege.BattlePass.Tier.Reward(
                            "Skydiving Pin",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 28
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "High Altitude Specs",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.ace
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 29
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "QCR-Supplied Wrecker",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "SG-CQB"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 30
                    [
                        siege.BattlePass.Tier.Reward(
                            "High Altitude Specs",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.ace
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 31
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.defenders.aruni
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 32
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Aerated Body Armor",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.defenders.smoke
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 33
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 34
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Harbored Anchorage",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.grim
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 35
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "QCR-Supplied Crossfire",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "SMG-11"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 36
                    [
                        siege.BattlePass.Tier.Reward(
                            "Hummingbird Pin",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 37
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Rough Skies",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "AK-12"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 38
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Aerated Body Armor",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.defenders.smoke
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 39
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.pulse
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 40
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Battle Point Booster",
                            siege.BattlePass.Tier.Reward.types.boosterBP,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            3
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 41
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Color Delivery",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 42
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 43
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "R6 Credits",
                            siege.BattlePass.Tier.Reward.types.credits,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            120
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 44
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Secured Canister",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 45
                    [
                        siege.BattlePass.Tier.Reward(
                            "Cloud Jumper",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.ace
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 46
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Carapace Casing",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.grim
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 47
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wearable Canvas",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.ela
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 48
                    [
                        siege.BattlePass.Tier.Reward(
                            "Beetle Pin",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 49
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "High Altitude Specs",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.ace
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 50
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Poisonous Membrane",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            "Seasonal"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 51
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 52
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wearable Canvas",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.defenders.ela
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 53
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Poisonous Membrane",
                            siege.BattlePass.Tier.Reward.types.attachment,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 54
                    [
                        siege.BattlePass.Tier.Reward(
                            "Komodo Pin",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 55
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.pulse
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 56
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wall-Marker",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "Scorpion Evo 3 A1"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 57
                    [
                        siege.BattlePass.Tier.Reward(
                            "Snake Bite",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 58
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.defenders.wamai
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 59
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Wearable Canvas",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.ela
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 60
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 61
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Undersea Nebula",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.iq
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 62
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "M1014"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 63
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "556XI"
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 64
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Street Artist",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.ela
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 65 TODO
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.defenders.wamai
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 66
                    [
                        siege.BattlePass.Tier.Reward(
                            "Blue Mollusk",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 67
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Tech",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 68
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Otter Pin",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.uncommon,
                            "MP5K"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 69
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 70
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "R6 Credits",
                            siege.BattlePass.Tier.Reward.types.credits,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            120
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 71
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Standard",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.osa
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 72
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 73
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nightghaven Standard",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.osa
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 74
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Elegans Caeruleum",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "AUG A2"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 75
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 76
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Fisherman Dream",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.thatcher
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 77
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Undersea Nebula",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.iq
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 78
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 79
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Antique Reel",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 80
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Unknown Guest",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.attackers.nokk
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 81
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 82
                    [
                        siege.BattlePass.Tier.Reward(
                            "Redacted Operation",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.attackers.nokk
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 83
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Compact Intruder",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "D-50"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 84
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 85
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Hunter's Tartan",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.thatcher
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 86
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Enclosed Growth",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.osa
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 87
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 88
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Keyring Drive",
                            siege.BattlePass.Tier.Reward.types.charm,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 89
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Gwlanen Finish",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            "AR33"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 90
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 91
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Nighthaven Standard",
                            siege.BattlePass.Tier.Reward.types.portrait,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            siege.attackers.osa
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 92
                    [
                        siege.BattlePass.Tier.Reward(
                            "Hunter's Tartan",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.thatcher
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 93
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Bravo Pack",
                            siege.BattlePass.Tier.Reward.types.bravo,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 94
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Hunter's Tartan",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.rare,
                            siege.attackers.thatcher
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 95
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Natural Flow",
                            siege.BattlePass.Tier.Reward.types.background,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 96
                    [
                        siege.BattlePass.Tier.Reward(
                            "Alpha Pack",
                            siege.BattlePass.Tier.Reward.types.alpha,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Renown Booster",
                            siege.BattlePass.Tier.Reward.types.boosterRenown,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            1
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 97
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "R6 Credits",
                            siege.BattlePass.Tier.Reward.types.credits,
                            siege.BattlePass.Tier.Reward.rarities.none,
                            ""
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 98
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Cloaked Interloper",
                            siege.BattlePass.Tier.Reward.types.attachment,
                            siege.BattlePass.Tier.Reward.rarities.epic,
                            "FMG-9"
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 99
                    [
                        
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Unknown Guest",
                            siege.BattlePass.Tier.Reward.types.uniform,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.attackers.nokk
                        )
                    ]
                ),
                siege.BattlePass.Tier( ; 100
                    [
                        siege.BattlePass.Tier.Reward(
                            "Unknown Guest",
                            siege.BattlePass.Tier.Reward.types.headgear,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            siege.attackers.nokk
                        )
                    ],
                    [
                        siege.BattlePass.Tier.Reward(
                            "Cloaked Interloper",
                            siege.BattlePass.Tier.Reward.types.weapon,
                            siege.BattlePass.Tier.Reward.rarities.legendary,
                            "FMG-9"
                        )
                    ]
                )
            )
        }
    }

    class AlphaPackTracker
    {
        static baseChances := [
            "Common", 0.2672413793,
            "Uncommon", 0.224137931,
            "Rare", 0.2844827586,
            "Epic", 0.1724137931,
            "Legendary", 0.05172413793
        ]

        static flags := {
            rarity: {
                common: codebase.Binary("00001").Value(),
                uncommon: codebase.Binary("00010").Value(),
                rare: codebase.Binary("00100").Value(),
                epic: codebase.Binary("01000").Value(),
                legendary: codebase.Binary("10000").Value()
            },
            kind: {
                charm: codebase.Binary("00001").Value(),
                weapon: codebase.Binary("00010").Value(),
                headgear: codebase.Binary("00100").Value(),
                uniform: codebase.Binary("01000").Value(),
                unset: codebase.Binary("10000").Value()
            }
        }

        class Roll
        {
            __New(rarity, kind, duplicate)
            {
                this.rarity := rarity
                this.kind := kind
                this.duplicate := duplicate
            }
        }

        __New()
        {
            siege.AlphaPackTracker.flags.kind.DefineProp("list", { Value: [siege.AlphaPackTracker.flags.kind.charm, siege.AlphaPackTracker.flags.kind.weapon, siege.AlphaPackTracker.flags.kind.headgear, siege.AlphaPackTracker.flags.kind.uniform] })
            this.apgui := Gui(, "Alpha Pack Opening Tracker")
            this.rolls := []
            this.kinds := Map()
            this.kindsCounts := Map()

            xbase := 10
            ybase := 10
            w := 100
            
            offset := ybase
            this.common := this.apgui.Add("Button", "x" . xbase . " y" . offset - 1 . " w" . w . " r1", "Common")
            this.common.OnEvent("Click", (*) => this.registerAP(&this, this.common))
            this.commonCount := this.apgui.Add("Edit", "x" . xbase + 5 + w . " y" . offset . " w30 r1 ReadOnly", "0")

            offset += 25
            this.uncommon := this.apgui.Add("Button", "x" . xbase . " y" . offset - 1 . " w" . w . " r1", "Uncommon")
            this.uncommon.OnEvent("Click", (*) => this.registerAP(&this, this.uncommon))
            this.uncommonCount := this.apgui.Add("Edit", "x" . xbase + 5 + w . " y" . offset . " w30 r1 ReadOnly", "0")

            this.apgui.Add("Text", "x" . xbase + 40 + w . " y" . offset + 3 . " w" . w / 2 . " r1 Right", "Charm  ")
            this.kindsCounts.Set("Charm", this.apgui.Add("Edit", "x" . xbase + 40 + 1.5 * w . " y" . offset . " w" . w / 2 . " r1 ReadOnly", "0"))
            this.apgui.Add("Text", "x" . xbase + 40 + 2 * w . " y" . offset + 3 . " w" . w / 2 . " r1 Right", "Weapon  ")
            this.kindsCounts.Set("Weapon", this.apgui.Add("Edit", "x" . xbase + 40 + 2.5 * w . " y" . offset . " w" . w / 2 . " r1 ReadOnly", "0"))

            offset += 25
            this.rare := this.apgui.Add("Button", "x" . xbase . " y" . offset - 1 . " w" . w . " r1", "Rare")
            this.rare.OnEvent("Click", (*) => this.registerAP(&this, this.rare))
            this.rareCount := this.apgui.Add("Edit", "x" . xbase + 5 + w . " y" . offset . " w30 r1 ReadOnly", "0")

            this.kinds.Set("Charm", this.apgui.Add("Radio", "x" . xbase + 84 + w . " y" . offset - 1 . " w15 r1 Center"))
            this.kinds.Set("Weapon", this.apgui.Add("Radio", "x" . xbase + 84 + 2 * w . " y" . offset - 1 . " w15 r1 Center"))
            this.kinds.Set("Headgear", this.apgui.Add("Radio", "x" . xbase + 84 + w . " y" . (offset + 75) - 1 . " w15 r1 Center"))
            this.kinds.Set("Uniform", this.apgui.Add("Radio", "x" . xbase + 84 + 2 * w . " y" . (offset + 75) - 1 . " w15 r1 Center"))

            offset += 25
            this.epic := this.apgui.Add("Button", "x" . xbase . " y" . offset - 1 . " w" . w . " r1", "Epic")
            this.epic.OnEvent("Click", (*) => this.registerAP(&this, this.epic))
            this.epicCount := this.apgui.Add("Edit", "x" . xbase + 5 + w . " y" . offset . " w30 r1 ReadOnly", "0")

            this.dupe := this.apgui.Add("Checkbox", "x" . xbase + w + 45 . " y" . offset, "Duplicate")

            offset += 25
            this.blackice := this.apgui.Add("Button", "x" . xbase . " y" . offset - 1 . " w" . w . " r1", "Black Ice")
            this.blackice.OnEvent("Click", (*) => this.registerAP(&this, this.blackice))
            this.blackiceCount := this.apgui.Add("Edit", "x" . xbase + 5 + w . " y" . offset . " w30 r1 ReadOnly", "0")

            this.apgui.Add("Text", "x" . xbase + 40 + w . " y" . offset + 3 . " w" . w / 2 . " r1 Right", "Headgear ")
            this.kindsCounts.Set("Headgear", this.apgui.Add("Edit", "x" . xbase + 40 + 1.5 * w . " y" . offset . " w" . w / 2 . " r1 ReadOnly", "0"))
            this.apgui.Add("Text", "x" . xbase + 40 + 2 * w . " y" . offset + 3 . " w" . w / 2 . " r1 Right", "Uniform  ")
            this.kindsCounts.Set("Uniform", this.apgui.Add("Edit", "x" . xbase + 40 + 2.5 * w . " y" . offset . " w" . w / 2 . " r1 ReadOnly", "0"))

            offset += 25
            this.legendary := this.apgui.Add("Button", "x" . xbase . " y" . offset - 1 . " w" . w . " r1", "Legendary")
            this.legendary.OnEvent("Click", (*) => this.registerAP(&this, this.legendary))
            this.legendaryCount := this.apgui.Add("Edit", "x" . xbase + 5 + w . " y" . offset . " w30 r1 ReadOnly", "0")
            
            offset += 25
            this.totalCount := this.apgui.Add("Edit", "x" . xbase + 5 + w . " y" . offset . " w30 r1 ReadOnly")
            
            offset += 25
            this.reset := this.apgui.Add("Button", "x" . xbase . " y" . offset . " w" . 135 . " r1", "Reset")
            this.reset.OnEvent("Click", (*) => this.registerAP(&this, this.reset))

            ; Epic and Black Ice counts are combined.
            ; Black Ice count by itself is written to file underneath the EPICS count.
            this.export := this.apgui.Add("Button", "x" . xbase + 140 . " y" . offset . " w" . 2 * w . " r1", "Export")
            this.export.OnEvent("Click", (*) => this.exportData(&this))

            this.apgui.Show()
        }

        exportData(&obj)
        {
            FILENAME := 'AlphaPackTrackerExport.csv'
            ; Always overwrite existing data!
            csv := FileOpen(FILENAME, "w")

            ; Gather the shit-tons of data
            local COMMONCHARMS := 0
            local UNCOMMONCHARMS := 0
            local RARECHARMS := 0
            local EPICCHARMS := 0
            local LEGENDARYCHARMS := 0
            local CHARMS := 0
            local COMMONWEAPONS := 0
            local UNCOMMONWEAPONS := 0
            local RAREWEAPONS := 0
            local EPICWEAPONS := 0
            local LEGENDARYWEAPONS := 0
            local WEAPONS := 0
            local COMMONHEADGEARS := 0
            local UNCOMMONHEADGEARS := 0
            local RAREHEADGEARS := 0
            local EPICHEADGEARS := 0
            local LEGENDARYHEADGEARS := 0
            local HEADGEARS := 0
            local COMMONUNIFORMS := 0
            local UNCOMMONUNIFORMS := 0
            local RAREUNIFORMS := 0
            local EPICUNIFORMS := 0
            local LEGENDARYUNIFORMS := 0
            local UNIFORMS := 0
            local COMMONS := 0
            local UNCOMMONS := 0
            local RARES := 0
            local EPICS := 0
            local LEGENDARYS := 0
            local DUPLICATES := 0
            local TOTAL := obj.rolls.Length

            for roll in obj.rolls
            {
                if (roll.duplicate)
                {
                    DUPLICATES++
                }

                if (roll.rarity & siege.AlphaPackTracker.flags.rarity.common)
                {
                    COMMONS++
                    if (roll.kind & siege.AlphaPackTracker.flags.kind.charm)
                    {
                        COMMONCHARMS++
                        CHARMS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.weapon)
                    {
                        COMMONWEAPONS++
                        WEAPONS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.headgear)
                    {
                        COMMONHEADGEARS++
                        HEADGEARS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.uniform)
                    {
                        COMMONUNIFORMS++
                        UNIFORMS++
                    }
                }
                else if (roll.rarity & siege.AlphaPackTracker.flags.rarity.uncommon)
                {
                    UNCOMMONS++
                    if (roll.kind & siege.AlphaPackTracker.flags.kind.charm)
                    {
                        UNCOMMONCHARMS++
                        CHARMS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.weapon)
                    {
                        UNCOMMONWEAPONS++
                        WEAPONS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.headgear)
                    {
                        UNCOMMONHEADGEARS++
                        HEADGEARS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.uniform)
                    {
                        UNCOMMONUNIFORMS++
                        UNIFORMS++
                    }
                }
                else if (roll.rarity & siege.AlphaPackTracker.flags.rarity.rare)
                {
                    RARES++
                    if (roll.kind & siege.AlphaPackTracker.flags.kind.charm)
                    {
                        RARECHARMS++
                        CHARMS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.weapon)
                    {
                        RAREWEAPONS++
                        WEAPONS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.headgear)
                    {
                        RAREHEADGEARS++
                        HEADGEARS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.uniform)
                    {
                        RAREUNIFORMS++
                        UNIFORMS++
                    }
                }
                else if (roll.rarity & siege.AlphaPackTracker.flags.rarity.epic)
                {
                    EPICS++
                    if (roll.kind & siege.AlphaPackTracker.flags.kind.charm)
                    {
                        EPICCHARMS++
                        CHARMS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.weapon)
                    {
                        EPICWEAPONS++
                        WEAPONS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.headgear)
                    {
                        EPICHEADGEARS++
                        HEADGEARS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.uniform)
                    {
                        EPICUNIFORMS++
                        UNIFORMS++
                    }
                }
                else if (roll.rarity & siege.AlphaPackTracker.flags.rarity.legendary)
                {
                    LEGENDARYS++
                    if (roll.kind & siege.AlphaPackTracker.flags.kind.charm)
                    {
                        LEGENDARYCHARMS++
                        CHARMS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.weapon)
                    {
                        LEGENDARYWEAPONS++
                        WEAPONS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.headgear)
                    {
                        LEGENDARYHEADGEARS++
                        HEADGEARS++
                    }
                    else if (roll.kind & siege.AlphaPackTracker.flags.kind.uniform)
                    {
                        LEGENDARYUNIFORMS++
                        UNIFORMS++
                    }
                }
            }

            ; TOTAL is computed from the rarities (i.e. rolls in total) as the user may not have bothered with setting the kind of loot it is
            csv.WriteLine(",Common,Uncommon,Rare,Epic,Legendary,")
            csv.WriteLine("Charm," . COMMONCHARMS . "," . UNCOMMONCHARMS . "," . RARECHARMS . "," . EPICCHARMS . "," . LEGENDARYCHARMS . "," . CHARMS)
            csv.WriteLine("Weapon," . COMMONWEAPONS . "," . UNCOMMONWEAPONS . "," . RAREWEAPONS . "," . EPICWEAPONS . "," . LEGENDARYWEAPONS . "," . WEAPONS)
            csv.WriteLine("Headgear," . COMMONHEADGEARS . "," . UNCOMMONHEADGEARS . "," . RAREHEADGEARS . "," . EPICHEADGEARS . "," . LEGENDARYHEADGEARS . "," . HEADGEARS)
            csv.WriteLine("Uniform," . COMMONUNIFORMS . "," . UNCOMMONUNIFORMS . "," . RAREUNIFORMS . "," . EPICUNIFORMS . "," . LEGENDARYUNIFORMS . "," . UNIFORMS)
            csv.WriteLine("," . COMMONS . "," . UNCOMMONS . "," . RARES . "," . EPICS . "," . LEGENDARYS . "," . TOTAL)
            csv.WriteLine("Of above marked as Black Ice,,,," . obj.blackiceCount.Value . ",,")
            csv.WriteLine("Duplicates,,,,,," . DUPLICATES)

            csv.Close()

            if (MsgBox("File written. Resetting input.`n`nOpen file?", , 0x4) == "Yes")
            {
                Run(FILENAME)
            }

            obj.commonCount.Value := "0"
            obj.uncommonCount.Value := "0"
            obj.rareCount.Value := "0"
            obj.epicCount.Value := "0"
            obj.blackiceCount.Value := "0"
            obj.legendaryCount.Value := "0"
            obj.totalCount.Value := Integer(obj.commonCount.Value) + Integer(obj.uncommonCount.Value) + Integer(obj.rareCount.Value) + Integer(obj.epicCount.Value) + Integer(obj.blackiceCount.Value) + Integer(obj.legendaryCount.Value)
            obj.dupe.Value := false
            for k in obj.kindsCounts
            {
                obj.kindsCounts.Get(k).Value := "0"
                obj.kinds.Get(k).Value := 0
            }
        }

        registerAP(&obj, sender)
        {
            local modEdit, rarityflag, dupeflag := obj.dupe.Value, kindflag := siege.AlphaPackTracker.flags.kind.unset

            switch (sender)
            {
                case obj.common:
                    modEdit := obj.commonCount
                    rarityflag := siege.AlphaPackTracker.flags.rarity.common
                case obj.uncommon:
                    modEdit := obj.uncommonCount
                    rarityflag := siege.AlphaPackTracker.flags.rarity.uncommon
                case obj.rare:
                    modEdit := obj.rareCount
                    rarityflag := siege.AlphaPackTracker.flags.rarity.rare
                case obj.epic:
                    modEdit := obj.epicCount
                    rarityflag := siege.AlphaPackTracker.flags.rarity.epic
                case obj.blackice:
                    modEdit := obj.blackiceCount
                    rarityflag := siege.AlphaPackTracker.flags.rarity.epic
                case obj.legendary:
                    modEdit := obj.legendaryCount
                    rarityflag := siege.AlphaPackTracker.flags.rarity.legendary
                case obj.reset:
                    obj.commonCount.Value := "0"
                    obj.uncommonCount.Value := "0"
                    obj.rareCount.Value := "0"
                    obj.epicCount.Value := "0"
                    obj.blackiceCount.Value := "0"
                    obj.legendaryCount.Value := "0"
                    obj.totalCount.Value := all()
                    obj.dupe.Value := false
                    for k in obj.kindsCounts
                    {
                        obj.kindsCounts.Get(k).Value := "0"
                        obj.kinds.Get(k).Value := 0
                    }
                    return
            }

            for k, v in this.kinds
            {
                if (v.Value)
                {
                    obj.kindsCounts.Get(k).Value := Integer(obj.kindsCounts.Get(k).Value) + 1
                    kindflag := siege.AlphaPackTracker.flags.kind.list[A_Index]
                }
            }

            obj.rolls.Push(siege.AlphaPackTracker.Roll(rarityflag, kindflag, dupeflag))
            obj.dupe.Value := false

            modEdit.Value := Integer(modEdit.Value) + 1
            obj.totalCount.Value := all()

            all() => Integer(obj.commonCount.Value) + Integer(obj.uncommonCount.Value) + Integer(obj.rareCount.Value) + Integer(obj.epicCount.Value) + Integer(obj.blackiceCount.Value) + Integer(obj.legendaryCount.Value)
        }

        __Delete()
        {
            this.apgui.Hide()
            this.apgui := ""
        }
    }
}