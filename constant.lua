constant = {}

--[[
    Function to allow the creation of constants defined in a table.
    Protects the table, throws an error if there is an attempt to change any value.
    The second argument to 'error' reports the error in a level above this function.
    
    @param _table - the table to be protected.
    @returns - a metatable protecting the values in _table from being changed.
--]]
function constant.protect(_table) 
    return setmetatable({}, {
        __index = _table,
        __newindex = function(t, key, val)
                        error("Cannot change constant " .. tostring(key) .. 
                              " to " .. tostring(val), 2)
                     end
    })
end

return constant