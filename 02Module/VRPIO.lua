-- name: VRPIO
-- purpose: Open VRP instance files and processing the data
-- start date: 2019-04-19
-- update log: 
-- 20190419-create the module      
-- authors: YangMin
module(..., package.seeall)

function read_csv(filename, ifhead)
    local inputdata = io.input('00Data/' .. filename .. '.csv')
	local matrix = {}	
	local i = 1
	for line in inputdata:lines() do
		if ifhead  then
			matrix[i] = {}
			for element in string.gmatch(line, "[0-9%.]+") do
				table.insert(matrix[i], tonumber(string.match(element,'[0-9%.]+')))
			end
			i = i + 1
		else
			ifhead = 0
		end
	end
	return matrix
end 

function read_txt(filename, ifhead)
    local inputdata = io.input('00Data/' .. filename .. '.txt')
	local matrix = {}	
	local i = 1
	for line in inputdata:lines() do
		if ifhead  then
			matrix[i] = {}
			for element in string.gmatch(line, "[0-9%.]+") do
				table.insert(matrix[i], tonumber(string.match(element,'[0-9%.]+')))
			end
			i = i + 1
		else
			ifhead = 0
		end
	end
	return matrix
end 


function read_solomon(filename, size)
    local inputf = assert(io.open('00Data/Solomon/' .. filename .. '.txt', 'r'))
    local nodes, Dis, Time, vehicle = Giant:new(), {}, {}, {{volume = 1;fc = 0,tc = 1,wc = 0}}
    
    local i = 1
    for line in inputf:lines() do
        if i > 9 then 
            local node = {}
            for element in string.gmatch(line, "[0-9%.]+") do
                node[#node+1] = tonumber(string.match(element,'[0-9%.]+'))
            end
            if node[1] then nodes[node[1]] = Node:new(unpack(node)) end 
        end 
        if not vehicle[1].weight and i==5 then
            vehicle[1].weight = tonumber(string.match(line, "[0-9%.]+$"))
        end
        i = i + 1
        if #nodes == size then break end 
    end
    inputf:close()
    for i=0,#nodes do
        Dis[i] = {}
        for j=0,#nodes do
            local x = math.sqrt((nodes[i].x - nodes[j].x)^2 + (nodes[i].y - nodes[j].y)^2 )
            Dis[i][j] = i == j and false or x - x % 0.01
        end
        Time[i] = Dis[i]
    end 
    return nodes, Dis, Time, vehicle
end 

--function read_vrp(filename)
--    local inputf = assert(io.open(filename, 'r'))
--    local nodes, Dis, Time, vehicle = Giant:new(), {}, {}, {{volume = 1;fc = 0,tc = 1,wc = 0}}
--    local i,dimension = 1, 0 
--    for line in inputf:lines() do
--        if i == 6 then
--            vehicle.weight = tonumber(string.match(line, "[0-9%.]+$"))
--        elseif i == 4 then
--            dimension = tonumber(string.match(line, "[0-9%.]+$"))
--        elseif i > 7 then 
--            local node = {}
--            for element in string.gmatch(line, "[0-9%.]+") do
--                node[#node+1] = tonumber(string.match(element,'[0-9%.]+'))
--            end
--            if #node == 3 then 
--                nodes[node[1]-1] = Node:new(unpack(node)) end 
--            elseif #node == 2 then
--                nodes[node[1]-1].weight = node[2]
--            end
--        end 
--    end 
--    inputf:close()
    
--    for i=1,#nodes do
--        Dis[i] = {}
--        for j=1,#nodes do
--            local x = math.sqrt((nodes[i].x - nodes[j].x)^2 + (nodes[i].y - nodes[j].y)^2 )
--            Dis[i][j] = i == j and false or x - x % 0.01
--        end 
--        Time[i] = Dis[i]
--    end 
--    return nodes, Dis, Time, vehicle
--end 


function read_vrp(filename)
    local inputf = assert(io.open(filename, 'r'))
    local ins = {nodes={}}
    local i = 1
    for line in inputf:lines() do
        if not ins.opt then
            local opt = {}
            opt.trucks = tonumber(string.match(line, "Min no of trucks: (%d+)"))
            opt.val = tonumber(string.match(line, "Optimal value: (%d+)"))
            if opt.trucks and opt.val then
                ins.opt = opt
            end 
        end
        if not ins.cap then
            ins.cap = tonumber(string.match(line, "CAPACITY : (%d+)"))
        end
        
        if not ins.nodes[i] then
            local node = {}
            node.x = tonumber(string.match(line, i .. " (%d+) %d+"))
            node.y = tonumber(string.match(line, i .. " %d+ (%d+)"))
            if node.x and node.y then
                ins.nodes[i] = node
                i = i + 1
            end
        elseif not ins.nodes[i].d then
            ins.nodes[i].d = tonumber(string.match(line, "^" .. i .. " (%d+) "))
            i = i + 1
        end
        if string.match(line, "DEMAND_SECTION") then
            i = 1
        end 
    end 
    inputf:close()
    
    local dis = {}
    for i=1,#ins.nodes do
        dis[i] = {}
        for j=1,#ins.nodes do
            dis[i][j] = i==j and false or math.floor(math.sqrt((ins.nodes[i].x - ins.nodes[j].x)^2 + (ins.nodes[i].y - ins.nodes[j].y)^2)+0.5)
        end 
    end 
    return ins, dis
end 
