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

# Cache card data to avoid recomputation on each rerun
@st.cache_data(ttl=3600)  # Cache for 1 hour
def get_card_data():
    """Get credit card data with caching"""
    return [
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

# Get cached card data
cards = get_card_data()

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

# Function to preload card images in parallel
@st.cache_data(ttl=3600)
def preload_card_images(cards, max_cards=5):
    """Preload card images in parallel for better performance"""
    import concurrent.futures
    
    # Only preload the first few cards for initial performance
    urls = [card['image_url'] for card in cards[:max_cards]]
    
    results = {}
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        future_to_url = {executor.submit(display_card_image, url): url for url in urls}
        for future in concurrent.futures.as_completed(future_to_url):
            url = future_to_url[future]
            try:
                results[url] = future.result()
            except Exception as e:
                st.warning(f"Error preloading image: {e}")
    
    return results

# Preload images for better performance
preloaded_images = preload_card_images(filtered_cards)

# Display cards in a grid layout with lazy loading
col1, col2 = st.columns(2)

# Show initial number of cards
if 'show_cards' not in st.session_state:
    st.session_state.show_cards = 4  # Start with showing 4 cards

for i, card in enumerate(filtered_cards[:st.session_state.show_cards]):
    with col1 if i % 2 == 0 else col2:
        # Use expanded=False for lazy loading of content
        with st.expander(f"**{card['name']}**", expanded=False):
            st.markdown(f"### {card['name']}")
            
            # Use preloaded image if available, otherwise fetch on demand
            if card['image_url'] in preloaded_images:
                img = preloaded_images[card['image_url']]
            else:
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

# Load more button
if st.session_state.show_cards < len(filtered_cards):
    if st.button("Load More Cards"):
        st.session_state.show_cards += 4  # Show 4 more cards
        st.rerun()

# Add comparison feature
st.sidebar.markdown("---")
if st.sidebar.button("Compare Selected Cards"):
    st.sidebar.info("Card comparison feature coming soon!")

# Add a section for personalized recommendations
st.markdown("---")
st.header("Get Personalized Recommendations")
st.write("Tell us about your spending habits and we'll recommend the best cards for you.")

# Use a form to batch all inputs and reduce rerendering
with st.form(key="spending_form"):
    col1, col2 = st.columns(2)
    
    with col1:
        st.write("### Enter Your Monthly Spending")
        spending_categories = {
            "Travel": st.slider("Travel Spending ($)", 0, 2000, 200),
            "Dining": st.slider("Dining Spending ($)", 0, 2000, 300),
            "Groceries": st.slider("Grocery Spending ($)", 0, 2000, 400),
            "Gas": st.slider("Gas Spending ($)", 0, 1000, 150),
            "Other": st.slider("Other Spending ($)", 0, 5000, 1000),
        }
        
        # Submit button for the form
        submitted = st.form_submit_button("Get Recommendations")
    
    with col2:
        st.write("### Your Spending Profile")
        total_spending = sum(spending_categories.values())
        
        # Create a chart of spending
        df = pd.DataFrame({
            'Category': list(spending_categories.keys()),
            'Amount': list(spending_categories.values())
        })
        
        st.write(f"Total Monthly Spending: ${total_spending}")
        st.bar_chart(df.set_index('Category'))

# Cache the recommendation logic
@st.cache_data
def get_card_recommendations(spending):
    """Get card recommendations based on spending profile"""
    travel = spending.get("Travel", 0)
    dining = spending.get("Dining", 0)
    groceries = spending.get("Groceries", 0)
    gas = spending.get("Gas", 0)
    total = sum(spending.values())
    
    recommendations = []
    
    # Primary recommendation
    if travel > 300:
        recommendations.append(("Chase Sapphire Preferred", "Great for your travel spending!"))
    elif dining > 400:
        recommendations.append(("American Express Gold", "Perfect for your dining habits!"))
    elif groceries > 500:
        recommendations.append(("Blue Cash Preferred", "6% cash back on groceries!"))
    elif gas > 200:
        recommendations.append(("Wells Fargo Autograph", "Great for gas stations and travel!"))
    elif total > 2000:
        recommendations.append(("Citi Double Cash", "Solid 2% back on all your spending!"))
    else:
        recommendations.append(("Discover it Cash Back", "Good all-around option!"))
    
    # Secondary recommendation
    if total > 3000 and "Citi Double Cash" not in [r[0] for r in recommendations]:
        recommendations.append(("Citi Double Cash", "Good for all other spending categories"))
    
    return recommendations

# Display recommendations if form was submitted
if 'submitted' in locals() and submitted:
    with st.container():
        st.success("Based on your spending profile, we recommend the following cards:")
        
        # Get cached recommendations
        recommendations = get_card_recommendations(spending_categories)
        
        for i, (card_name, reason) in enumerate(recommendations, 1):
            st.markdown(f"{i}. **{card_name}** - {reason}")
            
            # Find the card in our database
            card_details = next((card for card in cards if card["name"] == card_name), None)
            if card_details:
                with st.expander("View Card Details"):
                    col1, col2 = st.columns([1, 2])
                    with col1:
                        img = display_card_image(card_details['image_url'])
                        if img:
                            st.image(img, width=200)
                    with col2:
                        st.markdown(f"**Annual Fee:** {card_details['annual_fee']}")
                        st.markdown(f"**Rewards:** {card_details['rewards']}")
                        st.markdown(f"**Welcome Bonus:** {card_details['welcome_bonus']}")
        
        st.info("💡 Pro tip: Consider having a combination of cards to maximize rewards across different spending categories.")


# Footer
st.markdown("---")
st.markdown("© 2025 Fleece | Credit card information is for demonstration purposes only.")
