// lib/config/app_theme.dart
// Equivalente a src/index.css + tailwind.config.js

import 'package:flutter/material.dart';

class AppTheme {
  // ── Colores ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1a6b3c);
  static const Color primaryDark = Color(0xFF145530);
  static const Color primaryLight = Color(0xFF2d8f55);
  static const Color accent = Color(0xFFf5a623);
  static const Color earth = Color(0xFF5d4e37);
  static const Color bg = Color(0xFFf8faf8);
  static const Color textMain = Color(0xFF1a1a1a);
  static const Color textMuted = Color(0xFF6b7280);
  static const Color borderColor = Color(0xFFe5e7eb);

  // ── Gradiente ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Animaciones ──────────────────────────────────────────────────────────
  static const Duration fadeInDuration = Duration(milliseconds: 300);
  static const Curve fadeInCurve = Curves.easeOut;

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        fontFamily: 'PlusJakartaSans',
        colorScheme: const ColorScheme.light(
          primary: primary,
          onPrimary: Colors.white,
          secondary: accent,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: textMain,
          error: Color(0xFFef4444),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: borderColor),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          hintStyle: const TextStyle(color: textMuted, fontSize: 13),
          labelStyle: const TextStyle(color: textMuted, fontSize: 13),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borderColor),
          ),
          margin: const EdgeInsets.only(bottom: 10),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primary,
          unselectedItemColor: textMuted,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(fontSize: 10),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFf3f4f6),
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        ),
        dividerTheme: const DividerThemeData(
          color: borderColor,
          thickness: 1,
          space: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800, color: textMain),
          headlineMedium: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800, color: textMain),
          headlineSmall: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: textMain),
          titleLarge: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: textMain),
          titleMedium: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: textMain),
          bodyLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textMain,
              height: 1.5),
          bodyMedium: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: textMain,
              height: 1.5),
          bodySmall: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w400, color: textMuted),
          labelSmall: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textMuted,
              letterSpacing: 0.5),
        ),
      );
}

// ── Estilos de texto reutilizables ───────────────────────────────────────────
class AppTextStyles {
  static const TextStyle displayBold = TextStyle(
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    fontSize: 22,
    color: AppTheme.textMain,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppTheme.textMuted,
    letterSpacing: 0.8,
  );

  static const TextStyle priceText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppTheme.primary,
  );
}

// ── Decoraciones reutilizables ───────────────────────────────────────────────
class AppDecorations {
  static BoxDecoration card({double radius = 16}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration cardGreen({double radius = 16}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppTheme.primary),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
          ),
        ],
      );

  static BoxDecoration greenLight({double radius = 10}) => BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius),
      );

  static BoxDecoration get badgeGreen => BoxDecoration(
        color: const Color(0xFFdcfce7),
        borderRadius: BorderRadius.circular(20),
      );

  static BoxDecoration get badgeAmber => BoxDecoration(
        color: const Color(0xFFfef3c7),
        borderRadius: BorderRadius.circular(20),
      );

  static BoxDecoration get badgeRed => BoxDecoration(
        color: const Color(0xFFfee2e2),
        borderRadius: BorderRadius.circular(20),
      );
}

// ── Widget FadeIn — equivalente a .animate-fadeIn ────────────────────────────
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const FadeInWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppTheme.fadeInDuration,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: AppTheme.fadeInCurve),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: AppTheme.fadeInCurve),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: widget.child,
        ),
      );
}

// ── Widget PulseGreen — equivalente a .pulse-green ───────────────────────────
class PulseGreenWidget extends StatefulWidget {
  final Widget child;
  const PulseGreenWidget({super.key, required this.child});

  @override
  State<PulseGreenWidget> createState() => _PulseGreenWidgetState();
}

class _PulseGreenWidgetState extends State<PulseGreenWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(
                alpha: 0.4 * (1 - _anim.value / 8),
              ),
              blurRadius: _anim.value,
              spreadRadius: _anim.value / 2,
            ),
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ── Widget AppLayout430 — equivalente a max-width: 430px ─────────────────────
class AppLayout430 extends StatelessWidget {
  final Widget child;
  const AppLayout430({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: child,
      ),
    );
  }
}

// ── Widget BgOverlay — equivalente a body::before overlay ────────────────────
class BgOverlay extends StatelessWidget {
  final Widget child;
  const BgOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppTheme.bg),
        child,
      ],
    );
  }
}
