# Min_VRP-Solver
**dddd**
A framework of algorithms for VRP with side constraints

我的车辆路径问题求解框架，采用rich VRP的思想，将构造式constructive算法、基于single trajectory的元启发式算法、基于population的元启发算法和精确exact算法整合起来，构建好玩好用的一份work


## Reference
### Heuristics
- Solomon, Marius M . Algorithms for the Vehicle Routing and Scheduling Problems with Time Window Constraints[J]. Operations Research, 1987, 35(2):254-265.
- Vidal T , Crainic T G , Gendreau M , et al. Heuristics for multi-attribute vehicle routing problems: A survey and synthesis[J]. European Journal of Operational Research, 2013, 231(1):1-21.
- Vidal T , Crainic T G , Gendreau M , et al. A hybrid genetic algorithm with adaptive diversity management for a large class of vehicle routing problems with time-windows[J]. Computers & Operations Research, 2013, 40(1):475-489.
- Schneider M , Sand B , Stenger A . A note on the time travel approach for handling time windows in vehicle routing problems[J]. Computers & Operations Research, 2013, 40(10):2564–2568.
- Irnich S , Funke B , Tore Grünert. Sequential search and its application to vehicle-routing problems[J]. Computers & Operations Research, 2006, 33(8):2405-2429.
- Irnich, S. A Unified Modeling and Solution Framework for Vehicle Routing and Local Search-Based Metaheuristics[J]. INFORMS Journal on Computing, 2008, 20(2):270-287.
### Exact
- Desrochers M , Desrosiers J , Solomon M M . A new optimization algorithm for the vehicle routing problem with time windows[M]. INFORMS, 1992.
- Kohl N , Desrosiers J , Madsen O B G , et al. 2-Path Cuts for the Vehicle Routing Problem with Time Windows[J]. Transportation Science, 1999, 33(1):101-116.
- Righini G , Salani M . Symmetry helps: Bounded bi-directional dynamic programming for the elementary shortest path problem with resource constraints[J]. Discrete Optimization, 2006, 3(3):255-273.
## Constructives
1. back_forth
2. NearestNeighbor
3. Solomon Insertion I
4. Clark Wright 
## single-metaheuristics
- Steepest Descent
- Simulated Annealing
- Tabu Search
- Variable Neighbor Search
- ILS
- GLS
- LNS
- ALNS
## population-metaheuristics
- GA
- MA
- PSO
- ACO
- Path Relink

## Exact
- Column Generation
- Branch and Bound
- Branch and Price
- Cut










## 重要分支日志
### Allow Infeasible Solution
- time window penalty TW   time-warp
- weight and volume penalty 
- 






## Variants变种的处理
### Multi-depot
多仓库如何处理，每个客户点除了要分配给一辆车意外，还需要分配给一个仓库
- 增加一个虚拟主仓库，每辆车从虚拟仓库出发，先选择仓库作为第一个点，最后返回仓库
- 虚拟仓库到实际仓库的距离为0

### Open route
开放式VRP，因为有些公司，完成每天任务后，各自回家，所以不需要返回仓库，如何处理
- 将各点到仓库的距离设置为0即可

###VRP with Backhual
考虑回程货的VRP，送完货后，返回仓库的过程中，可以利用空间，再赚点钱
- 先delivery后pickup
- 增加紧前约束
- 存在一个转折点



- b-cyclic, k-transfer
- string cross, string exchange, string relocation, and string mix 











# 工作日志 update log
0610
- work for this project every day before my job
- 



0531
- 修正了wait time evaluation, needed to extends to Vidal WT test
- branch  1.vehicle num 2. arc flow
- the sources of duals:  dual cost should be subtracted   减去
    1. each node has a negative cost as reward for vehicle who visit it 
    2. the fixed cost for vehicle, if <= then positive, else negative, represent the cost for a type of vehicle
    3. if there are more than one type of vehicle, for each type of vehicle have a specific cost 
    4. for some cut, will generate a cost in arc 
0601
- refactor whole program, create class BranchNode to contain branching decision and brancing, column generation get LP opimize result, and solve subproblem to get new route
- solomon benchmarks test:
    1. got best         directly: R101-25, R103-25, R104-25, R105-25, R107-25, R108-25, R109-25,
    2. one vehicle number branch: R102-25
    3. many arc flow branch     : R106-25, R110-25, R111-25, R112-25
0602
- there are 106,108,110,111 and 112 -25 have no result
- arc flow branch is ok, but it needs to many branch nodes

0603
- some trival details

0604
- need to change the weight and volume, fW,fV,bW,bV to be W,V???
- dis --- no need for bidirectly forward 

0607
## Column generation Acceleration strategies
### Preprocessing
1. == narrow the solution space
2. fixing some variables
3. reducing the interval of values a variable can take and so on 
, narrow down time window (eliminate some bad arcs)    (启发式，主动删去一些太远，成本太高的边， 虽然可达，但是很贵），= narrow the solution space
### Subproblem strategies
1. return many negative marginal cost columns to the master problem

0608
1. refactor code
## valid inequality
### k-path inequality: it requirs taht at least k paths enter the set S in any feasible integer solution
    1. define the flow network, with xij > 0
    2. find a customers Set
    3. 




### Master problem strategy
1. generate a set of initial columns by local search,  a good initial solution will accelerate our work
2. 在每一个节点，在得到的整数解上，进行local search
3. keep track of how long a column is part of a basis : deleting columns that have not been part of the basis for the last 20 branch-and-bound nodes 
4. stop the algorithm for the SPPTWCC before it completes
 
 
1. Constructive Heuristic Algorithms
    1. BackAndForth *finished*
    2. Solomon`s Nearest insertion *finished*
    3. Clark Wright *finished*
    4. Insertion I
2. Improvement Heuristic Algorithms
    - *traditional neiborhoods*:size is growing polynomially with n in a controlled manner such that all solutions in the neighborhood can be evaluated by explicit enumeration.
    1. SteepestDescent Algorithm *finished*
    2. SimulateAnnealing Algorithm
    3. Variable Neighborhoods Search
    4. Tabu Search
    5. Iterated Local Search
    - *large neighborhoods*: size is growing exponentially with n that cannot be searched explicitly
    6. Large Neighborhood Search
3. Population Heuristic Algorithms
    1. Genetic Algorithm
    2. Memetic Algorithm
4. Exact Algorithms
    1. column generation
    2. BranchAndPrice
    3. BranchAndCutAndPrice
    
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

### Local search Speedup Techniques
- *filtering* : considering only moves that connect nearby customers; time-window considerations
- *sequential search*



