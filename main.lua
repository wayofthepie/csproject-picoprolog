require "analyzer" require "prelude" require "memory"
require "symbol"   require "symbol-table" 
require "compound" require "parser"

tab = SymbolTable.new()
mem = Memory.new()
p = Parser.new(tab, mem)
p:readClause()
mem:printMemory()