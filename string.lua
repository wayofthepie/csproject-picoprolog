StringBuilder = {}

function StringBuilder.new()
    local self = {}
    local str = {}
    
    --[[
        Constructs a string as a polog list.
        @param string -string to build
    --]]
    function self:build(string)
        local index = 0
        for char in string:gmatch"." do            
            str[index] = char
            index = index + 1
            str[index] = ":"
            index = index + 1
        end 
    end
    
    --[[
        
    --]]
    function getChar()
    
    end
end