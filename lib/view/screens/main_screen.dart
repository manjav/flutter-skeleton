import 'package:flutter/material.dart';
import 'package:flutter_skeleton/view/screens/iscreen.dart';

class MainScreen extends AbstractScreen {
  MainScreen({super.key}) : super(Screens.home);

  @override
  createState() => _MainScreenState();
}

class _MainScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(body: FlutterLogo()),
    );
  }
}
