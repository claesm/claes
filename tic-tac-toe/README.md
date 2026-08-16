# Tic-Tac-Toe vs AI

A Tic-Tac-Toe game with an AI opponent, built with plain JavaScript/HTML/CSS
and packaged as an Electron app.

## Features

- Play as X or O, going first or second.
- Three AI difficulty levels: Easy, Medium, and Unbeatable (minimax with
  alpha-beta pruning — it will never lose).
- Win-line highlighting and draw detection.

## Running

```bash
npm install
npm start
```

## Project structure

- `main.js` — Electron main process; creates the app window.
- `preload.js` — preload script (keeps `contextIsolation` on).
- `src/index.html` / `src/style.css` — UI.
- `src/gameLogic.js` — pure board rules (win/draw detection).
- `src/ai.js` — minimax AI opponent with difficulty levels.
- `src/renderer.js` — DOM wiring / game loop for the renderer process.

`gameLogic.js` and `ai.js` also export via `module.exports` when run under
Node, so the AI/logic can be unit tested without Electron.
