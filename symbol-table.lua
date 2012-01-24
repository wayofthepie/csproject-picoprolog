package.path = package.path .. ";../lib/constant.lua;../0-prelude/?.lua;../lib/?.lua;"
require("constant") 
require("built-in-relations")
require("symbol")

--[[
    Table mapping built in relations to integer codes.
--]]
local BuiltIn = {
    CUT     = 1,         -- !/0
    CALL    = 2,
    PLUS    = 3,
    TIMES   = 4,
    ISINT   = 5,
    ISCHAR  = 6,
    NAFF    = 7,
    EQUALITY= 8,
    FAIL    = 9
}

SymbolTable = {}

--[[
    Table used to store symbols. 
    Use metatables!!!!!
    TODO Use hash function to compute index.
--]]
function SymbolTable.new()
    
    local self = {}
    
    --[[
        Number of symbols.
    --]]
    local symcount = 0
    
    --[[
        Stores the symbols.
    --]]
    local symbolsTable = {}
    
    
    --[[
        Variables for storing builtin symbols
    --]]
    
    -- cons symbol (":", list concatenation)
    local cons
    
    -- cut symbol ("!")
    local cutsym
    
    -- equality symbol ("=")
    local eqsym
    
    -- nil symbol ("nil")
    local nilsym
    
    -- not symbol ("not")
    local notsym    
    
        
    --[[
        Checks whether a symbol already exists in the symbol table.
        @param symbol - the Symbol being searched for.  
        @returns - 1. true if the symbol exists, false otherwise.
                   2. the symbol or nil if not found
        
        TODO this comparison should just be by name, 
        and not comparing all values in each symbol, as now symbols 
        with 
    --]]
    function self:symbolExists(symbol)
        local sym = nil
        local exists = false
        
        for k,v in pairs(symbolsTable) do
            if v:compare(symbol) then
                exists = true
                sym = v
            end
        end
        return exists,sym
    end
       
    --[[
        @param symbolName   -string representing the name of this symbol.
        @return             -exists: true if the symbol exists
                            -symbol: the symbol if it exists
    --]]
    function self:symbolNameExists(symbolName)
        local symbol
        local exists = false
        
        for k,v in pairs(symbolsTable) do
            if v:get(SymbolFields.NAME) == symbolName  then
                exists = true
                symbol = v
            end
        end
        return exists, symbol
    end
    
    --[[
        Adds a Symbol to the table symbols, if that Symbol does not already exist. 
        @param symbol   -the Symbol you want to define
        @return         -the Symbol
    --]]
    function self:defineSymbol(symbol)
        if not self:symbolExists(symbol) then
            if symbol['arity'] == nil then
                symbol['arity'] = -1
            end
            symbolsTable[symbol] = symbol
            symcount = symcount + 1
        else
            print("Cannot define a non-unique symbol!")
        end
        return symbol
    end    
    
    --[[
        @return  -the nil symbol
    --]]
    function self:getNilSym()   return nilsym end
    
    --[[
        @return  -the cons symbol
    --]]
    function self:getConsSym()  return cons end
    
    --[[
        @return  -the equality symbol
    --]]    
    function self:getEqSym()    return eqsym end
    
    
    --[[ 
        Prints all the values of all the symbols in the table.
    --]]
    function self:printSymbols()
        for k,v in pairs(symbols) do
            print(v:getvals()[SymbolFields.NAME],v:getvals()[SymbolFields.ARITY],
                  v:getvals()[SymbolFields.ACTION], v:getvals()[SymbolFields.PROC])
        end
    end
    
    --[[
        Initializes the bult-in symbols (relations).
    --]]
    local function initBuiltInSymbols()
        cons = self:defineSymbol(Symbol.new(":", 2, 0, nil))
        self:defineSymbol(Symbol.new("!", 0, BuiltIn.CUT, nil))
        eqsym = self:defineSymbol(Symbol.new("=", 2, BuiltIn.EQUALIY ,nil))
        nilsym = self:defineSymbol(Symbol.new("nil", 0, 0, nil))
        self:defineSymbol(Symbol.new("not", 1, BuiltIn,NAFF, nil))
        self:defineSymbol(Symbol.new("call", 1, BuiltIn.CALL, nil))
        self:defineSymbol(Symbol.new("plus", 3, BuiltIn.PLUS, nil))
        self:defineSymbol(Symbol.new("times", 3, BuiltIn.TIMES, nil))
        self:defineSymbol(Symbol.new("integer", 1, BuiltIn.ISINT, nil))
        self:defineSymbol(Symbol.new("char", 1, BuiltIn.ISCHAR, nil))
        self:defineSymbol(Symbol.new("false", 0, BuiltIn.FAIL, nil))
    end
    
    --[[
        Initializes the bult-in symbols (relations) on creation of
        this object.
    --]]
    initBuiltInSymbols()   
    
    return self
end

--[[
    s = Symbol.new("n", "t", "i", "o")
    symtab = SymbolTable.new()
    symtab:printSymbols()
    symtab:defineSymbol(Symbol.new(":      ", 1, 0, nil))
    symtab:printSymbols()
    
--]]