---
name: fleece-partners
description: Transfer partners for a credit card's rewards program — airlines and hotels, transfer ratios, and timing. Use when asked about moving points or miles.
---

# /fleece-partners

Fetches transfer partner details for a card's rewards currency.

## When to use
- User asks what airlines or hotels they can transfer points to
- User wants to know transfer ratios or how long transfers take
- User is planning a specific redemption and needs partner details

## Usage

```bash
python cli.py partners "<card name>" --json
```

## Example

```bash
python cli.py partners "Chase Sapphire Preferred" --json
python cli.py partners "Capital One Venture X" --json
python cli.py partners "Amex Platinum" --json
```
