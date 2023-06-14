import 'package:flutter/material.dart';
import 'package:flutter_skeleton/view/screens/iscreen.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Screens.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(body: SizedBox()),
    );
  }
}
