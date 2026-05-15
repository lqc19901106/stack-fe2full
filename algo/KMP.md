# KMP 算法详解

### 1. 什么是 KMP 算法？

KMP 算法是一种高效的字符串匹配算法，由 Donald Knuth、Vaughan Pratt 和 James Morris 在 1977 年联合发布，因此以他们三人的姓氏首字母命名。

**核心目标**：在一个长字符串（文本串 `text`）中，快速查找一个短字符串（模式串 `pattern`）的出现位置。

相比于朴素的暴力匹配算法，KMP 的主要优势在于它能**利用匹配失败后的信息**，避免文本串指针的回溯，从而将时间复杂度从 O(m*n) 优化到 O(m+n)，其中 m 是文本串的长度，n 是模式串的长度。

### 2. 朴素算法的弊端

让我们先看看朴素的暴力匹配（Brute Force）是如何工作的：

1.  将文本串的 `i` 指针和模式串的 `j` 指针都对齐到起始位置。
2.  逐个比较字符 `text[i]` 和 `pattern[j]`。
3.  如果相等，则 `i` 和 `j` 都向后移动一位。
4.  如果**不相等**，则：
    *   将 `j` 指针重置为 0（模式串回到开头）。
    *   将 `i` 指针**回溯**到本次匹配开始位置的**下一个字符**。
5.  重复此过程，直到找到匹配或遍历完文本串。

**示例**：
`text = "ABABACABAB"`
`pattern = "ABABAC"`

当 `i=5`, `j=5` 时，`text[5]` 是 'C'，`pattern[5]` 也是 'C'，匹配成功。但如果 `pattern` 是 `"ABABAD"`，那么在 `j=5` 时会发生失配。

`text:    A B A B A C ...`
`pattern: A B A B A D`  (在 D 处失配)

此时，朴素算法会将 `i` 回溯到 `1`，`j` 回到 `0`，然后重新开始比较，这浪费了之前已经匹配过的信息（我们已经知道 `text` 的前五个字符是 "ABABA"）。

### 3. KMP 的核心思想：`next` 数组

KMP 算法的精髓在于，当发生不匹配时，它不会简单地将模式串移回起点，而是根据已经匹配过的内容，计算出一个**最佳的移动距离**，从而跳过不必要的比较。

这个“最佳移动距离”的信息，被预先计算并存储在一个叫做 **`next` 数组**（也常被称为“部分匹配表”或“前缀函数”）中。

#### `next` 数组是什么？

`next` 数组是针对**模式串 `pattern`** 构建的。`next[j]` 的值表示在 `pattern` 的子串 `pattern[0...j]` 中，**最长的相等的前缀和后缀**的长度。

**定义**：
*   **前缀**：指不包含最后一个字符的所有头部子串。例如，"apple" 的前缀有 "a", "ap", "app", "appl"。
*   **后缀**：指不包含第一个字符的所有尾部子串。例如，"apple" 的后缀有 "e", "le", "ple", "pple"。
*   **最长相等前后缀**：在 `pattern[0...j]` 中，找到一个最长的前缀，使得它等于一个后缀。

**示例**：`pattern = "ababaca"`

| j | 子串 `pattern[0...j]` | 前缀 | 后缀 | 最长相等前后缀 | `next[j]` |
|---|---|---|---|---|---|
| 0 | "a" | (空) | (空) | (空) | 0 |
| 1 | "ab" | "a" | "b" | (空) | 0 |
| 2 | "aba" | "a", "ab" | "a", "ba" | "a" | 1 |
| 3 | "abab" | "a", "ab", "aba" | "b", "ab", "bab" | "ab" | 2 |
| 4 | "ababa" | "a", "ab", "aba", "abab" | "a", "ba", "aba", "baba" | "aba" | 3 |
| 5 | "ababac"| ... | ... | (空) | 0 |
| 6 | "ababaca"| ... | ... | "a" | 1 |

