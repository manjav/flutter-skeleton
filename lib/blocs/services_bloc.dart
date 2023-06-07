import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/core/integrated_services.dart';

class ServicesEvent {}

//--------------------------------------------------------

abstract class ServicesState {
  final IntegratedServices integratedServices;

  ServicesState({required this.integratedServices});
}

class ServicesInit extends ServicesState {
  ServicesInit({required super.integratedServices});
}

class ServicesUpdate extends ServicesState {
  ServicesUpdate({required super.integratedServices});
}

//--------------------------------------------------------

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  IntegratedServices integratedServices;

  ServicesBloc({required this.integratedServices})
      : super(ServicesInit(integratedServices: integratedServices)) {
    // on<ServicesEvent>(update);
  }

  initialize() async {
    integratedServices.init();
  }
}
