--class name: Route
--information: a kind of solution routes data structure for constructive algorithms
--date：2019-04-17
--author: YangMin

Route = {vtp = 1}
Route.__index = Route

function Route:new(vtp)
    local self = {}
    setmetatable(self, Route)
    self.vtp = vtp or 1
    self[0] = {id=0, fT = nodes[0].time1, bT=nodes[0].time2, fW = 0, fV = 0, bW=0, bV=0} 
    --point = {id=2, ptype=2, fW,bW,fV,bV,fT,bT,fY,bY}  a set of label for the node in route, which indicate the information for them, in order to check feasibility of route
    return self
end 

local function forward_mark(route, p)
    for i=p,#route do
        route[i].fT = push_forward(route[i-1], route[i].id)
        route[i].fW = route[i-1].fW + nodes[route[i].id].weight
        route[i].fV = route[i-1].fV + nodes[route[i].id].volume
    end 
end 

local function backward_mark(route, p)
    for i=p,1,-1 do
        local point = route[i+1] or {id=0, bT=nodes[0].time2, bW=0, bV=0}
        route[i].bT = push_backward(point, route[i].id)
        route[i].bW = point.bW + nodes[route[i].id].weight
        route[i].bV = point.bV + nodes[route[i].id].volume
    end
end 

function Route:push_back(node_id)
    local fT, bT, forward
    forward = self[#self]
    fT = push_forward(forward, node_id)
    bT = nodes[node_id].time2
    table.insert(self, {id=node_id, fT=fT, bT=bT, fW=forward.fW + nodes[node_id].weight, fV=forward.fV + nodes[node_id].volume, bW=nodes[node_id].weight, bV=nodes[node_id].volume})
    backward_mark(self, #self-1)
end 


function Route:push_back_seq(seq)
    for i=1,#seq do
        local fT, bT, forward
        forward = self[#self]
        fT = push_forward(forward, seq[i].id)
        table.insert(self, {id=seq[i].id, fT=fT, bT=bT, fW=forward.fW + nodes[seq[i].id].weight, fV=forward.fV + nodes[seq[i].id].volume})
    end
    self[#self].bW = nodes[seq[#seq].id].weight
    self[#self].bV = nodes[seq[#seq].id].volume
    self[#self].bT = nodes[seq[#seq].id].time2
    backward_mark(self, #self-1)
end 


function Route:clone()
    return DeepCopy(self)
end
