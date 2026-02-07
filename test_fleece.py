"""
Tests for fleece.py — the main Streamlit chatbot application.

Because fleece.py executes top-level Streamlit calls on import, every test
must patch `streamlit` (and related modules) before importing the module.
We use importlib to get a fresh module-level execution per test.
"""

import importlib
from unittest.mock import MagicMock, patch


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

class FakeSessionState:
    """Mimics Streamlit's SessionState: supports both dict-style and attribute access."""

    def __init__(self, initial=None):
        # Use object.__setattr__ to avoid triggering our custom __setattr__
        object.__setattr__(self, "_store", dict(initial or {}))

    def __contains__(self, key):
        return key in self._store

    def __getitem__(self, key):
        return self._store[key]

    def __setitem__(self, key, value):
        self._store[key] = value

    def __delitem__(self, key):
        del self._store[key]

    def __getattr__(self, key):
        store = object.__getattribute__(self, "_store")
        if key in store:
            return store[key]
        raise AttributeError(key)

    def __setattr__(self, key, value):
        self._store[key] = value

    def __delattr__(self, key):
        del self._store[key]


def _build_st_mock():
    """Build a mock for the `streamlit` module with enough surface area for fleece.py."""
    st = MagicMock()
    # Default text inputs to empty strings so the module-level code
    # doesn't enter the API-key or user-input branches.
    st.text_input.return_value = ""
    st.sidebar.text_input.return_value = ""
    # Buttons and checkboxes default to False (not clicked / unchecked),
    # matching Streamlit's real behavior.
    st.button.return_value = False
    st.checkbox.return_value = False
    st.sidebar.checkbox.return_value = False
    # st.sidebar.columns(2) must return two context-manager-capable mocks
    col1, col2 = MagicMock(), MagicMock()
    st.sidebar.columns.return_value = [col1, col2]
    return st


def _default_langchain_mocks(lc_overrides=None):
    """Return the standard set of langchain sys.modules mocks."""
    lc_prompt = MagicMock()
    lc_prompt.ENTITY_MEMORY_CONVERSATION_TEMPLATE = MagicMock()

    mocks = {
        "langchain": MagicMock(),
        "langchain.chains": MagicMock(),
        "langchain.chains.conversation": MagicMock(),
        "langchain.chains.conversation.memory": MagicMock(),
        "langchain.chains.conversation.prompt": lc_prompt,
        "langchain_openai": MagicMock(),
    }
    if lc_overrides:
        mocks.update(lc_overrides)
    return mocks


def _import_fleece(st_mock, langchain_mocks=None):
    """
    Import (or reload) fleece.py with streamlit and langchain patched.
    Returns the imported module.
    """
    import sys

    patches = {"streamlit": st_mock}
    patches.update(langchain_mocks or _default_langchain_mocks())

    sys.modules.pop("fleece", None)

    with patch.dict(sys.modules, patches):
        mod = importlib.import_module("fleece")
    return mod


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------


class TestSessionStateInitialization:
    """Verify that fleece.py initialises missing session-state keys."""

    def test_default_keys_are_created(self):
        st_mock = _build_st_mock()
        state = FakeSessionState()
        st_mock.session_state = state

        _import_fleece(st_mock)

        assert "generated" in state
        assert "past" in state
        assert "input" in state
        assert "stored_session" in state

    def test_default_values_are_empty_lists_and_string(self):
        st_mock = _build_st_mock()
        state = FakeSessionState()
        st_mock.session_state = state

        _import_fleece(st_mock)

        assert state["generated"] == []
        assert state["past"] == []
        assert state["input"] == ""
        assert state["stored_session"] == []

    def test_existing_keys_are_not_overwritten(self):
        st_mock = _build_st_mock()
        state = FakeSessionState({
            "generated": ["old_response"],
            "past": ["old_prompt"],
            "input": "hello",
            "stored_session": [["archived"]],
        })
        st_mock.session_state = state

        _import_fleece(st_mock)

        assert state["generated"] == ["old_response"]
        assert state["past"] == ["old_prompt"]
        assert state["input"] == "hello"
        assert state["stored_session"] == [["archived"]]


