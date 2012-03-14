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
    c = p:readClause()

    --mem:printMemory()

   --[[ if c ~= nil then
        print("Clause location " .. c)
        body = mem:get(c):getBody()
        for k,v in pairs(body) do
            print("Clause body ")
            t = mem:get(v)
            
            for i,j in pairs(body) do
                print("key = " .. i .." val = ".. j)
            end
        end
    else 
        print("Done.")
    end--]]
until c == nil