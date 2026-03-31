// lib/screens/admin_screen.dart
// Equivalente a src/pages/Admin.jsx

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  // Equivalente a: const [stats, setStats] = useState({...})
  Map<String, int> _stats = {
    'usuarios': 0,
    'diagnosticos': 0,
    'parcelas': 0,
    'comunidad': 0,
  };
  List<Map<String, dynamic>> _usuarios = [];
  bool _loading = true;

  final _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // Equivalente a useEffect(() => { cargar() }, [])
  Future<void> _cargar() async {
    try {
      // Equivalente a Promise.all([...])
      final results = await Future.wait([
        _db.collection('usuarios').get(),
        _db.collection('diagnosticos').get(),
        _db.collection('parcelas').get(),
        _db.collection('comunidad').get(),
      ]);

      final usuariosDocs =
          results[0].docs.map((d) => {'id': d.id, ...d.data()}).toList();

      // Equivalente a .sort((a,b) => new Date(b.createdAt) - new Date(a.createdAt))
      usuariosDocs.sort(
          (a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));

      setState(() {
        _stats = {
          'usuarios': results[0].size,
          'diagnosticos': results[1].size,
          'parcelas': results[2].size,
          'comunidad': results[3].size,
        };
        _usuarios = usuariosDocs;
      });
    } catch (e) {
      debugPrint('Error cargando admin: $e');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Equivalente a: if (loading) return <div animate-spin />
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    // Equivalente a statCards array
    final statCards = [
      {
        'label': 'Usuarios registrados',
        'value': _stats['usuarios'],
        'emoji': '👥',
        'color': Colors.blue
      },
      {
        'label': 'Diagnósticos realizados',
        'value': _stats['diagnosticos'],
        'emoji': '🔬',
        'color': Colors.green
      },
      {
        'label': 'Parcelas creadas',
        'value': _stats['parcelas'],
        'emoji': '🌱',
        'color': AppTheme.primary
      },
      {
        'label': 'Posts comunidad',
        'value': _stats['comunidad'],
        'emoji': '💬',
        'color': Colors.purple
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
        child: Column(children: [
          // ── Header gris oscuro ─────────────────────────────────────────
          // Equivalente a: bg-gray-800 text-white
          Container(
            color: const Color(0xFF1f2937),
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
            child: const Row(children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Panel Admin',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  SizedBox(height: 4),
                  Text('Estadísticas y usuarios',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                      )),
                ],
              )),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // ── Grid de stats ──────────────────────────────────────────
              // Equivalente a: grid grid-cols-2 gap-3
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: statCards
                    .map((s) => Container(
                          padding: const EdgeInsets.all(14),
                          decoration: AppDecorations.card(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Equivalente a: ${s.color} w-10 h-10 rounded-xl
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: (s['color'] as Color)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(s['emoji'] as String,
                                      style: const TextStyle(fontSize: 20)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('${s['value']}',
                                  style: const TextStyle(
                                    fontFamily: 'Syne',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1f2937),
                                  )),
                              Text(s['label'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  )),
                            ],
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 12),

              // ── Lista de usuarios ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'USUARIOS REGISTRADOS (${_usuarios.length})',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Equivalente a: max-h-96 overflow-y-auto
                    SizedBox(
                      height: 380,
                      child: ListView.builder(
                        itemCount: _usuarios.length,
                        itemBuilder: (ctx, i) {
                          final u = _usuarios[i];
                          final inicial = (u['nombre'] as String? ?? 'A')
                              .substring(0, 1)
                              .toUpperCase();
                          final whatsapp = (u['whatsapp'] as String? ?? '')
                              .replaceAll(RegExp(r'\D'), '');

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: i == _usuarios.length - 1
                                      ? Colors.transparent
                                      : const Color(0xFFf9fafb),
                                ),
                              ),
                            ),
                            child: Row(children: [
                              // Avatar con inicial
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(inicial,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primary,
                                      )),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Nombre y ubicación
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(u['nombre'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis),
                                  Text(
                                      '${u['ubicacion'] ?? ''} · ${u['tipo'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      )),
                                ],
                              )),

                              // Equivalente a: <a href="https://wa.me/51...">WhatsApp</a>
                              GestureDetector(
                                onTap: () async {
                                  final url = Uri.parse(
                                    'https://wa.me/51$whatsapp',
                                  );
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: const Text('WhatsApp',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    )),
                              ),
                            ]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
