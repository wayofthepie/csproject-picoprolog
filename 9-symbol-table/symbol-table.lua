package.path = package.path .. ";../lib/constant.lua"
require("constant") 
require("built-in-relations")
require("symbol")

SymbolTable = {}

--[[
    Table used to store symbols. 
    
    TODO Use hash function to compute index.
--]]
function SymbolTable.new()
    local self = {}
    
    local symcount = 0
    local symbols = {}
       
        
    --[[
        Checks whether a symbol already exists in the symbol table.
        @param symbol - the Symbol being searched for.  
        @returns -true if the symbol exists, false otherwise.
        
        TODO this comparison should just be by name, 
        and not comparing all values in each symbol, as now symbols 
        with 
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
    
    --[[
        Adds a Symbol to the table symbols, if that Symbol does not already exist. 
        @param symbol - the Symbol you want to define
    --]]
    function self:defineSymbol(symbol)
        if not self:exists(symbol) then
            symbols[symbol] = symbol
            symcount = symcount + 1
        else
            print("Cannot define a non-unique symbol!")
        end
    end
    
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
        
        TODO these symbols must be created so they can be accessed
        from anywhere.
    --]]
    local function initBuiltInSymbols()
        self:defineSymbol(Symbol.new(":      ", 2, 0, nil))
        self:defineSymbol(Symbol.new("!      ", 0, BuiltIn.CUT, nil))
        self:defineSymbol(Symbol.new("=      ", 2, BuiltIn.EQUALIY ,nil))
        self:defineSymbol(Symbol.new("nil      ", 0, 0, nil))
        self:defineSymbol(Symbol.new("not      ", 1, BuiltIn,NAFF, nil))
        self:defineSymbol(Symbol.new("call      ", 1, BuiltIn.CALL, nil))
        self:defineSymbol(Symbol.new("plus      ", 3, BuiltIn.PLUS, nil))
        self:defineSymbol(Symbol.new("times      ", 3, BuiltIn.TIMES, nil))
        self:defineSymbol(Symbol.new("integer      ", 1, BuiltIn.ISINT, nil))
        self:defineSymbol(Symbol.new("char      ", 1, BuiltIn.ISCHAR, nil))
        self:defineSymbol(Symbol.new("false      ", 0, BuiltIn.FAIL, nil))
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