
# 回溯算法 (Backtracking)

回溯算法是一种通过探索所有可能的候选解来找出所有解的算法。如果候选解被确认不是一个解（或者至少不是最后一个解），回溯算法会通过在上一步进行一些变化来丢弃该解，即“回溯”。

回溯算法通常用于解决组合问题、排列问题、子集问题、棋盘问题（如N皇后、数独）等。

## 核心思想

回溯算法可以被看作是深度优先搜索（DFS）的一种特殊形式，它在搜索过程中加入了“剪枝”操作。

1.  **路径 (Path)**: 已经做出的选择。
2.  **选择列表 (Choices)**: 当前可以做的选择。
3.  **结束条件 (End Condition)**: 到达决策树的叶子节点，无法再做选择的条件。

其本质是一个决策树的遍历过程：

*   从根节点出发，探索从根节点到某一子节点的路径。
*   当探索到某一节点时，先判断该节点是否符合要求（是否是问题的解）。
*   如果符合，就记录下来。
*   如果不符合，就回退到上一个节点（回溯），然后探索该节点的其他子节点。
*   重复以上过程，直到遍历完整个决策树。

## 算法模板

回溯算法通常使用递归来实现。下面是一个通用的伪代码模板：

```
result = []
def backtrack(路径, 选择列表):
    if 满足结束条件:
        result.add(路径)
        return

    for 选择 in 选择列表:
        做选择
        backtrack(路径, 选择列表)
        撤销选择
```

*   **做选择**: 将当前选择添加到“路径”中，并从“选择列表”中移除该选择。
*   **撤销选择**: 将当前选择从“路径”中移除，并将其重新加入到“选择列表”中，以便探索其他可能性。这就是“回溯”的关键。

## 经典 LeetCode 题目

