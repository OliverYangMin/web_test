Tabu = {}
Tabu.__index = Tabu

function Tabu:new(node, route)
    local self = {node = node, route = route, iter = 20}
    setmetatable(self, Tabu)
    return self
end 

function Tabu:isForbidden(node, route)
    return self.node == node and self.route == route
end 