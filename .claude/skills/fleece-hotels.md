---
name: fleece-hotels
description: Generate a PointsYeah hotel search URL. No API key required. Use when the user wants to search for award hotel stays or find redemption options for a destination.
---

# /fleece-hotels

Generates a PointsYeah hotel search URL from location and dates. No Brave API key needed — pure URL generation.

## When to use
- User asks to search for award hotel stays at a destination
- User wants to redeem hotel points after a `fleece wallet` or `fleece partners` analysis
- User provides a location and dates and wants to look up availability

## Usage

```bash
fleece hotels "<location>" --checkin <YYYY-MM-DD> --checkout <YYYY-MM-DD> --json
```

**With guests and rooms:**
```bash
fleece hotels "Tokyo" --checkin 2026-06-01 --checkout 2026-06-07 --guests 2 --rooms 1 --json
```

**Open in browser:**
```bash
fleece hotels "Jersey City" --checkin 2026-04-10 --checkout 2026-04-12 --open
```

## Output

```json
{
  "command": "hotels",
  "location": "Tokyo",
  "checkin": "2026-06-01",
  "checkout": "2026-06-07",
  "guests": 1,
  "rooms": 1,
  "url": "https://www.pointsyeah.com/?type=hotels&location=Tokyo&checkin=2026-06-01&checkout=2026-06-07&guests=1&rooms=1",
  "ok": true,
  "error": null
}
```

> PointsYeah does not publish a stable deep-link spec. If the URL stops resolving,
> the query parameters still serve as a useful manual search reference.
