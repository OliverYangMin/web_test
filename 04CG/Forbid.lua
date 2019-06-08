Forbid = {}
Forbid.__index = Forbid

function Forbid:new(arc, ok)
    local self = {arc = arc, ok = ok}
    setmetatable(self, Forbid)
    return self
end 
-- 1. 用来将已经产生的路径集中不可行的路径过滤掉
-- 2. 阻止标签扩展到不可行的node上
function Forbid:isForbidden(cRoute)
    if self.ok == 0 then 
        for i=0,#cRoute-1 do
            if cRoute[i].id == self.arc[1] then 
                if cRoute[i+1].id == self.arc[2] then 
                    return true
                end 
                break
            end      
            if cRoute[1].id == self.arc[2] then
                break
            end 
        end     
    else
        for i=0,#cRoute do
            if cRoute[i].id == self.arc[1] then 
                return not (cRoute[i+1] and cRoute[i+1].id == self.arc[2])
            end
        end 

        for i=1,#cRoute do
            if cRoute[i].id == self.arc[2] then
                return true           
            end 
        end 
    end     
end

function Forbid:forbid(cLabel)
    if self.ok == 0 then
        if cLabel.id == self.arc[1] then
            cLabel.sign[self.arc[2]] = 1
        end 
    else
        if cLabel.id == self.arc[1] then
            for i=1,#nodes do
                if i ~= self.arc[2] then
                    cLabel.sign[i] = 1 
                end 
            end 
        else
            cLabel.sign[self.arc[2]] = 1
        end  
    end 
end 