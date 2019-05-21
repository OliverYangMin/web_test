-- name: BasicFunction
-- purpose: some functions for our object
-- start date: 2019-04-20
-- authors: YangMin

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
    --if node1==node2 then return false end
    local delta_lat = math.abs((nodes[node1].x - nodes[node2].x) / 2)
    local delta_lng = math.abs((nodes[node1].y - nodes[node2].y) / 2)
    return 2 * 6378137 * math.asin(math.sqrt(math.sin(math.pi/180*delta_lat)^2 + math.cos(math.pi/180*nodes[node1].x) * math.cos(math.pi/180*nodes[node2].x) * math.sin(math.pi/180*delta_lng)^2))
end 