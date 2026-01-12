# 🚀 QUICK START GUIDE

Schnelle Anleitung zum Starten der LED Wand Rechner App.

## ⚡ Schritt 1: Flutter installieren (falls noch nicht geschehen)

```bash
# Besuche https://flutter.dev/docs/get-started/install
# und folge den Anweisungen für dein Betriebssystem

# Verifiziere Installation
flutter --version
dart --version
```

## 🔑 Schritt 2: Supabase Projekt erstellen

1. Gehe zu https://supabase.com
2. Klicke "New Project"
3. Wähle eine Region (z.B. Europe - Frankfurt)
4. Merke dir die **Project URL** und **Anon Key**

## 🗄️ Schritt 3: Datenbank einrichten

1. Öffne dein Supabase Projekt Dashboard
2. Gehe zu **SQL Editor**
3. Erstelle neue Query
4. Kopiere kompletten Inhalt aus `supabase_ddl.sql`
5. Führe aus → Sollte ohne Fehler durchlaufen
6. Wiederhole für `supabase_seed_data.sql`

**Verifizierung:**
- Gehe zu **Table Editor**
- Du solltest Tabellen sehen: `led_brands`, `led_models`, `projects`, etc.
- In `led_brands` sollten ~11 LED-Hersteller sichtbar sein

## 🔐 Schritt 4: Credentials in App eintragen

Öffne `lib/main.dart`:

```dart
// FINDE DIESE ZEILEN (oben in der Datei):
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

// ERSETZE MIT DEINEN WERTEN:
const String supabaseUrl = 'https://abc123.supabase.co';  // Dein Project URL
const String supabaseAnonKey = 'eyJ...';  // Dein Anon Key
```

Wo finde ich diese Werte?
- **Project URL:** Supabase Dashboard → Settings → API → Project URL
- **Anon Key:** Supabase Dashboard → Settings → API → anon key

## 📦 Schritt 5: Dependencies installieren

```bash
cd /path/to/led-wand-rechner
flutter pub get
```

## ▶️ Schritt 6: App starten

```bash
# Web (Chrome Browser)
flutter run -d chrome

# Alternativ: iOS Simulator
flutter run -d ios

# Alternativ: Android Emulator
flutter run -d android
```

## ✅ Schritt 7: Funktioniert es?

1. App sollte mit leerer Projektliste starten
2. Klicke **[Neues Projekt]** Button
3. Gib einen Namen ein (z.B. "Meine erste LED Wand")
4. Wähle eine LED-Marke (z.B. "Infiiled")
5. Wähle ein Modell (z.B. "CF5")
6. Gib Breite & Höhe ein (z.B. 1000mm × 600mm)
7. **Du solltest live Berechnungen sehen!**

## 🐛 Häufige Probleme

### ❌ "flutter command not found"
```bash
# Stelle sicher, Flutter bin im PATH ist
export PATH="$PATH:$HOME/flutter/bin"
```

### ❌ "Supabase connection failed"
- Prüfe, dass URL/Key korrekt in `main.dart` sind
- Prüfe deine Internetverbindung
- Supabase Projekt aktiv? (Prüfe im Dashboard)

### ❌ "No led_brands in database"
- Hast du `supabase_seed_data.sql` ausgeführt?
- Gehe zu Supabase Table Editor und prüfe `led_brands`

### ❌ "Build error for iOS/Android"
```bash
# Alles löschen und neu bauen
flutter clean
flutter pub get
flutter run
```

## 📱 Nächste Schritte

1. **Teste die App:**
   - Erstelle mehrere Projekte
   - Probiere verschiedene LED-Modelle
   - Wechsle zwischen Projekten
   - Sieh dir die Berechnungen an

2. **Authentifizierung testen:**
   - Öffne Drawer (Hamburger-Menü oben links)
   - Klicke "Anmelden"
   - Registriere mit Email/Password
   - Deine Projekte sollten in der Cloud synchronisiert werden

3. **Custom Models testen:**
   - Erstelle ein neues Projekt
   - Wähle "[+ Benutzerdefiniertes Modell]"
   - Gib Parameter ein
   - Speichern
   - Optional: Veröffentliche es als Community-Model

## 🎨 UI anpassen

**Design ändern:**
- Theme: `lib/ui/theme/app_theme.dart`
- Farben: `primaryColor`, `secondaryColor`, etc.

**Text ändern (Lokalisierung):**
- Deutsch: `assets/i18n/de.json`
- Englisch: `assets/i18n/en.json`

## 📊 Datenbank-Struktur verstehen

```
Benutzer (optional Login)
  ├─ Projects (mehrere pro Benutzer)
  │   ├─ selected_brand_id → LED_Brands
  │   ├─ selected_model_id → LED_Models
  │   └─ resultsJson (Berechnungen)
  ├─ Custom_Models (Benutzer-definierte LEDs)
  └─ Sync_Metadata (für Konflikt-Auflösung)

Öffentliche Daten (für alle zugänglich)
  ├─ LED_Brands (11 Hersteller)
  ├─ LED_Models (100+ Modelle)
  ├─ Model_Variants (RGB vs RGBW)
  └─ Community_Models (Benutzer-Modelle, öffentlich)
```

## 🔄 Offline-Modus testen

1. **Starte die App online** (mit Internetverbindung)
2. **Erstelle ein Projekt** mit Daten
3. **Schalte Internet aus** (Flugzeugmodus)
4. **App sollte noch funktionieren** – alle Berechnungen lokal!
5. **Schalte Internet wieder an** – App synchronisiert automatisch

## 🎉 Bereit zum Entwickeln?

Gratuliert! Die App ist jetzt voll funktionsfähig. Du kannst:

- ✅ Weitere Features hinzufügen
- ✅ LED-Modelle erweitern
- ✅ UI anpassen
- ✅ Für App Store / Play Store builden
- ✅ Mit Freunden teilen

## 📚 Weitere Ressourcen

- [Flutter Dokumentation](https://flutter.dev/docs)
- [Supabase Dokumentation](https://supabase.com/docs)
- [Provider State Management](https://pub.dev/packages/provider)
- [Hive Database](https://docs.hivedb.dev/)

---

**Viel Erfolg! 🚀**