所以，对于 `pattern = "ababaca"`，其 `next` 数组为 `[0, 0, 1, 2, 3, 0, 1]`。

#### 如何利用 `next` 数组？

当 `text[i]` 和 `pattern[j]` 发生不匹配时：
*   我们知道在不匹配发生前，`text` 中 `i` 指针之前的 `j` 个字符与 `pattern` 的前 `j` 个字符是匹配的（即 `text[i-j ... i-1] == pattern[0 ... j-1]`）。
*   `next[j-1]` 告诉我们，在 `pattern[0 ... j-1]` 这段已匹配的字符串中，其前缀和后缀有多长是相同的。
*   这意味着我们**不需要回溯文本串的 `i` 指针**，只需将模式串的 `j` 指针移动到 `next[j-1]` 的位置，然后让 `text[i]` 和新的 `pattern[j]` 继续比较。

这相当于将模式串向右滑动 `j - next[j-1]` 位，使得模式串的一个前缀对齐到文本串的一个后缀上，然后继续比较。

### 4. JavaScript 实现

#### a. 构建 `next` 数组

```javascript
function computeNext(pattern) {
    const n = pattern.length;
    const next = new Array(n).fill(0);

    // `length` 表示当前最长相等前后缀的长度
    // `i` 是遍历模式串的指针
    for (let i = 1, length = 0; i < n; i++) {
        // 如果不匹配，则回溯 `length`
        // length > 0 是为了防止 length 变成负数
        // 我们利用已经计算好的 next[length - 1] 来找到更短的相等前后缀
        while (length > 0 && pattern[i] !== pattern[length]) {
            length = next[length - 1];
        }

        // 如果匹配，则最长相等前后缀长度加一
        if (pattern[i] === pattern[length]) {
            length++;
        }

        // 记录当前位置的最长相等前后缀长度
        next[i] = length;
    }
    return next;
}
```
**测试 `next` 数组构建**:
```javascript
console.log(computeNext("ababaca")); // 输出: [0, 0, 1, 2, 3, 0, 1]
console.log(computeNext("abacaba")); // 输出: [0, 0, 1, 0, 1, 2, 3]
console.log(computeNext("aaaaa"));   // 输出: [0, 1, 2, 3, 4]
```

#### b. KMP 搜索算法

```javascript
function kmpSearch(text, pattern) {
    const m = text.length;
    const n = pattern.length;

    if (n === 0) return 0; // 空模式串在开头匹配
    if (m < n) return -1;  // 文本串比模式串还短

    const next = computeNext(pattern);
    const result = [];

    // `i` 是文本串指针, `j` 是模式串指针
    for (let i = 0, j = 0; i < m; i++) {
        // 如果不匹配，利用 next 数组移动模式串指针 j
        // i 指针保持不变
        while (j > 0 && text[i] !== pattern[j]) {
            j = next[j - 1];
        }

        // 如果匹配，则模式串指针 j 后移
        if (text[i] === pattern[j]) {
            j++;
        }

        // 如果 j 到达模式串末尾，说明完全匹配
        if (j === n) {
            // 找到了一个匹配，记录起始位置
            result.push(i - n + 1);
            
            // 继续向后查找其他匹配
            // 将 j 移动到 next[j-1]，寻找下一个可能的匹配起点
            j = next[j - 1];
        }
    }

    // 如果只想找第一个匹配，可以修改为：
    // if (j === n) {
    //     return i - n + 1; // 返回第一个匹配的索引
    // }
    // ...
    // return -1; // 未找到匹配

    return result; // 返回所有匹配的起始索引数组
}
```

### 5. 如何应用 KMP？

#### a. 查找字符串出现位置

这是 KMP 最直接的应用。

