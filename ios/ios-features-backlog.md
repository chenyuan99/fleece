# Fleece iOS — Features Backlog

Planned features, ideas discussed during development, and deferred work.

---

## PassKit

### Lock screen pass / Wallet pass
Issue a Fleece-branded pass into Apple Wallet that surfaces the best card recommendation as a live lock screen widget.

- Use `PKPass` + a signed `.pkpass` bundle served from a backend
- Pass type: Generic pass with a custom barcode or QR
- Dynamic fields: merchant name, best card, multiplier, reward rate
- Update pass via Apple's push notification service for passes (`PKPushRegistry`)
- Requires: PassKit certificate from Apple Developer portal + a small server to sign passes

### Wallet network auto-populate
Currently detection fires on launch and silently sorts the "Add to Wallet" list. Future improvement:
- After user adds a card to Fleece wallet, offer to also add a branded pass to Apple Wallet
- Deep-link to relevant card issuer app for full application

---

## Maps & Place Detection

### Fix manual map tap (MKLocalPointsOfInterestRequest)
See `ios-known-issues.md` issue #1. Replace `MKLocalSearch.Request` with `MKLocalPointsOfInterestRequest(coordinateRegion:)` which anchors strictly to the passed region rather than drifting toward device GPS.

```swift
let region = MKCoordinateRegion(center: coord,
                                 latitudinalMeters: 300,
                                 longitudinalMeters: 300)
let request = MKLocalPointsOfInterestRequest(coordinateRegion: region)
request.pointOfInterestFilter = .includingAll
let search = MKLocalSearch(request: request)
```

### Real-time place tracking
Use `CLLocationManager.startMonitoringSignificantLocationChanges()` for background location updates — fires a notification when you arrive at a new type of merchant without the user having the app open.

### Geofencing for recurring places
Let users save favourite stores (Trader Joe's, favourite gas station) and get a card reminder notification on entry via `CLCircularRegion` geofence monitoring.

---

## Apple Intelligence / Foundation Models

### Richer AI explanation
Current: one-sentence explanation per card in the recommendations sheet.
Future:
- Stream the response word-by-word using `LanguageModelSession.streamResponse`
- Add a "Why?" button on the horizontal card chips to expand the explanation inline
- Structured output with `@Generable`: return `headline`, `reasoning`, and `estimatedAnnualValue` fields

### AI-powered card database
Use Foundation Models to interpret freeform place names and map them to MCC categories when `MKLocalSearch` returns ambiguous types (e.g. "establishment only").

---

## Wallet & Cards

### Full card database
Expand beyond the current 9 cards to include:
- Chase Freedom Flex, Ink Business cards
- Citi Custom Cash, Premier, Prestige
- Amex EveryDay, Delta co-brands, Marriott Bonvoy
- Discover it, US Bank Altitude
- Synchrony store cards (Amazon, Costco)

### Card image / art
Show the actual card artwork in the wallet using `AsyncImage` loaded from card issuer CDNs or a Fleece-hosted asset catalog.

### iCloud sync
Sync wallet selection across iPhone, iPad, and Mac using `NSUbiquitousKeyValueStore` or CloudKit so the user's card setup carries over to new devices.

### Spending profile
Port the CLI `fleece profile` feature to iOS — let users set `dining_monthly`, `groceries_monthly`, etc. and use those values to personalise ROI estimates shown per card.

---

## Notifications

### Rich notifications
Add card art thumbnail to the push notification via `UNNotificationAttachment`.

### Notification actions
Currently "View All Cards" opens the sheet. Add a second action:
- "Add to Wallet" → one tap adds the recommended card to the Fleece wallet

### Smart cooldown
Current: 5-minute global cooldown per place ID. Future: per-category cooldown so moving from a restaurant to a grocery store fires a new notification even within the cooldown window.

---

## App Store

### Developer account
Pending Apple Developer Program approval (`cysbc1999@gmail.com`). Once active:
1. Run `ios/release.sh <TEAM_ID>` to archive + upload
2. Add screenshots from `ios/screenshots/framed/` to App Store Connect
3. Write privacy policy (required — app uses location)
4. Submit for review

### Privacy policy page
Required by Apple for any app using location. Can be a simple `docs/privacy.html` hosted at `getfleece.io/privacy`.

### App Clip
Lightweight `<10 MB` version that activates via NFC or QR at a merchant — shows the best card for that specific store without requiring the full app install.

---

## Widget

### Home screen widget
`WidgetKit` extension showing the best card for the current location, updating via `TimelineProvider` on significant location changes.

- Small: card name + multiplier + category emoji
- Medium: card chip + place name + reward rate
- Lock screen: single line "Use Amex Gold · 4x Dining"
