import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/services.dart';
import '../../view/screens/iscreen.dart';
import '../navigation_route.dart';
import '../overlays/ioverlay.dart';

class LoadingScreen extends AbstractScreen {
  LoadingScreen({super.key}) : super(Routes.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  void onRender(Duration timeStamp) {
    Overlays.insert(context, OverlayType.loading);
    BlocProvider.of<Services>(context).initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
