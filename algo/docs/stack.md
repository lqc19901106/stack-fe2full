好的，我们来详细探讨栈（Stack）这种数据结构。

### 1. 栈数据结构的详解

#### 什么是栈？

**栈 (Stack)** 是一种遵循 **“后进先出” (Last-In, First-Out, LIFO)** 原则的抽象数据类型 (ADT)。你可以把它想象成一叠盘子：你最后放上去的盘子，总是最先被拿走。

#### 栈的基本操作

栈主要支持以下两种基本操作：

1.  **入栈 (Push)**：将一个元素添加到栈的顶部。
2.  **出栈 (Pop)**：从栈的顶部移除一个元素。

此外，栈还通常支持以下辅助操作：

*   **查看栈顶元素 (Peek / Top)**：返回栈顶元素，但不将其移除。
*   **判断栈是否为空 (isEmpty)**：检查栈中是否有元素。
*   **获取栈的大小 (size)**：返回栈中元素的数量。

#### 栈的特点

*   **LIFO 原则**：这是栈最核心的特性。
*   **线性结构**：元素按照线性顺序排列。
*   **只能在栈顶操作**：所有插入和删除都发生在栈的同一端，称为“栈顶” (Top)。另一端称为“栈底” (Bottom)。

#### 栈的底层实现

栈可以通过多种方式实现：

1.  **数组 (Array)**：
    *   将数组的末尾（或开头）作为栈顶。
    *   **优点**：实现简单，数组的随机访问特性可以方便地定位栈顶。
    *   **缺点**：如果使用数组开头作为栈顶，每次 `push` 和 `pop` 都需要移动所有元素（效率低）；如果使用数组末尾作为栈顶，当数组空间不足时可能需要扩容，涉及内存重新分配。JavaScript 中的数组 `push` 和 `pop` 操作通常效率很高，因为它们在数组末尾操作。

2.  **链表 (Linked List)**：
    *   将链表的头部（或尾部）作为栈顶。
    *   **优点**：动态大小，不会有数组扩容的开销。
    *   **缺点**：每个节点都需要额外的指针空间；如果使用尾部作为栈顶，`pop` 操作可能需要遍历链表（效率低，除非是双向链表）。通常将链表头部作为栈顶，这样 `push` 和 `pop` 都是 `O(1)` 操作。

在 JavaScript 中，由于数组 `push` 和 `pop` 操作的优化，通常直接使用数组来实现栈是最简洁高效的方式。

### 2. JavaScript 实现

使用 JavaScript 数组实现一个简单的栈：

```javascript
class Stack {
    constructor() {
        this.items = []; // 使用数组存储栈中的元素
    }

    // 入栈操作
    push(element) {
        this.items.push(element);
    }

    // 出栈操作
    pop() {
        if (this.isEmpty()) {
            return "Underflow"; // 栈为空时的错误或特殊值
        }
        return this.items.pop();
    }

    // 查看栈顶元素
    peek() {
        if (this.isEmpty()) {
            return "No elements in Stack";
        }
        return this.items[this.items.length - 1];
    }

    // 判断栈是否为空
    isEmpty() {
        return this.items.length === 0;
    }

    // 获取栈的大小
    size() {
        return this.items.length;
    }

    // 清空栈
    clear() {
        this.items = [];
    }

    // 打印栈内容（辅助方法）
    printStack() {
        let str = "";
        for (let i = 0; i < this.items.length; i++) {
            str += this.items[i] + " ";
        }
        return str.trim();
    }
}
```

#### 使用示例

```javascript
const stack = new Stack();
console.log("栈是否为空?", stack.isEmpty()); // true

stack.push(10);
stack.push(20);
stack.push(30);
console.log("入栈 10, 20, 30 后:", stack.printStack()); // 10 20 30

console.log("栈顶元素:", stack.peek()); // 30
console.log("栈大小:", stack.size()); // 3

console.log("出栈:", stack.pop()); // 30
console.log("出栈后:", stack.printStack()); // 10 20

console.log("栈是否为空?", stack.isEmpty()); // false

stack.clear();
console.log("清空栈后:", stack.printStack()); // (空字符串)
console.log("栈是否为空?", stack.isEmpty()); // true
console.log("出栈 (空栈):", stack.pop()); // Underflow
```

