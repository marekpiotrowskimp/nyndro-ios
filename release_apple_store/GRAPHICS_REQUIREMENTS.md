# Required Graphics for App Store

## 1. App Icon (DONE)

| Size | Status | Location |
|------|--------|----------|
| 1024x1024 px | ✅ Done | `Nyndro/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png` |

---

## 2. Screenshots (REQUIRED)

### Required Device Sizes

You must provide screenshots for at least one of these sizes:

| Device | Size (Portrait) | Required |
|--------|-----------------|----------|
| **iPhone 6.7"** (15 Pro Max, 14 Pro Max) | 1290 x 2796 px | Yes (or 6.5") |
| **iPhone 6.5"** (11 Pro Max, XS Max) | 1242 x 2688 px | Yes (or 6.7") |
| **iPhone 5.5"** (8 Plus, 7 Plus) | 1242 x 2208 px | Optional |

### Recommended Screenshots (5-6 images)

Create screenshots showing:

1. **Practice List** - Main screen with practice cards
   - Show 2-3 practices with different colors
   - Show progress percentages

2. **Counter Screen** - Tap to count interface
   - Show large counter number
   - Show "Tap anywhere to count" hint

3. **Progress Visualization** - Mala or Lotus view
   - Show partially filled progress
   - Choose the most visually appealing style

4. **Statistics** - Charts and predictions
   - Show weekly activity chart
   - Show estimated completion date

5. **History** - Practice history list
   - Show several entries with dates
   - Show total counts

6. **Settings** (optional) - App customization
   - Show sound and haptic options
   - Show progress style picker

### Screenshot Tips

- Use light mode (more common)
- Hide status bar clutter if possible
- Show realistic data (not 0% or 100%)
- Consider adding marketing text overlays
- Use consistent device frame style

### Tools for Creating Screenshots

- **Simulator** - Cmd+S to save screenshot
- **AppMockUp** (appmockup.io) - Free device frames
- **Previewed** (previewed.app) - Professional mockups
- **Figma** - Custom templates
- **Fastlane Frameit** - Automated framing

---

## 3. App Preview Video (OPTIONAL)

| Size | Format | Duration |
|------|--------|----------|
| 1290 x 2796 px | .mov, .m4v, .mp4 | 15-30 seconds |

### Video Content Ideas

- Show adding a practice
- Demonstrate tap counting
- Show progress animation
- Display statistics

---

## 4. How to Capture Screenshots

### Using Simulator

```bash
# Run app in simulator
open -a Simulator

# Take screenshot (saves to Desktop)
# Press Cmd+S in Simulator

# Or use xcrun
xcrun simctl io booted screenshot screenshot.png
```

### Recommended Simulators

- iPhone 15 Pro Max (6.7")
- iPhone 14 Pro Max (6.7")
- iPhone 11 Pro Max (6.5")

---

## 5. Screenshot Placement in App Store Connect

1. Go to App Store Connect
2. Select your app → App Store tab
3. Scroll to "Screenshots"
4. Upload for each device size
5. Drag to reorder

---

## 6. Checklist

- [ ] App Icon 1024x1024 ✅
- [ ] iPhone 6.7" screenshots (5-6 images)
- [ ] iPhone 6.5" screenshots (or use 6.7" - will auto-scale)
- [ ] Optional: App Preview video
- [ ] Optional: iPad screenshots (if supporting iPad)
