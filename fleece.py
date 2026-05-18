"""
Fleece — AI-powered credit card advisor chatbot.
# Author: Yuan Chen
# Date: March 16, 2025
"""
import os

import streamlit as st
from langchain.agents import AgentExecutor, create_openai_tools_agent
from langchain.chains.conversation.memory import ConversationEntityMemory
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_openai import ChatOpenAI

from prompts.agent_system_prompt import SYSTEM_PROMPT

# ---------------------------------------------------------------------------
# Page config + CSS
# ---------------------------------------------------------------------------

st.set_page_config(
    page_title="Fleece — Find the best card for deal saviors",
    page_icon="🟡",
    layout="wide",
)


def load_css():
    # Google Fonts
    st.markdown(
        '<link rel="preconnect" href="https://fonts.googleapis.com">'
        '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
        '<link href="https://fonts.googleapis.com/css2?family=Oswald:wght@400;600;700'
        '&family=Source+Sans+3:wght@400;600&display=swap" rel="stylesheet">',
        unsafe_allow_html=True,
    )
    with open("style.css") as f:
        st.markdown(f'<style>{f.read()}</style>', unsafe_allow_html=True)


try:
    load_css()
except Exception as e:
    st.warning(f"Could not load custom styling: {e}")

# ---------------------------------------------------------------------------
# Session state initialisation
# ---------------------------------------------------------------------------

if "generated" not in st.session_state:
    st.session_state["generated"] = []
if "past" not in st.session_state:
    st.session_state["past"] = []
if "input" not in st.session_state:
    st.session_state["input"] = ""
if "stored_session" not in st.session_state:
    st.session_state["stored_session"] = []


# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

def get_text():
    """Return the current user input from the text box."""
    return st.text_input(
        "You: ",
        st.session_state["input"],
        key="input",
        placeholder="Your AI assistant here! Ask me anything ...",
        label_visibility="hidden",
    )


def new_chat():
    """Archive the current conversation and start fresh."""
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


# ---------------------------------------------------------------------------
# Sidebar — settings
# ---------------------------------------------------------------------------

with st.sidebar.expander("🛠️ ", expanded=False):
    if st.checkbox("Preview memory store"):
        st.write("### Memory Store")
        if "entity_memory" in st.session_state and hasattr(st.session_state.entity_memory, "store"):
            st.write(st.session_state.entity_memory.store)
        else:
            st.write("Memory store not initialized yet.")
    if st.checkbox("Preview memory buffer"):
        st.write("### Buffer Store")
        if "entity_memory" in st.session_state and hasattr(st.session_state.entity_memory, "buffer"):
            st.write(st.session_state.entity_memory.buffer)
        else:
            st.write("Memory buffer not initialized yet.")
    MODEL = st.selectbox(
        label="Model",
        options=["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo", "gpt-4o"],
        index=0,
    )
    K = st.number_input(" (#)Summary of prompts to consider", min_value=3, max_value=1000)
    show_tool_calls = st.checkbox("Show tool calls", value=False)

# ---------------------------------------------------------------------------
# Main layout
# ---------------------------------------------------------------------------

st.markdown(
    '<h1 style="color:#111111;font-family:Oswald,sans-serif;font-weight:700;'
    'text-transform:uppercase;letter-spacing:1px;border-bottom:3px solid #FFD100;'
    'padding-bottom:0.4rem;margin-bottom:0.25rem;">Fleece</h1>'
    '<p style="color:#555555;font-family:\'Source Sans 3\',sans-serif;font-size:1rem;'
    'margin-top:0;margin-bottom:1.25rem;">Find the best card for deal saviors</p>',
    unsafe_allow_html=True,
)
st.info("💡 Navigate to the Credit Cards page to explore available cards or My Credit Cards to manage your existing cards!")

API_O = st.sidebar.text_input("API-KEY", type="password")

# ---------------------------------------------------------------------------
# Agent setup (runs on every Streamlit rerender — cheap, stateless object)
# ---------------------------------------------------------------------------

