require("constant")
require("prelude")
require("symbol")
require("symbol-table")
require("stringbuilder")

--[[
    Object used to represent a compound term in memory,
--]]
Compound = {}
function Compound.new()
    
    local self = {}
    
    --[[
        The symbol used to represent this compound term.
    --]]
    local symbol = ""
    
    --[[
        Arguments of this compound term.
    --]]
    local arguments = {}
    
    --[[
        Arity of this compound term.
    --]]
    local arity = 0
    
    --[[
        @param sym -symbol for this compound.
    --]]
    function self:setSymbol(sym)    symbol = sym end
    
    --[[
        @param args -arguments of this compound.
    --]]
    function self:setArgs(args)     arguments = args end
    
    --[[
        @param arity -arity of this compound.
    --]]
    function self:setArity(num)     arity = num end
    
    --[[
        @return -the symbol for this compound
    --]]
    function self:getSymbol()   return symbol end
    
    --[[
        @return -the arguments of this compound.
    --]]
    function self:getArgs()     return arguments end
    
    --[[
        @return -the arity of this compound.
    --]]
    function self:getArity()    return arity end
    
    function self:toString()
        print("------------")
        print("Compound:")
        print("Symbol= ")
        print(self:getSymbol())
        print("Arguments= ")
        if self:getArgs() ~= nil then
            for k,v in pairs(self:getArgs()) do
                print(v)
            end        
        else
            print("arguments are nil!")
        end
        print("Arity= ")
        print(self:getArity())
        print("------------")
    end
    
    return self    
end

-------------------------------------------------------------------------------

--[[
    Object used to represent a clause in memory.
--]]
Clause = {}
function Clause.new()
    
    local self = {}
    
    -- Number of variables
    local nvars = 0
    
    -- Term
    local head
    
    -- Arguments
    local body
    
    -- Number of arguments
    local nbody = 0
    
    -- Clause key
    local key
    
    --[[
        Sets the number of variables in this clause.
        @param num -the number of variables
    --]]
    function self:setNumVars(num)   nvars = num end
    
    --[[
        Sets the head of this clause.
        @param term -the head of this clause
    --]]
    function self:setHead(term)     head = term end
    
    --[[
        Sets the body of this clause.
        @param args -the body of this clause
    --]]
    function self:setBody(args)     body = args end
    
    --[[
        TODO can get this dynamically using #body....
        Sets the number of arguments in the body of 
        this clause.
        @param num -the number of arguments in the 
                    body of this clause.
    --]]
    function self:setNumBody(num)   nbody = num end
    
    --[[
        @param ckey -the clause unification key
    --]]
    function self:setKey(ckey)  key = ckey end
    
    --[[
        @return the number of variables in this clause
    --]]
    function self:getNumVars()  return nvars end
    
    --[[
        @return the head of this clause
    --]]
    function self:getHead()     return head end
    
    --[[
        @return the body of this clause
    --]]
    function self:getBody()     return body end
    
    --[[
        @return the number of arguments in the body 
                of this clause
    --]]
    function self:getNumBody()  return nbody end
    
    --[[
        TODO remove
    --]]
    function self:getType() return "clause" end
    
    --[[
        String representation of this clause.
    --]]
    function self:toString()
        print("------------")
        print("Clause:")
        print(self:getNumVars())
        print(self:getHead())
        print(self:getBody())
        print(self:getNumBody())
        print("------------")
    end
    
    return self
end


-------------------------------------------------------------------------------

