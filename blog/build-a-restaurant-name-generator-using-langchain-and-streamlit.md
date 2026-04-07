---
layout: default
title: "Build a Restaurant Name Generator using LangChain and
  Streamlit"
date: 2024-06-02
tags: ["python", "streamlit", "langchain", "google-gemini", "llm-apps"]
image: "restaurant-robot.webp"
excerpt: "Build an application for generating unique restaurant names using Large Language Models (LLMs) and the LangChain framework. It covers setting up the environment ..."
---

# Summary

- This tutorial demonstrates how to build a restaurant name generator app using LangChain and Streamlit
- Utilizes Google's Gemini model through API integration for generating contextually appropriate restaurant names
- Covers key concepts like prompt engineering, model parameters, and error handling
- Features a user-friendly interface with cuisine selection and restaurant name generation
- Includes complete implementation details from environment setup to cloud deployment to Streamlit Community Cloud

# Introduction

Large Language Models (LLMs) have revolutionized the field of natural language processing by enabling machines to generate human-like text. These models are trained on vast amounts of textual data and can be used for a variety of tasks, including text generation, sentiment analysis, question answering, and much more. As the field of artificial intelligence continues to evolve, AI engineers face the unique challenge of integrating these powerful language models into practical applications. This integration process, often referred to as "Software 2.0", represents a fundamental shift in how we approach software development. Unlike traditional programming with rigid rules and logic, Software 2.0 leverages AI's ability to discover subtle patterns and relationships in data that would be extremely difficult to capture through conventional programming approaches.

The role of AI engineers in this new paradigm is to bridge the gap between raw language models and user-friendly applications. This includes handling crucial aspects such as prompt engineering, context management, error handling, and ensuring the model's outputs are both reliable and useful for end users. They must also address important considerations like scalability, cost optimization, and ethical AI usage.

One of the most successful tools leading this software revolution has been LangChain. Initially released in October 2022, this powerful framework comes with extensive integrations to the most popular model providers and common interfaces for getting started quickly, including prompt templates, memory management, document loading capabilities, and output parsing tools. This comprehensive toolkit enables developers to rapidly prototype robust LLM-powered applications without having to build these common components from scratch.

Another great tool for speeding up initial iteration is Streamlit, which allows developers and data scientists to build data apps and prototypes in pure Python without any front-end experience. They could focus on their application logic rather than wrestling with complex web development frameworks. Using both LangChain and Streamlit together enables rapid development of functional demos, letting developers focus on core functionality rather than wrestling with complex web frameworks.

# Setting Up the Environment

To get started with the project clone the repository like this:

```bash
git clone https://github.com/pedropcamellon/restaurant-name-generator.git
cd restaurant-name-generator
```

This guide assumes you have Python installed on your machine. For the most up-to-date setup instructions, please refer to the project repository.

The setup process involves using the `uv` package manager to handle dependencies and setting up environment variables for the Google Generative AI API. Here's a quick overview:

1. Install the `uv` package manager:

   ```bash
   pip install uv
   ```

2. Sync project dependencies:

   ```bash
   uv sync
   ```

You'll need to set up your environment variables by obtaining a Google Generative AI API key from [Google AI Studio](https://aistudio.google.com/apikey). Create a `.env` file in your project directory with:

```
GOOGLE_API_KEY=YOUR_GOOGLE_API_KEY
```

Once everything is set up, you can run the application using:

```bash
streamlit run main.py
```

This will provide you with a local URL to access the application in your browser.

# Choosing the Language Model

In the initial release of this project, I used the Hugging Face model google/flan-t5-xxl. However, Google now offers direct access to their latest Gemini models through a free API, which provides significant improvements in performance and capabilities.

Here's how to initialize and use the model:

```python
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage

llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash")

# Generate restaurant names and menu items
response = llm.invoke("Suggest a name for a Mexican restaurant")
```

The Gemini model offers several advantages for our restaurant name generator:

- Enhanced understanding of culinary contexts
- Better multilingual capabilities for international restaurant names
- Faster response times for improved user experience

This model also provides advanced capabilities that weren't used in this project:

- **Tool calling:** Ability to interact with external tools and APIs through function calling
- **Structured output:** Capability to generate responses in specific formats like JSON or XML
- **Multimodal processing:** Support for handling multiple types of inputs like text, images and audio

For this restaurant name generator application, we focused solely on text generation capabilities to keep the implementation straightforward.

## Model Parameters

The model's text generation is controlled by several parameters: `max_new_tokens` sets the maximum length of generated text, `top_k` determines how many likely next tokens to consider, `temperature` controls the randomness of token selection, and `repetition_penalty` discourages repetitive text.

# Tweaking the Prompt

In the context of working with Large Language Models (LLMs), a prompt is a carefully crafted text input that guides the model to generate desired outputs. Think of it as giving instructions to the model about what kind of response you want. A prompt can range from a simple question to a complex set of instructions with examples and constraints.

The quality and structure of prompts significantly affect how well an LLM performs:

- **Clarity and Specificity:** Clear, specific prompts tend to produce more accurate and relevant responses. Vague prompts might lead to inconsistent or off-topic outputs.
- **Context and Examples:** Including relevant context or examples in the prompt helps the model understand the desired format and style of the response.
- **Constraints:** Explicitly stating limitations or requirements in the prompt helps control the model's output, such as specifying the length, format, or tone of the response.
- **Temperature Impact:** The effectiveness of a prompt can vary based on the model's temperature setting - a well-structured prompt becomes even more crucial when using higher temperatures that introduce more randomness.

In our restaurant name generator application, the prompt's design is crucial because it needs to guide the LLM to generate appropriate, creative, and contextually relevant restaurant names while maintaining consistency with the chosen cuisine type.

