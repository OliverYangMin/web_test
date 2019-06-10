-- name: Algorithms
-- purpose: includes all algorithm frameworks 
-- start date: 2019-04-11
-- authors: YangMin
module(..., package.seeall)
require '02Module.Neighborhood'

function SteepestDescent(operator, strategy)
    while true do
        local move = Neighborhood(operator, strategy)
        if move.delta < 0 then
            move:execute()
        else 
            break
        end 
    end 
end 

function SimulateAnnealing(operator, ...)
    local function SAaccept(move, temp)
        return move.delta < 0 or math.exp(- move.delta / temp / 10) > math.random()
    end 
    local paras = {...}
    local alpha = paras[1] or 0.98 --退火系数
    local Len = paras[2] or 100    --每个温度时的迭代次数，即链长
    local T = 100 --nodes:getCost()      --初始温度
    local best_solution = nodes:to_solution()
    local count = 0
    while T > 1 do
        for i=1,Len do
            local move = RandomNeighbor(operator)
            if SAaccept(move, T) then
                move:execute()
                   
                if nodes:getCost() < best_solution:getCost() then
                 
                    best_solution = nodes:to_solution()
                end
            end
        end 
        T = T * alpha
        count = count + 1
        --print('Current Temperature = ',T)
    end
    return best_solution
end   

function VariableNeighborhoodSearch(operators, max_iter)
    local best_solution = nodes:to_solution()
    for i=1,max_iter do
        SetProgress(i, max_iter)
        RandomNeighbor(operators[math.random(#operators)]):execute()
        local index = 1
        while index <= #operators do
            local move = Neighborhood(operators[index])
            if move.delta < 0 then
                move:execute()
                if nodes:getCost() < best_solution.cost then 
                    best_solution = nodes:to_solution()
                end 
                index = 1
            else 
                index = index + 1
            end 
        end  
        print('Iteration number:', i, ' and ', nodes:getCost())
    end 
    return best_solution
end 

local function greedyAccept(cMove)
    return cMove.delta<0 
end 
function IteratedLocalSearch(random_move, operator)
    while stopCriterion() do
        Perturb(random_move)
        local move = Neighborhood(operator)
        if greedyAccept(move) then
            giant:executeMove(move)
        end 
        if cDelta:giantTour() < best_solution.cost then
            best_solution = to_solution()
        end 
    end 
end 

local function stopCriterion()
    

end 

local function updateTabu(cMove)
    
end 

local function buildRCL(alpha, candi, cmax, cmin)
    local RCL
    for i=1,#candi do
        if candi[i] <= cmin + alpha * (cmax - cmin) then
            RCL[#RCL+1] = candi[i] 
        end 
    end 
    return RCL
end

local function greedyRandomizedConstruction(alpah, seed)
    local candidates = {}
    evaluateIncrementalCost(candidates)
    while #candidates > 0 do
        local cmin = math.min(unpack(candidates))
        local cmax = math.max(unpack(candidates))
        local rcl = buildRCL(alpha, candidates, cmax, cmin)
        local elem = rcl[math.random(#rcl)]
        expandSolution(solution, elem)
        
    end 
end 

function GRASP(max_iterations, operator, seed)
    math.randomseed(seed)
    for k=1,max_iterations do
        local solution = greedyRandomizedConstruction(alpha, seed)
        if not feasible(solution) then 
            solution = repair(solution)
        end 
        solution = SteepestDescent(operator)
        if solution.cost < best_solution.cost then
            best_solution = solution
        end 
    end
end 

--local function tryInsertNode(node, route_index)
--    for i=#solution,1,-1 do
--        if solution[i] and i~=route_index and #solution[i]<=10 then 
--            for j=0,#solution[i] do
--                if solution[i][0].bW+nodes[node].weight<=vehicles[solution[i].v_type].weight and solution[i][0].bV+nodes[node].volume<=vehicles[solution[i].v_type].volume then 
--                    if dis[solution[i][j].id][node] then  
--                        local fT = push_forward(solution[i][j], node)
--                        if fT<=nodes[node].time2 then
--                            local tail = solution[i][j+1] or {id=0,bT=nodes[0].time2}
--                            if dis[node][tail.id] and fT + nodes[node].stime + time[node][tail.id]<= tail.bT then
--                                table.insert(solution[i], j+1, {id=node})
--                                forward_mark(solution[i], j+1)
--                                backward_mark(solution[i], j+1)
--                                return true 
--                            end 
--                        else
--                            break
--                        end
--                    end
--                else
--                    break
--                end 
--            end 
--        end 
--    end       
--    return false
--end 

--local function tryInsertRCL(rcl, route_index)
--    for i=1,#rcl do
--        if not tryInsertNode(rcl[i], route_index) then 
--            return false
--        end 
--    end
--    return true
--end 

--function DestoryRoute()
--    --solution:sort()
--    table.sort(solution, function(a,b) return #a<#b end)
--    local copy_solution = solution:clone()
--    for r,route in ipairs(solution) do
--        local RCL = {}
--        for i=1,#route do table.insert(RCL, route[i].id) end
--        if tryInsertRCL(RCL, r) then 
--            solution[r] = false
--            copy_solution = solution:clone()
--        else
--            solution = copy_solution:clone()
--        end 
--    end 
--    --require 'mobdebug'.on()
   
--end 

function LargeNeighborhoodSearch(accept)
    local cSolu = {cost = solution:getCost()}
    
    for iter=1,100 do    
        destroy()
        repair()
        if nodes:getCost() < cSolu.cost then 
            cSolu = nodes:to_solution()
        end 
        if cSolu.cost < solution:getCost() then
            solution = cSolu
        end 
    end 
end 

--function AdaptiveLargeNeighborhoodSearch()
--    repeat
--        local destroy = chooseDestory()
--        local repair  = chooseRepair()
--        destroy()
--        repair()
--        if accept() then
--            solution = nodes:to_solution()
--        end 
--        dscore[1] = dscore[1] + 1
--        rscore[1] = rscore[1] + 1
        
--    until a 
--end 

