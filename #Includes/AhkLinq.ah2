/**
 * Replicates the functionality of the `System.Linq.Enumerable` class in C#, slightly modified to account for factors such as AHKv2's lack of generics, strong typing etc.
 * 
 * Note that all of the methods in this class return `Enumerator` instances, which also replicates the lazy evaluation behavior of the `IEnumerable` interface in C#. You may enumerate the the results of these methods using `Enumerator.Enumerate()`. It replicates the `To#` methods in C#, where `#` is the desired type of the result.
 * 
 * For example, `Linq.Select([1, 2, 3], x => x * 2).Enumerate()` will return `[2, 4, 6]`.
 */
class Linq
{
    /**
     * Aggregate
     * All
     * Any
     * Average
     * Cast
     * Concat
     * Contains
     * Count
     * DefaultIfEmpty
     * Distinct
     * ElementAt
     * ElementAtOrDefault
     * Empty
     * Except
     * First
     * FirstOrDefault
     * GroupBy
     * Intersect
     * Join
     * Last
     * LastOrDefault
     * LongCount
     * Max
     * Min
     * OfType
     * OrderBy
     * OrderByDescending
     * Reverse
     * Select
     * SelectMany
     * SequenceEqual
     * Single
     * SingleOrDefault
     * Skip
     * SkipWhile
     * Sum
     * Take
     * TakeWhile
     * ThenBy
     * ThenByDescending
     * ToArray
     * ToDictionary
     * ToList
     * ToLookup
     * Union
     * Where
     * Zip
     */

    /**
     * Aggregates an `Array` or a `Map` using a custom aggregate function and a provided seed value.
     * @param source The source object to aggregate.
     * @param aggregateFunc The function that receives the current seed value, its index in the `source` collection and a value depending on the type of the source object:
     * - If it is an `Array`, the items are passed in as-is.
     * - If it is a `Map`, the name-value pairs are passed as objects in the format `{ Name, Value }`.
     * @param seed The starting value for the accumulator.
     * @param resultSelector The function that transforms the final seed value into the return value. Defaults to `unset` if omitted, which causes the final seed value to be returned as-is.
     * @returns The final seed value as-is or what `resultSelector` transformed it into.
     */
    static Aggregate(source, aggregateFunc, seed, resultSelector?)
    {
        if (source is Array)
        {
            for i, item in source
            {
                seed := aggregateFunc(seed, i, item)
            }
        }
        else if (source is Map)
        {
            c := 0
            for name, value in source
            {
                seed := aggregateFunc(seed, ++c, { Name: name, Value: value })
            }
        }
        else
        {
            throw TypeError("The source collection must be an ``Array`` or a ``Map``.")
        }

        if (IsSet(resultSelector))
        {
            return resultSelector(seed)
        }
        else
        {
            return seed
        }
    }

    /**
     * Returns a value that indicates whether all elements of a collection satisfy a condition.
     * @param source The source collection to iterate over.
     * @param predicate The function 
     */
    static All(source, predicate?)
    {
        throw codebase.errors.NotImplementedError("Linq.All")
    }

    static Select(source, selector?)
    {
        ret := []
        if (source is Array)
        {
            if (IsSet(selector))
            {
                if (selector.MaxParams == 1)
                {
                    for item in source
                    {
                        ret.Push(selector(item))
                    }
                }
                else if (selector.MaxParams == 2)
                {
                    for index, item in source
                    {
                        ret.Push(selector(index, item))
                    }
                }
                else
                {
                    throw ValueError("The selector function for an Array must accept either 1 (for just the current element) or 2 (for the element's index in the source collection and the element itself) parameters.")
                }
            }
            else
            {
                return source
            }
        }
        else if (source is Map)
        {
            if (IsSet(selector))
            {
                if (selector.MaxParams == 2)
                {
                    for name, value in source
                    {
                        ret.Push(selector(name, value))
                    }
                }
                else if (selector.MaxParams == 3)
                {
                    c := 0
                    for name, value in source
                    {
                        ret.Push(selector(++c, name, value))
                    }
                }
                else
                {
                    throw ValueError("The selector function for a Map must accept either 2 (for the name and the value of each name-value pair) or 3 (for the name-value pair's index in the source collection, the name and the value) parameters.")
                }
            }
            else
            {
                return source
            }
        }
        else
        {
            throw TypeError("The source collection must be an ``Array`` or a ``Map``.")
        }
    }

    static Template(source, function?)
    {
        throw codebase.errors.NotImplementedError("Linq.Template", "Linq.Template cannot be called.")

        if (source is Array)
        {
            if (IsSet(function))
            {
                if (function.MaxParams == 1)
                {
                    for item in source
                    {

                    }
                }
                else if (function.MaxParams == 2)
                {
                    for index, item in source
                    {

                    }
                }
                else
                {
                    throw ValueError("The selector function for an Array must accept either 1 (for just the current element) or 2 (for the element's index in the source collection and the element itself) parameters.")
                }
            }
            else
            {
                return source
            }
        }
        else if (source is Map)
        {
            if (IsSet(function))
            {
                if (function.MaxParams == 2)
                {
                    for name, value in source
                    {

                    }
                }
                else if (function.MaxParams == 3)
                {
                    c := 0
                    for name, value in source
                    {

                    }
                }
                else
                {
                    throw ValueError("The selector function for a Map must accept either 2 (for the name and the value of each name-value pair) or 3 (for the name-value pair's index in the source collection, the name and the value) parameters.")
                }
            }
            else
            {
                return source
            }
        }
        else
        {
            throw TypeError("The source collection must be an ``Array`` or a ``Map``.")
        }
    }
}

try
{
    enumerateEnumerator(enumerator)
    {
        arr := []
        for item in enumerator
        {
            arr.Push(item)
        }
        return arr
    }

    defProp := {}.DefineProp
    defProp(Enumerator.Prototype, "Enumerate", { Call: enumerateEnumerator })
}