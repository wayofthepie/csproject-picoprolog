
--[[
    Constructs a string as a polog list.
    @param string -string to build
--]]
function buildString(string)
    local index = 1
    local str = {}
    str[index] = "nil"
    for char in string:gmatch"." do            
        str[index] = char
        index = index + 1
        str[index] = ":"
        index = index + 1
    end 
    str[index] = "nil"
    return str
end

t = buildString("test")

for k,v in pairs(t) do print(k .. v) end