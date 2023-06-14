import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerEvent {}

class PlayerInitEvent extends PlayerEvent {
  PlayerInitEvent();
}

class SetPlayer extends PlayerEvent {
  Player player;
  SetPlayer({required this.player});
}

//--------------------------------------------------------

abstract class PlayerState {
  final Player player;
  PlayerState({required this.player});
}

class PlayerInit extends PlayerState {
  PlayerInit({required super.player});
}

class PlayerUpdate extends PlayerState {
  PlayerUpdate({required super.player});
}

//--------------------------------------------------------

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  late Player? player;

  PlayerBloc() : super(PlayerInit(player: Player.defult())) {
    on<SetPlayer>(setPlayer);
  }

  // Future getPlayerDataFromAPI(Response playerData) async {
  // Response playerData = await CustomHttpService.loadData();
  // player = Player.fromJson(playerData.getData);

  // ignore: invalid_use_of_visible_for_testing_member
  // emit(PlayerUpdate(player: player!));
  // }

  setPlayer(SetPlayer event, Emitter<PlayerState> emit) {
    player = event.player;
    emit(PlayerUpdate(player: player!));
  }
}

/// TODO added by hamiiid
class Player {
  final String name;
  final int id;
  Player({required this.name, required this.id});

  factory Player.defult() {
    return Player(name: "NA", id: 0);
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? 0,
      name: json['name'] ?? "NAs",
    );
  }
}
