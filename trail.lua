require("memory")
require("stackframes")

--[[
    Records assignments to variables so they can be undone on backtracking.
    It is a list of Node's of type UNDO, allocated on the global stack.
--]]
Trail = {}

function Trail.new(memory)
    
    local self = {}
    
    --[[
        Head of the trail
    --]]
    local trhead
    
    --[[
        Table containing the state of the trail.
    --]]
    local trail = {}
    
          
    --[[
        Tests whether a variable will survive backtracking.
        @param var - pointer to variable
        @param choice - pointer to frame
    --]]
    function self:isCritical(var,choice)
        local isCritical = false
        local frame = memory:get(choice)
        if var < choice and var >= frame:getGloTop() then
            isCritical = true
        end
        return isCritical
    end
    
    --[[
        Add a critical variable to the trail
        @param var - pointer to variable
    --]]
    function self:save(var, choice)
        local pointer
        local critical
        local node
        if isCritical(var,choice) then
            critical = CriticalVar(var,trhead)
            node = Node.new(Term.UNDO,critical)
            pointer = memory:gloAlloc(node)
            trhead = pointer
        end
        
    end
    
    --[[
        Undo bindings back to a previous state.
    --]]
    function self:restore()
        
    end
    
    --[[
        Blank out trail entries not needed after cut.
    --]]
    function self:commit()
    
    end
    
    return self
    
end

--[[
    Stores the variables to be reset, and a pointer to the next 
    trail entry. Used in conjunction with Node objects of type UNDO 
    to store the variables in memory.
--]]
CriticalVar = {}

function CriticalVar.new(var,trailEntry)
    
    local self = {}
    
    --[[
        Pointer to variable to be reset.
    --]]
    local reset = var
    
    --[[
        Pointer to the next trail entry.
    --]]
    local nextEntry = trailEntry
    
    function self:getResetVar() return reset end
    
    function self:getNextEntry() return trailEntry end
    
end