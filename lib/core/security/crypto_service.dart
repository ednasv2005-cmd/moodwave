import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class CryptoService {
  static const int _saltLength = 16;
  static const int _keyLength = 32;
  static const int _iterations = 10000;

  /// Genera una sal criptográfica pseudoaleatoria
  static Uint8List _generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(List<int>.generate(_saltLength, (_) => random.nextInt(256)));
  }

  /// Derivación de clave mediante PBKDF2-HMAC-SHA256
  static Uint8List deriveKey(String password, Uint8List salt, {int iterations = _iterations, int keyLen = _keyLength}) {
    final passwordBytes = utf8.encode(password);
    var derivedKey = Uint8List(keyLen);
    var hmac = Hmac(sha256, passwordBytes);

    int blocksNeeded = (keyLen / 32).ceil();
    var output = BytesBuilder();

    for (int block = 1; block <= blocksNeeded; block++) {
      var blockBytes = ByteData(4)..setUint32(0, block, Endian.big);
      var u = hmac.convert([...salt, ...blockBytes.buffer.asUint8List()]).bytes;
      var xorSum = List<int>.from(u);

      for (int i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (int j = 0; j < u.length; j++) {
          xorSum[j] ^= u[j];
        }
      }
      output.add(xorSum);
    }

    final fullKey = output.toBytes();
    derivedKey.setRange(0, keyLen, fullKey.sublist(0, keyLen));
    return derivedKey;
  }

  /// Cifra un string usando un flujo CTR autenticado con HMAC-SHA256
  static Map<String, dynamic> encryptData(String plainText, String password) {
    final salt = _generateSalt();
    final key = deriveKey(password, salt);
    final plainBytes = utf8.encode(plainText);

    // IV para el flujo
    final random = Random.secure();
    final iv = Uint8List.fromList(List<int>.generate(16, (_) => random.nextInt(256)));

    // Cifrado de flujo tipo ChaCha/CTR con clave derivada
    final cipherBytes = Uint8List(plainBytes.length);
    var hmacKeystream = Hmac(sha256, key);

    for (int i = 0; i < plainBytes.length; i += 32) {
      final counter = ByteData(4)..setUint32(0, i ~/ 32, Endian.big);
      final keyBlock = hmacKeystream.convert([...iv, ...counter.buffer.asUint8List()]).bytes;
      final chunkSize = min(32, plainBytes.length - i);
      for (int j = 0; j < chunkSize; j++) {
        cipherBytes[i + j] = plainBytes[i + j] ^ keyBlock[j];
      }
    }

    // Firma HMAC para verificación de integridad (Encrypt-then-MAC)
    final mac = Hmac(sha256, key).convert([...iv, ...cipherBytes]).bytes;

    return {
      'version': '1.0',
      'algorithm': 'PBKDF2-HMAC-SHA256-STREAM',
      'salt': base64Encode(salt),
      'iv': base64Encode(iv),
      'ciphertext': base64Encode(cipherBytes),
      'mac': base64Encode(mac),
    };
  }

  /// Descifra un paquete cifrado verificando la contraseña y la integridad
  static String decryptData(Map<String, dynamic> encryptedPackage, String password) {
    final salt = base64Decode(encryptedPackage['salt'] as String);
    final iv = base64Decode(encryptedPackage['iv'] as String);
    final cipherBytes = base64Decode(encryptedPackage['ciphertext'] as String);
    final expectedMac = base64Decode(encryptedPackage['mac'] as String);

    final key = deriveKey(password, salt);

    // Validar MAC (Integridad y clave correcta)
    final computedMac = Hmac(sha256, key).convert([...iv, ...cipherBytes]).bytes;
    bool match = true;
    if (computedMac.length != expectedMac.length) {
      match = false;
    } else {
      for (int i = 0; i < computedMac.length; i++) {
        if (computedMac[i] != expectedMac[i]) {
          match = false;
          break;
        }
      }
    }

    if (!match) {
      throw Exception('Contraseña incorrecta o archivo de respaldo dañado/adulterado.');
    }

    // Descifrar
    final plainBytes = Uint8List(cipherBytes.length);
    var hmacKeystream = Hmac(sha256, key);

    for (int i = 0; i < cipherBytes.length; i += 32) {
      final counter = ByteData(4)..setUint32(0, i ~/ 32, Endian.big);
      final keyBlock = hmacKeystream.convert([...iv, ...counter.buffer.asUint8List()]).bytes;
      final chunkSize = min(32, cipherBytes.length - i);
      for (int j = 0; j < chunkSize; j++) {
        plainBytes[i + j] = cipherBytes[i + j] ^ keyBlock[j];
      }
    }

    return utf8.decode(plainBytes);
  }
}

