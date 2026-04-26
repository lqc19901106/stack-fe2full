# 跳表 (Skip List)

跳表（Skip List）是一种基于并行链表的随机化数据结构，它允许快速的查找、插入和删除操作，其效率可与平衡树（如红黑树、AVL树）相媲美，但实现起来却简单得多。

## 核心思想

想象一下一个普通的有序链表。如果你想查找一个元素，你必须从头开始，一个一个地向后遍历，直到找到目标元素或者到达链表末尾。这种操作的时间复杂度是 O(n)。

为了加速查找，跳表在原始链表的基础上增加了一些“快速通道”。它会从原始链表中随机抽取一些节点，将它们提升到更高一级的链表中。这个过程可以重复多次，形成一个多层次的结构。

*   **第 0 层**: 包含所有节点的原始链表。
*   **第 1 层**: 第 0 层的一个稀疏子集。
*   **第 2 层**: 第 1 层的一个更稀疏的子集。
*   ... 以此类推。

最高层的链表最稀疏，节点最少，可以看作是“高速公路的主干道”。查找时，我们从最高、最稀疏的层开始。在这个“高速公路”上前进，直到下一个节点的目标值大于我们要查找的值。然后，我们下降到下一层（相当于从主干道下到辅路），继续这个过程。通过这种方式，我们可以跳过大量节点，从而大大加快查找速度。

![Skip List Diagram](https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Skip_list_add_element.svg/600px-Skip_list_add_element.svg.png)

## 结构与原理

*   **节点 (Node)**: 跳表中的每个节点不仅包含一个值，还包含一个指向同一层下一个节点的指针数组（`forward`）。数组的大小表示该节点所在的最高层级。例如，`node.forward[i]` 指向该节点在第 `i` 层的下一个节点。
*   **层级 (Level)**: 每个节点被分配一个随机的层级。一个节点出现在第 `i` 层，意味着它也会出现在所有低于 `i` 的层。
*   **随机化**: 节点层级的随机性是跳表性能的关键。通常，一个节点有 50% 的概率提升到上一层。这种概率分布确保了上层链表是下层链表的稀疏索引，并且期望的空间复杂度为 O(n)。

## 核心操作

### 1. 搜索 (Search)

搜索操作最能体现跳表的优势。

1.  从最高层的头节点开始。
2.  在当前层，向右移动，直到找到一个节点，其下一个节点的值大于或等于目标值。
3.  如果当前层的下一个节点不存在或其值大于目标值，则从当前节点下降到下一层。
4.  重复步骤 2 和 3，直到到达最底层的链表（第 0 层）。
5.  在第 0 层，检查紧随当前节点的那个节点是否是我们要找的目标。

### 2. 插入 (Insertion)

1.  **查找插入位置**: 类似于搜索操作，首先找到目标值在每一层应该被插入的位置。在查找过程中，记录下每一层需要修改（即指向新节点）的节点路径（`update` 数组）。
2.  **确定新节点层级**: 通过一个随机过程（例如抛硬币）来决定新节点的层级（`level`）。
3.  **创建并插入新节点**:
    *   如果新节点的层级大于当前跳表的最大层级，需要更新跳表的最大层级，并相应地更新 `update` 数组。
    *   创建一个新节点，其层级为 `level`。
    *   从第 0 层开始，直到 `level - 1` 层，调整指针。对于每一层 `i`，将新节点的 `forward[i]` 指向 `update[i]` 原本指向的节点，然后将 `update[i]` 的 `forward[i]` 指向新节点。

### 3. 删除 (Deletion)

1.  **查找目标节点**: 同样，先找到目标节点在每一层的前驱节点，并记录在 `update` 数组中。
2.  **执行删除**:
    *   在第 0 层找到目标节点。如果找不到，则无需删除。
    *   如果找到了，遍历每一层（从 0 到该节点的最高层）。如果 `update[i]` 在该层的下一个节点是目标节点，就将 `update[i]` 的 `forward[i]` 指针“跳过”目标节点，直接指向目标节点的下一个节点。
    *   如果删除节点后，最高层变成了空链表（除了头节点），则可以降低跳表的整体最大层级。

## JavaScript 代码实现

下面是一个跳表的完整 JavaScript 实现，包括节点定义、跳表类以及插入、搜索、删除等方法。

