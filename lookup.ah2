#Include ".\#Includes\ahk-codebase.ah2"

wolfram_appid := "P364EJ-HP72P7YLVP"

/**
 * Inserts passed command line arguments `A_Args[2]` and `A_Args[3]` into a template string and opens the resulting URL in the default browser.
 * @param A_Args[2] The gesetz_abk to look up in.
 * @param A_Args[3] The number of the Gesetz to look up.
 */
gesetz()
{
    uri := 'https://www.gesetze-im-internet.de/' . A_Args[2] . '/__' . A_Args[3] . '.html'
    Run(uri)
}

/**
 * Inserts passed command line argument `A_Args[2]` into a template string and opens the resulting URL in the default browser.
 * @param A_Args[2] The ISBN to search for. May be passed with or without the usual dashes.
 */
isbn()
{
    uri := 'https://isbnsearch.org/isbn/' . StrReplace(A_Args[2], "-", "")
    Run(uri)
}

/**
 * Inserts passed command line arguments `A_Args[2]` and `A_Args[3]` into a template string and makes a request to https://dictionaryapi.dev/ to retrieve the word's dictionary entry.
 * @param A_Args[2] The language abbreviation to look up in (e.g. `de` for German, `en` for English, etc.)
 * @param A_Args[3] The word to look up.
 */
dict()
{
    req := codebase.requests.makeRequest("https://api.dictionaryapi.dev/api/v2/entries/" . A_Args[2] . "/" . A_Args[3], "GET")

    out := ""
    cnt := 1

    try
    {
        for entry in req.Get("JSON")
        {
            for meaning in entry.Get("meanings")
            {
                for definition in meaning.Get("definitions")
                {
                    out .= cnt . ": " . definition.Get("definition") . "`n"
                    cnt++
                }
            }
        }
    }
    catch (Error as e)
    {
        if (req.Get("JSON").Get("title") == "No Definitions Found")
        {
            out := "No definitions found. Check for typos in your query."
        }
        else
        {
            throw e
        }
    }

    MsgBox(out)
}

/**
 * Inserts passed command line arguments `A_Args[2]` and `A_Args[3]` into a template string and makes a request to http://api.wolframalpha.com/ to retrieve the solution of the query.
 * @param A_Args[2] The query to look up the solution for. Wrap this in quotation marks if it contains spaces.
 * @param A_Args[3] Whether to show all `<plaintext>` tag contents (`true`) or display only the first one. If omitted or a value other than `true`, `false` is assumed.
 */
solve()
{
    showExtraInfo := false
    if (A_Args.Has(3))
    {
        if (A_Args[3] == "true")
        {
            showExtraInfo := true
        }
    }

    input := Trim(A_Args[2], '`t `r`n"`'')
    input := StrReplace(input, "+", "%2B")

    req := codebase.requests.makeRequest('http://api.wolframalpha.com/v2/query?appid=' . wolfram_appid . "&input=" . input, "GET")

    out := ""
    txt := StrSplit(req.Get("ResponseText"), "`n")
    firstFound := false

    for line in txt
    {
        if (RegExMatch(line, "<plaintext>(.*)<\/plaintext>", &match))
        {
            if (!firstFound)
            {
                out .= Trim(StrReplace(match[1] . "`n", A_Space, ""))
                firstFound := true
            }
            else
            {
                if (showExtraInfo)
                {
                    out .= Trim(match[1] . "`n")
                }
            }
        }
    }

    MsgBox(out)
}

ol()
{
    uri := 'https://onelook.com/thesaurus/?s=' . StrReplace(StrReplace(A_Args[2], "-", ""), " ", "+")
    Run(uri)
}

try %A_Args[1]%()
catch
{
    try %A_Args[1]%(codebase.collectionOperations.arrayOperations.subarray(A_Args, 2)*)
    catch
    {
        throw ValueError("Unrecognized lookup action ``" . A_Args[1] . "``.") 
    }
}