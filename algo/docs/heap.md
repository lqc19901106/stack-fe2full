# 堆 (Heap)

### 1. 什么是堆？

堆是一种特殊的、基于树的数据结构，通常被实现为**完全二叉树**。它满足一个关键的性质，称为**堆性质**。根据堆性质的不同，堆可以分为两种：

1.  **最大堆 (Max-Heap)**：对于任意一个节点，其值都**大于或等于**其所有子节点的值。这意味着堆的根节点存储的是整个数据集中的最大值。
2.  **最小堆 (Min-Heap)**：对于任意一个节点，其值都**小于或等于**其所有子节点的值。这意味着堆的根节点存储的是整个数据集中的最小值。

**关键特性**：
*   **结构性**：它必须是一个**完全二叉树**。这意味着树的每一层都被完全填满，除了最后一层，最后一层的节点都尽可能地靠左排列。
*   **有序性**：所有节点都必须遵循最大堆或最小堆的性质。

> **注意**：堆的有序性只保证了父节点和子节点之间的关系，但**不保证**兄弟节点之间或堂兄弟节点之间的大小关系。例如，在最大堆中，右子节点可能比左子节点大。

### 2. 堆的数组表示法

由于堆是完全二叉树，它有一个非常重要的优点：可以用一个简单的**数组**来高效地表示，而无需使用指针。

在一个用数组表示的堆中，对于任意索引为 `i` 的节点：
*   **父节点**的索引为 `Math.floor((i - 1) / 2)`
*   **左子节点**的索引为 `2 * i + 1`
*   **右子节点**的索引为 `2 * i + 2`

这种表示法非常节省空间，并且可以通过简单的算术运算快速定位父子关系。

### 3. 核心操作

堆的核心操作是**插入 (insert)** 和**删除根节点 (extract)**，这两个操作都依赖于**堆化 (heapify)** 的过程来维持堆的性质。

#### a. 堆化 (Heapify)

堆化是调整堆以重新满足堆性质的过程，分为两种：
1.  **上浮 (Sift Up / Heapify Up)**：当一个节点比其父节点更“优先”（在最小堆中更小，在最大堆中更大）时，需要将它与其父节点交换，并重复此过程，直到它不再违反堆性质或到达根节点。**此操作用于插入新元素**。
2.  **下沉 (Sift Down / Heapify Down)**：当一个节点比其子节点更“不优先”时，需要将它与其最优先的子节点交换，并重复此过程，直到它不再违反堆性质或成为叶子节点。**此操作用于删除根元素和构建堆**。

#### b. 插入 (Insert)

1.  将新元素添加到数组的末尾（即完全二叉树的下一个可用位置）。
2.  对新元素执行**上浮 (Sift Up)** 操作，以恢复堆性质。

#### c. 提取最大/最小值 (Extract Max / Min)

1.  堆顶元素（数组索引 0）就是我们想要的最大值或最小值。
2.  将堆顶元素与数组的最后一个元素交换。
3.  从数组中移除最后一个元素（即原来的堆顶）。
4.  对新的堆顶元素（原来是最后一个元素）执行**下沉 (Sift Down)** 操作，以恢复堆性质。
5.  返回被移除的原始堆顶元素。

### 4. JavaScript 实现 (最小堆)

下面是一个最小堆的完整 JavaScript 实现。

```javascript
class MinHeap {
    constructor() {
        // 使用数组来存储堆元素
        this.heap = [];
    }

    // 获取父节点的索引
    getParentIndex(i) {
        return Math.floor((i - 1) / 2);
    }

    // 获取左子节点的索引
    getLeftChildIndex(i) {
        return 2 * i + 1;
    }

    // 获取右子节点的索引
    getRightChildIndex(i) {
        return 2 * i + 2;
    }

    // 交换两个节点
    swap(i1, i2) {
        [this.heap[i1], this.heap[i2]] = [this.heap[i2], this.heap[i1]];
    }

    // 上浮操作，用于插入
    siftUp(index) {
        let parentIndex = this.getParentIndex(index);
        // 如果当前节点比父节点小，则交换
        while (index > 0 && this.heap[index] < this.heap[parentIndex]) {
            this.swap(index, parentIndex);
            index = parentIndex;
            parentIndex = this.getParentIndex(index);
        }
    }

    // 下沉操作，用于提取和建堆
    siftDown(index) {
        let smallest = index;
        const left = this.getLeftChildIndex(index);
        const right = this.getRightChildIndex(index);
        const size = this.size();

        // 找出当前节点和其左右子节点中最小的那个
        if (left < size && this.heap[left] < this.heap[smallest]) {
            smallest = left;
        }
        if (right < size && this.heap[right] < this.heap[smallest]) {
            smallest = right;
        }

        // 如果最小的不是当前节点，则交换并继续下沉
        if (smallest !== index) {
            this.swap(index, smallest);
            this.siftDown(smallest);
        }
    }

    // 插入一个新元素
    insert(value) {
        this.heap.push(value);
        this.siftUp(this.heap.length - 1);
    }

    // 提取并返回堆顶的最小元素
    extractMin() {
        if (this.isEmpty()) {
            return null;
        }
        if (this.size() === 1) {
            return this.heap.pop();
        }

        const min = this.heap[0];
        // 将最后一个元素放到堆顶
        this.heap[0] = this.heap.pop();
        // 对新的堆顶执行下沉操作
        this.siftDown(0);
        return min;
    }

    // 查看堆顶元素
    peek() {
        return this.isEmpty() ? null : this.heap[0];
    }

    // 获取堆的大小
    size() {
        return this.heap.length;
    }

    // 判断堆是否为空
    isEmpty() {
        return this.size() === 0;
    }
}

// 使用示例
const minHeap = new MinHeap();
minHeap.insert(3);
minHeap.insert(1);
minHeap.insert(6);
minHeap.insert(5);
minHeap.insert(2);
minHeap.insert(4);

console.log("Heap array:", minHeap.heap); // [1, 2, 4, 5, 3, 6] (可能因实现略有不同)
console.log("Peek min:", minHeap.peek()); // 1

console.log("Extract min:", minHeap.extractMin()); // 1
console.log("Heap after extract:", minHeap.heap); // [2, 3, 4, 5, 6]
console.log("Peek min:", minHeap.peek()); // 2
```

