/**
 * To check for an Operator's properties, use standard comparison operators and bitwise-and `&` and bitwise-or `|`. For example, if a `siege.Operator` (object) is stored in `op`...
 * - ...can a Hard Breach Charge _or_ a Breach Charge be chosen with this Operator? `op.gadgets & (siege.Weapon.gadgets.hardbreachcharge | siege.Weapon.gadgets.breachcharge)`
 * To check for an Operator's weapons' properties, use bitwise-and `&` and bitwise-or `|`. For example, if a `siege.Weapon` (object) is stored in `prim`...
 * - ...can a 2x, 2.5x or Russian 2.5x sight be equipped? `prim.sights & (siege.Weapon.sights.x25 | siege.Weapon.sights.x2 | siege.Weapon.sights.x25)`
 * - ...is this weapon _not_ a slug shotgun _or_ a light machine gun? `prim.type & ~(siege.Weapon.types.shotgunSlug | siege.Weapon.types.lightmachinegun)`
 */
notes := ""

#Include ahk-codebase.ahk

class siege
{
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
         *
         * Currently broken, returns Buck's object, when it should be Thunderbird's.
         */
        static longestOperatorNick := codebase.collectionOperations.arrayOperations.arrayConcat(siege.attackers.list, siege.defenders.list)[(a := codebase.collectionOperations.arrayOperations.evaluate((x) => StrLen(x.nickname), codebase.collectionOperations.arrayOperations.arrayConcat(siege.attackers.list, siege.defenders.list)))[codebase.collectionOperations.arrayOperations.arrayContains(a, Max(a*))[1]]]
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
            for n, v in siege.Weapon.gadgets.list
            {
                if (this.gadgets & v)
                {
                    gdg.Push(n)
                }
            }
            gdg := ((s := gdg[Random(1, gdg.Length)]) !== "" ? s : "None")

            primbarrel := []
            for n, v in siege.Weapon.barrels.list
            {
                if (prim.barrels & v)
                {
                    primbarrel.Push(n)
                }
            }
            primbarrel := (primbarrel.Length ? primbarrel[Random(1, primbarrel.Length)] : "—")

