# Fleece - Credit Card Recommendation and Management App

## Overview

Fleece is a comprehensive credit card recommendation and management application built with Streamlit and LangChain. The app helps users find the best credit cards based on their spending habits and manage their existing credit card portfolio.

## Author

@chenyuan99

## Features

### Chat Interface
- Interactive AI-powered chat assistant using OpenAI's GPT models
- Conversation memory that remembers context across sessions
- Entity memory to track important information mentioned in conversations
- Ability to save and download conversation history

### Credit Card Recommendations
- Browse a curated list of popular credit cards with detailed information
- Filter cards by annual fee, reward type, and other criteria
- Get personalized card recommendations based on spending habits
- Compare different cards side by side

### My Credit Cards Management
- Track all your existing credit cards in one place
- Add new cards with templates or custom information
- Edit card details and remove cards you no longer use
- View portfolio insights with visualizations of credit limits and annual fees
- Sort and filter your cards by various criteria

## Performance Optimizations

The application includes several performance optimizations:

1. **Image Handling**
   - Parallel image loading with ThreadPoolExecutor
   - Multi-level image caching to reduce network requests
   - Pre-generated default card images

2. **Data Management**
   - Streamlit caching with TTL for expensive operations
   - Lazy loading of UI components
   - Optimized data structures

3. **UI/UX Improvements**
   - Pagination for card displays
   - Progressive loading with "Load More" buttons
   - Form submission to reduce rerendering

## Technical Architecture

### Core Components
- **fleece.py**: Main application entry point with chat interface
- **pages/credit_cards.py**: Credit card recommendation page
- **pages/my_credit_cards.py**: Personal credit card management page
- **image_service.py**: Optimized image loading and caching service
- **style.css**: Custom styling for the application

### Dependencies
- Streamlit: Web application framework
- LangChain: Framework for working with language models
- OpenAI: API for accessing GPT models
- Pandas: Data manipulation and analysis
- PIL: Image processing
- Requests: HTTP requests for fetching card images

## Installation and Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/chenyuan99/fleece.git
   cd fleece
   ```

2. Create and activate a virtual environment:
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Set up your OpenAI API key in a `.env` file:
   ```
   OPENAI_API_KEY=your_api_key_here
   ```

5. Run the application:
   ```bash
   streamlit run fleece.py
   ```

## Usage Guide

### Chat Interface
- Enter your query in the text input field
- The AI assistant will respond based on the conversation context
- Use the "New Chat" button to start a fresh conversation
- Download your conversation history using the download button

### Credit Card Recommendations
- Browse available credit cards in the expandable card views
- Use sidebar filters to narrow down card options
- Enter your spending habits in the form to get personalized recommendations
- Click "Apply" on any card to start the application process

### My Credit Cards
- View all your cards with detailed information
- Use the "Add New Card" tab to add a new credit card
- Choose from templates or create a custom card entry
- Edit or remove existing cards as needed
- View portfolio insights to understand your credit profile

## Resources

- [OpenAI](https://openai.com/)
- [LangChain](https://langchain.readthedocs.io/)
- [Streamlit](https://streamlit.io/)

## License

MIT

