-- name: BasicFunction
-- purpose: some functions for our object
-- start date: 2019-04-20
-- authors: YangMin

function displayResult(start_time)
    --giant:plot()
    giant:isFeasible()
    print('The algorithm`s total computation time=', os.time() - start_time)
    print('The total cost of best tour plan = ', (giant:getCost()))
    print('The number of vehicle be used: ', giant:getRouteNum())
end 

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

function checkWV(cPoint1, cPoint2, cPoint3)
    if cPoint3 then 
        return cPoint1.fW + cPoint2.weight + cPoint3.bW <= vehicle[cPoint1.vtp].weight and cPoint1.fV + cPoint2.volume + cPoint3.bV <= vehicle[cPoint1.vtp].volume 
    else
        return cPoint1.fW + cPoint2.bW <= vehicle[cPoint1.vtp].weight and cPoint1.fV + cPoint2.bV <= vehicle[cPoint1.vtp].volume 
    end    
end 


-----------Mark Update-------------------------
function markForward(node)   --从node开始，包括node，向后更新 f labels 直到碰到终点depot
    while node > 0 do 
        nodes[node].fT = push_forward(nodes[nodes[node].pre], node)
        nodes[node].fW = nodes[nodes[node].pre].fW + nodes[node].weight
        nodes[node].fV = nodes[nodes[node].pre].fV + nodes[node].volume
        node = nodes[node].suc
    end 
end 

function markBackward(node)   --从node开始，包括node，向前更新 b labels， 直到碰到 起点depot
    while node > 0 do
        local point = nodes[node].suc > 0 and nodes[nodes[node].suc] or {id=0, bT=nodes[0].time2, bW=0, bV=0}   --如果保证，depot点的label 都是0，则可以删去此地方
        nodes[node].bT = push_backward(point, node)
        nodes[node].bW = point.bW + nodes[node].weight
        nodes[node].bV = point.bV + nodes[node].volume
        node = nodes[node].pre
    end 
end 

function EarthDistance(node1, node2)
    --if node1==node2 then return false end
    local delta_lat = math.abs((nodes[node1].x - nodes[node2].x) / 2)
    local delta_lng = math.abs((nodes[node1].y - nodes[node2].y) / 2)
    return 2 * 6378137 * math.asin(math.sqrt(math.sin(math.pi/180*delta_lat)^2 + math.cos(math.pi/180*nodes[node1].x) * math.cos(math.pi/180*nodes[node2].x) * math.sin(math.pi/180*delta_lng)^2))
end 