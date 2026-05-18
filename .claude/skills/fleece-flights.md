---
name: fleece-flights
description: Generate a PointsYeah flight search URL. No API key required. Use when the user wants to search for award flights or find redemption options for a route.
---

# /fleece-flights

Generates a PointsYeah flight search URL from origin, destination, and date. No Brave API key needed — pure URL generation.

## When to use
- User asks to search for award flights on a route
- User wants to find redemption options after a `fleece wallet` or `fleece partners` analysis
- User provides an origin, destination, and date and wants to look up availability

## Usage

```bash
fleece flights <ORIGIN> <DESTINATION> --date <YYYY-MM-DD> --json
```

**With return date and cabin:**
```bash
fleece flights JFK LHR --date 2026-06-01 --return 2026-06-15 --adults 2 --cabin business --json
```

**Open in browser:**
```bash
fleece flights JFK LAX --date 2026-06-01 --open
```

Cabin options: `economy` | `premium-economy` | `business` | `first` (default: `economy`)

## Output

```json
{
  "command": "flights",
  "origin": "JFK",
  "destination": "LAX",
  "date": "2026-06-01",
  "return_date": null,
  "adults": 1,
  "cabin": "economy",
  "url": "https://www.pointsyeah.com/?type=flights&origin=JFK&destination=LAX&date=2026-06-01&return=&adults=1&cabin=economy",
  "ok": true,
  "error": null
}
```

> PointsYeah does not publish a stable deep-link spec. If the URL stops resolving,
> the query parameters still serve as a useful manual search reference.