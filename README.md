# LED Wand Rechner – Flutter Cross-Platform App

Eine professionelle, plattformübergreifende Anwendung zur Berechnung und Verwaltung aller relevanten Parameter für LED-Wandinstallationen. Die App läuft auf **Web, iOS, Android, macOS und Windows** mit einer einzigen Codebase.

## 🎯 Features

- ✅ **Single-Page-Interface** – Alle Berechnungen auf einem Bildschirm
- ✅ **Live-Berechnungen** – Echtzeit-Updates bei Eingabeänderungen
- ✅ **Multi-Projekt-Management** – Speichern und Verwaltung mehrerer Projekte
- ✅ **Offline-First** – Vollständig offline funktional, optional Cloud-Sync
- ✅ **Cloud-Synchronisierung** – Nahtlose Supabase-Integration mit Hive-Caching
- ✅ **LED-Marken-Datenbank** – 11+ Hersteller (Infiiled, Nova, Linsn, etc.) mit hunderten Modellen
- ✅ **Benutzerdefinierte Modelle** – Erstelle custom LED-Module und teile sie in der Community
- ✅ **Mehrsprachigkeit** – Deutsch & Englisch von Anfang an
- ✅ **PDF/CSV-Export** – Erstelle professionelle Reports
- ✅ **Material Design 3** – Modern UI mit Dark Mode Support

## 📊 Berechnete Parameter

- **Pixeldichte (PPI)** – Pixel per Inch
- **Auflösung** – Gesamtpixel (Breite × Höhe)
- **Stromverbrauch** – Watt und Ampere
- **Helligkeit** – Geschätzte Lux-Werte
- **Kosten** – Modul + Installation + Service + Versand
- **Material-Gewicht** – Gesamtgewicht in kg
- **Wärmeerzeugung** – Watt
- **Fläche** – m²
- **Refresh-Rate** – Hz

## 🛠️ Tech Stack

| Layer | Technologie |
|-------|-------------|
| **Frontend** | Flutter 3.x + Material Design 3 |
| **State Management** | Provider |
| **Datenbank (lokal)** | Hive (offline-first) |
| **Backend** | Supabase (PostgreSQL + Auth + Realtime) |
| **Connectivity** | connectivity_plus |
| **i18n** | JSON-basiert (de, en) |
| **Export** | PDF + CSV |
| **Plattformen** | Web, iOS, Android, macOS, Windows |

## 🚀 Installation & Setup

### Voraussetzungen

