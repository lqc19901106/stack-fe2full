# ES6 面试手写题实战版

这份文档只放高频手写题，结构为：**题目 -> 思路 -> 可背实现 -> 追问点**。

## 1) 手写 `Promise.all`

### 题目

实现 `myPromiseAll(promises)`，要求：
- 全部成功则按原顺序返回结果数组。
- 任意一个失败则立即 `reject`。
- 输入可包含普通值（按 `Promise.resolve` 处理）。

### 实现

```js
function myPromiseAll(iterable) {
  return new Promise((resolve, reject) => {
    const arr = Array.from(iterable);
    if (arr.length === 0) return resolve([]);

    const results = new Array(arr.length);
    let count = 0;

    arr.forEach((item, index) => {
      Promise.resolve(item)
        .then((value) => {
          results[index] = value;
          count++;
          if (count === arr.length) resolve(results);
        })
        .catch(reject);
    });
  });
}
```

### 追问点

- 为什么需要 `Array.from`？（兼容可迭代对象）
- 为什么要按 `index` 存结果？（保证顺序）

---

## 2) 手写 `Promise.race`

```js
function myPromiseRace(iterable) {
  return new Promise((resolve, reject) => {
    for (const item of iterable) {
      Promise.resolve(item).then(resolve, reject);
    }
  });
}
```

---

## 3) 手写 `Promise.allSettled`

```js
function myPromiseAllSettled(iterable) {
  const arr = Array.from(iterable);
  if (arr.length === 0) return Promise.resolve([]);

  return new Promise((resolve) => {
    const results = new Array(arr.length);
    let count = 0;

    arr.forEach((item, index) => {
      Promise.resolve(item)
        .then((value) => {
          results[index] = { status: "fulfilled", value };
        })
        .catch((reason) => {
          results[index] = { status: "rejected", reason };
        })
        .finally(() => {
          count++;
          if (count === arr.length) resolve(results);
        });
    });
  });
}
```

---

## 4) 手写 `new` 操作符

### 思路

1. 创建一个新对象。
2. 把新对象原型指向构造函数 `prototype`。
3. 用新对象执行构造函数，拿到返回值。
4. 若返回对象类型则用它，否则返回新对象。

### 实现

```js
function myNew(Constructor, ...args) {
  if (typeof Constructor !== "function") {
    throw new TypeError("Constructor must be a function");
  }

  const obj = Object.create(Constructor.prototype);
  const ret = Constructor.apply(obj, args);

  return ret !== null && (typeof ret === "object" || typeof ret === "function")
    ? ret
    : obj;
}
```

---

## 5) 手写 `instanceof`

```js
function myInstanceof(left, right) {
  if (left == null || (typeof left !== "object" && typeof left !== "function")) {
    return false;
  }
  let proto = Object.getPrototypeOf(left);
  const prototype = right.prototype;

  while (proto) {
    if (proto === prototype) return true;
    proto = Object.getPrototypeOf(proto);
  }
  return false;
}
```

---

## 6) 手写防抖 `debounce`

### 题目要求（常见）

- 触发后延迟执行。
- 多次触发只执行最后一次。
- 支持立即执行（leading）。

### 实现

```js
function debounce(fn, wait = 300, immediate = false) {
  let timer = null;

  return function (...args) {
    const context = this;
    const callNow = immediate && !timer;

    clearTimeout(timer);
    timer = setTimeout(() => {
      timer = null;
      if (!immediate) fn.apply(context, args);
    }, wait);

    if (callNow) fn.apply(context, args);
  };
}
```

---

## 7) 手写节流 `throttle`

### 时间戳版

```js
function throttle(fn, wait = 300) {
  let last = 0;
  return function (...args) {
    const now = Date.now();
    if (now - last >= wait) {
      last = now;
      fn.apply(this, args);
    }
  };
}
```

### 定时器版

```js
function throttleWithTimer(fn, wait = 300) {
  let timer = null;
  return function (...args) {
    if (timer) return;
    timer = setTimeout(() => {
      fn.apply(this, args);
      timer = null;
    }, wait);
  };
}
```

---

## 8) 手写深拷贝（含循环引用）

### 题目要求（常见）

- 支持对象、数组。
- 处理循环引用。
- 基础类型直接返回。

### 实现

```js
function deepClone(value, map = new WeakMap()) {
  if (value === null || typeof value !== "object") return value;
  if (map.has(value)) return map.get(value);

  const result = Array.isArray(value) ? [] : {};
  map.set(value, result);

  for (const key of Reflect.ownKeys(value)) {
    result[key] = deepClone(value[key], map);
  }
  return result;
}
```

### 追问点

- 这个版本未完整处理 `Date/RegExp/Map/Set`，面试可主动说明扩展思路。

---

## 9) 手写对象扁平化

