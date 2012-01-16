module("_tlib",package.seeall)

--[[
    Table functions
    A library for useful functions on tables
--]]

local _tlib = {}

--[[
    Sets the default value of an index in the table 'table' to
    be the value 'default'.
    @param table -the table to change the default returned value in.
    @param default -the value to change to.
--]]
function _tlib.setDefault(table, default)
    local mt = {__index = function() return default end}
    setmetatable(table, mt)
end
      
--[[
    
    map(function,table)
    
    maps the function "function" over the values of table "table" and returns
    a table containing the results.
    
--]]
function _tlib.map(f,t)
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
function _tlib.filter(f,t)
    local filtered = {}
    for k,v in pairs(t) do
        if f(v) then t[k] = v end
    end
end


--[[
    
    foldr(function,value,table)
    
--]]
function _tlib.foldr(f,val,t)  
    for k,v in pairs(t) do
        val = f(val,v)
    end
    return val
end

        
return _tlib