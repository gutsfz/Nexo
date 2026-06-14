import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_theme.dart';

// tela de detalhe do hábito
// recebe o id via parâmetro de rota (go_router)
// por enquanto com dados mockados — RN-06, RN-07, RN-08 do documento
class HabitDetailScreen extends StatelessWidget {
  final int habitId;

  const HabitDetailScreen({required this.habitId, super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // mock — depois vem do provider buscando pelo habitId
    const emoji = '🧘';
    const name = 'Meditação Matinal';
    const category = 'Mindfulness';
    const streak = 14;
    const completionRate = 72; // RN-06: completions / dias agendados
    const totalDays = 38;
    final weekStatus = [true, true, false, true, true, false, true];
    const weekLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];

    // mock do heatmap — 30 dias, intensidade 0 a 3 (RN-08)
    final heatmap = List.generate(30, (i) => i % 4);

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // emoji e nome
          Center(
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                Text('Categoria: $category',
                    style: TextStyle(
                        color: onSurface.withValues(alpha: 0.6),
                        fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // estatísticas: streak, taxa de conclusão, dias totais
          Row(
            children: [
              _StatBox(
                icon: Icons.local_fire_department,
                iconColor: Colors.orange,
                value: '$streak',
                label: 'streak',
              ),
              const SizedBox(width: 12),
              _StatBox(
                icon: Icons.percent,
                iconColor: primaryColor,
                value: '$completionRate%',
                label: 'concl.',
              ),
              const SizedBox(width: 12),
              _StatBox(
                icon: Icons.calendar_month,
                iconColor: primaryColor,
                value: '$totalDays',
                label: 'dias',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // dias da semana agendados
          const Text('DIAS DA SEMANA',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return Column(
                children: [
                  Text(weekLabels[i],
                      style: TextStyle(
                          color: onSurface.withValues(alpha: 0.6),
                          fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: weekStatus[i]
                          ? primaryColor
                          : onSurface.withValues(alpha: 0.1),
                    ),
                    child: weekStatus[i]
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 24),

          // heatmap dos últimos 30 dias
          const Text('ÚLTIMOS 30 DIAS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: heatmap.map((intensity) {
              return Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: intensity == 0
                      ? onSurface.withValues(alpha: 0.1)
                      : primaryColor.withValues(alpha: 0.25 * intensity),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // botões de ação
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // editar — abre o formulário com dados preenchidos
                  },
                  child: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmDelete(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Excluir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // RN-07: pede confirmação antes de excluir
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir hábito'),
        content: const Text(
            'Tem certeza? Isso vai remover o hábito e todo o histórico.'),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              dialogContext.pop(); // fecha o dialog
              context.pop(); // volta para a home
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

// card pequeno para mostrar uma estatística
class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(height: 4),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ),
    );
  }
}