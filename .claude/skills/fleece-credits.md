---
name: fleece-credits
description: Statement credits and perks for a credit card — amounts, cadence, enrollment requirements. Use when asked how to offset the annual fee or what credits are available.
---

# /fleece-credits

Fetches the full list of statement credits and perks for a card.

## When to use
- User asks what credits a card offers
- User wants to know how to offset the annual fee
- User asks about dining, travel, streaming, or hotel credits

## Usage

```bash
python cli.py credits "<card name>" --json
```

## Example

```bash
python cli.py credits "Amex Platinum" --json
python cli.py credits "Chase Sapphire Reserve" --json
```
