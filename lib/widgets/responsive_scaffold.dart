import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  const ResponsiveScaffold({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: SizedBox(
          width: isWide ? 600 : double.infinity,
          child: body,
        ),
      ),
    );
  }
}