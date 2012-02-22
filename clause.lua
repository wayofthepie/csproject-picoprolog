Clause = {}
function Clause.new()
    
    local self = {}
    
    -- Number of variables
    local nvars = 0
    
    -- Term
    local head
    
    -- Arguments
    local body
    
    -- Number of arguments
    local nbody = 0
    
    function self:setNumVars(num)   nvars = num end
    function self:setHead(term)     head = term end
    function self:setBody(args)     body = args end
    function self:setNumBody(num)   nbody = num end
    
    
    function self:getNumVars()  return nvars end
    function self:getHead()     return head end
    function self:getBody()     return body end
    function self:getNumBody()  return nbody end
    
    return self
end