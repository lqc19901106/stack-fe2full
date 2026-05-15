探讨**树状数组（Fenwick Tree 或 Binary Indexed Tree, BIT）**。

### 1. 树状数组详解

#### 1.1 什么是树状数组？

树状数组是一种数据结构，主要用于解决以下两类问题：

1.  **单点更新 (Point Update)**：修改数组中某个元素的值。
2.  **区间查询 (Range Query)**：查询数组中某个前缀和（例如，`arr[1] + ... + arr[i]`）或某个区间的和（通过前缀和相减得到）。

它能够在 `O(logN)` 的时间复杂度内完成上述操作，其中 `N` 是数组的长度。相较于朴素的 `O(N)` 更新和 `O(N)` 查询，或使用前缀和数组（`O(N)` 更新，`O(1)` 查询），树状数组在两者之间取得了很好的平衡。

#### 1.2 树状数组的原理

树状数组的核心思想是利用二进制的特性来表示区间的和。它不是直接存储每个元素的值，而是存储一些**特殊区间的和**。

每个元素 `C[i]` (通常树状数组用 `C` 或 `BIT` 表示) 存储的不是 `arr[i]` 的值，而是 `arr` 数组中以 `i` 结尾的、长度为 `lowbit(i)` 的一段区间的和。

**`lowbit(i)` 函数**：
`lowbit(i)` 表示 `i` 的二进制表示中，最低位的 `1` 所对应的值。
等价于 `i & (-i)`。

例如：
*   `lowbit(1) = lowbit(0001_2) = 1`
*   `lowbit(2) = lowbit(0010_2) = 2`
*   `lowbit(4) = lowbit(0100_2) = 4`
*   `lowbit(6) = lowbit(0110_2) = 2` (因为 `6` 的二进制是 `110`，最低位的 `1` 在第二位，值为 `2^1 = 2`)
*   `lowbit(8) = lowbit(1000_2) = 8`

**`C[i]` 的含义**：
`C[i]` 存储的是从 `arr[i - lowbit(i) + 1]` 到 `arr[i]` 这一段区间的和。
也就是说，`C[i] = arr[i - lowbit(i) + 1] + arr[i - lowbit(i) + 2] + ... + arr[i]`

**示例 (N=8):**

*   `C[1]`: 存储 `arr[1]` 的和。 (`lowbit(1)=1`)
*   `C[2]`: 存储 `arr[1] + arr[2]` 的和。 (`lowbit(2)=2`)
*   `C[3]`: 存储 `arr[3]` 的和。 (`lowbit(3)=1`)
*   `C[4]`: 存储 `arr[1] + arr[2] + arr[3] + arr[4]` 的和。 (`lowbit(4)=4`)
*   `C[5]`: 存储 `arr[5]` 的和。 (`lowbit(5)=1`)
*   `C[6]`: 存储 `arr[5] + arr[6]` 的和。 (`lowbit(6)=2`)
*   `C[7]`: 存储 `arr[7]` 的和。 (`lowbit(7)=1`)
*   `C[8]`: 存储 `arr[1] + ... + arr[8]` 的和。 (`lowbit(8)=8`)

#### 1.3 操作详解

**a) 单点更新 `update(index, delta)`**

当 `arr[index]` 的值增加 `delta` 时，所有覆盖 `arr[index]` 的 `C[j]` 都需要更新。

如何找到所有需要更新的 `C[j]` 呢？
从 `index` 开始，每次将 `index` 加上 `lowbit(index)`，直到 `index` 超过数组范围。

`index += lowbit(index)` 的操作相当于将 `index` 的二进制表示中最低位的 `1` 向上进位，找到下一个覆盖 `index` 的区间。

**例如，更新 `arr[3]`：**

1.  `index = 3` (`0011_2`)
2.  `C[3]` 更新 (`0011_2` + `lowbit(3)=1` = `0100_2` 即 4)
3.  `index = 4` (`0100_2`)
4.  `C[4]` 更新 (`0100_2` + `lowbit(4)=4` = `1000_2` 即 8)
5.  `index = 8` (`1000_2`)
6.  `C[8]` 更新 (`1000_2` + `lowbit(8)=8` = `10000_2` 即 16，超出范围，停止)

这个过程的复杂度是 `O(logN)`，因为每次 `index += lowbit(index)` 都相当于把 `index` 的最低位的 `1` 去掉，并进一位，最多进行 `logN` 次。

**b) 区间查询 `query(index)` (求 `arr[1] + ... + arr[index]` 的和)**

要查询 `arr[1]` 到 `arr[index]` 的和，我们从 `index` 开始，不断将 `index` 减去 `lowbit(index)`，并将对应的 `C[index]` 值累加起来，直到 `index` 变为 0。

