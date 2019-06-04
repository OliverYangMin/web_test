-- name: Constructive Algorithms for vrp_tw
-- purpose: includes constructive algorithms: back_forth, nearest neighbor, Clark Wright, Sweep 
-- start date: 2019-04-20
-- authors: YangMin
-- update: 
module(..., package.seeall)

function back_forth()
    for i=1,#nodes do
        local route = Route:new(1)
        route:push_back(i)
        solution:append(route)
    end 
end 

function getBackForth()
    local routes = {}
    for i=1,#nodes do
        local route = Route:new(1)
        route:push_back(i)
        routes[#routes+1] = route
    end 
    return routes 
end 
--------------------------------------------------------------------------------
function ClarkWright(seq_para, mu)
    local savings = {}
    back_forth()
    
    local function compute_savings(mu)
        for i=1,#nodes do
            for j=1,#nodes do
                if i ~= j then
                    local saving = dis(0,i) + dis(j,0) - mu * dis(i,j)
                    if saving>0 then table.insert(savings, {saving; i=i,j=j}) end
                end 
            end
        end 
        table.sort(savings, function(a,b) return a[1]>b[1] end)
    end
    compute_savings(mu)
    
    local function feasible(route1, route2)
        if route2[#route2].fW + route1[#route1].fW <= vehicle[route2.vtp].weight and route2[#route2].fV + route1[#route1].fV <= vehicle[route2.vtp].volume then
            return push_forward(route2[#route2], route1[1].id) <= route1[1].bT
        end 
    end 
  
    if seq_para==0 then
        local cIndex = 1
        while cIndex<=#solution do
            ::continue::
            for s,saving in ipairs(savings) do
                if saving.i==solution[cIndex][1].id then
                    for j=cIndex+1,#solution do
                        if solution[j][#solution[j]].id==saving.j then 
                            if feasible(solution[j], solution[cIndex]) then
                                solution[j]:push_back_seq(solution[cIndex])
                                solution[cIndex], solution[j] = solution[j], solution[cIndex]
                                --table.remove(savings, s+1)
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
                                --table.remove(savings, s-1)
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
    elseif seq_para==1 then 
        for s,saving in ipairs(savings) do
            for i=1,#solution do
                if solution[i][1].id==saving.i then 
                    for j=1,#solution do
                        if i~=j then
                            if saving.j==solution[j][#solution[j]].id then 
                                if feasible(solution[i], solution[j]) then 
                                    solution[j]:push_back_seq(solution[i])
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
    else 
        error('CW parameter error')
    end
end
--------------------------------------------------------------------------------
function NearestInsertion(...)
    local function closet(point, node)
        local node_time = push_forward(point, node)
        return beta[1] * dis(point.id,node) + beta[2] * (node_time - point.fT - nodes[node].stime) + beta[3] * (nodes[node].time2 - point.fT - nodes[node].stime - time(point.id,node))
    end 

    local function isFeasiblePushBack(node)
        if dis(route[#route].id,node) and route[#route].fT + nodes[route[#route].id].stime + time(route[#route].id,node) <= nodes[node].time2 then
            if route[#route].fW + nodes[node].weight <= vehicle[route.vtp].weight and route[#route].fV + nodes[node].volume <= vehicle[route.vtp].volume then
                return true
            end 
        end 
        return false
    end 

    local function NearestUnroutedNode()
        local min, min_v = 0, math.huge
        for i=1,#unrouted do
            if isFeasiblePushBack(unrouted[i]) then 
                local cclose = closet(route[#route], unrouted[i])
                if cclose<min_v then
                    min,min_v = i, cclose
                end 
            end 
        end 
        local node = unrouted[min]
        if node then table.remove(unrouted, min) end 
        return node
    end 

    beta = {...}
    unrouted = {}
    for i=1,#nodes do table.insert(unrouted, i) end
    
    route = Route:new()
    local node = NearestUnroutedNode()
    if node then 
        route:push_back(node)
    end 
    while #unrouted>0 do
        local next_node = NearestUnroutedNode()
        if next_node then 
            route:push_back(next_node)
        else
            solution:append(route)
            route = Route:new(nil)
            local node = NearestUnroutedNode()
            if node then 
                route:push_back(node)
            else
                break
            end 
        end 
    end  
    if #route>0 then
        solution:append(route)
    end 
    beta, unrouted, route = nil, nil, nil
end  
--------------------------------------------------------------------------------
--function Insertion1()
--    unrouted, routes = {}, {Route:new()}
--    for i=1,#nodes do unrouted[#unrouted+1] = i end 
--    while #unrouted > 0 do
--        local min = {cost = math.huge, node = 0, route = 0, pos = 0}
--        for i=1,#unrouted do
--            for j=1,#routes do
--                for k=0,#routes[j] do
--                    if feasible:insert() then
--                        local cost = cDelta:insert(j,p,unrouted[i])
--                        if cost < min.cost then
--                            min = {cost = cost, node = i, route = , pos = }
--                        end 
--                    end 
--                end 
--            end 
--        end
--        routes[min.route]:insert(pos, unrouted[min.node])
--        table.remove(unrouted, min.node)
--    end 
--    return routes 
--end 


--local function criteria(cRoute, node, p)
--    local c11,c12 = dis(cRoute[p].id, node) + dis(node, cRoute[p+1].id) - mu * dis(cRoute[p].id, cRoute[p+1].id)
--    local fT = push_forward(cRoute[p], node)
--    if fT<=nodes[node].time2 then 
--        if fT + time(node, cRoute[p+1].id) + nodes[node].stime <= cRoute[p+1].bT then
--            c12 = time(cRoute[p].id, node) + time(node, cRoute[p+1].id) - time(cRoute[p].id, cRoute[p+1].id)
--        end
--    end 
--end 

--function Insertion1(mu)
--    local unrouted = {}
--    for i=1,#nodes do table.insert(unrouted, {i, dis(0,i)}) end 
--    route = Route:new()
--    route:push_back()
--    local node, min, min_c = 0, math.huge
--    for i=1,#unrouted do
--        for j=0,#route do
--            if isFeasibleInsert() then 
--                local c = dis[route[j].id][unrouted[i]] + dis[unrouted[i]][route[j+1].id] - mu * dis[route[j].id][route[j+1].id]
--                if c<min_c then
--                    node, min, min_c = i, j, c
--                end 
--            end 
--        end
--    end 
--end 