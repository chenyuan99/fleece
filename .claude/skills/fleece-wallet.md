---
name: fleece-wallet
description: Portfolio analysis for a set of cards the user holds — category coverage map, overlaps, gaps, and next-card suggestions. Use when asked how to maximize an existing wallet.
---

# /fleece-wallet

Analyzes a multi-card portfolio and identifies optimization opportunities.

## When to use
- User asks how many cards they have
- User lists their current cards and asks how to maximize
- User asks what category gaps exist in their wallet
- User asks which card to use for a specific purchase given what they hold

## Usage

**If the user has a saved profile (most common)** — no args needed; the CLI auto-loads from `fleece.db`:

```bash
python cli.py wallet
```

**To pass cards explicitly:**

```bash
python cli.py wallet "Amex Platinum" "Chase Freedom Unlimited" "Bilt"
```

**Agent-friendly JSON output:**

```bash
python cli.py wallet --json
```

Cards can come from three sources (in priority order):
1. Arguments passed directly on the command line
2. `--from-profile` / `-p` flag (reads `user_cards.json`)
3. No args + saved profile exists → auto-loads from `fleece.db`

> **Do not query `fleece.db` directly with SQLite.** The CLI fetches live data via
> Brave Search and returns a richer analysis (category rates, transfer partners,
> recent benefit changes). Raw DB queries only give you stored card names and
> cannot surface live earning rates or gaps.

## Output

The result includes:
- **Category coverage map** — which card wins each spend category and at what rate
- **Overlaps** — redundant benefits across cards (e.g., two dining multipliers in different currencies)
- **Gaps** — categories earning only 1x with no bonus card
- **1–2 complementary card suggestions** to plug the biggest gaps

## Example

```bash
# Auto-load saved wallet (preferred)
python cli.py wallet

# Explicit cards
python cli.py wallet "Amex Gold" "Chase Sapphire Preferred" "Citi Double Cash"
```
