import 'package:flutter/material.dart';
import 'package:nexo/core/theme/app_theme.dart';

// barra de progresso diário - completados / total
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
                const Text('Progresso diário'),
                Text('$percent%',
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            Text('$completed de $total hábitos concluídos',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}