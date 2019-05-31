Route = {vtp = 1}
Route.__index = Route

function Route:new(vtp, cost)
    local self = {vtp = vtp or 1, cost = cost}
    setmetatable(self, Route)
    self[0] = {id=0, fT = nodes[0].time1, bT=nodes[0].time2, fW = 0, fV = 0, bW=0, bV=0} 
    return self
end 

function Route:contains(node)
    for i=1,#self do
        if self[i].id == node then 
            return true
        end 
    end 
    return false
end 

function Route:getBranchArc(cRoute)
    if not self:intersects(cRoute) then error(110) end 
    for i=1,#self do
        for j=1,#cRoute do
            if self[i].id == cRoute[j].id then 
                if i == #self or j == #cRoute then
                    if self[i-1].id ~= cRoute[j-1].id then 
                        return {self[i-1].id, self[i].id}
                    end 
                elseif self[i+1].id ~= cRoute[j+1].id then
                    return {self[i].id, self[i+1].id}
                end 
            end 
        end
    end 
end 

function Route:intersects(cRoute)
    for i=1,#self do
        for j=1,#cRoute do
            if self[i].id == cRoute[j].id then
                return true
            end 
        end 
    end 
    return false
end 

function Route:forward_mark(p)
    for i=p,#self do
        self[i].fT = push_forward(self[i-1], self[i].id)
        self[i].fW = self[i-1].fW + nodes[self[i].id].weight
        self[i].fV = self[i-1].fV + nodes[self[i].id].volume
    end 
end 

function Route:backward_mark(p)
    for i=p,1,-1 do
        local point = self[i+1] or {id = 0, bT = nodes[0].time2, bW = 0, bV = 0}
        self[i].bT = push_backward(point, self[i].id)
        self[i].bW = point.bW + nodes[self[i].id].weight
        self[i].bV = point.bV + nodes[self[i].id].volume
    end
end 

function Route:push_back(node_id)
    local fT, bT, forward
    forward = self[#self]
    fT = push_forward(forward, node_id)
    bT = nodes[node_id].time2
    table.insert(self, {id=node_id, fT=fT, bT=bT, fW=forward.fW + nodes[node_id].weight, fV=forward.fV + nodes[node_id].volume, bW=nodes[node_id].weight, bV=nodes[node_id].volume})
    self:backward_mark(#self-1)
end 

function Route:append(point)
    self[#self+1] = DeepCopy(point)
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
    self:backward_mark(#self-1)
end 

function Route:getCost()
    local cost = vehicle[self.vtp].fc
    for i=1,#self do
        cost = cost + dis(self[i-1].id, self[i].id) * vehicle[self.vtp].tc + math.max(0, nodes[self[i].id].time1 - self[i].bT) * vehicle[self.vtp].wc
    end
    return cost + dis(self[#self].id, 0) * vehicle[self.vtp].tc
end 

function Route:clone()
    return DeepCopy(self)
end

Solution = {cost = false, pena_cost = false, feasible = true}
Solution.__index = Solution

function Solution:new(cost)
    local self = {cost = cost}
    setmetatable(self, Solution)
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

function Solution:append(route)
    table.insert(self, route)
end 

function Solution:getCost()
    local cost = 0
    for r,route in ipairs(self) do
        cost = cost + route:getCost()
    end 
    self.cost = cost
    return self.cost
end 

function Solution:output()
    io.output(#solution .. '+'.. solution:getCost() .. 'Result.csv')
    io.write('trans_code   ,  vehicle type , visit count , total weight, loading wegiht, total volume,  loading volume,  origin, customer id-arrival time\n')
    for i=1,#self do
        io.write(string.format('DP%04d, %d, %d', i, self[i].vtp, #self[i]))
        --io.write(string.format(',%d', vehicles[self[i].vtp].weight))
        io.write(string.format(',%f', self[i][1].bW))
--        io.write(string.format(',%d', vehicles[self[i].v_type].volume))
--        io.write(string.format(',%f', self[i][1].bV))
        --local totalDistance = 0        
        for j=0,#self[i] do
            --io.write(string.format(',%d-%02d:%02d', self[i][j].id, math.floor(self[i][j].bT/60), self[i][j].bT%60))
            io.write(string.format(',%d-%d', self[i][j].id, self[i][j].bT))
        end
        io.write('\n')
--        io.write(string.format('time window, , , ,  %f%%, , %f%%,', self[i][1].bW/vehicles[self[i].v_type].weight*100, self[i][1].bV/vehicles[self[i].v_type].volume*100))    
--        for j=0,#self[i] do
--            if j<#self[i] then
--                io.write(string.format('%02d:%02d-%02d:%02d,', math.floor(nodes[self[i][j].id].time1/60),nodes[self[i][j].id].time1%60, math.floor(nodes[self[i][j].id].time2/60), nodes[self[i][j].id].time2%60))
--            else 
--                io.write(string.format('%02d:%02d-%02d:%02d', math.floor(nodes[self[i][j].id].time1/60),nodes[self[i][j].id].time1%60, math.floor(nodes[self[i][j].id].time2/60), nodes[self[i][j].id].time2%60))
--            end
--        end
--        io.write('\n')
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