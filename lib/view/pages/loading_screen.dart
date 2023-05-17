import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/services_bloc.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    var a = BlocProvider.of<ServicesBloc>(context);

    a.servicesInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
          child: Column(
        children: [
          FloatingActionButton(
            onPressed: () async {},
            child: const Text("Save"),
          ),
          FloatingActionButton(
            onPressed: () async {},
            child: const Text("load"),
          ),
          // BlocBuilder<AdsBloc, AdsState>(
          //   builder: (context, state) {
          //     return Text(
          //         "AnalyticsState value ${state.value} value ${state.type}");
          //   },
          // ),
        ],
      )),
    ));
  }
}
