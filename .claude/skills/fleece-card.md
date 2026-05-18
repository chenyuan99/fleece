---
name: fleece-card
description: Full credit card report — fees, welcome offer, earning rates, statement credits, benefits, and strategy. Use when asked about a specific card in detail.
---

# /fleece-card

Fetches a comprehensive report for a US credit card using live Brave Search data.

## When to use
- User asks about a specific card's details, benefits, or annual fee
- User wants to know if a card is worth it
- You need current card info (training data may be stale)

## Usage

```bash
python cli.py card "<card name>" --json
```

The `--json` flag returns a structured envelope your can parse:
```json
{ "command": "card", "query": "...", "result": "...", "ok": true, "error": null }
```

Use `result` as your research context, then synthesize a natural answer.

## Exit codes
- `0` success
- `1` search error — tell the user and fall back to training data
- `2` `BRAVE_API_KEY` not configured

## Example

```bash
python cli.py card "Chase Sapphire Preferred" --json
python cli.py card "Amex Gold" --json
```
