// lib/screens/diagnostico_screen.dart
// Equivalente a src/pages/Diagnostico.jsx

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../services/openai_service.dart';
import '../config/app_theme.dart';
import '../config/constants.dart';

class DiagnosticoScreen extends StatefulWidget {
  const DiagnosticoScreen({super.key});

  @override
  State<DiagnosticoScreen> createState() => _DiagnosticoScreenState();
}

class _DiagnosticoScreenState extends State<DiagnosticoScreen> {
  // Equivalente a useState
  Cultivo _cultivo = kCultivos.first;
  final List<Uint8List> _fotos = [];
  final List<String> _sintomas = [];
  String _ubicacion = '';
  String _descripcion = '';
  bool _mostrarOpciones = false;
  bool _analizando = false;
  Map<String, dynamic>? _resultado;
  bool _errorResultado = false;

  // Chat
  final List<Map<String, String>> _chat = [];
  final _preguntaCtrl = TextEditingController();
  bool _enviando = false;

  final _ai = OpenAIService();
  final _picker = ImagePicker();
  final _db = FirebaseFirestore.instance;
  final _chatScrollCtrl = ScrollController();

  static const _sintomas = [
    'Manchas',
    'Hojas enrolladas',
    'Plagas visibles',
    'Pudrición',
    'Amarillamiento',
    'Marchitez',
    'Tallos débiles',
    'Frutos dañados',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _ubicacion = user?.ubicacion ?? '';
  }

  @override
  void dispose() {
    _preguntaCtrl.dispose();
    _chatScrollCtrl.dispose();
    super.dispose();
  }

  // Equivalente a handleFoto()
  Future<void> _pickFotos() async {
    final picked = await _picker.pickMultiImage();
    for (final f in picked) {
      final bytes = await f.readAsBytes();
      setState(() => _fotos.add(bytes));
    }
  }

  // Equivalente a toggleSintoma()
  void _toggleSintoma(String s) {
    setState(() {
      _sintomas.contains(s) ? _sintomas.remove(s) : _sintomas.add(s);
    });
  }

