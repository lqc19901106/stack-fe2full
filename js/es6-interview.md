# ES6 面试高频整理

本文按“概念 -> 高频问法 -> 示例”整理，适合前端面试前快速过一遍。

## 1. let / const / var 区别

### 核心点

- `var` 存在变量提升，且可重复声明。
- `let`、`const` 存在暂时性死区（TDZ）。
- `let`、`const` 是块级作用域。
- `const` 不能重新赋值，但如果是对象，可修改内部属性。

### 高频问法

- 为什么 `let` 可以解决循环里闭包取值问题？
- `const` 定义对象后到底能不能改？

### 示例

```js
for (let i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 0); // 0 1 2
}

const user = { name: "Tom" };
user.name = "Jerry"; // 可以
// user = {} // 不可以，重新赋值会报错
```

## 2. 箭头函数

### 核心点

- 箭头函数没有自己的 `this`，`this` 来自外层词法作用域。
- 没有 `arguments`，可用剩余参数 `...args`。
- 不能作为构造函数（不能 `new`）。

### 高频问法

- 为什么在 `setTimeout` 回调里常用箭头函数？
- 箭头函数和普通函数的 `this` 指向有何区别？

### 示例

```js
const obj = {
  count: 0,
  inc() {
    setTimeout(() => {
      this.count++;
      console.log(this.count); // 1
    }, 100);
  },
};
obj.inc();
```

## 3. 模板字符串

### 核心点

- 使用反引号 `` ` `` 支持多行字符串和插值 `${}`。
- 可读性高，常用于拼接 HTML 或日志文本。

```js
const name = "Alice";
const msg = `Hello, ${name}.
Welcome to ES6 interview.`;
```

## 4. 解构赋值

### 核心点

- 支持数组和对象解构。
- 支持默认值、重命名、嵌套解构。

### 高频问法

- 函数参数解构有什么优势？
- 解构默认值在什么情况下生效？

### 示例

```js
const [a, b = 2] = [1];
const { name: userName, age = 18 } = { name: "Tom" };

function printUser({ name, city = "Unknown" }) {
  console.log(name, city);
}
```

## 5. 扩展运算符与剩余参数

### 核心点

- `...` 在不同位置语义不同：
  - 展开（数组/对象展开）
  - 收集（函数剩余参数）

### 示例

```js
const arr1 = [1, 2];
const arr2 = [...arr1, 3, 4];

const obj1 = { a: 1 };
const obj2 = { ...obj1, b: 2 };

function sum(...nums) {
  return nums.reduce((acc, n) => acc + n, 0);
}
```

## 6. Promise

### 核心点

- 三种状态：`pending`、`fulfilled`、`rejected`。
- 状态一旦改变不可逆。
- `then` 返回新 Promise，可链式调用。

### 高频问法

- `Promise.all` 和 `Promise.allSettled` 的区别？
- 如何处理中途某个 Promise 失败？

### 示例

```js
Promise.all([Promise.resolve(1), Promise.resolve(2)])
  .then((res) => console.log(res)) // [1, 2]
  .catch((err) => console.error(err));