```javascript
const text = "ababcababa_ababcababd";
const pattern = "ababcababd";

const occurrences = kmpSearch(text, pattern);
console.log(`'${pattern}' found at indices:`, occurrences); // [10]

const text2 = "ababab";
const pattern2 = "aba";
console.log(`'${pattern2}' found at indices:`, kmpSearch(text2, pattern2)); // [0, 2]
```

#### b. 检查字符串的周期性

一个字符串 `S` 如果可以由其一个前缀 `P` 重复若干次构成，那么 `S` 就具有周期性。
例如，`S = "ababab"`，其前缀 `P = "ab"` 重复 3 次构成 `S`。

**判断方法**：
如果一个长度为 `n` 的字符串 `S` 具有周期性，并且其最小周期长度为 `L`，那么 `n` 必须是 `L` 的整数倍，并且 `S` 的前 `n-L` 个字符必须等于后 `n-L` 个字符。

这恰好与 `next` 数组的定义相关！
`next[n-1]` 表示 `S` 的最长相等前后缀的长度。
令 `L = n - next[n-1]`。
如果 `L` 能够整除 `n`，那么 `S` 的最小周期就是 `L`。

```javascript
function findSmallestPeriod(str) {
    const n = str.length;
    if (n === 0) return 0;
    
    const next = computeNext(str);
    const lastNextVal = next[n - 1];
    const possiblePeriod = n - lastNextVal;

    // 如果长度能被可能周期整除，则该周期有效
    if (lastNextVal > 0 && n % possiblePeriod === 0) {
        return possiblePeriod;
    }
    
    // 否则，整个字符串本身是最小周期
    return n;
}

console.log(findSmallestPeriod("ababab")); // 2 (最小周期是 "ab")
console.log(findSmallestPeriod("abcabcabc")); // 3 (最小周期是 "abc")
console.log(findSmallestPeriod("abac"));   // 4 (没有更小的周期)
```

### 6. 复杂度分析

*   **时间复杂度**: O(m + n)
    *   `computeNext` 函数的时间复杂度是 O(n)，因为 `i` 指针从不回溯。
    *   `kmpSearch` 函数的时间复杂度是 O(m)，因为文本串的 `i` 指针也从不回溯。虽然内部有 `while` 循环，但 `j` 指针的移动总次数是有限的，均摊下来是 O(m)。
*   **空间复杂度**: O(n)
    *   需要一个长度为 `n` 的 `next` 数组来存储模式串的部分匹配信息。

### 7. 经典 LeetCode 题目

