require "analyzer" require "prelude" require "memory"
require "symbol"   require "symbol-table" 


OldParser = {}
function OldParser.new(symTab) 
    
    local self = {}    
    
    -- Stores the variables seen so far
    local variables = {}
    
    -- Stores the number of variables of a clause
    local nvars = 0
    
    -- Lexical Analyzer object
    local lexer = LexicalAnalyzer.new(arg[1])
    
    -- Current token
    local token = lexer:getNextToken()
    
    -- The type of the token
    local tType = token:getType()
    
    -- The value of the token
    local tValue = token:getValue()
               
    -- 
    local mem = OldMemory.new()
    
    -- Build object (allocates memory)
    local memoryBuilder = Build.new(symTab,mem)
    
    -- Table library
    local _tlib = require "lib/_tlib"
    
    
    local function varLookup(name)        
        local ref = 1
        if nvars == TunableParameters.MAXARITY then
            error("too many variables")
            os.exit(1)
        end
        
        variables[nvars + 1] = name
        
        while name ~= variables[ref] do 
            ref = ref + 1
        end
        
        if ref == nvars + 1 then 
            nvars = nvars + 1
        end
        
        return memoryBuilder:makeRef(ref)
    end
    
    
    --[[
        Checks for an expected token and ignores it
        @param tokenType -the type of the expected token
    --]]
    local function eat(tokenType)
        print("eat " .. tokenType)
        local expected = token:getType()
        if expected == tokenType then
            if tokenType ~= TokVal.DOT then
                token = lexer:getNextToken()
                tType = token:getType()
                tValue = token:getValue()               
            end
        end
    end
    
    --[[
        Parse a compound. 
        Rules: compound ::= ident['('term { ',' term }')']
        @return -pointer to the term on the heap
    --]]
    function self:parseCompound()       
        --print("parseCompound")
        
        -- The arguments of the term
        local args  = {}
        
        -- The number of arguments
        local arity   = 0
               
        -- Whether the token value exists as a symbol
        local exists, symbol = symTab:symbolNameExists(tValue)
        
        -- CUrrent value of token
        local symVal = token:getValue()

        eat(TokVal.IDENT)
        
        -- Get the arity
        if tType == TokVal.LPAR then
            eat(TokVal.LPAR)
            arity = 1            
            args[1] = self:parseTerm()            
            while tType == TokVal.COMMA do
                eat(TokVal.COMMA)
                arity = arity + 1
                args[arity] = self:parseTerm()
               print(token:getValue())
            end            
            eat(TokVal.RPAR)            
        end
        
        -- 
        if exists then
            local symArity = symbol:get(SymbolFields.ARITY)
            if symArity == -1 then
                symbol:set(SymbolFields.ARITY,arity)  
            elseif symArity ~= arity then
                error("wrong number of arguments")
            end 
        else
            symbol = Symbol.new(symVal,arity,0,nil)
        end
        
        local x = memoryBuilder:makeCompound(symbol,args)
        print("x = " ..x)
        return x
    
    end
    
    --[[
        Parse a primary.        
        Rules:  primary ::= compound | variable | number | string | char | ‘(’ term ‘)’
        @return -pointer to the term on the heap
    --]]
    function self:parsePrimary()
        --print("parsePrimary")
        local term
        local terms = {
            [TokVal.IDENT]          =   function() term = self:parseCompound()  end,
            
            [TokVal.VARIABLE]       =   function() 
                                            varLookup(token:getValue())
                                            eat(TokVal.VARIABLE) 
                                        end,
                                        
            [TokVal.NUMBER]         =   function() 
                                            term = memoryBuilder:makeInt(tValue) 
                                            eat(TokVal.NUMBER)                                            
                                        end,
            
            [TokVal.CHCON]          =   function() 
                                            term = memoryBuilder:makeChar(tValue)
                                            eat(TokVal.CHCON)
                                        end,
            
            [TokVal.STRCON]         =   function() 
                                            term = memoryBuilder:makeString(tValue)
                                            eat(TokVal.STRCON)
                                        end,
                                    
            [TokVal.LPAR]           =   function() 
                                            eat(TokVal.LPAR)
                                            term = self:parseTerm()
                                            eat(TokVal.RPAR)
                                        end      
        }
             
        --print("token= "..token:getType() .. " " .. token:getValue())
        --[[
            Prints an error and kills lua.
        --]]        
        
        local function default(tokenType) 
            error("expected a term!!") 
            os.exit(1)
        end
        
        --[[
            Sets the default return value of table 'terms'
            to the function 'default'.
        --]]
        _tlib.setDefault(terms,default) 
      --  print(token:getType())
         terms[token:getType()]()
         print(term)
        return term
    end
    
    --[[
        @return -pointer to the term on the heap
    --]]
    function self:parseFactor()
       -- print("parseFactor")
        local term
        term = self:parsePrimary()
        print("f=")
        print(term)
        if token:getType() == TokVal.COLON then
            eat(TokVal.COLON)
            term = memoryBuilder:makeNode(symTab:getConsSym(),
                                          term,self:parseFactor())
        end        
        --print(term)
        print("end parseFactor")
        return term
    end
    
    --[[
        Parses a term.         
        Rules: term ::= primary [ ':' term ]
        @return -pointer to the term on the heap
    --]]
    function self:parseTerm()
        --print("parseTerm")
        local term        
        term = self:parseFactor()
        print("t=")
        print(term)
        if token:getType() == TokVal.EQUAL then
            eat(TokVal.EQUAL)
            term = memoryBuilder:makeNode(eqsym,term,self:parseFactor())
        end    
        
        print("end parseTerm")
        return term
    end
    
    local function checkAtom(atom)
    
        --print(atom)
        --print("kind = " .. memoryBuilder:getKind(atom))
        print(memoryBuilder:getKind(atom))
        if memoryBuilder:getKind(atom) ~= Term.FUNC then
            error("literal must be compound term")
            
        end
    end  
    
    --[[
        Parses a clause. Rules:        
        clause ::= [ atom | '#' ] ':-' [ literal { ',' literal } '.' ]
        @return -pointer to the term on the heap
    --]]
    function self:parseClause(isgoal)
        --print("parseClause")
        local head,term
        local minus = false
        local body  = {}
        local num   = 0
        local tType = t
        
        if isgoal then
            head = nil
        else 
            head = self:parseTerm()
            print("head")
            print(head)
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
                
                checkAtom(term)
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
        
        eat(TokVal.DOT)
        
        -- if error return nil else
        return memoryBuilder:makeClause(nvars,head,body,num)
    end
    
    
    function self:readClause()
        local clause       
        
        repeat     
            nvars = 0            
            token = lexer:getNextToken()            
            -- Point heap to heapmark
            mem:setHeapPointer(mem:getHeapMark())
                       
            if token:getType() == TokVal.EOFTOK then
                clause = nil
            else 
                -- interacting var should be passed instead 
                clause = self:parseClause(true) 
                
            end
        until token:getType() == TokVal.EOFTOK
        return clause
    end
    
  
    
    function self:showAnswer()
        local show = false
        local num = 0
        local char
        
        if nvars == 0 then
            show = true
        else
            
        end
            
    end
    
    function self:p()
        memoryBuilder:printMem()
    end
    
    return self
      
