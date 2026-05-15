## JavaScript 动态规划算法详解

动态规划（Dynamic Programming，简称 DP）是一种通过将问题分解成相互重叠的子问题，并解决这些子问题一次，将结果保存起来，避免重复计算，从而高效地解决复杂问题的算法思想。  它通常用于优化递归解决方案，特别是那些具有大量重复子问题的递归解决方案。

**1. 动态规划的核心思想**

*   **分解子问题：** 将原问题分解成若干个相互重叠的子问题。
*   **状态定义：**  定义问题的状态。状态通常表示子问题的解。 例如，`dp[i]` 可以表示以 `i` 结尾的子数组的最大和。
*   **状态转移方程：**  定义状态之间的关系。  状态转移方程描述了如何从一个或多个子问题的解，计算出当前问题的解。  例如，`dp[i] = Math.max(dp[i-1] + nums[i], nums[i])`。
*   **记忆化存储：** 将已经计算过的子问题的解保存起来，避免重复计算。 通常使用数组或哈希表来存储。
*   **自底向上：**  从最小的子问题开始，逐步计算出更大的子问题，直到计算出原问题的解。

**2. 动态规划的适用场景**

*   **优化问题：** 寻找最优解，例如最大值、最小值、最长路径、最短路径等。
*   **计数问题：**  计算满足特定条件的方案数。
*   **具有重叠子问题：**  问题的解决方案可以通过组合子问题的解决方案来获得，并且这些子问题可以重复出现。
*   **具有最优子结构：**  问题的最优解包含其子问题的最优解。

**3. 动态规划的实现方式**

*   **自顶向下（记忆化搜索）：** 使用递归的方式，从原问题开始，逐步分解成子问题。  在递归的过程中，将已经计算过的子问题的解保存起来，避免重复计算。

*   **自底向上（递推）：**  从最小的子问题开始，逐步计算出更大的子问题，直到计算出原问题的解。  通常使用循环的方式实现。

**4. 动态规划的实现步骤（通用）**

1.  **定义状态：** 明确 `dp[i]` 代表什么含义。  例如，`dp[i]` 可以表示第 `i` 个元素的最优解，前 `i` 个元素的最优解，或者以第 `i` 个元素结尾的某个问题的解。

2.  **状态转移方程：** 找到 `dp[i]` 和 `dp[i-1]` (或 `dp[i-k]`) 之间的关系。  状态转移方程描述了如何通过子问题的解来计算当前问题的解。

3.  **初始化：**  确定 `dp[0]` 或者其他初始状态的值。  初始化是动态规划的基础，必须正确设置。

4.  **计算顺序：**  确定计算 `dp` 数组的顺序。  自底向上通常是正向循环，而自顶向下需要考虑递归的顺序。

5.  **返回结果：** 返回 `dp[n]` (或者其他最终状态) 作为问题的解。

**5. JavaScript 代码模板（通用） - 自底向上 (递推)**

```javascript
function dynamicProgramming(input) {
  const n = input.length;
  const dp = new Array(n + 1).fill(0); // 初始化 dp 数组 (状态定义)

  // 初始化 base case (初始化)
  dp[0] = baseCaseValue; // 例如：dp[0] = 0;

  // 循环计算 dp 数组 (状态转移)
  for (let i = 1; i <= n; i++) {
    // 根据状态转移方程计算 dp[i]
    dp[i] = ... dp[i-1] ... input[i-1] ...; // 例如： dp[i] = Math.max(dp[i-1] + input[i-1], input[i-1]);
  }

  // 返回结果 (返回结果)
  return dp[n];
}
```

**6. JavaScript 代码模板（通用） - 自顶向下 (记忆化搜索)**

```javascript
function dynamicProgrammingMemoization(input) {
  const n = input.length;
  const memo = new Array(n + 1).fill(null); // 初始化 memo 数组 (记忆化)

  function solve(i) {
    // Base case
    if (i === 0) {
      return baseCaseValue; // 例如：return 0;
    }

    // 检查 memo 中是否存在结果
    if (memo[i] !== null) {
      return memo[i];
    }

    // 递归计算 (状态转移)
    memo[i] = ... solve(i - 1) ... input[i - 1] ...;  // 例如： memo[i] = Math.max(solve(i - 1) + input[i - 1], input[i - 1]);

    return memo[i];
  }

  return solve(n);
}
```

**7. LeetCode 典型题目推荐**

以下是一些使用动态规划算法解决的 LeetCode 题目，并附带 JavaScript 解题思路：

