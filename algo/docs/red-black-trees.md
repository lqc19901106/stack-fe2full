
# 红黑树 (Red-Black Tree)

红黑树是一种自平衡的二叉搜索树（BST）。普通的二叉搜索树在频繁的插入和删除操作后，可能会退化成一个链表，导致其操作的时间复杂度从 O(log n) 退化到 O(n)。红黑树通过引入一些特定的性质（颜色和规则）来确保树在操作后能通过旋转和重新着色来保持大致的平衡，从而保证其查找、插入和删除等操作在最坏情况下的时间复杂度仍然为 O(log n)。

## 红黑树的五个性质

一棵有效的红黑树必须满足以下五个性质：

1.  **性质一（颜色）**: 每个节点要么是红色，要么是黑色。
2.  **性质二（根节点）**: 根节点是黑色的。
3.  **性质三（叶子节点）**: 所有叶子节点（NIL 节点，即空节点）都是黑色的。在实现中，我们通常用一个哨兵节点来代表所有的 NIL 节点。
4.  **性质四（红色节点）**: 如果一个节点是红色的，那么它的两个子节点都是黑色的。这意味着**不能有两个连续的红色节点**（父子关系）。
5.  **性质五（黑色高度）**: 从任一节点到其每个叶子节点的所有路径都包含相同数目的黑色节点。这个数目被称为该节点的“黑高”（black-height）。

这些性质共同确保了树中最长的路径（从根到最远的叶子）不会超过最短路径的两倍长，从而保证了树的平衡。

## 核心操作：旋转

为了在插入和删除后维持红黑树的性质，需要进行两种基本操作：**重新着色**和**旋转**。旋转是改变树结构的关键，分为左旋和右旋。

*   **左旋 (Left Rotation)**: 以某个节点 `x` 为支点进行左旋，会使其右子节点 `y` 成为新的根，`x` 成为 `y` 的左子节点。`y` 原本的左子节点会成为 `x` 的右子节点。
*   **右旋 (Right Rotation)**: 与左旋相反。以 `y` 为支点进行右旋，会使其左子节点 `x` 成为新的根。

## 插入操作

插入一个新节点时，为了尽可能少地破坏红黑树的性质，新节点总是被染成**红色**。这样唯一可能被违反的只有性质四（不能有两个连续的红色节点）。如果新节点的父节点是黑色的，那么插入完成。如果父节点是红色的，就需要进行一系列的修复操作（重新着色和旋转）。

修复过程主要分三种情况，取决于**叔叔节点**（祖父节点的另一个子节点）的颜色：

1.  **情况一：叔叔节点是红色**
    *   将父节点和叔叔节点都染成黑色。
    *   将祖父节点染成红色。
    *   将当前节点指向祖父节点，继续向上检查是否违反性质。

2.  **情况二：叔叔节点是黑色，且当前节点是其父节点的右孩子（形成"三角形"）**
    *   将父节点作为当前节点。
    *   对新的当前节点进行一次左旋。
    *   这样就转换成了情况三。

3.  **情况三：叔叔节点是黑色，且当前节点是其父节点的左孩子（形成"直线"）**
    *   将父节点染成黑色。
    *   将祖父节点染成红色。
    *   对祖父节点进行一次右旋。

（以上是针对父节点是祖父节点的左孩子的情况，如果父节点是右孩子，则左右操作相反）。

## JavaScript 代码实现

下面是一个红黑树的 JavaScript 实现，包含了节点定义、颜色常量、树的构造函数以及核心的插入和修复逻辑。