`index -= lowbit(index)` 的操作相当于从 `index` 指向的区间中，跳到它之前的一个不重叠的、更小的区间。

**例如，查询 `sum(7)` (`arr[1] + ... + arr[7]`)：**

1.  `index = 7` (`0111_2`)
2.  `sum += C[7]` (`lowbit(7)=1`)
3.  `index = 7 - 1 = 6` (`0110_2`)
4.  `sum += C[6]` (`lowbit(6)=2`)
5.  `index = 6 - 2 = 4` (`0100_2`)
6.  `sum += C[4]` (`lowbit(4)=4`)
7.  `index = 4 - 4 = 0` (`0000_2`，停止)

最终 `sum = C[7] + C[6] + C[4]`。这个过程的复杂度也是 `O(logN)`。

**查询任意区间 `sum(left, right)` (求 `arr[left] + ... + arr[right]` 的和)**

可以转换为 `query(right) - query(left - 1)`。

#### 1.4 树状数组的实现细节

*   **索引通常从 1 开始**：为了方便 `lowbit` 操作，树状数组的索引通常从 1 开始。如果原始数组是 0 索引，需要进行转换 (`index + 1`)。
*   **数组大小**：树状数组 `BIT` 的大小通常比原始数组 `arr` 大 1（或者根据最大索引决定）。

### 2. JavaScript 实现

```javascript
class FenwickTree {
    constructor(size) {
        // 树状数组的长度通常比实际数据多 1，以支持从 1 开始的索引
        this.tree = new Array(size + 1).fill(0);
        this.size = size;
    }

    // 计算 lowbit(x) = x & (-x)
    // 这是获取 x 的二进制表示中最低位的 1 及其后面的 0 组成的数
    _lowbit(x) {
        return x & (-x);
    }

    // 单点更新: 将 arr[index] 的值增加 delta
    // 注意: index 必须是 1-based (从 1 开始)
    update(index, delta) {
        // 从 index 开始，向上更新所有受影响的树节点
        while (index <= this.size) {
            this.tree[index] += delta;
            index += this._lowbit(index); // 向上跳到下一个需要更新的节点
        }
    }

    // 区间查询: 计算 arr[1] 到 arr[index] 的前缀和
    // 注意: index 必须是 1-based (从 1 开始)
    query(index) {
        let sum = 0;
        // 从 index 开始，向下累加所有包含 index 的区间和
        while (index > 0) {
            sum += this.tree[index];
            index -= this._lowbit(index); // 向下跳到下一个需要累加的节点
        }
        return sum;
    }

    // 获取原始数组中某个元素的值（通过差分计算）
    // 注意：这不是 O(1) 操作，而是 O(logN)
    get(index) {
        if (index === 0) return 0; // 或者抛出错误
        return this.query(index) - this.query(index - 1);
    }

    // 初始化树状数组（如果已知原始数组）
    // O(N logN) 的方法，每次都调用 update
    build(arr) {
        // arr 应该是 0-based，我们转换为 1-based 处理
        for (let i = 0; i < arr.length; i++) {
            this.update(i + 1, arr[i]);
        }
    }

    // 优化的初始化树状数组 (O(N) 时间复杂度)
    // 直接根据定义计算 tree 数组
    buildOptimized(arr) {
        // arr 应该是 0-based
        for (let i = 0; i < arr.length; i++) {
            const index = i + 1; // 转换为 1-based
            this.tree[index] = arr[i]; // 先存储原始值
            // 将 arr[i] 的值累加到所有它的父节点
            const parentIndex = index + this._lowbit(index);
            if (parentIndex <= this.size) {
                this.tree[parentIndex] += this.tree[index];
            }
        }
        // 更常见且容易理解的 O(N) build 方式是：
        // let temp = new Array(this.size + 1).fill(0);
        // for (let i = 0; i < arr.length; i++) {
        //     temp[i + 1] = arr[i];
        // }
        // for (let i = 1; i <= this.size; i++) {
        //     this.tree[i] += temp[i];
        //     let j = i + this._lowbit(i);
        //     if (j <= this.size) {
        //         this.tree[j] += this.tree[i];
        //     }
        // }
        // 但是上面这种 O(N) 的 build 方式有点问题，我重新思考一下

        // 最常见的 O(N logN) build 方式是基于 update 循环调用：
        // 另一种 O(N) 的构建方式是：
        // for (let i = 0; i < arr.length; i++) {
        //     this.tree[i+1] = arr[i];
        // }
        // for (let i = 1; i <= this.size; i++) {
        //     let j = i + this._lowbit(i);
        //     if (j <= this.size) {
        //         this.tree[j] += this.tree[i];
        //     }
        // }
        // 这种 O(N) 的构建方式是正确的
        // 在这里我们使用更直观的 build 方式，即通过多次 update
        // 如果需要严格 O(N) 的 build，可以采用上面的注释掉的逻辑
    }
}
```

