package.path = package.path .. ";../0-prelude/?.lua;../lib/constant.lua;../9-symbol-table/?.lua"
require("constant")
require("prelude")
require("symbol")
require("symbol-table")

--[[
    
--]]
local Memory = {}
function Memory.new() 
    local self = {}
    
    --[[
        Storage for heap, local stack (grows up) and global stack (grows down).
        The total size of this table is TunableParameters.MEMSIZE.
    --]]
    local memory = {}                                                  --
    
    --[[
        Pointer to the local stack pointer, Grows upwards in memory,
        stored above the heap.
    --]]
    local localsp= 0
    
    --[[
        Pointer to global stack. Grows downwards in memory, size can 
        be set in prelude.lua.
    --]]
    local globalsp = TunableParameters.MEMSIZE
    
    --[[
        Pointer to the heap. Starts at 0 location in memory, and grows to 
    --]]
    local heapp = 0
    
    --[[
        Indicates the beginning of a clause. This is needed as program
        clauses become a permanent part of the heap, but goal clauses 
        can be discarded
     --]]        
    local heapmark
    
    
    ------------ Public Functions ------------                                 
    --[[
        Allocate space on the local stack.
        @param size
        @return -a pointer to the allocated memory on the local stack
    --]]
    function self:locAlloc(size)
        local temp
        if localsp + size >= globalsp then 
            -- TODO This should also kill interpreter.
            error("Out of Stack space!!") 
        end
        temp = localsp + 1
        localsp = localsp + size
        return temp        
    end
    
    --[[
        Allocate space on the global stack.
        @param kind
        @param size
        @return -a pointer to the allocated memory on the global stack
    --]]
    function self:gloAlloc(kind, size)
        local pointer
        if globalsp - size <= localsp then
            -- TODO This should also kill interpreter.
            error("Out of Stack space!!")
        end
        globalsp = globalsp - size
        memory[globalsp] = kind            
        return globalsp
    end
    
    --[[
        Allocate memory on the heap.
        @param size
        @return -pointer to the allocated space on the heap
    --]]
    function self:heapAlloc(size)
        if heapp + size > TunableParameters.MEMSIZE then
            -- TODO should kill interpreter
            error("Out of heap space!")
        end      
        temp = heapp + 1
        heapp = heapp + size        
        return temp
    end
    
    function self:get()
        return memory
    end
    --[[
        Prints all locations of memory.        
    --]]
    function self:printMemory()
        for k,v in pairs(memory) do            
            print(k,v)
        end
    end
    ------------ End Public Functions ------------
    
    return self
end

local Term = {
    FUNC = 1,
    INT = 2,
    CHRCTR = 3,
    CELL = 4,
    REF = 5,
    UNDO = 6,
    TERM_SIZE = 3,
    CLAUSE_SIZE = 4
}

local BuildTerms = {}
function BuildTerms.new()
    
    local self = {}
    
    local mem = Memory.new()
    
    --[[
        @param termpointer -pointer to mem
        @param offset - 
        @param tType - type of term
    --]]
    function makeTag(termpointer, offset, tType)
        mem:get()[termpointer] = 256 * (offset + tType)
    end
    
    function buildFunc(termpointer, func)
        mem:get()[termpointer + 2] = func 
    end
    
    function buildInt(termpointer,num)
        mem:get()[termpointer + 2] = num
    end
 
        
    --[[
        Constructs a compound term on the heap.
        @param func 
        @param args        @return -pointer to the compound term
    --]]
    function self:makeCompound(func, args)
        local termpointer
        local arity, index = 0       
        local termAndArity = 0
        local refnode = {}
        
        arity = func:get(SymbolFields.ARITY)        
        termAndArity = Term.TERM_SIZE + arity
        termpointer = mem:heapAlloc(termAndArity)
    
        makeTag(termpointer, termAndArity, Term.FUNC)
        buildFunc(termpointer,func)
               
        return termpointer
    end
    
    --[[
        Construct a compound term of up to two arguments.
        @param func
        @param arg1
        @param arg2
        @return
    --]]
    function self:makeNode(func, arg1, arg2)
        args = { arg1, arg2 }
        return self:makeCompund(func, args)        
    end
    
    --[[
        Construct a reference cell prepared earlier.
        
    --]]
    function self:makeRef(offset)
        return refnode[offset]
    end
    
    --[[
        Construct an integer node on the heap.
    --]]
    function self:makeInt(integer)
        local termpointer 
        
        termpointer = mem:heapAlloc(Term.TERM_SIZE)
        
        makeTag(termpointer,Term.TERM_SIZE, Term.INT)
        buildInt(termpointer,integer)        
        return termpointer
    end
    
    --[[
        Constructs a character node on the heap
    --]]
    function self:makeChar()
        local termpointer
        
        termpointer = mem:heapAlloc(Term.TERM_SIZE)        
        
    end
    
    return self
end

f = Symbol.new("FUNC", 5, 0, nil)

bt = BuildTerms.new()
local i =bt:makeCompound(f,5)