end


Parser = {}
function Parser.new(symTab,mem)
    
    local self = {}    
    
    -- Stores the variables seen so far
    local variables = {}
    
    -- Lexical Analyzer object
    local lexer = LexicalAnalyzer.new(arg[1])
    
    -- Current token
    local token = lexer:getNextToken()
    
    
    --[[-- Private Functions --]]--
    --[[
        Checks for an expected token and ignores it
        @param tokenType -the type of the expected token
    --]]
    local function eat(tokenType)
        local expected = token:getType()
        if expected == tokenType then
            if tokenType ~= TokVal.DOT then
                token = lexer:getNextToken()                           
            end
        end
    end
    
    --[[
    --]]
    local function parseCompound() 
     
        -- The arguments of the term
        local args  = {}
        
        -- The number of arguments
        local arity   = 0
               
        -- Whether the token value exists as a symbol
        local exists, symbol = symTab:symbolNameExists(tValue)
        
        -- CUrrent value of token
        local symVal = token:getValue()

        eat(TokVal.IDENT)
        
        -- Get the arity
        if token:getType() == TokVal.LPAR then
            eat(TokVal.LPAR)
            arity = 1
            args[1] = self:parseTerm()            
            while token:getType() == TokVal.COMMA do
                eat(TokVal.COMMA)
                arity = arity + 1
                args[arity] = parseTerm()
            end            
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
        
        return memoryBuilder:makeCompound(symbol,args)
    end
    
    --[[
        Parse a primary.        
        Rules:  primary ::= compound | variable | number | string | char | ‘(’ term ‘)’
        @return -pointer to the term on the heap
    --]]
    local function parsePrimary()
        
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
                                            varLookup(token:getValue())
                                            eat(TokVal.VARIABLE) 
                                        end,
            
            --[[
                Number:
            --]]
            [TokVal.NUMBER]         =   function() 
                                            term = memoryBuilder:makeInt(tValue) 
                                            eat(TokVal.NUMBER)                                            
                                        end,
            
            --[[
                Character:
            --]]
            [TokVal.CHCON]          =   function() 
                                            term = memoryBuilder:makeChar(tValue)
                                            eat(TokVal.CHCON)
                                        end,
            
            --[[
                String:
            --]]
            [TokVal.STRCON]         =   function() 
                                            term = memoryBuilder:makeString(tValue)
                                            eat(TokVal.STRCON)
                                        end,
            
            --[[
                Left parenthesis:
            --]]
            [TokVal.LPAR]           =   function() 
                                            eat(TokVal.LPAR)
                                            term = self:parseTerm()
                                            eat(TokVal.RPAR)
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
        _tlib.setDefault(terms,default) 
      
        rules[token:getType()]()
        
        return term
    end
    
    local function parseFactor() 
        local term = self:parsePrimary()
       
        if token:getType() == TokVal.COLON then
            eat(TokVal.COLON)
            term = memoryBuilder:makeNode(symTab:getConsSym(),
                                          term,parseFactor())
        end  
        
        return term
    end
    
    local function parseTerm() 
        local term = parseFactor()
              
        if token:getType() == TokVal.EQUAL then
            eat(TokVal.EQUAL)
            term = memoryBuilder:makeNode(symtab:getEqSym(),
                                          term,parseFactor())
        end    
        
        return term
    end
    
    local function parseClause(isgoal)      
        local head,term
        local minus = false
        local body  = {}
        local num   = 0
              
        if isgoal then
            head = nil
        else 
            head = self:parseTerm()            
            --checkAtom(head)
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
                --checkAtom(term)
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
    
    --[[--Public functions--]]--
    
end


tab = SymbolTable.new()
mem = OldMemory
p = OldParser.new(tab)
p:readClause()