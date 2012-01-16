module("analyzer", package.seeall)
-- Edit the package search path
package.path = package.path .. ";../0-prelude/?.lua;../lib/?.lua;../lib/classes/?.lua;../9-symbol-table/?.lua"
require "prelude" require "scanner" require("token-values")
require "constant" require "StrBuffer" require "symbol-table"



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
    
    local scan = Scanner.new()
    local _tlib = require "_tlib"       
    local sbuff = StrBuffer.new()
    local lineno = 1
    
    local rules = {
        --[[
            Whitespace rules: 
            Ignore, scan the next character and return a Token of type and value 0.
        --]]
        [SpecVals.SPACE]    =   function() scan:nextChar() return Token.new(0,0) end,
        
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
                                    print(lineno)
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
                                            error("identifier too long!")
                                        end             
                                        
                                        sbuff:append(char)
                                        tokenlen = tokenlen + 1                                       
                                        char = scan:nextChar()                                       
                                    end
                                
                                    
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
                                            error("identifier too long!")
                                        end             
                                        
                                        sbuff:append(char)
                                        tokenlen = tokenlen + 1
                                        
                                        char = scan:nextChar()
                                    
                                    end
                                    
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
                                    local k = num.toString()
                                
                                    --[[
                                        lua provides auto conversion between st    -- Load a file into the scanner
    scan:loadFile("test.pp")rings and numbers
                                        at runtime, so no need to convert string to number before
                                        creating the following token.
                                    --]]
                                    return Token.new(TokVal.NUMBER, num:toString())
                                end,
        
        --[[
            Right parenthesis:
        --]]
        ["("]               =   function() 
                                    scan:nextChar()
                                    return Token.new(TokVal.LPAR,"(")
                                end,
        
        --[[
            Left parenthesis:
        --]]
        [")"] = function() 
                    scan:nextChar()
                    return Token.new(TokVal.RPAR,")")                         
                end,
                
        --[[
            Comma:
        --]]
        [","] = function() 
                    scan:nextChar()
                    return Token.new(TokVal.COMMA,",")
                end,
        
        --[[
            Dot:
        --]]
        ["."] = function() 
                    scan:nextChar()
                    return Token.new(TokVal.DOT,".")       
                end,
                
        --[[
            Equals:
        --]]
        ["="] = function() 
                    scan:nextChar()
                    return Token.new(TokVal.EQUAL,"=")     
                end,
        
        --[[
            Exclamation:
        --]]
        ["!"] = function() 
                    scan:nextChar()
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
                        error("bad token \"/\"")
                    else 
                        chartwo = ' '
                        char = scan:nextChar()
                        while scan:hasNext() and not(chartwo =='*' and char == "/") do
                            chartwo = char; char = scan:nextChar() 
                        end
                        if scan:hasNext() == nil then
                            error("end of file in comment!")
                        else
                            char = scan:nextChar()
                        end
                    end       
                    return Token.new(0,0)
                end,
        
        --[[
            Colon - (incorporates rules for ":-"):
        --]]
        [":"] = function(char)
                    local token = 0
                    char = scan:nextChar()
                    if char == "-" then
                        token = Token.new(TokVal.ARROW,":-")
                        scan:nextChar()
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
                            error("missing quote!")
                        end
                        scan:nextChar()
                        
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
                                error("unterminated string!")
                                scan:dec()
                            end
                        end
                        return Token.new(TokVal.STRCON,sbuff)
                    end,
                    
        --[[
            Illegal characters:
        --]]
        ['ILLEGAL'] =   function(char) 
                            -- TODO kill interpreter
                            error("illegal character " .. char .." on line ".. lineno )                             
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
        print(scan:currentChar())
        token = self:applyRules(scan:currentChar())
        return token
    end
          
    -- Private Functions
    --[[
        Refers to a specific index in the rules table, depending on
        what the value of 'char' is.
        @param char -
    --]]
    local function ruleMatcher(char) 
        local ret
        -- uppercase character
        if string.find(char, '%u') ~= nil then
            ret = rules['VARIABLE'](char)
        
        -- lowercase character
        elseif string.find(char, '%a') ~= nil then
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
    
    -- Load a file into the scanner
    scan:loadFile(filename) 
    
    return self
end
--[[
-- Testing --
local t = -1
local lexer = LexicalAnalyzer.new("../test/test.pp")

while t ~= TokVal.EOFTOK do
    t = lexer:getNextToken()
    val = t:getValue() 
    if val == nil then val = "nil" end
    print("type= " .. t:getType() .. " | value= " .. val)
    t = t:getType()
end

--]]