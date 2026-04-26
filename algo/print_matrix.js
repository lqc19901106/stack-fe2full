/*
 矩阵打印
 1 2 3 4
 5 6 7 8
 9 10 11 12
 13 14 15 16
 输出 1 2 3 4 8 12 16 15 14 13 9 5 6 7 11 10
*/

function printMatrix(matrix) {
  let left = 0;
  let right = matrix[0].length - 1;
  let top = 0;
  let bottom = matrix.length - 1;
  const result = [];
  while (left <= right && top <= bottom) {
    for (let i = left; i <= right; i++) {
      result.push(matrix[top][i]);
    }
    for (let i = top + 1; i <= bottom; i++) {
      result.push(matrix[i][right]);
    }
    if (left < right && top < bottom) {
      for (let i = right - 1; i > left; i--) {
        result.push(matrix[bottom][i]);
      }
      for (let i = bottom; i > top; i--) {
        result.push(matrix[i][left]);
      }
    }
    left++;
    right--;
    top++;
    bottom--;
  }
  return result;
}
console.log(printMatrix([
  [1, 2, 3, 4],
  [5, 6, 7, 8],
  [9, 10, 11, 12],
  [13, 14, 15, 16],
]));