### 3. 栈数据结构的应用

栈在计算机科学中有着广泛的应用，包括：

1.  **函数调用栈 (Call Stack)**：
    *   程序在执行函数调用时，会将当前函数的上下文（局部变量、参数、返回地址）压入调用栈。
    *   当函数执行完毕时，其上下文从栈中弹出，程序返回到调用它的位置。
    *   这也是为什么递归调用过多会导致“栈溢出”错误的原因。

2.  **表达式求值**：
    *   将中缀表达式转换为后缀表达式（逆波兰表示法），然后计算后缀表达式。
    *   在转换和计算过程中，运算符和操作数会根据优先级入栈和出栈。

3.  **括号匹配**：
    *   检查数学表达式或代码中的括号（`()`, `[]`, `{}`）是否正确匹配。
    *   遇到左括号入栈，遇到右括号时与栈顶的左括号匹配，如果匹配则出栈。最后栈为空则匹配成功。

4.  **撤销/重做 (Undo/Redo) 功能**：
    *   将每次操作的状态压入“撤销栈”。
    *   点击撤销时，从撤销栈中弹出最近的操作，并将其压入“重做栈”。
    *   点击重做时，从重做栈中弹出操作，并将其压入撤销栈。

5.  **浏览器历史记录**：
    *   访问的每个页面都可以视为一个元素，压入“前进栈”或“后退栈”。
    *   点击后退时，当前页面弹出，压入前进栈，再显示后退栈的新栈顶。

6.  **深度优先搜索 (DFS)**：
    *   图或树的深度优先搜索可以用递归实现（隐式使用了函数调用栈），也可以用显式栈实现。

7.  **语法分析**：
    *   编译器在对程序进行语法分析时，会使用栈来处理语法结构，如识别语句块、函数定义等。

### 4. LeetCode 经典题目

