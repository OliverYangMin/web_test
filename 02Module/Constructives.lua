-- name: Constructive Algorithms for vrp_tw
-- purpose: includes constructive algorithms: back_forth, nearest neighbor, Clark Wright, Sweep 
-- start date: 2019-04-20
-- authors: YangMin
-- update: 
module(..., package.seeall)

function getBackForth()
    local solution = Solution:new()
    for i=1,#nodes do
        local route = Route:new(1)
        route:push_back(i)
        solution:append(route)
    end 
    return solution
end 
--------------------------------------------------------------------------------
local function compute_savings(mu)
    local saves = {}
    for i=1,#nodes do
        for j=1,#nodes do
            if i ~= j then
                local save = dis(0,i) + dis(j,0) - mu * dis(i,j)
                if save > 0 then table.insert(saves, {save; i = i, j = j}) end
            end 
        end
    end 
    table.sort(saves, function(a,b) return a[1] > b[1] end)
    return saves
end

local function feasible(route1, route2)
    if route2[#route2].fW + route1[#route1].fW <= vehicle[route2.vtp].weight and route2[#route2].fV + route1[#route1].fV <= vehicle[route2.vtp].volume then
        return push_forward(route2[#route2], route1[1].id) <= route1[1].bT
    end 
end 

function ClarkWright(mu, seq_para)
    local savings = compute_savings(mu)
    local solution = getBackForth()
    if seq_para then
        local cIndex = 1
        while cIndex <= #solution do
            ::continue::
            for s,saving in ipairs(savings) do
                if solution[cIndex][1].id == saving.i then
                    for j=cIndex+1,#solution do
                        if solution[j][#solution[j]].id == saving.j then 
                            if feasible(solution[j], solution[cIndex]) then
                                solution[j]:push_back_seq(solution[cIndex])
                                solution[cIndex], solution[j] = solution[j], solution[cIndex]
                                table.remove(savings, s)
                                table.remove(solution, j)
                                goto continue
                            else
                                break
                            end 
                        end 
                    end
                elseif saving.j == solution[cIndex][#solution[cIndex]].id then
                    for j=cIndex+1,#solution do
                        if solution[j][1].id == saving.i then 
                            if feasible(solution[cIndex], solution[j]) then
                                solution[cIndex]:push_back_seq(solution[j])
                                table.remove(savings, s)
                                table.remove(solution, j)
                                goto continue
                            else
                                break
                            end 
                        end 
                    end
                end 
            end    
            cIndex = cIndex + 1
        end 
    else 
        for s,saving in ipairs(savings) do
            for i, route1 in ipairs(solution) do 
                if route1[1].id == saving.i then
                    for j,route2 in ipairs(solution) do
                        if i~=j then
                            if saving.j == route2[#route2].id then  
                                if feasible(route1, route2) then
                                    route2:push_back_seq(route1)
                                    table.remove(solution, i)
                                end 
                                goto continue
                            end 
                        end 
                    end 
                end 
            end 
            ::continue::
        end 
    end
    return solution
end
--------------------------------------------------------------------------------
local function closet(point, node)
    local node_time = push_forward(point, node)
    return beta[1] * dis(point.id, node) + beta[2] * (node_time - point.fT - nodes[node].stime) + beta[3] * (nodes[node].time2 - point.fT - nodes[node].stime - time(point.id,node))
end 

local function isFeasiblePushBack(node)
    if dis(route[#route].id,node) and route[#route].fT + nodes[route[#route].id].stime + time(route[#route].id,node) <= nodes[node].time2 then
        return route[#route].fW + nodes[node].weight <= vehicle[route.vtp].weight and route[#route].fV + nodes[node].volume <= vehicle[route.vtp].volume 
    end 
end 

local function NearestUnroutedNode()
    local min, min_v = 0, math.huge
    for i=1,#unrouted do
        if isFeasiblePushBack(unrouted[i]) then 
            local cclose = closet(route[#route], unrouted[i])
            if cclose < min_v then
                min, min_v = i, cclose
            end 
        end 
    end 
    local node = unrouted[min]
    table.remove(unrouted, min)
    return node
end 

function NearestInsertion(...)
    local solution = Solution:new()
    beta, unrouted = {...}, {}
    for i=1,#nodes do unrouted[#unrouted+1] = i end
    repeat 
        route = Route:new()
        repeat
            local next_node = NearestUnroutedNode()
            if next_node then 
                route:push_back(next_node)
            else
                solution:append(route)
            end 
        until not next_node
    until #unrouted == 0
    beta, unrouted, route = nil, nil, nil
    return solution
end  
--------------------------------------------------------------------------------
local function insertDelta(cRoute, pos, node)
    if cRoute[#cRoute].fW + nodes[node].weight <= vehicle[cRoute.vtp].weight and cRoute[#cRoute].fV + nodes[node].volume <= vehicle[cRoute.vtp].volume then 
        local point2 = cRoute[pos+1] or {id = 0, bT = nodes[0].time2, fT = cRoute[pos].fT + nodes[cRoute[pos].id].stime + time(cRoute[pos].id, 0)}
        if dis(cRoute[pos].id, node) and dis(node, point2.id) then     
            local fT = push_forward(cRoute[pos], node)
            if fT <= nodes[node].time2 and fT + nodes[node].stime + time(node, point2.id) <= point2.bT then
                local c11 = dis(cRoute[pos].id, node) + dis(node, point2.id) - dis(cRoute[pos].id, point2.id) * mu
                local c12 = math.max(0, fT + nodes[node].stime + time(node, point2.id) - point2.fT)
                return lambda * dis(0, node) - c11 * alpha1 - c12 * alpha2
            end 
        end 
    end 
    return - math.huge
end 

function Insertion1(...)
    mu, alpha1, alpha2, lambda = ...
    local solution = Solution:new()
    solution:append(Route:new())
    unrouted = {}
    for i=1,#nodes do unrouted[#unrouted+1] = i end     
    while #unrouted > 0 do
        --local min = {cost = math.huge, node = 0, route = 0, pos = 0}
        local min = {cost = -10000000, node = 0, route = 0, pos = 0}
        for i=1,#unrouted do
            for j=#solution,1,-1 do
                for k=0,#solution[j] do
                    local cost = insertDelta(solution[j], k, unrouted[i])
                    if cost > min.cost then
                        min = {cost = cost, node = i, route = j, pos = k}
                    end 
                end 
            end 
        end
        if min.node > 0 then 
            solution[min.route]:insert(unrouted[min.node], min.pos)
            table.remove(unrouted, min.node)
        else
            solution:append(Route:new())
        end 
    end 
    mu, alpha1, alpha2, lambda = nil
    return solution 
end 