import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

final class ProtectedSession {
  final int version;
  final Uint8List nonce;
  final Uint8List ciphertext;
  final Uint8List mac;

  const ProtectedSession({required this.version, required this.nonce, required this.ciphertext, required this.mac});

  String encode() => jsonEncode({
        'v': version,
        'nonce': base64Encode(nonce),
        'ciphertext': base64Encode(ciphertext),
        'mac': base64Encode(mac),
      });

  static ProtectedSession decode(String value) {
    final map = jsonDecode(value);
    if (map is! Map<String, dynamic> || map['v'] != 1) throw const FormatException('Unsupported protected session');
    return ProtectedSession(
      version: 1,
      nonce: base64Decode(map['nonce'] as String),
      ciphertext: base64Decode(map['ciphertext'] as String),
      mac: base64Decode(map['mac'] as String),
    );
  }
}

final class SessionProtector {
  final AesGcm _cipher;
  SessionProtector({AesGcm? cipher}) : _cipher = cipher ?? AesGcm.with256bits();

  Future<ProtectedSession> protect({required Uint8List plaintext, required SecretKey key, Uint8List? aad}) async {
    final box = await _cipher.encrypt(plaintext, secretKey: key, aad: aad ?? const <int>[]);
    return ProtectedSession(
      version: 1,
      nonce: Uint8List.fromList(box.nonce),
      ciphertext: Uint8List.fromList(box.cipherText),
      mac: Uint8List.fromList(box.mac.bytes),
    );
  }

  Future<Uint8List> unprotect({required ProtectedSession protected, required SecretKey key, Uint8List? aad}) async {
    final box = SecretBox(protected.ciphertext, nonce: protected.nonce, mac: Mac(protected.mac));
    return Uint8List.fromList(await _cipher.decrypt(box, secretKey: key, aad: aad ?? const <int>[]));
  }
}
