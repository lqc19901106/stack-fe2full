# 队列 (Queue)

### 1. 什么是队列？

队列是一种基础的**线性数据结构**，其行为模式遵循**先进先出 (First-In, First-Out, FIFO)** 的原则。可以把它想象成现实生活中的排队队伍：最先到达队伍的人最先获得服务并离开。

在队列中，元素只能从一端添加，这一端称为**队尾 (Rear / Tail)**；而元素只能从另一端移除，这一端称为**队头 (Front / Head)**。

**核心操作**:
*   **入队 (Enqueue)**: 在队尾添加一个新元素。
*   **出队 (Dequeue)**: 从队头移除一个元素。
*   **查看队头元素 (Peek / Front)**: 查看队头的元素，但不移除它。
*   **判空 (isEmpty)**: 检查队列是否为空。
*   **获取大小 (Size)**: 获取队列中元素的数量。

### 2. JavaScript 实现

在 JavaScript 中，队列可以通过多种方式实现，最常见的是使用数组或链表。

#### a. 基于数组的实现

使用数组实现队列非常直观，`push` 方法用于入队，`shift` 方法用于出队。

```javascript
class QueueArray {
    constructor() {
        this.items = [];
    }

    // 入队
    enqueue(element) {
        this.items.push(element);
    }

    // 出队
    dequeue() {
        if (this.isEmpty()) {
            return "Queue is empty";
        }
        return this.items.shift();
    }

    // 查看队头
    front() {
        if (this.isEmpty()) {
            return "Queue is empty";
        }
        return this.items[0];
    }

    // 判空
    isEmpty() {
        return this.items.length === 0;
    }

    // 获取大小
    size() {
        return this.items.length;
    }

    // 打印队列
    print() {
        console.log(this.items.join(' <- '));
    }
}

// 使用示例
const queue1 = new QueueArray();
queue1.enqueue(10);
queue1.enqueue(20);
queue1.enqueue(30);
queue1.print(); // 10 <- 20 <- 30
console.log("Front:", queue1.front()); // 10
console.log("Dequeue:", queue1.dequeue()); // 10
queue1.print(); // 20 <- 30
```
> **性能注意**：基于数组的实现虽然简单，但 `Array.prototype.shift()` 操作的时间复杂度是 O(n)，因为它需要将数组中所有后续元素向前移动一位。对于频繁出队的场景，这可能会导致性能问题。

#### b. 基于链表的实现

为了解决 `shift()` 的性能问题，可以使用链表来实现队列。这样，入队和出队操作的时间复杂度都可以达到 O(1)。

```javascript
// 节点类
class Node {
    constructor(data, next = null) {
        this.data = data;
        this.next = next;
    }
}

class QueueLinkedList {
    constructor() {
        this.head = null; // 队头
        this.tail = null; // 队尾
        this.length = 0;
    }

    // 入队 (O(1))
    enqueue(element) {
        const newNode = new Node(element);
        if (this.isEmpty()) {
            this.head = newNode;
            this.tail = newNode;
        } else {
            this.tail.next = newNode;
            this.tail = newNode;
        }
        this.length++;
    }

    // 出队 (O(1))
    dequeue() {
        if (this.isEmpty()) {
            return "Queue is empty";
        }
        const data = this.head.data;
        this.head = this.head.next;
        // 如果出队后队列为空，需要更新 tail
        if (!this.head) {
            this.tail = null;
        }
        this.length--;
        return data;
    }

    // 查看队头
    front() {
        if (this.isEmpty()) {
            return "Queue is empty";
        }
        return this.head.data;
    }

    // 判空
    isEmpty() {
        return this.length === 0;
    }

    // 获取大小
    size() {
        return this.length;
    }
    
    // 打印队列
    print() {
        let current = this.head;
        const result = [];
        while(current) {
            result.push(current.data);
            current = current.next;
        }
        console.log(result.join(' <- '));
    }
}

// 使用示例
const queue2 = new QueueLinkedList();
queue2.enqueue(10);
queue2.enqueue(20);
queue2.enqueue(30);
queue2.print(); // 10 <- 20 <- 30
console.log("Front:", queue2.front()); // 10
console.log("Dequeue:", queue2.dequeue()); // 10
queue2.print(); // 20 <- 30
```

### 3. 队列的应用

队列的应用非常广泛，主要用于处理需要按顺序处理的任务或数据。

#### 常见应用场景

1.  **任务调度**：操作系统使用队列来管理待执行的进程。CPU 按照队列的顺序为进程分配时间片。
2.  **广度优先搜索 (BFS)**：在图和树的遍历中，BFS 算法使用队列来存储待访问的节点，确保按层级顺序进行遍历。
3.  **消息队列 (Message Queue)**：在分布式系统中，消息队列（如 RabbitMQ, Kafka）是核心组件，用于服务之间的异步通信、解耦和削峰填谷。生产者将消息放入队列，消费者按顺序取出处理。
4.  **打印机任务**：打印机将待打印的文件放入一个队列中，然后按顺序逐个打印。
5.  **网络请求处理**：服务器可以将收到的请求放入队列中，然后由工作线程池按顺序处理，避免因瞬间高并发而崩溃。
6.  **多源 BFS (Multi-source BFS)**：从多个源点同时开始搜索，常用于求解"最短距离"问题。例如在网格中找所有陆地到最近海洋的距离。
7.  **拓扑排序 (Topological Sort)**：使用 Kahn 算法实现拓扑排序，将入度为 0 的节点加入队列，逐步移除节点及其边。
8.  **银行排队系统**：模拟现实中的排队场景，顾客按先来先服务原则处理。

