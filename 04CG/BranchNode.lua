BranchNode = {}
BranchNode.__index = BranchNode

function BranchNode:new(cRoutes, cForbids, vNumberCons)
    local self = {routes = cRoutes or Constructives.getBackForth(), forbids = cForbids or {}, vNumberCons = vNumberCons}
    setmetatable(self, BranchNode)
    return self
end 

function BranchNode:columnGeneration()
    local iter, master = 0
    repeat
        iter = iter + 1
        master = Master:new(self.routes, self.forbids, self.vNumberCons)
        if master:solve() ~= 0 then return nil end 
        master:setNodesDual()
        self.routes[#self.routes+1], self.routes[#self.routes+2] = master:solveSubproblem()
    until self.routes[#self.routes].cost > -0.1  -- stop early to accelarate
    return master
end

function BranchNode:filter(cRoutes)
    if #self.forbids > 0 then 
        for i=#cRoutes,1,-1 do
            if self.forbids[#self.forbids]:isForbidden(cRoutes[i]) then
                table.remove(cRoutes, i)
            end 
        end 
    end
    return cRoutes
end

function BranchNode:branch(cRoutes)
    BranchNode:new(self:filter(cRoutes), DeepCopy(self.forbids), self.vNumberCons):solve()
end 

function BranchNode:branchVehicleNumber(vNumber, cRoutes)
    print('Branching at vehicle number <= ', math.floor(vNumber))
    self.vNumberCons = {math.floor(vNumber), '<='}
    self:branch(DeepCopy(cRoutes))
                
    print('Branching at vehicle number >=', math.ceil(vNumber))
    self.vNumberCons = {math.ceil(vNumber), '>='}
    self:branch(cRoutes)
end 

function BranchNode:branchArcFlow(arc, cRoutes)
    print('Branching at 0 not arc = {', arc[1], ',', arc[2], '}')
    self.forbids[#self.forbids+1] = (Forbid:new(arc, 0))
    self:branch(DeepCopy(cRoutes))    
    
    print('Branching at 1 arc = {', arc[1], ',', arc[2], '}')
    self.forbids[#self.forbids].ok = 1
    self:branch(cRoutes)
end 

function BranchNode:solve()
    local master = self:columnGeneration() 
    if master then
        print(string.format('The LP relax objective value is %.2f and UpBound = %.2f', master:getObj(), UpBound))
        if master:isInteger() then
            master:updateUpbound()
        elseif UpBound - master:getObj() > 0.0001 then  
            local vehicle_number = master:getVarSum()
            if vehicle_number % 1 > 0.0001 and (1 - vehicle_number % 1) > 0.0001 then 
                master:solve(true)
                master:updateUpbound()
                self:branchVehicleNumber(vehicle_number, master.routes)
            else
                local arc = master:getBranchArc()       
                master:solve(true)
                master:updateUpbound()
                self:branchArcFlow(arc, master.routes)
            end 
        end 
    end
end 