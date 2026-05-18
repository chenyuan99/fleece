---
name: fleece-compare
description: Side-by-side comparison of two credit cards across fees, rewards, welcome offers, credits, and transfer partners. Use when asked which card is better.
---

# /fleece-compare

Searches live data for both cards and returns research for a structured comparison.

## When to use
- User asks "which is better" between two specific cards
- User is deciding between two cards and wants a comparison
- User wants to see how two cards stack up on a specific dimension

## Usage

```bash
fleece compare "<card A>" "<card B>" --json
fleece compare "<card A>" "<card B>" --aspects "fees,rewards,credits" --json
```

Default aspects: `fees,rewards,welcome_offer,credits,transfer_partners`

## Example

```bash
fleece compare "Amex Gold" "Chase Sapphire Preferred" --json
fleece compare "Capital One Venture X" "Chase Sapphire Reserve" --json
```

After receiving the result, synthesize a clear recommendation based on the user's stated priorities.
