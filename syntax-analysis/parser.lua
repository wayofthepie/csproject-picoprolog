module("parser",package.seeall)
package.path = package.path .. ";../12-scanner/?.lua;"
require "analyzer"


Parser = {}
function Parser.new() 
    local self = {}
    
    function self:eat()
        
    end
    
    function self:parseCompund()
        
    end

end