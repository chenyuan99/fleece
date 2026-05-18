---
name: fleece-news
description: Recent changes to a credit card in the past month — benefit cuts, fee increases, new perks, or limited-time offers. Use when asked if anything changed recently.
---

# /fleece-news

Searches for the latest news and changes for a card using freshness-filtered results.

## When to use
- User asks if a card's benefits have changed recently
- User heard something changed and wants confirmation
- You want to verify your training data is still accurate

## Usage

```bash
fleece news "<card name>" --json
```

Results are filtered to the past month (`freshness=pm`).

## Example

```bash
fleece news "Amex Gold" --json
fleece news "Chase Sapphire Reserve" --json
```
