import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'pq_session.dart';

final class EncryptedMessage {
  final int version;
  final String sessionId;
  final int counter;
  final Uint8List nonce;
  final Uint8List ciphertext;
  final Uint8List mac;
  const EncryptedMessage({required this.version, required this.sessionId, required this.counter, required this.nonce, required this.ciphertext, required this.mac});
  String encode() => jsonEncode({'v': version, 'sessionId': sessionId, 'counter': counter, 'nonce': base64Encode(nonce), 'ciphertext': base64Encode(ciphertext), 'mac': base64Encode(mac)});
}

final class EncryptedMessageService {
  final AesGcm cipher;
  const EncryptedMessageService({AesGcm? cipher}) : cipher = cipher ?? const AesGcm.with256bits();

  Future<EncryptedMessage> encrypt(PqSession session, String plaintext) async {
    final counter = session.sendCounter;
    final key = await session.nextSendKey();
    final aad = Uint8List.fromList(utf8.encode('${session.sessionId}:$counter:v1'));
    final box = await cipher.encrypt(Uint8List.fromList(utf8.encode(plaintext)), secretKey: SecretKey(key), aad: aad);
    return EncryptedMessage(version: 1, sessionId: session.sessionId, counter: counter, nonce: Uint8List.fromList(box.nonce), ciphertext: Uint8List.fromList(box.cipherText), mac: Uint8List.fromList(box.mac.bytes));
  }

  Future<String> decrypt(PqSession session, EncryptedMessage message) async {
    if (message.version != 1 || message.sessionId != session.sessionId) throw const FormatException('Invalid encrypted message envelope');
    if (message.counter != session.receiveCounter) throw StateError('Unexpected message counter');
    final key = await session.nextReceiveKey();
    final aad = Uint8List.fromList(utf8.encode('${message.sessionId}:${message.counter}:v1'));
    final plaintext = await cipher.decrypt(SecretBox(message.ciphertext, nonce: message.nonce, mac: Mac(message.mac)), secretKey: SecretKey(key), aad: aad);
    return utf8.decode(plaintext);
  }
}
