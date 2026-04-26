## JavaScript 滑动窗口算法详解

滑动窗口算法是一种高效解决数组/字符串问题的技巧，它通过维护一个在数组/字符串上滑动的窗口，动态地更新窗口内的元素，从而达到优化时间复杂度的目的。  它的核心思想是将嵌套循环转换为单循环，降低时间复杂度。

**1. 什么是滑动窗口？**

想象你在一个传送带上，你只能看到一部分货物（窗口）。 你可以移动（滑动）这个窗口，从而查看不同部分的货物。

在算法中，窗口通常是一个数组或字符串的子集，它的大小可以是固定的或可变的。  我们通过移动窗口的起始和结束位置，来遍历整个数组/字符串。

**2. 滑动窗口的适用场景**

*   **寻找满足特定条件的子数组/子字符串：** 例如，找到长度为 k 的子数组的最大和，或者找到包含特定字符的最小子字符串。
*   **解决子数组/子字符串的计数问题：** 例如，计算有多少个子数组的和等于 target。
*   **优化时间复杂度：** 将原本需要 O(n^2) 或更高时间复杂度的嵌套循环问题，优化到 O(n)。

**3. 滑动窗口的实现步骤**

通常情况下，滑动窗口算法的实现包括以下几个步骤：

1.  **初始化窗口：** 定义窗口的起始和结束位置，以及一些必要的变量（例如，窗口内的元素之和、窗口内的元素个数等）。

2.  **滑动窗口：**  循环遍历数组/字符串。
    *   **扩展窗口：**  将窗口的结束位置向右移动一位，并将新的元素加入窗口。
    *   **收缩窗口（可选）：**  如果当前窗口不满足特定条件，或者为了优化空间复杂度，可以尝试将窗口的起始位置向右移动一位，并将旧的元素从窗口中移除，直到窗口满足条件。
    *   **更新结果：**  在每次滑动窗口后，根据题目的要求更新结果（例如，最大值、最小值、计数等）。

3.  **返回结果：**  循环结束后，返回最终的结果。

**4. 滑动窗口的两种常见形式**

*   **固定大小的滑动窗口：**  窗口的大小固定不变。  例如，寻找长度为 k 的子数组的最大和。

*   **可变大小的滑动窗口：** 窗口的大小可以动态调整。  例如，寻找包含特定字符的最小子字符串。

**5. JavaScript 代码模板（通用）**

```javascript
function slidingWindow(arr, target) {
  let left = 0; // 窗口左边界
  let right = 0; // 窗口右边界
  let windowSum = 0; // 窗口内元素之和 (或其他统计值)
  let minLength = Infinity; // 初始化最小长度 (或其他目标值)

  while (right < arr.length) {
    // 1. 扩展窗口
    windowSum += arr[right];
    right++;

    // 2. 根据题目要求，判断是否需要收缩窗口
    while (windowSum >= target) { // 示例：窗口内元素之和大于等于目标值
      // 3. 更新结果
      minLength = Math.min(minLength, right - left);

      // 4. 收缩窗口
      windowSum -= arr[left];
      left++;
    }
  }

  return minLength === Infinity ? 0 : minLength; // 如果没有找到满足条件的窗口，返回 0
}
```

**代码解释：**

*   `left`: 窗口的左边界。
*   `right`: 窗口的右边界。
*   `windowSum`: 窗口内元素的总和。根据题目要求，可以是其他统计值，例如窗口内最大值、最小值、平均值等。
*   `minLength`: 满足条件的最小窗口长度。根据题目要求，可以是其他目标值，例如最大窗口长度、满足条件的窗口数量等。
*   `while (right < arr.length)`:  外层循环，用于扩展窗口，直到窗口的右边界到达数组的末尾。
*   `windowSum += arr[right]; right++;`:  将窗口的右边界向右移动一位，并将新的元素加入窗口。
*   `while (windowSum >= target)`: 内层循环，用于收缩窗口，直到窗口不再满足条件。  这个条件需要根据题目的具体要求进行修改。
*   `minLength = Math.min(minLength, right - left);`:  更新结果。
*   `windowSum -= arr[left]; left++;`: 将窗口的左边界向右移动一位，并将旧的元素从窗口中移除。

**6. LeetCode 典型题目推荐**

以下是一些使用滑动窗口算法解决的 LeetCode 题目，并附带 JavaScript 解题思路：