- **Flutter SDK** (≥3.0.0) – [Installation](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (enthalten in Flutter)
- **Supabase-Projekt** – [Kostenlos erstellen](https://supabase.com)
- Für native Builds: Xcode (macOS/iOS), Android Studio, Visual Studio (Windows)

### 1. Flutter-Projekt klonen/herunterladen

```bash
cd /path/to/led-wand-rechner
```

### 2. Dependencies installieren

```bash
flutter pub get
```

### 3. Supabase-Projekt erstellen

1. Besuche [Supabase](https://supabase.com) und erstelle ein neues Projekt
2. Kopiere die **Project URL** und **Anon Key** aus den Projekteinstellungen

### 4. Supabase-Datenbank einrichten

1. Öffne die **SQL Editor** in Supabase Dashboard
2. Kopiere den Inhalt von `supabase_ddl.sql` und führe alle Queries aus
3. Kopiere den Inhalt von `supabase_seed_data.sql` und führe diese Queries aus (LED-Daten werden geladen)

### 5. Supabase-Credentials in der App eintragen

Öffne [lib/main.dart](lib/main.dart) und ersetze:

```dart
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

Mit deinen tatsächlichen Credentials:

```dart
const String supabaseUrl = 'https://xxxxx.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

### 6. App starten

**Web:**
```bash
flutter run -d chrome
```

**Android:**
```bash
flutter run -d android
```

**iOS:**
```bash
flutter run -d ios
```

**macOS:**
```bash
flutter run -d macos
```

**Windows:**
```bash
flutter run -d windows
```

## 📁 Projektstruktur

```
led-wand-rechner/
├── lib/
│   ├── main.dart                    # Entry Point
│   ├── models/
│   │   └── led_models.dart          # Datenmodelle
│   ├── services/
│   │   ├── local_database_service.dart
│   │   ├── supabase_sync_service.dart
│   │   ├── auth_service.dart
│   │   ├── led_calculation_service.dart
│   │   ├── localization_service.dart
│   │   └── hive_adapters.dart
│   ├── providers/
│   │   └── app_providers.dart       # State Management (Provider)
│   └── ui/
│       ├── screens/
│       │   └── main_screen.dart     # Hauptbildschirm (Single-Page)
│       ├── widgets/
│       │   ├── project_selector.dart
│       │   ├── led_input_form.dart
│       │   ├── results_panel.dart
│       │   ├── sync_status_indicator.dart
│       │   └── auth_drawer.dart
│       └── theme/
│           └── app_theme.dart
├── assets/
│   └── i18n/
│       ├── de.json                  # Deutsche Übersetzungen
│       └── en.json                  # Englische Übersetzungen
├── pubspec.yaml                     # Dependencies
├── supabase_ddl.sql                 # Datenbank-Schema
└── supabase_seed_data.sql           # LED-Daten für Seeding
```

## 🔐 Authentifizierung

Die App unterstützt **optionale** Authentifizierung:

- **Ohne Login** – Lokal speichern, alles funktioniert offline
- **Mit Login** – Cloud-Sync, Community-Modelle teilen, Multi-Device-Zugriff
- Login-Button ist im **Menü** (Hamburger-Icon oben links) verfügbar

### Supabase Auth konfigurieren

1. Gehe zu **Authentication > Providers** in Supabase
2. Aktiviere **Email Provider**
3. Konfiguriere optional OAuth (Google, GitHub, etc.)

## 💾 Offline-First Sync-Strategie

```
┌─────────────────┐
│  App startet    │
└────────┬────────┘
         │
      ┌──▼───┐
      │ Hive │ ◄─── Lokale Datenbank
      └──┬───┘
         │
      ┌──▼────────────┐
      │ Online Check? │
      └──┬─────┬──────┘
         │     │
        JA    NEIN
         │      │
      ┌──▼──┐   │
      │Sync │   │ Nur Lokal arbeiten
      │Cloud│   │ (transparent)
      └─────┘   │
         │      │
         └──┬───┘
            │
         ┌──▼───────┐
         │ App läuft │ ◄─── Unabhängig von Netzwerk
         └───────────┘
```

**Automatisches Syncing:**
- Lokal: Alle Änderungen sofort in Hive gespeichert
- Online: Automatisches Sync mit Supabase alle 30 Sekunden
- Konflikt-Auflösung: Last-write-wins Strategie

## 🌍 Multi-Language Support

Übersetzungen sind in `assets/i18n/` als JSON-Dateien definiert:

- **de.json** – Deutsch
- **en.json** – Englisch

Zur Verwendung in Code:

```dart
import 'services/localization_service.dart';

// Long form
localization.translate('projects.title')

// Short form
t('projects.title')

// Helper methods
localization.projectsTitle
localization.commonSave
```

Neue Übersetzungen hinzufügen:
1. Schlüssel in both `.json`-Dateien (de.json + en.json) hinzufügen
2. In Code mit `t('key')` oder `localization.translate('key')` verwenden

## 📝 LED-Modelle & Community-Models

### Vordefinierte Marken (11+)

- Infiiled (CF2.5, CF4, CF5, CF6, CF8)
- Nova (NovaStar-P1.25, P2, P3)
- Linsn (LS-IM, LS-OM)
- Unilumin (UliStar-UMS)
- ROE Visual (GEMINI, VANISH)
- Barco (NovaLED-1000)
- Pixelfly (PF-XL)
- Daktronics (SIGMA-LX)
- Watchfire (HD-Pro)
- Leyard (NPU2.5, NPU3.9)

### Custom Models erstellen

1. Wähle **[+ Benutzerdefiniertes Modell]** im Form
2. Fülle Namen, Pixel-Pitch, Stromverbrauch, Preis aus
3. **Speichern** – lokal gespeichert
4. Optional: **Veröffentlichen** – als Community-Model für andere freigeben

### Community Models teilen

```dart
// In Custom-Model-Details
await supabaseSyncService.publishCommunityModel(
  customModel: myCustomModel,
  description: "Mein tolles LED-Modul",
);
```

Community-Models sind automatisch öffentlich + bewertet.

## 🖨️ PDF-Export

```dart
// In results_panel.dart
final pdfData = await generatePDFReport(project, results);
await Printing.layoutPdf(
  onLayout: (PdfPageFormat format) async => pdfData,
);
```

Der Report enthält:
- Projektname & Datum
- LED-Marke/Modell
- Alle Parameter & Ergebnisse
- Kostenaufstellung
- Berechningsformeln (optional)

## 🔧 Problembehebung

### App startet nicht / Fehler beim Laden

**Problem:** `Supabase.instance.client` ist null

**Lösung:**
- Kontrolliere, dass `supabaseUrl` und `supabaseAnonKey` korrekt in `main.dart` gesetzt sind
- Stelle sicher, dass Supabase-Projekt aktiv ist (nicht gelöscht)

### Keine Marken/Modelle angezeigt

**Problem:** LED-Datenbank leer

**Lösung:**
1. Stelle sicher, dass `supabase_ddl.sql` komplett ausgeführt wurde
2. Führe `supabase_seed_data.sql` in SQL Editor aus
3. Prüfe in Supabase: **Table Editor > led_brands** – sollte 11 Marken anzeigen

### Offline-Sync funktioniert nicht

**Problem:** Daten werden nicht lokal gespeichert

**Lösung:**
- `connectivity_plus` benötigt Permissions. Prüfe Manifest/Info.plist
- Stelle sicher, dass Hive initialisiert ist: `await LocalDatabaseService().initialize()`

### Build-Fehler für iOS/Android

**iOS:**
```bash
cd ios
rm -rf Pods
cd ..
flutter pub get
flutter run -d ios
```

**Android:**
```bash
flutter clean
flutter pub get
flutter run -d android
```

## 📦 Build für Production

### Web
```bash
flutter build web --release
```
Deploy zu Firebase Hosting, Vercel, oder Netlify

### iOS
```bash
flutter build ios --release
# Öffne dann in Xcode für App Store Upload
open ios/Runner.xcworkspace
```

### Android
```bash
flutter build apk --release
# oder AAB für Play Store
flutter build appbundle --release
```

### macOS
```bash
flutter build macos --release
# Signieren für Mac App Store
```

### Windows
```bash
flutter build windows --release
```

## 🤝 Beitragen

Contributions sind willkommen! Bitte:

1. Fork das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/AmazingFeature`)
3. Commit Changes (`git commit -m 'Add AmazingFeature'`)
4. Push zum Branch (`git push origin feature/AmazingFeature`)
5. Öffne einen Pull Request

## 📄 Lizenz

MIT License – siehe [LICENSE](LICENSE) für Details

## 📞 Support

- Fragen? Öffne ein [GitHub Issue](https://github.com/JoKeks2023/led-wand-rechner/issues)
- Bugs? Bitte mit Repro-Schritten melden

---

**Made with ❤️ by JoKeks2023**

Aktualisiert: Januar 2026
