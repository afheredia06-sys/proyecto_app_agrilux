// lib/screens/registro_screen.dart
// Equivalente a src/pages/Registro.jsx

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_theme.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  // Equivalente a: const [nombre, setNombre] = useState('')
  final _controller = TextEditingController();
  bool get _puedeEntrar => _controller.text.trim().isNotEmpty;

  // Equivalente a handleEntrar()
  Future<void> _handleEntrar() async {
    if (!_puedeEntrar) return;
    final auth = context.read<AuthProvider>();
    await auth.registerUser({
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'nombre': _controller.text.trim(),
      'ubicacion': 'Perú',
      'tipo': 'agricultor',
      'whatsapp': '',
    });
    // Equivalente a navigate('/diagnostico')
    // En Flutter el navigate lo maneja main.dart automáticamente
    // cuando auth.isLoggedIn cambia a true
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Equivalente a: background: linear-gradient(160deg, #f0faf4, #e8f5ee)
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFf0faf4), Color(0xFFe8f5ee)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    // ── Logo y título ──────────────────────────────────────
                    // Equivalente a: w-24 h-24 bg-primary rounded-3xl
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🌾', style: TextStyle(fontSize: 48)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Equivalente a: text-4xl font-display font-bold text-primary
                    const Text(
                      'AGRILUX',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Agricultura Inteligente del Perú',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Card blanca ───────────────────────────────────────
                    // Equivalente a: bg-white rounded-3xl shadow-xl p-8
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '¿Cómo te llamas?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1f2937),
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Solo necesitamos tu nombre para comenzar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Equivalente a: <input value={nombre} onChange={...} />
                          TextField(
                            controller: _controller,
                            autofocus: true,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _handleEntrar(),
                            style: const TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Ej: Juan Pérez',
                              filled: true,
                              fillColor: const Color(0xFFf9fafb),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFf3f4f6),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFf3f4f6),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppTheme.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Equivalente a: <button disabled={!nombre.trim()}>
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _puedeEntrar ? _handleEntrar : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppTheme.primary.withValues(alpha: 0.4),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor:
                                    AppTheme.primary.withValues(alpha: 0.3),
                              ),
                              child: const Text(
                                'Comenzar →',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Equivalente a: text-xs text-gray-400
                    const Text(
                      'Al continuar aceptas usar la app con fines agrícolas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
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
}
