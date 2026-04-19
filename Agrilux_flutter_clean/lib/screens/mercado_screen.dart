// lib/screens/mercado_screen.dart
// Equivalente a src/pages/Mercado.jsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../config/app_theme.dart';
import '../config/constants.dart';

class MercadoScreen extends StatefulWidget {
  const MercadoScreen({super.key});

  @override
  State<MercadoScreen> createState() => _MercadoScreenState();
}

class _MercadoScreenState extends State<MercadoScreen> {
  final _db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _tiendas = [];
  bool _loading = true;
  bool _modalRegistro = false;
  Map<String, dynamic>? _tiendaActiva;
  String _busqueda = '';
  String _filtroUbicacion = '';

  // Market user separado del auth user principal
  Map<String, dynamic>? _marketUser;

  @override
  void initState() {
    super.initState();
    _cargarTiendas();
  }

  Future<void> _cargarTiendas() async {
    try {
      final snap = await _db
          .collection('usuariosMercado')
          .where('tipo', isEqualTo: 'proveedor')
          .get();
      setState(() {
        _tiendas = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      });
    } catch (e) {
      setState(() => _tiendas = []);
    }
    setState(() => _loading = false);
  }

  Future<void> _registrarMarketUser(Map<String, dynamic> data) async {
    final ref = await _db.collection('usuariosMercado').add({
      ...data,
      'createdAt': DateTime.now().toIso8601String(),
    });
    setState(() {
      _marketUser = {'id': ref.id, ...data};
      _modalRegistro = false;
    });
    if (data['tipo'] == 'proveedor') await _cargarTiendas();
  }

  List<Map<String, dynamic>> get _tiiendasFiltradas => _tiendas.where((t) {
        final porNombre = _busqueda.isEmpty ||
            (t['empresa'] as String? ?? '')
                .toLowerCase()
                .contains(_busqueda.toLowerCase());
        final porUbicacion = _filtroUbicacion.isEmpty ||
            (t['ubicacion'] as String? ?? '')
                .toLowerCase()
                .contains(_filtroUbicacion.toLowerCase());
        return porNombre && porUbicacion;
      }).toList();

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tiendaActiva != null) {
      return _VistaTienda(
        tienda: _tiendaActiva!,
        marketUser: _marketUser,
        onVolver: () => setState(() => _tiendaActiva = null),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🛡️ Fungicidas',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  SizedBox(height: 4),
                  Text('Marketplace de insumos certificados',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // ── Usuario registrado o botón registro ───────────────────
                _marketUser != null
                    ? Container(
                        padding: const EdgeInsets.all(14),
                        decoration: AppDecorations.card(),
                        child: Row(children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                  (_marketUser!['nombre'] as String? ?? 'A')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
                                  )),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${_marketUser!['nombre']} ${_marketUser!['apellido']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  )),
                              Text(
                                  '${_marketUser!['tipo']} · ${_marketUser!['ubicacion']}',
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey)),
                            ],
                          )),
                          if (_marketUser!['tipo'] == 'proveedor')
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('Proveedor',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                    ))),
                        ]),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              setState(() => _modalRegistro = true),
                          icon: const Icon(Icons.store),
                          label: const Text('Unirme al Marketplace',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),

                const SizedBox(height: 10),

                // ── Info soporte ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(children: [
                    const Text('📞', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('¿Necesitas ayuda?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.amber.shade700,
                            )),
                        GestureDetector(
                            onTap: () => _launch('https://wa.me/$kWhatsApp'),
                            child: Text('935 211 605',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber.shade600,
                                ))),
                      ],
                    ),
                  ]),
                ),

                const SizedBox(height: 10),

                // ── Buscador ──────────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: AppDecorations.card(),
                  child: Row(children: [
                    const Text('🔍', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _busqueda = v),
                        decoration: const InputDecoration(
                          hintText: 'Buscar tienda...',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 8),

                // ── Filtro ubicación ──────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: AppDecorations.card(),
                  child: Row(children: [
                    const Text('📍', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _filtroUbicacion = v),
                        decoration: const InputDecoration(
                          hintText: 'Filtrar por ciudad...',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 12),

                // ── Lista de tiendas ──────────────────────────────────────
                Text('TIENDAS REGISTRADAS (${_tiiendasFiltradas.length})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 0.8,
                    )),
                const SizedBox(height: 10),

                _loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppTheme.primary))
                    : _tiiendasFiltradas.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(28),
                            decoration: AppDecorations.card(),
                            child: Column(children: [
                              const Text('🏪', style: TextStyle(fontSize: 36)),
                              const SizedBox(height: 10),
                              const Text('Aún no hay tiendas registradas',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  )),
                              const Text('Sé el primero en registrar tu tienda',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                  onPressed: () =>
                                      setState(() => _modalRegistro = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Registrar mi tienda',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700))),
                            ]),
                          )
                        : Column(
                            children: _tiiendasFiltradas
                                .map((tienda) => GestureDetector(
                                      onTap: () => setState(
                                          () => _tiendaActiva = tienda),
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(14),
                                        decoration: AppDecorations.card(),
                                        child: Row(children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: AppTheme.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Center(
                                                child: Text('🏪',
                                                    style: TextStyle(
                                                        fontSize: 22))),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(tienda['empresa'] ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  )),
                                              Text(
                                                  '${tienda['nombre']} ${tienda['apellido']}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey,
                                                  )),
                                              Text('📍 ${tienda['ubicacion']}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey,
                                                  )),
                                            ],
                                          )),
                                          const Text('Ver →',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.primary,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ]),
                                      ),
                                    ))
                                .toList(),
                          ),
              ]),
            ),
          ]),
        ),

        // ── Modal registro ───────────────────────────────────────────────
        if (_modalRegistro)
          _ModalRegistro(
            onClose: () => setState(() => _modalRegistro = false),
            onSuccess: _registrarMarketUser,
          ),
      ]),
    );
  }
}

