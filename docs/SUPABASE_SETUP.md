# Supabase Setup & Authentication Guide

## Overview

Dieses Projekt nutzt **Supabase** als Backend für:
- ✅ Benutzer-Authentifizierung (Email/Password)
- ✅ Cloud-Daten-Speicherung (LED Projekte, DMX Profile, Fixtures)
- ✅ Row-Level Security (RLS) für Datenschutz
- ✅ Real-time Subscriptions (optional)
- ✅ Automatische User-Profile-Erstellung

---

## Schritt 1: Supabase Projekt Erstellen

### 1.1 Projekt anlegen
1. Gehe zu https://app.supabase.com
2. Klicke "New Project"
3. Gib einen Namen ein (z.B. "led-wand-rechner")
4. Wähle deine Datenbankregion (z.B. EU - Dublin)
5. Speichere das **Database Password** sicher

### 1.2 Projektkonfiguration
Nach der Erstellung:
- Kopiere deine **Project URL** (format: `https://xxxxx.supabase.co`)
- Kopiere deinen **Anon Key** (für öffentlichen Zugriff)
- Kopiere deinen **Service Role Key** (nur für Backend!)

---

## Schritt 2: Datenbank Schema Erstellen

### 2.1 SQL Editor öffnen
1. Im Supabase Dashboard: gehe zu **SQL Editor**
2. Klicke **New Query**

### 2.2 DDL ausführen
Kopiere die gesamte SQL aus [supabase_ddl.sql](../docs/supabase_ddl.sql) und führe sie aus:

```bash
# Alternative: Mit CLI
supabase db push
```

**Was wird erstellt:**
- 8 Tabellen (Brands, Models, Projects, DMX Profiles, Patches, Fixtures, etc.)
- 30+ Indizes für Performance
- Row-Level Security Policies
- Automatische User-Profile beim Sign-up

### 2.3 Seed-Daten einladen
1. Gehe zur **SQL Editor**
2. Führe [supabase_seed_data.sql](../docs/supabase_seed_data.sql) aus

**Was wird eingefügt:**
- 11 LED-Hersteller
- 26 LED-Modelle (Infiiled, ROE, Elation, etc.)

---

## Schritt 3: Authentication Konfigurieren

### 3.1 Authentifizierungsmethoden aktivieren
1. Gehe zu **Auth** → **Providers**
2. Deaktiviere **Google/GitHub OAuth** (optional)
3. Stelle sicher dass **Email** aktiviert ist (Standard)

### 3.2 Email-Vorlagen anpassen (Optional)
1. Gehe zu **Auth** → **Email Templates**
2. Bearbeite:
   - Welcome Email
   - Password Reset Email
   - Confirm Email

### 3.3 App-Einstellungen
1. Gehe zu **Auth** → **URL Configuration**
2. Setze **Site URL** (wo deine App gehostet wird):
   ```
   http://localhost:3000          # Entwicklung
   https://deine-domain.com       # Production
   ```
3. Füge **Redirect URLs** hinzu:
   ```
   http://localhost:3000/auth     # Entwicklung
   https://deine-domain.com/auth  # Production
   ```

---

## Schritt 4: Flutter App Konfigurieren

### 4.1 Umgebungsvariablen setzen

Erstelle `lib/.env` (oder verwende `flutter_dotenv`):

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
```

### 4.2 pubspec.yaml aktualisieren

```yaml
dependencies:
  supabase_flutter: ^2.0.0
  connectivity_plus: ^6.0.0
  flutter_dotenv: ^5.1.0
```

### 4.3 app_main.dart (main.dart) initialisieren

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: 'lib/.env');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(MyApp());
}
```

### 4.4 AuthService nutzen

```dart
import 'package:provider/provider.dart';
import 'lib/services/auth_service.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService()..initialize(),
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          if (!authService.isInitialized) {
            return CircularProgressIndicator();
          }
          
          if (authService.isAuthenticated) {
            return MainScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
```

---

## Schritt 5: Row-Level Security (RLS) verstehen

### 5.1 Wie RLS funktioniert

Beispiel: `led_projects` Tabelle
```sql
-- Benutzer können NUR ihre eigenen Projekte sehen
SELECT * FROM led_projects 
WHERE user_id = current_user_id();
```

