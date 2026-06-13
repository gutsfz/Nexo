import 'package:flutter/material.dart';
import 'package:nexo/core/theme/app_theme.dart';

// card que mostra a citação do dia na home
class QuoteCard extends StatelessWidget {
  final String content;
  final String author;
  final VoidCallback onRefresh;

  const QuoteCard({
    required this.content,
    required this.author,
    required this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                Text('Citação do dia',
                    style: TextStyle(color: primaryColor, fontSize: 12)),
                GestureDetector(
                  onTap: onRefresh,
                  child: Icon(Icons.refresh, size: 18, color: onSurface),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('"$content"',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: onSurface)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('— $author',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: onSurface.withValues(alpha: 0.7))),
            ),
          ],
        ),
      ),
    );
  }
}