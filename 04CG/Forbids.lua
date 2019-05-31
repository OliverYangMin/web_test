Forbid = {}
Forbid.__index = Forbid

function Forbid:new(arc, ok)
    local self = {arc = arc, ok = ok}
    setmetatable(self, Forbid)
    return self
end 

function Forbid:isForbidden(node1, node2)
    if self.ok == 0 then 
        if self.arc[1] == node1 and self.arc[2] == node2 then 
            return true
        end 
    else
        return self.arc[1] == node1 and self.arc[2] ~= node2 
    end
end 

function Forbid:routeForbidden(route)
    if self.ok == 0 then 
        for i=0,#route do
            if route[i].id == self.arc[1] and routes[i+1].id == self.arc[2] then
                return true
            end 
        end 
    elseif self.ok == 1 then
        for i=1,#route do
            if route[i].id == self.arc[1] then
                for j=1,#route do
                    if route[j].id == self.arc[2] then
                        if j == i + 1 then
                            return true
                        else
                            return false
                        end 
                    end 
                end 
            end 
        end 
    end 
end

Forbids = {}
Forbids.__index = Forbids
function Forbids:new()
    local self = {}
    setmetatable(self, Forbids)
    return self
end 

function Forbids:append(cForbid)
    self[#self+1] = cForbid
end 

function Forbids:filter(cRoutes)
    if self[1] then 
        for i=#cRoutes,1,-1 do
            for _,forbid in ipairs(self) do
                if forbid:routeForbidden(cRoutes[i]) then
                    table.remove(cRoutes, i)
                end 
            end 
        end
    end 
    return cRoutes
end