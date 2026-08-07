import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'post_quantum.dart';

final class AeadCipher {
  final Cipher _cipher = AesGcm.with256bits();

  Future<EncryptedPayload> encrypt({required Uint8List plaintext, required Uint8List key, Uint8List? aad}) async {
    if (key.length != 32) throw ArgumentError.value(key.length, 'key', 'AES-256 requires 32 bytes');
    final secretKey = SecretKey(key);
    final box = await _cipher.encrypt(plaintext, secretKey: secretKey, aad: aad ?? const <int>[]);
    return EncryptedPayload(nonce: Uint8List.fromList(box.nonce), ciphertext: Uint8List.fromList(box.cipherText), mac: Uint8List.fromList(box.mac.bytes));
  }

  Future<Uint8List> decrypt({required EncryptedPayload payload, required Uint8List key, Uint8List? aad}) async {
    if (key.length != 32) throw ArgumentError.value(key.length, 'key', 'AES-256 requires 32 bytes');
    final box = SecretBox(payload.ciphertext, nonce: payload.nonce, mac: Mac(payload.mac));
    final plaintext = await _cipher.decrypt(box, secretKey: SecretKey(key), aad: aad ?? const <int>[]);
    return Uint8List.fromList(plaintext);
  }
}

final class EncryptedPayload {
  final Uint8List nonce;
  final Uint8List ciphertext;
  final Uint8List mac;
  const EncryptedPayload({required this.nonce, required this.ciphertext, required this.mac});

  Map<String, String> toJson() => {
        'nonce': base64UrlEncode(nonce),
        'ciphertext': base64UrlEncode(ciphertext),
        'mac': base64UrlEncode(mac),
      };

  factory EncryptedPayload.fromJson(Map<String, dynamic> json) => EncryptedPayload(
        nonce: Uint8List.fromList(base64Url.decode(json['nonce'] as String)),
        ciphertext: Uint8List.fromList(base64Url.decode(json['ciphertext'] as String)),
        mac: Uint8List.fromList(base64Url.decode(json['mac'] as String)),
      );
}
