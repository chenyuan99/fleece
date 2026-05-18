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
python cli.py recommend "<spending profile>" --json
python cli.py recommend "<spending profile>" --preferences "<extra preferences>" --json
```

Keep the profile concise: categories + rough amounts or priorities.

## Example

```bash
python cli.py recommend "high dining and travel spend, $500/mo dining, $300/mo travel" --json
python cli.py recommend "everyday spending, mostly groceries and gas" --preferences "no annual fee" --json
python cli.py recommend "frequent international traveler" --preferences "priority pass lounge access" --json
```

After receiving results, present 2–3 top recommendations with a brief rationale for each.
