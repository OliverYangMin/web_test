--class name: GiantTour
--information: solution routes data structure named giant tour
--date：2019-04-28
--author: YangMin
GiantTour = {}
GiantTour.__index = GiantTour

function GiantTour:new()
    local self = {}
    setmetatable(self, GiantTour)
    return self
end 

--------------------two_opt-----------------------------------------
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

local function reverseRoute(pos1, pos2)
    reverseLink(pos1, pos2)
    markForward(pos1)
    markBackward(pos2)
end 
--------------------two_opt-----------------------------------------
--------------------two_opt_star------------------------------------
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
--------------------two_opt_star------------------------------------
--------------------node_relocate-----------------------------------
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

local function remove_insertPoint(cPoint, pos)
    removePoint(cPoint)
    insertPoint(cPoint, pos)
end
------------------node_relocate--------------------------------
------------------node_swap------------------------------------
local function swapPoints(cPoint1, cPoint2)
    nodes[cPoint1.pre].suc, nodes[cPoint1.suc].pre = cPoint2.id, cPoint2.id
    nodes[cPoint2.pre].suc, nodes[cPoint2.suc].pre = cPoint1.id, cPoint1.id
    cPoint1.pre, cPoint2.pre = cPoint2.pre, cPoint1.pre
    cPoint1.suc, cPoint2.suc = cPoint2.suc, cPoint1.suc
    markForward(cPoint1.id)
    markBackward(cPoint1.id)
    markForward(cPoint2.id)
    markBackward(cPoint2.id)
    cPoint1.route, cPoint2.route = cPoint2.route, cPoint1.route
    cPoint1.vtp, cPoint2.vtp = cPoint2.vtp, cPoint1.vtp
end 
------------------node_swap------------------------------------
function GiantTour:executeMove(cMove)
    --cMove = {mtp=1,2,3,4,  p={}, k=1, delta}
    if cMove.mtp==0 then
        local pos1, pos2 = cMove.p[1], cMove.p[2]
        if nodes[pos1].route==nodes[pos2].route then --2-opt
            reverseRoute(pos1, pos2)
        else --2-opt-star
            crossRoutes(pos1, pos2)
        end
    elseif cMove.mtp==1 then --relocate
        remove_insertPoint(nodes[cMove.p[1]], cMove.p[2])
    elseif cMove.mtp==2 then --swap
        swapPoints(nodes[cMove.p[1]], nodes[cMove.p[2]])
    end 

    --if CONSOLEDISPLAY then
        if cMove.delta<0 then 
            print('The solution has been imporved: ', cMove.delta)
        else 
            print('The solution be deteriorated temporary: ', cMove.delta)
        end     
    --end
end 

function GiantTour:isFeasible()
    local node = -1
    local t = 0
    repeat 
        t = t + nodes[node].stime + time(node, nodes[node].suc)
        if t > nodes[nodes[node].suc].time2 then print(node,nodes[node].suc) return false end 
        t = math.max(nodes[nodes[node].suc].time1, t)
        if nodes[node].suc<0 then t = 0 end 
        node = nodes[node].suc
    until node == -1
    return true
end 

function GiantTour:convert2Routes()
    local function getRoute(index)
        local route = {}
        repeat 
            table.insert(route, nodes[index].id==0 and nodes[index].route or nodes[index].id)
            index = nodes[index].suc 
        until index<0
        return route
    end 
    
    local routes = {cost=self:getCost()}
    local i = -1 
    while nodes[i] do
        table.insert(routes, getRoute(i))
        i = i - 1 
    end 
    return routes 
end 

function GiantTour:getCost()
    local cPoint, distance, cost = nodes[-1], 0, 0 
    ---reverse order
    repeat --cPoint.pre ~= -1 do
        distance = distance + dis(cPoint.pre, cPoint.id)
        cost = cost + dis(cPoint.pre, cPoint.id) * vehicle[cPoint.vtp].tc + math.max(0, cPoint.time1 - cPoint.bT) * vehicle[cPoint.vtp].wc
        if cPoint.pre < 0 and cPoint.id > 0 then cost = cost + vehicle[cPoint.vtp].fc end 
        cPoint = nodes[cPoint.pre]
    until nodes[cPoint.pre].suc == -1 
    return cost, distance
end 

function GiantTour:getRouteNum()
    local i = -1 
    while nodes[i] do
        i = i - 1
    end 
    return -(i + 1)
end 

function GiantTour:plot()
     if not Nodes then 
        Nodes = CreateShapes('nodes [Points]','point') 
        AddField(Nodes, 'id', 'int')
        AddField(Nodes, 'ptype', 'int') -- dont do that:the color of attributes put at first place
        AddField(Nodes, 'weight', 'float')
        AddField(Nodes, 'volume', 'float')
        AddField(Nodes, 'route', 'int')
        for i=0,#nodes do
            local shp = AddShape(Nodes, nodes[i].x, nodes[i].y) 
            if i==1 then 
                SetValue(shp, 1, 'ptype')
            else
                SetValue(shp, 2, 'ptype')
            end 
            SetValue(shp, i, 'id')
            SetValue(shp, nodes[i].weight, 'weight')
            SetValue(shp, nodes[i].weight, 'volume')
        end
        Update(Nodes)
        SetParameter(Nodes, "COLORS_TYPE", 3)
        SetParameter(Nodes, "LABEL_ATTRIB", 1)
    end 
    
    local Routes = CreateShapes('Solution [Lines]','line')
    AddField(Routes, 'id', 'int')
    AddField(Routes, 'route_id', 'int')  --  dont do that: the color of attributes put at first place
    local index, cPoint = 1, nodes[-1]
    repeat 
        if cPoint.suc>0 then 
            local shp = AddShape(Routes, cPoint.x, cPoint.y, nodes[cPoint.suc].x,nodes[cPoint.suc].y)
            SetValue(shp, index, 'id')
            SetValue(shp, -cPoint.route, 'route_id')
            index = index + 1
        end 
        cPoint = nodes[cPoint.suc]
    until (cPoint.id==0 and cPoint.route==-1)
    SetParameter(Routes, "COLORS_TYPE", 3)
    Update(Nodes)
    Update(Routes)
    CreateView('vrp result cost: ' .. self:getCost(), Nodes, Routes)
end 