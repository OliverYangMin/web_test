Master = {}
Master.__index = Master

local function resetCoeff(cSize, value)
    local coeff = {}
    for i=1,cSize do
        coeff[i] = value or 0
    end 
    return coeff
end 

function Master:new(cRoutes, cForbids,cvNum)
    local self = {obj = {}, routes = cForbids:filter(cRoutes), forbids = cForbids or {}}
    setmetatable(self, Master)
    self.lp = CreateLP()
    self:buildModel()
    if cvNum then AddConstraint(self.lp, resetCoeff(#self.obj, 1), cvNum[2], cvNum[1]) end 
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
        AddConstraint(self.lp, coeff, '=', 1)
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
end 

function Master:getObj()
    return GetObjective(self.lp)
end

function Master:getResult()
    return  {GetVariables(self.lp)}
end 

function Master:getMostFractional()
    if not self.result then self.result = self:getResult() end
    local max, max_value = 1, self.result[1]
    for i=2,#self.result do
        if self.result[i] < 0.99999 and self.result[i] > max_value then
            max, max_value = i, self.result[i]
        end 
    end 
    return max
end
function Master:getBranchArc()   -- return arc {node1, node2}
    local max = self:getMostFractional()
    for i=1,#self.routes do
        if i ~= max and self.result[i] > 0 and self.routes[i]:intersects(self.routes[max]) then 
            return  self.routes[max]:getBranchArc(self.routes[i])
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