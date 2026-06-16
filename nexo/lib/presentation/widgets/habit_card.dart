import 'package:flutter/material.dart';
import 'package:nexo/core/theme/app_theme.dart';

// card de um hábito na lista da home
class HabitCard extends StatefulWidget {
  final String emoji;
  final String name;
  final String category;
  final int streak;
  final bool isCompleted;
  final List<bool> weekStatus;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final Widget? dragHandle;

  const HabitCard({
    required this.emoji,
    required this.name,
    required this.category,
    required this.streak,
    required this.isCompleted,
    required this.weekStatus,
    required this.onToggle,
    required this.onTap,
    this.dragHandle,
    super.key,
  });

  static const _weekLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    _scaleController.forward(from: 0.0);
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (widget.dragHandle != null) ...[
                widget.dragHandle!,
                const SizedBox(width: 4),
              ],
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(widget.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        )),
                    Text(widget.name,
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
                                  color: widget.weekStatus[i]
                                      ? primaryColor
                                      : onSurface.withValues(alpha: 0.2),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(HabitCard._weekLabels[i],
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
                    Text(' ${widget.streak}', style: TextStyle(color: onSurface)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _handleToggle,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isCompleted
                          ? primaryColor
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.isCompleted
                            ? primaryColor
                            : onSurface.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: widget.isCompleted
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
