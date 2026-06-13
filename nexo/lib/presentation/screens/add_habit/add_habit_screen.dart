import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexo/core/theme/app_theme.dart';

// tela de criar novo hábito
// por enquanto sem salvar no banco — isso vem quando os repositories
// estiverem prontos. aqui é só o formulário e validação.
class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  static const _emojis = ['🧘', '📖', '🏃', '💧', '✍️', '🎯', '💪', '🎨', '🎵', '🌱'];
  String _selectedEmoji = _emojis.first;

  static const _categories = [
    'Mindfulness',
    'Aprendizado',
    'Fitness',
    'Saúde',
    'Produtividade',
  ];
  String _selectedCategory = _categories.first;

  static const _weekLabels = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB', 'DOM'];
  final List<bool> _selectedWeekdays = List.filled(7, false);

  // mensagem de erro dos dias da semana — null quando não há erro
  String? _weekdaysError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final isFormValid = _formKey.currentState!.validate();

    // RN-10: pelo menos 1 dia da semana selecionado
    setState(() {
      _weekdaysError = _selectedWeekdays.contains(true)
          ? null
          : 'Selecione pelo menos um dia da semana';
    });

    if (!isFormValid || _weekdaysError != null) return;

    final weekdaysString = _selectedWeekdays
        .asMap()
        .entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(',');

    debugPrint('Novo hábito: '
        'name=${_nameController.text}, '
        'emoji=$_selectedEmoji, '
        'category=$_selectedCategory, '
        'weekdays=$weekdaysString');

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Hábito')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // nome do hábito
            const Text('Nome do hábito',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'ex: Meditação matinal',
                hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.5)),
                border: const OutlineInputBorder(),
              ),
              // RN-09: nome obrigatório, mínimo 3 caracteres
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O nome é obrigatório';
                }
                if (value.trim().length < 3) {
                  return 'O nome deve ter no mínimo 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // emoji
            const Text('Emoji', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _emojis.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : onSurface.withValues(alpha: 0.2),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // categoria
            const Text('Categoria',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 24),

            // repetição semanal
            const Text('Repetição semanal',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final isSelected = _selectedWeekdays[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWeekdays[index] = !_selectedWeekdays[index];
                      if (_selectedWeekdays.contains(true)) {
                        _weekdaysError = null;
                      }
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : onSurface.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _weekLabels[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (_weekdaysError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _weekdaysError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}