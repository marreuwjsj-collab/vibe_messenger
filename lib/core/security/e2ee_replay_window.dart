final class E2eeReplayWindow {
  final int maxForwardDistance;
  int highest = -1;
  final Set<int> _seen = <int>{};

  E2eeReplayWindow({this.maxForwardDistance = 4096}) {
    if (maxForwardDistance <= 0) throw ArgumentError.value(maxForwardDistance, 'maxForwardDistance');
  }

  bool accept(int counter) {
    if (counter < 0) return false;
    if (highest >= 0 && counter > highest + maxForwardDistance) return false;
    if (_seen.contains(counter)) return false;
    _seen.add(counter);
    if (counter > highest) highest = counter;
    final floor = highest - maxForwardDistance;
    _seen.removeWhere((value) => value < floor);
    return true;
  }
}
