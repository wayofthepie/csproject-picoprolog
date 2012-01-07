Memory = {}

function Memory.new() 
    local self {}
    
    local localsp,globalsp,heapp,hmark
    
    --[[
        Allocate space on the local stack.
        @param Integer - size
        @return - localsp + the size allocated
    --]]
    function locAlloc(size)
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
        @param Integer - kind
        @param Integer - size
        @return
    --]]
    function gloAlloc(kind, size)
        local pointer
        if globalsp - size < localsp then
            -- TODO This should also kill interpreter.
            error("Out of Stack space!!")
        end
        globalsp = globalsp - size
        pointer = globalsp
        -- TODO finish function: C.4
    end
    
end