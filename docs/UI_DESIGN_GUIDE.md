# 🎨 Modern UI Implementation Guide

## Overview
Die Anwendung nutzt Material Design 3 mit einer modernen, benutzerfreundlichen Schnittstelle.

## 🎯 Struktur

### Navigation
- **AppNavigationShell** (`app_navigation_shell.dart`) - Hauptnavigation mit Bottom Nav Bar
- 3 Haupttabs: LED, DMX, Stage
- DMX hat Sub-Navigation: Pult Manager + Settings

### Screens

#### 1. LED Calculator (`led_calculator_screen.dart`)
- Modernes Card-Layout
- Projekt-Verwaltung
- Live-Berechnung mit Results Panel
- Full-featured Input Form

#### 2. DMX Pult Manager (`dmx_pult_screen.dart`)
- Profile-Selection mit Chips
- Patch-Management
- Fixture-Übersicht
- Create/Delete Dialog

#### 3. DMX Settings (`dmx_settings_screen.dart`)
**5 Tab-Struktur:**

1. **Connection Tab** 🌐
   - Auto-Discovery Toggle
   - mDNS/Bonjour Toggle
   - Manual IP Configuration
   - Connection Status Indicator

2. **Patching Tab** 🔌
   - Auto-Patching Mode
   - Fixture Merging Options
   - Channel Allocation (Sequential/Sparse)

3. **Stage Tab** 🎭
   - Stage Dimensions (Width/Depth)
   - Grid Display Toggle
   - Label Display Toggle
   - Intensity Indicator Toggle

4. **Export Tab** 📤
   - Format Selection (GrandMA 3 XML, Standard DMX)
   - Metadata/Effects Include Options

5. **Performance Tab** ⚡
   - Update Frequency Slider (10-200 Hz)
   - Maximum Fixtures Slider (100-5000)
   - Caching Toggle

#### 4. Stage Visualizer (`stage_visualizer_screen.dart`)
- Interactive Canvas mit Zoom/Pan
- Real-time Fixture Visualization
- Grid & Labels (configurable)
- Intensity Visualization
- Control Panel mit Fixture-Info

### Components (`modern_components.dart`)

#### ModernCard
```dart
ModernCard(
  child: Widget,
  onTap: VoidCallback?,
  elevation: double?,
  backgroundColor: Color?,
  borderRadius: BorderRadius?,
)
```

#### ModernButton
```dart
ModernButton(
  label: String,
  onPressed: VoidCallback,
  icon: IconData?,
  isLoading: bool,
  variant: ButtonVariant, // primary, secondary, destructive
)
```

#### ModernInput
```dart
ModernInput(
  label: String,
  hint: String?,
  controller: TextEditingController?,
  keyboardType: TextInputType,
  validator: String? Function(String?)?,
  obscureText: bool,
)
```

#### ModernSwitch
```dart
ModernSwitch(
  label: String,
  value: bool,
  onChanged: ValueChanged<bool>,
  description: String?,
)
```

### Theme System (`app_colors.dart` & `app_theme.dart`)

#### Color Palette
- **Primary**: Indigo (#6366F1)
- **Secondary**: Cyan (#06B6D4)
- **Tertiary**: Purple (#9333EA)
- **LED Colors**: Red, Green, Blue, Yellow, White, Amber
- **Status**: Success, Warning, Error, Info
- **Neutrals**: 9 Abstufungen (100-900)

#### Material Design 3
- ColorScheme mit Light & Dark Themes
- Custom TextTheme
- InputDecorationTheme
- ButtonTheme (Elevated, Outlined, Text)
- CardTheme mit BorderRadius
- SnackBar Theme (Floating)

## 🎨 Design Features

### Modern Design Elements
✅ Rounded Corners (12-16px)
✅ Smooth Shadows & Elevation
✅ Clear Spacing & Padding
✅ Interactive Feedback
✅ Smooth Animations
✅ Responsive Layout
✅ Dark Mode Support

### User Experience
✅ Loading States (CircularProgressIndicator)
✅ Error Handling (AlertDialog)
✅ Confirmation Dialogs
✅ Toast Notifications (SnackBar)
✅ Form Validation
✅ Empty States
✅ Connection Status Indicator

## 📱 Responsiveness

Die App funktioniert auf:
- 📱 Mobile (Android/iOS)
- 💻 Web
- 🖥️ Desktop (Windows/macOS)

**Layout Strategy:**
- Single Column auf Mobile
- Adaptive Spacing
- Flexible Widgets
- SafeArea Handling

## 🌍 Internationalization

Unterstützte Sprachen:
- 🇩🇪 Deutsch (de.json)
- 🇬🇧 English (en.json)

**Usage:**
```dart
Text(localization.translate('dmx.settings'))
```

## 🚀 Performance Optimizations

✅ IndexedStack für Tab Navigation
✅ CustomPaint für Canvas (Stage Visualizer)
✅ InteractiveViewer für Zoom/Pan
✅ Lazy Loading von Providers
✅ Efficient State Management (Provider)
✅ Image Caching
✅ Smooth Animations (Duration: 300ms)

## 🔒 Accessibility

✅ Clear Color Contrast
✅ Readable Font Sizes
✅ Touch Targets (min 48x48dp)
✅ Semantic Labels
✅ Tooltip Support
✅ Dark Mode Support
✅ Form Labels & Hints

## 📝 Best Practices

### Widget Organization
```
lib/ui/
├── screens/         # Full page screens
├── widgets/         # Reusable components
├── theme/           # Design system
└── dialogs/         # Modal dialogs
```

### Color Usage
```dart
// Primary Actions
color: Theme.of(context).colorScheme.primary

// Text
color: Theme.of(context).colorScheme.onSurface

// Backgrounds
backgroundColor: AppColors.backgroundLight
```

### Spacing
```dart
const spacing = 16.0;  // Cards, sections
const padding = 12.0;  // Internal padding
const gap = 8.0;       // Item spacing
```

## 🐛 Debugging

### Hot Reload Issues
- Bei Theme-Änderungen: Full Rebuild erforderlich
- bei new Screens: Reload & clear state

### Performance Issues
- Nutze DevTools Performance Tab
- Check Rebuild-Counts in Widget Inspector
- Profile mit `flutter run --profile`

## 📚 Resources

- [Material Design 3 Docs](https://m3.material.io)
- [Flutter Widgets](https://flutter.dev/docs/development/ui/widgets)
- [Provider Package](https://pub.dev/packages/provider)

---

**Status:** ✅ Complete
**Last Update:** 2026-01-12
**Version:** 2.0.0
