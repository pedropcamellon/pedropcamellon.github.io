---
layout: default
title: "How to build a currency converter"
date: 2021-08-15
tags: ["javascript", "web-development", "fetch-api", "async-await"]
---

### What will we learn

1. What is asynchronous JavaScript, how it differs from synchronous JavaScript, and why we need it?
2. To understand how to use promises in JavaScript.

- To understand how to use async / await in JavaScript.

1. [Fetching JSON](https://dmitripavlutin.com/javascript-fetch-async-await/#2-fetching-json)
2. [Handling fetch errors](https://dmitripavlutin.com/javascript-fetch-async-await/#3-handling-fetch-errors)

- [Canceling a fetch request](https://dmitripavlutin.com/javascript-fetch-async-await/#4-canceling-a-fetch-request)
- [Parallel fetch requests](https://dmitripavlutin.com/javascript-fetch-async-await/#5-parallel-fetch-requests)
- [Summary](https://dmitripavlutin.com/javascript-fetch-async-await/#6-summary)`
- [Intro to Fetch API](https://www.notion.so/pedropcamellon/%5B%3Chttps://dmitripavlutin.com/javascript-fetch-async-await/#1-intro-to-fetch%3E%5D)

## What is asynchronous JavaScript?

In synchronous programming the browser effectively steps through the program one line at a time, in the order we wrote it. At each point, the browser waits for the line to finish its work before going on to the next line. It has to do this because each line depends on the work done in the preceding lines. In a long running synchronous function, you'll find that while our heavy function is running, our program is completely unresponsive: you can't type anything, click anything, or do anything else.`

---

Asynchronous functions start a long-running operation by calling a function that return immediately, so that our program can still be responsive to other events. It notifies us with the result of the operation when it eventually completes. Many functions provided by browsers, especially the most interesting ones, can potentially take a long time, and therefore, are asynchronous. Making an HTTP requests using _fetch_ is an example of this [ref](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Introducing).`

`Long-running synchronous functions make asynchronous programming a necessity.`

## From callbacks to async / await

### Event handlers

[`https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Introducing#event_handlers](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Introducing#event_handlers) "Permalink to Event handlers")`

Some early asynchronous APIs used events handlers as a form of asynchronous programming: you provide a function (the event handler) that will be called, not right away, but whenever the event happens. If "the event" is "the asynchronous operation has completed", then that event could be used to notify the caller about the result of an asynchronous function call.

### Callbacks

`([<https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Introducing#callbacks>](<https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Introducing#callbacks>) "Permalink to Callbacks")`

`An event handler is a particular type of callback. A callback is just a function that's passed into another function, with the expectation that the callback will be called at the appropriate time. As we just saw, callbacks used to be the main way asynchronous functions were implemented in JavaScript. However, when calling callbacks inside callbacks, this led to code hard to understand sometimes called as "callback hell" or the "pyramid of doom" (because the indentation looks like a pyramid on its side). For these reasons, most modern asynchronous APIs don't use callbacks, but *[promises](<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise>)*.`

### `Promises`

`Promises are the foundation of asynchronous programming in modern JavaScript. A promise is an object returned by an asynchronous function, which represents the current state of the operation. At the time the promise is returned to the caller, the operation often isn't finished, but the promise object provides methods to handle the eventual success or failure of the operation [How to use promises - Learn web development | MDN (mozilla.org)](<https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Promises>). First, a promise can be in one of three states:`

- \*`pending**: the promise has been created but the associated function has not succeeded or failed yet. This is the state your promise is in when it's returned from a call to fetch(), and the request is still being made.`
- \*`fulfilled**: the asynchronous function has succeeded, so its then() handler is called.`
- \*`rejected**: the asynchronous function has failed, so its catch() handler is called.`

`Note that what "succeeded" or "failed" means here is up to the API in question: for example,  fetch()  considers a request successful if the server returned an error like  [404 Not Found](<https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/404>), but not if a network error prevented the request being sent.`

`Sometimes, we use the term  **settled**  to cover both  **fulfilled**  and  **rejected**.`

`A promise is  **resolved**  if it is settled, or if it has been "locked in" to follow the state of another promise.`

### `Chained Promises`

[`https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise#chained_promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise#chained_promises) "Permalink to Chained Promises")`

`The methods  then(), catch() and finally() are used to associate further action with a promise that becomes settled. As the first two return promises, they can be chained. The .then() method takes up to two arguments; the first argument is a callback function for the fulfilled case of the promise, and the second argument is a callback function for the rejected case. Each  .then()  returns a newly generated promise object, which can optionally be used for chaining.`

`Handling a rejected promise in each  .then()  has consequences further down the promise chain. Sometimes there is no choice, because an error must be handled immediately. In such cases we must throw an error of some type to maintain error state down the chain. On the other hand, in the absence of an immediate need, it is simpler to leave out error handling until a final  .catch()  statement. A  .catch()  is really just a  .then()  without a slot for a callback function for the case when the promise is fulfilled.`

`We can use arrow function expressions for the callback functions.`

### `async / await`

[`https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Promises#async_and_await](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Promises#async_and_await) "Permalink to async and await")`

`The introduction of  async  functions made working with promises much more intuitive, they are used a lot where you might otherwise use promise chains. For making these, we add the async keyword to the start of them. These give us a simpler way to work with asynchronous promise-based code. Inside an async function, we can use the  await  keyword before a call to a function that returns a promise. This makes the code wait at that point until the promise is settled, at which point the fulfilled value of the promise is treated as a return value, or the rejected value is thrown. Keep in mind that just like a promise chain,  await  forces asynchronous operations to be completed in series. This is necessary if the result of the next operation depends on the result of the last one. This enables us to write code that uses asynchronous functions but looks like synchronous code.`

- `Note though that async functions always return a promise.`

`When making async requests, we can either use  then()  or  async/await. The former was introduced on ES2015 and the later on ES20117. They are very similar, but in an  async function, JavaScript will pause the function execution until the promise settles. With  then(), the rest of the function will continue to execute but JavaScript won't execute the  .then()  callback until the promise settles.  If you use promise chaining with  then(), you need to put any logic you want to execute after the request in the promise chain. Any code that you put after  fetch()  will execute immediately,  **before**  the  fetch()  is done.`

`We recommend using async/await where possible and minimize promise chaining. Async/await makes JavaScript code more accessible to developers that aren't as familiar with JavaScript, and much easier to read [ref](<https://medium.com/free-code-camp/how-to-master-async-await-with-this-real-world-example-19107e7558ad>).`

---

`Here, we are calling  await fetch(), and instead of getting a  Promise, our caller gets back a fully complete  Response  object, just as if  fetch()  were a synchronous function!`

`We can even use a  try...catch  block for error handling, exactly as we would if the code were synchronous.`

---

## `Making the layout`

```
<!DOCTYPE  html>
<html>
	<head>
	<title>Currency Converter</title>
	<meta  charset="UTF-8" />

	<script  src="src/index.js" defer></script>
	</head>

```

```
	<body>
		<h1>Currency Converter</h1>
		<p>
			<label  for="from">From:</label>
			<input type="text" id="from" name="from" minlength="3" maxlength="3" size="1" value="EUR" required/>

			<label  for="from-qty">Quantity:</label>
			<input type="number" id="from-qty" name="from-qty" minlength="1" maxlength="5" size="5" value="0" required/>
		</p>

		<p>
			<label  for="to">To:</label>
			<input type="text" id="to" name="to" minlength="3" maxlength="3" size="1" value="USD" required/>

			<label  for="to-qty">Quantity:</label>
			<input type="number" id="to-qty" name="to-qty" minlength="1" maxlength="5" size="5" value="0" required/>
		</p>
	</body>
</html>

```

## `JS`

```
const  fromCurrencyElem  =  document.querySelector("#from");
const  toCurrencyElem  =  document.querySelector("#to");
const  fromQtyElem  =  document.querySelector("#from-qty");
const  toQtyElem  =  document.querySelector("#to-qty");

```

`API`

```
const  API  =  `https://api.exchangerate.host/convert`;

```

`We get exchange rates data from [Exchange Rate] ([<https://api.exchangerate.host/convert>](<https://api.exchangerate.host/convert>)). We need to sign up for free for using the API Access Key.`

`Call convertCurrency function when user changes the quantity to convert.`

```
fromQtyElem.addEventListener("change",  convertCurrency);

```

### `Using Fetch API with chained promises`

```
const convertCurrency = (e) => {
	// Sell currency
	const fromCurrency = fromCurrencyElem.value;
	// Buy currency
	const toCurrency = toCurrencyElem.value;

```

```
	// How much we want to change
	const fromQty = e.target.value;
	let exchangeRate = -1;

```

```
	fetch(`${API}?from=${fromCurrency}&to=${toCurrency}`, { method: "GET" })
		.then((response) => {
			if (!response.ok) {
				throw new Error(`HTTP error! Status: ${response.status}`);
			}

			// Get Response object
			return response.json();
		})

```

`Use destructuring assignment for unpacking data from response object`

```
		.then(({ info }) => {
			// Get rate from response data
			exchangeRate = info["rate"];
			toQtyElem.value = fromQty * exchangeRate;
		});
};

In this article we show how to build a simple, but educational and useful app, that given an amount in one currency, calculates the equivalent in a currency of our interest. Making this app will improve our knowledge of asynchronous JavaScript. It will get the exchange rate from a free API.

Asynchronous programming is a technique that enables your program to start a potentially long-running task and still be able to be responsive to other events while that task runs, rather than having to wait until that task has finished [ref](<https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Introducing>). Once that task has finished, your program is presented with the result. Many functions provided by browsers, especially the most interesting ones, can potentially take a long time, and therefore, are asynchronous. For example:
	-   Making HTTP requests using  `fetch()`
	-   Accessing a user's camera or microphone using  `getUserMedia()`
	-   Asking a user to select files using  `showOpenFilePicker()`

So even though you may not have to implement your own asynchronous functions very often, you are very likely to need to use them correctly. We'll start by looking at the problem with long-running synchronous functions, which make asynchronous programming a necessity.

In this article, we'll explain what asynchronous programming is, why we need it, and briefly discuss some of the ways asynchronous functions have historically been implemented in JavaScript.

### Table of Contents

* [Intro to Fetch API](<https://dmitripavlutin.com/javascript-fetch-async-await/#1-intro-to-fetch>)
* [Fetching JSON](<https://dmitripavlutin.com/javascript-fetch-async-await/#2-fetching-json>)
* [Handling fetch errors](<https://dmitripavlutin.com/javascript-fetch-async-await/#3-handling-fetch-errors>)
* [Canceling a fetch request](<https://dmitripavlutin.com/javascript-fetch-async-await/#4-canceling-a-fetch-request>)
-   [Parallel fetch requests](<https://dmitripavlutin.com/javascript-fetch-async-await/#5-parallel-fetch-requests>)
-   [Summary](<https://dmitripavlutin.com/javascript-fetch-async-await/#6-summary>)

### Prerequisites:
Basic computer literacy, a reasonable understanding of JavaScript fundamentals, including functions and event handlers.

### Objective:

* To gain familiarity with what asynchronous JavaScript is, how it differs from synchronous JavaScript, and why we need it.
* To understand how to use promises in JavaScript.
* To understand how to use async / await in JavaScript.

In synchronous programming the browser effectively steps through the program one line at a time, in the order we wrote it. At each point, the browser waits for the line to finish its work before going on to the next line. It has to do this because each line depends on the work done in the preceding lines. In a long running synchronous function, you'll find that while our heavy function is running, our program is completely unresponsive: you can't type anything, click anything, or do anything else. Asynchronous functions start a long-running operation by calling a function; they have that function start the operation and return immediately, so that our program can still be responsive to other events, and lastly, they notify us with the result of the operation when it eventually completes [ref](<https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Introducing>).

The rest of this module explains how they are implemented in JavaScript.

Promises are the foundation of asynchronous programming in modern JavaScript. A promise is an object returned by an asynchronous function, which represents the current state of the operation. At the time the promise is returned to the caller, the operation often isn't finished, but the promise object provides methods to handle the eventual success or failure of the operation. With a promise-based API, the asynchronous function starts the operation and returns a `Promise` object. You can then attach handlers to this promise object, and these handlers will be executed when the operation has succeeded or failed [How to use promises - Learn web development | MDN (mozilla.org)](<https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Promises>).

In this application we’re going receive data from [Currency Layer] (<https://currencylayer.com> /). You’ll need to sign up for free so you can use the API Access Key. This API will provide us with data needed to calculate exchange rate between currencies.

When making async requests, we can either use  `then()`  or  async/await. The former was introduced on ES2015 and the later on ES20117. They are very similar, but in an  async function, JavaScript will pause the function execution until the promise settles. With  `then()`, the rest of the function will continue to execute but JavaScript won't execute the  `.then()`  callback until the promise settles.  If you use promise chaining with  `then()`, you need to put any logic you want to execute after the request in the promise chain. Any code that you put after  `fetch()`  will execute immediately,  **before**  the  `fetch()`  is done.

We recommend using async/await where possible and minimize promise chaining. Async/await makes JavaScript code more accessible to developers that aren't as familiar with JavaScript, and much easier to read [ref](<https://medium.com/free-code-camp/how-to-master-async-await-with-this-real-world-example-19107e7558ad>).

The app receives data from  [Currency Layer](<https://currencylayer.com/>). You’ll need to sign up for free so you can use API Access Key. This API will provide us with data needed to calculate exchange rate between currencies.

Our goal for this program is to have three functions. Not one, not two, but  **three asynchronous functions.** The first function is going to fetch data about currencies. The second function if going to fetch data about countries. And the third function is going to gather that information into one single place and output it nicely to the user.

## First function — Receiving Currency Data Asynchronously

We’ll create an asynchronous function that is going to take in two arguments, fromCurrency and toCurrency.

const getExchangeRate = **async** (_fromCurrency_, _toCurrency_) => {}

Now we need to fetch the data. With async/await, we can assign data directly to a variable; don’t forget to sign up and enter your own correct access key.

const getExchangeRate = **async** (_fromCurrency_, _toCurrency_) => {
  const response = await axios.get('<http://data.fixer.io/api/latest>?    access_key=**[yourAccessKey]**&format=1');
}

The data from the response is available under  `response.data.rates`  so we can put that into a variable just below response:

const rate = response.data.rates;

Since everything is being converted from the euro, below, we’ll create a variable called euro which will be equal to 1/currency we want to convert from:

const euro = 1 / rate[fromCurrency];

Finally, to get an exchange rate we can multiply euros by the currency we want to convert to:

const exchangeRate = euro * rate[toCurrency];

Finally, the function should look something like this:

# async-await
### [How to Use Fetch with async/await (dmitripavlutin.com)](<https://dmitripavlutin.com/javascript-fetch-async-await/>)

The  [Fetch API](<https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API>)  is the default tool to make network in web applications. While  `fetch()`  is generally easy to use, there some nuances to be aware of.

In this post, you'll find the common scenarios of how to use  `fetch()`  with  `async/await`  syntax. You'll understand how to fetch data, handle fetch errors, cancel a fetch request, and more.

## Intro to Fetch API

The Fetch API accesses resources across the network. You can make HTTP requests (using  `GET`,  `POST`  and other methods), download, and upload files.

To start a request, call the special function  `fetch()`:

const  response = await  fetch(resource[, options]);

which accepts 2 arguments:

-   `resource`: the URL string, or a  [Request](<https://developer.mozilla.org/en-US/docs/Web/API/Request>)  object
-   `options`: the configuration object with properties like  `method`,  `headers`,  `body`,  `credentials`,  [and more](<https://javascript.info/fetch-api>).

`fetch()`  starts a request and returns a promise. When the request completes, the promise is resolved with the  [Response](<https://developer.mozilla.org/en-US/docs/Web/API/Response>)  object. If the request fails due to some network problems, the promise is rejected.

`async/await`  syntax fits great with  `fetch()`  because it simplifies the work with promises.

For example, let's make a request to fetch some movies:

async  function  fetchMovies() {

  const  response = await  fetch('/movies');

  // waits until the request completes...

  console.log(response);

}

`fetchMovies()`  is an asynchronous function since it's marked with the  `async`  keyword.

`await fetch('/movies')`  starts an HTTP request to  `'/movies'`  URL. Because the  `await`  keyword is present, the asynchronous function is paused until the request completes.

When the request completes,  `response`  is assigned with the response object of the request. Let's see in the next section how to extract useful data, like JSON or plain text, from the response.

## Fetching JSON

The  `response`  object, returned by the  `await fetch()`, is a generic placeholder for multiple data formats.

For example, you can extract the JSON object from a fetch response:

async  function  fetchMoviesJSON() {

  const  response = await  fetch('/movies');

  const  movies = await  response.json();

  return  movies;

}

fetchMoviesJSON().then(movies  => {

  movies; // fetched movies

});

`response.json()`  is a method on the Response object that lets you extract a JSON object from the response. The method returns a promise, so you have to wait for the JSON:  `await response.json()`.

## Parallel fetch requests

To perform parallel fetch requests use the  [Promise.all()](<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all>)  helper function.

Let's start 2 parallel requests to fetch movies and categories:

async  function  fetchMoviesAndCategories() {

  const [moviesResponse, categoriesResponse] = await  Promise.all([

  fetch('/movies'),

  fetch('/categories')

 ]);

  const  movies = await  moviesResponse.json();

  const  categories = await  categoriesResponse.json();

  return [movies, categories];

}

fetchMoviesAndCategories().then(([movies, categories]) => {

  movies; // fetched movies

  categories; // fetched categories

}).catch(error  => {

  // /movies or /categories request failed

});

`await Promise.all([...])`  starts fetch requests in parallel, and waits until all of them are resolved.

If any request fails, then the whole parallel promise gets rejected right away with the failed request error.

In case if you want all parallel requests to complete, despite any of them fail, consider using  [Promise.allSettled()](<https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/allSettled>).

## Conclusions

Promises are the foundation of asynchronous programming in modern JavaScript. They make it easier to express and reason about sequences of asynchronous operations without deeply nested callbacks, and they support a style of error handling that is similar to the synchronous  `try...catch`  statement.

The  `async`  and  `await`  keywords make it easier to build an operation from a series of consecutive asynchronous function calls, avoiding the need to create explicit promise chains, and allowing you to write code that looks just like synchronous code.

Calling  `fetch()`  starts a request and returns a promise. When the request completes, the promise resolves to the response object. From the response object we extract data in JSON format. Because  `fetch()`  returns a promise, you can simplify the code by using the  `async/await`  syntax:  `response = await fetch()`.

You've found out how to use  `fetch()`  accompanied with  `async/await`  to fetch JSON data, handle fetching errors, cancel a request, perform parallel requests.

Having mastered the basics of  `fetch()`  with  `async/await`, follow my post on
* [How to Timeout a fetch() Request](<https://dmitripavlutin.com/timeout-fetch-request/>).

## See also
* [An Interesting Explanation of async/await in JavaScript (dmitripavlutin.com)](<https://dmitripavlutin.com/javascript-async-await/#comments>)
* [Currency Converter in JavaScript - GeeksforGeeks](<https://www.geeksforgeeks.org/currency-converter-in-javascript/>)
* [Using `then()` vs Async/Await in JavaScript - DEV Community 👩‍💻👨‍💻](<https://dev.to/masteringjs/using-then-vs-async-await-in-javascript-2pma>)

# MDN

[Introducing asynchronous JavaScript - Learn web development | MDN (mozilla.org)](<https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Introducing>)

In this example, we'll download the JSON file from  ... , and log some information about it.

To do this, we'll make an  HTTP request  to the server. In an HTTP request, we send a request message to a remote server, and it sends us back a response. In this case, we'll send a request to get a JSON file from the server. In this article, we'll use the  `fetch()` API, which is the modern, promise-based replacement for  `XMLHttpRequest`.

```

`const fetchPromise = fetch('[<https://mdn.github.io/learning-area/javascript/apis/fetching-data/can-store/products.json>](<https://mdn.github.io/learning-area/javascript/apis/fetching-data/can-store/products.json>)');`

`console.log(fetchPromise);`

`fetchPromise.then((response) => { console.log(Received response: ${response.status}); });`

`console.log("Started request…");`

```jsx

Copy to Clipboard

Here we are:

1.  calling the  `fetch()`  API, and assigning the return value to the  `fetchPromise`  variable
2.  immediately after, logging the  `fetchPromise`  variable. This should output something like:  `Promise { <state>: "pending" }`, telling us that we have a  `Promise`  object, and it has a  `state`  whose value is  `"pending"`. The  `"pending"`  state means that the fetch operation is still going on.
3.  passing a handler function into the Promise's  **`then()`**  method. When (and if) the fetch operation succeeds, the promise will call our handler, passing in a  [`Response`](<https://developer.mozilla.org/en-US/docs/Web/API/Response>)  object, which contains the server's response.
4.  logging a message that we have started the request.

The complete output should be something like:

Promise { <state>: "pending" }
Started request…
Received response: 200

Note that  `Started request…`  is logged before we receive the response. Unlike a synchronous function,  `fetch()`  returns while the request is still going on, enabling our program to stay responsive. The response shows the  `200`  (OK)  [status code](<https://developer.mozilla.org/en-US/docs/Web/HTTP/Status>), meaning that our request succeeded.

This probably seems a lot like the example in the last article, where we added event handlers to the  [`XMLHttpRequest`](<https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest>)  object. Instead of that, we're passing a handler into the  `then()`  method of the returned promise.

## [Chaining promises](<https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Asynchronous/Promises#chaining_promises> "Permalink to Chaining promises")

With the  `fetch()`  API, once you get a  `Response`  object, you need to call another function to get the response data. In this case, we want to get the response data as JSON, so we would call the  [`json()`](<https://developer.mozilla.org/en-US/docs/Web/API/Response/json> "json()")  method of the  `Response`  object. It turns out that  `json()`  is also asynchronous. So this is a case where we have to call two successive asynchronous functions.

Try this:

```

`const fetchPromise = fetch('[<https://mdn.github.io/learning-area/javascript/apis/fetching-data/can-store/products.json>](<https://mdn.github.io/learning-area/javascript/apis/fetching-data/can-store/products.json>)');`

`fetchPromise.then((response) => { const jsonPromise = response.json(); jsonPromise.then((data) => { console.log(data[0].name); }); });`

```

Copy to Clipboard

In this example, as before, we add a  `then()`  handler to the promise returned by  `fetch()`. But this time, our handler calls  `response.json()`, and then passes a new  `then()`  handler into the promise returned by  `response.json()`.

This should log "baked beans" (the name of the first product listed in "products.json").

But wait! Remember the last article, where we said that by calling a callback inside another callback, we got successively more nested levels of code? And we said that this "callback hell" made our code hard to understand? Isn't this just the same, only with  `then()`  calls?

It is, of course. But the elegant feature of promises is that  _`then()`  itself returns a promise, which will be completed with the result of the function passed to it_. This means that we can (and certainly should) rewrite the above code like this:

```

`const fetchPromise = fetch('[<https://mdn.github.io/learning-area/javascript/apis/fetching-data/can-store/products.json>](<https://mdn.github.io/learning-area/javascript/apis/fetching-data/can-store/products.json>)');`

`fetchPromise .then((response) => response.json()) .then((data) => { console.log(data[0].name); });`

```

Copy to Clipboard

Instead of calling the second  `then()`  inside the handler for the first  `then()`, we can  _return_  the promise returned by  `json()`, and call the second  `then()`  on that return value. This is called  **promise chaining**  and means we can avoid ever-increasing levels of indentation when we need to make consecutive asynchronous function calls.

Before we move on to the next step, there's one more piece to add. We need to check that the server accepted and was able to handle the request, before we try to read it. We'll do this by checking the status code in the response and throwing an error if it wasn't "OK":

```

`const fetchPromise = fetch('[<https://mdn.github.io/learning-area/javascript/apis/fetching-data/can-store/products.json>](<https://mdn.github.io/learning-area/javascript/apis/fetching-data/can-store/products.json>)');`

`fetchPromise .then((response) => { if (!response.ok) { throw new Error(HTTP error: ${response.status}); } return response.json(); }) .then((data) => { console.log(data[0].name); });`