```javascript
// 定义颜色常量
const RED = 'RED';
const BLACK = 'BLACK';

// 节点类
class Node {
    constructor(key, value, color = RED) {
        this.key = key;       // 键
        this.value = value;   // 值
        this.color = color;   // 颜色
        this.parent = null;   // 父节点
        this.left = null;     // 左子节点
        this.right = null;    // 右子节点
    }
}

// 红黑树类
class RedBlackTree {
    constructor() {
        // 哨兵节点，代表所有的 NIL 叶子节点
        this.NIL = new Node(null, null, BLACK);
        this.root = this.NIL;
    }

    // 左旋
    leftRotate(x) {
        const y = x.right;
        x.right = y.left;
        if (y.left !== this.NIL) {
            y.left.parent = x;
        }
        y.parent = x.parent;
        if (x.parent === this.NIL) {
            this.root = y;
        } else if (x === x.parent.left) {
            x.parent.left = y;
        } else {
            x.parent.right = y;
        }
        y.left = x;
        x.parent = y;
    }

    // 右旋
    rightRotate(y) {
        const x = y.left;
        y.left = x.right;
        if (x.right !== this.NIL) {
            x.right.parent = y;
        }
        x.parent = y.parent;
        if (y.parent === this.NIL) {
            this.root = x;
        } else if (y === y.parent.right) {
            y.parent.right = x;
        } else {
            y.parent.left = x;
        }
        x.right = y;
        y.parent = x;
    }

    // 插入新节点
    insert(key, value) {
        const newNode = new Node(key, value);
        newNode.left = this.NIL;
        newNode.right = this.NIL;

        let parent = this.NIL;
        let current = this.root;

        // 1. 按照 BST 规则找到插入位置
        while (current !== this.NIL) {
            parent = current;
            if (newNode.key < current.key) {
                current = current.left;
            } else {
                current = current.right;
            }
        }

        newNode.parent = parent;
        if (parent === this.NIL) {
            this.root = newNode;
        } else if (newNode.key < parent.key) {
            parent.left = newNode;
        } else {
            parent.right = newNode;
        }

        // 2. 修复红黑树性质
        this.insertFixup(newNode);
    }

    // 插入修复
    insertFixup(z) {
        while (z.parent.color === RED) {
            if (z.parent === z.parent.parent.left) { // 父节点是祖父节点的左孩子
                const y = z.parent.parent.right; // 叔叔节点
                if (y.color === RED) { // 情况一：叔叔是红色
                    z.parent.color = BLACK;
                    y.color = BLACK;
                    z.parent.parent.color = RED;
                    z = z.parent.parent;
                } else {
                    if (z === z.parent.right) { // 情况二：当前节点是右孩子
                        z = z.parent;
                        this.leftRotate(z);
                    }
                    // 情况三：当前节点是左孩子
                    z.parent.color = BLACK;
                    z.parent.parent.color = RED;
                    this.rightRotate(z.parent.parent);
                }
            } else { // 父节点是祖父节点的右孩子 (与上面对称)
                const y = z.parent.parent.left; // 叔叔节点
                if (y.color === RED) { // 情况一
                    z.parent.color = BLACK;
                    y.color = BLACK;
                    z.parent.parent.color = RED;
                    z = z.parent.parent;
                } else {
                    if (z === z.parent.left) { // 情况二
                        z = z.parent;
                        this.rightRotate(z);
                    }
                    // 情况三
                    z.parent.color = BLACK;
                    z.parent.parent.color = RED;
                    this.leftRotate(z.parent.parent);
                }
            }
        }
        // 始终保持根节点是黑色
        this.root.color = BLACK;
    }

    // 搜索
    search(key) {
        let current = this.root;
        while (current !== this.NIL && key !== current.key) {
            if (key < current.key) {
                current = current.left;
            } else {
                current = current.right;
            }
        }
        return current; // 如果找不到，会返回 this.NIL
    }
}

// --- 使用示例 ---
const rbt = new RedBlackTree();
rbt.insert(10, 'ten');
rbt.insert(20, 'twenty');
rbt.insert(30, 'thirty');
rbt.insert(15, 'fifteen');
rbt.insert(5, 'five');

console.log('Search for 15:', rbt.search(15).value); // fifteen
console.log('Search for 99:', rbt.search(99).value); // null
```

## 应用场景

红黑树以其稳定的 O(log n) 性能和相对高效的平衡维护机制，在许多需要有序数据存储的场景中得到了广泛应用：

1.  **C++ STL**: `std::map`, `std::multimap`, `std::set`, `std::multiset` 的底层实现都是红黑树。
2.  **Java**: `java.util.TreeMap` 和 `java.util.TreeSet` 也是基于红黑树实现的。
3.  **Linux 内核**:
    *   **CFS (Completely Fair Scheduler)**: Linux 2.6.23 版本后引入的进程调度器使用红黑树来管理任务队列，确保能够快速找到下一个需要运行的进程。
    *   **内存管理**: 内核使用红黑树来管理虚拟内存区域（VMA）。
4.  **Nginx**: 使用红黑树来管理定时器，以便高效地处理超时事件。
5.  **数据库索引**: 虽然 B+ 树在磁盘存储中更常见，但一些内存数据库或特定场景下也可能使用红黑树作为索引结构。
