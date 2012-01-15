-- Create a module called analyzer
module("analyzer",package.seeall)

package.path = package.path .. ";../0-prelude/?.lua;../lib/?.lua"
require "prelude" require "scanner" require("token-values")
 require "constant"

-- Construct a new scanner
local scan = Scanner.new()

-- Load a file into the scanner
scan:loadFile("test.pp")
--scan:printAll()

local StrBuffer = {}
--[[
    Used to build up strings.
--]]
function StrBuffer.new()
    local self = {}
    local string = {}
    local index = 1
    
    --[[
        Appends the character 'char' to the end of this StrngBuffer.
    --]]
    function self:append(char)
        string[index] = char
        index = index + 1
    end
    
    --[[
    --]]
    function self:toString()
        return table.concat(string, "")
    end
    
    return self
end

Token = {}

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

local tlib = require "tlib"

--print(scan:hasNext())
function getNextToken()
    local token = 0
    local tokval 
    local tokival = 0
    local toksval = ""
    local tokenlen = 0
    local tokvar= ""
    local sbuff = StrBuffer.new()
    local num = 0
    local char = scan:nextChar()
    local rules = Rules.new()
    
    -- Should use an iterator here possibly..
    while token == 0 and char ~= nil do
        if char == SpecVals.ENDFILE then
            token = TokVal.EOFTOK
        elseif char == SpecVals.ENDLINE then
            char = scan:nextChar()
        -- Is the char a letter?
        elseif string.find(char, '%a') ~= nil then
            -- Is it an uppercase letter?
            if string.find(char, '%u') ~= nil then
                token = TokVal.VARIABLE
            else 
                token = TokVal.IDENT
            end
            tokenlen = 1
            -- While it's a letter or digit
            while (string.find(char, '%a') ~= nil) or (string.find(char, '%d') ~= nil) do
                if tokenlen > TunableParameters.MAXSTRING then
                    error("identifier too long!")
                end               
                sbuff:append(char)
                tokenlen = tokenlen + 1
                char = scan:nextChar()
            end
            
            
        -- Is it a number?
        elseif type(char) == "number" then
            token = TokVal.NUMBER
            tokival = tokival * 10
            while type(char) == "number" do
                tokival = tokival + char
                char = scan:nextChar()                
            end    
            
            scan:dec()
        else 
            -- cases
            local switch = {
                ["("] = function() token = TokVal.LPAR;     print("(") end,
                [")"] = function() token = TokVal.RPAR;     print(")")  end,
                [","] = function() token = TokVal.COMMA;    print(",") end,
                ["."] = function() token = TokVal.DOT       print(".") end,
                ["="] = function() token = TokVal.EQUAL     print("=") end,
                ["!"] = function() token = TokVal.IDENT; --[[ TODO tokval = cutsym --]] end,
                ["/"] = function() 
                            char = scan:nextChar()
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
                        end,
                [":"] = function() 
                            char = scan:nextChar()
                            if char == "-" then
                                token = TokVal.ARROW
                            else
                                scan:dec()
                                token = TokVal.COLON
                            end
                        end,
                ["\'"] = function()
                             token = TokVal.CHCON
                             -- TODO tokival = ascii rep of char ~IMPROVE
                             scan:nextChar()
                             char = scan:nextChar()
                             if char ~= "\'" then
                                 error("missing quote!")
                             end
                         end,
                ["\""] = function()
                             token = TokVal.STRCON 
                             token = toklen + 1
                             char = scan:nextChar()
                             while char ~= "\"" and char ~= SpecVals.ENDLINE do
                                 sbuff:append(char)
                                 char = scan:nextChar()
                                 tokenlen = tokenlen + 1
                                 if char == SpecVals.ENDLINE then
                                     error("unterminated string!")
                                     scan:dec()
                                 end
                             end
                         end        
            }
            -- Any access to an index that does not exist will return "illegal".
           
            tlib.setDefault(switch, "illegal")
            
            case = switch[char]
            
            if  case == "illegal" then 
                error("illegal character " .. char .. "!")
            else 
                case()
            end
          
        end

         
    end
    return token        
end

function getToken2()
    local token = Token.new(0,0)
    local rules = Rules.new()
    while token:getValue() == 0 do        
        char = scan:currentChar()
        r = rules:rules()
        
        token = r[char](char)
        --print(token)
        
        --print(token:getType())
        
        --print(scan:currentChar())
    end
    return token
end
local lineno = 1
Rules = {}
function Rules.new() 
    local self = {}
    
    local sbuff = StrBuffer.new()
   
    local rules = {
        [SpecVals.SPACE]    =   function() scan:nextChar() return Token.new(0,0) end,
        
        [SpecVals.ENDFILE]  =   function()
                                    return Token.new(TokVal.EOFTOK)
                                end,
                                
        [SpecVals.ENDLINE]  =   function()                                   
                                    scan:nextChar() 
                                    lineno = lineno + 1
                                    print ("line num = " .. lineno)
                                    return Token.new(TokVal.EOLTOK) 
                                end,
                                
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
                                    
        ["NUMBER"]          =   function(char)
                                    local num = StrBuffer.new()
                                   
                                    while string.find(char, '%d') ~= nil do
                                        num:append(char)
                                        char = scan:nextChar()
                                    end
                                    local k = num.toString()
                                   
                                    --[[
                                        lua provides auto conversion between strings and numbers
                                        at runtime, so no need to convert string to number before
                                        creating the following token.
                                    --]]
                                    return Token.new(TokVal.NUMBER, num:toString())
                                end,
                                
        ["("]               =   function() 
                                    scan:nextChar()
                                    return Token.new(TokVal.LPAR,"(")
                                end,
                                
        [")"] = function() 
                    scan:nextChar()
                    return Token.new(TokVal.RPAR,")")                         
                end,
                
        [","] = function() 
                    scan:nextChar()
                    return Token.new(TokVal.COMMA,",")
                end,
                
        ["."] = function() 
                    scan:nextChar()
                    return Token.new(TokVal.DOT,".")       
                end,
                
        ["="] = function() 
                    scan:nextChar()
                    return Token.new(TokVal.EQUAL,"=")     
                end,
        ["!"] = function() 
                    scan:nextChar()
                    --[[ TODO tokval = cutsym --]] 
                    return Token.new(TokVal.IDENT,"!") 
                    end,
                    
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
                    
        ['ILLEGAL'] =   function(char) 
                            -- TODO kill interpreter
                            error("illegal character " .. char .." on line ".. lineno )                             
                        end
                   
    }
    
    function self:rules() return rules end
    
    function func(char) 
        local ret
        if string.find(char, '%u') ~= nil then
            ret =  rules['VARIABLE'](char)        
        elseif string.find(char, '%a') ~= nil then
            ret = rules['IDENT'](char)
        elseif string.find(char, '%d') then
            ret = rules['NUMBER'](char)
        else
            ret = rules['ILLEGAL'](char)
        end
        return ret
    end
    
    tlib.setDefault(rules, func)
    
    
    return self
end
--scan:printAll()
local t = -1
while t ~= TokVal.EOFTOK do
    t = getToken2()
    val = t:getValue() 
    if val == nil then val = "nil" end
    print("type= " .. t:getType() .. " | value= " .. val)
    t = t:getType()
end

