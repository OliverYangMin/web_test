-- name: LocalSearch
-- purpose: includes all operators for solution neighbor
-- start date: 2019-04-16
-- authors: YangMin
function Neighborhood(operator, strategy)
    strategy = strategy or math.huge
    local move = {delta=0}
    for new_move in Neighbors(operator) do
        if new_move and new_move.delta<0 then
            strategy = strategy - 1
            if new_move.delta < move.delta then
                move = new_move
            end
            if strategy==0 then break end 
        end 
    end  
    return move
    --operator()
end 

function RandomNeighbor(operator)
    local moves = {}
    for move in Neighbors(operator) do
        table.insert(moves, move)
    end 
    return moves[math.random(#moves)]
end 

function Perturb(operator)
    giant:executeMove(RandomNeighbor(operator))
end 

function Neighbors(operator)   --领域使用迭代生成器，一个一个返回move
    return coroutine.wrap(function() operator() end)
end  

-------------common function--------------------
local function removeCost(node)
    return - dis(nodes[node].pre, node) - dis(node, nodes[node].suc) 
end 
---------------------------------node_relocate----------------------------------------------------------
local function freeNodeDelta(node)
    local cost = (dis(nodes[node].pre, nodes[node].suc) + removeCost(node)) * vehicle[nodes[node].vtp].tc
    if nodes[node].pre < 0 and nodes[node].suc < 0 then 
        return cost - vehicle[nodes[node].vtp].fc
    end 
    return cost 
end 

local function insertNodeCost(node, pos)
    return (dis(pos, node) + dis(node, nodes[pos].suc) - dis(pos, nodes[pos].suc)) * vehicle[nodes[pos].vtp].tc
end 

local function relocateTest(node, pos)
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

function node_relocate()
    --selected one node be relocated to pos --move type = 1
    for i=1,#nodes do
        local delta_free = freeNodeDelta(i)
        local j = -1 
        repeat 
            local sign 
            --1 i==j; 2 j.suc==i; 3 j.route is empty
            if j ~= i and j ~= nodes[i].pre and nodes[j].id ~= nodes[nodes[j].suc].id then
                if nodes[i].route == nodes[j].route then 
                    
                else
                    sign = relocateTest(i, j)
                    if sign==true then 
                        coroutine.yield{delta = delta_free + insertNodeCost(i, j), p = {i,j}, mtp = 1} 
                    end 
                end
            end 
            j = sign == 'next_route' and nodes[j].route - 1 or nodes[j].suc
        until j == -1 or j < nodes[nodes[-1].pre].route
    end 
end 
---------------------------------2-opt-star----------------------------------------------------------
local function isConcate2SegmentsFeasible(node1, node2)
    if not checkWV(nodes[node1], nodes[node2]) then
        return false --'capacity_violation'
    elseif not dis(node1, node2) then
        return false --'accessbility_violation'
    elseif push_forward(nodes[node1], node2) > nodes[node2].bT then 
        return false ---'time_violation'
    end 
    return true
end 

local function isReverseSegmentFeasible(node1, node2)  --只有前后顺序发生改变的点，才可能dis(i,j)可行，而dis(j,i)不可行
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

function two_opt_star()
    local i = -1
    repeat
        local j = nodes[i].suc < 0 and  nodes[i].suc or nodes[nodes[i].suc].suc  
        --node i 是否为末尾点
        while j ~= -1 and j >= nodes[nodes[-1].pre].route do
            local sign = true 
            if not ((i < 0 and j<0) or (nodes[i].suc < 0 and nodes[j].suc < 0)) then 
                if nodes[i].route == nodes[j].route then
                    if isReverseSegmentFeasible(nodes[i].suc, j) then
                        --if j is the start depot, one route be deleted
                        coroutine.yield{delta = delta_free + dis(i, j) + dis(nodes[i].suc, nodes[j].suc), p={i,j}, mtp=0}
                    else
                        --next route
                        sign = false
                    end
                else
                    sign = isConcate2SegmentsFeasible(j, nodes[i].suc) 
                    if sign and isConcate2SegmentsFeasible(i, nodes[j].suc) then
                        local delta = ((j < 0 and nodes[i].suc < 0) or  (i < 0 and nodes[j].suc < 0)) and vehicle[nodes[j].vtp].fc or 0
                        coroutine.yield{delta = delta + dis(i, nodes[j].suc) + dis(j, nodes[i].suc) - dis(i, nodes[i].suc) - dis(j, nodes[j].suc), p={i,j}, mtp=0}
                    end 
                end 
            end 
            j = sign and nodes[j].suc or nodes[j].route - 1
            --next node or next route
        end
        i = nodes[i].suc
        --next node 
    until i == -1 or i < nodes[nodes[-1].pre].route
end 
---------------------------------node_swap----------------------------------------------------------
local function insertTest(node1, node2, node3)
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

local function connectCost(node1, node2)
    return dis(nodes[node1].pre, node2) + dis(node2, nodes[node1].suc)
end 

local function swapNodeDelta(node1, node2)
    return (connectCost(node1, node2) + removeCost(node1)) * vehicle[nodes[node1].vtp].tc + (connectCost(node2, node1) + removeCost(node2)) * vehicle[nodes[node2].vtp].tc
end 

function node_swap()
    --swap two nodes; move type = 2
    for i=1,#nodes do
        for j=i+1,#nodes do
            if nodes[i].route ~= nodes[j].route then 
                if insertTest(nodes[i].pre, j, nodes[i].suc) and insertTest(nodes[j].pre, i, nodes[j].suc) then 
                    coroutine.yield{delta = swapNodeDelta(i, j), p = {i,j}, mtp = 2} 
                end 
            end 
        end 
    end 
end 

---------------------------------node_swap----------------------------------------------------------
