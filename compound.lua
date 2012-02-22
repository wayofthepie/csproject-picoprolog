Compound = {}
function Compound.new()
    
    local self = {}
    
    local symbol 
    
    local arguments = {}
    
    local arity = 0
    
    function self:setSymbol(sym)    symbol = sym end
    function self:setArgs(args)     arguments = args end
    function self:setArity(num)     arity = num end
    
    function self:getSymbol()   return symbol end
    function self:getArgs()     return args end
    function self:getArity()    return arity end
    
    return self    
end