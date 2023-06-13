import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/services_bloc.dart';
import '../../view/screens/iscreen.dart';

class LoadingScreen extends AbstractScreen {
  LoadingScreen({super.key}) : super(Screens.loading);

  @override
  createState() => _LoadingScreenState();
}

class _LoadingScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  void initState() {
    loadServices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: SizedBox(
      child: BlocBuilder<ServicesBloc, ServicesState>(
        builder: (context, state) {
          return const SizedBox();
        }
      ),
    )));
  }

  loadServices() async {
    await BlocProvider.of<ServicesBloc>(context).initialize();
  }
}
