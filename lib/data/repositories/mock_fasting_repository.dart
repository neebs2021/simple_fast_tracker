import '../../domain/entities/fasting_session.dart';

class MockFastingRepository {
  Future<List<FastingSession>> getHistory() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate net
    final now = DateTime.now();
    return List.generate(10, (index) {
      final start = now.subtract(Duration(days: index + 1, hours: 18));
      final end = start.add(Duration(hours: 16));
      return FastingSession(
        id: 'history_$index',
        startTime: start,
        endTime: end,
      );
    });
  }
}
