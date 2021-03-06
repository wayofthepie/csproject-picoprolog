--[[ 
    Some useful functions taken from functional languages
    e.g.Haskell.
--]]


--[[
    
    map(function,table)
    
    maps the function "function" over the values of table "table" and returns
    a table containing the results.
    
--]]
function map(f,t)
    local mapped = {}
    for k,v in pairs(t) do 
        results[k] = f(v)
    end
    return mapped
end


--[[
    
    filter(function,table)
    
    reduces the table "table" by applying the predicate contained in "function"
    to the table.
    
--]]
function filter(f,t)
    local filtered = {}
    for k,v in pairs(t) do
        if f(v) then t[k] = v end
    end
end


--[[
    
    foldr(function,value,table)
    
--]]
function foldr(f,val,t)  
    for k,v in pairs(t) do
        val = f(val,v)
    end
    return val
end

