import 'package:flutter/material.dart';

class StarMapScreen extends StatelessWidget {
  const StarMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(appBar: AppBar(title: const Text('Star map'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.my_location))]), body: Padding(padding: const EdgeInsets.all(12), child: Container(height: 600, decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(18), border: Border.all(color: scheme.outlineVariant)), child: Stack(children: [
      const Positioned(top: 16, left: 0, right: 0, child: Center(child: Text('N'))), const Positioned(bottom: 16, left: 0, right: 0, child: Center(child: Text('S'))), const Positioned(top: 0, bottom: 0, left: 16, child: Center(child: Text('W'))), const Positioned(top: 0, bottom: 0, right: 16, child: Center(child: Text('E'))),
      Center(child: Container(width: 240, height: 240, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: scheme.outline, width: 1)), child: CustomPaint(painter: _StarsPainter(color: scheme.onSurface)))),
      Positioned(top: 120, left: 72, child: _Tag(label: 'Vega', color: scheme.tertiary)), Positioned(top: 250, right: 58, child: _Tag(label: 'M31', color: scheme.primary)), Positioned(bottom: 120, left: 108, child: _Tag(label: 'Cassiopeia', color: scheme.secondary)),
      Positioned(top: 46, right: 52, child: Icon(Icons.navigation, color: scheme.tertiary)), const Positioned(top: 42, right: 44, child: Text('ZENITH')),
    ]))));
  }
}

class _Tag extends StatelessWidget { const _Tag({required this.label, required this.color}); final String label; final Color color; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(8)), child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700))); }

class _StarsPainter extends CustomPainter { const _StarsPainter({required this.color}); final Color color; @override void paint(Canvas canvas, Size size) { final paint = Paint()..color = color.withValues(alpha: 0.8); for (final point in const [Offset(34, 28), Offset(74, 72), Offset(126, 42), Offset(180, 94), Offset(92, 148), Offset(152, 174), Offset(48, 194), Offset(202, 48)]) { canvas.drawCircle(point, 2.5, paint); } } @override bool shouldRepaint(covariant _StarsPainter oldDelegate) => oldDelegate.color != color; }