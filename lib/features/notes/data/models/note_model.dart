class NoteModel {
  const NoteModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isIdea = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isIdea;

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[createdAt.month - 1];
    final year = createdAt.year.toString().substring(2);
    return '${createdAt.day} $month, $year';
  }

  String get dayOfWeek {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[createdAt.weekday - 1];
  }

  String get preview {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 'No content yet';
    return trimmed.length > 120 ? '${trimmed.substring(0, 120)}...' : trimmed;
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isIdea,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isIdea: isIdea ?? this.isIdea,
    );
  }
}
