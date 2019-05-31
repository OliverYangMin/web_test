local function isForbidden(cForbids, node1, node2)
    for _,forbid in ipairs(cForbids) do
        if forbid:isForbidden(node1, node2) then
            return true
        end 
    end 
end 

function solveSubproblem(cForbis)
    unprocessed, useful = {Label:new({}, true)}, {}
    repeat
        local label = unprocessed[#unprocessed]
        useful[#useful+1] = label
        table.remove(unprocessed)
        
        for i=1,#nodes do
            if not isForbidden(cForbis, label.id, i) and label.sign[i] < 1 then
                local new_label = label:extend(i) 
                if new_label and not new_label:isDominated() then 
                    for i=#unprocessed,1,-1 do
                        if new_label.id == unprocessed[i].id and unprocessed[i]:isDominatedBy(new_label) then
                            table.remove(unprocessed, i)
                        end
                    end 
                    if new_label.active then
                        unprocessed[#unprocessed+1] = new_label
                    else
                        useful[#useful+1] = new_label
                    end 
                    
                end 
            end
        end
    until #unprocessed == 0
    
    print('there are ',#useful, ' labels in useful')
    for i=2,#useful do
        useful[i].cost = useful[i].cost + dis(useful[i].id, 0)
    end 
    -- 一次进基多条路径
    table.sort(useful, function(a,b) return a.cost < b.cost end)
    if useful[2].cost < -0.01 then 
        return useful[1]:to_route(), useful[2]:to_route() 
    else
        return useful[1]:to_route()
    end 
end 