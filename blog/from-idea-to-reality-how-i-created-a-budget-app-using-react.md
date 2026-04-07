---
layout: default
title: "From Idea to Reality: How I Created a Budget App Using React"
date: 2021-09-14
tags: ["react", "javascript", "web-development", "frontend"]
---

## Getting Started

Facebook and a community of individual developers and corporations support React, an open-source JavaScript toolkit for developing user interfaces. Developers may utilize React's component-based architecture to construct reusable UI components that can be combined to create complex user interfaces. Its ability to efficiently update and render components depending on changes in state or props is one of its primary advantages. Even with huge and sophisticated systems, this enables fast and responsive user interfaces.

---

To create a budget tracking app, React is used in conjunction with the React Bootstrap toolkit. To manage state and handle user interactions, the application makes use of React capabilities such as functional components, hooks (such as the useState hook), and context. Furthermore, the program makes use of React's component-based architecture to create reusable UI components, such as the numerous card components used to display financial information.

## Setting up the Project

Now, we use the create-react-app command to create a new React app. The UUID library is then installed to produce unique IDs for each budget item that the user adds. The React Bootstrap library is then installed to take advantage of its pre-built UI components and styling. When opposed to building and styling the app from scratch, this method saves a significant amount of time. We can focus on building the app's main functionality rather than worrying about setup and stylistic minutiae by utilising these libraries.

## Planning the app architecture

After carefully considering the necessary components and how they will interact with each other, the selected architecture for the app involves four main components: App, Budget Card, Add Budget, Add Expense and BudgetsContext. The App component serves as the main entry point for the application and BudgetsContext contains the main state variables of the app, from where child components can access them. BudgetCard, Add Budget and Add Expense are rendered inside of App. The first one displays budgets and total of expenses in each one.

To manage budgets, as well as with expenses, the app will utilize an array of objects, where each one represents a single budget entry. We create one state variable for each one on BudgetProvider and we provide methods for accessing them.

The BudgetProvider will handle the data flow between the BudgetCard and Modal Forms. When a user adds a new budget or expense, the form component will call the corresponding method from BudgetProvider to update the budgets and expenses states. The updated data will then be passed to Budget Card for display. On each Budget Card, the total of expenses is shown in a Progress Bar from React Bootstrap.

For adding new budgets, a form on a Modal component from React Bootstrap is used. This takes the name and maximum spending assigned. Similarly, for adding expenses to a budget, a form on a Modal takes a description and an amount.

## Building the User Interface

The entry point of our budget app is the index.js file as usual. It looks like this:

```jsx
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BudgetsProvider } from "./contexts/BudgetsContext";
import App from "./App";
import "bootstrap/dist/css/bootstrap.min.css";

const rootElement = document.getElementById("root");
const root = createRoot(rootElement);

root.render(
  <StrictMode>
    <BudgetsProvider>
      <App />
    </BudgetsProvider>
  </StrictMode>
);
```

The first two lines of code import the StrictMode component from the React library and the createRoot function from the react-dom/client library. The StrictMode component is used to enable additional runtime checks for React applications, while createRoot function is used to create a new root for the React tree to render in. The next line imports the BudgetsProvider component from the BudgetsContext file, which is a custom context provider created for this app. This provider will allow the application to pass budget-related data down to all the components that need it. Then we import the main App component of the application, which will be rendered on the page. We also need to import the Bootstrap CSS stylesheet, which is used to style the application. The next line gets the root element from the HTML file where the app will be mounted. The createRoot function is then called with the root element as its argument.

The root element is rendered with the StrictMode component as its parent, which wraps the BudgetsProvider component and the App component. This ensures that the budget-related data will be passed down to all the child components and that any errors or warnings will be caught and displayed during development.

The main component named App contains all app UI. Here we initially show the app logo, an Add Budget button and an Add Expense Button. As we add budgets a list of Budgets Cards will start to appear below, each one will contain a total assigned budget and their correspondent expenses. After we add the first budget a Total Budget Card will appear at the bottom.

First, we import the necessary components from React, React Bootstrap and the custom ones:

```javascript
import { useState } from "react";
import { Button, Stack } from "react-bootstrap";
import Container from "react-bootstrap/Container";
import BudgetCard from "./components/BudgetCard";
import UncategorizedBudgetCard from "./components/UncategorizedBudgetCard";
import TotalBudgetCard from "./components/TotalBudgetCard";
import AddBudgetModal from "./components/AddBudgetModal";
import AddExpenseModal from "./components/AddExpenseModal";
import ViewExpensesModal from "./components/ViewExpensesModal";
import { useBudgets, UNCATEGORIZED_BUDGET_ID } from "./contexts/BudgetsContext";
```

