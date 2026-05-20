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

## 3. `xcodebuild` CLI fails with plugin error

**Status:** One-time fix required per machine  
**Error:** `xcodebuild failed to load a required plug-in`  

### Fix
Run once with sudo:
```bash
sudo xcodebuild -runFirstLaunch
```
