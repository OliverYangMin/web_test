Delta = {}
Delta.__index = Delta


function Delta:new()
    local self = {}
    setmetatable(self, Delta)
    return self
end 

--function Delta:penaltyCost()
--    local cPoint, cost = nodes[-1], 0 
--    repeat 
--        distance = distance + dis(cPoint.pre, cPoint.id)
--        cost = cost + dis(cPoint.pre, cPoint.id) * vehicle[cPoint.vtp].tc + math.max(0, cPoint.time1 - cPoint.bT) * vehicle[cPoint.vtp].wc
--        if cPoint.pre < 0 and cPoint.id > 0 then cost = cost + vehicle[cPoint.vtp].fc end 
--        cPoint = nodes[cPoint.pre]
--    until nodes[cPoint.pre].suc == -1 
--    return cost
--end 
--  ddsd  --- ds d 



function Delta:freeNodeCost(node)
    local cost =  dis(nodes[node].pre, nodes[node].suc)  * vehicle[nodes[node].vtp].tc + self:removeNodeCost(node)
    if nodes[node].pre < 0 and nodes[node].suc < 0 then 
        return cost - vehicle[nodes[node].vtp].fc
    end 
    return cost 
end 

function Delta:removeNodeCost(node)
    return - dis(nodes[node].pre, node) - dis(node, nodes[node].suc) * vehicle[nodes[node].vtp].tc
end 

function Delta:replaceCost(node1, node2)
    return (dis(nodes[node1].pre, node2) + dis(node2, nodes[node1].suc)) * vehicle[nodes[node1].vtp].tc + self:removeNodeCost(node1)
end 

function Delta:swapNodeCost(node1, node2)
    return self:replaceCost(node1, node2) + self:replaceCost(node2, node1)
end 

function Delta:insertNodeCost(node, pos)
    return (dis(pos, node) + dis(node, nodes[pos].suc) - dis(pos, nodes[pos].suc)) * vehicle[nodes[pos].vtp].tc
end 

function Delta:penalty_insertNodeCost(node, pos)
    --nodes[pos].fW + nodes[node].weight + nodes[nodes[pos].suc].bW - vehicle[]
    return (dis(pos, node) + dis(node, nodes[pos].suc) - dis(pos, nodes[pos].suc)) * vehicle[nodes[pos].vtp].tc
end



