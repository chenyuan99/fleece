"""
Credit Cards Page for Fleece Application
This page displays various credit cards and their details to users.
"""
import streamlit as st
import pandas as pd
import os
from image_service import  display_card_image

# Set page configuration
st.set_page_config(page_title="Credit Cards | Fleece", layout="wide")

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
st.title("Credit Card Recommendations")
st.subheader("Find the best cards for your needs")

# Define card data
cards = [
    {
        "name": "Chase Sapphire Preferred",
        "annual_fee": "$95",
        "rewards": "5x on travel purchased through Chase, 3x on dining, 2x on other travel",
        "welcome_bonus": "60,000 points after spending $4,000 in first 3 months",
        "image_url": "https://creditcards.chase.com/K-Marketplace/images/cardart/sapphire_preferred_card.png",
        "best_for": "Travel rewards with moderate annual fee"
    },
    {
        "name": "American Express Gold",
        "annual_fee": "$250",
        "rewards": "4x at restaurants, 4x at U.S. supermarkets (up to $25,000/year), 3x on flights",
        "welcome_bonus": "60,000 points after spending $4,000 in first 6 months",
        "image_url": "https://icm.aexp-static.com/Internet/Acquisition/US_en/AppContent/OneSite/category/cardarts/gold-card.png",
        "best_for": "Dining and grocery rewards"
    },
    {
        "name": "Citi Double Cash",
        "annual_fee": "$0",
        "rewards": "2% on all purchases (1% when you buy, 1% when you pay)",
        "welcome_bonus": "None",
        "image_url": "https://www.citi.com/CRD/images/citi-double-cash/card_2.png",
        "best_for": "Simple cash back with no annual fee"
    },
    {
        "name": "Capital One Venture",
        "annual_fee": "$95",
        "rewards": "2x miles on all purchases",
        "welcome_bonus": "75,000 miles after spending $4,000 in first 3 months",
        "image_url": "https://ecm.capitalone.com/WCM/card/products/venture-card-art/tablet.png",
        "best_for": "Travel rewards with flexible redemption options"
    },
    {
        "name": "Discover it Cash Back",
        "annual_fee": "$0",
        "rewards": "5% cash back in rotating categories (up to $1,500 per quarter), 1% on all else",
        "welcome_bonus": "Cash back match at end of first year",
        "image_url": "https://www.discover.com/content/dam/discover/en_us/credit-cards/card-acquisition/rewards/it-chrome/images/discover-it-cashback-match-card-art.png",
        "best_for": "Rotating category cash back"
    }
]

# Filter options
st.sidebar.header("Filter Cards")
annual_fee_filter = st.sidebar.multiselect(
    "Annual Fee",
    options=["$0", "$95", "$250"],
    default=["$0", "$95", "$250"]
)

reward_type_filter = st.sidebar.multiselect(
    "Reward Type",
    options=["Cash Back", "Travel", "Dining", "Groceries", "All Purchases"],
    default=["Cash Back", "Travel", "Dining", "Groceries", "All Purchases"]
)

# Apply filters (simplified for demonstration)
filtered_cards = cards

# Display cards in a grid layout
col1, col2 = st.columns(2)

for i, card in enumerate(filtered_cards):
    with col1 if i % 2 == 0 else col2:
        with st.expander(f"**{card['name']}**", expanded=True):
            st.markdown(f"### {card['name']}")
            
            # Display card image
            img = display_card_image(card['image_url'])
            if img:
                st.image(img, width=300)
            
            st.markdown(f"**Annual Fee:** {card['annual_fee']}")
            st.markdown(f"**Rewards:** {card['rewards']}")
            st.markdown(f"**Welcome Bonus:** {card['welcome_bonus']}")
            st.markdown(f"**Best For:** {card['best_for']}")
            
            # Apply button
            if st.button(f"Apply for {card['name']}", key=f"apply_{i}"):
                st.success(f"Application started for {card['name']}!")

# Add comparison feature
st.sidebar.markdown("---")
if st.sidebar.button("Compare Selected Cards"):
    st.sidebar.info("Card comparison feature coming soon!")

# Add a section for personalized recommendations
st.markdown("---")
st.header("Get Personalized Recommendations")
st.write("Tell us about your spending habits and we'll recommend the best cards for you.")

col1, col2 = st.columns(2)
with col1:
    spending_categories = {
        "Travel": st.slider("Monthly Travel Spending ($)", 0, 2000, 200),
        "Dining": st.slider("Monthly Dining Spending ($)", 0, 2000, 300),
        "Groceries": st.slider("Monthly Grocery Spending ($)", 0, 2000, 400),
        "Gas": st.slider("Monthly Gas Spending ($)", 0, 1000, 150),
        "Other": st.slider("Other Monthly Spending ($)", 0, 5000, 1000),
    }

with col2:
    st.write("### Your Spending Profile")
    total_spending = sum(spending_categories.values())
    
    # Create a pie chart of spending
    df = pd.DataFrame({
        'Category': list(spending_categories.keys()),
        'Amount': list(spending_categories.values())
    })
    
    st.write(f"Total Monthly Spending: ${total_spending}")
    st.bar_chart(df.set_index('Category'))
    
    if st.button("Get Recommendations"):
        st.success("Based on your spending profile, we recommend the following cards:")
        
        # Simple recommendation logic (could be more sophisticated in a real app)
        if spending_categories["Travel"] > 300:
            st.markdown("1. **Chase Sapphire Preferred** - Great for your travel spending!")
        elif spending_categories["Dining"] > 400:
            st.markdown("1. **American Express Gold** - Perfect for your dining habits!")
        elif total_spending > 2000:
            st.markdown("1. **Citi Double Cash** - Solid 2% back on all your spending!")
        else:
            st.markdown("1. **Discover it Cash Back** - Good all-around option!")

# Footer
st.markdown("---")
st.markdown("© 2025 Fleece | Credit card information is for demonstration purposes only.")
