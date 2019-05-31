function dis(i, j)
    i = i>0 and i or 0
    j = j>0 and j or 0
    return Dis[i][j]
end 

function time(i, j)
    i = i>0 and i or 0
    j = j>0 and j or 0
    return Time[i][j]
end 

function preprocessing()
    for i=1,#nodes do
        nodes[i].time2 = math.min(nodes[0].time2 - time(i, 0), nodes[i].time2)
    end 
    repeat
        local change 
        for i=1,#nodes do
            local min = math.huge
            for j=0,#nodes do
                if i~=j then 
                    min = math.min(min, nodes[j].time1 + nodes[j].stime + time(j, i))
                end 
            end
            change = nodes[i].time1 < math.min(nodes[i].time2, min)
            nodes[i].time1 = math.max(nodes[i].time1, math.min(nodes[i].time2, min))
        end 
        
        for i=1,#nodes do
            local min = math.huge
            for j=0,#nodes do 
                if i~=j then
                    min = math.min(min, nodes[j].time1 - nodes[i].stime - time(i, j))
                end 
            end 
            change = nodes[i].time1 < math.min(nodes[i].time2, min)
            nodes[i].time1 = math.max(nodes[i].time1, math.min(nodes[i].time2, min))
        end 
        
        for i=1,#nodes do
            local max = 0
            for j=0,#nodes do
                if i~=j then 
                    max = math.max(max, nodes[j].time2 + nodes[j].stime + time(j, i))
                end 
            end 
            change = nodes[i].time2 > math.max(nodes[i].time1, max)
            nodes[i].time2 = math.min(nodes[i].time2, math.max(nodes[i].time1, max))
        end 
        
        for i=1,#nodes do
            local max = 0 
            for j=0,#nodes do
                if i~=j then 
                    max = math.max(max, nodes[j].time2 - nodes[i].stime + time(i, j))
                end 
            end
            change = nodes[i].time2 > math.max(nodes[i].time1, max)
            nodes[i].time2 = math.min(nodes[i].time2, math.max(nodes[i].time1, max))
        end   
    until not change
end 

function DeepCopy(object)      
    local SearchTable = {}  
    local function Func(object)  
        if type(object) ~= "table" then  
            return object         
        end  
        local NewTable = {}  
        SearchTable[object] = NewTable  
        for k, v in pairs(object) do  
            NewTable[Func(k)] = Func(v)  
        end     
        return setmetatable(NewTable, getmetatable(object))      
    end    
    return Func(object)  
end 

function push_forward(point, node, fT)
    if fT then 
        return math.max(nodes[node].time1, fT + time(point.id, node) + nodes[point.id].stime) 
    else
        return math.max(nodes[node].time1, point.fT + time(point.id, node) + nodes[point.id].stime) 
    end 
end 

function push_backward(point, node)
    return math.min(nodes[node].time2, point.bT - time(node, point.id) - nodes[point.id].stime)
end 

function EarthDistance(node1, node2)
    local delta_lat = math.abs((nodes[node1].x - nodes[node2].x) / 2)
    local delta_lng = math.abs((nodes[node1].y - nodes[node2].y) / 2)
    return 2 * 6378137 * math.asin(math.sqrt(math.sin(math.pi/180*delta_lat)^2 + math.cos(math.pi/180*nodes[node1].x) * math.cos(math.pi/180*nodes[node2].x) * math.sin(math.pi/180*delta_lng)^2))
end 