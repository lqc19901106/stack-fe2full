
# 分治算法 (Divide and Conquer)

分治算法是一种重要的算法设计范式。它将一个难以直接解决的大问题，分割成一些规模较小的相同问题，以便各个击破，分而治之。

分治算法通常遵循三个步骤：

1.  **分解 (Divide)**: 将原问题分解为若干个规模较小、相互独立、与原问题形式相同的子问题。
2.  **解决 (Conquer)**: 若子问题规模较小且易于解决时，则直接解决。否则，递归地解决各子问题。
3.  **合并 (Combine)**: 将各子问题的解合并为原问题的解。

## 核心思想

分治算法的本质是递归。通过递归，我们将大问题不断分解，直到达到一个可以直接求解的“基本情况”（base case），然后将子问题的解逐层合并，最终得到原问题的解。

## 算法模板

分治算法的递归结构非常清晰，其伪代码模板如下：

```
function divide_conquer(problem, params):
    // 1. 递归终止条件
    if problem is small enough:
        solve problem directly
        return result

    // 2. 分解问题
    subproblems = divide(problem)

    // 3. 递归解决子问题
    sub_results = []
    for sub in subproblems:
        sub_results.push(divide_conquer(sub, params))

    // 4. 合并结果
    final_result = combine(sub_results)
    return final_result
```

## 经典算法示例

### 归并排序 (Merge Sort)

归并排序是分治思想的完美体现。

*   **分解**: 将待排序的数组从中间一分为二。
*   **解决**: 递归地对左右两个子数组进行归并排序。
*   **合并**: 将两个已排序的子数组合并成一个大的有序数组。

```javascript
function mergeSort(arr) {
    if (arr.length <= 1) {
        return arr;
    }

    const mid = Math.floor(arr.length / 2);
    const left = arr.slice(0, mid);
    const right = arr.slice(mid);

    const sortedLeft = mergeSort(left);
    const sortedRight = mergeSort(right);

    return merge(sortedLeft, sortedRight);
}

function merge(left, right) {
    const result = [];
    let i = 0, j = 0;
    while (i < left.length && j < right.length) {
        if (left[i] < right[j]) {
            result.push(left[i++]);
        } else {
            result.push(right[j++]);
        }
    }
    return result.concat(left.slice(i)).concat(right.slice(j));
}
```

## 经典 LeetCode 题目