// ─── VISTA TIENDA ─────────────────────────────────────────────────────────────
class _VistaTienda extends StatefulWidget {
  final Map<String, dynamic> tienda;
  final Map<String, dynamic>? marketUser;
  final VoidCallback onVolver;

  const _VistaTienda({
    required this.tienda,
    required this.marketUser,
    required this.onVolver,
  });

  @override
  State<_VistaTienda> createState() => _VistaTiendaState();
}

class _VistaTiendaState extends State<_VistaTienda> {
  final _db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _productos = [];
  bool _loading = true;
  bool _modalProducto = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      final snap = await _db
          .collection('productos')
          .where('tiendaId', isEqualTo: widget.tienda['id'])
          .get();
      setState(() {
        _productos = snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      });
    } catch (e) {
      setState(() => _productos = []);
    }
    setState(() => _loading = false);
  }

  Future<void> _solicitarProducto(Map<String, dynamic> p) async {
    final t = widget.tienda;
    final mu = widget.marketUser;
    final cel = (t['celular'] as String? ?? '').replaceAll(RegExp(r'\D'), '');
    final msg = Uri.encodeComponent(
      '🛡️ *SOLICITUD DE FUNGICIDA - AGRILUX*\n\n'
      '🏪 *Tienda:* ${t['empresa']}\n'
      '📦 *Producto:* ${p['nombre']}\n'
      '📍 *Ubicación tienda:* ${t['ubicacion']}\n\n'
      '👤 *Mi nombre:* ${mu?['nombre'] ?? 'Agricultor'} ${mu?['apellido'] ?? ''}\n'
      '📱 *Mi celular:* ${mu?['celular'] ?? 'No registrado'}\n\n'
      '¿Cuál es el precio y cómo coordino la compra?',
    );
    final url = Uri.parse('https://wa.me/51$cel?text=$msg');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tienda;
    final esDueno = widget.marketUser?['id'] == t['userId'];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(children: [
            Container(
              color: AppTheme.primary,
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: widget.onVolver,
                    child: const Text('← Volver',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
                  Text(t['empresa'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  Text('📍 ${t['ubicacion']}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('📱 ${t['celular']}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                if (esDueno) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => _modalProducto = true),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar producto',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppTheme.primary))
                    : _productos.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(28),
                            decoration: AppDecorations.card(),
                            child: const Column(children: [
                              Text('📦', style: TextStyle(fontSize: 36)),
                              SizedBox(height: 8),
                              Text('Esta tienda aún no tiene productos',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            ]),
                          )
                        : Column(
                            children: _productos
                                .map((p) => Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: AppDecorations.card(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                  child: Text(p['nombre'] ?? '',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                      ))),
                                              Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: p['disponible'] ==
                                                            true
                                                        ? Colors.green.shade50
                                                        : Colors.red.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                      p['disponible'] == true
                                                          ? 'Disponible'
                                                          : 'Sin stock',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            p['disponible'] ==
                                                                    true
                                                                ? Colors.green
                                                                    .shade700
                                                                : Colors.red
                                                                    .shade600,
                                                      ))),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(p['descripcion'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                          if ((p['uso'] as String?)
                                                  ?.isNotEmpty ==
                                              true) ...[
                                            const SizedBox(height: 6),
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFf9fafb),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text('💊 ${p['uso']}',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                    ))),
                                          ],
                                          if ((p['cultivos'] as List?)
                                                  ?.isNotEmpty ==
                                              true) ...[
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 4,
                                              children: (p['cultivos'] as List)
                                                  .map((cId) {
                                                final c = kCultivos
                                                    .where((x) => x.id == cId)
                                                    .firstOrNull;
                                                return c != null
                                                    ? Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppTheme
                                                              .primary
                                                              .withValues(
                                                                  alpha: 0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Text(
                                                            '${c.emoji} ${c.nombre}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              color: AppTheme
                                                                  .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            )))
                                                    : const SizedBox.shrink();
                                              }).toList(),
                                            ),
                                          ],
                                          if (p['precio'] != null) ...[
                                            const SizedBox(height: 6),
                                            Text('S/ ${p['precio']}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppTheme.primary,
                                                )),
                                          ],
                                          if (p['disponible'] == true) ...[
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                  onPressed: () =>
                                                      _solicitarProducto(p),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green.shade500,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                  ),
                                                  child: const Text(
                                                      '📲 Solicitar por WhatsApp',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 13,
                                                      ))),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
              ]),
            ),
          ]),
        ),
        if (_modalProducto)
          _ModalSubirProducto(
            tiendaId: t['id'],
            onClose: () => setState(() => _modalProducto = false),
            onSuccess: () {
              setState(() => _modalProducto = false);
              _cargarProductos();
            },
          ),
      ]),
    );
  }
}