#### 实例：模拟银行排队系统

```javascript
class BankQueue {
    constructor() {
        this.queue = [];
    }

    // 顾客到达
    customerArrives(customerId) {
        this.queue.push(customerId);
        console.log(`顾客 ${customerId} 进入队列，目前队列长度: ${this.queue.length}`);
    }

    // 下一个顾客取号
    serveNext() {
        if (this.queue.length === 0) {
            console.log("队列为空，没有顾客");
            return null;
        }
        const customerId = this.queue.shift();
        console.log(`顾客 ${customerId} 被服务，剩余顾客: ${this.queue.length}`);
        return customerId;
    }

    // 查看队列长度
    getQueueLength() {
        return this.queue.length;
    }
}

// 使用示例
const bank = new BankQueue();
bank.customerArrives(101);
bank.customerArrives(102);
bank.customerArrives(103);
bank.serveNext(); // 顾客 101 被服务
```

### 4. 双端队列 (Deque)

双端队列是一种特殊的队列，可以在两端进行插入和删除操作。它结合了栈和队列的特性。

```javascript
class Deque {
    constructor() {
        this.items = [];
    }

    // 在队尾添加元素
    addRear(element) {
        this.items.push(element);
    }

    // 在队头添加元素
    addFront(element) {
        this.items.unshift(element);
    }

    // 从队尾移除元素
    removeRear() {
        return this.items.pop();
    }

    // 从队头移除元素
    removeFront() {
        return this.items.shift();
    }

    // 查看队头
    front() {
        return this.items[0];
    }

    // 查看队尾
    rear() {
        return this.items[this.items.length - 1];
    }

    isEmpty() {
        return this.items.length === 0;
    }

    size() {
        return this.items.length;
    }

    print() {
        console.log(this.items.join(' <-> '));
    }
}
```

### 5. 经典 LeetCode 题目

