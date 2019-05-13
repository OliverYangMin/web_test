Move = {delta = 0}
Move.__index = Move

function Move:new(delta)
    local self = {delta = delta}
    setmetatable(self, Move)
    return self
end 

function Move:execute()
    
end 

function Move:print(move_type)
    if self.delta<0 then 
        print('The solution has been imporved: ', self.delta, ' by ', move_type)
    else 
        print('The solution be deteriorated temporary: ', self.delta, ' by ', move_type)
    end    
end 
-------------------------------------------------------------------------------------------------------------------------------------------------------
TwoOptMove = Move:new(delta)
TwoOptMove.__index = TwoOptMove
function TwoOptMove:new(delta, pos1, pos2)
    local self = {delta = delta, pos1 = pos1, pos2 = pos2}
    setmetatable(self, TwoOptMove)
    return self
end 

local function reverseLink(pos1, pos2)
    local start = nodes[pos1].suc
    local over = nodes[pos2].suc
    local cur = nodes[pos1].suc
    while true do
        nodes[cur].pre, nodes[cur].suc = nodes[cur].suc, nodes[cur].pre
        cur = nodes[cur].pre
        if cur==pos2 then break end 
    end 
    nodes[pos1].suc = pos2
    nodes[pos2].pre = pos1
    nodes[start].suc = over
    nodes[over].pre = start
end 

function TwoOptMove:execute()
    reverseLink(self.pos1, self.pos2)
    markForward(self.pos1)
    markBackward(self.pos2)
     self:print('2-Opt')
end 
-------------------------------------------------------------------------------------------------------------------------------------------------------
TwoOptStarMove = Move:new()
TwoOptStarMove.__index = TwoOptStarMove

function TwoOptStarMove:new(delta, pos1, pos2)
    local self = {delta = delta, pos1 = pos1, pos2 = pos2}
    setmetatable(self, TwoOptStarMove)
    return self
end 

local function crossRoutes(pos1, pos2)
    local nxt1 = nodes[pos1].route - 1 
    local nxt2 = nodes[pos2].route == - giant:getRouteNum() and -1 or nodes[pos2].route - 1
    local seg1h, seg1d, seg2h,seg2d
    if nodes[pos1].suc < 0 then 
        seg1h, seg1d = 0, 0
    else
        seg1h, seg1d = nodes[pos1].suc, nodes[nxt1].pre
    end 
    if nodes[pos2].suc < 0 then 
        seg2h, seg2d = 0, 0
    else
        seg2h, seg2d = nodes[pos2].suc, nodes[nxt2].pre
    end 
    if seg2h == 0 then 
        nodes[pos1].suc = nxt1
        nodes[nxt1].pre = pos1
    else
        nodes[pos1].suc = seg2h
        nodes[seg2d].suc = nxt1
        nodes[nxt1].pre = seg2d
        nodes[seg2h].pre = pos1
    end 
    if seg1h == 0 then
        nodes[pos2].suc = nxt2
        nodes[nxt2].pre = pos2
    else
        nodes[pos2].suc = seg1h
        nodes[seg1d].suc = nxt2
        nodes[nxt2].pre = seg1d
        nodes[seg1h].pre = pos2
    end 
    markForward(nodes[pos1].suc)
    markBackward(pos1)
    markForward(nodes[pos2].suc)
    markBackward(pos2)
    local node = nodes[pos1].suc
    while node>0 do
        nodes[node].route, nodes[node].vtp = nodes[pos1].route, nodes[pos1].vtp
        node = nodes[node].suc
    end 
    node = nodes[pos2].suc
    while node>0 do
        nodes[node].route, nodes[node].vtp = nodes[pos2].route, nodes[pos2].vtp        
        node = nodes[node].suc
    end 
end 

function TwoOptStarMove:execute()
    crossRoutes(self.pos1, self.pos2)
    self:print('2-Opt*')
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
SwapMove = Move:new()
SwapMove.__index = SwapMove
function SwapMove:new(delta, node1, node2)
    local self = {delta = delta, node1 = node1, node2 = node2}
    setmetatable(self, SwapMove)
    return self
end 

function SwapMove:execute()
    local point1, point2 = nodes[self.node1], nodes[self.node2]
    nodes[point1.pre].suc, nodes[point1.suc].pre = point2.id, point2.id
    nodes[point2.pre].suc, nodes[point2.suc].pre = point1.id, point1.id
    point1.pre, point2.pre = point2.pre, point1.pre
    point1.suc, point2.suc = point2.suc, point1.suc
    markForward(point1.id)
    markBackward(point1.id)
    markForward(point2.id)
    markBackward(point2.id)
    point1.route, point2.route = point2.route, point1.route
    point1.vtp, point2.vtp = point2.vtp, point1.vtp
    self:print('Swap')
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
RelocateMove = Move:new(delta)
RelocateMove.__index = RelocateMove

function RelocateMove:new(delta, node, pos)
    local self = {delta = delta, node = node, pos = pos}
    setmetatable(self, RelocateMove)
    return self
end

local function removePoint(cPoint)
    nodes[cPoint.pre].suc = cPoint.suc
    nodes[cPoint.suc].pre = cPoint.pre
    markForward(cPoint.suc)
    markBackward(cPoint.pre)
end 

local function insertPoint(cPoint, pos)
    cPoint.pre, cPoint.suc = pos, nodes[pos].suc 
    nodes[pos].suc, nodes[nodes[pos].suc].pre = cPoint.id, cPoint.id
    markForward(cPoint.id)
    markBackward(cPoint.id)
    cPoint.route, cPoint.vtp = nodes[cPoint.pre].route, nodes[cPoint.pre].vtp
end 

function RelocateMove:execute()
    removePoint(nodes[self.node])
    insertPoint(nodes[self.node], self.pos)
    self:print('Relocation')
end 