1.  **20. 有效的括号 (Valid Parentheses)** (Easy)
    *   [https://leetcode.cn/problems/valid-parentheses/](https://leetcode.cn/problems/valid-parentheses/)
    *   **描述**：给定一个只包括 `(`, `)`, `{`, `}`, `[`, `]` 的字符串，判断字符串是否有效。
    *   **解法**：遍历字符串，遇到左括号入栈；遇到右括号时，检查栈是否为空，以及栈顶是否是对应的左括号。

2.  **155. 最小栈 (Min Stack)** (Medium)
    *   [https://leetcode.cn/problems/min-stack/](https://leetcode.cn/problems/min-stack/)
    *   **描述**：设计一个支持 push，pop，top 操作，并能在常数时间内检索到最小元素的栈。
    *   **解法**：除了主栈存储元素，再维护一个辅助栈（或叫最小栈），专门存储当前主栈中的最小元素。

3.  **739. 每日温度 (Daily Temperatures)** (Medium)
    *   [https://leetcode.cn/problems/daily-temperatures/](https://leetcode.cn/problems/daily-temperatures/)
    *   **描述**：给定一个整数数组 `temperatures`，表示每天的温度。返回一个数组 `answer`，其中 `answer[i]` 是指在 `i` 天之后，才会有更高的温度。如果之后没有更高的温度， `answer[i]` 就等于 `0`。
    *   **解法**：使用**单调栈**。栈中存储的是温度的索引，并且保持栈内元素（索引对应的温度）单调递减。

4.  **42. 接雨水 (Trapping Rain Water)** (Hard)
    *   [https://leetcode.cn/problems/trapping-rain-water/](https://leetcode.cn/problems/trapping-rain-water/)
    *   **描述**：给定 `n` 个非负整数表示每个宽度为 `1` 的柱子的高度图，计算按此排列的柱子，下雨之后能接多少雨水。
    *   **解法**：多种方法，其中一种是使用**单调栈**。栈中存储柱子的索引，当遇到比栈顶高的柱子时，就可以计算出一段能接的雨水。

5.  **84. 柱状图中最大的矩形 (Largest Rectangle in Histogram)** (Hard)
    *   [https://leetcode.cn/problems/largest-rectangle-in-histogram/](https://leetcode.cn/problems/largest-rectangle-in-histogram/)
    *   **描述**：给定 `n` 个非负整数，用来表示柱状图中各个柱子的高度。每个柱子彼此相邻，且宽度为 `1`。求在该柱状图中，能够勾勒出来的矩形的最大面积。
    *   **解法**：同样是使用**单调栈**。栈中维护一个递增的柱子高度索引序列。

6.  **150. 逆波兰表达式求值 (Evaluate Reverse Polish Notation)** (Medium)
    *   [https://leetcode.cn/problems/evaluate-reverse-polish-notation/](https://leetcode.cn/problems/evaluate-reverse-polish-notation/)
    *   **描述**：根据逆波兰表示法，求表达式的值。
    *   **解法**：遍历表达式，遇到数字入栈；遇到运算符时，从栈中弹出两个操作数进行计算，然后将结果重新入栈。

这些题目涵盖了栈的基本操作、辅助栈、单调栈等多种高级应用。掌握它们能让你对栈的理解更深入。

### 5. 栈与 DFS / 回溯进阶题目 ✅

下面补充 7 道与栈、DFS、回溯结合的经典 LeetCode 题目，包含详细描述、解题思路、JS 参考代码和复杂度分析。

#### 1) 144. 二叉树的前序遍历 (Binary Tree Preorder Traversal) - Easy
* **链接**: https://leetcode.cn/problems/binary-tree-preorder-traversal/
* **描述**: 给定二叉树根节点，返回其前序遍历结果（根 -> 左 -> 右）。
* **解题思路**: 
  * 递归方法最简洁（隐式使用函数栈）
  * 迭代方法：使用显式栈，先入栈根，出栈时访问节点，再先入右子树再入左子树（保证左先访问）
* **时间/空间复杂度**: O(n) / O(h)，h 为树高
* **JS 代码**:
```javascript
// 迭代方法
function preorderTraversal(root) {
  if (!root) return [];
  const res = [], stack = [root];
  while (stack.length) {
    const node = stack.pop();
    res.push(node.val);
    // 注意：先入栈右子树，后入栈左子树（栈是 LIFO）
    if (node.right) stack.push(node.right);
    if (node.left) stack.push(node.left);
  }
  return res;
}
```

#### 2) 145. 二叉树的后序遍历 (Binary Tree Postorder Traversal) - Easy
* **链接**: https://leetcode.cn/problems/binary-tree-postorder-traversal/
* **描述**: 给定二叉树根节点，返回其后序遍历结果（左 -> 右 -> 根）。
* **解题思路**: 迭代方法相对复杂；一个巧妙的办法是反向前序遍历（根 -> 右 -> 左），再反转结果得到后序（左 -> 右 -> 根）
* **时间/空间复杂度**: O(n) / O(h)
* **JS 代码**:
```javascript
function postorderTraversal(root) {
  if (!root) return [];
  const res = [], stack = [root];
  while (stack.length) {
    const node = stack.pop();
    res.push(node.val);
    // 反向顺序：先入栈左子树，后入栈右子树
    if (node.left) stack.push(node.left);
    if (node.right) stack.push(node.right);
  }
  return res.reverse(); // 反转即得后序
}
```

#### 3) 22. 括号生成 (Generate Parentheses) - Medium
* **链接**: https://leetcode.cn/problems/generate-parentheses/
* **描述**: 数字 n 代表生成括号的对数，设计一个函数，用于生成所有可能的并且 **有效的** 括号组合。
* **解题思路**: 回溯 + 剪枝；通过 left 和 right 计数来确保括号有效（left 和 right 都不超过 n，且每个时刻 left >= right）
* **时间/空间复杂度**: O(4^n / √n) ≈ O(2^n) / O(n)（输出空间除外）
* **JS 代码**:
```javascript
function generateParenthesis(n) {
  const res = [];
  function backtrack(cur, left, right) {
    if (left === n && right === n) {
      res.push(cur);
      return;
    }
    // 左括号没用完，继续加左括号
    if (left < n) backtrack(cur + '(', left + 1, right);
    // 右括号数 < 左括号数，可以加右括号
    if (right < left) backtrack(cur + ')', left, right + 1);
  }
  backtrack('', 0, 0);
  return res;
}
```

#### 4) 94. 二叉树的中序遍历 (Binary Tree Inorder Traversal) - Easy
* **链接**: https://leetcode.cn/problems/binary-tree-inorder-traversal/
* **描述**: 给定二叉树根节点，返回其中序遍历结果（左 -> 根 -> 右）。
* **解题思路**: 迭代方法需要用栈模拟递归；先一直向左压栈，到达空时出栈并访问，再转向右子树
* **时间/空间复杂度**: O(n) / O(h)
* **JS 代码**:
```javascript
function inorderTraversal(root) {
  const res = [];
  const stack = [];
  let cur = root;
  while (cur || stack.length) {
    // 一直向左压栈
    while (cur) {
      stack.push(cur);
      cur = cur.left;
    }
    // 出栈、访问、转向右
    cur = stack.pop();
    res.push(cur.val);
    cur = cur.right;
  }
  return res;
}
```

#### 5) 32. 最长有效括号 (Longest Valid Parentheses) - Hard
* **链接**: https://leetcode.cn/problems/longest-valid-parentheses/
* **描述**: 给定一个只包含 `(` 和 `)` 的字符串，找出包含不超过一个不匹配括号的最长子字符串的长度。
* **解题思路**: 栈法：栈底始终存放最后一个未匹配的右括号的索引（或 -1）；遇到左括号入栈，遇到右括号时尝试与栈顶匹配；记录有效片段长度
* **时间/空间复杂度**: O(n) / O(n)
* **JS 代码**:
```javascript
function longestValidParentheses(s) {
  const stack = [-1];
  let maxLen = 0;
  for (let i = 0; i < s.length; i++) {
    if (s[i] === '(') {
      stack.push(i);
    } else {
      stack.pop();
      if (stack.length === 0) {
        stack.push(i); // 当前右括号无法匹配，作为新的基准
      } else {
        maxLen = Math.max(maxLen, i - stack[stack.length - 1]);
      }
    }
  }
  return maxLen;
}
```

#### 6) 46. 全排列 (Permutations) - Medium
* **链接**: https://leetcode.cn/problems/permutations/
* **描述**: 给定一个不含重复数字的数组，返回其所有全排列。
* **解题思路**: 回溯法；通过 visited 数组标记已使用的数字，逐步构建排列；当排列长度等于数组长度时，加入结果
* **时间/空间复杂度**: O(n! × n) / O(n)（不计输出空间）
* **JS 代码**:
```javascript
function permute(nums) {
  const res = [];
  const visited = new Array(nums.length).fill(false);
  function backtrack(cur) {
    if (cur.length === nums.length) {
      res.push([...cur]);
      return;
    }
    for (let i = 0; i < nums.length; i++) {
      if (!visited[i]) {
        visited[i] = true;
        cur.push(nums[i]);
        backtrack(cur);
        cur.pop();
        visited[i] = false;
      }
    }
  }
  backtrack([]);
  return res;
}
```

#### 7) 98. 验证二叉搜索树 (Validate Binary Search Tree) - Medium
* **链接**: https://leetcode.cn/problems/validate-binary-search-tree/
* **描述**: 给定二叉树根节点，判断该树是否是有效的二叉搜索树。
* **解题思路**: 中序遍历的栈法；BST 的中序遍历序列是递增的，若中途发现非递增则不是 BST；或使用递归同时传递上下界限制
* **时间/空间复杂度**: O(n) / O(h)
* **JS 代码（栈 + 中序遍历法）**:
```javascript
function isValidBST(root) {
  let prev = -Infinity;
  const stack = [];
  let cur = root;
  while (cur || stack.length) {
    while (cur) {
      stack.push(cur);
      cur = cur.left;
    }
    cur = stack.pop();
    if (cur.val <= prev) return false;
    prev = cur.val;
    cur = cur.right;
  }
  return true;
}
```

---

**总结**：上述题目涵盖了栈的不同应用场景——基础遍历、回溯组合、匹配校验等，掌握这些有助于深化对栈与 DFS/回溯的理解。