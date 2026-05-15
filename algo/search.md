# 查找相关算法

查找算法用于在数据结构中定位目标元素。常见查找算法及其 JS 实现和复杂度分析如下：

## 1. 顺序查找（Linear Search）
逐个遍历数组，查找目标值。

**实现：**
```javascript
function linearSearch(arr, target) {
  for (let i = 0; i < arr.length; i++) {
    if (arr[i] === target) return i;
  }
  return -1;
}
```
**时间复杂度：** 最坏/平均 O(n)

---

## 2. 二分查找（Binary Search）
在有序数组中，每次折半查找目标值。

**实现：**
```javascript
function binarySearch(arr, target) {
  let left = 0, right = arr.length - 1;
  while (left <= right) {
    const mid = Math.floor((left + right) / 2);
    if (arr[mid] === target) return mid;
    if (arr[mid] < target) left = mid + 1;
    else right = mid - 1;
  }
  return -1;
}
```
**时间复杂度：** 最坏/平均 O(log n)

---

## 3. 插值查找（Interpolation Search）
适用于均匀分布的有序数组，根据值估算查找位置。

**实现：**
```javascript
function interpolationSearch(arr, target) {
  let low = 0, high = arr.length - 1;
  while (low <= high && target >= arr[low] && target <= arr[high]) {
    if (low === high) {
      return arr[low] === target ? low : -1;
    }
    const pos = low + Math.floor(
      ((target - arr[low]) * (high - low)) / (arr[high] - arr[low])
    );
    if (arr[pos] === target) return pos;
    if (arr[pos] < target) low = pos + 1;
    else high = pos - 1;
  }
  return -1;
}
```
**时间复杂度：** 平均 O(log log n)，最坏 O(n)

---

## 4. 跳跃查找（Jump Search）
在有序数组中按固定步长跳跃查找，再线性查找区间。

**实现：**
```javascript
function jumpSearch(arr, target) {
  const n = arr.length;
  const step = Math.floor(Math.sqrt(n));
  let prev = 0;
  let curr = step;
  while (curr < n && arr[curr] < target) {
    prev = curr;
    curr += step;
  }
  for (let i = prev; i < Math.min(curr, n); i++) {
    if (arr[i] === target) return i;
  }
  return -1;
}
```
**时间复杂度：** O(√n)

---

## 5. 哈希查找（Hash Search）
通过哈希表实现常数时间查找。

**实现：**
```javascript
function hashSearch(arr, target) {
  const map = new Map();
  arr.forEach((val, idx) => map.set(val, idx));
  return map.has(target) ? map.get(target) : -1;
}
```
**时间复杂度：** 平均 O(1)，最坏 O(n)（哈希冲突）

---

你可以根据实际需求选择合适的查找算法。