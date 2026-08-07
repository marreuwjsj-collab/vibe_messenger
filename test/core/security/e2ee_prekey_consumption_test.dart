import 'package:flutter_test/flutter_test.dart';
import '../../../lib/core/security/e2ee_prekey_registry.dart';

void main(){
  test('one-time registry consumes only once',() async {final r=MemoryE2eePreKeyRegistry();expect(await r.tryConsume('k'),isTrue);expect(await r.tryConsume('k'),isFalse);});
  test('once refuses a previously consumed key',() async {final r=MemoryE2eePreKeyRegistry();final c=E2eePreKeyConsumption(r);expect(await c.once('k',()=>Future.value(7)),7);expect(()=>c.once('k',()=>Future.value(8)),throwsStateError);});
}
