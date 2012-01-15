package.path = package.path .. ";../0-prelude/prelude.lua"
require "prelude"

Scanner = {}

function Scanner.new() 
    local self = {}
    
    local chars = {}
    
    local index = 1
    
    local token, tokval, tokival, toksval
    local errflag, errcount
    
    function self:syntaxerror()
        
    end
    
    function self:showError()
    
    end
    
    function self:recover()
    
    end
    
    function self:scan()
        
    end
    
    --[[ 
        Opens a (text) file and builds a table of all the 
        characters contained in the file.
        Does not store any whitespaces.
        Must change to add ENDOFLINE to each end of line.
    --]]
    function self:loadFile(filename)
        local file = io.open(filename)
        for line in file:lines() do
            for char in line:gmatch"." do
                if not char:match"%s" then
                    table.insert(chars,char)
                else
                    table.insert(chars,SpecVals.SPACE)
                end                
             end
             table.insert(chars,SpecVals.ENDLINE)
        end
        table.insert(chars,SpecVals.ENDFILE)
    end
    
    function self:currentChar()
        return chars[index]
    end
    
    --[[
        Gets the next character from the file loaded.
    --]]
    function self:nextChar()
        index = index + 1
        return chars[index]  
    end
        
    --[[
        Checks whether there is another character in the input.
    --]]
    function self:hasNext()
        local hasNext = false        
        if chars[index] ~= nil then
            hasNext = true
        end            
        return hasNext
    end
    
    function self:dec()
        index = index -1
    end
    
    function self:printAll()
        for k,v in pairs(chars) do 
            print(k .. " " .. v)
        end
    end

    return self
    
end

--[[
s = Scanner.new()
s:loadFile("../../lua-prolog-code/prolog/factorial.pl")
s:printAll()
--]]