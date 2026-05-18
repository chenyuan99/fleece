---
name: fleece-recommend
description: Card recommendations matched to a spending profile and preferences. Use when the user asks for the best card for their situation without naming a specific card.
---

# /fleece-recommend

Searches for best-match US credit cards for a given spending profile.

## When to use
- User asks "what's the best card for me?"
- User describes their spending habits and wants recommendations
- User states a preference (no annual fee, travel perks, cash back, etc.)

## Usage

```bash
fleece recommend "<spending profile>" --json
fleece recommend "<spending profile>" --preferences "<extra preferences>" --json
```

Keep the profile concise: categories + rough amounts or priorities.

## Example

```bash
fleece recommend "high dining and travel spend, $500/mo dining, $300/mo travel" --json
fleece recommend "everyday spending, mostly groceries and gas" --preferences "no annual fee" --json
fleece recommend "frequent international traveler" --preferences "priority pass lounge access" --json
```

After receiving results, present 2–3 top recommendations with a brief rationale for each.

## MCC-informed spending profiles

For more precise recommendations, identify the MCC codes for the user's top merchants first, then describe the profile by category name:

```bash
# User shops at Whole Foods (5411), commutes by subway (4111), eats out often (5812)
fleece mcc 5411   # → Grocery Stores, Supermarkets
fleece mcc 4111   # → Transportation / Commuter
fleece mcc 5812   # → Eating Places, Restaurants

# Then recommend based on confirmed categories
fleece recommend "grocery stores, transit, restaurants" --json
```

This avoids vague profiles like "I spend a lot on food" and maps the user's real spend to known card bonus categories.
