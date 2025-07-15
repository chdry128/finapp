import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double value;
  const ProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      color: value > 1 ? Colors.red : Colors.green,
    );
  }
}
