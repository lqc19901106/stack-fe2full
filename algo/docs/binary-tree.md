4.  **二叉搜索树 (Binary Search Tree, BST)**：
    *   对于任意一个节点：
        *   其左子树中所有节点的值都小于该节点的值。
        *   其右子树中所有节点的值都大于该节点的值。
        *   左右子树也必须是二叉搜索树。
    *   这使得查找、插入和删除操作效率很高。

### 2. JavaScript 实现

首先定义二叉树的节点结构：

```javascript
class TreeNode {
    constructor(val) {
        this.val = val;
        this.left = null; // 左子节点指针
        this.right = null; // 右子节点指针
    }
}
```

接下来，我们可以实现一个简单的二叉树类，包含一些基本操作。

```javascript
class BinaryTree {
    constructor() {
        this.root = null;
    }

    // 辅助方法：构建二叉树（这里使用一个数组构建，'#' 代表空节点）
    // 例如：[1, 2, 3, '#', '#', 4, 5]
    //      1
    //     / \
    //    2   3
    //       / \
    //      4   5
    buildTree(arr) {
        if (!arr || arr.length === 0 || arr[0] === '#') {
            this.root = null;
            return;
        }

        const nodes = arr.map(val => (val === '#' ? null : new TreeNode(val)));
        this.root = nodes[0];
        let parentIndex = 0;
        for (let i = 1; i < nodes.length; i += 2) {
            while (parentIndex < nodes.length && nodes[parentIndex] === null) {
                parentIndex++;
            }
            if (parentIndex >= nodes.length) break;

            const parent = nodes[parentIndex];
            if (nodes[i]) {
                parent.left = nodes[i];
            }
            if (i + 1 < nodes.length && nodes[i + 1]) {
                parent.right = nodes[i + 1];
            }
            parentIndex++;
        }
    }

    // -------- 从遍历序列构建树 --------

    // 从前序和中序遍历序列构建二叉树
    buildFromPreIn(preorder, inorder) {
        if (!preorder || !inorder || preorder.length === 0 || inorder.length === 0) {
            this.root = null;
            return null;
        }
        // 使用 Map 存储中序遍历的值和索引，以提高查找效率
        const inorderMap = new Map();
        for (let i = 0; i < inorder.length; i++) {
            inorderMap.set(inorder[i], i);
        }
        let preIndex = 0;

        const build = (left, right) => {
            if (left > right) return null;

            const rootVal = preorder[preIndex++];
            const root = new TreeNode(rootVal);
            const rootIndex = inorderMap.get(rootVal);

            root.left = build(left, rootIndex - 1);
            root.right = build(rootIndex + 1, right);
            return root;
        };

        this.root = build(0, inorder.length - 1);
        return this.root;
    }

    // 从后序和中序遍历序列构建二叉树
    buildFromPostIn(inorder, postorder) {
        if (!inorder || !postorder || inorder.length === 0 || postorder.length === 0) {
            this.root = null;
            return null;
        }
        const inorderMap = new Map();
        for (let i = 0; i < inorder.length; i++) {
            inorderMap.set(inorder[i], i);
        }
        let postIndex = postorder.length - 1;

        const build = (left, right) => {
            if (left > right) return null;

            const rootVal = postorder[postIndex--];
            const root = new TreeNode(rootVal);
            const rootIndex = inorderMap.get(rootVal);

            // 注意：由于后序遍历是“左右根”，所以要先构建右子树，再构建左子树
            root.right = build(rootIndex + 1, right);
            root.left = build(left, rootIndex - 1);
            return root;
        };

        this.root = build(0, inorder.length - 1);
        return this.root;
    }

    // -------- 遍历操作 (Traversals) --------

    // 前序遍历 (根 -> 左 -> 右)
    preorderTraversal(node = this.root, result = []) {
        if (node) {
            result.push(node.val);
            this.preorderTraversal(node.left, result);
            this.preorderTraversal(node.right, result);
        }
        return result;
    }

    // 中序遍历 (左 -> 根 -> 右)
    inorderTraversal(node = this.root, result = []) {
        if (node) {
            this.inorderTraversal(node.left, result);
            result.push(node.val);
            this.inorderTraversal(node.right, result);
        }
        return result;
    }

    // 后序遍历 (左 -> 右 -> 根)
    postorderTraversal(node = this.root, result = []) {
        if (node) {
            this.postorderTraversal(node.left, result);
            this.postorderTraversal(node.right, result);
            result.push(node.val);
        }
        return result;
    }

    // 广度优先遍历 (层序遍历)
    levelOrderTraversal() {
        if (!this.root) return [];
        const result = [];
        const queue = [this.root];

        while (queue.length > 0) {
            const levelSize = queue.length;
            const currentLevelNodes = [];
            for (let i = 0; i < levelSize; i++) {
                const node = queue.shift();
                currentLevelNodes.push(node.val);
                if (node.left) queue.push(node.left);
                if (node.right) queue.push(node.right);
            }
            result.push(currentLevelNodes);
        }
        return result;
    }

    // -------- 常见操作 --------

    // 计算树的高度 (从根节点到最远叶子节点的最长路径上的边数)
    getHeight(node = this.root) {
        if (!node) return -1; // 空树高度为-1
        const leftHeight = this.getHeight(node.left);
        const rightHeight = this.getHeight(node.right);
        return Math.max(leftHeight, rightHeight) + 1;
    }

    // 计算树的节点数
    countNodes(node = this.root) {
        if (!node) return 0;
        return 1 + this.countNodes(node.left) + this.countNodes(node.right);
    }

    // 查找节点
    find(val, node = this.root) {
        if (!node) return null;
        if (node.val === val) return node;
        let found = this.find(val, node.left);
        if (found) return found;
        return this.find(val, node.right);
    }

    // 判断是否是平衡二叉树
    isBalanced(node = this.root) {
        if (!node) return true;

        const leftHeight = this.getHeight(node.left);
        const rightHeight = this.getHeight(node.right);

        if (Math.abs(leftHeight - rightHeight) > 1) {
            return false;
        }

        return this.isBalanced(node.left) && this.isBalanced(node.right);
    }

    // 翻转二叉树 (镜像)
    invertTree(node = this.root) {
        if (node) {
            // 交换左右子节点
            [node.left, node.right] = [node.right, node.left];
            // 递归翻转左右子树
            this.invertTree(node.left);
            this.invertTree(node.right);
        }
        return node;
    }
}
```

