# Min_VRP-Solver
A framework of algorithms for VRP with side constraints

1. Constructive Heuristic Algorithms
    1. Solomon`s Nearest insertion
2. Improvement Heuristic Algorithms
    1. SteepestDescent Algorithms
    2. Variable Neighborhoods Search
    3. Large Neighborhood Search
    4. Iterated Local Search
3. Population Heuristic Algorithms
    1. Genetic Algorithm
    2. Memetic Algorithm




# Solution Data Structure
1. multiple routes list
2. giant tour  nodes[0]
    - origin = 0
    - depot = -1,-2,-3   第1，2，3条路径  记录车辆类型   {x,y,id=0,weight=0,volume=0,time1=0,time2=1440,stime=0,route=-1,pre=,suc=}
    - customer = 1,2,3,4,5 {x,y,id=1,weight=,volume=,time1=,time2=,stime=,route=-1, pre=, suc=}

node : 节点的ID
point : 节点的table，包含各种类型== nodes[i] = {x,y,id=i, bT,bW,bV,fT,fW,fV, vtp, route}











[hhahh](https://github.com/OliverYangMin/Min_VRP-Solver/blob/master/README.md)

