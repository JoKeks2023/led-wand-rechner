# Supabase DDL Migration Files

Diese Datei enthält die SQL zum Erstellen der kompletten Datenbankstruktur.

## Verwendung

1. **Option A: Manuell im Supabase Dashboard**
   - Gehe zu Supabase Dashboard → SQL Editor
   - Erstelle eine neue Query
   - Kopiere/füge den Inhalt ein (siehe unten)
   - Klicke "Execute"

2. **Option B: Mit Supabase CLI**
   ```bash
   supabase db push
   ```

## DDL Inhalte

Siehe [01_initial_led_dmx_schema.sql](#) für:
- ✅ Extensions (UUID, pgcrypto)
- ✅ 8 Tabellen (Brands, Models, Projects, DMX, etc.)
- ✅ 30+ Indizes
- ✅ Row-Level Security Policies
- ✅ Auth Trigger für Auto-Profil-Erstellung

Siehe [02_seed_led_brands_and_models.sql](#) für:
- ✅ 11 LED-Hersteller
- ✅ 26 LED-Modelle

Siehe [03_auth_triggers_and_functions.sql](#) für:
- ✅ Automatische User-Profile bei Sign-up
- ✅ Helper Functions (count_projects, count_profiles, etc.)
- ✅ Real-time Grant-Permissions

## Was wird erstellt?

### Tabellen (8)

| Tabelle | Zweck | RLS |
|---------|-------|-----|
| `user_profiles` | Benutzerprofile + Preferences | ✅ |
| `led_brands` | LED-Hersteller | ❌ Public |
| `led_models` | LED-Modelle | ❌ Public |
| `led_projects` | Benutzer LED-Projekte | ✅ |
| `custom_led_models` | Community LED-Modelle | ✅ |
| `dmx_profiles` | GrandMA Konfigurationen | ✅ |
| `dmx_patches` | DMX Patches (Projekte) | ✅ |
| `dmx_fixtures` | Individuelle DMX Fixtures | ✅ |
| `gdtf_fixtures` | GDTF Fixture-Datenbank | ❌ Public |
| `stage_settings` | Bühnen-Visualizer-Konfiguration | ✅ |
| `dmx_preferences` | DMX Benutzer-Einstellungen | ✅ |

### Indizes (30+)

Für beste Performance bei:
- User-ID Lookups
- Timestamps (Sortieren)
- Unique-Constraints
- Universe/Channel Kombinationen

### Row-Level Security

Implementiert nach diesem Muster:

```sql
-- Beispiel: LED Projects
-- User kann nur seine eigenen Projekte sehen
CREATE POLICY "Users can view their own LED projects"
  ON led_projects
  FOR SELECT
  USING (auth.uid() = user_id);

-- User kann Shared Projekte sehen
CREATE POLICY "Users can view shared LED projects"
  ON led_projects
  FOR SELECT
  USING (shared = TRUE);
```

Alle Policies sind benutzer-isoliert (keine Datenlecks).

### Auth Trigger

Wenn ein neuer User sich registriert:
1. ✅ `auth.users` Entry wird erstellt (Supabase)
2. ✅ `user_profiles` Entry wird AUTO-erstellt (unser Trigger)
3. ✅ Standard-Preferences werden gesetzt

```dart
// Automatisch nach Sign-up:
{
  'language': 'de',
  'theme': 'system',
  'notifications_enabled': true,
  'backup_enabled': true
}
```

## Troubleshooting

### Fehler: "Extension pgcrypto does not exist"

**Lösung:** Supabase erstellt diese automatisch. Falls fehlt:
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

### Fehler: "function handle_new_user does not exist"

**Lösung:** Stelle sicher, dass `03_auth_triggers_and_functions.sql` ausgeführt wurde

### Fehler: "RLS policy already exists"

**Lösung:** OK – mehrfaches Ausführen ist safe (hat `IF NOT EXISTS`)

### Keine LED-Daten angezeigt?

**Lösung:** Führe `02_seed_led_brands_and_models.sql` aus

## Seed-Daten

Insgesamt werden eingefügt:

### LED Brands (11)
1. Infiiled (CF2.5, CF4, CF5, CF6, CF8 Series)
2. ROE Visual (ViPixtile 5mm, 3.9mm)
3. Elation (Proteus Hybrid)
4. Chauvet (NEXUS Pro)
5. ADJ (ProPanel)
6. Martin Professional (LC-Serie)
7. High End Systems (Stagebar)
8. GLP (X-Ray)
9-11. Weitere

### LED Modelle (26)

**Infiiled Fokus:**
- ROE A Series (1.3mm, 2.6mm, 1.95mm variants)
- ROE P10 Series (Standard, Plus, Lite, Max)
- ROE TNT Series (4mm, 6mm)

Alle mit:
- ✅ Pixel-Pitch (mm)
- ✅ Max-Helligkeit (Nits)
- ✅ Stromverbrauch (W/m²)
- ✅ Typische Auflösungen (16:9)
- ✅ Use-Cases

## Weitere Migration Files

Falls du später mehr Tabellen brauchst, erstelle neue Files:

```
migrations/
├── 001_initial_led_dmx_schema.sql       ← Diese Datei
├── 002_seed_led_brands_and_models.sql
├── 003_auth_triggers_and_functions.sql
├── 004_gdtf_fixture_imports.sql         ← Future
├── 005_realtime_config.sql              ← Future
└── 006_backup_settings.sql              ← Future
```

Dann mit CLI:
```bash
supabase migration new <name>
# Bearbeite die Datei
supabase db push
```

## Performance-Tipps

1. ✅ Indizes sind bereits erstellt
2. ✅ RLS Policies sind optimiert
3. ✅ Foreign Keys mit CASCADE für Datenintegrität
4. ✅ JSONB für flexible Preferences

Bei vielen Fixtures verwende Pagination:
```sql
SELECT * FROM dmx_fixtures 
WHERE patch_id = $1 
LIMIT 50 OFFSET 0;
```

## Sicherheit

✅ All tables haben RLS enabled (außer Public wie LED Brands)
✅ User können nur ihre eigenen Daten sehen
✅ Shared/Community data ist explizit gekennzeichnet
✅ Admin-Keys sind für Backend nur (Service Role)

---

**Benötigst du Hilfe?** Schreib mich an! 📧
