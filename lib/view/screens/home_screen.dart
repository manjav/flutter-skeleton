import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/core/account.dart';

import '../../blocs/account_bloc.dart';
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
    var bloc = BlocProvider.of<AccountBloc>(context);

    bloc.account!.loadingState = AccountLoadingState.complete;
    bloc.add(SetAccount(account: bloc.account!));
  }
}
