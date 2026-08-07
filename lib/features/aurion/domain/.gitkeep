enum AurionRole { user, assistant }
class AurionMessage { final AurionRole role; final String content; const AurionMessage({required this.role, required this.content}); }
abstract interface class AurionRepository { Stream<String> send(List<AurionMessage> history); }
final class DemoAurionRepository implements AurionRepository {
  @override Stream<String> send(List<AurionMessage> history) async* {
    const text = 'Aurion готов. Подключение AI-провайдера будет выполнено через transport layer.';
    for (final word in text.split(' ')) { await Future<void>.delayed(const Duration(milliseconds: 25)); yield '$word '; }
  }
}
