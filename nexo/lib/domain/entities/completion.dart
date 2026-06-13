// entidade que representa a conclusão de um hábito em um dia específico
class Completion {
  final int id;
  final int habitId;
  final DateTime completedAt;

  Completion({
    required this.id,
    required this.habitId,
    required this.completedAt,
  });

// verifica se a conclusão foi feita no mesmo dia que a data fornecida
  bool isSameDay(DateTime date) {
    return completedAt.year == date.year &&
        completedAt.month == date.month &&
        completedAt.day == date.day;
  }
}