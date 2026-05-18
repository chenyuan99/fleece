---
name: fleece-rates
description: Earning rates for a credit card by spend category — points, miles, or cash back per dollar. Optionally filter to a specific category like dining or travel.
---

# /fleece-rates

Looks up earning rates for a credit card, with optional category filtering.

## When to use
- User asks how many points/miles/cash back a card earns
- User wants to know the best card for a specific spend category
- You need to compare multipliers across categories

## Usage

```bash
fleece rates "<card name>" --json
fleece rates "<card name>" --category "<category>" --json
```

Categories: `dining`, `travel`, `groceries`, `gas`, `streaming`, `drugstores`, etc.

## Example

```bash
fleece rates "Chase Sapphire Preferred" --json
fleece rates "Amex Gold" --category dining --json
```

## MCC precision tip

Category names like `dining` are broad — a card may earn differently at MCC 5812 (sit-down restaurants) vs 5814 (fast food) vs 5411 (grocery stores with a café). When exact merchant-level precision matters, pair with `fleece mcc`:

```bash
# Confirm the MCC for the merchant type, then look up the rate
fleece mcc 5814   # → Fast Food Restaurants
fleece rates "Amex Gold" --category "fast food restaurants" --json
```
