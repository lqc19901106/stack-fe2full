# 哈希表 (Hash Table)

### 1. 什么是哈希表？

哈希表（Hash Table），也称为哈希映射（Hash Map），是一种非常高效的数据结构，用于实现**键值对（key-value pair）**的存储和查找。它通过一个叫做**哈希函数（Hash Function）**的特殊函数，将任意类型的键（key）映射到一个固定大小的数组的索引上。这个数组通常被称为**桶（bucket）**或**槽（slot）**。

**核心思想**：通过计算键的哈希值，直接定位到其在内存中的存储位置，从而实现近乎 **O(1)** 时间复杂度的插入、删除和查找操作。

**生活中的例子**：
可以把哈希表想象成一个智能的储物柜系统。每个储物柜都有一个编号（数组索引）。当你存入一个物品（value）时，你给它贴上一个标签（key）。系统通过一个神奇的算法（哈希函数）根据你的标签直接告诉你应该存入哪个编号的柜子。取物时，你只需提供标签，系统再次用同样的算法计算出柜子编号，直接打开对应的柜子取出物品，无需逐个查找。

### 2. 哈希表的工作原理

哈希表主要由两部分组成：
1.  **底层数组**：用于实际存储数据。
2.  **哈希函数**：一个将键映射到数组索引的函数。

#### 哈希函数 (Hash Function)

哈希函数是哈希表的核心。一个好的哈希函数应具备以下特点：
*   **确定性**：对于相同的输入（key），必须总是产生相同的输出（索引）。
*   **高效性**：计算速度要快。
*   **均匀性**：应尽可能地将不同的键均匀地分布到数组的不同位置，以减少**哈希冲突**。

#### 哈希冲突 (Hash Collision)

理想情况下，不同的键会被映射到不同的索引。但由于键的可能取值范围通常远大于数组的长度，所以完全有可能**两个或多个不同的键被哈希函数映射到同一个索引**。这种情况就是**哈希冲突**。

例如，一个哈希函数 `hash(key) = key % 10`，对于键 `12` 和 `22`，哈希值都是 `2` (`12 % 10 = 2`, `22 % 10 = 2`)，这就产生了冲突。

解决哈希冲突是实现哈希表的关键。主要有两种策略：

**a. 链地址法 (Separate Chaining)**

这是最常用的一种方法。它将哈希到同一个索引的键值对存储在一个**链表**中。
*   数组的每个槽位存储的不再是单个元素，而是一个链表的头指针（或者其他数据结构，如红黑树）。
*   当发生冲突时，新的键值对被添加到对应索引位置的链表中。
*   查找时，先通过哈希函数找到对应的槽位，然后遍历该槽位的链表，找到正确的键。

> JavaScript 的 `Map` 和 Java 的 `HashMap` 都主要使用链地址法。当链表过长时（例如，Java 中长度超过 8），为了优化性能，链表可能会被转换为**红黑树**，将查找时间从 O(N) 优化到 O(logN)。

**b. 开放寻址法 (Open Addressing)**

开放寻址法的核心思想是：如果一个位置已经被占用，就按照某种规则去寻找下一个可用的空位。所有元素都直接存储在哈希表的数组中，不使用额外的数据结构。

常见的探测序列方法有：
1.  **线性探测 (Linear Probing)**：如果索引 `i` 被占用，就尝试 `i+1`, `i+2`, `i+3`, ... 直到找到空位。
    *   **优点**：实现简单，缓存友好。
    *   **缺点**：容易产生**聚集（clustering）**现象，即连续的槽位被占据，导致查找效率下降。
2.  **二次探测 (Quadratic Probing)**：如果索引 `i` 被占用，就尝试 `i+1²`, `i+2²`, `i+3²`, ...
    *   **优点**：能有效缓解线性探测的聚集问题。
    *   **缺点**：可能会产生另一种形式的聚集。
