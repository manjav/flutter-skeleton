import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/services_provider.dart';
import '../../services/routes.dart';
import '../overlays/overlay.dart';
import 'screen.dart';

class LoadingScreen extends AbstractScreen {
  LoadingScreen({super.key}) : super(Routes.home, args: {});

  @override
  createState() => _LoadingScreenState();
}

class _LoadingScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  void onRender(Duration timeStamp) {
    Overlays.insert(context, OverlayType.loading);
    context.read<ServicesProvider>().initialize(context);
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
