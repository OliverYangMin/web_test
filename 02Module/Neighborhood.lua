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
---------------------------------node_relocate----------------------------------------------------------
function node_relocate()
    for i=1,#nodes do
        local delta_free = cDelta:freeNodeCost(i)
        local j = -1 
        repeat 
            local sign 
            if j ~= i and j ~= nodes[i].pre and nodes[j].id ~= nodes[nodes[j].suc].id then
                if feasible:sameRoute(i, j) then 
                    
                else
                    sign = feasible:relocate(i, j)
                    if sign==true then 
                        coroutine.yield(RelocateMove:new(delta_free + cDelta:insertNodeCost(i, j), i, j))
                    end 
                end
            end 
            j = sign == 'next_route' and nodes[j].route - 1 or nodes[j].suc
        until j == -1 or j < nodes[nodes[-1].pre].route
    end 
end 
---------------------------------2-opt-star----------------------------------------------------------
local function create2OptMove(pos1, pos2)
    if feasible:reverseSegment(nodes[pos1].suc, pos2) then
        return TwoOptMove:new(dis(pos1, pos2) + dis(nodes[pos1].suc, nodes[pos2].suc) - dis(pos1, nodes[pos1].suc) - dis(pos2, nodes[pos2].suc), pos1, pos2)
    end
end 

local function create2OptStarMove(pos1, pos2)
    if feasible:concateTwoSegments(pos1, nodes[pos2].suc) then
        local vehicle_fc = ((pos2 < 0 and nodes[pos1].suc < 0) or  (pos1 < 0 and nodes[pos2].suc < 0)) and vehicle[nodes[pos2].vtp].fc or 0
        return TwoOptStarMove:new(vehicle_fc + dis(pos1, nodes[pos2].suc) + dis(pos2, nodes[pos1].suc) - dis(pos1, nodes[pos1].suc) - dis(pos2, nodes[pos2].suc), pos1, pos2)
    end 
end 

function two_opt_star()
    local i = -1
    repeat
        local j = nodes[i].suc < 0 and  nodes[i].suc or nodes[nodes[i].suc].suc  
        while j ~= -1 and j >= nodes[nodes[-1].pre].route do
            local sign = true 
            if not ((i < 0 and j<0) or (nodes[i].suc < 0 and nodes[j].suc < 0)) then 
                local move 
                if feasible:sameRoute(i, j) then
                    move = create2OptMove(i, j) 
                    if not move then sign = false end
                else
                    sign = feasible:concateTwoSegments(j, nodes[i].suc) 
                    if sign then move = create2OptStarMove(i, j) end 
                end 
                if move then coroutine.yield(move) end
            end 
            j = sign and nodes[j].suc or nodes[j].route - 1
        end
        i = nodes[i].suc
    until i == -1 or i < nodes[nodes[-1].pre].route
end 
---------------------------------node_swap----------------------------------------------------------
function node_swap()
    for i=1,#nodes do
        for j=i+1,#nodes do
            if not feasible:sameRoute(i, j) and feasible:insert(nodes[i].pre, j, nodes[i].suc) and feasible:insert(nodes[j].pre, i, nodes[j].suc) then 
                coroutine.yield(SwapMove:new(cDelta:swapNodeCost(i, j), i, j)) 
            end 
        end 
    end 
end 
---------------------------------node_swap----------------------------------------------------------