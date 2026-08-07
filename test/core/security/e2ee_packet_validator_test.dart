import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/security/e2ee_packet_validator.dart';

void main(){
  test('accepts valid packet metadata',(){final p=Uint8List.fromList(utf8.encode(jsonEncode({'v':1,'sid':'s','n':3,'p':{}})));final x=const E2eePacketValidator().parse(p);expect(x.sessionId,'s');expect(x.counter,3);});
  test('rejects malformed metadata',()=>expect(()=>const E2eePacketValidator().parse(Uint8List.fromList(utf8.encode('{"v":1,"sid":"","n":-1,"p":{}}'))),throwsFormatException));
}
