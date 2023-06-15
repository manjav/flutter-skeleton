import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/player_bloc.dart';
import '../../view/screens/iscreen.dart';

class HomeScreen extends AbstractScreen {
  HomeScreen({super.key}) : super(Screens.home);

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  void onRender(Duration timeStamp) {
    super.onRender(timeStamp);
    var bloc = BlocProvider.of<PlayerBloc>(context);

    bloc.player!.loadinfState = PlayerLoadingState.complete;
    bloc.add(SetPlayer(player: bloc.player!));
  }
}
