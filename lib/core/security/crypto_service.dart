import 'package:cryptography/cryptography.dart';

final class CryptoService {
  final X25519 _x25519 = X25519();
  final Chacha20.poly1305Aead _aead = Chacha20.poly1305Aead();
  Future<KeyPair> generateKeyPair() => _x25519.newKeyPair();
  Future<SimplePublicKey> publicKey(KeyPair pair) => pair.extractPublicKey();
  Future<SecretKey> deriveSecret({required KeyPair localKeyPair, required SimplePublicKey remotePublicKey}) => _x25519.sharedSecretKey(keyPair: localKeyPair, remotePublicKey: remotePublicKey);
  Future<SecretBox> encrypt(List<int> data, SecretKey key) => _aead.encrypt(data, secretKey: key);
  Future<List<int>> decrypt(SecretBox box, SecretKey key) => _aead.decrypt(box, secretKey: key);
}
