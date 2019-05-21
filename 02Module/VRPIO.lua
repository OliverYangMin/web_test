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
    local inputf = assert(io.open('00Data/Solomon/' .. size .. '/' .. filename .. '.txt', 'r'))
    local nodes, Dis, Time, vehicle = {}, {}, {}, {{volume=0;fc=0,tc=1,wc=0}}
    
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
    end
    inputf:close()
    for i=0,#nodes do
        Dis[i], Time[i] = {}, {}
        for j=0,#nodes do
            Dis[i][j] = i == j and false or math.floor( math.sqrt( (nodes[i].x - nodes[j].x)^2 + (nodes[i].y - nodes[j].y)^2 ) * 100 + 0.5) * 0.01
            Time[i][j] = Dis[i][j]
        end
    end 
    return nodes, Dis, Time, vehicle
end 
