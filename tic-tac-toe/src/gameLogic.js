// Core Tic-Tac-Toe rules: pure functions operating on a 9-cell array.
// Cells hold 'X', 'O', or null. Index layout:
//   0 1 2
//   3 4 5
//   6 7 8

const WIN_LINES = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
  [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
  [0, 4, 8], [2, 4, 6],           // diagonals
];

function createEmptyBoard() {
  return Array(9).fill(null);
}

function getWinner(board) {
  for (const [a, b, c] of WIN_LINES) {
    if (board[a] && board[a] === board[b] && board[a] === board[c]) {
      return { player: board[a], line: [a, b, c] };
    }
  }
  return null;
}

function getEmptyCells(board) {
  const cells = [];
  for (let i = 0; i < board.length; i++) {
    if (!board[i]) cells.push(i);
  }
  return cells;
}

function isBoardFull(board) {
  return board.every((cell) => cell !== null);
}

function isGameOver(board) {
  return Boolean(getWinner(board)) || isBoardFull(board);
}

function otherPlayer(player) {
  return player === 'X' ? 'O' : 'X';
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    WIN_LINES,
    createEmptyBoard,
    getWinner,
    getEmptyCells,
    isBoardFull,
    isGameOver,
    otherPlayer,
  };
}
