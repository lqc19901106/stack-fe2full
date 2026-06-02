# TypeScript 面试题整理（高频版）

这份文档按“题目 -> 回答要点 -> 简短示例”整理，适合前端/Node 岗位面试复习。

## 1. TypeScript 和 JavaScript 的核心区别是什么？

### 回答要点

- TypeScript 是 JavaScript 的超集，增加了静态类型系统。
- TS 在编译阶段做类型检查，运行时仍是 JS。
- TS 的价值主要是提升可维护性、可重构性和多人协作效率。

## 2. `any`、`unknown`、`never` 的区别？

### 回答要点

- `any`：关闭类型检查，什么都能赋值、调用、访问。
- `unknown`：安全版 `any`，使用前必须先缩小类型。
- `never`：表示不可能出现的值（如抛异常函数、死循环、穷尽检查）。

### 示例

```ts
let a: any = 1;
a.foo.bar(); // 不报类型错（但运行时可能报错）

let u: unknown = "hello";
if (typeof u === "string") {
  console.log(u.toUpperCase()); // 需要先缩小类型
}

function fail(msg: string): never {
  throw new Error(msg);
}
```

## 3. `type` 和 `interface` 有什么区别？

### 回答要点

- 都能描述对象类型。
- `interface` 支持声明合并，更适合对外 API 约束。
- `type` 更灵活，可表示联合、交叉、元组、条件类型等复杂类型。

### 示例

```ts
interface User {
  id: number;
  name: string;
}

type ID = string | number;
type Point = { x: number } & { y: number };
```

## 4. 什么是联合类型和交叉类型？

### 回答要点

- 联合类型 `A | B`：值是 A 或 B。
- 交叉类型 `A & B`：值同时满足 A 和 B。

```ts
type A = { a: string };
type B = { b: number };
type C = A & B; // 必须同时有 a 和 b
```

## 5. 什么是类型缩小（Type Narrowing）？

### 回答要点

- TS 会根据条件判断缩小变量类型。
- 常见方式：`typeof`、`instanceof`、`in`、判空、自定义类型守卫。

### 示例

```ts
function printId(id: string | number) {
  if (typeof id === "string") {
    return id.toUpperCase();
  }
  return id.toFixed(0);
}
```

## 6. 什么是类型守卫（Type Guard）？

### 回答要点

- 类型守卫是返回 `x is T` 的函数，用于告诉 TS “这里可以当成某类型”。

### 示例

```ts
type Cat = { meow: () => void };
type Dog = { bark: () => void };

function isCat(animal: Cat | Dog): animal is Cat {
  return "meow" in animal;
}
```

## 7. 泛型是什么？有什么价值？

### 回答要点

- 泛型用于编写“与具体类型无关但类型安全”的复用逻辑。
- 保留参数类型信息，避免 `any` 丢失约束。

### 示例

```ts
function identity<T>(value: T): T {
  return value;
}

const n = identity<number>(123);
```

## 8. `extends` 在泛型里是什么意思？

### 回答要点

- 在泛型中常用作约束：`T extends SomeType` 表示 T 必须满足某结构。

```ts
function getLength<T extends { length: number }>(x: T) {
  return x.length;
}
```

## 9. `keyof`、`typeof`、`in` 各自做什么？

### 回答要点

- `keyof T`：得到 T 的键联合类型。
- `typeof`（类型上下文）：从值推导类型。
- `in`（映射类型）：遍历键生成新类型。

### 示例

```ts
const user = { id: 1, name: "Tom" };
type User = typeof user; // { id: number; name: string }
type UserKey = keyof User; // "id" | "name"
type ReadonlyUser = { readonly [K in keyof User]: User[K] };
```

## 10. 什么是 `Partial`、`Required`、`Pick`、`Omit`？

### 回答要点

- `Partial<T>`：所有属性变可选。
- `Required<T>`：所有属性变必选。
- `Pick<T, K>`：挑选属性。
- `Omit<T, K>`：排除属性。

```ts
interface User {
  id: number;
  name: string;
  age?: number;
}

type UserPatch = Partial<User>;
type UserBase = Omit<User, "age">;
```

## 11. `Record<K, V>` 的典型场景？

### 回答要点

- 用于“已知 key 集合 -> value 类型一致”的映射结构。

```ts
type Role = "admin" | "user";
type RoleLabel = Record<Role, string>;
```

## 12. 什么是条件类型（Conditional Types）？

### 回答要点

- 形式：`T extends U ? X : Y`。
- 可根据类型条件返回不同类型。

```ts
type IsString<T> = T extends string ? true : false;
type A = IsString<"hi">; // true
type B = IsString<123>; // false
```

## 13. 什么是分布式条件类型？

### 回答要点

- 当条件类型作用于联合类型时会“逐个分发”。

```ts
type ToArray<T> = T extends any ? T[] : never;
type R = ToArray<string | number>; // string[] | number[]
```

