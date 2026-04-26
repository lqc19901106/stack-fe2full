# 线段树 (Segment Tree)

线段树是一种基于树形结构的数据结构，主要用于高效地处理区间或线段上的信息查询和修改。它特别适用于解决涉及范围查询和单点更新的问题，能够在 O(log n) 的时间复杂度内完成这些操作。

## 1. 数据结构详解

线段树的核心思想是将一个大区间递归地分割成更小的子区间，直到每个区间只包含一个元素。树中的每个节点都代表一个特定的区间，并存储该区间的聚合信息（例如，区间内所有元素的和、最大值、最小值等）。

### 节点表示

通常，我们使用一个数组来存储线段树。如果父节点在数组中的索引是 `i`，那么它的左子节点和右子节点的索引通常是 `2*i + 1` 和 `2*i + 2`。

- **根节点**: 代表整个数组的区间，例如 `[0, n-1]`。
- **内部节点**: 代表其子节点所代表区间的并集。节点的值是其子节点值的聚合结果。
- **叶子节点**: 代表单个元素。

### 构建线段树 (Build)

构建过程是一个递归的过程，从根节点开始：

1.  **创建根节点**: 代表整个输入数组的区间 `[0, n-1]`。
2.  **递归分割**: 将当前区间 `[start, end]` 分为两半：`[start, mid]` 和 `[mid + 1, end]`，其中 `mid = Math.floor((start + end) / 2)`。
3.  **递归构建子树**: 分别为左半部分和右半部分递归构建子树。
4.  **聚合信息**: 子树构建完成后，父节点的值由其左右子节点的值计算得出（例如，求和）。
5.  **终止条件**: 当 `start === end` 时，到达叶子节点，其值等于输入数组中对应位置的元素值。

### 范围查询 (Query)

查询特定区间 `[queryL, queryR]` 的聚合信息也是一个递归过程：

1.  从根节点开始，检查当前节点代表的区间 `[start, end]` 与查询区间的关系。
2.  **完全不重叠**: 如果 `[start, end]` 与 `[queryL, queryR]` 没有交集，返回一个不影响结果的初始值（如求和时返回 0，求最小值时返回无穷大）。
3.  **完全包含**: 如果 `[start, end]` 完全被 `[queryL, queryR]` 包含，直接返回当前节点存储的值。
4.  **部分重叠**: 如果两个区间部分重叠，则递归地在左子树和右子树中进行查询，并将结果合并。

### 单点更新 (Update)

当数组中某个元素的值发生变化时，需要更新线段树以保证数据的一致性：

1.  从根节点开始，沿着树向下查找包含待更新索引的路径。
2.  **找到叶子节点**: 找到代表该索引的叶子节点，并更新其值。
3.  **回溯更新父节点**: 递归地向上返回，更新路径上所有父节点的值，直到根节点。

## 2. JavaScript 实现

下面是一个通用的线段树实现，可以用于求和、求最大/最小值等，只需在构造时传入不同的 `merger` 函数。

