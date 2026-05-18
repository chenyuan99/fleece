---
name: fleece-roi
description: First-year ROI estimate for a credit card given monthly spend on travel, dining, and other. Calculates welcome bonus value + earn + credits minus annual fee.
---

# /fleece-roi

Estimates first-year return on investment for a card based on the user's spending.

## When to use
- User asks if a card is worth it for them specifically
- User provides their spending habits and wants a value estimate
- User wants to compare first-year value across cards

## Usage

```bash
python cli.py roi "<card name>" --travel <monthly $> --dining <monthly $> --other <monthly $> --json
```

All spend flags are optional and default to `0`. Omit any category the user didn't mention.

## Example

```bash
python cli.py roi "Chase Sapphire Preferred" --travel 500 --dining 300 --other 1000 --json
python cli.py roi "Amex Gold" --dining 800 --other 500 --json
```

The result includes annual spend totals, an assumed cents-per-point value, and live research context.
Present the math clearly and note that exact welcome bonus amounts should be verified with the issuer.
