# Nyndro - Development Roadmap

## Current State (v1.0)

Fully functional local app:
- Practice tracking with visualizations (Mala, Lotus)
- Statistics and completion predictions
- History and reminders
- Data export/import (JSON, CSV)
- Localizations (EN/PL/DE)

---

## Phase 1: Post-Launch Stabilization (v1.1)

### Analytics & Monitoring
- [ ] **TelemetryDeck** - Privacy-focused analytics (GDPR compliant, EU-based)
  - Track: app opens, practice sessions, feature usage
  - No personal data collection
- [ ] **Sentry** or **Firebase Crashlytics** - Crash reporting
  - Real-time crash alerts
  - Stack traces and device info

### iOS Widgets
- [ ] **Small widget** - Current streak + today's count
- [ ] **Medium widget** - Practice progress bars
- [ ] **Lock screen widget** - Quick glance at streak

### Quick Wins
- [ ] Calendar heatmap view (GitHub-style activity visualization)
- [ ] Streak freeze (1 day grace period)
- [ ] Improved onboarding with sample data option

---

## Phase 2: Cloud Sync & Apple Watch (v1.2)

### CloudKit Integration
- [ ] Sync practices across devices (iPhone, iPad)
- [ ] Automatic backup to iCloud
- [ ] Conflict resolution for offline edits
- [ ] Zero server costs (Apple provides infrastructure)

### Apple Watch App
- [ ] Simple tap counter on wrist
- [ ] Haptic feedback per count
- [ ] Complication showing today's progress
- [ ] Sync with iPhone app

### Shortcuts & Siri
- [ ] "Start [practice name] session" voice command
- [ ] Shortcuts app integration
- [ ] Quick actions from app icon (3D Touch / Haptic Touch)

---

## Phase 3: Enhanced Features (v1.3)

### Meditation Timer
- [ ] Configurable duration
- [ ] Interval bells (every X minutes)
- [ ] Background audio support
- [ ] Integration with practice sessions

### Apple Health Integration
- [ ] Log "Mindful Minutes"
- [ ] Read/write meditation data
- [ ] Health app summary

### Achievements System
- [ ] Milestone badges (1k, 10k, 100k repetitions)
- [ ] Streak achievements (7, 21, 30, 100, 365 days)
- [ ] Practice completion certificates
- [ ] Share achievements

### Additional Features
- [ ] PDF export with practice report/certificate
- [ ] Calendar integration (block time for practice)
- [ ] Custom app icons
- [ ] Additional themes (pure dark, warm, cool)

---

## Phase 4: Community Features (v2.0) - Optional

### Anonymous Global Statistics
- [ ] "Today the community completed X repetitions"
- [ ] Global practice counter
- [ ] No personal data shared - just aggregate numbers

### Community Challenges
- [ ] Group goals (e.g., "1 million mantras together")
- [ ] Time-limited events
- [ ] Optional participation

### Guided Content
- [ ] Audio mantra recordings
- [ ] Practice instructions
- [ ] Ambient sounds (temple bells, nature, rain)
- [ ] Teacher talks integration (external links)

---

## Service Recommendations

### Analytics (choose one)
| Service | Why | Cost |
|---------|-----|------|
| **TelemetryDeck** ⭐ | Privacy-focused, EU, Swift native | Free < 100k signals |
| Firebase Analytics | Full-featured, Google ecosystem | Free |
| PostHog | Open-source, self-host option | Free tier available |

### Crash Reporting (choose one)
| Service | Why | Cost |
|---------|-----|------|
| **Sentry** ⭐ | Great error grouping, alerts | Free < 5k errors/mo |
| Firebase Crashlytics | Integrated with Firebase | Free |

### Cloud Sync
| Service | Why | Cost |
|---------|-----|------|
| **CloudKit** ⭐ | Apple native, zero server cost, privacy | Free |
| Firebase Firestore | Cross-platform | Free tier |
| Supabase | Open-source, PostgreSQL | Free tier |

### Push Notifications
| Service | Why | Cost |
|---------|-----|------|
| **APNs** ⭐ | Native, local notifications sufficient | Free |
| OneSignal | If need advanced segmentation | Free tier |

---

## Monetization Options (Future)

| Model | Description | Fit for Dharma App |
|-------|-------------|-------------------|
| **Free** | Completely free, no ads | ⭐⭐⭐ Best for dharma |
| **Tip Jar** | Voluntary donations in-app | ⭐⭐⭐ Aligned with dana |
| **Freemium** | Basic free, premium features paid | ⭐⭐ Acceptable |
| **One-time purchase** | Unlock all forever | ⭐⭐ Fair |
| **Subscription** | Monthly/yearly | ⭐ Less aligned |

**Recommendation:** Free app with optional Tip Jar for those who want to support development.

---

## Technical Debt & Improvements

### Code Quality
- [ ] Add unit tests for services
- [ ] Add UI tests for critical flows
- [ ] SwiftLint integration
- [ ] Documentation comments

### Performance
- [ ] Profile and optimize SwiftData queries
- [ ] Lazy loading for large history lists
- [ ] Image/asset optimization

### Accessibility
- [ ] VoiceOver support audit
- [ ] Dynamic Type support
- [ ] Reduce Motion support
- [ ] Color contrast verification

---

## Timeline Estimate

| Phase | Target | Effort |
|-------|--------|--------|
| v1.0 | Now | Done ✅ |
| v1.1 | +2-4 weeks post-launch | ~20 hours |
| v1.2 | +2-3 months | ~40 hours |
| v1.3 | +4-6 months | ~30 hours |
| v2.0 | +1 year | ~60 hours |

---

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| Dec 2024 | iOS only (no Android) | Focus on quality, CloudKit benefits |
| Dec 2024 | SwiftData over Core Data | Modern, simpler API |
| Dec 2024 | Local-first architecture | Privacy, offline support |
| TBD | Analytics choice | TBD after launch |
| TBD | Monetization | TBD based on user feedback |

---

## Notes

- Keep app aligned with Buddhist principles (simplicity, mindfulness, non-attachment)
- Privacy is a feature, not an afterthought
- Community features should be optional, never required
- Avoid gamification that creates attachment or competition
- Consider accessibility for elderly practitioners