```javascript
class SegmentTree {
  /**
   * @param {number[]} nums 输入数组
   * @param {function(a, b): number} merger 合并函数，例如 (a, b) => a + b 用于求和
   */
  constructor(nums, merger) {
    if (!nums || nums.length === 0) {
      return;
    }

    this.data = [...nums];
    this.n = nums.length;
    this.merger = merger;
    // 线段树需要大约 4n 的空间
    this.tree = new Array(4 * this.n);

    this.build(0, 0, this.n - 1);
  }

  /**
   * 在 treeIndex 的位置创建表示区间 [start...end] 的线段树
   * @private
   */
  build(treeIndex, start, end) {
    if (start === end) {
      this.tree[treeIndex] = this.data[start];
      return;
    }

    const leftTreeIndex = 2 * treeIndex + 1;
    const rightTreeIndex = 2 * treeIndex + 2;
    const mid = start + Math.floor((end - start) / 2);

    this.build(leftTreeIndex, start, mid);
    this.build(rightTreeIndex, mid + 1, end);

    this.tree[treeIndex] = this.merger(this.tree[leftTreeIndex], this.tree[rightTreeIndex]);
  }

  /**
   * 查询区间 [queryL, queryR] 的值
   * @public
   */
  query(queryL, queryR) {
    if (queryL < 0 || queryL >= this.n || queryR < 0 || queryR >= this.n || queryL > queryR) {
      throw new Error("Index is illegal.");
    }
    return this._query(0, 0, this.n - 1, queryL, queryR);
  }

  /**
   * 在以 treeIndex 为根的线段树中 [start...end] 的范围里，搜索区间 [queryL...queryR] 的值
   * @private
   */
  _query(treeIndex, start, end, queryL, queryR) {
    if (start === queryL && end === queryR) {
      return this.tree[treeIndex];
    }

    const mid = start + Math.floor((end - start) / 2);
    const leftTreeIndex = 2 * treeIndex + 1;
    const rightTreeIndex = 2 * treeIndex + 2;

    if (queryL >= mid + 1) {
      // 查询区间完全在右子树
      return this._query(rightTreeIndex, mid + 1, end, queryL, queryR);
    } else if (queryR <= mid) {
      // 查询区间完全在左子树
      return this._query(leftTreeIndex, start, mid, queryL, queryR);
    }

    // 查询区间横跨左右子树
    const leftResult = this._query(leftTreeIndex, start, mid, queryL, mid);
    const rightResult = this._query(rightTreeIndex, mid + 1, end, mid + 1, queryR);
    return this.merger(leftResult, rightResult);
  }

  /**
   * 将 index 位置的值更新为 val
   * @public
   */
  update(index, val) {
    if (index < 0 || index >= this.n) {
      throw new Error("Index is illegal.");
    }
    this.data[index] = val;
    this._update(0, 0, this.n - 1, index, val);
  }

  /**
   * 在以 treeIndex 为根的线段树中更新 index 的值为 val
   * @private
   */
  _update(treeIndex, start, end, index, val) {
    if (start === end) {
      this.tree[treeIndex] = val;
      return;
    }

    const mid = start + Math.floor((end - start) / 2);
    const leftTreeIndex = 2 * treeIndex + 1;
    const rightTreeIndex = 2 * treeIndex + 2;

    if (index >= mid + 1) {
      this._update(rightTreeIndex, mid + 1, end, index, val);
    } else { // index <= mid
      this._update(leftTreeIndex, start, mid, index, val);
    }

    this.tree[treeIndex] = this.merger(this.tree[leftTreeIndex], this.tree[rightTreeIndex]);
  }
}

// 示例：区域和检索
const nums = [-2, 0, 3, -5, 2, -1];
const sumSegmentTree = new SegmentTree(nums, (a, b) => a + b);

console.log(sumSegmentTree.query(0, 2)); // 输出: 1 (-2 + 0 + 3)
console.log(sumSegmentTree.query(2, 5)); // 输出: -1 (3 + -5 + 2 + -1)
sumSegmentTree.update(1, 10); // 将 nums[1] 从 0 更新为 10
console.log(sumSegmentTree.query(0, 2)); // 输出: 11 (-2 + 10 + 3)
```

## 3. 应用场景

线段树的应用非常广泛，主要包括：

- **范围和查询 (Range Sum Query, RSQ)**: 求解一个区间内所有元素的和。
- **范围最值查询 (Range Minimum/Maximum Query, RMQ)**: 求解一个区间内所有元素的最大值或最小值。
- **范围频率查询**: 统计一个区间内某个值出现的次数。
- **计算几何**: 用于处理涉及线段和矩形的问题。

## 4. LeetCode 经典题目

以下是一些可以使用线段树解决的经典 LeetCode 题目，通过这些题目可以加深对线段树的理解和应用。

