import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexo/core/theme/app_theme.dart';

const _filterKey = 'history_filter'; // RN-21

// opções de período disponíveis
enum HistoryPeriod { week, month }

extension HistoryPeriodLabel on HistoryPeriod {
  String get label =>
      this == HistoryPeriod.week ? 'Últimos 7 dias' : 'Último mês';
}

// tela de histórico — completions por período (RN-20)
// dados mockados por enquanto, virá do provider de completions
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryPeriod _selectedPeriod = HistoryPeriod.week;

  @override
  void initState() {
    super.initState();
    _restoreFilter();
  }

  // RN-21: restaura o filtro salvo
  Future<void> _restoreFilter() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_filterKey);
    if (saved == 'month') {
      setState(() => _selectedPeriod = HistoryPeriod.month);
    }
  }

  // RN-21: salva o filtro escolhido
  Future<void> _saveFilter(HistoryPeriod period) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _filterKey,
      period == HistoryPeriod.week ? 'week' : 'month',
    );
  }

  void _onPeriodChanged(HistoryPeriod period) {
    setState(() => _selectedPeriod = period);
    _saveFilter(period);
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // mock de dados — completions por dia
    // formato: dia da semana, concluídos, total agendado
    final mockData = _selectedPeriod == HistoryPeriod.week
        ? [
            ('Dom', 4, 5),
            ('Sáb', 5, 5),
            ('Sex', 3, 5),
            ('Qui', 2, 5),
            ('Qua', 5, 5),
            ('Ter', 3, 5),
            ('Seg', 4, 5),
          ]
        : List.generate(30, (i) => ('Dia ${30 - i}', (i % 5) + 1, 5));

    // RN-23: taxa média = média das taxas diárias
    final rates = mockData.map((d) => d.$2 / d.$3).toList();
    final avgRate = (rates.reduce((a, b) => a + b) / rates.length * 100)
        .round();

    // melhor dia
    final best = mockData.reduce((a, b) => a.$2 / a.$3 > b.$2 / b.$3 ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          PopupMenuButton<HistoryPeriod>(
            initialValue: _selectedPeriod,
            onSelected: _onPeriodChanged,
            itemBuilder: (context) => HistoryPeriod.values
                .map((p) => PopupMenuItem(value: p, child: Text(p.label)))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(_selectedPeriod.label),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // lista de dias com barra de progresso
          ...mockData.map((day) {
            final (label, completed, total) = day;
            final progress = total == 0 ? 0.0 : completed / total;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Text(
                      label,
                      style: TextStyle(color: onSurface, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 16,
                        backgroundColor: onSurface.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '$completed/$total',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // resumo — taxa média e melhor dia (RN-23)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$avgRate%',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Taxa média'),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 18,
                          ),
                          Text(
                            ' ${best.$2}/${best.$3}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text('Melhor dia'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
