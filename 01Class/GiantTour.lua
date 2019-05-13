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
    repeat 
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