  // Equivalente a analizar()
  Future<void> _analizar() async {
    if (_fotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sube al menos una foto')));
      return;
    }
    setState(() {
      _analizando = true;
      _errorResultado = false;
    });
    try {
      final user = context.read<AuthProvider>().user;
      final compressedUrls = _fotos.map((b) => _ai.compressImage(b)).toList();

      final analisis = await _ai.invoke(
        prompt:
            '''Eres un agrónomo experto en cultivos del Perú. Analiza esta imagen de ${_cultivo.nombre} y da un diagnóstico claro y sencillo para un agricultor.

Datos:
- Cultivo: ${_cultivo.nombre} (${_cultivo.emoji})
- Ubicación: ${_ubicacion.isEmpty ? 'No especificada' : _ubicacion}
- Síntomas reportados: ${_sintomas.isEmpty ? 'No especificados' : _sintomas.join(', ')}
- Descripción del agricultor: ${_descripcion.isEmpty ? 'Sin descripción' : _descripcion}

IMPORTANTE: Responde en lenguaje simple y directo, sin términos técnicos complejos.''',
        fileUrls: compressedUrls,
        responseJsonSchema: {
          'type': 'object',
          'properties': {
            'tiene_problema': {'type': 'boolean'},
            'nombre_problema': {'type': 'string'},
            'gravedad': {
              'type': 'string',
              'enum': ['ninguna', 'leve', 'moderada', 'grave']
            },
            'que_tiene': {'type': 'string'},
            'que_hacer': {'type': 'string'},
            'productos': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': {
                  'nombre': {'type': 'string'},
                  'dosis': {'type': 'string'},
                }
              }
            },
            'prevencion': {'type': 'string'},
          }
        },
      );

      setState(() => _resultado = analisis as Map<String, dynamic>);

      // Guardar en Firebase
      try {
        await _db.collection('diagnosticos').add({
          'userId': user?.id,
          'userName': user?.nombre,
          'cultivo': _cultivo.nombre,
          'ubicacion': _ubicacion,
          'resultado': analisis,
          'fecha': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Firebase save error: $e');
      }
    } catch (e) {
      debugPrint('Error analizar: $e');
      setState(() => _errorResultado = true);
    }
    setState(() => _analizando = false);
  }

  // Equivalente a enviarPregunta()
  Future<void> _enviarPregunta() async {
    final p = _preguntaCtrl.text.trim();
    if (p.isEmpty) return;
    _preguntaCtrl.clear();
    setState(() {
      _chat.add({'role': 'user', 'text': p});
      _enviando = true;
    });
    try {
      final historial = _chat
          .map((m) =>
              '${m['role'] == 'user' ? 'Agricultor' : 'Asistente'}: ${m['text']}')
          .join('\n');
      final resp = await _ai.invoke(
        prompt:
            '''Eres un agrónomo experto. El agricultor tiene un ${_cultivo.nombre} con ${_resultado?['nombre_problema'] ?? 'cultivo saludable'}.

Historial: $historial

Pregunta actual: $p

Responde de forma clara, breve y en lenguaje simple.''',
      );
      setState(() => _chat.add({'role': 'ia', 'text': resp.toString()}));
      await Future.delayed(const Duration(milliseconds: 100));
      if (_chatScrollCtrl.hasClients) {
        _chatScrollCtrl.animateTo(
          _chatScrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      setState(() => _chat.add({
            'role': 'ia',
            'text': 'Lo siento, hubo un error. Intenta de nuevo.',
          }));
    }
    setState(() => _enviando = false);
  }

  // Color del header según gravedad
  Color _headerColor() {
    final g = _resultado?['gravedad'] as String? ?? '';
    if (g == 'grave') return Colors.red.shade600;
    if (g == 'moderada') return Colors.orange;
    if (_resultado?['tiene_problema'] == true) return Colors.amber;
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla resultado
    if (_resultado != null && !_errorResultado) return _buildResultado();
    // Pantalla formulario
    return _buildFormulario();
  }

  // ── PANTALLA RESULTADO ───────────────────────────────────────────────────────
  Widget _buildResultado() {
    final r = _resultado!;
    final tieneProblema = r['tiene_problema'] == true;
    final productos =
        (r['productos'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
        child: Column(children: [
          // Header con color según gravedad
          Container(
            color: _headerColor(),
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () => setState(() => _resultado = null),
                  child: const Text('← Nuevo diagnóstico',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
                Row(children: [
                  Icon(tieneProblema ? Icons.warning_amber : Icons.check_circle,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          tieneProblema
                              ? (r['nombre_problema'] ?? '')
                              : '✓ Cultivo Saludable',
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                      Text('${_cultivo.emoji} ${_cultivo.nombre}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  )),
                ]),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // ¿Qué tiene tu cultivo?
              _card('¿Qué tiene tu cultivo?', r['que_tiene'] ?? ''),

              // ¿Qué debes hacer?
              if (tieneProblema) ...[
                const SizedBox(height: 10),
                _card('¿Qué debes hacer?', r['que_hacer'] ?? ''),
              ],

              // Productos recomendados
              if (productos.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: AppDecorations.card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PRODUCTOS RECOMENDADOS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                            letterSpacing: 0.8,
                          )),
                      const SizedBox(height: 10),
                      ...productos.map((p) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFf9fafb),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p['nombre'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        )),
                                    Text(p['dosis'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                  ],
                                )),
                                ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Ver en tienda',
                                        style: TextStyle(fontSize: 11))),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],

              // Prevención
              if ((r['prevencion'] as String?)?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('🛡️ PREVENCIÓN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                            letterSpacing: 0.8,
                          )),
                      const SizedBox(height: 6),
                      Text(r['prevencion'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade800,
                            height: 1.5,
                          )),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Chat
              Container(
                padding: const EdgeInsets.all(14),
                decoration: AppDecorations.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💬 CONSULTA MÁS SOBRE TU CULTIVO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 0.8,
                        )),
                    const SizedBox(height: 10),
                    if (_chat.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          controller: _chatScrollCtrl,
                          itemCount: _chat.length,
                          itemBuilder: (ctx, i) {
                            final m = _chat[i];
                            final isUser = m['role'] == 'user';
                            return Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.75),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? AppTheme.primary
                                      : const Color(0xFFf3f4f6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(m['text'] ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isUser
                                          ? Colors.white
                                          : Colors.black87,
                                    )),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _preguntaCtrl,
                          onSubmitted: (_) => _enviarPregunta(),
                          decoration: InputDecoration(
                            hintText: 'Escribe tu pregunta...',
                            hintStyle: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xFFf9fafb),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppTheme.borderColor)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppTheme.borderColor)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AppTheme.primary)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _enviando ? null : _enviarPregunta,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _enviando
                                ? Colors.grey.shade300
                                : AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _enviando
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send,
                                  color: Colors.white, size: 18),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Explorar más
              Row(children: [
                Expanded(child: _quickCard('🛒', 'Mercado', 'Compra insumos')),
                const SizedBox(width: 10),
                Expanded(
                    child: _quickCard('🌱', 'Mi Parcela', 'Gestiona cultivos')),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── PANTALLA FORMULARIO ──────────────────────────────────────────────────────
  Widget _buildFormulario() {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
        child: Column(children: [
          // Header
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Diagnóstico IA',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
                SizedBox(height: 4),
                Text('Identifica plagas y enfermedades',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Selector de cultivos
              Container(
                padding: const EdgeInsets.all(14),
                decoration: AppDecorations.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SELECCIONA TU CULTIVO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 0.8,
                        )),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: kCultivos
                            .map((c) => GestureDetector(
                                  onTap: () => setState(() => _cultivo = c),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _cultivo.id == c.id
                                          ? AppTheme.primary
                                          : const Color(0xFFf9fafb),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: _cultivo.id == c.id
                                              ? AppTheme.primary
                                              : AppTheme.borderColor),
                                    ),
                                    child: Column(children: [
                                      Text(c.emoji,
                                          style: const TextStyle(fontSize: 22)),
                                      const SizedBox(height: 4),
                                      Text(c.nombre,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: _cultivo.id == c.id
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                          )),
                                    ]),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Fotos
              Container(
                padding: const EdgeInsets.all(14),
                decoration: AppDecorations.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FOTOS DEL CULTIVO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 0.8,
                        )),
                    const SizedBox(height: 10),
                    _fotos.isEmpty
                        ? GestureDetector(
                            onTap: _pickFotos,
                            child: Container(
                              width: double.infinity,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.borderColor,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined,
                                      size: 32, color: Colors.grey),
                                  SizedBox(height: 6),
                                  Text('Toca para subir fotos',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                        fontSize: 13,
                                      )),
                                  Text(
                                      'Fotos claras de hojas o plantas afectadas',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ..._fotos.asMap().entries.map((e) => Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          e.value,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () => setState(
                                              () => _fotos.removeAt(e.key)),
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close,
                                                size: 12, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              GestureDetector(
                                onTap: _pickFotos,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppTheme.borderColor, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.add_a_photo_outlined,
                                      color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Opciones adicionales colapsables
              GestureDetector(
                onTap: () =>
                    setState(() => _mostrarOpciones = !_mostrarOpciones),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: AppDecorations.card(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('➕ Agregar más detalles (opcional)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          )),
                      Icon(
                          _mostrarOpciones
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),

              // Opciones expandibles
              if (_mostrarOpciones) ...[
                const SizedBox(height: 10),

                // Síntomas
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: AppDecorations.card(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SÍNTOMAS OBSERVADOS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                            letterSpacing: 0.8,
                          )),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _sintomas
                            .map((s) => GestureDetector(
                                  onTap: () => _toggleSintoma(s),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _sintomas.contains(s)
                                          ? AppTheme.primary
                                          : const Color(0xFFf3f4f6),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: _sintomas.contains(s)
                                              ? AppTheme.primary
                                              : AppTheme.borderColor),
                                    ),
                                    child: Text(s,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _sintomas.contains(s)
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                        )),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Ubicación y descripción
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: AppDecorations.card(),
                  child: Column(children: [
                    TextField(
                      onChanged: (v) => _ubicacion = v,
                      decoration: InputDecoration(
                        labelText: 'Ubicación',
                        hintText: 'Ej: Cutervo, Cajamarca',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppTheme.primary)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (v) => _descripcion = v,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        hintText: 'Describe lo que observas...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppTheme.primary)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ]),
                ),
              ],

              const SizedBox(height: 14),

              // Botón analizar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _fotos.isEmpty || _analizando ? null : _analizar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _analizando
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white)),
                              SizedBox(width: 8),
                              Text('Analizando con IA...',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ])
                      : const Text('🔬 Iniciar Diagnóstico',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),

              // Error
              if (_errorResultado) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(children: [
                    Icon(Icons.warning_amber,
                        color: Colors.red.shade400, size: 32),
                    const SizedBox(height: 6),
                    Text('Error en el análisis',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade600)),
                    Text('Intenta con una foto más clara',
                        style: TextStyle(
                            fontSize: 11, color: Colors.red.shade400)),
                  ]),
                ),
              ],

              const SizedBox(height: 14),

              // Explorar más
              const Text('EXPLORAR MÁS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    letterSpacing: 0.8,
                  )),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _quickCard('🛒', 'Mercado', 'Compra insumos')),
                const SizedBox(width: 8),
                Expanded(
                    child: _quickCard('🌱', 'Mi Parcela', 'Gestiona cultivos')),
                const SizedBox(width: 8),
                Expanded(child: _quickCard('👥', 'Comunidad', 'Conecta')),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  Widget _card(String title, String content) => Container(
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                )),
            const SizedBox(height: 6),
            Text(content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF374151),
                  height: 1.5,
                )),
          ],
        ),
      );

  Widget _quickCard(String emoji, String title, String sub) => Container(
        padding: const EdgeInsets.all(12),
        decoration: AppDecorations.card(),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
      );
}
