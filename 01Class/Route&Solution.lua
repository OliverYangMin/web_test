

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
        --SetParameter(Nodes, "COLORS_TYPE", 3)
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
    --SetParameter(Routes, "COLORS_TYPE", 3)
    Update(Routes)
    CreateView(string.format('VRP result cost: %.2f and %d vehicles', self:getCost(), #self), Nodes, Routes)
end