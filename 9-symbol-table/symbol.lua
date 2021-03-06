package.path = package.path .. ";../lib/constant.lua"
require("constant")


--[[
    Field names to access specific values of a Symbol. 
--]]
local SymbolFields = {
    NAME = "name",      -- name
    ARITY = "arity",    -- number of arguments
    ACTION = "action",  -- code for the action, if built-in symbol, 0 if not
    PROC = "proc"       -- clause chain
}


Symbol = {}

--[[
    Constructs a Symbol. Once constucted, a symbol remains constant.
    
    @returns - a Symbol.
--]]
function Symbol.new(name, arity, action, proc) 
    local self = {}
    
    --[[
        Stores the name, arity, action, proc values for this Symbol.
    --]]
    local symbolVals = constant.protect({        
        name      = name,
        arity     = arity,
        action    = action,
        proc      = proc
    })
        
    --[[        
        @param key the index of the value being searched for.
        @returns - the value at the index 'key'.
    --]]
    function self:get(key) 
        return symbolVals[key]
    end
    
    --[[
        @returns - the table containing the name, arity,
                   action and proc for this symbol. 
    --]]
    function self:getvals()
        return symbolVals
    end
    
    --[[
        Compares this Symbol to the Symbol symbol.
        @returns - true if this Symbol is equal to symbol.
    --]]
    function self:compare(symbol)
        local isEqual = true
        
        for key,val in next, SymbolFields, nil do
            if(symbolVals[val] ~= symbol:getvals()[val]) then           
                isEqual = false
            end
        end
        
        return isEqual    
    end
        
    return self
    
end