3.  **双重哈希 (Double Hashing)**：使用第二个哈希函数来计算步长。如果索引 `i` 被占用，就尝试 `i + hash2(key)`, `i + 2*hash2(key)`, ...
    *   **优点**：探测序列更随机，能更好地避免聚集。
    *   **缺点**：计算成本更高。

### 3. JavaScript 实现

在 JavaScript 中，我们通常不需要自己从头实现哈希表，因为语言内置了非常高效的实现：
*   **`Object`**: JavaScript 的普通对象本质上就是一种哈希表的实现，但它有一些限制（例如，键只能是字符串或 Symbol）。
*   **`Map`**: ES6 引入的 `Map` 对象是更纯粹、更强大的哈希表实现。它支持任意类型的键，并提供了一系列方便的方法（`set`, `get`, `has`, `delete`, `size`）。

下面我们手动实现一个使用**链地址法**解决冲突的简单哈希表，以帮助理解其内部工作原理。

```javascript
class HashTable {
    constructor(size = 50) {
        this.buckets = new Array(size);
        this.size = size;
    }

    // 哈希函数：将键转换为数组索引
    _hash(key) {
        let hash = 0;
        // 将字符串键的每个字符的 ASCII 码相加
        for (let i = 0; i < key.length; i++) {
            hash += key.charCodeAt(i);
        }
        // 取模运算，确保索引在数组范围内
        return hash % this.size;
    }

    // set(key, value): 插入或更新键值对
    set(key, value) {
        const index = this._hash(key);
        // 如果该索引处没有链表，则创建一个
        if (!this.buckets[index]) {
            this.buckets[index] = [];
        }

        const bucket = this.buckets[index];
        let found = false;

        // 检查键是否已存在，如果存在则更新值
        for (let i = 0; i < bucket.length; i++) {
            if (bucket[i][0] === key) {
                bucket[i][1] = value;
                found = true;
                break;
            }
        }

        // 如果键不存在，则添加到链表中
        if (!found) {
            bucket.push([key, value]);
        }
    }

    // get(key): 查找键对应的值
    get(key) {
        const index = this._hash(key);
        const bucket = this.buckets[index];

        if (!bucket) {
            return null; // 键不存在
        }

        // 遍历链表查找对应的键
        for (let i = 0; i < bucket.length; i++) {
            if (bucket[i][0] === key) {
                return bucket[i][1]; // 返回找到的值
            }
        }

        return null; // 键不存在
    }

    // has(key): 判断键是否存在
    has(key) {
        const index = this._hash(key);
        const bucket = this.buckets[index];

        if (!bucket) {
            return false;
        }

        for (let i = 0; i < bucket.length; i++) {
            if (bucket[i][0] === key) {
                return true;
            }
        }

        return false;
    }

    // delete(key): 删除键值对
    delete(key) {
        const index = this._hash(key);
        const bucket = this.buckets[index];

        if (!bucket) {
            return false;
        }

        for (let i = 0; i < bucket.length; i++) {
            if (bucket[i][0] === key) {
                bucket.splice(i, 1); // 从链表中移除
                return true;
            }
        }

        return false;
    }

    // 打印哈希表内容，用于调试
    display() {
        for (let i = 0; i < this.buckets.length; i++) {
            if (this.buckets[i]) {
                console.log(`Bucket ${i}:`, this.buckets[i]);
            }
        }
    }
}

// 使用示例
const ht = new HashTable();
ht.set("name", "Alice");
ht.set("age", 30);
ht.set("city", "New York");
// "name" 和 "mane" 可能会产生哈希冲突
ht.set("mane", "lion's hair"); 

console.log("Get 'name':", ht.get("name"));   // "Alice"
console.log("Get 'age':", ht.get("age"));     // 30
console.log("Has 'city':", ht.has("city"));   // true
console.log("Has 'country':", ht.has("country")); // false

ht.display();

ht.delete("age");
console.log("After deleting 'age':");
ht.display();
```

### 4. 经典 LeetCode 题目

