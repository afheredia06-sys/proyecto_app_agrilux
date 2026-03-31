// lib/screens/comunidad_screen.dart
// Equivalente a src/pages/Comunidad.jsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../config/app_theme.dart';

class ComunidadScreen extends StatefulWidget {
  const ComunidadScreen({super.key});

  @override
  State<ComunidadScreen> createState() => _ComunidadScreenState();
}

class _ComunidadScreenState extends State<ComunidadScreen> {
  // Equivalente a CATEGORIAS array
  static const _categorias = [
    {'id': 'todas', 'label': 'Todas', 'emoji': '📋'},
    {'id': 'plagas', 'label': 'Plagas', 'emoji': '🐛'},
    {'id': 'enfermedades', 'label': 'Enfermedades', 'emoji': '🍂'},
    {'id': 'precios', 'label': 'Precios', 'emoji': '💰'},
    {'id': 'consejos', 'label': 'Consejos', 'emoji': '💡'},
    {'id': 'venta', 'label': 'Venta', 'emoji': '🛒'},
    {'id': 'general', 'label': 'General', 'emoji': '💬'},
  ];

  // Equivalente a catColors
  static const _catColors = {
    'plagas': {'bg': Color(0xFFfee2e2), 'text': Color(0xFFb91c1c)},
    'enfermedades': {'bg': Color(0xFFffedd5), 'text': Color(0xFFc2410c)},
    'precios': {'bg': Color(0xFFfef9c3), 'text': Color(0xFFa16207)},
    'consejos': {'bg': Color(0xFFdbeafe), 'text': Color(0xFF1d4ed8)},
    'venta': {'bg': Color(0xFFf3e8ff), 'text': Color(0xFF7e22ce)},
    'general': {'bg': Color(0xFFf3f4f6), 'text': Color(0xFF374151)},
  };

  // Equivalente a useState
  List<Map<String, dynamic>> _mensajes = [];
  String _categoria = 'todas';
  bool _modal = false;
  bool _loading = true;
  bool _publicando = false;

  // Equivalente a form state
  String _formCategoria = 'general';
  String _formTitulo = '';
  String _formContenido = '';
  String _formUbicacion = '';

  final _db = FirebaseFirestore.instance;
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
    final user = context.read<AuthProvider>().user;
    _formUbicacion = user?.ubicacion ?? '';
    _ubicacionCtrl.text = _formUbicacion;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _contenidoCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  // Equivalente a cargarMensajes()
  Future<void> _cargarMensajes() async {
    try {
      final snap = await _db
          .collection('comunidad')
          .orderBy('fecha', descending: true)
          .get();
      setState(() {
        _mensajes = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      });
    } catch (e) {
      setState(() => _mensajes = []);
    }
    setState(() => _loading = false);
  }

