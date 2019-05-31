# Min_VRP-Solver
**A framework of algorithms for VRP with side constraints**

# 工作日志 update log
0531
- 修正了wait time evaluation, needed to extends to Vidal WT test
- branch  1.vehicle num 2. arc flow


1. Constructive Heuristic Algorithms
    1. BackAndForth
    2. Solomon`s Nearest insertion
    3. Clark Wright
    4. Insertion I
2. Improvement Heuristic Algorithms
    1. SteepestDescent Algorithm
    2. SimulateAnnealing Algorithm
    3. Variable Neighborhoods Search
    4. Tabu Search
    5. Iterated Local Search
    6. Large Neighborhood Search
3. Population Heuristic Algorithms
    1. Genetic Algorithm
    2. Memetic Algorithm
4. Exact Algorithms
    1. column generation
    2. BranchAndBound
    
# Solution Data Structure
1. Solution: multiple routes list
2. Giant: giant tour  nodes 
    - origin = 0
    - depot = -1,-2,-3   第1，2，3条路径  记录车辆类型   {x, y, id = 0, weight = 0, volume = 0, time1 = 0, time2 = 1440, stime = 0, route = -1, pre = , suc =} 
    - customer = 1,2,3,4,5 {x, y, id=1, weight=, volume=, time1=, time2=, stime=, route=-1, pre=, suc=}  --ptp = 2   
3. Route:

# Functional Class
1. Feasible: feasible
2. Delta: cDelta
3. 



node : 节点的ID
point : 节点的table，包含各种类型== nodes[i] = {x,y,id=i, bT,bW,bV,fT,fW,fV, vtp, route}

# Operators 算子部分
## Move: move
1. node_relocate
2. node_swap
3. 2-opt
4. 2-opt*
5. Or-opt
6. 
增加算子  对等待时间的影响，使用Vidal的方法改正，按照京东时的方案和方法





# 系统 framework 设计
明确  Input\Output





