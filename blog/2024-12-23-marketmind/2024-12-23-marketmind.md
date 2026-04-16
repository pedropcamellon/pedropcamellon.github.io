---
layout: default
title: "MarketMind"
date: 2024-12-23
tags: ["python", "django", "llm-agents", "web-app"]
image: "market_m_home.webp"
excerpt: "MarketMind is a Django-based web application that integrates with a language model agent to provide users with the latest news and stock prices for companies. The application uses LangChain tools to fetch data from Google Search, process it, and store it in a FAISS vector database for efficient retrieval. This project demonstrates how to build a simple yet powerful LLM-based agent that can handle real-world queries about companies."
---


Repo URL: [MarketMind GitHub Repository](https://github.com/pedropcamellon/market-mind)

MarketMind is a small demo Django-based web application that integrates with a language model agent to handle search queries about companies. The application provides a summary of the latest news and stock price for a given company using LLM-based agent.

The user interface is intentionally minimalistic and straightforward, featuring a clean design that focuses on essential functionality. This design choice was deliberate for two main reasons:

- To provide a distraction-free experience where users can focus solely on getting the information they need without navigating through complex menus or unnecessary features.
- To allocate development resources primarily to building robust backend systems and implementing sophisticated LLM-based features, ensuring high-quality search results and accurate company information.

The simple UI approach allows users to quickly input their queries and receive clear, organized results without any learning curve or confusion.

![home_screenshot.png](home_screenshot.png)

## Features

- Search for the latest news and stock prices of companies.
- Integration with Google Search for fetching news.
- Utilizes language models for generating responses.

## Search

The search functionality leverages LangChain tools to provide comprehensive company insights through the following process:

- **Data Collection:** Utilizes the Google Search API via Python SDK to gather relevant links and information about companies
- **Content Processing:** Employs WebBaseLoader to convert HTML webpage content into processable document format
- **Vector Storage:** Stores processed content in a FAISS vector database for efficient retrieval, using Google's text-embedding-gecko-005 model to generate embeddings
- **Similarity Search:** Uses the same text-embedding-gecko-005 model through Vertex AI to perform similarity search and retrieve the most relevant documents

This architecture ensures fast and accurate retrieval of company information while maintaining cost-effectiveness through the use of Google's efficient embedding model.

## Tech Stack

- **Backend Framework**: Django
- **Language Model**: LangChain with Google Vertex AI
- **Database**: SQLite (for development)
- **Templating Engine**: Django Templates
- **Environment Management**: Python `dotenv`
- **Search Integration**: Google Search API

## Best Practices

### Code Organization

- **Modular Structure**: The project is organized into different directories for tools, services, and templates. This helps in maintaining a clean and modular codebase.
- **Separation of Concerns**: The agent-related logic is encapsulated in a dedicated service and its tools are defined in the `agent_tools` directory.

## LLM-based Agents and Tools

Language models by themselves can only generate text, but when implemented as agents through LangChain, they become powerful reasoning engines that can determine and execute actions through tool-calling. These agents can perform multi-step problem solving, maintain context across interactions, and choose appropriate tools based on user queries. For a deeper understanding of agents, tools, and vector stores, the LangChain documentation ([Introduction - LangChain](https://python.langchain.com/docs/introduction/)) provides comprehensive guidance and examples.
