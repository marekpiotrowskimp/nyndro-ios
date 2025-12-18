# Nyndro v1.01 - Release Checklist

## Pre-Release Checklist

### Code & Build

- [ ] Version number updated to 1.01 in `project.yml`
- [ ] Build number updated to 2 in `project.yml`
- [ ] Project regenerated with `xcodegen generate`
- [ ] All tests passing
- [ ] No compiler warnings
- [ ] App runs correctly on simulator (iPhone)
- [ ] App runs correctly on physical device
- [ ] Dark mode tested
- [ ] Light mode tested
- [ ] All localizations tested (EN, PL, DE)

### App Store Connect - App Information

- [ ] App name: **Nyndro**
- [ ] Subtitle set for each language
- [ ] Primary category: **Lifestyle**
- [ ] Secondary category: **Health & Fitness**
- [ ] Age rating questionnaire completed
- [ ] Privacy Policy URL configured
- [ ] Support URL configured

### App Store Connect - Pricing

- [ ] Price: **Free**
- [ ] Availability: All territories (or selected)

### App Store Connect - App Privacy

- [ ] Data collection practices declared
- [ ] Privacy nutrition labels completed

### Metadata (per language: EN, PL, DE)

- [ ] Name (30 chars max)
- [ ] Subtitle (30 chars max)
- [ ] Description (4000 chars max)
- [ ] Keywords (100 chars max)
- [ ] Promotional Text (170 chars max)

### Screenshots

- [ ] iPhone 6.7" screenshots (1290 x 2796 px) - 5-6 images
- [ ] iPhone 6.5" screenshots (1242 x 2688 px) - or use 6.7"
- [ ] Screenshots for each language (EN, PL, DE)

### App Icon

- [ ] App Icon 1024x1024 px in Assets.xcassets

### Build Upload

- [ ] Archive created in Xcode (Product > Archive)
- [ ] Build uploaded to App Store Connect
- [ ] Build processing completed
- [ ] Build selected for submission

### Final Review

- [ ] All metadata reviewed for typos
- [ ] All screenshots reviewed
- [ ] Contact information correct
- [ ] Demo account notes provided (if needed)
- [ ] App Review notes provided

---

## Submission

- [ ] Submit for App Review
- [ ] Received "Waiting for Review" status
- [ ] Received "In Review" status
- [ ] Received "Ready for Sale" status

---

## Post-Release

- [ ] Verify app appears in App Store
- [ ] Verify app downloads correctly
- [ ] Verify all localizations display correctly
- [ ] Monitor App Store Connect for reviews
- [ ] Monitor crash reports (if analytics enabled)

---

## Quick Commands

### Build & Archive
```bash
# Clean build folder
xcodebuild clean -project Nyndro.xcodeproj -scheme Nyndro

# Build for release
xcodebuild -project Nyndro.xcodeproj -scheme Nyndro -configuration Release

# Archive (use Xcode GUI for App Store submission)
# Product > Archive
```

### Regenerate Project
```bash
xcodegen generate
```

### Validate Localizations
```bash
./Scripts/validate_localizations.sh
```

---

## Metadata Files Location

```
release_1_01/
├── docs/
│   ├── privacy_policy.html
│   └── support.html
├── metadata/
│   ├── en-US/
│   │   ├── name.txt
│   │   ├── subtitle.txt
│   │   ├── description.txt
│   │   ├── keywords.txt
│   │   └── promotional_text.txt
│   ├── pl/
│   │   └── ... (same structure)
│   └── de-DE/
│       └── ... (same structure)
├── APP_STORE_INFO.md
└── RELEASE_CHECKLIST.md (this file)
```

---

## Important URLs

| Resource | URL |
|----------|-----|
| App Store Connect | https://appstoreconnect.apple.com |
| Apple Developer | https://developer.apple.com |
| App Review Guidelines | https://developer.apple.com/app-store/review/guidelines/ |

---

*Checklist for Nyndro v1.01 - First App Store Release*
