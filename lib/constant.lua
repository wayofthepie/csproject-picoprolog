
constant = {}

--[[
    Function to allow the creation of constants defined in a table.
    Protects the table, throws an error if there is an attempt to change any value.
    The second argument to 'error' reports the error in a level above this function.
--]]
function constant.protect(table) 
    return setmetatable({}, {
        __index = table,
        __newindex = function(t, key, val)
                        error("Cannot change constant " .. tostring(key) .. 
                              " to " .. tostring(val), 2)
                     end
    })
end

return constant