哈希表是解决算法问题的利器，尤其适用于需要快速查找、计数或去重的场景。

#### 1. **1. 两数之和 (Two Sum)** (Easy)
*   **题目链接**: [https://leetcode.cn/problems/two-sum/](https://leetcode.cn/problems/two-sum/)
*   **解题思路**: 遍历数组，对于每个元素 `x`，在哈希表中查找是否存在 `target - x`。如果不存在，则将 `x` 及其索引存入哈希表。
*   **JS 代码**:
    ```javascript
    var twoSum = function(nums, target) {
        const map = new Map(); // key: number, value: index
        for (let i = 0; i < nums.length; i++) {
            const complement = target - nums[i];
            if (map.has(complement)) {
                return [map.get(complement), i];
            }
            map.set(nums[i], i);
        }
    };
    ```

#### 2. **49. 字母异位词分组 (Group Anagrams)** (Medium)
*   **题目链接**: [https://leetcode.cn/problems/group-anagrams/](https://leetcode.cn/problems/group-anagrams/)
*   **解题思路**: 遍历字符串数组，对每个字符串进行排序，将排序后的字符串作为哈希表的键。将原字符串存入对应键的值（一个数组）中。
*   **JS 代码**:
    ```javascript
    var groupAnagrams = function(strs) {
        const map = new Map();
        for (const str of strs) {
            const sortedStr = str.split('').sort().join('');
            if (map.has(sortedStr)) {
                map.get(sortedStr).push(str);
            } else {
                map.set(sortedStr, [str]);
            }
        }
        return Array.from(map.values());
    };
    ```

#### 3. **3. 无重复字符的最长子串 (Longest Substring Without Repeating Characters)** (Medium)
*   **题目链接**: [https://leetcode.cn/problems/longest-substring-without-repeating-characters/](https://leetcode.cn/problems/longest-substring-without-repeating-characters/)
*   **解题思路**: 使用滑动窗口和哈希表。哈希表用于存储窗口内字符及其最新出现的索引。当遇到重复字符时，将窗口的左边界移动到重复字符上次出现位置的右边。
*   **JS 代码**:
    ```javascript
    var lengthOfLongestSubstring = function(s) {
        const map = new Map(); // key: character, value: index
        let maxLength = 0;
        let left = 0; // 滑动窗口左边界

        for (let right = 0; right < s.length; right++) {
            const char = s[right];
            // 如果字符已在窗口内，则移动左边界
            if (map.has(char) && map.get(char) >= left) {
                left = map.get(char) + 1;
            }
            map.set(char, right);
            maxLength = Math.max(maxLength, right - left + 1);
        }
        return maxLength;
    };
    ```

#### 4. **128. 最长连续序列 (Longest Consecutive Sequence)** (Medium)
*   **题目链接**: [https://leetcode.cn/problems/longest-consecutive-sequence/](https://leetcode.cn/problems/longest-consecutive-sequence/)
*   **解题思路**: 首先用哈希集合（`Set`）存储所有数字以实现 O(1) 的查找。然后遍历数组，对于每个数字 `num`，如果 `num - 1` 不在集合中（说明 `num` 是一个序列的起点），则开始向后查找 `num + 1`, `num + 2`, ... 并计算当前序列的长度，更新最大长度。
*   **JS 代码**:
    ```javascript
    var longestConsecutive = function(nums) {
        if (nums.length === 0) return 0;
        
        const numSet = new Set(nums);
        let maxLength = 0;

        for (const num of numSet) {
            // 如果 num-1 不存在，说明 num 是一个新序列的起点
            if (!numSet.has(num - 1)) {
                let currentNum = num;
                let currentLength = 1;

                // 向后查找连续的数字
                while (numSet.has(currentNum + 1)) {
                    currentNum++;
                    currentLength++;
                }
                
                maxLength = Math.max(maxLength, currentLength);
            }
        }
        return maxLength;
    };
    ```
