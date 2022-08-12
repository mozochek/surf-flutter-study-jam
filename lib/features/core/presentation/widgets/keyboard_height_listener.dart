import 'package:flutter/material.dart';

typedef KeyboardHeightChangesCallback = Function(double keyboardHeight, double heightDiff);

class KeyboardHeightChangesListener extends StatefulWidget {
  final Widget child;

  /// Передаёт значение, равное разнице значений высоты клавиатуры между предыдущим и текущим вызовами.
  ///
  /// Примеры:
  ///
  /// При первом вызове высота клавиатуры была 100.0, при втором - 120.0.
  /// Первый callback вернёт значения [keyboardHeight] = 100.0, [heightDiff] = 100.0
  /// Второй callback вернёт значение [keyboardHeight] = 120.0, [heightDiff] = 20.0(120.0 - 100.0).
  ///
  /// При первом вызове высота клавиатуры была 200.0, при втором - 150.0.
  /// Первый callback вернёт значения [keyboardHeight] = 200.0, [heightDiff] = 200.0.
  /// Второй callback вернёт значения [keyboardHeight] = 150.0, [heightDiff] = -50.0(150.0 - 200.0).
  final KeyboardHeightChangesCallback onKeyboardHeightChanged;

  const KeyboardHeightChangesListener({
    required this.child,
    required this.onKeyboardHeightChanged,
    Key? key,
  }) : super(key: key);

  @override
  KeyboardHeightChangesListenerState createState() => KeyboardHeightChangesListenerState();
}

class KeyboardHeightChangesListenerState extends State<KeyboardHeightChangesListener> with WidgetsBindingObserver {
  late double _lastKeyboardHeight;

  @override
  void initState() {
    super.initState();

    _lastKeyboardHeight = .0;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    final window = WidgetsBinding.instance.window;
    final currentKeyboardHeight = EdgeInsets.fromWindowPadding(window.viewInsets, window.devicePixelRatio).bottom;

    if (_lastKeyboardHeight != currentKeyboardHeight) {
      widget.onKeyboardHeightChanged(currentKeyboardHeight, currentKeyboardHeight - _lastKeyboardHeight);
      _lastKeyboardHeight = currentKeyboardHeight;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
