Destory = {}
Destory.__index = Destory

function Destory:new()
    local self = {}
    setmetatable(self, Destory)
    return self
end 

RandomRemoval = Destory:new()
RandomRemoval.__index = RandomRemoval

function RandomRemoval:new()
    local self = {}
    setmetatable(self, RandomRemoval)
    return self
end 
local function removePoint(cPoint)
    nodes[cPoint.pre].suc = cPoint.suc
    nodes[cPoint.suc].pre = cPoint.pre
    nodes:markForward(cPoint.suc)
    nodes:markBackward(cPoint.pre)
end 

function ShawRemoval:execute(size)
    --relatedness measue    remove requests that are somewhat similar
    -- distance term, time term, capacity term and a term that considers the vehicles that can be used to serve the two requests
    local left = {}
    for i=1,#nodes do
        left[#left+1] = {i}
    end 
    local pool = {math.random(#nodes)}
    table.remove(left, pool[1])
    while #pool < size do
        local r = pool[math.random(#pool)]
        for _,node in ipairs(left) do
            node.relatedness = Relatedness(r, node[1])
        end 
        table.sort(left, function(a,b) return a.relatedness < a.relatedness end)
        local y = math.ceil(math.random() ^ 5 * #left)
        pool[#pool+1] = left[y]
        table.remove(left, y)
    end 
    
    for i=1,#pool do
        removePoint(nodes[pool[i]])
    end 
    return pool
end 












function RandomRemoval:execute(size)
    local pool = combination(size, #nodes)
    for _,node in ipairs(pool) do
        removePoint(nodes[node])
    end
    return pool
end

function WorstRemoval:execute(size)
    local left = {}
    for i=1,#nodes do
        left[#left+1] = {i, cost = cDelta:removeNodeCost(i)}
    end 
    table.sort(left, function(a,b) return a.cost < a.cost end)
    
    local pool = {}
    while #pool < size do
        local y = math.ceil(math.random() ^ 5 * #left)
        pool[#pool+1] = left[y]
        table.remove(left, y)
    end
    return pool
end 

function greedyInsertion(cPool)
    for i=1,#cPool do
        repeat 
    end 
end 

function RegretInsertion(cPool)
    
end 



