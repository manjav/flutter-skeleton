import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/core/account.dart';

class AccountEvent {}

class AccountInitEvent extends AccountEvent {
  AccountInitEvent();
}

class SetAccount extends AccountEvent {
  Account account;
  SetAccount({required this.account});
}

//--------------------------------------------------------

abstract class AccountState {
  final Account account;
  AccountState({required this.account});
}

class AccountInit extends AccountState {
  AccountInit({required super.account});
}

class AccountUpdate extends AccountState {
  AccountUpdate({required super.account});
}

//--------------------------------------------------------

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  late Account? account;

  AccountBloc() : super(AccountInit(account: Account())) {
    on<SetAccount>(setAccount);
  }

  setAccount(SetAccount event, Emitter<AccountState> emit) {
    account = event.account;
    emit(AccountUpdate(account: account!));
  }
}