## 14. `infer` 关键字有什么用？

### 回答要点

- 在条件类型中提取某部分类型信息。

```ts
type ReturnTypeX<T> = T extends (...args: any[]) => infer R ? R : never;
type R = ReturnTypeX<() => Promise<number>>; // Promise<number>
```

## 15. `as const` 的作用？

### 回答要点

- 把字面量“收窄”为只读字面量类型，而不是宽泛类型。

```ts
const statusMap = {
  ok: 200,
  notFound: 404,
} as const;
```

## 16. `enum`、`const enum`、联合字面量怎么选？

### 回答要点

- 联合字面量 + 常量对象通常更轻量、可推断性更好。
- `enum` 有运行时对象。
- `const enum` 会被内联（需看构建链支持）。

## 17. 结构化类型系统（Structural Typing）是什么？

### 回答要点

- TS 是“看结构不看名义”，只要结构兼容就可赋值。

```ts
type A = { name: string };
type B = { name: string; age: number };
const a: A = { name: "Tom", age: 18 }; // 结构兼容
```

## 18. 什么是函数重载？何时用？

### 回答要点

- 对外暴露多个签名，内部一个实现签名。
- 当参数类型不同、返回类型联动时可用重载。

```ts
function format(x: number): string;
function format(x: Date): string;
function format(x: number | Date): string {
  return x instanceof Date ? x.toISOString() : String(x);
}
```

## 19. 如何给第三方库补类型？

### 回答要点

- 优先安装官方/社区类型包（如 `@types/*`）。
- 没有就写声明文件：`*.d.ts`。
- 可用模块声明和接口扩展（declaration merging）。

## 20. `tsconfig` 里常问的关键配置？

### 回答要点

- `strict`：严格模式总开关（面试常强调）。
- `noImplicitAny`：禁止隐式 any。
- `strictNullChecks`：`null/undefined` 参与类型系统。
- `module`、`target`：模块系统和编译目标。
- `baseUrl`、`paths`：路径别名。

## 21. 为什么推荐开启 `strictNullChecks`？

### 回答要点

- 能在编译期暴露大量空值问题，减少运行时 NPE。
- 与可选链、空值合并运算符配合更安全。

## 22. 可选链 `?.` 和空值合并 `??` 区别？

### 回答要点

- `?.`：安全访问深层属性。
- `??`：仅在 `null/undefined` 时使用默认值（不影响 `0`、`""`、`false`）。

```ts
const title = data?.article?.title ?? "default";
```

## 23. 什么是 `never` 的穷尽检查（exhaustive check）？

### 回答要点

- 用于联合类型的分支覆盖检查，避免漏分支。

```ts
type Shape =
  | { kind: "circle"; r: number }
  | { kind: "square"; s: number };

function area(shape: Shape) {
  switch (shape.kind) {
    case "circle":
      return Math.PI * shape.r * shape.r;
    case "square":
      return shape.s * shape.s;
    default: {
      const _exhaustive: never = shape;
      return _exhaustive;
    }
  }
}
```

## 24. 常见类型体操问题怎么回答？

### 回答要点

- 面试更看重“理解能力”而非背题。
- 优先讲清：输入类型、目标类型、拆解步骤（条件类型+映射类型+infer）。
- 不要上来写超复杂实现，先给简化版思路。

## 25. 面试中的 TS 实战问题（高频）

### 高频问法

- 如何设计一个类型安全的 API 响应结构？
- 如何约束前端路由配置对象的结构？
- 如何让表单字段和校验规则保持类型一致？
- 如何在 React 组件中正确写泛型 Props？

### 回答框架（可背）

1. 先定义核心领域类型（接口/联合类型）。
2. 再用工具类型做派生类型（`Pick/Omit/Partial`）。
3. 对输入输出边界做收窄（`unknown` + 类型守卫）。
4. 对分支逻辑做穷尽检查（`never`）。
5. 用 `strict` 配置兜底。

## 26. TypeScript 高频易错点（速记）

- 把 `any` 当“方便”长期使用，导致类型系统失效。
- 不开 `strictNullChecks`，空值 bug 增多。
- 误把 `interface` 和 `type` 对立化（实际上常互补）。
- 误用类型断言 `as` 掩盖真实类型问题。
- 把泛型当 `any` 替代品，而不是类型约束工具。

## 27. 30 秒自我总结模板（可背）

“TypeScript 我重点关注三件事：  
第一是类型建模能力，用联合类型、泛型、工具类型表达业务约束；  
第二是类型安全边界，用 `unknown + 类型守卫 + strictNullChecks` 降低运行时错误；  
第三是工程可维护性，通过统一的类型定义和派生类型减少重复代码，提升重构效率。”

---

如果你要，我可以继续补一版：`js/typescript-interview-coding.md`，专门放 TS 手写题（实现 `DeepPartial`、`MyPick`、`MyOmit`、`Awaited`、类型安全事件总线等）。  
