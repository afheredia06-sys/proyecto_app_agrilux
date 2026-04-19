// lib/screens/home_screen.dart
// Equivalente a src/pages/Home.jsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  // Equivalente a modules array
  static const _modules = [
    {
      'idx': 1,
      'color': Color(0xFF10b981),
      'emoji': '🛒',
      'label': 'Mercado',
      'desc': 'Compra y vende productos',
      'disabled': false
    },
    {
      'idx': 1,
      'color': Color(0xFF3b82f6),
      'emoji': '🔬',
      'label': 'Diagnóstico IA',
      'desc': 'Identifica plagas y enfermedades',
      'disabled': false
    },
    {
      'idx': 2,
      'color': Color(0xFF16a34a),
      'emoji': '🌱',
      'label': 'Mi Parcela',
      'desc': 'Gestiona tus cultivos',
      'disabled': false
    },
    {
      'idx': 4,
      'color': Color(0xFFf59e0b),
      'emoji': '💰',
      'label': 'Salud Financiera',
      'desc': 'Próximamente',
      'disabled': true
    },
    {
      'idx': 3,
      'color': Color(0xFF8b5cf6),
      'emoji': '👥',
      'label': 'Comunidad',
      'desc': 'Conecta con agricultores',
      'disabled': false
    },
  ];

  // Equivalente a precios del día
  static const _precios = [
    {'n': 'Papa Yungay', 'p': 'S/ 1.20', 't': '↑'},
    {'n': 'Maíz', 'p': 'S/ 0.90', 't': '→'},
    {'n': 'Arroz', 'p': 'S/ 2.40', 't': '↑'},
    {'n': 'Palta Hass', 'p': 'S/ 3.80', 't': '↓'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    // Equivalente a user?.nombre?.split(' ')[0]
    final nombre = (user?.nombre ?? '').split(' ').first;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
        child: Column(children: [
          // ── Header ──────────────────────────────────────────────────────
          // Equivalente a: bg-primary relative overflow-hidden
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 28),
            child: Stack(children: [
              // Círculos decorativos — equivalente a absolute -right-8 -top-8
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: -8,
                top: 56,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Contenido
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bienvenido,',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('$nombre 👋',
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  if ((user?.ubicacion ?? '').isNotEmpty)
                    Text(user!.ubicacion,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        )),
                ],
              ),
            ]),
          ),

          // ── Precios del día ──────────────────────────────────────────────
          // Equivalente a: mx-4 -mt-4 bg-white rounded-2xl shadow-md
          Container(
            margin: const EdgeInsets.fromLTRB(16, -16, 16, 20),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.trending_up, size: 16, color: AppTheme.primary),
                  SizedBox(width: 6),
                  Text('PRECIOS DEL DÍA - LIMA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      )),
                ]),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _precios
                        .map((p) => Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFf9fafb),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['n']!,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(p['p']!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primary,
                                      )),
                                  Text(
                                      p['t'] == '↑'
                                          ? '↑ tendencia'
                                          : p['t'] == '↓'
                                              ? '↓ tendencia'
                                              : '→ estable',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: p['t'] == '↑'
                                            ? Colors.green
                                            : p['t'] == '↓'
                                                ? Colors.red
                                                : Colors.grey,
                                      )),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Módulos ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Qué deseas hacer?',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1f2937),
                    )),
                const SizedBox(height: 12),

                // Equivalente a: grid grid-cols-2 gap-3
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: _modules.map((m) {
                    final disabled = m['disabled'] as bool;
                    return GestureDetector(
                      onTap:
                          disabled ? null : () => onNavigate(m['idx'] as int),
                      child: Opacity(
                        opacity: disabled ? 0.6 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFf3f4f6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icono con color
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: (m['color'] as Color)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(m['emoji'] as String,
                                      style: const TextStyle(fontSize: 20)),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(m['label'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF1f2937),
                                  )),
                              const SizedBox(height: 2),
                              Text(m['desc'] as String,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                              // Badge "Próximamente"
                              if (disabled)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFfef3c7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Próximamente',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFd97706),
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // ── Banner comunidad ─────────────────────────────────────────────
          // Equivalente a: bg-gradient-to-r from-primary to-primary-light
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌾 Comunidad Agrilux',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    )),
                const SizedBox(height: 4),
                const Text(
                    'Conecta con agricultores de tu zona, comparte alertas y consejos.',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => onNavigate(3),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Ver comunidad →',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        )),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}