#### 使用示例

```javascript
const tree = new BinaryTree();
tree.buildTree([1, 2, 3, '#', '#', 4, 5]); // 构建树 1 -> (2, 3), 3 -> (4, 5)

console.log("前序遍历 (Preorder):", tree.preorderTraversal()); // [1, 2, 3, 4, 5]
console.log("中序遍历 (Inorder):", tree.inorderTraversal());   // [2, 1, 4, 3, 5]
console.log("后序遍历 (Postorder):", tree.postorderTraversal()); // [2, 4, 5, 3, 1]
console.log("层序遍历 (Level Order):", tree.levelOrderTraversal()); // [[1], [2, 3], [4, 5]]

console.log("树的高度:", tree.getHeight()); // 2 (根节点到最远叶子节点有2条边)
console.log("节点总数:", tree.countNodes()); // 5
console.log("查找节点 3:", tree.find(3)); // 返回 TreeNode { val: 3, ... }
console.log("查找节点 99:", tree.find(99)); // null

// 尝试构建一个不平衡的树
const unbalancedTree = new BinaryTree();
unbalancedTree.buildTree([1, '#', 2, '#', '#', '#', 3]); // 1 -> null, 1 -> 2, 2 -> null, 2 -> 3
console.log("不平衡树的层序遍历:", unbalancedTree.levelOrderTraversal()); // [[1], [2], [3]]
console.log("不平衡树是否平衡:", unbalancedTree.isBalanced()); // false

// 翻转二叉树
console.log("翻转前的中序遍历:", tree.inorderTraversal()); // [2, 1, 4, 3, 5]
tree.invertTree();
console.log("翻转后的中序遍历:", tree.inorderTraversal()); // [5, 3, 4, 1, 2]
console.log("翻转后的层序遍历:", tree.levelOrderTraversal()); // [[1], [3, 2], [5, 4]]

// 从遍历序列构建树
const preOrder = [3, 9, 20, 15, 7];
const inOrder = [9, 3, 15, 20, 7];
const postOrder = [9, 15, 7, 20, 3];

const treeFromPreIn = new BinaryTree();
treeFromPreIn.buildFromPreIn(preOrder, inOrder);
console.log("从前序和中序构建的树 (层序):", treeFromPreIn.levelOrderTraversal()); // [[3], [9, 20], [15, 7]]

const treeFromPostIn = new BinaryTree();
treeFromPostIn.buildFromPostIn(inOrder, postOrder);
console.log("从后序和中序构建的树 (层序):", treeFromPostIn.levelOrderTraversal()); // [[3], [9, 20], [15, 7]]
```

