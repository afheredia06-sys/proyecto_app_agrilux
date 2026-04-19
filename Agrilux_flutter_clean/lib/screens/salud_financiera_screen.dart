import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class SaludFinancieraScreen extends StatelessWidget {
  const SaludFinancieraScreen({super.key});

  static const _items = [
    'Solicitar micro-créditos para tu campaña agrícola',
    'Pagar en cuotas según tu cosecha',
    'Historial crediticio basado en tus ventas',
    'Tasas preferenciales para agricultores registrados',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SingleChildScrollView(
        child: Column(children: [
          // ── Header ──────────────────────────────────────────────────────
          // Equivalente a: bg-amber-500 text-white
          Container(
            color: Colors.amber.shade500,
            padding: const EdgeInsets.fromLTRB(24, 52, 24, 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Salud Financiera',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
                SizedBox(height: 4),
                Text('Micro-Crédito Disponible',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    )),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // ── Card principal ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.card(),
                child: Column(children: [
                  // Header card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Icon(Icons.credit_card,
                            color: Colors.amber.shade500, size: 24),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Crédito Disponible',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                )),
                            Text('Micro-Crédito Agrilux',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ]),
                      // Badge "PRÓXIMAMENTE"
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('PRÓXIMAMENTE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.amber.shade700,
                            )),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Monto
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Crédito disponible',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('S/ 0.00',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1f2937),
                            )),
                        Text('Usado: S/ 0.00 (0%)',
                            style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Barra de progreso
                  // Equivalente a: bg-gray-100 rounded-xl
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf3f4f6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber.shade400),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón deshabilitado
                  // Equivalente a: disabled cursor-not-allowed
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.lock_outline),
                      label: const Text('Solicitar Micro-préstamo',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey,
                        disabledBackgroundColor: Colors.grey.shade200,
                        disabledForegroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                      'Estamos trabajando con aliados financieros para habilitar esta opción pronto',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ]),
              ),

              const SizedBox(height: 12),

              // ── Card próximamente ────────────────────────────────────────
              // Equivalente a: bg-amber-50 border border-amber-200
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('¿Qué podrás hacer próximamente?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.amber.shade700,
                        )),
                    const SizedBox(height: 10),
                    // Equivalente a: ul con li
                    ..._items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('✓ ',
                                  style: TextStyle(
                                    color: Colors.amber.shade600,
                                    fontWeight: FontWeight.w700,
                                  )),
                              Expanded(
                                  child: Text(item,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.amber.shade700,
                                        height: 1.4,
                                      ))),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ]),
          ),
        ]),
      ),
    );
  }
}
