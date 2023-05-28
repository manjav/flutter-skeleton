import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final OverlayEntry overlay;
  const MainScreen({super.key, required this.overlay});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2))
          .then((value) => widget.overlay.remove());
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(body: FlutterLogo()),
    );
  }
}
