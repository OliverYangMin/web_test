Feasible = {}
Feasible.__index = Feasible

function Feasible:new()
    local self = {}
    setmetatable(self, Feasible)
    return self
end 


function Feasible:giantTour()
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

function Feasible:insert(node1, node2, node3)
    if checkWV(nodes[node1], nodes[node2], nodes[node3]) then 
        if dis(node1, node2) and dis(node2, node3) then     
            local fT = push_forward(nodes[node1], node2)
            if fT <= nodes[node2].time2 and fT + nodes[node2].stime + time(node2, node3) <= nodes[node3].bT then
                return true
            end
        end 
    end 
    return false
end 

function Feasible:relocate(node, pos)
    local point1, point2, point3 = nodes[pos], nodes[node], nodes[nodes[pos].suc]
    if checkWV(point1, point2, point3) and dis(point1.id, point2.id) then 
        if dis(point2.id, point3.id) then     
            local fT = push_forward(point1, point2.id)
            if fT > point2.time2 then
                return 'next_route'
            end 
            return  fT + point2.stime + time(point2.id, point3.id) <= point3.bT 
        end 
    else
        return 'next_route' 
    end 
    return false 
end

function Feasible:reverseSegment(node1, node2)  --只有前后顺序发生改变的点，才可能dis(i,j)可行，而dis(j,i)不可行
    local fT = push_forward(nodes[nodes[node1].pre], node2)
    if fT > nodes[node2].time2 then return false end 
    local node = node2
    repeat 
        if not dis(node, nodes[node].pre) then return false end  ---could cut down
        fT = push_forward(nodes[node], nodes[node].pre, fT)
        if fT > nodes[nodes[node].pre].time2 then return false end 
        node = nodes[node].pre
    until node == nodes[node1].pre
    return push_forward(nodes[node], nodes[node2].suc, fT) <= nodes[nodes[node2].suc].bT
end 


function Feasible:concateTwoSegments(node1, node2)
    if not checkWV(nodes[node1], nodes[node2]) then
        return false --'capacity_violation'
    elseif not dis(node1, node2) then
        return false --'accessbility_violation'
    elseif push_forward(nodes[node1], node2) > nodes[node2].bT then 
        return false ---'time_violation'
    end 
    return true
end 

function Feasible:sameRoute(node1, node2)
    return nodes[node1].route == nodes[node2].route
end 