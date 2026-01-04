import 'package:uuid/uuid.dart';

class FastingSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;

  FastingSession({
    required this.id,
    required this.startTime,
    this.endTime,
  });

  bool get isActive => endTime == null;

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  // Factory for mock/testing
  factory FastingSession.startNew() {
    return FastingSession(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
    };
  }

  factory FastingSession.fromJson(Map<String, dynamic> json) {
    return FastingSession(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
    );
  }
}
