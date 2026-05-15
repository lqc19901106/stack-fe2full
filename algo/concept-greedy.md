
# 贪心算法 (Greedy Algorithm)

贪心算法是一种在每一步选择中都采取在当前状态下最好或最优（即最有利）的选择，从而希望导致结果是全局最好或最优的算法。

贪心算法并不从整体最优上加以考虑，它所作出的选择只是在某种意义上的局部最优选择。当然，希望贪心算法得到的最终结果也是整体最优的。

## 核心思想

1.  **贪心选择性质 (Greedy Choice Property)**: 这是贪心算法的核心。一个全局最优解可以通过局部最优（贪心）选择来达到。换句话说，当我们考虑做何种选择时，我们只考虑对当前问题最佳的选择，而不考虑子问题的解。
2.  **最优子结构 (Optimal Substructure)**: 一个问题的最优解包含其子问题的最优解。这意味着问题可以被分解成更小的、独立的部分。

## 贪心算法与动态规划的区别

*   **动态规划**: 会保存以前的运算结果，并根据以前的结果对当前进行选择，有回退功能。通常是自底向上解决问题。
*   **贪心算法**: 总是做出当前最好的选择，不能回退。一旦做出选择，就不能改变。通常是自顶向下解决问题。

## 贪心算法解题步骤

1.  **分解**: 将问题分解为若干个子问题。
2.  **解决**: 找出合适的贪心策略，求解每个子问题的最优解。
3.  **合并**: 将子问题的解合并为原问题的解。

## 经典 LeetCode 题目

以下是一些可以用贪心算法解决的经典 LeetCode 题目：

