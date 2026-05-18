---
name: fleece
description: Fleece credit card research CLI. Provides live US credit card data via Brave Search — full reports, earning rates, transfer partners, statement credits, recent news, card comparisons, portfolio analysis, ROI estimates, and profile-based recommendations. Install with `pip install fleece-cli`. Use whenever you need current credit card information.
---

# Fleece Credit Card Research

Live US credit card research backed by Brave Search. All commands output JSON for
programmatic use. Requires `BRAVE_API_KEY` in the environment.

## Prerequisites

```bash
# Install once
pip install fleece-cli

# Set in environment or .env file
export BRAVE_API_KEY=<your_key>
```

## Commands

### Full card report
```bash
fleece card "<card name>" --json
```
Returns fees, welcome offer, earning rates, credits, benefits, and strategy.

### Earning rates
```bash
fleece rates "<card name>" --json
fleece rates "<card name>" --category "<dining|travel|groceries|gas>" --json
```

### Transfer partners
```bash
fleece partners "<card name>" --json
```
Returns airline and hotel partners with ratios and transfer timing.

### Statement credits
```bash
fleece credits "<card name>" --json
```
Returns all credits with amounts, cadence, and enrollment requirements.

### Recent news (past month)
```bash
fleece news "<card name>" --json
```
Freshness-filtered to the past month.

### Side-by-side comparison
```bash
fleece compare "<card A>" "<card B>" --json
fleece compare "<card A>" "<card B>" --aspects "fees,rewards,credits" --json
```

### Portfolio / wallet analysis
```bash
fleece wallet "<card 1>" "<card 2>" "<card 3>" --json
```
Returns coverage map, overlaps, gaps, and next-card suggestions.

### First-year ROI
```bash
fleece roi "<card name>" --travel <monthly $> --dining <monthly $> --other <monthly $> --json
```

### Profile-based recommendations
```bash
fleece recommend "<spending profile>" --json
fleece recommend "<spending profile>" --preferences "<preferences>" --json
```

## Output format

Every command with `--json` returns:
```json
{
  "command": "card",
  "query": "...",
  "result": "...",
  "ok": true,
  "error": null
}
```

On error, `ok` is `false` and `error` contains the message. Always check `ok` before using `result`.

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Search / tool error (Brave API failure) |
| `2` | `BRAVE_API_KEY` not set |

## Stdin piping

The primary argument on any single-card command accepts `-` to read from stdin:
```bash
echo "Chase Sapphire Preferred" | fleece card - --json
echo "high dining spend" | fleece recommend - --json
```

The `wallet` command accepts `-` as its sole argument to read newline-delimited card names:
```bash
printf "Amex Gold\nChase Freedom Unlimited\nBilt\n" | fleece wallet - --json
```

## Coverage

Supports all major US issuers: Amex, Bank of America, Barclays, Bilt, Capital One,
Chase, Citi, Discover, Robinhood, U.S. Bank, Wells Fargo.