### 3. 常见操作

除了上述实现中包含的，还有一些常见操作：

*   **插入 (Insert)**：对于普通二叉树，插入位置不固定；对于二叉搜索树，则有特定的插入规则。
*   **删除 (Delete)**：删除一个节点时，需要根据节点的子节点情况进行复杂的调整，以保持树的结构。对于二叉搜索树，删除操作更复杂。
*   **判断是否为二叉搜索树**：中序遍历结果是否严格递增。
*   **求最小/最大值**：对于二叉搜索树，最小值是最左边的叶子节点，最大值是最右边的叶子节点。
*   **求两个节点的最低公共祖先 (Lowest Common Ancestor, LCA)**。
*   **翻转/镜像二叉树**。
*   **路径问题**：如所有从根到叶子的路径，路径和。

### 4. 经典 LeetCode 题目

二叉树是 LeetCode 中非常热门的考点，涵盖了各种难度。

#### 1. 遍历相关

*   **94. 二叉树的中序遍历** (Easy): [https://leetcode.cn/problems/binary-tree-inorder-traversal/](https://leetcode.cn/problems/binary-tree-inorder-traversal/)
    *   考察递归和非递归中序遍历。
    ```javascript
    // 递归解法
    var inorderTraversal = function(root) {
        const result = [];
        const traverse = (node) => {
            if (!node) return;
            traverse(node.left);
            result.push(node.val);
            traverse(node.right);
        };
        traverse(root);
        return result;
    };

    // 迭代解法 (使用栈)
    var inorderTraversalIterative = function(root) {
        const result = [];
        const stack = [];
        let current = root;
        while (current || stack.length > 0) {
            while (current) {
                stack.push(current);
                current = current.left;
            }
            current = stack.pop();
            result.push(current.val);
            current = current.right;
        }
        return result;
    };
    ```
*   **102. 二叉树的层序遍历** (Medium): [https://leetcode.cn/problems/binary-tree-level-order-traversal/](https://leetcode.cn/problems/binary-tree-level-order-traversal/)
    *   考察广度优先搜索 (BFS) 的应用。
    ```javascript
    var levelOrder = function(root) {
        if (!root) return [];
        const result = [];
        const queue = [root];

        while (queue.length > 0) {
            const levelSize = queue.length;
            const currentLevel = [];
            for (let i = 0; i < levelSize; i++) {
                const node = queue.shift();
                currentLevel.push(node.val);
                if (node.left) queue.push(node.left);
                if (node.right) queue.push(node.right);
            }
            result.push(currentLevel);
        }
        return result;
    };
    ```

#### 2. 属性计算

*   **104. 二叉树的最大深度** (Easy): [https://leetcode.cn/problems/maximum-depth-of-binary-tree/](https://leetcode.cn/problems/maximum-depth-of-binary-tree/)
    *   递归或 BFS 均可解决。
    ```javascript
    // 递归解法
    var maxDepth = function(root) {
        if (!root) return 0;
        const leftDepth = maxDepth(root.left);
        const rightDepth = maxDepth(root.right);
        return Math.max(leftDepth, rightDepth) + 1;
    };
    ```
*   **111. 二叉树的最小深度** (Easy): [https://leetcode.cn/problems/minimum-depth-of-binary-tree/](https://leetcode.cn/problems/minimum-depth-of-binary-tree/)
    *   注意叶子节点的定义。
    ```javascript
    var minDepth = function(root) {
        if (!root) return 0;
        if (!root.left && !root.right) return 1; // 是叶子节点
        
        let min = Infinity;
        if (root.left) {
            min = Math.min(min, minDepth(root.left));
        }
        if (root.right) {
            min = Math.min(min, minDepth(root.right));
        }
        return min + 1;
    };
    ```
*   **110. 平衡二叉树** (Easy): [https://leetcode.cn/problems/balanced-binary-tree/](https://leetcode.cn/problems/balanced-binary-tree/)
    *   考察递归和对高度的判断。
    ```javascript
    var isBalanced = function(root) {
        const getHeight = (node) => {
            if (!node) return 0;
            const leftHeight = getHeight(node.left);
            const rightHeight = getHeight(node.right);
            // 如果子树不平衡，或当前节点不平衡，返回-1
            if (leftHeight === -1 || rightHeight === -1 || Math.abs(leftHeight - rightHeight) > 1) {
                return -1;
            }
            return Math.max(leftHeight, rightHeight) + 1;
        };
        return getHeight(root) !== -1;
    };
    ```
*   **226. 翻转二叉树** (Easy): [https://leetcode.cn/problems/invert-binary-tree/](https://leetcode.cn/problems/invert-binary-tree/)
    *   递归交换左右子树即可。
    ```javascript
    var invertTree = function(root) {
        if (!root) return null;
        // 交换左右子节点
        [root.left, root.right] = [root.right, root.left];
        // 递归翻转
        invertTree(root.left);
        invertTree(root.right);
        return root;
    };
    ```

#### 3. 结构判断与构造

*   **100. 相同的树** (Easy): [https://leetcode.cn/problems/same-tree/](https://leetcode.cn/problems/same-tree/)
    *   递归比较两个树的节点值和子树。
    ```javascript
    var isSameTree = function(p, q) {
        if (!p && !q) return true; // 都为空
        if (!p || !q || p.val !== q.val) return false; // 一个为空或值不等
        return isSameTree(p.left, q.left) && isSameTree(p.right, q.right);
    };
    ```
*   **101. 对称二叉树** (Easy): [https://leetcode.cn/problems/symmetric-tree/](https://leetcode.cn/problems/symmetric-tree/)
    *   比较左子树的左侧和右子树的右侧，以及左子树的右侧和右子树的左侧。
    ```javascript
    var isSymmetric = function(root) {
        if (!root) return true;
        const check = (left, right) => {
            if (!left && !right) return true;
            if (!left || !right || left.val !== right.val) return false;
            return check(left.left, right.right) && check(left.right, right.left);
        };
        return check(root.left, root.right);
    };
    ```
*   **105. 从前序与中序遍历序列构造二叉树** (Medium): [https://leetcode.cn/problems/construct-binary-tree-from-preorder-and-inorder-traversal/](https://leetcode.cn/problems/construct-binary-tree-from-preorder-and-inorder-traversal/)
    *   经典题目，需要理解前序和中序遍历的特点。
    ```javascript
    var buildTree = function(preorder, inorder) {
        const map = new Map();
        for (let i = 0; i < inorder.length; i++) {
            map.set(inorder[i], i);
        }
        let preIndex = 0;
        const build = (left, right) => {
            if (left > right) return null;
            let rootVal = preorder[preIndex++];
            let root = new TreeNode(rootVal);
            let rootIndex = map.get(rootVal);
            root.left = build(left, rootIndex - 1);
            root.right = build(rootIndex + 1, right);
            return root;
        };
        return build(0, inorder.length - 1);
    };
    ```
*   **106. 从中序与后序遍历序列构造二叉树** (Medium): [https://leetcode.cn/problems/construct-binary-tree-from-inorder-and-postorder-traversal/](https://leetcode.cn/problems/construct-binary-tree-from-inorder-and-postorder-traversal/)
    *   与 105 类似。
    ```javascript
    var buildTreeFromPostIn = function(inorder, postorder) {
        const map = new Map();
        for (let i = 0; i < inorder.length; i++) {
            map.set(inorder[i], i);
        }
        let postIndex = postorder.length - 1;
        const build = (left, right) => {
            if (left > right) return null;
            let rootVal = postorder[postIndex--];
            let root = new TreeNode(rootVal);
            let rootIndex = map.get(rootVal);
            // 后序是左右根，所以要先构建右子树
            root.right = build(rootIndex + 1, right);
            root.left = build(left, rootIndex - 1);
            return root;
        };
        return build(0, inorder.length - 1);
    };
    ```

#### 4. 二叉搜索树 (BST) 特有题目

*   **98. 验证二叉搜索树** (Medium): [https://leetcode.cn/problems/validate-binary-search-tree/](https://leetcode.cn/problems/validate-binary-search-tree/)
    *   中序遍历是递增的，或者递归时传递 min/max 范围。
    ```javascript
    // 递归 + 范围检查
    var isValidBST = function(root, min = -Infinity, max = Infinity) {
        if (!root) return true;
        if (root.val <= min || root.val >= max) {
            return false;
        }
        return isValidBST(root.left, min, root.val) && isValidBST(root.right, root.val, max);
    };

    // 中序遍历解法
    var isValidBSTInorder = function(root) {
        let prev = -Infinity;
        let isValid = true;
        const inorder = (node) => {
            if (!node || !isValid) return;
            inorder(node.left);
            if (node.val <= prev) {
                isValid = false;
                return;
            }
            prev = node.val;
            inorder(node.right);
        };
        inorder(root);
        return isValid;
    };
    ```
*   **700. 二叉搜索树中的搜索** (Easy): [https://leetcode.cn/problems/search-in-a-binary-search-tree/](https://leetcode.cn/problems/search-in-a-binary-search-tree/)
    *   直接利用 BST 的性质进行查找。
    ```javascript
    var searchBST = function(root, val) {
        if (!root) return null;
        if (root.val === val) return root;
        if (val < root.val) {
            return searchBST(root.left, val);
        } else {
            return searchBST(root.right, val);
        }
    };
    ```
*   **230. 二叉搜索树中第K小的元素** (Medium): [https://leetcode.cn/problems/kth-smallest-element-in-a-bst/](https://leetcode.cn/problems/kth-smallest-element-in-a-bst/)
    *   中序遍历即可。
    ```javascript
    var kthSmallest = function(root, k) {
        const stack = [];
        let current = root;
        while (current || stack.length > 0) {
            while (current) {
                stack.push(current);
                current = current.left;
            }
            current = stack.pop();
            k--;
            if (k === 0) {
                return current.val;
            }
            current = current.right;
        }
    };
    ```

#### 5. 路径相关

*   **112. 路径总和** (Easy): [https://leetcode.cn/problems/path-sum/](https://leetcode.cn/problems/path-sum/)
    *   递归检查从根到叶子的路径和。
    ```javascript
    var hasPathSum = function(root, targetSum) {
        if (!root) return false;
        // 到达叶子节点，并且路径和相等
        if (!root.left && !root.right && root.val === targetSum) {
            return true;
        }
        // 递归地在左右子树中查找
        return hasPathSum(root.left, targetSum - root.val) || hasPathSum(root.right, targetSum - root.val);
    };
    ```
*   **113. 路径总和 II** (Medium): [https://leetcode.cn/problems/path-sum-ii/](https://leetcode.cn/problems/path-sum-ii/)
    *   需要回溯来找到所有符合条件的路径。
    ```javascript
    var pathSum = function(root, targetSum) {
        const result = [];
        const findPath = (node, currentSum, path) => {
            if (!node) return;

            currentSum += node.val;
            path.push(node.val);

            if (!node.left && !node.right && currentSum === targetSum) {
                result.push([...path]); // 找到一条路径
            }

            findPath(node.left, currentSum, path);
            findPath(node.right, currentSum, path);

            path.pop(); // 回溯
        };
        findPath(root, 0, []);
        return result;
    };
    ```
*   **124. 二叉树中的最大路径和** (Hard): [https://leetcode.cn/problems/binary-tree-maximum-path-sum/](https://leetcode.cn/problems/binary-tree-maximum-path-sum/)
    *   经典难题，需要深入理解递归和状态传递。
    ```javascript
    var maxPathSum = function(root) {
        let maxSum = -Infinity;

        const maxGain = (node) => {
            if (!node) return 0;

            // 递归计算左右子节点的最大贡献值
            // 只有当贡献值大于0时才选取，否则舍弃
            const leftGain = Math.max(maxGain(node.left), 0);
            const rightGain = Math.max(maxGain(node.right), 0);

            // 当前节点的最大路径和 = 当前节点值 + 左子树贡献 + 右子树贡献
            const currentPathSum = node.val + leftGain + rightGain;
            
            // 更新全局最大路径和
            maxSum = Math.max(maxSum, currentPathSum);

            // 返回当前节点能为父节点提供的最大贡献值
            return node.val + Math.max(leftGain, rightGain);
        };

        maxGain(root);
        return maxSum;
    };
    ```
*   **236. 二叉树的最近公共祖先** (Medium): [https://leetcode.cn/problems/lowest-common-ancestor-of-a-binary-tree/](https://leetcode.cn/problems/lowest-common-ancestor-of-a-binary-tree/)
    *   重要的递归思路，分情况讨论 P 和 Q 的位置。
    ```javascript
    var lowestCommonAncestor = function(root, p, q) {
        if (!root || root === p || root === q) {
            return root;
        }
        const left = lowestCommonAncestor(root.left, p, q);
        const right = lowestCommonAncestor(root.right, p, q);

        if (left && right) { // p和q分别在左右子树
            return root;
        }
        if (left) { // p和q都在左子树
            return left;
        }
        return right; // p和q都在右子树
    };
    ```

掌握了这些二叉树的基础知识和题目，你就能很好地应对相关的算法面试和数据结构问题了！
````

掌握了这些二叉树的基础知识和题目，你就能很好地应对相关的算法面试和数据结构问题了！