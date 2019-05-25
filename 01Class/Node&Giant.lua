Node = {}
Node.__index = Node

function Node:new(id, x, y, weight, time1, time2, stime, volume)
    local self = {id = id, x = x, y = y, weight = weight, volume = volume or 0, time1 = time1, time2 = time2, stime = stime}
    setmetatable(self, Node)
    return self
end 

Giant = {}
Giant.__index = Giant

function Giant:new()
    local self = {}
    setmetatable(self, Giant)
    return self
end

function Giant:getCost()
    local cPoint, distance, cost = nodes[-1], 0, 0 
    repeat 
        distance = distance + dis(cPoint.pre, cPoint.id)
        cost = cost + dis(cPoint.pre, cPoint.id) * vehicle[self[cPoint.pre].vtp].tc + math.max(0, cPoint.time2 - cPoint.bT) * vehicle[self[cPoint.pre].vtp].wc
        if cPoint.pre < 0 and cPoint.id > 0 then cost = cost + vehicle[self[cPoint.pre].vtp].fc end 
        cPoint = self[cPoint.pre]
    until self[cPoint.pre].suc == -1 
    return cost, distance
end 

function Giant:penaltyCost()
    local alpha = {1,1,1,1}
    local cPoint, cost = nodes[-1], 0, 0 
    local W, V, T = 0, 0, 0
    repeat 
        cost = cost + dis(cPoint.pre, cPoint.id) * vehicle[self[cPoint.pre].vtp].tc + math.max(0, cPoint.time2 - cPoint.bT) * vehicle[self[cPoint.pre].vtp].wc
        if cPoint.pre < 0 and cPoint.id > 0 then 
            cost = cost + vehicle[cPoint.vtp].fc 
            W = W + math.max(0, cPoint.fW - vehicle[cPoint.vtp].weight)
            V = V + math.max(0, cPoint.fV - vehicle[cPoint.vtp].volume)
        end 
        cPoint = self[cPoint.pre]
    until self[cPoint.pre].suc == -1 
    
    
    
    
    return cost




end 









function Giant:to_solution()
    local function getRoute(index)
        local route = Route:new()
        index = self[index].suc 
        while index > 0 do
            route:append(self[index])
            index = self[index].suc 
        end 
        if route[1] then return route end 
    end 
    local cost = self:getCost()
    local solu = Solution:new(cost)
    local i = -1 
    while self[i] do
        solu:appendRoute(getRoute(i))
        i = i - 1 
    end 
    return solu
end 

function Giant:getRouteNum()
    local i = -1 
    while self[i] do
        i = i - 1
    end 
    return -(i + 1)
end 

function Giant:markForward(node)   --从node开始，包括node，向后更新 f labels 直到碰到终点depot
    while node > 0 do 
        self[node].fT = push_forward(self[self[node].pre], node)
        self[node].fW = self[self[node].pre].fW + self[node].weight
        self[node].fV = self[self[node].pre].fV + self[node].volume
        node = nodes[node].suc
    end 
end 

function Giant:markBackward(node)   --从node开始，包括node，向前更新 b labels， 直到碰到 起点depot
    while node > 0 do
        local point = self[node].suc > 0 and self[self[node].suc] or {id = 0, bT = self[0].time2, bW=0, bV=0}   --如果保证，depot点的label 都是0，则可以删去此地方
        self[node].bT = push_backward(point, node)
        self[node].bW = point.bW + self[node].weight
        self[node].bV = point.bV + self[node].volume
        node = self[node].pre
    end 
end 