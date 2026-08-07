import 'dart:convert';
import 'dart:typed_data';
import 'e2ee_protocol_limits.dart';

final class E2eePacketValidator {
  const E2eePacketValidator();
  ({String sessionId,int counter,Map<String,dynamic> payload}) parse(Uint8List packet){
    if(packet.isEmpty||packet.length>E2eeProtocolLimits.maxPacketBytes)throw const FormatException('Invalid E2EE packet size');
    final decoded=jsonDecode(utf8.decode(packet));
    if(decoded is! Map<String,dynamic>||decoded['v']!=1||decoded['sid'] is! String||decoded['n'] is! int||decoded['p'] is! Map)throw const FormatException('Malformed E2EE packet');
    final sid=decoded['sid'] as String;final n=decoded['n'] as int;if(sid.isEmpty||sid.length>E2eeProtocolLimits.maxSessionIdBytes||n<0)throw const FormatException('Invalid E2EE packet metadata');
    return(sessionId:sid,counter:n,payload:Map<String,dynamic>.from(decoded['p'] as Map));
  }
}
