"""
My Credit Cards Page for Fleece Application
This page displays the credit cards that the user currently owns and their details.
"""
import streamlit as st
import pandas as pd
from PIL import Image
import os
import io
import requests
from io import BytesIO
import json
import datetime

# Set page configuration
st.set_page_config(page_title="My Credit Cards | Fleece", layout="wide")

# Load custom CSS
def load_css():
    try:
        with open("style.css") as f:
            st.markdown(f'<style>{f.read()}</style>', unsafe_allow_html=True)
    except FileNotFoundError:
        # Try with relative path from pages directory
        try:
            with open(os.path.join(os.path.dirname(__file__), "..", "style.css")) as f:
                st.markdown(f'<style>{f.read()}</style>', unsafe_allow_html=True)
        except Exception as e:
            st.warning(f"Could not load custom styling: {e}")

try:
    load_css()
except Exception as e:
    st.warning(f"Could not load custom styling: {e}")

# Page header
st.title("My Credit Cards")
st.subheader("Manage your current credit card portfolio")

# File path for storing user's credit cards
USER_CARDS_FILE = os.path.join(os.path.dirname(__file__), "..", "user_cards.json")

# Function to load user's credit cards
def load_user_cards():
    if os.path.exists(USER_CARDS_FILE):
        try:
            with open(USER_CARDS_FILE, 'r') as f:
                return json.load(f)
        except Exception as e:
            st.error(f"Error loading your cards: {e}")
            return []
    else:
        return []

# Function to save user's credit cards
def save_user_cards(cards):
    try:
        with open(USER_CARDS_FILE, 'w') as f:
            json.dump(cards, f, indent=2)
        return True
    except Exception as e:
        st.error(f"Error saving your cards: {e}")
        return False

# Function to display card image
def display_card_image(image_url):
    try:
        response = requests.get(image_url)
        img = Image.open(BytesIO(response.content))
        return img
    except Exception as e:
        # If loading from URL fails, try to use a default image
        try:
            img = Image.open(os.path.join(os.path.dirname(__file__), "..", "assets", "default_card.png"))
            return img
        except:
            st.error(f"Error loading image")
            return None

# Load user's credit cards
user_cards = load_user_cards()

# Two tabs: View Cards and Add New Card
tab1, tab2 = st.tabs(["My Cards", "Add New Card"])

# Tab 1: View Cards
with tab1:
    if not user_cards:
        st.info("You haven't added any credit cards yet. Use the 'Add New Card' tab to add your first card.")
    else:
        # Display summary metrics
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Total Cards", len(user_cards))
        with col2:
            total_credit_limit = sum(card.get('credit_limit', 0) for card in user_cards)
            st.metric("Total Credit Limit", f"${total_credit_limit:,}")
        with col3:
            annual_fees = sum(int(card.get('annual_fee', '0').replace('$', '').replace(',', '')) for card in user_cards)
            st.metric("Annual Fees", f"${annual_fees}")
        
        # Sort options
        sort_by = st.selectbox(
            "Sort by",
            options=["Card Name", "Annual Fee", "Credit Limit", "Date Added"],
            index=0
        )
        
        # Sort the cards based on selection
        if sort_by == "Card Name":
            sorted_cards = sorted(user_cards, key=lambda x: x.get('name', ''))
        elif sort_by == "Annual Fee":
            sorted_cards = sorted(user_cards, key=lambda x: int(x.get('annual_fee', '$0').replace('$', '').replace(',', '')))
        elif sort_by == "Credit Limit":
            sorted_cards = sorted(user_cards, key=lambda x: x.get('credit_limit', 0), reverse=True)
        else:  # Date Added
            sorted_cards = sorted(user_cards, key=lambda x: x.get('date_added', ''), reverse=True)
        
        # Display cards in a grid layout
        for i, card in enumerate(sorted_cards):
            with st.expander(f"**{card['name']}**", expanded=True):
                col1, col2 = st.columns([1, 2])
                
                with col1:
                    # Display card image
                    img = display_card_image(card.get('image_url', ''))
                    if img:
                        st.image(img, width=250)
                
                with col2:
                    # Card details
                    st.markdown(f"### {card['name']}")
                    st.markdown(f"**Card Number:** •••• •••• •••• {card.get('last_four', '****')}")
                    st.markdown(f"**Annual Fee:** {card.get('annual_fee', 'N/A')}")
                    st.markdown(f"**Credit Limit:** ${card.get('credit_limit', 'N/A'):,}")
                    st.markdown(f"**Rewards:** {card.get('rewards', 'N/A')}")
                    st.markdown(f"**Expiration:** {card.get('expiration', 'N/A')}")
                    st.markdown(f"**Date Added:** {card.get('date_added', 'N/A')}")
                    
                    # Action buttons
                    col1, col2 = st.columns(2)
                    with col1:
                        if st.button(f"Remove Card", key=f"remove_{i}"):
                            user_cards.remove(card)
                            if save_user_cards(user_cards):
                                st.success(f"Removed {card['name']} from your cards!")
                                st.rerun()
                    
                    with col2:
                        if st.button(f"Edit Details", key=f"edit_{i}"):
                            st.session_state['edit_card'] = card
                            st.session_state['edit_index'] = i
                            st.rerun()
        
        # Edit card form (appears when Edit Details is clicked)
        if 'edit_card' in st.session_state and 'edit_index' in st.session_state:
            with st.form("edit_card_form"):
                st.subheader(f"Edit {st.session_state['edit_card']['name']}")
                
                name = st.text_input("Card Name", value=st.session_state['edit_card']['name'])
                last_four = st.text_input("Last Four Digits", value=st.session_state['edit_card'].get('last_four', ''))
                annual_fee = st.text_input("Annual Fee (e.g. $95)", value=st.session_state['edit_card'].get('annual_fee', '$0'))
                credit_limit = st.number_input("Credit Limit ($)", value=int(st.session_state['edit_card'].get('credit_limit', 0)))
                rewards = st.text_area("Rewards", value=st.session_state['edit_card'].get('rewards', ''))
                expiration = st.text_input("Expiration (MM/YY)", value=st.session_state['edit_card'].get('expiration', ''))
                
                submitted = st.form_submit_button("Save Changes")
                if submitted:
                    # Update card details
                    user_cards[st.session_state['edit_index']]['name'] = name
                    user_cards[st.session_state['edit_index']]['last_four'] = last_four
                    user_cards[st.session_state['edit_index']]['annual_fee'] = annual_fee
                    user_cards[st.session_state['edit_index']]['credit_limit'] = credit_limit
                    user_cards[st.session_state['edit_index']]['rewards'] = rewards
                    user_cards[st.session_state['edit_index']]['expiration'] = expiration
                    
                    if save_user_cards(user_cards):
                        st.success("Card details updated successfully!")
                        # Clear the edit state and refresh
                        del st.session_state['edit_card']
                        del st.session_state['edit_index']
                        st.rerun()

