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
    loadServices(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: SizedBox(
      child: BlocBuilder<ServicesBloc, ServicesState>(
        builder: (context, state) {
          return const SizedBox();
        },
      ),
    )));
  }

  loadServices(BuildContext context) async {
    var services = BlocProvider.of<ServicesBloc>(context);
    await services.initialize();
    await Future.delayed(const Duration(seconds: 1)).then((value) {});
  }
}
