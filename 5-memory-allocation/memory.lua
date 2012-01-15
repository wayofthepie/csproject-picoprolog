package.path = package.path .. ";../0-prelude/?.lua;../lib/constant.lua"
require("constant")
require("prelude")

Memory = {}

function Memory.new() 
    local self = {}
    
    --[[
        Storage for heap, local stack (grows up) and global stack (grows down).
        The total size of this table is TunableParameters.MEMSIZE.
    --]]
    local memory = {}                                                  --
    
    local localsp= 0
    local globalsp = TunableParameters.MEMSIZE
    local heapp
    local heapmark
    
    --[[
        Allocate space on the local stack.
        @param size
        @return
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
        @return
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
    --]]
    function heapAlloc(size)
        if heapp + size > MEMSIZE then
            -- TODO should kill interpreter
            error("Out of heap space!")
        end      
        temp = heapp + 1
        heapp = heapp + size        
        return temp
    end
    
    function self:printMemory()
        for k,v in pairs(memory) do
            
            print(k,v)
        end
    end
      
    return self
end

m = Memory.new()
m:gloAlloc("FUNC", 34)
m:printMemory()