---
layout: default
title: "Dragons vs Unicorns (Part II) - JavaScript"
date: 2018-06-03
tags: [html, css, javascript]
image: "dragons-vs-unicorns.webp"
excerpt: "In the previous post we made the markup and applied some styles to our Dragons vs Unicorns game app. Now it’s time to implement the game logic in JavaScript. This part is what makes the game playful. First, we reference the html elements for accessing them more easily."
---

In the previous post we made the markup and applied some styles to our Dragons vs Unicorns game app. Now it’s time to implement the game logic in JavaScript. This part is what makes the game playful. First, we reference the html elements for accessing them more easily.

You can play the live version here: https://pedropcamellon.github.io/tic-tac-toe/; or you can check the repo here: https://github.com/pedropcamellon/tic-tac-toe.

## What Will We Learn About JavaScript?

- Declare and use variables.
- Reference HTML elements.
- Create HTML elements.
- Declare and call functions.
- Use `forEach`, `some` and `every` array methods.
- Change clases of an HTML element.
- Let an HTML element respond to user clicks on it.
- Use `prepend` to insert an HTML element before another.
- Set HTML `img` element `src` and `alt` properties.
- Use conditional (ternary) operator.
- Check if an element has a given class using `contains` method.
- Use the spread syntax (`...`).

We begin by referencing the HTML elements we defined in the part I of this series.
Here we used the id tags we assigned in the index.html to save the values of all the board elements, winning message and the restart button. For this we used the JavaScript method getElementById().

For the winning message text element, we are going the querySelector() method which returns the first element within the document that matches the specified selector.

```javascript
const board = document.getElementById("board");
const cells = document.querySelectorAll("[data-cell]");
const currentStatus = document.getElementById("currentStatus");
const resetButton = document.getElementById("resetButton");
const gameEndOverlay = document.getElementById("gameEndOverlay");
const currentBeastStatusImg = document.getElementById("currentBeastImg");
const winningMessage = document.querySelector("[data-winning-message]");
const winningMessageText = document.querySelector("[data-winning-message] p");
const winningMessageImg = document.createElement("img");
```

This holds an `<img>` element for showing the winner image when the game ends.

```javascript
const gameOverMsgImg = document.createElement("img");
```

This holds an `<img>` element for showing current player's image:

let activePlayerImg = document.createElement("img");

These variables allow us personalize player's names more easily.

```javascript
const x = "unicorn";
const o = "dragon";
```

The first player is X, so `xTurn` variable initial value is `true`.

```
let  xTurn  =  true;

```

The game starts with `startGame`. First, we make sure no cell displays X player image nor O player image. Then we add the ability to respond to clicks with `addEventListener`. If visible, we hide the Game Over screen, show active player information and set the active player image as the cell background when hovering on them.

```
const  startGame  =  ()  =>  {
	// Reset each cell state
	cells.forEach((cell)  =>  {
	cell.classList.remove("x");
	cell.classList.remove("o");

	// Handle clicks on each cell
	cell.removeEventListener("click",  handleCellClick);
	cell.addEventListener("click", handleCellClick, {once:  true});
	});

	// Hide Game Over Msg
	if(gameEndOverlay.classList.contains("show"))
		gameEndOverlay.classList.remove("show");

	// Active Player info
	activePlayer.prepend(activePlayerImg);
	activePlayerImg.src = `src/${x}.png`;
	activePlayerImg.alt = x;

	// Set cell hover image given active player
	setBoardHoverClass();
};

```

When hovering on a cell we show the active player image over it by adding the active player corresponding class.

```
const setBoardHoverClass = () => {
	if (xTurn) {
		board.classList.remove("o");
		board.classList.add("x");
	} else {
		board.classList.remove("x");
		board.classList.add("o");
	}
};

```

Clicking on a cell triggers `handleCellClick`. We first save the clicked cell on a variable and check who is the active player. Then, if possible, `placePlayerImg` set the clicked cell background to the active player image. After the move, we check if the active player won or it is a draw, if neither, we keep playing. We change the active player (`swapTurns`), we update its corresponding displayed information (`updateActivePlayerInfo`), and we change the hovered cell background if it's playable (`setBoardHoverClass`).

