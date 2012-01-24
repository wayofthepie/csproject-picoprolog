require("constant")
require("prelude")
require("symbol")
require("symbol-table")

--[[
    
--]]
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
    local heapmark = 0
    
    
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
    
    function self:setHeapMark(pointer)
        heapmark = pointer
    end
    
    function self:getHeapMark()
        return heapmark
    end
    
    function self:setHeapPointer(pointer)
        heapp = pointer
    end
    
    function self:getHeapPointer()
        return heapp
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



Build = {}
function Build.new(symTab,mem)
    
    local self = {}
    
    
    
    local TERM_SIZE     = 3
    
    local CLAUSE_SIZE   = 4
    
    ---------- Helper Functions for Terms ----------
    --[[
        @param termpointer -pointer to mem
        @param offset - 
        @param tType - type of term
    --]]
    local function makeTag(termpointer, offset, tType)
        mem:get()[termpointer] = 256 * (offset + tType)
    end
    
    local function build(termpointer, term) mem:get()[termpointer + 2] = term end
    
    local function buildFunc(termpointer, func) build(termpointer,func) end
    
    local function buildInt(termpointer,num) build(termpointer,num) end
    
    local function buildChar(termpointer,char) build(termpointer,char) end
        
    ------------------------------------------------ 
           
    --[[
        Constructs a compound term on the heap.
        @param func 
        @param args        
        @return -pointer to the compound term
    --]]
    function self:makeCompound(func, args)
        local termpointer
        local arity, index = 0       
        local termAndArity = 0
        local refnode = {}
        
        arity = func:get(SymbolFields.ARITY)        
        termAndArity = TERM_SIZE + arity
        termpointer = mem:heapAlloc(termAndArity)
    
        makeTag(termpointer, termAndArity, Term.FUNC)
        buildFunc(termpointer,func)
        print("tab= " .. mem:get()[termpointer])
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
        return self:makeCompound(func, args)        
    end
    
    --[[
        Construct a reference cell prepared earlier.0
        
    --]]
    function self:makeRef(offset)
        return refnode[offset]
    end
    
    --[[
        Construct an integer node on the heap.
    --]]
    function self:makeInt(integer)
        local termpointer 
        
        termpointer = mem:heapAlloc(TERM_SIZE)
        
        makeTag(termpointer,TERM_SIZE, Term.INT)
        buildInt(termpointer,integer)        
        return termpointer
    end
    
    --[[
        Constructs a character node on the heap.
    --]]
    function self:makeChar(char)
        local termpointer
        
        termpointer = mem:heapAlloc(TERM_SIZE)        
        makeTag(termpointer,TERM_SIZE,Term.CHRCTR)        
        buildChar(termpointer,char)
        return termpointer
    end
    
    --[[
        Constructs a string as a Prolog list of chars.
    --]]
    function self:makeString(string)
        local termpointer
               
        termpointer = self:makeNode(symTab:getNilSym(),nil,nil)                
        for char in string:gmatch"." do
            termpointer = self:makeNode(symTab:getConsSym(),self:makeChar(char),termpointer)
        end            
        return termpointer
    end
    
    ---------- Helper Functions for Clauses ----------
    local function setNumVars(pointer,nvars)
        mem[pointer] = nvars
    end
    
    --[[
        Unification key.
    --]]
    local function setClauseKey(pointer,val)
        mem[pointer + 1] = val
    end
    
    local function setNextClause(pointer,nextClause)
        mem[pointer + 2] = nextClause
    end
    
    local function setClauseHead(pointer,head)
        mem[pointer + 3] = head
    end
    
    local function startOfClauseBody(pointer)
        return pointer + 4
    end
    
    local function clauseBody(pointer,num,arg)
        mem[startOfClauseBody(pointer) + num - 1] = arg
    end        
    --------------------------------------------------
    
    --[[
        Constructs a clause on the heap
    --]]
    function self:makeClause(nvars,head,body,nbody)
        local num = 1
        
        termpointer = mem:heapAlloc(CLAUSE_SIZE + nbody + 1)
        setNumVars(termpointer,nvars)
        setNextClause(termpointer,nil)
        
        for k,v in pairs(body) do
            clauseBody(termpointer,num,v)
            num = num + 1
        end
        
        clauseBody(termpointer,nbody + 1, nil)
        --[[
        if head = nil then 
            setClauseKey(termpointer,0)
        else
            setClauseKey(termpointer, --]]
        return termpointer
            
    end
    
    function self:getKind(pointer)
        print(mem:get(pointer))
        return mem:get(pointer)
    end
    
    function self:printMem()
        mem:printMemory()
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