Master = {}
Master.__index = Master

local function resetCoeff(cSize, value)
    local coeff = {}
    for i=1,cSize do
        coeff[i] = value or 0
    end 
    return coeff
end 

function Master:new(cRoutes, cForbids, cvNum)
    local self = {obj = {}, routes = cRoutes, forbids = cForbids or {}, num = cvNum, carDual = 0}
    setmetatable(self, Master)
    self.lp = CreateLP()
    self:buildModel()
    if self.num then AddConstraint(self.lp, resetCoeff(#self.obj, 1), cvNum[2], cvNum[1]) end 
    return self
end 

function Master:setVehNum(compare, num)
    AddConstraint(self.lp, resetCoeff(#self.obj, 1), compare, num)
end 

function Master:buildModel()
    for i=1,#self.routes do
        self.obj[i] = self.routes[i]:getCost()
    end 
    SetObjFunction(self.lp, self.obj, 'min')
    
    for i=1,#nodes do
        local coeff = resetCoeff(#self.obj)
        for r,route in ipairs(self.routes) do
            if route:contains(i) then 
                coeff[r] = 1
            end 
        end
        AddConstraint(self.lp, coeff, '>=', 1)
    end
    
    for i=1,#nodes do
        local coeff = resetCoeff(#self.obj)
        coeff[i] = 1
        AddConstraint(self.lp, coeff, '<=',1)
    end
end 

function Master:solve(isInteger)
    if isInteger then
        for i=1,#self.obj do
            SetBinary(self.lp, i)
        end 
    end 
    return SolveLP(self.lp)
end 

function Master:getDuals()
    return {GetDuals(self.lp)}
end 

function Master:setNodesDual()
    local duals = self:getDuals()
    for i=1,#nodes do
        nodes[i].dual = duals[i]
    end 
    if #duals > #nodes then
        self.carDual = duals[#duals] 
    end 
end 

function Master:getObj()
    return GetObjective(self.lp)
end

function Master:getResult()
    return  {GetVariables(self.lp)}
end 

function Master:getMostFractional()
    if not self.result then self.result = self:getResult() end
    local choice = {}
    for i=1,#self.result do
        if self.result[i] < 0.99999 and self.result[i] > 0.0001 then
            table.insert(choice, {math.abs(0.5 - self.result[i]), id = i})
        end 
    end 
    table.sort(choice, function(a,b) return a[1] < b[1] end)
    return choice
end

function Master:getBranchArc()   -- return arc {node1, node2}
    local choice = self:getMostFractional()
    for i=1,#choice do
        for j=i+1,#choice do
            if self.routes[choice[j].id]:intersects(self.routes[choice[i].id]) then 
                local arc = self.routes[choice[i].id]:getBranchArc(self.routes[choice[j].id], self.forbids)
                if arc then return arc end 
            end 
        end
    end 
end 

function Master:isInteger()
    local result = self:getResult() 
    for i=1,#result do
        if result[i] % 1 > 0.0001 and (1 - result[i] % 1) > 0.0001 then 
            return false
        end 
    end 
    return true
end 

function Master:getVarSum()
    local sum = 0
    for v,var in ipairs(self:getResult()) do
        sum = sum + var
    end 
    return sum 
end 

function Master:to_solution()
    local solu = Solution:new()
    for i, ir in ipairs{GetVariables(self.lp)} do
        if ir > 0.001 then
            solu:append(self.routes[i])
        end 
    end 
    return solu
end 

function Master:solveSubproblem() 
    unprocessed, useful = {Label:new({}, true)}, {}
    repeat
        local label = unprocessed[#unprocessed]
        useful[#useful+1] = label
        table.remove(unprocessed)
        
        for _,forbid in ipairs(self.forbids) do
            forbid:forbid(label) 
        end 
        
        for i=1,#nodes do
            if label.sign[i] < 1 then
                local new_label = label:extend(i) 
                if new_label and not new_label:isDominated() then 
                    for i=#unprocessed,1,-1 do --使用hashmap
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
            ::continue::
        end
    until #unprocessed == 0    
    --local negative_routes = {}
    for i=#useful,1,-1 do 
        useful[i].cost = useful[i].cost + dis(useful[i].id, 0) - self.carDual
--        if useful[i].cost >= 0 then
--            table.remove(useful, i)
--            --negative_routes[#negative_routes+1] = useful[i]:to_route
--        end 
    end 
    
    table.sort(useful, function(a,b) return a.cost < b.cost end)
--    if useful[2] then 
--        return useful[1]:to_route(), useful[2]:to_route() 
--    elseif useful[1] then
--        return useful[1]:to_route()
--    end
    
    if useful[2].cost < -0.0001 then 
        return useful[1]:to_route(), useful[2]:to_route() 
    else
        return useful[1]:to_route()
    end
    
    --return negative_routes
end 

function Master:updateUpbound()
    if self:getObj() < UpBound then 
        UpBound = self:getObj() 
        BestVehicles = self:getVarSum()
        solution = self:to_solution()
    end 
end 