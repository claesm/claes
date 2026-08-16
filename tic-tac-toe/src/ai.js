// Minimax-based AI opponent for Tic-Tac-Toe, with alpha-beta pruning.
// Depth is factored into scoring so the AI prefers faster wins and slower losses.

if (typeof module !== 'undefined' && module.exports) {
  // Node/CommonJS environment (e.g. tests): pull in the board helpers.
  // In the browser these are already global, loaded via a preceding <script> tag.
  var { getWinner, getEmptyCells, isBoardFull, otherPlayer } = require('./gameLogic');
}

const DIFFICULTY_RANDOMNESS = {
  easy: 0.75,   // 75% of the time, plays a random legal move instead of the best one
  medium: 0.35,
  hard: 0,      // always plays optimally (unbeatable)
};

function scoreForOutcome(winner, aiPlayer, depth) {
  if (!winner) return 0;
  if (winner === aiPlayer) return 10 - depth;
  return depth - 10;
}

function minimax(board, depth, isMaximizing, aiPlayer, humanPlayer, alpha, beta) {
  const winnerInfo = getWinner(board);
  if (winnerInfo) return scoreForOutcome(winnerInfo.player, aiPlayer, depth);
  if (isBoardFull(board)) return 0;

  const currentPlayer = isMaximizing ? aiPlayer : humanPlayer;
  const emptyCells = getEmptyCells(board);

  if (isMaximizing) {
    let best = -Infinity;
    for (const index of emptyCells) {
      board[index] = currentPlayer;
      const score = minimax(board, depth + 1, false, aiPlayer, humanPlayer, alpha, beta);
      board[index] = null;
      best = Math.max(best, score);
      alpha = Math.max(alpha, score);
      if (beta <= alpha) break;
    }
    return best;
  }

  let best = Infinity;
  for (const index of emptyCells) {
    board[index] = currentPlayer;
    const score = minimax(board, depth + 1, true, aiPlayer, humanPlayer, alpha, beta);
    board[index] = null;
    best = Math.min(best, score);
    beta = Math.min(beta, score);
    if (beta <= alpha) break;
  }
  return best;
}

function getBestMove(board, aiPlayer) {
  const humanPlayer = otherPlayer(aiPlayer);
  let bestScore = -Infinity;
  let bestMove = null;

  for (const index of getEmptyCells(board)) {
    board[index] = aiPlayer;
    const score = minimax(board, 0, false, aiPlayer, humanPlayer, -Infinity, Infinity);
    board[index] = null;
    if (score > bestScore) {
      bestScore = score;
      bestMove = index;
    }
  }

  return bestMove;
}

function getRandomMove(board) {
  const emptyCells = getEmptyCells(board);
  return emptyCells[Math.floor(Math.random() * emptyCells.length)];
}

// Picks the AI's move for the given board and difficulty level.
function getAiMove(board, aiPlayer, difficulty = 'hard') {
  const randomness = DIFFICULTY_RANDOMNESS[difficulty] ?? 0;
  if (randomness > 0 && Math.random() < randomness) {
    return getRandomMove(board);
  }
  return getBestMove(board, aiPlayer);
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = { getAiMove, getBestMove };
}
