import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerEvent {}

class PlayerInitEvent extends PlayerEvent {
  PlayerInitEvent();
}

class SetPlayer extends PlayerEvent {
  PlayerData player;
  SetPlayer({required this.player});
}

//--------------------------------------------------------

abstract class PlayerState {
  final PlayerData player;
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
  late PlayerData? player;

  PlayerBloc() : super(PlayerInit(player: PlayerData.defult())) {
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

class PlayerData {
  final String name;
  final String id;
  PlayerData({required this.name, required this.id});

  factory PlayerData.defult() {
    return PlayerData(name: "NA", id: "0");
  }

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      id: json['id'] ?? "0",
      name: json['name'] ?? "NAs",
    );
  }
}