**Policies:**
- ✅ SELECT: Benutzer sieht eigene + geteilte Projekte
- ✅ INSERT: Benutzer kann nur für sich selbst erstellen
- ✅ UPDATE: Benutzer kann nur eigene Projekte ändern
- ✅ DELETE: Benutzer kann nur eigene Projekte löschen

### 5.2 RLS Status prüfen
Im Dashboard:
1. **Authentication** → **Policies**
2. Schau ob alle Tabellen grün (enabled) sind
3. Überprüfe die Policies für deine Tabelle

---

## Schritt 6: Real-time Subscriptions (Optional)

### 6.1 Real-time aktivieren
1. Im Dashboard: **Database** → **Replication**
2. Schalte "Realtime" für diese Tabellen ein:
   - `led_projects`
   - `dmx_patches`
   - `dmx_fixtures`

### 6.2 In der App nutzen

```dart
final subscription = supabase
  .from('led_projects')
  .on(RealtimeListenTypes.all, (payload) {
    print('Change received: ${payload.eventType}');
  })
  .subscribe();

// Cleanup
await subscription.cancel();
```

---

## Schritt 7: Offline-First Sync

### 7.1 Wie es funktioniert
1. **Offline**: Daten werden in **Hive** (lokal) gespeichert
2. **Online**: Daten werden automatisch zu **Supabase** synchronisiert
3. **Conflict**: Last-Write-Wins Strategy

### 7.2 Sync Service

```dart
final syncService = SupabaseSyncService();

// Manuell sync
await syncService.syncAll();

// Status prüfen
print(syncService.isOnline);      // bool
print(syncService.isSyncing);     // bool
print(syncService.lastSyncTime);  // DateTime?
```

---

## Schritt 8: User Statistiken

### 8.1 Verfügbare RPC Functions

```dart
final authService = context.read<AuthService>();

// LED Projekte zählen
final stats = await authService.getUserStats();
print('LED Projekte: ${stats['ledProjectsCount']}');
print('DMX Profile: ${stats['dmxProfilesCount']}');
print('Fixtures: ${stats['fixturesCount']}');
```

---

## Troubleshooting

### Problem: "Invalid API Key"
**Lösung**: Überprüfe dass du den **Anon Key** (nicht Service Role Key) nutzt

### Problem: "RLS policy missing"
**Lösung**: Führe die DDL erneut aus - überprüfe in Dashboard → Auth → Policies

### Problem: "Profile creation failed"
**Lösung**: Der Trigger sollte auto-erstellen. Überprüfe:
```sql
SELECT * FROM public.user_profiles WHERE id = 'YOUR_USER_ID';
```

### Problem: "Can't sign in"
**Lösung**: 
1. Überprüfe Email bestätigung (Dashboard → Auth → Users)
2. Überprüfe Rate-Limiting (Dashboard → Auth → Rate Limiting)

---

## Sicherheit Best Practices

### ✅ DO:
- ✅ Nutze **Anon Key** nur in der Client-App
- ✅ Aktiviere RLS auf allen Tabellen
- ✅ Nutze Row-Level Security Policies
- ✅ Speichere Service Role Key im Backend
- ✅ Aktiviere HTTPS nur in Production
- ✅ Setze CORS URLs auf deine Domain

### ❌ DON'T:
- ❌ Committe deinen API Key zu Git
- ❌ Nutze Service Role Key in der Client-App
- ❌ Deaktiviere RLS (außer für öffentliche Daten)
- ❌ Speichere Passwörter in Preferences
- ❌ Nutze `select()` ohne Filter auf sensiblen Tabellen

---

## Nächste Schritte

1. ✅ Führe DDL aus (Schritt 2)
2. ✅ Konfiguriere Flutter App (Schritt 4)
3. ✅ Teste mit LoginScreen
4. ✅ Überprüfe RLS Policies (Schritt 5)
5. ✅ Implementiere Offline Sync (Schritt 7)
6. ✅ Teste mit echten Daten

---

## Weitere Ressourcen

- 📚 [Supabase Docs](https://supabase.com/docs)
- 🔐 [Auth Guide](https://supabase.com/docs/guides/auth)
- 🔒 [RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- 📱 [Flutter Integration](https://supabase.com/docs/reference/flutter)

---

**Benötigst du Hilfe?** Schreib mich an! 🚀
