Label = {}
Label.__index = Label

function Label:new(seq, sign)
    local self = {weight = 0, volume = 0, time = 0, cost = 0, id = 0}
    self[0] = 0
    for i=1,#seq do self[i] = seq[i] end 
    setmetatable(self, Label)
    if sign then
        self.sign, self.active = {}, true
        for i=1,#nodes do self.sign[i] = 0 end 
    end 
    return self
end 

function Label:extend(node)
    local tag = Label:new({unpack(self)})
    tag[#tag+1], tag.id = node, node
    tag.cost = self.cost + dis(self.id, node) - nodes[node].dual   -- vehicle type 
    tag.time = math.max(self.time + nodes[self.id].stime + time(self.id, node), nodes[node].time1)
    tag.weight, tag.volume = self.weight + nodes[node].weight, self.volume + nodes[node].volume
    if tag.weight <= 200 and tag.volume <= 1 and tag.time <= nodes[node].time2 then 
        tag.sign = {}
        for i=1,#nodes do
            if i == node then 
                tag.sign[i] = 1
            else
                local sign = (tag.weight + nodes[i].weight <= 200 and tag.volume + nodes[i].volume <= 1 and tag.time + nodes[node].stime + time(node, i) <= nodes[i].time2) and 0 or 1
                tag.sign[i] = math.max(self.sign[i], sign)
                if sign == 0 then tag.active = true end 
            end 
        end     
        return tag
    end 
end 

function Label:isDominatedBy(label)
    for i=1,#nodes do
        if self.sign[i] < label.sign[i] then
            return false
        end 
    end 
    return not(self.cost < label.cost or self.weight < label.weight or self.volume < label.volume or self.time < label.time)
end 

function Label:isDominated()
    for i=1,#unprocessed do
        if self.id == unprocessed[i].id and self:isDominatedBy(unprocessed[i]) then
            return true
        end
    end 
    for i=1,#useful do
        if self.id == useful[i].id and self:isDominatedBy(useful[i]) then
            return true
        end
    end 
end 

function Label:to_route()
    local route = Route:new(1, self.cost)
    for i=1,#self do 
        route:push_back(self[i])
    end 
    return route
end 

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
    elseif self.arc[1] == node1 and self.arc[2] ~= node2 then 
        return true
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