Next, the main component App is defined. Here the useState hook is used to manage the visibility of several modal windows used for adding, viewing, and editing budgets and expenses. It will also use the useBudgets hook to retrieve budget data from the parent component BudgetsContext.

```javascript
export default function App() {
  const [showAddBudgetModal, setShowAddBudgetModal] = useState(false);
  const [showAddExpenseModal, setShowAddExpenseModal] = useState(false);
  const [viewExpensesModalBudgetId, setViewExpensesModalBudgetId] = useState();
  const [addExpenseModalBudgetId, setAddExpenseModalBudgetId] = useState();
  const { budgets, getBudgetExpenses } = useBudgets();

  function openAddExpenseModal(budgetId) {
    setShowAddExpenseModal(true);
    setAddExpenseModalBudgetId(budgetId);
  }

  // UI content is returned here
}
```

We define a function called openAddExpenseModal, which will be used as an event handler for the "Add Expense" button on each budget card. This function will set the showAddExpenseModal state to true and store the ID of the budget being edited in the addExpenseModalBudgetId state.

{% raw %}

```
return (
  <>
    <Container className="my-4">
      <Stack direction="horizontal" gap="2" className="mb-4">
        <h1 className="me-auto">Budgets</h1>
        <Button variant="primary" onClick={() => setShowAddBudgetModal(true)}>
          Add Budget
        </Button>
        <Button variant="outline-primary" onClick={openAddExpenseModal}>
          Add Expense
        </Button>
      </Stack>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fill, minmax(300px, 1fr))",
          gap: "1rem",
          alignItems: "flex-start",
        }}
      >
        {/* budgets cards list are rendered here */}
        {budgets.map((budget) => {
```

{% endraw %}
const amount = getBudgetExpenses(budget.id).reduce(
(total, expense) => total + expense.amount,
0
);
return (
<BudgetCard
key={budget.id}
name={budget.name}
amount={amount}
max={budget.max}
onAddExpenseClick={() => openAddExpenseModal(budget.id)}
onViewExpensesClick={() => setViewExpensesModalBudgetId(budget.id)}
/>
);
})}

        <UncategorizedBudgetCard
          onAddExpenseClick={openAddExpenseModal}
          onViewExpensesClick={() => setViewExpensesModalBudgetId(UNCATEGORIZED_BUDGET_ID)}
        />

        <TotalBudgetCard />
      </div>
    </Container>

    <AddBudgetModal show={showAddBudgetModal} handleClose={() => setShowAddBudgetModal(false)} />

    <AddExpenseModal
      show={showAddExpenseModal}
      defaultBudgetId={addExpenseModalBudgetId}
      handleClose={() => setShowAddExpenseModal(false)}
    />

    <ViewExpensesModal budgetId={viewExpensesModalBudgetId} handleClose={() => setViewExpensesModalBudgetId()} />

</>
);

```

## Managing State with Budget Context

Some challenges that may have been encountered during development could include managing the complexity of the app's state, ensuring efficient re-rendering of components, and debugging issues related to component interactions and data flow. The useBudgets hook is used throughout the application to access the Budgets Context and retrieve data stored within it. Inside this, Budget Provider hold the state of our main state variables: budgets and expenses. It includes functions for adding and deleting budgets, as well as adding and deleting expenses for each budget. This approach allowed me to keep the state management in one place and avoid passing data through multiple levels of components using the useContext hook.

This centralized state management solution like the BudgetProvider can greatly simplify the development of a React app with multiple components that need to interact with each other. While there are other options available, such as passing state and callback props down the component tree or using a third-party library like Redux, the BudgetProvider approach is often the most straightforward and suitable for small to medium-sized projects. While there are alternative state management solutions like Redux or MobX, those might be too complex and unnecessary for small projects. Similarly, using props to pass down state and actions from parent to child components can quickly become messy and difficult to maintain as the application grows in complexity.

One advantage of the BudgetProvider is that it provides a clear separation of concerns between the presentation logic and the state management logic. In our app, we can focus on building the UI components and leave the state management to the BudgetProvider and its associated hooks. This makes the code more modular and easier to reason about, especially as the app grows in complexity.

## Conclusion

Building a budget app with React can be a great way to learn the basics of the framework while also creating a useful tool for managing personal finances. By breaking down the app into smaller components and using hooks to manage state, we can create a modular and efficient app that is easy to maintain and update. The use of a centralized state management solution like the BudgetProvider can simplify the development process and make it easier to reason about the codebase. With some additional features and improvements, this budget app can be a valuable tool for anyone looking to manage their finances more effectively.
```
