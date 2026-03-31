// lib/widgets/layout.dart
// Equivalente a src/components/Layout.jsx

import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final void Function(int) onTabChanged;

  const AppLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTabChanged,
  });

  // Equivalente a navItems en Layout.jsx
  static const _navItems = [
    {'label': 'Inicio', 'icon': Icons.home_outlined, 'iconActive': Icons.home},
    {
      'label': 'Diagnóstico',
      'icon': Icons.camera_alt_outlined,
      'iconActive': Icons.camera_alt,
    },
    {
      'label': 'Mi Parcela',
      'icon': Icons.eco_outlined,
      'iconActive': Icons.eco,
    },
    {
      'label': 'Comunidad',
      'icon': Icons.people_outline,
      'iconActive': Icons.people,
    },
    {
      'label': 'Más',
      'icon': Icons.more_horiz_outlined,
      'iconActive': Icons.more_horiz,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Equivalente a <main className="flex-1 pb-20 overflow-y-auto">
      body: child,

      // Equivalente a <nav className="fixed bottom-0 ...">
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final active = currentIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          // Equivalente a strokeWidth activo/inactivo
                          active
                              ? _navItems[i]['iconActive'] as IconData
                              : _navItems[i]['icon'] as IconData,
                          size: 22,
                          color: active
                              ? AppTheme.primary
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _navItems[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: active
                                ? AppTheme.primary
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
