BranchNode = {}
BranchNode.__index = BranchNode

function BranchNode:new(cRoutes, cForbids, vNumberCons)
    local self = {routes = cRoutes or Constructives.getBackForth(), forbids = cForbids or {}, vNumberCons = vNumberCons}
    setmetatable(self, BranchNode)
    return self
end 

function BranchNode:columnGeneration()
    --require 'mobdebug'.off()
    local iter, master = 0
    repeat
        iter = iter + 1
        master = Master:new(self.routes, self.forbids, self.vNumberCons)
        if master:solve() ~= 0 then return nil end 
        master:setNodesDual()
        self.routes[#self.routes+1], self.routes[#self.routes+2] = master:solveSubproblem()
        --print(string.format('the LP relax obj = %02f and The min reduced cost = %02f', master:getObj(),self.routes[#self.routes].cost))
    until self.routes[#self.routes].cost > -0.1
    --print('Total iteration = ', iter)
    --require 'mobdebug'.on()
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

function BranchNode:branching(cRoutes, vNumberCons)
    vNumberCons = vNumberCons or self.vNumberCons    
    BranchNode:new(self:filter(cRoutes), DeepCopy(self.forbids), vNumberCons):solve()
end 

function BranchNode:solve()
    local master = self:columnGeneration() 
    if master then
        print(string.format('The LP relax objective value is %.2f and UpBound = %.2f', master:getObj(), UpBound))
        if master:isInteger() then
            master:updateUpbound()
        elseif master:getObj() - UpBound < -0.0001 then  
            local vehcile_number = master:getVarSum()
            
            if vehcile_number % 1 > 0.0001 and (1 - vehcile_number % 1) > 0.0001 then 
                
                master:solve(true)
                UpBound = master:getObj() < UpBound and master:getObj() or UpBound
                
                print('Branching at vehicle number <= ', math.floor(vehcile_number))
                self:branching(DeepCopy(self.routes), {math.floor(vehcile_number), '<='})
                print('Branching at vehicle number >=', math.ceil(vehcile_number))
                self:branching(self.routes, {math.ceil(vehcile_number) , '>='})
            else
                local arc = master:getBranchArc()       
                master:solve(true)
                master:updateUpbound()
                if arc then    
                    print('Branching at 0 not arc = {', arc[1], ',', arc[2], '}')
                    self.forbids[#self.forbids+1] = (Forbid:new(arc, 0))
                    self:branching(DeepCopy(master.routes))
                    
                    print('Branching at 1 arc = {', arc[1], ',', arc[2], '}')
                    self.forbids[#self.forbids].ok = 1
                    self:branching(master.routes)
                end 
            end 
        end 
    end
end 