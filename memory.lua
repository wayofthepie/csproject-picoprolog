require("constant")
require("prelude")
require("symbol")
require("symbol-table")
require("stringbuilder")
require("clause")

Memory = {}
function Memory.new()
    local self = {}
    
    --[[
        Storage for heap, local stack (grows up) and global stack (grows down).
        The total size of this table is TunableParameters.MEMSIZE.
    --]]
    local memory = {}                                                  --
    
    --[[
        Pointer to the local stack pointer, Grows upwards in memory,
        stored above the heap. This wil begin a the vaue of the heap 
        pointer heapp.
    --]]
    local localsp= 1
    
    --[[
        Pointer to global stack. Grows downwards in memory, size can 
        be set in prelude.lua.
    --]]
    local globalsp = TunableParameters.MEMSIZE
    
    --[[
        Pointer to the heap. Starts at 0 location in memory, and grows to 
    --]]
    local heapp = 1
    
    --[[
        Indicates the beginning of a clause. This is needed as program
        clauses become a permanent part of the heap, but goal clauses 
        can be discarded
     --]]        
    local heapmark = 0
    
    --Public Functions
    --[[
        Stores bject "obj" in the local stack.
        @param obj -the object to store
        @return -index of the object on the stack
    --]]
    function self:locAlloc(obj)
        local temp
        
        if localsp + 1 >= globalsp then 
            -- TODO This should also kill interpreter.
            error("Out of Stack space!!") 
        else 
            memory[localsp] = obj
            localsp = localsp + 1
        end
        return localsp - 1       
    end
    
     --[[
        Allocate space on the global stack.
        @param obj 
        @return -index of the object on the global stack
    --]]
    function self:gloAlloc(obj)
        local pointer
        if globalsp - 1 <= localsp then
            -- TODO This should also kill interpreter.
            error("Out of Stack space!!")
        else
            memory[globalsp] = obj
            globalsp = globalsp + 1
        end
        return globalsp - 1
    end
    
    --[[
        Allocate memory on the heap.
        @param obj
        @return -index of the object in the heap
    --]]
    function self:heapAlloc(obj)
        print("loc= " .. heapp)
        if heapp + 1 > TunableParameters.MEMSIZE then
            -- TODO should kill interpreter
            error("Out of heap space!")
        else
            memory[heapp] = obj
            heapp = heapp + 1
        end      
        
        return heapp - 1
    end
    
    --[[
        Returns the value of memory at index.
    --]]
    function self:get(index)
        return memory[index]
    end
    
    --[[
        Prints all locations of memory.        
    --]]
    function self:printMemory()
        for k,v in pairs(memory) do                        
            for x,y in pairs(v) do
                print(x,y)
                
            end
        end
    end
    
    return self  
end


Build = {}
function Build.new(symtab, memory)
    
    local self = {}
       
    local vartable = {}
    
    -- Stores variable REF nodes
    local refnode = {} -- references to variables
    
    -- Number of nodes in refnode table
    local numVars = 0
    
    --[[
        Stores a compound on the heap
        @param obj -the compound term to store on the heap
        @return -the index of the term on the heap
    --]]
    function self:makeCompound(obj)
        local index = memory:heapAlloc(obj)
        return index
    end
    
    --[[
        Stores an int on the heap
        @param num -the value to stored
        @return -the index of the value on the heap
    --]]
    function self:makeInt(num)
        local index = memory:heapAlloc(num)
        return index
    end
    
    --[[
        Stores a character on the heap
        @param char -the character to store on the heap
        @return -the index of the value on the heap
    --]]
    function self:makeChar(char)
        local index = memory:heapAlloc(char)
        return index
    end
    
    --[[
        Constructs a string as a Prolog list of chars, 
        and stores it on the heap.
        @param string -the value of the string
        @return -index of the value on the heap
    --]]
    function self:makeString(string)
        local pstr = buildString()
        local index = memory:heapAlloc(pstr)        
        return index
    end
    
    --[[
        TODO fix this...
        Construct a reference cell.
        @param varName  -value of the cell
        @return         -
    --]]
    function self:makeRef(varName)
        local index = 1
        refnode[numVars + 1] = varName
        numVars = numVars + 1
        return numVars
    end
    
    --[[
        Constructs a clause and stores it on the heap
        @param nvars    -number of variables in the clause
        @param head
        @param body
        @param nbody
    --]]
    function self:makeClause(nvars,head,body,nbody)
        local index
        local clause = Clause.new()
        clause:setNumVars(nvars)
        clause:setHead(head)
        clause:setBody(body)
        clause:setNumBody(nbody)
        index = memory:heapAlloc(clause)
        return index
    end
    
    --[[
        Returns the type of the literal at the location
        loc.
    --]]
    function self:getType(loc)        
        return memory:get(loc)
    end
    
    return self
end

--[[
local mem = Memory.new()
    
local symTab = SymbolTable.new()

f = Symbol.new("FUNC", 5, 0, nil)

b = Build.new(symTab,mem)
local i     = b:makeCompound(f,5)
local test  = b:makeString("test")
b:makeClause(2,"e2",{t,t},0)
b:makeClause(5,"e22",{t,t},4)
b:makeClause(2,"e2",{t,t},0)
b:makeClause(5,"e22",{t,t},4)
mem:printMemory() --]]