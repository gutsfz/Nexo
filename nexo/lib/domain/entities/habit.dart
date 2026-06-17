// entidade que representa um hábito
class Habit {
  final int id;
  final String name;
  final String emoji;
  final String category;
  final List<int> weekdays; //dias da semana em que o hábito deve ser realizado (0-6, onde 0 é domingo)
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.weekdays,
    required this.createdAt,
  });

// weekday do dart: 1 = segunda, 7 = domingo → converte para índice 0-6
  bool isScheduledFor(DateTime date) {
    final index = date.weekday - 1; //converte para índice de 0 a 6
    return weekdays.contains(index);
  }
}