--[[
    As a clause is read, this object will hold the variable names contained
    in the clause and their location on the heap.
--]]
VarTable = {}
function VarTable.new(memory)
    
    local self = {}
    
    --[[
        Table containing the variable names.
    --]]
    local variables = {}
    
    --[[
        Number of variables in table.
    --]]
    local nvars = 0
    
    --[[
        TODO finish this
    --]]
    function self:insert(var)
        if nvars = TunableParameters.MAXARITY then
            error("too many variables!")
            os.exit(1)
        end
        
        --[[
            Allocate space on the heap for this variable,
            let its value be its name for now.
        --]]
        if self:exists(var)then 
            variables[var] = memory:heapAlloc(var)
            nvars = nvars + 1
        end
        return variables[var]
    end
    
    --[[
        @param var -the variable name we are looking for.
        @return - true if the variable exists
    --]]
    function self:exists(var)        
        local exists = false
        
        if variables[var] ~=nil then
            exists = true
        end
        
        return exists
    end
    
    --[[
        @return -the number of variables
    --]]
    function self:getNumVars()
        return nvars
    end
end
-------------------------------------------------------------------------------

--[[
    Nodes are used to populate the memory table.
    Every entry in the table is a node that stores the
    type of the entry and its value.
--]]
Node= {}

--[[
    Constructs a new node of type t and value v.
--]]
function Node.new(t,v)
    
    local self = {}
    
    -- Type of the node.
    local nodeType = t
    
    -- Value of the node
    local nodeValue = v
    
    --[[
        Sets the type of the node.
    --]]
    function self:setType(t)    nodeType = t end
    
    --[[
        Sets the value of the node.
    --]]
    function self:setValue(v)   nodeValue = v end
    
    --[[ 
        Returns the type of the node.
    --]]
    function self:getType()     return nodeType  end
    
    --[[
        Returns the value of the node.
    --]]
    function self:getValue()    return nodeValue end
    
    --[[
        TODO add print info for REF, CELL and UNDO.
        Prints information about this node, and the value it contains.
    --]]
    function self:printNode()
        local types = {
            [Term.FUNC] =   function()
                                local val = self:getValue()
                                print(Term.FUNC)
                                print(val:toString())
                            end,
            [Term.INT]  =   function()
                                print(Term.INT)
                                print(self:getValue())
                            end,
            [Term.CHRCTR]=  function()
                                print(Term.CHRCTR)
                                print(self:getValue())
                            end,
            [Term.STRING]=  function()
                                print(Term.STRING)
                                print(self:getValue())
                            end
        }
        
        types[self:getType()]()
    end
    
    return self
end

-------------------------------------------------------------------------------

--[[
    Used for organising memory. Stores the heap, 
    local and global stack in a table.
--]]
Memory = {}

--[[
    Constructs a memory object.
--]]
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
    local heapmark = 1
    
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


-------------------------------------------------------------------------------

--[[
    Class used for building the programs representation
    in memory.
--]]
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
        local node = Node.new(Term.FUNC,obj)
        local index = memory:heapAlloc(node)
        node:printNode()
        return index
    end
    
    --[[
        Stores an int on the heap
        @param num -the value to stored
        @return -the index of the value on the heap
    --]]
    function self:makeInt(num)    
        local node = Node.new(Term.INT,num)
        local index = memory:heapAlloc(node)
        return index
    end
    
    --[[
        Stores a character on the heap
        @param char -the character to store on the heap
        @return -the index of the value on the heap
    --]]
    function self:makeChar(char)
        local node = Node.new(Term.CHRCTR,char)
        local index = memory:heapAlloc(node)
        return index
    end
    
    --[[
        TODO fix this...
        Constructs a string as a Prolog list of chars, 
        and stores it on the heap.
        @param string -the value of the string
        @return -index of the value on the heap
    --]]
    function self:makeString(string)
        local pstr = buildString(string)
        local node = Node.new(Term.STRING,pstr)
        local index = memory:heapAlloc(node)        
        return index
    end
    
    --[[
        TODO fix this...
        Construct a reference cell.
        @param ref  -pointer to variable
        @return         -
    --]]
    function self:makeRef(ref)
        local index = 1
        refnode[numVars + 1] = ref
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
        print("creating clause")
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
        print(loc)
        local node = memory:get(loc)         
        return node:getType()
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