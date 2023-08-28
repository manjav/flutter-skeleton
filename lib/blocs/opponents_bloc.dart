import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/core/ranking.dart';

class OpponentsEvent {}

class OpponentsInitEvent extends OpponentsEvent {
  OpponentsInitEvent();
}

class SetOpponents extends OpponentsEvent {
  List<Opponent> list;
  SetOpponents({required this.list});
}

//--------------------------------------------------------

abstract class OpponentsState {
  final List<Opponent> list;
  OpponentsState({required this.list});
}

class OpponentsInit extends OpponentsState {
  OpponentsInit({required super.list});
}

class OpponentsUpdate extends OpponentsState {
  OpponentsUpdate({required super.list});
}

//--------------------------------------------------------

class OpponentsBloc extends Bloc<OpponentsEvent, OpponentsState> {
  List<Opponent>? list;
  OpponentsBloc() : super(OpponentsInit(list: <Opponent>[])) {
    on<SetOpponents>(setOpponents);
  }

  setOpponents(SetOpponents event, Emitter<OpponentsState> emit) {
    list = event.list;
    emit(OpponentsUpdate(list: list!));
  }
}
