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
    Values used throughout.
--]]
SpecVals = constant.protect({
    SPACE = "SPACE",
    ENDLINE = "ENDLINE",
    ENDFILE = "ENDFILE"    
})

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

Term = constant.protect({
    FUNC = 1,
    INT = 2,
    CHRCTR = 3,
    CELL = 4,
    REF = 5,
    UNDO = 6
})