1.  **[455. 分发饼干 (Assign Cookies)](https://leetcode.cn/problems/assign-cookies/)**
    *   **问题描述**: 你有一群孩子和一堆饼干，每个孩子有一个饥饿度 `g[i]`，每个饼干有一个尺寸 `s[j]`。只有当 `s[j] >= g[i]` 时，我们才能将饼干 `j` 分给孩子 `i`。你的目标是尽可能满足越多数量的孩子。
    *   **贪心策略**: 优先用最小的饼干满足最不“贪心”的孩子。或者说，用最小的饼干去满足饥饿度最小的孩子。
    *   **JavaScript 实现**:
        ```javascript
        var findContentChildren = function(g, s) {
            g.sort((a, b) => a - b);
            s.sort((a, b) => a - b);
            let childIndex = 0;
            let cookieIndex = 0;
            while (childIndex < g.length && cookieIndex < s.length) {
                if (s[cookieIndex] >= g[childIndex]) {
                    childIndex++;
                }
                cookieIndex++;
            }
            return childIndex;
        };
        ```

2.  **[122. 买卖股票的最佳时机 II (Best Time to Buy and Sell Stock II)](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-ii/)**
    *   **问题描述**: 给定一个数组，它的第 `i` 个元素是一支给定股票第 `i` 天的价格。设计一个算法来计算你所能获取的最大利润。你可以尽可能地完成更多的交易（多次买卖一支股票）。
    *   **贪心策略**: 只要今天的价格比昨天高，就在昨天买入，今天卖出，然后累加利润。这相当于收集所有上坡的利润。
    *   **JavaScript 实现**:
        ```javascript
        var maxProfit = function(prices) {
            let totalProfit = 0;
            for (let i = 1; i < prices.length; i++) {
                if (prices[i] > prices[i - 1]) {
                    totalProfit += prices[i] - prices[i - 1];
                }
            }
            return totalProfit;
        };
        ```

3.  **[55. 跳跃游戏 (Jump Game)](https://leetcode.cn/problems/jump-game/)**
    *   **问题描述**: 给定一个非负整数数组，你最初位于数组的第一个位置。数组中的每个元素代表你在该位置可以跳跃的最大长度。判断你是否能够到达最后一个位置。
    *   **贪心策略**: 维护一个当前能够到达的最远距离。遍历数组，如果当前位置 `i` 小于等于最远距离，说明可以到达当前位置，然后用 `i + nums[i]` 更新最远距离。如果最远距离大于等于数组最后一个下标，则返回 `true`。
    *   **JavaScript 实现**:
        ```javascript
        var canJump = function(nums) {
            let maxReach = 0;
            for (let i = 0; i < nums.length; i++) {
                if (i > maxReach) {
                    return false; // 无法到达当前位置
                }
                maxReach = Math.max(maxReach, i + nums[i]);
                if (maxReach >= nums.length - 1) {
                    return true; // 已能到达或越过终点
                }
            }
            return true;
        };
        ```

4.  **[435. 无重叠区间 (Non-overlapping Intervals)](https://leetcode.cn/problems/non-overlapping-intervals/)**
    *   **问题描述**: 给定一个区间的集合，找到需要移除区间的最小数量，使剩余区间互不重叠。
    *   **贪心策略**: 这是一个经典的区间调度问题。将所有区间按结束时间升序排序。选择第一个区间，然后遍历剩下的区间，如果区间的起始时间大于等于已选区间的结束时间，则选择该区间。需要移除的区间数等于总区间数减去选择的区间数。
    *   **JavaScript 实现**:
        ```javascript
        var eraseOverlapIntervals = function(intervals) {
            if (intervals.length === 0) {
                return 0;
            }
            intervals.sort((a, b) => a[1] - b[1]);
            let count = 1; // 记录非重叠区间的数量
            let end = intervals[0][1];
            for (let i = 1; i < intervals.length; i++) {
                if (intervals[i][0] >= end) {
                    end = intervals[i][1];
                    count++;
                }
            }
            return intervals.length - count;
        };
        ```

5.  **[763. 划分字母区间 (Partition Labels)](https://leetcode.cn/problems/partition-labels/)**
    *   **问题描述**: 字符串 `S` 由小写字母构成。我们要把这个字符串划分为尽可能多的片段，同一个字母只会出现在其中的一个片段。返回一个表示每个字符串片段的长度的列表。
    *   **贪心策略**: 首先，遍历一次字符串，记录每个字符最后出现的位置。然后再次遍历字符串，维护当前片段的结束位置 `end`。对于每个字符，更新 `end` 为其最后出现位置和当前 `end` 的较大值。当遍历到 `end` 位置时，就找到了一个片段。
    *   **JavaScript 实现**:
        ```javascript
        var partitionLabels = function(s) {
            const last = new Array(26);
            const aCode = 'a'.charCodeAt(0);
            for (let i = 0; i < s.length; i++) {
                last[s.charCodeAt(i) - aCode] = i;
            }
            const partitions = [];
            let start = 0;
            let end = 0;
            for (let i = 0; i < s.length; i++) {
                end = Math.max(end, last[s.charCodeAt(i) - aCode]);
                if (i === end) {
                    partitions.push(end - start + 1);
                    start = i + 1;
                }
            }
            return partitions;
        };
        ```

6.  **[135. 分发糖果 (Candy)](https://leetcode.cn/problems/candy/)**
    *   **问题描述**: 老师想给孩子们分发糖果，有 N 个孩子站成了一条直线，老师会根据每个孩子的表现，预先给他们评分。你需要按照以下要求，帮助老师给每个孩子分发糖果：每个孩子至少分配到 1 个糖果。相邻的孩子中，评分高的孩子必须获得更多的糖果。
    *   **贪心策略**: 这道题需要两次遍历。第一次从左到右遍历，保证右边的孩子评分比左边高时，糖果数比左边多。第二次从右到左遍历，保证左边的孩子评分比右边高时，糖果数比右边多。最终每个孩子获得的糖果数是两次遍历结果的较大值。
    *   **JavaScript 实现**:
        ```javascript
        var candy = function(ratings) {
            const n = ratings.length;
            const candies = new Array(n).fill(1);
            // 从左到右
            for (let i = 1; i < n; i++) {
                if (ratings[i] > ratings[i - 1]) {
                    candies[i] = candies[i - 1] + 1;
                }
            }
            // 从右到左
            for (let i = n - 2; i >= 0; i--) {
                if (ratings[i] > ratings[i + 1]) {
                    candies[i] = Math.max(candies[i], candies[i + 1] + 1);
                }
            }
            return candies.reduce((sum, num) => sum + num, 0);
        };
        ```

7.  **[452. 用最少数量的箭引爆气球 (Minimum Number of Arrows to Burst Balloons)](https://leetcode.cn/problems/minimum-number-of-arrows-to-burst-balloons/)**
    *   **问题描述**: 在二维空间中有许多球形的气球。对于每个气球，提供的输入是水平方向上，气球直径的开始和结束坐标。一支弓箭可以从 x 轴上的任何点垂直向上射出。如果一支箭的坐标是 x，它可以引爆所有满足 `x_start <= x <= x_end` 的气球。求最少需要多少支箭才能引爆所有气球。
    *   **贪心策略**: 这与“无重叠区间”问题非常相似。将所有气球按结束坐标升序排序。射出第一支箭，位置是第一个气球的结束坐标。然后遍历剩下的气球，所有在这支箭范围内的气球都会被引爆。对于没有被引爆的气球，选择第一个，并以同样的方式处理。
    *   **JavaScript 实现**:
        ```javascript
        var findMinArrowShots = function(points) {
            if (points.length === 0) {
                return 0;
            }
            points.sort((a, b) => a[1] - b[1]);
            let arrows = 1;
            let arrowPos = points[0][1];
            for (let i = 1; i < points.length; i++) {
                if (points[i][0] > arrowPos) {
                    arrows++;
                    arrowPos = points[i][1];
                }
            }
            return arrows;
        };
        ```

8.  **[56. 合并区间 (Merge Intervals)](https://leetcode.cn/problems/merge-intervals/)**
    *   **问题描述**: 给出一个区间的集合，请合并所有重叠的区间。
    *   **贪心策略**: 将所有区间按起始时间升序排序。然后遍历排序后的区间，如果当前区间的起始时间小于等于前一个合并后区间的结束时间，说明它们有重叠，就合并它们（更新结束时间为两者结束时间的最大值）。否则，它们不重叠，就将当前区间作为一个新的合并区间。
    *   **JavaScript 实现**:
        ```javascript
        var merge = function(intervals) {
            if (intervals.length === 0) {
                return [];
            }
            intervals.sort((a, b) => a[0] - b[0]);
            const merged = [intervals[0]];
            for (let i = 1; i < intervals.length; i++) {
                const last = merged[merged.length - 1];
                if (intervals[i][0] <= last[1]) {
                    last[1] = Math.max(last[1], intervals[i][1]);
                } else {
                    merged.push(intervals[i]);
                }
            }
            return merged;
        };
        ```

