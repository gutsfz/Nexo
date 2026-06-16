import 'package:flutter/material.dart';
import 'package:nexo/core/theme/app_theme.dart';

// card que mostra o progresso diário na home
class ProgressBarCard extends StatelessWidget {
  final int completed;
  final int total;

  const ProgressBarCard({
    required this.completed,
    required this.total,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final percent = (progress * 100).round();
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progresso diário', style: TextStyle(color: onSurface)),
                Text('$percent%',
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: onSurface.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('$completed de $total hábitos concluídos',
                style: TextStyle(
                    fontSize: 12, color: onSurface.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}
