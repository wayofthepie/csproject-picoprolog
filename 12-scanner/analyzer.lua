module("analyzer",package.seeall)
package.path = package.path .. ";../0-prelude/?.lua;"
require("prelude") require("scanner") require("token-values")
require "table" require "constant"
scan = Scanner.new()

scan:loadFile("test.pp")
--scan:printAll()

StrBuffer = {}
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

    -- Should use an iterator here possibly..
    while token == 0 and char ~= nil do
        -- Is the char a letter?
        if type(char) == "string" and string.find(char, '%a') ~= nil then
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
             print("strval = \"" .. sbuff:toString() .. "\"|")
            scan:dec()
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
local t = ""
while t ~= 0 do
    t = getNextToken()
   
end