# Tab 2: Add New Card
with tab2:
    st.subheader("Add a New Credit Card")
    
    # Sample card templates to choose from
    card_templates = [
        {"name": "Chase Sapphire Preferred", "annual_fee": "$95", "rewards": "5x on travel purchased through Chase, 3x on dining, 2x on other travel", "image_url": "https://creditcards.chase.com/K-Marketplace/images/cardart/sapphire_preferred_card.png"},
        {"name": "American Express Gold", "annual_fee": "$250", "rewards": "4x at restaurants, 4x at U.S. supermarkets (up to $25,000/year), 3x on flights", "image_url": "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/gold-card.png"},
        {"name": "Citi Double Cash", "annual_fee": "$0", "rewards": "2% on all purchases (1% when you buy, 1% when you pay)", "image_url": "https://www.citi.com/CRD/images/citi-double-cash/card_2.png"},
        {"name": "Capital One Venture", "annual_fee": "$95", "rewards": "2x miles on all purchases", "image_url": "https://ecm.capitalone.com/WCM/card/products/venture-card-art/tablet.png"},
        {"name": "Custom Card", "annual_fee": "$0", "rewards": "Enter your own rewards", "image_url": ""}
    ]
    
    # Let user select from templates or custom
    template_names = [card["name"] for card in card_templates]
    selected_template = st.selectbox("Select a card template or create custom", template_names)
    
    # Get the selected template
    template = next((card for card in card_templates if card["name"] == selected_template), None)
    
    # Create a form for adding a new card
    with st.form("add_card_form"):
        name = st.text_input("Card Name", value=template["name"])
        last_four = st.text_input("Last Four Digits", max_chars=4, help="Last 4 digits of your card number")
        annual_fee = st.text_input("Annual Fee", value=template["annual_fee"])
        credit_limit = st.number_input("Credit Limit ($)", min_value=0, value=10000, step=1000)
        rewards = st.text_area("Rewards", value=template["rewards"])
        expiration = st.text_input("Expiration Date (MM/YY)", placeholder="05/28")
        
        # Only show image URL field for custom card
        image_url = template["image_url"]
        if selected_template == "Custom Card":
            image_url = st.text_input("Card Image URL (optional)")
        
        submitted = st.form_submit_button("Add Card")
        if submitted:
            # Create new card entry
            new_card = {
                "name": name,
                "last_four": last_four,
                "annual_fee": annual_fee,
                "credit_limit": credit_limit,
                "rewards": rewards,
                "expiration": expiration,
                "image_url": image_url,
                "date_added": datetime.datetime.now().strftime("%Y-%m-%d")
            }
            
            # Add to user's cards
            user_cards.append(new_card)
            
            # Save updated cards
            if save_user_cards(user_cards):
                st.success(f"Added {name} to your cards!")
                # Switch to the My Cards tab
                st.rerun()

# Add a section for card statistics and insights
if user_cards:
    st.markdown("---")
    st.header("Card Portfolio Insights")
    
    # Create dataframe for analysis
    card_data = []
    for card in user_cards:
        annual_fee_value = int(card.get('annual_fee', '$0').replace('$', '').replace(',', ''))
        card_data.append({
            'name': card.get('name', 'Unknown'),
            'annual_fee': annual_fee_value,
            'credit_limit': card.get('credit_limit', 0)
        })
    
    df = pd.DataFrame(card_data)
    
    # Display charts
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Credit Limit Distribution")
        st.bar_chart(df.set_index('name')['credit_limit'])
    
    with col2:
        st.subheader("Annual Fee Comparison")
        st.bar_chart(df.set_index('name')['annual_fee'])
    
    # Calculate utilization if we had that data
    st.info("💡 Pro tip: A good credit utilization ratio is under 30% of your total available credit.")

# Footer
st.markdown("---")
st.markdown("© 2025 Fleece | Manage your credit cards wisely.")