// ─── MODAL REGISTRO ───────────────────────────────────────────────────────────
class _ModalRegistro extends StatefulWidget {
  final VoidCallback onClose;
  final Future<void> Function(Map<String, dynamic>) onSuccess;

  const _ModalRegistro({
    required this.onClose,
    required this.onSuccess,
  });

  @override
  State<_ModalRegistro> createState() => _ModalRegistroState();
}

class _ModalRegistroState extends State<_ModalRegistro> {
  String _tipo = '';
  bool _loading = false;
  String _error = '';
  final _form = <String, String>{
    'nombre': '',
    'apellido': '',
    'celular': '',
    'ubicacion': '',
    'empresa': '',
  };

  Future<void> _submit() async {
    if (_form['nombre']!.isEmpty ||
        _form['apellido']!.isEmpty ||
        _form['celular']!.isEmpty ||
        _form['ubicacion']!.isEmpty) {
      setState(() => _error = 'Completa todos los campos obligatorios');
      return;
    }
    if (_tipo == 'proveedor' && _form['empresa']!.isEmpty) {
      setState(() => _error = 'Ingresa el nombre de tu empresa');
      return;
    }
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      await widget.onSuccess({..._form, 'tipo': _tipo});
    } catch (e) {
      setState(() => _error = 'Error al registrar. Intenta de nuevo.');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Unirte al Marketplace',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            )),
                        GestureDetector(
                            onTap: widget.onClose,
                            child: const Icon(Icons.close, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _tipo.isEmpty
                        ? Column(children: [
                            const Text('¿Cómo deseas participar?',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 12),
                            _tipoBtn(
                                'agricultor',
                                '👨‍🌾',
                                'Soy Agricultor',
                                'Explora tiendas y solicita cotizaciones',
                                Colors.green.shade50,
                                Colors.green.shade200),
                            const SizedBox(height: 10),
                            _tipoBtn(
                                'proveedor',
                                '🏪',
                                'Soy Proveedor de Insumos',
                                'Registra tu tienda y sube tus productos',
                                Colors.blue.shade50,
                                Colors.blue.shade200),
                          ])
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                  onPressed: () => setState(() => _tipo = ''),
                                  child: const Text('← Volver',
                                      style: TextStyle(color: Colors.grey))),
                              if (_error.isNotEmpty)
                                Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(_error,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 13,
                                        ))),
                              for (final field in [
                                {
                                  'key': 'nombre',
                                  'label': 'Nombre *',
                                  'hint': 'Tu nombre'
                                },
                                {
                                  'key': 'apellido',
                                  'label': 'Apellido *',
                                  'hint': 'Tu apellido'
                                },
                                {
                                  'key': 'celular',
                                  'label': 'Celular *',
                                  'hint': 'Ej: 935211605'
                                },
                                {
                                  'key': 'ubicacion',
                                  'label': 'Ubicación *',
                                  'hint': 'Ej: Cutervo'
                                },
                                if (_tipo == 'proveedor')
                                  {
                                    'key': 'empresa',
                                    'label': 'Empresa *',
                                    'hint': 'Ej: Agroservicios SAC'
                                  },
                              ]) ...[
                                _label(field['label']!),
                                TextField(
                                  onChanged: (v) => _form[field['key']!] = v,
                                  decoration: _inputDeco(field['hint']!),
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 10),
                              ],
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                      _loading
                                          ? 'Registrando...'
                                          : 'Registrarme →',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tipoBtn(String tipo, String emoji, String title, String sub,
          Color bgColor, Color borderColor) =>
      GestureDetector(
        onTap: () => setState(() => _tipo = tipo),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(sub,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            )),
          ]),
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            )),
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

