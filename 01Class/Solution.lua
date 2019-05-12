--Class Name: Solution
--Meaning: The abstraction of routes result
--Attributes: cost, penaCost, feasible, routes
--Methods: getCost(), isFeasible(), appendRoute(), clone(), sort(), executeMove(),

Solution = {cost = false, pena_cost = false, feasible = true}
Solution.__index = Solution

function Solution:new()
    local self = {}
    setmetatable(self, Solution)
    self.cost = false
    self.pena_cost = false
    self.feasible = true
    return self
end 

local function copyKeyValue(toTab, fromTab)    
    for key,value in pairs(fromTab) do
        toTab[key] = value
    end 
end

function Solution:convert2Giant()
    for r,route in ipairs(self) do
        nodes[-r] = {suc=route[1].id, route=-r, vtp=route.vtp}
        copyKeyValue(nodes[-r], nodes[0])
        copyKeyValue(nodes[-r], route[0])
        
        if #route > 1 then 
            nodes[route[1].id].pre, nodes[route[1].id].suc = -r, route[2].id
            for i=2,#route-1 do nodes[route[i].id].pre, nodes[route[i].id].suc = route[i-1].id, route[i+1].id end 
            nodes[route[#route].id].pre, nodes[route[#route].id].suc = route[#route-1].id, -r - 1
        else
            nodes[route[1].id].pre, nodes[route[1].id].suc = -r, -r - 1
        end 
    
        for i=1,#route do 
            copyKeyValue(nodes[route[i].id], route[i])
            nodes[route[i].id].route, nodes[route[i].id].vtp = -r, route.vtp
        end 
    end 
    nodes[self[#self][#self[#self]].id].suc = -1
    for i=2,#solution do
        nodes[-i].pre = self[i-1][#self[i-1]].id
    end 
    nodes[-1].pre = self[#self][#self[#self]].id
end 

function Solution:appendRoute(route)
    table.insert(self, route)
end 