```js
function flattenObject(obj, prefix = "", result = {}) {
  for (const key of Object.keys(obj)) {
    const val = obj[key];
    const newKey = prefix ? `${prefix}.${key}` : key;

    if (val && typeof val === "object" && !Array.isArray(val)) {
      flattenObject(val, newKey, result);
    } else {
      result[newKey] = val;
    }
  }
  return result;
}
```

---

## 10) 手写数组去重（多方案）

```js
// 方案1：Set
const unique1 = (arr) => [...new Set(arr)];

// 方案2：Map
function unique2(arr) {
  const map = new Map();
  const res = [];
  for (const item of arr) {
    if (!map.has(item)) {
      map.set(item, true);
      res.push(item);
    }
  }
  return res;
}
```

---

## 11) 手写 `compose`（函数组合）

```js
function compose(...fns) {
  if (fns.length === 0) return (x) => x;
  if (fns.length === 1) return fns[0];
  return fns.reduce(
    (prev, curr) =>
      (...args) =>
        prev(curr(...args))
  );
}
```

---

## 12) 手写 `curry`（柯里化）

```js
function curry(fn, ...presetArgs) {
  return function curried(...args) {
    const allArgs = [...presetArgs, ...args];
    if (allArgs.length >= fn.length) {
      return fn.apply(this, allArgs);
    }
    return curry(fn, ...allArgs);
  };
}

// 示例
const add = (a, b, c) => a + b + c;
const cAdd = curry(add);
// cAdd(1)(2)(3) === 6
```

---

## 13) 手写简版 `EventEmitter`

```js
class EventEmitter {
  constructor() {
    this.events = new Map();
  }

  on(event, listener) {
    const arr = this.events.get(event) || [];
    arr.push(listener);
    this.events.set(event, arr);
    return this;
  }

  off(event, listener) {
    const arr = this.events.get(event) || [];
    this.events.set(
      event,
      arr.filter((fn) => fn !== listener)
    );
    return this;
  }

  once(event, listener) {
    const wrapper = (...args) => {
      listener(...args);
      this.off(event, wrapper);
    };
    this.on(event, wrapper);
    return this;
  }

  emit(event, ...args) {
    const arr = this.events.get(event) || [];
    arr.forEach((fn) => fn(...args));
    return this;
  }
}
```

---

## 14) 手写并发控制（Promise Pool）

### 题目

有一组异步任务，限制最大并发数为 `limit`。

### 实现

```js
async function asyncPool(limit, tasks, iteratorFn) {
  const ret = [];
  const executing = [];

  for (const task of tasks) {
    const p = Promise.resolve().then(() => iteratorFn(task));
    ret.push(p);

    if (limit <= tasks.length) {
      const e = p.then(() => {
        const idx = executing.indexOf(e);
        if (idx >= 0) executing.splice(idx, 1);
      });
      executing.push(e);

      if (executing.length >= limit) {
        await Promise.race(executing);
      }
    }
  }

  return Promise.all(ret);
}
```

---

## 15) 手写 `sleep`

```js
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// 用法
// await sleep(1000);
```

---

## 16) 手写支持取消的请求包装（基础版）

```js
function cancellable(promiseFactory) {
  let canceled = false;

  const wrapped = new Promise((resolve, reject) => {
    promiseFactory()
      .then((res) => (canceled ? reject(new Error("Canceled")) : resolve(res)))
      .catch((err) => (canceled ? reject(new Error("Canceled")) : reject(err)));
  });

  return {
    promise: wrapped,
    cancel() {
      canceled = true;
    },
  };
}
```

---

## 17) 事件循环手写题常见输出分析模板

面试时看类似代码：

```js
console.log(1);
setTimeout(() => console.log(2), 0);
Promise.resolve().then(() => console.log(3));
console.log(4);
```

回答模板：

1. 先执行同步：`1、4`
2. 清空微任务：`3`
3. 再执行宏任务：`2`
4. 最终输出：`1 4 3 2`

---

## 18) 手写题答题策略（高分版）

- 先确认需求边界（是否考虑空输入、异常、顺序、并发）。
- 先写函数签名和主流程，再补边界。
- 每题主动说时间复杂度/空间复杂度。
- 主动说明“工程版还会补测试和类型定义”。
- 写完给一个最小可运行示例。

---

## 19) 一页速记（可直接背）

- Promise 题核心：状态流转、顺序保证、失败短路。
- 对象题核心：原型链、引用类型、浅深拷贝。
- 高频工具题：防抖、节流、并发控制、事件发布订阅。
- 面试加分点：边界处理、复杂度、可扩展性说明。

---

如果你继续要，我可以再补第四版：`js/es6-interview-mistakes.md`，专门整理“最容易答错的 50 个坑点 + 纠正答案”。  
