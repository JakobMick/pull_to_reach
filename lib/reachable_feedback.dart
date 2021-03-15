import 'package:flutter/services.dart';

abstract class ReachableFeedback {
  void onFocus(int index);

  void onSelect(int index);
}

class HapticReachableFeedback implements ReachableFeedback {
  final bool Function(int index)? shouldVibrateOnFocus;
  final bool Function(int index)? shouldVibrateOnSelect;

  HapticReachableFeedback({
    this.shouldVibrateOnFocus,
    this.shouldVibrateOnSelect,
  });

  @override
  void onFocus(int index) async {
    if (shouldVibrateOnFocus == null || shouldVibrateOnFocus!(index)) {
      await SystemChannels.platform.invokeMethod(
        'HapticFeedback.vibrate',
        'HapticFeedbackType.lightImpact',
      );
    }
  }

  @override
  void onSelect(int index) async {
    if (shouldVibrateOnSelect == null || shouldVibrateOnSelect!(index)) {
      await SystemChannels.platform.invokeMethod(
        'HapticFeedback.vibrate',
        'HapticFeedbackType.heavyImpact',
      );
    }
  }
}
