final class ReplayGuard {
  final int windowSize;
  final Map<String, int> _highest = <String, int>{};

  ReplayGuard({this.windowSize = 128});

  bool accept(String sessionId, int counter) {
    final previous = _highest[sessionId];
    if (previous == null) {
      _highest[sessionId] = counter;
      return true;
    }
    if (counter <= previous - windowSize) return false;
    if (counter > previous) _highest[sessionId] = counter;
    return true;
  }

  void reset(String sessionId) => _highest.remove(sessionId);
}
