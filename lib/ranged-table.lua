--[[
    Defines an object which contains functions to keep track of certain
    aspects of tables.
--]]
_track_ = {} 
    
--[[
    Makes sure the table "table" can only store "maxrange" number
    of values.
--]]
function _track_.range(table, maxrange)
    local proxy = {}
    local index = {}
    local itemcount = 0
    
    proxy[index] = table
    
    setmetatable(proxy,{
        __index =   function(t,k)                   
                        return t[index][k]
                    end,
       
        __newindex =    function(t,k,v)     
                            -- if the new value is not nil
                            if v ~= nil then                                
                                -- if the current value is not nil
                                if t[index][k] ~= nil then                                
                                    t[index][k] = v                                
                                else                                     
                                    -- if the itemcount is lt maxrange
                                    if itemcount < maxrange then    
                                        itemcount = itemcount + 1
                                        t[index][k] = v
                                    else
                                        error("Max number of values exceeded!!",2)
                                    end
                                end
                            else
                                error("Cannot set value to nil!!")
                            end
                        end
    })          
    
    return proxy
end

t = {}
t = _track_.range(t,2)

t[9] =" w"
t[9] = 2
t[9] = 2
t[0] = 0
t[8] = 8
print(t[9])