```

## 7. async / await

### 核心点

- `async` 函数总是返回 Promise。
- `await` 后面通常跟 Promise，写法更接近同步。
- 错误处理要用 `try...catch`。
- `await` 不会阻塞主线程，只会暂停当前 `async` 函数。
- `await` 后面的代码会放入微任务队列，晚于当前同步代码执行。

### 高频问法

- `async/await` 和 `Promise.then` 的关系是什么？
- `await` 串行和 `Promise.all` 并行如何选择？
- 为什么 `await` 可能导致性能下降？
- `return` 和 `return await` 有什么区别？
- 如何在 `async` 函数里做统一错误处理？

### 执行机制（面试答题版）

可以直接这样答：

1. `async` 函数调用后立即返回一个 Promise。
2. 执行到 `await` 时，函数先“让出执行权”。
3. `await` 等待的 Promise 完成后，把后续逻辑放进微任务队列。
4. 当前调用栈清空后，继续执行 `await` 后面的代码。

### 示例 1：基础请求与错误处理

```js
async function fetchData() {
  try {
    const res = await fetch("/api/user");
    if (!res.ok) {
      throw new Error(`HTTP ${res.status}`);
    }
    const data = await res.json();
    return data;
  } catch (e) {
    console.error("request failed:", e);
    throw e; // 继续向上抛出，让调用方决定如何兜底
  }
}
```

### 示例 2：串行 vs 并行

```js
// 串行：后一个依赖前一个结果时使用
async function loadSerial() {
  const userRes = await fetch("/api/user");
  const user = await userRes.json();

  const orderRes = await fetch(`/api/orders?uid=${user.id}`);
  const orders = await orderRes.json();
  return { user, orders };
}

// 并行：互不依赖时优先并行，性能更好
async function loadParallel() {
  const [userRes, orderRes] = await Promise.all([
    fetch("/api/user"),
    fetch("/api/orders"),
  ]);
  const [user, orders] = await Promise.all([userRes.json(), orderRes.json()]);
  return { user, orders };
}
```

### 示例 3：`return` vs `return await`

```js
async function directReturn() {
  // 直接返回 Promise，错误由调用方处理
  return fetch("/api/user");
}

async function returnAwait() {
  try {
    // 在当前函数内等待，便于在此处被 try/catch 捕获
    return await fetch("/api/user");
  } catch (e) {
    console.error("caught in function:", e);
    throw e;
  }
}
```

### 常见陷阱

- 在循环里连续 `await` 导致不必要串行，性能变慢。
- 忘记 `try...catch`，导致 Promise rejection 未处理。
- 把 `await` 放在不需要等待的地方，拉长链路耗时。
- 误以为 `await` 会阻塞线程（实际上不会阻塞主线程）。

### 最佳实践

- 有依赖关系用串行，无依赖关系用 `Promise.all`。
- 每层只处理自己能处理的错误，其他错误继续抛出。
- 对外部 IO（请求、文件、数据库）统一超时和重试策略。
- 重要异步流程增加日志上下文（请求 ID、参数、耗时）。

### 一句速记

`async/await` 是 Promise 的语法糖：可读性更好，但并发与错误处理策略仍要主动设计。
```

## 8. Class 与继承

### 核心点

- `class` 是语法糖，本质还是原型链。
- `extends` 实现继承，子类中用 `super()` 调用父类构造。
- 实例方法在 `prototype` 上。

### 高频问法

- `class` 和构造函数有何关系？
- `super` 必须在什么时候调用？

### 示例

```js
class Animal {
  constructor(name) {
    this.name = name;
  }
  speak() {
    return `${this.name} makes a sound`;
  }
}

class Dog extends Animal {
  constructor(name) {
    super(name);
  }
  speak() {
    return `${this.name} barks`;
  }
}
```

## 9. 模块化（import / export）

### 核心点

- ES6 模块是静态结构，编译时可分析依赖。
- `export default` 每个模块只能有一个默认导出。
- 可同时存在默认导出和具名导出。

### 示例

```js
// utils.js
export const PI = 3.14;
export default function add(a, b) {
  return a + b;
}

// app.js
import add, { PI } from "./utils.js";
console.log(add(1, 2), PI);
```

## 10. Set / WeakSet / Map / WeakMap

### 核心点

- `Set`：值唯一，常用于数组去重。
- `WeakSet`：成员只能是对象，且是弱引用，不能遍历。
- `Map`：键值对集合，键可为任意类型，可遍历，有 `size`。
- `WeakMap`：键只能是对象，键是弱引用，不能遍历，无 `size`。

### 区别速记（面试高频）

