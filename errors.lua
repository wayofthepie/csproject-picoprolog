--[[
--]]

Errors = {}

function Errors.new()
    local self = ){}
    local run = false
    local dflag = false
    
    --[[
        Prints the error and cleanly exits.
    --]]
    function self:execerror(args) 
        print()
    end    
    
    
    return self
end

function Errors.