// ─── MODAL SUBIR PRODUCTO ─────────────────────────────────────────────────────
class _ModalSubirProducto extends StatefulWidget {
  final String tiendaId;
  final VoidCallback onClose;
  final VoidCallback onSuccess;

  const _ModalSubirProducto({
    required this.tiendaId,
    required this.onClose,
    required this.onSuccess,
  });

  @override
  State<_ModalSubirProducto> createState() => _ModalSubirProductoState();
}

class _ModalSubirProductoState extends State<_ModalSubirProducto> {
  final _db = FirebaseFirestore.instance;
  String _nombre = '', _descripcion = '', _uso = '', _precio = '';
  final List<String> _cultivos = [];
  bool _disponible = true;
  bool _loading = false;

  void _toggleCultivo(String id) {
    setState(() {
      _cultivos.contains(id) ? _cultivos.remove(id) : _cultivos.add(id);
    });
  }

  Future<void> _submit() async {
    if (_nombre.isEmpty || _descripcion.isEmpty || _cultivos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Completa nombre, descripción y al menos un cultivo')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _db.collection('productos').add({
        'nombre': _nombre,
        'descripcion': _descripcion,
        'uso': _uso,
        'cultivos': _cultivos,
        'precio': _precio,
        'disponible': _disponible,
        'tiendaId': widget.tiendaId,
        'createdAt': DateTime.now().toIso8601String(),
      });
      widget.onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error al guardar')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Agregar Producto',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            )),
                        GestureDetector(
                            onTap: widget.onClose,
                            child: const Icon(Icons.close, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _field('Nombre del producto *', 'Ej: Mancozeb 80% WP',
                        (v) => _nombre = v),
                    const SizedBox(height: 10),
                    _field('Descripción *', '¿Para qué sirve este producto?',
                        (v) => _descripcion = v,
                        maxLines: 2),
                    const SizedBox(height: 10),
                    _field('Modo de uso', 'Ej: 2g/litro cada 7 días',
                        (v) => _uso = v),
                    const SizedBox(height: 10),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('Cultivos compatibles *',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ))),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: kCultivos
                          .map((c) => GestureDetector(
                              onTap: () => _toggleCultivo(c.id),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _cultivos.contains(c.id)
                                        ? AppTheme.primary
                                        : const Color(0xFFf3f4f6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text('${c.emoji} ${c.nombre}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _cultivos.contains(c.id)
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      )))))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    _field('Precio referencial (S/)', 'Ej: 25.00',
                        (v) => _precio = v,
                        inputType: TextInputType.number),
                    const SizedBox(height: 10),
                    Row(children: [
                      Checkbox(
                        value: _disponible,
                        onChanged: (v) =>
                            setState(() => _disponible = v ?? true),
                        activeColor: AppTheme.primary,
                      ),
                      const Text('Disponible ahora',
                          style: TextStyle(fontSize: 13)),
                    ]),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                            _loading ? 'Guardando...' : 'Agregar producto',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    String hint,
    void Function(String) onChanged, {
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              )),
          const SizedBox(height: 4),
          TextField(
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: inputType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.borderColor)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.borderColor)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.primary)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      );
}