#### a. 200. 岛屿数量 (Number of Islands) - Medium
*   **题目链接**: [https://leetcode.cn/problems/number-of-islands/](https://leetcode.cn/problems/number-of-islands/)
*   **解题思路**: 这是使用**广度优先搜索 (BFS)** 的经典题目。遍历整个二维网格，当遇到一个 '1' (陆地) 时，岛屿数量加一，并从这个点开始进行 BFS。BFS 的目的是将与该点相连的所有陆地 ('1') 都标记为已访问（例如，置为 '0'），以防重复计数。队列在 BFS 中用于存储待探索的陆地坐标。
*   **JS 代码**:
    ```javascript
    var numIslands = function(grid) {
        if (!grid || grid.length === 0) return 0;

        const rows = grid.length;
        const cols = grid[0].length;
        let islandCount = 0;

        for (let r = 0; r < rows; r++) {
            for (let c = 0; c < cols; c++) {
                if (grid[r][c] === '1') {
                    islandCount++;
                    // 使用 BFS 将相连的陆地淹没
                    const queue = [[r, c]];
                    grid[r][c] = '0'; // 标记为已访问

                    while (queue.length > 0) {
                        const [row, col] = queue.shift();
                        const directions = [[-1, 0], [1, 0], [0, -1], [0, 1]];

                        for (const [dr, dc] of directions) {
                            const newRow = row + dr;
                            const newCol = col + dc;

                            if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols && grid[newRow][newCol] === '1') {
                                queue.push([newRow, newCol]);
                                grid[newRow][newCol] = '0';
                            }
                        }
                    }
                }
            }
        }
        return islandCount;
    };
    ```

#### b. 225. 用队列实现栈 (Implement Stack using Queues) - Easy
*   **题目链接**: [https://leetcode.cn/problems/implement-stack-using-queues/](https://leetcode.cn/problems/implement-stack-using-queues/)
*   **解题思路**: 栈是后进先出 (LIFO)，队列是先进先出 (FIFO)。可以用一个队列来模拟栈。关键在于 `push` 操作：每次将新元素入队后，将队列中原有的所有元素依次出队再入队。这样，新元素就跑到了队头，实现了后进先出的效果。
*   **JS 代码**:
    ```javascript
    var MyStack = function() {
        this.queue = [];
    };

    MyStack.prototype.push = function(x) {
        this.queue.push(x);
        // 将队列前面的元素全部移到队尾
        let size = this.queue.length;
        while (size > 1) {
            this.queue.push(this.queue.shift());
            size--;
        }
    };

    MyStack.prototype.pop = function() {
        return this.queue.shift();
    };

    MyStack.prototype.top = function() {
        return this.queue[0];
    };

    MyStack.prototype.empty = function() {
        return this.queue.length === 0;
    };
    ```

#### c. 239. 滑动窗口最大值 (Sliding Window Maximum) - Hard
*   **题目链接**: [https://leetcode.cn/problems/sliding-window-maximum/](https://leetcode.cn/problems/sliding-window-maximum/)
*   **解题思路**: 这道题需要使用**双端队列 (Deque)**。双端队列允许在队头和队尾进行添加和删除。
    我们维护一个存储**数组索引**的双端队列，并确保队列中的索引对应的数组值是**单调递减**的。
    1.  遍历数组，对于每个元素 `nums[i]`：
    2.  **移除队尾**：如果队列不为空，且队尾索引对应的 `nums` 值小于 `nums[i]`，则将队尾索引弹出。重复此过程，直到队列为空或队尾值大于等于 `nums[i]`。
    3.  **入队**：将当前索引 `i` 加入队尾。
    4.  **移除队头**：如果队头索引已经超出了当前窗口的范围，则将其从队头弹出。
    5.  **记录结果**：当窗口形成后（即 `i >= k - 1`），队头索引对应的 `nums` 值就是当前窗口的最大值。
*   **JS 代码**:
    ```javascript
    var maxSlidingWindow = function(nums, k) {
        const result = [];
        const deque = []; // 存储索引

        for (let i = 0; i < nums.length; i++) {
            // 移除队尾小于当前值的索引
            while (deque.length > 0 && nums[deque[deque.length - 1]] < nums[i]) {
                deque.pop();
            }
            
            deque.push(i);

            // 移除队头超出窗口范围的索引
            if (deque[0] <= i - k) {
                deque.shift();
            }

            // 当窗口形成后，记录最大值
            if (i >= k - 1) {
                result.push(nums[deque[0]]);
            }
        }
        return result;
    };
    ```

#### d. 542. 01 矩阵 (01 Matrix) - Medium
*   **题目链接**: [https://leetcode.cn/problems/01-matrix/](https://leetcode.cn/problems/01-matrix/)
*   **解题思路**: 这是一个**多源 BFS** 问题。所有 0 都是源点，需要求每个 1 到最近 0 的距离。初始化时，将所有 0 的位置加入队列，然后从这些源点同时开始 BFS，逐层扩展，计算距离。
*   **JS 代码**:
    ```javascript
    var updateMatrix = function(mat) {
        const rows = mat.length;
        const cols = mat[0].length;
        const queue = [];
        const visited = Array(rows).fill(null).map(() => Array(cols).fill(false));

        // 将所有 0 加入队列作为源点
        for (let i = 0; i < rows; i++) {
            for (let j = 0; j < cols; j++) {
                if (mat[i][j] === 0) {
                    queue.push([i, j, 0]); // [行, 列, 距离]
                    visited[i][j] = true;
                }
            }
        }

        const directions = [[-1, 0], [1, 0], [0, -1], [0, 1]];
        
        while (queue.length > 0) {
            const [row, col, dist] = queue.shift();

            for (const [dr, dc] of directions) {
                const newRow = row + dr;
                const newCol = col + dc;

                if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols && !visited[newRow][newCol]) {
                    visited[newRow][newCol] = true;
                    mat[newRow][newCol] = dist + 1;
                    queue.push([newRow, newCol, dist + 1]);
                }
            }
        }
        return mat;
    };
    ```

#### e. 622. 设计循环队列 (Design Circular Queue) - Medium
*   **题目链接**: [https://leetcode.cn/problems/design-circular-queue/](https://leetcode.cn/problems/design-circular-queue/)
*   **解题思路**: 循环队列通过巧妙的取模运算来重用数组空间。维护指向队头和队尾的指针，以及当前元素个数，当数组满员时，新元素会覆盖已出队的位置。
*   **JS 代码**:
    ```javascript
    class MyCircularQueue {
        constructor(k) {
            this.queue = new Array(k);
            this.k = k;
            this.front = 0;
            this.rear = -1;
            this.size = 0;
        }

        enQueue(value) {
            if (this.isFull()) return false;
            this.rear = (this.rear + 1) % this.k;
            this.queue[this.rear] = value;
            this.size++;
            return true;
        }

        deQueue() {
            if (this.isEmpty()) return false;
            this.front = (this.front + 1) % this.k;
            this.size--;
            return true;
        }

        Front() {
            return this.isEmpty() ? -1 : this.queue[this.front];
        }

        Rear() {
            return this.isEmpty() ? -1 : this.queue[this.rear];
        }

        isEmpty() {
            return this.size === 0;
        }

        isFull() {
            return this.size === this.k;
        }
    }
    ```

#### f. 207. 课程表 (Course Schedule) - Medium
*   **题目链接**: [https://leetcode.cn/problems/course-schedule/](https://leetcode.cn/problems/course-schedule/)
*   **解题思路**: 这是一个**拓扑排序**问题。使用 Kahn 算法：
    1. 构建有向图和入度表
    2. 将所有入度为 0 的课程加入队列
    3. 逐个弹出队列中的课程，并减少其后继课程的入度
    4. 当某个后继课程的入度变为 0 时，将其加入队列
    5. 如果所有课程都被访问，则不存在环，可以完成所有课程
    
*   **JS 代码**:
    ```javascript
    var canFinish = function(numCourses, prerequisites) {
        // 构建邻接表和入度数组
        const graph = Array(numCourses).fill(null).map(() => []);
        const inDegree = new Array(numCourses).fill(0);

        for (const [course, prerequisite] of prerequisites) {
            graph[prerequisite].push(course);
            inDegree[course]++;
        }

        // 将所有入度为 0 的课程入队
        const queue = [];
        for (let i = 0; i < numCourses; i++) {
            if (inDegree[i] === 0) {
                queue.push(i);
            }
        }

        let completedCourses = 0;

        // 拓扑排序
        while (queue.length > 0) {
            const course = queue.shift();
            completedCourses++;

            for (const nextCourse of graph[course]) {
                inDegree[nextCourse]--;
                if (inDegree[nextCourse] === 0) {
                    queue.push(nextCourse);
                }
            }
        }

        return completedCourses === numCourses;
    };
    ```

#### g. 1162. 地图分析 (As Far from Land as Possible) - Medium
*   **题目链接**: [https://leetcode.cn/problems/as-far-from-land-as-possible/](https://leetcode.cn/problems/as-far-from-land-as-possible/)
*   **解题思路**: 求所有海洋格子到最近陆地的最大距离，这也是一个**多源 BFS** 问题。将所有陆地 (1) 同时作为源点加入队列，然后逐层扩展，最后遍历一遍矩阵找距离最大的海洋格子。
*   **JS 代码**:
    ```javascript
    var maxDistance = function(grid) {
        const n = grid.length;
        const queue = [];

        // 将所有陆地位置加入队列
        for (let i = 0; i < n; i++) {
            for (let j = 0; j < n; j++) {
                if (grid[i][j] === 1) {
                    queue.push([i, j]);
                }
            }
        }

        // 如果全是陆地或全是海洋，返回 -1
        if (queue.length === 0 || queue.length === n * n) {
            return -1;
        }

        let dist = 0;
        const directions = [[-1, 0], [1, 0], [0, -1], [0, 1]];

        while (queue.length > 0) {
            dist++;
            const size = queue.length;

            for (let i = 0; i < size; i++) {
                const [row, col] = queue.shift();

                for (const [dr, dc] of directions) {
                    const newRow = row + dr;
                    const newCol = col + dc;

                    if (newRow >= 0 && newRow < n && newCol >= 0 && newCol < n && grid[newRow][newCol] === 0) {
                        grid[newRow][newCol] = 1; // 标记为已访问
                        queue.push([newRow, newCol]);
                    }
                }
            }
        }

        return dist - 1;
    };

#### 更多 LeetCode 题目（扩展） ✅

下面补充若干与队列、BFS、双端队列、拓扑排序和优先队列相关的经典题目，均包含题目描述、题目链接、解题思路与 JS 参考实现。

#### a. 994. 腐烂的橘子 (Rotting Oranges) - Medium
* **题目链接**: https://leetcode.cn/problems/rotting-oranges/
* **题目描述**: 给定一个网格，每个单元格值为 0（空）、1（新鲜橘子）、2（腐烂橘子）。每分钟，任何与腐烂橘子相邻的上/下/左/右的新鲜橘子都会变成腐烂。返回使所有橘子都腐烂所需的最小分钟数；如果不可能，返回 -1。
* **解题思路**: 多源 BFS：将所有初始腐烂橘子入队，当做多源点同时扩散，记录时间直至无法再腐烂新鲜橘子。最后检查是否还有新鲜橘子。
* **JS 代码**:
```javascript
var orangesRotting = function(grid) {
    const m = grid.length, n = grid[0].length;
    const q = [];
    let fresh = 0;
    for (let i = 0; i < m; i++) {
        for (let j = 0; j < n; j++) {
            if (grid[i][j] === 2) q.push([i, j]);
            if (grid[i][j] === 1) fresh++;
        }
    }
    if (fresh === 0) return 0;
    let minutes = 0;
    const dirs = [[1,0],[-1,0],[0,1],[0,-1]];
    while (q.length) {
        let sz = q.length;
        let changed = false;
        for (let k = 0; k < sz; k++) {
            const [r,c] = q.shift();
            for (const [dr,dc] of dirs) {
                const nr = r+dr, nc = c+dc;
                if (nr>=0 && nr<m && nc>=0 && nc<n && grid[nr][nc]===1) {
                    grid[nr][nc] = 2;
                    fresh--;
                    changed = true;
                    q.push([nr,nc]);
                }
            }
        }
        if (changed) minutes++;
    }
    return fresh === 0 ? minutes : -1;
};
```

#### b. 127. 单词接龙 (Word Ladder) - Hard
* **题目链接**: https://leetcode.cn/problems/word-ladder/
* **题目描述**: 给定起始单词 beginWord、目标单词 endWord 和单词表 wordList，要求通过每次改变一个字母且生成的单词必须在单词表中，找到从 beginWord 到 endWord 的最短转换序列长度，若不存在返回 0。
* **解题思路**: BFS（单向或双向 BFS 更优）：把单词看成图的节点，边连接仅差一个字母的单词；从 beginWord 开始进行 BFS，遇到 endWord 即可返回转换步数。双向 BFS 常用以降低复杂度。
* **JS 代码（双向 BFS 简化版）**:
```javascript
var ladderLength = function(beginWord, endWord, wordList) {
    const dict = new Set(wordList);
    if (!dict.has(endWord)) return 0;
    let beginSet = new Set([beginWord]), endSet = new Set([endWord]);
    let visited = new Set();
    let steps = 1;
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    while (beginSet.size && endSet.size) {
        if (beginSet.size > endSet.size) [beginSet,endSet] = [endSet,beginSet];
        const next = new Set();
        for (const word of beginSet) {
            for (let i = 0; i < word.length; i++) {
                for (const ch of letters) {
                    if (ch === word[i]) continue;
                    const newWord = word.slice(0,i) + ch + word.slice(i+1);
                    if (endSet.has(newWord)) return steps + 1;
                    if (dict.has(newWord) && !visited.has(newWord)) {
                        visited.add(newWord);
                        next.add(newWord);
                    }
                }
            }
        }
        beginSet = next;
        steps++;
    }
    return 0;
};
```

#### c. 1091. 二进制矩阵中的最短路径 (Shortest Path in Binary Matrix) - Medium
* **题目链接**: https://leetcode.cn/problems/shortest-path-in-binary-matrix/
* **题目描述**: 给定一个二进制矩阵，0 表示可通行，1 表示障碍。从左上角走到右下角，允许向 8 个方向移动，求最短路径长度（包含起点和终点）。不存在则返回 -1。
* **解题思路**: BFS：从 (0,0) 开始层序遍历，记录步数，遇到终点返回即可，注意八个方向的遍历和越界判断。
* **JS 代码**:
```javascript
var shortestPathBinaryMatrix = function(grid) {
    const n = grid.length;
    if (grid[0][0] === 1 || grid[n-1][n-1] === 1) return -1;
    const dirs = [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]];
    const q = [[0,0]];
    grid[0][0] = 1; // reuse grid to store distance
    while (q.length) {
        const [r,c] = q.shift();
        const d = grid[r][c];
        if (r === n-1 && c === n-1) return d;
        for (const [dr,dc] of dirs) {
            const nr = r+dr, nc = c+dc;
            if (nr>=0 && nr<n && nc>=0 && nc<n && grid[nr][nc]===0) {
                grid[nr][nc] = d+1;
                q.push([nr,nc]);
            }
        }
    }
    return -1;
};
```

#### d. 210. 课程表 II (Course Schedule II) - Medium
* **题目链接**: https://leetcode.cn/problems/course-schedule-ii/
* **题目描述**: 给定课程数量和先修课对列表，返回一个可行的修课顺序（拓扑排序），若不存在则返回空数组。
* **解题思路**: Kahn 拓扑排序：构建邻接表与入度数组，将入度为 0 的节点入队，依次出队并减少后继入度，记录顺序；若最终顺序包含所有课程则成功。
* **JS 代码**:
```javascript
var findOrder = function(numCourses, prerequisites) {
    const graph = Array.from({length:numCourses},()=>[]);
    const inDegree = Array(numCourses).fill(0);
    for (const [u,v] of prerequisites) { graph[v].push(u); inDegree[u]++; }
    const q = [];
    for (let i=0;i<numCourses;i++) if (inDegree[i]===0) q.push(i);
    const order = [];
    while (q.length) {
        const node = q.shift(); order.push(node);
        for (const nxt of graph[node]) {
            inDegree[nxt]--;
            if (inDegree[nxt]===0) q.push(nxt);
        }
    }
    return order.length===numCourses ? order : [];
};
```

#### e. 23. 合并 K 个排序链表 (Merge k Sorted Lists) - Hard
* **题目链接**: https://leetcode.cn/problems/merge-k-sorted-lists/
* **题目描述**: 给定 K 个升序链表，将它们合并为一个升序链表并返回。
* **解题思路**: 使用最小堆（优先队列）每次取当前最小节点接到结果链表后将该链表的下一个节点入堆；时间复杂度 O(N log K)，N 为总节点数。
* **JS 代码（使用小顶堆）**:
```javascript
class MinHeap {
    constructor(){ this.data=[]; }
    push(node){ this.data.push(node); this._siftUp(this.data.length-1); }
    pop(){ if(!this.data.length) return null; const top=this.data[0]; const last=this.data.pop(); if(this.data.length){ this.data[0]=last; this._siftDown(0); } return top; }
    _siftUp(i){ while(i>0){ const p=(i-1)>>1; if(this.data[p].val<=this.data[i].val) break; [this.data[p],this.data[i]]=[this.data[i],this.data[p]]; i=p; } }
    _siftDown(i){ const n=this.data.length; while(true){ let l=i*2+1, r=l+1, smallest=i; if(l<n&&this.data[l].val<this.data[smallest].val) smallest=l; if(r<n&&this.data[r].val<this.data[smallest].val) smallest=r; if(smallest===i) break; [this.data[i],this.data[smallest]]=[this.data[smallest],this.data[i]]; i=smallest; } }
}
var mergeKLists = function(lists) {
    const heap = new MinHeap();
    for (const node of lists) if (node) heap.push(node);
    const dummy = new ListNode(0), tail = dummy;
    while (true) {
        const node = heap.pop();
        if (!node) break;
        tail.next = node; tail = tail.next;
        if (node.next) heap.push(node.next);
    }
    return dummy.next;
};
```

#### f. 347. 前 K 个高频元素 (Top K Frequent Elements) - Medium
* **题目链接**: https://leetcode.cn/problems/top-k-frequent-elements/
* **题目描述**: 给定一个整数数组，返回出现频率前 k 高的元素。
* **解题思路**: 常用两种方法：桶排序（O(n)）或最小堆（O(n log k)）。这里给出基于最小堆的写法简要示例。
* **JS 代码（简化）**:
```javascript
var topKFrequent = function(nums, k) {
    const map = new Map();
    for (const x of nums) map.set(x,(map.get(x)||0)+1);
    const heap = [];
    const pushHeap = (val)=>{ heap.push(val); let i=heap.length-1; while(i>0){ const p=(i-1)>>1; if (map.get(heap[p])<=map.get(heap[i])) break; [heap[p],heap[i]]=[heap[i],heap[p]]; i=p; } };
    const popHeap = ()=>{ const top=heap[0]; const last=heap.pop(); if(heap.length){ heap[0]=last; let i=0; while(true){ let l=i*2+1,r=l+1,small=i; if(l<heap.length&&map.get(heap[l])<map.get(heap[small])) small=l; if(r<heap.length&&map.get(heap[r])<map.get(heap[small])) small=r; if(small===i) break; [heap[i],heap[small]]=[heap[small],heap[i]]; i=small; } } return top; };
    for (const key of map.keys()){
        pushHeap(key);
        if (heap.length>k) popHeap();
    }
    return heap;
};
```

#### g. 752. 打开转盘锁 (Open the Lock) - Medium
* **题目链接**: https://leetcode.cn/problems/open-the-lock/
* **题目描述**: 有四个拨轮，每次可以将某一拨轮向上或向下拨动一位（0-9 环绕）。给定起始 "0000"、目标密码和一些死码，求最少拨动次数使锁打开，若无法打开返回 -1。
* **解题思路**: BFS：从 "0000" 开始层序遍历所有下一状态（8 个变化），使用集合记录已访问与死码，遇到目标返回步数。
* **JS 代码**:
```javascript
var openLock = function(deadends, target) {
    const dead = new Set(deadends);
    if (dead.has('0000')) return -1;
    const q = ['0000'];
    const visited = new Set(['0000']);
    let steps = 0;
    while (q.length) {
        let sz = q.length;
        for (let i=0;i<sz;i++){
            const cur = q.shift();
            if (cur === target) return steps;
            for (let j=0;j<4;j++){
                const digit = Number(cur[j]);
                for (const d of [1,-1]){
                    const nd = (digit + d + 10) % 10;
                    const nxt = cur.slice(0,j) + nd + cur.slice(j+1);
                    if (!dead.has(nxt) && !visited.has(nxt)) { visited.add(nxt); q.push(nxt); }
                }
            }
        }
        steps++;
    }
    return -1;
};
```


    ```

### 6. 队列类型对比与选择

| 队列类型 | 实现方式 | 入队复杂度 | 出队复杂度 | 适用场景 |
|---------|--------|---------|---------|--------|
| 数组队列 | 数组 + shift() | O(1) | O(n) | 出队较少的场景 |
| 链表队列 | 链表 + head/tail | O(1) | O(1) | 频繁出入队的场景 |
| 循环队列 | 数组 + 取模 | O(1) | O(1) | 内存受限，需要重用空间 |
| 双端队列 | 数组或链表 | O(1) | O(1) | 需要两端操作，滑动窗口 |
| 优先级队列 | 堆 | O(log n) | O(log n) | 需要按优先级处理任务 |

### 7. 性能优化建议

1. **避免频繁 shift()**：JavaScript 数组的 `shift()` 操作时间复杂度为 O(n)，对于频繁出队的场景，应考虑使用链表或循环队列实现。

2. **循环队列的优势**：在内存有限的场景下，循环队列通过取模运算巧妙地重用数组空间，避免了频繁的内存分配和释放。

3. **多源 BFS 的优化**：在处理多源问题时，一次性将所有源点加入队列，可以避免多次初始化，提高效率。

4. **拓扑排序的应用**：在处理依赖关系问题时，使用 Kahn 算法的队列实现比 DFS 更直观，易于理解和调试。

### 8. 开源项目中的队列应用

队列在众多开源项目中发挥着重要作用，以下是一些著名项目的实际应用案例。

#### a. Koa 框架 - 中间件执行队列

Koa 是一个流行的 Node.js 框架，其核心的中间件系统基于洋葱模型，本质上使用队列来管理中间件的执行顺序。

**源代码参考**：[koa/koa](https://github.com/koajs/koa/blob/master/lib/application.js)

```javascript
// 简化的 Koa 中间件队列执行模式
class KoaApp {
    constructor() {
        this.middlewares = [];
    }

    // 使用队列存储中间件
    use(middleware) {
        this.middlewares.push(middleware);
        return this;
    }

    // 按顺序执行中间件队列
    async execute(ctx) {
        let index = -1;

        const dispatch = async (i) => {
            if (i <= index) return Promise.reject(new Error('next() called multiple times'));
            index = i;

            let fn = this.middlewares[i];
            if (!fn) return;

            try {
                await fn(ctx, () => dispatch(i + 1));
            } catch (err) {
                throw err;
            }
        };

        return dispatch(0);
    }
}

// 使用示例
const app = new KoaApp();
app.use(async (ctx, next) => {
    console.log('1. 进入第一个中间件');
    await next();
    console.log('1. 离开第一个中间件');
});

app.use(async (ctx, next) => {
    console.log('2. 进入第二个中间件');
    await next();
    console.log('2. 离开第二个中间件');
});
```

#### b. Redis - 任务队列与消息队列

Redis 是一个开源的内存数据存储，支持列表（List）数据结构，本质上是一个双向队列，被广泛用于实现消息队列、任务队列等功能。

**常见使用场景**：
- **Bull**（Node.js 任务队列库）基于 Redis 实现
- **Celery**（Python 任务队列）支持 Redis 作为 Broker
- **RabbitMQ** 类似功能但更强大

```javascript
// 使用 Redis 实现任务队列的伪代码
const redis = require('redis');
const client = redis.createClient();

// 生产者：添加任务到队列
async function enqueueTask(taskName, taskData) {
    await client.rpush('task:queue', JSON.stringify({ taskName, taskData }));
}

// 消费者：处理队列中的任务
async function processQueue() {
    while (true) {
        const task = await client.lpop('task:queue');
        if (task) {
            const { taskName, taskData } = JSON.parse(task);
            console.log(`处理任务: ${taskName}`, taskData);
            // 执行任务逻辑
        } else {
            await new Promise(resolve => setTimeout(resolve, 1000)); // 等待
        }
    }
}

// 生产任务
enqueueTask('send_email', { to: 'user@example.com', subject: 'Hello' });
```

#### c. Webpack - 打包处理队列

Webpack 是前端最流行的模块打包器，其编译过程中使用队列来管理待处理的模块和资源。

**核心流程**：
1. 初始化时将入口文件加入编译队列
2. 从队列中取出模块，进行转换和依赖分析
3. 新发现的依赖又加入队列
4. 重复直到队列为空

```javascript
// Webpack 打包过程的简化模型
class WebpackCompiler {
    constructor() {
        this.moduleQueue = [];
        this.modules = new Map();
    }

    // 初始化编译队列
    startCompile(entry) {
        this.moduleQueue.push(entry);
    }

    // 处理编译队列
    process() {
        while (this.moduleQueue.length > 0) {
            const modulePath = this.moduleQueue.shift();

            if (this.modules.has(modulePath)) {
                continue; // 已处理过
            }

            // 加载并转换模块
            const moduleContent = this.loadModule(modulePath);
            const dependencies = this.analyzeDependencies(moduleContent);

            // 将新的依赖加入队列
            for (const dep of dependencies) {
                if (!this.modules.has(dep)) {
                    this.moduleQueue.push(dep);
                }
            }

            this.modules.set(modulePath, { content: moduleContent, deps: dependencies });
        }
    }

    loadModule(path) {
        // 模拟加载模块
        return `// module content of ${path}`;
    }

    analyzeDependencies(content) {
        // 模拟分析依赖
        return [];
    }
}
```

#### d. Node.js 事件循环 - 任务队列

Node.js 的事件循环使用多个队列来管理不同类型的异步任务：
- **微任务队列 (Microtask Queue)**：存储 Promise 回调、`queueMicrotask()` 等
- **宏任务队列 (Macrotask Queue/Task Queue)**：存储 `setTimeout`、`setInterval`、I/O 操作等

```javascript
// 理解 Node.js 事件循环中的队列机制
console.log('1. 同步代码开始');

// 宏任务
setTimeout(() => {
    console.log('2. 宏任务：setTimeout 回调');
}, 0);

// 微任务
Promise.resolve()
    .then(() => {
        console.log('3. 微任务：Promise.then');
    });

console.log('4. 同步代码结束');

// 输出顺序：
// 1. 同步代码开始
// 4. 同步代码结束
// 3. 微任务：Promise.then     (微任务队列先执行)
// 2. 宏任务：setTimeout 回调   (然后执行宏任务队列)
```

#### e. Electron - 事件队列

Electron 框架使用队列来管理主进程和渲染进程之间的事件通信。

**源代码参考**：[electron/electron](https://github.com/electron/electron)

```javascript
// Electron 事件队列的简化模型
class EventQueue {
    constructor() {
        this.queue = [];
    }

    // 发送事件到队列
    emit(event, data) {
        this.queue.push({ event, data, timestamp: Date.now() });
    }

    // 处理队列中的事件
    process(listener) {
        while (this.queue.length > 0) {
            const { event, data } = this.queue.shift();
            listener(event, data);
        }
    }
}

// 使用示例
const eventQueue = new EventQueue();

// 主进程发送事件
eventQueue.emit('window-created', { width: 800, height: 600 });
eventQueue.emit('file-opened', { path: '/tmp/file.txt' });

// 渲染进程处理事件队列
eventQueue.process((event, data) => {
    console.log(`处理事件: ${event}`, data);
});
```

#### f. Express 框架 - 中间件队列

Express 是广泛使用的 Node.js Web 框架，其请求处理管道本质上是一个中间件队列系统。

```javascript
// Express 中间件队列的简化实现
class ExpressApp {
    constructor() {
        this.middlewares = [];
    }

    // 注册中间件到队列
    use(middleware) {
        this.middlewares.push(middleware);
    }

    // 处理请求时按序执行中间件队列
    handleRequest(req, res) {
        let index = 0;

        const next = () => {
            if (index < this.middlewares.length) {
                const middleware = this.middlewares[index++];
                middleware(req, res, next);
            }
        };

        next();
    }
}

// 使用示例
const app = new ExpressApp();

app.use((req, res, next) => {
    console.log('日志中间件');
    next();
});

app.use((req, res, next) => {
    console.log('认证中间件');
    next();
});

app.use((req, res, next) => {
    console.log('业务逻辑中间件');
    res.send('响应完成');
});

app.handleRequest({}, {});
```

#### g. RabbitMQ - 分布式消息队列

RabbitMQ 是一个开源的消息代理软件，实现了 AMQP 协议，广泛用于分布式系统中的异步通信。

**核心概念**：
- **Producer（生产者）**：将消息放入队列
- **Queue（队列）**：存储消息，支持持久化
- **Consumer（消费者）**：按顺序消费队列中的消息
- **Exchange（交换机）**：路由消息到不同的队列

```javascript
// RabbitMQ 消息队列的 Node.js 使用示例（伪代码）
const amqp = require('amqplib');

async function startProducer() {
    const connection = await amqp.connect('amqp://localhost');
    const channel = await connection.createChannel();
    
    // 声明队列
    await channel.assertQueue('tasks', { durable: true });
    
    // 生产者发送消息到队列
    channel.sendToQueue('tasks', Buffer.from(JSON.stringify({
        id: 1,
        name: 'send_email',
        data: { to: 'user@example.com' }
    })), { persistent: true });

    console.log('消息已发送到队列');
}

async function startConsumer() {
    const connection = await amqp.connect('amqp://localhost');
    const channel = await connection.createChannel();
    
    // 声明队列（确保存在）
    await channel.assertQueue('tasks', { durable: true });
    
    // 消费者从队列取消息
    channel.consume('tasks', (msg) => {
        const task = JSON.parse(msg.content.toString());
        console.log('收到任务:', task);
        
        // 处理任务
        // ...
        
        // 确认消息已处理
        channel.ack(msg);
    });
}
```

#### h. Vue.js - 任务调度队列

Vue.js 使用内部的任务队列来管理 DOM 更新和组件生命周期。

```javascript
// Vue.js 任务队列的简化模型
class VueScheduler {
    constructor() {
        this.queue = [];
        this.flushing = false;
    }

    // 将任务加入队列
    queueJob(job) {
        this.queue.push(job);
        this.tryFlush();
    }

    // 处理队列中的所有任务
    tryFlush() {
        if (this.flushing) return;

        this.flushing = true;

        // 使用 Promise 微任务队列来刷新
        Promise.resolve().then(() => {
            while (this.queue.length > 0) {
                const job = this.queue.shift();
                job();
            }
            this.flushing = false;
        });
    }
}

// 使用示例
const scheduler = new VueScheduler();

scheduler.queueJob(() => console.log('更新 DOM'));
scheduler.queueJob(() => console.log('运行监听器'));
scheduler.queueJob(() => console.log('触发生命周期钩子'));
```

### 9. 学习资源与参考

- **官方文档**
  - [Node.js Events](https://nodejs.org/en/docs/guides/nodejs-event-emitter/)
  - [MDN - 事件循环](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Event_loop)

- **开源项目**
  - [Koa 中间件模型](https://github.com/koajs/koa)
  - [Webpack 编译流程](https://github.com/webpack/webpack)
  - [Redis 数据结构](https://github.com/redis/redis)
  - [RabbitMQ 消息队列](https://github.com/rabbitmq/rabbitmq-server)

- **推荐书籍**
  - 《深入浅出 Node.js》- 朴灵
  - 《你不知道的 JavaScript》- Kyle Simpson
  - 《算法导论》- Cormen 等