Before generating restaurant names, we need to define a prompt template. In LangChain, we use the `ChatPromptTemplate` class from `langchain_core.prompts` to create structured prompts that guide the model's responses. A prompt template allows us to create reusable prompts with dynamic variables.

Here's how to create a prompt template:

```python
from langchain_core.prompts import ChatPromptTemplate

system_template = "I want to open a restaurant. Suggest a good restaurant name based on the cuisine provided by the user. Response must include only the name of the restaurant."

prompt_template = ChatPromptTemplate.from_messages([
    ("system", system_template),
    ("user", "Cuisine: {cuisine}")
])

```

This template uses two distinct message roles:

- The "system" message sets the context and behavior rules for the AI. In this case, it explains the task and output format requirements.
- The "user" message contains the variable input (cuisine) that will change with each request. The {cuisine} placeholder will be replaced with the actual cuisine type when the template is used.

To use the template, you can invoke it with specific values:

```python
prompt = prompt_template.invoke({"cuisine": "Italian"})
```

# Getting the Restaurant Name

Now that we have our prompt template set up, we can use it with our LLM to generate restaurant names. Here's how to get the response from the model:

```python
response = llm.invoke(prompt)
print(f"Restaurant Name: {response.content}")

```

When you run this code with "Italian" as the cuisine input, you might get a response like:

```
Restaurant Name: Bella Notte Ristorante
```

The model generates a contextually appropriate name based on the cuisine type provided. The response is a simple string containing just the restaurant name, as specified in our system prompt. This makes it easy to process and use the generated name in subsequent steps of our application.

Note that due to the stochastic nature of language models, running the same prompt multiple times may generate different restaurant names. This is actually beneficial for our use case, as it provides variety and allows users to generate multiple options until they find one they like.

# Building the App with Streamlit

Next, we are going to build and deploy the app using Streamlit. For better code organization, I placed all generation-related logic in a separate module file called `generator.py`. This includes the model initialization, prompt templates, and functions for generating the restaurant names.

Let's create our `main.py` file which will serve as the entry point for our Streamlit application:

```python
import streamlit as st
from generator import generate_restaurant_name, generate_menu_items

def main():
    st.set_page_config(
        page_title="Restaurant Name Generator",
        page_icon="🍽️",
    )

    st.title("🏪 Restaurant Name Generator")

    # Add a sidebar with information
    with st.sidebar:
        st.header("About")
        st.write("Generate unique restaurant names based on cuisine type using AI.")

    # Main content
    cuisines = ["Italian", "Mexican", "Chinese", "Indian", "Japanese", "American", "French", "Thai"]
    cuisine = st.selectbox("Select a cuisine type:", cuisines)

    if st.button("Generate Restaurant Name", type="primary"):
        with st.spinner("Generating restaurant name..."):
            # Generate restaurant name
            restaurant_name = generate_restaurant_name(cuisine)

            if restaurant_name:
                st.header(restaurant_name)

                # Generate menu items
                with st.spinner("Generating menu items..."):
                    menu_items = generate_menu_items(restaurant_name, cuisine)

                    if menu_items:
                        st.subheader("Suggested Menu Items:")
                        for item in menu_items[:5]:  # Display top 5 items
                            st.write("•", item.strip())
            else:
                st.error("Failed to generate restaurant name. Please try again.")

if __name__ == "__main__":
    main()
```

This Streamlit app provides a user-friendly interface with:

- A custom page title and icon
- An informative sidebar
- A dropdown menu for cuisine selection
- A primary button to trigger the generation
- Loading spinners for better user experience
- Error handling for failed generations

The user interface consists of a select box for choosing the cuisine type and a "Generate Name" button. When the user clicks the button, it triggers a function that calls the LLM with the selected cuisine. The generated restaurant name is then displayed on the page.

To run the app, open your terminal and run:

```bash
streamlit run main.py
```

A new browser window will open, displaying your app.

# Deploying to Streamlit Community Cloud

Now that you've successfully built the app, let's deploy it to Streamlit Community Cloud where anyone can use it. Streamlit's cloud platform makes deploying and sharing your applications seamless.

First, you need to create a GitHub repository for your app. After creating a new repository named "restaurant-name-generator", prepare the app for deployment by creating a `requirements.txt` file that lists all necessary dependencies. This can be done by running the command `pip freeze > requirements.txt` in your project directory.

To deploy the app to the Streamlit Community Cloud, go to the Streamlit Community Cloud website and sign in. Click on "New app" and follow the instructions to connect your GitHub repository, specifying the branch and main file path. You can also customize your app's URL by choosing a custom subdomain. Finally, click "Deploy!" to deploy your app to the Streamlit Community Cloud.

<aside>
💡

Important

After deployment, make sure to add your Google API key as a secret in your Streamlit Community Cloud app settings. Navigate to your app settings, find the "Secrets" section, and add:

```toml
GOOGLE_API_KEY = "your-api-key-here"
```

This ensures your API key remains secure and isn't exposed in your source code. The app will use this environment variable to authenticate with the Google Generative AI API.

</aside>

Congratulations! Your app is now deployed and accessible through the provided URL. Share it with others and let your creativity flow!

Try out the live demo here: [Restaurant Name Generator](https://restaurant-name-generator-305.streamlit.app/)

# Conclusions

I hope this tutorial has given you valuable hands-on experience with LLMs, modern AI tools, and practical development workflows. By following along and building this restaurant name generator, you've learned essential skills in LLM integration, prompt engineering, and application architecture. I've shown you how to rapidly prototype using Streamlit and LangChain, while introducing you to industry-standard tools and deployment practices. Whether you're just starting your AI engineering career or looking to expand your skills, I hope this post has helped you take a step forward in your journey.
