---
name: fleece-profile
description: Manage the user's spending profile — monthly spend by category, annual fee tolerance, points programs, home airport, and redemption goal. Profile context is automatically injected into fleece wallet, fleece roi, and fleece recommend. Use when setting up or updating the user's preferences.
---

# /fleece-profile

Manages the user's persistent spending profile stored in `fleece.db`. Once set, profile context is automatically injected into `fleece wallet`, `fleece roi`, and `fleece recommend` — no need to re-enter spend amounts each time.

## When to use
- User wants to set up their profile so research commands are personalised
- User updates their spending habits or preferences
- User asks why recommendations don't match their situation (profile may be empty or stale)
- Before running `fleece recommend` or `fleece roi` for the first time

## Profile fields

| Field | Description |
|---|---|
| `dining_monthly` | Monthly dining spend ($) |
| `groceries_monthly` | Monthly groceries spend ($) |
| `travel_monthly` | Monthly travel spend ($) |
| `gas_monthly` | Monthly gas spend ($) |
| `other_monthly` | Monthly other spend ($) |
| `annual_fee_tolerance` | Max annual fee willing to pay ($) |
| `points_programs` | Preferred points programs (e.g. Amex MR, Chase UR) |
| `home_airport` | Home airport IATA code (e.g. JFK) |
| `goal` | Current redemption goal (e.g. business class to Tokyo) |
| `preferences` | Other preferences (e.g. no foreign transaction fees) |

## Usage

```bash
# See all available fields
fleece profile fields

# Show current profile
fleece profile show
fleece profile show --json

# Set fields
fleece profile set dining_monthly 600
fleece profile set travel_monthly 300
fleece profile set annual_fee_tolerance 550
fleece profile set points_programs "Amex MR, Chase UR"
fleece profile set home_airport JFK
fleece profile set goal "business class to Tokyo, June 2027"

# Clear a field
fleece profile unset goal
```

## How profile enriches other commands

Once set, you don't need to pass spend amounts manually:

```bash
# Without profile: must pass all spend flags
fleece roi "Amex Gold" --dining 600 --travel 300 --other 800

# With profile set: spend values pulled automatically
fleece roi "Amex Gold"

# fleece wallet and fleece recommend also use profile context automatically
fleece wallet
fleece recommend "travel rewards"
```

## Setup workflow

```bash
fleece profile set dining_monthly 600
fleece profile set groceries_monthly 400
fleece profile set travel_monthly 300
fleece profile set gas_monthly 150
fleece profile set other_monthly 800
fleece profile set annual_fee_tolerance 250
fleece profile set home_airport JFK
fleece profile set goal "Fly business to Tokyo in 2027"
fleece profile show
```
