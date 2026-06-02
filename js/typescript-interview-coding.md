# TypeScript 面试手写题（实战版）

结构：**题目 -> 实现 -> 追问点**。  
目标：让你不仅会“说”，还能“写”。

## 1) 手写 `MyPick<T, K>`

### 题目

实现和内置 `Pick` 等价的类型。

### 实现

```ts
type MyPick<T, K extends keyof T> = {
  [P in K]: T[P];
};
```

### 追问点

- 为什么 `K` 要 `extends keyof T`？（防止 key 越界）

---

## 2) 手写 `MyOmit<T, K>`

```ts
type MyOmit<T, K extends keyof any> = Pick<T, Exclude<keyof T, K>>;
```

### 追问点

- 为什么 `K` 常写成 `keyof any`？（兼容 string/number/symbol 键）

---

## 3) 手写 `MyPartial<T>`

```ts
type MyPartial<T> = {
  [P in keyof T]?: T[P];
};
```

---

## 4) 手写 `MyRequired<T>`

```ts
type MyRequired<T> = {
  [P in keyof T]-?: T[P];
};
```

### 追问点

- `-?` 的含义是什么？（去掉可选修饰符）

---

## 5) 手写 `MyReadonly<T>`

```ts
type MyReadonly<T> = {
  readonly [P in keyof T]: T[P];
};
```

---

## 6) 手写 `MyRecord<K, V>`

```ts
type MyRecord<K extends keyof any, V> = {
  [P in K]: V;
};
```

---

## 7) 手写 `MyExclude<T, U>` 和 `MyExtract<T, U>`

```ts
type MyExclude<T, U> = T extends U ? never : T;
type MyExtract<T, U> = T extends U ? T : never;
```

---

## 8) 手写 `MyNonNullable<T>`

```ts
type MyNonNullable<T> = T extends null | undefined ? never : T;
```

---

## 9) 手写 `MyReturnType<T>`

```ts
type MyReturnType<T extends (...args: any[]) => any> =
  T extends (...args: any[]) => infer R ? R : never;
```

---

## 10) 手写 `MyParameters<T>`

```ts
type MyParameters<T extends (...args: any[]) => any> =
  T extends (...args: infer P) => any ? P : never;
```

---

## 11) 手写 `MyAwaited<T>`

### 题目

递归展开 Promise，直到拿到最终值类型。

### 实现

```ts
type MyAwaited<T> = T extends PromiseLike<infer U> ? MyAwaited<U> : T;

type A = MyAwaited<Promise<Promise<number>>>; // number
```

### 追问点

- 为什么用 `PromiseLike` 而不是 `Promise`？（兼容 thenable）

---

## 12) 手写 `DeepPartial<T>`

### 实现

```ts
type DeepPartial<T> = T extends Function
  ? T
  : T extends object
    ? { [K in keyof T]?: DeepPartial<T[K]> }
    : T;
```

### 追问点

- 数组在 TS 中也是 object，这个实现是否符合预期？

---

## 13) 手写 `DeepReadonly<T>`

```ts
type DeepReadonly<T> = T extends Function
  ? T
  : T extends object
    ? { readonly [K in keyof T]: DeepReadonly<T[K]> }
    : T;
```

---

## 14) 手写 `Mutable<T>`

```ts
type Mutable<T> = {
  -readonly [K in keyof T]: T[K];
};
```

---

## 15) 手写字符串工具类型 `TrimLeft`

```ts
type WhiteSpace = " " | "\n" | "\t";

type TrimLeft<S extends string> = S extends `${WhiteSpace}${infer Rest}`
  ? TrimLeft<Rest>
  : S;
```

---

## 16) 手写 `TupleToUnion<T>`

```ts
type TupleToUnion<T extends readonly any[]> = T[number];

type U = TupleToUnion<["a", "b", "c"]>; // "a" | "b" | "c"
```

---

## 17) 手写 `First<T>` / `Last<T>`

```ts
type First<T extends any[]> = T extends [infer F, ...any[]] ? F : never;
type Last<T extends any[]> = T extends [...any[], infer L] ? L : never;
```

