(function () {
  const boardEl = document.getElementById('board');
  const statusEl = document.getElementById('status');
  const difficultySelect = document.getElementById('difficulty');
  const playerSymbolSelect = document.getElementById('playerSymbol');
  const newGameBtn = document.getElementById('newGame');

  const AI_MOVE_DELAY_MS = 350;

  let board = createEmptyBoard();
  let humanPlayer = 'X';
  let aiPlayer = 'O';
  let currentPlayer = 'X';
  let gameActive = true;
  let cellButtons = [];

  function buildBoard() {
    boardEl.innerHTML = '';
    cellButtons = board.map((_, index) => {
      const btn = document.createElement('button');
      btn.className = 'cell';
      btn.type = 'button';
      btn.setAttribute('aria-label', `Cell ${index + 1}`);
      btn.addEventListener('click', () => onCellClick(index));
      boardEl.appendChild(btn);
      return btn;
    });
  }

  function render() {
    board.forEach((value, index) => {
      const btn = cellButtons[index];
      btn.textContent = value ?? '';
      btn.classList.toggle('x', value === 'X');
      btn.classList.toggle('o', value === 'O');
      btn.disabled = Boolean(value) || !gameActive || currentPlayer !== humanPlayer;
    });
  }

  function setStatus(message) {
    statusEl.textContent = message;
  }

  function highlightWin(line) {
    for (const index of line) {
      cellButtons[index].classList.add('win');
    }
  }

  function endTurnCheck() {
    const winnerInfo = getWinner(board);
    if (winnerInfo) {
      gameActive = false;
      highlightWin(winnerInfo.line);
      setStatus(winnerInfo.player === humanPlayer ? 'You win!' : 'AI wins!');
      render();
      return true;
    }
    if (isBoardFull(board)) {
      gameActive = false;
      setStatus("It's a draw!");
      render();
      return true;
    }
    return false;
  }

  function onCellClick(index) {
    if (!gameActive || board[index] || currentPlayer !== humanPlayer) return;

    board[index] = humanPlayer;
    render();
    if (endTurnCheck()) return;

    currentPlayer = aiPlayer;
    setStatus('AI is thinking...');
    render();
    window.setTimeout(aiTurn, AI_MOVE_DELAY_MS);
  }

  function aiTurn() {
    if (!gameActive) return;

    const difficulty = difficultySelect.value;
    const move = getAiMove(board, aiPlayer, difficulty);
    if (move === null || move === undefined) return;

    board[move] = aiPlayer;
    render();
    if (endTurnCheck()) return;

    currentPlayer = humanPlayer;
    setStatus('Your turn');
    render();
  }

  function newGame() {
    board = createEmptyBoard();
    humanPlayer = playerSymbolSelect.value;
    aiPlayer = otherPlayer(humanPlayer);
    currentPlayer = 'X';
    gameActive = true;

    buildBoard();
    render();

    if (currentPlayer === aiPlayer) {
      setStatus('AI is thinking...');
      window.setTimeout(aiTurn, AI_MOVE_DELAY_MS);
    } else {
      setStatus('Your turn');
    }
  }

  newGameBtn.addEventListener('click', newGame);
  playerSymbolSelect.addEventListener('change', newGame);

  newGame();
})();
