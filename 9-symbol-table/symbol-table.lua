package.path = package.path .. ";../lib/constant.lua"
require("constant") 
require("built-in-relations")
require("symbol")

Symtab = {}

--[[
    Table used to store symbols
--]]
function Symtab.new()
    local self = {}
    local symbols = {}
        
    --[[
        Checks whether a symbol already exists in the symbol table.
        
        @returns Boolean -true if the symbol exists, false otherwise.
    --]]
    function self:exists(symbol)
        local exists = false
        for k,v in pairs(symbols) do
            if v:compare(symbol) then
                exists = true
            end
        end
        return exists
    end
    
    function self:defineSymbol(symbol)
        
    end
    
    function self:initBuiltInSymbols()
        
    end
end