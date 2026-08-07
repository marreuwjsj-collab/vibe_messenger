final class E2eeProtocolLimits {
  static const maxPacketBytes=24*1024*1024;
  static const maxPlaintextBytes=16*1024*1024;
  static const maxSkippedKeys=256;
  static const maxFutureGap=4096;
  static const maxSessionIdBytes=128;
  static const maxKeyIdBytes=256;
  const E2eeProtocolLimits._();
}
