module("analyzer", package.seeall)
-- Edit the package search path
package.path = package.path .. ";../0-prelude/?.lua;../lib/?.lua;../lib/classes/?.lua;../9-symbol-table/?.lua"
require "prelude" require "scanner" 
require "constant" require "StrBuffer" require "symbol-table"

--turn off stack tracebacks for now:
debug.traceback=nil

--[[
    Class to represent tokens.
--]]
local Token = {}
function Token.new(token, value)
    local self = {}
    
    local t = token
    local v = value
    
    
    function self:getType()
        return t
    end
    
    function self:getValue()
        return v
    end
    
    return self
end

--[[
    Represents rules for characters being scanned.
--]]

LexicalAnalyzer = {}
function LexicalAnalyzer.new(filename) 
    local self = {}
    
    local scan = Scanner.new(filename)
    local _tlib = require "_tlib"       
    local sbuff = StrBuffer.new()
    local futureToken = nil
    local lineno = 1
    
    local rules = {
        --[[
            Whitespace rules: 
            Ignore, scan the next character and return a Token of type and value 0.
        --]]
        [SpecVals.SPACE]    =   function() 
                                    scan:nextChar() 
                                    return Token.new(SpecVals.SPACE,SpecVals.SPACE) 
                                end,
        
        --[[
            End of file rules: 
        --]]
        [SpecVals.ENDFILE]  =   function()
                                    return Token.new(TokVal.EOFTOK)
                                end,
        
        --[[
            End of line rules:
            TODO fix line number counting.
        --]]
        [SpecVals.ENDLINE]  =   function()                                         
                                    lineno = lineno + 1
                                    scan:nextChar()                                         
                                    return Token.new(TokVal.EOLTOK, lineno) 
                                end,
        
        --[[
            Rules for identifiers:
        --]]
        ['IDENT']           =   function(char) 
                                    local tokenlen = 1
                                    local sbuff = StrBuffer.new()
                                    
                                    while (string.find(char, '%a') ~= nil) or 
                                        (string.find(char, '%d') ~= nil) or 
                                        (char == "_") do
                                        
                                        if tokenlen > TunableParameters.MAXSTRING then
                                            error("Syntax Error: identifier too long! line: " 
                                                  .. lineno)
                                           
                                        end             
                                        
                                        sbuff:append(char)
                                        tokenlen = tokenlen + 1
                                        char = scan:nextChar()                                       
                                    end
                                    scan:push(char)                                    
                                    return Token.new(TokVal.IDENT,sbuff:toString())
                                end,
        
        --[[
            Rules for variables:
        --]]
        ['VARIABLE']        =   function(char) 
                                    local tokenlen = 1
                                    local sbuff = StrBuffer.new()
                                    while (string.find(char, '%a') ~= nil) or 
                                        (string.find(char, '%d') ~= nil) or
                                        (char == "_") do
                                        
                                        if tokenlen > TunableParameters.MAXSTRING then
                                            error("Syntax Error: identifier too long! line: " 
                                                  .. lineno)
                                        end             
                                        
                                        sbuff:append(char)
                                        tokenlen = tokenlen + 1
                                        
                                        char = scan:nextChar()
                                    
                                    end
                                    scan:push(char)
                                    return Token.new(TokVal.VARIABLE, sbuff:toString())
                                end,
        --[[
            Rules for numbers:
        --]]
        ["NUMBER"]          =   function(char)
                                    local num = StrBuffer.new()
                                    
                                    while string.find(char, '%d') ~= nil do
                                        num:append(char)
                                        char = scan:nextChar()
                                    end
                                                                    
                                    --[[
                                        lua provides auto conversion between strings and numbers
                                        at runtime, so no need to convert string to number before
                                        creating the following token.
                                    --]]
                                    return Token.new(TokVal.NUMBER, num:toString())
                                end,
        
        --[[
            Right parenthesis:
        --]]
        ["("]               =   function()                                     
                                    return Token.new(TokVal.LPAR,"(")
                                end,
        
        --[[
            Left parenthesis:
        --]]
        [")"] = function() 
                    
                    return Token.new(TokVal.RPAR,")")                         
                end,
                
        --[[
            Comma:
        --]]
        [","] = function() 
                    
                    return Token.new(TokVal.COMMA,",")
                end,
        
        --[[
            Dot:
        --]]
        ["."] = function() 
                    
                    return Token.new(TokVal.DOT,".")       
                end,
                
        --[[
            Equals:
        --]]
        ["="] = function() 
                    
                    return Token.new(TokVal.EQUAL,"=")     
                end,
        
        --[[
            Exclamation:
        --]]
        ["!"] = function() 
                    
                    --[[ TODO tokval = cutsym --]] 
                    return Token.new(TokVal.IDENT,"!") 
                    end,
        
        --[[
            Forward slash:
                                    lineno = 
            If we see this character, check the next. If that is not a "*", then 
            throw an error for the "/" character. Else loop until we find either then
            closing symbol of a comment (*/) or the end of the character stream, throw
            an error in the latter case.
        --]]
        ["/"] = function() 
                    local char = scan:nextChar()
                    if char ~= "*" then
                        error("Syntax Error: bad token \"/\", possibly an unclosed comment.")
                    else 
                        chartwo = ' '
                        char = scan:nextChar()
                        while char ~= nil and not(chartwo =='*' and char == "/") do                            
                            chartwo = char; char = scan:nextChar() 
                        end
                        if char == nil then
                            error("Syntax Error: end of file in comment! line: " .. lineno)                       
                        end
                    end       
                    return Token.new(TokVal.COMMENT)
                end,
        
        --[[
            Colon - (incorporates rules for ":-"):
        --]]
        [":"] = function(char)
                    local token = 0
                    char = scan:nextChar()
                    if char == "-" then
                        token = Token.new(TokVal.ARROW,":-")                        
                    else                        
                        token = Token.new(TokVal.COLON,":")
                    end
                    
                    return token
                end,
        --[[
            Single quote (') - incorporates rules for characters in lprolog e.g 'a':
        --]]
        ["\'"] = function()
                        local char = ''
                        -- TODO tokival = ascii rep of char ~IMPROVE
                        char = scan:nextChar() 
                                            
                        if scan:nextChar()   ~= "\'" then
                            -- throw syntax error
                            error("Syntax Error: missing quote, possibly an"
                                   .. " incomplete character constant line: " 
                                   .. lineno)
                        end
                        
                        
                        return Token.new(TokVal.CHCON, char)
                    end,
        
        --[[
            Double quote (") - incorporates rules for string in lprolog e.g "hello":
        --]]
        ["\""] = function()                       
                        local char = scan:nextChar()
                        while char ~= "\"" and char ~= SpecVals.ENDLINE do
                            sbuff:append(char)
                            char = scan:nextChar()
                            tokenlen = tokenlen + 1
                            if char == SpecVals.ENDLINE then
                                error("Syntax Error: unterminated string!")                               
                            end
                        end
                        return Token.new(TokVal.STRCON,sbuff)
                    end,
                    
        --[[
            Illegal characters:
        --]]
        ['ILLEGAL'] =   function(char) 
                            -- TODO kill interpreter
                            error("SYNTAX ERROR: illegal character " .. char .." on line ".. lineno )                             
                        end
                
    }
    
    -- Public Functions
    --[[
        @return the table representing the rules for characters.
    --]]
    function self:applyRules(char) 
        return rules[char](char)
    end
    
    
    --[[
        Returns the next token generated from the character strea starting at the 
        character the scanner is currently pointing to.
        @return -the next token.
    --]]
    function self:getNextToken()
        local token    
        local c = scan:nextChar()
       -- print("char= " .. c)
        token = self:applyRules(c)
        return token
    end
          
    -- Private Functions
    --[[
        Refers to a specific index in the rules table, depending on
        what the value of 'char' is.
        @param char -char to find a rule for.
    --]]
    local function ruleMatcher(char) 
        local ret
        -- uppercase character
        if string.find(char, '%u') ~= nil then
            ret = rules['VARIABLE'](char)
        
        -- lowercase character
        elseif string.find(char, '%l') ~= nil then
            ret = rules['IDENT'](char)
        
        -- digit
        elseif string.find(char, '%d') then
            ret = rules['NUMBER'](char)
        
        --illegal
        else               
            ret = rules['ILLEGAL'](char)
        end
        return ret
    end
    
    -- Initialization
    --[[
        Sets the default value that rules will return if an non-existant 
        index tries to be accessed.
    --]]
    _tlib.setDefault(rules, ruleMatcher) 
    
  
    
    return self
end

-- Testing --
local t = -1
local lexer = LexicalAnalyzer.new(arg[1])

while t ~= TokVal.EOFTOK do
    t = lexer:getNextToken()
    val = t:getValue() 
    t = t:getType()
    if val == nil then val = "nil" end
    print("type= " .. t .. " | value= " .. val)
    
end

