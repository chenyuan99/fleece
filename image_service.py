import os
import functools
from PIL import Image, ImageDraw, ImageFont
import requests
from io import BytesIO
import streamlit as st
import logging
import time

# Configure logging
logging.basicConfig(level=logging.WARNING)

# Create the default image once at module level
DEFAULT_CARD_IMAGE = None
try:
    width, height = 340, 220
    DEFAULT_CARD_IMAGE = Image.new('RGB', (width, height), color=(30, 58, 138))  # Dark blue background
    draw = ImageDraw.Draw(DEFAULT_CARD_IMAGE)
    draw.rectangle([(20, 20), (70, 60)], fill=(255, 215, 0))  # Gold chip
    draw.text((width//2, height//2), "FLEECE CARD", fill=(255, 255, 255), anchor="mm")
    draw.text((40, 160), "•••• •••• •••• ••••", fill=(255, 255, 255))
    draw.text((40, 185), "CARDHOLDER NAME", fill=(200, 200, 200))
    draw.text((280, 185), "VALID THRU", fill=(200, 200, 200))
    draw.text((280, 200), "MM/YY", fill=(255, 255, 255))
    logging.info("Default card image pre-generated successfully")
except Exception as e:
    logging.error(f"Failed to create default image: {e}")

# Cache for storing fetched images
IMAGE_CACHE = {}
CACHE_EXPIRY = 3600  # Cache expiry in seconds (1 hour)

@functools.lru_cache(maxsize=32)
def cached_image_fetch(image_url):
    """Cache image fetching to avoid repeated network requests"""
    # Check if we have a valid cached response
    if image_url in IMAGE_CACHE:
        timestamp, content = IMAGE_CACHE[image_url]
        if time.time() - timestamp < CACHE_EXPIRY:
            logging.info(f"Cache hit for {image_url}")
            return content
    
    # Fetch the image if not in cache or expired
    try:
        logging.info(f"Fetching image from {image_url}")
        response = requests.get(image_url, timeout=5)
        if response.status_code == 200:
            # Store in cache
            IMAGE_CACHE[image_url] = (time.time(), response.content)
            return response.content
    except Exception as e:
        logging.warning(f"Error fetching image from {image_url}: {e}")
    
    return None

def display_card_image(image_url):
    """Display a credit card image, with caching and fallback to default image"""
    # Use cached image fetch
    content = cached_image_fetch(image_url)
    
    if content:
        try:
            img = Image.open(BytesIO(content))
            return img
        except Exception as e:
            logging.warning(f"Could not process image content: {e}")
    
    # Return the pre-generated default image if available
    if DEFAULT_CARD_IMAGE:
        logging.info("Using default card image")
        return DEFAULT_CARD_IMAGE.copy()
    
    # Fallback to generating a new default image if the pre-generated one failed
    try:
        logging.warning("Creating new default image as fallback")
        width, height = 340, 220
        img = Image.new('RGB', (width, height), color=(30, 58, 138))
        draw = ImageDraw.Draw(img)
        draw.rectangle([(20, 20), (70, 60)], fill=(255, 215, 0))
        draw.text((width//2, height//2), "FLEECE CARD", fill=(255, 255, 255), anchor="mm")
        draw.text((40, 160), "•••• •••• •••• ••••", fill=(255, 255, 255))
        draw.text((40, 185), "CARDHOLDER NAME", fill=(200, 200, 200))
        draw.text((280, 185), "VALID THRU", fill=(200, 200, 200))
        draw.text((280, 200), "MM/YY", fill=(255, 255, 255))
        return img
    except Exception as e:
        logging.error(f"Error creating fallback default image: {e}")
    
    # If all else fails, return None
    return None