# 排序相关算法

排序算法用于将一组数据按照指定顺序（通常是升序或降序）进行排列。常见的排序算法包括：

## 1. 冒泡排序（Bubble Sort）
通过重复遍历待排序序列，每次比较相邻元素并交换顺序，直到序列有序。

**实现：**
```javascript
function bubbleSort(arr) {
  for (let i = 0; i < arr.length - 1; i++) {
    for (let j = 0; j < arr.length - 1 - i; j++) {
      if (arr[j] > arr[j + 1]) {
        [arr[j], arr[j + 1]] = [arr[j + 1], arr[j]];
      }
    }
  }
  return arr;
}
```
**时间复杂度：** 最坏/平均 O(n²)，最好 O(n)（已排序时）

## 2. 选择排序（Selection Sort）
每次从未排序部分选择最小（或最大）元素，放到已排序部分的末尾。

**实现：**
```javascript
function selectionSort(arr) {
  for (let i = 0; i < arr.length - 1; i++) {
    let minIdx = i;
    for (let j = i + 1; j < arr.length; j++) {
      if (arr[j] < arr[minIdx]) minIdx = j;
    }
    [arr[i], arr[minIdx]] = [arr[minIdx], arr[i]];
  }
  return arr;
}
```
**时间复杂度：** O(n²)

## 3. 插入排序（Insertion Sort）
将每个元素插入到已排序部分的合适位置。

**实现：**
```javascript
function insertionSort(arr) {
  for (let i = 1; i < arr.length; i++) {
    let key = arr[i], j = i - 1;
    while (j >= 0 && arr[j] > key) {
      arr[j + 1] = arr[j];
      j--;
    }
    arr[j + 1] = key;
  }
  return arr;
}
```
**时间复杂度：** 最坏/平均 O(n²)，最好 O(n)

## 4. 快速排序（Quick Sort）
通过分治法，将序列分为两部分，分别排序后合并。

**实现：**
```javascript
function quickSort(arr) {
  if (arr.length <= 1) return arr;
  const pivot = arr[0];
  const left = arr.slice(1).filter(x => x < pivot);
  const right = arr.slice(1).filter(x => x >= pivot);
  return [...quickSort(left), pivot, ...quickSort(right)];
}
```
**时间复杂度：** 平均 O(n log n)，最坏 O(n²)

## 5. 归并排序（Merge Sort）
递归地将序列分为两部分，分别排序后合并。

**实现：**
```javascript
function mergeSort(arr) {
  if (arr.length <= 1) return arr;
  const mid = Math.floor(arr.length / 2);
  const left = mergeSort(arr.slice(0, mid));
  const right = mergeSort(arr.slice(mid));
  return merge(left, right);
}
function merge(left, right) {
  const result = [];
  while (left.length && right.length) {
    result.push(left[0] < right[0] ? left.shift() : right.shift());
  }
  return result.concat(left, right);
}
```
**时间复杂度：** O(n log n)

## 6. 堆排序（Heap Sort）
利用堆这种数据结构进行排序。

**实现：**
```javascript
function heapSort(arr) {
  function heapify(arr, n, i) {
    let largest = i, l = 2 * i + 1, r = 2 * i + 2;
    if (l < n && arr[l] > arr[largest]) largest = l;
    if (r < n && arr[r] > arr[largest]) largest = r;
    if (largest !== i) {
      [arr[i], arr[largest]] = [arr[largest], arr[i]];
      heapify(arr, n, largest);
    }
  }
  let n = arr.length;
  for (let i = Math.floor(n / 2) - 1; i >= 0; i--) heapify(arr, n, i);
  for (let i = n - 1; i > 0; i--) {
    [arr[0], arr[i]] = [arr[i], arr[0]];
    heapify(arr, i, 0);
  }
  return arr;
}
```
**时间复杂度：** O(n log n)

## 7. 希尔排序（Shell Sort）
基于插入排序的改进版，通过分组进行排序。

**实现：**
```javascript
function shellSort(arr) {
  let gap = Math.floor(arr.length / 2);
  while (gap > 0) {
    for (let i = gap; i < arr.length; i++) {
      let temp = arr[i], j = i;
      while (j >= gap && arr[j - gap] > temp) {
        arr[j] = arr[j - gap];
        j -= gap;
      }
      arr[j] = temp;
    }
    gap = Math.floor(gap / 2);
  }
  return arr;
}
```
**时间复杂度：** 平均 O(n^1.3) ~ O(n^2)，具体取决于 gap 序列

## 8. 计数排序（Counting Sort）
适用于整数排序，通过统计每个元素出现的次数进行排序。

**实现：**
```javascript
function countingSort(arr) {
  const max = Math.max(...arr), min = Math.min(...arr);
  const count = Array(max - min + 1).fill(0);
  arr.forEach(num => count[num - min]++);
  let idx = 0;
  for (let i = 0; i < count.length; i++) {
    while (count[i]-- > 0) arr[idx++] = i + min;
  }
  return arr;
}
```
**时间复杂度：** O(n + k)，k 为数值范围

## 9. 桶排序（Bucket Sort）
将数据分到不同的桶中，分别排序后合并。

**实现：**
```javascript
function bucketSort(arr, bucketSize = 5) {
  if (arr.length === 0) return arr;
  const min = Math.min(...arr), max = Math.max(...arr);
  const bucketCount = Math.floor((max - min) / bucketSize) + 1;
  const buckets = Array.from({ length: bucketCount }, () => []);
  arr.forEach(num => buckets[Math.floor((num - min) / bucketSize)].push(num));
  return buckets.reduce((acc, bucket) => acc.concat(insertionSort(bucket)), []);
}
```
**时间复杂度：** 平均 O(n)，最坏 O(n²)

## 10. 基数排序（Radix Sort）
按位进行排序，适用于整数或字符串。

**实现：**
```javascript
function radixSort(arr) {
  const max = Math.max(...arr);
  let exp = 1;
  while (Math.floor(max / exp) > 0) {
    const output = Array(arr.length).fill(0);
    const count = Array(10).fill(0);
    arr.forEach(num => count[Math.floor(num / exp) % 10]++);
    for (let i = 1; i < 10; i++) count[i] += count[i - 1];
    for (let i = arr.length - 1; i >= 0; i--) {
      const idx = Math.floor(arr[i] / exp) % 10;
      output[--count[idx]] = arr[i];
    }
    for (let i = 0; i < arr.length; i++) arr[i] = output[i];
    exp *= 10;
  }
  return arr;
}
```
**时间复杂度：** O(d·n)，d 为位数

---