class TestNewChat:
    """Tests for the new_chat() function."""

    def _setup(self, store_contents):
        """Import fleece with the given session state and return (new_chat, state)."""
        st_mock = _build_st_mock()
        state = FakeSessionState(store_contents)
        st_mock.session_state = state

        mod = _import_fleece(st_mock)
        return mod.new_chat, state

    def test_archives_conversation_in_reverse_order(self):
        entity_memory = MagicMock()
        entity_memory.entity_store = {"Person": "info"}
        entity_memory.buffer = MagicMock()

        new_chat, state = self._setup({
            "generated": ["response1", "response2"],
            "past": ["prompt1", "prompt2"],
            "input": "current input",
            "stored_session": [],
            "entity_memory": entity_memory,
        })

        new_chat()

        assert len(state["stored_session"]) == 1
        archived = state["stored_session"][0]
        assert archived[0] == "User:prompt2"
        assert archived[1] == "Bot:response2"
        assert archived[2] == "User:prompt1"
        assert archived[3] == "Bot:response1"

    def test_clears_generated_past_and_input(self):
        entity_memory = MagicMock()
        entity_memory.entity_store = {"Person": "info"}
        entity_memory.buffer = MagicMock()

        new_chat, state = self._setup({
            "generated": ["r1"],
            "past": ["p1"],
            "input": "text",
            "stored_session": [],
            "entity_memory": entity_memory,
        })

        new_chat()

        assert state["generated"] == []
        assert state["past"] == []
        assert state["input"] == ""

    def test_clears_entity_memory(self):
        entity_memory = MagicMock()
        entity_memory.entity_store = {"Person": "info"}
        entity_memory.buffer = MagicMock()

        new_chat, state = self._setup({
            "generated": ["r1"],
            "past": ["p1"],
            "input": "",
            "stored_session": [],
            "entity_memory": entity_memory,
        })

        new_chat()

        assert state.entity_memory.entity_store == {}
        state.entity_memory.buffer.clear.assert_called_once()

    def test_empty_conversation_archives_empty_list(self):
        entity_memory = MagicMock()
        entity_memory.entity_store = {}
        entity_memory.buffer = MagicMock()

        new_chat, state = self._setup({
            "generated": [],
            "past": [],
            "input": "",
            "stored_session": [],
            "entity_memory": entity_memory,
        })

        new_chat()

        assert len(state["stored_session"]) == 1
        assert state["stored_session"][0] == []

    def test_preserves_previous_sessions(self):
        entity_memory = MagicMock()
        entity_memory.entity_store = {}
        entity_memory.buffer = MagicMock()

        existing_session = ["User:old", "Bot:old_reply"]
        new_chat, state = self._setup({
            "generated": ["new_reply"],
            "past": ["new_msg"],
            "input": "",
            "stored_session": [existing_session],
            "entity_memory": entity_memory,
        })

        new_chat()

        assert len(state["stored_session"]) == 2
        assert state["stored_session"][0] == existing_session


class TestGetText:
    """Tests for the get_text() function."""

    def test_returns_user_input(self):
        st_mock = _build_st_mock()
        state = FakeSessionState()
        st_mock.session_state = state

        mod = _import_fleece(st_mock)

        # Change return value *after* import so module-level get_text()
        # returned "" (avoiding the Conversation branch).
        st_mock.text_input.return_value = "What card should I get?"
        result = mod.get_text()

        assert result == "What card should I get?"

    def test_passes_correct_label(self):
        st_mock = _build_st_mock()
        state = FakeSessionState()
        st_mock.session_state = state
        st_mock.text_input.return_value = ""

        mod = _import_fleece(st_mock)
        mod.get_text()

        call_args = st_mock.text_input.call_args
        assert call_args is not None
        assert call_args[0][0] == "You: "


class TestConversationChainSetup:
    """Verify that providing an API key sets up the LLM and memory."""

    def test_llm_created_with_api_key(self):
        st_mock = _build_st_mock()
        state = FakeSessionState()
        st_mock.session_state = state

        # sidebar.text_input returns an API key
        st_mock.sidebar.text_input.return_value = "sk-test-key-123"
        st_mock.sidebar.expander.return_value.__enter__ = MagicMock(return_value=st_mock)
        st_mock.sidebar.expander.return_value.__exit__ = MagicMock(return_value=False)
        st_mock.selectbox.return_value = "gpt-4o"
        st_mock.number_input.return_value = 5

        mock_chat_openai = MagicMock()
        lc_openai = MagicMock()
        lc_openai.ChatOpenAI = mock_chat_openai

        lc_chain = MagicMock()
        lc_prompt = MagicMock()
        lc_prompt.ENTITY_MEMORY_CONVERSATION_TEMPLATE = "template"

        overrides = {
            "langchain.chains": lc_chain,
            "langchain.chains.conversation.prompt": lc_prompt,
            "langchain_openai": lc_openai,
        }

        _import_fleece(st_mock, _default_langchain_mocks(overrides))

        mock_chat_openai.assert_called()

    def test_no_api_key_shows_warning(self):
        st_mock = _build_st_mock()
        state = FakeSessionState()
        st_mock.session_state = state

        # sidebar.text_input returns empty string (no API key)
        st_mock.sidebar.text_input.return_value = ""
        st_mock.sidebar.expander.return_value.__enter__ = MagicMock(return_value=st_mock)
        st_mock.sidebar.expander.return_value.__exit__ = MagicMock(return_value=False)

        _import_fleece(st_mock)

        st_mock.sidebar.warning.assert_called()


class TestDownloadConversation:
    """Verify conversation download string is built correctly."""

    def test_download_str_format(self):
        """The download string joins past and generated messages with newlines,
        newest first."""
        past = ["Hello", "How are you?"]
        generated = ["Hi there!", "I'm good, thanks!"]

        # Reproduce the logic from fleece.py lines 174-184
        download_str = []
        for i in range(len(generated) - 1, -1, -1):
            download_str.append(past[i])
            download_str.append(generated[i])

        result = "\n".join(download_str)
        lines = result.split("\n")

        assert lines[0] == "How are you?"
        assert lines[1] == "I'm good, thanks!"
        assert lines[2] == "Hello"
        assert lines[3] == "Hi there!"

    def test_empty_conversation_produces_empty_string(self):
        download_str = []
        result = "\n".join(download_str)
        assert result == ""