### 5. 堆的应用

堆在计算机科学中有广泛的应用，主要因为它能高效地支持“查找最值”和“插入”操作。

1.  **优先队列 (Priority Queue)**
    这是堆最经典的应用。优先队列是一种抽象数据类型，允许你插入元素并总是能以 O(1) 的时间复杂度访问到优先级最高（或最低）的元素。堆是实现优先队列最自然、最高效的数据结构。

2.  **堆排序 (Heap Sort)**
    堆排序是一种高效的原地排序算法，时间复杂度为 O(n log n)。
    *   **步骤 1 (建堆)**：将待排序的数组原地建成一个最大堆。
    *   **步骤 2 (排序)**：重复 n-1 次以下操作：
        *   将堆顶元素（当前最大值）与堆的最后一个元素交换。
        *   将堆的大小减一。
        *   对新的堆顶进行下沉操作，以恢复最大堆性质。
    最终，数组将变为升序排列。

3.  **查找 Top K 问题**
    在海量数据中查找最大或最小的 K 个元素。
    *   **查找最大的 K 个元素**：维护一个大小为 K 的**最小堆**。遍历数据，如果当前元素比堆顶元素大，则弹出堆顶，将当前元素插入。遍历结束后，堆中剩下的就是最大的 K 个元素。
    *   **查找最小的 K 个元素**：同理，维护一个大小为 K 的**最大堆**。

4.  **图论算法**
    *   **Dijkstra 算法**：在计算图中节点的最短路径时，使用最小堆来存储待访问的节点，可以快速找到距离起点最近的节点。
    *   **Prim 算法**：在生成最小生成树时，使用最小堆来选择连接下一个节点的权重最小的边。

### 6. 经典 LeetCode 题目

#### a. 215. 数组中的第K个最大元素 (Kth Largest Element in an Array)
*   **题目链接**: [https://leetcode.cn/problems/kth-largest-element-in-an-array/](https://leetcode.cn/problems/kth-largest-element-in-an-array/)
*   **解题思路**: 维护一个大小为 `k` 的最小堆。遍历数组，将元素逐个插入堆中。如果堆的大小超过 `k`，就弹出堆顶（当前堆中最小的元素）。遍历结束后，堆顶元素就是整个数组中第 `k` 大的元素。
*   **JS 代码**:
    ```javascript
    var findKthLargest = function(nums, k) {
        const minHeap = new MinHeap(); // 使用上面实现的 MinHeap 类
        for (const num of nums) {
            minHeap.insert(num);
            if (minHeap.size() > k) {
                minHeap.extractMin();
            }
        }
        return minHeap.peek();
    };
    ```

#### b. 295. 数据流的中位数 (Find Median from Data Stream)
*   **题目链接**: [https://leetcode.cn/problems/find-median-from-data-stream/](https://leetcode.cn/problems/find-median-from-data-stream/)
*   **解题思路**: 这是一个非常经典的设计题，需要使用**两个堆**来解决：
    1.  一个**最大堆 (maxHeap)**，存储数据流中较小的一半数字。
    2.  一个**最小堆 (minHeap)**，存储数据流中较大的一半数字。
    **维护规则**：
    *   始终保持 `maxHeap` 的大小等于或比 `minHeap` 大 1。
    *   `maxHeap` 的堆顶元素必须小于或等于 `minHeap` 的堆顶元素。
    **查找中位数**：
    *   如果元素总数为奇数，中位数就是 `maxHeap` 的堆顶。
    *   如果元素总数为偶数，中位数是 `maxHeap` 堆顶和 `minHeap` 堆顶的平均值。
*   **JS 代码 (伪代码)**:
    ```javascript
    class MedianFinder {
        constructor() {
            this.maxHeap = new MaxHeap(); // 存储较小的一半
            this.minHeap = new MinHeap(); // 存储较大的一半
        }

        addNum(num) {
            // 默认先加入 maxHeap
            this.maxHeap.insert(num);
            
            // 将 maxHeap 的最大值移动到 minHeap
            this.minHeap.insert(this.maxHeap.extractMax());

            // 保持平衡：如果 minHeap 更大，则将其最小值移回 maxHeap
            if (this.minHeap.size() > this.maxHeap.size()) {
                this.maxHeap.insert(this.minHeap.extractMin());
            }
        }

        findMedian() {
            if (this.maxHeap.size() > this.minHeap.size()) {
                return this.maxHeap.peek();
            } else {
                return (this.maxHeap.peek() + this.minHeap.peek()) / 2;
            }
        }
    }
    ```
    *(注：`MaxHeap` 的实现与 `MinHeap` 类似，只需将比较符 `<` 改为 `>` 即可)*
