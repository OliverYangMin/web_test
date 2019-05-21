--class name: Route
--information: a kind of solution routes data structure for constructive algorithms
--date：2019-04-17
--author: YangMin
Node = {}
Node.__index = Node

function Node:new(id, x, y, weight, time1, time2, stime, volume)
    local self = {id = id, x = x, y = y, weight = weight, volume = volume or 0, time1 = time1, time2 = time2, stime = stime}
    setmetatable(self, Node)
    return self
end 





Route = {vtp = 1}
Route.__index = Route

function Route:new(vtp)
    local self = {}
    setmetatable(self, Route)
    self.vtp = vtp or 1
    self[0] = {id=0, fT = nodes[0].time1, bT=nodes[0].time2, fW = 0, fV = 0, bW=0, bV=0} 
    --point = {id=2, ptype=2, fW,bW,fV,bV,fT,bT,fY,bY}  a set of label for the node in route, which indicate the information for them, in order to check feasibility of route
    return self
end 

local function forward_mark(route, p)
    for i=p,#route do
        route[i].fT = push_forward(route[i-1], route[i].id)
        route[i].fW = route[i-1].fW + nodes[route[i].id].weight
        route[i].fV = route[i-1].fV + nodes[route[i].id].volume
    end 
end 

local function backward_mark(route, p)
    for i=p,1,-1 do
        local point = route[i+1] or {id=0, bT=nodes[0].time2, bW=0, bV=0}
        route[i].bT = push_backward(point, route[i].id)
        route[i].bW = point.bW + nodes[route[i].id].weight
        route[i].bV = point.bV + nodes[route[i].id].volume
    end
end 

