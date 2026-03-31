import 'package:flutter/material.dart';

class MasScreen extends StatelessWidget {
  final VoidCallback onAdmin;
  const MasScreen({super.key, required this.onAdmin});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Más')));
}