            primsight := []
            for n, v in siege.Weapon.sights.list
            {
                if (prim.sights & v)
                {
                    primsight.Push(n)
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
            for n, v in siege.Weapon.grips.list
            {
                if (prim.grips & v)
                {
                    primgrip.Push(n)
                }
            }
            primgrip := (primgrip.Length ? primgrip[Random(1, primgrip.Length)] : "—")
            
            secbarrel := []
            for n, v in siege.Weapon.barrels.list
            {
                if (sec.barrels & v)
                {
                    secbarrel.Push(n)
                }
            }
            secbarrel := (secbarrel.Length ? secbarrel[Random(1, secbarrel.Length)] : "—")

            tp := ""
            ts := ""
            for n, v in siege.Weapon.types.list
            {
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
     * This is never universal among all Operators; for example, there must be at least two `Weapon` objects holding information about the "Spear .308", as Finka and Thunderbird both use this weapon, but the barrel extensions they may use differ.
     */
    class Weapon
    {
        /**
         * This multiplier is applied to a weapon's base damage when equipping a suppressor on it. This is not defined anywhere and resulted from averaging the ratios from all weapons a suppressor can be equipped on (`suppressed_dmg / dmg`). Typically, using `0.84` yields a close enough approximate.
         *
         * ~It is also unknown whether the resulting float is rounded up or down, but as far as the evidence I have suggests, it's rounded up.~
         *
         * Further testing has shown that the calculated suppressed damage value is _not_ always rounded up, but instead rounded to the nearest integer.
         */
        static suppressedDamageMultiplier := 0.837697879481015

        class types
        {
            /**
             * Identifies the Assault Rifle weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static assaultrifle := codebase.Bitfield("0000000001").Value()
            /**
             * Identifies the Handgun weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static handgun := codebase.Bitfield("0000000010").Value()
            /**
             * Identifies the Light Machine Gun weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static lightmachinegun := codebase.Bitfield("0000000100").Value()
            /**
             * Identifies the Machine Pistol weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static machinepistol := codebase.Bitfield("0000001000").Value()
            /**
             * Identifies the Marksman Rifle weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static marksmanrifle := codebase.Bitfield("0000010000").Value()
            /**
             * Identifies the Shield weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static shield := codebase.Bitfield("0000100000").Value()
            /**
             * Identifies the Shotgun weapon type generally. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             *
             * @note This flag is not used to identify any shotgun in this library. It is merely supposed to be a user-friendly shortcut to allow for easier filtering of weapons, i.e. `siege.Weapon.types.shotgun` instead of `siege.Weapon.types.shotgunSlug | siege.Weapon.types.shotgunShot`, as they are handled the same in-game (e.g. the specific type of shotgun doesn't matter for shotgun kill challenges).
             */
            static shotgun := codebase.Bitfield("0011000000").Value()
            /**
             * Identifies the Shotgun (slug ammo) weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static shotgunSlug := codebase.Bitfield("0001000000").Value()
            /**
             * Identifies the Shotgun (shot / pellet) weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static shotgunShot := codebase.Bitfield("0010000000").Value()
            /**
             * Identifies the Submachine Gun weapon type. Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static submachinegun := codebase.Bitfield("0100000000").Value()
            /**
             * Identifies the Hand Cannon weapon type (which currently uniquely identifies the "GONNE-6"). Use bitwise-and `&` to check whether a weapon's `type` prop matches this flag.
             */
            static handcannon := codebase.Bitfield("1000000000").Value()

            static list := Map(
                "Assault Rifle", this.assaultrifle,
                "Handgun", this.handgun,
                "Light Machine Gun", this.lightmachinegun,
                "Machine Pistol", this.machinepistol,
                "Marksman Rifle", this.marksmanrifle,
                "Shield", this.shield,
                "Slug Shotgun", this.shotgunSlug,
                "Shotgun", this.shotgunShot,
                "Submachine Gun", this.submachinegun,
                "Hand Cannon", this.handcannon
            )
            __Enum(*) => this.list.__Enum()
            __New(*) => this.list.__Enum()
            __Call(*) => this.list.__Enum()
        }

        class firingmodes
        {
            /**
             * Indicates that the weapon fires single-shot only. Use bitwise-and `&` to check whether a weapon's `firingmode` prop matches this flag.
             */
            static singleshot := codebase.Bitfield("01").Value()
            /**
             * Indicates that the weapon fires full auto only. Use bitwise-and `&` to check whether a weapon's `firingmode` prop matches this flag.
             */
            static fullauto := codebase.Bitfield("10").Value()

            static list := Map(
                "Single Shot", this.singleshot,
                "Full Auto", this.fullauto
            )
            __Enum(*) => this.list.__Enum()
            __New(*) => this.list.__Enum()
            __Call(*) => this.list.__Enum()
        }

        /**
         * Since Y7S1 (Demon Veil), _all_ weapons (excepting most secondaries and, for example, Glaz's "OTs-03" DMR, which does not have access to Reflex C) have access to _all_ non-magnifying scopes (Red Dot, Holo, Reflex), or more precisely, _all_ of their variants (no matter if standard, Russian, alternate etc.). Because of this, I've decided to combine them into the option `nonmag`. Checking for magnifying scopes still works as before.
         *
         * However, as mentioned above, exceptions such as Glaz's "OTs-03" DMR, which cannot be equipped with Reflex C, are not (yet?) handled differently.
         *
         * Additionally, since there are two 2.5x scope variants, the two options `x25` and `rux25` have also been combined into the option `x25`.
         */
        class sights
        {
            /**
             * Indicates that some other sight properties are going on with the weapon (e.g. Red Dot only on "P10-C", custom Reflex only on "DP27"). Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static other := codebase.Bitfield("0000001").Value()
            /**
             * Indicates that all non-magnifying scope variant can be or one of them is forcefully equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static nonmag := codebase.Bitfield("0000010").Value()
            static nonmags := ["Red Dot A", "Red Dot B", "Red Dot C", "Holo A", "Holo B", "Holo C", "Holo D", "Reflex B", "Reflex A", "Reflex C"]
            /**
             * Indicates that the 1.5x sight can be or is forcefully equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static x15 := codebase.Bitfield("0000100").Value()
            /**
             * Indicates that the 2x sight can be or is forcefully equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static x2 := codebase.Bitfield("0001000").Value()
            /**
             * Indicates that the 2.5x sight can be or is forcefully equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static x25 := codebase.Bitfield("0010000").Value()
            static x25s := ["2.5x A", "2.5x B"]
            /**
             * Indicates that the 3x sight can be or is forcefully equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static x3 := codebase.Bitfield("0100000").Value()
            /**
             * Indicates that the 6x and 12x sights are equipped on the weapon (this currently uniquely identifies Kali's "CSRX 300"). Use bitwise-and `&` to check whether a weapon's `sights` prop matches this flag.
             */
            static x612 := codebase.Bitfield("1000000").Value()

            static list := Map(
                "Other", this.other,
                "Non-magnifying", this.nonmag,
                "1.5x", this.x15,
                "2x", this.x2,
                "2.5x", this.x25,
                "3x", this.x3,
                "6x/12x", this.x612
            )
            __Enum(*) => this.list.__Enum()
            __New(*) => this.list.__Enum()
            __Call(*) => this.list.__Enum()
        }

        class barrels
        {
            /**
             * Indicates that a Suppressor can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `barrels` prop matches this flag.
             */
            static suppressor := codebase.Bitfield("00001").Value()
            /**
             * Indicates that a Flash Hider can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `barrels` prop matches this flag.
             */
            static flashhider := codebase.Bitfield("00010").Value()
            /**
             * Indicates that a Compensator can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `barrels` prop matches this flag.
             */
            static compensator := codebase.Bitfield("00100").Value()
            /**
             * Indicates that a Muzzle Brake can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `barrels` prop matches this flag.
             */
            static muzzlebrake := codebase.Bitfield("01000").Value()
            /**
             * Indicates that an Extended Barrel can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `barrels` prop matches this flag.
             */
            static extendedbarrel := codebase.Bitfield("10000").Value()

            static list := Map(
                "Suppressor", this.suppressor,
                "Flash Hider", this.flashhider,
                "Compensator", this.compensator,
                "Muzzle Brake", this.muzzlebrake,
                "Extended Barrel", this.extendedbarrel
            )
            __New(*) => this.list.__Enum()
            __Enum(*) => this.list.__Enum()
            __Call(*) => this.list.__Enum()
        }

        class grips
        {
            /**
             * Indicates that a Vertical Grip can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `grips` prop matches this flag.
             */
            static verticalgrip := codebase.Bitfield("01").Value()
             /**
              * Indicates that an Extended Barrel can be equipped on the weapon. Use bitwise-and `&` to check whether a weapon's `grips` prop matches this flag.
              */
            static angledgrip := codebase.Bitfield("10").Value()

            static list := Map(
                "Vertical Grip", this.verticalgrip,
                "Angled Grip", this.angledgrip
            )
            __New(*) => this.list.__Enum()
            __Enum(*) => this.list.__Enum()
            __Call(*) => this.list.__Enum()
        }

        class gadgets
        {
            /**
             * Indicates that a Frag Grenade can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static fraggrenade := codebase.Bitfield("000000000001").Value()
            /**
             * Indicates that a Breach Charge can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static breachcharge := codebase.Bitfield("000000000010").Value()
            /**
             * Indicates that a Claymore can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static claymore := codebase.Bitfield("000000000100").Value()
            /**
             * Indicates that a Hard Breach Charge can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static hardbreachcharge := codebase.Bitfield("000000001000").Value()
            /**
             * Indicates that a Smoke Grenade can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static smokegrenade := codebase.Bitfield("000000010000").Value()
            /**
             * Indicates that a Stun Grenade can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static stungrenade := codebase.Bitfield("000000100000").Value()
            
            /**
             * Indicates that Barbed Wire can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static barbedwire := codebase.Bitfield("000001000000").Value()
            /**
             * Indicates that a Deployable Shield can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static deployableshield := codebase.Bitfield("000010000000").Value()
            /**
             * Indicates that a Nitro Cell can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static nitrocell := codebase.Bitfield("000100000000").Value()
            /**
             * Indicates that a Bulletproof Camera can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static bulletproofcamera := codebase.Bitfield("001000000000").Value()
            /**
             * Indicates that a Proximity Alarm can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static proximityalarm := codebase.Bitfield("010000000000").Value()
            /**
             * Indicates that an Impact Grenade can be chosen with this Operator. Use bitwise-and `&` to check whether an Operator's `gadgets` prop matches this flag.
             */
            static impactgrenade := codebase.Bitfield("100000000000").Value()

            static list := Map(
                "Frag Grenade", this.fraggrenade,
                "Breach Charge", this.breachcharge,
                "Claymore", this.claymore,
                "Hard Breach Charge", this.hardbreachcharge,
                "Smoke Grenade", this.smokegrenade,
                "Stun Grenade", this.stungrenade,
                "Barbed Wire", this.barbedwire,
                "Deployable Shield", this.deployableshield,
                "Nitro Cell", this.nitrocell,
                "Bulletproof Camera", this.bulletproofcamera,
                "Proximity Alarm", this.proximityalarm,
                "Impact Grenade", this.impactgrenade
            )
            __New(*) => this.list.__Enum()
            __Enum(*) => this.list.__Enum()
            __Call(*) => this.list.__Enum()
        }

        /**
         * The name of the weapon in-game.
         */
        name := ""
        /**
         * The value of a `codebase.Bitfield` object to indicate which type of weapon it is. 
         * @note Inconsistencies like with Maverick's "AR-15.50" (which, in reality, is a so-called "Home Defense Rifle", not an "Assault Rifle" or "Marksman Rifle", despite what the game calls it) should not be and are not corrected.
         */
        type := ""
        /**
         * The value of a `codebase.Bitfield` object to indicate the firing mode the weapon possesses.
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
         * The values of one or more `codebase.Bitfield` objects summed up to indicate which sights can be equipped on the weapon.
         *
         * - This is `0` for Shields.
         * - This is `0` for the "GONNE-6".
         * - This is `0` for all weapons which do not have scopes available.
         */
        sights := ""
        /**
         * The values of one or more `codebase.Bitfield` objects summed up to indicate which barrels / barrel extensions can be equipped on the weapon.
         *
         * - This is `0` for Shields.
         * - This is `0` for the "GONNE-6".
         */
        barrels := ""
        /**
         * The values of one or more `codebase.Bitfield` objects summed up to indicate which grips can be equipped on the weapon.
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
         */
        suppresseddamage := ""
        /**
         * The amount of damage per second the weapon can deal.
         *
         * - This is `0` for Shields.
         */
        dps := ""

        /**
         * Instantiate a new `Weapon` object.
         * @param name The name of the weapon in-game.
         * @param type The value of a `codebase.Bitfield` object to indicate which type of weapon it is.
         * @param firingmode The value of a `codebase.Bitfield` object to indicate the firing mode the weapon possesses.
         * @param damage The damage of the weapon.
         * @param rpm How many rounds per minute the weapon fires.
         * @param capacity How many rounds the weapon can fire before having to reload. This should _not_ include the extra round in the chamber after cocking the gun.
         * @param sights The values of one or more `codebase.Bitfield` objects summed up to indicate which sights can be equipped on the weapon.
         * @param barrels The values of one or more `codebase.Bitfield` objects summed up to indicate which barrels / barrel extensions can be equipped on the weapon.
         * @param grips The values of one or more `codebase.Bitfield` objects summed up to indicate which grips can be equipped on the weapon.
         * @param underbarrel Whether the weapon has an underbarrel slot (i.e. a laser can be equipped).
         * @returns A `Weapon` object.
         */
        __New(name, type, firingmode, damage, rpm, capacity, sights, barrels, grips, underbarrel)
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
            this.dps := Round(this.damage * (this.rpm / 60))
        }
    }

    class attackers
    {
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
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                ),
                siege.Weapon(
                    "L85A2",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    47,
                    670,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.fraggrenade + siege.Weapon.gadgets.stungrenade,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "L85A2",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    47,
                    670,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "M590A1",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    85,
                    7,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.breachcharge + siege.Weapon.gadgets.claymore,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "R4-C",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    39,
                    860,
                    30,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "5.7 USG",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    550,
                    20,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.breachcharge + siege.Weapon.gadgets.claymore,
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
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                ),
                siege.Weapon(
                    "556XI",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    47,
                    690,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "5.7 USG",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    550,
                    20,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.smokegrenade + siege.Weapon.gadgets.stungrenade,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "417",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    69,
                    450,
                    20,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25 + siege.Weapon.sights.x3,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "SG-CQB",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    53,
                    85,
                    7,
                    siege.Weapon.sights.nonmag,
                    0,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    true
                )
            ],
            siege.Weapon.gadgets.claymore + siege.Weapon.gadgets.smokegrenade,
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
                    false
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    true
                )
            ],
            siege.Weapon.gadgets.hardbreachcharge + siege.Weapon.gadgets.smokegrenade,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    0,
                    false
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    false
                ),
                siege.Weapon(
                    "Bearing 9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    1100,
                    25,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.smokegrenade + siege.Weapon.gadgets.fraggrenade,
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
                    false
                ),
                siege.Weapon(
                    "6P41",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    46,
                    680,
                    100,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "AK-12",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    45,
                    850,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "GSH-18",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    18,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    false
                )
            ],
            siege.Weapon.gadgets.breachcharge + siege.Weapon.gadgets.hardbreachcharge,
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
                    false
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.smokegrenade + siege.Weapon.gadgets.breachcharge,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator,
                    0,
                    true
                ),
                siege.Weapon(
                    "552 Commando",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    48,
                    690,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "G8A1",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    37,
                    850,
                    50,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.breachcharge + siege.Weapon.gadgets.claymore,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    0,
                    true
                ),
                siege.Weapon(
                    "CAMRS",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    69,
                    450,
                    20,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25 + siege.Weapon.sights.x3,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.stungrenade + siege.Weapon.gadgets.hardbreachcharge,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "SR-25",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    61,
                    450,
                    20,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25 + siege.Weapon.sights.x3,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.claymore + siege.Weapon.gadgets.stungrenade,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "M249",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    48,
                    650,
                    100,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.claymore + siege.Weapon.gadgets.hardbreachcharge,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "Supernova",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    75,
                    7,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "Bearing 9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    1100,
                    25,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.stungrenade + siege.Weapon.gadgets.breachcharge,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "PDW9",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    34,
                    800,
                    50,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "ITA12L",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    85,
                    8,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "ITA12S",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    70,
                    85,
                    5,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.claymore + siege.Weapon.gadgets.smokegrenade,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "SIX12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    6,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.hardbreachcharge + siege.Weapon.gadgets.smokegrenade,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "M762",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    45,
                    730,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.breachcharge + siege.Weapon.gadgets.claymore,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25 + siege.Weapon.sights.x3,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "BOSG.12.2",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.singleshot,
                    125,
                    500,
                    2,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x25,
                    0,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.sights.nonmag,
                    0,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    false
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
                    false
                )
            ],
            siege.Weapon.gadgets.smokegrenade + siege.Weapon.gadgets.stungrenade,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "417",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    69,
                    450,
                    20,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25 + siege.Weapon.sights.x3,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "SG-CQB",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    53,
                    85,
                    7,
                    siege.Weapon.sights.nonmag,
                    0,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    true
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
                    false
                ),
                siege.Weapon(
                    "P9",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    45,
                    550,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.stungrenade + siege.Weapon.gadgets.claymore,
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
                    "SPEAR .308",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    42,
                    700,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "6P41",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    46,
                    680,
                    100,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "SASG-12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    330,
                    10,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    false
                ),
                siege.Weapon(
                    "GSH-18",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    18,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    false
                )
            ],
            siege.Weapon.gadgets.fraggrenade + siege.Weapon.gadgets.stungrenade,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25 + siege.Weapon.sights.x3,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "M4",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    44,
                    750,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.fraggrenade + siege.Weapon.gadgets.claymore,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "ARX200",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    47,
                    700,
                    20,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    true
                ),
                siege.Weapon(
                    "PRB92",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    450,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.stungrenade + siege.Weapon.gadgets.breachcharge,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "M249 SAW",
                    siege.Weapon.types.lightmachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    48,
                    650,
                    60,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    false
                ),
                siege.Weapon(
                    "SDP 9mm",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    47,
                    450,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.smokegrenade + siege.Weapon.gadgets.breachcharge,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "SIX12 SD",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    6,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "D-50",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    71,
                    550,
                    7,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.fraggrenade + siege.Weapon.gadgets.hardbreachcharge,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    false
                ),
                siege.Weapon(
                    "Supernova",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    75,
                    7,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor,
                    0,
                    true
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    false
                ),
                siege.Weapon(
                    "ITA12S",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    70,
                    85,
                    5,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.hardbreachcharge + siege.Weapon.gadgets.stungrenade,
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
                    false
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider,
                    0,
                    true
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
                    false
                ),
                siege.Weapon(
                    "P226 MK 25",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.claymore + siege.Weapon.gadgets.breachcharge,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "G36C",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    38,
                    780,
                    30,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    false
                )
            ],
            siege.Weapon.gadgets.fraggrenade + siege.Weapon.gadgets.smokegrenade,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "M1014",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    34,
                    200,
                    8,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.breachcharge + siege.Weapon.gadgets.claymore,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "MP7",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    32,
                    900,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor,
                    0,
                    true
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
                    false
                )
            ],
            siege.Weapon.gadgets.hardbreachcharge + siege.Weapon.gadgets.claymore,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "SR-25",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    61,
                    450,
                    20,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25 + siege.Weapon.sights.x3,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    false
                )
            ],
            siege.Weapon.gadgets.stungrenade + siege.Weapon.gadgets.claymore,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "PDW9",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    34,
                    800,
                    50,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.smokegrenade + siege.Weapon.gadgets.claymore,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "417",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    69,
                    450,
                    20,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15 + siege.Weapon.sights.x2 + siege.Weapon.sights.x25 + siege.Weapon.sights.x3,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    false
                )
            ],
            siege.Weapon.gadgets.hardbreachcharge + siege.Weapon.gadgets.claymore,
            "R.O.U. Projector System",
            "SFG",
            "Brussels, Belgium",
            178,
            73,
            "Néon Ngoma Mutombo",
            { month: 3, day: 3, age: 30 },
            1
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
            siege.attackers.sens
        ]
        __Enum(*) => siege.attackers.list.__Enum()
        __New(*) => siege.attackers.list.__Enum()
        __Call(*) => siege.attackers.list.__Enum()
    }

    class defenders
    {
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "M590A1",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    85,
                    7,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "SMG-11",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    35,
                    1270,
                    16,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip,
                    true
                )
            ],
            siege.Weapon.gadgets.barbedwire + siege.Weapon.gadgets.deployableshield,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "M590A1",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    85,
                    7,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "SMG-11",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    35,
                    1270,
                    16,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip,
                    true
                )
            ],
            siege.Weapon.gadgets.nitrocell + siege.Weapon.gadgets.bulletproofcamera,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "M1014",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    34,
                    200,
                    8,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "Super Shorty",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    85,
                    3,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera + siege.Weapon.gadgets.proximityalarm,
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
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                ),
                siege.Weapon(
                    "UMP45",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    38,
                    600,
                    25,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "5.7 USG",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    42,
                    550,
                    20,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.barbedwire + siege.Weapon.gadgets.nitrocell,
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
                    siege.Weapon.sights.nonmag,
                    0,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "MP5",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    27,
                    800,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "P90",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    22,
                    970,
                    50,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    true
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera + siege.Weapon.gadgets.barbedwire,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    0,
                    true
                ),
                siege.Weapon(
                    "MP5",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    27,
                    800,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "SG-CQB",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    53,
                    85,
                    7,
                    siege.Weapon.sights.nonmag,
                    0,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    true
                ),
                siege.Weapon(
                    "P9",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    45,
                    550,
                    16,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.proximityalarm + siege.Weapon.gadgets.impactgrenade,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "SASG-12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    330,
                    10,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "GSH-18",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    18,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    false
                )
            ],
            siege.Weapon.gadgets.impactgrenade + siege.Weapon.gadgets.nitrocell,
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
                    siege.Weapon.sights.other,
                    0,
                    0,
                    false
                ),
                siege.Weapon(
                    "9x19VSN",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    34,
                    750,
                    30,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    false
                ),
                siege.Weapon(
                    "PMM",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    61,
                    550,
                    8,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "Bearing 9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    1100,
                    25,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.barbedwire + siege.Weapon.gadgets.deployableshield,
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
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                ),
                siege.Weapon(
                    "416-C Carbine",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    38,
                    740,
                    25,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera + siege.Weapon.gadgets.barbedwire,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "M870",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    100,
                    7,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.barbedwire + siege.Weapon.gadgets.nitrocell,
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
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                ),
                siege.Weapon(
                    "9mm C1",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    45,
                    575,
                    34,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "ITA12S",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    70,
                    85,
                    5,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera + siege.Weapon.gadgets.deployableshield,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "SPAS-12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    7,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.impactgrenade + siege.Weapon.gadgets.nitrocell,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    0,
                    true
                ),
                siege.Weapon(
                    "SPAS-15",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    30,
                    290,
                    6,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    true
                )
            ],
            siege.Weapon.gadgets.impactgrenade + siege.Weapon.gadgets.proximityalarm,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor,
                    0,
                    true
                ),
                siege.Weapon(
                    "MP5SD",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    30,
                    800,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    0,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "Bearing 9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    1100,
                    25,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.impactgrenade + siege.Weapon.gadgets.deployableshield,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "ITA12L",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    50,
                    85,
                    8,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "ITA12S",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    70,
                    85,
                    5,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.proximityalarm + siege.Weapon.gadgets.nitrocell,
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
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                ),
                siege.Weapon(
                    "T-5 SMG",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    28,
                    900,
                    30,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.impactgrenade + siege.Weapon.gadgets.bulletproofcamera,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.weapon.grips.verticalgrip + siege.weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "FO-12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    25,
                    400,
                    10,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.barbedwire + siege.Weapon.gadgets.deployableshield,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.weapon.grips.verticalgrip + siege.weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "BOSG.12.2",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.singleshot,
                    125,
                    500,
                    2,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x25,
                    0,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    false
                ),
                siege.Weapon(
                    "SMG-12",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    28,
                    1270,
                    32,
                    siege.Weapon.sights.nonmag,
                    0,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera + siege.Weapon.gadgets.impactgrenade,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "ACS12",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.fullauto,
                    69,
                    300,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2,
                    0,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    true
                ),
                siege.Weapon(
                    "Keratos .357",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    78,
                    450,
                    6,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.barbedwire + siege.Weapon.gadgets.impactgrenade,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "ACS12",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.fullauto,
                    69,
                    300,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2,
                    0,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    true
                )
            ],
            siege.Weapon.gadgets.impactgrenade + siege.Weapon.gadgets.deployableshield,
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
                    true
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
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                ),
                siege.Weapon(
                    "SPSMG9",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    33,
                    980,
                    20,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider,
                    0,
                    true
                ),
                siege.Weapon(
                    "P-10C",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    40,
                    450,
                    15,
                    siege.Weapon.sights.other,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.barbedwire + siege.Weapon.gadgets.impactgrenade,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.weapon.grips.verticalgrip + siege.weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "TCSG12",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.singleshot,
                    63,
                    450,
                    10,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2,
                    siege.Weapon.barrels.suppressor,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    true
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
                    true
                )
            ],
            siege.Weapon.gadgets.nitrocell + siege.Weapon.gadgets.barbedwire,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.weapon.grips.verticalgrip + siege.weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "P10 RONI",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    26,
                    980,
                    15,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.barbedwire + siege.Weapon.gadgets.nitrocell,
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
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
                ),
                siege.Weapon(
                    "MPX",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    26,
                    830,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "SMG-12",
                    siege.Weapon.types.machinepistol,
                    siege.Weapon.firingmodes.fullauto,
                    28,
                    1270,
                    32,
                    siege.Weapon.sights.nonmag,
                    0,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                )
            ],
            siege.Weapon.gadgets.deployableshield + siege.Weapon.gadgets.nitrocell,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "TCSG12",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.singleshot,
                    63,
                    450,
                    10,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x2,
                    siege.Weapon.barrels.suppressor,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.proximityalarm + siege.Weapon.gadgets.nitrocell,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator,
                    0,
                    true
                ),
                siege.Weapon(
                    "MP5K",
                    siege.Weapon.types.submachinegun,
                    siege.Weapon.firingmodes.fullauto,
                    30,
                    800,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "P12",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    44,
                    550,
                    15,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.impactgrenade + siege.Weapon.gadgets.proximityalarm,
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
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                ),
                siege.Weapon(
                    "SPAS-12",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    7,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    true
                ),
                siege.Weapon(
                    "USP40",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    48,
                    550,
                    12,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.barbedwire + siege.Weapon.gadgets.proximityalarm,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "Super 90",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    35,
                    200,
                    8,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.bulletproofcamera + siege.Weapon.gadgets.impactgrenade,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake + siege.Weapon.barrels.extendedbarrel,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "Mk 14 EBR",
                    siege.Weapon.types.marksmanrifle,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    450,
                    20,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.barbedwire + siege.Weapon.gadgets.bulletproofcamera,
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
                    "SPEAR .308",
                    siege.Weapon.types.assaultrifle,
                    siege.Weapon.firingmodes.fullauto,
                    42,
                    700,
                    30,
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip,
                    true
                ),
                siege.Weapon(
                    "SPAS-15",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    30,
                    290,
                    6,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator,
                    0,
                    true
                ),
                siege.Weapon(
                    "Q-929",
                    siege.Weapon.types.handgun,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    550,
                    10,
                    0,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.impactgrenade + siege.Weapon.gadgets.nitrocell,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "M870",
                    siege.Weapon.types.shotgunShot,
                    siege.Weapon.firingmodes.singleshot,
                    60,
                    100,
                    7,
                    siege.Weapon.sights.nonmag,
                    0,
                    0,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
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
                    false
                )
            ],
            siege.Weapon.gadgets.deployableshield + siege.Weapon.gadgets.barbedwire,
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
                    siege.Weapon.sights.nonmag,
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.flashhider + siege.Weapon.barrels.compensator + siege.Weapon.barrels.muzzlebrake,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
                ),
                siege.Weapon(
                    "ACS12",
                    siege.Weapon.types.shotgunSlug,
                    siege.Weapon.firingmodes.fullauto,
                    69,
                    300,
                    30,
                    siege.Weapon.sights.nonmag + siege.Weapon.sights.x15,
                    0,
                    siege.Weapon.grips.verticalgrip + siege.Weapon.grips.angledgrip,
                    true
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
                    siege.Weapon.barrels.suppressor + siege.Weapon.barrels.muzzlebrake,
                    0,
                    true
                )
            ],
            siege.Weapon.gadgets.impactgrenade + siege.Weapon.gadgets.barbedwire,
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
        __Enum(*) => siege.defenders.list.__Enum()
        __New(*) => siege.defenders.list.__Enum()
        __Call(*) => siege.defenders.list.__Enum()
    }

    /**
     * The `list` Arrays from the `siege.attackers` and `siege.defenders` subclasses concatenated into one in that order to allow for easier looping.
     */
    static atkdef := codebase.collectionOperations.arrayOperations.arrayConcat(siege.attackers.list, siege.defenders.list)
    /**
     * The `list` Arrays from the `siege.defenders` and `siege.attackers` subclasses concatenated into one in that order to allow for easier looping.
     */
    static defatk := codebase.collectionOperations.arrayOperations.arrayConcat(siege.defenders.list, siege.attackers.list)

    class challenges
    {
        static winRoundsWith()
        {
            s := "Win {n} rounds with {o1}, {o2}, {o3} or {o4}."
            obj := {
                n: Random(1, 2) * 5,
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
            s := "Eliminate {n} opponents with {t}."
            tpe := ""
            while (tpe == "")
            {
                for n, v in siege.Weapon.types.list
                {
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
            obj := {
                n: Random(1, 2) * 5,
                t: tpe
            }
            codebase.stringOperations.strComposite(&s, obj)
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
                n: Random(1, 2) * 5
            }
            for op in ops
            {
                obj.DefineProp("o" . A_Index, { Value: op })
            }
            codebase.stringOperations.strComposite(&s, obj)
            return s
        }

        static role() => "Win " . Random(1, 2) * 5 . " rounds as " . (Random(1, 100) <= 50 ? "an Attacker" : "a Defender") . "."
        static hardBreach() => "Breach " . Random(1, 3) * 5 . " reinforced walls with Thermite's Exothermic Charges, Hibana's X-KAIROs, Ace's S.E.L.M.A. Aqua Breachers or Hard Breach Charges."
        static headshots() => "Headshot " . Random(2, 3) * 5 . " opponents."
        static kills() => "Kill " . Random(2, 4) * 5 . " opponents."
        static matches() => (Mod(Random(0, 100), 3) ? "Play " : "Win ") . Random(1, 2) * 5 . ((h := Random(1, 100)) <= 10 ? " Ranked" : (h <= 50 ? " Unranked" : " Casual")) . " matches."
        static explosiveKills() => "Eliminate " . Random(1, 2) * 5 . " opponents with Impact Grenades, Nitro Cells, Frag Grenades, Fuze's Cluster Charges, Flores's RCE-Ratero Charges, Kapkan's Entry Denial Devices or Thorn's Razorbloom Shells."
        static disorient() => "Disorient " . Random(1, 2) * 5 . " opponents with Zofia's Grzmot Grenades, Nomad's Airjabs, Echo's Yokai Sonic Burst, Ela's Grzmot Mines or Oryx's Remah Dash."
        static stun() => "Stun " . Random(1, 2) * 5 . " opponents with Stun Grenades, Blitz's G52-Tactical Shield or Ying's Candelas."
        static destroyObservation() => "Destroy " . Random(1, 2) * 5 . " Defender cameras, Bulletproof Cameras, Valkyrie's Black Eyes, Echo's Yokai, Maestro's Evil Eyes or drones hacked by Mozzie's Pest as an Attacker."
        static heal() => "Heal " . Random(1, 2) * 5 . " teammates with Finka's Adrenal Surge, Doc's Stim Pistol or Thunderbird's KÓNA Stations. Revives count as 2 towards this."
        static suppressed() => "Eliminate " . Random(2, 3) * 5 . " opponents with suppressed weapons."
        static trapper() => "Eliminate or incapacitate " . Random(1, 2) * 5 . " opponents with Kapkan's Entry Denial Devices, Frost's Welcome Mats, Goyo's Volcán Canisters, Thorn's Razorbloom Shells or during and after they are tracked by Alibi's Primas. Eliminations count as 2 towards this."
        static chemicalBonds() => "Eliminate, incapacitate or damage " . Random(2, 3) * 5 . " opponents with Smoke's Z8 Gas Grenades or Lesion's Gu Mines. Eliminations and incapacitations count as 2 towards this."
        static areaDenial() => "Damage or perform area denial against " . Random(2, 3) * 5 . " opponents using Smoke's Z8 Gas Grenades, Tachanka's Shumikha Grenade Launcher, Goyo's Volcán Canisters, Capitão's Asphyxiating Bolts or Gridlock's Trax Stingers."
        static techAttackAtk() => "Destroy, disable or render " . Random(1, 2) * 5 . " Defender gadgets useless using Thatcher's EG Mk 0-EMP Grenades, Twitch's RSD Model 1 Shock Drones, Kali's LV Explosive Lance or Zero's Argus Cameras."
        static techAttackDef() => "Destroy, disable or render " . Random(1, 2) * 5 . " Attacker gadgets useless using Mute's GC90 Signal Disruptors, Bandit's CED-1 Shock Wires or Kaid's Rtila Electroclaws or by hacking Attacker drones using Mozzie's Pest."
        static antiProjectile() => "Destroy " . Random(1, 2) * 5 . " Attacker projectiles using Jäger's ADS-Mk IV, Wamai's Mag-NET Systems or Aruni's Surya Gates."
        static reveal() => "Reveal " . Random(2, 4) * 5 . " opponents by scanning them in cameras or pinging their special abilities."
        static unauthorizedAccess() => "Hack into Defender cameras as Dokkaebi or hack an Attacker drone as Mozzie " . Random(1, 2) * 5 . " times."
        static deployCams() => "Deploy " . Random(1, 2) * 5 . " Bulletproof Cameras, Valkyrie's Black Eyes, Maestro's Evil Eyes or Zero's Argus Cameras."

        static weeklyChallengeSet() => codebase.stringOperations.strJoin("`n", false,
            siege.challenges.wepTypeElims(),
            siege.challenges.orgActiveDuty(),
            siege.challenges.orgActiveDuty(),
            siege.challenges.orgActiveDuty(), ; 3rd time replaces thunt challenge because who tf plays thunt except for the challenges
            siege.challenges.role()
        )

        static list := [
            siege.challenges.orgActiveDuty,
            siege.challenges.winRoundsWith,
            siege.challenges.wepTypeElims,
            siege.challenges.hardBreach,
            siege.challenges.headshots,
            siege.challenges.kills,
            siege.challenges.matches,
            siege.challenges.explosiveKills,
            siege.challenges.disorient,
            siege.challenges.stun,
            siege.challenges.destroyObservation,
            siege.challenges.heal,
            siege.challenges.suppressed,
            siege.challenges.trapper,
            siege.challenges.chemicalBonds,
            siege.challenges.areaDenial,
            siege.challenges.techAttackAtk,
            siege.challenges.techAttackDef,
            siege.challenges.antiProjectile,
            siege.challenges.reveal,
            siege.challenges.unauthorizedAccess,
            siege.challenges.deployCams,
            siege.challenges.role,
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
                common: codebase.Bitfield("00001").Value(),
                uncommon: codebase.Bitfield("00010").Value(),
                rare: codebase.Bitfield("00100").Value(),
                epic: codebase.Bitfield("01000").Value(),
                legendary: codebase.Bitfield("10000").Value()
            },
            kind: {
                charm: codebase.Bitfield("00001").Value(),
                weapon: codebase.Bitfield("00010").Value(),
                headgear: codebase.Bitfield("00100").Value(),
                uniform: codebase.Bitfield("01000").Value(),
                unset: codebase.Bitfield("10000").Value()
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