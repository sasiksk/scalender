class Event {
  final int id;
  final String title;
  final DateTime date;
  final String description;
  String status;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.status,
  });
}
