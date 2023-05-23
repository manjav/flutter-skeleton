import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            child: Stack(
              children: [
                Center(
                  child: RiveAnimation.asset('anims/${Asset.prefix}map.riv',
                      onInit: (Artboard artboard) {
                    final controller = StateMachineController.fromArtboard(
                      artboard,
                      'Map',
                      onStateChange: (state, animation) {
                        debugPrint("---$animation");
                      },
                    );
                    controller!.findInput<int>('mine')?.value = 3;
                    controller.findInput<int>('military')?.value = 3;

                    // _closeInput = controller.findInput<bool>('close') as SMIBool;
                    artboard.addController(controller);
                  }, fit: BoxFit.fitWidth),
                ),
                CupertinoButton(
                    child: Text("data"),
                    onPressed: () {
                      setState(() {});
                    })
              ],
            ),
          );
        },
      ),
    )));
  }

  showLoadingOverlay(BuildContext context) async {
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
                    debugPrint("---$animation");
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => showLoadingOverlay(context));

    var services = BlocProvider.of<ServicesBloc>(context);
    await services.initialize();
    // Device.init(MediaQuery.of(context).size); //TODO move this into services bloc
    _closeInput?.value = true;

    await Future.delayed(const Duration(seconds: 1)).then((value) {
      _overlayEntry.remove();
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => const MainScreen()));
    });
  }
}
