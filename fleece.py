"""
This is a Python script that serves as a frontend for a conversational AI model built with the `langchain` and `llms` libraries.
The code creates a web application using Streamlit, a Python library for building interactive web apps.
# Author: Yuan Chen
# Date: March 16, 2025
"""
import os

# Import necessary libraries
import streamlit as st
from langchain.chains import ConversationChain
from langchain.chains.conversation.memory import ConversationEntityMemory
from langchain.chains.conversation.prompt import ENTITY_MEMORY_CONVERSATION_TEMPLATE
from langchain_openai import ChatOpenAI  # Using ChatOpenAI for chat models
# from dotenv import load_dotenv


# Load environment variables
# load_dotenv()

# Set Streamlit page configuration
st.set_page_config(page_title="Fleece", layout="wide")

# Load custom CSS
def load_css():
    with open("style.css") as f:
        st.markdown(f'<style>{f.read()}</style>', unsafe_allow_html=True)

try:
    load_css()
except Exception as e:
    st.warning(f"Could not load custom styling: {e}")

# Initialize session states
if "generated" not in st.session_state:
    st.session_state["generated"] = []
if "past" not in st.session_state:
    st.session_state["past"] = []
if "input" not in st.session_state:
    st.session_state["input"] = ""
if "stored_session" not in st.session_state:
    st.session_state["stored_session"] = []


# Define function to get user input
def get_text():
    """
    Get the user input text.

    Returns:
        (str): The text entered by the user
    """
    input_text = st.text_input(
        "You: ",
        st.session_state["input"],
        key="input",
        placeholder="Your AI assistant here! Ask me anything ...",
        label_visibility="hidden",
    )
    return input_text


# Define function to start a new chat
def new_chat():
    """
    Clears session state and starts a new chat.
    """
    save = []
    for i in range(len(st.session_state["generated"]) - 1, -1, -1):
        save.append("User:" + st.session_state["past"][i])
        save.append("Bot:" + st.session_state["generated"][i])
    st.session_state["stored_session"].append(save)
    st.session_state["generated"] = []
    st.session_state["past"] = []
    st.session_state["input"] = ""
    st.session_state.entity_memory.entity_store = {}
    st.session_state.entity_memory.buffer.clear()


# Set up sidebar with various options
with st.sidebar.expander("🛠️ ", expanded=False):
    # Option to preview memory store
    if st.checkbox("Preview memory store"):
        st.write("### Memory Store")
        if "entity_memory" in st.session_state and hasattr(st.session_state.entity_memory, "store"):
            st.write(st.session_state.entity_memory.store)
        else:
            st.write("Memory store not initialized yet.")
    # Option to preview memory buffer
    if st.checkbox("Preview memory buffer"):
        st.write("### Buffer Store")
        if "entity_memory" in st.session_state and hasattr(st.session_state.entity_memory, "buffer"):
            st.write(st.session_state.entity_memory.buffer)
        else:
            st.write("Memory buffer not initialized yet.")
    MODEL = st.selectbox(
        label="Model",
        options=[
            "gpt-3.5-turbo",
            "gpt-4",
            "gpt-4-turbo",
            "gpt-4o"
        ],
        index=0
    )
    K = st.number_input(
        " (#)Summary of prompts to consider", min_value=3, max_value=1000
    )

# Set up the Streamlit app layout
st.title("Fleece")
st.subheader("Find the best card for deal saviors")

# Add navigation information
st.info("💡 Navigate to the Credit Cards page to explore available cards or My Credit Cards to manage your existing cards!")

# Ask the user to enter their OpenAI API key
API_O = st.sidebar.text_input("API-KEY", type="password")

# API_O = os.getenv('OPENAI_API_KEY')
# Session state storage would be ideal
if API_O:
    # Create a ChatOpenAI instance for chat models
    llm = ChatOpenAI(temperature=0, api_key=API_O, model_name=MODEL, verbose=False)

    # Create a ConversationEntityMemory object if not already created
    if "entity_memory" not in st.session_state:
        st.session_state.entity_memory = ConversationEntityMemory(llm=llm, k=K)

    # Create the ConversationChain object with the specified configuration
    Conversation = ConversationChain(
        llm=llm,
        prompt=ENTITY_MEMORY_CONVERSATION_TEMPLATE,
        memory=st.session_state.entity_memory,
    )
else:
    st.sidebar.warning(
        "API key required to try this app.The API key is not stored in any form."
    )
    # st.stop()

# Add navigation and action buttons
st.sidebar.markdown("## Navigation")
st.sidebar.info("Use the dropdown menu above ↑ to navigate between pages")

# Add a button to start a new chat
st.sidebar.markdown("## Actions")
st.sidebar.button("New Chat", on_click=new_chat, type="primary")

# Add links to the credit cards pages
col1, col2 = st.sidebar.columns(2)
with col1:
    if st.button("Credit Cards", type="secondary"):
        # This is a workaround since direct navigation isn't supported in this way
        # The user will need to use the sidebar navigation
        st.info("Please use the sidebar navigation menu to view the Credit Cards page")

with col2:
    if st.button("My Cards", type="secondary"):
        # This is a workaround since direct navigation isn't supported in this way
        # The user will need to use the sidebar navigation
        st.info("Please use the sidebar navigation menu to view the My Credit Cards page")

# Get the user input
user_input = get_text()

# Generate the output using the ConversationChain object and the user input, and add the input/output to the session
if user_input:
    output = Conversation.run(input=user_input)
    st.session_state.past.append(user_input)
    st.session_state.generated.append(output)

# Allow to download as well
download_str = []
# Display the conversation history using an expander, and allow the user to download it
with st.expander("Conversation", expanded=True):
    for i in range(len(st.session_state["generated"]) - 1, -1, -1):
        st.info(st.session_state["past"][i], icon="🧐")
        st.success(st.session_state["generated"][i], icon="🤖")
        download_str.append(st.session_state["past"][i])
        download_str.append(st.session_state["generated"][i])

    # Can throw error - requires fix
    download_str = "\n".join(download_str)
    if download_str:
        st.download_button("Download", download_str)

# Display stored conversation sessions in the sidebar
for i, sublist in enumerate(st.session_state.stored_session):
    with st.sidebar.expander(label=f"Conversation-Session:{i}"):
        st.write(sublist)

# Allow the user to clear all stored conversation sessions
if st.session_state.stored_session:
    if st.sidebar.checkbox("Clear-all"):
        del st.session_state.stored_session
