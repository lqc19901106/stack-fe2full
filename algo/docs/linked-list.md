# 链表 (Linked List)

### 1. 什么是链表？

链表是一种基础且重要的**线性数据结构**。与数组不同，链表的元素在内存中不是连续存储的。相反，每个元素都是一个独立的对象，称为**节点 (Node)**。

每个节点包含两部分信息：
1.  **数据 (Data)**：节点存储的实际值。
2.  **指针 (Pointer / Next)**：指向下一个节点的引用（内存地址）。

链表的第一个节点被称为**头节点 (Head)**，最后一个节点的指针通常指向 `null`，表示链表的结束。

![Singly Linked List](https://upload.wikimedia.org/wikipedia/commons/6/6d/Singly-linked-list.svg)

#### 链表 vs. 数组

| 特性 | 数组 (Array) | 链表 (Linked List) |
|---|---|---|
| **内存存储** | 连续的内存空间 | 离散、分散的内存空间 |
| **大小** | 固定大小（静态数组）或动态调整（但可能涉及昂贵的复制操作） | 动态大小，可轻松增长或缩小 |
| **访问元素** | O(1) - 通过索引直接访问 | O(n) - 需要从头节点开始遍历 |
| **插入/删除 (开头)** | O(n) - 需要移动后续所有元素 | O(1) - 只需修改头指针 |
| **插入/删除 (中间)** | O(n) - 需要移动后续元素 | O(n) - O(n)查找 + O(1)插入/删除 |
| **插入/删除 (末尾)** | O(1) (如果容量足够) | O(n) (单向链表) 或 O(1) (如果维护尾指针) |

### 2. 链表的类型

1.  **单向链表 (Singly Linked List)**：最简单的链表，每个节点只有一个指向下一个节点的指针。只能单向遍历。
2.  **双向链表 (Doubly Linked List)**：每个节点有两个指针，一个指向**下一个节点 (`next`)**，一个指向**前一个节点 (`prev`)**。这使得链表可以双向遍历，方便了某些操作（如在给定节点前插入），但代价是需要额外的内存空间来存储 `prev` 指针。
3.  **循环链表 (Circular Linked List)**：最后一个节点的 `next` 指针不是指向 `null`，而是指向**头节点**，形成一个环。

### 3. JavaScript 实现 (单向链表)

首先，我们定义 `Node` 类，然后是 `LinkedList` 类。

```javascript
// 节点类
class Node {
    constructor(data, next = null) {
        this.data = data;
        this.next = next;
    }
}

// 链表类
class LinkedList {
    constructor() {
        this.head = null;
        this.size = 0;
    }

    // 1. 在链表头部插入节点
    insertAtHead(data) {
        this.head = new Node(data, this.head);
        this.size++;
    }

    // 2. 在链表尾部插入节点
    insertAtEnd(data) {
        const node = new Node(data);
        if (!this.head) {
            this.head = node;
        } else {
            let current = this.head;
            while (current.next) {
                current = current.next;
            }
            current.next = node;
        }
        this.size++;
    }

    // 3. 在指定索引处插入节点
    insertAt(data, index) {
        if (index < 0 || index > this.size) {
            return; // 索引越界
        }
        if (index === 0) {
            this.insertAtHead(data);
            return;
        }

        const node = new Node(data);
        let current = this.head;
        let previous;
        let count = 0;

        while (count < index) {
            previous = current;
            current = current.next;
            count++;
        }

        node.next = current;
        previous.next = node;
        this.size++;
    }

    // 4. 获取指定索引处的节点
    getAt(index) {
        if (index < 0 || index >= this.size) {
            return null;
        }
        let current = this.head;
        let count = 0;
        while (count < index) {
            current = current.next;
            count++;
        }
        return current.data;
    }

    // 5. 删除指定索引处的节点
    deleteAt(index) {
        if (index < 0 || index >= this.size) {
            return null;
        }
        let current = this.head;
        let previous;
        let count = 0;

        if (index === 0) {
            this.head = current.next;
        } else {
            while (count < index) {
                previous = current;
                current = current.next;
                count++;
            }
            previous.next = current.next;
        }
        this.size--;
        return current.data;
    }
    
    // 6. 清空链表
    clearList() {
        this.head = null;
        this.size = 0;
    }

    // 7. 打印链表数据
    printListData() {
        let current = this.head;
        const result = [];
        while (current) {
            result.push(current.data);
            current = current.next;
        }
        console.log(result.join(' -> '));
    }
}

// 使用示例
const ll = new LinkedList();
ll.insertAtHead(100);
ll.insertAtHead(200);
ll.insertAtEnd(300);
ll.insertAt(50, 1); // 在索引1处插入50

ll.printListData(); // 输出: 200 -> 50 -> 100 -> 300

console.log("Node at index 2:", ll.getAt(2)); // 100

ll.deleteAt(2);
ll.printListData(); // 输出: 200 -> 50 -> 300
```

### 4. 链表的应用

*   **实现其他数据结构**：栈和队列都可以用链表高效实现。
*   **浏览器历史记录**：浏览器的“前进”和“后退”功能通常用双向链表实现。
*   **音乐播放器**：歌曲列表可以用双向链表实现，方便切换上一首和下一首。
*   **操作系统的任务调度**：操作系统使用链表来管理处于不同状态（如运行、等待）的进程。
*   **内存管理**：操作系统的内存管理器使用链表来记录空闲和已分配的内存块。
#### 4.1 应用示例详解

下面为上述 5 个应用场景各补充一个代码实现示例，展示链表的实际应用。

##### A. 用链表实现栈 (Stack)
```javascript
class StackByLinkedList {
    constructor() {
        this.head = null; // 栈顶在链表头部
        this.size = 0;
    }

    // 入栈：在头部插入
    push(data) {
        this.head = new Node(data, this.head);
        this.size++;
    }

    // 出栈：从头部删除
    pop() {
        if (!this.head) return null;
        const data = this.head.data;
        this.head = this.head.next;
        this.size--;
        return data;
    }

    // 查看栈顶元素
    peek() {
        return this.head ? this.head.data : null;
    }

    // 判断栈是否为空
    isEmpty() {
        return this.size === 0;
    }
}

// 使用示例：验证括号匹配
const stack = new StackByLinkedList();
stack.push('(');
stack.push('{');
console.log(stack.pop()); // {
console.log(stack.peek()); // (
```

##### B. 浏览器历史记录 (使用双向链表)
```javascript
class BrowserHistory {
    constructor(homepage) {
        // 初始化当前页面为首页
        this.current = new Node(homepage);
        this.forward = null; // 前进栈（此处简化为单个链表）
    }

    // 访问新页面
    visit(url) {
        // 访问新页面时，前进栈清空
        this.forward = null;
        const newNode = new Node(url);
        newNode.prev = this.current;
        this.current.next = newNode;
        this.current = newNode;
    }

    // 后退：回到上一个页面
    back(steps) {
        while (steps > 0 && this.current.prev) {
            // 保存当前页面用于前进
            this.forward = this.current;
            this.current = this.current.prev;
            steps--;
        }
        return this.current.data;
    }

    // 前进：返回下一个页面
    forward(steps) {
        while (steps > 0 && this.current.next) {
            this.current = this.current.next;
            steps--;
        }
        return this.current.data;
    }
}

// 使用示例
const history = new BrowserHistory('google.com');
history.visit('github.com');
history.visit('leetcode.com');
console.log(history.back(1)); // github.com
console.log(history.forward(1)); // leetcode.com
```

##### C. 音乐播放器 (双向链表)
```javascript
class MusicPlayer {
    constructor() {
        this.current = null; // 当前播放的歌曲
        this.size = 0;
    }

    // 添加歌曲到播放列表
    addSong(songName) {
        const newSong = new Node(songName);
        if (!this.current) {
            this.current = newSong;
            newSong.next = newSong; // 循环链表
            newSong.prev = newSong;
        } else {
            const head = this.current;
            const last = head.prev;
            last.next = newSong;
            newSong.prev = last;
            newSong.next = head;
            head.prev = newSong;
        }
        this.size++;
    }

    // 下一首
    next() {
        if (this.current) {
            this.current = this.current.next;
        }
        return this.current ? this.current.data : null;
    }

    // 上一首
    prev() {
        if (this.current) {
            this.current = this.current.prev;
        }
        return this.current ? this.current.data : null;
    }

    // 获取当前播放歌曲
    currentSong() {
        return this.current ? this.current.data : null;
    }
}

// 使用示例
const player = new MusicPlayer();
player.addSong('Song A');
player.addSong('Song B');
player.addSong('Song C');
console.log(player.currentSong()); // Song A
console.log(player.next()); // Song B
console.log(player.prev()); // Song A
```

##### D. 操作系统进程调度队列
```javascript
class ProcessScheduler {
    constructor() {
        this.head = null; // 队列头（优先执行）
        this.tail = null; // 队列尾（新进程加入处）
        this.size = 0;
    }

    // 创建新进程并加入就绪队列
    createProcess(processId, priority) {
        const process = new Node({ id: processId, priority, status: 'ready' });
        
        if (!this.head) {
            this.head = this.tail = process;
        } else {
            this.tail.next = process;
            this.tail = process;
        }
        this.size++;
    }

    // 执行当前进程（从头部取出）
    executeProcess() {
        if (!this.head) return null;
        const process = this.head.data;
        process.status = 'running';
        this.head = this.head.next;
        this.size--;
        return process;
    }

    // 进程完成后移除
    completeProcess(process) {
        process.status = 'completed';
        console.log(`Process ${process.id} completed`);
    }

    // 获取就绪队列中的进程数
    getQueueSize() {
        return this.size;
    }
}

// 使用示例
const scheduler = new ProcessScheduler();
scheduler.createProcess(1, 1);
scheduler.createProcess(2, 1);
const p1 = scheduler.executeProcess();
console.log(p1); // { id: 1, priority: 1, status: 'running' }
scheduler.completeProcess(p1);
```

##### E. 内存管理 (空闲/已分配内存块)
```javascript
class MemoryManager {
    constructor(totalMemory) {
        // 初始化一个大的空闲内存块
        this.memoryBlocks = new Node({ 
            start: 0, 
            end: totalMemory, 
            isFree: true 
        });
        this.totalMemory = totalMemory;
    }

    // 分配内存
    allocate(size) {
        let current = this.memoryBlocks;
        let allocated = null;

        while (current) {
            // 找到第一个足够大的空闲块
            if (current.data.isFree && (current.data.end - current.data.start) >= size) {
                allocated = {
                    start: current.data.start,
                    end: current.data.start + size,
                    isFree: false
                };

                // 在当前块之后插入已分配块
                const newBlock = new Node(allocated);
                newBlock.next = current.next;
                current.next = newBlock;

                // 更新原块的起始位置
                current.data.start += size;

                if (current.data.start >= current.data.end) {
                    // 如果原块已满，删除它
                    return newBlock;
                }
                return newBlock;
            }
            current = current.next;
        }
        return null; // 分配失败
    }

    // 释放内存
    deallocate(block) {
        block.data.isFree = true;
        // 可进一步优化：合并相邻空闲块
    }

    // 显示内存使用状况
    showMemoryMap() {
        let current = this.memoryBlocks;
        const map = [];
        while (current) {
            const status = current.data.isFree ? 'FREE' : 'USED';
            map.push(`[${current.data.start}-${current.data.end}]: ${status}`);
            current = current.next;
        }
        console.log(map.join(' -> '));
    }
}

// 使用示例
const memory = new MemoryManager(1000);
const block1 = memory.allocate(200);
const block2 = memory.allocate(300);
memory.showMemoryMap(); // 显示内存分配状况
memory.deallocate(block1);
```

---

### 6. 经典 LeetCode 题目

#### a. 206. 反转链表 (Reverse Linked List) - Easy
*   **题目链接**: [https://leetcode.cn/problems/reverse-linked-list/](https://leetcode.cn/problems/reverse-linked-list/)
*   **解题思路**: 迭代法。使用三个指针：`prev` (前一个节点), `current` (当前节点), `nextTemp` (临时存储下一个节点)。遍历链表，将 `current` 的 `next` 指针指向 `prev`，然后将所有指针向后移动一位。
*   **JS 代码**:
    ```javascript
    var reverseList = function(head) {
        let prev = null;
        let current = head;
        
        while (current) {
            const nextTemp = current.next; // 存储下一个节点
            current.next = prev;           // 反转指针
            
            // 移动指针
            prev = current;
            current = nextTemp;
        }
        
        return prev; // 新的头节点
    };
    ```

#### b. 21. 合并两个有序链表 (Merge Two Sorted Lists) - Easy
*   **题目链接**: [https://leetcode.cn/problems/merge-two-sorted-lists/](https://leetcode.cn/problems/merge-two-sorted-lists/)
*   **解题思路**: 创建一个虚拟头节点 `dummy`。使用一个指针 `current` 指向 `dummy`。比较两个链表 `l1` 和 `l2` 的当前节点值，将较小的节点连接到 `current.next`，然后移动 `current` 和被选中的链表指针。
*   **JS 代码**:
    ```javascript
    var mergeTwoLists = function(l1, l2) {
        const dummy = new Node(-1); // 虚拟头节点
        let current = dummy;

        while (l1 && l2) {
            if (l1.val <= l2.val) {
                current.next = l1;
                l1 = l1.next;
            } else {
                current.next = l2;
                l2 = l2.next;
            }
            current = current.next;
        }

        // 连接剩余的部分
        current.next = l1 || l2;

        return dummy.next;
    };
    ```

#### c. 141. 环形链表 (Linked List Cycle) - Easy
*   **题目链接**: [https://leetcode.cn/problems/linked-list-cycle/](https://leetcode.cn/problems/linked-list-cycle/)
*   **解题思路**: **快慢指针法 (Floyd's Tortoise and Hare algorithm)**。设置两个指针 `slow` 和 `fast`，都从头节点开始。`slow` 每次移动一步，`fast` 每次移动两步。如果链表中存在环，`fast` 指针最终会追上 `slow` 指针。
*   **JS 代码**:
    ```javascript
    var hasCycle = function(head) {
        if (!head || !head.next) {
            return false;
        }
        
        let slow = head;
        let fast = head.next;

        while (slow !== fast) {
            if (!fast || !fast.next) {
                return false; // fast 到达终点，无环
            }
            slow = slow.next;
            fast = fast.next.next;
        }

        return true; // 相遇，有环
    };
    ```

#### d. 19. 删除链表的倒数第 N 个结点 (Remove Nth Node From End of List) - Medium
*   **题目链接**: [https://leetcode.cn/problems/remove-nth-node-from-end-of-list/](https://leetcode.cn/problems/remove-nth-node-from-end-of-list/)
*   **解题思路**: **双指针法**。设置 `fast` 和 `slow` 两个指针。先让 `fast` 指针从头节点向前移动 `n` 步。然后同时移动 `fast` 和 `slow` 指针，直到 `fast` 到达链表末尾。此时 `slow` 指针指向的就是倒数第 `n+1` 个节点，其 `next` 就是要删除的节点。
*   **JS 代码**:
    ```javascript
    var removeNthFromEnd = function(head, n) {
        const dummy = new Node(0, head);
        let fast = dummy;
        let slow = dummy;

        // fast 先走 n+1 步
        for (let i = 0; i <= n; i++) {
            fast = fast.next;
        }

        // fast 和 slow 一起走，直到 fast 到达末尾
        while (fast) {
            fast = fast.next;
            slow = slow.next;
        }

        // 删除节点
        slow.next = slow.next.next;

        return dummy.next;
    };
    ```

#### e. 234. 回文链表 (Palindrome Linked List) - Easy
*   **题目链接**: [https://leetcode.cn/problems/palindrome-linked-list/](https://leetcode.cn/problems/palindrome-linked-list/)
*   **描述**: 给定一个链表的头节点，判断该链表是否为回文链表（正向和反向遍历结果相同）。
*   **解题思路**: 快慢指针找中点，反转后半部分链表，然后双指针从头尾同时遍历比较。时间 O(n)，空间 O(1)。
*   **JS 代码**:
    ```javascript
    var isPalindrome = function(head) {
        if (!head || !head.next) return true;
        
        // 1. 快慢指针找中点
        let slow = head, fast = head;
        while (fast && fast.next) {
            slow = slow.next;
            fast = fast.next.next;
        }
        
        // 2. 反转后半部分
        let prev = null, curr = slow;
        while (curr) {
            const next = curr.next;
            curr.next = prev;
            prev = curr;
            curr = next;
        }
        
        // 3. 双指针比较
        let p1 = head, p2 = prev;
        while (p2) { // p2 是反转后的较短部分
            if (p1.val !== p2.val) return false;
            p1 = p1.next;
            p2 = p2.next;
        }
        return true;
    };
    ```

#### f. 25. K 个一组翻转链表 (Reverse Nodes in k-Group) - Hard
*   **题目链接**: [https://leetcode.cn/problems/reverse-nodes-in-k-group/](https://leetcode.cn/problems/reverse-nodes-in-k-group/)
*   **描述**: 给定链表和整数 k，将链表每 k 个节点为一组进行反转，返回修改后的链表（最后不足 k 个则不反转）。
*   **解题思路**: 使用虚拟头节点，逐组扫描和反转。对每一组进行反转并连接到前一组，复杂的是指针管理。
*   **JS 代码**:
    ```javascript
    var reverseKGroup = function(head, k) {
        const dummy = new Node(0, head);
        let prevGroup = dummy;
        
        while (true) {
            // 检查是否还有k个节点
            let kth = prevGroup;
            for (let i = 0; i < k; i++) {
                kth = kth.next;
                if (!kth) return dummy.next;
            }
            
            // 开始反转这k个节点
            let groupPrev = prevGroup.next;
            let groupNext = kth.next;
            
            // 反转k个节点
            let prev = groupNext, curr = groupPrev;
            for (let i = 0; i < k; i++) {
                const next = curr.next;
                curr.next = prev;
                prev = curr;
                curr = next;
            }
            
            // 连接到前一组
            const temp = prevGroup.next;
            prevGroup.next = kth;
            prevGroup = temp;
        }
    };
    ```

#### g. 86. 分隔链表 (Partition List) - Medium
*   **题目链接**: [https://leetcode.cn/problems/partition-list/](https://leetcode.cn/problems/partition-list/)
*   **描述**: 给定链表和值 x，将所有小于 x 的节点移动到大于等于 x 的节点之前，保持原有相对顺序。
*   **解题思路**: 两条虚拟链表分别记录小于 x 和 ≥ x 的节点，最后连接两条链表。
*   **JS 代码**:
    ```javascript
    var partition = function(head, x) {
        // 小于x的节点
        const smallDummy = new Node(0);
        let small = smallDummy;
        
        // 大于等于x的节点
        const largeDummy = new Node(0);
        let large = largeDummy;
        
        // 遍历原链表，分类
        let curr = head;
        while (curr) {
            if (curr.val < x) {
                small.next = curr;
                small = small.next;
            } else {
                large.next = curr;
                large = large.next;
            }
            curr = curr.next;
        }
        
        // 连接两条链表
        large.next = null; // 避免循环
        small.next = largeDummy.next;
        
        return smallDummy.next;
    };
    ```

#### h. 142. 环形链表 II (Linked List Cycle II) - Medium
*   **题目链接**: [https://leetcode.cn/problems/linked-list-cycle-ii/](https://leetcode.cn/problems/linked-list-cycle-ii/)
*   **描述**: 给定链表，返回链表通始环的第一个节点；若无环返回 null。
*   **解题思路**: 快慢指针相遇后，设置两个指针分别从 head 和相遇点出发，每次移动一步，相遇处即环入口（数学推导：a = c）。
*   **JS 代码**:
    ```javascript
    var detectCycleEntry = function(head) {
        if (!head || !head.next) return null;
        
        // 快慢指针找相遇点
        let slow = head, fast = head;
        while (fast && fast.next) {
            slow = slow.next;
            fast = fast.next.next;
            if (slow === fast) break;
        }
        
        // 检查是否有环
        if (!fast || !fast.next) return null;
        
        // 从head和相遇点同时出发，每次移动一步
        let p1 = head, p2 = slow;
        while (p1 !== p2) {
            p1 = p1.next;
            p2 = p2.next;
        }
        
        return p1; // 环入口
    };
    ```

---

### 总结

以上题目涵盖了链表的核心操作：反转、判环、回文、分隔、K-group反转等，通过掌握这些题目，可以深入理解指针操作、双指针、快慢指针等常见技巧，这对链表问题的解决能力提升很有帮助。
