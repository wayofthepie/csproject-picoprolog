require "analyzer" require "prelude" require "memory"
require "symbol"   require "symbol-table" 
require "parser"


tab = SymbolTable.new()
mem = Memory.new()
p = Parser.new(tab, mem)
repeat 
    c = p:readClause()

    --mem:printMemory()

    if c ~= nil then
        print(c)
        body = mem:get(c):getBody()
        for k,v in pairs(body) do
            print(mem:get(v))
        end
    else 
        print("Done.")
    end
until c == nil