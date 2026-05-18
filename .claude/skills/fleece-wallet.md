---
name: fleece-wallet
description: Portfolio analysis for a set of cards the user holds — category coverage map, overlaps, gaps, and next-card suggestions. Use when asked how to maximize an existing wallet.
---

# /fleece-wallet

Analyzes a multi-card portfolio and identifies optimization opportunities.

## When to use
- User lists their current cards and asks how to maximize
- User asks what category gaps exist in their wallet
- User asks which card to use for a specific purchase given what they hold

## Usage

```bash
python cli.py wallet "<card 1>" "<card 2>" "<card 3>" --json
```

Pass each card as a separate quoted argument.

## Example

```bash
python cli.py wallet "Amex Platinum" "Chase Freedom Unlimited" "Bilt" --json
python cli.py wallet "Amex Gold" "Chase Sapphire Preferred" "Citi Double Cash" --json
```

The result includes a coverage map, overlaps, gaps, and 1–2 complementary card suggestions.
