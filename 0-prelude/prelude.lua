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