```javascript
// 定义最大层级
const MAX_LEVEL = 16;

// 节点类
class SkipNode {
    constructor(value, level) {
        this.value = value;
        // forward 数组存储每一层指向的下一个节点
        this.forward = new Array(level).fill(null);
    }
}

// 跳表类
class SkipList {
    constructor() {
        // 头节点，不存储实际值
        this.head = new SkipNode(-1, MAX_LEVEL);
        this.level = 0; // 当前跳表的最高层级
    }

    // 随机生成新节点的层级
    randomLevel() {
        let level = 1;
        while (Math.random() < 0.5 && level < MAX_LEVEL) {
            level++;
        }
        return level;
    }

    // 插入节点
    insert(value) {
        const update = new Array(MAX_LEVEL).fill(this.head);
        let current = this.head;

        // 1. 查找插入位置，并记录每层的前驱节点
        for (let i = this.level - 1; i >= 0; i--) {
            while (current.forward[i] && current.forward[i].value < value) {
                current = current.forward[i];
            }
            update[i] = current;
        }

        // 2. 确定新节点的随机层级
        const newLevel = this.randomLevel();

        // 如果新层级高于当前最高层级，更新跳表层级和 update 数组
        if (newLevel > this.level) {
            for (let i = this.level; i < newLevel; i++) {
                update[i] = this.head;
            }
            this.level = newLevel;
        }

        // 3. 创建新节点并插入
        const newNode = new SkipNode(value, newLevel);
        for (let i = 0; i < newLevel; i++) {
            newNode.forward[i] = update[i].forward[i];
            update[i].forward[i] = newNode;
        }
    }

    // 搜索节点
    search(value) {
        let current = this.head;
        for (let i = this.level - 1; i >= 0; i--) {
            while (current.forward[i] && current.forward[i].value < value) {
                current = current.forward[i];
            }
        }
        // 移动到第 0 层
        current = current.forward[0];
        // 检查第 0 层的下一个节点是否是目标值
        if (current && current.value === value) {
            console.log(`Found ${value}`);
            return true;
        }
        console.log(`Did not find ${value}`);
        return false;
    }

    // 删除节点
    delete(value) {
        const update = new Array(MAX_LEVEL).fill(this.head);
        let current = this.head;

        // 1. 查找目标节点，并记录前驱
        for (let i = this.level - 1; i >= 0; i--) {
            while (current.forward[i] && current.forward[i].value < value) {
                current = current.forward[i];
            }
            update[i] = current;
        }

        current = current.forward[0];

        // 2. 如果找到节点，执行删除
        if (current && current.value === value) {
            for (let i = 0; i < this.level; i++) {
                // 如果前驱节点的下一个是目标节点，则跳过它
                if (update[i].forward[i] !== current) {
                    break;
                }
                update[i].forward[i] = current.forward[i];
            }

            // 3. 更新跳表的层级（如果需要）
            while (this.level > 1 && this.head.forward[this.level - 1] === null) {
                this.level--;
            }
            console.log(`Deleted ${value}`);
            return true;
        }
        console.log(`Value ${value} not found for deletion.`);
        return false;
    }

    // 打印跳表（用于调试）
    print() {
        console.log("--- Skip List ---");
        for (let i = this.level - 1; i >= 0; i--) {
            let current = this.head.forward[i];
            let line = `Level ${i}: `;
            while (current) {
                line += `${current.value} -> `;
                current = current.forward[i];
            }
            console.log(line + "null");
        }
        console.log("-----------------");
    }
}

// --- 使用示例 ---
const list = new SkipList();
list.insert(3);
list.insert(6);
list.insert(7);
list.insert(9);
list.insert(12);
list.insert(19);
list.insert(17);
list.insert(26);
list.insert(21);
list.insert(25);
list.print();

list.search(19);
list.search(18);

list.delete(19);
list.delete(3);
list.print();
```

## 应用场景

跳表因其高性能和相对简单的实现，在工业界有广泛应用：

1.  **Redis**: Redis 的有序集合（Sorted Set）就是使用跳表和哈希表的组合来实现的。跳表用于保证元素的有序性以及范围查询的效率，而哈希表则用于存储元素值到分数的映射，从而实现 O(1) 复杂度的成员分数查找。
2.  **LevelDB 和 RocksDB**: 这些高性能的键值存储引擎使用跳表作为其内存中的数据结构（MemTable）。当写操作发生时，数据首先被写入 MemTable（一个跳表）。因为跳表支持高效的并发插入和查找，非常适合高写入负载的场景。
3.  **数据库索引**: 尽管 B+ 树是关系型数据库索引的标准实现，但在某些需要高并发、写密集的特定场景下，跳表也可以作为一种有效的索引结构。

总的来说，跳表是在需要高效的动态插入、删除和查找（特别是范围查找），同时希望代码实现比平衡树更简单的场景下的一个绝佳选择。