*   **[70. Climbing Stairs](https://leetcode.com/problems/climbing-stairs/) (Easy)**

    *   **题目描述：**  假设你正在爬楼梯。需要 `n` 阶你才能到达楼顶。 每次你可以爬 1 或 2 个台阶。你有多少种不同的方法可以爬到楼顶呢？
    *   **解题思路：**  这是一个典型的斐波那契数列问题。  `dp[i]` 表示爬到第 `i` 阶楼梯的方法数。  状态转移方程为 `dp[i] = dp[i-1] + dp[i-2]`。
    *   **JavaScript 代码 (自底向上):**

```javascript
function climbStairs(n) {
  const dp = new Array(n + 1);
  dp[0] = 1;
  dp[1] = 1;

  for (let i = 2; i <= n; i++) {
    dp[i] = dp[i - 1] + dp[i - 2];
  }

  return dp[n];
}
```

    *   **JavaScript 代码 (自顶向下 - 记忆化搜索):**

```javascript
function climbStairsMemoization(n) {
    const memo = new Array(n + 1).fill(null);

    function solve(i) {
        if (i === 0 || i === 1) {
            return 1;
        }

        if (memo[i] !== null) {
            return memo[i];
        }

        memo[i] = solve(i - 1) + solve(i - 2);
        return memo[i];
    }

    return solve(n);
}
```

*   **[53. Maximum Subarray](https://leetcode.com/problems/maximum-subarray/) (Medium)**

    *   **题目描述：**  给你一个整数数组 `nums` ，请你找出一个具有最大和的连续子数组（子数组最少包含一个元素），返回其最大和。
    *   **解题思路：** `dp[i]` 表示以 `nums[i]` 结尾的子数组的最大和。  状态转移方程为 `dp[i] = Math.max(dp[i-1] + nums[i], nums[i])`。
    *   **JavaScript 代码：**

```javascript
function maxSubArray(nums) {
  const dp = new Array(nums.length).fill(0);
  dp[0] = nums[0];
  let maxSum = nums[0];

  for (let i = 1; i < nums.length; i++) {
    dp[i] = Math.max(dp[i - 1] + nums[i], nums[i]);
    maxSum = Math.max(maxSum, dp[i]);
  }

  return maxSum;
}
```

*   **[198. House Robber](https://leetcode.com/problems/house-robber/) (Medium)**

    *   **题目描述：**  你是一个专业的小偷，计划偷窃沿街的房屋。每间房内都藏有一定的现金，影响你偷窃的唯一制约因素就是相邻的房屋装有相互连通的防盗系统，*如果两间相邻的房屋在同一晚上被小偷闯入，系统会自动报警*。 给定一个代表每个房屋存放金额的非负整数数组，计算你 *不触动警报装置的情况下* ，一夜之内能够偷窃到的最高金额。
    *   **解题思路：** `dp[i]` 表示偷窃前 `i` 间房屋能够获得的最大金额。  状态转移方程为 `dp[i] = Math.max(dp[i-1], dp[i-2] + nums[i])`。
    *   **JavaScript 代码：**

```javascript
function rob(nums) {
  const n = nums.length;
  if (n === 0) return 0;
  if (n === 1) return nums[0];

  const dp = new Array(n);
  dp[0] = nums[0];
  dp[1] = Math.max(nums[0], nums[1]);

  for (let i = 2; i < n; i++) {
    dp[i] = Math.max(dp[i - 1], dp[i - 2] + nums[i]);
  }

  return dp[n - 1];
}
```

*   **[322. Coin Change](https://leetcode.com/problems/coin-change/) (Medium)**

    *   **题目描述：** 给你一个整数数组 `coins` ，表示不同面额的硬币；以及一个整数 `amount` ，表示总金额。 计算并返回可以凑成总金额所需的 *最少的硬币个数* 。如果没有任何一种硬币组合能组成总金额，返回 `-1` 。 你可以认为每种硬币的数量是无限的。
    *   **解题思路：** `dp[i]` 表示凑成金额 `i` 所需的最少硬币个数。 状态转移方程为 `dp[i] = Math.min(dp[i], dp[i - coin] + 1)`，其中 `coin` 是 `coins` 数组中的每个硬币面额。
    *   **JavaScript 代码：**

```javascript
function coinChange(coins, amount) {
  const dp = new Array(amount + 1).fill(amount + 1); // 初始化为 amount + 1, 表示无法凑成
  dp[0] = 0; // 凑成金额 0 需要 0 个硬币

  for (let i = 1; i <= amount; i++) {
    for (const coin of coins) {
      if (i >= coin) {
        dp[i] = Math.min(dp[i], dp[i - coin] + 1);
      }
    }
  }

  return dp[amount] > amount ? -1 : dp[amount];
}
```

*   **[62. Unique Paths](https://leetcode.com/problems/unique-paths/) (Medium)**

    *   **题目描述：**  一个机器人位于一个 `m x n` 网格的左上角 （起始点在下图中标记为 “Start” ）。 机器人每次只能向下或者向右移动一步。机器人试图达到网格的右下角（在下图中标记为 “Finish” ）。 问总共有多少条不同的路径？
    *   **解题思路：** `dp[i][j]`表示从起点到`(i, j)`的路径总数。 转移方程是`dp[i][j] = dp[i-1][j] + dp[i][j-1]`。
    *   **JavaScript 代码：**

```javascript
function uniquePaths(m, n) {
    const dp = Array(m).fill(null).map(() => Array(n).fill(0));

    // 初始化第一行和第一列，只有一种走法
    for (let i = 0; i < m; i++) {
        dp[i][0] = 1;
    }
    for (let j = 0; j < n; j++) {
        dp[0][j] = 1;
    }

    // 动态规划，计算每个格子的路径总数
    for (let i = 1; i < m; i++) {
        for (let j = 1; j < n; j++) {
            dp[i][j] = dp[i - 1][j] + dp[i][j - 1];
        }
    }

    return dp[m - 1][n - 1];
}
```

**8. 总结**

动态规划是一种强大的算法思想，可以用来解决很多复杂问题。  理解动态规划的核心思想，掌握状态定义、状态转移方程、初始化和计算顺序等关键步骤，可以帮助你更高效地解决这类问题。  多做练习，熟悉各种动态规划的变体，才能真正掌握这项技术。
