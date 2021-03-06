--[[
    Defines the types _permstring and _tempstring used in 
    C.3 String Buffer.
--]]
package.path = package.path .. ";../0-prelude/?.lua;../lib/constant.lua"
require("constant")
require("prelude")

--[[
    _permstring =   a type that only allows strings of size <= TunableParameters.MAXCHARS.
                    returns an immutable "_permstring" object.
    _tempstring = 
--]]
_permstring = {}
_tempstring = {}

--[[
    Constructs a "_permstring".
    
    Returns this constructed _permstring protected from any changes
    using the constant.protect method defined in lib/.
--]]
function _permstring.new(string) 
    
    --[[    
        Sets the 'value' key of the table to be the String 'string' 
        if and only if the Strings length is <= TunableParameters.MAXCHARS.
    --]]
    local self = {
           value =  (function (str) 
                        if str:len() > TunableParameters.MAXCHARS then
                            error("Cannot set higher than " .. TunableParameters.MAXCHARS)
                        else
                            return str
                        end
                     end) (string)
    }   
    
    --[[
        Returns the value of the 'value' field of this _permstring
    --]]
    function self:getval() 
        return self["value"] 
    end
    
    return constant.protect(self)
    
end


--[[
    Constructs a "_tempstring".
--]]

function _tempstring.new(string)
    local self = {}
    
end

    