AC 自动机（Aho-Corasick Automaton）是一种多模式匹配算法，它能够在线性时间内查找一个文本中所有出现的模式串。它结合了 Trie 树和 KMP 算法的思想，常用于敏感词过滤、病毒检测等场景。

### AC 自动机的数据结构和构建

AC 自动机主要由以下几部分组成：

1.  **Trie 树（或称字典树）**：用于存储所有的模式串。每个节点代表一个字符串的前缀。
2.  **失配指针（Failure Link）**：每个节点有一个失配指针，指向在当前节点无法匹配时，下一个尝试匹配的节点。这个指针指向的是当前节点所代表的最长真后缀，且该后缀也是某个模式串的前缀。
3.  **输出（Output）或结束标记**：标记一个节点是否是某个模式串的结尾，以及是哪个模式串的结尾。

**构建过程：**

1.  **构建 Trie 树**：将所有模式串插入到 Trie 树中。
2.  **构建失配指针**：通过广度优先搜索（BFS）构建。
    *   根节点的子节点的失配指针都指向根节点。
    *   对于其他节点 `u`，假设它的父节点是 `p`，并且 `p` 的失配指针指向 `fail[p]`。如果 `fail[p]` 也有一个子节点和 `u` 对应的字符相同，那么 `u` 的失配指针就指向 `fail[p]` 的这个子节点。
    *   如果 `fail[p]` 没有对应的子节点，就继续沿着 `fail[p]` 的失配指针向上查找，直到找到或到达根节点。
3.  **处理输出**：为了方便后续的匹配，通常会将一个节点的失配指针指向的节点的输出也“链接”到当前节点，这样在匹配到当前节点时，也能同时发现失配指针指向的节点所代表的模式串。

### JavaScript 代码实现

以下是一个简化的 AC 自动机 JavaScript 实现：

```javascript
class TrieNode {
    constructor() {
        this.children = {}; // 子节点，key为字符，value为TrieNode
        this.parent = null; // 父节点
        this.char = '';     // 当前节点代表的字符
        this.isEndOfWord = false; // 是否是模式串的结尾
        this.word = '';       // 如果是结尾，存储对应的模式串
        this.failureLink = null; // 失配指针
        this.outputLink = null; // 输出链，用于快速查找所有匹配到的模式串
        this.wordList = [];   // 存储以当前节点为结尾的所有模式串
    }
}

class AhoCorasick {
    constructor() {
        this.root = new TrieNode();
    }

    // 1. 插入模式串到Trie树
    insert(word) {
        let node = this.root;
        for (let i = 0; i < word.length; i++) {
            const char = word[i];
            if (!node.children[char]) {
                node.children[char] = new TrieNode();
                node.children[char].parent = node;
                node.children[char].char = char;
            }
            node = node.children[char];
        }
        node.isEndOfWord = true;
        node.word = word;
        node.wordList.push(word); // 将当前模式串添加到wordList
    }

    // 2. 构建失配指针 (BFS)
    buildFailureLinks() {
        const queue = [];

        // 根节点的子节点的失配指针指向根节点
        for (const char in this.root.children) {
            const child = this.root.children[char];
            queue.push(child);
            child.failureLink = this.root;
        }

        while (queue.length > 0) {
            const currentNode = queue.shift();

            for (const char in currentNode.children) {
                const child = currentNode.children[char];
                queue.push(child);

                let failureNode = currentNode.failureLink;
                // 沿着失配指针向上查找，直到找到匹配的字符或到达根节点
                while (failureNode && !failureNode.children[char]) {
                    failureNode = failureNode.failureLink;
                }

                if (failureNode && failureNode.children[char]) {
                    child.failureLink = failureNode.children[char];
                } else {
                    child.failureLink = this.root; // 如果没找到，指向根节点
                }

                // 处理输出链：将失配指针指向的节点的wordList合并到当前节点的wordList
                if (child.failureLink && child.failureLink.wordList.length > 0) {
                    child.wordList = child.wordList.concat(child.failureLink.wordList);
                }
            }
        }
    }

    // 3. 匹配文本
    findAll(text) {
        const matches = [];
        let currentNode = this.root;

        for (let i = 0; i < text.length; i++) {
            const char = text[i];

            // 沿着失配指针回溯，直到找到匹配的字符或到达根节点
            while (currentNode && !currentNode.children[char] && currentNode !== this.root) {
                currentNode = currentNode.failureLink;
            }

            if (currentNode.children[char]) {
                currentNode = currentNode.children[char];
            } else {
                currentNode = this.root; // 如果没找到，回到根节点
            }

            // 如果当前节点有匹配到的模式串
            if (currentNode.wordList.length > 0) {
                currentNode.wordList.forEach(word => {
                    matches.push({
                        word: word,
                        index: i - word.length + 1 // 计算匹配到的起始索引
                    });
                });
            }
        }
        return matches;
    }

    // 辅助函数，用于将所有模式串插入并构建AC自动机
    build(patterns) {
        patterns.forEach(pattern => this.insert(pattern));
        this.buildFailureLinks();
    }
}
```

