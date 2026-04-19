// lib/screens/mas_screen.dart
// Equivalente a src/pages/Mas.jsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../config/app_theme.dart';
import '../config/constants.dart';

class MasScreen extends StatelessWidget {
  final VoidCallback onAdmin;
  const MasScreen({super.key, required this.onAdmin});

  // Equivalente a redes array
  static const _redes = [
    {
      'nombre': 'YouTube',
      'desc': 'Videos de especialistas en cultivos',
      'emoji': '📹',
      'color': Color(0xFFef4444),
      'url': 'https://youtube.com/@agrilux'
    },
    {
      'nombre': 'TikTok',
      'desc': 'Tips rápidos de agricultura',
      'emoji': '🎵',
      'color': Color(0xFF000000),
      'url': 'https://tiktok.com/@agrilux'
    },
    {
      'nombre': 'Facebook',
      'desc': 'Comunidad y noticias',
      'emoji': '📘',
      'color': Color(0xFF2563eb),
      'url': 'https://facebook.com/agrilux'
    },
    {
      'nombre': 'Instagram',
      'desc': 'Fotos e historias de campo',
      'emoji': '📸',
      'color': Color(0xFFec4899),
      'url': 'https://instagram.com/agrilux'
    },
    {
      'nombre': 'LinkedIn',
      'desc': 'Red profesional agrícola',
      'emoji': '💼',
      'color': Color(0xFF1d4ed8),
      'url': 'https://linkedin.com/company/agrilux'
    },
  ];

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final inicial = (user?.nombre ?? 'A').substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
        child: Column(children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Más',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
                SizedBox(height: 4),
                Text('Redes, soporte y configuración',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // ── Perfil ───────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card(),
                child: Row(children: [
                  // Avatar con inicial
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(inicial,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.nombre ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          )),
                      const SizedBox(height: 2),
                      Text(user?.ubicacion ?? '',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(user?.tipo ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  )),
                ]),
              ),

              const SizedBox(height: 12),

              // ── Soporte WhatsApp ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: AppDecorations.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SOPORTE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 0.8,
                        )),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _launch(
                          'https://wa.me/$kWhatsApp?text=Hola Agrilux, necesito ayuda'),
                      child: Row(children: [
                        const Text('📲', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        const Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('WhatsApp Agrilux',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                )),
                            Text('+51 935 211 605',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        )),
                        const Icon(Icons.open_in_new,
                            size: 16, color: Colors.grey),
                      ]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Redes sociales ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: AppDecorations.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NUESTRAS REDES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 0.8,
                        )),
                    const SizedBox(height: 10),

                    // Lista de redes
                    ..._redes.map((r) => GestureDetector(
                          onTap: () => _launch(r['url'] as String),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: r == _redes.last
                                      ? Colors.transparent
                                      : const Color(0xFFf9fafb),
                                ),
                              ),
                            ),
                            child: Row(children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: r['color'] as Color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                    child: Text(r['emoji'] as String,
                                        style: const TextStyle(fontSize: 18))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r['nombre'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      )),
                                  Text(r['desc'] as String,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                ],
                              )),
                              const Icon(Icons.open_in_new,
                                  size: 14, color: Colors.grey),
                            ]),
                          ),
                        )),

                    const SizedBox(height: 10),

                    // Banner YouTube
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📹 YouTube — Contenido destacado',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade700,
                              )),
                          const SizedBox(height: 4),
                          Text(
                              'Videos de especialistas explicando el proceso de cultivo de cada uno de nuestros 15 productos.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade600,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Panel Admin (solo si tipo == 'admin') ────────────────────
              if (user?.tipo == 'admin') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAdmin,
                    icon: const Icon(Icons.shield),
                    label: const Text('Panel de Administrador',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1f2937),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // ── Cerrar sesión ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.read<AuthProvider>().logout(),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Cerrar sesión',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      )),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text('Agrilux v1.0 · Agricultura Inteligente del Perú',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),

              const SizedBox(height: 16),
            ]),
          ),
        ]),
      ),
    );
  }
}
