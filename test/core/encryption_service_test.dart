import 'package:flutter_test/flutter_test.dart';
import 'package:simple_fast_tracker/core/services/encryption_service.dart';

void main() {
  group('EncryptionService Tests', () {
    late EncryptionService service;

    setUp(() {
      service = EncryptionService();
      // Initialize with a 32-character key
      service.init('12345678901234567890123456789012');
    });

    test('should encrypt and decrypt data correctly', () {
      const originalText = "Sensitive Data";
      
      final encrypted = service.encryptData(originalText);
      
      // Should be different from original
      expect(encrypted, isNot(equals(originalText)));
      // Should contain IV separator
      expect(encrypted.contains(':'), true);
      
      final decrypted = service.decryptData(encrypted);
      
      expect(decrypted, equals(originalText));
    });

    test('should handle empty string', () {
      final encrypted = service.encryptData("");
      final decrypted = service.decryptData(encrypted);
      expect(decrypted, equals(""));
    });
  });
}
