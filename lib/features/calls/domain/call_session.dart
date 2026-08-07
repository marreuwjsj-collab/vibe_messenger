enum CallType { audio, video }
enum CallState { idle, ringing, connecting, connected, ended, failed }
class CallSession { final String id; final String chatId; final CallType type; final CallState state; const CallSession({required this.id, required this.chatId, required this.type, this.state = CallState.idle}); }
abstract interface class CallRepository { Future<void> start(CallSession session); Future<void> end(String callId); }
