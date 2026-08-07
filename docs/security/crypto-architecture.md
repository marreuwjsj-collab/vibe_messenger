# Vibe cryptographic architecture

## Target

Vibe uses a crypto-agile, hybrid post-quantum design. Message content is encrypted locally before transport and storage. The server is treated as an untrusted relay for ciphertext.

## PQ primitives

- **ML-KEM-768 (FIPS 203)** for post-quantum key encapsulation.
- **ML-DSA-65 (FIPS 204)** for post-quantum identity/message signatures where signatures are required.
- **AES-256-GCM** for bulk authenticated encryption.
- **HKDF-SHA-256** for deriving symmetric keys from protocol key material.

NIST finalized ML-KEM, ML-DSA and SLH-DSA as its initial PQC standards. ML-KEM-768 is the planned default for Vibe's E2EE session layer; algorithm identifiers are versioned so they can be migrated later. See FIPS 203/204 and NIST PQC guidance.

## Hybrid rule

Where a classical agreement is retained for interoperability, its secret is combined with the independent ML-KEM secret through HKDF. We do not claim that concatenation alone is a secure combiner.

## E2EE boundaries

Encryption must occur before:

1. network transport;
2. local message cache/database persistence;
3. attachment upload;
4. backup/export;
5. notification payload generation.

Push notifications must contain only opaque identifiers or generic wake-up data. Plaintext message content must never be sent through the push provider.

## Key lifecycle

Each identity has long-term authentication keys and rotating session/pre-key material. Session keys are scoped by protocol version, conversation ID, sender/recipient key IDs and message counter. Forward secrecy and post-compromise recovery are requirements of the final ratcheting protocol; this current layer is only the primitive boundary and is **not yet the completed ratchet**.

## Security constraints

- Never implement ML-KEM, ML-DSA, X25519, AES-GCM, HKDF or a ratchet from scratch in application code.
- Never reuse a nonce with the same AES-GCM key.
- Never use a password directly as an encryption key.
- Never log plaintext, keys, seeds, ciphertext keys or authentication material.
- All cryptographic protocol formats must be versioned and domain-separated.
- Malformed ciphertext/signatures must fail closed.
- Cryptographic claims require KAT/interoperability tests and an external audit before production security claims.

## Current status

The repository now contains the PQC abstraction, ML-KEM-768 and ML-DSA-65 adapters, AES-256-GCM envelope encryption and HKDF hybrid combiner. The full E2EE protocol still needs identity verification, prekeys, ratchet state, key rotation, multi-device handling, group key management and a security audit.