function Route:push_back(node_id)
    local fT, bT, forward
    forward = self[#self]
    fT = push_forward(forward, node_id)
    bT = nodes[node_id].time2
    table.insert(self, {id=node_id, fT=fT, bT=bT, fW=forward.fW + nodes[node_id].weight, fV=forward.fV + nodes[node_id].volume, bW=nodes[node_id].weight, bV=nodes[node_id].volume})
    backward_mark(self, #self-1)
end 

function Route:append(point)
    table.insert(self, point)
end 

function Route:push_back_seq(seq)
    for i=1,#seq do
        local fT, bT, forward
        forward = self[#self]
        fT = push_forward(forward, seq[i].id)
        table.insert(self, {id=seq[i].id, fT=fT, bT=bT, fW=forward.fW + nodes[seq[i].id].weight, fV=forward.fV + nodes[seq[i].id].volume})
    end
    self[#self].bW = nodes[seq[#seq].id].weight
    self[#self].bV = nodes[seq[#seq].id].volume
    self[#self].bT = nodes[seq[#seq].id].time2
    backward_mark(self, #self-1)
end 


function Route:clone()
    return DeepCopy(self)
end

Solution = {cost = false, pena_cost = false, feasible = true}
Solution.__index = Solution

function Solution:new()
    local self = {}
    setmetatable(self, Solution)
    self.cost = false
    self.pena_cost = false
    self.feasible = true
    return self
end 

local function copyKeyValue(toTab, fromTab)    
    for key,value in pairs(fromTab) do
        toTab[key] = value
    end 
end

function Solution:to_giantTour()
    for r,route in ipairs(self) do
        nodes[-r] = {suc=route[1].id, route=-r, vtp=route.vtp}
        copyKeyValue(nodes[-r], nodes[0])
        copyKeyValue(nodes[-r], route[0])
        
        if #route > 1 then 
            nodes[route[1].id].pre, nodes[route[1].id].suc = -r, route[2].id
            for i=2,#route-1 do nodes[route[i].id].pre, nodes[route[i].id].suc = route[i-1].id, route[i+1].id end 
            nodes[route[#route].id].pre, nodes[route[#route].id].suc = route[#route-1].id, -r - 1
        else
            nodes[route[1].id].pre, nodes[route[1].id].suc = -r, -r - 1
        end 
    
        for i=1,#route do 
            copyKeyValue(nodes[route[i].id], route[i])
            nodes[route[i].id].route, nodes[route[i].id].vtp = -r, route.vtp
        end 
    end 
    nodes[self[#self][#self[#self]].id].suc = -1
    for i=2,#solution do
        nodes[-i].pre = self[i-1][#self[i-1]].id
    end 
    nodes[-1].pre = self[#self][#self[#self]].id
end 

function Solution:appendRoute(route)
    table.insert(self, route)
end 
function Solution:getCost()
    local cost = 0
    local total_distance = 0
    for r,route in ipairs(self) do
        if route[1] then 
            for i=1,#route do
                if route[i].bT > nodes[route[i].id].time2 then 
                    self.isfeasible = false
                    self.cost = math.huge 
                    return self.cost
                end
                cost = cost + dis(route[i-1].id, route[i].id) * vehicle[route.vtp].tc + math.max(0,  nodes[route[i].id].time1 - route[i].bT) * vehicle[route.vtp].wc
                total_distance = total_distance +  dis(route[i-1].id, route[i].id)
            end 
            cost = cost + dis(route[#route].id,1) * vehicle[route.vtp].tc + vehicle[route.vtp].fc  
            total_distance = total_distance +  dis(route[#route].id,1)
        end
        -- waittime cost
    end 
    print('Total distance: ', total_distance)
    self.cost = cost
    return self.cost
end 
function Solution:output()
    io.output('Result.csv')
    io.write('trans_code, dist_seq, distacne\n')
    for i=1,#self.routes do
        io.write(string.format('DP%04d,', i))
        --local totalDistance = 0
        for j=1,#self.routes[i] do
            if j<#self.routes[i] then
                io.write(string.format('%d;', self.routes[i][j].id))
                --totalDistance = totalDistance + dis[self[i][j].id][self[i][j+1].id]
            else 
                io.write(string.format('%d,', self.routes[i][j].id))
            end
        end
        --io.write(string.format('%f,', totalDistance))
        io.write('\n')
    end
    io.close()
end 

function Solution:plot()
    if not Nodes then 
        Nodes = CreateShapes('nodes [Points]','point') 
        AddField(Nodes, 'id', 'int')
        AddField(Nodes, 'ptype', 'int') -- dont do that:the color of attributes put at first place
        AddField(Nodes, 'weight', 'float')
        AddField(Nodes, 'volume', 'float')
        AddField(Nodes, 'route', 'int')
        AddField(Nodes, 'TW', 'string')
        for i=0,#nodes do
            local shp = AddShape(Nodes, nodes[i].x, nodes[i].y) 
            if i==0 then 
                SetValue(shp, 1, 'ptype')
            else
                SetValue(shp, 2, 'ptype')
            end 
            SetValue(shp, i, 'id')
            SetValue(shp, nodes[i].weight, 'weight')
            SetValue(shp, nodes[i].weight, 'volume')
            SetValue(shp, '[' .. nodes[i].time1/10 .. ',' .. nodes[i].time2/10 .. ']', 'TW')
        end
        Update(Nodes)
        SetParameter(Nodes, "COLORS_TYPE", 3)
        SetParameter(Nodes, "LABEL_ATTRIB", 1)
    end 
    
    local Routes = CreateShapes('Solution [Lines]','line')
    AddField(Routes, 'id', 'int')
    AddField(Routes, 'route_segment', 'int')  --  dont do that: the color of attributes put at first place
    AddField(Routes, 'route_travel_time', 'float')
    local index = 1
    for i, route in ipairs(self) do
        for j=0,#route-1 do 
            local shp = AddShape(Routes, nodes[route[j].id].x,nodes[route[j].id].y,nodes[route[j+1].id].x,nodes[route[j+1].id].y)
            SetValue(shp, index, 'id')
            SetValue(shp, i, 'route_segment')
            index = index + 1
            if j>0 then
                SetValue(Nodes, route[j].id, 'route', route[#route].id) 
            end 
        end
    end 
    SetParameter(Routes, "COLORS_TYPE", 3)
    Update(Routes)
    CreateView('vrp result cost: ' .. self:getCost(), Nodes, Routes)
end