if API_O:
    llm = ChatOpenAI(temperature=0, api_key=API_O, model_name=MODEL, verbose=False)

    # Critical: chat_history_key and return_messages must match the prompt placeholders
    if "entity_memory" not in st.session_state:
        st.session_state.entity_memory = ConversationEntityMemory(
            llm=llm,
            k=K,
            chat_history_key="chat_history",  # must match MessagesPlaceholder name
            return_messages=True,              # must be True for MessagesPlaceholder
        )

    brave_key = os.getenv("BRAVE_API_KEY", "")

    try:
        from tools import build_tools
        tools = build_tools(brave_key) if brave_key else []
    except Exception:
        tools = []

    prompt = ChatPromptTemplate.from_messages([
        ("system", SYSTEM_PROMPT),
        MessagesPlaceholder(variable_name="chat_history", optional=True),
        ("human", "{input}"),
        MessagesPlaceholder(variable_name="agent_scratchpad"),
    ])

    agent = create_openai_tools_agent(llm=llm, tools=tools, prompt=prompt)
    agent_executor = AgentExecutor(
        agent=agent,
        tools=tools,
        memory=st.session_state.entity_memory,
        handle_parsing_errors=True,
        max_iterations=5,
        max_execution_time=150.0,
        verbose=False,
        return_intermediate_steps=show_tool_calls,
    )

    # Sidebar research status
    st.sidebar.markdown("## Research Tools")
    if brave_key:
        st.sidebar.success(f"Live research enabled ({len(tools)} tools)")
    else:
        st.sidebar.info("Research tools disabled. Set BRAVE_API_KEY to enable live card data.")

else:
    st.sidebar.warning("API key required to try this app. The API key is not stored in any form.")

# ---------------------------------------------------------------------------
# Sidebar — navigation and actions
# ---------------------------------------------------------------------------

st.sidebar.markdown("## Navigation")
st.sidebar.info("Use the dropdown menu above ↑ to navigate between pages")

st.sidebar.markdown("## Actions")
st.sidebar.button("New Chat", on_click=new_chat, type="primary")

col1, col2 = st.sidebar.columns(2)
with col1:
    if st.button("Credit Cards", type="secondary"):
        st.info("Please use the sidebar navigation menu to view the Credit Cards page")
with col2:
    if st.button("My Cards", type="secondary"):
        st.info("Please use the sidebar navigation menu to view the My Credit Cards page")

# ---------------------------------------------------------------------------
# Conversation — input → agent → display
# ---------------------------------------------------------------------------

user_input = get_text()

if user_input and API_O:
    with st.status("Thinking...", expanded=False) as status:
        try:
            result = agent_executor.invoke({"input": user_input})
            output = result["output"]

            if show_tool_calls and result.get("intermediate_steps"):
                st.write("**Tools used:**")
                for action, _ in result["intermediate_steps"]:
                    st.write(f"- `{action.tool}` ← {action.tool_input}")

            status.update(label="Done", state="complete", expanded=False)
        except Exception as e:
            error_type = type(e).__name__
            if "RateLimit" in error_type:
                output = "I've hit the API rate limit. Please wait a moment and try again."
            elif "Timeout" in error_type or "Connection" in error_type:
                output = "Research is temporarily unavailable. I'll answer from my training data instead. Please try again shortly."
            else:
                output = "I encountered an error processing your request. Please try rephrasing your question."
            status.update(label="Error", state="error", expanded=False)

    st.session_state.past.append(user_input)
    st.session_state.generated.append(output)

# ---------------------------------------------------------------------------
# Conversation history display
# ---------------------------------------------------------------------------

download_str = []
with st.expander("Conversation", expanded=True):
    for i in range(len(st.session_state["generated"]) - 1, -1, -1):
        st.info(st.session_state["past"][i], icon="🧐")
        st.success(st.session_state["generated"][i], icon="🤖")
        download_str.append(st.session_state["past"][i])
        download_str.append(st.session_state["generated"][i])

    download_str = "\n".join(download_str)
    if download_str:
        st.download_button("Download", download_str)

# ---------------------------------------------------------------------------
# Stored sessions
# ---------------------------------------------------------------------------

for i, sublist in enumerate(st.session_state.stored_session):
    with st.sidebar.expander(label=f"Conversation-Session:{i}"):
        st.write(sublist)

if st.session_state.stored_session:
    if st.sidebar.checkbox("Clear-all"):
        del st.session_state.stored_session
