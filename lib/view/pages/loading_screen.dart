import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/services/localization_service.dart';
import 'package:rive/rive.dart';

import '../../blocs/services_bloc.dart';
import '../../utils/utils.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  SMIBool? _closeInput;
  late OverlayEntry _overlayEntry;

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
          return Center(
            child: Column(
              children: [
                Text("${state.adsService}"),
                Text("${state.analyticsService}"),
                Text("${state.gameApiService}"),
                Text("${((state.localizationService) as ILocalization).dir}"),
                Text("${state.networkService}"),
                Text("${state.soundService}"),
              ],
            ),
          );
        },
      ),
    )));
  }

  showOverlay(BuildContext context) async {
    // showOverlay(context);
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
        builder: (context) => Center(
              child: RiveAnimation.asset('anims/${Asset.prefix}loading.riv',
                  onInit: (Artboard artboard) {
                final controller = StateMachineController.fromArtboard(
                  artboard,
                  'Loading',
                  onStateChange: (state, animation) {
                    print("---$animation");
                  },
                );
                controller!.findInput<bool>('close') as SMIBool;
                _closeInput = controller.findInput<bool>('close') as SMIBool;
                artboard.addController(controller);
              }, fit: BoxFit.fitWidth),
            ));

    overlay.insert(_overlayEntry);
    // await Future.delayed(Duration(seconds: 2));
  }

  loadServices(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay(context));

    var services = BlocProvider.of<ServicesBloc>(context);
    await services.initialize();
    // Device.init(MediaQuery.of(context).size); //TODO move this into services bloc
    _closeInput?.value = true;

    await Future.delayed(const Duration(seconds: 2));
    _overlayEntry.remove();

    // Navigator.pushReplacement(context, MaterialPageRoute(builder: builder));
    return true;
  }
}
