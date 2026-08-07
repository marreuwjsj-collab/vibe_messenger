import 'dart:convert';
import 'dart:typed_data';

import 'prekey_bundle.dart';

abstract final class PreKeySerializer {
  static String encode(PreKeyBundle bundle) => jsonEncode({
        'version': bundle.version,
        'identityKey': base64Encode(bundle.identityKey),
        'signedPreKey': base64Encode(bundle.signedPreKey),
        'signedPreKeySignature': base64Encode(bundle.signedPreKeySignature),
        'oneTimePreKeys': bundle.oneTimePreKeys
            .map((key) => {
                  'id': key.id,
                  'publicKey': base64Encode(key.publicKey),
                  'signature': base64Encode(key.signature),
                })
            .toList(growable: false),
      });

  static PreKeyBundle decode(String encoded) {
    final json = jsonDecode(encoded);
    if (json is! Map<String, dynamic>) throw const FormatException('Invalid pre-key bundle');
    final keys = json['oneTimePreKeys'];
    if (keys is! List) throw const FormatException('Invalid one-time pre-key list');
    return PreKeyBundle(
      version: json['version'] as int,
      identityKey: base64Decode(json['identityKey'] as String),
      signedPreKey: base64Decode(json['signedPreKey'] as String),
      signedPreKeySignature: base64Decode(json['signedPreKeySignature'] as String),
      oneTimePreKeys: keys.map((item) {
        final key = item as Map<String, dynamic>;
        return OneTimePreKey(
          id: key['id'] as int,
          publicKey: Uint8List.fromList(base64Decode(key['publicKey'] as String)),
          signature: Uint8List.fromList(base64Decode(key['signature'] as String)),
        );
      }).toList(growable: false),
    );
  }
}
