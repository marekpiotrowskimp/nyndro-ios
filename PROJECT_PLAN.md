# Nyndro iOS - Kompletny Plan Projektu v3.0

> Aplikacja do śledzenia praktyk buddyjskich Ngöndro na platformę iOS

## Spis treści

1. [Podsumowanie decyzji](#1-podsumowanie-decyzji)
2. [Architektura projektu](#2-architektura-projektu)
3. [Model danych](#3-model-danych)
4. [Kolorystyka i Dark Mode](#4-kolorystyka-i-dark-mode)
5. [Ikony praktyk](#5-ikony-praktyk)
6. [Custom Progress Bars](#6-custom-progress-bars)
7. [Ekrany aplikacji](#7-ekrany-aplikacji)
8. [Onboarding](#8-onboarding)
9. [Tryb zliczania (Counter Mode)](#9-tryb-zliczania-counter-mode)
10. [Dźwięki i Haptic Feedback](#10-dźwięki-i-haptic-feedback)
11. [Algorytm predykcji](#11-algorytm-predykcji)
12. [System milestones](#12-system-milestones)
13. [Lokalizacja](#13-lokalizacja)
14. [Export/Import](#14-exportimport)
15. [Plan implementacji](#15-plan-implementacji)

---

## 1. Podsumowanie decyzji

| Aspekt | Decyzja |
|--------|---------|
| **Katalog projektu** | `nyndro_ios` |
| **Min. iOS** | 17.0+ |
| **Języki** | English, Polski, Deutsch |
| **Apple Watch** | Faza późniejsza |
| **Model biznesowy** | Darmowa |
| **Tryb zliczania** | Konfigurowalny (+1, +108, custom) |
| **Dźwięki** | Opcje do wyboru (click, bell, singing bowl, gong) |
| **Haptic feedback** | 4 poziomy (none, light, medium, heavy) |
| **Import/Export** | JSON/CSV + Share sheet |
| **Predykcja** | Zakres (optymistyczna-pesymistyczna) + najbardziej prawdopodobna |
| **Reset statystyk** | Po przerwie > 6 miesięcy |
| **Milestones** | Rekord osobisty, % ukończenia, serie dni |
| **Progress Bar** | Lotos (domyślny) + Mala (alternatywa) |
| **Ikony praktyk** | SF Symbols + custom monochromatyczne |
| **Onboarding** | 5 ekranów |
| **Nazwa aplikacji** | Nyndro |

---

## 2. Architektura projektu

```
nyndro_ios/
├── Nyndro.xcodeproj
├── Nyndro/
│   ├── App/
│   │   ├── NyndroApp.swift
│   │   └── ContentView.swift
│   ├── Core/
│   │   ├── Models/
│   │   │   ├── Practice.swift
│   │   │   ├── HistoryEntry.swift
│   │   │   ├── Reminder.swift
│   │   │   └── UserSettings.swift
│   │   ├── Services/
│   │   │   ├── PracticeService.swift
│   │   │   ├── StatisticsService.swift
│   │   │   ├── PredictionService.swift
│   │   │   ├── NotificationService.swift
│   │   │   ├── ExportService.swift
│   │   │   ├── SoundService.swift
│   │   │   ├── HapticService.swift
│   │   │   └── MilestoneService.swift
│   │   ├── Theme/
│   │   │   ├── ThemeColors.swift
│   │   │   ├── PracticeColors.swift
│   │   │   ├── Typography.swift
│   │   │   └── Spacing.swift
│   │   ├── Extensions/
│   │   │   ├── Date+Extensions.swift
│   │   │   ├── Color+Extensions.swift
│   │   │   └── String+Extensions.swift
│   │   └── Utilities/
│   │       └── Constants.swift
│   ├── Features/
│   │   ├── Onboarding/
│   │   │   ├── Views/
│   │   │   │   ├── OnboardingView.swift
│   │   │   │   └── OnboardingPageView.swift
│   │   │   └── ViewModels/
│   │   │       └── OnboardingViewModel.swift
│   │   ├── Practices/
│   │   │   ├── Views/
│   │   │   │   ├── PracticeListView.swift
│   │   │   │   ├── PracticeCardView.swift
│   │   │   │   ├── PracticeDetailView.swift
│   │   │   │   ├── AddPracticeView.swift
│   │   │   │   └── EditPracticeView.swift
│   │   │   └── ViewModels/
│   │   │       └── PracticeViewModel.swift
│   │   ├── Counter/
│   │   │   ├── Views/
│   │   │   │   ├── CounterView.swift
│   │   │   │   └── CounterSettingsSheet.swift
│   │   │   └── ViewModels/
│   │   │       └── CounterViewModel.swift
│   │   ├── Statistics/
│   │   │   ├── Views/
│   │   │   │   ├── StatisticsView.swift
│   │   │   │   ├── PracticeStatsView.swift
│   │   │   │   ├── PredictionCardView.swift
│   │   │   │   └── Charts/
│   │   │   │       ├── WeekdayChartView.swift
│   │   │   │       └── MonthlyChartView.swift
│   │   │   └── ViewModels/
│   │   │       └── StatisticsViewModel.swift
│   │   ├── History/
│   │   │   ├── Views/
│   │   │   │   ├── HistoryListView.swift
│   │   │   │   └── HistoryRowView.swift
│   │   │   └── ViewModels/
│   │   │       └── HistoryViewModel.swift
│   │   ├── Reminders/
│   │   │   ├── Views/
│   │   │   │   ├── RemindersListView.swift
│   │   │   │   └── AddReminderView.swift
│   │   │   └── ViewModels/
│   │   │       └── RemindersViewModel.swift
│   │   └── Settings/
│   │       ├── Views/
│   │       │   ├── SettingsView.swift
│   │       │   └── ExportImportView.swift
│   │       └── ViewModels/
│   │           └── SettingsViewModel.swift
│   ├── Components/
│   │   ├── ProgressBar/
│   │   │   ├── LotusProgressView.swift
│   │   │   ├── MalaProgressView.swift
│   │   │   └── ProgressBarStyle.swift
│   │   ├── MilestoneAlertView.swift
│   │   ├── PracticeIconView.swift
│   │   └── EmptyStateView.swift
│   └── Resources/
│       ├── Assets.xcassets/
│       │   ├── Colors/
│       │   ├── Images/
│       │   └── PracticeIcons/
│       ├── Sounds/
│       │   ├── click.wav
│       │   ├── bell.wav
│       │   ├── singing_bowl.wav
│       │   └── gong.wav
│       ├── Localizable.xcstrings
│       └── PredefinedPractices.json
├── NyndroTests/
└── NyndroUITests/
```

---

## 3. Model danych

### Practice.swift

```swift
@Model
final class Practice {
    @Attribute(.unique) var id: UUID
    var name: String
    var descriptionText: String
    var imageName: String               // SF Symbol lub custom asset
    var colorId: String                 // Klucz do PracticeColors
    var progress: Int                   // Aktualna liczba powtórzeń
    var maxRepetition: Int              // Cel (np. 111111)
    var defaultRepetition: Int          // Domyślna wartość +X (108)
    var isActive: Bool
    var isPredefined: Bool              // Czy z listy predefiniowanych
    var createdAt: Date
    var order: Int                      // Kolejność na liście
    
    @Relationship(deleteRule: .cascade, inverse: \HistoryEntry.practice)
    var history: [HistoryEntry] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Reminder.practice)
    var reminders: [Reminder] = []
    
    // Computed properties
    var progressPercentage: Double {
        guard maxRepetition > 0 else { return 0 }
        return min(Double(progress) / Double(maxRepetition), 1.0)
    }
    
    var lastPracticeDate: Date? {
        history.max(by: { $0.practiceDate < $1.practiceDate })?.practiceDate
    }
    
    var isCompleted: Bool {
        progress >= maxRepetition
    }
}
```

### HistoryEntry.swift

```swift
@Model
final class HistoryEntry {
    @Attribute(.unique) var id: UUID
    var practice: Practice?
    var progressSnapshot: Int           // Stan po dodaniu
    var repetitionAdded: Int            // Ile dodano w tej sesji
    var practiceDate: Date
    var note: String?                   // Opcjonalna notatka
    var sessionDuration: TimeInterval?  // Czas trwania sesji (opcjonalny)
}
```

### Reminder.swift

```swift
@Model
final class Reminder {
    @Attribute(.unique) var id: UUID
    var practice: Practice?
    var scheduledDate: Date
    var repeatType: RepeatType
    var isActive: Bool
    var notificationId: String          // ID dla UNUserNotificationCenter
}

enum RepeatType: Int, Codable {
    case none = 0
    case daily = 1
    case weekly = 2
    case monthly = 3
    
    var displayName: String {
        switch self {
        case .none: return String(localized: "reminder.repeat.none")
        case .daily: return String(localized: "reminder.repeat.daily")
        case .weekly: return String(localized: "reminder.repeat.weekly")
        case .monthly: return String(localized: "reminder.repeat.monthly")
        }
    }
}
```

### UserSettings.swift

```swift
@Model
final class UserSettings {
    var id: UUID
    var progressBarStyle: ProgressBarStyle
    var counterSound: CounterSound
    var hapticStyle: HapticStyle
    var keepScreenAwake: Bool
    var hasCompletedOnboarding: Bool
    var preferredLanguage: String?      // nil = system default
    
    init() {
        self.id = UUID()
        self.progressBarStyle = .lotus
        self.counterSound = .none
        self.hapticStyle = .medium
        self.keepScreenAwake = true
        self.hasCompletedOnboarding = false
        self.preferredLanguage = nil
    }
}

enum ProgressBarStyle: String, Codable, CaseIterable {
    case lotus = "lotus"
    case mala = "mala"
    
    var displayName: String {
        switch self {
        case .lotus: return String(localized: "settings.progress_style.lotus")
        case .mala: return String(localized: "settings.progress_style.mala")
        }
    }
    
    var icon: String {
        switch self {
        case .lotus: return "leaf.fill"
        case .mala: return "circle.dotted"
        }
    }
}

enum CounterSound: String, Codable, CaseIterable {
    case none = "none"
    case click = "click"
    case bell = "bell"
    case singingBowl = "singing_bowl"
    case gong = "gong"
    
    var displayName: String {
        switch self {
        case .none: return String(localized: "settings.sound.none")
        case .click: return String(localized: "settings.sound.click")
        case .bell: return String(localized: "settings.sound.bell")
        case .singingBowl: return String(localized: "settings.sound.singing_bowl")
        case .gong: return String(localized: "settings.sound.gong")
        }
    }
    
    var fileName: String? {
        switch self {
        case .none: return nil
        default: return rawValue
        }
    }
}

enum HapticStyle: String, Codable, CaseIterable {
    case none = "none"
    case light = "light"
    case medium = "medium"
    case heavy = "heavy"
    
    var displayName: String {
        switch self {
        case .none: return String(localized: "settings.haptic.none")
        case .light: return String(localized: "settings.haptic.light")
        case .medium: return String(localized: "settings.haptic.medium")
        case .heavy: return String(localized: "settings.haptic.heavy")
        }
    }
}
```

---

## 4. Kolorystyka i Dark Mode

### Kolory UI (Light + Dark)

| Element | Light Mode | Dark Mode |
|---------|------------|-----------|
| Background | `#FAFAFA` | `#121212` |
| Card Background | `#FFFFFF` | `#1E1E1E` |
| Secondary Background | `#F5F5F5` | `#2D2D2D` |
| Text Primary | `#1A1A1A` | `#FAFAFA` |
| Text Secondary | `#666666` | `#A0A0A0` |
| Accent | `#FF9933` | `#FFB366` |
| Success | `#4CAF50` | `#66BB6A` |
| Warning | `#FF9800` | `#FFB74D` |
| Error | `#F44336` | `#EF5350` |
| Progress Empty | `#E0E0E0` | `#3D3D3D` |
| Lotus Water | `#E3F2FD` | `#1A237E` (30% opacity) |
| Lotus Stem | `#2E7D32` | `#4CAF50` |

### Kolory praktyk

| Praktyka | Light Mode | Dark Mode | Symbolika |
|----------|------------|-----------|-----------|
| Schronienie | `#5B8FB9` | `#7BA3C9` | Spokojny błękit - ochrona |
| Bodhicitta | `#E85D75` | `#F07D91` | Ciepły róż - współczucie |
| Wadżrasattwa | `#9B72CF` | `#B08DE0` | Fiolet - oczyszczenie |
| Amitabha | `#FF6B35` | `#FF8555` | Pomarańcz - światło |
| Mandala | `#D4AF37` | `#E5C454` | Złoto - ofiarowanie |
| Guru Joga | `#FF9933` | `#FFB366` | Saffron - tradycja |
| Czenrezig | `#4ECDC4` | `#6FE0D8` | Turkus - współczucie |
| Własna | `#6B7280` | `#9CA3AF` | Neutralna szarość |

---

## 5. Ikony praktyk

| Praktyka | SF Symbol | Alternatywa |
|----------|-----------|-------------|
| Schronienie | `shield.fill` | 3 zagnieżdżone koła |
| Bodhicitta | `heart.circle.fill` | Serce z promieniami |
| Wadżrasattwa | `drop.fill` | Diament/wadżra |
| Amitabha | `sun.horizon.fill` | Zachodzące słońce |
| Mandala | `circle.grid.3x3.fill` | Koncentryczne koła |
| Guru Joga | `link.circle.fill` | Połączone koła |
| Czenrezig | `hands.sparkles.fill` | Dłonie w modlitwie |
| Własna praktyka | `plus.circle.fill` | — |

---

## 6. Custom Progress Bars

### LotusProgressView (domyślny)

Lotos rozkwitający symbolizujący ścieżkę praktykującego - wyrasta z błota ku światłu.

**Elementy:**
- 8 płatków (każdy = 12.5% postępu)
- Łodyga rosnąca wraz z postępem
- Woda/podstawa z subtleną animacją
- Rdzeń wypełniający się gradientem
- Kolor dopasowany do praktyki

**Etapy rozkwitu:**
- 0-12%: Pączek
- 13-25%: Pękający pączek
- 26-50%: Połowa otwarta
- 51-75%: 3/4 rozkwitu
- 76-100%: Pełny rozkwit

**Animacje:**
- Pulse na aktualnym płatku przy dodaniu
- Shimmer przy ukończeniu płatka
- Celebracja przy 100%

### MalaProgressView (alternatywa)

Tradycyjna buddyjska mala z 108 koralikami.

**Elementy:**
- 108 koralików w okręgu
- Guru bead (główny koralik) na dole
- Licznik w środku
- Kolor dopasowany do praktyki

**Animacje:**
- Koralik "zapala się" przy dodaniu
- Pulse na guru bead przy pełnym okrążeniu

---

## 7. Ekrany aplikacji

### Nawigacja (TabView)

```
TabView
├── Tab 1: Praktyki (PracticeListView)
├── Tab 2: Statystyki (StatisticsView)
├── Tab 3: Historia (HistoryListView)
└── Tab 4: Ustawienia (SettingsView)
```

### Lista praktyk
- Karty praktyk z progress barem
- Quick-add button (+X) na każdej karcie
- Swipe left: Usuń
- Swipe right: Edytuj
- FAB: Dodaj praktykę
- Pull-to-refresh (przyszły sync)

### Szczegóły praktyki
- Duży progress bar (Lotus/Mala)
- Pełne statystyki
- Przycisk "Rozpocznij sesję"
- Historia ostatnich sesji
- Edycja praktyki

### Statystyki
- Picker wyboru praktyki
- Karta predykcji (zakres dat)
- Średnie: dzienne/tygodniowe/miesięczne
- Wykres dni tygodnia (Swift Charts)
- Wykres miesięczny (Swift Charts)

### Historia
- Grupowanie po dniach
- Filtry: praktyka, zakres dat
- Możliwość edycji/usunięcia wpisu

### Ustawienia
- Styl progress bara (Lotus/Mala)
- Dźwięk counter
- Haptic feedback
- Przypomnienia
- Export/Import danych
- O aplikacji

---

## 8. Onboarding

5 ekranów dla nowych użytkowników:

| # | Tytuł | Opis | Grafika |
|---|-------|------|---------|
| 1 | Powitanie | "Twój towarzysz na ścieżce praktyk wstępnych" | Logo + lotos |
| 2 | Śledzenie postępu | "Dodawaj powtórzenia, obserwuj postęp" | Progress bar |
| 3 | Tryb zliczania | "Dotknij ekran podczas praktyki" | Counter |
| 4 | Predykcja | "Zobacz kiedy ukończysz praktykę" | Wykres |
| 5 | Powiadomienia | "Nie zapomnij o praktyce" | Bell + CTA |

---

## 9. Tryb zliczania (Counter Mode)

Pełnoekranowy widok do zliczania podczas praktyki.

**Funkcje:**
- Tap anywhere = +X (konfigurowalne: +1, +21, +108, custom)
- Duży licznik centralnie
- Dźwięk przy tap (opcjonalny)
- Haptic feedback (opcjonalny)
- Keep screen awake (opcjonalny)
- Przycisk zakończenia sesji

**Po zakończeniu:**
- Podsumowanie sesji
- Opcja dodania notatki
- Sprawdzenie milestones
- Animacja celebracji (przy osiągnięciu)

---

## 10. Dźwięki i Haptic Feedback

### Dźwięki

| ID | EN | PL | DE |
|----|----|----|-----|
| none | None | Brak | Keine |
| click | Click | Kliknięcie | Klick |
| bell | Bell | Dzwonek | Glocke |
| singing_bowl | Singing Bowl | Misa tybetańska | Klangschale |
| gong | Gong | Gong | Gong |

### Haptic

| ID | EN | PL | DE |
|----|----|----|-----|
| none | None | Brak | Keine |
| light | Light | Lekki | Leicht |
| medium | Medium | Średni | Mittel |
| heavy | Strong | Mocny | Stark |

---

## 11. Algorytm predykcji

### Kluczowe cechy

1. **Trzy wartości:**
   - Optymistyczna (top 25% tempo)
   - Najbardziej prawdopodobna (ważona średnia)
   - Pesymistyczna (z uwzględnieniem przerw)

2. **Ważenie danych:**
   - Nowsze dane = większa waga
   - Decay factor: `weight = 1 / (1 + daysAgo / 30)`

3. **Reset po długiej przerwie:**
   - Przerwa > 180 dni = statystyki liczone od nowa

4. **Poziomy pewności:**
   - `insufficient`: < 7 dni danych
   - `low`: 7-14 dni
   - `medium`: 15-30 dni
   - `high`: > 30 dni + regularna praktyka

### Wynik predykcji

```swift
struct PredictionResult {
    let mostLikelyDate: Date
    let mostLikelyDays: Int
    let optimisticDate: Date
    let pessimisticDate: Date
    let confidence: ConfidenceLevel
    let basedOnDays: Int
}
```

---

## 12. System milestones

### Typy osiągnięć

| Typ | Warunek | Celebracja |
|-----|---------|------------|
| Personal Best | Pobity rekord dzienny | Level 2 |
| Streak 7 | 7 dni z rzędu | Level 2 |
| Streak 21 | 21 dni z rzędu | Level 2 |
| Streak 30 | 30 dni z rzędu | Level 3 |
| Streak 100 | 100 dni z rzędu | Level 3 |
| 25% Complete | 25% praktyki | Level 1 |
| 50% Complete | 50% praktyki | Level 3 |
| 75% Complete | 75% praktyki | Level 1 |
| 90% Complete | 90% praktyki | Level 2 |
| Completed | 100% praktyki | Level 3 |

### Poziomy celebracji

- **Level 1**: Subtle animation + haptic
- **Level 2**: Medium animation + sound + haptic
- **Level 3**: Full celebration (confetti, sound, strong haptic)

---

## 13. Lokalizacja

### Wspierane języki

- English (en) - domyślny
- Polski (pl)
- Deutsch (de)

### Struktura

Plik `Localizable.xcstrings` z kluczami:

```
app.*                 - Ogólne teksty aplikacji
practice.*            - Teksty związane z praktykami
counter.*             - Tryb zliczania
statistics.*          - Statystyki
history.*             - Historia
settings.*            - Ustawienia
reminder.*            - Przypomnienia
milestone.*           - Osiągnięcia
onboarding.*          - Onboarding
error.*               - Komunikaty błędów
```

---

## 14. Export/Import

### Formaty

- **JSON**: Pełny backup z możliwością importu
- **CSV**: Historia do analizy (tylko export)

### JSON Schema

```json
{
  "version": "1.0",
  "exportDate": "2024-01-15T10:30:00Z",
  "practices": [...],
  "history": [...],
  "reminders": [...],
  "settings": {...}
}
```

### Flow

**Export:**
1. Wybór formatu (JSON/CSV)
2. Generowanie pliku
3. Share sheet (AirDrop, Mail, Files, iCloud)

**Import:**
1. Wybór pliku JSON
2. Podgląd zawartości
3. Opcje: zastąp wszystko / połącz
4. Potwierdzenie

---

## 15. Plan implementacji

### Faza 1: Fundament (Tydzień 1-2)

- [ ] Utworzenie projektu Xcode
- [ ] Konfiguracja SwiftData
- [ ] Modele danych (Practice, HistoryEntry, Reminder, UserSettings)
- [ ] System kolorów (ThemeColors, PracticeColors)
- [ ] Konfiguracja lokalizacji (EN/PL/DE)
- [ ] Podstawowa nawigacja TabView
- [ ] Constants i Extensions

### Faza 2: Onboarding + Lista praktyk (Tydzień 3-4)

- [ ] OnboardingView (5 ekranów)
- [ ] OnboardingViewModel
- [ ] PracticeListView
- [ ] PracticeCardView
- [ ] AddPracticeView (predefined + custom)
- [ ] EditPracticeView
- [ ] PracticeService
- [ ] PredefinedPractices.json

### Faza 3: Progress Bars (Tydzień 5-6)

- [ ] LotusProgressView
- [ ] Animacje lotosu
- [ ] MalaProgressView
- [ ] Animacje mali
- [ ] ProgressBarStyle selector
- [ ] Integracja z PracticeDetailView

### Faza 4: Counter Mode (Tydzień 7-8)

- [ ] CounterView
- [ ] CounterViewModel
- [ ] CounterSettingsSheet
- [ ] SoundService
- [ ] HapticService
- [ ] MilestoneService
- [ ] MilestoneAlertView
- [ ] Pliki dźwiękowe

### Faza 5: Statystyki i Predykcja (Tydzień 9-10)

- [ ] StatisticsService
- [ ] PredictionService
- [ ] StatisticsView
- [ ] PredictionCardView
- [ ] WeekdayChartView (Swift Charts)
- [ ] MonthlyChartView (Swift Charts)
- [ ] Logika resetu po 6 miesiącach

### Faza 6: Historia i Przypomnienia (Tydzień 11)

- [ ] HistoryListView
- [ ] HistoryRowView
- [ ] HistoryViewModel
- [ ] Filtry historii
- [ ] RemindersListView
- [ ] AddReminderView
- [ ] NotificationService
- [ ] Obsługa powtarzających się przypomnień

### Faza 7: Export/Import i Polish (Tydzień 12)

- [ ] ExportService (JSON, CSV)
- [ ] ImportService
- [ ] ExportImportView
- [ ] SettingsView
- [ ] Dark mode fine-tuning
- [ ] Pełna lokalizacja wszystkich tekstów
- [ ] Error handling
- [ ] Empty states
- [ ] Testy jednostkowe
- [ ] Testy UI

---

## Appendix A: Predefiniowane praktyki

```json
[
  {
    "id": "refuge",
    "colorId": "refuge",
    "imageName": "shield.fill",
    "maxRepetition": 11000,
    "defaultRepetition": 108,
    "name": {
      "en": "Refuge",
      "pl": "Schronienie",
      "de": "Zuflucht"
    },
    "description": {
      "en": "Taking refuge in Buddha, Dharma, Sangha",
      "pl": "Przyjmowanie schronienia w Buddzie, Dharmie, Sandze",
      "de": "Zuflucht zu Buddha, Dharma, Sangha nehmen"
    }
  },
  {
    "id": "bodhicitta",
    "colorId": "bodhicitta",
    "imageName": "heart.circle.fill",
    "maxRepetition": 111111,
    "defaultRepetition": 108,
    "name": {
      "en": "Refuge & Bodhicitta",
      "pl": "Schronienie i Bodhicitta",
      "de": "Zuflucht & Bodhicitta"
    },
    "description": {
      "en": "Refuge with enlightened attitude for all beings",
      "pl": "Schronienie z postawą oświeconą dla wszystkich istot",
      "de": "Zuflucht mit erleuchteter Haltung für alle Wesen"
    }
  },
  {
    "id": "vajrasattva",
    "colorId": "vajrasattva",
    "imageName": "drop.fill",
    "maxRepetition": 111111,
    "defaultRepetition": 108,
    "name": {
      "en": "Vajrasattva",
      "pl": "Wadżrasattwa",
      "de": "Vajrasattva"
    },
    "description": {
      "en": "Purification practice with 100-syllable mantra",
      "pl": "Praktyka oczyszczania z mantrą 100 sylab",
      "de": "Reinigungspraxis mit 100-Silben-Mantra"
    }
  },
  {
    "id": "amitabha",
    "colorId": "amitabha",
    "imageName": "sun.horizon.fill",
    "maxRepetition": 100000,
    "defaultRepetition": 108,
    "name": {
      "en": "Amitabha",
      "pl": "Amitabha",
      "de": "Amitabha"
    },
    "description": {
      "en": "Buddha of Infinite Light practice",
      "pl": "Praktyka Buddy Nieskończonego Światła",
      "de": "Praxis des Buddha des Unendlichen Lichts"
    }
  },
  {
    "id": "mandala",
    "colorId": "mandala",
    "imageName": "circle.grid.3x3.fill",
    "maxRepetition": 111111,
    "defaultRepetition": 108,
    "name": {
      "en": "Mandala Offering",
      "pl": "Ofiarowanie Mandali",
      "de": "Mandala-Opferung"
    },
    "description": {
      "en": "Offering the universe to accumulate merit",
      "pl": "Ofiarowanie wszechświata dla akumulacji zasługi",
      "de": "Darbringung des Universums zur Ansammlung von Verdienst"
    }
  },
  {
    "id": "guru_yoga",
    "colorId": "guru_yoga",
    "imageName": "link.circle.fill",
    "maxRepetition": 111111,
    "defaultRepetition": 108,
    "name": {
      "en": "Guru Yoga",
      "pl": "Guru Joga",
      "de": "Guru Yoga"
    },
    "description": {
      "en": "Devotion practice to the spiritual teacher",
      "pl": "Praktyka oddania wobec duchowego nauczyciela",
      "de": "Hingabepraxis an den spirituellen Lehrer"
    }
  },
  {
    "id": "chenrezig",
    "colorId": "chenrezig",
    "imageName": "hands.sparkles.fill",
    "maxRepetition": 111111,
    "defaultRepetition": 108,
    "name": {
      "en": "Chenrezig",
      "pl": "Czenrezig",
      "de": "Chenrezig"
    },
    "description": {
      "en": "Bodhisattva of Compassion - Om Mani Padme Hum",
      "pl": "Bodhisattwa Współczucia - Om Mani Padme Hum",
      "de": "Bodhisattva des Mitgefühls - Om Mani Padme Hum"
    }
  },
  {
    "id": "custom",
    "colorId": "custom",
    "imageName": "plus.circle.fill",
    "maxRepetition": 111111,
    "defaultRepetition": 108,
    "name": {
      "en": "Custom Practice",
      "pl": "Własna praktyka",
      "de": "Eigene Praxis"
    },
    "description": {
      "en": "Add your own practice",
      "pl": "Dodaj własną praktykę",
      "de": "Füge deine eigene Praxis hinzu"
    }
  }
]
```

---

## Appendix B: Kontakt i licencja

**Autor:** Marek Piotrowski  
**Projekt:** Nyndro iOS  
**Licencja:** Prywatna  

---

*Dokument wygenerowany: Grudzień 2024*
