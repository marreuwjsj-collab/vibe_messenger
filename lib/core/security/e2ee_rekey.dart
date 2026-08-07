import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

final class E2eeRekey {
  static final _hkdf=Hkdf(hmac: Hmac.sha256(), outputLength:32);
  static Future<Uint8List> derive(Uint8List root, Uint8List authenticatedSecret, int epoch) async {
    if(root.length!=32||authenticatedSecret.isEmpty)throw ArgumentError('Invalid rekey material');
    final info=Uint8List.fromList('VIBE-E2EE-REKEY-V1:$epoch'.codeUnits);
    final out=await _hkdf.deriveKey(secretKey:SecretKey(root),nonce:authenticatedSecret,info:info);
    return Uint8List.fromList(await out.extractBytes());
  }
}
