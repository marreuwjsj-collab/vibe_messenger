import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'prekey_bundle.dart';

abstract final class PreKeyTranscript {
  static Uint8List encode({required int version, required Uint8List identityKey, required Uint8List signedPreKey}) {
    final map = <String, Object>{
      'version': version,
      'identityKey': base64Encode(identityKey),
      'signedPreKey': base64Encode(signedPreKey),
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(map)));
  }

  static Future<Uint8List> digest({required PreKeyBundle bundle}) async {
    final bytes = encode(
      version: bundle.version,
      identityKey: bundle.identityKey,
      signedPreKey: bundle.signedPreKey,
    );
    final hash = await Sha256().hash(bytes);
    return Uint8List.fromList(hash.bytes);
  }
}