1.  **[53. 最大子数组和 (Maximum Subarray)](https://leetcode.cn/problems/maximum-subarray/)**
    *   **问题描述**: 给定一个整数数组 `nums` ，找到一个具有最大和的连续子数组（子数组最少包含一个元素），返回其最大和。
    *   **分治策略**:
        *   **分解**: 将数组从中间分为左右两部分。
        *   **解决**: 最大子数组和可能存在于三个地方：① 完全在左半部分；② 完全在右半部分；③ 跨越了中点。前两种情况可以递归求解。对于第三种情况，我们需要从中点开始，分别向左和向右找出包含中点的最大和，然后相加。
        *   **合并**: 最终结果是这三种情况中的最大值。
    *   **JavaScript 实现**:
        ```javascript
        var maxSubArray = function(nums) {
            function findMax(arr, left, right) {
                if (left === right) {
                    return arr[left];
                }

                const mid = Math.floor((left + right) / 2);

                const leftMax = findMax(arr, left, mid);
                const rightMax = findMax(arr, mid + 1, right);

                let crossLeftMax = -Infinity;
                let tempSum = 0;
                for (let i = mid; i >= left; i--) {
                    tempSum += arr[i];
                    crossLeftMax = Math.max(crossLeftMax, tempSum);
                }

                let crossRightMax = -Infinity;
                tempSum = 0;
                for (let i = mid + 1; i <= right; i++) {
                    tempSum += arr[i];
                    crossRightMax = Math.max(crossRightMax, tempSum);
                }

                const crossMax = crossLeftMax + crossRightMax;

                return Math.max(leftMax, rightMax, crossMax);
            }

            return findMax(nums, 0, nums.length - 1);
        };
        ```

2.  **[241. 为运算表达式设计优先级 (Different Ways to Add Parentheses)](https://leetcode.cn/problems/different-ways-to-add-parentheses/)**
    *   **问题描述**: 给定一个含有数字和运算符的字符串，为表达式添加括号，改变运算优先级，求出所有可能的结果。
    *   **分治策略**:
        *   **分解**: 遍历字符串，以每一个运算符作为分割点。例如，对于 "2-1-1"，可以先在第一个 '-' 分割，得到 "2" 和 "1-1"。
        *   **解决**: 递归地计算左右两边子表达式所有可能的结果。
        *   **合并**: 将左边的结果集和右边的结果集，根据中间的运算符进行组合，得到当前层的结果。
    *   **JavaScript 实现**:
        ```javascript
        var diffWaysToCompute = function(expression) {
            const memo = new Map();

            function compute(expr) {
                if (memo.has(expr)) {
                    return memo.get(expr);
                }
                
                const results = [];
                for (let i = 0; i < expr.length; i++) {
                    const char = expr[i];
                    if (char === '+' || char === '-' || char === '*') {
                        const leftParts = compute(expr.substring(0, i));
                        const rightParts = compute(expr.substring(i + 1));

                        for (const left of leftParts) {
                            for (const right of rightParts) {
                                if (char === '+') {
                                    results.push(left + right);
                                } else if (char === '-') {
                                    results.push(left - right);
                                } else {
                                    results.push(left * right);
                                }
                            }
                        }
                    }
                }

                if (results.length === 0) {
                    results.push(parseInt(expr));
                }
                
                memo.set(expr, results);
                return results;
            }

            return compute(expression);
        };
        ```

3.  **[95. 不同的二叉搜索树 II (Unique Binary Search Trees II)](https://leetcode.cn/problems/unique-binary-search-trees-ii/)**
    *   **问题描述**: 给你一个整数 `n` ，请你生成并返回所有由 `n` 个节点组成且节点值从 `1` 到 `n` 互不相同的不同二叉搜索树。
    *   **分治策略**:
        *   **分解**: 遍历 `1` 到 `n`，依次选择一个数 `i` 作为根节点。
        *   **解决**: 根据二叉搜索树的性质，`1` 到 `i-1` 的所有数将构成左子树，`i+1` 到 `n` 的所有数将构成右子树。递归地为这两个范围生成所有可能的子树。
        *   **合并**: 将所有可能的左子树和右子树进行组合，拼接到根节点 `i` 上，形成一棵完整的二叉搜索树。
    *   **JavaScript 实现**:
        ```javascript
        /**
         * Definition for a binary tree node.
         * function TreeNode(val, left, right) {
         *     this.val = (val===undefined ? 0 : val)
         *     this.left = (left===undefined ? null : left)
         *     this.right = (right===undefined ? null : right)
         * }
         */
        var generateTrees = function(n) {
            if (n === 0) return [];

            function buildTrees(start, end) {
                if (start > end) {
                    return [null];
                }

                const allTrees = [];
                for (let i = start; i <= end; i++) {
                    const leftTrees = buildTrees(start, i - 1);
                    const rightTrees = buildTrees(i + 1, end);

                    for (const left of leftTrees) {
                        for (const right of rightTrees) {
                            const currTree = new TreeNode(i);
                            currTree.left = left;
                            currTree.right = right;
                            allTrees.push(currTree);
                        }
                    }
                }
                return allTrees;
            }

            return buildTrees(1, n);
        };
        ```

4.  **[169. 多数元素 (Majority Element)](https://leetcode.cn/problems/majority-element/)**
    *   **问题描述**: 给定一个大小为 `n` 的数组，找到其中的多数元素。多数元素是指在数组中出现次数大于 `⌊ n/2 ⌋` 的元素。
    *   **分治策略**:
        *   **分解**: 将数组分成左右两半。
        *   **解决**: 递归地在左右两半中寻找多数元素，得到 `left_major` 和 `right_major`。
        *   **合并**: 如果 `left_major` 和 `right_major` 相同，那么它就是当前数组的多数元素。如果不同，那么需要分别计算它们在当前整个数组中的出现次数，次数较多的那个是多数元素。这个策略的正确性基于一个事实：如果一个元素是整个数组的多数元素，那么它必然至少是其中一半数组的多数元素。
    *   **JavaScript 实现**:
        ```javascript
        var majorityElement = function(nums) {
            function findMajority(arr, left, right) {
                if (left === right) {
                    return arr[left];
                }

                const mid = Math.floor((left + right) / 2);
                const leftMajor = findMajority(arr, left, mid);
                const rightMajor = findMajority(arr, mid + 1, right);

                if (leftMajor === rightMajor) {
                    return leftMajor;
                }

                let leftCount = 0;
                let rightCount = 0;
                for (let i = left; i <= right; i++) {
                    if (arr[i] === leftMajor) {
                        leftCount++;
                    } else if (arr[i] === rightMajor) {
                        rightCount++;
                    }
                }

                return leftCount > rightCount ? leftMajor : rightMajor;
            }

            return findMajority(nums, 0, nums.length - 1);
        };
        ```

