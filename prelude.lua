--[[
    Tunable parameters
--]]
package.path = package.path .. ";../lib/constant.lua"
require("constant")


--[[
    These are set to the same as picoProlog, can be changed.
--]]
TunableParameters = constant.protect({
    MAXSYMBOLS = 511,
    HASHFACTOR = 90,
    MAXCHARS = 2048,
    MAXSTRING = 128,
    MAXARITY = 63,
    MEMSIZE = 24576,
    GCLOW = 512,
    GCHIGH = 4096
})


--[[
    Special values.
--]]
SpecVals = constant.protect({
    SPACE = "SPACE",
    ENDLINE = "ENDLINE",
    ENDFILE = "ENDFILE"    
})

--[[
    Possible values for tokens.
--]]
TokVal = constant.protect({
    IDENT = "IDENTIFIER",
    VARIABLE = "VARIABLE",
    NUMBER = "NUMBER",
    CHCON = "CHARACTER_CONSTANT",
    STRCON = "STRING_CONSTANT",
    ARROW = "ARROW",
    LPAR = "LEFT_PARENTHESIS",
    RPAR = "RIGHT_PARENTHESIS",
    COMMA = "COMMA",
    DOT = "DOT",
    COLON = "COLON",
    EQUAL = "EQUAL",
    NEGATE = "NEGATE",
    COMMENT = "COMMENT",
    EOLTOK = "EOLTOK",
    EOFTOK = "EOFTOK"    
})

--[[
    These constants are now used mainly to identify Nodes in memory.
--]]
Term = constant.protect({
    CLAUSE = "clause",      -- clause
    FUNC = "func",          -- compound term
    INT = "int",            -- integer
    CHRCTR = "character",   -- character
    STRING = "string",      -- string
    CELL = "cell",          
    REF = "ref",
    VAR = "var",
    UNDO = "undo"
})
