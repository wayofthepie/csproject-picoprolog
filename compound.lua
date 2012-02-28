require "prelude"

Compound = {}
function Compound.new()
    
    local self = {}
    
    local termKind = Term.FUNC
    
    local symbol 
    
    local arguments = {}
    
    local arity = 0
    
    function self:setSymbol(sym)    symbol = sym end
    function self:setArgs(args)     arguments = args end
    function self:setArity(num)     arity = num end
    
    function self:getSymbol()   return symbol end
    function self:getArgs()     return args end
    function self:getArity()    return arity end
    function self:getTermKind() return termKind end
    
    function self:toString()
        print("Compound:")
        print(self:getSymbol())
        print(self:getArgs())
        print(self:getArity())
        print("------------")
    end
    
    return self    
end