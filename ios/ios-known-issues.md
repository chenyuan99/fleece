# Fleece iOS — Known Issues

---

## 1. Manual map tap does not update place banner or card recommendations

**Status:** ✅ Fixed  
**Affected build:** all current builds  
**Affects:** Simulator and physical device  

### Symptom
Tapping the map drops the native red `Marker` pin at the tapped coordinate, but the place banner and card recommendation strip do not update to reflect the tapped location — they remain on the last GPS-detected place.

### What was tried
| Approach | Result |
|---|---|
| `onTapGesture` on `Map` | Swallowed by MapKit's pan/zoom gesture handlers — tap never fires |
| `simultaneousGesture(SpatialTapGesture())` on `Map` | Tap fires, pin drops, but `MKLocalSearch` returns same result as GPS location |
| Increased search radius to 300m for manual taps | No change in banner output |

### Root cause hypothesis
`MKLocalSearch` with `naturalLanguageQuery: "point of interest"` appears to anchor results to the device's current GPS location rather than the `region.center` passed in the request when running on the iOS 26 simulator. The search returns the same prominent landmark (Point Reyes National Seashore) regardless of the tapped coordinate.

### Root cause
`MKLocalSearch.Request` with `naturalLanguageQuery` treats the region as a hint and anchors results to the device's GPS location, ignoring the tapped coordinate.

### Fix applied
Replaced `MKLocalSearch.Request` + `naturalLanguageQuery` with `MKLocalPointsOfInterestRequest(coordinateRegion:)` which anchors strictly to the passed region. No natural language query — returns all POIs within the given radius of the tapped point.

---

## 2. iOS 26 Simulator — MapKit tiles intermittently blank on launch

**Status:** Known simulator bug (not a Fleece bug)  
**Affected:** iOS 26.5 simulator only  

### Symptom
On app launch the map area renders white. The nav bar, tab bar, and recommendation strip all appear correctly.

### Fix
Shut down and reboot the simulator before launching:
```bash
xcrun simctl shutdown <UDID>
xcrun simctl boot <UDID>
xcrun simctl location <UDID> set 37.7749,-122.4194
```

---

## 3. Apple Intelligence chat returns "Something went wrong" on KB tool queries

**Status:** ✅ Partially mitigated (root cause: on-device context window limit)
**Affected:** Physical device, iOS 26+, Apple Intelligence enabled
**Triggers:** Questions that invoke `get_application_rules` or `get_point_valuations`

### Symptom
Asking questions like "Can I get the Amex Gold bonus again?" or "How much are my Chase points worth?" causes the AI chat to return a generic error instead of an answer.

### Console output (noise — unrelated to this bug)
The following lines appear in the Xcode console on every run and are **not** related to this issue:
```
Failed to locate resource named "default.csv"
Connection error: com.apple.PerfPowerTelemetryClientRegistrationService … Sandbox restriction
(+[PPSClientDonation …]) Permission denied: Maps / SpringfieldUsage
CAMetalLayer ignoring invalid setDrawableSize width=0.000000 height=0.000000
```
These are simulator sandbox and telemetry artifacts. Safe to ignore.

### Root cause
`KnowledgeBase.applicationRules()` and `KnowledgeBase.valuationText` were returning 100–200 word strings per tool call. After a tool call, the full response (system prompt + conversation + tool result) is passed back to the on-device model for `FleeceResponse` guided generation. Long tool responses exhaust the context budget, causing the generation to fail and throw.

The error was also silently swallowed — "Something went wrong" gave no diagnostic information.

### Fix applied
- Trimmed `rulesText` and `valuationText` from ~150 words to ~40 words each, preserving the key facts.
- Changed catch block to show the actual `NSError.localizedDescription` in the chat bubble so future errors are diagnosable.
- Committed in `39157be`.

### If the error recurs
Check the chat bubble — it now shows the real error message. Common follow-ons:
- `"generation failed: context length exceeded"` → further trim the relevant KB text string
- `"schema validation failed"` → check `@Generable FleeceResponse` field count / optionality
- `"model unavailable"` → Apple Intelligence is off or device is not eligible

---

## 4. `xcodebuild` CLI fails with plugin error

**Status:** One-time fix required per machine  
**Error:** `xcodebuild failed to load a required plug-in`  

### Fix
Run once with sudo:
```bash
sudo xcodebuild -runFirstLaunch
```
