(() => {
  const PLAYER = 'X'; // cute girl — human
  const COMPUTER = 'O'; // frog — computer
  const ICONS = { X: '👧', O: '🐸' };

  const WIN_LINES = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6],           // diagonals
  ];

  const boardEl = document.getElementById('board');
  const cells = Array.from(document.querySelectorAll('.cell'));
  const statusEl = document.getElementById('status');
  const resetBtn = document.getElementById('resetBtn');
  const difficultySelect = document.getElementById('difficulty');
  const scoreXEl = document.getElementById('scoreX');
  const scoreOEl = document.getElementById('scoreO');
  const scoreTieEl = document.getElementById('scoreTie');

  let board = Array(9).fill(null);
  let gameOver = false;
  let scores = { X: 0, O: 0, tie: 0 };

  function checkWinner(b) {
    for (const line of WIN_LINES) {
      const [a, c, d] = line;
      if (b[a] && b[a] === b[c] && b[a] === b[d]) {
        return { winner: b[a], line };
      }
    }
    if (b.every((v) => v !== null)) return { winner: 'tie', line: null };
    return null;
  }

  function render() {
    board.forEach((value, i) => {
      const cell = cells[i];
      cell.textContent = value ? ICONS[value] : '';
      cell.classList.toggle('filled', !!value);
      cell.disabled = !!value || gameOver;
      cell.classList.remove('win');
    });
  }

  function setStatus(text) {
    statusEl.textContent = text;
  }

  function updateScoreboard() {
    scoreXEl.textContent = scores.X;
    scoreOEl.textContent = scores.O;
    scoreTieEl.textContent = scores.tie;
  }

  function endGame(result) {
    gameOver = true;
    cells.forEach((cell) => (cell.disabled = true));

    if (result.winner === 'tie') {
      scores.tie += 1;
      setStatus("It's a tie!");
    } else {
      result.line.forEach((i) => cells[i].classList.add('win'));
      if (result.winner === PLAYER) {
        scores.X += 1;
        setStatus('You win! 🎉');
      } else {
        scores.O += 1;
        setStatus('The frog wins! 🐸');
      }
    }
    updateScoreboard();
  }

  function handleCellClick(e) {
    const index = Number(e.currentTarget.dataset.index);
    if (gameOver || board[index]) return;

    playMove(index, PLAYER);
    const result = checkWinner(board);
    if (result) {
      render();
      endGame(result);
      return;
    }

    render();
    setStatus("Frog is thinking…");
    window.setTimeout(computerMove, 380);
  }

  function playMove(index, mark) {
    board[index] = mark;
  }

  function computerMove() {
    if (gameOver) return;
    const index = chooseComputerMove(difficultySelect.value);
    if (index === -1) return;

    playMove(index, COMPUTER);
    const result = checkWinner(board);
    render();
    if (result) {
      endGame(result);
      return;
    }
    setStatus('Your turn');
  }

  function chooseComputerMove(difficulty) {
    const available = board.reduce((acc, v, i) => {
      if (!v) acc.push(i);
      return acc;
    }, []);
    if (available.length === 0) return -1;

    if (difficulty === 'easy') {
      return available[Math.floor(Math.random() * available.length)];
    }

    if (difficulty === 'medium') {
      // 50% chance of an optimal move, otherwise random.
      if (Math.random() < 0.5) {
        return available[Math.floor(Math.random() * available.length)];
      }
      return bestMove();
    }

    return bestMove();
  }

  function bestMove() {
    let best = { score: -Infinity, index: -1 };
    for (let i = 0; i < 9; i++) {
      if (board[i]) continue;
      board[i] = COMPUTER;
      const score = minimax(board, 0, false);
      board[i] = null;
      if (score > best.score) {
        best = { score, index: i };
      }
    }
    return best.index;
  }

  function minimax(state, depth, isMaximizing) {
    const result = checkWinner(state);
    if (result) {
      if (result.winner === COMPUTER) return 10 - depth;
      if (result.winner === PLAYER) return depth - 10;
      return 0;
    }

    if (isMaximizing) {
      let best = -Infinity;
      for (let i = 0; i < 9; i++) {
        if (state[i]) continue;
        state[i] = COMPUTER;
        best = Math.max(best, minimax(state, depth + 1, false));
        state[i] = null;
      }
      return best;
    }

    let best = Infinity;
    for (let i = 0; i < 9; i++) {
      if (state[i]) continue;
      state[i] = PLAYER;
      best = Math.min(best, minimax(state, depth + 1, true));
      state[i] = null;
    }
    return best;
  }

  function newGame() {
    board = Array(9).fill(null);
    gameOver = false;
    setStatus('Your turn');
    render();
  }

  cells.forEach((cell) => cell.addEventListener('click', handleCellClick));
  resetBtn.addEventListener('click', newGame);

  newGame();
  updateScoreboard();
})();
