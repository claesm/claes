const WIN_LINES = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8],
  [0, 3, 6], [1, 4, 7], [2, 5, 8],
  [0, 4, 8], [2, 4, 6],
];

const boardEl = document.getElementById('board');
const statusEl = document.getElementById('status');
const resetBtn = document.getElementById('reset');

let cells = Array(9).fill(null);
let currentPlayer = 'X';
let gameOver = false;

function checkWinner() {
  for (const [a, b, c] of WIN_LINES) {
    if (cells[a] && cells[a] === cells[b] && cells[a] === cells[c]) {
      return cells[a];
    }
  }
  if (cells.every(Boolean)) return 'draw';
  return null;
}

function render() {
  boardEl.innerHTML = '';
  cells.forEach((value, index) => {
    const cellEl = document.createElement('div');
    cellEl.className = 'cell';
    cellEl.textContent = value ?? '';
    cellEl.addEventListener('click', () => handleMove(index));
    boardEl.appendChild(cellEl);
  });
}

function handleMove(index) {
  if (gameOver || cells[index]) return;

  cells[index] = currentPlayer;
  const winner = checkWinner();

  if (winner === 'draw') {
    statusEl.textContent = "It's a draw!";
    gameOver = true;
  } else if (winner) {
    statusEl.textContent = `Player ${winner} wins!`;
    gameOver = true;
  } else {
    currentPlayer = currentPlayer === 'X' ? 'O' : 'X';
    statusEl.textContent = `Player ${currentPlayer}'s turn`;
  }

  render();
}

function resetGame() {
  cells = Array(9).fill(null);
  currentPlayer = 'X';
  gameOver = false;
  statusEl.textContent = "Player X's turn";
  render();
}

resetBtn.addEventListener('click', resetGame);
render();
