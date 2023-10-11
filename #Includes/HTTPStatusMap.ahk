class HTTPStatusMap
{
    class responses
    {

    }

    static _data := HTTPStatusMap.buildMappings()

    static buildMappings()
    {
        mappings := Map(
            "Continue",                      100,
            "Switching Protocols",           101,
            "OK",                            200,
            "Created",                       201,
            "Accepted",                      202,
            "Non-Authoritative Information", 203,
            "No Content",                    204,
            "Reset Content",                 205,
            "Partial Content",               206,
            "Multiple Choices",              300,
            "Moved Permanently",             301,
            "Found",                         302,
            "See Other",                     303,
            "Not Modified",                  304,
            "Use Proxy",                     305,
            "Temporary Redirect",            307,
            "Bad Request",                   400,
            "Unauthorized",                  401,
            "Payment Required",              402,
            "Forbidden",                     403,
            "Not Found",                     404,
            "Method Not Allowed",            405,
            "Not Acceptable",                406,
            "Proxy Authentication Required", 407,
            "Request Timeout",               408,
            "Conflict",                      409,
            "Gone",                          410,
            "Length Required",               411,
            "Precondition Failed",           412,
            "Payload Too Large",             413,
            "URI Too Long",                  414,
            "Unsupported Media Type",        415,
            "Range Not Satisfiable",         416,
            "Expectation Failed",            417,
            "Upgrade Required",              426,
            "Internal Server Error",         500,
            "Not Implemented",               501,
            "Bad Gateway",                   502,
            "Service Unavailable",           503,
            "Gateway Timeout",               504,
            "HTTP Version Not Supported",    505
        )
        
        for key, value in mappings.Clone()
        {
            if (!(mappings.Has(value)))
            {
                mappings.Set(value, key)
            }

            HTTPStatusMap.responses.DefineProp(RegExReplace(key, "[ \-]"),   { Value: RegExReplace(value, "[ \-]") })
            HTTPStatusMap.responses.DefineProp(RegExReplace(value, "[ \-]"), { Value: RegExReplace(key, "[ \-]") })
        }

        return mappings
    }

    /**
     * Translates from a string to a status code or vice versa.
     * @param data The string or status code to translate.
     * @note Lookup is case-insensitive and characters such as spaces, hyphens and underscores are ignored when comparing descriptions.
     * @throws `Error` if `err` is `true` and no corresponding description or status code was found.
     * @return The status code or the string for a given status code, depending on which was passed, or an empty string if no corresponding description or status code was found.
     */
    static translate(data, err := true)
    {
        search := StrLower(RegExReplace(data, "[\s\-_]+", ''))

        for k, v in HTTPStatusMap._data.Clone()
        {
            if (StrLower(RegExReplace(k, "[\s\-_]+", '')) = search)
            {
                return v
            }
        }

        if (err)
        {
            throw Error("Unable to find corresponding status code or description for input ``" . data . "``.")
        }

        return ""
    }
}