```
// Handle clicks on each cell
const handleCellClick = (e) => {
	const cell = e.target;
	const activePlayer = xTurn ? "x" : "o";

	placePlayerImg(cell,  activePlayer);

	// Check if the active player won
	if (checkWin(activePlayer)) {
		// Game Over (not a draw)
		gameOver(false);
	} else if (isDraw()) {
		// Game Over (draw)
		gameOver(true);
	} else {
		// No winner. Keep playing
		swapTurns();
		updateActivePlayerInfo();
		setBoardHoverClass();
	}
};

```

For placing the active player image as the clicked cell background we add a class with the players name to its class list.

```
// Place current turn player img on clicked tile
const placePlayerImg = (cell, activePlayer) => {
	cell.classList.add(activePlayer);
};

```

In order to check if the active player won, we call `checkWin`. This uses the array called `winningCombinations` and test each case. If one matches, then the active player is the winner, if none, then we call `isDraw` for checking if no more moves are possible.

```
/*
Indexes within the board
[0] [1] [2]
[3] [4] [5]
[6] [7] [8]
*/

const  winningCombinations  =  [
	[0,  1,  2],
	[3,  4,  5],
	[6,  7,  8],
	[0,  3,  6],
	[1,  4,  7],
	[2,  5,  8],
	[0,  4,  8],
	[2,  4,  6]
];

const checkWin = (currentPlayer) => {
	return winningCombinations.some((combination) => {
		return combination.every((i) => {
			return cells[i].classList.contains(currentPlayer);
		});
	});
};

const isDraw  =  ()  =>  {
	return  [...cells].every((cell)  =>  {
		return  cell.classList.contains("x") || cell.classList.contains("o");
	});
};

```

We use `some` and `every`, two nice array method that determines, the former, whether at least one element in the array passes the test defined by the provided function, and the later, if all of them do. The `contains` method of the `classList` property is used for checking if a class is present. They give back a boolean value.

In both cases, there is a winner or a draw, we call `gameOver`. In the first case we show a message with the text "draw!", in the second, we display the winner image and its name followed by "wins!!!".

```
const gameOver = (draw) => {
	if (draw) {
		gameOverMsgTxt.innerText = `draw!`;
	} else {
		gameOverMsgImg.src = activePlayerImg.src;
		gameOverMsgImg.alt = activePlayerImg.alt;
		gameOverMsgTxt.innerText = `wins!!!`;
		gameOverMsg.insertBefore(gameOverMsgImg,  gameOverMsgTxt);
	}

	gameEndOverlay.classList.add("show");
};

```

The second function is the one which swaps the turns after the character is placed in a cell.

```
const swapTurns = () =>  {
	xTurn = !xTurn;
};

const updateActivePlayerInfo = ()  =>  {
	if  (xTurn)  {
		activePlayerImg.src = `src/${x}.png`;
		activePlayerImg.alt = x;
	}  else  {
		activePlayerImg.src = `src/${o}.png`;
		activePlayerImg.alt =  o;
	}
};

```

Lastly, we link the reset button with the `startGame` function for restarting the game.

```javascript
resetButton.addEventListener("click", startGame);
```

## Wrapping up

We now have a working Tic-Tac-Toe game! We used HTML, CSS, and JavaScript to implement it in this series. We begin with the markup, then add some colors and layout elements, and lastly create the game logic. There are a lot more things we could do here, such as making the game multiplayer so we can play with a friend, creating an AI to play against, or rewriting the app in a framework of our choice to see how it compares to vanilla JavaScript. There are several opportunities to explore and grow here. Please let me know which one you like, and I'll gladly make another one of these guides! I hope this was a straightforward project to follow and a nice introduction to both game and web programming.

_Thanks to:_

1. [Simple Tic-Tac-Toe JavaScript game for beginners (codebrainer.com)](https://www.codebrainer.com/blog/tic-tac-toe-javascript-game)
2. https://dev.to/bornasepic/pure-and-simple-tic-tac-toe-with-javascript-4pgn
3. [Create a simple Tic-Tac-Toe game using HTML, CSS, JavaScript - DEV Community 👩‍💻👨‍💻](https://dev.to/javascriptacademy/create-a-simple-tic-tac-toe-game-using-html-css-javascript-i4k?signin=true)