  // Equivalente a timeAgo()
  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final diff = DateTime.now().difference(DateTime.parse(dateStr)).inSeconds;
    if (diff < 60) return 'hace un momento';
    if (diff < 3600) return 'hace ${diff ~/ 60} min';
    if (diff < 86400) return 'hace ${diff ~/ 3600} h';
    return 'hace ${diff ~/ 86400} días';
  }

  // Equivalente a publicar()
  Future<void> _publicar() async {
    if (_formTitulo.isEmpty || _formContenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa título y contenido')));
      return;
    }
    setState(() => _publicando = true);
    final user = context.read<AuthProvider>().user;
    try {
      final ref = await _db.collection('comunidad').add({
        'categoria': _formCategoria,
        'titulo': _formTitulo,
        'contenido': _formContenido,
        'ubicacion': _formUbicacion,
        'autor': user?.nombre,
        'autorId': user?.id,
        'fecha': DateTime.now().toIso8601String(),
        'likes': 0,
      });
      setState(() {
        _mensajes.insert(0, {
          'id': ref.id,
          'categoria': _formCategoria,
          'titulo': _formTitulo,
          'contenido': _formContenido,
          'ubicacion': _formUbicacion,
          'autor': user?.nombre,
          'fecha': DateTime.now().toIso8601String(),
          'likes': 0,
        });
        _modal = false;
        _formTitulo = '';
        _formContenido = '';
        _tituloCtrl.clear();
        _contenidoCtrl.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error al publicar')));
    }
    setState(() => _publicando = false);
  }

  // Equivalente a darLike()
  Future<void> _darLike(String id) async {
    try {
      await _db.collection('comunidad').doc(id).update({
        'likes': FieldValue.increment(1),
      });
      setState(() {
        _mensajes = _mensajes
            .map((m) =>
                m['id'] == id ? {...m, 'likes': (m['likes'] ?? 0) + 1} : m)
            .toList();
      });
    } catch (e) {}
  }

  // Equivalente a filtrados
  List<Map<String, dynamic>> get _filtrados => _categoria == 'todas'
      ? _mensajes
      : _mensajes.where((m) => m['categoria'] == _categoria).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        Column(children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Comunidad',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                    SizedBox(height: 4),
                    Text('Conecta con agricultores',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        )),
                  ],
                ),
                // Equivalente a: <button onClick={() => setModal(true)}>
                GestureDetector(
                  onTap: () => setState(() => _modal = true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(children: [
                      Icon(Icons.add, size: 16, color: AppTheme.primary),
                      SizedBox(width: 4),
                      Text('Publicar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          )),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // ── Filtros de categorías ────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categorias.length,
              itemBuilder: (ctx, i) {
                final c = _categorias[i];
                final active = _categoria == c['id'];
                return GestureDetector(
                  onTap: () => setState(() => _categoria = c['id']!),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? AppTheme.primary : AppTheme.borderColor,
                      ),
                    ),
                    child: Row(children: [
                      Text(c['emoji']!, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(c['label']!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : Colors.grey.shade600,
                          )),
                    ]),
                  ),
                );
              },
            ),
          ),

          // ── Lista de mensajes ────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : _filtrados.isEmpty
                    ? Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💬', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 8),
                          const Text('No hay publicaciones en esta categoría',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13)),
                          TextButton(
                              onPressed: () => setState(() => _modal = true),
                              child: const Text('Sé el primero en publicar',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ))),
                        ],
                      ))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                        itemCount: _filtrados.length,
                        itemBuilder: (ctx, i) => _buildMensaje(_filtrados[i]),
                      ),
          ),
        ]),

        // ── Modal publicar ───────────────────────────────────────────────
        if (_modal) _buildModal(),
      ]),
    );
  }

  // ── Widget tarjeta mensaje ───────────────────────────────────────────────
  Widget _buildMensaje(Map<String, dynamic> m) {
    final cat = m['categoria'] as String? ?? 'general';
    final colors = _catColors[cat] ?? _catColors['general']!;
    final inicial =
        ((m['autor'] as String?) ?? 'A').substring(0, 1).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(inicial,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  )),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Autor + ubicación + badge categoría
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  Text(m['autor'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      )),
                  if ((m['ubicacion'] as String?)?.isNotEmpty == true)
                    Text('📍 ${m['ubicacion']}',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors['bg'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                        '${_categorias.firstWhere((c) => c['id'] == cat, orElse: () => _categorias.last)['emoji']} $cat',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colors['text'],
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(_timeAgo(m['fecha'] as String?),
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(m['titulo'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  )),
              const SizedBox(height: 4),
              Text(m['contenido'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4b5563),
                    height: 1.5,
                  )),
              const SizedBox(height: 8),
              // Botón like
              GestureDetector(
                onTap: () => _darLike(m['id']),
                child: Text('👍 ${m['likes'] ?? 0}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    )),
              ),
            ],
          )),
        ],
      ),
    );
  }

  // ── Modal publicar ───────────────────────────────────────────────────────
  Widget _buildModal() {
    return GestureDetector(
      onTap: () => setState(() => _modal = false),
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Publicar en la comunidad',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )),
                      GestureDetector(
                          onTap: () => setState(() => _modal = false),
                          child: const Icon(Icons.close, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Selector categoría
                  _label('Categoría'),
                  DropdownButtonFormField<String>(
                    value: _formCategoria,
                    decoration: _inputDeco(''),
                    items: _categorias
                        .where((c) => c['id'] != 'todas')
                        .map((c) => DropdownMenuItem(
                              value: c['id'],
                              child: Text('${c['emoji']} ${c['label']}',
                                  style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _formCategoria = v ?? 'general'),
                  ),
                  const SizedBox(height: 10),

                  // Título
                  _label('Título *'),
                  TextField(
                    controller: _tituloCtrl,
                    onChanged: (v) => _formTitulo = v,
                    decoration:
                        _inputDeco('Ej: Rancha en parcelas del sector Alto'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 10),

                  // Contenido
                  _label('Contenido *'),
                  TextField(
                    controller: _contenidoCtrl,
                    onChanged: (v) => _formContenido = v,
                    maxLines: 3,
                    decoration:
                        _inputDeco('Describe el problema, precio o consejo...'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 10),

                  // Ubicación
                  _label('Ubicación'),
                  TextField(
                    controller: _ubicacionCtrl,
                    onChanged: (v) => _formUbicacion = v,
                    decoration: _inputDeco('Ej: Sector Alto Salabamba'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Botones
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _modal = false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancelar',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _publicando ? null : _publicar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(_publicando ? 'Publicando...' : 'Publicar',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              )),
        ),
      );

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppTheme.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
}
