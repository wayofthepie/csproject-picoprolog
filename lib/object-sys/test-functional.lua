--[[ 
    Some useful functions taken from functional languages
    e.g.Haskell.
--]]

--[[
    
    map(f,t)
    
    maps the function f over the values of table t and returns
    a table containing the results.
    
--]]
function map(f,t)
    local results = {}
    for k,v in pairs(t) do 
        results[k] = f(v)
    end
    return results
end

function add2(v)
    return v + 2
end

test = {1,2,3,4}
res = map(add2,test)
print(type(res))
