---
name: fleece
description: Fleece credit card research CLI. Provides live US credit card data via Brave Search — full reports, earning rates, transfer partners, statement credits, recent news, card comparisons, portfolio analysis, ROI estimates, and profile-based recommendations. Use whenever you need current credit card information.
---

# Fleece Credit Card Research

Live US credit card research backed by Brave Search. All commands output JSON for
programmatic use. Requires `BRAVE_API_KEY` in the environment.

## Prerequisites

```bash
# Set in environment or .env file
export BRAVE_API_KEY=<your_key>

# Run from the fleece project root
cd /path/to/fleece
```

## Commands

### Full card report
```bash
python cli.py card "<card name>" --json
```
Returns fees, welcome offer, earning rates, credits, benefits, and strategy.

### Earning rates
```bash
python cli.py rates "<card name>" --json
python cli.py rates "<card name>" --category "<dining|travel|groceries|gas>" --json
```

### Transfer partners
```bash
python cli.py partners "<card name>" --json
```
Returns airline and hotel partners with ratios and transfer timing.

### Statement credits
```bash
python cli.py credits "<card name>" --json
```
Returns all credits with amounts, cadence, and enrollment requirements.

### Recent news (past month)
```bash
python cli.py news "<card name>" --json
```
Freshness-filtered to the past month.

### Side-by-side comparison
```bash
python cli.py compare "<card A>" "<card B>" --json
python cli.py compare "<card A>" "<card B>" --aspects "fees,rewards,credits" --json
```

### Portfolio / wallet analysis
```bash
python cli.py wallet "<card 1>" "<card 2>" "<card 3>" --json
```
Returns coverage map, overlaps, gaps, and next-card suggestions.

### First-year ROI
```bash
python cli.py roi "<card name>" --travel <monthly $> --dining <monthly $> --other <monthly $> --json
```

### Profile-based recommendations
```bash
python cli.py recommend "<spending profile>" --json
python cli.py recommend "<spending profile>" --preferences "<preferences>" --json
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
echo "Chase Sapphire Preferred" | python cli.py card - --json
echo "high dining spend" | python cli.py recommend - --json
```

The `wallet` command accepts `-` as its sole argument to read newline-delimited card names:
```bash
printf "Amex Gold\nChase Freedom Unlimited\nBilt\n" | python cli.py wallet - --json
```

## Coverage

Supports all major US issuers: Amex, Bank of America, Barclays, Bilt, Capital One,
Chase, Citi, Discover, Robinhood, U.S. Bank, Wells Fargo.