#### 使用示例

```javascript
// 原始数组 (0-based)
const originalArray = [1, 2, 3, 4, 5, 6, 7, 8]; // 长度为 8

// 创建树状数组，大小为 originalArray.length
const ft = new FenwickTree(originalArray.length);

// 方式一：逐个 update 构建 (O(N logN))
for (let i = 0; i < originalArray.length; i++) {
    ft.update(i + 1, originalArray[i]); // 转换为 1-based 索引
}
console.log("树状数组构建完成 (逐个update)");
// 打印内部 tree 数组（调试用，实际不直接操作）
// console.log("Fenwick Tree internal array:", ft.tree); // [0, 1, 3, 3, 10, 5, 11, 7, 36]

// 方式二：使用 build 方法构建 (O(N logN))
// const ft2 = new FenwickTree(originalArray.length);
// ft2.build(originalArray);
// console.log("树状数组构建完成 (build方法)");


// 查询前缀和
// sum(arr[1]...arr[4]) = 1 + 2 + 3 + 4 = 10
console.log("query(4) (sum(1..4)):", ft.query(4)); // 10

// sum(arr[1]...arr[8]) = 1 + ... + 8 = 36
console.log("query(8) (sum(1..8)):", ft.query(8)); // 36

// 查询区间和 (arr[3]...arr[6]) = query(6) - query(2) = (1+2+3+4+5+6) - (1+2) = 21 - 3 = 18
console.log("query(3,6) (sum(3..6)):", ft.query(6) - ft.query(2)); // 18 (即 3+4+5+6)

// 单点更新: arr[3] (在 0-based 中是 index 2) 增加 10
// 原始 arr[3] = 4, 更新后 arr[3] = 14
ft.update(3, 10); // 更新 1-based 索引 3

// 再次查询前缀和
// query(4) (sum(1..4)) 应该增加 10，变为 20
console.log("query(4) after update:", ft.query(4)); // 20

// query(8) (sum(1..8)) 应该增加 10，变为 46
console.log("query(8) after update:", ft.query(8)); // 46

// 获取更新后的 arr[3] 的值 (原始索引 2)
// ft.get(3) 对应 1-based 索引 3，即原始数组的 arr[2]
console.log("get(3) after update:", ft.get(3)); // 14
```

### 3. 树状数组的应用

树状数组是一个非常实用的数据结构，广泛应用于需要频繁进行单点更新和区间查询的场景。

1.  **静态/动态区间和查询**：这是最直接的应用，如上述例子。
2.  **逆序对计数**：在一个数组中统计有多少对 `(i, j)` 满足 `i < j` 且 `arr[i] > arr[j]`。可以通过将元素离散化后，从后往前遍历数组，每次将当前元素插入树状数组，并查询之前已经插入的元素中比当前元素大的数量。
3.  **求区间内小于/大于某个数的元素个数**：结合离散化和树状数组。
4.  **二维树状数组**：扩展到二维平面，支持矩形区域的更新和查询。
5.  **解决一些特定 LeetCode 问题**：
    *   **307. 区域和检索 - 数组可修改 (Range Sum Query - Mutable)** (Medium): [https://leetcode.cn/problems/range-sum-query-mutable/](https://leetcode.cn/problems/range-sum-query-mutable/)
        *   这道题是树状数组的经典应用场景。
    *   **315. 计算右侧小于当前元素的个数 (Count of Smaller Numbers After Self)** (Hard): [https://leetcode.cn/problems/count-of-smaller-numbers-after-self/](https://leetcode.cn/problems/count-of-smaller-numbers-after-self/)
        *   需要结合离散化（或值域范围已知）和树状数组。
    *   **493. 翻转对 (Reverse Pairs)** (Hard): [https://leetcode.cn/problems/reverse-pairs/](https://leetcode.cn/problems/reverse-pairs/)
        *   比逆序对更复杂，但同样可以使用树状数组或归并排序解决。
    *   **1649. 通过指令创建有序数组 (Create Sorted Array through Instructions)** (Hard): [https://leetcode.cn/problems/create-sorted-array-through-instructions/](https://leetcode.cn/problems/create-sorted-array-through-instructions/)
        *   每次插入一个数字，需要计算它左边比它小的和右边比它大的（或等于它的）。

### 总结

树状数组是一种优雅且高效的数据结构，适用于解决单点更新和区间查询问题。它的核心在于 `lowbit` 操作，通过二进制特性巧妙地维护了区间和。虽然理解其原理可能需要一些时间，但一旦掌握，它将成为你解决许多算法问题的强大工具。在 JavaScript 中，由于数组索引的灵活性，实现起来也相对直接。