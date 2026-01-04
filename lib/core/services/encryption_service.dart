import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  // Singleton pattern
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  late encrypt.Encrypter _encrypter;
  late encrypt.Key _key;
  
  // Initialize with a secure key. 
  // In production, this should come from secure storage or user input (e.g. derived from password).
  void init(String keyString) {
    // Ensure key is 32 bytes (256 bits)
    // If keyString is less, pad it; if more, trim it (simple approach for this task)
    // Better approach: Use Key.fromBase64 if properly generated, or SHA-256 hash of the string.
    _key = encrypt.Key.fromUtf8(keyString.padRight(32).substring(0, 32));
    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  }

  /// Encrypts a string and returns a base64 encoded string containing IV + CipherText
  String encryptData(String plainText) {
    if (plainText.isEmpty) return "";
    
    final iv = encrypt.IV.fromLength(16); // Random IV
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    // Combine IV and Encrypted data to allow decryption
    // Format: base64(iv) : base64(ciphertext)
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts a string in the format base64(iv) : base64(ciphertext)
  String decryptData(String encryptedString) {
    if (encryptedString.isEmpty) return "";
    
    try {
      final parts = encryptedString.split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid encrypted data format');
      }
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print('Decryption Error: $e');
      return ''; // Return empty on error
    }
  }

  String encryptWithCustomKey(String plainText, String keyStr) {
    if (plainText.isEmpty) return "";
    final key = encrypt.Key.fromUtf8(keyStr); // Ensure caller handles padding/length
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final iv = encrypt.IV.fromLength(16);
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decryptWithCustomKey(String encryptedString, String keyStr) {
    if (encryptedString.isEmpty) return "";
    try {
      final parts = encryptedString.split(':');
      if (parts.length != 2) throw FormatException('Invalid format');
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      final key = encrypt.Key.fromUtf8(keyStr);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print('Custom Decrypt Error: $e');
      rethrow; 
    }
  }
}
