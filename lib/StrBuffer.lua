
StrBuffer = {}
--[[
    Used to build up strings.
--]]
function StrBuffer.new()
    local self = {}
    local string = {}
    local index = 1
    
    --[[
        Appends the string 's' to the end of this StringBuffer.
    --]]
    function self:append(s)
        string[index] = s
        index = index + 1
    end
    
    --[[
        Returns each string in this table concatenated into
        a single string.
    --]]
    function self:toString()
        return table.concat(string, "")
    end
    
    --[[
        Returns each string in the table seperated by a return 
        character, used if printing the string.
    --]]
    function self:toPrintString()
        return table.concat(string, "\n")
    end
    
    return self
end