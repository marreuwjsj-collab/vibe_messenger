import 'dart:convert';
import 'dart:typed_data';

import '../../../core/security/aead_cipher.dart';
import '../../../core/security/post_quantum.dart';

final class EncryptedMessageEnvelope {
  final int version;
  final String algorithmSuite;
  final String senderKeyId;
  final Uint8List ciphertext;
  final Uint8List nonce;
  final Uint8List mac;
  final Uint8List? kemCiphertext;
  final Uint8List? signature;

  const EncryptedMessageEnvelope({
    required this.version,
    required this.algorithmSuite,
    required this.senderKeyId,
    required this.ciphertext,
    required this.nonce,
    required this.mac,
    this.kemCiphertext,
    this.signature,
  });

  Map<String, dynamic> toJson() => {
        'v': version,
        'suite': algorithmSuite,
        'sender_key_id': senderKeyId,
        'ciphertext': base64UrlEncode(ciphertext),
        'nonce': base64UrlEncode(nonce),
        'mac': base64UrlEncode(mac),
        if (kemCiphertext != null) 'kem_ct': base64UrlEncode(kemCiphertext!),
        if (signature != null) 'sig': base64UrlEncode(signature!),
      };
}

/// Message-level E2EE boundary. The server should only ever receive the envelope.
abstract interface class MessageCrypto {
  Future<EncryptedMessageEnvelope> encryptMessage({
    required String senderKeyId,
    required Uint8List plaintext,
    required Uint8List messageKey,
    Uint8List? kemCiphertext,
    Uint8List? signature,
  });

  Future<Uint8List> decryptMessage(EncryptedMessageEnvelope envelope, Uint8List messageKey);
}

final class AeadMessageCrypto implements MessageCrypto {
  final AeadCipher cipher;
  const AeadMessageCrypto(this.cipher);

  @override
  Future<EncryptedMessageEnvelope> encryptMessage({required String senderKeyId, required Uint8List plaintext, required Uint8List messageKey, Uint8List? kemCiphertext, Uint8List? signature}) async {
    final encrypted = await cipher.encrypt(plaintext: plaintext, key: messageKey);
    return EncryptedMessageEnvelope(
      version: 1,
      algorithmSuite: 'HYBRID-PQC-AES256GCM',
      senderKeyId: senderKeyId,
      ciphertext: encrypted.ciphertext,
      nonce: encrypted.nonce,
      mac: encrypted.mac,
      kemCiphertext: kemCiphertext,
      signature: signature,
    );
  }

  @override
  Future<Uint8List> decryptMessage(EncryptedMessageEnvelope envelope, Uint8List messageKey) {
    return cipher.decrypt(
      payload: EncryptedPayload(nonce: envelope.nonce, ciphertext: envelope.ciphertext, mac: envelope.mac),
      key: messageKey,
    );
  }
}
