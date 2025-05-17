import os
from PIL import Image, ImageDraw, ImageFont
import requests
from io import BytesIO
import streamlit as st
import logging

# Function to display card image
def display_card_image(image_url):
    try:
        response = requests.get(image_url, timeout=5)
        if response.status_code == 200:
            try:
                img = Image.open(BytesIO(response.content))
                return img
            except Exception as e:
                logging.warning(f"Could not process image from URL: {e}")
        else:
            logging.warning(f"Failed to fetch image: Status code {response.status_code}")
    except Exception as e:
        logging.warning(f"Error fetching image: {e}")
    
    # If loading from URL fails, create a default image
    try:
        # Create a simple default credit card image
        width, height = 340, 220
        img = Image.new('RGB', (width, height), color=(30, 58, 138))  # Dark blue background
        
        # Create a drawing context
        draw = ImageDraw.Draw(img)
        
        # Draw a gold chip
        draw.rectangle([(20, 20), (70, 60)], fill=(255, 215, 0))
        
        # Add text
        draw.text((width//2, height//2), "FLEECE CARD", fill=(255, 255, 255), anchor="mm")
        draw.text((40, 160), "•••• •••• •••• ••••", fill=(255, 255, 255))
        draw.text((40, 185), "CARDHOLDER NAME", fill=(200, 200, 200))
        draw.text((280, 185), "VALID THRU", fill=(200, 200, 200))
        draw.text((280, 200), "MM/YY", fill=(255, 255, 255))
        
        return img
    except Exception as e:
        logging.warning(f"Error creating default image: {e}")
    
    # If all else fails, return None
    return None