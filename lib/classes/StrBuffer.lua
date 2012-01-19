
StrBuffer = {}
--[[
    Used to build up strings.
--]]
function StrBuffer.new()
    local self = {}
    local string = {}
    local index = 1
    
    --[[
        Appends the character 'char' to the end of this StrngBuffer.
    --]]
    function self:append(char)
        string[index] = char
        index = index + 1
    end
    
    --[[
    --]]
    function self:toString()
        return table.concat(string, "")
    end
    
    return self
end