class Completion {
  final int id;
  final int habitId;
  final DateTime completedAt;

  Completion({
    required this.id,
    required this.habitId,
    required this.completedAt,
  });

  bool isSameDay(DateTime date) {
    return completedAt.year == date.year &&
        completedAt.month == date.month &&
        completedAt.day == date.day;
  }
}