1.  **[46. 全排列 (Permutations)](https://leetcode.cn/problems/permutations/)**
    *   **问题描述**: 给定一个不含重复数字的数组 `nums` ，返回其所有可能的全排列。
    *   **回溯思路**:
        *   `路径`: 当前已经选择的数字组成的列表。
        *   `选择列表`: `nums` 中还没有被选择的数字。
        *   `结束条件`: `路径` 的长度等于 `nums` 的长度。
    *   **JavaScript 实现**:
        ```javascript
        var permute = function(nums) {
            const result = [];
            const path = [];
            const used = new Array(nums.length).fill(false);

            function backtrack() {
                if (path.length === nums.length) {
                    result.push([...path]);
                    return;
                }

                for (let i = 0; i < nums.length; i++) {
                    if (used[i]) {
                        continue;
                    }
                    path.push(nums[i]);
                    used[i] = true;
                    backtrack();
                    path.pop();
                    used[i] = false;
                }
            }

            backtrack();
            return result;
        };
        ```

2.  **[78. 子集 (Subsets)](https://leetcode.cn/problems/subsets/)**
    *   **问题描述**: 给你一个整数数组 `nums` ，数组中的元素互不相同。返回该数组所有可能的子集（幂集）。
    *   **回溯思路**:
        *   `路径`: 当前构建的子集。
        *   `选择列表`: 从 `nums` 的某个位置开始的所有后续元素。
        *   `结束条件`: 无特定结束条件，决策树的每个节点都是一个合法的子集，都需要被加入结果。
    *   **JavaScript 实现**:
        ```javascript
        var subsets = function(nums) {
            const result = [];
            const path = [];

            function backtrack(start) {
                result.push([...path]); // 每个节点都是一个解

                for (let i = start; i < nums.length; i++) {
                    path.push(nums[i]);
                    backtrack(i + 1);
                    path.pop();
                }
            }

            backtrack(0);
            return result;
        };
        ```

3.  **[77. 组合 (Combinations)](https://leetcode.cn/problems/combinations/)**
    *   **问题描述**: 给定两个整数 `n` 和 `k`，返回范围 `[1, n]` 中所有可能的 `k` 个数的组合。
    *   **回溯思路**:
        *   `路径`: 当前已经选择的数字组合。
        *   `选择列表`: 从 `[1, n]` 中可以选择的数字。为了避免重复，我们通常会传递一个 `start` 索引，表示下一次选择从哪里开始。
        *   `结束条件`: `路径` 的长度等于 `k`。
    *   **JavaScript 实现**:
        ```javascript
        var combine = function(n, k) {
            const result = [];
            const path = [];

            function backtrack(start) {
                if (path.length === k) {
                    result.push([...path]);
                    return;
                }

                // 剪枝：如果剩余的元素个数不足以填满 path，则无需继续
                for (let i = start; i <= n - (k - path.length) + 1; i++) {
                    path.push(i);
                    backtrack(i + 1);
                    path.pop();
                }
            }

            backtrack(1);
            return result;
        };
        ```

4.  **[39. 组合总和 (Combination Sum)](https://leetcode.cn/problems/combination-sum/)**
    *   **问题描述**: 给定一个无重复元素的数组 `candidates` 和一个目标数 `target` ，找出 `candidates` 中所有可以使数字和为 `target` 的组合。`candidates` 中的数字可以无限制重复被选取。
    *   **回溯思路**:
        *   `路径`: 当前组合的数字列表。
        *   `选择列表`: `candidates` 数组中的所有数字（可以重复使用）。
        *   `结束条件`: `路径` 中数字的和等于 `target`。
        *   为了避免重复组合，可以要求选择的数字索引不小于前一个。
    *   **JavaScript 实现**:
        ```javascript
        var combinationSum = function(candidates, target) {
            const result = [];
            const path = [];

            function backtrack(start, sum) {
                if (sum === target) {
                    result.push([...path]);
                    return;
                }
                if (sum > target) {
                    return;
                }

                for (let i = start; i < candidates.length; i++) {
                    path.push(candidates[i]);
                    backtrack(i, sum + candidates[i]); // i, 因为可以重复使用
                    path.pop();
                }
            }

            backtrack(0, 0);
            return result;
        };
        ```

5.  **[17. 电话号码的字母组合 (Letter Combinations of a Phone Number)](https://leetcode.cn/problems/letter-combinations-of-a-phone-number/)**
    *   **问题描述**: 给定一个仅包含数字 `2-9` 的字符串，返回所有它能表示的字母组合。
    *   **回溯思路**:
        *   `路径`: 当前生成的字符串。
        *   `选择列表`: 当前数字对应的所有字母。
        *   `结束条件`: 生成的字符串长度等于输入数字字符串的长度。
    *   **JavaScript 实现**:
        ```javascript
        var letterCombinations = function(digits) {
            if (digits.length === 0) return [];
            const map = {
                '2': 'abc', '3': 'def', '4': 'ghi', '5': 'jkl',
                '6': 'mno', '7': 'pqrs', '8': 'tuv', '9': 'wxyz'
            };
            const result = [];
            const path = [];

            function backtrack(index) {
                if (path.length === digits.length) {
                    result.push(path.join(''));
                    return;
                }

                const letters = map[digits[index]];
                for (const letter of letters) {
                    path.push(letter);
                    backtrack(index + 1);
                    path.pop();
                }
            }

            backtrack(0);
            return result;
        };
        ```

6.  **[51. N 皇后 (N-Queens)](https://leetcode.cn/problems/n-queens/)**
    *   **问题描述**: n 皇后问题研究的是如何将 n 个皇后放置在 n×n 的棋盘上，并且使皇后彼此之间不能相互攻击（任何两个皇后都不得在同一行、同一列或同一条斜线上）。
    *   **回溯思路**:
        *   `路径`: 棋盘的当前布局。
        *   `选择列表`: 在当前行中，可以选择放置皇后的所有列。
        *   `结束条件`: 成功放置了 `n` 行皇后。
        *   在做选择时，需要判断当前位置是否与之前放置的皇后冲突。
    *   **JavaScript 实现**:
        ```javascript
        var solveNQueens = function(n) {
            const result = [];
            const board = new Array(n).fill(0).map(() => new Array(n).fill('.'));

            function isValid(row, col) {
                // 检查列
                for (let i = 0; i < row; i++) {
                    if (board[i][col] === 'Q') return false;
                }
                // 检查 45 度角
                for (let i = row - 1, j = col - 1; i >= 0 && j >= 0; i--, j--) {
                    if (board[i][j] === 'Q') return false;
                }
                // 检查 135 度角
                for (let i = row - 1, j = col + 1; i >= 0 && j < n; i--, j++) {
                    if (board[i][j] === 'Q') return false;
                }
                return true;
            }

            function backtrack(row) {
                if (row === n) {
                    const snapshot = board.map(row => row.join(''));
                    result.push(snapshot);
                    return;
                }

                for (let col = 0; col < n; col++) {
                    if (isValid(row, col)) {
                        board[row][col] = 'Q';
                        backtrack(row + 1);
                        board[row][col] = '.';
                    }
                }
            }

            backtrack(0);
            return result;
        };
        ```