1.  **[303. 区域和检索 - 数组不可变](https://leetcode.cn/problems/range-sum-query-immutable/)**
    - **描述**: 给定一个整数数组 `nums`，求出数组从索引 `i` 到 `j`（`i` ≤ `j`）范围内元素的总和。
    - **解法**: 这是最简单的范围查询问题。虽然前缀和数组是更优的解法，但它也是线段树的入门级应用。

2.  **[307. 区域和检索 - 数组可修改](https://leetcode.cn/problems/range-sum-query-mutable/)**
    - **描述**: 在题目 303 的基础上，增加了 `update` 操作，可以修改数组中某个元素的值。
    - **解法**: 这是线段树的典型应用场景。前缀和数组每次更新需要 O(n) 的时间，而线段树的查询和更新都只需要 O(log n)。
    - **JavaScript 实现**:
      ```javascript
      // 需要使用上文定义的 SegmentTree 类

      class NumArray {
        /**
         * @param {number[]} nums
         */
        constructor(nums) {
          if (nums.length > 0) {
            this.segmentTree = new SegmentTree(nums, (a, b) => a + b);
          }
        }

        /** 
         * @param {number} index 
         * @param {number} val
         * @return {void}
         */
        update(index, val) {
          if (this.segmentTree) {
            this.segmentTree.update(index, val);
          }
        }

        /** 
         * @param {number} left 
         * @param {number} right
         * @return {number}
         */
        sumRange(left, right) {
          if (this.segmentTree) {
            return this.segmentTree.query(left, right);
          }
          return 0;
        }
      }
      ```

3.  **[315. 计算右侧小于当前元素的个数](https://leetcode.cn/problems/count-of-smaller-numbers-after-self/)**
    - **描述**: 给定一个整数数组 `nums`，你需要返回一个新的 `counts` 数组。`counts[i]` 的值是 `nums[i]` 右侧小于 `nums[i]` 的元素的数量。
    - **解法**: 可以从右向左遍历数组，将元素值离散化后，使用线段树（或树状数组）来统计已经遍历过的元素中，比当前元素小的个数。
    - **JavaScript 实现**:
      ```javascript
      /**
       * @param {number[]} nums
       * @return {number[]}
       */
      var countSmaller = function(nums) {
        if (!nums || nums.length === 0) {
          return [];
        }

        // 1. 离散化
        const uniqueSorted = Array.from(new Set(nums)).sort((a, b) => a - b);
        const rankMap = new Map();
        uniqueSorted.forEach((val, index) => {
          rankMap.set(val, index);
        });

        // 2. 构建线段树
        // 树的范围是离散化后的索引范围
        const tree = new SegmentTree(new Array(uniqueSorted.length).fill(0), (a, b) => a + b);
        
        const result = [];
        // 3. 从右向左遍历
        for (let i = nums.length - 1; i >= 0; i--) {
          const rank = rankMap.get(nums[i]);
          
          // 4. 查询右侧较小元素
          // 查询排名在 [0, rank - 1] 区间内的元素个数
          let count = 0;
          if (rank > 0) {
            count = tree.query(0, rank - 1);
          }
          result.push(count);
          
          // 5. 更新线段树
          // 将当前元素排名的位置+1，表示该数字已出现
          tree.update(rank, tree.query(rank, rank) + 1);
        }

        return result.reverse();
      };

      // 此处同样需要上文定义的 SegmentTree 类
      // 注意：为适配此题，SegmentTree 的构造函数和 update 方法需要能处理初始为空或全0的数组
      // 上文的实现已满足要求
      ```

4.  **[218. 天际线问题](https://leetcode.cn/problems/the-skyline-problem/)**
    - **描述**: 给定一系列矩形建筑物的坐标，计算这些建筑物形成的天际线轮廓。
    - **解法**: 这是一个更高级的应用。可以将建筑物的左右边界作为事件点，使用扫描线算法，并配合线段树来维护当前扫描线位置的最大高度。这个问题的线段树实现较为复杂，通常需要支持“区间更新”的“懒加载”线段树。

通过学习和实践这些题目，你可以熟练掌握线段树的构建、查询和更新操作，并灵活地将其应用于解决实际问题。
