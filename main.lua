require "analyzer" require "prelude" require "memory"
require "symbol"   require "symbol-table" 
require "parser"

-- Symbol table
symTab = SymbolTable.new()

-- Memory object
mem = Memory.new()

-- Build object
memBuilder = Build.new(symTab, mem)

-- VarTable object
varTable = VarTable.new(memBuilder)

-- Parser object
p = Parser.new(memBuilder, varTable)

-- Main loop, reads clauses one by one 
repeat 
    
    -- Whether to read next clause
    local answer
    
    -- Current clause
    local clause
    
    -- Body of current clause
    local body
    
    -- Tables next function bound locally
    local next = next
    
    -- Pointer to node containing clause
    local c = p:readClause(false)
    
    if c ~= nil then
        print("Clause location " .. c)
        
        --[[
            mem:get(c) returns the node containing the clause.
        --]]
        clause = mem:get(c):getValue()
        body = clause:getBody() 
        
        if next(body) ~= nil then
            print("Clause body ")            
            for k,v in pairs(body) do
                print("key = " .. k .." val = ".. v)            
            end
        end
        
        -- read clauses one by one
        repeat
            io.write("read next clause (y/n)? ")
            io.flush()
            answer=io.read()
            
            if answer == "n" then 
                break
            end
                
        until answer == "y" or answer == "n"
    else 
        print("Done.")
    end
    
    if answer == "n" then 
        break
    end
   
until c == nil 