| 类型 | 键/值限制 | 是否弱引用 | 是否可遍历 | 典型场景 |
| --- | --- | --- | --- | --- |
| `Set` | 值可为任意类型 | 否 | 是 | 去重、成员集合 |
| `WeakSet` | 值只能是对象 | 是 | 否 | 临时对象标记、避免内存泄漏 |
| `Map` | 键可为任意类型 | 否 | 是 | 通用键值映射、缓存 |
| `WeakMap` | 键只能是对象 | 是 | 否 | 对象私有数据、DOM 关联缓存 |

面试可直接答：
- 需要遍历和统计数量，用 `Set/Map`。
- 只想给对象挂“外部私有信息”，并希望对象销毁后自动释放，用 `WeakSet/WeakMap`。

### 示例

```js
const unique = [...new Set([1, 1, 2, 3])]; // [1, 2, 3]

const map = new Map();
const keyObj = { id: 1 };
map.set(keyObj, "value");
console.log(map.get(keyObj)); // value

const ws = new WeakSet();
const wm = new WeakMap();
const obj = { name: "Tom" };
ws.add(obj);
wm.set(obj, { visited: true });
console.log(wm.get(obj)); // { visited: true }
```

## 11. Symbol

### 核心点

- `Symbol` 是唯一值，常用于对象私有标识或避免键名冲突。
- `Symbol.for` 可复用全局注册表中的 Symbol。

```js
const id = Symbol("id");
const user = { [id]: 123, name: "Tom" };
```

## 12. Iterator 与 for...of

### 核心点

- 可迭代对象需实现 `Symbol.iterator`。
- `for...of` 用于遍历可迭代对象的值。
- `for...in` 遍历对象可枚举键名，不同于 `for...of`。

### 示例

```js
const arr = ["a", "b", "c"];
for (const item of arr) {
  console.log(item);
}
```

## 13. Generator

### 核心点

- `function*` 定义生成器。
- `yield` 可暂停执行并返回中间结果。
- 常用于异步流程控制（在 `async/await` 普及前更常见）。

```js
function* gen() {
  yield 1;
  yield 2;
  return 3;
}
const it = gen();
console.log(it.next()); // { value: 1, done: false }
```

## 14. Proxy 与 Reflect

### 核心点

- `Proxy` 可拦截对象的读写、删除、函数调用等操作。
- `Reflect` 提供与 Proxy handler 一一对应的默认行为方法。

```js
const target = { count: 0 };
const p = new Proxy(target, {
  get(obj, key) {
    return Reflect.get(obj, key);
  },
  set(obj, key, value) {
    if (key === "count" && value < 0) return false;
    return Reflect.set(obj, key, value);
  },
});
```

## 15. 面试速记清单

- 作用域与提升：`var` / `let` / `const`、TDZ、闭包。
- 函数：箭头函数 `this`、参数默认值、剩余参数。
- 异步：Promise 链、`all` / `race` / `allSettled`、`async/await` 错误处理。
- 对象与数组：解构、展开、浅拷贝陷阱。
- 面向对象：`class`、继承、原型链本质。
- 模块化：`import/export`、默认导出与具名导出。
- 常用新对象：Map、WeakMap、Set、WeakSet、Symbol、Proxy、Reflect。

## 16. 常见追问题（建议自测）

1. `let` 为什么能解决 `for + setTimeout` 的经典问题？
2. `Promise.resolve().then(...)` 和 `setTimeout(..., 0)` 执行顺序如何？
3. `async` 函数里 `return` 和 `throw` 分别等价于什么？
4. `Object.assign` 和展开运算符是深拷贝吗？
5. 为什么说 ES Module 是“静态依赖”？
6. `for...in`、`for...of`、`Object.keys` 有什么区别？
7. `Map` / `WeakMap`、`Set` / `WeakSet` 的核心区别是什么？

---

如果你要，我可以再补一版 `js/es6-interview-qa.md`，做成“面试官提问 + 标准回答 + 易错点”的问答版，背起来更快。
