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

function RandomRemoval:execute(size)
    local pool = combination(size, #nodes)
    for _,node in ipairs(pool) do
        removePoint(nodes[node])
    end
    return pool
end

function WorstRemoval:execute(size)
    local pool = {}
    for i=1,#nodes do
        pool[#pool+1] = {i, cost = cDelta:removeNodeCost(i)}
    end 
    table.sort(pool, function(a,b) return a.cost < a.cost end)
    local result = {}
    for i=1,#size do
        result[i] = pool[i][1]
    end 
    return result
end 

function greedyInsertion(cPool)
    for i=1,#cPool do
        repeat 
    end 
end 




