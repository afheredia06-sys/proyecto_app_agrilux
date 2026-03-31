// lib/main.dart
// Equivalente a src/App.jsx + src/main.jsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'widgets/layout.dart';
import 'screens/registro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mercado_screen.dart';
import 'screens/diagnostico_screen.dart';
import 'screens/mi_parcela_screen.dart';
import 'screens/comunidad_screen.dart';
import 'screens/mas_screen.dart';
import 'screens/salud_financiera_screen.dart';
import 'screens/all_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const AgriluxApp(),
    ),
  );
}

// Equivalente a export default function App()
class AgriluxApp extends StatelessWidget {
  const AgriluxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agrilux',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppRoutes(),
    );
  }
}

// Equivalente a function AppRoutes()
class AppRoutes extends StatefulWidget {
  const AppRoutes({super.key});

  @override
  State<AppRoutes> createState() => _AppRoutesState();
}

class _AppRoutesState extends State<AppRoutes> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Equivalente a: if (loading) return <div animate-spin />
    if (auth.loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1a6b3c),
            strokeWidth: 4,
          ),
        ),
      );
    }

    // Equivalente a: if (!user) return <Registro />
    if (!auth.isLoggedIn) {
      return const RegistroScreen();
    }

    // Equivalente a: <Layout> con todas las rutas
    final screens = [
      HomeScreen(onNavigate: (i) => setState(() => _currentIndex = i)),
      const DiagnosticoScreen(),
      const MiParcelaScreen(),
      const ComunidadScreen(),
      MasScreen(
        onAdmin: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        ),
      ),
    ];

    return AppLayout(
      currentIndex: _currentIndex,
      onTabChanged: (i) => setState(() => _currentIndex = i),
      child: screens[_currentIndex],
    );
  }
}