### 应用示例

#### 示例 1：敏感词过滤

```javascript
const sensitiveWords = ["暴力", "赌博", "色情", "毒品", "枪支"];
const acAutomaton = new AhoCorasick();
acAutomaton.build(sensitiveWords);

const text1 = "这是一段包含暴力和赌博的文字。";
const matches1 = acAutomaton.findAll(text1);
console.log("文本1匹配结果:", matches1);
// 预期输出:
// [
//   { word: '暴力', index: 6 },
//   { word: '赌博', index: 9 }
// ]

const text2 = "这是一段干净的文字，没有敏感词。";
const matches2 = acAutomaton.findAll(text2);
console.log("文本2匹配结果:", matches2);
// 预期输出: []

const text3 = "毒品交易是违法的行为。";
const matches3 = acAutomaton.findAll(text3);
console.log("文本3匹配结果:", matches3);
// 预期输出: [{ word: '毒品', index: 0 }]
```

#### 示例 2：关键词提取

```javascript
const keywords = ["JavaScript", "Python", "前端", "后端", "算法", "数据结构"];
const acAutomatonKeywords = new AhoCorasick();
acAutomatonKeywords.build(keywords);

const article = "学习JavaScript和Python是前端和后端开发者的必备技能。深入理解数据结构和算法对于提升编程能力至关重要。";
const foundKeywords = acAutomatonKeywords.findAll(article);
console.log("文章中的关键词:", foundKeywords);
// 预期输出:
// [
//   { word: 'JavaScript', index: 2 },
//   { word: 'Python', index: 12 },
//   { word: '前端', index: 17 },
//   { word: '后端', index: 20 },
//   { word: '数据结构', index: 44 },
//   { word: '算法', index: 48 }
// ]
```

### AC 自动机的优势和适用场景

**优势：**

*   **高效性**：在文本长度为 `N`，模式串总长度为 `M` 的情况下，构建时间复杂度为 `O(M)`，匹配时间复杂度为 `O(N + K)` (其中 `K` 为匹配到的模式串的数量)。相比于朴素的多模式匹配算法（`O(N * M)`）或多次使用 KMP 算法（`O(N * M_avg)`），效率显著提高。
*   **一次遍历**：只需要对文本进行一次扫描，就能找出所有模式串。

**适用场景：**

*   **敏感词过滤**：在一个长文本中快速找出所有预设的敏感词。
*   **病毒特征码扫描**：在文件中查找已知的病毒特征码。
*   **网络入侵检测系统 (IDS)**：检测网络流量中是否存在恶意攻击模式。
*   **关键词提取**：从文章或文档中提取预设的关键词。
*   **搜索引擎**：优化多关键词的匹配和高亮。

### 可视化解释

为了更好地理解 AC 自动机的构建过程，特别是失配指针的作用，通常会用图来表示。

构建一个包含模式串 "he", "she", "his", "hers" 的 AC 自动机：

1.  **Trie 树部分：**
    