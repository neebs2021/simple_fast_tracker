import 'package:flutter_test/flutter_test.dart';
import 'package:simple_fast_tracker/domain/entities/fasting_session.dart';

void main() {
  group('FastingSession Tests', () {
    test('should calculate duration correctly for active session', () {
      final start = DateTime.now().subtract(const Duration(hours: 2));
      final session = FastingSession(id: '1', startTime: start);
      
      expect(session.isActive, true);
      // Allow for small time difference during test execution
      expect(session.duration.inMinutes, closeTo(120, 1));
    });

    test('should calculate duration correctly for completed session', () {
      final start = DateTime(2023, 1, 1, 10, 0);
      final end = DateTime(2023, 1, 1, 14, 0); // 4 hours later
      final session = FastingSession(id: '1', startTime: start, endTime: end);
      
      expect(session.isActive, false);
      expect(session.duration.inHours, 4);
    });
  });
}
