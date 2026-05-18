---
name: fleece-mcc
description: Look up a Merchant Category Code (MCC) and find the best card in the user's wallet to use at that merchant. No API key needed for basic lookup; BRAVE_API_KEY needed for wallet cross-reference. Use when the user asks "what card should I use at [merchant]?" or provides an MCC code.
---

# /fleece-mcc

Looks up an MCC code from the bundled dataset (981 codes, offline) and optionally cross-references with the user's saved wallet to find the highest-earning card.

## When to use
- User asks "what card should I use at [merchant type]?" and you know or can infer the MCC
- User provides an MCC code directly and wants to know the category
- User wants to know which card earns most at a specific merchant category
- After `fleece wallet` identifies a gap, find which MCC codes fall into that gap

## Usage

**Basic lookup (no API key needed):**
```bash
fleece mcc 5812
# → MCC 5812: Eating Places, Restaurants
```

**With wallet cross-reference (requires BRAVE_API_KEY):**
```bash
fleece mcc 5812 --wallet --json
fleece mcc 5411 --wallet --json   # Grocery Stores
fleece mcc 5541 --wallet --json   # Service Stations (gas)
fleece mcc 4111 --wallet --json   # Transportation / Commuter
```

## Common MCCs

| MCC  | Category |
|------|----------|
| 5411 | Grocery Stores, Supermarkets |
| 5812 | Eating Places, Restaurants |
| 5541 | Service Stations (gas) |
| 5912 | Drug Stores, Pharmacies |
| 5310 | Discount Stores |
| 5732 | Electronics Stores |
| 4111 | Transportation / Commuter |
| 4411 | Cruise Lines |
| 7011 | Hotels, Motels, Resorts |
| 4511 | Airlines, Air Carriers |

## Output (--json)

```json
{
  "command": "mcc",
  "mcc": "5812",
  "category": "Eating Places, Restaurants",
  "irs_description": "Restaurants",
  "ok": true,
  "error": null
}
```

With `--wallet`, returns live research on earning rates per card plus a recommendation for the best card to use.

## Notes
- Dataset is bundled with `fleece-cli` — works fully offline for basic lookups
- Source: github.com/greggles/mcc-codes (981 codes)
- `--wallet` mode requires cards saved via `fleece cards add`