#### a. 28. 找出字符串中第一个匹配项的下标 (Find the Index of the First Occurrence in a String)
*   **题目链接**: [https://leetcode.cn/problems/find-the-index-of-the-first-occurrence-in-a-string/](https://leetcode.cn/problems/find-the-index-of-the-first-occurrence-in-a-string/)
*   **解题思路**: 这道题就是 KMP 算法的直接应用。给定 `haystack` (文本串) 和 `needle` (模式串)，要求找到 `needle` 在 `haystack` 中第一次出现的位置。我们只需实现 KMP 算法，并在找到第一个匹配时立即返回其索引即可。
*   **JS 代码**:
    ```javascript
    var strStr = function(haystack, needle) {
        const m = haystack.length;
        const n = needle.length;

        if (n === 0) return 0;
        if (m < n) return -1;

        // 1. 构建 next 数组 (与 computeNext 函数逻辑相同)
        const next = new Array(n).fill(0);
        for (let i = 1, j = 0; i < n; i++) {
            while (j > 0 && needle[i] !== needle[j]) {
                j = next[j - 1];
            }
            if (needle[i] === needle[j]) {
                j++;
            }
            next[i] = j;
        }

        // 2. KMP 搜索
        for (let i = 0, j = 0; i < m; i++) {
            while (j > 0 && haystack[i] !== needle[j]) {
                j = next[j - 1];
            }
            if (haystack[i] === needle[j]) {
                j++;
            }
            if (j === n) {
                return i - n + 1; // 找到匹配，返回起始索引
            }
        }

        return -1; // 未找到
    };
    ```

#### b. 459. 重复的子字符串 (Repeated Substring Pattern)
*   **题目链接**: [https://leetcode.cn/problems/repeated-substring-pattern/](https://leetcode.cn/problems/repeated-substring-pattern/)
*   **解题思路**: 这道题就是我们前面提到的“检查字符串周期性”的应用。如果一个字符串 `s` 是由一个子串重复多次构成的，那么 `s` 的长度 `n` 必须是其最小周期 `L` 的整数倍，并且 `L < n`。
    利用 `next` 数组，`L = n - next[n-1]`。所以，我们只需判断 `next[n-1]` 是否大于 0，并且 `n` 是否能被 `n - next[n-1]` 整除。
*   **JS 代码 (KMP 解法)**:
    ```javascript
    var repeatedSubstringPattern = function(s) {
        const n = s.length;
        if (n === 0) return false;

        const next = new Array(n).fill(0);
        for (let i = 1, j = 0; i < n; i++) {
            while (j > 0 && s[i] !== s[j]) {
                j = next[j - 1];
            }
            if (s[i] === s[j]) {
                j++;
            }
            next[i] = j;
        }

        const lastNextVal = next[n - 1];
        const possiblePeriod = n - lastNextVal;
        
        // 周期存在 (lastNextVal > 0) 且字符串长度是周期的整数倍
        return lastNextVal > 0 && n % possiblePeriod === 0;
    };
    ```

#### c. 214. 最短回文串 (Shortest Palindrome)
*   **题目链接**: [https://leetcode.cn/problems/shortest-palindrome/](https://leetcode.cn/problems/shortest-palindrome/)
*   **解题思路**: 题意是在字符串 `s` 的前面添加最少的字符，使其成为一个回文串。
    1.  首先，我们需要找到 `s` 的一个**最长的前缀**，这个前缀本身是一个回文串。
    2.  例如，`s = "aacecaaa"`，其最长回文前缀是 `"aacecaa"`。
    3.  剩下的部分是 `"a"`，我们需要将这部分的逆序 `"a"` 添加到 `s` 的最前面，得到 `"aaacecaaa"`。
    4.  如何高效地找到这个最长回文前缀？这可以转化为一个 KMP 问题。我们将 `s` 与其逆序 `rev_s` 连接起来，中间用一个特殊字符（如 `#`）隔开，形成一个新字符串 `temp = s + '#' + rev_s`。
    5.  计算 `temp` 的 `next` 数组。`next` 数组的最后一个值 `next[temp.length - 1]` 就代表了 `s` 的最长回文前缀的长度。
    6.  因为 `next` 数组的定义是“最长相等的前后缀”，在 `temp` 字符串中，它的前缀是 `s` 的一部分，后缀是 `rev_s` 的一部分。如果它们相等，就意味着 `s` 的一个前缀等于其自身的一个后缀的逆序，这正是回文前缀的定义！
*   **JS 代码**:
    ```javascript
    var shortestPalindrome = function(s) {
        const n = s.length;
        if (n <= 1) return s;

        const rev_s = s.split('').reverse().join('');
        const temp = s + '#' + rev_s;
        const m = temp.length;
        
        // 计算 temp 的 next 数组
        const next = new Array(m).fill(0);
        for (let i = 1, j = 0; i < m; i++) {
            while (j > 0 && temp[i] !== temp[j]) {
                j = next[j - 1];
            }
            if (temp[i] === temp[j]) {
                j++;
            }
            next[i] = j;
        }

        // 最长回文前缀的长度
        const maxPalindromePrefixLen = next[m - 1];
        
        // 需要被添加到前面的部分
        const suffixToAdd = s.substring(maxPalindromePrefixLen);
        
        // 将这部分的逆序加到 s 的开头
        return suffixToAdd.split('').reverse().join('') + s;
    };
    ```
