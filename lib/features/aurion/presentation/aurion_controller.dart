import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/aurion_message.dart';
final aurionRepositoryProvider = Provider<AurionRepository>((ref) => DemoAurionRepository());
final aurionProvider = AsyncNotifierProvider<AurionController, List<AurionMessage>>(AurionController.new);
final class AurionController extends AsyncNotifier<List<AurionMessage>> {
  @override Future<List<AurionMessage>> build() async => const [];
  Future<void> send(String text) async {
    final current = [...state.valueOrNull ?? const <AurionMessage>[], AurionMessage(role: AurionRole.user, content: text)];
    state = AsyncData(current);
    final buffer = StringBuffer();
    await for (final chunk in ref.read(aurionRepositoryProvider).send(current)) { buffer.write(chunk); }
    state = AsyncData([...current, AurionMessage(role: AurionRole.assistant, content: buffer.toString().trim())]);
  }
}
