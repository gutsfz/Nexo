import 'package:flutter/material.dart';
import 'package:nexo/core/theme/app_theme.dart';

// card de um hábito na lista da home
class HabitCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String category;
  final int streak;
  final bool isCompleted;
  final List<bool> weekStatus;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const HabitCard({
    required this.emoji,
    required this.name,
    required this.category,
    required this.streak,
    required this.isCompleted,
    required this.weekStatus,
    required this.onToggle,
    required this.onTap,
    super.key,
  });

  static const _weekLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: onSurface)),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(7, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Column(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: weekStatus[i]
                                      ? primaryColor
                                      : onSurface.withValues(alpha: 0.2),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(_weekLabels[i],
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: onSurface.withValues(alpha: 0.6))),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.orange, size: 18),
                    Text(' $streak', style: TextStyle(color: onSurface)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? primaryColor : Colors.transparent,
                    border: Border.all(
                      color: isCompleted
                          ? primaryColor
                          : onSurface.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}