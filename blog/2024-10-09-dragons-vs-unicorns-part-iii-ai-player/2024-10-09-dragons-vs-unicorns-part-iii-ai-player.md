---
layout: default
title: "Dragons vs Unicorns (Part III) - AI Player"
date: 2024-10-09
tags: [html, css, javascript]
image: "dragons-vs-unicorns.webp"
excerpt: "In the previous post we made the markup and applied some styles to our Dragons vs Unicorns game app. Now it’s time to implement the game logic in JavaScript. This part is what makes the game playful. First, we reference the html elements for accessing them more easily."
---

I recently rediscovered one of my earliest projects, the "Dragons vs Unicorns" game series, and decided to apply my artificial intelligence expertise to enhance it. This post serves as a continuation of the series, with minimal alterations to the existing HTML structure and core JavaScript logic.

In this final installment, we will explore the integration of an AI opponent into our interactive game, which was originally developed using HTML, CSS, and JavaScript. The focus of this update is the implementation of a challenging computer player utilizing the minimax algorithm, thus adding a sophisticated twist to the traditional gameplay.

This post will provide a detailed walkthrough of the AI integration process, demonstrating how we can elevate a simple two-player game into a more complex and engaging single-player experience. We'll examine the step-by-step process of incorporating AI decision-making into our existing game framework.

You can play the live version here: https://pedropcamellon.github.io/tic-tac-toe/; or you can check the repo here: https://github.com/pedropcamellon/tic-tac-toe.

# Game Initialization and Flow

The game will initialize as before, with the board set up and ready for play. Here's how the enhanced gameplay will unfold:

1. **Game Start**: The game begins with an empty 3x3 grid, just as in our original version.
2. **Human's First Move**: The human player, represented by the Unicorn, always makes the first move. They can click on any empty cell to place their symbol.
3. **AI's Turn**: After the human player's move, control transitions to the AI (the Dragon). Here's where our new implementation comes into play:
   - The game will display a brief "thinking" state, simulating the AI's decision-making process.
   - Our AI, powered by the minimax algorithm, will evaluate the board state and determine the optimal move.
   - After a short delay (to enhance user experience), the AI will make its move by placing the Dragon symbol in its chosen cell.
4. **Alternating Turns**: The game will continue to alternate between the human player and the AI until a win or draw condition is met.
5. **Game End**: The game concludes when either player achieves a winning combination or when the board is full (resulting in a draw).

For the AI implementation, we'll focus on the essential elements from the previous sections:

1. Game Variables:
   - We retain the `AI_PLAYER` and `HUMAN_PLAYER` constants, which define the Dragon as the AI and the Unicorn as the human player.
   - The `cells` NodeList is crucial for accessing the game board state.
2. Utility Functions:
   - `placeBeastImg`: Used to place the AI's move on the board.
   - `checkWin`: Essential for evaluating game states in the AI algorithm.
   - `isDraw`: Needed to check for draw conditions in the AI logic.
3. Event Handler:
   - The `handleCellClick` function now includes a call to `handleAITurn()` after the human player's move, which will be the entry point for our AI logic.

These elements provide the foundation for implementing the AI player. The AI will utilize the existing game state representation and win-checking mechanisms while introducing new functions for decision-making using the minimax algorithm.

In the following sections, we'll dive into the specifics of implementing the AI logic, focusing on the minimax algorithm and how it integrates with our existing game structure. This enhancement will transform our two-player game into an engaging single-player experience, challenging human players with a formidable AI opponent. Let's proceed to examine the AI implementation in detail.

# Start the AI turn

The `handleAITurn` function serves as the core of our AI player's decision-making process in the Dragons vs Unicorns game. When it's the AI's turn, this function orchestrates a series of critical actions. First, it calls the `findBestMove` function, which utilizes the minimax algorithm to determine the optimal cell for the AI's next move. Once the best move is identified, the function places the AI's symbol (the Dragon) on the chosen cell using the `placeBeastImg` function. After making its move, the AI checks for a win condition or a draw using the `checkWin` and `isDraw` functions respectively. If either condition is met, the game ends accordingly. If the game continues, the function switches the current player back to the human player (the Unicorn) and updates the game status display. This function encapsulates the AI's turn logic, ensuring a smooth transition between human and AI moves while maintaining the game's rules and flow.