---

## 18) 手写 `PromiseAll` 的类型签名

### 题目

实现一个函数签名，使其返回值保留元组中每一项的 resolved 类型。

### 实现

```ts
declare function promiseAll<T extends readonly unknown[]>(
  values: [...T]
): Promise<{ [K in keyof T]: MyAwaited<T[K]> }>;

// 用法推导
const p = promiseAll([Promise.resolve(1), "x", Promise.resolve(true)] as const);
// Promise<[1, "x", true]>
```

---

## 19) 类型安全事件总线（手写）

### 题目

实现一个事件总线，要求：
- 事件名受类型约束
- `on/emit` 参数自动推导

### 实现

```ts
type EventMap = {
  login: { userId: string };
  logout: { userId: string };
  error: { message: string; code?: number };
};

class TypedEmitter<E extends Record<string, any>> {
  private listeners: {
    [K in keyof E]?: Array<(payload: E[K]) => void>;
  } = {};

  on<K extends keyof E>(event: K, cb: (payload: E[K]) => void) {
    (this.listeners[event] ||= []).push(cb);
  }

  emit<K extends keyof E>(event: K, payload: E[K]) {
    this.listeners[event]?.forEach((cb) => cb(payload));
  }
}

const emitter = new TypedEmitter<EventMap>();
emitter.on("login", (p) => console.log(p.userId));
emitter.emit("error", { message: "network failed" });
```

### 追问点

- 如何支持 `once`、`off`？
- 如何支持不带 payload 的事件？

---

## 20) 类型安全 API Client（手写）

### 题目

根据接口定义自动约束请求参数与返回值。

### 实现

```ts
type ApiDef = {
  "/user/get": {
    req: { id: string };
    res: { id: string; name: string };
  };
  "/user/list": {
    req: { page: number; size: number };
    res: { list: Array<{ id: string; name: string }>; total: number };
  };
};

async function request<K extends keyof ApiDef>(
  path: K,
  body: ApiDef[K]["req"]
): Promise<ApiDef[K]["res"]> {
  // 这里只演示类型，真实场景替换为 fetch/axios
  return {} as ApiDef[K]["res"];
}

request("/user/get", { id: "u1" }).then((res) => {
  console.log(res.name);
});
```

---

## 21) `unknown` 入参 + 类型守卫（手写）

### 实现

```ts
type User = { id: string; name: string };

function isUser(data: unknown): data is User {
  return (
    typeof data === "object" &&
    data !== null &&
    "id" in data &&
    "name" in data
  );
}

function parseUser(data: unknown): User {
  if (!isUser(data)) {
    throw new Error("invalid user payload");
  }
  return data;
}
```

---

## 22) React 场景：泛型列表组件（手写）

```tsx
import React from "react";

type ListProps<T> = {
  data: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  keyExtractor: (item: T) => React.Key;
};

function List<T>(props: ListProps<T>) {
  const { data, renderItem, keyExtractor } = props;
  return (
    <ul>
      {data.map((item, index) => (
        <li key={keyExtractor(item)}>{renderItem(item, index)}</li>
      ))}
    </ul>
  );
}
```

### 追问点

- 泛型组件在 JSX 中如何显式传类型参数？
- 如何约束 `T` 必须包含 `id` 字段？

---

## 23) 面试高频追问模板（口述）

- 先解释“目标类型是什么”。
- 再解释“用到哪些 TS 能力”（映射类型、条件类型、infer）。
- 最后讲“边界和限制”（如数组、函数、递归深度）。

---

## 24) 一页速记

- 映射类型：`keyof + in`。
- 条件类型：`extends ? :`。
- 提取类型：`infer`。
- 深层递归：`DeepPartial/DeepReadonly`。
- 工程落地：Typed Emitter、Typed API Client、unknown + 守卫。

---

如果你继续要，我可以再补一版 `js/typescript-interview-mistakes.md`，做成 TS 易错点纠正版（类似 ES6 那份 50 题）。  
