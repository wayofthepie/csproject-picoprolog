package.path = package.path .. ";../0-prelude/prelude.lua"
require "prelude"

Scanner = {}

function Scanner.new(filename) 
    local self = {}
    
    local chars = {}
    local pushedChar = nil
    local file = io.open(filename)
      
    --[[
        Gets the next character from the file loaded.
    --]]
    function self:nextChar()
        local char = ""   
        if pushedChar == nil then
            char = file:read(1)
            if char == nil then
                char = SpecVals.ENDFILE
            else
                while char:match"%s" do 
                    char = file:read(1)        
                end
            end
            print("ret = " .. char)
        else
            char = pushedChar
            pushedChar = nil
        end
        return char
    end
  
    --[[
        Stores the character char.
    --]]
    function self:push(char)
        pushedChar = char
    end
    
   
    
    function self:hasPushedChar()
        local hasPushed = false
        if pushed ~= nil then
            hasPushed = true
        end
        return hasPushed
    end
    
    return self
end

--[[
s = Scanner.new()
s:loadFile("../../lua-prolog-code/prolog/factorial.pl")
s:printAll()
--]]