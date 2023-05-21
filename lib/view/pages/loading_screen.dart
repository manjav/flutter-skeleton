import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/utils/device.dart';
import 'package:rive/rive.dart';

import '../../blocs/services_bloc.dart';
import '../../utils/utils.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  loadServices(BuildContext context) async {
    var services = BlocProvider.of<ServicesBloc>(context);
    await services.initialize();
    // Device.init(MediaQuery.of(context).size); //TODO move this into services bloc
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: FutureBuilder(
          future: loadServices(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              return Center(
                  child: Column(
                children: [
                  BlocBuilder<ServicesBloc, ServicesState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          Text("${state.adsService}"),
                          Text("${state.analyticsService}"),
                          Text("${state.gameApiService}"),
                          Text("${state.localizationService}"),
                          Text("${state.networkService}"),
                          Text("${state.soundService}"),
                        ],
                      );
                    },
                  ),
                ],
              ));
            }
            return Center(
              child: RiveAnimation.asset('anims/${Asset.prefix}loading.riv',
                  onInit: (Artboard artboard) {
                final controller = StateMachineController.fromArtboard(
                  artboard,
                  'Loading',
                  onStateChange: (state, animation) {},
                );
                // _closeInput = controller!.findInput<bool>('close') as SMIBool;
                artboard.addController(controller!);
              }, fit: BoxFit.fitWidth),
            );
          }),
    ));
  }
}