*   **[3. Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/) (Medium)**

    *   **题目描述：** 给定一个字符串 `s`，找到不包含重复字符的最长子字符串的长度。
    *   **解题思路：** 使用一个哈希表来记录每个字符是否在当前窗口中出现过。  当遇到重复字符时，收缩窗口，直到窗口中不再包含重复字符。
    *   **JavaScript 代码：**

```javascript
function lengthOfLongestSubstring(s) {
  let left = 0;
  let right = 0;
  let maxLength = 0;
  const charSet = new Set();

  while (right < s.length) {
    if (!charSet.has(s[right])) {
      charSet.add(s[right]);
      maxLength = Math.max(maxLength, right - left + 1);
      right++;
    } else {
      charSet.delete(s[left]);
      left++;
    }
  }

  return maxLength;
}
```

*   **[209. Minimum Size Subarray Sum](https://leetcode.com/problems/minimum-size-subarray-sum/) (Medium)**

    *   **题目描述：** 给定一个正整数数组 `nums` 和一个正整数 `target`，找到和大于等于 `target` 的最短连续子数组 `[nums[l], nums[l+1], ..., nums[r-1], nums[r]]` 的长度。如果不存在符合条件的子数组，返回 `0`。
    *   **解题思路：**  使用滑动窗口来找到和大于等于 `target` 的子数组。 当窗口内的元素之和大于等于 `target` 时，尝试收缩窗口，找到更短的满足条件的子数组。
    *   **JavaScript 代码：**

```javascript
function minSubArrayLen(target, nums) {
  let left = 0;
  let right = 0;
  let minLength = Infinity;
  let windowSum = 0;

  while (right < nums.length) {
    windowSum += nums[right];
    right++;

    while (windowSum >= target) {
      minLength = Math.min(minLength, right - left);
      windowSum -= nums[left];
      left++;
    }
  }

  return minLength === Infinity ? 0 : minLength;
}
```

*   **[438. Find All Anagrams in a String](https://leetcode.com/problems/find-all-anagrams-in-a-string/) (Medium)**

    *   **题目描述：**  给定两个字符串 `s` 和 `p`，找到 `s` 中所有 `p` 的异位词的起始索引。  异位词指由相同字母重排列形成的字符串。
    *   **解题思路：** 使用滑动窗口来遍历字符串 `s`。  使用一个哈希表来记录字符串 `p` 中每个字符的频率。  对于字符串 `s` 的每个窗口，检查该窗口内的字符频率是否与 `p` 的字符频率相同。  如果相同，则该窗口是 `p` 的一个异位词。
    *   **JavaScript 代码：**

```javascript
function findAnagrams(s, p) {
  const result = [];
  const pMap = new Map();
  const sMap = new Map();

  // 初始化 pMap
  for (const char of p) {
    pMap.set(char, (pMap.get(char) || 0) + 1);
  }

  let left = 0;
  let right = 0;

  while (right < s.length) {
    // 扩展窗口
    const char = s[right];
    sMap.set(char, (sMap.get(char) || 0) + 1);

    // 当窗口大小等于 p 的长度时，进行比较
    if (right - left + 1 === p.length) {
      let isEqual = true;
      for (const [key, value] of pMap) {
        if (sMap.get(key) !== value) {
          isEqual = false;
          break;
        }
      }

      if (isEqual) {
        result.push(left);
      }

      // 收缩窗口
      const leftChar = s[left];
      sMap.set(leftChar, sMap.get(leftChar) - 1);
      if (sMap.get(leftChar) === 0) {
        sMap.delete(leftChar);
      }
      left++;
    }
    right++;
  }

  return result;
}
```

*   **[76. Minimum Window Substring](https://leetcode.com/problems/minimum-window-substring/) (Hard)**

    *   **题目描述：** 给你一个字符串 `s` 、一个字符串 `t` 。返回 `s` 中涵盖 `t` 所有字符的最小子串。如果 `s` 中不存在涵盖 `t` 所有字符的子串，则返回空字符串 `""` 。
    *   **解题思路：**  和上面的`Find All Anagrams in a String`类似，都需要维护一个哈希表记录需要的字符，然后不断扩展和收缩窗口，更新找到的最小子串。 难度在于字符串`t`的字符可以重复。
    *   **JavaScript 代码：**

```javascript
function minWindow(s, t) {
    if (!s || !t || s.length < t.length) {
        return "";
    }

    const tMap = new Map();
    for (const char of t) {
        tMap.set(char, (tMap.get(char) || 0) + 1);
    }

    let left = 0;
    let right = 0;
    let minLen = Infinity;
    let start = 0;  // 记录最小子串的起始位置
    let matched = 0;  // 记录已匹配的字符数量

    const windowMap = new Map();

    while (right < s.length) {
        const char = s[right];
        if (tMap.has(char)) {
            windowMap.set(char, (windowMap.get(char) || 0) + 1);
            if (windowMap.get(char) === tMap.get(char)) {
                matched++;
            }
        }

        while (matched === tMap.size) {
            if (right - left + 1 < minLen) {
                minLen = right - left + 1;
                start = left;
            }

            const leftChar = s[left];
            if (tMap.has(leftChar)) {
                windowMap.set(leftChar, windowMap.get(leftChar) - 1);
                if (windowMap.get(leftChar) < tMap.get(leftChar)) {
                    matched--;
                }
            }

            left++;
        }
        right++;
    }

    return minLen === Infinity ? "" : s.substring(start, start + minLen);
}
```

**7. 总结**

滑动窗口算法是一种非常有用的算法技巧，可以用来解决很多数组/字符串问题。  理解滑动窗口的核心思想，以及掌握滑动窗口的实现步骤，可以帮助你更高效地解决这类问题。 记住根据不同的题目要求，灵活地调整窗口的扩展和收缩策略，以及更新结果的方式。 多做练习，熟悉各种滑动窗口的变体，才能真正掌握这项技术。

---

### 更多 LeetCode 题目（推荐） ✅
下面补充 8 道与滑动窗口 / 双端队列 / 单调队列相关的题目，包含题目链接、简要描述、解题思路与 JS 参考实现。

#### 1) 3. Longest Substring Without Repeating Characters - Medium
* 链接: https://leetcode.cn/problems/longest-substring-without-repeating-characters/
* 描述: 求不含重复字符的最长子串长度。
* 思路: 可变窗口 + 哈希表（记录字符最后位置或是否出现），当遇到重复字符时收缩左边界。
* JS 代码:
```javascript
function lengthOfLongestSubstring(s) {
  const last = new Map();
  let left = 0, ans = 0;
  for (let i = 0; i < s.length; i++) {
    if (last.has(s[i]) && last.get(s[i]) >= left) {
      left = last.get(s[i]) + 1;
    }
    last.set(s[i], i);
    ans = Math.max(ans, i - left + 1);
  }
  return ans;
}
```

#### 2) 30. Substring with Concatenation of All Words - Hard
* 链接: https://leetcode.cn/problems/substring-with-concatenation-of-all-words/
* 描述: 在字符串中找到所有由 words 中所有单词恰好一次且无间隔连在一起的起始位置。
* 思路: 固定每个单词长度，用滑动窗口 + 哈希比较（可用分段滑动减少复杂度）。
* JS 代码（思路示例）:
```javascript
function findSubstring(s, words) {
  if (!s || !words.length) return [];
  const wordLen = words[0].length, total = wordLen * words.length;
  const need = new Map();
  for (const w of words) need.set(w, (need.get(w)||0)+1);
  const res = [];
  for (let i = 0; i < wordLen; i++) {
    let left = i, count = 0, window = new Map();
    for (let j = i; j + wordLen <= s.length; j += wordLen) {
      const word = s.slice(j, j + wordLen);
      if (need.has(word)) {
        window.set(word, (window.get(word)||0)+1);
        count++;
        while (window.get(word) > need.get(word)) {
          const leftWord = s.slice(left, left + wordLen);
          window.set(leftWord, window.get(leftWord)-1);
          left += wordLen; count--;
        }
        if (count === words.length) res.push(left);
      } else {
        window.clear(); count = 0; left = j + wordLen;
      }
    }
  }
  return res;
}
```

#### 3) 76. Minimum Window Substring - Hard
* 链接: https://leetcode.cn/problems/minimum-window-substring/
* 描述: 找到字符串 s 中包含 t 所有字符的最小子串。
* 思路: 可变窗口 + 哈希表记录所需字符计数，扩张直到覆盖，再尽量收缩更新答案。
* JS 代码:
```javascript
function minWindow(s, t) {
  if (!s || !t || s.length < t.length) return "";
  const need = new Map();
  for (const c of t) need.set(c, (need.get(c)||0)+1);
  let left = 0, right = 0, valid = 0, start = 0, len = Infinity;
  const window = new Map();
  while (right < s.length) {
    const c = s[right++];
    if (need.has(c)) {
      window.set(c, (window.get(c)||0)+1);
      if (window.get(c) === need.get(c)) valid++;
    }
    while (valid === need.size) {
      if (right - left < len) { start = left; len = right - left; }
      const d = s[left++];
      if (need.has(d)) {
        if (window.get(d) === need.get(d)) valid--;
        window.set(d, window.get(d)-1);
      }
    }
  }
  return len === Infinity ? "" : s.substring(start, start + len);
}
```

#### 4) 209. Minimum Size Subarray Sum - Medium
* 链接: https://leetcode.cn/problems/minimum-size-subarray-sum/
* 描述: 给定数组和目标值 target，求最短连续子数组长度，和 >= target。
* 思路: 固定右边界扩张并维护窗口和，满足条件后收缩左边界更新最短长度。
* JS 代码: 前面已展示，略。

#### 5) 424. Longest Repeating Character Replacement - Medium
* 链接: https://leetcode.cn/problems/longest-repeating-character-replacement/
* 描述: 在字符串中最多替换 k 个字符，使得最长重复字符子串尽可能长，返回该长度。
* 思路: 固定窗口扩大并维护窗口内最高频字符 countMax，当窗口长度 - countMax > k 时收缩窗口。
* JS 代码:
```javascript
function characterReplacement(s, k) {
  const count = new Array(26).fill(0);
  let left = 0, right = 0, maxCount = 0, res = 0;
  while (right < s.length) {
    maxCount = Math.max(maxCount, ++count[s.charCodeAt(right++) - 65]);
    while (right - left - maxCount > k) {
      count[s.charCodeAt(left++) - 65]--;
    }
    res = Math.max(res, right - left);
  }
  return res;
}
```

#### 6) 239. Sliding Window Maximum - Hard (双端队列/单调队列)
* 链接: https://leetcode.cn/problems/sliding-window-maximum/
* 描述: 给定数组和窗口大小 k，返回每个窗口中的最大值。
* 思路: 使用双端队列存储索引，保证队列单调递减，队头为当前窗口最大值。
* JS 代码: 前面已展示（也可复用）。

#### 7) 904. Fruit Into Baskets - Medium
* 链接: https://leetcode.cn/problems/fruit-into-baskets/
* 描述: 在数组中寻找包含最多两种不同元素的最长子数组长度（类似于限制不同字符数的滑动窗口）。
* 思路: 可变窗口 + 哈希表记录元素频次，当不同元素数超过 2 时收缩窗口。
* JS 代码:
```javascript
function totalFruit(fruits) {
  const count = new Map();
  let left = 0, res = 0;
  for (let right = 0; right < fruits.length; right++) {
    count.set(fruits[right], (count.get(fruits[right]) || 0) + 1);
    while (count.size > 2) {
      count.set(fruits[left], count.get(fruits[left]) - 1);
      if (count.get(fruits[left]) === 0) count.delete(fruits[left]);
      left++;
    }
    res = Math.max(res, right - left + 1);
  }
  return res;
}
```

#### 8) 862. Shortest Subarray with Sum at Least K - Hard (单调队列)
* 链接: https://leetcode.cn/problems/shortest-subarray-with-sum-at-least-k/
* 描述: 给定含负数数组，求和至少为 K 的最短子数组长度，若不存在返回 -1。
* 思路: 使用前缀和 + 单调队列（维护递增的前缀和索引队列），当当前前缀和减队头前缀和 >= K 时更新答案并弹出队头；同时保持队尾前缀和单调递增以优化。
* JS 代码（简化）:
```javascript
function shortestSubarray(A, K) {
  const n = A.length;
  const P = new Array(n+1).fill(0);
  for (let i=0;i<n;i++) P[i+1]=P[i]+A[i];
  const dq = [];
  let ans = Infinity;
  for (let i=0;i<P.length;i++){
    while (dq.length && P[i]-P[dq[0]]>=K) { ans = Math.min(ans, i-dq.shift()); }
    while (dq.length && P[i]<=P[dq[dq.length-1]]) dq.pop();
    dq.push(i);
  }
  return ans === Infinity ? -1 : ans;
}

---

以上题目覆盖了滑动窗口的常见变体：固定/可变窗口、频次统计、双端队列与单调队列等。可按需将其中某些题目单独拆分为详细解析与复杂度/易错点补充。
