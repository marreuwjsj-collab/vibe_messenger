import 'dart:convert';
import 'dart:typed_data';
import '../../features/messages/domain/e2ee_session.dart';

final class E2eeSessionCodec {
  static const int version = 2;
  static String encode(E2eeSessionState s) => jsonEncode({'v':version,'sid':s.sessionId,'peer':s.peerKeyId,'role':s.role.name,'root':base64UrlEncode(s.rootKey),'send':base64UrlEncode(s.sendChainKey),'recv':base64UrlEncode(s.receiveChainKey),'sc':s.sendCounter,'rc':s.receiveCounter,'skip':{for(final e in s.skippedMessageKeys.entries)e.key.toString():base64UrlEncode(e.value)}});
  static E2eeSessionState decode(String raw){
    final m=jsonDecode(raw); if(m is! Map<String,dynamic>||m['v']!=version)throw const FormatException('Unsupported E2EE session snapshot');
    final r=m['role']=='initiator'?E2eeRole.initiator:m['role']=='responder'?E2eeRole.responder:null; if(r==null)throw const FormatException('Invalid E2EE role');
    final sr=m['skip']; if(sr is! Map)throw const FormatException('Invalid skipped-key state'); final skip=<int,Uint8List>{};
    for(final e in sr.entries){final n=int.tryParse(e.key.toString());if(n==null||n<0||e.value is! String)throw const FormatException('Invalid skipped-key entry');final k=Uint8List.fromList(base64Url.decode(e.value as String));if(k.length!=32)throw const FormatException('Invalid skipped-key length');skip[n]=k;if(skip.length>256)throw const FormatException('Too many skipped keys');}
    return E2eeSessionState(sessionId:m['sid'] as String,peerKeyId:m['peer'] as String,role:r,rootKey:_key(m['root']),sendChainKey:_key(m['send']),receiveChainKey:_key(m['recv']),sendCounter:m['sc'] as int,receiveCounter:m['rc'] as int,skippedMessageKeys:skip);
  }
  static Uint8List _key(Object? v){if(v is! String)throw const FormatException('Missing E2EE key');final k=Uint8List.fromList(base64Url.decode(v));if(k.length!=32)throw const FormatException('Invalid E2EE key length');return k;}
}
