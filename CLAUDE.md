# Fleece - Credit Card Research Chatbot

## Project Overview
**Fleece** is a Streamlit-based conversational AI application designed to help users find the best credit cards for their needs. The tagline is "Find the best card for deal saviors."

### Core Purpose
Fleece is a chatbot that:
- Uses OpenAI's chat models (gpt-3.5-turbo, gpt-4, gpt-4-turbo, gpt-4o) to provide conversational credit card research and recommendations
- Maintains entity-based memory across conversations to remember user details and preferences
- Allows users to explore available credit cards and manage their existing card portfolio
- Stores conversation history and provides download capability

### Tech Stack
- **Frontend**: Streamlit (Python web app framework)
- **LLM**: OpenAI ChatGPT (via LangChain)
- **Memory**: ConversationEntityMemory (tracks entities mentioned in conversation)
- **Language**: Python

## Key Features
1. **Conversational Interface**: Chat with an AI assistant about credit cards
2. **Entity Memory**: Remembers details about the user across conversation turns
3. **Multi-model Support**: Choose between different OpenAI models
4. **Conversation Management**: 
   - Start new chats
   - Browse past conversation sessions
   - Download conversation history
   - Customize memory buffer size (K parameter)
5. **Navigation**: Planned pages for "Credit Cards" exploration and "My Credit Cards" management

## Current Limitations & Opportunities
- **Limited knowledge**: Currently relies on OpenAI's training data, which may be outdated for credit card details
- **No specialized tools**: The chatbot cannot search current issuer websites or real-time data sources
- **No structured research**: Lacks the ability to provide specific, verified credit card information (fees, benefits, offers, transfer partners, etc.)

## Future Integration Opportunities
- **credit-card-skills integration**: Add specialized research capabilities to access live issuer data
- **Multi-page app expansion**: Build out the "Credit Cards" discovery page and "My Credit Cards" portfolio management
- **Database backend**: Store user profiles, card portfolios, and preferences

## Development Notes
- Author: Yuan Chen
- Created: March 16, 2025
- Uses custom CSS styling (style.css)
- Requires OpenAI API key (entered via sidebar, not stored)

## Infrastructure Notes
- **Databricks**: No Databricks resources are available at the moment. The Databricks App deployment workflow has been removed. Do not suggest or implement Databricks-based solutions until resources are provisioned.