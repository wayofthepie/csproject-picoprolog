-- TODO varLookup()

--[[
    Builds the internal representation of the program.
--]]
Parser = {}

--[[
    @param memoryBuilder    - Build
    @param varTab           - VarTable
--]]
function Parser.new(memoryBuilder, varTab)
    
    local self = {}  
    
    --[[
        Lexical Analyzer 
    --]]
    local lexer = LexicalAnalyzer.new(arg[1])
    
    --[[
        Current token
    --]]
    local token = nil
    
    --[[
        Library for useful table functions
    --]]
    local _tlib = require "lib/_tlib"
    
    --[[-- Private Functions --]]--
    --[[
        Checks for an expected token and ignores it
        @param tokenType -the type of the expected token
    --]]
    local function eat(tokenType)        
        local expected = token:getType()
        if expected == tokenType then
            if tokenType ~= TokVal.DOT then
                print("eating = " .. tokenType)
                token = lexer:getNextToken()                
            end
        end
    end
    
    --[[
        Checks that a literal is a compound term.
    --]]
    local function checkAtom(atom)
        if  memoryBuilder:getType(atom) ~= Term.FUNC then
            error("literal must be compound term")            
            os.exit(1)
        end
    end
       
    --[[
        Parse a compound term. Atoms are compound terms of 0 arity.
    --]]
    function self:parseCompound() 
     
        -- The arguments of the term
        local args  = {}
        
        -- The number of arguments
        local arity   = 0
               
        -- Whether the token value exists as a symbol
        local exists, symbol = symTab:symbolNameExists(token:getValue())
        
        -- Current value of token
        local symVal = token:getValue()

        -- Compound to create
        local compound = Compound.new()
        
        compound:setSymbol(token:getValue())
        
        eat(TokVal.IDENT)
        -- Get the arity
        if token:getType() == TokVal.LPAR then
            eat(TokVal.LPAR)
            arity = 1
            args[1] = self:parseTerm()  -- add the terms          
            while token:getType() == TokVal.COMMA do
                eat(TokVal.COMMA)
                arity = arity + 1
                args[arity] = self:parseTerm()                
            end            
            compound:setArgs(args)
            compound:setArity(arity)
            eat(TokVal.RPAR)            
        end
        
        -- if symbol exists
        if exists then
            local symArity = symbol:get(SymbolFields.ARITY)
            if symArity == -1 then
                symbol:set(SymbolFields.ARITY,arity)  
            elseif symArity ~= arity then
                error("wrong number of arguments")
            end
        end   
        
        return memoryBuilder:makeCompound(compound)
    end
    
    --[[
        Parse a primary.        
        Rules:  primary ::= compound | variable | number | string | char | ‘(’ term ‘)’
        @return -pointer to the term on the heap
    --]]
    function self:parsePrimary()
        
        local term
        
        --[[
            Defines rules for term generation 
        --]]
        local rules = {
            
            --[[
                Identifier:
            --]]
            [TokVal.IDENT]          =   function() term = self:parseCompound()  end,
            
            --[[
                Variable:
            --]]
            [TokVal.VARIABLE]       =   function() 
                                            term = varTab:insert(token:getValue())
                                            
                                            --print("t val= " .. token:getValue())
                                            eat(TokVal.VARIABLE) 
                                        end,
            
            --[[
                Number:
            --]]
            [TokVal.NUMBER]         =   function() 
                                            term = memoryBuilder:makeInt(token:getValue()) 
                                            eat(TokVal.NUMBER)                                            
                                        end,
            
            --[[
                Character:
            --]]
            [TokVal.CHCON]          =   function() 
                                            term = memoryBuilder:makeChar(token:getValue())
                                            eat(TokVal.CHCON)
                                        end,
            
            --[[
                String:
            --]]
            [TokVal.STRCON]         =   function() 
                                            term = memoryBuilder:makeString(token:getValue())
                                            eat(TokVal.STRCON)
                                        end,
            
            --[[
                Left parenthesis:
            --]]
            [TokVal.LPAR]           =   function() 
                                            eat(TokVal.LPAR)
                                            term = self:parseTerm()
                                            eat(TokVal.RPAR)
                                        end,
                                                  
            [TokVal.ARROW]           =  function() 
                                            print("arrow") 
                                            eat(TokVal.ARROW) 
                                        end
        }
             
        --[[
            Prints an error and kills lua.
            @param tokenType -the type of token
        --]]                
        local function default(tokenType) 
            error("expected a term!!") 
            os.exit(1)
        end
        
        --[[
            Sets the default return value of table 'terms'
            to the function 'default'.
        --]]
        _tlib.setDefault(rules,default) 
        
        rules[token:getType()]()
        
        return term
    end
    
    function self:parseFactor() 
        local args = {}
        local compound
        local term = self:parsePrimary()
       
        if token:getType() == TokVal.COLON then
            compound = Compound.new()
            eat(TokVal.COLON)
            args = { term, self:parseFactor() }
            compound:setSymbol(symTab:getConsSym())
            compound:setArgs(args)
            term = memoryBuilder:makeCompound(compound)
        end  
        
        return term
    end
    
    --[[
        Parses a term.         
        Rules: term ::= primary [ ':' term ]
        @return -pointer to the term on the heap
    --]]
    function self:parseTerm() 
        local compound
        local term = self:parseFactor()
              
        if token:getType() == TokVal.EQUAL then
            compound = Compound.new()
            eat(TokVal.EQUAL)
            args = { term, self:parseFactor() }
            compound:setSymbol(symTab:getEqSym())
            compound:setArgs(args)
            term = memoryBuilder:makeCompound(compound)
        end    
        
        return term
    end
    
    --[[
        TODO This must be fixed...
        @return index of the clause on the heap
    --]]
    function self:parseClause(isgoal)      
        local head,term
        local minus = false
        local body  = {}
        local num   = 0
              
        if isgoal then
            head = nil
        else             
            head = self:parseTerm()                  
            checkAtom(head)            
            eat(TokVal.ARROW)
        end
        
        if token:getType() ~= TokVal.DOT then            
            while token:getType() ~= TokVal.COMMA do
                
                num = num + 1
                minus = false
                
                if token:getType() == TokVal.NEGATE then
                    eat(TokVal.NEGATE)
                    minus = true                    
                end
                
                term = self:parseTerm()
                
                if token:getType() == TokVal.DOT then
                    break
                else                    
                    checkAtom(term)
                end
                
                if minus then
                    body[num] = 
                        memoryBuilder:makeNode(symTab:getNilSym(),term,nil)
                else                   
                    body[num] = term
                end
                
                if token:getType() ~= TokVal.COMMA then 
                    break 
                end
                
                eat(TokVal.COMMA)
            end
        
        end
        return memoryBuilder:makeClause(varTable:getNumVars(),head,body,num)
    end
    
    --[[
        Entry point for parser. Reads a clause and builds its internal 
        representation in memory. Returns a pointer to the clause on the heap.
        @return -pointer to the clause on the heap.
    --]]    
    function self:readClause()
       
        local clause = nil      
       
        --[[
            Generate a new variable table for the new clause.
        --]]
        varTable = VarTable.new() 
        
        token = lexer:getNextToken() 
        
        if token:getType() ~= TokVal.EOFTOK then
                   
            --[[
                If its the end of the file, set clause to be nil.
            --]]
            if token:getType() == TokVal.EOFTOK then
                clause = nil
            else              
                
                -- interacting var should be passed instead 
                clause = self:parseClause(true)                                 
                
                -- print variables in this clause
                --varTab:printVars()                
            end
        end
       
        return clause
    end    
     
    return self
end


