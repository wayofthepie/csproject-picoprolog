package.path = package.path .. ";../0-prelude/prelude.lua"
require "prelude"

Scanner = {}

function Scanner.new(filename) 
    
    local self = {}
    
    --[[
        Keeps track of the line number.
    --]]
    local lineno = 1
    
    --[[
        Character pushed back on the scanner.
    --]]
    local pushedChar = nil
    
    --[[        
        File to read from.
    --]]
    local file = io.open(filename)
      
    --[[
        Gets the next character from the file loaded.
       @return -the next character from input.
    --]]
    function self:nextChar()
        local char = ""   
        -- if the next char is not already read
        if pushedChar == nil then
            char = file:read(1)
            if char ~= nil then
                
                while char:match"%s" do                     
                    char = file:read(1) 
                    if char == nil then
                        break
                    end
                end
                
                if char == '\n' then
                    char = SpecVals.ENDLINE
                    lineno = lineno + 1
                    print(lineno)
                end
                
            end
            if char == nil then
                char = SpecVals.ENDFILE
                lineno = lineno + 1
            end
        --    print("ret = " .. char)
        else
            char = pushedChar
            pushedChar = nil
        end
        return char
    end
  
    -- Public Functions
    --[[
        @return -the current line number.        
    --]]
    function self:getLineNum() return lineno end
    
    --[[
        Pushes a character back on the scanner
        @param char -the character to push back.
    --]]
    function self:push(char) pushedChar = char end
    
   
    --[[
        Whether the scanner has a character pushed back on it.
        @return -true if the scanner has a character pushed back.
    --]]
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