```jsx
function handleAITurn() {
  const bestMove = findBestMove();

  placeBeastImg(cells[bestMove], AI_PLAYER);

  if (checkWin(AI_PLAYER)) {
    endGame(false, AI_PLAYER);
    return;
  }

  if (isDraw()) {
    endGame(true, AI_PLAYER);
    return;
  }

  currentPlayer = HUMAN_PLAYER;

  updateCurrentStatus();
}
```

# Finding the best AI move

The `findBestMove` function is a crucial component in our AI's decision-making process for the Dragons vs Unicorns game. This function systematically evaluates all available moves on the game board to determine the optimal play for the AI. It begins by creating a copy of the current board state and initializes variables to track the best score and move. The function then iterates through each cell on the board. For every empty cell, it simulates placing the AI's symbol (Dragon) and calls the `minimax` function to evaluate the potential outcomes of that move. After each evaluation, the AI symbol is removed to reset the board state. The function keeps track of the highest-scoring move encountered. By the end of the iteration, `findBestMove` returns the index of the cell that represents the AI's best possible move, ensuring that the AI always chooses the most strategically advantageous position based on the current game state.

```jsx
function findBestMove() {
  let boardCopy = [...cells];

  let bestScore = -Infinity;

  let bestMove;

  for (let i = 0; i < boardCopy.length; i++) {
    if (
      !boardCopy[i].classList.contains(HUMAN_PLAYER) &&
      !boardCopy[i].classList.contains(AI_PLAYER)
    ) {
      boardCopy[i].classList.add(AI_PLAYER);

      let score = minimax(boardCopy, 0, false);

      boardCopy[i].classList.remove(AI_PLAYER);

      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }
  }
  return bestMove;
}
```

# Minimax Algorithm

The `minimax` function forms the core of our AI's decision-making process in the Dragons vs Unicorns game. This recursive algorithm was chosen for its ability to make optimal decisions in two-player, zero-sum games with perfect information. By simulating all possible future game states, minimax determines the best move for the AI player, alternating between maximizing its own score and minimizing the human player's score. This approach ensures that the AI makes decisions that maximize its chances of winning while minimizing the risk of losing, resulting in a challenging and strategic opponent.

In this implementation, the minimax function first checks if the current board state results in a win or a draw, assigning a score based on the outcome and the depth of recursion. For ongoing games, it recursively explores all possible moves. During the AI's turn (maximizing), it seeks the highest score among all possible moves, while during the simulated human turn (minimizing), it seeks the lowest score. This process continues until all possible game states are evaluated, allowing the AI to make the most strategic decision based on the current board state. By considering all potential future moves and their outcomes, our AI opponent provides a formidable challenge to human players in our Dragons vs Unicorns game.

```jsx
function minimax(board, depth, isMaximizing) {
  let result = checkWinner();

  if (result !== null) {
    return result === AI_PLAYER ? 10 - depth : depth - 10;
  }

  if (isDraw()) {
    return 0;
  }

  if (isMaximizing) {
    let bestScore = -Infinity;

    for (let i = 0; i < cells.length; i++) {
      if (
        !cells[i].classList.contains(HUMAN_PLAYER) &&
        !cells[i].classList.contains(AI_PLAYER)
      ) {
        cells[i].classList.add(AI_PLAYER);
        let score = minimax(board, depth + 1, false);
        cells[i].classList.remove(AI_PLAYER);
        bestScore = Math.max(score, bestScore);
      }
    }

    return bestScore;
  } else {
    let bestScore = Infinity;

    for (let i = 0; i < cells.length; i++) {
      if (
        !cells[i].classList.contains(HUMAN_PLAYER) &&
        !cells[i].classList.contains(AI_PLAYER)
      ) {
        cells[i].classList.add(HUMAN_PLAYER);
        let score = minimax(board, depth + 1, true);
        cells[i].classList.remove(HUMAN_PLAYER);
        bestScore = Math.min(score, bestScore);
      }
    }
    return bestScore;
  }
}
```

# Conclusion

The implementation of the minimax algorithm in our Dragons vs Unicorns game exemplifies how AI can significantly enhance gameplay, transforming a simple project into a more challenging and engaging experience. By revisiting one of my first projects and applying newly acquired knowledge in AI, I not only improved the game but also gained valuable insights into the practical applications of AI in gaming. This integration showcases how straightforward AI techniques can create formidable opponents that make optimal decisions based on the current game state. Ultimately, this project highlights the importance of understanding both game mechanics and AI principles, illustrating their synergy in crafting dynamic and intellectually stimulating interactive applications.
