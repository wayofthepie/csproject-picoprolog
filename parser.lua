require "analyzer" require "prelude" require "memory"
require "symbol"   require "symbol-table" 


Parser = {}
function Parser.new(symTab,mem) 
    
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
    local mem = Memory.new()
    
    -- Build object (allocates memory)
    local memoryBuilder = Build.new(symTab,mem)
    
    -- Table library
    local _tlib = require "lib/_tlib"
    
    
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
                --print(tType)
            end
            
            mem:printMemory()
            -- TODO must add error logic here...
        end
    end
    
    --[[
        Parse a compound. Rules:
        
        compound ::= ident['('term { ',' term }')']
    --]]
    function self:parseCompound()       
        --print("parseCompound")
        
        -- The arguments of the term
        local args  = {}
        
        -- The number of arguments
        local arity   = 0
               
        -- Whether the token value exists as a symbol
        local exists, symbol = symTab:symbolNameExists(tValue)
        
        local symVal = token:getValue()
        print(symVal)
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
        
        print(symbol:get("name") .. symbol:get("arity"))
        --print("end parseCompound")
        return memoryBuilder:makeCompound(symbol,args)
    
    end
    
    --[[
        Parse a primary. Rules:
        
        primary ::= compound | variable | number | string | char | ‘(’ term ‘)’
    --]]
    function self:parsePrimary()
        --print("parsePrimary")
        local term
        local terms = {
            [TokVal.IDENT]          =   function() term = self:parseCompound() end,
            
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
        return term
    end
    
    
    function self:parseFactor()
       -- print("parseFactor")
        local term
        term = self:parsePrimary()
        print("f=")
        print(term)
        if token:getType() == TokVal.COLON then
            eat(TokVal.COLON)
            term = memoryBuilder:makeNode(eqsym,term,self:parseFactor())
        end        
        --print(term)
        print("end parseFactor")
        return term
    end
    
    --[[
        Parses a term. Rules:
        
        term ::= primary [ ':' term ]
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
        if memoryBuilder:getKind(atom) ~= Term.FUNC then
            error("literal must be compound term")
            
        end
    end  
    
    --[[
        Parses a clause. Rules:
        
        clause ::= [ atom | '#' ] ':-' [ literal { ',' literal } '.' ]
    --]]
    function self:parseClause(isgoal)
        --print("parseClause")
        local head,term
        local minus = false
        local body  = {}
        local num   = 0
        local tType = token:getType()
        
        if isgoal then
            head = nil
        else 
            head = self:parseTerm()
            print("head")
            print(head)
            checkAtom(head)
            eat(TokVal.ARROW)
        end
        
        if tType ~= TokVal.DOT then
            
            while tType ~= TokVal.COMMA do
                num = num + 1
                minus = false
                if tType == TokVal.NEGATE then
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
                if tType ~= TokVal.COMMA then 
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
       
        local tType = token:getType()
        
        repeat     
            nvars = 0            
            --token = lexer:getNextToken()
            
            -- Point heap to heapmark
            mem:setHeapPointer(mem:getHeapMark())
                       
            if tType == TokVal.EOFTOK then
                clause = nil
            else 
                -- interacting var should be passed instead 
                clause = self:parseClause(false) 
            end
        until tType == TokVal.EOFTOK
        return clause
    end
    
  
    
    
    local function varLookup(name)        
        local ref = 1
        if nvars == TunableParameters.MAXARITY then
            error("too many variables")
            os.exit(1)
        end
        
        variable[nvars + 1] = name
        
        while name ~= variables[ref] do 
            ref = ref + 1
        end
        
        if ref == nvars + 1 then 
            nvars = nvars + 1
        end
        
        return memoryBuilder:makeRef(ref)
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
tab = SymbolTable.new()
mem = Memory
p = Parser.new(tab)
p:readClause()