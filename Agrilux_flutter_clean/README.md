# Agrilux Flutter v2

App móvil completa convertida de React/Vite a Flutter/Dart.

## Equivalencias archivo por archivo

| Archivo Original (React/JS)         | Archivo Flutter (Dart)                              |
|--------------------------------------|-----------------------------------------------------|
| `src/main.jsx`                       | `lib/main.dart`                                     |
| `src/App.jsx`                        | `lib/main.dart` (AppRoot)                           |
| `src/components/Layout.jsx`          | `lib/widgets/layout.dart`                           |
| `src/lib/AuthContext.jsx`            | `lib/providers/auth_provider.dart`                  |
| `src/lib/firebase.js`                | `lib/services/firebase_service.dart`                |
| `src/lib/gemini.js`                  | `lib/services/openai_service.dart`                  |
| `src/lib/constants.js`               | `lib/config/constants.dart`                         |
| `.env.example`                       | `lib/config/app_config.dart`                        |
| `src/pages/Registro.jsx`             | `lib/screens/registro_screen.dart`                  |
| `src/pages/Home.jsx`                 | `lib/screens/home_screen.dart`                      |
| `src/pages/Mercado.jsx`              | `lib/screens/mercado_screen.dart`                   |
| `src/pages/Comunidad.jsx`            | `lib/screens/comunidad_screen.dart`                 |
| `src/pages/Mas.jsx`                  | `lib/screens/mas_screen.dart`                       |
| `src/pages/Diagnostico.jsx`          | `lib/screens/all_screens.dart` (DiagnosticoScreen)  |
| `src/pages/MiParcela.jsx`            | `lib/screens/all_screens.dart` (MiParcelaScreen)    |
| `src/pages/SaludFinanciera.jsx`      | `lib/screens/all_screens.dart` (SaludFinancieraScreen) |
| `src/pages/Admin.jsx`                | `lib/screens/all_screens.dart` (AdminScreen)        |

## Pasos para correr

### 1. Instala dependencias
```bash
flutter pub get
```

### 2. Configura Firebase
```bash
flutterfire configure
```
Esto crea `lib/firebase_options.dart` automáticamente.

Luego en `main.dart` agrega:
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 3. Pasa tus claves de API
```bash
flutter run \
  --dart-define=OPENAI_API_KEY=sk-... \
  --dart-define=FIREBASE_API_KEY=...
```

### 4. Ejecuta
```bash
flutter run
```

## Estructura

```
lib/
├── main.dart                        # Entrada + Router (≡ main.jsx + App.jsx)
├── config/
│   ├── app_config.dart              # Claves (≡ .env)
│   └── constants.dart               # Cultivos, precios, insumos (≡ constants.js)
├── models/
│   └── user_model.dart
├── providers/
│   └── auth_provider.dart           # Estado de sesión (≡ AuthContext.jsx)
├── services/
│   ├── openai_service.dart          # GPT-4o (≡ gemini.js)
│   └── firebase_service.dart        # Firebase (≡ firebase.js)
├── screens/
│   ├── registro_screen.dart         # ≡ Registro.jsx
│   ├── home_screen.dart             # ≡ Home.jsx
│   ├── mercado_screen.dart          # ≡ Mercado.jsx
│   ├── comunidad_screen.dart        # ≡ Comunidad.jsx
│   ├── mas_screen.dart              # ≡ Mas.jsx
│   └── all_screens.dart             # ≡ Diagnostico, MiParcela, SaludFinanciera, Admin
└── widgets/
    └── layout.dart                  # Bottom nav (≡ Layout.jsx)
```
